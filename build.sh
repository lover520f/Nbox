#!/bin/bash

# Nbox 构建脚本 - v1.0.0
# 用法: ./build.sh [android|windows|all]

set -e

VERSION="1.0.0"
OUTPUT_DIR="releases"

mkdir -p "$OUTPUT_DIR"

echo "=========================================="
echo "  Nbox 牛盒 构建脚本 v${VERSION}"
echo "=========================================="

# 检查 Flutter
if ! command -v flutter &> /dev/null; then
    echo "错误: 未找到 Flutter，请先安装 Flutter SDK"
    exit 1
fi

# 获取 Flutter 版本
FLUTTER_VERSION=$(flutter --version | head -1)
echo "Flutter: $FLUTTER_VERSION"

# 进入项目目录
cd "$(dirname "$0")"

# 构建目标
TARGET=${1:-all}

build_android() {
    echo ""
    echo ">>> 构建 Android 版本..."
    
    flutter pub get
    
    # Android 手机版
    echo "构建 Android APK..."
    flutter build apk --release -o "$OUTPUT_DIR/nbox-${VERSION}.apk"
    echo "✓ Android APK: $OUTPUT_DIR/nbox-${VERSION}.apk"
    
    # Android TV 版
    echo "构建 Android TV APK..."
    flutter build apk --release -t lib/main.dart -o "$OUTPUT_DIR/nbox-tv-${VERSION}.apk"
    echo "✓ Android TV APK: $OUTPUT_DIR/nbox-tv-${VERSION}.apk"
}

build_windows() {
    echo ""
    echo ">>> 构建 Windows 版本..."
    
    flutter pub get
    
    # Windows 版
    flutter build windows --release -o "$OUTPUT_DIR"
    
    # 重命名输出
    if [ -f "$OUTPUT_DIR/runner/nbox.exe" ]; then
        mv "$OUTPUT_DIR/runner/nbox.exe" "$OUTPUT_DIR/nbox-${VERSION}.exe"
        echo "✓ Windows EXE: $OUTPUT_DIR/nbox-${VERSION}.exe"
    fi
    
    # 打包为 zip
    cd "$OUTPUT_DIR"
    zip -r "nbox-windows-${VERSION}.zip" runner/ 2>/dev/null || true
    cd - > /dev/null
    echo "✓ Windows ZIP: $OUTPUT_DIR/nbox-windows-${VERSION}.zip"
}

case "$TARGET" in
    android)
        build_android
        ;;
    windows)
        build_windows
        ;;
    all)
        build_android
        build_windows
        ;;
    *)
        echo "用法: $0 [android|windows|all]"
        exit 1
        ;;
esac

echo ""
echo "=========================================="
echo "  构建完成!"
echo "  输出目录: $OUTPUT_DIR"
echo "=========================================="
ls -lh "$OUTPUT_DIR"
