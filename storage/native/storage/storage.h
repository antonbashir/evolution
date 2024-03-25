#ifndef STORAGE_STORAGE_H
#define STORAGE_STORAGE_H

#include <system/library.h>
#include "box.h"
#include "configuration.h"

#if defined(__cplusplus)
extern "C"
{
#endif

DART_LEAF_FUNCTION bool storage_initialize(struct storage_configuration* configuration, struct storage_box* box);
DART_LEAF_FUNCTION bool storage_initialized();
DART_LEAF_FUNCTION const char* storage_status();
DART_LEAF_FUNCTION int32_t storage_is_read_only();
DART_LEAF_FUNCTION const char* storage_initialization_error();
DART_LEAF_FUNCTION const char* storage_shutdown_error();
DART_LEAF_FUNCTION bool storage_shutdown();

#if defined(__cplusplus)
}
#endif

#endif
