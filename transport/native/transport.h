#ifndef TRANSPORT_H_INCLUDED
#define TRANSPORT_H_INCLUDED

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include "transport_client.h"
#include "transport_server.h"

#if defined(__cplusplus)
extern "C"
{
#endif
    struct mh_events_t;
    struct io_uring;
    typedef struct io_uring_cqe transport_completion_event;
    struct memory_module_configuration;

    typedef struct transport_configuration
    {
        struct memory_module_configuration* memory_configuration;
        uint16_t buffers_capacity;
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
        struct io_uring* ring;
        struct iovec* buffers;
        struct memory_module_configuration* memory_configuration;
        uint64_t timeout_checker_period_millis;
        uint32_t base_delay_micros;
        double delay_randomization_factor;
        uint64_t max_delay_micros;
        struct msghdr* inet_used_messages;
        struct msghdr* unix_used_messages;
        struct mh_events_t* events;
        size_t ring_size;
        int ring_flags;
        transport_completion_event** completions;
        uint64_t cqe_wait_timeout_millis;
        uint32_t cqe_wait_count;
        uint32_t cqe_peek_count;
        int32_t descriptor;
        bool trace;
    } transport_t;

    int transport_initialize(transport_t* transport,
                             transport_configuration_t* configuration,
                             uint8_t id);

    int transport_setup(transport_t* transport);

    void transport_write(transport_t* transport,
                         uint32_t fd,
                         uint16_t buffer_id,
                         uint32_t offset,
                         int64_t timeout,
                         uint16_t event,
                         uint8_t sqe_flags);
    void transport_read(transport_t* transport,
                        uint32_t fd,
                        uint16_t buffer_id,
                        uint32_t offset,
                        int64_t timeout,
                        uint16_t event,
                        uint8_t sqe_flags);
    void transport_send_message(transport_t* transport,
                                uint32_t fd,
                                uint16_t buffer_id,
                                struct sockaddr* address,
                                transport_socket_family_t socket_family,
                                int message_flags,
                                int64_t timeout,
                                uint16_t event,
                                uint8_t sqe_flags);
    void transport_receive_message(transport_t* transport,
                                   uint32_t fd,
                                   uint16_t buffer_id,
                                   transport_socket_family_t socket_family,
                                   int message_flags,
                                   int64_t timeout,
                                   uint16_t event,
                                   uint8_t sqe_flags);
    void transport_connect(transport_t* transport, transport_client_t* client, int64_t timeout);
    void transport_accept(transport_t* transport, transport_server_t* server);

    void transport_cancel_by_fd(transport_t* transport, int fd);

    void transport_check_event_timeouts(transport_t* transport);
    void transport_remove_event(transport_t* transport, uint64_t data);

    struct sockaddr* transport_get_datagram_address(transport_t* transport, transport_socket_family_t socket_family, int buffer_id);

    int transport_peek(transport_t* transport);
    void transport_cqe_advance(struct io_uring* ring, int count);

    void transport_destroy(transport_t* transport);
#if defined(__cplusplus)
}
#endif

#endif
