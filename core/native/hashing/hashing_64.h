#ifndef CORE_HASHING_H
#define CORE_HASHING_H

#include <common/common.h>
#include <common/constants.h>
#include "hasher.h"
#include "hashing_murmur32.h"
#include "hashing_polymur.h"
#include "hashing_wyhash.h"
#include "hashing_xxhash.h"

#define _ASSIGN(dst, src, ...) asm(""          \
                                   : "=r"(dst) \
                                   : "0"(src), ##__VA_ARGS__)

static FORCEINLINE uint32_t hasher_hash_64(struct hasher* hasher, const uint8_t* bytes, size_t length)
{
    switch (hasher->mode)
    {
        case HASHING_WYHASH:
            return hash_bytes_wyhash(bytes, length, hasher->seed_64, hasher->wyhash_secret);
        case HASHING_POLYMUR:
            return hash_bytes_polymur_configured(hasher->polymur_parameters, bytes, length, hasher->polymur_tweak);
        case HASHING_XXHASH:
            return hash_bytes_xxh64(bytes, length, hasher->seed_64);
    }
    unreachable();
}

static FORCEINLINE uint32_t CONST hash_64(uint64_t a, uint32_t bits)
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

static FORCEINLINE uint64_t hash_string_64(const char* string, size_t length)
{
    return hash_bytes_64((const uint8_t*)string, length);
}
#endif