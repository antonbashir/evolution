#ifndef CORE_SYSTEM_SOCKET_H
#define CORE_SYSTEM_SOCKET_H

#include <common/common.h>
#include <sys/socket.h>
#include <system/types.h>

#if defined(__cplusplus)
extern "C"
{
#endif

extern FORCEINLINE void system_shutdown_descriptor(int32_t fd)
{
    shutdown(fd, SHUT_RDWR);
    close(fd);
}

#if defined(__cplusplus)
}
#endif

#endif