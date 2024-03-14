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

add_custom_command(
  OUTPUT ${executor_liburing_SOURCE_DIR}/Makefile
  WORKING_DIRECTORY ${executor_liburing_SOURCE_DIR}
  COMMAND AR=${CMAKE_AR} CC=${CMAKE_C_COMPILER} CXX=${CMAKE_CXX_COMPILER} CFLAGS=${LIBURING_CFLAGS} CXXFLAGS=${LIBURING_CXXFLAGS}
  ./configure --prefix=${executor_liburing_BINARY_DIR}
)

add_custom_target(executor_liburing_build
  COMMAND AR=${CMAKE_AR} CC=${CMAKE_C_COMPILER} CXX=${CMAKE_CXX_COMPILER} CFLAGS=${LIBURING_CFLAGS} CXXFLAGS=${LIBURING_CXXFLAGS}
  make &> /dev/null && make install DESTDIR=${executor_liburing_BINARY_DIR} &> /dev/null
  WORKING_DIRECTORY ${executor_liburing_SOURCE_DIR}
  DEPENDS ${executor_liburing_SOURCE_DIR}/Makefile
  BYPRODUCTS ${executor_liburing_BINARY_DIR}/usr/lib/liburing.a
)

set(LIBURING_LIBRARY ${executor_liburing_BINARY_DIR}/usr/lib/liburing.a)

add_subdirectory(native)
add_subdirectory(test/native)
