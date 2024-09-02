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

#ifndef TABLE_INCREMENTAL_RESIZE
#define TABLE_INCREMENTAL_RESIZE 1
#endif

#include <arrays/pointer.h>
#include <common/common.h>
#include <system/library.h>

#define table_concat(a, b) table##a##_##b
#define table_execute_concat(a, b) table_concat(a, b)
#define _table(x) table_execute_concat(table_name, x)

#define table_unlikely(x) __builtin_expect((x), 0)

#ifndef TABLE_TYPEDEFS
#define TABLE_TYPEDEFS 1
typedef uint32_t table_int_t;
#endif /* TABLE_TYPEDEFS */

#ifndef TABLE_HEADER
#define TABLE_HEADER

#ifndef table_bytemap
#define table_bytemap 0
#endif

#ifndef table_name
#define table_name _default
#endif

#ifndef table_key_t
#define table_key_t int
#endif

#ifndef table_node_t
struct table_default_node_t
{
    int key;
};
#define table_node_t struct table_default_node_t
#endif

#ifndef table_arg_t
#define table_arg_t void*
#endif

#ifndef table_hash
#define table_hash(a, arg) (a->key)
#endif

#ifndef table_hash_key
#define table_hash_key(a, arg) (1)
#endif

#ifndef table_cmp_key
#define table_cmp_key(a, b, arg) (true)
#endif

#ifndef table_cmp
#define table_cmp(a, b, arg) ((a->key) != (a->key))
#endif

struct _table(t)
{
    table_node_t* p;
#if !table_bytemap
    uint32_t* b;
#else
    uint8_t* b;
#endif
    table_int_t n_buckets;
    table_int_t n_dirty;
    table_int_t size;
    table_int_t upper_bound;
    table_int_t prime;

    table_int_t resize_cnt;
    table_int_t resize_position;
    table_int_t batch;
    struct _table(t) * shadow;
};

#if !table_bytemap
#define table_exist(h, i) ({ h->b[i >> 4] & (1 << (i % 16)); })
#define table_dirty(h, i) ({ h->b[i >> 4] & (1u << (i % 16 + 16)); })
#define table_gethk(hash) (1)
#define table_mayeq(h, i, hk) table_exist(h, i)

#define table_setfree(h, i) ({ h->b[i >> 4] &= ~(1 << (i % 16)); })
#define table_setexist(h, i, hk) ({ h->b[i >> 4] |= (1 << (i % 16)); })
#define table_setdirty(h, i) ({ h->b[i >> 4] |= (1u << (i % 16 + 16)); })
#else
#define table_exist(h, i) ({ h->b[i] & 0x7f; })
#define table_dirty(h, i) ({ h->b[i] & 0x80; })
#define table_gethk(hash) ({ (hash) % 127 + 1; })
#define table_mayeq(h, i, hk) ({ table_exist(h, i) == hk; })

#define table_setfree(h, i) ({ h->b[i] &= 0x80; })
#define table_setexist(h, i, hk) ({ h->b[i] |= hk; })
#define table_setdirty(h, i) ({ h->b[i] |= 0x80; })
#endif

#define table_node(h, i) ((const table_node_t*)&((h)->p[(i)]))
#define table_size(h) ({ (h)->size; })
#define table_capacity(h) ({ (h)->n_buckets; })
#define table_begin(h) ({ 0; })
#define table_end(h) ({ (h)->n_buckets; })

#define table_first(h) ({              \
    table_int_t i;                     \
    for (i = 0; i < table_end(h); i++) \
    {                                  \
        if (table_exist(h, i))         \
            break;                     \
    }                                  \
    i;                                 \
})

#define table_next(h, i) ({                    \
    table_int_t n = i;                         \
    if (n < table_end(h))                      \
    {                                          \
        for (n = i + 1; n < table_end(h); n++) \
        {                                      \
            if (table_exist(h, n))             \
                break;                         \
        }                                      \
    }                                          \
    n;                                         \
})

#define table_foreach(h, i) \
    for (i = table_first(h); i < table_end(h); i = table_next(h, i))

#define TABLE_DENSITY 0.7

struct _table(t) * _table(new)();
void _table(clear)(struct _table(t) * h);
void _table(delete)(struct _table(t) * h);
void _table(resize)(struct _table(t) * h, table_arg_t arg);
void _table(start_resize)(struct _table(t) * h, table_int_t buckets, table_int_t batch, table_arg_t arg);
void _table(reserve)(struct _table(t) * h, table_int_t size, table_arg_t arg);
void NOINLINE _table(del_resize)(struct _table(t) * h, table_int_t x, table_arg_t arg);
size_t _table(memsize)(struct _table(t) * h);
void _table(dump)(struct _table(t) * h);

