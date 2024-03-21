function(copy_to_assets library)
  add_custom_command(TARGET ${library} POST_BUILD COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_FILE:${library}> ${CMAKE_CURRENT_SOURCE_DIR}/../dart/assets/lib${library}.so)
endfunction()

function(copy_file_to_assets target from to)
  add_custom_command(TARGET ${target} POST_BUILD COMMAND ${CMAKE_COMMAND} -E copy ${from} ${to})
endfunction()

function(list_add_prefix list_in prefix list_out)
  set(result "")

  foreach(i ${${list_in}})
    list(APPEND result "${prefix}${i}")
  endforeach()

  set(${list_out} ${result} PARENT_SCOPE)
endfunction()


function(include_dart_api)
get_property(DART_API_INCLUDE_DIRECTORY_PROPERTY GLOBAL PROPERTY DART_API_INCLUDE_DIRECTORY)
include_directories(${DART_API_INCLUDE_DIRECTORY_PROPERTY})
endfunction()

function(fetch_dart_api)
FetchContent_Declare(
  ${PROJECT_NAME}_dart_api
  GIT_REPOSITORY ${DEPENDENCY_DART_API_REPOSITORY}
  GIT_TAG ${DEPENDENCY_DART_API_VERSION}
  SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/dependencies/dart-api-source
  BINARY_DIR ${CMAKE_CURRENT_SOURCE_DIR}/dependencies/dart-api-binary
)
FetchContent_MakeAvailable(${PROJECT_NAME}_dart_api)
set_property(GLOBAL PROPERTY DART_API_INCLUDE_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/dependencies/dart-api-source)
endfunction()