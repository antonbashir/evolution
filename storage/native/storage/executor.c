#include "executor.h"
#include <liburing.h>
#include <small/small.h>
#include <system/library.h>
#include "fiber.h"

static struct executor_native* storage_executor;
static bool active;

int32_t storage_executor_initialize(struct storage_executor_configuration* configuration)
{
    storage_executor = calloc(1, sizeof(struct executor_native));
    int32_t descriptor;
    if ((descriptor = executor_native_initialize_default(storage_executor, configuration->executor_id)) < 0)
    {
        return -descriptor;
    }
    active = true;
    return 0;
}
  
void storage_executor_start(struct storage_executor_configuration* configuration)
{
    struct io_uring* ring = storage_executor->ring;
    struct ev_io io;
    ev_init(&io, (ev_io_cb)fiber_schedule_cb);
    io.data = fiber();
    ev_io_set(&io, storage_executor->descriptor, EV_READ);
    ev_set_priority(&io, EV_MAXPRI);
    ev_io_start(loop(), &io);
    while (likely(active))
    {
        io_uring_submit(ring);
        if (likely(io_uring_cq_ready(ring)))
        {
            if (!active) break;
            executor_native_process(storage_executor);
            io_uring_submit(ring);
        }
        fiber_yield();
    }
    ev_io_stop(loop(), &io);
    ev_io_set(&io, -1, EV_READ);
}

int32_t storage_executor_descriptor()
{
    return storage_executor->descriptor;
}

void storage_executor_stop()
{
    active = false;
    struct io_uring_sqe* sqe = io_uring_get_sqe(storage_executor->ring);
    while (unlikely(sqe == NULL))
    {
        struct io_uring_cqe* unused;
        io_uring_wait_cqe_nr(storage_executor->ring, &unused, 1);
        sqe = io_uring_get_sqe(storage_executor->ring);
    }
    io_uring_prep_nop(sqe);
    io_uring_submit(storage_executor->ring);
}

void storage_executor_destroy()
{
    executor_native_destroy(storage_executor);
}