#define put_slot(h, node, exist, arg) \
    _table(put_slot)(h, node, exist, arg)

static inline table_node_t*
_table(node)(struct _table(t) * h, table_int_t x)
{
    return (table_node_t*)&(h->p[x]);
}

static inline table_int_t
_table(next_slot)(table_int_t slot, table_int_t inc, table_int_t size)
{
    slot += inc;
    return slot >= size ? slot - size : slot;
}

#if defined(table_hash_key) && defined(table_cmp_key)
/**
 * If it is necessary to search by something different
 * than a hash node, define table_hash_key and table_eq_key
 * and use table_find().
 */
static inline table_int_t
_table(find)(struct _table(t) * h, table_key_t key, table_arg_t arg)
{
    (void)arg;

    table_int_t k = table_hash_key(key, arg);
    uint8_t hk = table_gethk(k);
    (void)hk;
    table_int_t i = k % h->n_buckets;
    table_int_t inc = 1 + k % (h->n_buckets - 1);
    for (;;)
    {
        if ((table_mayeq(h, i, hk) &&
             !table_cmp_key(key, table_node(h, i), arg)))
            return i;

        if (!table_dirty(h, i))
            return h->n_buckets;

        i = _table(next_slot)(i, inc, h->n_buckets);
    }
}
#endif

static inline table_int_t
_table(get)(struct _table(t) * h, const table_node_t* node, table_arg_t arg)
{
    (void)arg;

    table_int_t k = table_hash(node, arg);
    uint8_t hk = table_gethk(k);
    (void)hk;
    table_int_t i = k % h->n_buckets;
    table_int_t inc = 1 + k % (h->n_buckets - 1);
    for (;;)
    {
        if ((table_mayeq(h, i, hk) && !table_cmp(node, table_node(h, i), arg)))
            return i;

        if (!table_dirty(h, i))
            return h->n_buckets;

        i = _table(next_slot)(i, inc, h->n_buckets);
    }
}

static inline table_int_t
_table(random)(struct _table(t) * h, table_int_t rnd)
{
    table_int_t res = table_next(h, rnd % table_end(h));
    if (res != table_end(h))
        return res;
    return table_first(h);
}

static inline table_int_t
_table(put_slot)(struct _table(t) * h, const table_node_t* node, int* exist, table_arg_t arg)
{
    (void)arg;

    table_int_t k = table_hash(node, arg); /* hash key */
    uint8_t hk = table_gethk(k);
    (void)hk;
    table_int_t i = k % h->n_buckets;             /* offset in the hash table. */
    table_int_t inc = 1 + k % (h->n_buckets - 1); /* overflow chain increment. */

    *exist = 1;
    /* Skip through all collisions. */
    while (table_exist(h, i))
    {
        if (table_mayeq(h, i, hk) && !table_cmp(node, table_node(h, i), arg))
            return i; /* Found a duplicate. */
        /*
         * Mark this link as part of a collision chain. The
         * chain always ends with a non-marked link.
         * Note: the collision chain for this key may share
         * links with collision chains of other keys.
         */
        table_setdirty(h, i);
        i = _table(next_slot)(i, inc, h->n_buckets);
    }
    /*
     * Found an unused, but possibly dirty slot. Use it.
     * However, if this is a dirty slot, first check that
     * there are no duplicates down the collision chain. The
     * current link can also be from a collision chain of some
     * other key, but this is can't be established, so check
     * anyway.
     */
    table_int_t save_i = i;
    while (table_dirty(h, i))
    {
        i = _table(next_slot)(i, inc, h->n_buckets);

        if (table_mayeq(h, i, hk) && !table_cmp(table_node(h, i), node, arg))
            return i; /* Found a duplicate. */
    }
    /* Reached the end of the collision chain: no duplicates. */
    *exist = 0;
    h->size++;
    if (!table_dirty(h, save_i))
        h->n_dirty++;
    table_setexist(h, save_i, hk);
    return save_i;
}

static inline table_int_t
_table(put)(struct _table(t) * h, const table_node_t node, table_node_t* replaced, table_arg_t arg)
{
    table_int_t x = table_end(h);
    int exist;

    assert(h->size < h->n_buckets);

#if TABLE_INCREMENTAL_RESIZE
    if (table_unlikely(h->resize_position > 0))
        _table(resize)(h, arg);
    else if (table_unlikely(h->n_dirty >= h->upper_bound))
    {
        _table(start_resize)(h, h->n_buckets + 1, 0, arg);
    }
    if (h->resize_position)
        _table(put)(h->shadow, node, NULL, arg);
#else
    if (table_unlikely(h->n_dirty >= h->upper_bound))
    {
        _table(start_resize)(h, h->n_buckets + 1, h->size, arg);
    }
#endif

    x = put_slot(h, &node, &exist, arg);

    if (replaced)
    {
        if (exist) *replaced = h->p[x];
    }

    h->p[x] = (table_node_t)node;
    return x;
}

