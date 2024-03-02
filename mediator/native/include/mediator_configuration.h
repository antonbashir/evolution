#ifndef MEDIATOR_CONFIGURATION_H
#define MEDIATOR_CONFIGURATION_H

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

#if defined(__cplusplus)
extern "C"
{
#endif
    struct mediator_dart_configuration
    {
        size_t quota_size;
        size_t preallocation_size;
        size_t slab_size;
        size_t static_buffers_capacity;
        size_t static_buffer_size;
        size_t ring_size;
        uint64_t maximum_waking_time_millis;
        uint64_t completion_wait_timeout_millis;
        uint32_t ring_flags;
        uint32_t completion_wait_count;
        uint32_t completion_peek_count;
        bool trace;
    };

    struct mediator_module_native_configuration
    {
        uint64_t completion_wait_timeout_millis;
        size_t quota_size;
        size_t preallocation_size;
        size_t slab_size;
        size_t static_buffers_capacity;
        size_t static_buffer_size;
        size_t ring_size;
        int32_t ring_flags;
        uint32_t completion_wait_count;
    };

    struct mediator_dart_notifier_configuration
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
