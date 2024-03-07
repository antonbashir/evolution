#ifndef EXECUTOR_COMMON_H
#define EXECUTOR_COMMON_H

#include <common/common.h>
#include <liburing.h>
#include <system/library.h>

#if defined(__cplusplus)
extern "C"
{
#endif

#define EXECUTOR_CQE_FORMAT_BUFFER 1024

static FORCEINLINE char* executor_format_cqe(struct io_uring_cqe* cqe)
{
    char* buffer = malloc(EXECUTOR_CQE_FORMAT_BUFFER);
    snprintf(buffer, EXECUTOR_CQE_FORMAT_BUFFER, "cqe.res = [%d], cqe.user_data = [%lld], cqe.flags = [%d]", cqe->res, cqe->user_data, cqe->flags);
    return buffer;
};

#if defined(__cplusplus)
}
#endif

#endif