static inline table_int_t
_table(put_copy)(struct _table(t) * h, const table_node_t* node, table_node_t** ret, table_arg_t arg)
{
    table_int_t x = table_end(h);
    int exist;

    assert(h->size < h->n_buckets);

#if TABLE_INCREMENTAL_RESIZE
    if (table_unlikely(h->resize_position > 0))
        _table(resize)(h, arg);
    else if (table_unlikely(h->n_dirty >= h->upper_bound))
    {
        _table(start_resize)(h, h->n_buckets + 1, 0, arg);
    }
    if (h->resize_position)
        _table(put_copy)(h->shadow, node, NULL, arg);
#else
    if (table_unlikely(h->n_dirty >= h->upper_bound))
    {
        _table(start_resize)(h, h->n_buckets + 1, h->size, arg);
    }
#endif

    x = put_slot(h, node, &exist, arg);

    if (ret)
    {
        if (exist)
            memcpy(*ret, &(h->p[x]), sizeof(table_node_t));
        else
            *ret = NULL;
    }
    memcpy(&(h->p[x]), node, sizeof(table_node_t));
    return x;
}

static inline void
_table(del)(struct _table(t) * h, table_int_t x, table_arg_t arg)
{
    if (x != h->n_buckets && table_exist(h, x))
    {
        table_setfree(h, x);
        h->size--;
        if (!table_dirty(h, x))
            h->n_dirty--;
#if TABLE_INCREMENTAL_RESIZE
        if (table_unlikely(h->resize_position))
            _table(del_resize)(h, x, arg);
#endif
    }
}
#endif

static inline void
_table(remove)(struct _table(t) * h, const table_node_t* node, table_arg_t arg)
{
    table_int_t k = _table(get)(h, node, arg);
    if (k != table_end(h))
        _table(del)(h, k, arg);
}

static inline table_node_t* _table(find_value)(struct _table(t) * map, table_key_t key)
{
    table_int_t slot = _table(find)(map, key, (table_arg_t)NULL);
    return slot != table_end(map) ? _table(node)(map, slot) : NULL;
}

static inline struct pointer_array* _table(keys)(struct _table(t) * map)
{
    struct pointer_array* array = pointer_array_create(map->size, POINTER_ARRAY_DEFAULT_RESIZE_FACTOR);
    table_int_t slot;
    table_foreach(map, slot)
    {
        pointer_array_add(array, _table(node)(map, slot));
    }
    return array;
}

#ifdef TABLE_SOURCE

