#ifndef CORE_PANIC_PANIC_H
#define CORE_PANIC_PANIC_H

#include <system/system.h>

#if defined(__cplusplus)
extern "C"
{
#endif

#define raise_panic(event) system_get()->on_event_raise(event);

#if defined(__cplusplus)
}
#endif

#endif