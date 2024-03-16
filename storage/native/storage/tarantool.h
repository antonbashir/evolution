#ifndef TARANTOOL_H
#define TARANTOOL_H

#include <stdbool.h>
#include <stddef.h>
#include "tarantool_box.h"

#if defined(__cplusplus)
extern "C"
{
#endif
DART_STRUCTURE struct tarantool_configuration
{
    DART_FIELD const char* initial_script;
    DART_FIELD const char* library_path;
    DART_FIELD const char* binary_path;
    DART_FIELD uint64_t cqe_wait_timeout_milliseconds;
    DART_FIELD size_t slab_size;
    DART_FIELD size_t ring_size;
    DART_FIELD uint64_t initialization_timeout_seconds;
    DART_FIELD uint64_t shutdown_timeout_seconds;
    DART_FIELD size_t box_output_buffer_capacity;
    DART_FIELD size_t executor_ring_size;
    DART_FIELD int32_t ring_flags;
    DART_FIELD uint32_t cqe_wait_count;
    DART_FIELD uint32_t cqe_peek_count;
};

DART_LEAF_FUNCTION bool tarantool_initialize(struct tarantool_configuration* configuration, struct tarantool_box* box);
DART_LEAF_FUNCTION bool tarantool_initialized();
DART_LEAF_FUNCTION const char* tarantool_status();
DART_LEAF_FUNCTION int32_t tarantool_is_read_only();
DART_LEAF_FUNCTION const char* tarantool_initialization_error();
DART_LEAF_FUNCTION const char* tarantool_shutdown_error();
DART_LEAF_FUNCTION bool tarantool_shutdown();
#if defined(__cplusplus)
}
#endif

#endif
