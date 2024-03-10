#include "context.h"
#include "printer/printer.h"

struct context context_instance;

extern struct context* context_get();

void context_create()
{
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

void context_destroy()
{
    free(context_instance.modules);
    context_instance.size = 0;
    context_instance.initialized = false;
}