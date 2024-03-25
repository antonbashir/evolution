#include "module.h"

struct storage_module* storage_module_create(struct storage_module_configuration* configuration)
{
    return storage_module_construct(configuration);
}

void storage_module_destroy(struct storage_module* module)
{
    storage_module_delete(module);
}
