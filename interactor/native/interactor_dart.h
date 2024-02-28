#ifndef INTERACTOR_DART_IMPLEMENTATION_H
#define INTERACTOR_DART_IMPLEMENTATION_H

#include <interactor_message.h>
#include <interactor_configuration.h>

struct io_uring;
typedef struct io_uring_cqe interactor_dart_completion_event;

#if defined(__cplusplus)
extern "C"
{
#endif
 
    struct interactor_dart
    {
        struct io_uring* ring;
        size_t ring_size;
        uint64_t cqe_wait_timeout_millis;
        uint64_t max_delay_micros;
        double delay_randomization_factor;
        interactor_dart_completion_event** completions;
        int32_t descriptor;
        uint32_t ring_flags;
        uint32_t cqe_wait_count;
        uint32_t cqe_peek_count;
        uint32_t base_delay_micros;
        uint8_t id;
    };

    int interactor_dart_initialize(struct interactor_dart* interactor, struct interactor_module_dart_configuration* configuration, uint8_t id);

    int interactor_dart_peek(struct interactor_dart* interactor);

    void interactor_dart_call_native(struct interactor_dart* interactor, int target_ring_fd, struct interactor_message* message);
    void interactor_dart_callback_to_native(struct interactor_dart* interactor, struct interactor_message* message);

    void interactor_dart_cqe_advance(struct interactor_dart* interactor, int count);

    void interactor_dart_destroy(struct interactor_dart* interactor);
#if defined(__cplusplus)
}
#endif

#endif