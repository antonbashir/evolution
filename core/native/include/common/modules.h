#ifndef CORE_COMMON_MODULES_H
#define CORE_COMMON_MODULES_H

#define CORE_MODULE 0
#define MEMORY_MODULE 1
#define MEDIATOR_MODULE 2
#define TRANSPORT_MODULE 3
#define STORAGE_MODULE 4

#define CORE_MODULE_NAME "core"
#define MEMORY_MODULE_NAME "memory"
#define MEDIATOR_MODULE_NAME "mediator"
#define TRANSPORT_MODULE_NAME "transport"
#define STORAGE_MODULE_NAME "storage"

#include <system/types.h>
#if defined(__cplusplus)
extern "C"
{
#endif

static inline const char* module_to_string(uint32_t id)
{
    switch (id)
    {
        case CORE_MODULE:
            return CORE_MODULE_NAME;
        case MEMORY_MODULE:
            return MEMORY_MODULE_NAME;
        case MEDIATOR_MODULE:
            return MEDIATOR_MODULE_NAME;
        case TRANSPORT_MODULE:
            return TRANSPORT_MODULE_NAME;
        case STORAGE_MODULE:
            return STORAGE_MODULE_NAME;
    }
    return "unknown";
}

#if defined(__cplusplus)
}
#endif

#endif