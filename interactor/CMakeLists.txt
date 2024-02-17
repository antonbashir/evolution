cmake_minimum_required(VERSION 3.16.0)
project(interactor C ASM)

set(MSGPUCK_PROJECT interactor_msgpuck)
set(SMALL_PROJECT interactor_small)

FetchContent_Declare(
  interactor_liburing
  GIT_REPOSITORY ${DEPENDENCY_LIBURING_REPOSITORY}
  GIT_TAG ${DEPENDENCY_LIBURING_VERSION}
  SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/dependencies/liburing-source
  BINARY_DIR ${CMAKE_CURRENT_SOURCE_DIR}/dependencies/liburing-binary
)
FetchContent_MakeAvailable(interactor_liburing)
add_custom_target(interactor_liburing COMMAND ./configure --prefix=${interactor_liburing_SOURCE_DIR}/build && make && make install WORKING_DIRECTORY ${interactor_liburing_SOURCE_DIR})

FetchContent_Declare(
  interactor_small
  GIT_REPOSITORY ${DEPENDENCY_SMALL_REPOSITORY}
  GIT_TAG ${DEPENDENCY_SMALL_VERSION}
  SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/dependencies/small-source
  BINARY_DIR ${CMAKE_CURRENT_SOURCE_DIR}/dependencies/small-binary
)
FetchContent_MakeAvailable(interactor_small)
add_subdirectory(${interactor_small_SOURCE_DIR})

FetchContent_Declare(
  interactor_msgpuck
  GIT_REPOSITORY ${DEPENDENCY_MSGPUCK_REPOSITORY}
  GIT_TAG ${DEPENDENCY_MSGPUCK_VERSION}
  SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/dependencies/msgpuck-source
  BINARY_DIR ${CMAKE_CURRENT_SOURCE_DIR}/dependencies/msgpuck-binary
)
FetchContent_MakeAvailable(interactor_msgpuck)
add_subdirectory(${interactor_msgpuck_SOURCE_DIR})

add_subdirectory(native)
add_subdirectory(test/native)

unset(MSGPUCK_PROJECT)
unset(SMALL_PROJECT)