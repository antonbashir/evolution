#ifndef CORE_PRINTER_PRINTER_H
#define CORE_PRINTER_PRINTER_H

#include <events/events.h>
#include <system/system.h>

#if defined(__cplusplus)
extern "C"
{
#endif

#define system_print(format, ...) system_get()->on_print(format NEW_LINE, __VA_ARGS__)
#define system_print_string(string) system_print("%s\n", string)

#ifdef TRACE
#define system_trace_event(event) event_print(event)
#define system_trace(format, ...) system_print(format, __VA_ARGS__)
#else
#define system_trace(format, ...) \
    do                            \
    {                             \
    }                             \
    while (0)
#define system_trace_event(event) \
    do                            \
    {                             \
    }                             \
    while (0)
#endif

#if defined(__cplusplus)
}
#endif

#endif