#ifndef __ac_HASH_PRIME_SIZE
#define __ac_HASH_PRIME_SIZE 31
static const table_int_t __ac_prime_list[__ac_HASH_PRIME_SIZE] = {
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
_table(del_resize)(struct _table(t) * h, table_int_t x, table_arg_t arg)
{
    struct _table(t)* s = h->shadow;
    table_int_t y = _table(get)(s, (const table_node_t*)&(h->p[x]), arg);
    _table(del)(s, y, arg);
    _table(resize)(h, arg);
}

struct _table(t) *
    _table(new)()
{
    struct _table(t)* h = (struct _table(t)*)calloc(1, sizeof(*h));
    h->shadow = (struct _table(t)*)calloc(1, sizeof(*h));
    h->prime = 0;
    h->n_buckets = __ac_prime_list[h->prime];
    h->p = (table_node_t*)calloc(h->n_buckets, sizeof(table_node_t));
#if !table_bytemap
    h->b = (uint32_t*)calloc(h->n_buckets / 16 + 1, sizeof(uint32_t));
#else
    h->b = (uint8_t*)calloc(h->n_buckets, sizeof(uint8_t));
#endif
    h->upper_bound = h->n_buckets * TABLE_DENSITY;
    return h;
}

void _table(clear)(struct _table(t) * h)
{
    table_int_t n_buckets = __ac_prime_list[h->prime];
    table_node_t* p = (table_node_t*)calloc(n_buckets, sizeof(table_node_t));
#if !table_bytemap
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
    h->upper_bound = h->n_buckets * TABLE_DENSITY;
}

void
    _table(delete)(struct _table(t) * h)
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
_table(memsize)(struct _table(t) * h)
{
    size_t sz = 2 * sizeof(struct _table(t));

    sz += h->n_buckets * sizeof(table_node_t);
#if !table_bytemap
    sz += (h->n_buckets / 16 + 1) * sizeof(uint32_t);
#else
    sz += h->n_buckets;
#endif
    if (h->resize_position)
    {
        h = h->shadow;
        sz += h->n_buckets * sizeof(table_node_t);
#if !table_bytemap
        sz += (h->n_buckets / 16 + 1) * sizeof(uint32_t);
#else
        sz += h->n_buckets;
#endif
    }
    return sz;
}

void _table(resize)(struct _table(t) * h, table_arg_t arg)
{
    struct _table(t)* s = h->shadow;
    int exist;
#if TABLE_INCREMENTAL_RESIZE
    table_int_t batch = h->batch;
#endif
    for (table_int_t i = h->resize_position; i < h->n_buckets; i++)
    {
#if TABLE_INCREMENTAL_RESIZE
        if (batch-- == 0)
        {
            h->resize_position = i;
            return;
        }
#endif
        if (!table_exist(h, i))
            continue;
        table_int_t n = put_slot(s, table_node(h, i), &exist, arg);
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

void _table(start_resize)(struct _table(t) * h, table_int_t buckets, table_int_t batch, table_arg_t arg)
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
    table_int_t new_prime = h->prime;
    while (new_prime < __ac_HASH_PRIME_SIZE - 1)
    {
        if (__ac_prime_list[new_prime] >= buckets)
            break;
        new_prime += 1;
    }
    table_int_t new_batch = batch > 0 ? batch : h->n_buckets / (256 * 1024);
    if (new_batch < 256)
    {
        /*
         * Minimal batch must be greater or equal to
         * 1 / (1 - f), where f is upper bound percent
         * = TABLE_DENSITY
         */
        new_batch = 256;
    }

    table_int_t n_buckets = __ac_prime_list[new_prime];
    table_node_t* p = (table_node_t*)malloc(n_buckets * sizeof(table_node_t));
#if !table_bytemap
    uint32_t* b = (uint32_t*)calloc(n_buckets / 16 + 1, sizeof(uint32_t));
#else
    uint8_t* b = (uint8_t*)calloc(n_buckets, sizeof(uint8_t));
#endif
    h->prime = new_prime;
    h->batch = new_batch;
    struct _table(t)* s = h->shadow;
    memcpy(s, h, sizeof(*h));
    s->resize_position = 0;
    s->n_buckets = n_buckets;
    s->upper_bound = s->n_buckets * TABLE_DENSITY;
    s->n_dirty = 0;
    s->size = 0;
    s->p = p;
    s->b = b;
    _table(resize)(h, arg);
}

void _table(reserve)(struct _table(t) * h, table_int_t size, table_arg_t arg)
{
    _table(start_resize)(h, size / TABLE_DENSITY, h->size, arg);
}

#ifndef table_stat
#define table_stat(buf, h) ({                                                                                                                                                                                                                 \
    tbuf_printf(buf, "  n_buckets: %" PRIu32 CRLF "  n_dirty: %" PRIu32 CRLF "  size: %" PRIu32 CRLF "  resize_cnt: %" PRIu32 CRLF "  resize_position: %" PRIu32 CRLF, h->n_buckets, h->n_dirty, h->size, h->resize_cnt, h->resize_position); \
})
#endif

#ifdef TABLE_DEBUG
void _table(dump)(struct _table(t) * h)
{
    printf("slots:\n");
    int k = 0;
    for (int i = 0; i < h->n_buckets; i++)
    {
        if (table_dirty(h, i) || table_exist(h, i))
        {
            printf("   [%i] ", i);
            if (table_exist(h, i))
            {
                printf("   -> %p", h->p[i]);
                k++;
            }
            if (table_dirty(h, i))
                printf(" dirty");
            printf("\n");
        }
    }
    printf("end(%i)\n", k);
}
#endif

#endif

#if defined(TABLE_SOURCE) || defined(TABLE_UNDEF)
#undef TABLE_HEADER
#undef table_int_t
#undef table_node_t
#undef table_arg_t
#undef table_key_t
#undef table_name
#undef table_hash
#undef table_hash_key
#undef table_cmp
#undef table_cmp_key
#undef table_node
#undef table_dirty
#undef table_place
#undef table_setdirty
#undef table_setexist
#undef table_setvalue
#undef table_unlikely
#undef slot
#undef slot_and_dirty
#undef TABLE_DENSITY
#undef table_bytemap
#endif

#undef table_concat
#undef table_execute_concat
#undef _table
