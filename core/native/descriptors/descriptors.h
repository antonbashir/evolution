#ifndef CORE_DESCRIPTORS_DESCRIPTORS_H
#define CORE_DESCRIPTORS_DESCRIPTORS_H

#include <common/common.h>
#include <system/library.h>

#if defined(__cplusplus)
extern "C"
{
#endif

FORCEINLINE void system_shutdown_descriptor(int32_t fd)
{
    shutdown(fd, SHUT_RDWR);
    close(fd);
}

#if defined(__cplusplus)
}
#endif

#endif