#ifndef STORAGE_FACTORY_H
#define STORAGE_FACTORY_H

#include <common/common.h>
#include <system/library.h>

#if defined(__cplusplus)
extern "C"
{
#endif

DART_STRUCTURE struct storage_factory
{
    DART_FIELD struct memory_instance* memory;
    DART_FIELD struct memory_small_allocator* storage_datas;
};

DART_STRUCTURE struct storage_factory_configuration
{
    DART_FIELD size_t quota_size;
    DART_FIELD size_t slab_size;
    DART_FIELD size_t preallocation_size;
};

DART_LEAF_FUNCTION int32_t storage_factory_initialize(struct storage_factory* factory, struct storage_factory_configuration* configuration);

DART_LEAF_FUNCTION const char* storage_create_string(struct storage_factory* factory, size_t size);
DART_LEAF_FUNCTION void storage_free_string(struct storage_factory* factory, const char* string, size_t size);

DART_LEAF_FUNCTION void storage_factory_destroy(struct storage_factory* factory);

#if defined(__cplusplus)
}
#endif

#endif