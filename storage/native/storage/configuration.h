#ifndef STORAGE_CONFIGURATION_H
#define STORAGE_CONFIGURATION_H

#include <common/common.h>
#include <system/library.h>

#if defined(__cplusplus)
extern "C"
{
#endif

DART_STRUCTURE struct storage_executor_configuration
{
    DART_FIELD size_t ring_size;
    DART_FIELD size_t ring_flags;
    DART_FIELD struct storage_configuration* configuration;
    DART_FIELD uint32_t executor_id;
};

DART_STRUCTURE struct storage_configuration
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
    DART_FIELD struct storage_executor_configuration executor_configuration;
};

#if defined(__cplusplus)
}
#endif

#endif
