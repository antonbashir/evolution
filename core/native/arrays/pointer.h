#ifndef CORE_ARRAYS_POINTER
#define CORE_ARRAYS_POINTER

#include <common/common.h>
#include <numbers/numbers.h>
#include <system/library.h>

DART_STRUCTURE struct pointer_array
{
    DART_FIELD size_t capacity;
    DART_FIELD size_t size;
    DART_FIELD size_t resize_factor;
    DART_FIELD void** memory;
};

#define POINTER_ARRAY_DEFAULT_CAPACITY 16
#define POINTER_ARRAY_DEFAULT_RESIZE_FACTOR 2

DART_INLINE_LEAF_FUNCTION struct pointer_array* pointer_array_create(size_t initial_capacity, size_t resize_factor)
{
    struct pointer_array* array = (struct pointer_array*)calloc(1, sizeof(struct pointer_array));
    array->capacity = initial_capacity;
    array->memory = (void**)calloc(array->capacity, sizeof(void*));
    array->resize_factor = resize_factor;
    array->size = 0;
    return array;
}

DART_INLINE_LEAF_FUNCTION struct pointer_array* pointer_array_create_default()
{
    return pointer_array_create(POINTER_ARRAY_DEFAULT_CAPACITY, POINTER_ARRAY_DEFAULT_RESIZE_FACTOR);
}

DART_INLINE_LEAF_FUNCTION void pointer_array_destroy(struct pointer_array* array)
{
    free(array->memory);
    free(array);
}

DART_INLINE_LEAF_FUNCTION void pointer_array_grow(struct pointer_array* array)
{
    size_t new_capacity = round_up_to_power_of_two(array->resize_factor * array->capacity);
    array->memory = (void**)realloc((void*)array->memory, new_capacity * sizeof(void*));
    array->capacity = new_capacity;
}


DART_INLINE_LEAF_FUNCTION void* pointer_array_get(struct pointer_array* array, size_t index)
{
    if (index >= array->size) return NULL;
    return array->memory[index];
}

DART_INLINE_LEAF_FUNCTION void* pointer_array_set(struct pointer_array* array, size_t index, void* value)
{
    if (index >= array->capacity) return NULL;
    void* current = array->memory[index];
    array->memory[index] = value;
    return current;
}

DART_INLINE_LEAF_FUNCTION void pointer_array_remove_range(struct pointer_array* array, size_t from, size_t count)
{
    if (from + count >= array->capacity) return;
    memmove(array->memory + from * sizeof(void*), array->memory + (from + count) * sizeof(void*), (array->size - from - count) * sizeof(void*));
    array->size -= count;
}

DART_INLINE_LEAF_FUNCTION void* pointer_array_remove(struct pointer_array* array, size_t index)
{
    if (index >= array->capacity) return NULL;
    void* current = array->memory[index];
    pointer_array_remove_range(array, index, 1);
    return current;
}

DART_INLINE_LEAF_FUNCTION void* pointer_array_remove_last(struct pointer_array* array)
{
    if (array->size == 0) return NULL;
    void* current = array->memory[array->size - 1];
    array->memory[array->size - 1] = NULL;
    array->size--;
    return current;
}

DART_INLINE_LEAF_FUNCTION void pointer_array_add(struct pointer_array* array, void* value)
{
    if (array->size >= array->capacity) pointer_array_grow(array);
    array->memory[array->size] = value;
    array->size++;
}

#endif