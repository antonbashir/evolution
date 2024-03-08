#include "memory_state.h"
#include <memory.h>
#include <memory_io_buffers.h>
#include <memory_static_buffers.h>
#include <system/system.h>

int32_t memory_state_create(struct memory_state* memory, struct memory_configuration* configuration)
{
    memory->memory_instance = calloc(1, sizeof(struct memory));
    if (!memory->memory_instance)
    {
        return -ENOMEM;
    }


    memory->static_buffers = calloc(1, sizeof(struct memory_static_buffers));
    if (!memory->static_buffers)
    {
        return -ENOMEM;
    }

    memory->io_buffers = calloc(1, sizeof(struct memory_io_buffers));
    if (!memory->io_buffers)
    {
        return -ENOMEM;
    }

    if (memory_create(memory->memory_instance, configuration->quota_size, configuration->preallocation_size, configuration->slab_size))
    {
        return -ENOMEM;
    }
    if (memory_static_buffers_create(memory->static_buffers, configuration->static_buffers_capacity, configuration->static_buffer_size))
    {
        return -ENOMEM;
    }
    if (memory_io_buffers_create(memory->io_buffers, memory->memory_instance))
    {
        return -ENOMEM;
    }

    return 0;
}

void memory_state_destroy(struct memory_state* memory)
{
    memory_static_buffers_destroy(memory->static_buffers);
    memory_io_buffers_destroy(memory->io_buffers);
    memory_destroy(memory->memory_instance);
    free(memory->static_buffers);
    free(memory->io_buffers);
    free(memory->memory_instance);
}
