#ifndef EXECUTOR_SCHEDULER_EXECUTOR_SCHEDULER_H
#define EXECUTOR_SCHEDULER_EXECUTOR_SCHEDULER_H

#include <liburing.h>
#include <stdbool.h>
#include <stdint.h>
#include <system/threading.h>
#include "executor_configuration.h"

#define executor_scheduler_REGISTER 1 << 10
#define executor_scheduler_UNREGISTER 1 << 11
#define executor_scheduler_POLL 1 << 12

#define executor_scheduler_LIMIT 1 << 16

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

struct executor_scheduler
{
    struct io_uring ring;
    struct executor_scheduler_configuration configuration;
    struct executor_scheduler_thread thread;
    char* initialization_error;
    char* shutdown_error;
    int32_t descriptor;
    bool active;
    bool initialized;
};

bool executor_scheduler_initialize(struct executor_scheduler* scheduler, struct executor_scheduler_configuration* configuration);
bool executor_scheduler_shutdown(struct executor_scheduler* scheduler);

#if defined(__cplusplus)
}
#endif

#endif