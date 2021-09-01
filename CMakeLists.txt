cmake_minimum_required(VERSION 3.5 FATAL_ERROR)

project(ament_cmake_doxygen NONE)

find_package(ament_cmake REQUIRED)

ament_package(
  CONFIG_EXTRAS "ament_cmake_doxygen-extras.cmake"
)

install(
  DIRECTORY cmake resources tools
  DESTINATION share/${PROJECT_NAME}
)
