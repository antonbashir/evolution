#include "module.h"

struct executor_module* executor_module_create(struct executor_module_configuration* configuration)
{
    return executor_module_new_checked(sizeof(struct executor_module));
}

void executor_module_destroy(struct executor_module* module)
{
  executor_module_delete(module);
}
