#include "mediator_dart_notifier.h"
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/poll.h>
#include "core_common.h"
#include "liburing.h"
#include "mediator_dart.h"

static inline struct io_uring_sqe* mediator_notifier_provide_sqe(struct io_uring* ring)
{
    struct io_uring_sqe* sqe = io_uring_get_sqe(ring);
    while (unlikely(sqe == NULL))
    {
        struct io_uring_cqe* unused;
        io_uring_wait_cqe_nr(ring, &unused, 1);
        sqe = io_uring_get_sqe(ring);
    }
    return sqe;
};

static void* mediator_notifier_listen(void* input)
{
    struct mediator_dart_notifier* notifier = (struct mediator_dart_notifier*)input;
    int32_t error;
    if (error = pthread_mutex_lock(&notifier->initialization_mutex))
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
    if (error = pthread_cond_broadcast(&notifier->initialization_condition))
    {
        io_uring_queue_exit(ring);
        free(ring);
        notifier->active = false;
        notifier->initialization_error = strerror(error);
        return NULL;
    }
    if (error = pthread_mutex_unlock(&notifier->initialization_mutex))
    {
        io_uring_queue_exit(ring);
        free(ring);
        notifier->active = false;
        notifier->initialization_error = strerror(error);
        return NULL;
    }
    while (true)
    {
        io_uring_submit_and_wait(ring, 1);
        struct io_uring_cqe* cqe;
        unsigned head;
        unsigned count = 0;
        io_uring_for_each_cqe(ring, head, cqe)
        {
            ++count;

            if (unlikely(!notifier->active))
            {
                if (error = pthread_mutex_lock(&notifier->shutdown_mutex))
                {
                    notifier->shutdown_error = strerror(error);
                    return NULL;
                }
                io_uring_queue_exit(ring);
                free(ring);
                notifier->initialized = false;
                if (error = pthread_cond_broadcast(&notifier->shutdown_condition))
                {
                    notifier->shutdown_error = strerror(error);
                    return NULL;
                }
                if (error = pthread_mutex_unlock(&notifier->shutdown_mutex))
                {
                    notifier->shutdown_error = strerror(error);
                    return NULL;
                }
                return NULL;
            }

            if (likely(cqe->res & MEDIATOR_NOTIFIER_REGISTER))
            {
                struct mediator_dart* mediator = (struct mediator_dart*)cqe->user_data;
                struct io_uring_sqe* sqe = mediator_notifier_provide_sqe(ring);
                io_uring_prep_poll_multishot(sqe, mediator->descriptor, POLLIN);
                io_uring_sqe_set_data(sqe, mediator);
                continue;
            }

            if (likely(cqe->res & MEDIATOR_NOTIFIER_UNREGISTER))
            {
                struct io_uring_sqe* sqe = mediator_notifier_provide_sqe(ring);
                io_uring_prep_poll_remove(sqe, cqe->user_data);
                sqe->flags |= IOSQE_CQE_SKIP_SUCCESS;
                continue;
            }

            if (likely(cqe->res & POLLIN))
            {
                struct mediator_dart* mediator = (struct mediator_dart*)cqe->user_data;
                mediator->callback();
                if (!(cqe->flags & IORING_CQE_F_MORE))
                {
                    struct io_uring_sqe* sqe = mediator_notifier_provide_sqe(ring);
                    io_uring_prep_poll_multishot(sqe, mediator->descriptor, POLLIN);
                    io_uring_sqe_set_data(sqe, mediator);
                }
            }
        }
        io_uring_cq_advance(ring, count);
    }
    unreachable();
}

bool mediator_dart_notifier_initialize(struct mediator_dart_notifier* notifier, struct mediator_dart_notifier_configuration* configuration)
{
    notifier->configuration = *configuration;
    struct timespec timeout;
    timespec_get(&timeout, TIME_UTC);
    timeout.tv_sec += configuration->initialization_timeout_seconds;
    int32_t error;
    if (error = pthread_create(&notifier->main_thread_id, NULL, mediator_notifier_listen, notifier))
    {
        notifier->initialization_error = strerror(error);
        return false;
    }
    if (error = pthread_mutex_lock(&notifier->initialization_mutex))
    {
        notifier->initialization_error = strerror(error);
        return false;
    }
    while (!notifier->active)
    {
        if (error = pthread_cond_timedwait(&notifier->initialization_condition, &notifier->initialization_mutex, &timeout))
        {
            notifier->initialization_error = strerror(error);
            return false;
        }
    }
    notifier->initialized = true;
    if (error = pthread_mutex_unlock(&notifier->initialization_mutex))
    {
        notifier->initialization_error = strerror(error);
        return false;
    }
    if (error = pthread_cond_destroy(&notifier->initialization_condition))
    {
        notifier->initialization_error = strerror(error);
        return false;
    }
    if (error = pthread_mutex_destroy(&notifier->initialization_mutex))
    {
        notifier->initialization_error = strerror(error);
        return false;
    }
    return true;
}

bool mediator_dart_notifier_shutdown(struct mediator_dart_notifier* notifier)
{
    if (!notifier->initialized)
    {
        return true;
    }
    if (notifier->active)
    {
        struct io_uring* ring = notifier->ring;
        struct io_uring_sqe* sqe = mediator_notifier_provide_sqe(ring);
        notifier->active = false;
        io_uring_prep_nop(sqe);
        io_uring_submit(ring);
    }
    int32_t error;
    if (error = pthread_mutex_lock(&notifier->shutdown_mutex))
    {
        notifier->shutdown_error = strerror(error);
        return false;
    }
    struct timespec timeout;
    timespec_get(&timeout, TIME_UTC);
    timeout.tv_sec += notifier->configuration.shutdown_timeout_seconds;
    while (notifier->initialized)
    {
        if (error = pthread_cond_timedwait(&notifier->shutdown_condition, &notifier->shutdown_mutex, &timeout))
        {
            notifier->shutdown_error = strerror(error);
            return false;
        }
    }
    if (error = pthread_mutex_unlock(&notifier->shutdown_mutex))
    {
        notifier->shutdown_error = strerror(error);
        return false;
    }
    if (error = pthread_cond_destroy(&notifier->shutdown_condition))
    {
        notifier->shutdown_error = strerror(error);
        return false;
    }
    if (error = pthread_mutex_destroy(&notifier->shutdown_mutex))
    {
        notifier->shutdown_error = strerror(error);
        return false;
    }
    return true;
}