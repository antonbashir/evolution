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
    uint64_t v = 123;
    print_event(event_new_panic("test", event_field("test b", (bool)true), event_field("test b2", (bool)false), event_field("test", &argv), event_field("test 2", v), event_field("test 3", "test"), event_field("test 4", 13234.2451f), event_field("test 6", (char)'c')));
    crash_initialize();
    int* a = NULL;
    int b = (*a);
    b++;
    return 0;
    return 0;
}
