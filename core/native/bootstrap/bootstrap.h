#ifndef CORE_BOOTSTRAP_H
#define CORE_BOOTSTRAP_H

#include <common/common.h>
#include <system/library.h>

#if defined(__cplusplus)
extern "C"
{
#endif

DART_STRUCTURE struct bootstrap_configuration
{
    DART_FIELD bool silent;
    DART_FIELD uint8_t print_level;
};

DART_LEAF_FUNCTION void bootstrap(struct bootstrap_configuration* configuration);

#if defined(__cplusplus)
}
#endif

#endif