#include "transport.h"
#include <arpa/inet.h>
#include <liburing.h>
#include <liburing/io_uring.h>
#include <netinet/in.h>
#include <pthread.h>
#include <stdio.h>
#include <sys/time.h>
#include <sys/un.h>
#include <unistd.h>
#include "memory_configuration.h"
#include "transport.h"
#include "transport_collections.h"
#include "transport_common.h"
#include "transport_configuration.h"
#include "transport_constants.h"

int transport_initialize(struct transport* transport,
                         struct transport_module_configuration* configuration,
                         uint8_t id)
{
    transport->id = id;
    transport->ring_size = configuration->ring_size;
    transport->delay_randomization_factor = configuration->delay_randomization_factor;
    transport->base_delay_micros = configuration->base_delay_micros;
    transport->max_delay_micros = configuration->max_delay_micros;
    transport->memory_configuration = calloc(1, sizeof(struct memory_module_configuration));
    *transport->memory_configuration = *configuration->memory_configuration;
    transport->timeout_checker_period_millis = configuration->timeout_checker_period_millis;
    transport->cqe_wait_timeout_millis = configuration->cqe_wait_timeout_millis;
    transport->cqe_wait_count = configuration->cqe_wait_count;
    transport->cqe_peek_count = configuration->cqe_peek_count;
    transport->trace = configuration->trace;
    transport->completions = malloc(sizeof(struct io_uring_cqe*) * configuration->ring_size);
    if (!transport->completions)
    {
        return -ENOMEM;
    }

    transport->events = mh_events_new();
    if (!transport->events)
    {
        return -ENOMEM;
    }
    mh_events_reserve(transport->events, configuration->memory_configuration->static_buffers_capacity, 0);

    transport->inet_used_messages = malloc(sizeof(struct msghdr) * configuration->memory_configuration->static_buffers_capacity);
    transport->unix_used_messages = malloc(sizeof(struct msghdr) * configuration->memory_configuration->static_buffers_capacity);

    if (!transport->inet_used_messages || !transport->unix_used_messages)
    {
        return -ENOMEM;
    }

    for (size_t index = 0; index < configuration->memory_configuration->static_buffers_capacity; index++)
    {
        memset(&transport->inet_used_messages[index], 0, sizeof(struct msghdr));
        transport->inet_used_messages[index].msg_name = malloc(sizeof(struct sockaddr_in));
        if (!transport->inet_used_messages[index].msg_name)
        {
            return -ENOMEM;
        }
        transport->inet_used_messages[index].msg_namelen = sizeof(struct sockaddr_in);

        memset(&transport->unix_used_messages[index], 0, sizeof(struct msghdr));
        transport->unix_used_messages[index].msg_name = malloc(sizeof(struct sockaddr_un));
        if (!transport->unix_used_messages[index].msg_name)
        {
            return -ENOMEM;
        }
        transport->unix_used_messages[index].msg_namelen = sizeof(struct sockaddr_un);
    }

    transport->ring = malloc(sizeof(struct io_uring));
    if (!transport->ring)
    {
        return -ENOMEM;
    }

    int result = io_uring_queue_init(configuration->ring_size, transport->ring, configuration->ring_flags);
    if (result)
    {
        return result;
    }

    transport->descriptor = transport->ring->ring_fd;

    return 0;
}

int transport_setup(struct transport* transport)
{
    int result = io_uring_register_buffers(transport->ring, transport->buffers, transport->memory_configuration->static_buffers_capacity);
    if (result)
    {
        return result;
    }

    return 0;
}

static inline void transport_add_event(struct transport* transport, int fd, uint64_t data, int64_t timeout)
{
    struct mh_events_node_t node = {
        .data = data,
        .timeout = timeout,
        .timestamp = time(NULL),
        .fd = fd,
    };
    mh_events_put(transport->events, &node, NULL, 0);
}

void transport_write(struct transport* transport,
                     uint32_t fd,
                     uint16_t buffer_id,
                     uint32_t offset,
                     int64_t timeout,
                     uint16_t event,
                     uint8_t sqe_flags)
{
    struct io_uring* ring = transport->ring;
    struct io_uring_sqe* sqe = transport_provide_sqe(ring);
    uint64_t data = (((uint64_t)(fd) << 32) | (uint64_t)(buffer_id) << 16) | ((uint64_t)event);
    struct iovec* buffer = &transport->buffers[buffer_id];
    io_uring_prep_write_fixed(sqe, fd, buffer->iov_base, buffer->iov_len, offset, buffer_id);
    io_uring_sqe_set_data64(sqe, data);
    sqe->flags |= sqe_flags;
    transport_add_event(transport, fd, data, timeout);
}

