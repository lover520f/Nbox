#ifndef WIN32_WINDOW_H_
#define WIN32_WINDOW_H_

#include <Windows.h>
#include <windowsx.h>

#include <functional>
#include <memory>
#include <string>

namespace flutter {
class FlutterViewController;
}

class Win32Window {
 public:
  struct Point {
    unsigned int x;
    unsigned int y;
    Point(unsigned int x, unsigned int y) : x(x), y(y) {}
  };

  struct Size {
    int width;
    int height;
    Size(int width, int height) : width(width), height(height) {}
  };

  Win32Window();
  virtual ~Win32Window();

  bool CreateAndShow(const std::wstring& title, const Size& size);

  virtual void SetChildContent(HWND content);
  virtual void Destroy();

  RECT GetFrame() const;
  HWND GetHandle() const { return window_handle_; }

  void SetTitle(const std::wstring& title);

 protected:
  static LRESULT CALLBACK WndProc(HWND hwnd, UINT message, WPARAM wparam,
                                 LPARAM lparam);
  virtual LRESULT MessageHandler(HWND hwnd, UINT const message,
                                 WPARAM const wparam,
                                 LPARAM const lparam) noexcept;

  virtual void OnCreate();
  virtual void OnDestroy();
  void Activate();

  std::unique_ptr<flutter::FlutterViewController> flutter_controller_;

 private:
  bool RegisterWindowClass();

  HWND window_handle_ = nullptr;
  bool is_child_content_visible_ = false;
};

#endif  // WIN32_WINDOW_H_
