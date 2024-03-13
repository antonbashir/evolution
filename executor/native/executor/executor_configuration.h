#ifndef EXECUTOR_CONFIGURATION_H
#define EXECUTOR_CONFIGURATION_H

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

#if defined(__cplusplus)
extern "C"
{
#endif
    struct executor_configuration
    {
        size_t quota_size;
        size_t preallocation_size;
        size_t slab_size;
        size_t static_buffers_capacity;
        size_t static_buffer_size;
        size_t ring_size;
        uint32_t ring_flags;
        bool trace;
    };

    struct executor_scheduler_configuration
    {
        size_t ring_size;
        size_t ring_flags;
        uint64_t initialization_timeout_seconds;
        uint64_t shutdown_timeout_seconds;
        bool trace;
    };
#if defined(__cplusplus)
}
#endif

#endif
