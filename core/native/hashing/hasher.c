#include "hasher.h"
#include "polymur.h"
#include "wyhash.h"

struct hasher default_hasher_32;
struct hasher default_hasher_64;

static void hasher_initialize_polymur(struct hasher* hasher, uint64_t seed_64)
{
    PolymurHashParams* parameters = calloc(1, sizeof(PolymurHashParams));
    polymur_init_params_from_seed(parameters, seed_64);
    hasher->mode = HASHING_POLYMUR;
    hasher->seed_64 = seed_64;
    hasher->polymur_parameters = parameters;
}

static void hasher_initialize_murmur32(struct hasher* hasher, uint32_t seed_32)
{
    hasher->mode = HASHING_MURMUR;
    hasher->seed_32 = seed_32;
}

static void hasher_initialize_xxhash32(struct hasher* hasher, uint32_t seed)
{
    hasher->mode = HASHING_XXHASH;
    hasher->seed_32 = seed;
}

static void hasher_initialize_xxhash64(struct hasher* hasher, uint64_t seed)
{
    hasher->mode = HASHING_XXHASH;
    hasher->seed_64 = seed;
}

static void hasher_initialize_wyhash32(struct hasher* hasher, uint32_t seed)
{
    hasher->mode = HASHING_WYHASH;
    hasher->seed_32 = seed;
}

static void hasher_initialize_wyhash(struct hasher* hasher, uint64_t seed, const uint64_t* secret)
{
    hasher->mode = HASHING_WYHASH;
    hasher->seed_64 = seed;
    hasher->wyhash_secret = secret;
}

void hasher_initialize_default()
{
#if HASHING_DEFAULT_MODE == HASHING_WYHASH
    hasher_initialize_wyhash32(&default_hasher_32, HASHING_DEFAULT_STRING_SEED);
    hasher_initialize_wyhash(&default_hasher_64, HASHING_DEFAULT_STRING_SEED, _wyp);
#endif
#if HASHING_DEFAULT_MODE == HASHING_MURMUR
    hasher_initialize_murmur(&default_hasher_32, HASHING_DEFAULT_STRING_SEED);
#endif
#if HASHING_DEFAULT_MODE == HASHING_XXHASH
    hasher_initialize_xxhash32(&default_hasher_32, HASHING_DEFAULT_STRING_SEED);
    hasher_initialize_xxhash64(&default_hasher_64, HASHING_DEFAULT_STRING_SEED);
#endif
#if HASHING_DEFAULT_MODE == HASHING_POLYMUR
    hasher_initialize_polymur(&default_hasher_64, HASHING_DEFAULT_STRING_SEED);
#endif
}


void hasher_destroy(struct hasher* hasher)
{
    if (hasher->mode == HASHING_POLYMUR)
    {
        free(hasher->polymur_parameters);
    }
}
