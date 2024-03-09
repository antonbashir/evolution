#ifndef CORE_SYSTEM_SYSTEM_H
#define CORE_SYSTEM_SYSTEM_H

#include <common/common.h>
#include <common/library.h>
#include <events/events.h>

#if defined(__cplusplus)
extern "C"
{
#endif

typedef void (*event_raiser_function)(struct event* e);
typedef void (*event_printer_function)(struct event* e);
typedef void (*printer_function)(char const* format, ...);

#define SYSTEM_PRINT_LEVEL_SILENT -1
#define SYSTEM_PRINT_LEVEL_TRACE MODULE_EVENT_LEVEL_TRACE
#define SYSTEM_PRINT_LEVEL_INFORMATION MODULE_EVENT_LEVEL_INFORMATION
#define SYSTEM_PRINT_LEVEL_WARNING MODULE_EVENT_LEVEL_WARNING
#define SYSTEM_PRINT_LEVEL_ERROR MODULE_EVENT_LEVEL_ERROR
#define SYSTEM_PRINT_LEVEL_PANIC MODULE_EVENT_LEVEL_PANIC

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

void system_initialize(printer_function printer, printer_function error_printer, event_raiser_function event_raiser, event_printer_function event_printer, int8_t print_level);
void system_initialize_default();
void system_default_printer(const char* format, ...);
void system_default_error_printer(const char* format, ...);
void system_default_event_printer(struct event* event);
void system_default_event_raiser(struct event* event);

FORCEINLINE struct system* system_get()
{
    if (unlikely(!system_instance.initialized)) system_initialize_default();
    return &system_instance;
}

#if defined(__cplusplus)
}
#endif

#endif