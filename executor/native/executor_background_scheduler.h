#ifndef EXECUTOR_DART_NOTIFIER_H
#define EXECUTOR_DART_NOTIFIER_H

#include <stdbool.h>
#include <stdint.h>
#include "executor_configuration.h"

#define EXECUTOR_BACKGROUND_SCHEDULER_REGISTER 1 << 10
#define EXECUTOR_BACKGROUND_SCHEDULER_UNREGISTER 1 << 11
#define EXECUTOR_BACKGROUND_SCHEDULER_POLL 1 << 12
#define EXECUTOR_BACKGROUND_SCHEDULER_LIMIT 1 << 16

#if defined(__cplusplus)
extern "C"
{
#endif
    struct io_uring;
    struct executor_dart_notifier_thread;

    struct executor_dart_notifier
    {
        struct executor_dart_notifier_configuration configuration;
        char* initialization_error;
        char* shutdown_error;
        struct executor_dart_notifier_thread* thread;
        struct io_uring* ring;
        bool active;
        bool initialized;
        int32_t descriptor;
    };

    bool executor_dart_notifier_initialize(struct executor_dart_notifier* notifier, struct executor_dart_notifier_configuration* configuration);
    bool executor_dart_notifier_shutdown(struct executor_dart_notifier* notifier);
#if defined(__cplusplus)
}
#endif

#endif