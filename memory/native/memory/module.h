#ifndef MEMORY_MODULE_H
#define MEMORY_MODULE_H

#include <common/common.h>
#include <system/library.h>
#include "configuration.h"

#if defined(__cplusplus)
extern "C"
{
#endif

#define MODULE_SOURCE

#define module_name memory
DART_STRUCTURE struct memory_module_configuration
{
    DART_FIELD uint8_t library_package_mode;
    DART_FIELD struct memory_configuration memory_instance_configuration;
};
#define module_configuration struct memory_module_configuration
DART_STRUCTURE struct memory_module
{
    DART_FIELD const char* name;
    DART_FIELD struct memory_module_configuration configuration;
    DART_FIELD struct system_library* library;
};
#define module_structure struct memory_module
#include <modules/module.h>
DART_LEAF_FUNCTION struct memory_module* memory_module_create(struct memory_module_configuration* configuration);
DART_LEAF_FUNCTION void memory_module_destroy(struct memory_module* module);

#if defined(__cplusplus)
}
#endif

#endif
