#ifndef CORE_SYSTEM_SYSTEM_H
#define CORE_SYSTEM_SYSTEM_H

#include "common/common.h"  // IWYU pragma: export
#include "library.h"        // IWYU pragma: export
#include "network.h"        // IWYU pragma: export
#include "socket.h"         // IWYU pragma: export
#include "threading.h"      // IWYU pragma: export
#include "time.h"           // IWYU pragma: export
#include "types.h"          // IWYU pragma: export

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