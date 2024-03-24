#ifndef STORAGE_TUPLE_H
#define STORAGE_TUPLE_H

#include <stddef.h>
#include "box/port.h"
#include "box/tuple.h"
#include "common/common.h"

DART_TYPE struct storage_tuple;
DART_TYPE struct storage_port_vtab;
DART_TYPE struct storage_tuple_iterator;

DART_STRUCTURE struct storage_tuple_port_entry
{
    DART_FIELD struct storage_tuple_port_entry* next;
    DART_FIELD struct storage_tuple* tuple;
    DART_FIELD uint32_t* message_pack_size;
};
DART_STRUCTURE struct storage_tuple_port
{
    DART_FIELD const struct storage_port_vtab* vtab;
    DART_FIELD struct storage_tuple_port_entry* first;
    DART_FIELD struct storage_tuple_port_entry* last;
    DART_FIELD struct storage_tuple_port_entry first_entry;
    DART_FIELD int size;
};

typedef struct tuple storage_tuple;
typedef struct port storage_tuple_port;
typedef struct tuple_iterator storage_tuple_iterator;
typedef struct port_c_entry storage_tuple_port_entry;

#if defined(__cplusplus)
extern "C"
{
#endif

storage_tuple_port_entry* storage_port_first(storage_tuple_port* port)
{
    return (storage_tuple_port_entry*)&((struct port_c*)port)->first_entry;
}

storage_tuple_port_entry* storage_port_entry_next(storage_tuple_port_entry* current)
{
    return (storage_tuple_port_entry*)current->next;
}

storage_tuple* storage_port_entry_tuple(storage_tuple_port_entry* current)
{
    return (storage_tuple*)current->tuple;
}

DART_INLINE_LEAF_FUNCTION size_t storage_tuple_size(storage_tuple* tuple)
{
    return tuple_size(tuple);
}

DART_INLINE_LEAF_FUNCTION void* storage_tuple_data(storage_tuple* tuple)
{
    return (void*)tuple_data(tuple);
}

DART_INLINE_LEAF_FUNCTION void storage_tuple_release(storage_tuple* tuple)
{
    tuple_unref(tuple);
}

#if defined(__cplusplus)
}
#endif

#endif