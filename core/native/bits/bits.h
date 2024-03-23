#ifndef CORE_CONTEXT_H
#define CORE_CONTEXT_H

#include <common/common.h>
#include <system/library.h>

#if defined(__cplusplus)
extern "C"
{
#endif

static FORCEINLINE uint64_t round_up_to_power_of_two(uint64_t x)
{
    x = x - 1;
    x = x | (x >> 1);
    x = x | (x >> 2);
    x = x | (x >> 4);
    x = x | (x >> 8);
    x = x | (x >> 16);
    x = x | (x >> 32);
    return x + 1;
}

#if defined(__cplusplus)
}
#endif

#endif
