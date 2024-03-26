#ifndef STORAGE_CONFIGURATION_H
#define STORAGE_CONFIGURATION_H

#include <common/common.h>
#include <system/library.h>

#if defined(__cplusplus)
extern "C"
{
#endif

DART_STRUCTURE struct storage_executor_configuration
{
    DART_FIELD size_t ring_size;
    DART_FIELD size_t ring_flags;
};

DART_STRUCTURE struct storage_launch_configuration
{
    DART_FIELD const char* username;
    DART_FIELD const char* password;
};

DART_STRUCTURE struct storage_boot_configuration
{
    DART_FIELD const char* initial_script;
    DART_FIELD const char* binary_path;
    DART_FIELD uint64_t initialization_timeout_seconds;
    DART_FIELD uint64_t shutdown_timeout_seconds;
    DART_FIELD struct storage_launch_configuration launch_configuration;
};

#if defined(__cplusplus)
}
#endif

#endif
