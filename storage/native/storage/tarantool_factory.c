#include "tarantool_factory.h"
#include <asm-generic/errno-base.h>
#include <memory/memory.h>
#include "small.h"

int32_t tarantool_factory_initialize(struct tarantool_factory* factory, struct tarantool_factory_configuration* configuration)
{
    float actual_alloc_factor;

    factory->memory = memory_create(configuration->quota_size, configuration->preallocation_size, configuration->slab_size);
    if (!factory->memory)
    {
        return -ENOMEM;
    }

    factory->tarantool_datas = calloc(1, sizeof(struct small_alloc));
    if (!factory->tarantool_datas)
    {
        return -ENOMEM;
    }
    small_alloc_create(&factory->tarantool_datas->allocator, &factory->memory->cache, 3 * sizeof(int), sizeof(uintptr_t), 1.05, &actual_alloc_factor);

    return 0;
}

const char* tarantool_create_string(struct tarantool_factory* factory, size_t size)
{
    return smalloc(&factory->tarantool_datas->allocator, size);
}

void tarantool_free_string(struct tarantool_factory* factory, const char* string, size_t size)
{
    smfree(&factory->tarantool_datas->allocator, (void*)string, size);
}

void tarantool_factory_destroy(struct tarantool_factory* factory)
{
    small_alloc_destroy(&factory->tarantool_datas->allocator);
    memory_destroy(factory->memory);
    free(factory->tarantool_datas);
    free(factory->memory);
}