#ifndef TEST_CALL_H
#define TEST_CALL_H

#include <executor_task.h>
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

    bool test_call_native_check(test_executor_native* executor);
    void test_call_native(struct executor_task* message);

    void test_call_dart_null(test_executor_native* executor, int32_t target, uintptr_t method);
    void test_call_dart_bool(test_executor_native* executor, int32_t target, uintptr_t method, bool value);
    void test_call_dart_int(test_executor_native* executor, int32_t target, uintptr_t method, int32_t value);
    void test_call_dart_double(test_executor_native* executor, int32_t target, uintptr_t method, double value);
    struct executor_task* test_call_dart_check(test_executor_native* executor);
    void test_call_dart_callback(struct executor_task* message);

    intptr_t test_call_native_address_lookup();

#if defined(__cplusplus)
}
#endif

#endif
