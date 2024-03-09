/*
 * *No header guard*: the header is allowed to be included twice
 * with different sets of defines.
 */
/*
 * Copyright 2010-2016, Tarantool TARANTOOL_AUTHORS, please see licenses/tarantool/TARANTOOL_AUTHORS file.
 *
 * Redistribution and use in source and binary forms, with or
 * without modification, are permitted provided that the following
 * conditions are met:
 *
 * 1. Redistributions of source code must retain the above
 *    copyright notice, this list of conditions and the
 *    following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above
 *    copyright notice, this list of conditions and the following
 *    disclaimer in the documentation and/or other materials
 *    provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY <COPYRIGHT HOLDER> ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
 * TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
 * <COPYRIGHT HOLDER> OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
 * BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
 * THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */
/* The MIT License

   Copyright (c) 2008, by Attractive Chaos <attractivechaos@aol.co.uk>

   Permission is hereby granted, free of charge, to any person obtaining
   a copy of this software and associated documentation files (the
   "Software"), to deal in the Software without restriction, including
   without limitation the rights to use, copy, modify, merge, publish,
   distribute, sublicense, and/or sell copies of the Software, and to
   permit persons to whom the Software is furnished to do so, subject to
   the following conditions:

   The above copyright notice and this permission notice shall be
   included in all copies or substantial portions of the Software.

   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
   EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
   MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
   NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
   BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
   ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
   CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
   SOFTWARE.
*/

#ifndef SIMPLE_MAP_INCREMENTAL_RESIZE
#define SIMPLE_MAP_INCREMENTAL_RESIZE 1
#endif

#include <common/common.h>
#include <common/library.h>
#include <system/types.h>

#define simple_map_cat(a, b) simple_map##a##_##b
#define simple_map_ecat(a, b) simple_map_cat(a, b)
#define _simple_map(x) simple_map_ecat(simple_map_name, x)

#define simple_map_unlikely(x) __builtin_expect((x), 0)

#ifndef SIMPLE_MAP_TYPEDEFS
#define SIMPLE_MAP_TYPEDEFS 1
typedef uint32_t simple_map_int_t;
#endif /* SIMPLE_MAP_TYPEDEFS */

#ifndef SIMPLE_MAP_HEADER
#define SIMPLE_MAP_HEADER

#ifndef simple_map_bytemap
#define simple_map_bytemap 0
#endif

#ifndef simple_map_name
#define simple_map_name _default
#endif

#ifndef simple_map_key_t
#define simple_map_key_t int
#endif

#ifndef simple_map_node_t
struct simple_map_default_node_t
{
    int key;
};
#define simple_map_node_t struct simple_map_default_node_t
#endif

#ifndef simple_map_arg_t
#define simple_map_arg_t void*
#endif

#ifndef simple_map_hash
#define simple_map_hash(a, arg) (a->key)
#endif

#ifndef simple_map_cmp
#define simple_map_cmp(a, b, arg) ((a->key) != (a->key))
#endif

struct _simple_map(t)
{
    simple_map_node_t* p;
#if !simple_map_bytemap
    uint32_t* b;
#else
    uint8_t* b;
#endif
    simple_map_int_t n_buckets;
    simple_map_int_t n_dirty;
    simple_map_int_t size;
    simple_map_int_t upper_bound;
    simple_map_int_t prime;

    simple_map_int_t resize_cnt;
    simple_map_int_t resize_position;
    simple_map_int_t batch;
    struct _simple_map(t) * shadow;
};

#if !simple_map_bytemap
#define simple_map_exist(h, i) ({ h->b[i >> 4] & (1 << (i % 16)); })
#define simple_map_dirty(h, i) ({ h->b[i >> 4] & (1u << (i % 16 + 16)); })
#define simple_map_gethk(hash) (1)
#define simple_map_mayeq(h, i, hk) simple_map_exist(h, i)

#define simple_map_setfree(h, i) ({ h->b[i >> 4] &= ~(1 << (i % 16)); })
#define simple_map_setexist(h, i, hk) ({ h->b[i >> 4] |= (1 << (i % 16)); })
#define simple_map_setdirty(h, i) ({ h->b[i >> 4] |= (1u << (i % 16 + 16)); })
#else
#define simple_map_exist(h, i) ({ h->b[i] & 0x7f; })
#define simple_map_dirty(h, i) ({ h->b[i] & 0x80; })
#define simple_map_gethk(hash) ({ (hash) % 127 + 1; })
#define simple_map_mayeq(h, i, hk) ({ simple_map_exist(h, i) == hk; })

