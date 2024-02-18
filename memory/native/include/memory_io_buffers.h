#ifndef MEMORY_IO_BUFFERS_H
#define MEMORY_IO_BUFFERS_H

#include <stddef.h>
#include "memory.h"

#if defined(__cplusplus)
extern "C"
{
#endif
    struct memory_io_buffers
    {
        struct memory_pool input_buffers;
        struct memory_pool output_buffers;
        struct memory* memory;
    };

    static inline int memory_io_buffers_create(struct memory_io_buffers* pool, struct memory* memory)
    {
        pool->memory = memory;
        if (memory_pool_create(&pool->input_buffers, memory, sizeof(struct memory_input_buffer)))
        {
            return -1;
        }
        if (memory_pool_create(&pool->output_buffers, memory, sizeof(struct memory_output_buffer)))
        {
            return -1;
        }
        return 0;
    }

    static inline void memory_io_buffers_destroy(struct memory_io_buffers* pool)
    {
        memory_pool_destroy(&pool->input_buffers);
        memory_pool_destroy(&pool->output_buffers);
    }

    static inline struct memory_input_buffer* memory_io_buffers_allocate_input(struct memory_io_buffers* buffers, size_t inital_capacity)
    {
        struct memory_input_buffer* buffer = memory_pool_allocate(&buffers->input_buffers);
        ibuf_create(&buffer->buffer, &buffers->memory->cache, inital_capacity);
        return buffer;
    }

    static inline void memory_io_buffers_free_input(struct memory_io_buffers* buffers, struct memory_input_buffer* buffer)
    {
        ibuf_destroy(&buffer->buffer);
        memory_pool_free(&buffers->input_buffers, buffer);
    }

    static inline struct memory_output_buffer* memory_io_buffers_allocate_output(struct memory_io_buffers* buffers, size_t inital_capacity)
    {
        struct memory_output_buffer* buffer = memory_pool_allocate(&buffers->output_buffers);
        obuf_create(&buffer->buffer, &buffers->memory->cache, inital_capacity);
        return buffer;
    }

    static inline void memory_io_buffers_free_output(struct memory_io_buffers* buffers, struct memory_output_buffer* buffer)
    {
        obuf_destroy(&buffer->buffer);
        memory_pool_free(&buffers->output_buffers, buffer);
    }

    static inline uint8_t* memory_input_buffer_reserve(struct memory_input_buffer* buffer, size_t size)
    {
        return ibuf_reserve(&buffer->buffer, size ? size : buffer->buffer.start_capacity);
    }

    static inline uint8_t* memory_input_buffer_allocate(struct memory_input_buffer* buffer, size_t size)
    {
        uint8_t* allocated = ibuf_alloc(&buffer->buffer, size);
        return allocated;
    }

    static inline uint8_t* memory_input_buffer_allocate_reserve(struct memory_input_buffer* buffer, size_t delta, size_t size)
    {
        ibuf_alloc(&buffer->buffer, size);
        uint8_t* reserved = ibuf_reserve(&buffer->buffer, size ? size : buffer->buffer.start_capacity);
        return reserved;
    }

    static inline uint8_t* memory_output_buffer_reserve(struct memory_output_buffer* buffer, size_t size)
    {
        return obuf_reserve(&buffer->buffer, size ? size : buffer->buffer.start_capacity);
    }

    static inline uint8_t* memory_output_buffer_allocate(struct memory_output_buffer* buffer, size_t size)
    {
        return obuf_alloc(&buffer->buffer, size);
    }

    static inline uint8_t* memory_output_buffer_allocate_reserve(struct memory_output_buffer* buffer, size_t delta, size_t size)
    {
        obuf_alloc(&buffer->buffer, size);
        return obuf_reserve(&buffer->buffer, size ? size : buffer->buffer.start_capacity);
    }

#if defined(__cplusplus)
}
#endif

#endif
