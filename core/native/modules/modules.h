#ifndef CORE_MODULES_MODULES_H
#define CORE_MODULES_MODULES_H

#define MODULE_SOURCE

#define module_id 1
#define module_name core
#include "module.h"

#define module_id 2
#define module_name memory
#include "module.h"

#define module_id 3
#define module_name executor
#include "module.h"

#define module_id 4
#define module_name storage
#include "module.h"

#define module_id 5
#define module_name transport
#include "module.h"

#if defined(__cplusplus)
extern "C"
{
#endif

#if defined(__cplusplus)
}
#endif

#endif