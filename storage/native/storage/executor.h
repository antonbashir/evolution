#ifndef STORAGE_EXECUTOR_H
#define STORAGE_EXECUTOR_H

#include <common/common.h>
#include <liburing.h>
#include <system/library.h>
#include "configuration.h"

#if defined(__cplusplus)
extern "C"
{
#endif

struct storage_executor
{
    struct io_uring ring;
    struct storage_executor_configuration* configuration;
    int32_t descriptor;
    volatile bool active;
};

DART_LEAF_FUNCTION int32_t storage_executor_initialize(struct storage_executor_configuration* configuration);
DART_LEAF_FUNCTION void storage_executor_start();
DART_LEAF_FUNCTION void storage_executor_stop();
DART_LEAF_FUNCTION void storage_executor_destroy();
DART_LEAF_FUNCTION int32_t storage_executor_descriptor();

#if defined(__cplusplus)
}
#endif

#endif
