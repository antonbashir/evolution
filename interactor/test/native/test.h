#ifndef TEST_H
#define TEST_H

#include <stdbool.h>
#include "interactor_message.h"
typedef struct interactor_native test_interactor_native;

#if defined(__cplusplus)
extern "C"
{
#endif

    test_interactor_native* test_interactor_initialize(bool initialize_memory);
    int test_interactor_descriptor(test_interactor_native* interactor);
    void test_interactor_destroy(test_interactor_native* interactor, bool initialize_memory);
    struct interactor_message* test_allocate_message();
    double* test_allocate_double();

#if defined(__cplusplus)
}
#endif

#endif
