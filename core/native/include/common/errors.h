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
    fprintf(stderr, "[error]: line = [%d], file = [%s]\n[native] module = [%s], scope = [%s], code = [%d], message = [%s]\n", __LINE__, __FILE__, module_to_string(module), scope, code, message);
    exit(-1);
    unreachable();
};

static inline void dart_error_exit(uint32_t module, uint32_t code, const char* scope, const char* message)
{
    fprintf(stderr, "[error]: line = [%d], file = [%s]\n[dart] module = [%s], scope = [%s], code = [%d], message = [%s]\n", __LINE__, __FILE__, module_to_string(module), scope, code, message);
    exit(-1);
    unreachable();
}

#if defined(__cplusplus)
}
#endif

#endif