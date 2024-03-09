#include <events/events.h>
#include <modules/modules.h>
#include <printer/printer.h>
#include <system/system.h>
#include <system/socket.h>

struct t
{
};

NOINLINE void func()
{
    struct event* event = core_event(event_new_trace("test",
                                                     event_field("test 0", false),
                                                     event_field("test b", true),
                                                     event_field("test 1", 123),
                                                     event_field("test 2", 456),
                                                     event_field("test 3", -456),
                                                     event_field("test 4", 456.135),
                                                     event_field("test 5", "test")));
    print_message("test 5: %s", event_get_string(event, "test 5"));
    print_event(event);
    print_event(event_new_system_error(ENOMEM));
    raise_panic(event);
}

int main(int argc, char const* argv[])
{
    func();
    system_shutdown_descriptor(123);
    return 0;
}
