#include "event.h"
#include <printer/printer.h>
#include <stacktrace/stacktrace.h>
#include <strings/format.h>
#include "field.h"

#define _raise(format, ...)                                                                                    \
    print_message("(panic): %s(...) %s:%d - " format "\n", __FUNCTION__, __FILENAME__, __LINE__, __VA_ARGS__); \
    stacktrace_print(0);                                                                                       \
    exit(-1);                                                                                                  \
    unreachable();

#define _raise_system(code)                                                                                                        \
    print_message("(panic): %s(...) %s:%d - code = %d, message = %s", __FUNCTION__, __FILENAME__, __LINE__, code, strerror(code)); \
    stacktrace_print(0);                                                                                                           \
    exit(-1);                                                                                                                      \
    unreachable();

#define event_set_field(event, name, type, value)                                     \
    do                                                                                \
    {                                                                                 \
        struct event_field* field = event_find_field(event, name);                    \
        if (field != NULL)                                                            \
        {                                                                             \
            event_field_set_##type(field, value);                                     \
            break;                                                                    \
        }                                                                             \
        if (event->fields_count == MODULE_EVENT_FIELDS_MAXIMUM)                       \
        {                                                                             \
            _raise("event fields limit is reached: %d", MODULE_EVENT_FIELDS_MAXIMUM); \
        }                                                                             \
        field = calloc(1, sizeof(struct event_field));                                \
        field->name = name;                                                           \
        event_field_set_##type(field, value);                                         \
        event->fields[event->fields_count] = field;                                   \
        ++(event->fields_count);                                                      \
    }                                                                                 \
    while (0);

static FORCEINLINE struct event_field* event_find_field(struct event* event, const char* name)
{
    struct event_field* field = NULL;
    for (int i = 0; i < event->fields_count; ++i)
    {
        field = event->fields[i];
        if (strcmp(name, field->name) == 0)
            break;
        field = NULL;
    }
    return field;
}

struct event* event_create(uint8_t level, const char* function, const char* file, uint32_t line, const char* message)
{
    struct event* created = calloc(1, sizeof(struct event));
    if (created == NULL)
    {
        _raise_system(ENOMEM);
    }
    created->fields = calloc(MODULE_EVENT_FIELDS_MAXIMUM, sizeof(struct event_field));
    if (created->fields == NULL)
    {
        _raise_system(ENOMEM);
    }
    created->function = function;
    created->file = file;
    created->line = line;
    created->message = message;
    created->level = level;
    created->timestamp = time_now_real();
    created->raised_module_id = MODULE_UNKNOWN;
    created->raised_module_name = MODULE_UNKNOWN_NAME;
    return created;
}

