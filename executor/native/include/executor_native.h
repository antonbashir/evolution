#ifndef EXECUTOR_NATIVE_H
#define EXECUTOR_NATIVE_H

#include <executor_configuration.h>
#include <executor_message.h>
#include <stdint.h>

struct simple_map_native_callbacks_t;
struct io_uring;
typedef struct io_uring_cqe executor_native_completion_event;

#if defined(__cplusplus)
extern "C"
{
#endif

    struct executor_native
    {
        uint8_t id;
        struct executor_native_configuration configuration;
        struct io_uring* ring;
        executor_native_completion_event** completions;
        struct simple_map_native_callbacks_t* callbacks;
        int32_t descriptor;
    };

    int32_t executor_native_initialize(struct executor_native* executor, struct executor_native_configuration* configuration, uint8_t id);

    int32_t executor_native_initialize_default(struct executor_native* executor, uint8_t id);

    void executor_native_register_callback(struct executor_native* executor, uint64_t owner, uint64_t method, void (*callback)(struct executor_message*));

    int32_t executor_native_count_ready(struct executor_native* executor);
    int32_t executor_native_count_ready_submit(struct executor_native* executor);

    int8_t executor_native_process(struct executor_native* executor);
    int8_t executor_native_process_infinity(struct executor_native* executor);
    int8_t executor_native_process_timeout(struct executor_native* executor);

    void executor_native_foreach(struct executor_native* executor, void (*call)(struct executor_message*), void (*callback)(struct executor_message*));

    int32_t executor_native_submit(struct executor_native* executor);

    int8_t executor_native_call_dart(struct executor_native* executor, int32_t target_ring_fd, struct executor_message* message);
    int8_t executor_native_callback_to_dart(struct executor_native* executor, struct executor_message* message);

    void executor_native_destroy(struct executor_native* executor);
#if defined(__cplusplus)
}
#endif

#endif