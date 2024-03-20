cmake_minimum_required(VERSION 3.16.0)

project(core_native C CXX ASM)

include_directories(${PROJECT_BINARY_DIR})
include_directories(${PROJECT_SOURCE_DIR})
include_directories(${CORE_LIBUNWIND_INCLUDE})
include_dart_api()

file(GLOB sources
  **/*.c
  **/*.cc
  **/*.h
  *.h
  *.c
  *.cc
)

add_library(core_debug_linux_x64 SHARED ${sources})
add_dependencies(core_debug_linux_x64 core_libunwind_build)
set_target_properties(core_debug_linux_x64 PROPERTIES COMPILE_FLAGS ${COMPILER_C_FLAGS_DEBUG} LINKER_LANGUAGE CXX)
target_link_libraries(core_debug_linux_x64 ${CORE_LIBUNWIND_LIBRARIES})
copy_to_assets(core_debug_linux_x64)

add_library(core_release_linux_x64 SHARED ${sources})
add_dependencies(core_release_linux_x64 core_libunwind_build)
set_target_properties(core_release_linux_x64 PROPERTIES COMPILE_FLAGS ${COMPILER_C_FLAGS_RELEASE} LINKER_LANGUAGE CXX)
target_link_libraries(core_release_linux_x64 ${CORE_LIBUNWIND_LIBRARIES})
copy_to_assets(core_release_linux_x64)

add_executable(core_test ${sources})
add_dependencies(core_test core_debug_linux_x64)
target_link_libraries(core_test ${CORE_LIBUNWIND_LIBRARIES})

add_custom_target(core_native DEPENDS "core_release_linux_x64;core_debug_linux_x64")