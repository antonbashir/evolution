#ifndef STORAGE_BOX_H
#define STORAGE_BOX_H

#include <common/common.h>
#include <executor/task.h>
#include <system/library.h>

#if defined(__cplusplus)
extern "C"
{
#endif

typedef void (*executor_action)(struct executor_task*);

DART_STRUCTURE struct storage_box
{
    DART_FIELD DART_SUBSTITUTE(uintptr_t) executor_action storage_evaluate_address;
    DART_FIELD DART_SUBSTITUTE(uintptr_t) executor_action storage_call_address;
    DART_FIELD DART_SUBSTITUTE(uintptr_t) executor_action storage_iterator_next_single_address;
    DART_FIELD DART_SUBSTITUTE(uintptr_t) executor_action storage_iterator_next_many_address;
    DART_FIELD DART_SUBSTITUTE(uintptr_t) executor_action storage_iterator_destroy_address;
    DART_FIELD DART_SUBSTITUTE(uintptr_t) executor_action storage_free_output_buffer_address;
    DART_FIELD DART_SUBSTITUTE(uintptr_t) executor_action storage_space_id_by_name_address;
    DART_FIELD DART_SUBSTITUTE(uintptr_t) executor_action storage_space_count_address;
    DART_FIELD DART_SUBSTITUTE(uintptr_t) executor_action storage_space_length_address;
    DART_FIELD DART_SUBSTITUTE(uintptr_t) executor_action storage_space_iterator_address;
    DART_FIELD DART_SUBSTITUTE(uintptr_t) executor_action storage_space_insert_single_address;
    DART_FIELD DART_SUBSTITUTE(uintptr_t) executor_action storage_space_insert_many_address;
    DART_FIELD DART_SUBSTITUTE(uintptr_t) executor_action storage_space_put_single_address;
    DART_FIELD DART_SUBSTITUTE(uintptr_t) executor_action storage_space_put_many_address;
    DART_FIELD DART_SUBSTITUTE(uintptr_t) executor_action storage_space_delete_single_address;
    DART_FIELD DART_SUBSTITUTE(uintptr_t) executor_action storage_space_delete_many_address;
    DART_FIELD DART_SUBSTITUTE(uintptr_t) executor_action storage_space_update_single_address;
    DART_FIELD DART_SUBSTITUTE(uintptr_t) executor_action storage_space_update_many_address;
    DART_FIELD DART_SUBSTITUTE(uintptr_t) executor_action storage_space_get_address;
    DART_FIELD DART_SUBSTITUTE(uintptr_t) executor_action storage_space_min_address;
    DART_FIELD DART_SUBSTITUTE(uintptr_t) executor_action storage_space_max_address;
    DART_FIELD DART_SUBSTITUTE(uintptr_t) executor_action storage_space_truncate_address;
    DART_FIELD DART_SUBSTITUTE(uintptr_t) executor_action storage_space_upsert_address;
    DART_FIELD DART_SUBSTITUTE(uintptr_t) executor_action storage_index_count_address;
    DART_FIELD DART_SUBSTITUTE(uintptr_t) executor_action storage_index_length_address;
    DART_FIELD DART_SUBSTITUTE(uintptr_t) executor_action storage_index_iterator_address;
    DART_FIELD DART_SUBSTITUTE(uintptr_t) executor_action storage_index_get_address;
    DART_FIELD DART_SUBSTITUTE(uintptr_t) executor_action storage_index_max_address;
    DART_FIELD DART_SUBSTITUTE(uintptr_t) executor_action storage_index_min_address;
    DART_FIELD DART_SUBSTITUTE(uintptr_t) executor_action storage_index_update_single_address;
    DART_FIELD DART_SUBSTITUTE(uintptr_t) executor_action storage_index_update_many_address;
    DART_FIELD DART_SUBSTITUTE(uintptr_t) executor_action storage_index_select_address;
    DART_FIELD DART_SUBSTITUTE(uintptr_t) executor_action storage_index_id_by_name_address;
};

DART_STRUCTURE struct storage_space_request
{
    DART_FIELD size_t tuple_size;
    DART_FIELD const uint8_t* tuple;
    DART_FIELD uint32_t space_id;
    DART_FIELD struct executor_task task;
};

DART_STRUCTURE struct storage_space_count_request
{
    DART_FIELD size_t key_size;
    DART_FIELD const uint8_t* key;
    DART_FIELD uint32_t space_id;
    DART_FIELD int32_t iterator_type;
    DART_FIELD struct executor_task task;
};

DART_STRUCTURE struct storage_space_select_request
{
    DART_FIELD size_t key_size;
    DART_FIELD const uint8_t* key;
    DART_FIELD uint32_t space_id;
    DART_FIELD uint32_t offset;
    DART_FIELD uint32_t limit;
    DART_FIELD int32_t iterator_type;
    DART_FIELD struct executor_task task;
};

DART_STRUCTURE struct storage_space_update_request
{
    DART_FIELD size_t key_size;
    DART_FIELD size_t operations_size;
    DART_FIELD const uint8_t* key;
    DART_FIELD const uint8_t* operations;
    DART_FIELD uint32_t space_id;
    DART_FIELD struct executor_task task;
};

DART_STRUCTURE struct storage_space_upsert_request
{
    DART_FIELD size_t tuple_size;
    DART_FIELD const uint8_t* tuple;
    DART_FIELD const uint8_t* operations;
    DART_FIELD size_t operations_size;
    DART_FIELD uint32_t space_id;
    DART_FIELD struct executor_task task;
};

DART_STRUCTURE struct storage_space_iterator_request
{
    DART_FIELD size_t key_size;
    DART_FIELD const uint8_t* key;
    DART_FIELD uint32_t space_id;
    DART_FIELD int32_t type;
    DART_FIELD struct executor_task task;
};

DART_STRUCTURE struct storage_index_request
{
    DART_FIELD size_t tuple_size;
    DART_FIELD const uint8_t* tuple;
    DART_FIELD uint32_t space_id;
    DART_FIELD uint32_t index_id;
    DART_FIELD struct executor_task task;
};

DART_STRUCTURE struct storage_index_count_request
{
    DART_FIELD size_t key_size;
    DART_FIELD const uint8_t* key;
    DART_FIELD uint32_t space_id;
    DART_FIELD uint32_t index_id;
    DART_FIELD int32_t iterator_type;
    DART_FIELD struct executor_task task;
};

DART_STRUCTURE struct storage_index_id_by_name_request
{
    DART_FIELD const char* name;
    DART_FIELD size_t name_length;
    DART_FIELD uint32_t space_id;
    DART_FIELD struct executor_task task;
};

DART_STRUCTURE struct storage_index_update_request
{
    DART_FIELD const uint8_t* key;
    DART_FIELD size_t key_size;
    DART_FIELD const uint8_t* operations;
    DART_FIELD size_t operations_size;
    DART_FIELD uint32_t space_id;
    DART_FIELD uint32_t index_id;
    DART_FIELD struct executor_task task;
};

DART_STRUCTURE struct storage_call_request
{
    DART_FIELD const char* function;
    DART_FIELD const uint8_t* input;
    DART_FIELD size_t input_size;
    DART_FIELD uint32_t function_length;
    DART_FIELD struct executor_task task;
};

DART_STRUCTURE struct storage_evaluate_request
{
    DART_FIELD const char* expression;
    DART_FIELD const uint8_t* input;
    DART_FIELD size_t input_size;
    DART_FIELD uint32_t expression_length;
    DART_FIELD struct executor_task task;
};

DART_STRUCTURE struct storage_index_iterator_request
{
    DART_FIELD const uint8_t* key;
    DART_FIELD size_t key_size;
    DART_FIELD uint32_t space_id;
    DART_FIELD uint32_t index_id;
    DART_FIELD int32_t type;
    DART_FIELD struct executor_task task;
};

DART_STRUCTURE struct storage_index_select_request
{
    DART_FIELD const uint8_t* key;
    DART_FIELD size_t key_size;
    DART_FIELD uint32_t space_id;
    DART_FIELD uint32_t index_id;
    DART_FIELD uint32_t offset;
    DART_FIELD uint32_t limit;
    DART_FIELD int32_t iterator_type;
    DART_FIELD struct executor_task task;
};

DART_STRUCTURE struct storage_index_id_request
{
    DART_FIELD uint32_t space_id;
    DART_FIELD uint32_t index_id;
};

DART_LEAF_FUNCTION void storage_initialize_box(struct storage_box* box);
DART_LEAF_FUNCTION void storage_destroy_box(struct storage_box* box);

DART_LEAF_FUNCTION void storage_evaluate(struct executor_task* task);
DART_LEAF_FUNCTION void storage_call(struct executor_task* task);

DART_LEAF_FUNCTION void storage_space_iterator(struct executor_task* task);
DART_LEAF_FUNCTION void storage_space_count(struct executor_task* task);
DART_LEAF_FUNCTION void storage_space_length(struct executor_task* task);
DART_LEAF_FUNCTION void storage_space_truncate(struct executor_task* task);

DART_LEAF_FUNCTION void storage_space_put_single(struct executor_task* task);
DART_LEAF_FUNCTION void storage_space_insert_single(struct executor_task* task);
DART_LEAF_FUNCTION void storage_space_update_single(struct executor_task* task);
DART_LEAF_FUNCTION void storage_space_delete_single(struct executor_task* task);
DART_LEAF_FUNCTION void storage_space_put_many(struct executor_task* task);
DART_LEAF_FUNCTION void storage_space_insert_many(struct executor_task* task);
DART_LEAF_FUNCTION void storage_space_update_many(struct executor_task* task);
DART_LEAF_FUNCTION void storage_space_delete_many(struct executor_task* task);
DART_LEAF_FUNCTION void storage_space_upsert(struct executor_task* task);
DART_LEAF_FUNCTION void storage_space_get(struct executor_task* task);
DART_LEAF_FUNCTION void storage_space_min(struct executor_task* task);
DART_LEAF_FUNCTION void storage_space_max(struct executor_task* task);
DART_LEAF_FUNCTION void storage_space_select(struct executor_task* task);
DART_LEAF_FUNCTION void storage_space_id_by_name(struct executor_task* task);

DART_LEAF_FUNCTION void storage_index_iterator(struct executor_task* task);
DART_LEAF_FUNCTION void storage_index_count(struct executor_task* task);
DART_LEAF_FUNCTION void storage_index_length(struct executor_task* task);
DART_LEAF_FUNCTION void storage_index_id_by_name(struct executor_task* task);

DART_LEAF_FUNCTION void storage_index_get(struct executor_task* task);
DART_LEAF_FUNCTION void storage_index_min(struct executor_task* task);
DART_LEAF_FUNCTION void storage_index_max(struct executor_task* task);
DART_LEAF_FUNCTION void storage_index_select(struct executor_task* task);
DART_LEAF_FUNCTION void storage_index_update_single(struct executor_task* task);
DART_LEAF_FUNCTION void storage_index_update_many(struct executor_task* task);

DART_LEAF_FUNCTION void storage_iterator_next_single(struct executor_task* task);
DART_LEAF_FUNCTION void storage_iterator_next_many(struct executor_task* task);

DART_LEAF_FUNCTION void storage_iterator_destroy(struct executor_task* task);
DART_LEAF_FUNCTION void storage_free_output_buffer(struct executor_task* task);
DART_LEAF_FUNCTION void storage_free_output_port(struct executor_task* task);
DART_LEAF_FUNCTION void storage_free_output_tuple(struct executor_task* task);

#if defined(__cplusplus)
}
#endif

#endif
