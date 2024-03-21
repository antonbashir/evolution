#ifndef COMMON_EVENTS_EVENT_H
#define COMMON_EVENTS_EVENT_H

#include <common/common.h>
#include <stacktrace/stacktrace.h>
#include <strings/format.h>
#include <system/library.h>
#include <time/time.h>
#include "field.h"

#if defined(__cplusplus)
extern "C"
{
#endif

DART_STRUCTURE struct event
{
    const char* raised_module_name;
    struct event_field_structure** fields;
    const char* function;
    const char* file;
    size_t fields_count;
    uint32_t line;
    uint8_t level;
    struct timespec timestamp;
};

struct event* event_create(uint8_t level, const char* function, const char* file, uint32_t line);
struct event* event_build(uint8_t level, const char* function, const char* file, uint32_t line, size_t fields, ...);
void event_setup(struct event* event, const char* raised_module_name);
void event_destroy(struct event* event);

static FORCEINLINE struct event_field_structure* event_find_field(struct event* event, const char* name)
{
    struct event_field_structure* field = NULL;
    for (int i = 0; i < event->fields_count; ++i)
    {
        field = event->fields[i];
        if (strcmp(name, field->name) == 0)
            break;
        field = NULL;
    }
    return field;
}

DART_LEAF_FUNCTION void event_set_boolean(struct event* event, const char* name, bool value);
DART_LEAF_FUNCTION void event_set_signed(struct event* event, const char* name, int64_t value);
DART_LEAF_FUNCTION void event_set_unsigned(struct event* event, const char* name, uint64_t value);
DART_LEAF_FUNCTION void event_set_double(struct event* event, const char* name, double value);
DART_LEAF_FUNCTION void event_set_string(struct event* event, const char* name, const char* value);
DART_LEAF_FUNCTION void event_set_address(struct event* event, const char* name, void* value);
DART_LEAF_FUNCTION void event_set_character(struct event* event, const char* name, char value);

DART_LEAF_FUNCTION bool event_has_field(struct event* event, const char* name);
DART_LEAF_FUNCTION char event_get_character(struct event* event, const char* name);
DART_LEAF_FUNCTION void* event_get_address(struct event* event, const char* name);
DART_LEAF_FUNCTION bool event_get_boolean(struct event* event, const char* name);
DART_LEAF_FUNCTION int64_t event_get_signed(struct event* event, const char* name);
DART_LEAF_FUNCTION uint64_t event_get_unsigned(struct event* event, const char* name);
DART_LEAF_FUNCTION double event_get_double(struct event* event, const char* name);
DART_LEAF_FUNCTION const char* event_get_string(struct event* event, const char* name);

DART_LEAF_FUNCTION bool event_field_is_signed(struct event* event, const char* name);
DART_LEAF_FUNCTION bool event_field_is_unsigned(struct event* event, const char* name);
DART_LEAF_FUNCTION const char* event_get_module(struct event* event);
DART_LEAF_FUNCTION uint8_t event_get_level(struct event* event);

DART_LEAF_FUNCTION const char* event_format(struct event* event);

#if defined(__cplusplus)
}
#endif

#endif