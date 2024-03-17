#include "transport.h"
#include <liburing.h>
#include "collections.h"
#include "constants.h"
#include "module.h"

struct transport* transport_initialize(struct transport_configuration* configuration, uint8_t id)
{
    struct transport* transport = transport_module_new(sizeof(struct transport));
    transport->id = id;
    transport->configuration = *configuration;

    transport->events = simple_map_events_new();
    if (!transport->events)
    {
        return NULL;
    }
    simple_map_events_reserve(transport->events, configuration->memory_instance_configuration.static_buffers_capacity, 0);

    transport->inet_used_messages = transport_module_allocate(configuration->memory_instance_configuration.static_buffers_capacity, sizeof(struct msghdr));
    transport->unix_used_messages = transport_module_allocate(configuration->memory_instance_configuration.static_buffers_capacity, sizeof(struct msghdr));

    if (!transport->inet_used_messages || !transport->unix_used_messages)
    {
        return NULL;
    }

    for (size_t index = 0; index < configuration->memory_instance_configuration.static_buffers_capacity; index++)
    {
        memset(&transport->inet_used_messages[index], 0, sizeof(struct msghdr));
        transport->inet_used_messages[index].msg_name = transport_module_new(sizeof(struct sockaddr_in));
        if (!transport->inet_used_messages[index].msg_name)
        {
            return NULL;
        }
        transport->inet_used_messages[index].msg_namelen = sizeof(struct sockaddr_in);

        memset(&transport->unix_used_messages[index], 0, sizeof(struct msghdr));
        transport->unix_used_messages[index].msg_name = transport_module_new(sizeof(struct sockaddr_un));
        if (!transport->unix_used_messages[index].msg_name)
        {
            return NULL;
        }
        transport->unix_used_messages[index].msg_namelen = sizeof(struct sockaddr_un);
    }

    return 0;
}

int32_t transport_setup(struct transport* transport, struct executor_instance* transport_executor)
{
    transport->transport_executor = transport_executor;
    struct io_uring* ring = transport_executor->ring;
    int32_t result = io_uring_register_buffers(transport->transport_executor->ring, transport->buffers, transport->configuration.memory_instance_configuration.static_buffers_capacity);
    if (result)
    {
        return result;
    }

    return 0;
}

static FORCEINLINE void transport_add_event(struct transport* transport, int32_t fd, uint64_t data, int64_t timeout)
{
    struct simple_map_transport_event node = {
        .data = data,
        .timeout = timeout,
        .timestamp = time(NULL),
        .fd = fd,
    };
    simple_map_events_put_copy(transport->events, &node, NULL, 0);
}

int8_t transport_write(struct transport* transport,
                       uint32_t fd,
                       uint16_t buffer_id,
                       uint32_t offset,
                       int64_t timeout,
                       uint16_t event,
                       uint8_t sqe_flags)
{
    struct io_uring* ring = transport->transport_executor->ring;
    struct io_uring_sqe* sqe = io_uring_get_sqe(ring);
    if (unlikely(sqe == NULL))
    {
        return TRANSPORT_RING_FULL;
    }
    uint64_t data = (((uint64_t)(fd) << 32) | (uint64_t)(buffer_id) << 16) | ((uint64_t)event);
    struct iovec* buffer = &transport->buffers[buffer_id];
    io_uring_prep_write_fixed(sqe, fd, buffer->iov_base, buffer->iov_len, offset, buffer_id);
    io_uring_sqe_set_data64(sqe, data);
    sqe->flags |= sqe_flags;
    transport_add_event(transport, fd, data, timeout);
    executor_submit(transport->transport_executor);
    return 0;
}

int8_t transport_read(struct transport* transport,
                      uint32_t fd,
                      uint16_t buffer_id,
                      uint32_t offset,
                      int64_t timeout,
                      uint16_t event,
                      uint8_t sqe_flags)
{
    struct io_uring* ring = transport->transport_executor->ring;
    struct io_uring_sqe* sqe = io_uring_get_sqe(ring);
    if (unlikely(sqe == NULL))
    {
        return TRANSPORT_RING_FULL;
    }
    uint64_t data = (((uint64_t)(fd) << 32) | (uint64_t)(buffer_id) << 16) | ((uint64_t)event);
    struct iovec* buffer = &transport->buffers[buffer_id];
    io_uring_prep_read_fixed(sqe, fd, buffer->iov_base, buffer->iov_len, offset, buffer_id);
    io_uring_sqe_set_data64(sqe, data);
    sqe->flags |= sqe_flags;
    transport_add_event(transport, fd, data, timeout);
    executor_submit(transport->transport_executor);
    return 0;
}

int8_t transport_send_message(struct transport* transport,
                              uint32_t fd,
                              uint16_t buffer_id,
                              struct sockaddr* address,
                              transport_socket_family_t socket_family,
                              int32_t message_flags,
                              int64_t timeout,
                              uint16_t event,
                              uint8_t sqe_flags)
{
    struct io_uring* ring = transport->transport_executor->ring;
    struct io_uring_sqe* sqe = io_uring_get_sqe(ring);
    if (unlikely(sqe == NULL))
    {
        return TRANSPORT_RING_FULL;
    }
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
    executor_submit(transport->transport_executor);
    return 0;
}

