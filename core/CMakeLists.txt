cmake_minimum_required(VERSION 3.16.0)
project(core C ASM)

fetch_dart_api()

FetchContent_Declare(
  core_libunwind
  GIT_REPOSITORY ${DEPENDENCY_LIBUNWIND_REPOSITORY}
  GIT_TAG ${DEPENDENCY_LIBUNWIND_VERSION}
  SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/dependencies/libunwind-source
  BINARY_DIR ${CMAKE_CURRENT_SOURCE_DIR}/dependencies/libunwind-binary
)
FetchContent_Populate(core_libunwind)

set(autotool_files_standard configure.ac acinclude.m4)
list_add_prefix(autotool_files_standard "${core_libunwind_SOURCE_DIR}/" autotool_files_standard)
file(GLOB_RECURSE autotool_files_am CONFIGURE_DEPENDS RELATIVE "${PROJECT_SOURCE_DIR}" "${core_libunwind_SOURCE_DIR}/*.am")
set(autotool_files ${autotool_files_am} ${autotool_files_standard})
file(GLOB_RECURSE config_files_in CONFIGURE_DEPENDS RELATIVE "${PROJECT_SOURCE_DIR}" "${core_libunwind_SOURCE_DIR}/*.in")

add_custom_command(
  OUTPUT ${core_libunwind_SOURCE_DIR}/configure
  WORKING_DIRECTORY ${core_libunwind_SOURCE_DIR}
  COMMAND AR=${CMAKE_AR} CC=${CMAKE_C_COMPILER} CXX=${CMAKE_CXX_COMPILER} CFLAGS=${LIBUNWIND_CFLAGS} CXXFLAGS=${LIBUNWIND_CXXFLAGS} autoreconf -i
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
  DEPENDS ${core_libunwind_SOURCE_DIR}/configure
)

add_custom_command(
  OUTPUT ${core_libunwind_SOURCE_DIR}/config.log
  WORKING_DIRECTORY ${core_libunwind_SOURCE_DIR}
  COMMAND ./config.status
  DEPENDS
  ${config_files_in}
  ${core_libunwind_SOURCE_DIR}/Makefile
)

add_custom_target(core_libunwind_build
  COMMAND AR=${CMAKE_AR} CC=${CMAKE_C_COMPILER} CXX=${CMAKE_CXX_COMPILER} CFLAGS=${LIBUNWIND_CFLAGS} CXXFLAGS=${LIBUNWIND_CXXFLAGS}
  make &> /dev/null && make install prefix=${core_libunwind_BINARY_DIR} &> /dev/null
  WORKING_DIRECTORY ${core_libunwind_SOURCE_DIR}
  DEPENDS ${core_libunwind_SOURCE_DIR}/Makefile ${core_libunwind_SOURCE_DIR}/config.log
  BYPRODUCTS ${core_libunwind_BINARY_DIR}/lib/libunwind.a ${core_libunwind_BINARY_DIR}/lib/libunwind-${CMAKE_SYSTEM_PROCESSOR}.a
)

set(CORE_LIBUNWIND_LIBRARIES ${core_libunwind_BINARY_DIR}/lib/libunwind.a ${core_libunwind_BINARY_DIR}/lib/libunwind-${CMAKE_SYSTEM_PROCESSOR}.a)
set(CORE_LIBUNWIND_INCLUDE ${core_libunwind_BINARY_DIR}/include)

add_subdirectory(native)
