cmake_minimum_required(VERSION 3.16.0)
project(transport C ASM)

FetchContent_Declare(
  transport_liburing
  GIT_REPOSITORY ${DEPENDENCY_LIBURING_REPOSITORY}
  GIT_TAG ${DEPENDENCY_LIBURING_VERSION}
  SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/dependencies/liburing-source
  BINARY_DIR ${CMAKE_CURRENT_SOURCE_DIR}/dependencies/liburing-binary
)
FetchContent_MakeAvailable(transport_liburing)
add_custom_target(transport_liburing COMMAND ./configure --prefix=${transport_liburing_SOURCE_DIR}/build && make && make install WORKING_DIRECTORY ${transport_liburing_SOURCE_DIR})

add_subdirectory(native)