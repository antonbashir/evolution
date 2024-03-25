#include "box/box.h"
#include <lauxlib.h>
#include <lua.h>
#include "box.h"
#include "box/lua/call.h"
#include "box/port.h"
#include "box/session.h"
#include "box/tuple.h"
#include "box/txn.h"
#include "constants.h"
#include "diag.h"
#include "fiber.h"
#include "mempool.h"
#include "msgpuck.h"
#include "port.h"
#include "small.h"
#include "small/obuf.h"

static struct small_alloc storage_box_output_buffers;
static struct mempool storage_tuple_ports;

void storage_initialize_box(struct storage_box* box)
{
    float actual_alloc_factor;
    small_alloc_create(&storage_box_output_buffers, cord_slab_cache(), 3 * sizeof(int), sizeof(uintptr_t), 1.05, &actual_alloc_factor);
    mempool_create(&storage_tuple_ports, cord_slab_cache(), sizeof(struct port));
    box->storage_evaluate_address = &storage_evaluate;
    box->storage_call_address = &storage_call;
    box->storage_iterator_next_single_address = &storage_iterator_next_single;
    box->storage_iterator_next_many_address = &storage_iterator_next_many;
    box->storage_iterator_destroy_address = &storage_iterator_destroy;
    box->storage_free_output_buffer_address = &storage_free_output_buffer;
    box->storage_space_id_by_name_address = &storage_space_id_by_name;
    box->storage_space_count_address = &storage_space_count;
    box->storage_space_length_address = &storage_space_length;
    box->storage_space_iterator_address = &storage_space_iterator;
    box->storage_space_insert_single_address = &storage_space_insert_single;
    box->storage_space_insert_many_address = &storage_space_insert_many;
    box->storage_space_put_single_address = &storage_space_put_single;
    box->storage_space_put_many_address = &storage_space_put_many;
    box->storage_space_delete_single_address = &storage_space_delete_single;
    box->storage_space_delete_many_address = &storage_space_delete_many;
    box->storage_space_update_single_address = &storage_space_update_single;
    box->storage_space_update_many_address = &storage_space_update_many;
    box->storage_space_get_address = &storage_space_get;
    box->storage_space_min_address = &storage_space_min;
    box->storage_space_max_address = &storage_space_max;
    box->storage_space_truncate_address = &storage_space_truncate;
    box->storage_space_upsert_address = &storage_space_upsert;
    box->storage_index_count_address = &storage_index_count;
    box->storage_index_length_address = &storage_index_length;
    box->storage_index_iterator_address = &storage_index_iterator;
    box->storage_index_get_address = &storage_index_get;
    box->storage_index_max_address = &storage_index_max;
    box->storage_index_min_address = &storage_index_min;
    box->storage_index_update_single_address = &storage_index_update_single;
    box->storage_index_update_many_address = &storage_index_update_many;
    box->storage_index_select_address = &storage_index_select;
    box->storage_index_id_by_name_address = &storage_index_id_by_name;
}

void storage_evaluate(struct executor_task* task)
{
    struct storage_evaluate_request* request = (struct storage_evaluate_request*)task->input;
    struct port out_port, in_port;
    struct obuf out_buffer;
    obuf_create(&out_buffer, cord_slab_cache(), 1);
    port_msgpack_create(&in_port, (const char*)request->input, request->input_size);
    box_lua_eval(request->expression, request->expression_length, &in_port, &out_port);
    port_destroy(&in_port);
    size_t return_count = ((struct port_lua*)&out_port)->size;
    port_dump_msgpack(&out_port, &out_buffer);
    port_destroy(&out_port);
    size_t size = obuf_size(&out_buffer) + mp_sizeof_array(return_count);
    char* output = smalloc(&storage_box_output_buffers, size);
    char* result = mp_encode_array(output, return_count);
    for (size_t i = 0; i < out_buffer.n_iov; i++)
    {
        struct iovec* vec = &out_buffer.iov[i];
        memcpy(result, vec->iov_base, vec->iov_len);
        result += vec->iov_len;
    }
    task->output = output;
    task->output_size = size;
}

