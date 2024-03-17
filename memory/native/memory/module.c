#define DART_EXPORT_INLINES
#include "module.h"
#undef DART_EXPORT_INLINES

struct memory_module* memory_module_create(struct memory_module_configuration* configuration)
{
    return memory_module_construct(configuration);
}

void memory_module_destroy(struct memory_module* module)
{
    memory_module_delete(module);
}
