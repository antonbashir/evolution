#ifndef CORE_COLLECTIONS_MAPS_H
#define CORE_COLLECTIONS_MAPS_H

#include <common/common.h>
#include <hashing/hashing_64.h>
#include <system/library.h>

#ifndef TABLE_SOURCE
#define TABLE_UNDEF
#endif

#define table_name _modules
#define table_key_t const char*
DART_STRUCTURE struct module_container
{
    DART_FIELD uint32_t id;
    DART_FIELD const char* name;
    DART_FIELD void* module;
    DART_FIELD const char* type;
};
#define table_node_t struct module_container
#define table_hash(node, _) (hash_string_64(node->name, strlen(node->name)))
#define table_hash_key(key, _) (hash_string_64(key, strlen(key)))
#define table_cmp(left_node, right_node, _) (strcmp(left_node->name, right_node->name))
#define table_cmp_key(key, node, _) (strcmp(key, node->name))

#include <maps/table.h>

#define table_name _system_libraries
#define table_key_t const char*
DART_STRUCTURE struct system_library
{
    DART_FIELD const char* path;
    DART_FIELD const char* module;
    DART_FIELD void* handle;
};
#define table_node_t struct system_library*
#define table_hash(node, _) (hash_string_64((*node)->path, strlen((*node)->path)))
#define table_hash_key(key, _) (hash_string_64(key, strlen(key)))
#define table_cmp(left_node, right_node, _) (strcmp((*left_node)->path, (*right_node)->path))
#define table_cmp_key(key, node, _) (strcmp(key, (*node)->path))

#include <maps/table.h>

#define table_name _string_values
#define table_key_t const char*
DART_STRUCTURE struct string_value_pair
{
    DART_FIELD const char* key;
    DART_FIELD const void* value;
};
#define table_node_t struct string_value_pair
#define table_hash(node, _) (hash_string_64(node->key, strlen(node->key)))
#define table_hash_key(key, _) (hash_string_64(key, strlen(key)))
#define table_cmp(left_node, right_node, _) (strcmp(left_node->key, right_node->key))
#define table_cmp_key(key, node, _) (strcmp(key, node->key))

#include <maps/table.h>

#define table_name _string_value_pointers
#define table_key_t const char*
#define table_node_t struct string_value_pair*
#define table_hash(node, _) (hash_string_64((*node)->key, strlen((*node)->key)))
#define table_hash_key(key, _) (hash_string_64(key, strlen(key)))
#define table_cmp(left_node, right_node, _) (strcmp((*left_node)->key, (*right_node)->key))
#define table_cmp_key(key, node, _) (strcmp(key, (*node)->key))

#include <maps/table.h>

#endif