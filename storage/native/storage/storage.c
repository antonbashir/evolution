// clang-format off
#include <msgpuck.h>
#include "diag.h"
#include "trivia/util.h"
#include "storage.h"
#include <executor/executor.h>
#include <lauxlib.h>
#include <lua.h>
#include <luajit.h>
#include <system/library.h>
#include "box.h"
#include "box/box.h"
#include "cbus.h"
#include "constants.h"
#include "executor.h"
#include "launcher.h"
#include "lib/core/fiber.h"
#include "lua/init.h"
#include "on_shutdown.h"
#include "module.h"
#include "diag.h"
#include <system/library.h>
// clang-format on

static struct storage_instance
{
    char* initialization_error;
    char* shutdown_error;
    struct storage_box box;
    pthread_t main_thread_id;
    pthread_mutex_t initialization_mutex;
    pthread_cond_t initialization_condition;
    pthread_mutex_t shutdown_mutex;
    pthread_cond_t shutdown_condition;
    bool initialized;
} storage_instance;

struct storage_initialization_args
{
    const char* binary_path;
    const char* script;
};

struct storage_box* storage_get_box()
{
    return &storage_instance.box;
}

static int32_t storage_shutdown_trigger(void* ignore)
{
    (void)ignore;
    storage_executor_stop();
    ev_break(loop(), EVBREAK_ALL);
    return 0;
}

static int32_t storage_fiber(va_list args)
{
    (void)args;
    int32_t error;
    struct storage_executor_configuration* configuration = &storage()->configuration.executor_configuration;
    if (error = storage_executor_initialize(configuration))
    {
        storage_executor_destroy();
        storage_instance.initialization_error = strerror(error);
        return 0;
    }
    if (error = pthread_mutex_lock(&storage_instance.initialization_mutex))
    {
        storage_executor_destroy();
        storage_instance.initialization_error = strerror(error);
        return 0;
    }
    storage_instance.initialized = true;
    if (error = pthread_cond_broadcast(&storage_instance.initialization_condition))
    {
        storage_executor_destroy();
        storage_instance.initialized = false;
        storage_instance.initialization_error = strerror(error);
        return 0;
    }
    if (error = pthread_mutex_unlock(&storage_instance.initialization_mutex))
    {
        storage_executor_destroy();
        storage_instance.initialized = false;
        storage_instance.initialization_error = strerror(error);
        return 0;
    }
    storage_initialize_box(&storage_instance.box);
    storage_executor_start();
    storage_destroy_box(&storage_instance.box);
    storage_executor_destroy();
    ev_break(loop(), EVBREAK_ALL);
    return 0;
}

static void* storage_process_initialization(void* input)
{
    struct storage_initialization_args* args = (struct storage_initialization_args*)input;

    storage_launcher_launch((char*)args->binary_path);

    int32_t events = ev_activecnt(loop());

    if (tarantool_lua_run_string((char*)args->script) != 0)
    {
        storage_instance.initialization_error = "STORAGE_LUA_ERROR";
        diag_last_error(diag_get())->log(diag_last_error(diag_get()));
        return NULL;
    }

    start_loop = start_loop && ev_activecnt(loop()) > events;

    region_free(&fiber()->gc);

    if (box_on_shutdown(NULL, storage_shutdown_trigger, NULL) != 0)
    {
        storage_instance.initialization_error = strerror(errno);
        return NULL;
    }

    ev_now_update(loop());
    fiber_start(fiber_new(STORAGE_EXECUTOR_FIBER, storage_fiber));
    ev_run(loop(), 0);

    if (storage_instance.initialized)
    {
        int32_t error;
        if (error = pthread_mutex_lock(&storage_instance.shutdown_mutex))
        {
            storage_instance.shutdown_error = strerror(error);
            return NULL;
        }
        storage_launcher_shutdown(0);
        storage_instance.initialized = false;
        if (error = pthread_cond_broadcast(&storage_instance.shutdown_condition))
        {
            storage_instance.shutdown_error = strerror(error);
            return NULL;
        }
        if (error = pthread_mutex_unlock(&storage_instance.shutdown_mutex))
        {
            storage_instance.shutdown_error = strerror(error);
            return NULL;
        }
    }

    free(input);
    return NULL;
}

