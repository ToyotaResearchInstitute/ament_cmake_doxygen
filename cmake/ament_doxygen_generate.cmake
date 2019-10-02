# Copyright 2019 Toyota Research Institute
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#
# Generate documentation using Doxygen.
#
# Provided Doxygen configuration defaults expect C++ sources. This macro is capable of
# linking against upstream packages' documentation and expose generated documentation
# for downstream packages to link against.
#
# :param CONFIG_OVERLAY: Path to a Doxyfile overlay file, which may be a template if
#                        the '.in' suffix is present. Defaults to none.
# :type CONFIG_OVERLAY: string
# :param PROJECT_NAME: Doxygen project name. Defaults to the current CMake project name.
# :type PROJECT_NAME: string
# :param INPUT_DIRECTORY: Path to directory to crawl looking for sources.
#                         Defaults to the current directory in the CMake project source
#                         tree (i.e. the directory this macro was called at).
# :type INPUT_DIRECTORY: string
# :param OUTPUT_DIRECTORY: Path to directory to generate output into.
#                          Defaults to the ament_cmake_doxygen/${PROJECT_NAME}
#                          directory in the current CMake project build tree.
# :type OUTPUT_DIRECTORY: string
# :param DEPENDENCIES: List of project dependencies. Must be known by ament.
# :type DEPENDENCIES: list of strings
#
# @public
#
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

  if (DOXYGEN_DOT_FOUND)
    set(HAVE_DOT YES)
    get_filename_component(DOT_PATH "${DOXYGEN_DOT_EXECUTABLE}" DIRECTORY)
  endif()

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
      # cut off .in extension
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
