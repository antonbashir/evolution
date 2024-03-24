#include "factory.h"
#include <memory/memory.h>

int32_t storage_factory_initialize(struct storage_factory* factory, struct storage_factory_configuration* configuration)
{
    float actual_alloc_factor;

    factory->memory = memory_create(configuration->quota_size, configuration->preallocation_size, configuration->slab_size);
    if (!factory->memory)
    {
        return -ENOMEM;
    }

    factory->storage_datas = calloc(1, sizeof(struct small_alloc));
    if (!factory->storage_datas)
    {
        return -ENOMEM;
    }
    small_alloc_create(&factory->storage_datas->allocator, &factory->memory->cache, 3 * sizeof(int), sizeof(uintptr_t), 1.05, &actual_alloc_factor);

    return 0;
}

const char* storage_create_string(struct storage_factory* factory, size_t size)
{
    return smalloc(&factory->storage_datas->allocator, size);
}

void storage_free_string(struct storage_factory* factory, const char* string, size_t size)
{
    smfree(&factory->storage_datas->allocator, (void*)string, size);
}

void storage_factory_destroy(struct storage_factory* factory)
{
    small_alloc_destroy(&factory->storage_datas->allocator);
    memory_destroy(factory->memory);
    free(factory->storage_datas);
    free(factory->memory);
}