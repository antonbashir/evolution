#include <common/common.h>
#include <system/library.h>
#include "murmur32.h"

static FORCEINLINE uint32_t CONST hash_bytes_murmur32(const uint8_t* bytes, uint64_t length, uint32_t seed)
{
    uint32_t hash = seed;
    uint32_t carry = 0;
    murmur32_process(&hash, &carry, bytes, length);
    return murmur32_result(hash, carry, length);
}

#if HASHING_DEFAULT_MODE == HASHING_MURMUR
static FORCEINLINE uint32_t hash_bytes_32(const uint8_t* bytes, size_t length)
{
    return hash_bytes_murmur32(bytes, length, HASHING_DEFAULT_STRING_SEED);
}
#endif