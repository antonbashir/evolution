#ifndef CORE_HASHING_H
#define CORE_HASHING_H

#include <common/common.h>
#include <common/constants.h>
#include <stdint.h>

#ifndef HASHING_MODE
#define HASHING_MODE HASHING_XXHASH32
#endif

#ifndef HASHING_STRING_SEED
#define HASHING_STRING_SEED 13U
#endif

#define _ASSIGN(dst, src, ...) asm(""          \
                                   : "=r"(dst) \
                                   : "0"(src), ##__VA_ARGS__)

#if HASHING_MODE == HASHING_MURMUR32
#include "murmur32.h"
static FORCEINLINE uint32_t CONST hash_string(const char* string, uint32_t length)
{
    uint32_t hash = HASHING_STRING_SEED;
    uint32_t carry = 0;
    murmur32_process(&hash, &carry, string, length);
    return murmur32_result(hash, carry, length);
}
#endif

#if HASHING_MODE == HASHING_WYHASH32
#include "wyhash32.h"
static FORCEINLINE uint32_t CONST hash_string(const char* string, uint32_t length)
{
    return wyhash32(string, length, HASHING_STRING_SEED);
}
#endif

#if HASHING_MODE == HASHING_WYHASH
#define WYTRNG
#include "wyhash.h"
static FORCEINLINE uint32_t CONST hash_string(const char* string, uint32_t length)
{
    return wyhash(string, length, HASHING_STRING_SEED, _wyp);
}
#endif

#if HASHING_MODE == HASHING_XXHASH32
#include "xxhash.h"
static FORCEINLINE uint32_t CONST hash_string(const char* string, uint32_t length)
{
    return XXH32(string, length, HASHING_STRING_SEED);
}
#endif

#if HASHING_MODE == HASHING_XXHASH64
#include "xxhash.h"
static FORCEINLINE uint32_t CONST hash_string(const char* string, uint32_t length)
{
    return XXH64(string, length, HASHING_STRING_SEED);
}
#endif

static FORCEINLINE uint32_t CONST hash_unsigned(uint64_t a, unsigned int bits)
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