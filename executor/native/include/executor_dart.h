#ifndef EXECUTOR_DART_H
#define EXECUTOR_DART_H

#include <executor_configuration.h>
#include <executor_message.h>

struct io_uring;
typedef struct io_uring_cqe executor_dart_completion_event;

#if defined(__cplusplus)
extern "C"
{
#endif
    struct executor_dart
    {
        int64_t callback;
        struct executor_dart_notifier* notifier;
        struct io_uring* ring;
        executor_dart_completion_event** completions;
        struct executor_dart_configuration configuration;
        int32_t descriptor;
        uint32_t id;
        int8_t state;
    };

    int32_t executor_dart_initialize(struct executor_dart* executor, struct executor_dart_configuration* configuration, struct executor_dart_notifier* notifier, uint32_t id);
    int8_t executor_dart_register(struct executor_dart* executor, int64_t callback);
    int8_t executor_dart_unregister(struct executor_dart* executor);

    int32_t executor_dart_peek(struct executor_dart* executor);

    void executor_dart_submit(struct executor_dart* executor);

    int8_t executor_dart_awake(struct executor_dart* executor);
    void executor_dart_sleep(struct executor_dart* executor, uint32_t completions);

    int8_t executor_dart_call_native(struct executor_dart* executor, int32_t target_ring_fd, struct executor_message* message);
    int8_t executor_dart_callback_to_native(struct executor_dart* executor, struct executor_message* message);

    void executor_dart_destroy(struct executor_dart* executor);
#if defined(__cplusplus)
}
#endif

#endif