void storage_call(struct executor_task* task)
{
    struct storage_call_request* request = (struct storage_call_request*)task->input;
    struct port out_port, in_port;
    struct obuf out_buffer;
    obuf_create(&out_buffer, cord_slab_cache(), 1);
    port_msgpack_create(&in_port, (const char*)request->input, request->input_size);
    box_lua_call(request->function, request->function_length, &in_port, &out_port);
    port_destroy(&in_port);
    size_t return_count = ((struct port_lua*)&out_port)->size;
    port_dump_msgpack(&out_port, &out_buffer);
    port_destroy(&out_port);
    size_t size = obuf_size(&out_buffer) + mp_sizeof_array(return_count);
    char* output = smalloc(&storage_box_output_buffers, size);
    char* result = mp_encode_array(output, return_count);
    for (size_t i = 0; i < out_buffer.n_iov; i++)
    {
        struct iovec* vec = &out_buffer.iov[i];
        memcpy(result, vec->iov_base, vec->iov_len);
        result += vec->iov_len;
    }
    task->output = output;
    task->output_size = size;
}

void storage_space_iterator(struct executor_task* task)
{
    struct storage_space_iterator_request* request = (struct storage_space_iterator_request*)task->input;
    task->output = (void*)box_index_iterator(request->space_id,
                                             STORAGE_PRIMARY_INDEX_ID,
                                             request->type,
                                             (const char*)request->key,
                                             (const char*)(request->key + request->key_size));
}

void storage_space_count(struct executor_task* task)
{
    struct storage_space_count_request* request = (struct storage_space_count_request*)task->input;
    task->output = (void*)box_index_count(request->space_id,
                                          STORAGE_PRIMARY_INDEX_ID,
                                          request->iterator_type,
                                          (const char*)request->key,
                                          (const char*)(request->key + request->key_size));
}

void storage_space_length(struct executor_task* task)
{
    task->output = (void*)box_index_len((uint32_t)(uintptr_t)task->input, STORAGE_PRIMARY_INDEX_ID);
}

void storage_space_put_single(struct executor_task* task)
{
    struct storage_space_request* request = (struct storage_space_request*)task->input;
    box_tuple_t* result;
    if (unlikely(box_replace(request->space_id,
                             (const char*)request->tuple,
                             (const char*)(request->tuple + request->tuple_size),
                             &result) < 0))
    {
        return;
    }
    tuple_ref(result);
    task->output = result;
}

void storage_space_insert_single(struct executor_task* task)
{
    struct storage_space_request* request = (struct storage_space_request*)task->input;
    box_tuple_t* result;
    if (unlikely(box_insert(request->space_id,
                            (const char*)request->tuple,
                            (const char*)(request->tuple + request->tuple_size),
                            &result) < 0))
    {
        diag_log();
        return;
    }
    tuple_ref(result);
    task->output = result;
}

void storage_space_delete_single(struct executor_task* task)
{
    struct storage_space_request* request = (struct storage_space_request*)task->input;
    box_tuple_t* result;
    if (unlikely(box_delete(request->space_id,
                            STORAGE_PRIMARY_INDEX_ID,
                            (const char*)request->tuple,
                            (const char*)(request->tuple + request->tuple_size),
                            &result) < 0))
    {
        return;
    }
    tuple_ref(result);
    task->output = result;
}

void storage_space_update_single(struct executor_task* task)
{
    struct storage_space_update_request* request = (struct storage_space_update_request*)task->input;
    box_tuple_t* result;
    if (unlikely(box_update(request->space_id,
                            STORAGE_PRIMARY_INDEX_ID,
                            (const char*)request->key,
                            (const char*)(request->key + request->key_size),
                            (const char*)request->operations,
                            (const char*)(request->operations + request->operations_size),
                            STORAGE_INDEX_BASE_C,
                            &result) < 0))
    {
        return;
    }
    tuple_ref(result);
    task->output = result;
}

