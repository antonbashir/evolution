cmake_minimum_required(VERSION 3.16.0)
project(storage C ASM)

FetchContent_Declare(
  storage_tarantool
  GIT_REPOSITORY ${DEPENDENCY_TARANTOOL_REPOSITORY}
  GIT_TAG ${DEPENDENCY_TARANTOOL_VERSION}
  SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/dependencies/libtarantool-source
  BINARY_DIR ${CMAKE_CURRENT_SOURCE_DIR}/dependencies/libtarantool-binary
)
FetchContent_Populate(storage_tarantool)

set(TARANTOOL_CMAKE_ARGUMENTS
  --no-warn-unused-cli
  -Wno-dev
  -DCMAKE_BUILD_TYPE:STRING=RelWithDebInfo
  -DCMAKE_EXPORT_COMPILE_COMMANDS:BOOL=TRUE
  -S${storage_tarantool_SOURCE_DIR}
  -B${storage_tarantool_BINARY_DIR}
  -G "Unix Makefiles"
  -DCMAKE_INSTALL_LOCALSTATEDIR=<INSTALL_DIR>/var
  -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
  -DBUNDLED_LIBS_INSTALL_DIR=${storage_tarantool_BINARY_DIR}
  -DBUILD_STATIC_WITH_BUNDLED_LIBS=TRUE
  -DENABLE_DIST=OFF
  -DENABLE_GCOV=FALSE
  -DENABLE_LTO=FALSE
  -DENABLE_HARDENING=TRUE
  -DENABLE_BACKTRACE=FALSE
  -DWITH_TESTS=OFF
  -DCMAKE_POSITION_INDEPENDENT_CODE=ON
  -DCMAKE_BUILD_TYPE=RelWithDebInfo
  -DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}
  -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
  -DCMAKE_C_FLAGS=${COMPILER_C_FLAGS_RELEASE}
  -DCMAKE_CXX_FLAGS=${COMPILER_CXX_FLAGS_RELEASE}
  -DCMAKE_C_FLAGS_RELEASE=${COMPILER_C_FLAGS_RELEASE}
  -DCMAKE_CXX_FLAGS_RELEASE=${COMPILER_CXX_FLAGS_RELEASE}
  -DCMAKE_C_FLAGS_RELWITHDEBINFO=${COMPILER_C_FLAGS_RELEASE}
  -DCMAKE_CXX_FLAGS_RELWITHDEBINFO=${COMPILER_CXX_FLAGS_RELEASE})
ExternalProject_Add(storage_tarantool
  PREFIX ${CMAKE_CURRENT_SOURCE_DIR}/dependencies/libtarantool-prefix
  SOURCE_DIR ${storage_tarantool_SOURCE_DIR}
  BINARY_DIR ${storage_tarantool_BINARY_DIR}
  EXCLUDE_FROM_ALL TRUE
  CONFIGURE_COMMAND ""
  BUILD_COMMAND ""
  INSTALL_COMMAND ""
)
ExternalProject_Add_Step(storage_tarantool storage_tarantool_configure
  COMMAND cmake ${TARANTOOL_CMAKE_ARGUMENTS}
  WORKING_DIRECTORY <SOURCE_DIR>
  EXCLUDE_FROM_MAIN TRUE
  BYPRODUCTS ${storage_tarantool_SOURCE_DIR}/Makefile
)
ExternalProject_Add_Step(storage_tarantool storage_tarantool_build
  COMMAND make -j api build-tarantool-bundle
  WORKING_DIRECTORY <BINARY_DIR>
  EXCLUDE_FROM_MAIN FALSE
  BYPRODUCTS ${storage_tarantool_BINARY_DIR}/src/libtarantool-bundle.a
  DEPENDEES storage_tarantool_configure
)
ExternalProject_Add_Step(storage_tarantool storage_tarantool_install
  COMMAND make install
  WORKING_DIRECTORY <BINARY_DIR>
  EXCLUDE_FROM_MAIN FALSE
  BYPRODUCTS ${storage_tarantool_BINARY_DIR}/src/libtarantool-bundle.a
  DEPENDEES storage_tarantool_build
)

set(TARANTOOL_INSTALL_DIR ${storage_tarantool_BINARY_DIR})
set(TARANTOOL_LIBRARY ${CMAKE_CURRENT_SOURCE_DIR}/dependencies/libtarantool-prefix/lib/libtarantool-bundle.a)
set(TARANTOOL_SOURCE_DIRECTORY ${storage_tarantool_SOURCE_DIR})
set(TARANTOOL_BINARY_DIRECTORY ${storage_tarantool_BINARY_DIR})

add_subdirectory(native)