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

DART_STRUCTURE struct memory_input_buffer
{
    DART_FIELD uint8_t* read_position;
    DART_FIELD uint8_t* write_position;
    DART_FIELD size_t used;
    DART_FIELD size_t unused;
    struct ibuf buffer;
};

DART_STRUCTURE struct memory_output_buffer
{
    DART_FIELD struct iovec* content;
    DART_FIELD size_t vectors;
    DART_FIELD size_t size;
    DART_FIELD size_t last_reserved_size;
    struct obuf buffer;
};

DART_STRUCTURE struct memory_io_buffers
{
    DART_FIELD struct memory_instance* instance;
    DART_FIELD struct memory_pool* input_buffers;
    DART_FIELD struct memory_pool* output_buffers;
};

DART_INLINE_LEAF_FUNCTION struct memory_io_buffers* memory_io_buffers_create(struct memory_instance* memory)
{
    struct memory_io_buffers* pool = memory_module_new(sizeof(struct memory_io_buffers));
    if (pool == NULL)
    {
        return NULL;
    }
    pool->instance = memory;
    pool->input_buffers = memory_pool_create(memory, sizeof(struct memory_input_buffer));
    if (pool->input_buffers == NULL)
    {
        memory_module_delete(pool);
        return NULL;
    }
    pool->output_buffers = memory_pool_create(memory, sizeof(struct memory_output_buffer));
    if (pool->output_buffers == NULL)
    {
        memory_module_delete(pool);
        return NULL;
    }
    return pool;
}

DART_INLINE_LEAF_FUNCTION void memory_io_buffers_destroy(struct memory_io_buffers* pool)
{
    memory_pool_destroy(pool->input_buffers);
    memory_pool_destroy(pool->output_buffers);
    memory_module_delete(pool);
}

DART_INLINE_LEAF_FUNCTION struct memory_input_buffer* memory_io_buffers_allocate_input(struct memory_io_buffers* buffers, size_t initial_capacity)
{
    struct memory_input_buffer* buffer = memory_pool_allocate(buffers->input_buffers);
    if (buffer == NULL)
    {
        return NULL;
    }
    ibuf_create(&buffer->buffer, &buffers->instance->cache, initial_capacity);
    buffer->read_position = (uint8_t*)buffer->buffer.rpos;
    buffer->write_position = (uint8_t*)buffer->buffer.wpos;
    return buffer;
}

DART_INLINE_LEAF_FUNCTION void memory_io_buffers_free_input(struct memory_io_buffers* buffers, struct memory_input_buffer* buffer)
{
    ibuf_destroy(&buffer->buffer);
    memory_pool_free(buffers->input_buffers, buffer);
}

DART_INLINE_LEAF_FUNCTION struct memory_output_buffer* memory_io_buffers_allocate_output(struct memory_io_buffers* buffers, size_t initial_capacity)
{
    struct memory_output_buffer* buffer = memory_pool_allocate(buffers->output_buffers);
    if (buffer == NULL)
    {
        return NULL;
    }
    obuf_create(&buffer->buffer, &buffers->instance->cache, initial_capacity);
    buffer->content = &buffer->buffer.iov[0];
    return buffer;
}

DART_INLINE_LEAF_FUNCTION void memory_io_buffers_free_output(struct memory_io_buffers* buffers, struct memory_output_buffer* buffer)
{
    obuf_destroy(&buffer->buffer);
    memory_pool_free(buffers->output_buffers, buffer);
}

DART_INLINE_LEAF_FUNCTION uint8_t* memory_input_buffer_reserve(struct memory_input_buffer* buffer, size_t size)
{
    uint8_t* reserved = ibuf_reserve(&buffer->buffer, size ? size : buffer->buffer.start_capacity);
    if (reserved == NULL)
    {
        return NULL;
    }
    buffer->read_position = (uint8_t*)buffer->buffer.rpos;
    buffer->write_position = (uint8_t*)buffer->buffer.wpos;
    buffer->used = ibuf_used(&buffer->buffer);
    buffer->unused = ibuf_unused(&buffer->buffer);
    return reserved;
}

DART_INLINE_LEAF_FUNCTION uint8_t* memory_input_buffer_finalize(struct memory_input_buffer* buffer, size_t size)
{
    uint8_t* allocated = ibuf_alloc(&buffer->buffer, size);
    if (allocated == NULL)
    {
        return NULL;
    }
    buffer->read_position = (uint8_t*)buffer->buffer.rpos;
    buffer->write_position = (uint8_t*)buffer->buffer.wpos;
    buffer->used = ibuf_used(&buffer->buffer);
    buffer->unused = ibuf_unused(&buffer->buffer);
    return allocated;
}

DART_INLINE_LEAF_FUNCTION uint8_t* memory_input_buffer_finalize_reserve(struct memory_input_buffer* buffer, size_t delta, size_t size)
{
    ibuf_alloc(&buffer->buffer, delta);
    uint8_t* reserved = ibuf_reserve(&buffer->buffer, size ? size : buffer->buffer.start_capacity);
    if (reserved == NULL)
    {
        return NULL;
    }
    buffer->read_position = (uint8_t*)buffer->buffer.rpos;
    buffer->write_position = (uint8_t*)buffer->buffer.wpos;
    buffer->used = ibuf_used(&buffer->buffer);
    buffer->unused = ibuf_unused(&buffer->buffer);
    return reserved;
}

DART_INLINE_LEAF_FUNCTION uint8_t* memory_output_buffer_reserve(struct memory_output_buffer* buffer, size_t size)
{
    uint8_t* reserved = obuf_reserve(&buffer->buffer, size ? size : buffer->buffer.start_capacity);
    buffer->size = obuf_size(&buffer->buffer);
    buffer->vectors = buffer->buffer.n_iov;
    buffer->last_reserved_size = buffer->buffer.capacity[buffer->buffer.pos] - buffer->buffer.iov[buffer->buffer.pos].iov_len;
    return reserved;
}

DART_INLINE_LEAF_FUNCTION uint8_t* memory_output_buffer_finalize(struct memory_output_buffer* buffer, size_t size)
{
    uint8_t* reserved = obuf_alloc(&buffer->buffer, size);
    buffer->size = obuf_size(&buffer->buffer);
    buffer->vectors = buffer->buffer.n_iov;
    return reserved;
}

DART_INLINE_LEAF_FUNCTION uint8_t* memory_output_buffer_finalize_reserve(struct memory_output_buffer* buffer, size_t delta, size_t size)
{
    obuf_alloc(&buffer->buffer, delta);
    uint8_t* reserved = obuf_reserve(&buffer->buffer, size ? size : buffer->buffer.start_capacity);
    buffer->size = obuf_size(&buffer->buffer);
    buffer->vectors = buffer->buffer.n_iov;
    buffer->last_reserved_size = buffer->buffer.capacity[buffer->buffer.pos] - buffer->buffer.iov[buffer->buffer.pos].iov_len;
    return reserved;
}

#if defined(__cplusplus)
}
#endif

#endif
