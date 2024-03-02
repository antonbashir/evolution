#include <liburing.h>
#include <liburing/io_uring.h>
#include <mediator_native.h>
#include <stdint.h>
#include <sys/resource.h>
#include <sys/socket.h>
#include "mediator_configuration.h"
#include "mediator_constants.h"

#define mh_name _native_callbacks
struct mh_native_callbacks_key_t
{
    uint64_t owner;
    uint64_t method;
};
#define mh_key_t struct mh_native_callbacks_key_t
struct mh_native_callbacks_node_t
{
    mh_key_t key;
    void (*callback)(struct mediator_message*);
};

#define mh_node_t struct mh_native_callbacks_node_t
#define mh_arg_t uint64_t
#define mh_hash(a, arg) (a->key.owner * 31 + a->key.method)
#define mh_hash_key(a, arg) (a.owner * 31 + a.method)
#define mh_cmp(a, b, arg) ((a->key.owner != b->key.owner) && (a->key.method != b->key.method))
#define mh_cmp_key(a, b, arg) ((a.owner != b->key.owner) && (a.method != b->key.method))
#define MH_SOURCE

#include "collections/mhash.h"

#undef mh_node_t
#undef mh_arg_t
#undef mh_hash
#undef mh_hash_key
#undef mh_cmp
#undef mh_cmp_key

int32_t mediator_native_initialize(struct mediator_native* mediator, struct mediator_module_native_configuration* configuration, uint8_t id)
{
    mediator->configuration = *configuration;
    mediator->completions = malloc(sizeof(struct io_uring_cqe*) * configuration->ring_size);
    if (!mediator->completions)
    {
        return -ENOMEM;
    }

    mediator->callbacks = mh_native_callbacks_new();
    if (!mediator->callbacks)
    {
        return -ENOMEM;
    }

    mediator->ring = calloc(1, sizeof(struct io_uring));
    if (!mediator->ring)
    {
        return -ENOMEM;
    }

    int32_t result = io_uring_queue_init(configuration->ring_size, mediator->ring, configuration->ring_flags);
    if (result)
    {
        return result;
    }

    mediator->descriptor = mediator->ring->ring_fd;

    return mediator->descriptor;
}

