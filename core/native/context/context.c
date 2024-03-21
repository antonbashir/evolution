#include "context.h"
#include <dart_api.h>
#include <panic/panic.h>
#include <printer/printer.h>

struct context context_instance;

struct context* context_get()
{
    return &context_instance;
}

void context_create()
{
    if (context_instance.initialized)
    {
        raise_panic(event_panic(event_field_message(PANIC_CONTEXT_CREATED)));
    }
    context_instance.modules = simple_map_modules_new();
    context_instance.containers = calloc(MODULES_MAXIMUM, sizeof(struct module_container));
    if (context_instance.modules == NULL || context_instance.containers == NULL)
    {
        raise_panic(event_system_panic(ENOMEM));
    }
    context_instance.initialized = true;
    context_instance.size = 0;
    Dart_EnterScope();
    context_instance.context_field = Dart_GetField(Dart_LookupLibrary(Dart_NewStringFromUTF8((const uint8_t*)DART_CORE_LIBRARY, strlen(DART_CORE_LIBRARY))), Dart_NewStringFromUTF8((const uint8_t*)DART_CONTEXT_FIELD, strlen(DART_CONTEXT_FIELD)));
    if (Dart_IsError(context_instance.context_field))
    {
        Dart_PropagateError(context_instance.context_field);
    }
    Dart_ExitScope();
}

void* context_get_module(const char* name)
{
    simple_map_int_t slot = simple_map_modules_find(context_instance.modules, name, NULL);
    if (slot != simple_map_end(context_instance.modules))
    {
        return simple_map_modules_node(context_instance.modules, slot)->module;
    }
    return NULL;
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

DART_LEAF_FUNCTION void context_load()
{
    Dart_EnterScope();
    for (int i = 0; i < context_instance.size; i++)
    {
        struct module_container container = context_instance.containers[i];
        intptr_t librariesCount;
        Dart_Handle libraries = Dart_GetLoadedLibraries();
        Dart_ListLength(libraries, &librariesCount);
        for (int libraryIndex = 0; libraryIndex < librariesCount; libraryIndex++)
        {
            Dart_Handle library = Dart_ListGetAt(libraries, libraryIndex);
            if (Dart_IsError(library) || Dart_IsNull(library)) continue;
            Dart_Handle className = Dart_NewStringFromUTF8((const uint8_t*)container.type, strlen(container.type));
            Dart_Handle class = Dart_GetClass(library, className);
            if (Dart_IsError(class) || Dart_IsNull(class)) continue;
            Dart_Handle constructor = Dart_NewStringFromUTF8((const uint8_t*)DART_MODULE_FACTORY, strlen(DART_MODULE_FACTORY));
            Dart_Handle arguments[1];
            arguments[0] = Dart_NewIntegerFromUint64((uint64_t)container.module);
            Dart_Handle createdModule = Dart_New(class, constructor, 1, arguments);
            if (Dart_IsError(createdModule))
            {
                Dart_PropagateError(createdModule);
            }
        }
    }
    context_instance.context_field = Dart_GetField(Dart_LookupLibrary(Dart_NewStringFromUTF8((const uint8_t*)DART_CORE_LIBRARY, strlen(DART_CORE_LIBRARY))), Dart_NewStringFromUTF8((const uint8_t*)DART_CONTEXT_FIELD, strlen(DART_CONTEXT_FIELD)));
    if (Dart_IsError(context_instance.context_field))
    {
        Dart_PropagateError(context_instance.context_field);
    }
    Dart_ExitScope();
}

void context_set_local_event(struct event* event)
{
    Dart_EnterScope();
    Dart_Handle arguments[1];
    arguments[0] = Dart_NewIntegerFromUint64((uint64_t)event);
    Dart_Handle createdModule = Dart_Invoke(context_instance.context_field, Dart_NewStringFromUTF8((const uint8_t*)DART_CONTEXT_ON_NATIVE_EVENT_FUNCTION, strlen(DART_CONTEXT_ON_NATIVE_EVENT_FUNCTION)), 1, arguments);
    if (Dart_IsError(createdModule))
    {
        Dart_PropagateError(createdModule);
    }
    Dart_ExitScope();
}