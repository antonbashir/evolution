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

#define EXECUTOR_CQE_FIELD_RESULT "cqe.result"
#define EXECUTOR_CQE_FIELD_USER_DATA "cqe.user_data"
#define EXECUTOR_CQE_FIELD_FLAGS "cqe.flags"

#if defined(__cplusplus)
}
#endif

#endif
