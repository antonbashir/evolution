#include "bootstrap.h"
#include <system/system.h>

void empty_printer(const char* format, ...)
{
}

void empty_error_printer(const char* format, ...)
{
}

void empty_event_printer(struct event* event)
{
    event_destroy(event);
}

void bootstrap_system(struct bootstrap_configuration* configuration)
{
    system_initialize((struct system_configuration){
        .on_print = configuration->silent ? empty_printer : system_default_printer,
        .on_print_error = configuration->silent ? empty_error_printer : system_default_error_printer,
        .on_event_print = configuration->silent ? empty_event_printer : system_default_event_printer,
        .on_event_raise = system_default_event_raiser,
        .print_level = configuration->print_level,
    });
}

struct bootstrap_configuration* bootstrap_configuration_get()
{
    return &system_get()->configuration.bootstrap_configuration;
}