#include "error.h"

#define error_find_field(error, name)                     \
    ({                                                    \
        struct error_field* field;                        \
        for (int i = 0; i < error->fields_count; ++i)     \
        {                                                 \
            struct error_field* field = error->fields[i]; \
            if (strcmp(name, field->name) == 0)           \
                break;                                    \
        }                                                 \
        field;                                            \
    })

#define error_set_field(error, name, type, value)                  \
    do                                                             \
    {                                                              \
        struct error_field* field = error_find_field(error, name); \
        if (field != NULL)                                         \
        {                                                          \
            error_field_set_##type(field, value);                  \
            break;                                                 \
        }                                                          \
        if (error->fields_count == MODULE_ERROR_FIELDS_MAXIMUM)    \
        {                                                          \
            exit(-1);                                              \
            unreachable();                                         \
        }                                                          \
        field = calloc(1, sizeof(struct error_field));             \
        field->name = name;                                        \
        error_field_set_##type(field, value);                      \
        error->fields[error->fields_count] = field;                \
        ++error->fields_count;                                     \
    }                                                              \
    while (0);

struct error* error_create(const char* function, const char* file, uint32_t line, const char* message)
{
    struct error* created = calloc(1, sizeof(struct error));
    if (created == NULL)
    {
        exit(-1);
        unreachable();
    }
    created->fields = calloc(MODULE_ERROR_FIELDS_MAXIMUM, sizeof(struct error_field));
    if (created->fields == NULL)
    {
        exit(-1);
        unreachable();
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
        struct error_field field = va_arg(args, struct error_field);
        struct error_field* new_field = calloc(1, sizeof(struct error_field));
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
    struct error_field* field = error_find_field(error, name);
    if (field == NULL)
    {
        exit(-1);
        unreachable();
    }
    return field->signed_number;
}

int64_t error_get_signed(struct error* error, const char* name)
{
    struct error_field* field = error_find_field(error, name);
    if (field == NULL)
    {
        exit(-1);
        unreachable();
    }
    return field->signed_number;
}

uint64_t error_get_unsigned(struct error* error, const char* name)
{
    struct error_field* field = error_find_field(error, name);
    if (field == NULL)
    {
        exit(-1);
        unreachable();
    }
    return field->unsigned_number;
}

double error_get_double(struct error* error, const char* name)
{
    struct error_field* field = error_find_field(error, name);
    if (field == NULL)
    {
        exit(-1);
        unreachable();
    }
    return field->double_number;
}

const char* error_get_string(struct error* error, const char* name)
{
    struct error_field* field = error_find_field(error, name);
    if (field == NULL)
    {
        exit(-1);
        unreachable();
    }
    return field->string;
}

const char* error_format(struct error* error)
{
    size_t size = 0;
    char* buffer = calloc(MODULE_ERROR_BUFFER, sizeof(char));
    if (buffer == NULL)
    {
        exit(-1);
        unreachable();
    }
    size += snprintf(buffer, MODULE_ERROR_BUFFER, "(error): %s(...) %s:%d\n", error->function, error->file, error->line);
    struct error_field* field;
    for (int i = 0; i < error->fields_count; ++i)
    {
        field = error->fields[i];
        switch (field->type)
        {
            case MODULE_ERROR_TYPE_UNSIGNED:
                size += snprintf(buffer + size, MODULE_ERROR_BUFFER - size, "%s = %ld\n", field->name, field->unsigned_number);
                break;
            case MODULE_ERROR_TYPE_SIGNED:
                size += snprintf(buffer + size, MODULE_ERROR_BUFFER - size, "%s = %ld\n", field->name, field->signed_number);
                break;
            case MODULE_ERROR_TYPE_DOUBLE:
                size += snprintf(buffer + size, MODULE_ERROR_BUFFER - size, "%s = %lf\n", field->name, field->double_number);
                break;
            case MODULE_ERROR_TYPE_STRING:
                size += snprintf(buffer + size, MODULE_ERROR_BUFFER - size, "%s = %s\n", field->name, field->string);
                break;
        }
    }
    size += snprintf(buffer + size, MODULE_ERROR_BUFFER - size, "message = %s\n", error->message);
    return buffer;
}

void error_raise(struct error* error)
{
}