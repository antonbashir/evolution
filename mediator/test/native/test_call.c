#include "test_call.h"
#include <mediator_native.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "mediator_message.h"
#include "test.h"

static struct mediator_message* current_message = NULL;

void test_call_reset()
{
    current_message = NULL;
}

bool test_call_native_check(struct mediator_native* mediator)
{
    mediator_native_process_timeout(mediator);
    mediator_native_submit(mediator);
    return current_message != NULL;
}

void test_call_native(struct mediator_message* message)
{
    message->output = message->input;
    message->output_size = message->input_size;
    current_message = message;
}

void test_call_dart_null(struct mediator_native* mediator, int32_t target, uintptr_t method)
{
    struct mediator_message* message = test_allocate_message();
    message->id = 0;
    message->source = mediator->descriptor;
    message->owner = 0;
    message->method = method;
    mediator_native_call_dart(mediator, target, message);
    mediator_native_submit(mediator);
}

void test_call_dart_bool(struct mediator_native* mediator, int32_t target, uintptr_t method, bool value)
{
    struct mediator_message* message = test_allocate_message();
    message->id = 0;
    message->input = (void*)value;
    message->input_size = sizeof(bool);
    message->source = mediator->descriptor;
    message->owner = 0;
    message->method = method;
    mediator_native_call_dart(mediator, target, message);
    mediator_native_submit(mediator);
}

void test_call_dart_int(struct mediator_native* mediator, int32_t target, uintptr_t method, int value)
{
    struct mediator_message* message = test_allocate_message();
    message->id = 0;
    message->input = (void*)(uintptr_t)value;
    message->input_size = sizeof(int);
    message->source = mediator->descriptor;
    message->owner = 0;
    message->method = method;
    mediator_native_call_dart(mediator, target, message);
    mediator_native_submit(mediator);
}

void test_call_dart_double(struct mediator_native* mediator, int32_t target, uintptr_t method, double value)
{
    struct mediator_message* message = test_allocate_message();
    message->id = 0;
    message->input = test_allocate_double();
    (*(double*)message->input) = value;
    message->input_size = sizeof(double);
    message->source = mediator->descriptor;
    message->owner = 0;
    message->method = method;
    mediator_native_call_dart(mediator, target, message);
    mediator_native_submit(mediator);
}

void test_call_dart_callback(struct mediator_message* message)
{
    message->output = message->input;
    message->output_size = message->input_size;
    current_message = message;
}

struct mediator_message* test_call_dart_check(struct mediator_native* mediator)
{
    mediator_native_register_callback(mediator, 0, 0, test_call_dart_callback);
    mediator_native_process_timeout(mediator);
    mediator_native_submit(mediator);
    return current_message;
}

intptr_t test_call_native_address_lookup() {
  return (intptr_t)&test_call_native;
}