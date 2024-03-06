#include "transport_client.h"
#include <arpa/inet.h>
#include <netinet/in.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <sys/time.h>
#include <sys/un.h>
#include <unistd.h>
#include "transport_constants.h"
#include "transport_socket.h"

int32_t transport_client_initialize_tcp(struct transport_client* client, struct transport_client_configuration* configuration, const char* ip, int32_t port)
{
    client->family = INET;
    client->inet_destination_address = calloc(1, sizeof(struct sockaddr_in));
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
        return result;
    }
    client->fd = result;
    return 0;
}

int32_t transport_client_initialize_udp(struct transport_client* client, struct transport_client_configuration* configuration, const char* destination_ip, int32_t destination_port, const char* source_ip, int32_t source_port)
{
    client->family = INET;
    client->client_address_length = sizeof(struct sockaddr_in);

    client->inet_destination_address = calloc(1, sizeof(struct sockaddr_in));
    client->inet_destination_address->sin_addr.s_addr = inet_addr(destination_ip);
    client->inet_destination_address->sin_port = htons(destination_port);
    client->inet_destination_address->sin_family = AF_INET;

    client->inet_source_address = calloc(1, sizeof(struct sockaddr_in));
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
        return result;
    }
    client->fd = result;
    result = bind(client->fd, (struct sockaddr*)client->inet_source_address, client->client_address_length);
    if (result < 0)
    {
        return result;
    }

    return 0;
}

int32_t transport_client_initialize_unix_stream(struct transport_client* client, struct transport_client_configuration* configuration, const char* path)
{
    client->family = UNIX;
    client->unix_destination_address = calloc(1, sizeof(struct sockaddr_un));
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
        return result;
    }
    client->fd = result;
    return 0;
}

struct sockaddr* transport_client_get_destination_address(struct transport_client* client)
{
    return client->family == INET ? (struct sockaddr*)client->inet_destination_address : (struct sockaddr*)client->unix_destination_address;
}

void transport_client_destroy(struct transport_client* client)
{
    if (client->family == INET)
    {
        if (client->inet_destination_address)
        {
            free(client->inet_destination_address);
        }

        if (client->inet_source_address)
        {
            free(client->inet_source_address);
        }
    }
    if (client->family == UNIX)
    {
        unlink(client->unix_destination_address->sun_path);
        free(client->unix_destination_address);
    }
    free(client);
}