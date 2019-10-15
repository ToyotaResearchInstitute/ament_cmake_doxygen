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
# Provided Doxygen configuration defaults expect C++ sources. This macro uses the ament index
# to link against upstream packages' documentation projects and expose documentation projects
# for downstream packages to link against. Source configuration, generated tag and dependencies
# are made available as resources of doxygen_source, doxygen_tag and doxygen_dependencies types.
#
# :param target_name: Target for the documentation generation process.
# :type target_name: string
#
# :param PROJECT_NAME: Doxygen project name. Defaults to the current CMake project name.
# :type PROJECT_NAME: string
# :param CONFIG_OVERLAY: Path to a template overlay file. Defaults to none.
# :type CONFIG_OVERLAY: string
# :param CONFIG_DIRECTORY: Path to the directory holding configuration-time files e.g. configured
#                          templates. Non absolute paths are resolved relative to the current CMake
#                          build directory. Defaults to the 'ament_cmake_doxygen/${PROJECT_NAME}'
#                          subdirectory.
# :type CONFIG_DIRECTORY: string
# :param BUILD_DIRECTORY: Path to the directory holding build-time files e.g. Doxygen generated
#                         output. Non absolute paths are resolved relative to the current CMake
#                         build directory. Defaults to the '${CONFIG_DIRECTORY}/output' subdirectory.
# :type BUILD_DIRECTORY: string
# :param INPUT_DIRECTORY: Path to the root directory of all sources. Non absolute paths are resolved
#                         relative to the current CMake source directory. Defaults to '.'.
# :type INPUT_DIRECTORY: string
# :param INSTALL_DIRECTORY: Path to install generated output into. Non absolute paths are resolved
#                           relative to the CMake install prefix.
#                           Defaults to the 'share/${PROJECT_NAME}/doc' subdirectory.
# :type INSTALL_DIRECTORY: string
# :param STANDALONE: Generate documentation in a self-contained way. All recursive dependencies are
#                    re-built and bundled with this project's documentation.
#                    See `ament_doxygen_aggregate_external()` documentation for further reference.
# :type STANDALONE: boolean
# :param NO_INSTALL: Prevent installation of generated project documentation. This also means the project
#                    will not be exposed in the ament index.
# :type NO_INSTALL: boolean
# :param DEPENDENCIES: External Doxygen project dependencies to link against. If built using this macro,
#                      these must have been installed. See ament_doxygen_find_external() documentation
#                      for further reference.
# :type DEPENDENCIES: list of strings
#
# @public
#
function(ament_doxygen_generate target_name)
  cmake_parse_arguments(
    args
    "STANDALONE;NO_INSTALL"
    "PROJECT_NAME;CONFIG_OVERLAY;CONFIG_DIRECTORY;INPUT_DIRECTORY;BUILD_DIRECTORY;INSTALL_DIRECTORY"
    "DEPENDENCIES" ${ARGN})

  if (NOT DEFINED args_PROJECT_NAME)
    set(args_PROJECT_NAME "${PROJECT_NAME}")
  endif()

  if (NOT DEFINED args_CONFIG_DIRECTORY)
    set(args_CONFIG_DIRECTORY "ament_cmake_doxygen/${PROJECT_NAME}")
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

  if (args_STANDALONE)
    ament_doxygen_aggregate_external(${target_name}_dependencies
      EXTERNAL_PROJECTS ${args_DEPENDENCIES}
      CONFIG_DIRECTORY "${args_CONFIG_DIRECTORY}/deps"
      BUILD_DIRECTORY "${args_BUILD_DIRECTORY}/html/deps"
    )

    ament_doxygen_resolve_tags(tags
      TAGS ${${target_name}_dependencies_TAGS}
      BASE_DIRECTORY "${args_BUILD_DIRECTORY}/html"
    )
  else()
    ament_doxygen_find_external(tags
      EXTERNAL_PROJECTS ${args_DEPENDENCIES}
      BASE_DIRECTORY "${args_BUILD_DIRECTORY}/html"
    )
  endif()

  set(doxyfile "${args_CONFIG_DIRECTORY}/Doxyfile")
  ament_doxygen_generate_configuration("${doxyfile}"
    CONFIG_OVERLAY "${args_CONFIG_OVERLAY}"
    CONFIG_DIRECTORY "${args_CONFIG_DIRECTORY}"
    BUILD_DIRECTORY "${args_BUILD_DIRECTORY}"
    INPUT_DIRECTORY "${args_INPUT_DIRECTORY}"
    PROJECT_NAME "${args_PROJECT_NAME}"
    OUTPUT_TAGFILE "${args_PROJECT_NAME}.tag"
    INPUT_TAGS ${tags}
  )

  add_custom_target(${target_name} ALL
    COMMAND ${DOXYGEN_EXECUTABLE} "${doxyfile}"
    VERBATIM
  )

  if (TARGET ${target_name}_dependencies)
    add_dependencies(${target_name} ${target_name}_dependencies)
  endif()

  if (NOT args_NO_INSTALL)
    if (NOT DEFINED args_INSTALL_DIRECTORY)
      set(args_INSTALL_DIRECTORY "share/${PROJECT_NAME}/doc/${args_PROJECT_NAME}")
    endif()

    install(
      DIRECTORY "${args_BUILD_DIRECTORY}/"
      DESTINATION "${args_INSTALL_DIRECTORY}"
    )

    set(tagfile "${args_INSTALL_DIRECTORY}/${args_PROJECT_NAME}.tag")
    set(htmldir "${args_INSTALL_DIRECTORY}/html")
    ament_index_register_resource(doxygen_tag
      PACKAGE_NAME "${args_PROJECT_NAME}"
      CONTENT "${tagfile}=${htmldir}"
    )
    set(${target_name}_TAG "${tagfile}=${htmldir}" PARENT_SCOPE)

    file(READ "${doxyfile}" source)
    ament_index_register_resource(doxygen_source
      PACKAGE_NAME "${args_PROJECT_NAME}"
      CONTENT "${source}"
    )
    set(${target_name}_SOURCE "${source}" PARENT_SCOPE)

    ament_index_register_resource(doxygen_dependencies
      PACKAGE_NAME "${args_PROJECT_NAME}"
      CONTENT "${args_DEPENDENCIES}"
    )
    set(${target_name}_DEPENDENCIES "${args_DEPENDENCIES}" PARENT_SCOPE)
  endif()
endfunction()
