#ifndef EXECUTOR_H
#define EXECUTOR_H

#include <common/common.h>
#include <liburing.h>
#include "configuration.h"
#include "constants.h"
#include "task.h"

#if defined(__cplusplus)
extern "C"
{
#endif

DART_TYPE struct io_uring;
DART_STRUCTURE struct executor_instance
{
    DART_FIELD int64_t callback;
    DART_FIELD struct executor_scheduler* scheduler;
    DART_FIELD struct io_uring* ring;
    DART_FIELD DART_SUBSTITUTE(struct executor_completion_event**) struct io_uring_cqe** completions;
    DART_FIELD struct executor_configuration configuration;
    DART_FIELD int32_t descriptor;
    DART_FIELD uint32_t id;
    DART_FIELD int8_t state;
};

DART_LEAF_FUNCTION struct executor_instance* executor_create(struct executor_configuration* configuration, struct executor_scheduler* scheduler, uint32_t id);
DART_LEAF_FUNCTION int8_t executor_register_on_scheduler(struct executor_instance* executor, int64_t callback);
DART_LEAF_FUNCTION int8_t executor_unregister_from_scheduler(struct executor_instance* executor, bool stop);
DART_LEAF_FUNCTION int32_t executor_peek(struct executor_instance* executor);
DART_LEAF_FUNCTION int8_t executor_awake_begin(struct executor_instance* executor);
DART_LEAF_FUNCTION void executor_awake_complete(struct executor_instance* executor, uint32_t completions);
DART_LEAF_FUNCTION int8_t executor_call_native(struct executor_instance* executor, int32_t target_ring_fd, struct executor_task* message);
DART_LEAF_FUNCTION int8_t executor_callback_to_native(struct executor_instance* executor, struct executor_task* message);

DART_INLINE_LEAF_FUNCTION void executor_submit(struct executor_instance* executor)
{
    io_uring_submit(executor->ring);
}

DART_INLINE_LEAF_FUNCTION int8_t executor_call_dart(struct io_uring* ring, int32_t source_ring_fd, int32_t target_ring_fd, struct executor_task* message)
{
    struct io_uring_sqe* sqe = io_uring_get_sqe(ring);
    if (unlikely(sqe == NULL))
    {
        return EXECUTOR_ERROR_RING_FULL;
    }
    message->source = source_ring_fd;
    message->target = target_ring_fd;
    message->flags |= EXECUTOR_CALL;
    io_uring_prep_msg_ring(sqe, target_ring_fd, EXECUTOR_CALL, (uint64_t)((uintptr_t)message), 0);
    sqe->flags |= IOSQE_CQE_SKIP_SUCCESS;
    return 0;
}

DART_INLINE_LEAF_FUNCTION int8_t executor_callback_to_dart(struct io_uring* ring, int32_t source_ring_fd, struct executor_task* message)
{
    struct io_uring_sqe* sqe = io_uring_get_sqe(ring);
    if (unlikely(sqe == NULL))
    {
        return EXECUTOR_ERROR_RING_FULL;
    }
    uint64_t target = message->source;
    message->source = source_ring_fd;
    message->target = target;
    message->flags |= EXECUTOR_CALLBACK;
    io_uring_prep_msg_ring(sqe, target, EXECUTOR_CALLBACK, (uint64_t)((uintptr_t)message), 0);
    sqe->flags |= IOSQE_CQE_SKIP_SUCCESS;
    return 0;
}

DART_LEAF_FUNCTION void executor_destroy(struct executor_instance* executor);

#if defined(__cplusplus)
}
#endif

#endif