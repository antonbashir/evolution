#include "memory_state.h"
#include <buffers/memory_io_buffers.h>
#include <buffers/memory_static_buffers.h>
#include <memory/memory.h>
#include <system/system.h>

int32_t memory_state_create(struct memory_state* state, struct memory_configuration* configuration)
{
    state->memory_instance = memory_module_new(sizeof(struct memory));
    if (state->memory_instance == NULL)
    {
        return -ENOMEM;
    }
    if (memory_create(state->memory_instance, configuration->quota_size, configuration->preallocation_size, configuration->slab_size))
    {
        return -ENOMEM;
    }

    state->static_buffers = memory_module_new(sizeof(struct memory_static_buffers));
    if (state->static_buffers == NULL)
    {
        return -ENOMEM;
    }

    state->static_buffers = memory_static_buffers_create(configuration->static_buffers_capacity, configuration->static_buffer_size);
    if (state->static_buffers != NULL)
    {
        return -ENOMEM;
    }

    state->io_buffers = memory_module_new(sizeof(struct memory_io_buffers));
    if (!state->io_buffers)
    {
        return -ENOMEM;
    }

    state->io_buffers = memory_io_buffers_create(state->memory_instance);
    if (state->io_buffers != NULL)
    {
        return -ENOMEM;
    }

    return 0;
}

void memory_state_destroy(struct memory_state* state)
{
    memory_static_buffers_destroy(state->static_buffers);
    memory_io_buffers_destroy(state->io_buffers);
    memory_destroy(state->memory_instance);
    free(state->static_buffers);
    free(state->io_buffers);
    free(state->memory_instance);
}
