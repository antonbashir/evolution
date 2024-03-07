#include "test_threading.h"
#include <bits/pthreadtypes.h>
#include <executor_task.h>
#include <memory.h>
#include <memory_small_data.h>
#include <pthread.h>
#include <sched.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include "test.h"

struct test_threads threads;

int* test_threading_executor_descriptors()
{
    int* descriptors = malloc(sizeof(int) * threads.count);
    pthread_mutex_lock((pthread_mutex_t*)threads.global_working_mutex);
    for (int32_t id = 0; id < threads.count; id++)
    {
        descriptors[id] = ((struct executor_native*)threads.threads[id].test_executor)->descriptor;
    }
    pthread_mutex_unlock((pthread_mutex_t*)threads.global_working_mutex);
    return descriptors;
}

static inline struct test_thread* test_threading_thread_by_fd(int32_t fd)
{
    struct test_thread* thread = NULL;
    for (int32_t id = 0; id < threads.count; id++)
    {
        thread = &threads.threads[id];
        if (((struct executor_native*)thread->test_executor)->descriptor == fd)
        {
            return thread;
        }
    }
    return thread;
}

static void* test_threading_run(void* thread)
{
    struct test_thread* casted = (struct test_thread*)thread;
    pthread_mutex_lock((pthread_mutex_t*)casted->initialize_mutex);
    casted->alive = false;
    do
    {
        casted->test_executor = test_executor_initialize(false);
    }
    while (!casted->test_executor || ((struct executor_native*)casted->test_executor)->descriptor <= 0);
    executor_native_register_callback((struct executor_native*)casted->test_executor, 0, 0, test_threading_call_dart_callback);
    casted->alive = true;
    pthread_cond_broadcast((pthread_cond_t*)casted->initialize_condition);
    pthread_mutex_unlock((pthread_mutex_t*)casted->initialize_mutex);
    while (casted->alive)
    {
        executor_native_process_timeout((struct executor_native*)casted->test_executor);
    }
    test_executor_destroy((struct executor_native*)casted->test_executor, false);
    memory_small_data_destroy(casted->thread_small_data);
    memory_pool_destroy(casted->thread_memory_pool);
    memory_destroy(casted->thread_memory);
    free(casted->thread_small_data);
    free(casted->thread_memory_pool);
    free(casted->thread_memory);
    free(casted->messages);
    return NULL;
}

bool test_threading_initialize(int32_t thread_count, int32_t isolates_count, int32_t per_thread_messages_count)
{
    threads.count = thread_count;
    threads.threads = malloc(thread_count * sizeof(struct test_thread));
    threads.global_working_mutex = malloc(sizeof(pthread_mutex_t));
    pthread_mutex_init((pthread_mutex_t*)threads.global_working_mutex, NULL);
    for (int32_t thread_id = 0; thread_id < thread_count; thread_id++)
    {
        struct test_thread* thread = &threads.threads[thread_id];
        memset(thread, 0, sizeof(struct test_thread));
        thread->whole_messages_count = per_thread_messages_count;
        thread->received_messages_count = 0;
        thread->messages = malloc(per_thread_messages_count * sizeof(struct executor_task*));
        thread->initialize_mutex = malloc(sizeof(pthread_mutex_t));
        thread->thread_memory = calloc(1, sizeof(struct memory_state));
        thread->thread_memory_pool = calloc(1, sizeof(struct memory_pool));
        thread->thread_small_data = calloc(1, sizeof(struct memory_small_data));
        memory_create(thread->thread_memory, 1 * 1024 * 1024, 64 * 1024, 64 * 1024);
        memory_pool_create(thread->thread_memory_pool, thread->thread_memory, sizeof(struct executor_task));
        memory_small_data_create(thread->thread_small_data, thread->thread_memory);
        pthread_mutex_init((pthread_mutex_t*)thread->initialize_mutex, NULL);
        thread->initialize_condition = malloc(sizeof(pthread_cond_t));
        pthread_cond_init((pthread_cond_t*)thread->initialize_condition, NULL);

        pthread_create(&thread->id, NULL, test_threading_run, thread);
        pthread_setname_np(thread->id, "test_threading");

        pthread_mutex_lock((pthread_mutex_t*)thread->initialize_mutex);
        while (!thread->alive)
        {
            struct timespec timeout = {.tv_sec = 1};
            pthread_cond_timedwait((pthread_cond_t*)thread->initialize_condition, (pthread_mutex_t*)thread->initialize_mutex, &timeout);
        }
        pthread_mutex_unlock((pthread_mutex_t*)thread->initialize_mutex);
    }
    return true;
}