void storage_space_put_many(struct executor_task* task)
{
    struct storage_space_request* request = (struct storage_space_request*)task->input;
    struct port* port = mempool_alloc(&storage_tuple_ports);
    port_c_create(port);
    const char* batch = (const char*)request->tuple;
    uint32_t count = mp_decode_array(&batch);
    const char* tuple_next = batch;
    const char* tuple_data = tuple_next;
    const char* tuple_next_size = tuple_next;
    struct txn* transaction = txn_begin();
    while (count-- > 0)
    {
        tuple_data = tuple_next;
        uint32_t tuple_size = mp_decode_array(&tuple_next_size);
        box_tuple_t* tuple;
        if (unlikely(box_replace(request->space_id,
                                 tuple_data,
                                 tuple_data + tuple_size,
                                 &tuple) < 0))
        {
            port_destroy(port);
            txn_rollback(transaction);
            return;
        }
        tuple_ref(tuple);
        if (unlikely(port_c_add_tuple(port, tuple)))
        {
            port_destroy(port);
            txn_rollback(transaction);
            return;
        }
        mp_next(&tuple_next);
        tuple_next_size = tuple_next;
    }
    if (txn_commit(transaction))
    {
        port_destroy(port);
        return;
    }
    task->output = port;
}

void storage_space_insert_many(struct executor_task* task)
{
    struct storage_space_request* request = (struct storage_space_request*)task->input;
    struct port* port = mempool_alloc(&storage_tuple_ports);
    port_c_create(port);
    const char* batch = (const char*)request->tuple;
    uint32_t count = mp_decode_array(&batch);
    const char* tuple_next = batch;
    const char* tuple_data = tuple_next;
    const char* tuple_next_size = tuple_next;
    struct txn* transaction = txn_begin();
    while (count-- > 0)
    {
        tuple_data = tuple_next;
        uint32_t tuple_size = mp_decode_array(&tuple_next_size);
        box_tuple_t* tuple;
        if (unlikely(box_insert(request->space_id,
                                tuple_data,
                                tuple_data + tuple_size,
                                &tuple) < 0))
        {
            port_destroy(port);
            txn_rollback(transaction);
            return;
        }
        tuple_ref(tuple);
        if (unlikely(port_c_add_tuple(port, tuple)))
        {
            port_destroy(port);
            txn_rollback(transaction);
            return;
        }
        mp_next(&tuple_next);
        tuple_next_size = tuple_next;
    }
    if (txn_commit(transaction))
    {
        port_destroy(port);
        return;
    }
    task->output = port;
}

void storage_space_update_many(struct executor_task* task)
{
    struct storage_space_update_request* request = (struct storage_space_update_request*)task->input;
    struct port* port = mempool_alloc(&storage_tuple_ports);
    port_c_create(port);

    const char* key_batch = (const char*)request->key;
    uint32_t count = mp_decode_array(&key_batch);
    const char* key_next = key_batch;
    const char* key_data = key_next;
    const char* key_next_size = key_next;

    const char* operation_batch = (const char*)request->operations;
    uint32_t operations_count = mp_decode_array(&operation_batch);
    const char* operation_next = operation_batch;
    const char* operation_data = operation_next;
    const char* operation_next_size = operation_next;

    struct txn* transaction = txn_begin();
    while (count-- > 0)
    {
        key_data = key_next;
        operation_data = operation_next;
        uint32_t key_size = mp_decode_array(&key_next_size);
        uint32_t operation_size = mp_decode_array(&operation_next_size);
        box_tuple_t* tuple;
        if (unlikely(box_update(request->space_id,
                                STORAGE_PRIMARY_INDEX_ID,
                                key_data,
                                key_data + key_size,
                                operation_data,
                                operation_data + operation_size,
                                STORAGE_INDEX_BASE_C,
                                &tuple) < 0))
        {
            port_destroy(port);
            txn_rollback(transaction);
            return;
        }
        tuple_ref(tuple);
        if (unlikely(port_c_add_tuple(port, tuple)))
        {
            port_destroy(port);
            txn_rollback(transaction);
            return;
        }
        mp_next(&key_next);
        key_next_size = key_next;
        mp_next(&operation_next);
        operation_next_size = operation_next;
    }
    if (txn_commit(transaction))
    {
        port_destroy(port);
        return;
    }
    task->output = port;
}

