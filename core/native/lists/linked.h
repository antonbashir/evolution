#ifndef CORE_LINKED_H
#define CORE_LINKED_H
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
#include <common/common.h>
#include <system/library.h>

#if defined(__cplusplus)
extern "C"
{
#endif /* defined(__cplusplus) */

#ifndef typeof
#define typeof __typeof__
#endif

#ifndef offsetof
#define offsetof(type, member) ((size_t) & ((type*)0)->member)
#endif

/**
 * List entry and head structure.
 *
 * All functions has always_inline attribute. This way if caller
 * has no_sanitize_address attribute then linked_list functions are not
 * ASAN instrumented too.
 */
struct linked_list
{
    struct linked_list* prev;
    struct linked_list* next;
};

/**
 * init list head (or list entry as ins't included in list)
 */
static FORCEINLINE void
linked_list_create(struct linked_list* list)
{
    list->next = list;
    list->prev = list;
}

/**
 * add item to list
 */
static FORCEINLINE void
linked_list_add(struct linked_list* head, struct linked_list* item)
{
    item->prev = head;
    item->next = head->next;
    item->prev->next = item;
    item->next->prev = item;
}

/**
 * add item to list tail
 */
static FORCEINLINE void
linked_list_add_tail(struct linked_list* head, struct linked_list* item)
{
    item->next = head;
    item->prev = head->prev;
    item->prev->next = item;
    item->next->prev = item;
}

/**
 * delete element
 */
static FORCEINLINE void
linked_list_del(struct linked_list* item)
{
    item->prev->next = item->next;
    item->next->prev = item->prev;
    linked_list_create(item);
}

static FORCEINLINE struct linked_list*
linked_list_shift(struct linked_list* head)
{
    struct linked_list* shift = head->next;
    head->next = shift->next;
    shift->next->prev = head;
    shift->next = shift->prev = shift;
    return shift;
}

static FORCEINLINE struct linked_list*
linked_list_shift_tail(struct linked_list* head)
{
    struct linked_list* shift = head->prev;
    linked_list_del(shift);
    return shift;
}

/**
 * return first element
 */
static FORCEINLINE struct linked_list*
linked_list_first(struct linked_list* head)
{
    return head->next;
}

/**
 * return last element
 */
static FORCEINLINE struct linked_list*
linked_list_last(struct linked_list* head)
{
    return head->prev;
}

/**
 * return next element by element
 */
static FORCEINLINE struct linked_list*
linked_list_next(struct linked_list* item)
{
    return item->next;
}

/**
 * return previous element
 */
static FORCEINLINE struct linked_list*
linked_list_prev(struct linked_list* item)
{
    return item->prev;
}

/**
 * return TRUE if list is empty
 */
static FORCEINLINE int
linked_list_empty(struct linked_list* item)
{
    return item->next == item->prev && item->next == item;
}

/**
@brief delete from one list and add as another's head
@param to the head that will precede our entry
@param item the entry to move
*/
static FORCEINLINE void
linked_list_move(struct linked_list* to, struct linked_list* item)
{
    linked_list_del(item);
    linked_list_add(to, item);
}

/**
@brief delete from one list and add_tail as another's head
@param to the head that will precede our entry
@param item the entry to move
*/
static FORCEINLINE void
linked_list_move_tail(struct linked_list* to, struct linked_list* item)
{
    item->prev->next = item->next;
    item->next->prev = item->prev;
    item->next = to;
    item->prev = to->prev;
    item->prev->next = item;
    item->next->prev = item;
}

static FORCEINLINE void
linked_list_swap(struct linked_list* rhs, struct linked_list* lhs)
{
    struct linked_list tmp = *rhs;
    *rhs = *lhs;
    *lhs = tmp;
    /* Relink the nodes. */
    if (lhs->next == rhs) /* Take care of empty list case */
        lhs->next = lhs;
    lhs->next->prev = lhs;
    lhs->prev->next = lhs;
    if (rhs->next == lhs) /* Take care of empty list case */
        rhs->next = rhs;
    rhs->next->prev = rhs;
    rhs->prev->next = rhs;
}

/**
 * move all items of list head2 to the head of list head1
 */
static FORCEINLINE void
linked_list_splice(struct linked_list* head1, struct linked_list* head2)
{
    if (!linked_list_empty(head2))
    {
        head1->next->prev = head2->prev;
        head2->prev->next = head1->next;
        head1->next = head2->next;
        head2->next->prev = head1;
        linked_list_create(head2);
    }
}

/**
 * move all items of list head2 to the tail of list head1
 */
static FORCEINLINE void
linked_list_splice_tail(struct linked_list* head1, struct linked_list* head2)
{
    if (!linked_list_empty(head2))
    {
        head1->prev->next = head2->next;
        head2->next->prev = head1->prev;
        head1->prev = head2->prev;
        head2->prev->next = head1;
        linked_list_create(head2);
    }
}

/**
 * move the initial part of list head2, up to but excluding item,
 * to list head1; the old content of head1 is discarded
 */
static FORCEINLINE void
linked_list_cut_before(struct linked_list* head1, struct linked_list* head2, struct linked_list* item)
{
    if (head1->next == item)
    {
        linked_list_create(head1);
        return;
    }
    head1->next = head2->next;
    head1->next->prev = head1;
    head1->prev = item->prev;
    head1->prev->next = head1;
    head2->next = item;
    item->prev = head2;
}

/**
 * list head initializer
 */
#define LINKED_LIST_HEAD_INITIALIZER(name) \
    {                                      \
        &(name), &(name)                   \
    }

/**
 * list link node
 */
#define LINKED_LIST_LINK_INITIALIZER \
    {                                \
        0, 0                         \
    }

/**
 * allocate and init head of list
 */
#define LINKED_LIST_HEAD(name) \
    struct linked_list name = LINKED_LIST_HEAD_INITIALIZER(name)

/**
 * return entry by list item
 */
#define linked_list_entry(item, type, member) ({       \
    const typeof(((type*)0)->member)* __mptr = (item); \
    (type*)((char*)__mptr - offsetof(type, member));   \
})

