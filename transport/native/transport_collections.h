#ifndef TRANSPORT_COLLECTIONS_H
#define TRANSPORT_COLLECTIONS_H

#include <stdint.h>

#if defined(__cplusplus)
extern "C"
{
#endif

#ifndef SIMPLE_MAP_SOURCE
#define SIMPLE_MAP_UNDEF
#endif

struct simple_map_events_node_t
{
    uint64_t data;
    int64_t timeout;
    uint64_t timestamp;
    int32_t fd;
};

#define simple_map_name _events
#define simple_map_key_t uint64_t
#define simple_map_node_t struct simple_map_events_node_t
#define simple_map_arg_t uint64_t
#define simple_map_hash(a, arg) (a->data)
#define simple_map_hash_key(a, arg) (a)
#define simple_map_cmp(a, b, arg) ((a->data) != (b->data))
#define simple_map_cmp_key(a, b, arg) ((a) != (b->data))
#include <maps/simple.h>

#if defined(__cplusplus)
}
#endif

#endif
