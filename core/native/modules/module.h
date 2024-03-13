#include <common/common.h>
#include <context/context.h>
#include <events/events.h>
#include <panic/panic.h>
#include <printer/printer.h>
#include <stacktrace/stacktrace.h>
#include <system/library.h>

#define module_combine(a, b) a##_module_##b
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
#define module_name _unknown
#endif

struct _unknown_module_configuration
{
};
#ifndef module_configuration
#define module_configuration struct _unknown_module_configuration
#endif

struct _unknown_module
{
    struct _unknown_module_configuration configuration;
};
#ifndef module_structure
#define module_structure struct _unknown_module
#endif

#ifndef module_id
#define module_id 0
#endif

static const uint32_t _declare_module_id = module_id;
static const char* _declare_module_name = _declare_module_label;

static FORCEINLINE module_structure* module_name()
{
    return context_get_module(_declare_module_id);
}

static FORCEINLINE struct event* _module(event)(struct event* event)
{
    event_setup(event, _declare_module_id, _declare_module_name);
    return event;
}

static FORCEINLINE void* _module(new)(uint32_t size)
{
    trace_event(_module(event)(event_trace(event_field(MODULE_EVENT_FIELD_CALLER, stacktrace_callers(1, 3)))));
    return calloc(1, size);
}

static FORCEINLINE void* _module(new_checked)(uint32_t size)
{
    trace_event(_module(event)(event_trace(event_field(MODULE_EVENT_FIELD_CALLER, stacktrace_callers(1, 3)))));
    void* object = calloc(1, size);
    if (unlikely(object == NULL))
    {
        raise_panic(_module(event)(event_system_panic(ENOMEM)));
    }
    return object;
}

static FORCEINLINE void* _module(allocate)(uint32_t count, uint32_t size)
{
    trace_event(_module(event)(event_trace(event_field(MODULE_EVENT_FIELD_CALLER, stacktrace_callers(1, 3)))));
    return calloc(count, size);
}

static FORCEINLINE void* _module(allocate_checked)(uint32_t count, uint32_t size)
{
    trace_event(_module(event)(event_trace(event_field(MODULE_EVENT_FIELD_CALLER, stacktrace_callers(1, 3)))));
    void* object = calloc(count, size);
    if (unlikely(object == NULL))
    {
        raise_panic(_module(event)(event_system_panic(ENOMEM)));
    }
    return object;
}

static FORCEINLINE void _module(check_object)(void* object)
{
    trace_event(_module(event)(event_trace(event_field(MODULE_EVENT_FIELD_CALLER, stacktrace_callers(1, 3)))));
    if (unlikely(object == NULL))
    {
        raise_panic(_module(event)(event_system_panic(ENOMEM)));
    }
}

static FORCEINLINE void _module(check_code)(int32_t code)
{
    trace_event(_module(event)(event_trace(event_field(MODULE_EVENT_FIELD_CALLER, stacktrace_callers(1, 3)))));
    if (unlikely(code != 0))
    {
        raise_panic(_module(event)(event_system_panic(ENOMEM)));
    }
}

static FORCEINLINE void _module(delete)(void* object)
{
    trace_event(_module(event)(event_trace(event_field(MODULE_EVENT_FIELD_CALLER, stacktrace_callers(1, 3)))));
    free(object);
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
#undef _declare_module_getter
#undef _declare_module_id
#undef _declare_module_name
#undef _declare_module_label
#undef _module_new
#undef _module_allocate
#undef _module_delete