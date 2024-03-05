#include "memory.h"
#include <memory_io_buffers.h>
#include <memory_module.h>
#include <memory_small_data.h>
#include <memory_static_buffers.h>
#include <memory_structure_pool.h>
#include <system/system.h>

int32_t memory_initialize(struct memory* memory, struct memory_module_configuration* configuration)
{
    memory->memory_module = calloc(1, sizeof(struct memory_module));
    if (!memory->memory_module)
    {
        return -ENOMEM;
    }

    memory->small_data = calloc(1, sizeof(struct memory_small_data));
    if (!memory->small_data)
    {
        return -ENOMEM;
    }

    memory->static_buffers = calloc(1, sizeof(struct memory_static_buffers));
    if (!memory->static_buffers)
    {
        return -ENOMEM;
    }

    memory->io_buffers = calloc(1, sizeof(struct memory_io_buffers));
    if (!memory->io_buffers)
    {
        return -ENOMEM;
    }

    if (memory_create(memory->memory_module, configuration->quota_size, configuration->preallocation_size, configuration->slab_size))
    {
        return -ENOMEM;
    }
    if (memory_small_data_create(memory->small_data, memory->memory_module))
    {
        return -ENOMEM;
    }
    if (memory_static_buffers_create(memory->static_buffers, configuration->static_buffers_capacity, configuration->static_buffer_size))
    {
        return -ENOMEM;
    }
    if (memory_io_buffers_create(memory->io_buffers, memory->memory_module))
    {
        return -ENOMEM;
    }

    return 0;
}

int32_t memory_static_buffers_get(struct memory* memory)
{
    return memory_static_buffers_pop(memory->static_buffers);
}

int32_t memory_static_buffers_available(struct memory* memory)
{
    return memory->static_buffers->available;
}

int32_t memory_static_buffers_used(struct memory* memory)
{
    return memory->static_buffers->capacity - memory->static_buffers->available;
}

void memory_static_buffers_release(struct memory* memory, int32_t buffer_id)
{
    memory_static_buffers_push(memory->static_buffers, buffer_id);
}

struct iovec* memory_static_buffers_inner(struct memory* memory)
{
    return memory->static_buffers->buffers;
}

struct memory_structure_pool* memory_structure_pool_create(struct memory* memory, size_t size)
{
    struct memory_structure_pool* pool = malloc(sizeof(struct memory_structure_pool));
    pool->size = size;
    memory_structure_pool_create(pool, memory->memory_module, size);
    return (struct memory_structure_pool*)pool;
}

void* memory_structure_allocate(struct memory_structure_pool* pool)
{
    void* payload = memory_structure_pool_allocate((struct memory_structure_pool*)pool);
    memset(payload, 0, ((struct memory_structure_pool*)pool)->size);
    return payload;
}

void memory_structure_free(struct memory_structure_pool* pool, void* pointer)
{
    memory_structure_pool_free((struct memory_structure_pool*)pool, pointer);
}

void memory_structure_pool_destroy(struct memory_structure_pool* pool)
{
    memory_structure_pool_destroy((struct memory_structure_pool*)pool);
    free(pool);
}

size_t memory_structure_pool_size(struct memory_structure_pool* pool)
{
    return ((struct memory_structure_pool*)pool)->size;
}

void* memory_small_data_allocate(struct memory* memory, size_t size)
{
    void* data = memory_small_data_allocate(memory->small_data, size);
    memset(data, 0, size);
    return data;
}

void memory_small_data_free(struct memory* memory, void* pointer, size_t size)
{
    memory_small_data_free(memory->small_data, pointer, size);
}

struct memory_input_buffer* memory_io_buffers_allocate_input(struct memory* memory, size_t initial_capacity)
{
    return memory_io_buffers_allocate_input(memory->io_buffers, initial_capacity);
}

struct memory_output_buffer* memory_io_buffers_allocate_output(struct memory* memory, size_t initial_capacity)
{
    return memory_io_buffers_allocate_output(memory->io_buffers, initial_capacity);
}

void memory_io_buffers_free_input(struct memory* memory, struct memory_input_buffer* buffer)
{
    memory_io_buffers_free_input(memory->io_buffers, buffer);
}

void memory_io_buffers_free_output(struct memory* memory, struct memory_output_buffer* buffer)
{
    memory_io_buffers_free_output(memory->io_buffers, buffer);
}

uint8_t* memory_input_buffer_reserve(struct memory_input_buffer* buffer, size_t size)
{
    return memory_input_buffer_reserve(buffer, size);
}

uint8_t* memory_input_buffer_finalize(struct memory_input_buffer* buffer, size_t size)
{
    return memory_input_buffer_finalize(buffer, size);
}

uint8_t* memory_input_buffer_finalize_reserve(struct memory_input_buffer* buffer, size_t delta, size_t size)
{
    return memory_input_buffer_finalize_reserve(buffer, delta, size);
}

uint8_t* memory_input_buffer_read_position(struct memory_input_buffer* buffer)
{
    return (uint8_t*)buffer->buffer.rpos;
}

uint8_t* memory_input_buffer_write_position(struct memory_input_buffer* buffer)
{
    return (uint8_t*)buffer->buffer.wpos;
}

uint8_t* memory_output_buffer_reserve(struct memory_output_buffer* buffer, size_t size)
{
    return memory_output_buffer_reserve(buffer, size);
}

uint8_t* memory_output_buffer_finalize(struct memory_output_buffer* buffer, size_t size)
{
    return memory_output_buffer_finalize(buffer, size);
}

struct iovec* memory_output_buffer_content(struct memory_output_buffer* buffer)
{
    return buffer->buffer.iov;
}

uint8_t* memory_output_buffer_finalize_reserve(struct memory_output_buffer* buffer, size_t delta, size_t size)
{
    return memory_output_buffer_finalize_reserve(buffer, delta, size);
}

void memory_destroy(struct memory* memory)
{
    memory_static_buffers_destroy(memory->static_buffers);
    memory_io_buffers_destroy(memory->io_buffers);
    memory_small_data_destroy(memory->small_data);
    memory_destroy(memory->memory_module);
    free(memory->static_buffers);
    free(memory->io_buffers);
    free(memory->small_data);
    free(memory->memory_module);
}
