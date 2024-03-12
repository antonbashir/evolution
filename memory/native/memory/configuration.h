#ifndef MEMORY_CONFIGURATION_H
#define MEMORY_CONFIGURATION_H

#include <system/library.h>
#include "common/common.h"

#if defined(__cplusplus)
extern "C"
{
#endif

DART_STRUCTURE struct memory_configuration
{
    DART_FIELD size_t quota_size;
    DART_FIELD size_t preallocation_size;
    DART_FIELD size_t slab_size;
    DART_FIELD size_t static_buffers_capacity;
    DART_FIELD size_t static_buffer_size;
};

#if defined(__cplusplus)
}
#endif

#endif
