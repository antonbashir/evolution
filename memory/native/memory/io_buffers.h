#ifndef MEMORY_IO_BUFFERS_H
#define MEMORY_IO_BUFFERS_H

#include <common/common.h>
#include <memory/memory.h>
#include <system/library.h>
#include "module.h"

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

FORCEINLINE struct memory_io_buffers* memory_io_buffers_create(struct memory* memory)
{
    struct memory_io_buffers* pool = memory_module_new(sizeof(struct memory_io_buffers));
    if (pool == NULL)
    {
        return NULL;
    }
    pool->memory = memory;
    if (memory_pool_create(&pool->input_buffers, memory, sizeof(struct memory_input_buffer)))
    {
        memory_module_delete(pool);
        return NULL;
    }
    if (memory_pool_create(&pool->output_buffers, memory, sizeof(struct memory_output_buffer)))
    {
        memory_module_delete(pool);
        return NULL;
    }
    return pool;
}

FORCEINLINE void memory_io_buffers_destroy(struct memory_io_buffers* pool)
{
    memory_pool_destroy(&pool->input_buffers);
    memory_pool_destroy(&pool->output_buffers);
    memory_module_delete(pool);
}

FORCEINLINE struct memory_input_buffer* memory_io_buffers_allocate_input(struct memory_io_buffers* buffers, size_t initial_capacity)
{
    struct memory_input_buffer* buffer = memory_pool_allocate(&buffers->input_buffers);
    if (buffer == NULL)
    {
        return NULL;
    }
    ibuf_create(&buffer->buffer, &buffers->memory->cache, initial_capacity);
    buffer->read_position = (uint8_t*)buffer->buffer.rpos;
    buffer->write_position = (uint8_t*)buffer->buffer.wpos;
    return buffer;
}

FORCEINLINE void memory_io_buffers_free_input(struct memory_io_buffers* buffers, struct memory_input_buffer* buffer)
{
    ibuf_destroy(&buffer->buffer);
    memory_pool_free(&buffers->input_buffers, buffer);
}

FORCEINLINE struct memory_output_buffer* memory_io_buffers_allocate_output(struct memory_io_buffers* buffers, size_t initial_capacity)
{
    struct memory_output_buffer* buffer = memory_pool_allocate(&buffers->output_buffers);
    if (buffer == NULL)
    {
        return NULL;
    }
    obuf_create(&buffer->buffer, &buffers->memory->cache, initial_capacity);
    buffer->content = buffer->buffer.iov;
    return buffer;
}

FORCEINLINE void memory_io_buffers_free_output(struct memory_io_buffers* buffers, struct memory_output_buffer* buffer)
{
    obuf_destroy(&buffer->buffer);
    memory_pool_free(&buffers->output_buffers, buffer);
}

FORCEINLINE uint8_t* memory_input_buffer_reserve(struct memory_input_buffer* buffer, size_t size)
{
    uint8_t* reserved = ibuf_reserve(&buffer->buffer, size ? size : buffer->buffer.start_capacity);
    if (reserved == NULL)
    {
        return NULL;
    }
    buffer->read_position = (uint8_t*)buffer->buffer.rpos;
    buffer->write_position = (uint8_t*)buffer->buffer.wpos;
    return reserved;
}

FORCEINLINE uint8_t* memory_input_buffer_finalize(struct memory_input_buffer* buffer, size_t size)
{
    uint8_t* allocated = ibuf_alloc(&buffer->buffer, size);
    if (allocated == NULL)
    {
        return NULL;
    }
    buffer->read_position = (uint8_t*)buffer->buffer.rpos;
    buffer->write_position = (uint8_t*)buffer->buffer.wpos;
    return allocated;
}

FORCEINLINE uint8_t* memory_input_buffer_finalize_reserve(struct memory_input_buffer* buffer, size_t delta, size_t size)
{
    ibuf_alloc(&buffer->buffer, size);
    uint8_t* reserved = ibuf_reserve(&buffer->buffer, size ? size : buffer->buffer.start_capacity);
    if (reserved == NULL)
    {
        return NULL;
    }
    buffer->read_position = (uint8_t*)buffer->buffer.rpos;
    buffer->write_position = (uint8_t*)buffer->buffer.wpos;
    return reserved;
}

FORCEINLINE uint8_t* memory_output_buffer_reserve(struct memory_output_buffer* buffer, size_t size)
{
    return obuf_reserve(&buffer->buffer, size ? size : buffer->buffer.start_capacity);
}

FORCEINLINE uint8_t* memory_output_buffer_finalize(struct memory_output_buffer* buffer, size_t size)
{
    return obuf_alloc(&buffer->buffer, size);
}

static __attribute__((used, retain)) FORCEINLINE uint8_t* memory_output_buffer_finalize_reserve(struct memory_output_buffer* buffer, size_t delta, size_t size)
{
    obuf_alloc(&buffer->buffer, size);
    return obuf_reserve(&buffer->buffer, size ? size : buffer->buffer.start_capacity);
}

#if defined(__cplusplus)
}
#endif

#endif