#include "event.h"
#include <dart/dart.h>
#include <dart_api.h>
#include <printer/printer.h>
#include <stacktrace/stacktrace.h>
#include <strings/format.h>

__thread struct event* local = NULL;

#define raise(format, ...)                                                                                \
    print_message(EVENT_RAISE_FORMAT format NEW_LINE, __FUNCTION__, __FILENAME__, __LINE__, __VA_ARGS__); \
    stacktrace_print(0);                                                                                  \
    exit(-1);                                                                                             \
    unreachable();

#define raise_system(code)                                                                                \
    print_message(EVENT_RAISE_SYSTEM_FORMAT, __FUNCTION__, __FILENAME__, __LINE__, code, strerror(code)); \
    stacktrace_print(0);                                                                                  \
    exit(-1);                                                                                             \
    unreachable();

#define event_set_field(set_event, set_name, set_type, set_value)                    \
    do                                                                               \
    {                                                                                \
        struct event_field_structure* field = event_find_field(set_event, set_name); \
        if (field != NULL)                                                           \
        {                                                                            \
            event_field_set_##set_type(field, set_value);                            \
            break;                                                                   \
        }                                                                            \
        if (event->fields_count == EVENT_FIELDS_MAXIMUM)                             \
        {                                                                            \
            raise(ERROR_EVENT_FIELD_LIMIT_REACHED, EVENT_FIELDS_MAXIMUM);            \
        }                                                                            \
        field = calloc(1, sizeof(struct event_field_structure));                     \
        field->name = set_name;                                                      \
        event_field_set_##set_type(field, set_value);                                \
        event->fields[event->fields_count] = field;                                  \
        ++(event->fields_count);                                                     \
    }                                                                                \
    while (0);

struct event* event_create(uint8_t level, const char* function, const char* file, uint32_t line)
{
    struct event* created = calloc(1, sizeof(struct event));
    if (created == NULL)
    {
        raise_system(ENOMEM);
    }
    created->fields = calloc(EVENT_FIELDS_MAXIMUM, sizeof(struct event_field_structure));
    if (created->fields == NULL)
    {
        raise_system(ENOMEM);
    }
    created->function = function;
    created->file = file;
    created->line = line;
    created->level = level;
    created->timestamp = time_now_real();
    created->raised_module_name = NULL;
    return created;
}

struct event* event_build(uint8_t level, const char* function, const char* file, uint32_t line, size_t fields, ...)
{
    struct event* event = event_create(level, function, file, line);
    va_list args;
    va_start(args, fields);
    for (int i = 0; i < fields; ++i)
    {
        struct event_field_structure field = va_arg(args, struct event_field_structure);
        struct event_field_structure* new_field = calloc(1, sizeof(struct event_field_structure));
        new_field->name = field.name;
        new_field->type = field.type;
        new_field->signed_number = field.signed_number;
        new_field->unsigned_number = field.unsigned_number;
        new_field->double_number = field.double_number;
        new_field->string = field.string;
        event->fields[event->fields_count] = new_field;
        ++event->fields_count;
    }
    va_end(args);
    return event;
}

void event_setup(struct event* event, const char* raised_module_name)
{
    event->raised_module_name = raised_module_name;
}

void event_destroy(struct event* event)
{
    for (int i = 0; i < event->fields_count; ++i) event_field_delete(event->fields[i]);
    free(event->fields);
    free(event);
}

bool event_has_field(struct event* event, const char* name)
{
    return event_find_field(event, name) != NULL;
}

void event_set_boolean(struct event* event, const char* name, bool value)
{
    event_set_field(event, name, boolean, value);
}

void event_set_signed(struct event* event, const char* name, int64_t value)
{
    event_set_field(event, name, signed, value);
}

void event_set_unsigned(struct event* event, const char* name, uint64_t value)
{
    event_set_field(event, name, unsigned, value);
}

void event_set_double(struct event* event, const char* name, double value)
{
    event_set_field(event, name, double, value);
}

void event_set_string(struct event* event, const char* name, const char* value)
{
    event_set_field(event, name, string, value);
}

void event_set_address(struct event* event, const char* name, void* value)
{
    event_set_field(event, name, address, value);
}

