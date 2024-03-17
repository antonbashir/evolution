#include "server.h"
#include "constants.h"
#include "socket.h"

int32_t transport_server_initialize_tcp(struct transport_server* server, struct transport_server_configuration* configuration, const char* ip, int32_t port)
{
    server->family = INET;
    server->inet_server_address = calloc(1, sizeof(struct sockaddr_in));
    server->inet_server_address->sin_addr.s_addr = inet_addr(ip);
    server->inet_server_address->sin_port = htons(port);
    server->inet_server_address->sin_family = AF_INET;
    server->server_address_length = sizeof(*server->inet_server_address);
    int64_t result = transport_socket_create_tcp(
        configuration->socket_configuration_flags,
        configuration->socket_receive_buffer_size,
        configuration->socket_send_buffer_size,
        configuration->socket_receive_low_at,
        configuration->socket_send_low_at,
        configuration->ip_ttl,
        configuration->tcp_keep_alive_idle,
        configuration->tcp_keep_alive_max_count,
        configuration->tcp_keep_alive_individual_count,
        configuration->tcp_max_segment_size,
        configuration->tcp_syn_count);
    if (result < 0)
    {
        return result;
    }
    server->fd = result;
    result = bind(server->fd, (struct sockaddr*)server->inet_server_address, server->server_address_length);
    if (result < 0)
    {
        return result;
    }
    result = listen(server->fd, configuration->socket_max_connections);
    if (result < 0)
    {
        return result;
    }
    return 0;
}

int32_t transport_server_initialize_udp(struct transport_server* server, struct transport_server_configuration* configuration, const char* ip, int32_t port)
{
    server->family = INET;
    server->inet_server_address = calloc(1, sizeof(struct sockaddr_in));
    server->inet_server_address->sin_addr.s_addr = inet_addr(ip);
    server->inet_server_address->sin_port = htons(port);
    server->inet_server_address->sin_family = AF_INET;
    server->server_address_length = sizeof(*server->inet_server_address);
    int64_t result = transport_socket_create_udp(
        configuration->socket_configuration_flags,
        configuration->socket_receive_buffer_size,
        configuration->socket_send_buffer_size,
        configuration->socket_receive_low_at,
        configuration->socket_send_low_at,
        configuration->ip_ttl,
        configuration->ip_multicast_interface,
        configuration->ip_multicast_ttl);
    if (result < 0)
    {
        return result;
    }
    server->fd = result;
    result = bind(server->fd, (struct sockaddr*)server->inet_server_address, server->server_address_length);
    if (result < 0)
    {
        return result;
    }
    return 0;
}

int32_t transport_server_initialize_unix_stream(struct transport_server* server, struct transport_server_configuration* configuration, const char* path)
{
    server->family = UNIX;
    server->unix_server_address = calloc(1, sizeof(struct sockaddr_un));
    server->unix_server_address->sun_family = AF_UNIX;
    strcpy(server->unix_server_address->sun_path, path);
    server->server_address_length = sizeof(*server->unix_server_address);
    int64_t result = transport_socket_create_unix_stream(
        configuration->socket_configuration_flags,
        configuration->socket_receive_buffer_size,
        configuration->socket_send_buffer_size,
        configuration->socket_receive_low_at,
        configuration->socket_send_low_at);
    if (result < 0)
    {
        return result;
    }
    server->fd = result;
    result = bind(server->fd, (struct sockaddr*)server->unix_server_address, server->server_address_length);
    if (result < 0)
    {
        return result;
    }
    result = listen(server->fd, configuration->socket_max_connections);
    if (result < 0)
    {
        return result;
    }
    return 0;
}

void transport_server_destroy(struct transport_server* server)
{
    if (server->family == INET)
    {
        free(server->inet_server_address);
    }
    if (server->family == UNIX)
    {
        unlink(server->unix_server_address->sun_path);
        free(server->unix_server_address);
    }
    free(server);
}