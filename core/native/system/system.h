#ifndef CORE_SYSTEM_SYSTEM_H
#define CORE_SYSTEM_SYSTEM_H

#include <events/events.h>
#include <hashing/hashing.h>
#include <system/library.h>

#if defined(__cplusplus)
extern "C"
{
#endif

typedef void (*event_raiser_function)(struct event* e);
typedef void (*event_printer_function)(struct event* e);
typedef void (*printer_function)(char const* format, ...);

#ifndef SIMPLE_MAP_SOURCE
#define SIMPLE_MAP_UNDEF
#endif

#define simple_map_name _system_libraries
struct system_library_key
{
    const char* path;
};
#define simple_map_key_t struct system_library_key
DART_STRUCTURE struct system_library
{
    DART_FIELD const char* path;
    DART_FIELD void* handle;
};
#define simple_map_node_t struct system_library
#define simple_map_hash(node, _) (hash_string(node->path, strlen(node->path)))
#define simple_map_hash_key(key, _) (hash_string(key.path, strlen(key.path)))
#define simple_map_cmp(left_node, right_node, _) (strcmp(left_node->path, right_node->path))
#define simple_map_cmp_key(key, node, _) (strcmp(key.path, node->path))

#include <maps/simple.h>

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

void system_initialize(struct system_configuration configuration);
void system_initialize_default();
void system_default_printer(const char* format, ...);
void system_default_error_printer(const char* format, ...);
void system_default_event_printer(struct event* event);
void system_default_event_raiser(struct event* event);

DART_LEAF_FUNCTION struct system_library* system_library_load(const char* path);
DART_LEAF_FUNCTION struct system_library* system_library_get(const char* path);
DART_LEAF_FUNCTION struct system_library* system_library_reload(struct system_library* library);
DART_LEAF_FUNCTION void system_library_unload(struct system_library* library);

static FORCEINLINE struct system* system_get()
{
    return &system_instance;
}

#if defined(__cplusplus)
}
#endif

#endif