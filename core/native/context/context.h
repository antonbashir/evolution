#ifndef CORE_CONTEXT_H
#define CORE_CONTEXT_H

#include <collections/maps.h>
#include <common/common.h>
#include <common/constants.h>
#include <events/event.h>
#include <hashing/hashing.h>
#include <system/library.h>

#if defined(__cplusplus)
extern "C"
{
#endif

DART_STRUCTURE struct context_structure
{
    DART_FIELD bool initialized;
    DART_FIELD size_t size;
    DART_FIELD struct module_container* containers;
    struct simple_map_modules_t* modules;
};

DART_LEAF_FUNCTION struct context_structure* context_get();
DART_LEAF_FUNCTION void context_create();
DART_LEAF_FUNCTION void* context_get_module(const char* name);
DART_LEAF_FUNCTION void context_put_module(const char* name, void* module, const char* type);
DART_LEAF_FUNCTION void context_remove_module(const char* name);
DART_LEAF_FUNCTION void context_set_local_event(struct event* event);
DART_FUNCTION void context_load();

#if defined(__cplusplus)
}
#endif

#endif