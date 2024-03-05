#ifndef TEST_THREADING_H
#define TEST_THREADING_H

#include <stdbool.h>
#include "mediator_message.h"
#include "test.h"

typedef unsigned long int pthread_t;
typedef union pthread_cond_t test_cond_t;
typedef union pthread_mutex_t test_mutex_t;

#if defined(__cplusplus)
extern "C"
{
#endif

    struct test_thread
    {
        pthread_t id;

        volatile bool alive;

        size_t whole_messages_count;
        size_t received_messages_count;

        test_mediator_native* test_mediator;
        struct mediator_message** messages;

        test_cond_t* initialize_condition;
        test_mutex_t* initialize_mutex;
        
        struct memory_module* thread_memory;
        struct memory_pool* thread_memory_pool;
        struct memory_small_data* thread_small_data;
    };

    struct test_threads
    {
        struct test_thread* threads;
        size_t count;
        test_mutex_t* global_working_mutex;
    };

    bool test_threading_initialize(int32_t thread_count, int32_t isolates_count, int32_t per_thread_messages_count);
    int* test_threading_mediator_descriptors();

    void test_threading_call_native(struct mediator_message* message);
    int32_t test_threading_call_native_check();

    void test_threading_prepare_call_dart_bytes(int32_t* targets, int32_t count);

    int32_t test_threading_call_dart_check();
    void test_threading_call_dart_callback(struct mediator_message* message);

    void test_threading_destroy();

    intptr_t test_threading_call_native_address_lookup();

#if defined(__cplusplus)
}
#endif

#endif