int8_t transport_receive_message(struct transport* transport,
                                 uint32_t fd,
                                 uint16_t buffer_id,
                                 transport_socket_family_t socket_family,
                                 int32_t message_flags,
                                 int64_t timeout,
                                 uint16_t event,
                                 uint8_t sqe_flags)
{
    struct io_uring* ring = transport->transport_executor->ring;
    struct io_uring_sqe* sqe = io_uring_get_sqe(ring);
    if (unlikely(sqe == NULL))
    {
        return TRANSPORT_RING_FULL;
    }
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
    executor_submit(transport->transport_executor);
    return 0;
}

int8_t transport_connect(struct transport* transport, struct transport_client* client, int64_t timeout)
{
    struct io_uring* ring = transport->transport_executor->ring;
    struct io_uring_sqe* sqe = io_uring_get_sqe(ring);
    if (unlikely(sqe == NULL))
    {
        return TRANSPORT_RING_FULL;
    }
    uint64_t data = ((uint64_t)(client->fd) << 32) | ((uint64_t)TRANSPORT_EVENT_CONNECT | (uint64_t)TRANSPORT_EVENT_CLIENT);
    struct sockaddr* address = client->family == INET
                                   ? (struct sockaddr*)client->inet_destination_address
                                   : (struct sockaddr*)client->unix_destination_address;
    io_uring_prep_connect(sqe, client->fd, address, client->client_address_length);
    io_uring_sqe_set_data64(sqe, data);
    transport_add_event(transport, client->fd, data, timeout);
    executor_submit(transport->transport_executor);
    return 0;
}

int8_t transport_accept(struct transport* transport, struct transport_server* server)
{
    struct io_uring* ring = transport->transport_executor->ring;
    struct io_uring_sqe* sqe = io_uring_get_sqe(ring);
    if (unlikely(sqe == NULL))
    {
        return TRANSPORT_RING_FULL;
    }
    uint64_t data = ((uint64_t)(server->fd) << 32) | ((uint64_t)TRANSPORT_EVENT_ACCEPT | (uint64_t)TRANSPORT_EVENT_SERVER);
    struct sockaddr* address = server->family == INET
                                   ? (struct sockaddr*)server->inet_server_address
                                   : (struct sockaddr*)server->unix_server_address;
    io_uring_prep_accept(sqe, server->fd, address, &server->server_address_length, 0);
    io_uring_sqe_set_data64(sqe, data);
    transport_add_event(transport, server->fd, data, TRANSPORT_TIMEOUT_INFINITY);
    executor_submit(transport->transport_executor);
    return 0;
}

int8_t transport_cancel_by_fd(struct transport* transport, int32_t fd)
{
    simple_map_int_t index;
    simple_map_int_t to_delete[transport->events->size];
    int32_t to_delete_count = 0;
    struct io_uring* ring = transport->transport_executor->ring;
    simple_map_foreach(transport->events, index)
    {
        struct simple_map_transport_event* node = simple_map_events_node(transport->events, index);
        if (node->fd == fd)
        {
            struct io_uring_sqe* sqe = io_uring_get_sqe(ring);
            if (unlikely(sqe == NULL))
            {
                return TRANSPORT_RING_FULL;
            }
            io_uring_prep_cancel(sqe, (void*)node->data, IORING_ASYNC_CANCEL_ALL);
            sqe->flags |= IOSQE_CQE_SKIP_SUCCESS;
            to_delete[to_delete_count++] = index;
        }
    }
    for (int32_t index = 0; index < to_delete_count; index++)
    {
        simple_map_events_del(transport->events, to_delete[index], 0);
    }
    executor_submit(transport->transport_executor);
    return 0;
}

void transport_check_event_timeouts(struct transport* transport)
{
    simple_map_int_t index;
    simple_map_int_t to_delete[transport->events->size];
    int32_t to_delete_count = 0;
    struct io_uring* ring = transport->transport_executor->ring;
    simple_map_foreach(transport->events, index)
    {
        struct simple_map_transport_event* node = simple_map_events_node(transport->events, index);
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
            struct io_uring_sqe* sqe = io_uring_get_sqe(ring);
            if (unlikely(sqe == NULL))
            {
                continue;
            }
            io_uring_prep_cancel(sqe, (void*)data, IORING_ASYNC_CANCEL_ALL);
            sqe->flags |= IOSQE_CQE_SKIP_SUCCESS;
            to_delete[to_delete_count++] = index;
        }
    }
    for (int32_t index = 0; index < to_delete_count; index++)
    {
        simple_map_events_del(transport->events, to_delete[index], 0);
    }
    executor_submit(transport->transport_executor);
}

void transport_remove_event(struct transport* transport, uint64_t data)
{
    simple_map_int_t event;
    if ((event = simple_map_events_find(transport->events, data, 0)) != simple_map_end(transport->events))
    {
        simple_map_events_del(transport->events, event, 0);
    }
}

void transport_destroy(struct transport* transport)
{
    for (size_t index = 0; index < transport->configuration.memory_instance_configuration.static_buffers_capacity; index++)
    {
        transport_module_delete(transport->inet_used_messages[index].msg_name);
        transport_module_delete(transport->unix_used_messages[index].msg_name);
    }
    simple_map_events_delete(transport->events);
    transport_module_delete(transport->inet_used_messages);
    transport_module_delete(transport->unix_used_messages);
    transport_module_delete(transport);
}

void transport_cqe_advance(struct io_uring* ring, int32_t count)
{
    io_uring_cq_advance(ring, count);
}
