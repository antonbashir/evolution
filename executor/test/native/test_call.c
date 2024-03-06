#include "test_call.h"
#include <executor_native.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "executor_message.h"
#include "test.h"

static struct executor_message* current_message = NULL;

void test_call_reset()
{
    current_message = NULL;
}

bool test_call_native_check(struct executor_native* executor)
{
    executor_native_process_timeout(executor);
    executor_native_submit(executor);
    return current_message != NULL;
}

void test_call_native(struct executor_message* message)
{
    message->output = message->input;
    message->output_size = message->input_size;
    current_message = message;
}

void test_call_dart_null(struct executor_native* executor, int32_t target, uintptr_t method)
{
    struct executor_message* message = test_allocate_message();
    message->id = 0;
    message->source = executor->descriptor;
    message->owner = 0;
    message->method = method;
    executor_native_call_dart(executor, target, message);
    executor_native_submit(executor);
}

void test_call_dart_bool(struct executor_native* executor, int32_t target, uintptr_t method, bool value)
{
    struct executor_message* message = test_allocate_message();
    message->id = 0;
    message->input = (void*)value;
    message->input_size = sizeof(bool);
    message->source = executor->descriptor;
    message->owner = 0;
    message->method = method;
    executor_native_call_dart(executor, target, message);
    executor_native_submit(executor);
}

void test_call_dart_int(struct executor_native* executor, int32_t target, uintptr_t method, int32_t value)
{
    struct executor_message* message = test_allocate_message();
    message->id = 0;
    message->input = (void*)(uintptr_t)value;
    message->input_size = sizeof(int);
    message->source = executor->descriptor;
    message->owner = 0;
    message->method = method;
    executor_native_call_dart(executor, target, message);
    executor_native_submit(executor);
}

void test_call_dart_double(struct executor_native* executor, int32_t target, uintptr_t method, double value)
{
    struct executor_message* message = test_allocate_message();
    message->id = 0;
    message->input = test_allocate_double();
    (*(double*)message->input) = value;
    message->input_size = sizeof(double);
    message->source = executor->descriptor;
    message->owner = 0;
    message->method = method;
    executor_native_call_dart(executor, target, message);
    executor_native_submit(executor);
}

void test_call_dart_callback(struct executor_message* message)
{
    message->output = message->input;
    message->output_size = message->input_size;
    current_message = message;
}

struct executor_message* test_call_dart_check(struct executor_native* executor)
{
    executor_native_register_callback(executor, 0, 0, test_call_dart_callback);
    executor_native_process_timeout(executor);
    executor_native_submit(executor);
    return current_message;
}

intptr_t test_call_native_address_lookup() {
  return (uintptr_t)&test_call_native;
}