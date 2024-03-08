#ifndef CORE_COMMON_FACTORY_H
#define CORE_COMMON_FACTORY_H

#include <common/common.h>
#include <common/errors.h>
#include <system/types.h>

#if defined(__cplusplus)
extern "C"
{
#endif

#define new(module, type)                                     \
    ({                                                        \
        struct type* object = calloc(1, sizeof(struct type)); \
        if (unlikely(object == NULL))                         \
        {                                                     \
            error_exit(module, ENOMEM, strerror(ENOMEM));     \
        }                                                     \
        object;                                               \
    })

#define allocate(module, count, size)                     \
    ({                                                    \
        void* object = calloc(count, size);               \
        if (unlikely(object == NULL))                     \
        {                                                 \
            error_exit(module, ENOMEM, strerror(ENOMEM)); \
        }                                                 \
        object;                                           \
    })

#define delete(module, object) free(object);

#if defined(__cplusplus)
}
#endif

#endif