int32_t mediator_native_initialize_default(struct mediator_native* mediator, uint8_t id)
{
    struct mediator_module_native_configuration configuration = {
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
    return mediator_native_initialize(mediator, &configuration, id);
}

void mediator_native_register_callback(struct mediator_native* mediator, uint64_t owner, uint64_t method, void (*callback)(struct mediator_message*))
{
    struct mh_native_callbacks_node_t node = {
        .callback = callback,
        .key = {
            .method = method,
            .owner = owner,
        },
    };
    mh_native_callbacks_put((struct mh_native_callbacks_t*)mediator->callbacks, &node, NULL, 0);
}

int32_t mediator_native_count_ready(struct mediator_native* mediator)
{
    return io_uring_cq_ready(mediator->ring);
}

int32_t mediator_native_count_ready_submit(struct mediator_native* mediator)
{
    io_uring_submit(mediator->ring);
    return io_uring_cq_ready(mediator->ring);
}

static inline int8_t mediator_native_process_implementation(struct mediator_native* mediator)
{
    struct io_uring_cqe* cqe;
    unsigned head;
    unsigned count = 0;
    io_uring_for_each_cqe(mediator->ring, head, cqe)
    {
        count++;
        if (cqe->res & MEDIATOR_NATIVE_CALL)
        {
            struct mediator_message* message = (struct mediator_message*)cqe->user_data;
            void (*pointer)(struct mediator_message*) = (void (*)(struct mediator_message*))message->method;
            pointer(message);
            struct io_uring_sqe* sqe = io_uring_get_sqe(mediator->ring);
            if (sqe == NULL)
            {
                io_uring_cq_advance(mediator->ring, count);
                return MEDIATOR_ERROR_RING_FULL;
            }
            uint64_t target = message->source;
            message->source = mediator->descriptor;
            message->target = target;
            io_uring_prep_msg_ring(sqe, target, MEDIATOR_DART_CALLBACK, (uint64_t)((uintptr_t)message), 0);
            sqe->flags |= IOSQE_CQE_SKIP_SUCCESS;
            continue;
        }

        if (cqe->res & MEDIATOR_NATIVE_CALLBACK)
        {
            struct mediator_message* message = (struct mediator_message*)cqe->user_data;
            struct mh_native_callbacks_key_t key = {
                .owner = message->owner,
                .method = message->method,
            };
            mh_int_t callback;
            if ((callback = mh_native_callbacks_find(mediator->callbacks, key, 0)) != mh_end((struct mh_native_callbacks_t*)mediator->callbacks))
            {
                struct mh_native_callbacks_node_t* node = mh_native_callbacks_node((struct mh_native_callbacks_t*)mediator->callbacks, callback);
                node->callback(message);
            }
            continue;
        }
    }
    io_uring_cq_advance(mediator->ring, count);
    return 0;
}

int8_t mediator_native_process(struct mediator_native* mediator)
{
    return mediator_native_process_implementation(mediator);
}

int8_t mediator_native_process_infinity(struct mediator_native* mediator)
{
    io_uring_submit_and_wait(mediator->ring, mediator->configuration.completion_wait_count);
    if (io_uring_cq_ready(mediator->ring) > 0)
    {
        return mediator_native_process_implementation(mediator);
    }
    return 0;
}

int8_t mediator_native_process_timeout(struct mediator_native* mediator)
{
    struct __kernel_timespec timeout = {
        .tv_nsec = mediator->configuration.completion_wait_timeout_millis * 1e+6,
        .tv_sec = 0,
    };
    io_uring_submit_and_wait_timeout(mediator->ring, &mediator->completions[0], mediator->configuration.completion_wait_count, &timeout, 0);
    if (io_uring_cq_ready(mediator->ring) > 0)
    {
        return mediator_native_process_implementation(mediator);
    }
    return 0;
}

void mediator_native_foreach(struct mediator_native* mediator, void (*call)(struct mediator_message*), void (*callback)(struct mediator_message*))
{
    struct io_uring_cqe* cqe;
    unsigned head;
    unsigned count = 0;
    io_uring_for_each_cqe(mediator->ring, head, cqe)
    {
        ++count;
        if (cqe->res & MEDIATOR_NATIVE_CALL && call)
        {
            struct mediator_message* message = (struct mediator_message*)cqe->user_data;
            call(message);
            continue;
        }

        if (cqe->res & MEDIATOR_NATIVE_CALLBACK && callback)
        {
            struct mediator_message* message = (struct mediator_message*)cqe->user_data;
            callback(message);
            continue;
        }
    }
    io_uring_cq_advance(mediator->ring, count);
}

int32_t mediator_native_submit(struct mediator_native* mediator)
{
    return io_uring_submit(mediator->ring);
}

int8_t mediator_native_call_dart(struct mediator_native* mediator, int32_t target_ring_fd, struct mediator_message* message)
{
    struct io_uring_sqe* sqe = io_uring_get_sqe(mediator->ring);
    if (sqe == NULL)
    {
        return MEDIATOR_ERROR_RING_FULL;
    }
    message->source = mediator->descriptor;
    message->target = target_ring_fd;
    message->flags |= MEDIATOR_DART_CALL;
    io_uring_prep_msg_ring(sqe, target_ring_fd, MEDIATOR_DART_CALL, (uint64_t)((uintptr_t)message), 0);
    sqe->flags |= IOSQE_CQE_SKIP_SUCCESS;
    return 0;
}

int8_t mediator_native_callback_to_dart(struct mediator_native* mediator, struct mediator_message* message)
{
    struct io_uring_sqe* sqe = io_uring_get_sqe(mediator->ring);
    if (sqe == NULL)
    {
        return MEDIATOR_ERROR_RING_FULL;
    }
    uint64_t target = message->source;
    message->source = mediator->descriptor;
    message->target = target;
    message->flags |= MEDIATOR_DART_CALLBACK;
    io_uring_prep_msg_ring(sqe, target, MEDIATOR_DART_CALLBACK, (uint64_t)((uintptr_t)message), 0);
    sqe->flags |= IOSQE_CQE_SKIP_SUCCESS;
    return 0;
}

void mediator_native_destroy(struct mediator_native* mediator)
{
    io_uring_queue_exit(mediator->ring);
    mh_native_callbacks_delete(mediator->callbacks);
    free(mediator->ring);
    free(mediator->completions);
}