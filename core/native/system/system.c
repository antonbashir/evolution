#include "system.h"
#include <crash/crash.h>
#include <events/events.h>
#include <events/field.h>
#include <printer/printer.h>
#include <stacktrace/stacktrace.h>

struct system system_instance;

void system_default_printer(const char* format, ...)
{
    va_list arguments;
    va_start(arguments, format);
    vfprintf(stdout, format, arguments);
    va_end(arguments);
}

void system_default_error_printer(const char* format, ...)
{
    va_list arguments;
    va_start(arguments, format);
    vfprintf(stderr, format, arguments);
    va_end(arguments);
}

void system_default_event_printer(struct event* event)
{
    if (system_get()->configuration.print_level < event->level) return;
    const char* buffer = event_format(event);
    system_get()->configuration.on_print(STRING_FORMAT NEW_LINE, buffer);
    free((void*)buffer);
    if (event->level <= EVENT_LEVEL_ERROR)
    {
        stacktrace_print(0);
    }
    event_destroy(event);
}

void system_default_event_raiser(struct event* event)
{
    if (system_get()->configuration.print_level < event->level) return;
    system_get()->configuration.on_print(STRING_FORMAT NEW_LINE, event_format(event));
    stacktrace_print(0);
    exit(event_has_field(event, EVENT_FIELD_CODE) ? event_get_unsigned(event, EVENT_FIELD_CODE) : -1);
    unreachable();
}

void system_initialize(struct system_configuration configuration)
{
    if (system_instance.initialized) return;
    system_instance.libraries = table_system_libraries_new();
    system_instance.environment = table_string_values_new();
    system_instance.configuration = configuration;
    crash_initialize();
    hasher_initialize_default();
    system_instance.initialized = true;
}

struct system_library* system_library_load(const char* path, const char* module)
{
    struct system_library* current = system_library_get(path);
    if (current != NULL)
    {
        return current;
    }
    void* handle = dlopen(path, RTLD_GLOBAL | RTLD_LAZY);
    if (handle == NULL)
    {
        return NULL;
    }
#ifdef TRACE
    trace_message(LOADING_LIBRARY_MESSAGE, path);
#endif
    struct system_library* new = calloc(1, sizeof(struct system_library));
    new->handle = handle;
    new->path = strdup(path);
    new->module = strdup(module);
    table_system_libraries_put(system_instance.libraries, new, NULL, NULL);
    return new;
}

DART_LEAF_FUNCTION void system_library_put(struct system_library* library)
{
    table_system_libraries_put(system_instance.libraries, library, NULL, NULL);
}

struct system_library* system_library_get(const char* path)
{
    return safe_pointer(table_system_libraries_find_value(system_instance.libraries, path));
}

struct system_library* system_library_by_module(const char* module)
{
    table_int_t slot;
    table_foreach(system_instance.libraries, slot)
    {
        if (slot != table_end(system_instance.libraries))
        {
            struct system_library* library = *table_system_libraries_node(system_instance.libraries, slot);
            if (strcmp(library->module, module) == 0) return library;
        }
    }
    return NULL;
}

struct system_library* system_library_reload(const struct system_library* library)
{
    const char* path = library->path;
    const char* module = library->module;
    system_library_unload(library);
    return system_library_load(path, module);
}

void system_library_unload(const struct system_library* library)
{
    if (library->handle != NULL)
    {
        dlclose(library->handle);
    }
    table_system_libraries_remove(system_instance.libraries, &library, NULL);
    free((void*)library->module);
    free((void*)library->path);
    free((void*)library);
}

void system_set_environment(const char* key, const char* value)
{
    struct string_value_pair pair = {
        .key = strdup(key),
        .value = strdup(value),
    };
    table_string_values_put_copy(system_instance.environment, &pair, NULL, NULL);
}

const char* system_get_environment(const char* key)
{
    return safe_field(table_string_values_find_value(system_instance.environment, key), value);
}

struct pointer_array* system_environment_entries()
{
    return table_string_values_keys(system_instance.environment);
}
