#ifndef COMMON_EVENTS_EVENTS_H
#define COMMON_EVENTS_EVENTS_H

#include <events/event.h>
#include <events/field.h>

#if defined(__cplusplus)
extern "C"
{
#endif

#define event_trace(...) event_build(MODULE_EVENT_LEVEL_TRACE, __FUNCTION__, __FILENAME__, __LINE__, VA_LENGTH(__VA_ARGS__), ##__VA_ARGS__)
#define event_information(...) event_build(MODULE_EVENT_LEVEL_INFORMATION, __FUNCTION__, __FILENAME__, __LINE__,  VA_LENGTH(__VA_ARGS__), ##__VA_ARGS__)
#define event_warning(...) event_build(MODULE_EVENT_LEVEL_WARNING, __FUNCTION__, __FILENAME__, __LINE__,  VA_LENGTH(__VA_ARGS__), ##__VA_ARGS__)
#define event_error(...) event_build(MODULE_EVENT_LEVEL_ERROR, __FUNCTION__, __FILENAME__, __LINE__,  VA_LENGTH(__VA_ARGS__), ##__VA_ARGS__)
#define event_panic(...) event_build(MODULE_EVENT_LEVEL_PANIC, __FUNCTION__, __FILENAME__, __LINE__,  VA_LENGTH(__VA_ARGS__), ##__VA_ARGS__)
#define event_system_error(code, ...) event_error(strerror(code), event_field(MODULE_EVENT_FIELD_CODE, code), ##__VA_ARGS__)
#define event_system_panic(code, ...) event_panic(strerror(code), event_field(MODULE_EVENT_FIELD_CODE, code), ##__VA_ARGS__)

#if defined(__cplusplus)
}
#endif

#endif