void storage_space_delete_many(struct executor_task* task)
{
    struct storage_space_request* request = (struct storage_space_request*)task->input;
    struct port* port = mempool_alloc(&storage_tuple_ports);
    port_c_create(port);
    const char* batch = (const char*)request->tuple;
    uint32_t count = mp_decode_array(&batch);
    const char* tuple_next = batch;
    const char* tuple_data = tuple_next;
    const char* tuple_next_size = tuple_next;
    struct txn* transaction = txn_begin();
    while (count-- > 0)
    {
        tuple_data = tuple_next;
        uint32_t tuple_size = mp_decode_array(&tuple_next_size);
        box_tuple_t* tuple;
        if (unlikely(box_delete(request->space_id,
                                STORAGE_PRIMARY_INDEX_ID,
                                tuple_data,
                                tuple_data + tuple_size,
                                &tuple) < 0))
        {
            port_destroy(port);
            txn_rollback(transaction);
            return;
        }
        tuple_ref(tuple);
        if (unlikely(port_c_add_tuple(port, tuple)))
        {
            port_destroy(port);
            txn_rollback(transaction);
            return;
        }
        mp_next(&tuple_next);
        tuple_next_size = tuple_next;
    }
    if (txn_commit(transaction))
    {
        port_destroy(port);
        return;
    }
    task->output = port;
}

void storage_space_upsert(struct executor_task* task)
{
    struct storage_space_upsert_request* request = (struct storage_space_upsert_request*)task->input;
    box_tuple_t* result;
    if (unlikely(box_upsert(request->space_id,
                            STORAGE_PRIMARY_INDEX_ID,
                            (const char*)request->tuple,
                            (const char*)(request->tuple + request->tuple_size),
                            (const char*)request->operations,
                            (const char*)(request->operations + request->operations_size),
                            STORAGE_INDEX_BASE_C,
                            &result) < 0))
    {
        return;
    }
    tuple_ref(result);
    task->output = result;
}

void storage_space_get(struct executor_task* task)
{
    struct storage_space_request* request = (struct storage_space_request*)task->input;
    box_tuple_t* result;
    if (unlikely(box_index_get(request->space_id,
                               STORAGE_PRIMARY_INDEX_ID,
                               (const char*)request->tuple,
                               (const char*)(request->tuple + request->tuple_size),
                               &result) < 0))
    {
        diag_log();
        return;
    }
    tuple_ref(result);
    task->output = result;
}

void storage_space_min(struct executor_task* task)
{
    struct storage_space_request* request = (struct storage_space_request*)task->input;
    box_tuple_t* result;
    if (unlikely(box_index_min(request->space_id,
                               STORAGE_PRIMARY_INDEX_ID,
                               (const char*)request->tuple,
                               (const char*)(request->tuple + request->tuple_size),
                               &result) < 0))
    {
        return;
    }
    tuple_ref(result);
    task->output = result;
}

void storage_space_max(struct executor_task* task)
{
    struct storage_space_request* request = (struct storage_space_request*)task->input;
    box_tuple_t* result;
    if (unlikely(box_index_max(request->space_id,
                               STORAGE_PRIMARY_INDEX_ID,
                               (const char*)request->tuple,
                               (const char*)(request->tuple + request->tuple_size),
                               &result) < 0))
    {
        return;
    }
    tuple_ref(result);
    task->output = result;
}

