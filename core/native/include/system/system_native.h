#ifndef SYSTEM_NATIVE_H
#define SYSTEM_NATIVE_H

#include <string.h>
#include <sys/socket.h>
#include <unistd.h>

#if defined(__cplusplus)
extern "C"
{
#endif
    static inline const char* system_dart_error_to_string(int32_t error)
    {
        return strerror(-error);
    }

    static inline void system_dart_shutdown_descriptor(int32_t fd)
    {
        shutdown(fd, SHUT_RDWR);
        close(fd);
    }
#if defined(__cplusplus)
}
#endif

#endif