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
# Generate Doxygen configuration file aka Doxyfile.
#
# Provided defaults expect C++ sources.
#
# :param doxyfile: Path to generated configuration file.
# :type doxyfile: string
#
# :param BASE_CONFIG: Path to a template base configuration file. Non absolute paths
#                     are resolved relative to the current CMake source directory.
#                     Defaults to ament_cmake_doxygen's default Doxyfile.
# :type BASE_CONFIG: string
# :param CONFIG_OVERLAY: Path to a template overlay file. Defaults to none.
# :type CONFIG_OVERLAY: string
# :param PROJECT_NAME: Doxygen project name. Defaults to the current CMake project name.
# :type PROJECT_NAME: string
# :param CONFIG_DIRECTORY: Path to the directory holding configuration-time files e.g. configured
#                          templates. Non absolute paths are resolved relative to the current CMake
#                          build directory. Defaults to the 'ament_cmake_doxygen/${PROJECT_NAME}'
#                          subdirectory.
# :type CONFIG_DIRECTORY: string
# :param BUILD_DIRECTORY: Path to the directory holding build-time files e.g. Doxygen generated
#                         output. Non absolute paths are resolved relative to the current CMake
#                         build directory. Defaults to the ${CONFIG_DIRECTORY}/output subdirectory.
# :type BUILD_DIRECTORY: string
# :param INPUT_DIRECTORY: Path to the root directory of all sources. Non absolute paths are resolved
#                         relative to the current CMake source directory. Defaults to '.'.
# :type INPUT_DIRECTORY: string
# :param INPUT_TAGS: External projects' tags to link against, in the format that Doxygen
#                    expects: "PATH_TO_TAGFILE=PATH_TO_HTML_DIR". Defaults to none.
# :type INPUT_TAGS: list of strings
# :param OUTPUT_TAGFILE: Path to the Doxygen tagfile to be generated for this project. Non absolute
#                        paths are resolved relative to the ${CONFIG_DIRECTORY}. Defaults to none.
# :type OUTPUT_TAGFILE: string
#
# @public
#
function(ament_doxygen_generate_configuration doxyfile)
  cmake_parse_arguments(
    args
    ""
    "BASE_CONFIG;CONFIG_OVERLAY;CONFIG_DIRECTORY;PROJECT_NAME;BUILD_DIRECTORY;INPUT_DIRECTORY;OUTPUT_TAGFILE"
    "INPUT_TAGS" ${ARGN})

  if (NOT DEFINED args_BASE_CONFIG)
    set(args_BASE_CONFIG "${AMENT_CMAKE_DOXYGEN_RESOURCES_DIR}/Doxyfile.in")
  endif()
  get_filename_component(args_BASE_CONFIG "${args_BASE_CONFIG}"
    REALPATH BASE_DIR "${CMAKE_CURRENT_SOURCE_DIR}"
  )

  if (NOT DEFINED args_PROJECT_NAME)
    set(args_PROJECT_NAME "${PROJECT_NAME}")
  endif()

  if (NOT DEFINED args_CONFIG_DIRECTORY)
    set(args_CONFIG_DIRECTORY "ament_cmake_doxygen/${args_PROJECT_NAME}")
  endif()
  get_filename_component(args_CONFIG_DIRECTORY "${args_CONFIG_DIRECTORY}"
    REALPATH BASE_DIR "${CMAKE_CURRENT_BINARY_DIR}"
  )

  if (NOT DEFINED args_BUILD_DIRECTORY)
    set(args_BUILD_DIRECTORY "${args_CONFIG_DIRECTORY}/output")
  endif()
  get_filename_component(args_BUILD_DIRECTORY "${args_BUILD_DIRECTORY}"
    REALPATH BASE_DIR "${CMAKE_CURRENT_BINARY_DIR}"
  )

  if (NOT DEFINED args_INPUT_DIRECTORY)
    set(args_INPUT_DIRECTORY ".")
  endif()
  get_filename_component(args_INPUT_DIRECTORY "${args_INPUT_DIRECTORY}"
    REALPATH BASE_DIR "${CMAKE_CURRENT_SOURCE_DIR}"
  )

  set(PROJECT_NAME "${args_PROJECT_NAME}")
  set(CONFIG_DIRECTORY "${args_CONFIG_DIRECTORY}")
  set(OUTPUT_DIRECTORY "${args_BUILD_DIRECTORY}")
  set(INPUT_DIRECTORY "${args_INPUT_DIRECTORY}")
  string(REPLACE ";" " " TAGFILES "${args_INPUT_TAGS}")
  get_filename_component(GENERATE_TAGFILE "${args_OUTPUT_TAGFILE}"
    REALPATH BASE_DIR "${args_BUILD_DIRECTORY}"
  )
  if (DOXYGEN_DOT_FOUND)
    set(HAVE_DOT YES)
    get_filename_component(DOT_PATH "${DOXYGEN_DOT_EXECUTABLE}" DIRECTORY)
  endif()

  get_filename_component(doxyfile "${doxyfile}" REALPATH
    BASE_DIR "${args_CONFIG_DIRECTORY}")
  configure_file("${args_BASE_CONFIG}" "${doxyfile}" @ONLY)

  if (args_CONFIG_OVERLAY)
    get_filename_component(overlay_filename "${args_CONFIG_OVERLAY}" NAME)
    set(overlay "${args_CONFIG_DIRECTORY}/overlays/${overlay_filename}")
    configure_file("${args_CONFIG_OVERLAY}" "${overlay}" @ONLY)
    file(READ "${overlay}" overlay_content)
    file(APPEND "${doxyfile}" "${overlay_content}")
  endif()
endfunction()
