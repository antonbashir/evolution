#ifndef MEMORY_CONFIGURATION_H
#define MEMORY_CONFIGURATION_H

#include <system/types.h>

#if defined(__cplusplus)
extern "C"
{
#endif

struct memory_configuration
{
    size_t quota_size;               // Dart
    size_t preallocation_size;       // Dart
    size_t slab_size;                // Dart
    size_t static_buffers_capacity;  // Dart
    size_t static_buffer_size;       // Dart
};

#if defined(__cplusplus)
}
#endif

#endif
