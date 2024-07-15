#include "test.h"
#include <executor/module.h>
#include <executor/task.h>
#include <liburing.h>
#include <memory/memory.h>
#include <stdlib.h>
#include "executor/constants.h"

struct memory_small_allocator* small;
struct memory_pool* pool;
struct memory_instance* memory_instance;

struct test_executor* test_executor_initialize(bool initialize_memory)
{
    struct test_executor* executor = malloc(sizeof(struct test_executor));
    if (!executor)
    {
        return NULL;
    }
    executor->ring = malloc(sizeof(struct io_uring));
    int32_t result = io_uring_queue_init(1024, executor->ring, 0);
    if (result < 0)
    {
        return NULL;
    }
    if (initialize_memory)
    {
        memory_instance = memory_create(1 * 1024 * 1024, 64 * 1024, 64 * 1024);
        pool = memory_pool_create(memory_instance, sizeof(struct executor_task));
        small = memory_small_allocator_create(memory_instance, 1.05);
    }
    executor->descriptor = executor->ring->ring_fd;
    executor->callbacks = table_native_callbacks_new();
    return executor;
}

void test_executor_destroy(struct test_executor* executor, bool initialize_memory)
{
    executor_module_trace();
    if (initialize_memory)
    {
        memory_small_allocator_destroy(small);
        memory_pool_destroy(pool);
        memory_destroy(memory_instance);
    }
    io_uring_queue_exit(executor->ring);
    free(executor->ring);
    free(executor);
}

struct executor_task* test_allocate_message()
{
    return memory_pool_allocate(pool);
}

double* test_allocate_double()
{
    return memory_small_allocator_allocate(small, sizeof(double));
}

void test_executor_process(struct test_executor* executor)
{
    struct io_uring_cqe* cqe;
    unsigned head;
    unsigned count = 0;
    io_uring_for_each_cqe(executor->ring, head, cqe)
    {
        count++;
        if (cqe->res == EXECUTOR_CALL)
        {
            struct executor_task* task = (struct executor_task*)cqe->user_data;
            void (*pointer)(struct executor_task*) = (void (*)(struct executor_task*))task->method;
            pointer(task);
            struct io_uring_sqe* sqe = io_uring_get_sqe(executor->ring);
            uint64_t target = task->source;
            task->source = executor->descriptor;
            task->target = target;
            io_uring_prep_msg_ring(sqe, target, EXECUTOR_CALLBACK, (uint64_t)((intptr_t)task), 0);
            sqe->flags |= IOSQE_CQE_SKIP_SUCCESS;
            continue;
        }

        if (cqe->res == EXECUTOR_CALLBACK)
        {
            struct executor_task* message = (struct executor_task*)cqe->user_data;
            struct table_native_callbacks_key_t key = {
                .owner = message->owner,
                .method = message->method,
            };
            table_int_t callback;
            if ((callback = table_native_callbacks_find(executor->callbacks, key, 0)) != table_end(executor->callbacks))
            {
                struct table_native_callbacks_node_t* node = table_native_callbacks_node(executor->callbacks, callback);
                node->callback(message);
            }
            continue;
        }
    }
    io_uring_cq_advance(executor->ring, count);
}

void test_executor_call_dart(struct test_executor* executor, int32_t target, struct executor_task* task)
{
    task->source = executor->descriptor;
    task->target = target;
    struct io_uring_sqe* sqe = io_uring_get_sqe(executor->ring);
    io_uring_prep_msg_ring(sqe, target, EXECUTOR_CALL, (uint64_t)((intptr_t)task), 0);
    sqe->flags |= IOSQE_CQE_SKIP_SUCCESS;
}

void test_executor_register_callback(struct test_executor* executor, test_executor_call callback)
{
    struct table_native_callbacks_node_t node = {
        .callback = callback,
        .key = {
            .method = 0,
            .owner = 0,
        },
    };
    table_native_callbacks_put_copy(executor->callbacks, &node, NULL, 0);
}
