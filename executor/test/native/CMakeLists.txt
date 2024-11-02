cmake_minimum_required(VERSION 3.16.0)
project(executor_test C ASM)

file(GLOB sources
  **/*.c
  **/*.h
)

include_directories(${PROJECT_BINARY_DIR})
include_directories(${PROJECT_SOURCE_DIR})
include_directories(${memory_small_SOURCE_DIR}/include)
include_directories(${memory_small_SOURCE_DIR}/include/small)
include_directories(${memory_small_SOURCE_DIR}/third_party)
include_directories(${memory_small_BINARY_DIR}/small/include)
include_directories(${executor_liburing_SOURCE_DIR})
include_directories(${executor_liburing_BINARY_DIR})
include_directories(${CORE_INCLUDE_DIRECTORY})
include_directories(${EXECUTOR_INCLUDE_DIRECTORY})
include_directories(${MEMORY_INCLUDE_DIRECTORY})

add_library(executor_test SHARED ${sources})
add_dependencies(executor_test executor_debug_linux_x64)
target_link_libraries(executor_test PRIVATE ${LIBURING_LIBRARY})
set_target_properties(executor_test PROPERTIES COMPILE_FLAGS ${COMPILER_C_FLAGS_DEBUG})
copy_to_assets(executor_test)