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
# Aggregate external Doxygen projects in one place.
#
# Project source configurations and dependencies are looked up in the current ament index,
# as resources of doxygen_source and doxygen_dependencies types respectively. Projects and
# its recursive dependencies are aggregated under ${BUILD_DIRECTORY}/${PROJECT_NAME}. To
# restore cross-references, project aggregation implies project re-build once, no matter how
# many times a project shows up in the dependency graph.
#
# :param target_name: Target name for the aggregation process.
# :type target_name: string
# :param EXTERNAL_PROJECTS: External Doxygen projects to be aggregated.
# :type EXTERNAL_PROJECTS: list of strings
# :param CONFIG_DIRECTORY: Path to the directory holding configuration-time files e.g. projects
#                          configuration files. Defaults to the ament_cmake_doxygen/${target_name}
#                          subdirectory in the current CMake project build directory.
# :type CONFIG_DIRECTORY: string
# :param BUILD_DIRECTORY: Path to the directory holding build-time files e.g. Doxygen generated
#                         output. Defaults to the ${CONFIG_DIRECTORY}/aggregation subdirectory.
# :type BUILD_DIRECTORY: string
#
# @public
#
function(ament_doxygen_aggregate_external target_name)
  cmake_parse_arguments(
    args
    ""
    "CONFIG_DIRECTORY;BUILD_DIRECTORY"
    "EXTERNAL_PROJECTS" ${ARGN})

  if (NOT TARGET ${target_name})
    add_custom_target(${target_name} ALL)
  endif()
  set(${target_name}_TAGS "")
  foreach(project ${args_EXTERNAL_PROJECTS})
    if(NOT TARGET ${target_name}_${project})
      ament_index_has_resource(has_source doxygen_source "${project}")
      if(has_source)
        ament_index_get_resource(source doxygen_source "${project}")
        file(MAKE_DIRECTORY "${args_CONFIG_DIRECTORY}/${project}")
        file(WRITE "${args_CONFIG_DIRECTORY}/${project}/Doxyfile.base" "${source}")

        file(MAKE_DIRECTORY "${args_BUILD_DIRECTORY}/${project}")
        add_custom_target(${target_name}_${project} ALL
          COMMAND ${DOXYGEN_EXECUTABLE} "${args_CONFIG_DIRECTORY}/${project}/Doxyfile"
          VERBATIM
        )
        add_dependencies(${target_name} ${target_name}_${project})

        ament_index_has_resource(has_dependencies doxygen_dependencies "${project}")
        if(has_dependencies)
          ament_index_get_resource(dependencies doxygen_dependencies "${project}")

          set(stash ${${target_name}_TAGS})
          unset(${target_name}_TAGS)

          ament_doxygen_aggregate_external(${target_name}
            EXTERNAL_PROJECTS ${dependencies}
            CONFIG_DIRECTORY "${args_CONFIG_DIRECTORY}"
            BUILD_DIRECTORY "${args_BUILD_DIRECTORY}"
          )

          ament_doxygen_resolve_tags(${project}_tags
            TAGS ${${target_name}_TAGS}
            BASE_DIRECTORY "${args_BUILD_DIRECTORY}/${project}/html/"
          )

          foreach(dep ${dependencies})
            add_dependencies(${target_name}_${project} ${target_name}_${dep})
          endforeach()

          set(${target_name}_TAGS ${stash})
        endif()

        ament_doxygen_generate_configuration("${args_CONFIG_DIRECTORY}/${project}/Doxyfile"
          BASE_CONFIG "${args_CONFIG_DIRECTORY}/${project}/Doxyfile.base"
          CONFIG_OVERLAY "${AMENT_CMAKE_DOXYGEN_RESOURCES_DIR}/Doxyfile.deps.in"
          CONFIG_DIRECTORY "${args_CONFIG_DIRECTORY}/${project}"
          BUILD_DIRECTORY "${args_BUILD_DIRECTORY}/${project}"
          OUTPUT_TAGFILE "${project}.tag"
          INPUT_TAGS "${${project}_tags}"
        )
      else()
        message(WARNING "A Doxyfile for ${project} could not be found, ignoring...")
      endif()
    endif()
    list(APPEND ${target_name}_TAGS
      "\"${args_BUILD_DIRECTORY}/${project}/${project}.tag=${args_BUILD_DIRECTORY}/${project}/html\"")
  endforeach()
  set(${target_name}_TAGS ${${target_name}_TAGS} PARENT_SCOPE)
endfunction()
