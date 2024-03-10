#include "module.h"
#include <system/library.h>
#include "io_buffers.h"
#include "memory.h"
#include "static_buffers.h"

struct memory_module_state* memory_module_state_create(struct memory_configuration* configuration)
{
    struct memory_module_state* state = memory_module_new(sizeof(struct memory_module_state));
    if (state == NULL)
    {
        memory_module_delete(state);
        return NULL;
    }

    state->memory_instance = memory_create(configuration->quota_size, configuration->preallocation_size, configuration->slab_size);
    if (state->memory_instance == NULL)
    {
        memory_module_delete(state);
        return NULL;
    }

    state->static_buffers = memory_static_buffers_create(configuration->static_buffers_capacity, configuration->static_buffer_size);
    if (state->static_buffers == NULL)
    {
        memory_module_delete(state);
        return NULL;
    }

    state->io_buffers = memory_module_new(sizeof(struct memory_io_buffers));
    if (state->io_buffers == NULL)
    {
        memory_module_delete(state);
        return NULL;
    }

    state->io_buffers = memory_io_buffers_create(state->memory_instance);
    if (state->io_buffers == NULL)
    {
        memory_module_delete(state);
        return NULL;
    }

    return state;
}

void memory_module_state_destroy(struct memory_module_state* state)
{
    memory_static_buffers_destroy(state->static_buffers);
    memory_io_buffers_destroy(state->io_buffers);
    memory_destroy(state->memory_instance);
    memory_module_delete(state->static_buffers);
    memory_module_delete(state->io_buffers);
    memory_module_delete(state->memory_instance);
    memory_module_delete(state);
}


extern uint8_t* memory_output_buffer_finalize_reserve(struct memory_output_buffer* buffer, size_t delta, size_t size);