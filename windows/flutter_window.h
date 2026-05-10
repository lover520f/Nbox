#ifndef FLUTTER_WINDOW_H_
#define FLUTTER_WINDOW_H_

#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>

#include <memory>

#include "win32_window.h"

class FlutterWindow : public Win32Window {
 public:
  FlutterWindow(const flutter::DartProject& project);
  virtual ~FlutterWindow();

  bool OnCreate();
  void OnDestroy();

 private:
  flutter::DartProject project_;
};

int RunApplication(FlutterWindow* window);

#endif  // FLUTTER_WINDOW_H_
