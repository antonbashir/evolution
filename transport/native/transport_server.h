#ifndef TRANSPORT_SERVER_H
#define TRANSPORT_SERVER_H

#include <stdbool.h>
#include <stdint.h>
#include "common/common.h"
#include "transport_constants.h"

#if defined(__cplusplus)
extern "C"
{
#endif

struct ip_mreqn;
struct sockaddr_in;
struct sockaddr_un;

DART_STRUCTURE struct transport_server_configuration
{
    DART_FIELD int32_t socket_max_connections;
    DART_FIELD uint64_t socket_configuration_flags;
    DART_FIELD uint32_t socket_receive_buffer_size;
    DART_FIELD uint32_t socket_send_buffer_size;
    DART_FIELD uint32_t socket_receive_low_at;
    DART_FIELD uint32_t socket_send_low_at;
    DART_FIELD uint16_t ip_ttl;
    DART_FIELD uint32_t tcp_keep_alive_idle;
    DART_FIELD uint32_t tcp_keep_alive_max_count;
    DART_FIELD uint32_t tcp_keep_alive_individual_count;
    DART_FIELD uint32_t tcp_max_segment_size;
    DART_FIELD uint16_t tcp_syn_count;
    DART_FIELD struct ip_mreqn* ip_multicast_interface;
    DART_FIELD uint32_t ip_multicast_ttl;
};

DART_STRUCTURE struct transport_server
{
    DART_FIELD int32_t fd;
    DART_FIELD DART_SUBSTITUTE(int16_t) transport_socket_family_t family;
    DART_FIELD struct sockaddr_in* inet_server_address;
    DART_FIELD struct sockaddr_un* unix_server_address;
    DART_FIELD DART_SUBSTITUTE(int32_t) __socklen_t server_address_length;
};

DART_LEAF_FUNCTION int32_t transport_server_initialize_tcp(struct transport_server* server,
                                                           struct transport_server_configuration* configuration,
                                                           const char* ip,
                                                           int32_t port);
DART_LEAF_FUNCTION int32_t transport_server_initialize_udp(struct transport_server* server, struct transport_server_configuration* configuration, const char* ip, int32_t port);
DART_LEAF_FUNCTION int32_t transport_server_initialize_unix_stream(struct transport_server* server,
                                                                   struct transport_server_configuration* configuration,
                                                                   const char* path);
DART_LEAF_FUNCTION void transport_server_destroy(struct transport_server* server);

#if defined(__cplusplus)
}
#endif

#endif
