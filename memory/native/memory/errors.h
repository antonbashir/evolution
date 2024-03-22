#ifndef MEMORY_ERRORS_H
#define MEMORY_ERRORS_H

#if defined(__cplusplus)
extern "C"
{
#endif

#define memory_error_out_of_memory(...) memory_module_event(event_error_out_of_memory(__VA_ARGS__))
#define memory_error_system(code, ...) memory_module_event(event_system_error(-result, ##__VA_ARGS__))
#define memory_error_buffers_unavailable(...) memory_module_event(event_module_error(0, event_field_message("No buffers in pool"), ##__VA_ARGS__))

#if defined(__cplusplus)
}
#endif

#endif