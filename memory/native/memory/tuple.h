#ifndef MEMORY_TUPLE_H
#define MEMORY_TUPLE_H

#include <common/common.h>
#include <msgpuck.h>
#include <system/library.h>

#if defined(__cplusplus)
extern "C"
{
#endif

DART_INLINE uint64_t memory_tuple_next(const char* buffer, uint64_t offset)
{
    const char* offset_buffer = buffer + offset;
    mp_next(&offset_buffer);
    return (uint64_t)(offset_buffer - buffer);
}

#if defined(__cplusplus)
}
#endif

#endif
