cmake_minimum_required(VERSION 3.10)

project(nbox VERSION 1.0.0 LANGUAGES CXX)

set(BINARY_NAME "nbox")

cmake_policy(SET CMP0079 NEW)

set(CMAKE_INSTALL_RPATH "$ORIGIN/lib")

set(CMAKE_SYSTEM_PROCESSOR "x86_64")
if(CMAKE_SYSTEM_PROCESSOR MATCHES "(arm64|aarch64)")
    set(CMAKE_SYSTEM_PROCESSOR "aarch64")
endif()

set(FLUTTER_ROOT "$ENV{FLUTTER_ROOT}")
if(NOT FLUTTER_ROOT)
    set(FLUTTER_ROOT "$CMAKE_CURRENT_SOURCE_DIR/../../flutter")
endif()

set(FLUTTER_ENGINE_LIBRARY "${FLUTTER_ROOT}/bin/cache/artifacts/engine/windows-x64/libflutter.dll")
set(FLUTTER_LIBRARY "${FLUTTER_ROOT}/bin/cache/artifacts/engine/windows-x64/flutter_windows.dll")
set(FLUTTER_LIBRARY_RENDERER "${FLUTTER_ROOT}/bin/cache/artifacts/engine/windows-x64/flutter_windows.dll")
set(FLUTTER_LIBRARY_GL "${FLUTTER_ROOT}/bin/cache/artifacts/engine/windows-x64/flutter_windows.dll")

set(RUNTIME_LIBRARY_DIR "$<TARGET_FILE_DIR:nbox>")
set(RUNTIME_LIBRARY_DIR_DEBUG "$<TARGET_FILE_DIR:nbox>")

set(FLUTTER_LIBRARY "${FLUTTER_ROOT}/bin/flutter_windows.dll")
set(FLUTTER_LIBRARY_RENDERER "${FLUTTER_ROOT}/bin/flutter_windows.dll")
set(FLUTTER_LIBRARY_GL "${FLUTTER_ROOT}/bin/flutter_windows.dll")
set(RUNTIME_LIBRARY_DIR "$<TARGET_FILE_DIR:nbox>")
set(RUNTIME_LIBRARY_DIR_DEBUG "$<TARGET_FILE_DIR:nbox>")

set(FLUTTER_LIBRARY "${FLUTTER_ROOT}/bin/cache/artifacts/engine/windows-x64/libflutter.dll")
set(FLUTTER_LIBRARY_RENDERER "${FLUTTER_ROOT}/bin/cache/artifacts/engine/windows-x64/flutter_windows.dll")
set(FLUTTER_LIBRARY_GL "${FLUTTER_ROOT}/bin/flutter_windows.dll")

add_subdirectory(${FLUTTER_ROOT})

set(BUILD_ASSETS_DIR "${FLUTTER_ROOT}/build/assetSC")
set(FLUTTER_ASSET_DIR "${FLUTTER_ROOT}/build/ios/iphonesimulator/Assets")

set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/data/flutter_assets")
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin")

set(BUILD_OUTPUT_DIR "${CMAKE_CURRENT_SOURCE_DIR}/build/windows")

set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

if(CMAKE_BUILD_TYPE MATCHES "Debug")
    set(BUILD_DIR "${CMAKE_CURRENT_SOURCE_DIR}/build/windows")
    set(FLUTTER_LIBRARY "${BUILD_DIR}/artifacts/flutter_windows.dll")
    set(FLUTTER_LIBRARY_RENDERER "${BUILD_DIR}/artifacts/flutter_windows.dll")
    set(FLUTTER_LIBRARY_GL "${BUILD_DIR}/artifacts/flutter_windows.dll")
endif()

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

set(BINARY_NAME "nbox")
set(BUILD_DIR "${CMAKE_CURRENT_SOURCE_DIR}/build/windows")

if(NOT EXISTS "${FLUTTER_LIBRARY}")
    message(FATAL_ERROR "Flutter library not found at: ${FLUTTER_LIBRARY}")
endif()

set_target_properties(${BINARY_NAME} PROPERTIES
  RUNTIME_OUTPUT_DIRECTORY "${BUILD_DIR}/runner"
)

set(BINARY_OUTPUT "${BUILD_DIR}/runner/${BINARY_NAME}.exe")

add_custom_command(TARGET ${BINARY_NAME} POST_BUILD
  COMMAND ${CMAKE_COMMAND} -E copy_if_different
    ${FLUTTER_LIBRARY}
    "${BUILD_DIR}/runner/"
  COMMAND ${CMAKE_COMMAND} -E copy_if_different
    ${FLUTTER_LIBRARY_RENDERER}
    "${BUILD_DIR}/runner/"
)

if(NOT EXISTS "${FLUTTER_LIBRARY_GL}")
    set(FLUTTER_LIBRARY_GL "${FLUTTER_LIBRARY}")
endif()

add_custom_command(TARGET ${BINARY_NAME} POST_BUILD
  COMMAND ${CMAKE_COMMAND} -E copy_if_different
    ${FLUTTER_LIBRARY_GL}
    "${BUILD_DIR}/runner/"
)

set(BINARY_DIR "${BUILD_DIR}/runner")
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${BINARY_DIR}")
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_DEBUG "${BINARY_DIR}")
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_RELEASE "${BINARY_DIR}")
