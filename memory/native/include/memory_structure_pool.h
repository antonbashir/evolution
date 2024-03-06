#ifndef MEMORY_PAYLOADS_POOL
#define MEMORY_PAYLOADS_POOL

#include <common/common.h>
#include "memory.h"

#if defined(__cplusplus)
extern "C"
{
#endif

struct memory_structure_pool
{
    // FFI
    size_t size;
    // FFI

    struct memory_pool pool;
};

extern FORCEINLINE struct memory_structure_pool* memory_structure_pool_new()
{
    return calloc(1, sizeof(struct memory_structure_pool));
}

extern FORCEINLINE int32_t memory_structure_pool_create(struct memory_structure_pool* pool, struct memory* memory, size_t structure_size)
{
    return memory_pool_create(&pool->pool, memory, structure_size);
}

extern FORCEINLINE void memory_structure_pool_destroy(struct memory_structure_pool* pool)
{
    memory_pool_destroy(&pool->pool);
}

extern FORCEINLINE void* memory_structure_pool_allocate(struct memory_structure_pool* pool)
{
    return memory_pool_allocate(&pool->pool);
}

extern FORCEINLINE void memory_structure_pool_free(struct memory_structure_pool* pool, void* payload)
{
    memory_pool_free(&pool->pool, payload);
}

#if defined(__cplusplus)
}
#endif

#endif
