#include "win32_window.h"

#include <Windows.h>

#include <algorithm>

Win32Window::Win32Window() {}

Win32Window::~Win32Window() { Destroy(); }

bool Win32Window::CreateAndShow(const std::wstring& title, const Size& size) {
  Destroy();

  WNDCLASSEXW window_class;
  window_class.cbSize = sizeof(WNDCLASSEXW);
  window_class.style = CS_HREDRAW | CS_VREDRAW;
  window_class.lpfnWndProc = [](HWND hwnd, UINT msg, WPARAM wparam,
                                LPARAM lparam) -> LRESULT {
    if (msg == WM_NCCREATE) {
      auto window = reinterpret_cast<Win32Window*>(
          reinterpret_cast<CREATESTRUCT*>(lparam)->lpCreateParams);
      SetWindowLongPtr(hwnd, GWLP_USERDATA,
                       reinterpret_cast<LONG_PTR>(window));
      window->window_handle_ = hwnd;
    }
    return DefWindowProcW(hwnd, msg, wparam, lparam);
  };
  window_class.cbClsExtra = 0;
  window_class.cbWndExtra = 0;
  window_class.hInstance = GetModuleHandle(nullptr);
  window_class.hIcon = nullptr;
  window_class.hCursor = LoadCursor(nullptr, IDC_ARROW);
  window_class.hbrBackground = nullptr;
  window_class.lpszMenuName = nullptr;
  window_class.lpszClassName = L"NboxWindowClass";
  window_class.hIconSm = nullptr;

  RegisterClassExW(&window_class);

  int screen_width = GetSystemMetrics(SM_CXSCREEN);
  int screen_height = GetSystemMetrics(SM_CYSCREEN);

  window_handle_ = CreateWindowExW(
      0L, L"NboxWindowClass", title.c_str(),
      WS_CLIPSIBLINGS | WS_CLIPCHILDREN | WS_POPUP | WS_CAPTION | WS_SYSMENU,
      (screen_width - size.width) / 2, (screen_height - size.height) / 2,
      size.width, size.height, nullptr, nullptr,
      GetModuleHandle(nullptr), this);

  if (!window_handle_) {
    return false;
  }

  OnCreate();

  ShowWindow(window_handle_, SW_SHOW);
  UpdateWindow(window_handle_);

  return true;
}

void Win32Window::Destroy() {
  if (window_handle_) {
    DestroyWindow(window_handle_);
    window_handle_ = nullptr;
  }
}

void Win32Window::SetChildContent(HWND content) {
  if (!is_child_content_visible_) {
    ShowWindow(content, SW_SHOW);
    is_child_content_visible_ = true;
  }
}

RECT Win32Window::GetFrame() const {
  RECT frame;
  GetClientRect(window_handle_, &frame);
  return frame;
}

void Win32Window::SetTitle(const std::wstring& title) {
  SetWindowText(window_handle_, title.c_str());
}

LRESULT Win32Window::MessageHandler(HWND hwnd, UINT const message,
                                   WPARAM const wparam,
                                   LPARAM const lparam) noexcept {
  switch (message) {
    case WM_SIZE:
      return 0;
    case WM_DESTROY:
      OnDestroy();
      PostQuitMessage(0);
      return 0;
  }
  return DefWindowProc(window_handle_, message, wparam, lparam);
}

void Win32Window::OnCreate() {}

void Win32Window::OnDestroy() {}

void Win32Window::Activate() { SetFocus(window_handle_); }
