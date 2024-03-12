#ifndef TRANSPORT_SOCKET_H
#define TRANSPORT_SOCKET_H

#include <stdbool.h>
#include <stdint.h>
#include "common/common.h"

#if defined(__cplusplus)
extern "C"
{
#endif
struct ip_mreqn;

DART_LEAF_FUNCTION int64_t transport_socket_create_tcp(uint64_t flags,
                                                       uint32_t socket_receive_buffer_size,
                                                       uint32_t socket_send_buffer_size,
                                                       uint32_t socket_receive_low_at,
                                                       uint32_t socket_send_low_at,
                                                       uint16_t ip_ttl,
                                                       uint32_t tcp_keep_alive_idle,
                                                       uint32_t tcp_keep_alive_max_count,
                                                       uint32_t tcp_keep_alive_individual_count,
                                                       uint32_t tcp_max_segment_size,
                                                       uint16_t tcp_syn_count);
DART_LEAF_FUNCTION int64_t transport_socket_create_udp(uint64_t flags,
                                                       uint32_t socket_receive_buffer_size,
                                                       uint32_t socket_send_buffer_size,
                                                       uint32_t socket_receive_low_at,
                                                       uint32_t socket_send_low_at,
                                                       uint16_t ip_ttl,
                                                       struct ip_mreqn* ip_multicast_interface,
                                                       uint32_t ip_multicast_ttl);
DART_LEAF_FUNCTION int64_t transport_socket_create_unix_stream(uint64_t flags,
                                                               uint32_t socket_receive_buffer_size,
                                                               uint32_t socket_send_buffer_size,
                                                               uint32_t socket_receive_low_at,
                                                               uint32_t socket_send_low_at);

DART_LEAF_FUNCTION void transport_socket_initialize_multicast_request(struct ip_mreqn* request, const char* group_address, const char* local_address, int32_t interface_index);

DART_LEAF_FUNCTION int32_t transport_socket_multicast_add_membership(int32_t fd, const char* group_address, const char* local_address, int32_t interface_index);
DART_LEAF_FUNCTION int32_t transport_socket_multicast_drop_membership(int32_t fd, const char* group_address, const char* local_address, int32_t interface_index);

DART_LEAF_FUNCTION int32_t transport_socket_multicast_add_source_membership(int32_t fd, const char* group_address, const char* local_address, const char* source_address);
DART_LEAF_FUNCTION int32_t transport_socket_multicast_drop_source_membership(int32_t fd, const char* group_address, const char* local_address, const char* source_address);

DART_LEAF_FUNCTION int32_t transport_socket_get_interface_index(const char* interface);

#if defined(__cplusplus)
}
#endif

#endif
