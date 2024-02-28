#ifndef INTERACTOR_NATIVE_H
#define INTERACTOR_NATIVE_H

#include <interactor_configuration.h>
#include <interactor_message.h>
#include <stddef.h>
#include <stdint.h>

struct mh_native_callbacks_t;
struct io_uring;
typedef struct io_uring_cqe interactor_native_completion_event;

#if defined(__cplusplus)
extern "C"
{
#endif

    struct interactor_native
    {
        uint64_t cqe_wait_timeout_millis;
        size_t ring_size;
        struct io_uring* ring;
        interactor_native_completion_event** completions;
        struct mh_native_callbacks_t* callbacks;
        int32_t descriptor;
        int32_t ring_flags;
        uint32_t cqe_wait_count;
        uint32_t cqe_peek_count;
        uint8_t id;
    };

    int interactor_native_initialize(struct interactor_native* interactor, struct interactor_module_native_configuration* configuration, uint8_t id);

    int interactor_native_initialize_default(struct interactor_native* interactor, uint8_t id);

    void interactor_native_register_callback(struct interactor_native* interactor, uint64_t owner, uint64_t method, void (*callback)(struct interactor_message*));

    int interactor_native_count_ready(struct interactor_native* interactor);
    int interactor_native_count_ready_submit(struct interactor_native* interactor);

    void interactor_native_process(struct interactor_native* interactor);
    void interactor_native_process_infinity(struct interactor_native* interactor);
    void interactor_native_process_timeout(struct interactor_native* interactor);

    void interactor_native_foreach(struct interactor_native* interactor, void (*call)(struct interactor_message*), void (*callback)(struct interactor_message*));

    int interactor_native_submit(struct interactor_native* interactor);

    void interactor_native_call_dart(struct interactor_native* interactor, int target_ring_fd, struct interactor_message* message);
    void interactor_native_callback_to_dart(struct interactor_native* interactor, struct interactor_message* message);

    void interactor_native_destroy(struct interactor_native* interactor);
#if defined(__cplusplus)
}
#endif

#endif