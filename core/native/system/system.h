#ifndef CORE_SYSTEM_SYSTEM_H
#define CORE_SYSTEM_SYSTEM_H

#include <bootstrap/bootstrap.h>
#include <collections/maps.h>
#include <events/events.h>
#include <hashing/hashing_64.h>
#include <system/library.h>

#if defined(__cplusplus)
extern "C"
{
#endif

typedef void (*event_raiser_function)(struct event* e);
typedef void (*event_printer_function)(struct event* e);
typedef void (*printer_function)(char const* format, ...);

struct system_configuration
{
    printer_function on_print;
    printer_function on_print_error;
    event_raiser_function on_event_raise;
    event_printer_function on_event_print;
    int8_t print_level;
    struct bootstrap_configuration bootstrap_configuration;
};

struct system
{
    bool initialized;
    struct system_configuration configuration;
    struct simple_map_system_libraries_t* libraries;
    struct simple_map_string_values_t* environment;
};

extern struct system system_instance;

void system_initialize(struct system_configuration configuration);
void system_default_printer(const char* format, ...);
void system_default_error_printer(const char* format, ...);
void system_default_event_printer(struct event* event);
void system_default_event_raiser(struct event* event);

static FORCEINLINE struct system* system_get()
{
    return &system_instance;
}

#define system_print(format, ...)                                  \
    do                                                             \
    {                                                              \
        system_get()->configuration.on_print(format, __VA_ARGS__); \
    }                                                              \
    while (0);

#define system_print_error(format, ...)                                  \
    do                                                                   \
    {                                                                    \
        system_get()->configuration.on_print_error(format, __VA_ARGS__); \
    }                                                                    \
    while (0);

#define system_print_event(event)                          \
    do                                                     \
    {                                                      \
        system_get()->configuration.on_event_print(event); \
    }                                                      \
    while (0);

#define system_raise_event(event)                          \
    do                                                     \
    {                                                      \
        system_get()->configuration.on_event_raise(event); \
    }                                                      \
    while (0);

DART_LEAF_FUNCTION struct system_library* system_library_load(const char* path, const char* module);
DART_LEAF_FUNCTION void system_library_put(struct system_library* library);
DART_LEAF_FUNCTION struct system_library* system_library_get(const char* path);
DART_LEAF_FUNCTION struct system_library* system_library_by_module(const char* module);
DART_LEAF_FUNCTION struct system_library* system_library_reload(const struct system_library* library);
DART_LEAF_FUNCTION void system_library_unload(const struct system_library* library);
DART_LEAF_FUNCTION void system_set_environment(const char* key, const char* value);
DART_LEAF_FUNCTION const char* system_get_environment(const char* key);
DART_LEAF_FUNCTION struct pointer_array* system_environment_entries();

#if defined(__cplusplus)
}
#endif

#endif