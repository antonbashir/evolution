#ifndef CORE_CORE_H
#define CORE_CORE_H

#include <context/context.h>
#include <system/library.h>

#define MODULE_SOURCE

#if defined(__cplusplus)
extern "C"
{
#endif

#define module_id 0
#define module_name core
struct core_module_configuration
{
    uint8_t print_level;
    const char* component;
};
#define module_configuration struct core_module_configuration
struct core_module
{
    uint32_t id;
    const char* name;
    struct core_module_configuration* configuration;
};
#define module_structure struct core_module
#include <modules/module.h>

#if defined(__cplusplus)
}
#endif

#endif