#define simple_map_setfree(h, i) ({ h->b[i] &= 0x80; })
#define simple_map_setexist(h, i, hk) ({ h->b[i] |= hk; })
#define simple_map_setdirty(h, i) ({ h->b[i] |= 0x80; })
#endif

#define simple_map_node(h, i) ((const simple_map_node_t*)&((h)->p[(i)]))
#define simple_map_size(h) ({ (h)->size; })
#define simple_map_capacity(h) ({ (h)->n_buckets; })
#define simple_map_begin(h) ({ 0; })
#define simple_map_end(h) ({ (h)->n_buckets; })

#define simple_map_first(h) ({              \
    simple_map_int_t i;                     \
    for (i = 0; i < simple_map_end(h); i++) \
    {                                       \
        if (simple_map_exist(h, i))         \
            break;                          \
    }                                       \
    i;                                      \
})

#define simple_map_next(h, i) ({                    \
    simple_map_int_t n = i;                         \
    if (n < simple_map_end(h))                      \
    {                                               \
        for (n = i + 1; n < simple_map_end(h); n++) \
        {                                           \
            if (simple_map_exist(h, n))             \
                break;                              \
        }                                           \
    }                                               \
    n;                                              \
})

#define simple_map_foreach(h, i) \
    for (i = simple_map_first(h); i < simple_map_end(h); i = simple_map_next(h, i))

#define SIMPLE_MAP_DENSITY 0.7

struct _simple_map(t) * _simple_map(new)();
void _simple_map(clear)(struct _simple_map(t) * h);
void _simple_map(delete)(struct _simple_map(t) * h);
void _simple_map(resize)(struct _simple_map(t) * h, simple_map_arg_t arg);
void _simple_map(start_resize)(struct _simple_map(t) * h, simple_map_int_t buckets, simple_map_int_t batch, simple_map_arg_t arg);
void _simple_map(reserve)(struct _simple_map(t) * h, simple_map_int_t size, simple_map_arg_t arg);
void NOINLINE _simple_map(del_resize)(struct _simple_map(t) * h, simple_map_int_t x, simple_map_arg_t arg);
size_t _simple_map(memsize)(struct _simple_map(t) * h);
void _simple_map(dump)(struct _simple_map(t) * h);

#define put_slot(h, node, exist, arg) \
    _simple_map(put_slot)(h, node, exist, arg)

static inline simple_map_node_t*
_simple_map(node)(struct _simple_map(t) * h, simple_map_int_t x)
{
    return (simple_map_node_t*)&(h->p[x]);
}

static inline simple_map_int_t
_simple_map(next_slot)(simple_map_int_t slot, simple_map_int_t inc, simple_map_int_t size)
{
    slot += inc;
    return slot >= size ? slot - size : slot;
}

#if defined(simple_map_hash_key) && defined(simple_map_cmp_key)
/**
 * If it is necessary to search by something different
 * than a hash node, define simple_map_hash_key and simple_map_eq_key
 * and use simple_map_find().
 */
static inline simple_map_int_t
_simple_map(find)(struct _simple_map(t) * h, simple_map_key_t key, simple_map_arg_t arg)
{
    (void)arg;

    simple_map_int_t k = simple_map_hash_key(key, arg);
    uint8_t hk = simple_map_gethk(k);
    (void)hk;
    simple_map_int_t i = k % h->n_buckets;
    simple_map_int_t inc = 1 + k % (h->n_buckets - 1);
    for (;;)
    {
        if ((simple_map_mayeq(h, i, hk) &&
             !simple_map_cmp_key(key, simple_map_node(h, i), arg)))
            return i;

        if (!simple_map_dirty(h, i))
            return h->n_buckets;

        i = _simple_map(next_slot)(i, inc, h->n_buckets);
    }
}
#endif

static inline simple_map_int_t
_simple_map(get)(struct _simple_map(t) * h, const simple_map_node_t* node, simple_map_arg_t arg)
{
    (void)arg;

    simple_map_int_t k = simple_map_hash(node, arg);
    uint8_t hk = simple_map_gethk(k);
    (void)hk;
    simple_map_int_t i = k % h->n_buckets;
    simple_map_int_t inc = 1 + k % (h->n_buckets - 1);
    for (;;)
    {
        if ((simple_map_mayeq(h, i, hk) && !simple_map_cmp(node, simple_map_node(h, i), arg)))
            return i;

        if (!simple_map_dirty(h, i))
            return h->n_buckets;

        i = _simple_map(next_slot)(i, inc, h->n_buckets);
    }
}

