#ifndef CORE_STACKTRACE_STACKTRACE
#define CORE_STACKTRACE_STACKTRACE

#include <common/common.h>
#include <system/types.h>

#define STACKTRACE_FRAME_FORMAT \
    "#%-2d %p %s:%"             \
    "l"                         \
    "u"
#define STACKTRACE_FRAME_MAX 128
#define STACKTRACE_PRINT_BUFFER 1024

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
void stacktrace_print(int skip);
#if defined(__cplusplus)
}
#endif

#endif