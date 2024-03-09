#include "crash.h"
#include <common/common.h>
#include <events/events.h>
#include <panic/panic.h>
#include <printer/printer.h>
#include <stacktrace/stacktrace.h>
#include <system/signal.h>

static const int crash_signals[] = {SIGILL, SIGBUS, SIGFPE, SIGSEGV};

static void crash_signal_callback(int signal, siginfo_t* information, void* context)
{
    print_event(event_new_information("hello", event_field("test", "test 1234")));
    static volatile sig_atomic_t crashing = 0;
    struct event* crash_event = NULL;
    const char* signal_code = NULL;
    if (crashing == 0)
    {
        crashing = 1;
        switch (signal)
        {
            case SIGILL:
                crash_event = event_new_panic_empty("Crashed: Illegal instruction");
                break;
            case SIGBUS:
                crash_event = event_new_panic_empty("Crashed: Bus error");
                break;
            case SIGFPE:
                crash_event = event_new_panic_empty("Crashed: Floating-point error");
                break;
            case SIGSEGV:
                crash_event = event_new_panic_empty("Crashed: Segmentation fault");
                switch (information->si_code)
                {
                    case SEGV_MAPERR:
                        signal_code = "SEGV_MAPERR";
                        break;
                    case SEGV_ACCERR:
                        signal_code = "SEGV_ACCERR";
                        break;
                }
                break;
            default:
                print_error("Unexpected fatal signal: %d", signal);
                break;
        }

        if (signal_code != NULL)
            event_set_string(crash_event, "code", signal_code);
        else
            event_set_signed(crash_event, "code", information->si_code);
        if (information->si_addr != NULL)
        {
            event_set_address(crash_event, "address", information->si_addr);
        }
        event_set_address(crash_event, "signal information", information);
        print_event(crash_event);
    }
    else
    {
        print_error("Error %d while handling crash", signal);
    }

    struct sigaction default_signal_action = {.sa_handler = SIG_DFL};
    sigemptyset(&default_signal_action.sa_mask);
    sigaction(SIGABRT, &default_signal_action, NULL);
    abort();
}

void crash_initialize()
{
    struct sigaction signal_action = {
        .sa_flags = SA_RESETHAND | SA_NODEFER | SA_SIGINFO | SA_ONSTACK,
        .sa_sigaction = crash_signal_callback,
    };
    sigemptyset(&signal_action.sa_mask);

    for (size_t i = 0; i < length_of(crash_signals); i++)
    {
        if (sigaction(crash_signals[i], &signal_action, NULL) == 0)
            continue;
        raise_panic(event_new_system_panic(errno));
    }
}