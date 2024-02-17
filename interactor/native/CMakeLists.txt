cmake_minimum_required(VERSION 3.16.0)

project(interactor_native C ASM)

include_directories(${interactor_liburing_SOURCE_DIR}/src/include)
include_directories(${interactor_liburing_BINARY_DIR}/src/include)

include_directories(${interactor_msgpuck_SOURCE_DIR})

include_directories(${interactor_small_SOURCE_DIR}/include)
include_directories(${interactor_small_SOURCE_DIR}/include/small)
include_directories(${interactor_small_SOURCE_DIR}/third_party)
include_directories(${interactor_small_BINARY_DIR}/small/include)

include_directories(${PROJECT_BINARY_DIR})
include_directories(${PROJECT_SOURCE_DIR})
include_directories(include)

file(GLOB sources
  *.c
  *.h
  dart/*.h
  dart/*.c
  collections/*.h
  collections/*.c
  common/*.h
  common/*.c
)

add_library(interactor_debug_linux_x64 SHARED ${sources})
add_dependencies(interactor_debug_linux_x64 interactor_liburing ${SMALL_PROJECT} ${MSGPUCK_PROJECT})
target_link_libraries(interactor_debug_linux_x64 PRIVATE ${interactor_liburing_SOURCE_DIR}/build/lib/liburing.a ${SMALL_PROJECT} ${MSGPUCK_PROJECT})
set_target_properties(interactor_debug_linux_x64 PROPERTIES COMPILE_FLAGS ${CMAKE_C_FLAGS_DEBUG})
add_custom_command(TARGET interactor_debug_linux_x64 POST_BUILD COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_FILE:interactor_debug_linux_x64> ${CMAKE_CURRENT_SOURCE_DIR}/../dart/native/libinteractor_debug_linux_x64.so)

add_library(interactor_release_linux_x64 SHARED ${sources})
add_dependencies(interactor_release_linux_x64 interactor_liburing ${SMALL_PROJECT} ${MSGPUCK_PROJECT})
target_link_libraries(interactor_release_linux_x64 PRIVATE ${interactor_liburing_SOURCE_DIR}/build/lib/liburing.a ${SMALL_PROJECT} ${MSGPUCK_PROJECT})
set_target_properties(interactor_release_linux_x64 PROPERTIES COMPILE_FLAGS ${CMAKE_C_FLAGS})
add_custom_command(TARGET interactor_release_linux_x64 POST_BUILD COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_FILE:interactor_release_linux_x64> ${CMAKE_CURRENT_SOURCE_DIR}/../dart/native/libinteractor_release_linux_x64.so)

add_custom_target(interactor_native DEPENDS interactor_release_linux_x64 interactor_debug_linux_x64)