void storage_space_select(struct executor_task* task)
{
    struct storage_space_select_request* request = (struct storage_space_select_request*)task->input;
    struct port* port = mempool_alloc(&storage_tuple_ports);
    if (unlikely(box_select(request->space_id,
                            STORAGE_PRIMARY_INDEX_ID,
                            request->iterator_type,
                            request->offset,
                            request->limit,
                            (const char*)request->key,
                            (const char*)(request->key + request->key_size),
                            NULL,
                            NULL,
                            false,
                            port) < 0))
    {
        return;
    }

    task->output = port;
}

void storage_space_truncate(struct executor_task* task)
{
    box_truncate((uint32_t)(uintptr_t)task->input);
}

void storage_space_id_by_name(struct executor_task* task)
{
    task->output = (void*)(uintptr_t)box_space_id_by_name(task->input, task->input_size);
}

void storage_index_iterator(struct executor_task* task)
{
    struct storage_index_iterator_request* request = (struct storage_index_iterator_request*)task->input;
    task->output = (void*)box_index_iterator(request->space_id,
                                             request->index_id,
                                             request->type,
                                             (const char*)request->key,
                                             (const char*)(request->key + request->key_size));
}

void storage_index_count(struct executor_task* task)
{
    struct storage_index_count_request* request = (struct storage_index_count_request*)task->input;
    task->output = (void*)box_index_count(request->space_id,
                                          request->index_id,
                                          request->iterator_type,
                                          (const char*)request->key,
                                          (const char*)(request->key + request->key_size));
}

void storage_index_length(struct executor_task* task)
{
    struct storage_index_id_request* id = (struct storage_index_id_request*)task->input;
    task->output = (void*)box_index_len(id->space_id, id->index_id);
}

void storage_index_id_by_name(struct executor_task* task)
{
    struct storage_index_id_by_name_request* request = (struct storage_index_id_by_name_request*)task->input;
    task->output = (void*)(uintptr_t)box_index_id_by_name(request->space_id, request->name, request->name_length);
}

void storage_index_get(struct executor_task* task)
{
    struct storage_index_request* request = (struct storage_index_request*)task->input;
    box_tuple_t* result;
    if (unlikely(box_index_get(request->space_id,
                               request->index_id,
                               (const char*)request->tuple,
                               (const char*)(request->tuple + request->tuple_size),
                               &result) < 0))
    {
        return;
    }
    tuple_ref(result);
    task->output = result;
}

void storage_index_min(struct executor_task* task)
{
    struct storage_index_request* request = (struct storage_index_request*)task->input;
    box_tuple_t* result;
    if (unlikely(box_index_min(request->space_id,
                               request->index_id,
                               (const char*)request->tuple,
                               (const char*)(request->tuple + request->tuple_size),
                               &result) < 0))
    {
        return;
    }
    tuple_ref(result);
    task->output = result;
}

void storage_index_max(struct executor_task* task)
{
    struct storage_index_request* request = (struct storage_index_request*)task->input;
    box_tuple_t* result;
    if (unlikely(box_index_max(request->space_id,
                               request->index_id,
                               (const char*)request->tuple,
                               (const char*)(request->tuple + request->tuple_size),
                               &result) < 0))
    {
        return;
    }
    tuple_ref(result);
    task->output = result;
}

void storage_index_select(struct executor_task* task)
{
    struct storage_index_select_request* request = (struct storage_index_select_request*)task->input;
    struct port* port = mempool_alloc(&storage_tuple_ports);
    if (unlikely(box_select(request->space_id,
                            request->index_id,
                            request->iterator_type,
                            request->offset,
                            request->limit,
                            (const char*)request->key,
                            (const char*)(request->key + request->key_size),
                            NULL,
                            NULL,
                            false,
                            port) < 0))
    {
        return;
    }
    task->output = port;
}

