#ifndef ARRAYS_SIMPLE
#define ARRAYS_SIMPLE

#include <bits/bits.h>
#include <common/common.h>
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

#define pointer_array_add(array, value) array = pointer_array_add_resize(array, value)

DART_INLINE_LEAF_FUNCTION struct pointer_array* pointer_array_create(size_t initial_capacity, size_t resize_factor)
{
    struct pointer_array* array = calloc(1, sizeof(struct pointer_array));
    array->capacity = initial_capacity;
    array->memory = calloc(array->capacity, sizeof(void*));
    array->capacity = initial_capacity;
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

DART_INLINE_LEAF_FUNCTION struct pointer_array* pointer_array_resize(struct pointer_array* array)
{
    size_t new_capacity = round_up_to_power_of_two(array->resize_factor * array->capacity);
    struct pointer_array* temp = pointer_array_create(new_capacity, array->resize_factor);
    memcpy(temp->memory, array->memory, array->capacity * sizeof(void*));
    temp->size = array->size;
    pointer_array_destroy(array);
    return temp;
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

DART_INLINE_LEAF_FUNCTION struct pointer_array* pointer_array_add_resize(struct pointer_array* array, void* value)
{
    if (array->size >= array->capacity) array = pointer_array_resize(array);
    array->memory[array->size] = value;
    array->size++;
    return array;
}

#endif