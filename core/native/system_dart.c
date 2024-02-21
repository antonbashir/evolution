#include <string.h>
#include <sys/socket.h>
#include <unistd.h>

void system_dart_shutdown_descriptor(int fd)
{
    shutdown(fd, SHUT_RDWR);
    close(fd);
}

const char* system_dart_error_to_string(int error)
{
    return strerror(-error);
}
