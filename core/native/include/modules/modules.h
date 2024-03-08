#ifndef CORE_MODULES_MODULES_H
#define CORE_MODULES_MODULES_H

#include <common/factory.h>
#include <system/types.h>

#define MODULE_SOURCE

#define module_id 1
#define module_name core
#include "module.h"
#define core_new(type) new (core_module_name, type)
#define core_allocate(count, size) allocate(core_module_name, count, size)
#define core_error_exit(code, message) error_exit(core_module_name, code, message)

#define module_id 2
#define module_name memory
#include "module.h"
#define memory_new(type) new (memory_module_name, type)
#define memory_allocate(count, size) allocate(memory_module_name, count, size)
#define memory_error_exit(code, message) error_exit(memory_module_name, code, message)

#define module_id 3
#define module_name executor
#include "module.h"
#define executor_new(type) new (executor_module_name, type)
#define executor_allocate(count, size) allocate(executor_module_name, count, size)
#define executor_error_exit(code, message) error_exit(executor_module_name, code, message)

#define module_id 4
#define module_name storage
#include "module.h"
#define storage_new(type) new (storage_module_name, type)
#define storage_allocate(count, size) allocate(storage_module_name, count, size)
#define storage_error_exit(code, message) error_exit(storage_module_name, code, message)

#define module_id 5
#define module_name transport
#include "module.h"
#define transport_new(type) new (transport_module_name, type)
#define transport_allocate(count, size) allocate(transport_module_name, count, size)
#define transport_error_exit(code, message) error_exit(transport_module_name, code, message)

#if defined(__cplusplus)
extern "C"
{
#endif

#if defined(__cplusplus)
}
#endif

#endif