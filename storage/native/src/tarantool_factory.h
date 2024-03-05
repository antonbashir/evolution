#ifndef TARANTOOL_FACTORY_H
#define TARANTOOL_FACTORY_H

#include "mediator_message.h"

typedef struct mempool tarantool_factory_mempool;
typedef struct small_alloc tarantool_factory_small_alloc;
typedef struct memory_module tarantool_factory_memory;

#if defined(__cplusplus)
extern "C"
{
#endif
    struct tarantool_factory
    {
        tarantool_factory_memory* memory;
        tarantool_factory_small_alloc* tarantool_datas;
    };

    struct tarantool_factory_configuration
    {
        size_t quota_size;
        size_t slab_size;
        size_t preallocation_size;
    };

    int32_t tarantool_factory_initialize(struct tarantool_factory* factory, struct tarantool_factory_configuration* configuration);

    const char* tarantool_create_string(struct tarantool_factory* factory, size_t size);
    void tarantool_free_string(struct tarantool_factory* factory, const char* string, size_t size);

    void tarantool_factory_destroy(struct tarantool_factory* factory);
#if defined(__cplusplus)
}
#endif

#endif