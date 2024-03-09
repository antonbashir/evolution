#ifndef CORE_SYSTEM_SYSTEM_H
#define CORE_SYSTEM_SYSTEM_H

#include <common/common.h>
#include <common/library.h>
#include <modules/modules.h>
#include "network.h"
#include "socket.h"
#include "string.h"
#include "threading.h"
#include "time.h"
#include "types.h"

#if defined(__cplusplus)
extern "C"
{
#endif

typedef void (*event_raiser_function)(struct event* e);
typedef void (*event_printer_function)(struct event* e);
typedef int (*printer_function)(char const* format, ...);

#define SYSTEM_PRINT_LEVEL_SILENT -1
#define SYSTEM_PRINT_LEVEL_TRACE MODULE_EVENT_LEVEL_TRACE
#define SYSTEM_PRINT_LEVEL_INFORMATION MODULE_EVENT_LEVEL_INFORMATION
#define SYSTEM_PRINT_LEVEL_WARNING MODULE_EVENT_LEVEL_WARNING
#define SYSTEM_PRINT_LEVEL_ERROR MODULE_EVENT_LEVEL_ERROR
#define SYSTEM_PRINT_LEVEL_PANIC MODULE_EVENT_LEVEL_PANIC

struct system
{
    printer_function on_print;
    event_raiser_function on_event_raise;
    event_printer_function on_event_print;
    int8_t print_level;
};

void system_initialize(printer_function printer, event_raiser_function event_raiser, event_printer_function event_printer, int8_t print_level);

struct system* system_get();

extern FORCEINLINE void system_shutdown_descriptor(int32_t fd)
{
    shutdown(fd, SHUT_RDWR);
    close(fd);
}

#if defined(__cplusplus)
}
#endif

#endif