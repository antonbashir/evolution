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
  ${storage_tarantool_SOURCE_DIR}/src
  ${storage_tarantool_BINARY_DIR}/src
  ${storage_tarantool_SOURCE_DIR}/src/lib
  ${storage_tarantool_SOURCE_DIR}/src/lib/core
  ${storage_tarantool_BINARY_DIR}/src/lib/small/small/include
  ${storage_tarantool_SOURCE_DIR}/src/lib/small
  ${storage_tarantool_SOURCE_DIR}/src/lib/small/third_party
  ${storage_tarantool_SOURCE_DIR}/src/lib/small/include
  ${storage_tarantool_SOURCE_DIR}/src/lib/small/include/small
  ${storage_tarantool_SOURCE_DIR}/src/lib/msgpuck
  ${storage_tarantool_SOURCE_DIR}/third_party
  ${storage_tarantool_SOURCE_DIR}/third_party/luajit/src
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
copy_file_to_assets(storage_debug_linux_x64 ${TARANTOOL_INSTALL_DIR}/include/tarantool/module.h ${CMAKE_CURRENT_SOURCE_DIR}/../dart/assets/library.h)
copy_file_to_assets(storage_debug_linux_x64 ${storage_tarantool_SOURCE_DIR}/third_party/luajit/src/lua.h ${CMAKE_CURRENT_SOURCE_DIR}/../dart/assets/lua.h)
copy_file_to_assets(storage_debug_linux_x64 ${storage_tarantool_SOURCE_DIR}/third_party/luajit/src/lua.h ${CMAKE_CURRENT_SOURCE_DIR}/../dart/assets/lua.h)
copy_file_to_assets(storage_debug_linux_x64 ${storage_tarantool_SOURCE_DIR}/third_party/luajit/src/luaconf.h ${CMAKE_CURRENT_SOURCE_DIR}/../dart/assets/luaconf.h)
copy_file_to_assets(storage_debug_linux_x64 ${storage_tarantool_SOURCE_DIR}/src/lib/msgpuck/msgpuck.h ${CMAKE_CURRENT_SOURCE_DIR}/../dart/assets/msgpuck.h)
copy_file_to_assets(storage_debug_linux_x64 ${CMAKE_CURRENT_SOURCE_DIR}/src/storage_extension.h ${CMAKE_CURRENT_SOURCE_DIR}/../dart/assets/module.h)

add_library(storage_release_linux_x64 SHARED ${sources})
add_dependencies(storage_release_linux_x64 storage_tarantool executor_release_linux_x64)
target_link_libraries(storage_release_linux_x64 PRIVATE -Wl,--whole-archive ${TARANTOOL_LIBRARY} -Wl,--no-whole-archive)
target_include_directories(storage_release_linux_x64 PRIVATE ${STORAGE_INCLUDES})
set_target_properties(storage_release_linux_x64 PROPERTIES COMPILE_FLAGS ${COMPILER_C_FLAGS_RELEASE})
copy_to_assets(storage_release_linux_x64)
copy_file_to_assets(storage_release_linux_x64 ${TARANTOOL_INSTALL_DIR}/include/tarantool/module.h ${CMAKE_CURRENT_SOURCE_DIR}/../dart/assets/library.h)
copy_file_to_assets(storage_release_linux_x64 ${storage_tarantool_SOURCE_DIR}/third_party/luajit/src/lua.h ${CMAKE_CURRENT_SOURCE_DIR}/../dart/assets/lua.h)
copy_file_to_assets(storage_release_linux_x64 ${storage_tarantool_SOURCE_DIR}/third_party/luajit/src/luaconf.h ${CMAKE_CURRENT_SOURCE_DIR}/../dart/assets/luaconf.h)
copy_file_to_assets(storage_release_linux_x64 ${storage_tarantool_SOURCE_DIR}/src/lib/msgpuck/msgpuck.h ${CMAKE_CURRENT_SOURCE_DIR}/../dart/assets/msgpuck.h)
copy_file_to_assets(storage_release_linux_x64 ${storage_tarantool_SOURCE_DIR}/src/lib/msgpuck/msgpuck.h ${CMAKE_CURRENT_SOURCE_DIR}/../dart/assets/msgpuck.h)
copy_file_to_assets(storage_release_linux_x64 ${CMAKE_CURRENT_SOURCE_DIR}/src/storage_extension.h ${CMAKE_CURRENT_SOURCE_DIR}/../dart/assets/module.h)

add_custom_target(storage_native DEPENDS "storage_release_linux_x64;storage_debug_linux_x64")

add_executable(storage_test ${tests})
add_dependencies(storage_test storage_debug_linux_x64 executor_debug_linux_x64)
target_include_directories(storage_test PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/test ${STORAGE_INCLUDES})
set_target_properties(storage_test PROPERTIES COMPILE_FLAGS ${COMPILER_C_FLAGS_DEBUG})
target_link_libraries(storage_test PRIVATE storage_debug_linux_x64 executor_debug_linux_x64 -lstdc++ -lm)
set_target_properties(storage_test PROPERTIES
  ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/bin/test"
  LIBRARY_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/bin/test"
  RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/bin/test"
)