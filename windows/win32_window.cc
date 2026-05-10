#include "win32_window.h"

#include <Windows.h>

#include <algorithm>

namespace {
const wchar_t kWindowClassName[] = L"NboxWindowClass";
}

Win32Window::Win32Window() {}

Win32Window::~Win32Window() { Destroy(); }

bool Win32Window::CreateAndShow(const std::wstring& title, const Size& size) {
  Destroy();

  if (!RegisterWindowClass()) {
    return false;
  }

  int screen_width = GetSystemMetrics(SM_CXSCREEN);
  int screen_height = GetSystemMetrics(SM_CYSCREEN);

  window_handle_ = CreateWindowExW(
      0L, kWindowClassName, title.c_str(),
      WS_CLIPSIBLINGS | WS_CLIPCHILDREN | WS_OVERLAPPEDWINDOW,
      (screen_width - size.width) / 2, (screen_height - size.height) / 2,
      size.width, size.height, nullptr, nullptr,
      GetModuleHandle(nullptr), this);

  if (!window_handle_) {
    return false;
  }

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

LRESULT CALLBACK Win32Window::WndProc(HWND hwnd, UINT message, WPARAM wparam,
                                       LPARAM lparam) {
  Win32Window* window = nullptr;
  if (message == WM_NCCREATE) {
    CREATESTRUCT* create_struct = reinterpret_cast<CREATESTRUCT*>(lparam);
    window = static_cast<Win32Window*>(create_struct->lpCreateParams);
    SetWindowLongPtr(hwnd, GWLP_USERDATA, reinterpret_cast<LONG_PTR>(window));
  } else {
    window = reinterpret_cast<Win32Window*>(GetWindowLongPtr(hwnd, GWLP_USERDATA));
  }

  if (window) {
    return window->MessageHandler(hwnd, message, wparam, lparam);
  }
  return DefWindowProc(hwnd, message, wparam, lparam);
}

LRESULT Win32Window::MessageHandler(HWND hwnd, UINT const message,
                                   WPARAM const wparam,
                                   LPARAM const lparam) noexcept {
  switch (message) {
    case WM_CREATE:
      OnCreate();
      return 0;
    case WM_DESTROY:
      OnDestroy();
      PostQuitMessage(0);
      return 0;
    case WM_SIZE: {
      RECT rect;
      GetClientRect(hwnd, &rect);
      if (flutter_controller_) {
        flutter_controller_->SetSize(rect.right - rect.left, rect.bottom - rect.top);
      }
      return 0;
    }
    default:
      break;
  }
  return DefWindowProc(hwnd, message, wparam, lparam);
}

void Win32Window::OnCreate() {}

void Win32Window::OnDestroy() {}

void Win32Window::Activate() { SetFocus(window_handle_); }

bool Win32Window::RegisterWindowClass() {
  static bool class_registered = false;
  if (class_registered) {
    return true;
  }

  WNDCLASSEXW window_class = {};
  window_class.cbSize = sizeof(WNDCLASSEXW);
  window_class.style = CS_HREDRAW | CS_VREDRAW;
  window_class.lpfnWndProc = WndProc;
  window_class.hInstance = GetModuleHandle(nullptr);
  window_class.hCursor = LoadCursor(nullptr, IDC_ARROW);
  window_class.lpszClassName = kWindowClassName;

  if (RegisterClassExW(&window_class)) {
    class_registered = true;
    return true;
  }
  return false;
}
