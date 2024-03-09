#include "system.h"
#include <crash/crash.h>
#include <events/events.h>
#include <events/field.h>
#include <printer/printer.h>
#include <stacktrace/stacktrace.h>
#include <system/types.h>

struct system system_instance;

void system_default_printer(const char* format, ...)
{
    if (system_get()->print_level == SYSTEM_PRINT_LEVEL_SILENT) return;
    va_list args;
    va_start(args, format);
    vfprintf(stdout, format, args);
    va_end(args);
}

void system_default_error_printer(const char* format, ...)
{
    va_list args;
    va_start(args, format);
    vfprintf(stderr, format, args);
    va_end(args);
}

void system_default_event_printer(struct event* event)
{
    if (system_get()->print_level < event->level) return;
    const char* buffer = event_format(event);
    print_string(buffer);
    free((void*)buffer);
    if (event->level <= MODULE_EVENT_LEVEL_ERROR)
    {
        stacktrace_print(0);
    }
}

void system_default_event_raiser(struct event* event)
{
    if (system_get()->print_level < event->level) return;
    print_string(event_format(event));
    stacktrace_print(0);
    exit(event_has_field(event, MODULE_EVENT_FIELD_CODE) ? event_get_unsigned(event, MODULE_EVENT_FIELD_CODE) : -1);
    unreachable();
}

void system_initialize(printer_function printer, printer_function error_printer, event_raiser_function event_raiser, event_printer_function event_printer, int8_t event_print_level)
{
    if (system_instance.initialized) return;
    system_instance.on_print = printer;
    system_instance.on_print_error = error_printer;
    system_instance.on_event_raise = event_raiser;
    system_instance.on_event_print = event_printer;
    system_instance.print_level = event_print_level;
    crash_initialize();
}

void system_initialize_default()
{
#ifdef TRACE
    system_initialize(system_default_printer, system_default_error_printer, system_default_event_raiser, system_default_event_printer, SYSTEM_PRINT_LEVEL_TRACE);
#else
    system_initialize(system_default_printer, system_default_error_printer, system_default_event_raiser, system_default_event_printer, SYSTEM_PRINT_LEVEL_ERROR);
#endif
}