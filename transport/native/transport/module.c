#include "module.h"

struct transport_module* transport_module_create(struct transport_module_configuration* configuration)
{
    return transport_module_construct(configuration);
}

void transport_module_destroy(struct transport_module* module)
{
    transport_module_delete(module);
}