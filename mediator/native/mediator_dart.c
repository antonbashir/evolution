#include "mediator_dart.h"
#include <liburing.h>
#include <liburing/io_uring.h>
#include <stdint.h>
#include <stdlib.h>
#include <sys/socket.h>
#include "mediator_common.h"
#include "mediator_configuration.h"
#include "mediator_constants.h"

int mediator_dart_initialize(struct mediator_dart* mediator, struct mediator_module_dart_configuration* configuration, uint8_t id)
{
    mediator->id = id;
    mediator->ring_size = configuration->ring_size;
    mediator->delay_randomization_factor = configuration->delay_randomization_factor;
    mediator->base_delay_micros = configuration->base_delay_micros;
    mediator->max_delay_micros = configuration->max_delay_micros;
    mediator->cqe_wait_timeout_millis = configuration->cqe_wait_timeout_millis;
    mediator->cqe_wait_count = configuration->cqe_wait_count;
    mediator->cqe_peek_count = configuration->cqe_peek_count;

    mediator->completions = malloc(sizeof(struct io_uring_cqe*) * mediator->ring_size);
    if (!mediator->completions)
    {
        return -ENOMEM;
    }

    mediator->ring = calloc(1, sizeof(struct io_uring));
    if (!mediator->ring)
    {
        return -ENOMEM;
    }

    int result = io_uring_queue_init(configuration->ring_size, mediator->ring, configuration->ring_flags);
    if (result)
    {
        return result;
    }

    mediator->descriptor = mediator->ring->ring_fd;

    return mediator->descriptor;
}

int mediator_dart_peek(struct mediator_dart* mediator)
{
    struct __kernel_timespec timeout = {
        .tv_nsec = mediator->cqe_wait_timeout_millis * 1e+6,
        .tv_sec = 0,
    };
    io_uring_submit_and_wait_timeout(mediator->ring, &mediator->completions[0], mediator->cqe_wait_count, &timeout, 0);
    return io_uring_peek_batch_cqe(mediator->ring, &mediator->completions[0], mediator->cqe_peek_count);
}

void mediator_dart_call_native(struct mediator_dart* mediator, int target_ring_fd, struct mediator_message* message)
{
    struct io_uring_sqe* sqe = mediator_provide_sqe(mediator->ring);
    message->source = mediator->descriptor;
    message->target = target_ring_fd;
    message->flags |= MEDIATOR_NATIVE_CALL;
    io_uring_prep_msg_ring(sqe, target_ring_fd, MEDIATOR_NATIVE_CALL, (intptr_t)message, 0);
    sqe->flags |= IOSQE_CQE_SKIP_SUCCESS;
}

void mediator_dart_callback_to_native(struct mediator_dart* mediator, struct mediator_message* message)
{
    struct io_uring_sqe* sqe = mediator_provide_sqe(mediator->ring);
    uint64_t target = message->source;
    message->source = mediator->descriptor;
    message->target = target;
    message->flags |= MEDIATOR_NATIVE_CALLBACK;
    io_uring_prep_msg_ring(sqe, target, MEDIATOR_NATIVE_CALLBACK, (intptr_t)message, 0);
    sqe->flags |= IOSQE_CQE_SKIP_SUCCESS;
}

void mediator_dart_destroy(struct mediator_dart* mediator)
{
    io_uring_queue_exit(mediator->ring);
    free(mediator->ring);
    free(mediator->completions);
}

void mediator_dart_cqe_advance(struct mediator_dart* mediator, int count)
{
    io_uring_cq_advance(mediator->ring, count);
}