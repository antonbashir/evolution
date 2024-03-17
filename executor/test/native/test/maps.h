#ifndef TEST_MAPS_H
#define TEST_MAPS_H

#include <system/library.h>
#include <executor/task.h>

#ifndef SIMPLE_MAP_SOURCE
#define SIMPLE_MAP_UNDEF
#endif

#define simple_map_name _native_callbacks
struct simple_map_native_callbacks_key_t
{
    uint64_t owner;
    uint64_t method;
};
#define simple_map_key_t struct simple_map_native_callbacks_key_t
struct simple_map_native_callbacks_node_t
{
    simple_map_key_t key;
    void (*callback)(struct executor_task*);
};

#define simple_map_node_t struct simple_map_native_callbacks_node_t
#define simple_map_arg_t uint64_t
#define simple_map_hash(a, arg) (a->key.owner * 31 + a->key.method)
#define simple_map_hash_key(a, arg) (a.owner * 31 + a.method)
#define simple_map_cmp(a, b, arg) ((a->key.owner != b->key.owner) && (a->key.method != b->key.method))
#define simple_map_cmp_key(a, b, arg) ((a.owner != b->key.owner) && (a.method != b->key.method))

#include <maps/simple.h>

#endif
