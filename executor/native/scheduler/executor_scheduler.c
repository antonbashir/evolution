#include "executor_scheduler.h"
#include <common/common.h>
#include <common/errors.h>
#include <common/modules.h>
#include <dart/dart_native_api.h>
#include <executor.h>
#include <executor_common.h>
#include <executor_constants.h>
#include <liburing.h>
#include <system/library.h>
#include <system/scheduling.h>
#include <system/threading.h>
#include <system/time.h>

static FORCEINLINE struct io_uring_sqe* executor_scheduler_provide_sqe(struct io_uring* ring)
{
    struct io_uring_sqe* sqe = io_uring_get_sqe(ring);
    while (unlikely(sqe == NULL))
    {
        io_uring_submit_and_wait(ring, 1);
        sqe = io_uring_get_sqe(ring);
    }
    return sqe;
};

static void* executor_scheduler_listen(void* input)
{
    struct executor_scheduler* scheduler = (struct executor_scheduler*)input;
    int32_t error;
    if (error = pthread_mutex_lock(&scheduler->thread.initialization_mutex))
    {
        scheduler->initialization_error = strerror(error);
        return NULL;
    }
    struct io_uring* ring = &scheduler->ring;
    int32_t result = io_uring_queue_init(scheduler->configuration.ring_size, ring, scheduler->configuration.ring_flags);
    if (result)
    {
        scheduler->initialization_error = strerror(result);
        return NULL;
    }
    scheduler->active = true;
    scheduler->descriptor = ring->ring_fd;
    if (error = pthread_cond_broadcast(&scheduler->thread.initialization_condition))
    {
        io_uring_queue_exit(ring);
        free(ring);
        scheduler->active = false;
        scheduler->initialization_error = strerror(error);
        return NULL;
    }
    if (error = pthread_mutex_unlock(&scheduler->thread.initialization_mutex))
    {
        io_uring_queue_exit(ring);
        free(ring);
        scheduler->active = false;
        scheduler->initialization_error = strerror(error);
        return NULL;
    }
    uintptr_t executors[executor_scheduler_LIMIT];
    struct io_uring_cqe* cqe;
    unsigned head;
    unsigned count = 0;
    while (true)
    {
        count = 0;
        io_uring_submit_and_wait(ring, 1);
        io_uring_for_each_cqe(ring, head, cqe)
        {
            ++count;

            if (unlikely(cqe->res < 0))
            {
                continue;
            }

            if (unlikely(!scheduler->active))
            {
                if (error = pthread_mutex_lock(&scheduler->thread.shutdown_mutex))
                {
                    scheduler->shutdown_error = strerror(error);
                    return NULL;
                }
                io_uring_queue_exit(ring);
                free(ring);
                scheduler->initialized = false;
                if (error = pthread_cond_broadcast(&scheduler->thread.shutdown_condition))
                {
                    scheduler->shutdown_error = strerror(error);
                    return NULL;
                }
                if (error = pthread_mutex_unlock(&scheduler->thread.shutdown_mutex))
                {
                    scheduler->shutdown_error = strerror(error);
                    return NULL;
                }
                return NULL;
            }

            if (cqe->res & POLLIN)
            {
                struct executor* executor = (struct executor*)cqe->user_data;
                if (likely(executors[executor->id]))
                {
                    bool result = Dart_PostInteger(executor->callback, executor->id);
                    if (!result)
                    {
                        native_error_exit(EXECUTOR_MODULE, EXECUTOR_ERROR_BACKGROUND_SCHEDULER_POST, EXECUTOR_SCOPE_BACKGROUND_SCHEDULER, executor_format_cqe(cqe));
                    }
                }
                continue;
            }

            if (cqe->res & executor_scheduler_POLL)
            {
                struct executor* executor = (struct executor*)cqe->user_data;
                if (likely(executors[executor->id]))
                {
                    struct io_uring_sqe* sqe = executor_scheduler_provide_sqe(ring);
                    io_uring_prep_poll_add(sqe, executor->descriptor, POLLIN);
                    io_uring_sqe_set_data(sqe, executor);
                }
                continue;
            }

            if (cqe->res & executor_scheduler_REGISTER)
            {
                struct executor* executor = (struct executor*)cqe->user_data;
                struct io_uring_sqe* sqe = executor_scheduler_provide_sqe(ring);
                io_uring_prep_poll_add(sqe, executor->descriptor, POLLIN);
                io_uring_sqe_set_data(sqe, executor);
                executors[executor->id] = (uintptr_t)executor;
                continue;
            }

            if (cqe->res & executor_scheduler_UNREGISTER)
            {
                struct executor* executor = (struct executor*)executors[cqe->user_data];
                if (likely(executor))
                {
                    struct io_uring_sqe* sqe = executor_scheduler_provide_sqe(ring);
                    io_uring_prep_poll_remove(sqe, (uintptr_t)executor);
                    sqe->flags |= IOSQE_CQE_SKIP_SUCCESS;
                    executors[cqe->user_data] = 0;
                }
                continue;
            }
        }
        io_uring_cq_advance(ring, count);
    }
    unreachable();
}

