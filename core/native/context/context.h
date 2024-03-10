#ifndef CORE_CONTEXT_H
#define CORE_CONTEXT_H

#include <common/common.h>
#include <common/constants.h>
#include <system/library.h>

#if defined(__cplusplus)
extern "C"
{
#endif

struct context
{
    bool initialized;
    size_t size;
    void** modules;
};

extern struct context context_instance;

FORCEINLINE struct context* context_get()
{
    return &context_instance;
}

void context_create();
void* context_get_module(uint32_t module_id);
void context_put_module(uint32_t module_id, void* module);
void context_destroy();

#if defined(__cplusplus)
}
#endif

#endif