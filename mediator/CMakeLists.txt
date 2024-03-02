cmake_minimum_required(VERSION 3.16.0)
project(mediator C ASM)

FetchContent_Declare(
  mediator_liburing
  GIT_REPOSITORY ${DEPENDENCY_LIBURING_REPOSITORY}
  GIT_TAG ${DEPENDENCY_LIBURING_VERSION}
  SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/dependencies/liburing-source
  BINARY_DIR ${CMAKE_CURRENT_SOURCE_DIR}/dependencies/liburing-binary
)
FetchContent_MakeAvailable(mediator_liburing)
add_custom_target(mediator_liburing COMMAND ./configure --prefix=${mediator_liburing_SOURCE_DIR}/build && make && make install WORKING_DIRECTORY ${mediator_liburing_SOURCE_DIR})

add_subdirectory(native)
add_subdirectory(test/native)
