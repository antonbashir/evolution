#define FFI_EXPORTER
#include "context.h"
#include <panic/panic.h>
#include <printer/printer.h>

struct context context_instance;

extern struct context* context_get();

void context_create()
{
    if (context_instance.initialized)
    {
        raise_panic(event_panic(event_field("test", 123), event_field("test", "test")));
    }
    context_instance.modules = calloc(MODULES_MAXIMUM, sizeof(void*));
    context_instance.initialized = true;
    context_instance.size = 0;
}

void* context_get_module(uint32_t id)
{
    return context_instance.modules[id];
}

void context_put_module(uint32_t id, void* module)
{
    context_instance.modules[id] = module;
    context_instance.size++;
}
#undef FFI_EXPORTER