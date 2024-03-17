#ifndef EXECUTOR_MODULE_H
#define EXECUTOR_MODULE_H

#include <common/common.h>
#include <system/library.h>
#include "configuration.h"

#if defined(__cplusplus)
extern "C"
{
#endif

#define MODULE_SOURCE

#define module_name executor
DART_STRUCTURE struct executor_module_configuration
{
    DART_FIELD struct executor_scheduler_configuration scheduler_configuration;
};
#define module_configuration struct executor_module_configuration
DART_STRUCTURE struct executor_module
{
    DART_FIELD const char* name;
    DART_FIELD struct executor_module_configuration configuration;
    DART_FIELD struct executor_scheduler* scheduler;
    DART_FIELD DART_SUBSTITUTE(uint32_t) atomic_uint32_t executors;
};
#define module_structure struct executor_module
#include <modules/module.h>
DART_LEAF_FUNCTION struct executor_module* executor_module_create(struct executor_module_configuration* configuration);
DART_LEAF_FUNCTION void executor_module_destroy(struct executor_module* module);
DART_INLINE_LEAF_FUNCTION uint32_t executor_next_id(struct executor_module* module)
{
    atomic_fetch_add(&module->executors, 1);
    return module->executors;
}

#if defined(__cplusplus)
}
#endif

#endif
