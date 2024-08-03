#include <common/common.h>
#include "wyhash.h"
#include "wyhash32.h"

static FORCEINLINE uint64_t CONST hash_bytes_wyhash(const uint8_t* bytes, uint64_t length, uint64_t seed, const uint64_t* secret)
{
    return wyhash(bytes, length, seed, secret);
}

static FORCEINLINE uint32_t CONST hash_bytes_wyhash32(const uint8_t* bytes, uint64_t length, uint64_t seed)
{
    return wyhash32(bytes, length, seed);
}

#if HASHING_DEFAULT_MODE == HASHING_WYHASH
static FORCEINLINE uint64_t hash_bytes_64(const uint8_t* bytes, size_t length)
{
    return hash_bytes_wyhash(bytes, length, HASHING_DEFAULT_STRING_SEED, _wyp);
}

static FORCEINLINE uint32_t hash_bytes_32(const uint8_t* bytes, size_t length)
{
    return hash_bytes_wyhash32(bytes, length, HASHING_DEFAULT_STRING_SEED);
}
#endif
