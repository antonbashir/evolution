#ifndef COMMON_EVENTS_FIELD_H
#define COMMON_EVENTS_FIELD_H

#include <common/common.h>
#include <common/constants.h>
#include <system/library.h>

#if defined(__cplusplus)
extern "C"
{
#endif

DART_STRUCTURE struct event_field_structure
{
    const char* name;
    union
    {
        char character;
        uint64_t unsigned_number;
        int64_t signed_number;
        const char* string;
        double double_number;
        void* address;
        bool boolean;
    };
    uint8_t type;
};

FORCEINLINE void event_field_set_boolean(struct event_field_structure* field, bool value)
{
    field->type = EVENT_TYPE_BOOLEAN;
    field->boolean = value;
}

FORCEINLINE void event_field_set_double(struct event_field_structure* field, double value)
{
    field->type = EVENT_TYPE_DOUBLE;
    field->double_number = value;
}

FORCEINLINE void event_field_set_unsigned(struct event_field_structure* field, uint64_t value)
{
    field->type = EVENT_TYPE_UNSIGNED;
    field->unsigned_number = value;
}

FORCEINLINE void event_field_set_signed(struct event_field_structure* field, int64_t value)
{
    field->type = EVENT_TYPE_SIGNED;
    field->signed_number = value;
}

FORCEINLINE void event_field_set_string(struct event_field_structure* field, const char* value)
{
    field->type = EVENT_TYPE_STRING;
    field->string = strdup(value);
}

FORCEINLINE void event_field_set_character(struct event_field_structure* field, char value)
{
    field->type = EVENT_TYPE_CHARACTER;
    field->character = value;
}

FORCEINLINE void event_field_set_address(struct event_field_structure* field, void* value)
{
    field->type = EVENT_TYPE_ADDRESS;
    field->address = value;
}

FORCEINLINE void event_field_delete(struct event_field_structure* field)
{
    if (field->type == EVENT_TYPE_STRING)
    {
        free((void*)field->string);
    }
    free(field);
}

void event_field_set_any(struct event_field_structure* field, ...);

#define event_field_code(code) event_field(EVENT_FIELD_CODE, code)
#define event_field_message(message) event_field(EVENT_FIELD_MESSAGE, message)
#define event_field_scope(scope) event_field(EVENT_FIELD_SCOPE, scope)

#define event_field(field_name, field_value)                                                                                           \
    ({                                                                                                                                 \
        struct event_field_structure field##__LINE__;                                                                                  \
        field##__LINE__.name = field_name;                                                                                             \
        choose_expression(                                                                                                             \
            types_compatible(typeof(field_value), char),                                                                               \
            event_field_set_character,                                                                                                 \
            choose_expression(                                                                                                         \
                types_compatible(typeof(field_value), bool),                                                                           \
                event_field_set_boolean,                                                                                               \
                choose_expression(                                                                                                     \
                    types_compatible(typeof(field_value), uint8_t),                                                                    \
                    event_field_set_unsigned,                                                                                          \
                    choose_expression(                                                                                                 \
                        types_compatible(typeof(field_value), uint8_t),                                                                \
                        event_field_set_unsigned,                                                                                      \
                        choose_expression(                                                                                             \
                            types_compatible(typeof(field_value), int16_t),                                                            \
                            event_field_set_signed,                                                                                    \
                            choose_expression(                                                                                         \
                                types_compatible(typeof(field_value), uint16_t),                                                       \
                                event_field_set_unsigned,                                                                              \
                                choose_expression(                                                                                     \
                                    types_compatible(typeof(field_value), int32_t),                                                    \
                                    event_field_set_signed,                                                                            \
                                    choose_expression(                                                                                 \
                                        types_compatible(typeof(field_value), uint32_t),                                               \
                                        event_field_set_unsigned,                                                                      \
                                        choose_expression(                                                                             \
                                            types_compatible(typeof(field_value), int64_t),                                            \
                                            event_field_set_signed,                                                                    \
                                            choose_expression(                                                                         \
                                                types_compatible(typeof(field_value), uint64_t),                                       \
                                                event_field_set_unsigned,                                                              \
                                                choose_expression(                                                                     \
                                                    types_compatible(typeof(field_value), float),                                      \
                                                    event_field_set_double,                                                            \
                                                    choose_expression(                                                                 \
                                                        types_compatible(typeof(field_value), double),                                 \
                                                        event_field_set_double,                                                        \
                                                        choose_expression(                                                             \
                                                            types_compatible(typeof(field_value), char[]),                             \
                                                            event_field_set_string,                                                    \
                                                            choose_expression(                                                         \
                                                                types_compatible(typeof(field_value), char*),                          \
                                                                event_field_set_string,                                                \
                                                                choose_expression(                                                     \
                                                                    types_compatible(typeof(field_value), const char*),                \
                                                                    event_field_set_string,                                            \
                                                                    event_field_set_any)))))))))))))))(&field##__LINE__, field_value); \
        field##__LINE__;                                                                                                               \
    })

#if defined(__cplusplus)
}
#endif

#endif