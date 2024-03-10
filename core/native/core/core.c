#include "core.h"

extern struct core_module* core();

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
    system_initialize((struct system_configuration){
        .on_print = configuration->silent ? empty_printer : system_default_printer,
        .on_print_error = configuration->silent ? empty_error_printer : system_default_error_printer,
        .on_event_print = configuration->silent ? empty_event_printer : system_default_event_printer,
        .on_event_raise = system_default_event_raiser,
        .print_level = configuration->print_level,
    });
    struct core_module* module = core_module_new_checked(sizeof(struct core_module));
    module->id = core_module_id;
    module->name = core_module_name;
    module->configuration = core_module_new_checked(sizeof(struct core_module_configuration));
    *module->configuration = *configuration;
    module->configuration->component = core_module_new_checked(strlen(configuration->component));
    strcpy((char*)module->configuration->component, configuration->component);
    return module;
}

void core_module_destroy(struct core_module* module)
{
    core_module_delete((void*)module->configuration->component);
    core_module_delete(module->configuration);
    core_module_delete(module);
}
