#ifndef EXECUTOR_ERRORS_H
#define EXECUTOR_ERRORS_H

#if defined(__cplusplus)
extern "C"
{
#endif

#define executor_error_out_of_memory(...) executor_module_event(event_error_out_of_memory(__VA_ARGS__))
#define executor_error_system(code, ...) executor_module_event(event_system_error(-result, ##__VA_ARGS__))
#define executor_error_ring_full(...) executor_module_event(event_module_error(0, event_field_message("io_ring sqe is full"), ##__VA_ARGS__))

#if defined(__cplusplus)
}
#endif

#endif