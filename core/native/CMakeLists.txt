cmake_minimum_required(VERSION 3.16.0)

project(core_native C ASM)

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

add_library(core_debug_linux_x64 SHARED ${sources})
set_target_properties(core_debug_linux_x64 PROPERTIES COMPILE_FLAGS ${CMAKE_C_FLAGS_DEBUG})
copy_to_assets(core_debug_linux_x64)

add_library(core_release_linux_x64 SHARED ${sources})
set_target_properties(core_release_linux_x64 PROPERTIES COMPILE_FLAGS ${CMAKE_C_FLAGS})
copy_to_assets(core_release_linux_x64)

add_custom_target(core_native DEPENDS core_release_linux_x64 core_debug_linux_x64)