#ifndef MEMORY_DART_H
#define MEMORY_DART_H

#include <bits/types/struct_iovec.h>
#include <stddef.h>
#include <stdint.h>
#include "memory_configuration.h"

typedef struct memory_static_buffers memory_dart_static_buffers;
typedef struct memory_io_buffers memory_dart_io_buffers;
typedef struct memory_small_data memory_dart_small_data;
typedef struct memory memory_dart_memory;
typedef struct memory_structure_pool memory_dart_structure_pool;

#if defined(__cplusplus)
extern "C"
{
#endif

    struct memory_dart
    {
        memory_dart_static_buffers* static_buffers;
        memory_dart_io_buffers* io_buffers;
        memory_dart_small_data* small_data;
        memory_dart_memory* memory;
    };

    int32_t memory_dart_initialize(struct memory_dart* memory, struct memory_module_configuration* configuration);

    int32_t memory_dart_static_buffers_get(struct memory_dart* memory);
    void memory_dart_static_buffers_release(struct memory_dart* memory, int32_t buffer_id);
    int32_t memory_dart_static_buffers_available(struct memory_dart* memory);
    int32_t memory_dart_static_buffers_used(struct memory_dart* memory);
    struct iovec* memory_dart_static_buffers_inner(struct memory_dart* memory);

    struct memory_input_buffer* memory_dart_io_buffers_allocate_input(struct memory_dart* memory, size_t initial_capacity);
    struct memory_output_buffer* memory_dart_io_buffers_allocate_output(struct memory_dart* memory, size_t initial_capacity);
    void memory_dart_io_buffers_free_input(struct memory_dart* memory, struct memory_input_buffer* buffer);
    void memory_dart_io_buffers_free_output(struct memory_dart* memory, struct memory_output_buffer* buffer);
    uint8_t* memory_dart_input_buffer_reserve(struct memory_input_buffer* buffer, size_t size);
    uint8_t* memory_dart_input_buffer_finalize(struct memory_input_buffer* buffer, size_t size);
    uint8_t* memory_dart_input_buffer_finalize_reserve(struct memory_input_buffer* buffer, size_t delta, size_t size);
    uint8_t* memory_dart_input_buffer_read_position(struct memory_input_buffer* buffer);
    uint8_t* memory_dart_input_buffer_write_position(struct memory_input_buffer* buffer);
    uint8_t* memory_dart_output_buffer_reserve(struct memory_output_buffer* buffer, size_t size);
    uint8_t* memory_dart_output_buffer_finalize(struct memory_output_buffer* buffer, size_t size);
    uint8_t* memory_dart_output_buffer_finalize_reserve(struct memory_output_buffer* buffer, size_t delta, size_t size);
    struct iovec* memory_dart_output_buffer_content(struct memory_output_buffer* buffer);

    struct memory_dart_structure_pool* memory_dart_structure_pool_create(struct memory_dart* memory, size_t size);
    void* memory_dart_structure_allocate(struct memory_dart_structure_pool* pool);
    void memory_dart_structure_free(struct memory_dart_structure_pool* pool, void* pointer);
    void memory_dart_structure_pool_destroy(struct memory_dart_structure_pool* pool);
    size_t memory_dart_structure_pool_size(struct memory_dart_structure_pool* pool);

    void* memory_dart_small_data_allocate(struct memory_dart* memory, size_t size);
    void memory_dart_small_data_free(struct memory_dart* memory, void* pointer, size_t size);

    void memory_dart_destroy(struct memory_dart* memory);
#if defined(__cplusplus)
}
#endif

#endif