#ifndef CORE_STACKTRACE_STACKTRACE
#define CORE_STACKTRACE_STACKTRACE

#include <common/common.h>
#include <system/types.h>

#define STACKTRACE_FRAME_FORMAT \
    "#%-2d %p %s:%"             \
    "l"                         \
    "u"
#define STACKTRACE_PROCEDURE_SIZE 128
#define STACKTRACE_FRAME_MAX 128
#define STACKTRACE_PRINT_BUFFER 1024
#define STACKTRACE_UNKNOWN "(unknown)"

#if defined(__cplusplus)
extern "C"
{
#endif

struct stacktrace_frame
{
    void* instruction;
};

struct stacktrace
{
    int size;
    struct stacktrace_frame frames[STACKTRACE_FRAME_MAX];
};

#ifdef __x86_64__
__attribute__((__force_align_arg_pointer__))
#endif
NOINLINE void
stacktrace_collect_current(struct stacktrace* trace, int skip);
int stacktrace_format(struct stacktrace* trace, char* buffer, size_t buffer_size);
int stacktrace_format_at(int skip, int index, char* buffer, size_t size);
void stacktrace_print(int skip);

#define stacktrace_callers(skip, count)                                                                                                                           \
    ({                                                                                                                                                            \
        char result[STACKTRACE_PROCEDURE_SIZE * count];                                                                                                           \
        size_t result_size = 0;                                                                                                                                   \
        for (size_t i = 0; i < count; i++)                                                                                                                        \
        {                                                                                                                                                         \
            char buffer[STACKTRACE_PROCEDURE_SIZE];                                                                                                               \
            size_t size = stacktrace_format_at(skip, i, buffer, STACKTRACE_PROCEDURE_SIZE);                                                                       \
            if (result_size == 0 && size > 0)                                                                                                                     \
            {                                                                                                                                                     \
                result_size = snprintf(result, STACKTRACE_PROCEDURE_SIZE * count, "%s", buffer);                                                                  \
                continue;                                                                                                                                         \
            }                                                                                                                                                     \
            if (result_size != 0 && size > 0) result_size += snprintf(result + result_size, (STACKTRACE_PROCEDURE_SIZE * count) - result_size, " <- %s", buffer); \
        }                                                                                                                                                         \
        result;                                                                                                                                                   \
    })

#if defined(__cplusplus)
}
#endif

#endif