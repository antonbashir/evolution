cmake_minimum_required(VERSION 3.16.0)

project(memory_native C ASM)

include_directories(${memory_msgpuck_SOURCE_DIR})

include_directories(${memory_small_SOURCE_DIR}/include)
include_directories(${memory_small_SOURCE_DIR}/include/small)
include_directories(${memory_small_SOURCE_DIR}/third_party)
include_directories(${memory_small_BINARY_DIR}/small/include)

include_directories(${CORE_INCLUDE_DIRECTORY})

include_directories(${PROJECT_BINARY_DIR})
include_directories(${PROJECT_SOURCE_DIR})
include_directories(include)

file(GLOB sources
  **/*.c
  **/*.h
  *.c
  *.h
)

add_library(memory_debug_linux_x64 SHARED ${sources})
add_dependencies(memory_debug_linux_x64 core_debug_linux_x64 ${SMALL_PROJECT} ${MSGPUCK_PROJECT})
target_link_libraries(memory_debug_linux_x64 PRIVATE ${SMALL_PROJECT} ${MSGPUCK_PROJECT})
set_target_properties(memory_debug_linux_x64 PROPERTIES COMPILE_FLAGS ${COMPILER_C_FLAGS_DEBUG} LINKER_LANGUAGE C)
copy_to_assets(memory_debug_linux_x64)

add_library(memory_release_linux_x64 SHARED ${sources})
add_dependencies(memory_release_linux_x64 core_release_linux_x64 ${SMALL_PROJECT} ${MSGPUCK_PROJECT})
target_link_libraries(memory_release_linux_x64 PRIVATE ${SMALL_PROJECT} ${MSGPUCK_PROJECT})
set_target_properties(memory_release_linux_x64 PROPERTIES COMPILE_FLAGS ${COMPILER_C_FLAGS_RELEASE} LINKER_LANGUAGE C)
copy_to_assets(memory_release_linux_x64)

add_library(memory_debug_linux_x64_shared SHARED ${sources})
add_dependencies(memory_debug_linux_x64_shared core_debug_linux_x64 ${SMALL_PROJECT}_shared ${MSGPUCK_PROJECT}_shared)
set_target_properties(memory_debug_linux_x64_shared PROPERTIES COMPILE_FLAGS ${COMPILER_C_FLAGS_DEBUG} LINKER_LANGUAGE C)
copy_to_assets(memory_debug_linux_x64_shared)

add_library(memory_release_linux_x64_shared SHARED ${sources})
add_dependencies(memory_release_linux_x64_shared core_release_linux_x64 ${SMALL_PROJECT}_shared ${MSGPUCK_PROJECT}_shared)
set_target_properties(memory_release_linux_x64_shared PROPERTIES COMPILE_FLAGS ${COMPILER_C_FLAGS_RELEASE} LINKER_LANGUAGE C)
copy_to_assets(memory_release_linux_x64_shared)

add_custom_target(memory_native DEPENDS "memory_release_linux_x64_shared;memory_debug_linux_x64_shared;memory_release_linux_x64;memory_debug_linux_x64")
