#include "executor.h"
#include <liburing.h>
#include <liburing/io_uring.h>
#include <scheduler/scheduler.h>
#include <system/library.h>
#include "configuration.h"
#include "constants.h"
#include "module.h"

struct executor_instance* executor_create(struct executor_configuration* configuration, struct executor_scheduler* scheduler, uint32_t id)
{
    struct executor_instance* executor = executor_module_new(sizeof(struct executor_instance));
    executor->id = id;
    executor->configuration = *configuration;
    executor->scheduler = scheduler;
    executor->state = EXECUTOR_STATE_STOPPED;

    executor->completions = malloc(sizeof(struct io_uring_cqe*) * configuration->ring_size);
    if (!executor->completions)
    {
        return -ENOMEM;
    }

    executor->ring = calloc(1, sizeof(struct io_uring));
    if (!executor->ring)
    {
        return -ENOMEM;
    }

    int32_t result = io_uring_queue_init(configuration->ring_size, executor->ring, configuration->ring_flags);
    if (result)
    {
        return result;
    }

    executor->descriptor = executor->ring->ring_fd;

    return executor->descriptor;
}

int8_t executor_register_scheduler(struct executor_instance* executor, int64_t callback)
{
    executor->callback = callback;
    executor->state = EXECUTOR_STATE_IDLE;
    struct io_uring_sqe* sqe = io_uring_get_sqe(executor->ring);
    if (unlikely(sqe == NULL))
    {
        return EXECUTOR_ERROR_RING_FULL;
    }
    io_uring_prep_msg_ring(sqe, executor->scheduler->descriptor, EXECUTOR_SCHEDULER_REGISTER, (uintptr_t)executor, 0);
    sqe->flags |= IOSQE_CQE_SKIP_SUCCESS;
    io_uring_submit(executor->ring);
    return 0;
}

int8_t executor_unregister_scheduler(struct executor_instance* executor)
{
    executor->state = EXECUTOR_STATE_STOPPED;
    struct io_uring_sqe* sqe = io_uring_get_sqe(executor->ring);
    if (unlikely(sqe == NULL))
    {
        return EXECUTOR_ERROR_RING_FULL;
    }
    io_uring_prep_msg_ring(sqe, executor->scheduler->descriptor, EXECUTOR_SCHEDULER_UNREGISTER, executor->id, 0);
    sqe->flags |= IOSQE_CQE_SKIP_SUCCESS;
    io_uring_submit(executor->ring);
    return 0;
}

int32_t executor_peek(struct executor_instance* executor)
{
    struct executor_configuration* configuration = &executor->configuration;
    io_uring_submit_and_get_events(executor->ring);
    return io_uring_peek_batch_cqe(executor->ring, &executor->completions[0], configuration->ring_size);
}

int8_t executor_call_native(struct executor_instance* executor, int32_t target_ring_fd, struct executor_task* message)
{
    struct io_uring* ring = executor->ring;
    struct io_uring_sqe* sqe = io_uring_get_sqe(ring);
    if (unlikely(sqe == NULL))
    {
        return EXECUTOR_ERROR_RING_FULL;
    }
    message->source = executor->descriptor;
    message->target = target_ring_fd;
    message->flags |= EXECUTOR_CALL;
    io_uring_prep_msg_ring(sqe, target_ring_fd, EXECUTOR_CALLBACK, (uintptr_t)message, 0);
    sqe->flags |= IOSQE_CQE_SKIP_SUCCESS;
    if (executor->state & EXECUTOR_STATE_IDLE) io_uring_submit(ring);
    return 0;
}

int8_t executor_callback_to_native(struct executor_instance* executor, struct executor_task* message)
{
    struct io_uring* ring = executor->ring;
    struct io_uring_sqe* sqe = io_uring_get_sqe(ring);
    if (unlikely(sqe == NULL))
    {
        return EXECUTOR_ERROR_RING_FULL;
    }
    uint64_t target = message->source;
    message->source = executor->descriptor;
    message->target = target;
    message->flags |= EXECUTOR_CALLBACK;
    io_uring_prep_msg_ring(sqe, target, EXECUTOR_CALLBACK, (uintptr_t)message, 0);
    sqe->flags |= IOSQE_CQE_SKIP_SUCCESS;
    if (executor->state & EXECUTOR_STATE_IDLE) io_uring_submit(ring);
    return 0;
}

void executor_destroy(struct executor_instance* executor)
{
    io_uring_queue_exit(executor->ring);
    free(executor->ring);
    free(executor->completions);
}

void executor_submit(struct executor_instance* executor)
{
    io_uring_submit(executor->ring);
}

int8_t executor_awake_begin(struct executor_instance* executor)
{
    executor->state = EXECUTOR_STATE_WAKING;
    struct io_uring_sqe* sqe = io_uring_get_sqe(executor->ring);
    if (unlikely(sqe == NULL))
    {
        return EXECUTOR_ERROR_RING_FULL;
    }
    io_uring_prep_msg_ring(sqe, executor->scheduler->descriptor, EXECUTOR_SCHEDULER_POLL, (uintptr_t)executor, 0);
    sqe->flags |= IOSQE_CQE_SKIP_SUCCESS;
    return 0;
}

void executor_awake_complete(struct executor_instance* executor, uint32_t completions)
{
    io_uring_cq_advance(executor->ring, completions);
    io_uring_submit(executor->ring);
    executor->state = EXECUTOR_STATE_IDLE;
}