void event_set_character(struct event* event, const char* name, char value)
{
    event_set_field(event, name, character, value);
}

char event_get_character(struct event* event, const char* name)
{
    struct event_field_structure* field = event_find_field(event, name);
    if (field == NULL)
    {
        raise(ERROR_EVENT_FIELD_NOT_FOUND, name);
    }
    if (field->type != EVENT_TYPE_CHARACTER)
    {
        raise(ERROR_EVENT_FIELD_NOT_CHARACTER, name);
    }
    return field->character;
}

void* event_get_address(struct event* event, const char* name)
{
    struct event_field_structure* field = event_find_field(event, name);
    if (field == NULL)
    {
        raise(ERROR_EVENT_FIELD_NOT_FOUND, name);
    }
    if (field->type != EVENT_TYPE_ADDRESS)
    {
        raise(ERROR_EVENT_FIELD_NOT_ADDRESS, name);
    }
    return field->address;
}

bool event_get_boolean(struct event* event, const char* name)
{
    struct event_field_structure* field = event_find_field(event, name);
    if (field == NULL)
    {
        raise(ERROR_EVENT_FIELD_NOT_FOUND, name);
    }
    if (field->type != EVENT_TYPE_BOOLEAN)
    {
        raise(ERROR_EVENT_FIELD_NOT_BOOLEAN, name);
    }
    return field->boolean;
}

int64_t event_get_signed(struct event* event, const char* name)
{
    struct event_field_structure* field = event_find_field(event, name);
    if (field == NULL)
    {
        raise(ERROR_EVENT_FIELD_NOT_FOUND, name);
    }
    if (field->type != EVENT_TYPE_SIGNED)
    {
        raise(ERROR_EVENT_FIELD_NOT_SIGNED, name);
    }
    return field->signed_number;
}

uint64_t event_get_unsigned(struct event* event, const char* name)
{
    struct event_field_structure* field = event_find_field(event, name);
    if (field == NULL)
    {
        raise(ERROR_EVENT_FIELD_NOT_FOUND, name);
    }
    if (field->type != EVENT_TYPE_UNSIGNED)
    {
        raise(ERROR_EVENT_FIELD_NOT_UNSIGNED, name);
    }
    return field->unsigned_number;
}

double event_get_double(struct event* event, const char* name)
{
    struct event_field_structure* field = event_find_field(event, name);
    if (field == NULL)
    {
        raise(ERROR_EVENT_FIELD_NOT_FOUND, name);
    }
    if (field->type != EVENT_TYPE_DOUBLE)
    {
        raise(ERROR_EVENT_FIELD_NOT_DOUBLE, name);
    }
    return field->double_number;
}

const char* event_get_string(struct event* event, const char* name)
{
    struct event_field_structure* field = event_find_field(event, name);
    if (field == NULL)
    {
        raise(ERROR_EVENT_FIELD_NOT_FOUND, name);
    }
    if (field->type != EVENT_TYPE_STRING)
    {
        raise(ERROR_EVENT_FIELD_NOT_STRING, name);
    }
    return field->string;
}

bool event_field_is_signed(struct event* event, const char* name)
{
    struct event_field_structure* field = event_find_field(event, name);
    if (field == NULL)
    {
        return false;
    }
    return field->type == EVENT_TYPE_SIGNED;
}

bool event_field_is_unsigned(struct event* event, const char* name)
{
    struct event_field_structure* field = event_find_field(event, name);
    if (field == NULL)
    {
        return false;
    }
    return field->type == EVENT_TYPE_UNSIGNED;
}

const char* event_get_module(struct event* event)
{
    return event->raised_module_name;
}

uint8_t event_get_level(struct event* event)
{
    return event->level;
}

void event_set_local(struct event* event)
{
    local = event;
}

void event_propagate_local(struct event* event)
{
    Dart_EnterScope();
    event_put_stack_trace(event);
    Dart_Handle arguments[] = {dart_from_unsigned((intptr_t)event)};
    if (dart_call_static(DART_CORE_LOCAL_FILE, DART_CORE_LOCAL_EVENT_CLASS, DART_PRODUCE_FUNCTION, arguments) != NULL) local = event;
    Dart_ExitScope();
    event_set_local(event);
}

