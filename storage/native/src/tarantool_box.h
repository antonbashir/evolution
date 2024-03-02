#ifndef TARANTOOL_BOX_H
#define TARANTOOL_BOX_H

#include <stddef.h>
#include <stdint.h>
#include "mediator_message.h"

#if defined(__cplusplus)
extern "C"
{
#endif
    struct tarantool_box
    {
        void (*tarantool_evaluate_address)(struct mediator_message*);
        void (*tarantool_call_address)(struct mediator_message*);
        void (*tarantool_iterator_next_single_address)(struct mediator_message*);
        void (*tarantool_iterator_next_many_address)(struct mediator_message*);
        void (*tarantool_iterator_destroy_address)(struct mediator_message*);
        void (*tarantool_free_output_buffer_address)(struct mediator_message*);
        void (*tarantool_space_id_by_name_address)(struct mediator_message*);
        void (*tarantool_space_count_address)(struct mediator_message*);
        void (*tarantool_space_length_address)(struct mediator_message*);
        void (*tarantool_space_iterator_address)(struct mediator_message*);
        void (*tarantool_space_insert_single_address)(struct mediator_message*);
        void (*tarantool_space_insert_many_address)(struct mediator_message*);
        void (*tarantool_space_put_single_address)(struct mediator_message*);
        void (*tarantool_space_put_many_address)(struct mediator_message*);
        void (*tarantool_space_delete_single_address)(struct mediator_message*);
        void (*tarantool_space_delete_many_address)(struct mediator_message*);
        void (*tarantool_space_update_single_address)(struct mediator_message*);
        void (*tarantool_space_update_many_address)(struct mediator_message*);
        void (*tarantool_space_get_address)(struct mediator_message*);
        void (*tarantool_space_min_address)(struct mediator_message*);
        void (*tarantool_space_max_address)(struct mediator_message*);
        void (*tarantool_space_truncate_address)(struct mediator_message*);
        void (*tarantool_space_upsert_address)(struct mediator_message*);
        void (*tarantool_index_count_address)(struct mediator_message*);
        void (*tarantool_index_length_address)(struct mediator_message*);
        void (*tarantool_index_iterator_address)(struct mediator_message*);
        void (*tarantool_index_get_address)(struct mediator_message*);
        void (*tarantool_index_max_address)(struct mediator_message*);
        void (*tarantool_index_min_address)(struct mediator_message*);
        void (*tarantool_index_update_single_address)(struct mediator_message*);
        void (*tarantool_index_update_many_address)(struct mediator_message*);
        void (*tarantool_index_select_address)(struct mediator_message*);
        void (*tarantool_index_id_by_name_address)(struct mediator_message*);
    };

    struct tarantool_space_request
    {
        size_t tuple_size;
        const uint8_t* tuple;
        uint32_t space_id;
        struct mediator_message message;
    };

    struct tarantool_space_count_request
    {
        size_t key_size;
        const uint8_t* key;
        uint32_t space_id;
        int iterator_type;
        struct mediator_message message;
    };

    struct tarantool_space_select_request
    {
        size_t key_size;
        const uint8_t* key;
        uint32_t space_id;
        uint32_t offset;
        uint32_t limit;
        int iterator_type;
        struct mediator_message message;
    };

    struct tarantool_space_update_request
    {
        size_t key_size;
        size_t operations_size;
        const uint8_t* key;
        const uint8_t* operations;
        uint32_t space_id;
        struct mediator_message message;
    };

    struct tarantool_space_upsert_request
    {
        size_t tuple_size;
        const uint8_t* tuple;
        const uint8_t* operations;
        size_t operations_size;
        uint32_t space_id;
        struct mediator_message message;
    };

    struct tarantool_space_iterator_request
    {
        size_t key_size;
        const uint8_t* key;
        uint32_t space_id;
        int type;
        struct mediator_message message;
    };

    struct tarantool_index_request
    {
        size_t tuple_size;
        const uint8_t* tuple;
        uint32_t space_id;
        uint32_t index_id;
        struct mediator_message message;
    };

    struct tarantool_index_count_request
    {
        size_t key_size;
        const uint8_t* key;
        uint32_t space_id;
        uint32_t index_id;
        int iterator_type;
        struct mediator_message message;
    };

    struct tarantool_index_id_by_name_request
    {
        const char* name;
        size_t name_length;
        uint32_t space_id;
        struct mediator_message message;
    };

    struct tarantool_index_update_request
    {
        const uint8_t* key;
        size_t key_size;
        const uint8_t* operations;
        size_t operations_size;
        uint32_t space_id;
        uint32_t index_id;
        struct mediator_message message;
    };

    struct tarantool_call_request
    {
        const char* function;
        const uint8_t* input;
        size_t input_size;
        uint32_t function_length;
        struct mediator_message message;
    };

    struct tarantool_evaluate_request
    {
        const char* expression;
        const uint8_t* input;
        size_t input_size;
        uint32_t expression_length;
        struct mediator_message message;
    };

    struct tarantool_index_iterator_request
    {
        const uint8_t* key;
        size_t key_size;
        uint32_t space_id;
        uint32_t index_id;
        int type;
        struct mediator_message message;
    };

    struct tarantool_index_select_request
    {
        const uint8_t* key;
        size_t key_size;
        uint32_t space_id;
        uint32_t index_id;
        uint32_t offset;
        uint32_t limit;
        int iterator_type;
        struct mediator_message message;
    };

    struct tarantool_index_id_request
    {
        uint32_t space_id;
        uint32_t index_id;
    };

    void tarantool_initialize_box(struct tarantool_box* box);
    void tarantool_destroy_box(struct tarantool_box* box);

    void tarantool_evaluate(struct mediator_message* message);
    void tarantool_call(struct mediator_message* message);

    void tarantool_space_iterator(struct mediator_message* message);
    void tarantool_space_count(struct mediator_message* message);
    void tarantool_space_length(struct mediator_message* message);
    void tarantool_space_truncate(struct mediator_message* message);

    void tarantool_space_put_single(struct mediator_message* message);
    void tarantool_space_insert_single(struct mediator_message* message);
    void tarantool_space_update_single(struct mediator_message* message);
    void tarantool_space_delete_single(struct mediator_message* message);
    void tarantool_space_put_many(struct mediator_message* message);
    void tarantool_space_insert_many(struct mediator_message* message);
    void tarantool_space_update_many(struct mediator_message* message);
    void tarantool_space_delete_many(struct mediator_message* message);
    void tarantool_space_upsert(struct mediator_message* message);
    void tarantool_space_get(struct mediator_message* message);
    void tarantool_space_min(struct mediator_message* message);
    void tarantool_space_max(struct mediator_message* message);
    void tarantool_space_select(struct mediator_message* message);
    void tarantool_space_id_by_name(struct mediator_message* message);

    void tarantool_index_iterator(struct mediator_message* message);
    void tarantool_index_count(struct mediator_message* message);
    void tarantool_index_length(struct mediator_message* message);
    void tarantool_index_id_by_name(struct mediator_message* message);

    void tarantool_index_get(struct mediator_message* message);
    void tarantool_index_min(struct mediator_message* message);
    void tarantool_index_max(struct mediator_message* message);
    void tarantool_index_select(struct mediator_message* message);
    void tarantool_index_update_single(struct mediator_message* message);
    void tarantool_index_update_many(struct mediator_message* message);

    void tarantool_iterator_next_single(struct mediator_message* message);
    void tarantool_iterator_next_many(struct mediator_message* message);

    void tarantool_iterator_destroy(struct mediator_message* message);
    void tarantool_free_output_buffer(struct mediator_message* message);
    void tarantool_free_output_port(struct mediator_message* message);
    void tarantool_free_output_tuple(struct mediator_message* message);
#if defined(__cplusplus)
}
#endif

#endif
