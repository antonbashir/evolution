#ifndef TEST_H
#define TEST_H

#include <stdbool.h>
#include "mediator_message.h"
typedef struct mediator_native test_mediator_native;

#if defined(__cplusplus)
extern "C"
{
#endif

    test_mediator_native* test_mediator_initialize(bool initialize_memory);
    int32_t test_mediator_descriptor(test_mediator_native* mediator);
    void test_mediator_destroy(test_mediator_native* mediator, bool initialize_memory);
    struct mediator_message* test_allocate_message();
    double* test_allocate_double();

#if defined(__cplusplus)
}
#endif

#endif
