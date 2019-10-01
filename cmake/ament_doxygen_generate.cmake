
function(ament_doxygen_generate)
  cmake_parse_arguments(
    args
    ""
    "CONFIG_OVERLAY;PROJECT_NAME;INPUT_DIRECTORY;OUTPUT_DIRECTORY"
    "DEPENDENCIES" ${ARGN})
  set(CONFIG_DIRECTORY "${ament_cmake_doxygen_DIR}/../resources")

  if (NOT args_PROJECT_NAME)
    set(args_PROJECT_NAME "${PROJECT_NAME}")
  endif()
  set(PROJECT_NAME "${args_PROJECT_NAME}")

  set(BUILD_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/ament_cmake_doxygen/${PROJECT_NAME}")

  if (NOT args_INPUT_DIRECTORY)
    set(args_INPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}")
  endif()
  set(INPUT_DIRECTORY "${args_INPUT_DIRECTORY}")

  if (NOT args_OUTPUT_DIRECTORY)
    if (NOT DOXYGEN_OUTPUT_ROOT)
      set(DOXYGEN_OUTPUT_ROOT "${CMAKE_CURRENT_BINARY_DIR}/ament_cmake_doxygen")
    endif()
    set(args_OUTPUT_DIRECTORY "${DOXYGEN_OUTPUT_ROOT}/${PROJECT_NAME}")
  endif()
  set(OUTPUT_DIRECTORY "${args_OUTPUT_DIRECTORY}")


  foreach(dep ${args_DEPENDENCIES})
    ament_index_has_resource(has_tag doxygen_tags "${dep}")
    if(has_tag)
      ament_index_get_resource(tag doxygen_tags "${dep}")
      list(GET tag 0 tagfile)
      list(GET tag 1 htmldir)
      file(RELATIVE_PATH htmldir "${OUTPUT_DIRECTORY}/html" "${htmldir}")
      set(TAGFILES "${TAGFILES} \"${tagfile}=${htmldir}\"")
    else()
      message(WARNING "A Doxygen tagfile for ${dep} could not be found, ignoring")
    endif()
  endforeach()
  set(GENERATE_TAGFILE "${OUTPUT_DIRECTORY}/${PROJECT_NAME}.tag")

  configure_file("${CONFIG_DIRECTORY}/Doxyfile.in" "${BUILD_DIRECTORY}/Doxyfile" @ONLY)

  if (args_CONFIG_OVERLAY)
    string_ends_with("${args_CONFIG_OVERLAY}" ".in" is_template)
    if(is_template)
      get_filename_component(overlay_filename "${args_CONFIG_OVERLAY}" NAME)
      # cut of .in extension
      string(LENGTH "${overlay_filename}" length)
      math(EXPR offset "${length} - 3")
      string(SUBSTRING "${overlay_filename}" 0 ${offset} overlay_filename)
      configure_file(
        "${args_CONFIG_OVERLAY}"
        "${BUILD_DIRECTORY}/${overlay_filename}"
        @ONLY
      )
      set(args_CONFIG_OVERLAY "${BUILD_DIRECTORY}/${overlay_filename}")
    endif()
    file(READ "${args_CONFIG_OVERLAY}" overlay_content)
    file(APPEND "${BUILD_DIRECTORY}/Doxyfile" "${overlay_content}")
  endif()

  add_custom_target(doxygen_${PROJECT_NAME} ALL
    COMMAND ${DOXYGEN_EXECUTABLE} "${BUILD_DIRECTORY}/Doxyfile"
    VERBATIM
  )
  ament_index_register_resource(doxygen_tags
    PACKAGE_NAME "${PROJECT_NAME}"
    CONTENT "${GENERATE_TAGFILE};${OUTPUT_DIRECTORY}/html"
  )
endfunction()
