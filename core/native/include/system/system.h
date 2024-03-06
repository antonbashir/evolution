#ifndef CORE_SYSTEM_SYSTEM_H
#define CORE_SYSTEM_SYSTEM_H

#include "common/common.h"
#include "library.h"
#include "network.h"
#include "socket.h"
#include "threading.h"
#include "time.h"
#include "types.h"

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