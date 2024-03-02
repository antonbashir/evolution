#ifndef MEDIATOR_NATIVE_H
#define MEDIATOR_NATIVE_H

#include <mediator_configuration.h>
#include <mediator_message.h>
#include <stdint.h>

struct mh_native_callbacks_t;
struct io_uring;
typedef struct io_uring_cqe mediator_native_completion_event;

#if defined(__cplusplus)
extern "C"
{
#endif

    struct mediator_native
    {
        struct mediator_module_native_configuration configuration;
        struct io_uring* ring;
        mediator_native_completion_event** completions;
        struct mh_native_callbacks_t* callbacks;
        int32_t descriptor;
    };

    int32_t mediator_native_initialize(struct mediator_native* mediator, struct mediator_module_native_configuration* configuration, uint8_t id);

    int32_t mediator_native_initialize_default(struct mediator_native* mediator, uint8_t id);

    void mediator_native_register_callback(struct mediator_native* mediator, uint64_t owner, uint64_t method, void (*callback)(struct mediator_message*));

    int32_t mediator_native_count_ready(struct mediator_native* mediator);
    int32_t mediator_native_count_ready_submit(struct mediator_native* mediator);

    void mediator_native_process(struct mediator_native* mediator);
    void mediator_native_process_infinity(struct mediator_native* mediator);
    void mediator_native_process_timeout(struct mediator_native* mediator);

    void mediator_native_foreach(struct mediator_native* mediator, void (*call)(struct mediator_message*), void (*callback)(struct mediator_message*));

    int32_t mediator_native_submit(struct mediator_native* mediator);

    void mediator_native_call_dart(struct mediator_native* mediator, int32_t target_ring_fd, struct mediator_message* message);
    void mediator_native_callback_to_dart(struct mediator_native* mediator, struct mediator_message* message);

    void mediator_native_destroy(struct mediator_native* mediator);
#if defined(__cplusplus)
}
#endif

#endif