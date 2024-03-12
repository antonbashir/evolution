#ifndef memory_H
#define memory_H

#include <common/common.h>
#include <small/ibuf.h>
#include <small/mempool.h>
#include <small/obuf.h>
#include <small/quota.h>
#include <small/slab_arena.h>
#include <small/slab_cache.h>
#include <small/small.h>
#include "module.h"

#if defined(__cplusplus)
extern "C"
{
#endif

DART_STRUCTURE struct memory
{
    struct quota quota;
    struct slab_arena arena;
    struct slab_cache cache;
};

DART_STRUCTURE struct memory_pool
{
    struct mempool pool;
};

DART_STRUCTURE struct memory_small_allocator
{
    struct small_alloc allocator;
};

DART_STRUCTURE struct memory_input_buffer
{
    DART_FIELD uint8_t* read_position;
    DART_FIELD uint8_t* write_position;
    struct ibuf buffer;
};

DART_STRUCTURE struct memory_output_buffer
{
    DART_FIELD struct iovec* content;
    struct obuf buffer;
};

DART_INLINE_LEAF_FUNCTION struct memory* memory_create(size_t quota_size, size_t preallocation_size, size_t slab_size)
{
    struct memory* memory = memory_module_new(sizeof(struct memory));
    if (memory == NULL)
    {
        return NULL;
    }
    int32_t result;
    quota_init(&memory->quota, quota_size);
    if ((result = slab_arena_create(&memory->arena, &memory->quota, preallocation_size, slab_size, MAP_PRIVATE)))
    {
        memory_module_delete(memory);
        return NULL;
    }
    slab_cache_create(&memory->cache, &memory->arena);
    return memory;
}

DART_INLINE_LEAF_FUNCTION void memory_destroy(struct memory* memory)
{
    slab_cache_destroy(&memory->cache);
    slab_arena_destroy(&memory->arena);
    if (quota_used(&memory->quota))
    {
        quota_release(&memory->quota, quota_used(&memory->quota));
    }
    memory_module_delete(memory);
}

DART_INLINE_LEAF_FUNCTION int32_t memory_pool_create(struct memory_pool* pool, struct memory* memory, size_t size)
{
    mempool_create(&pool->pool, &memory->cache, size);
    return mempool_is_initialized(&pool->pool) ? 0 : -1;
}

DART_INLINE_LEAF_FUNCTION void memory_pool_destroy(struct memory_pool* pool)
{
    mempool_destroy(&pool->pool);
}

DART_INLINE_LEAF_FUNCTION void* memory_pool_allocate(struct memory_pool* pool)
{
    return mempool_alloc(&pool->pool);
}

DART_INLINE_LEAF_FUNCTION void memory_pool_free(struct memory_pool* pool, void* ptr)
{
    mempool_free(&pool->pool, ptr);
}

DART_INLINE_LEAF_FUNCTION int32_t memory_small_allocator_create(struct memory_small_allocator* pool, float allocation_factor, struct memory* memory)
{
    float actual_allocation_factor;
    small_alloc_create(&pool->allocator, &memory->cache, 3 * sizeof(int32_t), sizeof(uintptr_t), allocation_factor, &actual_allocation_factor);
    return pool->allocator.cache == NULL ? -1 : 0;
}

DART_INLINE_LEAF_FUNCTION void* memory_small_allocator_allocate(struct memory_small_allocator* pool, size_t size)
{
    return (void*)smalloc(&pool->allocator, size);
}

DART_INLINE_LEAF_FUNCTION void memory_small_allocator_free(struct memory_small_allocator* pool, void* ptr, size_t size)
{
    smfree(&pool->allocator, ptr, size);
}

DART_INLINE_LEAF_FUNCTION void memory_small_allocator_destroy(struct memory_small_allocator* pool)
{
    small_alloc_destroy(&pool->allocator);
}

#if defined(__cplusplus)
}
#endif

#endif
