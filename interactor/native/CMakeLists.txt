cmake_minimum_required(VERSION 3.16.0)

project(interactor_native C ASM)

include_directories(${interactor_liburing_SOURCE_DIR}/src/include)
include_directories(${interactor_liburing_BINARY_DIR}/src/include)

include_directories(${PROJECT_BINARY_DIR})
include_directories(${PROJECT_SOURCE_DIR})
include_directories(include)

file(GLOB sources
  *.c
  *.h
  collections/*.h
  collections/*.c
  common/*.h
  common/*.c
)

add_library(interactor_debug_linux_x64 SHARED ${sources})
add_dependencies(interactor_debug_linux_x64 interactor_liburing memory_debug_linux_x64)
target_link_libraries(interactor_debug_linux_x64 PRIVATE ${interactor_liburing_SOURCE_DIR}/build/lib/liburing.a)
set_target_properties(interactor_debug_linux_x64 PROPERTIES COMPILE_FLAGS ${CMAKE_C_FLAGS_DEBUG})
copy_to_assets(interactor_debug_linux_x64)

add_library(interactor_release_linux_x64 SHARED ${sources})
add_dependencies(interactor_release_linux_x64 interactor_liburing memory_release_linux_x64)
target_link_libraries(interactor_release_linux_x64 PRIVATE ${interactor_liburing_SOURCE_DIR}/build/lib/liburing.a)
set_target_properties(interactor_release_linux_x64 PROPERTIES COMPILE_FLAGS ${CMAKE_C_FLAGS})
copy_to_assets(interactor_release_linux_x64)

add_custom_target(interactor_native DEPENDS interactor_release_linux_x64 interactor_debug_linux_x64)