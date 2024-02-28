#ifndef TRANSPORT_SERVER_H
#define TRANSPORT_SERVER_H

#include <stdbool.h>
#include <stdint.h>
#include "transport_constants.h"

#if defined(__cplusplus)
extern "C"
{
#endif
    struct ip_mreqn;
    struct sockaddr_in;
    struct sockaddr_un;

    struct transport_server_configuration
    {
        int32_t socket_max_connections;
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

    struct transport_server
    {
        int fd;
        transport_socket_family_t family;
        struct sockaddr_in* inet_server_address;
        struct sockaddr_un* unix_server_address;
        __socklen_t server_address_length;
    };

    int transport_server_initialize_tcp(struct transport_server* server,
                                        struct transport_server_configuration* configuration,
                                        const char* ip,
                                        int32_t port);
    int transport_server_initialize_udp(struct transport_server* server, struct transport_server_configuration* configuration,
                                        const char* ip,
                                        int32_t port);
    int transport_server_initialize_unix_stream(struct transport_server* server,
                                                struct transport_server_configuration* configuration,
                                                const char* path);
    void transport_server_destroy(struct transport_server* server);

#if defined(__cplusplus)
}
#endif

#endif