int32_t test_threading_call_native_check()
{
    int32_t messages = 0;
    pthread_mutex_lock((pthread_mutex_t*)threads.global_working_mutex);
    for (int32_t id = 0; id < threads.count; id++)
    {
        messages += threads.threads[id].received_messages_count;
    }
    pthread_mutex_unlock((pthread_mutex_t*)threads.global_working_mutex);
    return messages;
}

int32_t test_threading_call_dart_check()
{
    int32_t messages = 0;
    pthread_mutex_lock((pthread_mutex_t*)threads.global_working_mutex);
    for (int32_t id = 0; id < threads.count; id++)
    {
        messages += threads.threads[id].received_messages_count;
    }
    pthread_mutex_unlock((pthread_mutex_t*)threads.global_working_mutex);
    return messages;
}

void test_threading_call_native(struct executor_task* message)
{
    pthread_mutex_lock((pthread_mutex_t*)threads.global_working_mutex);
    struct test_thread* thread = test_threading_thread_by_fd(message->target);
    if (thread)
    {
        message->output = message->input;
        message->output_size = message->input_size;
        thread->messages[thread->received_messages_count] = message;
        thread->received_messages_count++;
    }
    pthread_mutex_unlock((pthread_mutex_t*)threads.global_working_mutex);
}

void test_threading_prepare_call_dart_bytes(int32_t* targets, int32_t target_count)
{
    pthread_mutex_lock((pthread_mutex_t*)threads.global_working_mutex);
    for (int32_t id = 0; id < threads.count; id++)
    {
        struct test_thread* thread = &threads.threads[id];
        for (int32_t target = 0; target < target_count; target++)
        {
            for (int32_t message_id = 0; message_id < thread->whole_messages_count / target_count; message_id++)
            {
                struct executor_task* message = memory_pool_allocate(thread->thread_memory_pool);
                message->id = message_id;
                message->input = (void*)(uintptr_t)memory_small_data_allocate(thread->thread_small_data, 3);
                ((char*)message->input)[0] = 0x1;
                ((char*)message->input)[1] = 0x2;
                ((char*)message->input)[2] = 0x3;
                message->input_size = 3;
                message->owner = 0;
                message->method = 0;
                executor_native_call_dart((struct executor_native*)thread->test_executor, targets[target], message);
            }
        }
        executor_native_submit((struct executor_native*)thread->test_executor);
    }
    pthread_mutex_unlock((pthread_mutex_t*)threads.global_working_mutex);
}

void test_threading_call_dart_callback(struct executor_task* message)
{
    pthread_mutex_lock((pthread_mutex_t*)threads.global_working_mutex);
    struct test_thread* thread = test_threading_thread_by_fd(message->target);
    if (thread)
    {
        message->output = message->input;
        message->output_size = message->input_size;
        thread->messages[thread->received_messages_count] = message;
        thread->received_messages_count++;
    }
    pthread_mutex_unlock((pthread_mutex_t*)threads.global_working_mutex);
}

void test_threading_destroy()
{
    pthread_mutex_lock((pthread_mutex_t*)threads.global_working_mutex);
    for (int32_t thread_id = 0; thread_id < threads.count; thread_id++)
    {
        struct test_thread* thread = &threads.threads[thread_id];
        thread->alive = false;
        pthread_join(thread->id, NULL);
    }
    free(threads.threads);
    pthread_mutex_unlock((pthread_mutex_t*)threads.global_working_mutex);
}

intptr_t test_threading_call_native_address_lookup()
{
    return (uintptr_t)&test_threading_call_native;
}