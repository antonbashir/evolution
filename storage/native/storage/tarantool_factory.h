#ifndef TARANTOOL_FACTORY_H
#define TARANTOOL_FACTORY_H

#include <common/common.h>
#include <system/library.h>

#if defined(__cplusplus)
extern "C"
{
#endif

DART_STRUCTURE struct tarantool_factory
{
    DART_FIELD struct memory_instance* memory;
    DART_FIELD struct memory_small_allocator* tarantool_datas;
};

DART_STRUCTURE struct tarantool_factory_configuration
{
    DART_FIELD size_t quota_size;
    DART_FIELD size_t slab_size;
    DART_FIELD size_t preallocation_size;
};

DART_LEAF_FUNCTION int32_t tarantool_factory_initialize(struct tarantool_factory* factory, struct tarantool_factory_configuration* configuration);

DART_LEAF_FUNCTION const char* tarantool_create_string(struct tarantool_factory* factory, size_t size);
DART_LEAF_FUNCTION void tarantool_free_string(struct tarantool_factory* factory, const char* string, size_t size);

DART_LEAF_FUNCTION void tarantool_factory_destroy(struct tarantool_factory* factory);

#if defined(__cplusplus)
}
#endif

#endif