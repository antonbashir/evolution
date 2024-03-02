#include "mediator_dart.h"
#include <liburing.h>
#include <liburing/io_uring.h>
#include <stdint.h>
#include <stdlib.h>
#include <sys/socket.h>
#include "mediator_common.h"
#include "mediator_configuration.h"
#include "mediator_constants.h"

int32_t mediator_dart_initialize(struct mediator_dart* mediator, struct mediator_dart_configuration* configuration, struct mediator_dart_notifier* notifier, uint32_t id)
{
    mediator->id = id;
    mediator->configuration = *configuration;
    mediator->notifier = notifier;
    mediator->state = MEDIATOR_STATE_STOPPED;

    mediator->completions = malloc(sizeof(struct io_uring_cqe*) * configuration->ring_size);
    if (!mediator->completions)
    {
        return -ENOMEM;
    }

    mediator->ring = calloc(1, sizeof(struct io_uring));
    if (!mediator->ring)
    {
        return -ENOMEM;
    }

    int32_t result = io_uring_queue_init(configuration->ring_size, mediator->ring, configuration->ring_flags);
    if (result)
    {
        return result;
    }

    mediator->descriptor = mediator->ring->ring_fd;

    return mediator->descriptor;
}

void mediator_dart_setup(struct mediator_dart* mediator, mediator_notify_callback callback)
{
    mediator->callback = callback;
    mediator->state = MEDIATOR_STATE_IDLE;
    struct io_uring_sqe* sqe = mediator_provide_sqe(mediator->ring);
    io_uring_prep_msg_ring(sqe, mediator->notifier->descriptor, MEDIATOR_NOTIFIER_REGISTER, (uintptr_t)mediator, 0);
    sqe->flags |= IOSQE_CQE_SKIP_SUCCESS;
    io_uring_submit(mediator->ring);
}

int32_t mediator_dart_peek(struct mediator_dart* mediator)
{
    struct mediator_dart_configuration* configuration = &mediator->configuration;
    return io_uring_peek_batch_cqe(mediator->ring, &mediator->completions[0], configuration->completion_peek_count);
}

int32_t mediator_dart_peek_wait(struct mediator_dart* mediator)
{
    struct mediator_dart_configuration* configuration = &mediator->configuration;
    struct __kernel_timespec timeout = {
        .tv_nsec = configuration->completion_wait_timeout_millis * 1e+6,
        .tv_sec = 0,
    };
    io_uring_submit_and_wait_timeout(mediator->ring, &mediator->completions[0], configuration->completion_wait_count, &timeout, 0);
    return io_uring_peek_batch_cqe(mediator->ring, &mediator->completions[0], configuration->completion_peek_count);
}

void mediator_dart_call_native(struct mediator_dart* mediator, int32_t target_ring_fd, struct mediator_message* message)
{
    struct io_uring* ring = mediator->ring;
    struct io_uring_sqe* sqe = mediator_provide_sqe(ring);
    message->source = mediator->descriptor;
    message->target = target_ring_fd;
    message->flags |= MEDIATOR_NATIVE_CALL;
    io_uring_prep_msg_ring(sqe, target_ring_fd, MEDIATOR_NATIVE_CALL, (intptr_t)message, 0);
    sqe->flags |= IOSQE_CQE_SKIP_SUCCESS;
    if (mediator->state & MEDIATOR_STATE_IDLE) io_uring_submit(ring);
}

void mediator_dart_callback_to_native(struct mediator_dart* mediator, struct mediator_message* message)
{
    struct io_uring* ring = mediator->ring;
    struct io_uring_sqe* sqe = mediator_provide_sqe(ring);
    uint64_t target = message->source;
    message->source = mediator->descriptor;
    message->target = target;
    message->flags |= MEDIATOR_NATIVE_CALLBACK;
    io_uring_prep_msg_ring(sqe, target, MEDIATOR_NATIVE_CALLBACK, (intptr_t)message, 0);
    sqe->flags |= IOSQE_CQE_SKIP_SUCCESS;
    if (mediator->state & MEDIATOR_STATE_IDLE) io_uring_submit(ring);
}

void mediator_dart_destroy(struct mediator_dart* mediator)
{
    struct io_uring_sqe* sqe = mediator_provide_sqe(mediator->ring);
    io_uring_prep_msg_ring(sqe, mediator->notifier->descriptor, MEDIATOR_NOTIFIER_UNREGISTER, (uintptr_t)mediator, 0);
    sqe->flags |= IOSQE_CQE_SKIP_SUCCESS;
    io_uring_submit(mediator->ring);
    io_uring_queue_exit(mediator->ring);
    free(mediator->ring);
    free(mediator->completions);
}

void mediator_dart_submit(struct mediator_dart* mediator)
{
  io_uring_submit(mediator->ring);
}

void mediator_dart_completion_advance(struct mediator_dart* mediator, int32_t count)
{
    io_uring_cq_advance(mediator->ring, count);
}