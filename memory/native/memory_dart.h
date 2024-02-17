#ifndef MEMORY_DART_IMPLEMENTATION_H
#define MEMORY_DART_IMPLEMENTATION_H

#include <bits/types/struct_iovec.h>
#include <stddef.h>
#include <stdint.h>

typedef struct memory_messages_pool memory_dart_messages_pool;
typedef struct memory_static_buffers memory_dart_static_buffers;
typedef struct memory_io_buffers memory_dart_io_buffers;
typedef struct memory_small_data memory_dart_small_data;
typedef struct memory_memory memory_dart_memory;

#if defined(__cplusplus)
extern "C"
{
#endif
    struct memory_dart_configuration
    {
        size_t quota_size;
        size_t preallocation_size;
        size_t slab_size;
        size_t static_buffers_capacity;
        size_t static_buffer_size;
        size_t ring_size;
        double delay_randomization_factor;
        uint64_t max_delay_micros;
        uint64_t cqe_wait_timeout_millis;
        uint32_t ring_flags;
        uint32_t base_delay_micros;
        uint32_t cqe_wait_count;
        uint32_t cqe_peek_count;
    };

    struct memory_dart
    {
        memory_dart_messages_pool* messages_pool;
        memory_dart_static_buffers* static_buffers;
        memory_dart_io_buffers* io_buffers;
        memory_dart_small_data* small_data;
        memory_dart_memory* memory;
    };

    int memory_dart_initialize(struct memory_dart* interactor, struct memory_dart_configuration* configuration, uint8_t id);

    int32_t memory_dart_static_buffers_get(struct memory_dart* interactor);
    void memory_dart_static_buffers_release(struct memory_dart* interactor, int32_t buffer_id);
    int32_t memory_dart_static_buffers_available(struct memory_dart* interactor);
    int32_t memory_dart_static_buffers_used(struct memory_dart* interactor);
    struct iovec* memory_dart_static_buffers_inner(struct memory_dart* interactor);

    struct memory_input_buffer* memory_dart_io_buffers_allocate_input(struct memory_dart* interactor, size_t initial_capacity);
    struct memory_output_buffer* memory_dart_io_buffers_allocate_output(struct memory_dart* interactor, size_t initial_capacity);
    void memory_dart_io_buffers_free_input(struct memory_dart* interactor, struct memory_input_buffer* buffer);
    void memory_dart_io_buffers_free_output(struct memory_dart* interactor, struct memory_output_buffer* buffer);
    uint8_t* memory_dart_input_buffer_reserve(struct memory_input_buffer* buffer, size_t size);
    uint8_t* memory_dart_input_buffer_allocate(struct memory_input_buffer* buffer, size_t size);
    uint8_t* memory_dart_input_buffer_allocate_reserve(struct memory_input_buffer* buffer, size_t delta, size_t size);
    uint8_t* memory_dart_input_buffer_read_position(struct memory_input_buffer* buffer);
    uint8_t* memory_dart_input_buffer_write_position(struct memory_input_buffer* buffer);
    uint8_t* memory_dart_output_buffer_reserve(struct memory_output_buffer* buffer, size_t size);
    uint8_t* memory_dart_output_buffer_allocate(struct memory_output_buffer* buffer, size_t size);
    uint8_t* memory_dart_output_buffer_allocate_reserve(struct memory_output_buffer* buffer, size_t delta, size_t size);
    struct iovec* memory_dart_output_buffer_content(struct memory_output_buffer* buffer);

    struct memory_message* memory_dart_allocate_message(struct memory_dart* interactor);
    void memory_dart_free_message(struct memory_dart* interactor, struct memory_message* message);

    struct memory_payload_pool* memory_dart_payload_pool_create(struct memory_dart* interactor, size_t size);
    void* memory_dart_payload_allocate(struct memory_payload_pool* pool);
    void memory_dart_payload_free(struct memory_payload_pool* pool, void* pointer);
    void memory_dart_payload_pool_destroy(struct memory_payload_pool* pool);
    size_t memory_dart_payload_pool_size(struct memory_payload_pool* pool);

    void* memory_dart_data_allocate(struct memory_dart* interactor, size_t size);
    void memory_dart_data_free(struct memory_dart* interactor, void* pointer, size_t size);

    void memory_dart_destroy(struct memory_dart* interactor);

    uint64_t memory_dart_tuple_next(const char* buffer, uint64_t offset);
#if defined(__cplusplus)
}
#endif

#endif