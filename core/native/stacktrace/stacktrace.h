#ifndef CORE_STACKTRACE_STACKTRACE
#define CORE_STACKTRACE_STACKTRACE

#include <common/common.h>
#include <common/constants.h>
#include <system/library.h>

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

FORCE_ALIGN_ARG_POINTER NOINLINE void stacktrace_collect_current(struct stacktrace* trace, int skip);
int stacktrace_format(struct stacktrace* trace, char* buffer, size_t buffer_size);
int stacktrace_format_at(int skip, int index, char* buffer, size_t size);
void stacktrace_print(int skip);
DART_LEAF_FUNCTION const char* stacktrace_to_string(int skip);

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
        result_size == 0 ? "" : result;                                                                                                                           \
    })

#if defined(__cplusplus)
}
#endif

#endif