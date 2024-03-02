#ifndef MEDIATOR_DART_H
#define MEDIATOR_DART_H

#include <mediator_configuration.h>
#include <mediator_message.h>
#include "mediator_dart_notifier.h"

struct io_uring;
typedef struct io_uring_cqe mediator_dart_completion_event;

#if defined(__cplusplus)
extern "C"
{
#endif
    typedef void (*mediator_notify_callback)();

    struct mediator_dart
    {
        mediator_notify_callback callback;
        struct mediator_dart_notifier* notifier;
        struct io_uring* ring;
        mediator_dart_completion_event** completions;
        struct mediator_dart_configuration configuration;
        int32_t descriptor;
        int8_t state;
    };

    int32_t mediator_dart_initialize(struct mediator_dart* mediator, struct mediator_dart_configuration* configuration, struct mediator_dart_notifier* notifier);
    void mediator_dart_setup(struct mediator_dart* mediator, mediator_notify_callback callback);

    int32_t mediator_dart_peek(struct mediator_dart* mediator);
    int32_t mediator_dart_peek_wait(struct mediator_dart* mediator);
    
    void mediator_dart_submit(struct mediator_dart* mediator);

    void mediator_dart_call_native(struct mediator_dart* mediator, int32_t target_ring_fd, struct mediator_message* message);
    void mediator_dart_callback_to_native(struct mediator_dart* mediator, struct mediator_message* message);

    void mediator_dart_completion_advance(struct mediator_dart* mediator, int32_t count);

    void mediator_dart_destroy(struct mediator_dart* mediator);
#if defined(__cplusplus)
}
#endif

#endif