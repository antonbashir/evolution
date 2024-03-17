#include "client.h"
#include "constants.h"
#include "module.h"
#include "socket.h"

struct transport_client* transport_client_initialize_tcp(struct transport_client_configuration* configuration, const char* ip, int32_t port)
{
    struct transport_client* client = transport_module_new(sizeof(struct transport_client));
    client->family = INET;
    client->inet_destination_address = transport_module_new(sizeof(struct sockaddr_in));
    client->inet_destination_address->sin_addr.s_addr = inet_addr(ip);
    client->inet_destination_address->sin_port = htons(port);
    client->inet_destination_address->sin_family = AF_INET;
    client->client_address_length = sizeof(*client->inet_destination_address);
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
        client->initialization_error = result;
        return client;
    }
    client->fd = result;
    return client;
}

struct transport_client* transport_client_initialize_udp(struct transport_client_configuration* configuration, const char* destination_ip, int32_t destination_port, const char* source_ip, int32_t source_port)
{
    struct transport_client* client = transport_module_new(sizeof(struct transport_client));
    client->family = INET;
    client->client_address_length = sizeof(struct sockaddr_in);

    client->inet_destination_address = transport_module_new(sizeof(struct sockaddr_in));
    client->inet_destination_address->sin_addr.s_addr = inet_addr(destination_ip);
    client->inet_destination_address->sin_port = htons(destination_port);
    client->inet_destination_address->sin_family = AF_INET;

    client->inet_source_address = transport_module_new(sizeof(struct sockaddr_in));
    client->inet_source_address->sin_addr.s_addr = inet_addr(source_ip);
    client->inet_source_address->sin_port = htons(source_port);
    client->inet_source_address->sin_family = AF_INET;
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
        client->initialization_error = result;
        return client;
    }
    client->fd = result;
    result = bind(client->fd, (struct sockaddr*)client->inet_source_address, client->client_address_length);
    if (result < 0)
    {
        client->initialization_error = result;
        return client;
    }

    return client;
}

struct transport_client* transport_client_initialize_unix_stream(struct transport_client_configuration* configuration, const char* path)
{
    struct transport_client* client = transport_module_new(sizeof(struct transport_client));
    client->family = UNIX;
    client->unix_destination_address = transport_module_new(sizeof(struct sockaddr_un));
    client->unix_destination_address->sun_family = AF_UNIX;
    strcpy(client->unix_destination_address->sun_path, path);
    client->client_address_length = sizeof(*client->unix_destination_address);
    int64_t result = transport_socket_create_unix_stream(
        configuration->socket_configuration_flags,
        configuration->socket_receive_buffer_size,
        configuration->socket_send_buffer_size,
        configuration->socket_receive_low_at,
        configuration->socket_send_low_at);
    if (result < 0)
    {
        client->initialization_error = result;
        return client;
    }
    client->fd = result;
    return client;
}

void transport_client_destroy(struct transport_client* client)
{
    if (client->family == INET)
    {
        if (client->inet_destination_address)
        {
            transport_module_delete(client->inet_destination_address);
        }

        if (client->inet_source_address)
        {
            transport_module_delete(client->inet_source_address);
        }
    }
    if (client->family == UNIX)
    {
        unlink(client->unix_destination_address->sun_path);
        transport_module_delete(client->unix_destination_address);
    }
    transport_module_delete(client);
}