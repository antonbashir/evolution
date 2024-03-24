#include "module.h"

struct core_module* core_module_create(struct core_module_configuration* configuration)
{
    return core_module_construct(configuration);
}

void core_module_destroy(struct core_module* module)
{
    core_module_delete(module);
}
