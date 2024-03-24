#ifndef STORAGE_EXECUTOR_H
#define STORAGE_EXECUTOR_H

#include <system/library.h>
#include <common/common.h>

#if defined(__cplusplus)
extern "C"
{
#endif

DART_STRUCTURE struct storage_executor_configuration
{
    DART_FIELD size_t executor_ring_size;
    DART_FIELD struct storage_configuration* configuration;
    DART_FIELD uint32_t executor_id;
};

DART_LEAF_FUNCTION int32_t storage_executor_initialize(struct storage_executor_configuration* configuration);
DART_LEAF_FUNCTION void storage_executor_start(struct storage_executor_configuration* configuration);
DART_LEAF_FUNCTION void storage_executor_stop();
DART_LEAF_FUNCTION void storage_executor_destroy();
DART_LEAF_FUNCTION int32_t storage_executor_descriptor();

#if defined(__cplusplus)
}
#endif

#endif