void event_put_stack_trace(struct event* event)
{
    char stack_trace_buffer[STACKTRACE_PRINT_BUFFER];
    struct stacktrace trace;
    stacktrace_collect_current(&trace, 1);
    if (stacktrace_format(&trace, stack_trace_buffer, STACKTRACE_PRINT_BUFFER) > 0)
    {
        event_set_string(event, EVENT_FIELD_STACK_TRACE, strdupa(stack_trace_buffer));
    }
}

struct event* event_get_local()
{
    return local;
}

bool event_has_local(struct event* event)
{
    return local != NULL;
}

void event_clear_local(bool propagate_to_dart)
{
    local = NULL;
    if (propagate_to_dart)
    {
        event_propagate_local(NULL);
        return;
    }
    event_set_local(NULL);
}

const char* event_format(struct event* event)
{
    size_t size = 0;
    int32_t written = 0;
    char* buffer = calloc(EVENT_BUFFER, sizeof(char));
    if (buffer == NULL)
    {
        raise_system(ENOMEM);
    }
    const char* type = EVENT_LEVEL_UNKNOWN_LABEL;
    switch (event->level)
    {
        case EVENT_LEVEL_TRACE:
            type = EVENT_LEVEL_TRACE_LABEL;
            break;
        case EVENT_LEVEL_INFORMATION:
            type = EVENT_LEVEL_INFORMATION_LABEL;
            break;
        case EVENT_LEVEL_WARNING:
            type = EVENT_LEVEL_WARNING_LABEL;
            break;
        case EVENT_LEVEL_ERROR:
            type = EVENT_LEVEL_ERROR_LABEL;
            break;
        case EVENT_LEVEL_PANIC:
            type = EVENT_LEVEL_PANIC_LABEL;
            break;
    }
    written = snprintf(buffer, EVENT_BUFFER, EVENT_FORMAT, time_format_local(event->timestamp), type, event->function, event->file, event->line);
    if (written < 0)
    {
        return buffer;
    }
    size += written;
    if (event->raised_module_name != NULL)
    {
        written = snprintf(buffer + size, EVENT_BUFFER - size, EVENT_MODULE_PART, event->raised_module_name);
        if (written < 0)
        {
            return buffer;
        }
        size += written;
    }
    struct event_field_structure* field;
    for (int i = 0; i < event->fields_count; ++i)
    {
        field = event->fields[i];
        switch (field->type)
        {
            case EVENT_TYPE_BOOLEAN:
                written = snprintf(buffer + size, EVENT_BUFFER - size, EVENT_FIELD_BOOLEAN_FORMAT, field->name, field->boolean ? TRUE_LABEL : FALSE_LABEL);
                break;
            case EVENT_TYPE_UNSIGNED:
                written = snprintf(buffer + size, EVENT_BUFFER - size, EVENT_FIELD_UNSIGNED_FORMAT, field->name, field->unsigned_number);
                break;
            case EVENT_TYPE_SIGNED:
                written = snprintf(buffer + size, EVENT_BUFFER - size, EVENT_FIELD_SIGNED_FORMAT, field->name, field->signed_number);
                break;
            case EVENT_TYPE_DOUBLE:
                written = snprintf(buffer + size, EVENT_BUFFER - size, EVENT_FIELD_DOUBLE_FORMAT, field->name, field->double_number);
                break;
            case EVENT_TYPE_STRING:
                written = snprintf(buffer + size, EVENT_BUFFER - size, EVENT_FIELD_STRING_FORMAT, field->name, field->string);
                break;
            case EVENT_TYPE_ADDRESS:
                written = snprintf(buffer + size, EVENT_BUFFER - size, EVENT_FIELD_ADDRESS_FORMAT, field->name, field->address);
                break;
            case EVENT_TYPE_CHARACTER:
                written = snprintf(buffer + size, EVENT_BUFFER - size, EVENT_FIELD_CHARACTER_FORMAT, field->name, field->character);
                break;
        }
        if (written < 0)
        {
            return buffer;
        }
        size += written;
    }
    return buffer;
}