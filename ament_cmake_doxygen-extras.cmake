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

find_package(ament_cmake_core REQUIRED)
find_package(Doxygen REQUIRED)

set(AMENT_CMAKE_DOXYGEN_RESOURCES_DIR "${ament_cmake_doxygen_DIR}/../resources")
set(AMENT_CMAKE_DOXYGEN_TOOLS_DIR "${ament_cmake_doxygen_DIR}/../tools")

include("${ament_cmake_doxygen_DIR}/ament_doxygen_resolve_tags.cmake")
include("${ament_cmake_doxygen_DIR}/ament_doxygen_find_external.cmake")
include("${ament_cmake_doxygen_DIR}/ament_doxygen_generate_configuration.cmake")
include("${ament_cmake_doxygen_DIR}/ament_doxygen_aggregate_external.cmake")
include("${ament_cmake_doxygen_DIR}/ament_doxygen_generate.cmake")
