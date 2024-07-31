#include "executor.h"
#include <liburing.h>
#include <liburing/io_uring.h>
#include <scheduler/scheduler.h>
#include <system/library.h>
#include "configuration.h"
#include "constants.h"
#include "errors.h"
#include "module.h"

struct executor_instance* executor_create(struct executor_configuration* configuration, struct executor_scheduler* scheduler, uint32_t id)
{
    struct executor_instance* executor = executor_module_new(sizeof(struct executor_instance));
    if (executor == NULL)
    {
        event_propagate_local(executor_error_out_of_memory());
        return NULL;
    }

    executor->id = id;
    executor->configuration = *configuration;
    executor->scheduler = scheduler;
    executor->state = EXECUTOR_STATE_PAUSED;

    executor->completions = executor_module_allocate(configuration->ring_size, sizeof(struct io_uring_cqe*));
    if (executor->completions == NULL)
    {
        event_propagate_local(executor_error_out_of_memory());
        return NULL;
    }

    executor->ring = executor_module_new(sizeof(struct io_uring));
    if (executor->ring == NULL)
    {
        event_propagate_local(executor_error_out_of_memory());
        return NULL;
    }

    int32_t result = io_uring_queue_init(configuration->ring_size, executor->ring, configuration->ring_flags);
    if (result)
    {
        event_propagate_local(executor_error_system(-result));
        return NULL;
    }

    executor->descriptor = executor->ring->ring_fd;

    return executor;
}

int16_t executor_register_on_scheduler(struct executor_instance* executor, int64_t callback)
{
    executor->callback = callback;
    executor->state = EXECUTOR_STATE_IDLE;
    struct io_uring_sqe* sqe = io_uring_get_sqe(executor->ring);
    if (unlikely(sqe == NULL))
    {
        event_propagate_local(executor_error_ring_full());
        return MODULE_ERROR_CODE;
    }
    io_uring_prep_msg_ring(sqe, executor->scheduler->descriptor, EXECUTOR_SCHEDULER_REGISTER, (uintptr_t)executor, 0);
    sqe->flags |= IOSQE_CQE_SKIP_SUCCESS;
    io_uring_submit(executor->ring);
    return 0;
}

int16_t executor_unregister_from_scheduler(struct executor_instance* executor, bool stop)
{
    executor->state = stop ? EXECUTOR_STATE_STOPPED : EXECUTOR_STATE_PAUSED;
    struct io_uring_sqe* sqe = io_uring_get_sqe(executor->ring);
    if (unlikely(sqe == NULL))
    {
        event_propagate_local(executor_error_ring_full());
        return MODULE_ERROR_CODE;
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

int16_t executor_call_native(struct executor_instance* executor, int32_t target_ring_fd, struct executor_task* task)
{
    struct io_uring* ring = executor->ring;
    struct io_uring_sqe* sqe = io_uring_get_sqe(ring);
    if (unlikely(sqe == NULL))
    {
        event_propagate_local(executor_error_ring_full());
        return MODULE_ERROR_CODE;
    }
    task->source = executor->descriptor;
    task->target = target_ring_fd;
    io_uring_prep_msg_ring(sqe, target_ring_fd, EXECUTOR_CALL, (uintptr_t)task, 0);
    sqe->flags |= IOSQE_CQE_SKIP_SUCCESS;
    executor_submit(executor);
    return 0;
}

int16_t executor_callback_to_native(struct executor_instance* executor, struct executor_task* task)
{
    struct io_uring* ring = executor->ring;
    struct io_uring_sqe* sqe = io_uring_get_sqe(ring);
    if (unlikely(sqe == NULL))
    {
        event_propagate_local(executor_error_ring_full());
        return MODULE_ERROR_CODE;
    }
    uint64_t target = task->source;
    task->source = executor->descriptor;
    task->target = target;
    io_uring_prep_msg_ring(sqe, target, EXECUTOR_CALLBACK, (uintptr_t)task, 0);
    sqe->flags |= IOSQE_CQE_SKIP_SUCCESS;
    executor_submit(executor);
    return 0;
}

void executor_destroy(struct executor_instance* executor)
{
    io_uring_queue_exit(executor->ring);
    executor_module_delete(executor->ring);
    executor_module_delete(executor->completions);
    executor_module_delete(executor);
}

int16_t executor_awake_begin(struct executor_instance* executor)
{
    executor->state = EXECUTOR_STATE_WAKING;
    struct io_uring_sqe* sqe = io_uring_get_sqe(executor->ring);
    if (unlikely(sqe == NULL))
    {
        event_propagate_local(executor_error_ring_full());
        return MODULE_ERROR_CODE;
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