void storage_index_update_single(struct executor_task* task)
{
    struct storage_index_update_request* request = (struct storage_index_update_request*)task->input;
    box_tuple_t* result;
    if (unlikely(box_update(request->space_id,
                            request->index_id,
                            (const char*)request->key,
                            (const char*)(request->key + request->key_size),
                            (const char*)request->operations,
                            (const char*)(request->operations + request->operations_size),
                            STORAGE_INDEX_BASE_C,
                            &result) < 0))
    {
        return;
    }
    tuple_ref(result);
    task->output = result;
}

void storage_iterator_next_single(struct executor_task* task)
{
    box_tuple_t* tuple;
    if (unlikely(box_iterator_next((box_iterator_t*)task->input, &tuple) < 0 || !tuple))
    {
        return;
    }
    tuple_ref(tuple);
    task->output = tuple;
}

void storage_index_update_many(struct executor_task* task)
{
    struct storage_index_update_request* request = (struct storage_index_update_request*)task->input;
    struct port* port = mempool_alloc(&storage_tuple_ports);
    port_c_create(port);

    const char* key_batch = (const char*)request->key;
    uint32_t count = mp_decode_array(&key_batch);
    const char* key_next = key_batch;
    const char* key_data = key_next;
    const char* key_next_size = key_next;

    const char* operation_batch = (const char*)request->operations;
    uint32_t operations_count = mp_decode_array(&operation_batch);
    const char* operation_next = operation_batch;
    const char* operation_data = operation_next;
    const char* operation_next_size = operation_next;

    struct txn* transaction = txn_begin();
    while (count-- > 0)
    {
        key_data = key_next;
        operation_data = operation_next;
        uint32_t key_size = mp_decode_array(&key_next_size);
        uint32_t operation_size = mp_decode_array(&operation_next_size);
        box_tuple_t* tuple;
        if (unlikely(box_update(request->space_id,
                                request->index_id,
                                key_data,
                                key_data + key_size,
                                operation_data,
                                operation_data + operation_size,
                                STORAGE_INDEX_BASE_C,
                                &tuple) < 0))
        {
            port_destroy(port);
            txn_rollback(transaction);
            return;
        }
        tuple_ref(tuple);
        if (unlikely(port_c_add_tuple(port, tuple)))
        {
            port_destroy(port);
            txn_rollback(transaction);
            return;
        }
        mp_next(&key_next);
        key_next_size = key_next;
        mp_next(&operation_next);
        operation_next_size = operation_next;
    }
    if (txn_commit(transaction))
    {
        port_destroy(port);
        return;
    }
    task->output = port;
}

void storage_iterator_next_many(struct executor_task* task)
{
    struct port* port = mempool_alloc(&storage_tuple_ports);
    port_c_create(port);
    uint32_t found = 0;
    while (found < task->input_size)
    {
        box_tuple_t* tuple;
        if (unlikely(box_iterator_next((box_iterator_t*)task->input, &tuple) < 0 || !tuple))
        {
            port_destroy(port);
            return;
        }
        if (unlikely(port_c_add_tuple(port, tuple)))
        {
            port_destroy(port);
            return;
        }
        found++;
    }
    task->output = port;
}

void storage_iterator_destroy(struct executor_task* task)
{
    box_iterator_free((box_iterator_t*)task->input);
}

void storage_free_output_buffer(struct executor_task* task)
{
    smfree(&storage_box_output_buffers, task->input, task->input_size);
}

void storage_free_output_port(struct executor_task* task)
{
    port_destroy(task->input);
    mempool_free(&storage_tuple_ports, task->input);
}

void storage_free_output_tuple(struct executor_task* task)
{
    tuple_unref(task->input);
}

void storage_destroy_box(struct storage_box* box)
{
    (void)box;
    small_alloc_destroy(&storage_box_output_buffers);
    mempool_destroy(&storage_tuple_ports);
}
