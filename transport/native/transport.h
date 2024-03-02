#ifndef TRANSPORT_H
#define TRANSPORT_H

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
    struct transport_configuration
    {
        struct memory_module_configuration* memory_configuration;
        size_t ring_size;
        uint32_t ring_flags;
        uint64_t timeout_checker_period_millis;
        uint32_t base_delay_micros;
        double delay_randomization_factor;
        uint64_t max_delay_micros;
        uint64_t cqe_wait_timeout_millis;
        uint32_t cqe_wait_count;
        uint32_t cqe_peek_count;
        bool trace;
    };
    
    struct transport
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
        int32_t ring_flags;
        transport_completion_event** completions;
        uint64_t cqe_wait_timeout_millis;
        uint32_t cqe_wait_count;
        uint32_t cqe_peek_count;
        int32_t descriptor;
        bool trace;
    };

    int32_t transport_initialize(struct transport* transport,
                             struct transport_configuration* configuration,
                             uint8_t id);

    int32_t transport_setup(struct transport* transport);

    void transport_write(struct transport* transport,
                         uint32_t fd,
                         uint16_t buffer_id,
                         uint32_t offset,
                         int64_t timeout,
                         uint16_t event,
                         uint8_t sqe_flags);
    void transport_read(struct transport* transport,
                        uint32_t fd,
                        uint16_t buffer_id,
                        uint32_t offset,
                        int64_t timeout,
                        uint16_t event,
                        uint8_t sqe_flags);
    void transport_send_message(struct transport* transport,
                                uint32_t fd,
                                uint16_t buffer_id,
                                struct sockaddr* address,
                                transport_socket_family_t socket_family,
                                int32_t message_flags,
                                int64_t timeout,
                                uint16_t event,
                                uint8_t sqe_flags);
    void transport_receive_message(struct transport* transport,
                                   uint32_t fd,
                                   uint16_t buffer_id,
                                   transport_socket_family_t socket_family,
                                   int32_t message_flags,
                                   int64_t timeout,
                                   uint16_t event,
                                   uint8_t sqe_flags);
    void transport_connect(struct transport* transport, struct transport_client* client, int64_t timeout);
    void transport_accept(struct transport* transport, struct transport_server* server);

    void transport_cancel_by_fd(struct transport* transport, int32_t fd);

    void transport_check_event_timeouts(struct transport* transport);
    void transport_remove_event(struct transport* transport, uint64_t data);

    struct sockaddr* transport_get_datagram_address(struct transport* transport, transport_socket_family_t socket_family, int32_t buffer_id);

    int32_t transport_peek(struct transport* transport);
    void transport_cqe_advance(struct io_uring* ring, int32_t count);

    void transport_destroy(struct transport* transport);
#if defined(__cplusplus)
}
#endif

#endif
