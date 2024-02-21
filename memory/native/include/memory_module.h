#ifndef memory_H
#define memory_H

#include <stddef.h>
#include "small/ibuf.h"
#include "small/mempool.h"
#include "small/obuf.h"
#include "small/quota.h"
#include "small/slab_arena.h"
#include "small/slab_cache.h"
#include "small/small.h"

#if defined(__cplusplus)
extern "C"
{
#endif

#define MEMORY_BUFFER_USED -1
    struct memory
    {
        struct quota quota;
        struct slab_arena arena;
        struct slab_cache cache;
        bool initialized;
    };

    struct memory_pool
    {
        struct mempool pool;
    };

    struct memory_small_allocator
    {
        struct small_alloc allocator;
    };

    struct memory_input_buffer
    {
        struct ibuf buffer;
    };

    struct memory_output_buffer
    {
        struct obuf buffer;
    };

    static inline int memory_create(struct memory* memory, size_t quota_size, size_t preallocation_size, size_t slab_size)
    {
        int result;
        quota_init(&memory->quota, quota_size);
        if ((result = slab_arena_create(&memory->arena, &memory->quota, preallocation_size, slab_size, MAP_PRIVATE))) return result;
        slab_cache_create(&memory->cache, &memory->arena);
        memory->initialized = true;
        return 0;
    }

    static inline void memory_destroy(struct memory* memory)
    {
        slab_cache_destroy(&memory->cache);
        slab_arena_destroy(&memory->arena);
        if (quota_used(&memory->quota))
        {
            quota_release(&memory->quota, quota_used(&memory->quota));
        }
        memory->initialized = false;
    }

    static inline int memory_pool_create(struct memory_pool* pool, struct memory* memory, size_t size)
    {
        mempool_create(&pool->pool, &memory->cache, size);
        return mempool_is_initialized(&pool->pool) ? 0 : -1;
    }

    static inline void memory_pool_destroy(struct memory_pool* pool)
    {
        mempool_destroy(&pool->pool);
    }

    static inline void* memory_pool_allocate(struct memory_pool* pool)
    {
        return mempool_alloc(&pool->pool);
    }

    static inline void memory_pool_free(struct memory_pool* pool, void* ptr)
    {
        mempool_free(&pool->pool, ptr);
    }

    static inline int memory_small_allocator_create(struct memory_small_allocator* pool, struct memory* memory)
    {
        float actual_alloc_factor;
        small_alloc_create(&pool->allocator, &memory->cache, 3 * sizeof(int), sizeof(intptr_t), 1.05, &actual_alloc_factor);
        return pool->allocator.cache == NULL ? -1 : 0;
    }

    static inline void* memory_small_allocator_allocate(struct memory_small_allocator* pool, size_t size)
    {
        return (void*)smalloc(&pool->allocator, size);
    }

    static inline void memory_small_allocator_free(struct memory_small_allocator* pool, void* ptr, size_t size)
    {
        smfree(&pool->allocator, ptr, size);
    }

    static inline void memory_small_allocator_destroy(struct memory_small_allocator* pool)
    {
        small_alloc_destroy(&pool->allocator);
    }
#if defined(__cplusplus)
}
#endif

#endif
