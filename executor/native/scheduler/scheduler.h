#ifndef EXECUTOR_SCHEDULER_SCHEDULER_H
#define EXECUTOR_SCHEDULER_SCHEDULER_H

#include <executor/configuration.h>
#include <liburing.h>
#include <system/library.h>

#define EXECUTOR_SCHEDULER_REGISTER 1 << 10
#define EXECUTOR_SCHEDULER_UNREGISTER 1 << 11
#define EXECUTOR_SCHEDULER_POLL 1 << 12

#define EXECUTOR_SCHEDULER_LIMIT 1 << 16

#if defined(__cplusplus)
extern "C"
{
#endif

struct executor_scheduler_thread
{
    pthread_t main_thread_id;
    pthread_mutex_t initialization_mutex;
    pthread_cond_t initialization_condition;
    pthread_mutex_t shutdown_mutex;
    pthread_cond_t shutdown_condition;
};

DART_STRUCTURE struct executor_scheduler
{
    DART_FIELD char* initialization_error;
    DART_FIELD char* shutdown_error;
    DART_FIELD int32_t descriptor;
    DART_FIELD bool active;
    DART_FIELD bool initialized;
    struct io_uring ring;
    struct executor_scheduler_configuration configuration;
    struct executor_scheduler_thread thread;
};

DART_LEAF_FUNCTION struct executor_scheduler* executor_scheduler_initialize(struct executor_scheduler_configuration* configuration);
DART_LEAF_FUNCTION bool executor_scheduler_shutdown(struct executor_scheduler* scheduler);

#if defined(__cplusplus)
}
#endif

#endif