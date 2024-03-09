#ifndef COMMON_ERRORS_ERROR_H
#define COMMON_ERRORS_ERROR_H

#include <common/common.h>
#include <common/library.h>
#include <events/field.h>
#include <stacktrace/stacktrace.h>
#include <stdint.h>
#include <system/types.h>

#if defined(__cplusplus)
extern "C"
{
#endif

#define MODULE_ERROR_BUFFER 1024
#define MODULE_ERROR_FIELDS_MAXIMUM 128

struct error
{
    const char* module_name;
    struct event_field** fields;
    const char* function;
    const char* file;
    size_t fields_count;
    uint32_t line;
    uint32_t module_id;
    const char* message;
};

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

#define error_field event_field

#define error_new(message, ...) error_build(__FUNCTION__, __FILE__, __LINE__, message, VA_LENGTH(__VA_ARGS__), __VA_ARGS__)

#define error_system(code, ...) error_new(strerror(code), error_field("code", code), ##__VA_ARGS__)

#if defined(__cplusplus)
}
#endif

#endif