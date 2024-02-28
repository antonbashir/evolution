#ifndef TARANTOOL_TUPLE_H
#define TARANTOOL_TUPLE_H

#include <stddef.h>

typedef struct tuple tarantool_tuple;
typedef struct port tarantool_tuple_port;
typedef struct tuple_iterator tarantool_tuple_iterator;
typedef struct port_c_entry tarantool_tuple_port_entry;

#if defined(__cplusplus)
extern "C"
{
#endif
    tarantool_tuple_port_entry* tarantool_port_first(tarantool_tuple_port* port);
    tarantool_tuple_port_entry* tarantool_port_entry_next(tarantool_tuple_port_entry* current);
    tarantool_tuple* tarantool_port_entry_tuple(tarantool_tuple_port_entry* current);
    size_t tarantool_tuple_size(tarantool_tuple* tuple);
    void* tarantool_tuple_data(tarantool_tuple* tuple);
    void tarantool_tuple_release(tarantool_tuple* tuple);
#if defined(__cplusplus)
}
#endif

#endif