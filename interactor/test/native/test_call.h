#ifndef TEST_CALL_H
#define TEST_CALL_H

#include <interactor_message.h>
#include <stdbool.h>
#include <stdint.h>
#include "test.h"

#if defined(__cplusplus)
extern "C"
{
#endif

    struct test_object_child
    {
        int field;
    };

    struct test_object
    {
        int field;
        struct test_object_child child_field;
    };

    void test_call_reset();

    bool test_call_native_check(test_interactor_native* interactor);
    void test_call_native(struct interactor_message* message);

    void test_call_dart_null(test_interactor_native* interactor, int32_t target, uintptr_t method);
    void test_call_dart_bool(test_interactor_native* interactor, int32_t target, uintptr_t method, bool value);
    void test_call_dart_int(test_interactor_native* interactor, int32_t target, uintptr_t method, int value);
    void test_call_dart_double(test_interactor_native* interactor, int32_t target, uintptr_t method, double value);
    struct interactor_message* test_call_dart_check(test_interactor_native* interactor);
    void test_call_dart_callback(struct interactor_message* message);

    intptr_t test_call_native_address_lookup();

#if defined(__cplusplus)
}
#endif

#endif
