#include <liburing.h>
#include <liburing/io_uring.h>
#include <executor_native.h>
#include <stdint.h>
#include <sys/resource.h>
#include <sys/socket.h>
#include "executor_configuration.h"
#include "executor_constants.h"

#define simple_map_name _native_callbacks
struct simple_map_native_callbacks_key_t
{
    uint64_t owner;
    uint64_t method;
};
#define simple_map_key_t struct simple_map_native_callbacks_key_t
struct simple_map_native_callbacks_node_t
{
    simple_map_key_t key;
    void (*callback)(struct executor_message*);
};

#define simple_map_node_t struct simple_map_native_callbacks_node_t
#define simple_map_arg_t uint64_t
#define simple_map_hash(a, arg) (a->key.owner * 31 + a->key.method)
#define simple_map_hash_key(a, arg) (a.owner * 31 + a.method)
#define simple_map_cmp(a, b, arg) ((a->key.owner != b->key.owner) && (a->key.method != b->key.method))
#define simple_map_cmp_key(a, b, arg) ((a.owner != b->key.owner) && (a.method != b->key.method))
#define SIMPLE_MAP_SOURCE
#include <maps/simple.h>

int32_t executor_native_initialize(struct executor_native* executor, struct executor_native_configuration* configuration, uint8_t id)
{
    executor->id = id;
    executor->configuration = *configuration;
    executor->completions = malloc(sizeof(struct io_uring_cqe*) * configuration->ring_size);
    if (!executor->completions)
    {
        return -ENOMEM;
    }

    executor->callbacks = simple_map_native_callbacks_new();
    if (!executor->callbacks)
    {
        return -ENOMEM;
    }

    executor->ring = calloc(1, sizeof(struct io_uring));
    if (!executor->ring)
    {
        return -ENOMEM;
    }

    int32_t result = io_uring_queue_init(configuration->ring_size, executor->ring, configuration->ring_flags);
    if (result)
    {
        return result;
    }

    executor->descriptor = executor->ring->ring_fd;

    return executor->descriptor;
}

int32_t executor_native_initialize_default(struct executor_native* executor, uint8_t id)
{
    struct executor_native_configuration configuration = {
        .static_buffers_capacity = 4096,
        .static_buffer_size = 4096,
        .ring_size = 16384,
        .ring_flags = 0,
        .completion_wait_count = 1,
        .completion_wait_timeout_millis = 1,
        .preallocation_size = 64 * 1024,
        .slab_size = 64 * 1024,
        .quota_size = 1 * 1024 * 1024,
    };
    return executor_native_initialize(executor, &configuration, id);
}

void executor_native_register_callback(struct executor_native* executor, uint64_t owner, uint64_t method, void (*callback)(struct executor_message*))
{
    struct simple_map_native_callbacks_node_t node = {
        .callback = callback,
        .key = {
            .method = method,
            .owner = owner,
        },
    };
    simple_map_native_callbacks_put((struct simple_map_native_callbacks_t*)executor->callbacks, &node, NULL, 0);
}

int32_t executor_native_count_ready(struct executor_native* executor)
{
    return io_uring_cq_ready(executor->ring);
}

int32_t executor_native_count_ready_submit(struct executor_native* executor)
{
    io_uring_submit(executor->ring);
    return io_uring_cq_ready(executor->ring);
}

static inline int8_t executor_native_process_implementation(struct executor_native* executor)
{
    struct io_uring_cqe* cqe;
    unsigned head;
    unsigned count = 0;
    io_uring_for_each_cqe(executor->ring, head, cqe)
    {
        count++;
        if (cqe->res & EXECUTOR_NATIVE_CALL)
        {
            struct executor_message* message = (struct executor_message*)cqe->user_data;
            void (*pointer)(struct executor_message*) = (void (*)(struct executor_message*))message->method;
            pointer(message);
            struct io_uring_sqe* sqe = io_uring_get_sqe(executor->ring);
            if (sqe == NULL)
            {
                io_uring_cq_advance(executor->ring, count);
                return EXECUTOR_ERROR_RING_FULL;
            }
            uint64_t target = message->source;
            message->source = executor->descriptor;
            message->target = target;
            io_uring_prep_msg_ring(sqe, target, EXECUTOR_DART_CALLBACK, (uint64_t)((uintptr_t)message), 0);
            sqe->flags |= IOSQE_CQE_SKIP_SUCCESS;
            continue;
        }

        if (cqe->res & EXECUTOR_NATIVE_CALLBACK)
        {
            struct executor_message* message = (struct executor_message*)cqe->user_data;
            struct simple_map_native_callbacks_key_t key = {
                .owner = message->owner,
                .method = message->method,
            };
            simple_map_int_t callback;
            if ((callback = simple_map_native_callbacks_find(executor->callbacks, key, 0)) != simple_map_end((struct simple_map_native_callbacks_t*)executor->callbacks))
            {
                struct simple_map_native_callbacks_node_t* node = simple_map_native_callbacks_node((struct simple_map_native_callbacks_t*)executor->callbacks, callback);
                node->callback(message);
            }
            continue;
        }
    }
    io_uring_cq_advance(executor->ring, count);
    return 0;
}