static inline simple_map_int_t
_simple_map(random)(struct _simple_map(t) * h, simple_map_int_t rnd)
{
    simple_map_int_t res = simple_map_next(h, rnd % simple_map_end(h));
    if (res != simple_map_end(h))
        return res;
    return simple_map_first(h);
}

static inline simple_map_int_t
_simple_map(put_slot)(struct _simple_map(t) * h, const simple_map_node_t* node, int* exist, simple_map_arg_t arg)
{
    (void)arg;

    simple_map_int_t k = simple_map_hash(node, arg); /* hash key */
    uint8_t hk = simple_map_gethk(k);
    (void)hk;
    simple_map_int_t i = k % h->n_buckets;             /* offset in the hash table. */
    simple_map_int_t inc = 1 + k % (h->n_buckets - 1); /* overflow chain increment. */

    *exist = 1;
    /* Skip through all collisions. */
    while (simple_map_exist(h, i))
    {
        if (simple_map_mayeq(h, i, hk) && !simple_map_cmp(node, simple_map_node(h, i), arg))
            return i; /* Found a duplicate. */
        /*
         * Mark this link as part of a collision chain. The
         * chain always ends with a non-marked link.
         * Note: the collision chain for this key may share
         * links with collision chains of other keys.
         */
        simple_map_setdirty(h, i);
        i = _simple_map(next_slot)(i, inc, h->n_buckets);
    }
    /*
     * Found an unused, but possibly dirty slot. Use it.
     * However, if this is a dirty slot, first check that
     * there are no duplicates down the collision chain. The
     * current link can also be from a collision chain of some
     * other key, but this is can't be established, so check
     * anyway.
     */
    simple_map_int_t save_i = i;
    while (simple_map_dirty(h, i))
    {
        i = _simple_map(next_slot)(i, inc, h->n_buckets);

        if (simple_map_mayeq(h, i, hk) && !simple_map_cmp(simple_map_node(h, i), node, arg))
            return i; /* Found a duplicate. */
    }
    /* Reached the end of the collision chain: no duplicates. */
    *exist = 0;
    h->size++;
    if (!simple_map_dirty(h, save_i))
        h->n_dirty++;
    simple_map_setexist(h, save_i, hk);
    return save_i;
}

/**
 * Find a node in the hash and replace it with a new value.
 * Save the old node in ret pointer, if it is provided.
 * If the old node didn't exist, just insert the new node.
 *
 * @retval != simple_map_end()   pos of the new node, ret is either NULL
 *                       or copy of the old node
 */
static inline simple_map_int_t
_simple_map(put)(struct _simple_map(t) * h, const simple_map_node_t* node, simple_map_node_t** ret, simple_map_arg_t arg)
{
    simple_map_int_t x = simple_map_end(h);
    int exist;

    assert(h->size < h->n_buckets);

#if SIMPLE_MAP_INCREMENTAL_RESIZE
    if (simple_map_unlikely(h->resize_position > 0))
        _simple_map(resize)(h, arg);
    else if (simple_map_unlikely(h->n_dirty >= h->upper_bound))
    {
        _simple_map(start_resize)(h, h->n_buckets + 1, 0, arg);
    }
    if (h->resize_position)
        _simple_map(put)(h->shadow, node, NULL, arg);
#else
    if (simple_map_unlikely(h->n_dirty >= h->upper_bound))
    {
        _simple_map(start_resize)(h, h->n_buckets + 1, h->size, arg);
    }
#endif

    x = put_slot(h, node, &exist, arg);

    if (ret)
    {
        if (exist)
            memcpy(*ret, &(h->p[x]), sizeof(simple_map_node_t));
        else
            *ret = NULL;
    }
    memcpy(&(h->p[x]), node, sizeof(simple_map_node_t));
    return x;
}

static inline void
_simple_map(del)(struct _simple_map(t) * h, simple_map_int_t x, simple_map_arg_t arg)
{
    if (x != h->n_buckets && simple_map_exist(h, x))
    {
        simple_map_setfree(h, x);
        h->size--;
        if (!simple_map_dirty(h, x))
            h->n_dirty--;
#if SIMPLE_MAP_INCREMENTAL_RESIZE
        if (simple_map_unlikely(h->resize_position))
            _simple_map(del_resize)(h, x, arg);
#endif
    }
}
#endif

static inline void
_simple_map(remove)(struct _simple_map(t) * h, const simple_map_node_t* node, simple_map_arg_t arg)
{
    simple_map_int_t k = _simple_map(get)(h, node, arg);
    if (k != simple_map_end(h))
        _simple_map(del)(h, k, arg);
}

