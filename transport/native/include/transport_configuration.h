#ifndef TRANSPORT_CONFIGURATION_H
#define TRANSPORT_CONFIGURATION_H

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

#if defined(__cplusplus)
extern "C"
{
#endif
    struct memory_module_configuration;
    struct transport_module_configuration
    {
        struct memory_module_configuration* memory_configuration;
        size_t ring_size;
        unsigned int ring_flags;
        uint64_t timeout_checker_period_millis;
        uint32_t base_delay_micros;
        double delay_randomization_factor;
        uint64_t max_delay_micros;
        uint64_t cqe_wait_timeout_millis;
        uint32_t cqe_wait_count;
        uint32_t cqe_peek_count;
        bool trace;
    };
#if defined(__cplusplus)
}
#endif

#endif
