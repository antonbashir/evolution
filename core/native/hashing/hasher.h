#ifndef CORE_HASHER_H
#define CORE_HASHER_H

#include <common/common.h>
#include <common/constants.h>
#include <system/library.h>
#include "polymur.h"

struct hasher
{
    uint8_t mode;
    uint32_t seed_32;
    uint64_t seed_64;
    const uint64_t* wyhash_secret;
    PolymurHashParams* polymur_parameters;
    uint64_t polymur_tweak;
};

void hasher_initialize_default();
void hasher_destroy(struct hasher* hasher);

extern struct hasher default_hasher_32;
extern struct hasher default_hasher_64;

static FORCEINLINE struct hasher* hasher_get_default_32()
{
    return &default_hasher_32;
}

static FORCEINLINE struct hasher* hasher_get_default_64()
{
    return &default_hasher_64;
}

#endif