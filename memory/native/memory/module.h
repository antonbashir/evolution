#ifndef MEMORY_MODULE_H
#define MEMORY_MODULE_H

#include <common/common.h>
#include <system/library.h>
#include "configuration.h"

#if defined(__cplusplus)
extern "C"
{
#endif

#define module_id 1
#define module_name memory
struct memory_module_configuration
{
};
#define module_configuration struct memory_module_configuration
struct memory_module
{
    uint32_t id;
    const char* name;
    struct memory_module_configuration* configuration;
};
#define module_structure struct memory_module
#include <modules/module.h>

struct memory_module_state
{
    struct memory_static_buffers* static_buffers;
    struct memory_io_buffers* io_buffers;
    struct memory* memory_instance;
};

struct memory_module_state* memory_module_state_create(struct memory_configuration* configuration);
void memory_module_state_destroy(struct memory_module_state* state);

#if defined(__cplusplus)
}
#endif

#endif
