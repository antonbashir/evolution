#ifndef MEMORY_TUPLE_H
#define MEMORY_TUPLE_H

#include <system/library.h>

#if defined(__cplusplus)
extern "C"
{
#endif

uint64_t memory_tuple_next(const char* buffer, uint64_t offset);

#if defined(__cplusplus)
}
#endif

#endif
