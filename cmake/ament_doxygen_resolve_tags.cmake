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
# Resolve Doxygen tags' paths relative to a provided base directory.
#
# Tags format is that expected by Doxygen: "PATH_TO_TAGFILE=PATH_TO_HTML_DIR".
#
# :param tags_var: Output variable to populate with resolved tags.
# :type tags_var: space-delimited list of strings
# :param TAGS: Tags to be resolved.
# :type TAGS: list of strings
# :param BASE_DIRECTORY: Path to base directory to resolve tags' paths against.
# :type BASE_DIRECTORY: string
#
# @public
#
function(ament_doxygen_resolve_tags tags_var)
  cmake_parse_arguments(
    args
    ""
    "BASE_DIRECTORY"
    "TAGS" ${ARGN})

  set(${tags_var} "")
  foreach(tag ${args_TAGS})
    string(REPLACE "=" ";" tag "${tag}")
    string(REPLACE "\"" " " tag "${tag}")
    string(STRIP "${tag}" tag)
    list(GET tag 0 tagfile)
    list(GET tag 1 htmldir)

    file(RELATIVE_PATH htmldir "${args_BASE_DIRECTORY}" "${htmldir}")
    if(NOT htmldir MATCHES "^\.\.?/.*$")
      # Cope with Doxygen issues with nested subprojects
      set(htmldir "./${htmldir}")
    endif()
    list(APPEND ${tags_var} "\"${tagfile}=${htmldir}\"")
  endforeach()
  set(${tags_var} ${${tags_var}} PARENT_SCOPE)
endfunction()
