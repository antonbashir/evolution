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

DART_STRUCTURE struct memory_instance
{
    struct quota quota;
    struct slab_arena arena;
    struct slab_cache cache;
};

DART_STRUCTURE struct memory_pool
{
    DART_FIELD size_t size;
    struct mempool pool;
};

DART_STRUCTURE struct memory_small_allocator
{
    struct small_alloc allocator;
};

DART_INLINE_LEAF_FUNCTION struct memory_instance* memory_create(size_t quota_size, size_t preallocation_size, size_t slab_size)
{
    struct memory_instance* memory = memory_module_new(sizeof(struct memory_instance));
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

DART_INLINE_LEAF_FUNCTION void memory_destroy(struct memory_instance* memory)
{
    slab_cache_destroy(&memory->cache);
    slab_arena_destroy(&memory->arena);
    if (quota_used(&memory->quota))
    {
        quota_release(&memory->quota, quota_used(&memory->quota));
    }
    memory_module_delete(memory);
}

DART_INLINE_LEAF_FUNCTION struct memory_pool* memory_pool_create(struct memory_instance* memory, size_t size)
{
    struct memory_pool* pool = memory_module_new(sizeof(struct memory_pool));
    pool->size = size;
    mempool_create(&pool->pool, &memory->cache, size);
    return mempool_is_initialized(&pool->pool) ? pool : NULL;
}

DART_INLINE_LEAF_FUNCTION void memory_pool_destroy(struct memory_pool* pool)
{
    mempool_destroy(&pool->pool);
    memory_module_delete(pool);
}

DART_INLINE_LEAF_FUNCTION void* memory_pool_allocate(struct memory_pool* pool)
{
    return mempool_alloc(&pool->pool);
}

DART_INLINE_LEAF_FUNCTION void memory_pool_free(struct memory_pool* pool, void* ptr)
{
    mempool_free(&pool->pool, ptr);
}

DART_INLINE_LEAF_FUNCTION struct memory_small_allocator* memory_small_allocator_create(float allocation_factor, struct memory_instance* memory)
{
    struct memory_small_allocator* allocator = memory_module_new(sizeof(struct memory_small_allocator));
    float actual_allocation_factor;
    small_alloc_create(&allocator->allocator, &memory->cache, 3 * sizeof(int32_t), sizeof(uintptr_t), allocation_factor, &actual_allocation_factor);
    return allocator->allocator.cache == NULL ? NULL : allocator;
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
