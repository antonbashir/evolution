#ifndef TARANTOOL_EXECUTOR_H
#define TARANTOOL_EXECUTOR_H

#include <stdbool.h>
#include "tarantool.h"

#if defined(__cplusplus)
extern "C"
{
#endif
DART_STRUCTURE struct tarantool_executor_configuration
{
    DART_FIELD size_t executor_ring_size;
    DART_FIELD struct tarantool_configuration* configuration;
    DART_FIELD uint32_t executor_id;
};

DART_LEAF_FUNCTION int32_t tarantool_executor_initialize(struct tarantool_executor_configuration* configuration);
DART_LEAF_FUNCTION void tarantool_executor_start(struct tarantool_executor_configuration* configuration);
DART_LEAF_FUNCTION void tarantool_executor_stop();
DART_LEAF_FUNCTION void tarantool_executor_destroy();
DART_LEAF_FUNCTION int32_t tarantool_executor_descriptor();
#if defined(__cplusplus)
}
#endif

#endif
