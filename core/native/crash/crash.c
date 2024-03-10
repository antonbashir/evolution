#include "crash.h"
#include <common/common.h>
#include <common/constants.h>
#include <events/events.h>
#include <panic/panic.h>
#include <printer/printer.h>
#include <stacktrace/stacktrace.h>
#include <system/library.h>

static const int crash_signals[] = {SIGILL, SIGBUS, SIGFPE, SIGSEGV};

static void crash_signal_callback(int signal, siginfo_t* information, void* context)
{
    static volatile sig_atomic_t crashing = 0;
    struct event* crash_event = NULL;
    const char* signal_code = NULL;
    if (crashing == 0)
    {
        crashing = 1;
        switch (signal)
        {
            case SIGILL:
                crash_event = event_panic(CRASH_ILLEGAL_INSTRUCTION);
                break;
            case SIGBUS:
                crash_event = event_panic(CRASH_BUS_ERROR);
                break;
            case SIGFPE:
                crash_event = event_panic(CRASH_FLOATING_POINT_ERROR);
                break;
            case SIGSEGV:
                crash_event = event_panic(CRASH_SEGMENTATION_FAULT);
                switch (information->si_code)
                {
                    case SEGV_MAPERR:
                        signal_code = SIGNAL_CODE_MAPPER;
                        break;
                    case SEGV_ACCERR:
                        signal_code = SIGNAL_CODE_ACCERR;
                        break;
                }
                break;
            default:
                print_error(ERROR_UNEXPECTED_SIGNAL, signal);
                break;
        }

        if (signal_code != NULL)
            event_set_string(crash_event, MODULE_EVENT_FIELD_CODE, signal_code);
        else
            event_set_signed(crash_event, MODULE_EVENT_FIELD_CODE, information->si_code);
        if (information->si_addr != NULL)
        {
            event_set_address(crash_event, MODULE_EVENT_FIELD_ADDRESS, information->si_addr);
        }
        event_set_address(crash_event, MODULE_EVENT_FIELD_SIGNAL_INFORMATION, information);
        print_event(crash_event);
    }
    else
    {
        print_error(ERROR_CRASH_HANDLING, signal);
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
        raise_panic(event_system_panic(errno));
    }
}