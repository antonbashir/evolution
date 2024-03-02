#include "tarantool_executor.h"
#include <liburing.h>
#include <small/small.h>
#include <stdbool.h>
#include <sys/eventfd.h>
#include "fiber.h"
#include "mediator_native.h"

static struct mediator_native* tarantool_mediator;
static bool active;

int32_t tarantool_executor_initialize(struct tarantool_executor_configuration* configuration)
{
    tarantool_mediator = calloc(1, sizeof(struct mediator_native));
    int32_t descriptor;
    if ((descriptor = mediator_native_initialize_default(tarantool_mediator, configuration->mediator_id)) < 0)
    {
        return -descriptor;
    }
    active = true;
    return 0;
}
  
void tarantool_executor_start(struct tarantool_executor_configuration* configuration)
{
    struct io_uring* ring = tarantool_mediator->ring;
    struct ev_io io;
    ev_init(&io, (ev_io_cb)fiber_schedule_cb);
    io.data = fiber();
    ev_io_set(&io, tarantool_mediator->descriptor, EV_READ);
    ev_set_priority(&io, EV_MAXPRI);
    ev_io_start(loop(), &io);
    while (likely(active))
    {
        io_uring_submit(ring);
        if (likely(io_uring_cq_ready(ring)))
        {
            if (!active) break;
            mediator_native_process(tarantool_mediator);
            io_uring_submit(ring);
        }
        fiber_yield();
    }
    ev_io_stop(loop(), &io);
    ev_io_set(&io, -1, EV_READ);
}

int32_t tarantool_executor_descriptor()
{
    return tarantool_mediator->descriptor;
}

void tarantool_executor_stop()
{
    active = false;
    struct io_uring_sqe* sqe = io_uring_get_sqe(tarantool_mediator->ring);
    while (unlikely(sqe == NULL))
    {
        struct io_uring_cqe* unused;
        io_uring_wait_cqe_nr(tarantool_mediator->ring, &unused, 1);
        sqe = io_uring_get_sqe(tarantool_mediator->ring);
    }
    io_uring_prep_nop(sqe);
    io_uring_submit(tarantool_mediator->ring);
}

void tarantool_executor_destroy()
{
    mediator_native_destroy(tarantool_mediator);
}