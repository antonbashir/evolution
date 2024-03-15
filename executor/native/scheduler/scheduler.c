#include "scheduler.h"
#include <common/common.h>
#include <dart/dart_native_api.h>
#include <executor/executor.h>
#include <executor/module.h>
#include <liburing.h>
#include <system/library.h>
#include <time/time.h>
#include "executor/common.h"

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
    executor_module_check_code(pthread_mutex_lock(&scheduler->thread.initialization_mutex));
    struct io_uring* ring = &scheduler->ring;
    int32_t result = io_uring_queue_init(scheduler->configuration.ring_size, ring, scheduler->configuration.ring_flags);
    if (result)
    {
        scheduler->initialization_error = strerror(result);
        executor_module_check_code(pthread_cond_broadcast(&scheduler->thread.initialization_condition));
        executor_module_check_code(pthread_mutex_unlock(&scheduler->thread.initialization_mutex));
        return NULL;
    }
    scheduler->active = true;
    scheduler->descriptor = ring->ring_fd;
    executor_module_check_code(pthread_cond_broadcast(&scheduler->thread.initialization_condition));
    executor_module_check_code(pthread_mutex_unlock(&scheduler->thread.initialization_mutex));
    uintptr_t executors[EXECUTOR_SCHEDULER_LIMIT];
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
                executor_module_check_code(pthread_mutex_lock(&scheduler->thread.shutdown_mutex));
                io_uring_queue_exit(ring);
                scheduler->initialized = false;
                executor_module_check_code(pthread_cond_broadcast(&scheduler->thread.shutdown_condition));
                executor_module_check_code(pthread_mutex_unlock(&scheduler->thread.shutdown_mutex));
                return NULL;
            }

            if (cqe->res & POLLIN)
            {
                struct executor_instance* executor = (struct executor_instance*)cqe->user_data;
                if (likely(executors[executor->id]))
                {
                    bool result = Dart_PostInteger(executor->callback, executor->id);
                    if (!result)
                    {
                        print_event(executor_module_event(event_error(event_scope(EXECUTOR_SCOPE_SCHEDULER), executor_format_cqe(cqe))));
                    }
                }
                continue;
            }

            if (cqe->res & EXECUTOR_SCHEDULER_POLL)
            {
                struct executor_instance* executor = (struct executor_instance*)cqe->user_data;
                if (likely(executors[executor->id]))
                {
                    struct io_uring_sqe* sqe = executor_scheduler_provide_sqe(ring);
                    io_uring_prep_poll_add(sqe, executor->descriptor, POLLIN);
                    io_uring_sqe_set_data(sqe, executor);
                }
                continue;
            }

            if (cqe->res & EXECUTOR_SCHEDULER_REGISTER)
            {
                struct executor_instance* executor = (struct executor_instance*)cqe->user_data;
                struct io_uring_sqe* sqe = executor_scheduler_provide_sqe(ring);
                io_uring_prep_poll_add(sqe, executor->descriptor, POLLIN);
                io_uring_sqe_set_data(sqe, executor);
                executors[executor->id] = (uintptr_t)executor;
                continue;
            }

            if (cqe->res & EXECUTOR_SCHEDULER_UNREGISTER)
            {
                struct executor_instance* executor = (struct executor_instance*)executors[cqe->user_data];
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

struct executor_scheduler* executor_scheduler_initialize(struct executor_scheduler_configuration* configuration)
{
    struct executor_scheduler* scheduler = executor_module_new_checked(sizeof(struct executor_scheduler));
    scheduler->configuration = *configuration;
    struct timespec timeout = timeout_seconds(configuration->initialization_timeout_seconds);
    int32_t error;
    if (error = pthread_create(&scheduler->thread.main_thread_id, NULL, executor_scheduler_listen, scheduler))
    {
        scheduler->initialization_error = strerror(error);
        return false;
    }
    executor_module_check_code(pthread_mutex_lock(&scheduler->thread.initialization_mutex));
    if (error = pthread_cond_timedwait(&scheduler->thread.initialization_condition, &scheduler->thread.initialization_mutex, &timeout))
    {
        scheduler->initialization_error = strerror(error);
        executor_module_check_code(pthread_mutex_unlock(&scheduler->thread.initialization_mutex));
        executor_module_check_code(pthread_cond_destroy(&scheduler->thread.initialization_condition));
        executor_module_check_code(pthread_mutex_destroy(&scheduler->thread.initialization_mutex));
        return false;
    }
    if (!scheduler->active)
    {
        executor_module_check_code(pthread_mutex_unlock(&scheduler->thread.initialization_mutex));
        executor_module_check_code(pthread_cond_destroy(&scheduler->thread.initialization_condition));
        executor_module_check_code(pthread_mutex_destroy(&scheduler->thread.initialization_mutex));
        return false;
    }
    scheduler->initialized = true;
    executor_module_check_code(pthread_mutex_unlock(&scheduler->thread.initialization_mutex));
    executor_module_check_code(pthread_cond_destroy(&scheduler->thread.initialization_condition));
    executor_module_check_code(pthread_mutex_destroy(&scheduler->thread.initialization_mutex));
    return scheduler;
}

bool executor_scheduler_shutdown(struct executor_scheduler* scheduler)
{
    if (!scheduler->initialized || !scheduler->active)
    {
        return true;
    }
    struct io_uring* ring = &scheduler->ring;
    struct io_uring_sqe* sqe = executor_scheduler_provide_sqe(ring);
    scheduler->active = false;
    io_uring_prep_nop(sqe);
    io_uring_submit(ring);
    int32_t error;
    executor_module_check_code(pthread_mutex_lock(&scheduler->thread.shutdown_mutex));
    struct timespec timeout = timeout_seconds(scheduler->configuration.shutdown_timeout_seconds);
    if (error = pthread_cond_timedwait(&scheduler->thread.shutdown_condition, &scheduler->thread.shutdown_mutex, &timeout))
    {
        scheduler->shutdown_error = strerror(error);
        executor_module_check_code(pthread_mutex_unlock(&scheduler->thread.shutdown_mutex));
        executor_module_check_code(pthread_cond_destroy(&scheduler->thread.shutdown_condition));
        executor_module_check_code(pthread_mutex_destroy(&scheduler->thread.shutdown_mutex));
        return false;
    }
    if (scheduler->initialized)
    {
        executor_module_check_code(pthread_mutex_unlock(&scheduler->thread.shutdown_mutex));
        executor_module_check_code(pthread_cond_destroy(&scheduler->thread.shutdown_condition));
        executor_module_check_code(pthread_mutex_destroy(&scheduler->thread.shutdown_mutex));
        return false;
    }
    executor_module_check_code(pthread_mutex_unlock(&scheduler->thread.shutdown_mutex));
    executor_module_check_code(pthread_cond_destroy(&scheduler->thread.shutdown_condition));
    executor_module_check_code(pthread_mutex_destroy(&scheduler->thread.shutdown_mutex));
    return true;
}
