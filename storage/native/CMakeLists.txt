cmake_minimum_required(VERSION 3.16.0)
project(storage_native C CXX ASM)

file(GLOB sources
  **/*.h
  **/*.c
  **/*.cc
)

file(GLOB tests
  test/*.h
  test/*.c
  test/*.cc
)

set(STORAGE_INCLUDES
  ${CMAKE_CURRENT_SOURCE_DIR}/src
  ${TARANTOOL_SOURCE_DIRECTORY}/src
  ${TARANTOOL_BINARY_DIRECTORY}/src
  ${TARANTOOL_SOURCE_DIRECTORY}/src/lib
  ${TARANTOOL_SOURCE_DIRECTORY}/src/lib/core
  ${TARANTOOL_BINARY_DIRECTORY}/src/lib/small/small/include
  ${TARANTOOL_SOURCE_DIRECTORY}/src/lib/small
  ${TARANTOOL_SOURCE_DIRECTORY}/src/lib/small/third_party
  ${TARANTOOL_SOURCE_DIRECTORY}/src/lib/small/include
  ${TARANTOOL_SOURCE_DIRECTORY}/src/lib/small/include/small
  ${TARANTOOL_SOURCE_DIRECTORY}/src/lib/msgpuck
  ${TARANTOOL_SOURCE_DIRECTORY}/third_party
  ${TARANTOOL_SOURCE_DIRECTORY}/third_party/luajit/src
  ${CORE_INCLUDE_DIRECTORY}
  ${MEMORY_INCLUDE_DIRECTORY}
  ${EXECUTOR_INCLUDE_DIRECTORY}
)

add_library(storage_debug_linux_x64 SHARED ${sources})
add_dependencies(storage_debug_linux_x64 storage_tarantool executor_debug_linux_x64)
target_include_directories(storage_debug_linux_x64 PRIVATE ${STORAGE_INCLUDES})
target_link_libraries(storage_debug_linux_x64 PRIVATE -Wl,--whole-archive ${TARANTOOL_LIBRARY} -Wl,--no-whole-archive)
set_target_properties(storage_debug_linux_x64 PROPERTIES COMPILE_FLAGS ${COMPILER_C_FLAGS_DEBUG})
copy_to_assets(storage_debug_linux_x64)
copy_file_to_assets(storage_debug_linux_x64 ${TARANTOOL_BINARY_DIRECTORY}/src/module.h ${CMAKE_CURRENT_SOURCE_DIR}/../dart/assets/library.h)
copy_file_to_assets(storage_debug_linux_x64 ${TARANTOOL_SOURCE_DIRECTORY}/third_party/luajit/src/lua.h ${CMAKE_CURRENT_SOURCE_DIR}/../dart/assets/lua.h)
copy_file_to_assets(storage_debug_linux_x64 ${TARANTOOL_SOURCE_DIRECTORY}/third_party/luajit/src/lua.h ${CMAKE_CURRENT_SOURCE_DIR}/../dart/assets/lua.h)
copy_file_to_assets(storage_debug_linux_x64 ${TARANTOOL_SOURCE_DIRECTORY}/third_party/luajit/src/luaconf.h ${CMAKE_CURRENT_SOURCE_DIR}/../dart/assets/luaconf.h)
copy_file_to_assets(storage_debug_linux_x64 ${TARANTOOL_SOURCE_DIRECTORY}/src/lib/msgpuck/msgpuck.h ${CMAKE_CURRENT_SOURCE_DIR}/../dart/assets/msgpuck.h)

add_library(storage_release_linux_x64 SHARED ${sources})
add_dependencies(storage_release_linux_x64 storage_tarantool executor_release_linux_x64)
target_link_libraries(storage_release_linux_x64 PRIVATE -Wl,--whole-archive ${TARANTOOL_LIBRARY} -Wl,--no-whole-archive)
target_include_directories(storage_release_linux_x64 PRIVATE ${STORAGE_INCLUDES})
set_target_properties(storage_release_linux_x64 PROPERTIES COMPILE_FLAGS ${COMPILER_C_FLAGS_RELEASE})
copy_to_assets(storage_release_linux_x64)
copy_file_to_assets(storage_release_linux_x64 ${TARANTOOL_BINARY_DIRECTORY}/src/module.h ${CMAKE_CURRENT_SOURCE_DIR}/../dart/assets/library.h)
copy_file_to_assets(storage_release_linux_x64 ${TARANTOOL_SOURCE_DIRECTORY}/third_party/luajit/src/lua.h ${CMAKE_CURRENT_SOURCE_DIR}/../dart/assets/lua.h)
copy_file_to_assets(storage_release_linux_x64 ${TARANTOOL_SOURCE_DIRECTORY}/third_party/luajit/src/luaconf.h ${CMAKE_CURRENT_SOURCE_DIR}/../dart/assets/luaconf.h)
copy_file_to_assets(storage_release_linux_x64 ${TARANTOOL_SOURCE_DIRECTORY}/src/lib/msgpuck/msgpuck.h ${CMAKE_CURRENT_SOURCE_DIR}/../dart/assets/msgpuck.h)
copy_file_to_assets(storage_release_linux_x64 ${TARANTOOL_SOURCE_DIRECTORY}/src/lib/msgpuck/msgpuck.h ${CMAKE_CURRENT_SOURCE_DIR}/../dart/assets/msgpuck.h)

add_custom_target(storage_native DEPENDS "storage_release_linux_x64;storage_debug_linux_x64")