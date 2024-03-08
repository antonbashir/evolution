#ifndef MEMORY_STATIC_BUFFERS_H
#define MEMORY_STATIC_BUFFERS_H

#include <common/common.h>
#include <common/factory.h>
#include <system/types.h>
#include "memory.h"
#include <modules/modules.h>

#if defined(__cplusplus)
extern "C"
{
#endif

struct memory_static_buffers
{
    size_t available;       // Dart
    size_t size;            // Dart
    size_t capacity;        // Dart
    int32_t* ids;           // Dart
    struct iovec* buffers;  // Dart
};

extern FORCEINLINE struct memory_static_buffers* memory_static_buffers_create(size_t capacity, size_t size)
{
    struct memory_static_buffers* pool = memory_new(memory_static_buffers);
    pool->size = size;
    pool->capacity = capacity;
    pool->available = 0;

    pool->ids = malloc(capacity * sizeof(int32_t));
    if (pool->ids == NULL)
    {
        memory_delete(pool);
        return NULL;
    }

    pool->buffers = malloc(capacity * sizeof(struct iovec));
    if (pool->buffers == NULL)
    {
        memory_delete(pool);
        return NULL;
    }

    int32_t page_size = getpagesize();
    for (size_t index = 0; index < capacity; index++)
    {
        struct iovec* buffer = &pool->buffers[index];
        if (posix_memalign(&buffer->iov_base, page_size, size))
        {
            memory_delete(pool);
            return NULL;
        }
        memset(buffer->iov_base, 0, size);
        buffer->iov_len = size;
        pool->ids[pool->available++] = index;
    }
    return pool;
}

extern FORCEINLINE void memory_static_buffers_destroy(struct memory_static_buffers* pool)
{
    for (size_t index = 0; index < pool->capacity; index++)
    {
        struct iovec* buffer = &pool->buffers[index];
        free(buffer->iov_base);
    }
    free(pool->ids);
    free(pool->buffers);
    memory_delete(pool);
}

extern FORCEINLINE void memory_static_buffers_push(struct memory_static_buffers* pool, int32_t id)
{
    struct iovec* buffer = &pool->buffers[id];
    memset(buffer->iov_base, 0, pool->size);
    buffer->iov_len = pool->size;
    pool->ids[pool->available++] = id;
}

extern FORCEINLINE int32_t memory_static_buffers_pop(struct memory_static_buffers* pool)
{
    if (unlikely(pool->available == 0))
        return MEMORY_BUFFER_USED;
    return pool->ids[--pool->available];
}

extern FORCEINLINE int32_t memory_static_buffers_used(struct memory_static_buffers* pool)
{
    return pool->capacity - pool->available;
}

#if defined(__cplusplus)
}
#endif

#endif
