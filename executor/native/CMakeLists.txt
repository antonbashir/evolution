cmake_minimum_required(VERSION 3.16.0)

project(executor_native C ASM)

include_directories(${executor_liburing_SOURCE_DIR}/src/include)
include_directories(${executor_liburing_BINARY_DIR}/src/include)

include_directories(${PROJECT_BINARY_DIR})
include_directories(${PROJECT_SOURCE_DIR})
include_directories(${CORE_INCLUDE_DIRECTORY})
include_directories(include)

file(GLOB sources
  **/*.c
  **/*.h
  *.c
  *.h
)

add_library(executor_debug_linux_x64 SHARED ${sources})
add_dependencies(executor_debug_linux_x64 executor_liburing memory_debug_linux_x64)
target_link_libraries(executor_debug_linux_x64 PRIVATE ${executor_liburing_SOURCE_DIR}/build/lib/liburing.a)
set_target_properties(executor_debug_linux_x64 PROPERTIES COMPILE_FLAGS ${CMAKE_C_FLAGS_DEBUG})
copy_to_assets(executor_debug_linux_x64)

add_library(executor_release_linux_x64 SHARED ${sources})
add_dependencies(executor_release_linux_x64 executor_liburing memory_release_linux_x64)
target_link_libraries(executor_release_linux_x64 PRIVATE ${executor_liburing_SOURCE_DIR}/build/lib/liburing.a)
set_target_properties(executor_release_linux_x64 PROPERTIES COMPILE_FLAGS ${CMAKE_C_FLAGS})
copy_to_assets(executor_release_linux_x64)

add_custom_target(executor_native DEPENDS "executor_release_linux_x64;executor_debug_linux_x64")