#include <common/common.h>
#include <common/errors.h>
#include <common/factory.h>
#include <common/library.h>
#include <system/types.h>

#define module_combine(a, b) a##_##b
#define module_evaluate_combine(a, b) module_combine(a, b)
#define module_to_string(x) #x
#define module_label module_to_string(module_name)
#define _module(x) module_evaluate_combine(module_name, x)

#ifndef MODULE_HEADER
#define MODULE_HEADER

static const uint32_t _module(module_id) = module_id;
static const char* _module(module_name) = module_label;

void _module(error_exit)(uint32_t code, const char* message)
{
    error_exit(module_label, code, message);
}

void _module(error_system_exit)(uint32_t code)
{
    error_system_exit(module_label, code);
}

void _module(allocate_single)(size_t size)
{
    allocate(module_label, 1, size);
}

void _module(allocate_many)(size_t count, size_t size)
{
    allocate(module_label, count, size);
}

#endif

#if defined(MODULE_SOURCE) || defined(MODULE_UNDEF)
#undef MODULE_HEADER
#undef module_name
#undef module_id
#endif

#undef module_combine
#undef module_evaluate_combine
#undef module_to_string
#undef module_label
#undef module_id_label
#undef _module
