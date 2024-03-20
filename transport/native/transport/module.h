#ifndef TRANSPORT_MODULE_H
#define TRANSPORT_MODULE_H

#include <common/common.h>
#include <system/library.h>
#include "configuration.h"

#if defined(__cplusplus)
extern "C"
{
#endif

#define MODULE_SOURCE

#define module_name transport
DART_STRUCTURE struct transport_module_configuration
{
    DART_FIELD struct executor_configuration default_executor_configuration;
};
#define module_configuration struct transport_module_configuration
DART_STRUCTURE struct transport_module
{
    DART_FIELD const char* name;
    DART_FIELD struct transport_module_configuration configuration;
    DART_FIELD struct system_library* library;
};
#define module_structure struct transport_module
#include <modules/module.h>
DART_LEAF_FUNCTION struct transport_module* transport_module_create(struct transport_module_configuration* configuration);
DART_LEAF_FUNCTION void transport_module_destroy(struct transport_module* module);
DART_STRUCTURE struct transport_module_state
{
};

#if defined(__cplusplus)
}
#endif

#endif
