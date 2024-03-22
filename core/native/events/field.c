#include "field.h"

void event_field_set_any(struct event_field_structure* field, ...)
{
    va_list args;
    va_start(args, field);
    field->type = EVENT_TYPE_ADDRESS;
    field->address = va_arg(args, void*);
    va_end(args);
}
