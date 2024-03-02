#ifndef MEDIATOR_CONFIGURATION_H
#define MEDIATOR_CONFIGURATION_H

#include <stddef.h>
#include <stdint.h>

#if defined(__cplusplus)
extern "C"
{
#endif
   struct mediator_module_dart_configuration
    {
        size_t quota_size;
        size_t preallocation_size;
        size_t slab_size;
        size_t static_buffers_capacity;
        size_t static_buffer_size;
        size_t ring_size;
        double delay_randomization_factor;
        uint64_t max_delay_micros;
        uint64_t cqe_wait_timeout_millis;
        uint32_t ring_flags;
        uint32_t base_delay_micros;
        uint32_t cqe_wait_count;
        uint32_t cqe_peek_count;
    };

    struct mediator_module_native_configuration
    {
        uint64_t cqe_wait_timeout_millis;
        size_t quota_size;
        size_t preallocation_size;
        size_t slab_size;
        size_t static_buffers_capacity;
        size_t static_buffer_size;
        size_t ring_size;
        int32_t ring_flags;
        uint32_t cqe_wait_count;
        uint32_t cqe_peek_count;
    };
#if defined(__cplusplus)
}
#endif

#endif