bool storage_initialize()
{
    struct storage_boot_configuration* configuration = &storage()->configuration.boot_configuration;

    if (storage_instance.initialized)
    {
        return true;
    }

    storage_instance.initialization_error = "";

    struct storage_initialization_args* args = calloc(1, sizeof(struct storage_initialization_args));
    if (args == NULL)
    {
        storage_instance.initialization_error = strerror(ENOMEM);
        return false;
    }

    args->binary_path = configuration->binary_path;
    args->script = configuration->initial_script;

    struct timespec timeout = timeout_seconds(configuration->initialization_timeout_seconds);
    int32_t error;
    if (error = pthread_create(&storage_instance.main_thread_id, NULL, storage_process_initialization, args))
    {
        storage_instance.initialization_error = strerror(error);
        return false;
    }
    if (error = pthread_mutex_lock(&storage_instance.initialization_mutex))
    {
        storage_instance.initialization_error = strerror(error);
        return false;
    }
    while (!storage_instance.initialized)
    {
        if (error = pthread_cond_timedwait(&storage_instance.initialization_condition, &storage_instance.initialization_mutex, &timeout))
        {
            storage_instance.initialization_error = strerror(error);
            return false;
        }
    }
    if (error = pthread_mutex_unlock(&storage_instance.initialization_mutex))
    {
        storage_instance.initialization_error = strerror(error);
        return false;
    }
    if (error = pthread_cond_destroy(&storage_instance.initialization_condition))
    {
        storage_instance.initialization_error = strerror(error);
        return false;
    }
    if (error = pthread_mutex_destroy(&storage_instance.initialization_mutex))
    {
        storage_instance.initialization_error = strerror(error);
        return false;
    }
    return strlen(storage_instance.initialization_error) == 0;
}

bool storage_shutdown()
{
    struct storage_boot_configuration* configuration = &storage()->configuration.boot_configuration;
    if (!storage_instance.initialized)
    {
        return true;
    }
    storage_executor_stop();
    int32_t error;
    if (error = pthread_mutex_lock(&storage_instance.shutdown_mutex))
    {
        storage_instance.shutdown_error = strerror(error);
        return false;
    }
    struct timespec timeout = timeout_seconds(configuration->shutdown_timeout_seconds);
    while (storage_instance.initialized)
    {
        if (error = pthread_cond_timedwait(&storage_instance.shutdown_condition, &storage_instance.shutdown_mutex, &timeout))
        {
            storage_instance.shutdown_error = strerror(error);
            return false;
        }
    }
    if (error = pthread_mutex_unlock(&storage_instance.shutdown_mutex))
    {
        storage_instance.shutdown_error = strerror(error);
        return false;
    }
    if (error = pthread_cond_destroy(&storage_instance.shutdown_condition))
    {
        storage_instance.shutdown_error = strerror(error);
        return false;
    }
    if (error = pthread_mutex_destroy(&storage_instance.shutdown_mutex))
    {
        storage_instance.shutdown_error = strerror(error);
        return false;
    }
    return true;
}

bool storage_initialized()
{
    return storage_instance.initialized;
}

const char* storage_status()
{
    return box_status();
}

int32_t storage_is_read_only()
{
    return box_is_ro() ? 1 : 0;
}

const char* storage_initialization_error()
{
    return storage_instance.initialization_error;
}

const char* storage_shutdown_error()
{
    return storage_instance.shutdown_error;
}

void storage_raiser(struct error* error)
{
    raise_panic(storage_convert_error(error));
}

void storage_say(int level, const char* filename, int line, const char* message)
{
    struct event* event;
    switch (level)
    {
        case S_FATAL:
        case S_SYSERROR:
        case S_ERROR:
        case S_CRIT:
            event = storage_module_event(event_error(event_field_message(message)));
            break;
        case S_WARN:
            event = storage_module_event(event_warning(event_field_message(message)));
            break;
        case S_INFO:
            event = storage_module_event(event_information(event_field_message(message)));
            break;
        case S_VERBOSE:
        case S_DEBUG:
            event = storage_module_event(event_trace(event_field_message(message)));
            break;
    };
    event->file = filename;
    event->line = line;
    system_print_event(event);
}

struct event* storage_convert_error(struct error* error)
{
    struct event* event = storage_module_event(event_panic(event_field_code(error->code), event_field_message(error->errmsg)));
    event->file = error->file;
    event->line = error->line;
    for (size_t i = 0; i < error->payload.count; i++)
    {
        struct error_field* field = error->payload.fields[i];
        const char* data = field->data;
        if (field != NULL)
        {
            switch (mp_typeof(*data))
            {
                case MP_STR: {
                    uint32_t length;
                    const char* data = mp_decode_str(&data, &length);
                    event_set_string(event, field->name, strdup(data));
                    break;
                }
                case MP_UINT: {
                    event_set_unsigned(event, field->name, mp_decode_uint(&data));
                    break;
                }
                case MP_INT: {
                    event_set_signed(event, field->name, mp_decode_int(&data));
                    break;
                }
                case MP_BOOL: {
                    event_set_boolean(event, field->name, mp_decode_bool(&data));
                    break;
                }
                case MP_FLOAT: {
                    event_set_double(event, field->name, mp_decode_float(&data));
                    break;
                }
                case MP_DOUBLE: {
                    event_set_double(event, field->name, mp_decode_double(&data));
                    break;
                }
                case MP_NIL:
                case MP_BIN:
                case MP_ARRAY:
                case MP_MAP:
                case MP_EXT:
                    break;
            }
        }
    }
    return event;
}