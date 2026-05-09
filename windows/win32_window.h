#ifndef WIN32_WINDOW_H_
#define WIN32_WINDOW_H_

#include <Windows.h>
#include <windowsx.h>

#include <functional>
#include <memory>
#include <string>

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

  void SetTitle(const std::wstring& title);

 protected:
  virtual LRESULT MessageHandler(HWND hwnd, UINT const message,
                                 WPARAM const wparam,
                                 LPARAM const lparam) noexcept;

  virtual void OnCreate();
  virtual void OnDestroy();
  void Activate();

 private:
  bool RegisterWindowClass();

  HWND GetHandle() const { return window_handle_; }
  void HandleMessage(HWND hwnd, UINT const message, WPARAM const wparam,
                     LPARAM const lparam);

  HWND window_handle_ = nullptr;
  bool is_child_content_visible_ = false;
};

#endif  // WIN32_WINDOW_H_
