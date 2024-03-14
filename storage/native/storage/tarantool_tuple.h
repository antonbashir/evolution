#ifndef TARANTOOL_TUPLE_H
#define TARANTOOL_TUPLE_H

#include <stddef.h>
#include "box/port.h"
#include "box/tuple.h"
#include "common/common.h"

DART_TYPE struct tarantool_tuple;
DART_TYPE struct tarantool_port_vtab;
DART_TYPE struct tarantool_tuple_iterator;
DART_STRUCTURE struct tarantool_tuple_port_entry
{
    DART_FIELD struct tarantool_tuple_port_entry* next;
    DART_FIELD struct tarantool_tuple* tuple;
    DART_FIELD uint32_t* message_pack_size;
};
DART_STRUCTURE struct tarantool_tuple_port
{
    DART_FIELD const struct tarantool_port_vtab* vtab;
    DART_FIELD struct tarantool_tuple_port_entry* first;
    DART_FIELD struct tarantool_tuple_port_entry* last;
    DART_FIELD struct tarantool_tuple_port_entry first_entry;
    DART_FIELD int size;
};

typedef struct tuple tarantool_tuple;
typedef struct port tarantool_tuple_port;
typedef struct tuple_iterator tarantool_tuple_iterator;
typedef struct port_c_entry tarantool_tuple_port_entry;

#if defined(__cplusplus)
extern "C"
{
#endif

tarantool_tuple_port_entry* tarantool_port_first(tarantool_tuple_port* port)
{
    return (tarantool_tuple_port_entry*)&((struct port_c*)port)->first_entry;
}

tarantool_tuple_port_entry* tarantool_port_entry_next(tarantool_tuple_port_entry* current)
{
    return (tarantool_tuple_port_entry*)current->next;
}

tarantool_tuple* tarantool_port_entry_tuple(tarantool_tuple_port_entry* current)
{
    return (tarantool_tuple*)current->tuple;
}

DART_INLINE_LEAF_FUNCTION size_t tarantool_tuple_size(tarantool_tuple* tuple)
{
    return tuple_size(tuple);
}

DART_INLINE_LEAF_FUNCTION void* tarantool_tuple_data(tarantool_tuple* tuple)
{
    return (void*)tuple_data(tuple);
}

DART_INLINE_LEAF_FUNCTION void tarantool_tuple_release(tarantool_tuple* tuple)
{
    tuple_unref(tuple);
}

#if defined(__cplusplus)
}
#endif

#endif