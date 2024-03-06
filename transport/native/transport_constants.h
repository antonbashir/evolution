#ifndef TRANSPORT_CONSTANTS_H
#define TRANSPORT_CONSTANTS_H

#if defined(__cplusplus)
extern "C"
{
#endif

#define TRANSPORT_EVENT_READ ((uint16_t)1 << 0)
#define TRANSPORT_EVENT_WRITE ((uint16_t)1 << 1)
#define TRANSPORT_EVENT_RECEIVE_MESSAGE ((uint16_t)1 << 2)
#define TRANSPORT_EVENT_SEND_MESSAGE ((uint16_t)1 << 3)
#define TRANSPORT_EVENT_ACCEPT ((uint16_t)1 << 4)
#define TRANSPORT_EVENT_CONNECT ((uint16_t)1 << 5)
#define TRANSPORT_EVENT_CLIENT ((uint16_t)1 << 6)
#define TRANSPORT_EVENT_FILE ((uint16_t)1 << 7)
#define TRANSPORT_EVENT_SERVER ((uint16_t)1 << 8)

#define TRANSPORT_READ_ONLY (1 << 0)
#define TRANSPORT_WRITE_ONLY (1 << 1)
#define TRANSPORT_READ_WRITE (1 << 2)
#define TRANSPORT_WRITE_ONLY_APPEND (1 << 3)
#define TRANSPORT_READ_WRITE_APPEND (1 << 4)

#define TRANSPORT_BUFFER_USED -1
#define TRANSPORT_TIMEOUT_INFINITY -1

#define TRANSPORT_SOCKET_OPTION_SOCKET_NONBLOCK ((uint64_t)1 << 1)
#define TRANSPORT_SOCKET_OPTION_SOCKET_CLOCEXEC ((uint64_t)1 << 2)
#define TRANSPORT_SOCKET_OPTION_SOCKET_REUSEADDR ((uint64_t)1 << 3)
#define TRANSPORT_SOCKET_OPTION_SOCKET_REUSEPORT ((uint64_t)1 << 4)
#define TRANSPORT_SOCKET_OPTION_SOCKET_RCVBUF ((uint64_t)1 << 5)
#define TRANSPORT_SOCKET_OPTION_SOCKET_SNDBUF ((uint64_t)1 << 6)
#define TRANSPORT_SOCKET_OPTION_SOCKET_BROADCAST ((uint64_t)1 << 7)
#define TRANSPORT_SOCKET_OPTION_SOCKET_KEEPALIVE ((uint64_t)1 << 8)
#define TRANSPORT_SOCKET_OPTION_SOCKET_RCVLOWAT ((uint64_t)1 << 9)
#define TRANSPORT_SOCKET_OPTION_SOCKET_SNDLOWAT ((uint64_t)1 << 10)
#define TRANSPORT_SOCKET_OPTION_IP_TTL ((uint64_t)1 << 11)
#define TRANSPORT_SOCKET_OPTION_IP_ADD_MEMBERSHIP ((uint64_t)1 << 12)
#define TRANSPORT_SOCKET_OPTION_IP_ADD_SOURCE_MEMBERSHIP ((uint64_t)1 << 13)
#define TRANSPORT_SOCKET_OPTION_IP_DROP_MEMBERSHIP ((uint64_t)1 << 14)
#define TRANSPORT_SOCKET_OPTION_IP_DROP_SOURCE_MEMBERSHIP ((uint64_t)1 << 15)
#define TRANSPORT_SOCKET_OPTION_IP_FREEBIND ((uint64_t)1 << 16)
#define TRANSPORT_SOCKET_OPTION_IP_MULTICAST_ALL ((uint64_t)1 << 17)
#define TRANSPORT_SOCKET_OPTION_IP_MULTICAST_IF ((uint64_t)1 << 18)
#define TRANSPORT_SOCKET_OPTION_IP_MULTICAST_LOOP ((uint64_t)1 << 19)
#define TRANSPORT_SOCKET_OPTION_IP_MULTICAST_TTL ((uint64_t)1 << 20)
#define TRANSPORT_SOCKET_OPTION_TCP_QUICKACK ((uint64_t)1 << 21)
#define TRANSPORT_SOCKET_OPTION_TCP_DEFER_ACCEPT ((uint64_t)1 << 22)
#define TRANSPORT_SOCKET_OPTION_TCP_FASTOPEN ((uint64_t)1 << 23)
#define TRANSPORT_SOCKET_OPTION_TCP_KEEPIDLE ((uint64_t)1 << 24)
#define TRANSPORT_SOCKET_OPTION_TCP_KEEPCNT ((uint64_t)1 << 25)
#define TRANSPORT_SOCKET_OPTION_TCP_KEEPINTVL ((uint64_t)1 << 26)
#define TRANSPORT_SOCKET_OPTION_TCP_MAXSEG ((uint64_t)1 << 27)
#define TRANSPORT_SOCKET_OPTION_TCP_NODELAY ((uint64_t)1 << 28)
#define TRANSPORT_SOCKET_OPTION_TCP_SYNCNT ((uint64_t)1 << 29)

typedef enum transport_socket_family
{
    INET = 0,
    UNIX,
} transport_socket_family_t;

#if defined(__cplusplus)
}
#endif

#endif