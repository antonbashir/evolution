cmake_minimum_required(VERSION 3.16.0)
project(root)

add_definitions("-D_GNU_SOURCE")

set(CMAKE_WARN_DEPRECATED OFF CACHE BOOL "" FORCE)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED true)
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED true)

set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} -fPIC -O0 -g -Wno-parentheses -fno-stack-protector")
set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -fPIC -O0 -g -Wno-parentheses -fno-stack-protector")

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fPIC -O2 -Wno-parentheses -fno-stack-protector")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fPIC -O2 -Wno-parentheses -fno-stack-protector")

set(DEPENDENCY_LIBURING_REPOSITORY "developer@git.local:dependencies/liburing.git")
set(DEPENDENCY_LIBURING_VERSION evolution)

set(DEPENDENCY_SMALL_REPOSITORY "developer@git.local:dependencies/tarantool-small.git")
set(DEPENDENCY_SMALL_VERSION evolution)

set(DEPENDENCY_MSGPUCK_REPOSITORY "developer@git.local:dependencies/tarantool-msgpuck.git")
set(DEPENDENCY_MSGPUCK_VERSION evolution)

set(DEPENDENCY_TARANTOOL_REPOSITORY "developer@git.local:dependencies/tarantool.git")
set(DEPENDENCY_TARANTOOL_VERSION evolution-3.0.0)

set(CORE_INCLUDE_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/core/native/include)
set(INTERACTOR_INCLUDE_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/interactor/native/include)
set(MEMORY_INCLUDE_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/memory/native/include)

include(FetchContent)
include(ExternalProject)

add_subdirectory(core)
add_subdirectory(interactor)
add_subdirectory(transport)
add_subdirectory(memory)
add_subdirectory(storage)