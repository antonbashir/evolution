#ifndef CORE_COMMON_CONSTANTS_H
#define CORE_COMMON_CONSTANTS_H

#if defined(__cplusplus)
extern "C"
{
#endif

#define TRUE_LABEL "true"
#define FALSE_LABEL "false"

#define NEW_LINE "\n"
#define EMPTY_STRING ""
#define STRING_FORMAT "%s"
#define TIMEZONE_FORMAT "%Z"
#define DATE_TIME_FORMAT "%Y-%m-%d %H:%M:%S"
#define TIME_MICROSECONDS_FORMAT ".%04ld"
#define SPACE " "

#define MODULE_UNKNOWN_NAME "unknown"

#define MODULES_MAXIMUM 64

#define MODULE_ERROR_CODE -1997

#define EVENT_BUFFER 2048
#define EVENT_FIELDS_MAXIMUM 20

#define EVENT_LEVEL_PANIC 0
#define EVENT_LEVEL_ERROR 1
#define EVENT_LEVEL_WARNING 2
#define EVENT_LEVEL_INFORMATION 3
#define EVENT_LEVEL_TRACE 4

#define EVENT_LEVEL_UNKNOWN_LABEL "(unknown)";
#define EVENT_LEVEL_TRACE_LABEL "(trace)";
#define EVENT_LEVEL_INFORMATION_LABEL "(information)";
#define EVENT_LEVEL_WARNING_LABEL "(warning)";
#define EVENT_LEVEL_ERROR_LABEL "(error)";
#define EVENT_LEVEL_PANIC_LABEL "(panic)";

#define EVENT_TYPE_SIGNED 0
#define EVENT_TYPE_UNSIGNED 1
#define EVENT_TYPE_DOUBLE 2
#define EVENT_TYPE_STRING 3
#define EVENT_TYPE_ADDRESS 4
#define EVENT_TYPE_CHARACTER 5
#define EVENT_TYPE_BOOLEAN 6

#define EVENT_FIELD_MESSAGE "message"
#define EVENT_FIELD_ERROR_KIND "error-kind"
#define EVENT_FIELD_CODE "code"
#define EVENT_FIELD_SCOPE "scope"
#define EVENT_FIELD_CALLER "caller"
#define EVENT_FIELD_ADDRESS "address"
#define EVENT_FIELD_STACK_TRACE "stack-trace"
#define EVENT_FIELD_SIGNAL_INFORMATION "signal-information"

#define EVENT_ERROR_KIND_MODULE "module"
#define EVENT_ERROR_KIND_SYSTEM "system"

#define EVENT_FORMAT "[%s] %s: %s(...) %s:%d\n"
#define EVENT_MODULE_PART "module = %s\n"
#define EVENT_FIELD_BOOLEAN_FORMAT "%s = %s\n"
#define EVENT_FIELD_UNSIGNED_FORMAT "%s = %ld\n"
#define EVENT_FIELD_SIGNED_FORMAT "%s = %ld\n"
#define EVENT_FIELD_DOUBLE_FORMAT "%s = %lf\n"
#define EVENT_FIELD_STRING_FORMAT "%s = %s\n"
#define EVENT_FIELD_ADDRESS_FORMAT "%s = %p\n"
#define EVENT_FIELD_CHARACTER_FORMAT "%s = %c\n"

#define SYSTEM_PRINT_LEVEL_TRACE EVENT_LEVEL_TRACE
#define SYSTEM_PRINT_LEVEL_INFORMATION EVENT_LEVEL_INFORMATION
#define SYSTEM_PRINT_LEVEL_WARNING EVENT_LEVEL_WARNING
#define SYSTEM_PRINT_LEVEL_ERROR EVENT_LEVEL_ERROR
#define SYSTEM_PRINT_LEVEL_PANIC EVENT_LEVEL_PANIC

#define EVENT_RAISE_SYSTEM_FORMAT "(panic): %s(...) %s:%d - code = %d, message = %s"
#define EVENT_RAISE_FORMAT "(panic): %s(...) %s:%d - "

#define STACKTRACE_FRAME_FORMAT_LONG \
    "#%-2d %p %s:%"                  \
    "l"                              \
    "u"
#define STACKTRACE_FRAME_FORMAT_SHORT "%s:%lu"
#define STACKTRACE_PROCEDURE_SIZE 128
#define STACKTRACE_FRAME_MAX 128
#define STACKTRACE_PRINT_BUFFER 2048
#define STACKTRACE_UNKNOWN "(unknown)"

#define CRASH_ILLEGAL_INSTRUCTION "Crashed: Illegal instruction"
#define CRASH_BUS_ERROR "Crashed: Bus error"
#define CRASH_FLOATING_POINT_ERROR "Crashed: Floating-point error"
#define CRASH_SEGMENTATION_FAULT "Crashed: Segmentation fault"

#define SIGNAL_CODE_MAPPER "SEGV_MAPERR"
#define SIGNAL_CODE_ACCERR "SEGV_MAPERR"

#define ERROR_UNEXPECTED_SIGNAL "Unexpected fatal signal: %d"
#define ERROR_CRASH_HANDLING "Error %d while handling crash"
#define ERROR_EVENT_FIELD_NOT_FOUND "Event field %s is not found"
#define ERROR_EVENT_FIELD_NOT_CHARACTER "Event field %s is not character"
#define ERROR_EVENT_FIELD_NOT_STRING "Event field %s is not string"
#define ERROR_EVENT_FIELD_NOT_DOUBLE "Event field %s is not double"
#define ERROR_EVENT_FIELD_NOT_UNSIGNED "Event field %s is not unsigned"
#define ERROR_EVENT_FIELD_NOT_SIGNED "Event field %s is not signed"
#define ERROR_EVENT_FIELD_NOT_BOOLEAN "Event field %s is not boolean"
#define ERROR_EVENT_FIELD_NOT_ADDRESS "Event field %s is not address"
#define ERROR_EVENT_FIELD_LIMIT_REACHED "Event fields limit is reached: %d"

#define PANIC_CONTEXT_CREATED "Context already created"
#define MODULE_LOADING_FAILED "Failed to load module %s"

#define LOADING_LIBRARY_MESSAGE "Loading library: %s"

#if defined(__cplusplus)
}
#endif

#endif