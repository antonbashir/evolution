#ifndef MEMORY_PAYLOADS_POOL
#define MEMORY_PAYLOADS_POOL

#include "memory_module.h"

#if defined(__cplusplus)
extern "C"
{
#endif

    struct memory_structure_pool
    {
        struct memory_pool pool;
        size_t size;
    };

    static inline int32_t memory_structure_pool_create(struct memory_structure_pool* pool, struct memory_module* memory, size_t structure_size)
    {
        return memory_pool_create(&pool->pool, memory, structure_size);
    }

    static inline void memory_structure_pool_destroy(struct memory_structure_pool* pool)
    {
        memory_pool_destroy(&pool->pool);
    }

    static inline void* memory_structure_pool_allocate(struct memory_structure_pool* pool)
    {
        return memory_pool_allocate(&pool->pool);
    }

    static inline void memory_structure_pool_free(struct memory_structure_pool* pool, void* payload)
    {
        memory_pool_free(&pool->pool, payload);
    }

#if defined(__cplusplus)
}
#endif

#endif
