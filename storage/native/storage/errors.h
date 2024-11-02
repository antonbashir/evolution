#ifndef STORAGE_ERRORS_H
#define STORAGE_ERRORS_H

#include <events/events.h>

#if defined(__cplusplus)
extern "C"
{
#endif

#define storage_error_out_of_memory(...) storage_module_event(event_error_out_of_memory(__VA_ARGS__))
#define storage_error_system(code, ...) storage_module_event(event_system_error(-result, ##__VA_ARGS__))
#define storage_lua_error(path) storage_module_event(event_error(event_field("lua.path", path), event_field_message("Failed to execute initial Lua script")))

#if defined(__cplusplus)
}
#endif

#endif