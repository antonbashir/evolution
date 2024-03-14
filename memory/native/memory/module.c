#define DART_EXPORT_INLINES
#include "module.h"
#undef DART_EXPORT_INLINES

struct memory_module* memory_module_create(struct memory_module_configuration* configuration)
{
    struct memory_module* module = memory_module_new_checked(sizeof(struct memory_module));
    module->configuration = memory_module_new_checked(sizeof(struct memory_module_configuration));
    *module->configuration = *configuration;
    return module;
}

void memory_module_destroy(struct memory_module* module)
{
    memory_module_delete(module->configuration);
    memory_module_delete(module);
}
