#ifndef MEMORY_CONFIGURATION_H
#define MEMORY_CONFIGURATION_H

#include <system/library.h>

#if defined(__cplusplus)
extern "C"
{
#endif

struct memory_configuration
{
    size_t quota_size;
    size_t preallocation_size;
    size_t slab_size;
    size_t static_buffers_capacity;
    size_t static_buffer_size;
};

#if defined(__cplusplus)
}
#endif

#endif
