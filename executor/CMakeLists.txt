cmake_minimum_required(VERSION 3.16.0)
project(executor C ASM)

FetchContent_Declare(
  executor_liburing
  GIT_REPOSITORY ${DEPENDENCY_LIBURING_REPOSITORY}
  GIT_TAG ${DEPENDENCY_LIBURING_VERSION}
  SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/dependencies/liburing-source
  BINARY_DIR ${CMAKE_CURRENT_SOURCE_DIR}/dependencies/liburing-binary
)
FetchContent_MakeAvailable(executor_liburing)
add_custom_target(executor_liburing COMMAND ./configure --prefix=${executor_liburing_SOURCE_DIR}/build && make && make install WORKING_DIRECTORY ${executor_liburing_SOURCE_DIR})

add_subdirectory(native)
add_subdirectory(test/native)
