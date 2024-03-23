#ifndef TRANSPORT_H
#define TRANSPORT_H

#include <executor/executor.h>
#include <memory/configuration.h>
#include "client.h"
#include "configuration.h"
#include "server.h"

#if defined(__cplusplus)
extern "C"
{
#endif

DART_STRUCTURE struct transport
{
    DART_FIELD struct iovec* buffers;
    DART_FIELD struct executor_instance* transport_executor;
    DART_FIELD struct transport_configuration configuration;
    DART_FIELD struct msghdr* inet_used_messages;
    DART_FIELD struct msghdr* unix_used_messages;
    DART_FIELD DART_TYPE struct simple_map_events_t* events;
};

DART_LEAF_FUNCTION struct transport* transport_initialize(struct transport_configuration* configuration);

DART_LEAF_FUNCTION int16_t transport_setup(struct transport* transport, struct executor_instance* executor);

DART_LEAF_FUNCTION int16_t transport_write(struct transport* transport,
                                           uint32_t fd,
                                           uint16_t buffer_id,
                                           uint32_t offset,
                                           int64_t timeout,
                                           uint16_t event,
                                           uint8_t sqe_flags);
DART_LEAF_FUNCTION int16_t transport_read(struct transport* transport,
                                          uint32_t fd,
                                          uint16_t buffer_id,
                                          uint32_t offset,
                                          int64_t timeout,
                                          uint16_t event,
                                          uint8_t sqe_flags);
DART_LEAF_FUNCTION int16_t transport_send_message(struct transport* transport,
                                                  uint32_t fd,
                                                  uint16_t buffer_id,
                                                  struct sockaddr* address,
                                                  uint8_t socket_family,
                                                  int32_t message_flags,
                                                  int64_t timeout,
                                                  uint16_t event,
                                                  uint8_t sqe_flags);
DART_LEAF_FUNCTION int16_t transport_receive_message(struct transport* transport,
                                                     uint32_t fd,
                                                     uint16_t buffer_id,
                                                     uint8_t socket_family,
                                                     int32_t message_flags,
                                                     int64_t timeout,
                                                     uint16_t event,
                                                     uint8_t sqe_flags);
DART_LEAF_FUNCTION int16_t transport_connect(struct transport* transport, struct transport_client* client, int64_t timeout);
DART_LEAF_FUNCTION int16_t transport_accept(struct transport* transport, struct transport_server* server);

DART_LEAF_FUNCTION int16_t transport_cancel_by_fd(struct transport* transport, int32_t fd);

DART_LEAF_FUNCTION void transport_check_event_timeouts(struct transport* transport);
DART_LEAF_FUNCTION void transport_remove_event(struct transport* transport, uint64_t data);

DART_INLINE_LEAF_FUNCTION struct sockaddr* transport_get_datagram_address(struct transport* transport,
                                                                          uint8_t socket_family,
                                                                          int32_t buffer_id)
{
    return socket_family == TRANSPORT_SOCKET_FAMILY_INET ? (struct sockaddr*)transport->inet_used_messages[buffer_id].msg_name
                                                         : (struct sockaddr*)transport->unix_used_messages[buffer_id].msg_name;
}

DART_LEAF_FUNCTION void transport_destroy(struct transport* transport);
#if defined(__cplusplus)
}
#endif

#endif
