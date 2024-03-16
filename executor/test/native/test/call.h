#ifndef TEST_CALL_H
#define TEST_CALL_H

#include <executor/task.h>
#include <system/library.h>
#include "test.h"

#if defined(__cplusplus)
extern "C"
{
#endif

DART_STRUCTURE struct test_object_child
{
    DART_FIELD int32_t field;
};

DART_STRUCTURE struct test_object
{
    DART_FIELD int32_t field;
    DART_FIELD struct test_object_child child_field;
};

DART_LEAF_FUNCTION void test_call_reset();

DART_LEAF_FUNCTION bool test_call_native_check(struct test_executor* executor);
DART_LEAF_FUNCTION void test_call_native(struct executor_task* message);

DART_LEAF_FUNCTION void test_call_dart_null(struct test_executor* executor, int32_t target, uintptr_t method);
DART_LEAF_FUNCTION void test_call_dart_bool(struct test_executor* executor, int32_t target, uintptr_t method, bool value);
DART_LEAF_FUNCTION void test_call_dart_int(struct test_executor* executor, int32_t target, uintptr_t method, int32_t value);
DART_LEAF_FUNCTION void test_call_dart_double(struct test_executor* executor, int32_t target, uintptr_t method, double value);
DART_LEAF_FUNCTION struct executor_task* test_call_dart_check(struct test_executor* executor);
DART_LEAF_FUNCTION void test_call_dart_callback(struct executor_task* message);

DART_LEAF_FUNCTION intptr_t test_call_native_address_lookup();

#if defined(__cplusplus)
}
#endif

#endif
