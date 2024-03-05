#ifndef CORE_COMMON_ERRORS_H
#define CORE_COMMON_ERRORS_H

#include <system/library.h>
#include <system/types.h>
#include "common.h"
#include "modules.h"

#if defined(__cplusplus)
extern "C"
{
#endif

    static inline void native_error_exit(uint32_t module, uint32_t code, const char* scope, const char* message)
    {
        fprintf(stderr, "[error]: [native] module = [%s], scope = [%s], code = [%d], line = [%d], file = [%s], message = [%s]\n", module_to_string(module), scope, code, __LINE__, __FILE__, message);
        exit(-1);
        unreachable();
    }

    static inline void dart_error_exit(uint32_t module, uint32_t code, const char* scope, const char* message)
    {
        fprintf(stderr, "[error]: [dart] module = [%s], scope = [%s], code = [%d], line = [%d], file = [%s], message = [%s]\n", module_to_string(module), scope, code, __LINE__, __FILE__, message);
        exit(-1);
        unreachable();
    }

#if defined(__cplusplus)
}
#endif

#endif