cmake_minimum_required(VERSION 3.16.0)
project(memory C ASM)

set(MSGPUCK_PROJECT memory_msgpuck)
set(SMALL_PROJECT memory_small)

set(CMAKE_C_FLAGS ${COMPILER_C_FLAGS_RELEASE})
FetchContent_Declare(
  memory_small
  GIT_REPOSITORY ${DEPENDENCY_SMALL_REPOSITORY}
  GIT_TAG ${DEPENDENCY_SMALL_VERSION}
  SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/dependencies/small-source
  BINARY_DIR ${CMAKE_CURRENT_SOURCE_DIR}/dependencies/small-binary
)
FetchContent_MakeAvailable(memory_small)
add_subdirectory(${memory_small_SOURCE_DIR})
set(CMAKE_C_FLAGS "")

set(CMAKE_C_FLAGS ${COMPILER_C_FLAGS_RELEASE})
FetchContent_Declare(
  memory_msgpuck
  GIT_REPOSITORY ${DEPENDENCY_MSGPUCK_REPOSITORY}
  GIT_TAG ${DEPENDENCY_MSGPUCK_VERSION}
  SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/dependencies/msgpuck-source
  BINARY_DIR ${CMAKE_CURRENT_SOURCE_DIR}/dependencies/msgpuck-binary
)
FetchContent_MakeAvailable(memory_msgpuck)
add_subdirectory(${memory_msgpuck_SOURCE_DIR})
set(CMAKE_C_FLAGS "")

add_subdirectory(native)

unset(MSGPUCK_PROJECT)
unset(SMALL_PROJECT)