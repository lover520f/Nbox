cmake_minimum_required(VERSION 3.10)
project(nbox LANGUAGES CXX)

set(BINARY_NAME "nbox")
set(VERSION_NAME "1.0.0")

cmake_policy(SET CMP0079 NEW)

set(CMAKE_INSTALL_RPATH "$ORIGIN/lib")

add_subdirectory(${FLUTTER_ROOT})

set(BUILD_DIR "${CMAKE_BINARY_DIR}")
set(FLUTTER_LIBRARY "${FLUTTER_ROOT}/bin/flutter_windows.dll")
set(FLUTTER_LIBRARY_RENDERER "${FLUTTER_ROOT}/bin/flutter_windows.dll")

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${BUILD_DIR}/runner")

add_library(${BINARY_NAME} SHARED
  "${FLUTTER_ROOT}/cpp/client_wrapper/flutter_engine_method_channel.cc"
  "${FLUTTER_ROOT}/cpp/client_wrapper/plugin_registry.cc"
  "flutter_window.cc"
  "main.cc"
)

if(NOT DEFINED FLUTTER_LIBRARY)
    set(FLUTTER_LIBRARY "${FLUTTER_ROOT}/bin/flutter_windows.dll")
endif()

if(NOT DEFINED FLUTTER_LIBRARY_RENDERER)
    set(FLUTTER_LIBRARY_RENDERER "${FLUTTER_ROOT}/bin/flutter_windows.dll")
endif()

add_dependencies(${BINARY_NAME} flutter_assemble)

set_target_properties(${BINARY_NAME} PROPERTIES
  RUNTIME_OUTPUT_DIRECTORY "${BUILD_DIR}/runner"
)

add_custom_command(TARGET ${BINARY_NAME} POST_BUILD
  COMMAND ${CMAKE_COMMAND} -E copy_if_different
    ${FLUTTER_LIBRARY}
    "${BUILD_DIR}/runner/"
  COMMAND ${CMAKE_COMMAND} -E copy_if_different
    ${FLUTTER_LIBRARY_RENDERER}
    "${BUILD_DIR}/runner/"
)
