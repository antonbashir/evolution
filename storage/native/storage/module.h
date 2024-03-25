#ifndef STORAGE_MODULE_H
#define STORAGE_MODULE_H

#include <common/common.h>
#include <system/library.h>
#include "configuration.h"

#if defined(__cplusplus)
extern "C"
{
#endif

#define MODULE_SOURCE

#define module_name storage
DART_STRUCTURE struct storage_module_configuration
{
    DART_FIELD uint8_t library_package_mode;
    DART_FIELD struct storage_configuration storage_instance_configuration;
    DART_FIELD bool activate_reloader;
    DART_FIELD const char* script;
};
#define module_configuration struct storage_module_configuration
DART_STRUCTURE struct storage_module
{
    DART_FIELD const char* name;
    DART_FIELD struct storage_module_configuration configuration;
    DART_FIELD struct system_library* library;
};
#define module_structure struct storage_module
#include <modules/module.h>
DART_LEAF_FUNCTION struct storage_module* storage_module_create(struct storage_module_configuration* configuration);
DART_LEAF_FUNCTION void storage_module_destroy(struct storage_module* module);

#if defined(__cplusplus)
}
#endif

#endif
