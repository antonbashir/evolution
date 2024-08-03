#include "file.h"
#include "constants.h"

int32_t transport_file_open(const char* path, int32_t mode, bool truncate, bool create)
{
    int32_t options = 0;
    if (mode == TRANSPORT_READ_ONLY)
    {
        options |= O_RDONLY;
    }
    if (mode == TRANSPORT_WRITE_ONLY)
    {
        options |= O_WRONLY;
    }
    if (mode == TRANSPORT_READ_WRITE)
    {
        options |= O_RDWR;
    }
    if (mode == TRANSPORT_WRITE_ONLY_APPEND)
    {
        options |= O_WRONLY | O_APPEND;
    }
    if (mode == TRANSPORT_READ_WRITE_APPEND)
    {
        options |= O_RDWR | O_APPEND;
    }
    if (truncate)
    {
        options |= O_TRUNC;
    }
    if (create)
    {
        options |= O_CREAT;
    }
    return open(path, options, 0666);
}