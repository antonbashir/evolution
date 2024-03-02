#ifndef TEST_CALL_H
#define TEST_CALL_H

#include <mediator_message.h>
#include <stdbool.h>
#include <stdint.h>
#include "test.h"

#if defined(__cplusplus)
extern "C"
{
#endif

    struct test_object_child
    {
        int32_t field;
    };

    struct test_object
    {
        int32_t field;
        struct test_object_child child_field;
    };

    void test_call_reset();

    bool test_call_native_check(test_mediator_native* mediator);
    void test_call_native(struct mediator_message* message);

    void test_call_dart_null(test_mediator_native* mediator, int32_t target, uintptr_t method);
    void test_call_dart_bool(test_mediator_native* mediator, int32_t target, uintptr_t method, bool value);
    void test_call_dart_int(test_mediator_native* mediator, int32_t target, uintptr_t method, int32_t value);
    void test_call_dart_double(test_mediator_native* mediator, int32_t target, uintptr_t method, double value);
    struct mediator_message* test_call_dart_check(test_mediator_native* mediator);
    void test_call_dart_callback(struct mediator_message* message);

    intptr_t test_call_native_address_lookup();

#if defined(__cplusplus)
}
#endif

#endif
