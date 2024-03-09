#ifndef COMMON_ERRORS_event_H
#define COMMON_ERRORS_event_H

#include <common/common.h>
#include <system/types.h>

#if defined(__cplusplus)
extern "C"
{
#endif
#define MODULE_EVENT_TYPE_SIGNED 0
#define MODULE_EVENT_TYPE_UNSIGNED 1
#define MODULE_EVENT_TYPE_DOUBLE 2
#define MODULE_EVENT_TYPE_STRING 3

#define MODULE_EVENT_FIELD_CODE "code"

struct event_field
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

static void event_field_set_boolean(struct event_field* field, bool value)
{
    field->type = MODULE_EVENT_TYPE_SIGNED;
    field->signed_number = value;
}

static void event_field_set_double(struct event_field* field, double value)
{
    field->type = MODULE_EVENT_TYPE_DOUBLE;
    field->double_number = value;
}

static void event_field_set_unsigned(struct event_field* field, uint64_t value)
{
    field->type = MODULE_EVENT_TYPE_UNSIGNED;
    field->unsigned_number = value;
}

static void event_field_set_signed(struct event_field* field, int64_t value)
{
    field->type = MODULE_EVENT_TYPE_SIGNED;
    field->signed_number = value;
}

static void event_field_set_string(struct event_field* field, const char* value)
{
    field->type = MODULE_EVENT_TYPE_STRING;
    field->string = value;
}

static void event_field_set_any(struct event_field* field, ...)
{
    unreachable();
}

#define event_field(field_name, field_value)                                                                  \
    ({                                                                                                        \
        struct event_field field##__LINE__;                                                                   \
        field##__LINE__.name = field_name;                                                                    \
        choose_expression(                                                                                    \
            types_compatible(typeof(field_value), int8_t),                                                    \
            event_field_set_signed,                                                                           \
            choose_expression(                                                                                \
                types_compatible(typeof(field_value), uint8_t),                                               \
                event_field_set_unsigned,                                                                     \
                choose_expression(                                                                            \
                    types_compatible(typeof(field_value), int16_t),                                           \
                    event_field_set_signed,                                                                   \
                    choose_expression(                                                                        \
                        types_compatible(typeof(field_value), uint16_t),                                      \
                        event_field_set_unsigned,                                                             \
                        choose_expression(                                                                    \
                            types_compatible(typeof(field_value), int32_t),                                   \
                            event_field_set_signed,                                                           \
                            choose_expression(                                                                \
                                types_compatible(typeof(field_value), uint32_t),                              \
                                event_field_set_unsigned,                                                     \
                                choose_expression(                                                            \
                                    types_compatible(typeof(field_value), int64_t),                           \
                                    event_field_set_signed,                                                   \
                                    choose_expression(                                                        \
                                        types_compatible(typeof(field_value), uint64_t),                      \
                                        event_field_set_unsigned,                                             \
                                        choose_expression(                                                    \
                                            types_compatible(typeof(field_value), double),                    \
                                            event_field_set_double,                                           \
                                            choose_expression(                                                \
                                                types_compatible(typeof(field_value), char[]),                \
                                                event_field_set_string,                                       \
                                                event_field_set_any))))))))))(&field##__LINE__, field_value); \
        field##__LINE__;                                                                                      \
    })

#if defined(__cplusplus)
}
#endif

#endif