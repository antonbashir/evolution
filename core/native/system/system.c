#include "system.h"
#include <crash/crash.h>
#include <events/events.h>
#include <events/field.h>
#include <printer/printer.h>
#include <stacktrace/stacktrace.h>

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
    system_get()->on_print("%s", buffer);
    free((void*)buffer);
    if (event->level <= MODULE_EVENT_LEVEL_ERROR)
    {
        stacktrace_print(0);
    }
    event_destroy(event);
}

void system_default_event_raiser(struct event* event)
{
    if (system_get()->print_level < event->level) return;
    system_get()->on_print("%s", event_format(event));
    stacktrace_print(0);
    exit(event_has_field(event, MODULE_EVENT_FIELD_CODE) ? event_get_unsigned(event, MODULE_EVENT_FIELD_CODE) : -1);
    unreachable();
}

void system_initialize(struct system_configuration configuration)
{
    if (system_instance.initialized) return;
    system_instance.on_print = configuration.on_print;
    system_instance.on_print_error = configuration.on_print_error;
    system_instance.on_event_raise = configuration.on_event_raise;
    system_instance.on_event_print = configuration.on_event_print;
    system_instance.print_level = configuration.print_level;
    crash_initialize();
}


void system_initialize_default()
{
#ifdef TRACE
    system_initialize((struct system_configuration){
        .on_print = system_default_printer,
        .on_print_error = system_default_error_printer,
        .on_event_raise = system_default_event_raiser,
        .on_event_print = system_default_event_printer,
        .print_level = SYSTEM_PRINT_LEVEL_TRACE,
    });
#else
    system_initialize((struct system_configuration){
        .on_print = system_default_printer,
        .on_print_error = system_default_error_printer,
        .on_event_raise = system_default_event_raiser,
        .on_event_print = system_default_event_printer,
        .print_level = SYSTEM_PRINT_LEVEL_ERROR,
    });
#endif
}
