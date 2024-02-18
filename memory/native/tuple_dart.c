
#include <tuple_dart.h>
#include "msgpuck.h"

uint64_t memory_dart_tuple_next(const char* buffer, uint64_t offset)
{
    const char* offset_buffer = buffer + offset;
    mp_next(&offset_buffer);
    return (uint64_t)(offset_buffer - buffer);
}
