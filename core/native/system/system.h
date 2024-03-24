#ifndef CORE_SYSTEM_SYSTEM_H
#define CORE_SYSTEM_SYSTEM_H

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
    bool initialized;
    printer_function on_print;
    printer_function on_print_error;
    event_raiser_function on_event_raise;
    event_printer_function on_event_print;
    int8_t print_level;
};

struct system
{
    bool initialized;
    printer_function on_print;
    printer_function on_print_error;
    event_raiser_function on_event_raise;
    event_printer_function on_event_print;
    int8_t print_level;
    struct simple_map_system_libraries_t* system_libraries;
};

extern struct system system_instance;

void system_initialize_default();
void system_initialize(struct system_configuration configuration);

DART_LEAF_FUNCTION struct system_library* system_library_load(const char* path, const char* module);
DART_LEAF_FUNCTION void system_library_put(struct system_library* library);
DART_LEAF_FUNCTION struct system_library* system_library_get(const char* path);
DART_LEAF_FUNCTION struct system_library* system_library_by_module(const char* module);
DART_LEAF_FUNCTION struct system_library* system_library_reload(const struct system_library* library);
DART_LEAF_FUNCTION void system_library_unload(const struct system_library* library);

static FORCEINLINE struct system* system_get()
{
    return &system_instance;
}

#if defined(__cplusplus)
}
#endif

#endif