#ifndef TRANSPORT_FILE_H
#define TRANSPORT_FILE_H

#include <stdbool.h>
#include <stdint.h>

#if defined(__cplusplus)
extern "C"
{
#endif

int32_t transport_file_open(const char* path, int32_t mode, bool truncate, bool create);

#if defined(__cplusplus)
}
#endif

#endif
