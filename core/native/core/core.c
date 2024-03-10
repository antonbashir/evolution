#include "core.h"
#include <events/events.h>
#include <modules/modules.h>
#include <system/library.h>
#include <system/system.h>
#include "printer/printer.h"

void core_initialize(struct core_module_configuration* configuration)
{
    system_initialize((struct system_configuration){
        .on_print = system_default_printer,
        .on_print_error = system_default_error_printer,
        .on_event_raise = system_default_event_raiser,
        .on_event_print = system_default_event_printer,
        .print_level = configuration->print_level,
    });
}