cmake_minimum_required(VERSION 3.16.0)
project(mediator_test C ASM)

file(GLOB sources
  *.c
  *.h
)

include_directories(${PROJECT_BINARY_DIR})
include_directories(${PROJECT_SOURCE_DIR})
include_directories(${memory_small_SOURCE_DIR}/include)
include_directories(${memory_small_SOURCE_DIR}/include/small)
include_directories(${memory_small_SOURCE_DIR}/third_party)
include_directories(${memory_small_BINARY_DIR}/small/include)
include_directories(${mediator_liburing_SOURCE_DIR}/src/include)
include_directories(${mediator_liburing_BINARY_DIR}/src/include)
include_directories(${CORE_INCLUDE_DIRECTORY})
include_directories(${MEMORY_INCLUDE_DIRECTORY})
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../../native/include)

add_library(mediator_test SHARED ${sources})
target_link_libraries(mediator_test PUBLIC mediator_debug_linux_x64)
add_custom_command(TARGET mediator_test POST_BUILD COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_FILE:mediator_test> ${CMAKE_CURRENT_SOURCE_DIR}/../dart/native/libmediatortest.so)