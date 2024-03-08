#ifndef CORE_COMMON_ERRORS_H
#define CORE_COMMON_ERRORS_H

#include <common/library.h>
#include <system/types.h>
#include "common.h"

#if defined(__cplusplus)
extern "C"
{
#endif

#define error_exit(module, code, message)                                                                                                              \
    do                                                                                                                                                 \
    {                                                                                                                                                  \
        fprintf(stderr, "[error]: line = [%d], file = [%s]\nmodule = [%s], code = [%d], message = [%s]\n", __LINE__, __FILE__, module, code, message); \
        exit(-1);                                                                                                                                      \
        unreachable();                                                                                                                                 \
    }                                                                                                                                                  \
    while (0);

#define error_system_exit(module, code)                                                                                                                       \
    do                                                                                                                                                        \
    {                                                                                                                                                         \
        fprintf(stderr, "[error]: line = [%d], file = [%s]\nmodule = [%s], code = [%d], message = [%s]\n", __LINE__, __FILE__, module, code, strerror(code)); \
        exit(-1);                                                                                                                                             \
        unreachable();                                                                                                                                        \
    }                                                                                                                                                         \
    while (0);

#if defined(__cplusplus)
}
#endif

#endif