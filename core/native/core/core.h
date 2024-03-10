#ifndef CORE_CORE_H
#define CORE_CORE_H

#include <system/library.h>

#if defined(__cplusplus)
extern "C"
{
#endif

struct core_module_configuration
{
    uint8_t print_level;  // Dart
};

void core_initialize(struct core_module_configuration* configuration);

#if defined(__cplusplus)
}
#endif

#endif