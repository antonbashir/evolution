#ifndef MEMORY_STATE_MEMORY_STATE_H
#define MEMORY_STATE_MEMORY_STATE_H

#include <buffers/memory_io_buffers.h>
#include <buffers/memory_static_buffers.h>
#include <memory/memory.h>
#include <memory/memory_configuration.h>
#include <system/types.h>

#if defined(__cplusplus)
extern "C"
{
#endif

struct memory_state
{
    struct memory_static_buffers* static_buffers;  // Dart
    struct memory_io_buffers* io_buffers;          // Dart
    struct memory* memory_instance;                // Dart
};

int32_t memory_state_create(struct memory_state* memory, struct memory_configuration* configuration);
void memory_state_destroy(struct memory_state* memory);

#if defined(__cplusplus)
}
#endif

#endif