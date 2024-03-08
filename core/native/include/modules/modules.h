#ifndef CORE_MODULES_MODULES_H
#define CORE_MODULES_MODULES_H

#include <common/factory.h>
#include <system/types.h>

#define MODULE_SOURCE

#define module_id 1
#define module_name core
#include "module.h"
#define core_new(type) new (core_module_name, type)

#define module_id 2
#define module_name memory
#include "module.h"
#define memory_new(type) new (memory_module_name, type)

#define module_id 3
#define module_name executor
#include "module.h"
#define executor_new(type) new (executor_module_name, type)

#define module_id 4
#define module_name storage
#include "module.h"
#define storage_new(type) new (storage_module_name, type)

#define module_id 5
#define module_name transport
#include "module.h"
#define transport_new(type) new (transport_module_name, type)

#if defined(__cplusplus)
extern "C"
{
#endif

#if defined(__cplusplus)
}
#endif

#endif