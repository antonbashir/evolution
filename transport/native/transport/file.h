#ifndef TRANSPORT_FILE_H
#define TRANSPORT_FILE_H

#include <common/common.h>
#include <system/library.h>

#if defined(__cplusplus)
extern "C"
{
#endif

DART_LEAF_FUNCTION int32_t transport_file_open(const char* path, int32_t mode, bool truncate, bool create);

#if defined(__cplusplus)
}
#endif

#endif
