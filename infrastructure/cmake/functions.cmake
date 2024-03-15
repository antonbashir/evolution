function(copy_to_assets library)
  add_custom_command(TARGET ${library} POST_BUILD COMMAND ${CMAKE_COMMAND} -E copy $<TARGET_FILE:${library}> ${CMAKE_CURRENT_SOURCE_DIR}/../dart/assets/lib${library}.so)
endfunction()

function(list_add_prefix list_in prefix list_out)
  set(result "")

  foreach(i ${${list_in}})
    list(APPEND result "${prefix}${i}")
  endforeach()

  set(${list_out} ${result} PARENT_SCOPE)
endfunction()