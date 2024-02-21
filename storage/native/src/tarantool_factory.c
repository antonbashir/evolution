#include "tarantool_factory.h"
#include <asm-generic/errno-base.h>
#include "interactor_message.h"
#include "memory_module.h"
#include "small.h"

int tarantool_factory_initialize(struct tarantool_factory* factory, struct tarantool_factory_configuration* configuration)
{
    float actual_alloc_factor;

    factory->memory = calloc(1, sizeof(struct memory));
    if (!factory->memory)
    {
        return -ENOMEM;
    }
    if (memory_create(factory->memory, configuration->quota_size, configuration->preallocation_size, configuration->slab_size))
    {
        return -ENOMEM;
    }

    factory->tarantool_datas = calloc(1, sizeof(struct small_alloc));
    if (!factory->tarantool_datas)
    {
        return -ENOMEM;
    }
    small_alloc_create(factory->tarantool_datas, &factory->memory->cache, 3 * sizeof(int), sizeof(intptr_t), 1.05, &actual_alloc_factor);

    return 0;
}

const char* tarantool_create_string(struct tarantool_factory* factory, size_t size)
{
    return smalloc(factory->tarantool_datas, size);
}

void tarantool_free_string(struct tarantool_factory* factory, const char* string, size_t size)
{
    smfree(factory->tarantool_datas, (void*)string, size);
}

void tarantool_factory_destroy(struct tarantool_factory* factory)
{
    small_alloc_destroy(factory->tarantool_datas);
    memory_destroy(factory->memory);
    free(factory->tarantool_datas);
    free(factory->memory);
}