

#include "test.h"
#include <bits/pthreadtypes.h>
#include <stdlib.h>
#include "interactor_message.h"
#include "interactor_native.h"
#include <memory_module.h>
#include "memory_small_data.h"

static pthread_mutex_t mutex;
struct memory memory;
struct memory_pool pool;
struct memory_small_data small_data;

test_interactor_native* test_interactor_initialize(bool initialize_memory)
{
    struct interactor_native* test_interactor = malloc(sizeof(struct interactor_native));
    if (!test_interactor)
    {
        return NULL;
    }
    int result = interactor_native_initialize_default(test_interactor, 0);
    if (result < 0)
    {
        return NULL;
    }
    if (initialize_memory)
    {
        memory_create(&memory, 1 * 1024 * 1024, 64 * 1024, 64 * 1024);
        memory_pool_create(&pool, &memory, sizeof(struct interactor_message));
        memory_small_data_create(&small_data, &memory);
    }
    return test_interactor;
}

int test_interactor_descriptor(test_interactor_native* interactor)
{
    return ((struct interactor_native*)interactor)->descriptor;
}

void test_interactor_destroy(test_interactor_native* interactor, bool initialize_memory)
{
    if (initialize_memory)
    {
        memory_small_data_destroy(&small_data);
        memory_pool_destroy(&pool);
        memory_destroy(&memory);
    }
    interactor_native_destroy(interactor);
    free(interactor);
}

struct interactor_message* test_allocate_message()
{
    return memory_pool_allocate(&pool);
}

double* test_allocate_double()
{
    return memory_small_data_allocate(&small_data, sizeof(double));
}