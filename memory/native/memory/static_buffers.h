#ifndef MEMORY_STATIC_BUFFERS_H
#define MEMORY_STATIC_BUFFERS_H

#include <common/common.h>
#include <events/events.h>
#include <memory/memory.h>
#include <system/library.h>
#include "constants.h"
#include "errors.h"
#include "module.h"

#if defined(__cplusplus)
extern "C"
{
#endif

DART_STRUCTURE struct memory_static_buffers
{
    DART_FIELD size_t available;
    DART_FIELD size_t size;
    DART_FIELD size_t capacity;
    DART_FIELD int32_t* ids;
    DART_FIELD struct iovec* buffers;
};

DART_INLINE_LEAF_FUNCTION struct memory_static_buffers* memory_static_buffers_create(size_t capacity, size_t size)
{
    struct memory_static_buffers* pool = memory_module_new_checked(sizeof(struct memory_static_buffers));
    pool->size = size;
    pool->capacity = capacity;
    pool->available = 0;
    pool->ids = memory_module_allocate_checked(capacity, sizeof(int32_t));
    pool->buffers = memory_module_allocate_checked(capacity, sizeof(struct iovec));
    int32_t page_size = getpagesize();
    for (size_t index = 0; index < capacity; index++)
    {
        struct iovec* buffer = &pool->buffers[index];
        if (posix_memalign(&buffer->iov_base, page_size, size))
        {
            memory_module_delete(pool->ids);
            memory_module_delete(pool->buffers);
            memory_module_delete(pool);
            return NULL;
        }
        memset(buffer->iov_base, 0, size);
        buffer->iov_len = size;
        pool->ids[pool->available++] = index;
    }
    return pool;
}

DART_INLINE_LEAF_FUNCTION void memory_static_buffers_destroy(struct memory_static_buffers* pool)
{
    for (size_t index = 0; index < pool->capacity; index++)
    {
        struct iovec* buffer = &pool->buffers[index];
        memory_module_delete(buffer->iov_base);
    }
    memory_module_delete(pool->ids);
    memory_module_delete(pool->buffers);
    memory_module_delete(pool);
}

DART_INLINE_LEAF_FUNCTION void memory_static_buffers_push(struct memory_static_buffers* pool, int32_t id)
{
    struct iovec* buffer = &pool->buffers[id];
    memset(buffer->iov_base, 0, pool->size);
    buffer->iov_len = pool->size;
    pool->ids[pool->available++] = id;
}

DART_INLINE_LEAF_FUNCTION int32_t memory_static_buffers_pop(struct memory_static_buffers* pool)
{
    if (unlikely(pool->available == 0))
    {
        event_propagate_local(memory_error_buffers_unavailable());
        return MODULE_ERROR_CODE;
    }
    return pool->ids[--pool->available];
}

DART_INLINE_LEAF_FUNCTION int32_t memory_static_buffers_used(struct memory_static_buffers* pool)
{
    return pool->capacity - pool->available;
}

#if defined(__cplusplus)
}
#endif

#endif
