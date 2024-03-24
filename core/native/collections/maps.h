#ifndef CORE_COLLECTIONS_MAPS_H
#define CORE_COLLECTIONS_MAPS_H

#include <common/common.h>
#include <hashing/hashing_64.h>
#include <system/library.h>

#ifndef SIMPLE_MAP_SOURCE
#define SIMPLE_MAP_UNDEF
#endif

#define simple_map_name _modules
#define simple_map_key_t const char*
DART_STRUCTURE struct module_container
{
    DART_FIELD uint32_t id;
    DART_FIELD const char* name;
    DART_FIELD void* module;
    DART_FIELD const char* type;
};
#define simple_map_node_t struct module_container
#define simple_map_hash(node, _) (hash_string_64(node->name, strlen(node->name)))
#define simple_map_hash_key(key, _) (hash_string_64(key, strlen(key)))
#define simple_map_cmp(left_node, right_node, _) (strcmp(left_node->name, right_node->name))
#define simple_map_cmp_key(key, node, _) (strcmp(key, node->name))

#include <maps/simple.h>

#define simple_map_name _system_libraries
#define simple_map_key_t const char*
DART_STRUCTURE struct system_library
{
    DART_FIELD const char* path;
    DART_FIELD const char* module;
    DART_FIELD void* handle;
};
#define simple_map_node_t struct system_library*
#define simple_map_hash(node, _) (hash_string_64((*node)->path, strlen((*node)->path)))
#define simple_map_hash_key(key, _) (hash_string_64(key, strlen(key)))
#define simple_map_cmp(left_node, right_node, _) (strcmp((*left_node)->path, (*right_node)->path))
#define simple_map_cmp_key(key, node, _) (strcmp(key, (*node)->path))

#include <maps/simple.h>

#define simple_map_name _string_values
#define simple_map_key_t const char*
DART_STRUCTURE struct string_value_pair
{
    DART_FIELD const char* key;
    DART_FIELD const void* value;
};
#define simple_map_node_t struct string_value_pair
#define simple_map_hash(node, _) (hash_string_64(node->key, strlen(node->key)))
#define simple_map_hash_key(key, _) (hash_string_64(key, strlen(key)))
#define simple_map_cmp(left_node, right_node, _) (strcmp(left_node->key, right_node->key))
#define simple_map_cmp_key(key, node, _) (strcmp(key, node->key))

#include <maps/simple.h>

#define simple_map_name _string_value_pointers
#define simple_map_key_t const char*
#define simple_map_node_t struct string_value_pair*
#define simple_map_hash(node, _) (hash_string_64((*node)->key, strlen((*node)->key)))
#define simple_map_hash_key(key, _) (hash_string_64(key, strlen(key)))
#define simple_map_cmp(left_node, right_node, _) (strcmp((*left_node)->key, (*right_node)->key))
#define simple_map_cmp_key(key, node, _) (strcmp(key, (*node)->key))

#include <maps/simple.h>

#endif