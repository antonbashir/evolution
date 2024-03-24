#include "context.h"
#include <dart_api.h>
#include <hashing/hashing_64.h>
#include <panic/panic.h>
#include <printer/printer.h>
#include "dart/dart.h"

struct context_structure context_instance;

struct context_structure* context_get()
{
    return &context_instance;
}

void context_create()
{
    if (context_instance.initialized) return;
    context_instance.modules = simple_map_modules_new();
    context_instance.containers = calloc(MODULES_MAXIMUM, sizeof(struct module_container));
    if (context_instance.modules == NULL || context_instance.containers == NULL)
    {
        raise_panic(event_system_panic(ENOMEM));
    }
    context_instance.initialized = true;
    context_instance.size = 0;
}

void* context_get_module(const char* name)
{
    return safe_field(simple_map_modules_find_value(context_instance.modules, name), module);
}

void context_put_module(const char* name, void* module, const char* type)
{
    struct module_container container = {
        .id = context_instance.size,
        .name = strdup(name),
        .module = module,
        .type = type,
    };
    memcpy(&context_instance.containers[context_instance.size], &container, sizeof(struct module_container));
    simple_map_modules_put_copy(context_instance.modules, &container, NULL, NULL);
    context_instance.size++;
}

void context_remove_module(const char* name)
{
    simple_map_int_t slot = simple_map_modules_find(context_instance.modules, name, NULL);
    if (slot != simple_map_end(context_instance.modules))
    {
        struct module_container* container = simple_map_modules_node(context_instance.modules, slot);
        free((void*)container->name);
        memset(&context_instance.containers[container->id], 0, sizeof(struct module_container));
        simple_map_modules_del(context_instance.modules, slot, NULL);
    }
    context_instance.size--;
}

void context_load()
{
    Dart_EnterScope();
    for (int i = 0; i < context_instance.size; i++)
    {
        struct module_container container = context_instance.containers[i];
        Dart_Handle arguments[] = {dart_from_unsigned((uintptr_t)container.module)};
        dart_call_constructor(dart_find_class(container.type), DART_LOAD_FUNCTION, arguments);
    }
    Dart_ExitScope();
}