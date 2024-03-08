#ifndef CORE_COMMON_ERRORS_H
#define CORE_COMMON_ERRORS_H

#include <common/library.h>
#include <stacktrace/stacktrace.h>
#include <system/types.h>
#include "common.h"

#if defined(__cplusplus)
extern "C"
{
#endif

#define error_exit(module, code, message)                                                                                                             \
    do                                                                                                                                                \
    {                                                                                                                                                 \
        fprintf(stderr, "(error) %s() [%s:%d]\nmodule = [%s] code = [%d] message = [%s]\n", __FUNCTION__, __FILE__, __LINE__, module, code, message); \
        stacktrace_print(0);                                                                                                                          \
        exit(-1);                                                                                                                                     \
        unreachable();                                                                                                                                \
    }                                                                                                                                                 \
    while (0);

#define error_system_exit(module, code)                                                                                                                      \
    do                                                                                                                                                       \
    {                                                                                                                                                        \
        fprintf(stderr, "(error) %s() [%s:%d]\nmodule = [%s] code = [%d] message = [%s]\n", __FUNCTION__, __FILE__, __LINE__, module, code, strerror(code)); \
        stacktrace_print(0);                                                                                                                                 \
        exit(-1);                                                                                                                                            \
        unreachable();                                                                                                                                       \
    }                                                                                                                                                        \
    while (0);

#if defined(__cplusplus)
}
#endif

#endif