#ifdef SIMPLE_MAP_SOURCE

#ifndef __ac_HASH_PRIME_SIZE
#define __ac_HASH_PRIME_SIZE 31
static const simple_map_int_t __ac_prime_list[__ac_HASH_PRIME_SIZE] = {
    3ul,
    11ul,
    23ul,
    53ul,
    97ul,
    193ul,
    389ul,
    769ul,
    1543ul,
    3079ul,
    6151ul,
    12289ul,
    24593ul,
    49157ul,
    98317ul,
    196613ul,
    393241ul,
    786433ul,
    1572869ul,
    3145739ul,
    6291469ul,
    12582917ul,
    25165843ul,
    50331653ul,
    100663319ul,
    201326611ul,
    402653189ul,
    805306457ul,
    1610612741ul,
    3221225473ul,
    4294967291ul};
#endif /* __ac_HASH_PRIME_SIZE */

NOINLINE void
_simple_map(del_resize)(struct _simple_map(t) * h, simple_map_int_t x, simple_map_arg_t arg)
{
    struct _simple_map(t)* s = h->shadow;
    simple_map_int_t y = _simple_map(get)(s, (const simple_map_node_t*)&(h->p[x]), arg);
    _simple_map(del)(s, y, arg);
    _simple_map(resize)(h, arg);
}

struct _simple_map(t) *
    _simple_map(new)()
{
    struct _simple_map(t)* h = (struct _simple_map(t)*)calloc(1, sizeof(*h));
    h->shadow = (struct _simple_map(t)*)calloc(1, sizeof(*h));
    h->prime = 0;
    h->n_buckets = __ac_prime_list[h->prime];
    h->p = (simple_map_node_t*)calloc(h->n_buckets, sizeof(simple_map_node_t));
#if !simple_map_bytemap
    h->b = (uint32_t*)calloc(h->n_buckets / 16 + 1, sizeof(uint32_t));
#else
    h->b = (uint8_t*)calloc(h->n_buckets, sizeof(uint8_t));
#endif
    h->upper_bound = h->n_buckets * SIMPLE_MAP_DENSITY;
    return h;
}

void _simple_map(clear)(struct _simple_map(t) * h)
{
    simple_map_int_t n_buckets = __ac_prime_list[h->prime];
    simple_map_node_t* p = (simple_map_node_t*)calloc(n_buckets, sizeof(simple_map_node_t));
#if !simple_map_bytemap
    uint32_t* b = (uint32_t*)calloc(n_buckets / 16 + 1, sizeof(uint32_t));
#else
    uint8_t* b = (uint8_t*)calloc(n_buckets, sizeof(uint8_t));
#endif
    if (h->shadow->p)
    {
        free(h->shadow->p);
        free(h->shadow->b);
        memset(h->shadow, 0, sizeof(*h->shadow));
    }
    free(h->p);
    free(h->b);
    h->prime = 0;
    h->n_buckets = n_buckets;
    h->p = p;
    h->b = b;
    h->size = 0;
    h->upper_bound = h->n_buckets * SIMPLE_MAP_DENSITY;
}

void
    _simple_map(delete)(struct _simple_map(t) * h)
{
    if (h->shadow->p)
    {
        free(h->shadow->p);
        free(h->shadow->b);
        memset(h->shadow, 0, sizeof(*h->shadow));
    }
    free(h->shadow);
    free(h->b);
    free(h->p);
    free(h);
}

/** Calculate hash size. */
size_t
_simple_map(memsize)(struct _simple_map(t) * h)
{
    size_t sz = 2 * sizeof(struct _simple_map(t));

    sz += h->n_buckets * sizeof(simple_map_node_t);
#if !simple_map_bytemap
    sz += (h->n_buckets / 16 + 1) * sizeof(uint32_t);
#else
    sz += h->n_buckets;
#endif
    if (h->resize_position)
    {
        h = h->shadow;
        sz += h->n_buckets * sizeof(simple_map_node_t);
#if !simple_map_bytemap
        sz += (h->n_buckets / 16 + 1) * sizeof(uint32_t);
#else
        sz += h->n_buckets;
#endif
    }
    return sz;
}

