#include "interactor_dart.h"
#include <liburing.h>
#include <liburing/io_uring.h>
#include <stdint.h>
#include <stdlib.h>
#include <sys/socket.h>
#include "interactor_common.h"
#include "interactor_constants.h"

int interactor_dart_initialize(struct interactor_dart* interactor, struct interactor_dart_configuration* configuration, uint8_t id)
{
    interactor->id = id;
    interactor->ring_size = configuration->ring_size;
    interactor->delay_randomization_factor = configuration->delay_randomization_factor;
    interactor->base_delay_micros = configuration->base_delay_micros;
    interactor->max_delay_micros = configuration->max_delay_micros;
    interactor->cqe_wait_timeout_millis = configuration->cqe_wait_timeout_millis;
    interactor->cqe_wait_count = configuration->cqe_wait_count;
    interactor->cqe_peek_count = configuration->cqe_peek_count;

    interactor->completions = malloc(sizeof(struct io_uring_cqe*) * interactor->ring_size);
    if (!interactor->completions)
    {
        return -ENOMEM;
    }

    interactor->ring = calloc(1, sizeof(struct io_uring));
    if (!interactor->ring)
    {
        return -ENOMEM;
    }

    int result = io_uring_queue_init(configuration->ring_size, interactor->ring, configuration->ring_flags);
    if (result)
    {
        return result;
    }

    interactor->descriptor = interactor->ring->ring_fd;

    return interactor->descriptor;
}

int interactor_dart_peek(struct interactor_dart* interactor)
{
    struct __kernel_timespec timeout = {
        .tv_nsec = interactor->cqe_wait_timeout_millis * 1e+6,
        .tv_sec = 0,
    };
    io_uring_submit_and_wait_timeout(interactor->ring, &interactor->completions[0], interactor->cqe_wait_count, &timeout, 0);
    return io_uring_peek_batch_cqe(interactor->ring, &interactor->completions[0], interactor->cqe_peek_count);
}

void interactor_dart_call_native(struct interactor_dart* interactor, int target_ring_fd, struct interactor_message* message)
{
    struct io_uring_sqe* sqe = interactor_provide_sqe(interactor->ring);
    message->source = interactor->descriptor;
    message->target = target_ring_fd;
    message->flags |= INTERACTOR_NATIVE_CALL;
    io_uring_prep_msg_ring(sqe, target_ring_fd, INTERACTOR_NATIVE_CALL, (intptr_t)message, 0);
    sqe->flags |= IOSQE_CQE_SKIP_SUCCESS;
}

void interactor_dart_callback_to_native(struct interactor_dart* interactor, struct interactor_message* message)
{
    struct io_uring_sqe* sqe = interactor_provide_sqe(interactor->ring);
    uint64_t target = message->source;
    message->source = interactor->descriptor;
    message->target = target;
    message->flags |= INTERACTOR_NATIVE_CALLBACK;
    io_uring_prep_msg_ring(sqe, target, INTERACTOR_NATIVE_CALLBACK, (intptr_t)message, 0);
    sqe->flags |= IOSQE_CQE_SKIP_SUCCESS;
}

void interactor_dart_destroy(struct interactor_dart* interactor)
{
    io_uring_queue_exit(interactor->ring);
    free(interactor->ring);
    free(interactor->completions);
}

void interactor_dart_cqe_advance(struct interactor_dart* interactor, int count)
{
    io_uring_cq_advance(interactor->ring, count);
}