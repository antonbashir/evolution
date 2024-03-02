cmake_minimum_required(VERSION 3.16.0)

project(mediator_native C ASM)

include_directories(${mediator_liburing_SOURCE_DIR}/src/include)
include_directories(${mediator_liburing_BINARY_DIR}/src/include)

include_directories(${PROJECT_BINARY_DIR})
include_directories(${PROJECT_SOURCE_DIR})
include_directories(${CORE_INCLUDE_DIRECTORY})
include_directories(include)

file(GLOB sources
  *.c
  *.h
  dart/*.c
  dart/*.c
  dart/internal/*.h
  dart/internal/*.c
)

add_library(mediator_debug_linux_x64 SHARED ${sources})
add_dependencies(mediator_debug_linux_x64 mediator_liburing memory_debug_linux_x64)
target_link_libraries(mediator_debug_linux_x64 PRIVATE ${mediator_liburing_SOURCE_DIR}/build/lib/liburing.a)
set_target_properties(mediator_debug_linux_x64 PROPERTIES COMPILE_FLAGS ${CMAKE_C_FLAGS_DEBUG})
copy_to_assets(mediator_debug_linux_x64)

add_library(mediator_release_linux_x64 SHARED ${sources})
add_dependencies(mediator_release_linux_x64 mediator_liburing memory_release_linux_x64)
target_link_libraries(mediator_release_linux_x64 PRIVATE ${mediator_liburing_SOURCE_DIR}/build/lib/liburing.a)
set_target_properties(mediator_release_linux_x64 PROPERTIES COMPILE_FLAGS ${CMAKE_C_FLAGS})
copy_to_assets(mediator_release_linux_x64)

add_custom_target(mediator_native DEPENDS "mediator_release_linux_x64;mediator_debug_linux_x64")