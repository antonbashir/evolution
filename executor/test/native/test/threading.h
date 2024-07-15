#ifndef TEST_THREADING_H
#define TEST_THREADING_H

#include <executor/task.h>
#include <memory/memory.h>
#include <system/library.h>
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

    struct test_executor* test_executor_instance;
    struct executor_task** messages;

    test_cond_t* initialize_condition;
    test_mutex_t* initialize_mutex;

    struct memory_instance* thread_memory;
    struct memory_pool* thread_memory_pool;
    struct memory_small_allocator* thread_small_data;
};

struct test_threads
{
    struct test_thread* threads;
    size_t count;
    test_mutex_t* global_working_mutex;
};

DART_LEAF_FUNCTION bool test_threading_initialize(int32_t thread_count, int32_t isolates_count, int32_t per_thread_messages_count);
DART_LEAF_FUNCTION int* test_threading_executor_descriptors();

DART_LEAF_FUNCTION void test_threading_call_native(struct executor_task* message);
DART_LEAF_FUNCTION int32_t test_threading_call_native_check();

DART_LEAF_FUNCTION void test_threading_prepare_call_dart_bytes(int32_t* targets, int32_t count);

DART_LEAF_FUNCTION int32_t test_threading_call_dart_check();
DART_LEAF_FUNCTION void test_threading_call_dart_callback(struct executor_task* message);

DART_LEAF_FUNCTION void test_threading_destroy();

DART_LEAF_FUNCTION intptr_t test_threading_call_native_address_lookup();

#if defined(__cplusplus)
}
#endif

#endif
