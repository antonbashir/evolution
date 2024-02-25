#ifndef TRANSPORT_H_INCLUDED
#define TRANSPORT_H_INCLUDED

#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include "transport_client.h"
#include "transport_server.h"

typedef struct io_uring transport_io_uring;

#if defined(__cplusplus)
extern "C"
{
#endif
    struct memory_static_buffers;
    struct mh_events_t;

    typedef struct transport_configuration
    {
        uint16_t buffers_count;
        uint32_t buffer_size;
        size_t ring_size;
        unsigned int ring_flags;
        uint64_t timeout_checker_period_millis;
        uint32_t base_delay_micros;
        double delay_randomization_factor;
        uint64_t max_delay_micros;
        uint64_t cqe_wait_timeout_millis;
        uint32_t cqe_wait_count;
        uint32_t cqe_peek_count;
        bool trace;
    } transport_configuration_t;

    typedef struct transport
    {
        uint8_t id;
        struct memory_static_buffers* free_buffers;
        struct io_uring* ring;
        struct iovec* buffers;
        uint32_t buffer_size;
        uint16_t buffers_count;
        uint64_t timeout_checker_period_millis;
        uint32_t base_delay_micros;
        double delay_randomization_factor;
        uint64_t max_delay_micros;
        struct msghdr* inet_used_messages;
        struct msghdr* unix_used_messages;
        struct mh_events_t* events;
        size_t ring_size;
        int ring_flags;
        struct interactor_completion_event** cqes;
        uint64_t cqe_wait_timeout_millis;
        uint32_t cqe_wait_count;
        uint32_t cqe_peek_count;
        int32_t descriptor;
        bool trace;
    } transport_t;

    int transport_initialize(transport_t* worker,
                                    transport_configuration_t* configuration,
                                    uint8_t id);

    void transport_write(transport_t* worker,
                                uint32_t fd,
                                uint16_t buffer_id,
                                uint32_t offset,
                                int64_t timeout,
                                uint16_t event,
                                uint8_t sqe_flags);
    void transport_read(transport_t* worker,
                               uint32_t fd,
                               uint16_t buffer_id,
                               uint32_t offset,
                               int64_t timeout,
                               uint16_t event,
                               uint8_t sqe_flags);
    void transport_send_message(transport_t* worker,
                                       uint32_t fd,
                                       uint16_t buffer_id,
                                       struct sockaddr* address,
                                       transport_socket_family_t socket_family,
                                       int message_flags,
                                       int64_t timeout,
                                       uint16_t event,
                                       uint8_t sqe_flags);
    void transport_receive_message(transport_t* worker,
                                          uint32_t fd,
                                          uint16_t buffer_id,
                                          transport_socket_family_t socket_family,
                                          int message_flags,
                                          int64_t timeout,
                                          uint16_t event,
                                          uint8_t sqe_flags);
    void transport_connect(transport_t* worker, transport_client_t* client, int64_t timeout);
    void transport_accept(transport_t* worker, transport_server_t* server);

    void transport_cancel_by_fd(transport_t* worker, int fd);

    void transport_check_event_timeouts(transport_t* worker);
    void transport_remove_event(transport_t* worker, uint64_t data);

    struct sockaddr* transport_get_datagram_address(transport_t* worker, transport_socket_family_t socket_family, int buffer_id);

    int transport_peek(transport_t* worker);

    void transport_destroy(transport_t* worker);

    void transport_cqe_advance(transport_io_uring* ring, int count);
#if defined(__cplusplus)
}
#endif

#endif
