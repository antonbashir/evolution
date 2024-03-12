#ifndef TRANSPORT_H
#define TRANSPORT_H

#include <stdbool.h>
#include <stdint.h>
#include "executor_configuration.h"
#include "memory_configuration.h"
#include "transport_client.h"
#include "transport_server.h"

#if defined(__cplusplus)
extern "C"
{
#endif

struct small_map_events_t;
struct executor;
DART_TYPE struct ip_mreqn;
DART_TYPE struct sockaddr_in;
DART_TYPE struct sockaddr_un;

struct transport_configuration
{
    struct memory_configuration memory_configuration;
    struct executor_configuration executor_configuration;
    uint64_t timeout_checker_period_milliseconds;
    bool trace;
};

struct transport
{
    uint8_t id;
    struct iovec* buffers;
    struct executor* transport_executor;
    struct transport_configuration configuration;
    struct msghdr* inet_used_messages;
    struct msghdr* unix_used_messages;
    struct simple_map_events_t* events;
};

int32_t transport_initialize(struct transport* transport,
                             struct transport_configuration* configuration,
                             uint8_t id);

int32_t transport_setup(struct transport* transport, struct executor* executor);

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

void transport_destroy(struct transport* transport);
#if defined(__cplusplus)
}
#endif

#endif
