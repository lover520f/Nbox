cmake_minimum_required(VERSION 3.14)
project(nbox LANGUAGES CXX)

set(BINARY_NAME "nbox")

cmake_policy(SET CMP0063 NEW)

set(FLUTTER_VERSION "1.0.0" PARENT_SCOPE)
set(FLUTTER_VERSION_MAJOR 1 PARENT_SCOPE)
set(FLUTTER_VERSION_MINOR 0 PARENT_SCOPE)
set(FLUTTER_VERSION_PATCH 0 PARENT_SCOPE)
set(FLUTTER_VERSION_TWEAK 0 PARENT_SCOPE)

set(CMAKE_INSTALL_RPATH "$ORIGIN/lib")

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(EPHEMERAL_DIR "${CMAKE_CURRENT_SOURCE_DIR}/ephemeral")
include("${EPHEMERAL_DIR}/generated_config.cmake")

set(PLUGINS_BINARY_DIR "${CMAKE_CURRENT_BINARY_DIR}/plugins")

get_filename_component(FLUTTER_ROOT "${EPHEMERAL_DIR}" ABSOLUTE CACHE)

include("${EPHEMERAL_DIR}/plugin_symlinks/windows/flutter_plugins.cmake")

set(WRAPPER_ROOT "${EPHEMERAL_DIR}/cpp_client_wrapper")

add_subdirectory("${WRAPPER_ROOT}" cpp_client_wrapper)

set(FLUTTER_LIBRARY "${EPHEMERAL_DIR}/flutter_windows.dll")

set(RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/runner")

add_executable(${BINARY_NAME} WIN32
  "flutter_window.cc"
  "main.cc"
  "win32_window.cc"
  ${PLUGIN_SRCS}
)

apply_standard_settings(${BINARY_NAME})
target_compile_definitions(${BINARY_NAME} PRIVATE "NOMINMAX" "WIN32_LEAN_AND_MEAN")
target_link_libraries(${BINARY_NAME} PRIVATE flutter flutter_wrapper_app)
target_include_directories(${BINARY_NAME} PRIVATE "${CMAKE_SOURCE_DIR}")

add_dependencies(${BINARY_NAME} flutter_assemble)
