#ifndef TEST_H
#define TEST_H

#include <stdbool.h>
#include "executor_message.h"
typedef struct executor_native test_executor_native;

#if defined(__cplusplus)
extern "C"
{
#endif

    test_executor_native* test_executor_initialize(bool initialize_memory);
    int32_t test_executor_descriptor(test_executor_native* executor);
    void test_executor_destroy(test_executor_native* executor, bool initialize_memory);
    struct executor_message* test_allocate_message();
    double* test_allocate_double();

#if defined(__cplusplus)
}
#endif

#endif