void _simple_map(resize)(struct _simple_map(t) * h, simple_map_arg_t arg)
{
    struct _simple_map(t)* s = h->shadow;
    int exist;
#if SIMPLE_MAP_INCREMENTAL_RESIZE
    simple_map_int_t batch = h->batch;
#endif
    for (simple_map_int_t i = h->resize_position; i < h->n_buckets; i++)
    {
#if SIMPLE_MAP_INCREMENTAL_RESIZE
        if (batch-- == 0)
        {
            h->resize_position = i;
            return;
        }
#endif
        if (!simple_map_exist(h, i))
            continue;
        simple_map_int_t n = put_slot(s, simple_map_node(h, i), &exist, arg);
        s->p[n] = h->p[i];
    }
    free(h->p);
    free(h->b);
    if (s->size != h->size)
        abort();
    memcpy(h, s, sizeof(*h));
    h->resize_cnt++;
    memset(s, 0, sizeof(*s));
}

void _simple_map(start_resize)(struct _simple_map(t) * h, simple_map_int_t buckets, simple_map_int_t batch, simple_map_arg_t arg)
{
    if (h->resize_position)
    {
        /* resize has already been started */
        return;
    }
    if (buckets < h->n_buckets)
    {
        /* hash size is already greater than requested */
        return;
    }
    simple_map_int_t new_prime = h->prime;
    while (new_prime < __ac_HASH_PRIME_SIZE - 1)
    {
        if (__ac_prime_list[new_prime] >= buckets)
            break;
        new_prime += 1;
    }
    simple_map_int_t new_batch = batch > 0 ? batch : h->n_buckets / (256 * 1024);
    if (new_batch < 256)
    {
        /*
         * Minimal batch must be greater or equal to
         * 1 / (1 - f), where f is upper bound percent
         * = SIMPLE_MAP_DENSITY
         */
        new_batch = 256;
    }

    simple_map_int_t n_buckets = __ac_prime_list[new_prime];
    simple_map_node_t* p = (simple_map_node_t*)malloc(n_buckets * sizeof(simple_map_node_t));
#if !simple_map_bytemap
    uint32_t* b = (uint32_t*)calloc(n_buckets / 16 + 1, sizeof(uint32_t));
#else
    uint8_t* b = (uint8_t*)calloc(n_buckets, sizeof(uint8_t));
#endif
    h->prime = new_prime;
    h->batch = new_batch;
    struct _simple_map(t)* s = h->shadow;
    memcpy(s, h, sizeof(*h));
    s->resize_position = 0;
    s->n_buckets = n_buckets;
    s->upper_bound = s->n_buckets * SIMPLE_MAP_DENSITY;
    s->n_dirty = 0;
    s->size = 0;
    s->p = p;
    s->b = b;
    _simple_map(resize)(h, arg);
}

void _simple_map(reserve)(struct _simple_map(t) * h, simple_map_int_t size, simple_map_arg_t arg)
{
    _simple_map(start_resize)(h, size / SIMPLE_MAP_DENSITY, h->size, arg);
}

#ifndef simple_map_stat
#define simple_map_stat(buf, h) ({                                                                                                                                                                                                            \
    tbuf_printf(buf, "  n_buckets: %" PRIu32 CRLF "  n_dirty: %" PRIu32 CRLF "  size: %" PRIu32 CRLF "  resize_cnt: %" PRIu32 CRLF "  resize_position: %" PRIu32 CRLF, h->n_buckets, h->n_dirty, h->size, h->resize_cnt, h->resize_position); \
})
#endif

#ifdef SIMPLE_MAP_DEBUG
void _simple_map(dump)(struct _simple_map(t) * h)
{
    printf("slots:\n");
    int k = 0;
    for (int i = 0; i < h->n_buckets; i++)
    {
        if (simple_map_dirty(h, i) || simple_map_exist(h, i))
        {
            printf("   [%i] ", i);
            if (simple_map_exist(h, i))
            {
                printf("   -> %p", h->p[i]);
                k++;
            }
            if (simple_map_dirty(h, i))
                printf(" dirty");
            printf("\n");
        }
    }
    printf("end(%i)\n", k);
}
#endif

#endif

#if defined(SIMPLE_MAP_SOURCE) || defined(SIMPLE_MAP_UNDEF)
#undef SIMPLE_MAP_HEADER
#undef simple_map_int_t
#undef simple_map_node_t
#undef simple_map_arg_t
#undef simple_map_key_t
#undef simple_map_name
#undef simple_map_hash
#undef simple_map_hash_key
#undef simple_map_cmp
#undef simple_map_cmp_key
#undef simple_map_node
#undef simple_map_dirty
#undef simple_map_place
#undef simple_map_setdirty
#undef simple_map_setexist
#undef simple_map_setvalue
#undef simple_map_unlikely
#undef slot
#undef slot_and_dirty
#undef SIMPLE_MAP_DENSITY
#undef simple_map_bytemap
#endif

#undef simple_map_cat
#undef simple_map_ecat
#undef _simple_map
