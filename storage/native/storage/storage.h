#ifndef STORAGE_STORAGE_H
#define STORAGE_STORAGE_H

#include <system/library.h>
#include "box.h"
#include "configuration.h"

#if defined(__cplusplus)
extern "C"
{
#endif

struct error;

DART_LEAF_FUNCTION struct storage_box* storage_get_box();
DART_LEAF_FUNCTION bool storage_initialize();
DART_LEAF_FUNCTION bool storage_initialized();
DART_LEAF_FUNCTION const char* storage_status();
DART_LEAF_FUNCTION int32_t storage_is_read_only();
DART_LEAF_FUNCTION const char* storage_initialization_error();
DART_LEAF_FUNCTION const char* storage_shutdown_error();
DART_LEAF_FUNCTION bool storage_shutdown();

void storage_raiser(struct error* error);
void storage_say(int level, const char* filename, int line, const char* message);
struct event* storage_convert_error(struct error* error, int32_t level);
struct event* storage_get_diagnostic_event();
struct event* storage_create_error(const char* message);

#define storage_create_empty_error() storage_create_error("");

#if defined(__cplusplus)
}
#endif

#endif
