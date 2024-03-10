#ifndef CORE_SYSTEM_SYSTEM_H
#define CORE_SYSTEM_SYSTEM_H

#include <events/events.h>
#include <system/library.h>

#if defined(__cplusplus)
extern "C"
{
#endif

typedef void (*event_raiser_function)(struct event* e);
typedef void (*event_printer_function)(struct event* e);
typedef void (*printer_function)(char const* format, ...);

struct system_configuration
{
    bool initialized;
    printer_function on_print;
    printer_function on_print_error;
    event_raiser_function on_event_raise;
    event_printer_function on_event_print;
    int8_t print_level;
};

struct system
{
    bool initialized;
    printer_function on_print;
    printer_function on_print_error;
    event_raiser_function on_event_raise;
    event_printer_function on_event_print;
    int8_t print_level;
};

extern struct system system_instance;

void system_initialize(struct system_configuration configuration);
void system_initialize_default();
void system_default_printer(const char* format, ...);
void system_default_error_printer(const char* format, ...);
void system_default_event_printer(struct event* event);
void system_default_event_raiser(struct event* event);

static FORCEINLINE struct system* system_get()
{
    return &system_instance;
}

#if defined(__cplusplus)
}
#endif

#endif