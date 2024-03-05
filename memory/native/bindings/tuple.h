#ifndef MEMORY_BINDINGS_TUPLE_DART_H
#define MEMORY_BINDINGS_TUPLE_DART_H

#include <system/types.h>

#if defined(__cplusplus)
extern "C"
{
#endif
    uint64_t memory_tuple_next(const char* buffer, uint64_t offset);
#if defined(__cplusplus)
}
#endif

#endif
