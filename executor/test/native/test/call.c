#include "call.h"
#include <executor/module.h>
#include <liburing.h>
#include "test.h"

static struct executor_task* current_message = NULL;

void test_call_reset()
{
    current_message = NULL;
}

bool test_call_native_check(struct test_executor* executor)
{
    test_executor_process(executor);
    io_uring_submit(executor->ring);
    return current_message != NULL;
}

void test_call_native(struct executor_task* message)
{
    message->output = message->input;
    message->output_size = message->input_size;
    current_message = message;
}

void test_call_dart_null(struct test_executor* executor, int32_t target, uintptr_t method)
{
    struct executor_task* message = test_allocate_message();
    message->id = 0;
    message->source = executor->descriptor;
    message->owner = 0;
    message->method = method;
    test_executor_call_dart(executor, target, message);
    io_uring_submit(executor->ring);
}

void test_call_dart_bool(struct test_executor* executor, int32_t target, uintptr_t method, bool value)
{
    struct executor_task* message = test_allocate_message();
    message->id = 0;
    message->input = (void*)value;
    message->input_size = sizeof(bool);
    message->source = executor->descriptor;
    message->owner = 0;
    message->method = method;
    test_executor_call_dart(executor, target, message);
    io_uring_submit(executor->ring);
}

void test_call_dart_int(struct test_executor* executor, int32_t target, uintptr_t method, int32_t value)
{
    struct executor_task* message = test_allocate_message();
    message->id = 0;
    message->input = (void*)(uintptr_t)value;
    message->input_size = sizeof(int);
    message->source = executor->descriptor;
    message->owner = 0;
    message->method = method;
    test_executor_call_dart(executor, target, message);
    io_uring_submit(executor->ring);
}

void test_call_dart_double(struct test_executor* executor, int32_t target, uintptr_t method, double value)
{
    struct executor_task* message = test_allocate_message();
    message->id = 0;
    message->input = test_allocate_double();
    (*(double*)message->input) = value;
    message->input_size = sizeof(double);
    message->source = executor->descriptor;
    message->owner = 0;
    message->method = method;
    test_executor_call_dart(executor, target, message);
    io_uring_submit(executor->ring);
}

void test_call_dart_callback(struct executor_task* message)
{
    message->output = message->input;
    message->output_size = message->input_size;
    current_message = message;
}

struct executor_task* test_call_dart_check(struct test_executor* executor)
{
    test_executor_register_callback(executor, test_call_dart_callback);
    test_executor_process(executor);
    io_uring_submit(executor->ring);
    return current_message;
}

intptr_t test_call_native_address_lookup()
{
    return (uintptr_t)&test_call_native;
}