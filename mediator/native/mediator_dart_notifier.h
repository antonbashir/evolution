#ifndef MEDIATOR_DART_NOTIFIER_H
#define MEDIATOR_DART_NOTIFIER_H

#include <pthread.h>
#include <stdbool.h>
#include <stdint.h>
#include "mediator_configuration.h"

#define MEDIATOR_NOTIFIER_REGISTER 1 << 10
#define MEDIATOR_NOTIFIER_UNREGISTER 1 << 11
#define MEDIATOR_NOTIFIER_POLL 1 << 12
#define MEDIATOR_NOTIFIER_LIMIT 1 << 16

#if defined(__cplusplus)
extern "C"
{
#endif
    struct io_uring;

    struct mediator_dart_notifier
    {
        struct mediator_dart_notifier_configuration configuration;
        char* initialization_error;
        char* shutdown_error;
        pthread_t main_thread_id;
        pthread_mutex_t initialization_mutex;
        pthread_cond_t initialization_condition;
        pthread_mutex_t shutdown_mutex;
        pthread_cond_t shutdown_condition;
        struct io_uring* ring;
        bool active;
        bool initialized;
        int32_t descriptor;
    };

    bool mediator_dart_notifier_initialize(struct mediator_dart_notifier* notifier, struct mediator_dart_notifier_configuration* configuration);
    bool mediator_dart_notifier_shutdown(struct mediator_dart_notifier* notifier);
#if defined(__cplusplus)
}
#endif

#endif