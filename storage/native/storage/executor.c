// clang-format off
#include "trivia/util.h"
#include "executor.h"
#include <events/events.h>
#include <executor/constants.h>
#include <executor/task.h>
#include <liburing.h>
#include <small/small.h>
#include <system/library.h>
#include "fiber.h"
// clang-format on

struct storage_executor executor;

int32_t storage_executor_initialize(struct storage_executor_configuration* configuration)
{
    int32_t result;
    if ((result = io_uring_queue_init(configuration->ring_size, &executor.ring, configuration->ring_flags)) != 0)
    {
        event_propagate_local(event_system_error(-result));
    }
    executor.active = true;
    executor.configuration = configuration;
    executor.descriptor = executor.ring.ring_fd;
    return 0;
}

void storage_executor_start()
{
    struct io_uring* ring = &executor.ring;
    struct ev_io io;
    ev_init(&io, (ev_io_cb)fiber_schedule_cb);
    io.data = fiber();
    ev_io_set(&io, executor.descriptor, EV_READ);
    ev_set_priority(&io, EV_MAXPRI);
    ev_io_start(loop(), &io);
    struct io_uring_cqe* cqe;
    while (likely(executor.active))
    {
        io_uring_submit(ring);
        if (likely(io_uring_cq_ready(ring)))
        {
            if (!executor.active) break;
            unsigned head;
            unsigned count = 0;
            io_uring_for_each_cqe(ring, head, cqe)
            {
                ++count;
                struct executor_task* task = (struct executor_task*)cqe->user_data;
                if (task != NULL)
                {
                    void (*pointer)(struct executor_task*) = (void (*)(struct executor_task*))task->method;
                    pointer(task);
                    struct io_uring_sqe* sqe = io_uring_get_sqe(ring);
                    uint64_t target = task->source;
                    task->source = executor.descriptor;
                    task->target = target;
                    io_uring_prep_msg_ring(sqe, target, EXECUTOR_CALLBACK, (uint64_t)((intptr_t)task), 0);
                    sqe->flags |= IOSQE_CQE_SKIP_SUCCESS;
                }
            }
            io_uring_cq_advance(ring, count);
            io_uring_submit(ring);
        }
        fiber_yield();
    }
    ev_io_stop(loop(), &io);
    ev_io_set(&io, -1, EV_READ);
}

int32_t storage_executor_descriptor()
{
    return executor.descriptor;
}

void storage_executor_stop()
{
    executor.active = false;
    struct io_uring_sqe* sqe = io_uring_get_sqe(&executor.ring);
    while (unlikely(sqe == NULL))
    {
        struct io_uring_cqe* unused;
        io_uring_wait_cqe_nr(&executor.ring, &unused, 1);
        sqe = io_uring_get_sqe(&executor.ring);
    }
    io_uring_prep_nop(sqe);
    io_uring_submit(&executor.ring);
}

void storage_executor_destroy()
{
    io_uring_queue_exit(&executor.ring);
}