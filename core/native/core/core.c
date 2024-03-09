#include "core.h"
#include <events/events.h>
#include <panic/panic.h>
#include <system/network.h>
#include <system/scheduling.h>
#include <system/socket.h>
#include <system/system.h>
#include <system/threading.h>
#include <system/time.h>
#include <system/types.h>
#include "crash/crash.h"
#include "printer/printer.h"

void core_initialize(struct core_module_configuration* configuration)
{
    system_initialize(
        system_default_printer,
        system_default_error_printer,
        system_default_event_raiser,
        system_default_event_printer,
        configuration->print_level);
}

int main(int argc, char const* argv[])
{
    crash_initialize();
    int* a = NULL;
    int b = (*a);
    b++;
    return 0;
}
