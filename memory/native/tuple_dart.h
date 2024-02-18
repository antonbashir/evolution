#ifndef TUPLE_DART_H
#define TUPLE_DART_H

#include <stdint.h>

typedef struct memory_static_buffers memory_dart_static_buffers;
typedef struct memory_io_buffers memory_dart_io_buffers;
typedef struct memory_small_data memory_dart_small_data;
typedef struct memory memory_dart_memory;
typedef struct memory_structure_pool memory_dart_structure_pool;

#if defined(__cplusplus)
extern "C"
{
#endif
    uint64_t memory_dart_tuple_next(const char* buffer, uint64_t offset);
#if defined(__cplusplus)
}
#endif

#endif