struct event* event_build(uint8_t level, const char* function, const char* file, uint32_t line, const char* message, size_t fields, ...)
{
    struct event* event = event_create(level, function, file, line, message);
    va_list args;
    va_start(args, fields);
    for (int i = 0; i < fields; ++i)
    {
        struct event_field field = va_arg(args, struct event_field);
        struct event_field* new_field = calloc(1, sizeof(struct event_field));
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

void event_setup(struct event* event, uint32_t raised_module_id, const char* raised_module_name)
{
    event->raised_module_id = raised_module_id;
    event->raised_module_name = raised_module_name;
}

void event_destroy(struct event* event)
{
    for (int i = 0; i < event->fields_count; ++i) free(event->fields[i]);
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
    struct event_field* field = event_find_field(event, name);
    if (field == NULL)
    {
        _raise("event field %s is not found", name);
    }
    return field->character;
}

void* event_get_address(struct event* event, const char* name)
{
    struct event_field* field = event_find_field(event, name);
    if (field == NULL)
    {
        _raise("event field %s is not found", name);
    }
    return field->address;
}

bool event_get_boolean(struct event* event, const char* name)
{
    struct event_field* field = event_find_field(event, name);
    if (field == NULL)
    {
        _raise("event field %s is not found", name);
    }
    return field->boolean;
}

int64_t event_get_signed(struct event* event, const char* name)
{
    struct event_field* field = event_find_field(event, name);
    if (field == NULL)
    {
        _raise("event field %s is not found", name);
    }
    return field->signed_number;
}

uint64_t event_get_unsigned(struct event* event, const char* name)
{
    struct event_field* field = event_find_field(event, name);
    if (field == NULL)
    {
        _raise("event field %s is not found", name);
    }
    return field->unsigned_number;
}

double event_get_double(struct event* event, const char* name)
{
    struct event_field* field = event_find_field(event, name);
    if (field == NULL)
    {
        _raise("event field %s is not found", name);
    }
    return field->double_number;
}

const char* event_get_string(struct event* event, const char* name)
{
    struct event_field* field = event_find_field(event, name);
    if (field == NULL)
    {
        _raise("event field %s is not found", name);
    }
    return field->string;
}

const char* event_format(struct event* event)
{
    size_t size = 0;
    int32_t written = 0;
    char* buffer = calloc(MODULE_EVENT_BUFFER, sizeof(char));
    if (buffer == NULL)
    {
        _raise_system(ENOMEM);
    }
    const char* type = MODULE_EVENT_LEVEL_UNKNOWN_LABEL;
    switch (event->level)
    {
        case MODULE_EVENT_LEVEL_TRACE:
            type = MODULE_EVENT_LEVEL_TRACE_LABEL;
            break;
        case MODULE_EVENT_LEVEL_INFORMATION:
            type = MODULE_EVENT_LEVEL_INFORMATION_LABEL;
            break;
        case MODULE_EVENT_LEVEL_WARNING:
            type = MODULE_EVENT_LEVEL_WARNING_LABEL;
            break;
        case MODULE_EVENT_LEVEL_ERROR:
            type = MODULE_EVENT_LEVEL_ERROR_LABEL;
            break;
        case MODULE_EVENT_LEVEL_PANIC:
            type = MODULE_EVENT_LEVEL_PANIC_LABEL;
            break;
    }
    written = snprintf(buffer, MODULE_EVENT_BUFFER, "[%s] %s: %s(...) %s:%d\n", time_format_local(event->timestamp), type, event->function, event->file, event->line);
    if (written < 0)
    {
        return buffer;
    }
    size += written;
    if (event->raised_module_id != MODULE_UNKNOWN)
    {
        written = snprintf(buffer + size, MODULE_EVENT_BUFFER - size, "module{%d} = %s\n", event->raised_module_id, event->raised_module_name);
        if (written < 0)
        {
            return buffer;
        }
        size += written;
    }
    struct event_field* field;
    for (int i = 0; i < event->fields_count; ++i)
    {
        field = event->fields[i];
        switch (field->type)
        {
            case MODULE_EVENT_TYPE_BOOLEAN:
                written = snprintf(buffer + size, MODULE_EVENT_BUFFER - size, "%s = %s\n", field->name, field->boolean ? "true" : "false");
                break;
            case MODULE_EVENT_TYPE_UNSIGNED:
                written = snprintf(buffer + size, MODULE_EVENT_BUFFER - size, "%s = %ld\n", field->name, field->unsigned_number);
                break;
            case MODULE_EVENT_TYPE_SIGNED:
                written = snprintf(buffer + size, MODULE_EVENT_BUFFER - size, "%s = %ld\n", field->name, field->signed_number);
                break;
            case MODULE_EVENT_TYPE_DOUBLE:
                written = snprintf(buffer + size, MODULE_EVENT_BUFFER - size, "%s = %lf\n", field->name, field->double_number);
                break;
            case MODULE_EVENT_TYPE_STRING:
                written = snprintf(buffer + size, MODULE_EVENT_BUFFER - size, "%s = %s\n", field->name, field->string);
                break;
            case MODULE_EVENT_TYPE_ADDRESS:
                written = snprintf(buffer + size, MODULE_EVENT_BUFFER - size, "%s = %p\n", field->name, field->address);
                break;
            case MODULE_EVENT_TYPE_CHARACTER:
                written = snprintf(buffer + size, MODULE_EVENT_BUFFER - size, "%s = %c\n", field->name, field->character);
                break;
        }
        if (written < 0)
        {
            return buffer;
        }
        size += written;
    }
    if (strlen(event->message) != 0)
    {
        snprintf(buffer + size, MODULE_EVENT_BUFFER - size, "message = %s\n", event->message);
    }
    return buffer;
}