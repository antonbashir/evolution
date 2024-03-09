#include "error.h"

#define error_exit(format, ...)                                                                     \
    printf("(error): %s(...) %s:%d - " format "\n", __FUNCTION__, __FILE__, __LINE__, __VA_ARGS__); \
    stacktrace_print(0);                                                                            \
    exit(-1);                                                                                       \
    unreachable();

#define error_exit_system(code)                                                                                         \
    printf("(error): %s(...) %s:%d - code = %d, message = %s", __FUNCTION__, __FILE__, __LINE__, code, strerror(code)); \
    stacktrace_print(0);                                                                                                \
    exit(-1);                                                                                                           \
    unreachable();

#define error_find_field(error, name)                     \
    ({                                                    \
        struct event_field* field;                        \
        for (int i = 0; i < error->fields_count; ++i)     \
        {                                                 \
            struct event_field* field = error->fields[i]; \
            if (strcmp(name, field->name) == 0)           \
                break;                                    \
        }                                                 \
        field;                                            \
    })

#define error_set_field(error, name, type, value)                                         \
    do                                                                                    \
    {                                                                                     \
        struct event_field* field = error_find_field(error, name);                        \
        if (field != NULL)                                                                \
        {                                                                                 \
            event_field_set_##type(field, value);                                         \
            break;                                                                        \
        }                                                                                 \
        if (error->fields_count == MODULE_ERROR_FIELDS_MAXIMUM)                           \
        {                                                                                 \
            error_exit("error fields limit is reached: %d", MODULE_ERROR_FIELDS_MAXIMUM); \
        }                                                                                 \
        field = calloc(1, sizeof(struct event_field));                                    \
        field->name = name;                                                               \
        event_field_set_##type(field, value);                                             \
        error->fields[error->fields_count] = field;                                       \
        ++error->fields_count;                                                            \
    }                                                                                     \
    while (0);

struct error* error_create(const char* function, const char* file, uint32_t line, const char* message)
{
    struct error* created = calloc(1, sizeof(struct error));
    if (created == NULL)
    {
        error_exit_system(ENOMEM);
    }
    created->fields = calloc(MODULE_ERROR_FIELDS_MAXIMUM, sizeof(struct event_field));
    if (created->fields == NULL)
    {
        error_exit_system(ENOMEM);
    }
    created->function = function;
    created->file = file;
    created->line = line;
    created->message = message;
    return created;
}

struct error* error_build(const char* function, const char* file, uint32_t line, const char* message, size_t fields, ...)
{
    struct error* error = error_create(function, file, line, message);
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
        error->fields[error->fields_count] = new_field;
        ++error->fields_count;
    }
    va_end(args);
    return error;
}

void error_setup(struct error* error, uint32_t module_id, const char* module_name)
{
    error->module_id = module_id;
    error->module_name = module_name;
}

void error_destroy(struct error* error)
{
    for (int i = 0; i < error->fields_count; ++i) free(error->fields[i]);
    free(error->fields);
    free(error);
}

void error_set_boolean(struct error* error, const char* name, bool value)
{
    error_set_field(error, name, boolean, value);
}

void error_set_signed(struct error* error, const char* name, int64_t value)
{
    error_set_field(error, name, signed, value);
}

void error_set_unsigned(struct error* error, const char* name, uint64_t value)
{
    error_set_field(error, name, unsigned, value);
}

void error_set_double(struct error* error, const char* name, double value)
{
    error_set_field(error, name, double, value);
}

void error_set_string(struct error* error, const char* name, const char* value)
{
    error_set_field(error, name, string, value);
}

bool error_get_boolean(struct error* error, const char* name)
{
    struct event_field* field = error_find_field(error, name);
    if (field == NULL)
    {
        error_exit("error field %s is not found", name);
    }
    return field->signed_number;
}

int64_t error_get_signed(struct error* error, const char* name)
{
    struct event_field* field = error_find_field(error, name);
    if (field == NULL)
    {
        error_exit("error field %s is not found", name);
    }
    return field->signed_number;
}

uint64_t error_get_unsigned(struct error* error, const char* name)
{
    struct event_field* field = error_find_field(error, name);
    if (field == NULL)
    {
        error_exit("error field %s is not found", name);
    }
    return field->unsigned_number;
}

double error_get_double(struct error* error, const char* name)
{
    struct event_field* field = error_find_field(error, name);
    if (field == NULL)
    {
        error_exit("error field %s is not found", name);
    }
    return field->double_number;
}

const char* error_get_string(struct error* error, const char* name)
{
    struct event_field* field = error_find_field(error, name);
    if (field == NULL)
    {
        error_exit("error field %s is not found", name);
    }
    return field->string;
}

const char* error_format(struct error* error)
{
    size_t size = 0;
    int32_t written = 0;
    char* buffer = calloc(MODULE_ERROR_BUFFER, sizeof(char));
    if (buffer == NULL)
    {
        error_exit_system(ENOMEM);
    }
    written = snprintf(buffer, MODULE_ERROR_BUFFER, "(error): %s(...) %s:%d\n", error->function, error->file, error->line);
    if (written < 0)
    {
        return buffer;
    }
    size += written;
    if (error->module_id != 0 && strlen(error->module_name) != 0)
    {
        written = snprintf(buffer + size, MODULE_ERROR_BUFFER - size, "module{%d} = %s\n", error->module_id, error->module_name);
    }
    if (written < 0)
    {
        return buffer;
    }
    size += written;
    struct event_field* field;
    for (int i = 0; i < error->fields_count; ++i)
    {
        field = error->fields[i];
        switch (field->type)
        {
            case MODULE_EVENT_TYPE_UNSIGNED:
                written = snprintf(buffer + size, MODULE_ERROR_BUFFER - size, "%s = %ld\n", field->name, field->unsigned_number);
                break;
            case MODULE_EVENT_TYPE_SIGNED:
                written = snprintf(buffer + size, MODULE_ERROR_BUFFER - size, "%s = %ld\n", field->name, field->signed_number);
                break;
            case MODULE_EVENT_TYPE_DOUBLE:
                written = snprintf(buffer + size, MODULE_ERROR_BUFFER - size, "%s = %lf\n", field->name, field->double_number);
                break;
            case MODULE_EVENT_TYPE_STRING:
                written = snprintf(buffer + size, MODULE_ERROR_BUFFER - size, "%s = %s\n", field->name, field->string);
                break;
        }
        if (written < 0)
        {
            return buffer;
        }
        size += written;
    }
    snprintf(buffer + size, MODULE_ERROR_BUFFER - size, "message = %s\n", error->message);
    return buffer;
}

void error_raise(struct error* error)
{
    const char* format = error_format(error);
    printf("%s\n", format);
    stacktrace_print(0);
    exit(-1);
    unreachable();
}

void error_print(struct error* error)
{
    const char* format = error_format(error);
    printf("%s\n", format);
}