void transport_read(struct transport* transport,
                    uint32_t fd,
                    uint16_t buffer_id,
                    uint32_t offset,
                    int64_t timeout,
                    uint16_t event,
                    uint8_t sqe_flags)
{
    struct io_uring* ring = transport->ring;
    struct io_uring_sqe* sqe = transport_provide_sqe(ring);
    uint64_t data = (((uint64_t)(fd) << 32) | (uint64_t)(buffer_id) << 16) | ((uint64_t)event);
    struct iovec* buffer = &transport->buffers[buffer_id];
    io_uring_prep_read_fixed(sqe, fd, buffer->iov_base, buffer->iov_len, offset, buffer_id);
    io_uring_sqe_set_data64(sqe, data);
    sqe->flags |= sqe_flags;
    transport_add_event(transport, fd, data, timeout);
}

void transport_send_message(struct transport* transport,
                            uint32_t fd,
                            uint16_t buffer_id,
                            struct sockaddr* address,
                            transport_socket_family_t socket_family,
                            int message_flags,
                            int64_t timeout,
                            uint16_t event,
                            uint8_t sqe_flags)
{
    struct io_uring* ring = transport->ring;
    struct io_uring_sqe* sqe = transport_provide_sqe(ring);
    uint64_t data = (((uint64_t)(fd) << 32) | (uint64_t)(buffer_id) << 16) | ((uint64_t)event);
    struct msghdr* message;
    if (socket_family == INET)
    {
        message = &transport->inet_used_messages[buffer_id];
        memcpy(message->msg_name, address, message->msg_namelen);
    }
    if (socket_family == UNIX)
    {
        message = &transport->unix_used_messages[buffer_id];
        message->msg_namelen = SUN_LEN((struct sockaddr_un*)address);
        memcpy(message->msg_name, address, message->msg_namelen);
    }
    message->msg_control = NULL;
    message->msg_controllen = 0;
    message->msg_iov = &transport->buffers[buffer_id];
    message->msg_iovlen = 1;
    message->msg_flags = 0;
    io_uring_prep_sendmsg(sqe, fd, message, message_flags);
    io_uring_sqe_set_data64(sqe, data);
    sqe->flags |= sqe_flags;
    transport_add_event(transport, fd, data, timeout);
}

void transport_receive_message(struct transport* transport,
                               uint32_t fd,
                               uint16_t buffer_id,
                               transport_socket_family_t socket_family,
                               int message_flags,
                               int64_t timeout,
                               uint16_t event,
                               uint8_t sqe_flags)
{
    struct io_uring* ring = transport->ring;
    struct io_uring_sqe* sqe = transport_provide_sqe(ring);
    uint64_t data = (((uint64_t)(fd) << 32) | (uint64_t)(buffer_id) << 16) | ((uint64_t)event);
    struct msghdr* message;
    if (socket_family == INET)
    {
        message = &transport->inet_used_messages[buffer_id];
        message->msg_namelen = sizeof(struct sockaddr_in);
    }
    if (socket_family == UNIX)
    {
        message = &transport->unix_used_messages[buffer_id];
        message->msg_namelen = sizeof(struct sockaddr_un);
    }
    message->msg_control = NULL;
    message->msg_controllen = 0;
    memset(message->msg_name, 0, message->msg_namelen);
    message->msg_iov = &transport->buffers[buffer_id];
    message->msg_iovlen = 1;
    message->msg_flags = 0;
    io_uring_prep_recvmsg(sqe, fd, message, message_flags);
    io_uring_sqe_set_data64(sqe, data);
    sqe->flags |= sqe_flags;
    transport_add_event(transport, fd, data, timeout);
}

void transport_connect(struct transport* transport, struct transport_client* client, int64_t timeout)
{
    struct io_uring* ring = transport->ring;
    struct io_uring_sqe* sqe = transport_provide_sqe(ring);
    uint64_t data = ((uint64_t)(client->fd) << 32) | ((uint64_t)TRANSPORT_EVENT_CONNECT | (uint64_t)TRANSPORT_EVENT_CLIENT);
    struct sockaddr* address = client->family == INET
                                   ? (struct sockaddr*)client->inet_destination_address
                                   : (struct sockaddr*)client->unix_destination_address;
    io_uring_prep_connect(sqe, client->fd, address, client->client_address_length);
    io_uring_sqe_set_data64(sqe, data);
    transport_add_event(transport, client->fd, data, timeout);
}

