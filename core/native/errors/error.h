#ifndef COMMON_ERRORS_ERROR_H
#define COMMON_ERRORS_ERROR_H

#include <common/common.h>
#include <common/library.h>
#include <stacktrace/stacktrace.h>
#include <stdint.h>
#include <system/types.h>

#if defined(__cplusplus)
extern "C"
{
#endif

#define MODULE_ERROR_BUFFER 1024
#define MODULE_ERROR_FIELDS_MAXIMUM 128

#define MODULE_ERROR_TYPE_SIGNED 0
#define MODULE_ERROR_TYPE_UNSIGNED 1
#define MODULE_ERROR_TYPE_DOUBLE 2
#define MODULE_ERROR_TYPE_STRING 3

struct error_field
{
    const char* name;
    union
    {
        uint64_t unsigned_number;
        int64_t signed_number;
        const char* string;
        double double_number;
    };
    uint8_t type;
};

struct error
{
    const char* module_name;
    struct error_field** fields;
    const char* function;
    const char* file;
    size_t fields_count;
    uint32_t line;
    uint32_t module_id;
    const char* message;
};

static FORCEINLINE void error_field_set_boolean(struct error_field* field, bool value)
{
    field->type = MODULE_ERROR_TYPE_SIGNED;
    field->signed_number = value;
}

static FORCEINLINE void error_field_set_double(struct error_field* field, double value)
{
    field->type = MODULE_ERROR_TYPE_DOUBLE;
    field->double_number = value;
}

static FORCEINLINE void error_field_set_unsigned(struct error_field* field, uint64_t value)
{
    field->type = MODULE_ERROR_TYPE_UNSIGNED;
    field->unsigned_number = value;
}

static FORCEINLINE void error_field_set_signed(struct error_field* field, int64_t value)
{
    field->type = MODULE_ERROR_TYPE_SIGNED;
    field->signed_number = value;
}

static FORCEINLINE void error_field_set_string(struct error_field* field, const char* value)
{
    field->type = MODULE_ERROR_TYPE_STRING;
    field->string = value;
}

static FORCEINLINE void error_field_set_any(struct error_field* field, ...)
{
    unreachable();
}

struct error* error_create(const char* function, const char* file, uint32_t line, const char* message);
struct error* error_build(const char* function, const char* file, uint32_t line, const char* message, size_t fields, ...);
void error_setup(struct error* error, uint32_t module_id, const char* module_name);
void error_destroy(struct error* error);
void error_set_boolean(struct error* error, const char* name, bool value);
void error_set_signed(struct error* error, const char* name, int64_t value);
void error_set_unsigned(struct error* error, const char* name, uint64_t value);
void error_set_double(struct error* error, const char* name, double value);
void error_set_string(struct error* error, const char* name, const char* value);
bool error_get_boolean(struct error* error, const char* name);
int64_t error_get_signed(struct error* error, const char* name);
uint64_t error_get_unsigned(struct error* error, const char* name);
double error_get_double(struct error* error, const char* name);
const char* error_get_string(struct error* error, const char* name);
const char* error_format(struct error* error);
void error_raise(struct error* error);
void error_print(struct error* error);

#define error_field(field_name, field_value)                                                                         \
    ({                                                                                                               \
        struct error_field field##__LINE__;                                                                          \
        struct error_field* field_pointer##__LINE__ = &field##__LINE__;                                              \
        field##__LINE__.name = field_name;                                                                           \
        choose_expression(                                                                                           \
            types_compatible(typeof(field_value), int8_t),                                                           \
            error_field_set_signed,                                                                                  \
            choose_expression(                                                                                       \
                types_compatible(typeof(field_value), uint8_t),                                                      \
                error_field_set_unsigned,                                                                            \
                choose_expression(                                                                                   \
                    types_compatible(typeof(field_value), int16_t),                                                  \
                    error_field_set_signed,                                                                          \
                    choose_expression(                                                                               \
                        types_compatible(typeof(field_value), uint16_t),                                             \
                        error_field_set_unsigned,                                                                    \
                        choose_expression(                                                                           \
                            types_compatible(typeof(field_value), int32_t),                                          \
                            error_field_set_signed,                                                                  \
                            choose_expression(                                                                       \
                                types_compatible(typeof(field_value), uint32_t),                                     \
                                error_field_set_unsigned,                                                            \
                                choose_expression(                                                                   \
                                    types_compatible(typeof(field_value), int64_t),                                  \
                                    error_field_set_signed,                                                          \
                                    choose_expression(                                                               \
                                        types_compatible(typeof(field_value), uint64_t),                             \
                                        error_field_set_unsigned,                                                    \
                                        choose_expression(                                                           \
                                            types_compatible(typeof(field_value), double),                           \
                                            error_field_set_double,                                                  \
                                            choose_expression(                                                       \
                                                types_compatible(typeof(field_value), char[]),                       \
                                                error_field_set_string,                                              \
                                                error_field_set_any))))))))))(field_pointer##__LINE__, field_value); \
        field##__LINE__;                                                                                             \
    })

#define error_new(message, ...) error_build(__FUNCTION__, __FILE__, __LINE__, message, VA_LENGTH(__VA_ARGS__), __VA_ARGS__)

#define error_system(code, ...) error_new(strerror(code), error_field("code", code), ##__VA_ARGS__)

#if defined(__cplusplus)
}
#endif

#endif