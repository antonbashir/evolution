#ifndef TEST_MAPS_H
#define TEST_MAPS_H

#include <system/library.h>
#include <executor/task.h>

#ifndef TABLE_SOURCE
#define TABLE_UNDEF
#endif

#define table_name _native_callbacks
struct table_native_callbacks_key_t
{
    uint64_t owner;
    uint64_t method;
};
#define table_key_t struct table_native_callbacks_key_t
struct table_native_callbacks_node_t
{
    table_key_t key;
    void (*callback)(struct executor_task*);
};

#define table_node_t struct table_native_callbacks_node_t
#define table_arg_t uint64_t
#define table_hash(a, arg) (a->key.owner * 31 + a->key.method)
#define table_hash_key(a, arg) (a.owner * 31 + a.method)
#define table_cmp(a, b, arg) ((a->key.owner != b->key.owner) && (a->key.method != b->key.method))
#define table_cmp_key(a, b, arg) ((a.owner != b->key.owner) && (a.method != b->key.method))

#include <maps/table.h>

#endif
