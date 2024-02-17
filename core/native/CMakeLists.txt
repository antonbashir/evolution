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
add_custom_command(TARGET core_debug_linux_x64 POST_BUILD COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_FILE:core_debug_linux_x64> ${CMAKE_CURRENT_SOURCE_DIR}/../dart/native/libcore_debug_linux_x64.so)

add_library(core_release_linux_x64 SHARED ${sources})
set_target_properties(core_release_linux_x64 PROPERTIES COMPILE_FLAGS ${CMAKE_C_FLAGS})
add_custom_command(TARGET core_release_linux_x64 POST_BUILD COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_FILE:core_release_linux_x64> ${CMAKE_CURRENT_SOURCE_DIR}/../dart/native/libcore_release_linux_x64.so)

add_custom_target(core_native DEPENDS core_release_linux_x64 core_debug_linux_x64)