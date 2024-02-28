#include "tarantool_tuple.h"
#include "box/port.h"
#include "box/tuple.h"

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

size_t tarantool_tuple_size(tarantool_tuple* tuple)
{
    return tuple_size(tuple);
}

void* tarantool_tuple_data(tarantool_tuple* tuple)
{
    return (void*)tuple_data(tuple);
}

void tarantool_tuple_release(tarantool_tuple* tuple)
{
  tuple_unref(tuple);
}