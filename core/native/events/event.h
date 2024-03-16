#ifndef COMMON_EVENTS_EVENT_H
#define COMMON_EVENTS_EVENT_H

#include <system/library.h>
#include <time/time.h>

#if defined(__cplusplus)
extern "C"
{
#endif

struct event
{
    const char* raised_module_name;
    struct event_field_structure** fields;
    const char* function;
    const char* file;
    size_t fields_count;
    uint32_t line;
    uint32_t raised_module_id;
    uint8_t level;
    struct timespec timestamp;
};

struct event* event_create(uint8_t level, const char* function, const char* file, uint32_t line);
struct event* event_build(uint8_t level, const char* function, const char* file, uint32_t line, size_t fields, ...);
void event_setup(struct event* event, uint32_t raised_module_id, const char* raised_module_name);
void event_destroy(struct event* event);

bool event_has_field(struct event* event, const char* name);

void event_set_boolean(struct event* event, const char* name, bool value);
void event_set_signed(struct event* event, const char* name, int64_t value);
void event_set_unsigned(struct event* event, const char* name, uint64_t value);
void event_set_double(struct event* event, const char* name, double value);
void event_set_string(struct event* event, const char* name, const char* value);
void event_set_address(struct event* event, const char* name, void* value);
void event_set_character(struct event* event, const char* name, char value);

char event_get_character(struct event* event, const char* name);
void* event_get_address(struct event* event, const char* name);
bool event_get_boolean(struct event* event, const char* name);
int64_t event_get_signed(struct event* event, const char* name);
uint64_t event_get_unsigned(struct event* event, const char* name);
double event_get_double(struct event* event, const char* name);
const char* event_get_string(struct event* event, const char* name);

const char* event_format(struct event* event);

#if defined(__cplusplus)
}
#endif

#endif