
#include <common/common.h>
#include "hasher.h"
#include "polymur.h"

static FORCEINLINE uint64_t CONST hash_bytes_polymur_initialize(PolymurHashParams* parameters, const uint8_t* bytes, uint64_t length, uint64_t seed, uint64_t tweak)
{
    polymur_init_params_from_seed(parameters, seed);
    return polymur_hash(bytes, length, parameters, 0);
}

static FORCEINLINE uint64_t CONST hash_bytes_polymur_configured(PolymurHashParams* parameters, const uint8_t* bytes, uint64_t length, uint64_t tweak)
{
    return polymur_hash(bytes, length, parameters, 0);
}

static FORCEINLINE uint64_t CONST hash_bytes_polymur(const uint8_t* bytes, uint64_t length, uint64_t seed, uint64_t tweak)
{
    PolymurHashParams parameters;
    polymur_init_params_from_seed(&parameters, seed);
    return polymur_hash(bytes, length, &parameters, tweak);
}

#if HASHING_DEFAULT_MODE == HASHING_POLYMUR
static FORCEINLINE uint64_t hash_bytes_64(const uint8_t* bytes, size_t length)
{
    PolymurHashParams* parameters = hasher_get_default_64()->polymur_parameters;
    return hash_bytes_polymur_configured(parameters, bytes, length, 0);
}
#endif