#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>

#include <iostream>
#include <memory>
#include <string>

#include "flutter_window.h"
#include "win32_window.h"

int APIENTRY wWinMain(_In_ const HINSTANCE instance, _In_opt_ HINSTANCE,
                     _In_ wchar_t* const command_line, _In_ const int show_command) {
  UNREFERENCED_PARAMETER(instance);
  UNREFERENCED_PARAMETER(command_line);

  flutter::DartProject project(L"data");
  
  std::vector<std::string> command_line_arguments =
      CommandLineToArgvW(GetCommandLineW(), nullptr);
  if (!command_line_arguments.empty()) {
    project.set_dart_entrypoint_arguments(
        std::vector<std::string>(command_line_arguments.begin() + 1,
                                 command_line_arguments.end()));
  }

  FlutterWindow window(project);
  Win32Window::Size size(1280, 720);

  if (!window.CreateAndShow(L"Nbox - 牛盒 v1.0.0", size)) {
    return EXIT_FAILURE;
  }

  window.SetTitle(L"Nbox - 牛盒 v1.0.0");

  return RunApplication(&window);
}
