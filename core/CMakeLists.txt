cmake_minimum_required(VERSION 3.16.0)
project(core C ASM)

FetchContent_Declare(
  core_libunwind
  GIT_REPOSITORY ${DEPENDENCY_LIBUNWIND_REPOSITORY}
  GIT_TAG ${DEPENDENCY_LIBUNWIND_VERSION}
  SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/dependencies/libunwind-source
  BINARY_DIR ${CMAKE_CURRENT_SOURCE_DIR}/dependencies/libunwind-binary
)
FetchContent_Populate(core_libunwind)

add_custom_command(
  OUTPUT ${core_libunwind_SOURCE_DIR}/configure
  WORKING_DIRECTORY ${core_libunwind_SOURCE_DIR}
  COMMAND AR=${CMAKE_AR} CC=${CMAKE_C_COMPILER} CXX=${CMAKE_CXX_COMPILER} CFLAGS=${LIBUNWIND_CFLAGS} CXXFLAGS=${LIBUNWIND_CXXFLAGS}
  autoreconf -i &> /dev/null
  && autoupdate &> /dev/null
  COMMAND touch configure
  DEPENDS ${autotool_files}
)

add_custom_command(
  OUTPUT ${core_libunwind_SOURCE_DIR}/Makefile
  WORKING_DIRECTORY ${core_libunwind_SOURCE_DIR}
  COMMAND AR=${CMAKE_AR} CC=${CMAKE_C_COMPILER} CXX=${CMAKE_CXX_COMPILER} CFLAGS=${LIBUNWIND_CFLAGS} CXXFLAGS=${LIBUNWIND_CXXFLAGS}
  ${core_libunwind_SOURCE_DIR}/configure
  --prefix=${core_libunwind_BINARY_DIR}
  --silent
  --with-pic
  --disable-shared
  --enable-silent-rules
  --enable-static
  --disable-option-checking
  --disable-coredump
  --disable-ptrace
  --disable-setjmp
  --disable-documentation
  --disable-tests
  --disable-weak-backtrace
  --disable-unwind-header
  --disable-minidebuginfo
  --disable-zlibdebuginfo
  &> /dev/null
  DEPENDS ${core_libunwind_SOURCE_DIR}/configure
)

add_custom_target(core_libunwind_build
  COMMAND AR=${CMAKE_AR} CC=${CMAKE_C_COMPILER} CXX=${CMAKE_CXX_COMPILER} CFLAGS=${LIBUNWIND_CFLAGS} CXXFLAGS=${LIBUNWIND_CXXFLAGS}
  make -j &> /dev/null && make install prefix=${core_libunwind_BINARY_DIR} &> /dev/null
  WORKING_DIRECTORY ${core_libunwind_SOURCE_DIR}
  DEPENDS ${core_libunwind_SOURCE_DIR}/Makefile
)

set(CORE_LIBUNWIND_LIBRARIES ${core_libunwind_BINARY_DIR}/lib/libunwind.a ${core_libunwind_BINARY_DIR}/lib/libunwind-${CMAKE_SYSTEM_PROCESSOR}.a)
set(CORE_LIBUNWIND_INCLUDE ${core_libunwind_BINARY_DIR}/include)

add_subdirectory(native)
