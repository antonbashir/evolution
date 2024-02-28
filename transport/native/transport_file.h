#ifndef TRANSPORT_FILE_H
#define TRANSPORT_FILE_H

#include <stdbool.h>

#if defined(__cplusplus)
extern "C"
{
#endif
    int transport_file_open(const char* path, int mode, bool truncate, bool create);
#if defined(__cplusplus)
}
#endif

#endif
