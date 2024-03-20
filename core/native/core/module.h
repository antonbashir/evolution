#ifndef CORE_CORE_H
#define CORE_CORE_H

#include <context/context.h>
#include <system/library.h>

#if defined(__cplusplus)
extern "C"
{
#endif

#define MODULE_SOURCE

#define module_name core
DART_STRUCTURE struct core_module_configuration
{
    DART_FIELD bool silent;
    DART_FIELD uint8_t print_level;
};
#define module_configuration struct core_module_configuration
DART_STRUCTURE struct core_module
{
    DART_FIELD const char* name;
    DART_FIELD struct core_module_configuration configuration;
    DART_FIELD struct system_library* library;
};
#define module_structure struct core_module
#include <modules/module.h>
DART_LEAF_FUNCTION struct core_module* core_module_create(struct core_module_configuration* configuration);
DART_LEAF_FUNCTION void core_module_destroy(struct core_module* module);

#if defined(__cplusplus)
}
#endif

#endif