/**
 * return first entry
 */
#define linked_list_first_entry(head, type, member) \
    linked_list_entry(linked_list_first(head), type, member)

/**
 * Remove one element from the list and return it
 * @pre the list is not empty
 */
#define linked_list_shift_entry(head, type, member) \
    linked_list_entry(linked_list_shift(head), type, member)

/**
 * Remove one element from the list tail and return it
 * @pre the list is not empty
 */
#define linked_list_shift_tail_entry(head, type, member) \
    linked_list_entry(linked_list_shift_tail(head), type, member)

/**
 * return last entry
 * @pre the list is not empty
 */
#define linked_list_last_entry(head, type, member) \
    linked_list_entry(linked_list_last(head), type, member)

/**
 * return next entry
 */
#define linked_list_next_entry(item, member) \
    linked_list_entry(linked_list_next(&(item)->member), typeof(*item), member)

/**
 * return previous entry
 */
#define linked_list_prev_entry(item, member) \
    linked_list_entry(linked_list_prev(&(item)->member), typeof(*item), member)

#define linked_list_prev_entry_safe(item, head, member) \
    ((linked_list_prev(&(item)->member) == (head)) ? NULL : linked_list_entry(linked_list_prev(&(item)->member), typeof(*item), member))

/**
 * add entry to list
 */
#define linked_list_add_entry(head, item, member) \
    linked_list_add((head), &(item)->member)

/**
 * add entry to list tail
 */
#define linked_list_add_tail_entry(head, item, member) \
    linked_list_add_tail((head), &(item)->member)

/**
delete from one list and add as another's head
*/
#define linked_list_move_entry(to, item, member) \
    linked_list_move((to), &((item)->member))

/**
delete from one list and add_tail as another's head
*/
#define linked_list_move_tail_entry(to, item, member) \
    linked_list_move_tail((to), &((item)->member))

/**
 * delete entry from list
 */
#define linked_list_del_entry(item, member) \
    linked_list_del(&((item)->member))

/**
 * foreach through list
 */
#define linked_list_foreach(item, head) \
    for (item = linked_list_first(head); item != (head); item = linked_list_next(item))

/**
 * foreach backward through list
 */
#define linked_list_foreach_reverse(item, head) \
    for (item = linked_list_last(head); item != (head); item = linked_list_prev(item))

/**
 * return true if entry points to head of list
 *
 * NOTE: avoid using &item->member, because it may result in ASAN errors
 * in case the item type or member is supposed to be aligned, and the item
 * points to the list head.
 */
#define linked_list_entry_is_head(item, head, member) \
    ((char*)(item) + offsetof(typeof(*item), member) == (char*)(head))

/**
 * foreach through all list entries
 */
#define linked_list_foreach_entry(item, head, member)                   \
    for (item = linked_list_first_entry((head), typeof(*item), member); \
         !linked_list_entry_is_head((item), (head), member);            \
         item = linked_list_next_entry((item), member))

/**
 * foreach backward through all list entries
 */
#define linked_list_foreach_entry_reverse(item, head, member)          \
    for (item = linked_list_last_entry((head), typeof(*item), member); \
         !linked_list_entry_is_head((item), (head), member);           \
         item = linked_list_prev_entry((item), member))

/**
 * foreach through all list entries safe against removal
 */
#define linked_list_foreach_entry_safe(item, head, member, tmp)           \
    for ((item) = linked_list_first_entry((head), typeof(*item), member); \
         !linked_list_entry_is_head((item), (head), member) &&            \
         ((tmp) = linked_list_next_entry((item), member));                \
         (item) = (tmp))

/**
 * foreach backward through all list entries safe against removal
 */
#define linked_list_foreach_entry_safe_reverse(item, head, member, tmp)  \
    for ((item) = linked_list_last_entry((head), typeof(*item), member); \
         !linked_list_entry_is_head((item), (head), member) &&           \
         ((tmp) = linked_list_prev_entry((item), member));               \
         (item) = (tmp))

#if defined(__cplusplus)
} /* extern "C" */
#endif /* defined(__cplusplus) */

#endif /* LINKED_H_INCLUDED */
