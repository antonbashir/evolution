#ifndef COMMON_EVENTS_EVENTS_H
#define COMMON_EVENTS_EVENTS_H

#include <events/event.h>
#include <events/field.h>

#if defined(__cplusplus)
extern "C"
{
#endif

#define event_of(level, ...) event_build(level, __FUNCTION__, __FILENAME__, __LINE__, VA_LENGTH(__VA_ARGS__), ##__VA_ARGS__)
#define event_trace(...) event_build(EVENT_LEVEL_TRACE, __FUNCTION__, __FILENAME__, __LINE__, VA_LENGTH(__VA_ARGS__), ##__VA_ARGS__)
#define event_information(...) event_build(EVENT_LEVEL_INFORMATION, __FUNCTION__, __FILENAME__, __LINE__, VA_LENGTH(__VA_ARGS__), ##__VA_ARGS__)
#define event_warning(...) event_build(EVENT_LEVEL_WARNING, __FUNCTION__, __FILENAME__, __LINE__, VA_LENGTH(__VA_ARGS__), ##__VA_ARGS__)
#define event_error(...) event_build(EVENT_LEVEL_ERROR, __FUNCTION__, __FILENAME__, __LINE__, VA_LENGTH(__VA_ARGS__), ##__VA_ARGS__)
#define event_panic(...) event_build(EVENT_LEVEL_PANIC, __FUNCTION__, __FILENAME__, __LINE__, VA_LENGTH(__VA_ARGS__), ##__VA_ARGS__)

#define event_module_error(code, ...) event_error(event_field(EVENT_FIELD_ERROR_KIND, EVENT_ERROR_KIND_MODULE), event_field(EVENT_FIELD_CODE, code), ##__VA_ARGS__)
#define event_module_panic(code, ...) event_panic(event_field(EVENT_FIELD_ERROR_KIND, EVENT_ERROR_KIND_MODULE), event_field(EVENT_FIELD_CODE, code), ##__VA_ARGS__)
#define event_system_error(code, ...) event_error(event_field(EVENT_FIELD_ERROR_KIND, EVENT_ERROR_KIND_SYSTEM), event_field(EVENT_FIELD_MESSAGE, strerror(code)), event_field(EVENT_FIELD_CODE, code), ##__VA_ARGS__)
#define event_system_panic(code, ...) event_panic(event_field(EVENT_FIELD_ERROR_KIND, EVENT_ERROR_KIND_SYSTEM), event_field(EVENT_FIELD_MESSAGE, strerror(code)), event_field(EVENT_FIELD_CODE, code), ##__VA_ARGS__)

#define event_error_out_of_memory(...) event_system_error(ENOMEM, ##__VA_ARGS__)

#if defined(__cplusplus)
}
#endif

#endif