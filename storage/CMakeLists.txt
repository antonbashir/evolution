cmake_minimum_required(VERSION 3.16.0)
project(storage C ASM)

set(WITH_TESTS OFF)
FetchContent_Declare(
  storage_tarantool
  GIT_REPOSITORY ${DEPENDENCY_TARANTOOL_REPOSITORY}
  GIT_TAG ${DEPENDENCY_TARANTOOL_VERSION}
  SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/dependencies/libtarantool
)
FetchContent_MakeAvailable(storage_tarantool)
ExternalProject_Add(storage_tarantool
  PREFIX storage-tarantool-prefix
  SOURCE_DIR ${storage_tarantool_SOURCE_DIR}
  LIST_SEPARATOR :
  CMAKE_ARGS
  -DCMAKE_INSTALL_LOCALSTATEDIR=<INSTALL_DIR>/var
  -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
  -DBUNDLED_LIBS_INSTALL_DIR=${storage_tarantool_BINARY_DIR}
  -DBUILD_STATIC_WITH_BUNDLED_LIBS=TRUE
  -DENABLE_DIST=TRUE
  -DENABLE_LTO=FALSE
  -DENABLE_HARDENING=TRUE
  -DENABLE_BACKTRACE=FALSE
  -DWITH_TESTS=OFF
  -DCMAKE_POSITION_INDEPENDENT_CODE=ON
  STEP_TARGETS clean build
  BUILD_COMMAND $(MAKE)
  BUILD_ALWAYS TRUE
)
ExternalProject_Get_Property(storage_tarantool install_dir)
set(TARANTOOL_INSTALL_DIR ${install_dir})
set(TARANTOOL_LIBRARY ${install_dir}/lib/libtarantool-bundle.a)

add_subdirectory(native)