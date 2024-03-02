#include <sys/socket.h>
#include <unistd.h>

void system_dart_shutdown_descriptor(int32_t fd)
{
    shutdown(fd, SHUT_RDWR);
    close(fd);
}
