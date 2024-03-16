#ifndef CORE_HASHING_H
#define CORE_HASHING_H

#include <common/common.h>
#include <stdint.h>
#include "murmur32.h"

#define _ASSIGN(dst, src, ...) asm(""          \
                                   : "=r"(dst) \
                                   : "0"(src), ##__VA_ARGS__)

#define SIMPLE_MAP_STRING_SEED 13U

static FORCEINLINE uint32_t CONST hash_string(const char* string, uint32_t length)
{
    uint32_t hash = SIMPLE_MAP_STRING_SEED;
    uint32_t carry = 0;
    murmur32_process(&hash, &carry, string, length);
    return murmur32_result(hash, carry, length);
}

static FORCEINLINE uint32_t CONST hash_64(uint64_t a, unsigned int bits)
{
    uint64_t b, c, d;

    if (!__builtin_constant_p(bits))
        asm(""
            : "=q"(bits)
            : "0"(64 - bits));
    else
        bits = 64 - bits;

    _ASSIGN(b, a * 5);
    c = a << 13;
    b = (b << 2) + a;
    _ASSIGN(d, a << 17);
    a = b + (a << 1);
    c += d;
    d = a << 10;
    _ASSIGN(a, a << 19);
    d = a - d;
    _ASSIGN(a, a << 4, "X"(d));
    c += b;
    a += b;
    d -= c;
    c += a << 1;
    a += c << 3;
    _ASSIGN(b, b << (7 + 31), "X"(c), "X"(d));
    a <<= 31;
    b += d;
    a += b;
    return a >> bits;
}
#endif