#ifndef MEMORY_DATA_POOL
#define MEMORY_DATA_POOL

#include <memory_module.h>

#if defined(__cplusplus)
extern "C"
{
#endif

    struct memory_small_data
    {
        struct memory_small_allocator pool;
    };

    static inline int memory_small_data_create(struct memory_small_data* pool, struct memory* memory)
    {
        return memory_small_allocator_create(&pool->pool, memory);
    }

    static inline void memory_small_data_destroy(struct memory_small_data* pool)
    {
        memory_small_allocator_destroy(&pool->pool);
    }

    static inline void* memory_small_data_allocate(struct memory_small_data* pool, size_t data_size)
    {
        return memory_small_allocator_allocate(&pool->pool, data_size);
    }

    static inline void memory_small_data_free(struct memory_small_data* pool, void* data, size_t data_size)
    {
        memory_small_allocator_free(&pool->pool, data, data_size);
    }

#if defined(__cplusplus)
}
#endif

#endif
