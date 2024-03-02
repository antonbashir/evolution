#ifndef MEDIATOR_DART_IMPLEMENTATION_H
#define MEDIATOR_DART_IMPLEMENTATION_H

#include <mediator_message.h>
#include <mediator_configuration.h>

struct io_uring;
typedef struct io_uring_cqe mediator_dart_completion_event;

#if defined(__cplusplus)
extern "C"
{
#endif
 
    struct mediator_dart
    {
        struct io_uring* ring;
        size_t ring_size;
        uint64_t cqe_wait_timeout_millis;
        uint64_t max_delay_micros;
        double delay_randomization_factor;
        mediator_dart_completion_event** completions;
        int32_t descriptor;
        uint32_t ring_flags;
        uint32_t cqe_wait_count;
        uint32_t cqe_peek_count;
        uint32_t base_delay_micros;
        uint8_t id;
    };

    int mediator_dart_initialize(struct mediator_dart* mediator, struct mediator_module_dart_configuration* configuration, uint8_t id);

    int mediator_dart_peek(struct mediator_dart* mediator);

    void mediator_dart_call_native(struct mediator_dart* mediator, int target_ring_fd, struct mediator_message* message);
    void mediator_dart_callback_to_native(struct mediator_dart* mediator, struct mediator_message* message);

    void mediator_dart_cqe_advance(struct mediator_dart* mediator, int count);

    void mediator_dart_destroy(struct mediator_dart* mediator);
#if defined(__cplusplus)
}
#endif

#endif