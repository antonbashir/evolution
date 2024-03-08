#include <common/common.h>
#include <common/errors.h>
#include <common/factory.h>
#include <common/library.h>
#include <system/types.h>

#define module_combine(a, b) a##_##b
#define module_append(a, b) a##b
#define module_to_string(x) #x
#define module_evaluate_combine(a, b) module_combine(a, b)
#define module_evaluate_append(a, b) module_append(a, b)
#define module_evaluate_to_string(x) module_to_string(x)
#define _module(x) module_evaluate_combine(module_name, x)
#define _declare_module_id module_evaluate_append(module_name, _module_id)
#define _declare_module_name module_evaluate_append(module_name, _module_name)
#define _declare_module_label module_evaluate_to_string(module_name)

#ifndef MODULE_HEADER
#define MODULE_HEADER

#ifndef module_name
#define module_name default
#endif

#ifndef module_id
#define module_id 0
#endif

static const uint32_t _declare_module_id = module_id;
static const char* _declare_module_name = _declare_module_label;

void _module(allocate_single)(size_t size)
{
    allocate(_declare_module_label, 1, size);
}

void _module(allocate_many)(size_t count, size_t size)
{
    allocate(_declare_module_label, count, size);
}

#endif

#if defined(MODULE_SOURCE) || defined(MODULE_UNDEF)
#undef MODULE_HEADER
#undef module_name
#undef module_id
#undef module_label
#endif

#undef module_combine
#undef module_append
#undef module_to_string
#undef module_evaluate_combine
#undef module_evaluate_append
#undef module_evaluate_to_string
#undef module_to_string
#undef _module
#undef _declare_module_id
#undef _declare_module_name
