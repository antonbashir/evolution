#ifndef TRANSPORT_CONFIGURATION_H
#define TRANSPORT_CONFIGURATION_H

#include <common/common.h>
#include <executor/configuration.h>
#include <memory/configuration.h>
#include <system/library.h>

#if defined(__cplusplus)
extern "C"
{
#endif

DART_STRUCTURE struct transport_configuration
{
    DART_FIELD uint64_t timeout_checker_period_milliseconds;
};

#if defined(__cplusplus)
}
#endif

#endif
