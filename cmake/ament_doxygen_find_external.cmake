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
# Find Doxygen tags of external projects to link against.
#
# Tags are looked up in the current ament index, as resources of doxygen_tag type.
#
# :param tags_var: Output variable to populate with all found tags.
# :type tags_var: space-delimited list of strings
# :param EXTERNAL_PROJECTS: External projects to be found.
# :type EXTERNAL_PROJECTS: list of strings
# :param BASE_DIRECTORY: Path to base directory to resolve tags' paths against
#                        if provided. Defaults to none.
# :type BASE_DIRECTORY: string
#
# @public
#
function(ament_doxygen_find_external tags_var)
  cmake_parse_arguments(
    args
    ""
    "BASE_DIRECTORY"
    "EXTERNAL_PROJECTS" ${ARGN})
  foreach(project ${args_EXTERNAL_PROJECTS})
    ament_index_has_resource(has_tag doxygen_tag "${project}")
    if(has_tag)
      ament_index_get_resource(tag doxygen_tag "${project}")

      string(REPLACE "=" ";" tag "${tag}")
      string(REPLACE "\"" " " tag "${tag}")
      string(STRIP "${tag}" tag)

      list(GET tag 0 tagfile)
      list(GET tag 1 htmldir)

      get_filename_component(tagfile "${tagfile}" REALPATH BASE_DIR "${has_tag}")
      get_filename_component(htmldir "${htmldir}" REALPATH BASE_DIR "${has_tag}")

      list(APPEND ${tags_var} "\"${tagfile}=${htmldir}\"")
    else()
      message(WARNING "A Doxygen tag for ${project} could not be found.")
    endif()
  endforeach()
  if (DEFINED args_BASE_DIRECTORY)
    ament_doxygen_resolve_tags(${tags_var}
      TAGS ${${tags_var}}
      BASE_DIRECTORY "${args_BASE_DIRECTORY}"
    )
  endif()
  set(${tags_var} ${${tags_var}} PARENT_SCOPE)
endfunction()
