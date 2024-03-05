#ifndef MEMORY_BINDINGS_MEMORY_H
#define MEMORY_BINDINGS_MEMORY_H

#include <memory_configuration.h>
#include <system/types.h>

struct memory_static_buffers;
struct memory_io_buffers;
struct memory_small_data;
struct memory_module;
struct memory_structure_pool;

#if defined(__cplusplus)
extern "C"
{
#endif

    struct memory
    {
        struct memory_static_buffers* static_buffers;
        struct memory_io_buffers* io_buffers;
        struct memory_small_data* small_data;
        struct memory_module* memory_module;
    };

    int32_t memory_initialize(struct memory* memory, struct memory_module_configuration* configuration);

    int32_t memory_static_buffers_get(struct memory* memory);
    void memory_static_buffers_release(struct memory* memory, int32_t buffer_id);
    int32_t memory_static_buffers_available(struct memory* memory);
    int32_t memory_static_buffers_used(struct memory* memory);
    struct iovec* memory_static_buffers_inner(struct memory* memory);

    struct memory_input_buffer* memory_io_buffers_allocate_input(struct memory* memory, size_t initial_capacity);
    struct memory_output_buffer* memory_io_buffers_allocate_output(struct memory* memory, size_t initial_capacity);
    void memory_io_buffers_free_input(struct memory* memory, struct memory_input_buffer* buffer);
    void memory_io_buffers_free_output(struct memory* memory, struct memory_output_buffer* buffer);
    uint8_t* memory_input_buffer_reserve(struct memory_input_buffer* buffer, size_t size);
    uint8_t* memory_input_buffer_finalize(struct memory_input_buffer* buffer, size_t size);
    uint8_t* memory_input_buffer_finalize_reserve(struct memory_input_buffer* buffer, size_t delta, size_t size);
    uint8_t* memory_input_buffer_read_position(struct memory_input_buffer* buffer);
    uint8_t* memory_input_buffer_write_position(struct memory_input_buffer* buffer);
    uint8_t* memory_output_buffer_reserve(struct memory_output_buffer* buffer, size_t size);
    uint8_t* memory_output_buffer_finalize(struct memory_output_buffer* buffer, size_t size);
    uint8_t* memory_output_buffer_finalize_reserve(struct memory_output_buffer* buffer, size_t delta, size_t size);
    struct iovec* memory_output_buffer_content(struct memory_output_buffer* buffer);

    struct memory_structure_pool* memory_structure_pool_create(struct memory* memory, size_t size);
    void* memory_structure_allocate(struct memory_structure_pool* pool);
    void memory_structure_free(struct memory_structure_pool* pool, void* pointer);
    void memory_structure_pool_destroy(struct memory_structure_pool* pool);
    size_t memory_structure_pool_size(struct memory_structure_pool* pool);

    void* memory_small_data_allocate(struct memory* memory, size_t size);
    void memory_small_data_free(struct memory* memory, void* pointer, size_t size);

    void memory_destroy(struct memory* memory);
#if defined(__cplusplus)
}
#endif

#endif