#include "test_call.h"
#include <interactor_native.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "interactor_message.h"
#include "test.h"

static struct interactor_message* current_message = NULL;

void test_call_reset()
{
    current_message = NULL;
}

bool test_call_native_check(struct interactor_native* interactor)
{
    interactor_native_process_timeout(interactor);
    interactor_native_submit(interactor);
    return current_message != NULL;
}

void test_call_native(struct interactor_message* message)
{
    message->output = message->input;
    message->output_size = message->input_size;
    current_message = message;
}

void test_call_dart_null(struct interactor_native* interactor, int32_t target, uintptr_t method)
{
    struct interactor_message* message = test_allocate_message();
    message->id = 0;
    message->source = interactor->descriptor;
    message->owner = 0;
    message->method = method;
    interactor_native_call_dart(interactor, target, message);
    interactor_native_submit(interactor);
}

void test_call_dart_bool(struct interactor_native* interactor, int32_t target, uintptr_t method, bool value)
{
    struct interactor_message* message = test_allocate_message();
    message->id = 0;
    message->input = (void*)value;
    message->input_size = sizeof(bool);
    message->source = interactor->descriptor;
    message->owner = 0;
    message->method = method;
    interactor_native_call_dart(interactor, target, message);
    interactor_native_submit(interactor);
}

void test_call_dart_int(struct interactor_native* interactor, int32_t target, uintptr_t method, int value)
{
    struct interactor_message* message = test_allocate_message();
    message->id = 0;
    message->input = (void*)(uintptr_t)value;
    message->input_size = sizeof(int);
    message->source = interactor->descriptor;
    message->owner = 0;
    message->method = method;
    interactor_native_call_dart(interactor, target, message);
    interactor_native_submit(interactor);
}

void test_call_dart_double(struct interactor_native* interactor, int32_t target, uintptr_t method, double value)
{
    struct interactor_message* message = test_allocate_message();
    message->id = 0;
    message->input = test_allocate_double();
    (*(double*)message->input) = value;
    message->input_size = sizeof(double);
    message->source = interactor->descriptor;
    message->owner = 0;
    message->method = method;
    interactor_native_call_dart(interactor, target, message);
    interactor_native_submit(interactor);
}

void test_call_dart_callback(struct interactor_message* message)
{
    message->output = message->input;
    message->output_size = message->input_size;
    current_message = message;
}

struct interactor_message* test_call_dart_check(struct interactor_native* interactor)
{
    interactor_native_register_callback(interactor, 0, 0, test_call_dart_callback);
    interactor_native_process_timeout(interactor);
    interactor_native_submit(interactor);
    return current_message;
}

intptr_t test_call_native_address_lookup() {
  return (intptr_t)&test_call_native;
}