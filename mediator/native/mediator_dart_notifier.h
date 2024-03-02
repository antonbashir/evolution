#ifndef MEDIATOR_DART_NOTIFIER_H
#define MEDIATOR_DART_NOTIFIER_H

#include <pthread.h>
#include <stdbool.h>
#include <stdint.h>

#define MEDIATOR_NOTIFIER_REGISTER 1 << 10
#define MEDIATOR_NOTIFIER_UNREGISTER 1 << 11
#define MEDIATOR_NOTIFIER_SHUTDOWN 1 << 12

#if defined(__cplusplus)
extern "C"
{
#endif
    struct io_uring;

    struct mediator_dart_notifier_configuration
    {
        size_t ring_size;
        size_t ring_flags;
        uint64_t initialization_timeout_seconds;
        uint64_t shutdown_timeout_seconds;
    };

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