int8_t executor_native_process(struct executor_native* executor)
{
    return executor_native_process_implementation(executor);
}

int8_t executor_native_process_infinity(struct executor_native* executor)
{
    io_uring_submit_and_wait(executor->ring, executor->configuration.completion_wait_count);
    if (io_uring_cq_ready(executor->ring) > 0)
    {
        return executor_native_process_implementation(executor);
    }
    return 0;
}

int8_t executor_native_process_timeout(struct executor_native* executor)
{
    struct __kernel_timespec timeout = {
        .tv_nsec = executor->configuration.completion_wait_timeout_millis * 1e+6,
        .tv_sec = 0,
    };
    io_uring_submit_and_wait_timeout(executor->ring, &executor->completions[0], executor->configuration.completion_wait_count, &timeout, 0);
    if (io_uring_cq_ready(executor->ring) > 0)
    {
        return executor_native_process_implementation(executor);
    }
    return 0;
}

void executor_native_foreach(struct executor_native* executor, void (*call)(struct executor_message*), void (*callback)(struct executor_message*))
{
    struct io_uring_cqe* cqe;
    unsigned head;
    unsigned count = 0;
    io_uring_for_each_cqe(executor->ring, head, cqe)
    {
        ++count;
        if (cqe->res & EXECUTOR_NATIVE_CALL && call)
        {
            struct executor_message* message = (struct executor_message*)cqe->user_data;
            call(message);
            continue;
        }

        if (cqe->res & EXECUTOR_NATIVE_CALLBACK && callback)
        {
            struct executor_message* message = (struct executor_message*)cqe->user_data;
            callback(message);
            continue;
        }
    }
    io_uring_cq_advance(executor->ring, count);
}

int32_t executor_native_submit(struct executor_native* executor)
{
    return io_uring_submit(executor->ring);
}

int8_t executor_native_call_dart(struct executor_native* executor, int32_t target_ring_fd, struct executor_message* message)
{
    struct io_uring_sqe* sqe = io_uring_get_sqe(executor->ring);
    if (sqe == NULL)
    {
        return EXECUTOR_ERROR_RING_FULL;
    }
    message->source = executor->descriptor;
    message->target = target_ring_fd;
    message->flags |= EXECUTOR_DART_CALL;
    io_uring_prep_msg_ring(sqe, target_ring_fd, EXECUTOR_DART_CALL, (uint64_t)((uintptr_t)message), 0);
    sqe->flags |= IOSQE_CQE_SKIP_SUCCESS;
    return 0;
}

int8_t executor_native_callback_to_dart(struct executor_native* executor, struct executor_message* message)
{
    struct io_uring_sqe* sqe = io_uring_get_sqe(executor->ring);
    if (sqe == NULL)
    {
        return EXECUTOR_ERROR_RING_FULL;
    }
    uint64_t target = message->source;
    message->source = executor->descriptor;
    message->target = target;
    message->flags |= EXECUTOR_DART_CALLBACK;
    io_uring_prep_msg_ring(sqe, target, EXECUTOR_DART_CALLBACK, (uint64_t)((uintptr_t)message), 0);
    sqe->flags |= IOSQE_CQE_SKIP_SUCCESS;
    return 0;
}

void executor_native_destroy(struct executor_native* executor)
{
    io_uring_queue_exit(executor->ring);
    simple_map_native_callbacks_delete(executor->callbacks);
    free(executor->ring);
    free(executor->completions);
}