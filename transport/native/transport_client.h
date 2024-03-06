#ifndef TRANSPORT_CLIENT_H
#define TRANSPORT_CLIENT_H

#include <stdbool.h>
#include <stdint.h>
#include "transport_constants.h"

#if defined(__cplusplus)
extern "C"
{
#endif

struct sockaddr_in;
struct sockaddr_un;

struct transport_client_configuration
{
    uint64_t socket_configuration_flags;
    uint32_t socket_receive_buffer_size;
    uint32_t socket_send_buffer_size;
    uint32_t socket_receive_low_at;
    uint32_t socket_send_low_at;
    uint16_t ip_ttl;
    uint32_t tcp_keep_alive_idle;
    uint32_t tcp_keep_alive_max_count;
    uint32_t tcp_keep_alive_individual_count;
    uint32_t tcp_max_segment_size;
    uint16_t tcp_syn_count;
    struct ip_mreqn* ip_multicast_interface;
    uint32_t ip_multicast_ttl;
};

struct transport_client
{
    int32_t fd;
    struct sockaddr_in* inet_destination_address;
    struct sockaddr_in* inet_source_address;
    struct sockaddr_un* unix_destination_address;
    __socklen_t client_address_length;
    transport_socket_family_t family;
};

int32_t transport_client_initialize_tcp(struct transport_client* client,
    struct transport_client_configuration* configuration,
    const char* ip,
    int32_t port);

int32_t transport_client_initialize_udp(struct transport_client* client,
    struct transport_client_configuration* configuration,
    const char* destination_ip,
    int32_t destination_port,
    const char* source_ip,
    int32_t source_port);

int32_t transport_client_initialize_unix_stream(struct transport_client* client,
    struct transport_client_configuration* configuration,
    const char* path);

struct sockaddr* transport_client_get_destination_address(struct transport_client* client);

void transport_client_destroy(struct transport_client* client);
#if defined(__cplusplus)
}
#endif

#endif
