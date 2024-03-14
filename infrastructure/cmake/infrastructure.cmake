function(list_add_prefix list_in prefix list_out)
  set(result "")

  foreach(i ${${list_in}})
    list(APPEND result "${prefix}${i}")
  endforeach()

  set(${list_out} ${result} PARENT_SCOPE)
endfunction()

include(${CMAKE_CURRENT_LIST_DIR}/functions.cmake)