void transport_accept(struct transport* transport, struct transport_server* server)
{
    struct io_uring* ring = transport->ring;
    struct io_uring_sqe* sqe = transport_provide_sqe(ring);
    uint64_t data = ((uint64_t)(server->fd) << 32) | ((uint64_t)TRANSPORT_EVENT_ACCEPT | (uint64_t)TRANSPORT_EVENT_SERVER);
    struct sockaddr* address = server->family == INET
                                   ? (struct sockaddr*)server->inet_server_address
                                   : (struct sockaddr*)server->unix_server_address;
    io_uring_prep_accept(sqe, server->fd, address, &server->server_address_length, 0);
    io_uring_sqe_set_data64(sqe, data);
    transport_add_event(transport, server->fd, data, TRANSPORT_TIMEOUT_INFINITY);
}

void transport_cancel_by_fd(struct transport* transport, int fd)
{
    mh_int_t index;
    mh_int_t to_delete[transport->events->size];
    int to_delete_count = 0;
    mh_foreach(transport->events, index)
    {
        struct mh_events_node_t* node = mh_events_node(transport->events, index);
        if (node->fd == fd)
        {
            struct io_uring* ring = transport->ring;
            struct io_uring_sqe* sqe = transport_provide_sqe(ring);
            io_uring_prep_cancel(sqe, (void*)node->data, IORING_ASYNC_CANCEL_ALL);
            sqe->flags |= IOSQE_CQE_SKIP_SUCCESS;
            to_delete[to_delete_count++] = index;
        }
    }
    for (int index = 0; index < to_delete_count; index++)
    {
        mh_events_del(transport->events, to_delete[index], 0);
    }
    io_uring_submit(transport->ring);
}

int transport_peek(struct transport* transport)
{
    struct __kernel_timespec timeout = {
        .tv_nsec = transport->cqe_wait_timeout_millis * 1e+6,
        .tv_sec = 0,
    };
    io_uring_submit_and_wait_timeout(transport->ring, &transport->completions[0], transport->cqe_wait_count, &timeout, 0);
    return io_uring_peek_batch_cqe(transport->ring, &transport->completions[0], transport->cqe_peek_count);
}

void transport_check_event_timeouts(struct transport* transport)
{
    mh_int_t index;
    mh_int_t to_delete[transport->events->size];
    int to_delete_count = 0;
    mh_foreach(transport->events, index)
    {
        struct mh_events_node_t* node = mh_events_node(transport->events, index);
        int64_t timeout = node->timeout;
        if (timeout == TRANSPORT_TIMEOUT_INFINITY)
        {
            continue;
        }
        uint64_t timestamp = node->timestamp;
        uint64_t data = node->data;
        time_t current_time = time(NULL);
        if (current_time - timestamp > timeout)
        {
            struct io_uring* ring = transport->ring;
            struct io_uring_sqe* sqe = transport_provide_sqe(ring);
            io_uring_prep_cancel(sqe, (void*)data, IORING_ASYNC_CANCEL_ALL);
            sqe->flags |= IOSQE_CQE_SKIP_SUCCESS;
            to_delete[to_delete_count++] = index;
        }
    }
    for (int index = 0; index < to_delete_count; index++)
    {
        mh_events_del(transport->events, to_delete[index], 0);
    }
    io_uring_submit(transport->ring);
}

void transport_remove_event(struct transport* transport, uint64_t data)
{
    mh_int_t event;
    if ((event = mh_events_find(transport->events, data, 0)) != mh_end(transport->events))
    {
        mh_events_del(transport->events, event, 0);
    }
}

struct sockaddr* transport_get_datagram_address(struct transport* transport, transport_socket_family_t socket_family, int buffer_id)
{
    return socket_family == INET ? (struct sockaddr*)transport->inet_used_messages[buffer_id].msg_name
                                 : (struct sockaddr*)transport->unix_used_messages[buffer_id].msg_name;
}

void transport_destroy(struct transport* transport)
{
    io_uring_queue_exit(transport->ring);
    for (size_t index = 0; index < transport->memory_configuration->static_buffers_capacity; index++)
    {
        free(transport->inet_used_messages[index].msg_name);
        free(transport->unix_used_messages[index].msg_name);
    }
    mh_events_delete(transport->events);
    free(transport->completions);
    free(transport->inet_used_messages);
    free(transport->unix_used_messages);
    free(transport->ring);
    free(transport->memory_configuration);
    free(transport);
}

void transport_cqe_advance(struct io_uring* ring, int count)
{
    io_uring_cq_advance(ring, count);
}
