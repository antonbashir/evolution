#include "module.h"

void empty_printer(const char* format, ...)
{
}

void empty_error_printer(const char* format, ...)
{
}

void empty_event_printer(struct event* event)
{
    event_destroy(event);
}

struct core_module* core_module_create(struct core_module_configuration* configuration)
{
    return core_module_construct(configuration);
}

void core_module_destroy(struct core_module* module)
{
    core_module_delete(module);
}
