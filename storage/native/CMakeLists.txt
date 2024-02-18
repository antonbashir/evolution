cmake_minimum_required(VERSION 3.16.0)
project(storage_native C CXX ASM)

file(GLOB sources
  src/*.h
  src/*.c
  src/*.cc
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
  ${INTERACTOR_INCLUDE_DIRECTORY}
)

add_library(storage_debug_linux_x64 SHARED ${sources})
add_dependencies(storage_debug_linux_x64 storage_tarantool)
target_include_directories(storage_debug_linux_x64 PRIVATE ${STORAGE_INCLUDES})
target_link_libraries(storage_debug_linux_x64 PRIVATE -Wl,--whole-archive ${TARANTOOL_LIBRARY} -Wl,--no-whole-archive ${INTERACTOR_LIBRARY})
set_target_properties(storage_debug_linux_x64 PROPERTIES COMPILE_FLAGS ${CMAKE_C_FLAGS_DEBUG})
add_dependencies(storage_debug_linux_x64 storage_tarantool)
add_custom_command(TARGET storage_debug_linux_x64 POST_BUILD COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_FILE:storage_debug_linux_x64> ${CMAKE_CURRENT_SOURCE_DIR}/../dart/native/libstorage_debug_linux_x64.so)
add_custom_command(TARGET storage_debug_linux_x64 POST_BUILD COMMAND ${CMAKE_COMMAND} -E copy ${TARANTOOL_INSTALL_DIR}/include/tarantool/module.h ${CMAKE_CURRENT_SOURCE_DIR}/../dart/native/library.h)
add_custom_command(TARGET storage_debug_linux_x64 POST_BUILD COMMAND ${CMAKE_COMMAND} -E copy ${storage_tarantool_SOURCE_DIR}/third_party/luajit/src/lua.h ${CMAKE_CURRENT_SOURCE_DIR}/../dart/native/lua.h)
add_custom_command(TARGET storage_debug_linux_x64 POST_BUILD COMMAND ${CMAKE_COMMAND} -E copy ${storage_tarantool_SOURCE_DIR}/third_party/luajit/src/luaconf.h ${CMAKE_CURRENT_SOURCE_DIR}/../dart/native/luaconf.h)
add_custom_command(TARGET storage_debug_linux_x64 POST_BUILD COMMAND ${CMAKE_COMMAND} -E copy ${storage_tarantool_SOURCE_DIR}/src/lib/msgpuck/msgpuck.h ${CMAKE_CURRENT_SOURCE_DIR}/../dart/native/msgpuck.h)
add_custom_command(TARGET storage_debug_linux_x64 POST_BUILD COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/src/storage_extension.h ${CMAKE_CURRENT_SOURCE_DIR}/../dart/native/module.h)

add_library(storage_release_linux_x64 SHARED ${sources})
add_dependencies(storage_release_linux_x64 storage_tarantool)
target_include_directories(storage_release_linux_x64 PRIVATE ${STORAGE_INCLUDES})
set_target_properties(storage_release_linux_x64 PROPERTIES COMPILE_FLAGS ${CMAKE_C_FLAGS})
target_link_libraries(storage_release_linux_x64 PRIVATE -Wl,--whole-archive ${TARANTOOL_LIBRARY} -Wl,--no-whole-archive ${INTERACTOR_LIBRARY})
add_custom_command(TARGET storage_release_linux_x64 POST_BUILD COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_FILE:storage_release_linux_x64> ${CMAKE_CURRENT_SOURCE_DIR}/../dart/native/libstorage_release_linux_x64.so)
add_custom_command(TARGET storage_release_linux_x64 POST_BUILD COMMAND ${CMAKE_COMMAND} -E copy ${TARANTOOL_INSTALL_DIR}/include/tarantool/module.h ${CMAKE_CURRENT_SOURCE_DIR}/../dart/native/library.h)
add_custom_command(TARGET storage_release_linux_x64 POST_BUILD COMMAND ${CMAKE_COMMAND} -E copy ${storage_tarantool_SOURCE_DIR}/third_party/luajit/src/lua.h ${CMAKE_CURRENT_SOURCE_DIR}/../dart/native/lua.h)
add_custom_command(TARGET storage_release_linux_x64 POST_BUILD COMMAND ${CMAKE_COMMAND} -E copy ${storage_tarantool_SOURCE_DIR}/third_party/luajit/src/luaconf.h ${CMAKE_CURRENT_SOURCE_DIR}/../dart/native/luaconf.h)
add_custom_command(TARGET storage_release_linux_x64 POST_BUILD COMMAND ${CMAKE_COMMAND} -E copy ${storage_tarantool_SOURCE_DIR}/src/lib/msgpuck/msgpuck.h ${CMAKE_CURRENT_SOURCE_DIR}/../dart/native/msgpuck.h)
add_custom_command(TARGET storage_release_linux_x64 POST_BUILD COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/src/storage_extension.h ${CMAKE_CURRENT_SOURCE_DIR}/../dart/native/module.h)

add_custom_target(storage_native DEPENDS storage_release_linux_x64 storage_debug_linux_x64)

add_executable(storage_test ${tests})
add_dependencies(storage_test storage_debug_linux_x64)
target_include_directories(storage_test PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/test ${STORAGE_INCLUDES})
set_target_properties(storage_test PROPERTIES COMPILE_FLAGS ${CMAKE_C_FLAGS_DEBUG})
target_link_libraries(storage_test PRIVATE storage_debug_linux_x64 -lstdc++ -lm)
set_target_properties(storage_test PROPERTIES
  ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/bin/test"
  LIBRARY_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/bin/test"
  RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/bin/test"
)