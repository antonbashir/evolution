#ifndef TEST_TEST_H
#define TEST_TEST_H

#include <common/common.h>
#include <executor/task.h>
#include <system/library.h>

#ifndef SIMPLE_MAP_SOURCE
#define SIMPLE_MAP_UNDEF
#endif

#define simple_map_name _native_callbacks
struct simple_map_native_callbacks_key_t
{
    uint64_t owner;
    uint64_t method;
};
#define simple_map_key_t struct simple_map_native_callbacks_key_t
struct simple_map_native_callbacks_node_t
{
    simple_map_key_t key;
    void (*callback)(struct executor_task*);
};

#define simple_map_node_t struct simple_map_native_callbacks_node_t
#define simple_map_arg_t uint64_t
#define simple_map_hash(a, arg) (a->key.owner * 31 + a->key.method)
#define simple_map_hash_key(a, arg) (a.owner * 31 + a.method)
#define simple_map_cmp(a, b, arg) ((a->key.owner != b->key.owner) && (a->key.method != b->key.method))
#define simple_map_cmp_key(a, b, arg) ((a.owner != b->key.owner) && (a.method != b->key.method))

#include <maps/simple.h>

DART_STRUCTURE struct test_executor
{
    DART_FIELD struct io_uring* ring;
    DART_FIELD int32_t descriptor;
    DART_FIELD DART_TYPE struct simple_map_native_callbacks_t* callbacks;
};

#if defined(__cplusplus)
extern "C"
{
#endif

typedef void (*test_executor_call)(struct executor_task* message);

DART_LEAF_FUNCTION struct test_executor* test_executor_initialize(bool initialize_memory);
DART_LEAF_FUNCTION void test_executor_destroy(struct test_executor* executor, bool initialize_memory);
DART_LEAF_FUNCTION struct executor_task* test_allocate_message();
DART_LEAF_FUNCTION double* test_allocate_double();
void test_executor_process(struct test_executor* executor);
void test_executor_call_dart(struct test_executor* executor, int32_t target, struct executor_task* task);
void test_executor_register_callback(struct test_executor* executor, test_executor_call callback);

#if defined(__cplusplus)
}
#endif

#endif
