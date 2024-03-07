#ifndef TARANTOOL_BOX_H
#define TARANTOOL_BOX_H

#include <stddef.h>
#include <stdint.h>
#include "executor_task.h"

#if defined(__cplusplus)
extern "C"
{
#endif
    struct tarantool_box
    {
        void (*tarantool_evaluate_address)(struct executor_task*);
        void (*tarantool_call_address)(struct executor_task*);
        void (*tarantool_iterator_next_single_address)(struct executor_task*);
        void (*tarantool_iterator_next_many_address)(struct executor_task*);
        void (*tarantool_iterator_destroy_address)(struct executor_task*);
        void (*tarantool_free_output_buffer_address)(struct executor_task*);
        void (*tarantool_space_id_by_name_address)(struct executor_task*);
        void (*tarantool_space_count_address)(struct executor_task*);
        void (*tarantool_space_length_address)(struct executor_task*);
        void (*tarantool_space_iterator_address)(struct executor_task*);
        void (*tarantool_space_insert_single_address)(struct executor_task*);
        void (*tarantool_space_insert_many_address)(struct executor_task*);
        void (*tarantool_space_put_single_address)(struct executor_task*);
        void (*tarantool_space_put_many_address)(struct executor_task*);
        void (*tarantool_space_delete_single_address)(struct executor_task*);
        void (*tarantool_space_delete_many_address)(struct executor_task*);
        void (*tarantool_space_update_single_address)(struct executor_task*);
        void (*tarantool_space_update_many_address)(struct executor_task*);
        void (*tarantool_space_get_address)(struct executor_task*);
        void (*tarantool_space_min_address)(struct executor_task*);
        void (*tarantool_space_max_address)(struct executor_task*);
        void (*tarantool_space_truncate_address)(struct executor_task*);
        void (*tarantool_space_upsert_address)(struct executor_task*);
        void (*tarantool_index_count_address)(struct executor_task*);
        void (*tarantool_index_length_address)(struct executor_task*);
        void (*tarantool_index_iterator_address)(struct executor_task*);
        void (*tarantool_index_get_address)(struct executor_task*);
        void (*tarantool_index_max_address)(struct executor_task*);
        void (*tarantool_index_min_address)(struct executor_task*);
        void (*tarantool_index_update_single_address)(struct executor_task*);
        void (*tarantool_index_update_many_address)(struct executor_task*);
        void (*tarantool_index_select_address)(struct executor_task*);
        void (*tarantool_index_id_by_name_address)(struct executor_task*);
    };

    struct tarantool_space_request
    {
        size_t tuple_size;
        const uint8_t* tuple;
        uint32_t space_id;
        struct executor_task message;
    };

    struct tarantool_space_count_request
    {
        size_t key_size;
        const uint8_t* key;
        uint32_t space_id;
        int32_t iterator_type;
        struct executor_task message;
    };

    struct tarantool_space_select_request
    {
        size_t key_size;
        const uint8_t* key;
        uint32_t space_id;
        uint32_t offset;
        uint32_t limit;
        int32_t iterator_type;
        struct executor_task message;
    };

    struct tarantool_space_update_request
    {
        size_t key_size;
        size_t operations_size;
        const uint8_t* key;
        const uint8_t* operations;
        uint32_t space_id;
        struct executor_task message;
    };

    struct tarantool_space_upsert_request
    {
        size_t tuple_size;
        const uint8_t* tuple;
        const uint8_t* operations;
        size_t operations_size;
        uint32_t space_id;
        struct executor_task message;
    };

    struct tarantool_space_iterator_request
    {
        size_t key_size;
        const uint8_t* key;
        uint32_t space_id;
        int32_t type;
        struct executor_task message;
    };

    struct tarantool_index_request
    {
        size_t tuple_size;
        const uint8_t* tuple;
        uint32_t space_id;
        uint32_t index_id;
        struct executor_task message;
    };

    struct tarantool_index_count_request
    {
        size_t key_size;
        const uint8_t* key;
        uint32_t space_id;
        uint32_t index_id;
        int32_t iterator_type;
        struct executor_task message;
    };

    struct tarantool_index_id_by_name_request
    {
        const char* name;
        size_t name_length;
        uint32_t space_id;
        struct executor_task message;
    };

    struct tarantool_index_update_request
    {
        const uint8_t* key;
        size_t key_size;
        const uint8_t* operations;
        size_t operations_size;
        uint32_t space_id;
        uint32_t index_id;
        struct executor_task message;
    };

    struct tarantool_call_request
    {
        const char* function;
        const uint8_t* input;
        size_t input_size;
        uint32_t function_length;
        struct executor_task message;
    };

    struct tarantool_evaluate_request
    {
        const char* expression;
        const uint8_t* input;
        size_t input_size;
        uint32_t expression_length;
        struct executor_task message;
    };

    struct tarantool_index_iterator_request
    {
        const uint8_t* key;
        size_t key_size;
        uint32_t space_id;
        uint32_t index_id;
        int32_t type;
        struct executor_task message;
    };

    struct tarantool_index_select_request
    {
        const uint8_t* key;
        size_t key_size;
        uint32_t space_id;
        uint32_t index_id;
        uint32_t offset;
        uint32_t limit;
        int32_t iterator_type;
        struct executor_task message;
    };

    struct tarantool_index_id_request
    {
        uint32_t space_id;
        uint32_t index_id;
    };

    void tarantool_initialize_box(struct tarantool_box* box);
    void tarantool_destroy_box(struct tarantool_box* box);

    void tarantool_evaluate(struct executor_task* message);
    void tarantool_call(struct executor_task* message);

    void tarantool_space_iterator(struct executor_task* message);
    void tarantool_space_count(struct executor_task* message);
    void tarantool_space_length(struct executor_task* message);
    void tarantool_space_truncate(struct executor_task* message);

    void tarantool_space_put_single(struct executor_task* message);
    void tarantool_space_insert_single(struct executor_task* message);
    void tarantool_space_update_single(struct executor_task* message);
    void tarantool_space_delete_single(struct executor_task* message);
    void tarantool_space_put_many(struct executor_task* message);
    void tarantool_space_insert_many(struct executor_task* message);
    void tarantool_space_update_many(struct executor_task* message);
    void tarantool_space_delete_many(struct executor_task* message);
    void tarantool_space_upsert(struct executor_task* message);
    void tarantool_space_get(struct executor_task* message);
    void tarantool_space_min(struct executor_task* message);
    void tarantool_space_max(struct executor_task* message);
    void tarantool_space_select(struct executor_task* message);
    void tarantool_space_id_by_name(struct executor_task* message);

    void tarantool_index_iterator(struct executor_task* message);
    void tarantool_index_count(struct executor_task* message);
    void tarantool_index_length(struct executor_task* message);
    void tarantool_index_id_by_name(struct executor_task* message);

    void tarantool_index_get(struct executor_task* message);
    void tarantool_index_min(struct executor_task* message);
    void tarantool_index_max(struct executor_task* message);
    void tarantool_index_select(struct executor_task* message);
    void tarantool_index_update_single(struct executor_task* message);
    void tarantool_index_update_many(struct executor_task* message);

    void tarantool_iterator_next_single(struct executor_task* message);
    void tarantool_iterator_next_many(struct executor_task* message);

    void tarantool_iterator_destroy(struct executor_task* message);
    void tarantool_free_output_buffer(struct executor_task* message);
    void tarantool_free_output_port(struct executor_task* message);
    void tarantool_free_output_tuple(struct executor_task* message);
#if defined(__cplusplus)
}
#endif

#endif