bool executor_scheduler_initialize(struct executor_scheduler* scheduler, struct executor_scheduler_configuration* configuration)
{
    scheduler->configuration = *configuration;
    struct timespec timeout = timeout_seconds(configuration->initialization_timeout_seconds);
    int32_t error;
    if (error = pthread_create(&scheduler->thread.main_thread_id, NULL, executor_scheduler_listen, scheduler))
    {
        scheduler->initialization_error = strerror(error);
        return false;
    }
    if (error = pthread_mutex_lock(&scheduler->thread.initialization_mutex))
    {
        scheduler->initialization_error = strerror(error);
        return false;
    }
    while (!scheduler->active)
    {
        if (error = pthread_cond_timedwait(&scheduler->thread.initialization_condition, &scheduler->thread.initialization_mutex, &timeout))
        {
            scheduler->initialization_error = strerror(error);
            return false;
        }
    }
    scheduler->initialized = true;
    if (error = pthread_mutex_unlock(&scheduler->thread.initialization_mutex))
    {
        scheduler->initialization_error = strerror(error);
        return false;
    }
    if (error = pthread_cond_destroy(&scheduler->thread.initialization_condition))
    {
        scheduler->initialization_error = strerror(error);
        return false;
    }
    if (error = pthread_mutex_destroy(&scheduler->thread.initialization_mutex))
    {
        scheduler->initialization_error = strerror(error);
        return false;
    }
    return true;
}

bool executor_scheduler_shutdown(struct executor_scheduler* scheduler)
{
    if (!scheduler->initialized)
    {
        return true;
    }
    if (scheduler->active)
    {
        struct io_uring* ring = &scheduler->ring;
        struct io_uring_sqe* sqe = executor_scheduler_provide_sqe(ring);
        scheduler->active = false;
        io_uring_prep_nop(sqe);
        io_uring_submit(ring);
    }
    int32_t error;
    if (error = pthread_mutex_lock(&scheduler->thread.shutdown_mutex))
    {
        scheduler->shutdown_error = strerror(error);
        return false;
    }
    struct timespec timeout = timeout_seconds(scheduler->configuration.shutdown_timeout_seconds);
    while (scheduler->initialized)
    {
        if (error = pthread_cond_timedwait(&scheduler->thread.shutdown_condition, &scheduler->thread.shutdown_mutex, &timeout))
        {
            scheduler->shutdown_error = strerror(error);
            return false;
        }
    }
    if (error = pthread_mutex_unlock(&scheduler->thread.shutdown_mutex))
    {
        scheduler->shutdown_error = strerror(error);
        return false;
    }
    if (error = pthread_cond_destroy(&scheduler->thread.shutdown_condition))
    {
        scheduler->shutdown_error = strerror(error);
        return false;
    }
    if (error = pthread_mutex_destroy(&scheduler->thread.shutdown_mutex))
    {
        scheduler->shutdown_error = strerror(error);
        return false;
    }
    return true;
}
