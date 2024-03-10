#include "context.h"
#include <panic/panic.h>
#include <printer/printer.h>

struct context context_instance;

extern struct context* context_get();

void context_create()
{
    if (context_instance.initialized)
    {
        raise_panic(event_panic(event_message(PANIC_CONTEXT_CREATED)));
    }
    context_instance.modules = calloc(MODULES_MAXIMUM, sizeof(void*));
    context_instance.initialized = true;
    context_instance.size = 0;
}

void* context_get_module(uint32_t module_id)
{
    return context_instance.modules[module_id];
}

void context_put_module(uint32_t module_id, void* module)
{
    context_instance.modules[module_id] = module;
    context_instance.size++;
}