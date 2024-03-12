#ifndef MEMORY_TUPLE_H
#define MEMORY_TUPLE_H

#include <common/common.h>
#include <msgpuck.h>
#include <system/library.h>

#if defined(__cplusplus)
extern "C"
{
#endif

DART_INLINE_LEAF_FUNCTION uint64_t memory_tuple_next(uint8_t* buffer, uint64_t offset)
{
    const char* offset_buffer = (const char*)buffer + offset;
    mp_next(&offset_buffer);
    return (uint64_t)(offset_buffer - (const char*)buffer);
}

#if defined(__cplusplus)
}
#endif

#endif
