#include <common/common.h>
#include "xxhash.h"

static FORCEINLINE uint32_t CONST hash_bytes_xxh32(const uint8_t* bytes, uint64_t length, uint64_t seed)
{
    return XXH32(bytes, length, seed);
}

static FORCEINLINE uint32_t CONST hash_bytes_xxh64(const uint8_t* bytes, uint64_t length, uint64_t seed)
{
    return XXH64(bytes, length, seed);
}

#if HASHING_DEFAULT_MODE == HASHING_XXHASH
static FORCEINLINE uint32_t hash_bytes_32(const uint8_t* bytes, size_t length)
{
    return hash_bytes_xxh32(bytes, length, HASHING_DEFAULT_STRING_SEED);
}

static FORCEINLINE uint64_t hash_bytes_64(const uint8_t* bytes, size_t length)
{
    return hash_bytes_xxh64(bytes, length, HASHING_DEFAULT_STRING_SEED);
}
#endif