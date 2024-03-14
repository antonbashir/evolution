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

#define executor_format_cqe(cqe)                                                                                                                                  \
    ({                                                                                                                                                            \
        char buffer##__LINE__[EXECUTOR_CQE_FORMAT_BUFFER];                                                                                                        \
        snprintf(buffer##__LINE__, EXECUTOR_CQE_FORMAT_BUFFER, "cqe.res = [%d], cqe.user_data = [%lld], cqe.flags = [%d]", cqe->res, cqe->user_data, cqe->flags); \
        buffer##__LINE__;                                                                                                                                         \
    })

#if defined(__cplusplus)
}
#endif

#endif
