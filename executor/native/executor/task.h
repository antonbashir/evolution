#ifndef EXECUTOR_TASK_H
#define EXECUTOR_TASK_H

#include <asm-generic/int-ll64.h>
#include <stddef.h>
#include <stdint.h>
#include "common/common.h"

#if defined(__cplusplus)
extern "C"
{
#endif

DART_STRUCTURE struct executor_task
{
    DART_FIELD uint64_t id;
    DART_FIELD uint64_t source;
    DART_FIELD uint64_t target;
    DART_FIELD uint64_t owner;
    DART_FIELD uint64_t method;
    DART_FIELD void* input;
    DART_FIELD size_t input_size;
    DART_FIELD void* output;
    DART_FIELD size_t output_size;
    DART_FIELD uint16_t flags;
};

DART_STRUCTURE struct executor_completion_event
{
    DART_FIELD __u64 user_data;
    DART_FIELD __s32 res;
    DART_FIELD __u32 flags;
    DART_FIELD __u64 big_cqe[2];
};
#if defined(__cplusplus)
}
#endif

#endif
