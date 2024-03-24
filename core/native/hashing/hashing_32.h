#ifndef CORE_HASHING_H
#define CORE_HASHING_H

#include <common/common.h>
#include <common/constants.h>
#include "hasher.h"
#include "hashing_murmur32.h"
#include "hashing_wyhash.h"
#include "hashing_xxhash.h"

#define _ASSIGN(dst, src, ...) asm(""          \
                                   : "=r"(dst) \
                                   : "0"(src), ##__VA_ARGS__)

static FORCEINLINE uint32_t hasher_hash_32(struct hasher* hasher, const uint8_t* bytes, size_t length)
{
    switch (hasher->mode)
    {
        case HASHING_WYHASH:
            return hash_bytes_wyhash32(bytes, length, hasher->seed_32);
        case HASHING_MURMUR:
            return hash_bytes_murmur32(bytes, length, hasher->seed_32);
        case HASHING_XXHASH:
            return hash_bytes_xxh32(bytes, length, hasher->seed_32);
    }
    return 0;
}

static FORCEINLINE uint32_t hash_string_32(const char* string, size_t length)
{
    return hash_bytes_32((const uint8_t*)string, length);
}
#endif