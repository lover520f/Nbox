cmake_minimum_required(VERSION 3.10)

set(BINARY_NAME "nbox")
set(VERSION_NAME "1.0.0")

project(${BINARY_NAME} LANGUAGES CXX)

cmake_policy(SET CMP0079 NEW)

set(CMAKE_BUILD_TYPE ${BUILD_TYPE} CACHE STRING "")

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/runner")

add_subdirectory(${FLUTTER_ROOT} bin)
