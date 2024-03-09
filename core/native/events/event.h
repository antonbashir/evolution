#ifndef COMMON_EVENTS_EVENT_H
#define COMMON_EVENTS_EVENT_H

#include <common/common.h>
#include <common/library.h>
#include <events/field.h>
#include <stacktrace/stacktrace.h>
#include <stdint.h>
#include <system/types.h>

#if defined(__cplusplus)
extern "C"
{
#endif

#define MODULE_EVENT_BUFFER 1024
#define MODULE_EVENT_FIELDS_MAXIMUM 128

#define MODULE_EVENT_LEVEL_TRACE 0
#define MODULE_EVENT_LEVEL_INFORMATION 1
#define MODULE_EVENT_LEVEL_WARNING 2
#define MODULE_EVENT_LEVEL_ERROR 3
#define MODULE_EVENT_LEVEL_PANIC 4

#define MODULE_EVENT_LEVEL_UNKNOWN_LABEL "(unknown)";
#define MODULE_EVENT_LEVEL_TRACE_LABEL "(trace)";
#define MODULE_EVENT_LEVEL_INFORMATION_LABEL "(information)";
#define MODULE_EVENT_LEVEL_WARNING_LABEL "(warning)";
#define MODULE_EVENT_LEVEL_ERROR_LABEL "(error)";
#define MODULE_EVENT_LEVEL_PANIC_LABEL "(panic)";

struct event
{
    const char* raised_module_name;
    struct event_field** fields;
    const char* function;
    const char* file;
    const char* message;
    size_t fields_count;
    uint32_t line;
    uint32_t raised_module_id;
    uint8_t level;
};

struct event* event_create(uint8_t type, const char* function, const char* file, uint32_t line, const char* message);
struct event* event_build(uint8_t type, const char* function, const char* file, uint32_t line, const char* message, size_t fields, ...);
void event_setup(struct event* event, uint32_t raised_module_id, const char* raised_module_name);
void event_destroy(struct event* event);
bool event_has_field(struct event* event, const char* name);
void event_set_boolean(struct event* event, const char* name, bool value);
void event_set_signed(struct event* event, const char* name, int64_t value);
void event_set_unsigned(struct event* event, const char* name, uint64_t value);
void event_set_double(struct event* event, const char* name, double value);
void event_set_string(struct event* event, const char* name, const char* value);
bool event_get_boolean(struct event* event, const char* name);
int64_t event_get_signed(struct event* event, const char* name);
uint64_t event_get_unsigned(struct event* event, const char* name);
double event_get_double(struct event* event, const char* name);
const char* event_get_string(struct event* event, const char* name);
const char* event_format(struct event* event);
void event_raise(struct event* event);
void event_print(struct event* event);

#if defined(__cplusplus)
}
#endif

#endif