#ifndef EXECUTOR_CONFIGURATION_H
#define EXECUTOR_CONFIGURATION_H

#include <common/common.h>
#include <system/library.h>

#if defined(__cplusplus)
extern "C"
{
#endif
DART_STRUCTURE struct executor_configuration
{
    DART_FIELD size_t ring_size;
    DART_FIELD uint32_t ring_flags;
};

DART_STRUCTURE struct executor_scheduler_configuration
{
    DART_FIELD size_t ring_size;
    DART_FIELD size_t ring_flags;
    DART_FIELD uint64_t initialization_timeout_seconds;
    DART_FIELD uint64_t shutdown_timeout_seconds;
};
#if defined(__cplusplus)
}
#endif

#endif
