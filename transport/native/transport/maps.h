#ifndef TRANSPORT_COLLECTIONS_H
#define TRANSPORT_COLLECTIONS_H

#include <system/library.h>

#if defined(__cplusplus)
extern "C"
{
#endif

#ifndef TABLE_SOURCE
#define TABLE_UNDEF
#endif

struct table_transport_event
{
    uint64_t data;
    int64_t timeout;
    uint64_t timestamp;
    int32_t fd;
};

#define table_name _events
#define table_key_t uint64_t
#define table_node_t struct table_transport_event
#define table_arg_t uint64_t
#define table_hash(a, arg) (a->data)
#define table_hash_key(a, arg) (a)
#define table_cmp(a, b, arg) ((a->data) != (b->data))
#define table_cmp_key(a, b, arg) ((a) != (b->data))

#include <maps/table.h>

#if defined(__cplusplus)
}
#endif

#endif
