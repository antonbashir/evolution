#ifndef MEMORY_STATE_MEMORY_STATE_H
#define MEMORY_STATE_MEMORY_STATE_H

#include <memory.h>
#include <memory_configuration.h>
#include <memory_io_buffers.h>
#include <memory_small_data.h>
#include <memory_static_buffers.h>
#include <system/types.h>

#if defined(__cplusplus)
extern "C"
{
#endif

struct memory_state
{
    // FFI PUBLIC
    struct memory_static_buffers* static_buffers;
    struct memory_io_buffers* io_buffers;
    struct memory_small_data* small_data;
    struct memory* memory_instance;
};

int32_t memory_state_create(struct memory_state* memory, struct memory_configuration* configuration);
void memory_state_destroy(struct memory_state* memory);

#if defined(__cplusplus)
}
#endif

#endif