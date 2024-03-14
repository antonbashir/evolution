#ifndef CORE_COMMON_CONSTANTS_H
#define CORE_COMMON_CONSTANTS_H

#if defined(__cplusplus)
extern "C"
{
#endif

#define MODULE_UNKNOWN -1
#define MODULE_UNKNOWN_NAME "unknown"

#define MODULES_MAXIMUM 64

#define MODULE_EVENT_BUFFER 2048
#define MODULE_EVENT_FIELDS_MAXIMUM 20

#define MODULE_EVENT_LEVEL_PANIC 0
#define MODULE_EVENT_LEVEL_ERROR 1
#define MODULE_EVENT_LEVEL_WARNING 2
#define MODULE_EVENT_LEVEL_INFORMATION 3
#define MODULE_EVENT_LEVEL_TRACE 4

#define MODULE_EVENT_LEVEL_UNKNOWN_LABEL "(unknown)";
#define MODULE_EVENT_LEVEL_TRACE_LABEL "(trace)";
#define MODULE_EVENT_LEVEL_INFORMATION_LABEL "(information)";
#define MODULE_EVENT_LEVEL_WARNING_LABEL "(warning)";
#define MODULE_EVENT_LEVEL_ERROR_LABEL "(error)";
#define MODULE_EVENT_LEVEL_PANIC_LABEL "(panic)";

#define MODULE_EVENT_TYPE_SIGNED 0
#define MODULE_EVENT_TYPE_UNSIGNED 1
#define MODULE_EVENT_TYPE_DOUBLE 2
#define MODULE_EVENT_TYPE_STRING 3
#define MODULE_EVENT_TYPE_ADDRESS 4
#define MODULE_EVENT_TYPE_CHARACTER 5
#define MODULE_EVENT_TYPE_BOOLEAN 6

#define MODULE_EVENT_FIELD_MESSAGE "message"
#define MODULE_EVENT_FIELD_CODE "code"
#define MODULE_EVENT_FIELD_SCOPE "scope"
#define MODULE_EVENT_FIELD_CALLER "caller"
#define MODULE_EVENT_FIELD_ADDRESS "address"
#define MODULE_EVENT_FIELD_SIGNAL_INFORMATION "signal-information"

#define SYSTEM_PRINT_LEVEL_TRACE MODULE_EVENT_LEVEL_TRACE
#define SYSTEM_PRINT_LEVEL_INFORMATION MODULE_EVENT_LEVEL_INFORMATION
#define SYSTEM_PRINT_LEVEL_WARNING MODULE_EVENT_LEVEL_WARNING
#define SYSTEM_PRINT_LEVEL_ERROR MODULE_EVENT_LEVEL_ERROR
#define SYSTEM_PRINT_LEVEL_PANIC MODULE_EVENT_LEVEL_PANIC

#define STACKTRACE_FRAME_FORMAT_LONG \
    "#%-2d %p %s:%"                  \
    "l"                              \
    "u"
#define STACKTRACE_FRAME_FORMAT_SHORT "%s:%lu"
#define STACKTRACE_PROCEDURE_SIZE 128
#define STACKTRACE_FRAME_MAX 128
#define STACKTRACE_PRINT_BUFFER 1024
#define STACKTRACE_UNKNOWN "(unknown)"

#define CRASH_ILLEGAL_INSTRUCTION "Crashed: Illegal instruction"
#define CRASH_BUS_ERROR "Crashed: Bus error"
#define CRASH_FLOATING_POINT_ERROR "Crashed: Floating-point error"
#define CRASH_SEGMENTATION_FAULT "Crashed: Segmentation fault"

#define SIGNAL_CODE_MAPPER "SEGV_MAPERR"
#define SIGNAL_CODE_ACCERR "SEGV_MAPERR"

#define ERROR_UNEXPECTED_SIGNAL "Unexpected fatal signal: %d"
#define ERROR_CRASH_HANDLING "Error %d while handling crash"

#define PANIC_CONTEXT_CREATED "Context already created"

#if defined(__cplusplus)
}
#endif

#endif