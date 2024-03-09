#include "system.h"
#include <printer/printer.h>
#include <system/types.h>

struct system system_instance;

static void system_default_printer(const char* format, ...)
{
    if (system_get()->print_level == SYSTEM_PRINT_LEVEL_SILENT) return;
    va_list args;
    va_start(args, format);
    vprintf(format, args);
    va_end(args);
}

static void system_default_event_printer(struct event* event)
{
    if (system_get()->print_level < event->level) return;
    system_print_string(event_format(event));
    if (event->level == MODULE_EVENT_LEVEL_ERROR)
    {
        stacktrace_print(0);
    }
}

static void system_default_event_raiser(struct event* event)
{
    if (system_get()->print_level < event->level) return;
    system_print_string(event_format(event));
    stacktrace_print(0);
    exit(event_has_field(event, MODULE_EVENT_FIELD_CODE) ? event_get_unsigned(event, MODULE_EVENT_FIELD_CODE) : -1);
    unreachable();
}

void system_initialize(printer_function printer, event_raiser_function event_raiser, event_printer_function event_printer, int8_t event_print_level)
{
    system_instance.on_print = printer;
    system_instance.on_event_raise = event_raiser;
    system_instance.on_event_print = event_printer;
    system_instance.print_level = event_print_level;
}

FORCEINLINE struct system* system_get()
{
    return &system_instance;
}