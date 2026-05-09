cmake_minimum_required(VERSION 3.10)

set(BINARY_NAME "nbox")
set(VERSION_NAME "1.0.0")

project(${BINARY_NAME} LANGUAGES CXX)

cmake_policy(SET CMP0079 NEW)

set(CMAKE_BUILD_TYPE "RelWithDebInfo" CACHE STRING "")
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/runner")

add_subdirectory(${FLUTTER_ROOT} bin)

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(BINARY_NAME "nbox")

add_library(${BINARY_NAME} SHARED
  "flutter_window.cc"
  "main.cc"
)

apply_standard_settings(${BINARY_NAME})

set_target_properties(${BINARY_NAME} PROPERTIES
  RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/runner"
)

add_dependencies(${BINARY_NAME} flutter_assemble)
