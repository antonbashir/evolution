#include <executor_background_scheduler.h>
#include <executor_common.h>
#include <executor_constants.h>
#include <executor_dart.h>
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/poll.h>
#include "common/common.h"
#include "common/errors.h"
#include "dart/dart_native_api.h"
#include "liburing.h"
#include "system/time.h"

struct executor_dart_notifier_thread
{
    pthread_t main_thread_id;
    pthread_mutex_t initialization_mutex;
    pthread_cond_t initialization_condition;
    pthread_mutex_t shutdown_mutex;
    pthread_cond_t shutdown_condition;
};

static inline struct io_uring_sqe*
executor_background_scheduler_provide_sqe(struct io_uring* ring)
{
    struct io_uring_sqe* sqe = io_uring_get_sqe(ring);
    while (unlikely(sqe == NULL))
    {
        io_uring_submit_and_wait(ring, 1);
        sqe = io_uring_get_sqe(ring);
    }
    return sqe;
};

static void* executor_background_scheduler_listen(void* input)
{
    struct executor_dart_notifier* notifier = (struct executor_dart_notifier*)input;
    int32_t error;
    if (error = pthread_mutex_lock(&notifier->thread->initialization_mutex))
    {
        notifier->initialization_error = strerror(error);
        return NULL;
    }
    notifier->ring = calloc(1, sizeof(struct io_uring));
    if (notifier->ring == NULL)
    {
        notifier->initialization_error = strerror(ENOMEM);
        return NULL;
    }
    struct io_uring* ring = notifier->ring;
    int32_t result = io_uring_queue_init(notifier->configuration.ring_size, ring, notifier->configuration.ring_flags);
    if (result)
    {
        notifier->initialization_error = strerror(result);
        return NULL;
    }
    notifier->active = true;
    notifier->descriptor = ring->ring_fd;
    if (error = pthread_cond_broadcast(&notifier->thread->initialization_condition))
    {
        io_uring_queue_exit(ring);
        free(ring);
        notifier->active = false;
        notifier->initialization_error = strerror(error);
        return NULL;
    }
    if (error = pthread_mutex_unlock(&notifier->thread->initialization_mutex))
    {
        io_uring_queue_exit(ring);
        free(ring);
        notifier->active = false;
        notifier->initialization_error = strerror(error);
        return NULL;
    }
    uintptr_t executors[EXECUTOR_BACKGROUND_SCHEDULER_LIMIT];
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

            if (unlikely(!notifier->active))
            {
                if (error = pthread_mutex_lock(&notifier->thread->shutdown_mutex))
                {
                    notifier->shutdown_error = strerror(error);
                    return NULL;
                }
                io_uring_queue_exit(ring);
                free(ring);
                notifier->initialized = false;
                if (error = pthread_cond_broadcast(&notifier->thread->shutdown_condition))
                {
                    notifier->shutdown_error = strerror(error);
                    return NULL;
                }
                if (error = pthread_mutex_unlock(&notifier->thread->shutdown_mutex))
                {
                    notifier->shutdown_error = strerror(error);
                    return NULL;
                }
                return NULL;
            }

            if (cqe->res & POLLIN)
            {
                struct executor_dart* executor = (struct executor_dart*)cqe->user_data;
                if (likely(executors[executor->id]))
                {
                    bool result = Dart_PostInteger(executor->callback, executor->id);
                    if (!result)
                    {
                        native_error_exit(EXECUTOR_MODULE, EXECUTOR_ERROR_NOTIFIER_POST, EXECUTOR_SCOPE_NOTIFIER, executor_cqe_to_string(cqe));
                    }
                }
                continue;
            }

            if (cqe->res & EXECUTOR_BACKGROUND_SCHEDULER_POLL)
            {
                struct executor_dart* executor = (struct executor_dart*)cqe->user_data;
                if (likely(executors[executor->id]))
                {
                    struct io_uring_sqe* sqe = executor_background_scheduler_provide_sqe(ring);
                    io_uring_prep_poll_add(sqe, executor->descriptor, POLLIN);
                    io_uring_sqe_set_data(sqe, executor);
                }
                continue;
            }

            if (cqe->res & EXECUTOR_BACKGROUND_SCHEDULER_REGISTER)
            {
                struct executor_dart* executor = (struct executor_dart*)cqe->user_data;
                struct io_uring_sqe* sqe = executor_background_scheduler_provide_sqe(ring);
                io_uring_prep_poll_add(sqe, executor->descriptor, POLLIN);
                io_uring_sqe_set_data(sqe, executor);
                executors[executor->id] = (uintptr_t)executor;
                continue;
            }

            if (cqe->res & EXECUTOR_BACKGROUND_SCHEDULER_UNREGISTER)
            {
                struct executor_dart* executor = (struct executor_dart*)executors[cqe->user_data];
                if (likely(executor))
                {
                    struct io_uring_sqe* sqe = executor_background_scheduler_provide_sqe(ring);
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

bool executor_dart_notifier_initialize(struct executor_dart_notifier* notifier, struct executor_dart_notifier_configuration* configuration)
{
    notifier->thread = malloc(sizeof(struct executor_dart_notifier_thread));
    memset(notifier->thread, 0, sizeof(struct executor_dart_notifier_thread));
    notifier->configuration = *configuration;
    struct timespec timeout = timeout_seconds(configuration->initialization_timeout_seconds);
    int32_t error;
    if (error = pthread_create(&notifier->thread->main_thread_id, NULL, executor_background_scheduler_listen, notifier))
    {
        notifier->initialization_error = strerror(error);
        return false;
    }
    if (error = pthread_mutex_lock(&notifier->thread->initialization_mutex))
    {
        notifier->initialization_error = strerror(error);
        return false;
    }
    while (!notifier->active)
    {
        if (error = pthread_cond_timedwait(&notifier->thread->initialization_condition, &notifier->thread->initialization_mutex, &timeout))
        {
            notifier->initialization_error = strerror(error);
            return false;
        }
    }
    notifier->initialized = true;
    if (error = pthread_mutex_unlock(&notifier->thread->initialization_mutex))
    {
        notifier->initialization_error = strerror(error);
        return false;
    }
    if (error = pthread_cond_destroy(&notifier->thread->initialization_condition))
    {
        notifier->initialization_error = strerror(error);
        return false;
    }
    if (error = pthread_mutex_destroy(&notifier->thread->initialization_mutex))
    {
        notifier->initialization_error = strerror(error);
        return false;
    }
    return true;
}

bool executor_dart_notifier_shutdown(struct executor_dart_notifier* notifier)
{
    if (!notifier->initialized)
    {
        return true;
    }
    if (notifier->active)
    {
        struct io_uring* ring = notifier->ring;
        struct io_uring_sqe* sqe = executor_background_scheduler_provide_sqe(ring);
        notifier->active = false;
        io_uring_prep_nop(sqe);
        io_uring_submit(ring);
    }
    int32_t error;
    if (error = pthread_mutex_lock(&notifier->thread->shutdown_mutex))
    {
        notifier->shutdown_error = strerror(error);
        return false;
    }
    struct timespec timeout = timeout_seconds(notifier->configuration.shutdown_timeout_seconds);
    while (notifier->initialized)
    {
        if (error = pthread_cond_timedwait(&notifier->thread->shutdown_condition, &notifier->thread->shutdown_mutex, &timeout))
        {
            notifier->shutdown_error = strerror(error);
            return false;
        }
    }
    if (error = pthread_mutex_unlock(&notifier->thread->shutdown_mutex))
    {
        notifier->shutdown_error = strerror(error);
        return false;
    }
    if (error = pthread_cond_destroy(&notifier->thread->shutdown_condition))
    {
        notifier->shutdown_error = strerror(error);
        return false;
    }
    if (error = pthread_mutex_destroy(&notifier->thread->shutdown_mutex))
    {
        notifier->shutdown_error = strerror(error);
        return false;
    }
    return true;
}
