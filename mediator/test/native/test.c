

#include "test.h"
#include <bits/pthreadtypes.h>
#include <stdlib.h>
#include "mediator_message.h"
#include "mediator_native.h"
#include "memory_module.h"
#include "memory_small_data.h"

static pthread_mutex_t mutex;
struct memory_module memory_module;
struct memory_pool pool;
struct memory_small_data small_data;

test_mediator_native* test_mediator_initialize(bool initialize_memory)
{
    struct mediator_native* test_mediator = malloc(sizeof(struct mediator_native));
    if (!test_mediator)
    {
        return NULL;
    }
    int32_t result = mediator_native_initialize_default(test_mediator, 0);
    if (result < 0)
    {
        return NULL;
    }
    if (initialize_memory)
    {
        memory_create(&memory_module, 1 * 1024 * 1024, 64 * 1024, 64 * 1024);
        memory_pool_create(&pool, &memory_module, sizeof(struct mediator_message));
        memory_small_data_create(&small_data, &memory_module);
    }
    return test_mediator;
}

int32_t test_mediator_descriptor(test_mediator_native* mediator)
{
    return ((struct mediator_native*)mediator)->descriptor;
}

void test_mediator_destroy(test_mediator_native* mediator, bool initialize_memory)
{
    if (initialize_memory)
    {
        memory_small_data_destroy(&small_data);
        memory_pool_destroy(&pool);
        memory_destroy(&memory_module);
    }
    mediator_native_destroy(mediator);
    free(mediator);
}

struct mediator_message* test_allocate_message()
{
    return memory_pool_allocate(&pool);
}

double* test_allocate_double()
{
    return memory_small_data_allocate(&small_data, sizeof(double));
}