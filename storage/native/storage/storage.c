// clang-format off
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