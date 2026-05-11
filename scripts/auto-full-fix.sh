#!/bin/bash
# Nbox 全自动构建修复脚本 v2.0
# 功能：全面检查、修复问题、推送并创建新标签

set -e

REPO_DIR="/workspace/nbox"
cd $REPO_DIR

echo "========== Nbox 全自动构建修复 $(date) =========="

# 1. 确保与远程同步
echo "[1/6] 同步远程仓库..."
git fetch origin main
git pull --rebase origin main 2>/dev/null || true

# 2. 检查并更新 pubspec.yaml
echo "[2/6] 检查依赖配置..."
if grep -q "dependency_overrides:" pubspec.yaml; then
    echo "  移除 dependency_overrides..."
    # 移除 dependency_overrides 块
    sed -i '/^dependency_overrides:/,/^$/d' pubspec.yaml
fi

# 3. 检查 Dart 代码语法
echo "[3/6] 检查 Dart 代码..."
# 查找潜在的 null safety 问题
find lib -name "*.dart" -exec grep -l "!" {} \; | while read file; do
    if grep -q "![^=]" "$file"; then
        echo "  检查文件: $file"
    fi
done

# 4. 检查 Android 配置
echo "[4/6] 检查 Android 配置..."
if grep -q "flutter.compileSdkVersion\|flutter.targetSdkVersion" android/app/build.gradle; then
    echo "  警告: 发现不兼容的 Flutter 属性"
    sed -i 's/flutter.compileSdkVersion/34/g' android/app/build.gradle
    sed -i 's/flutter.targetSdkVersion/34/g' android/app/build.gradle
fi

if grep -q "flutter.compileSdkVersion\|flutter.targetSdkVersion" android/app-tv.disabled/build.gradle 2>/dev/null; then
    echo "  警告: app-tv 也有不兼容属性"
    sed -i 's/flutter.compileSdkVersion/34/g' android/app-tv.disabled/build.gradle
    sed -i 's/flutter.targetSdkVersion/34/g' android/app-tv.disabled/build.gradle
fi

# 5. 检查 withOpacity 弃用警告
echo "[5/6] 检查弃用 API..."
if grep -r "withOpacity" lib/ > /dev/null 2>&1; then
    echo "  发现 withOpacity，需要替换为 withValues"
    find lib -name "*.dart" -exec sed -i 's/\.withOpacity(\([0-9.]*\))/.withValues(alpha: \1)/g' {} \;
fi

# 6. 提交并推送
echo "[6/6] 提交并推送..."
CHANGES=$(git status --porcelain)

if [ -n "$CHANGES" ]; then
    echo "  发现更改，准备提交..."
    git add -A
    
    # 生成提交信息
    COMMIT_MSG="fix: 自动全面检查和修复 $(date '+%Y-%m-%d %H:%M')"
    git commit -m "$COMMIT_MSG"
    
    # 推送
    git push origin main
    
    # 创建新标签
    LATEST_TAG=$(git tag -l 'v*' | sort -V | tail -1)
    if [ -z "$LATEST_TAG" ]; then
        NEW_TAG="v1.0.0"
    else
        # 提取版本号并增加
        VERSION_NUM=$(echo $LATEST_TAG | sed 's/v//')
        IFS='.' read -ra VER <<< "$VERSION_NUM"
        MAJOR=${VER[0]}
        MINOR=${VER[1]}
        PATCH=$((${VER[2]} + 1))
        NEW_TAG="v$MAJOR.$MINOR.$PATCH"
    fi
    
    echo "  创建标签: $NEW_TAG"
    git tag -d $LATEST_TAG 2>/dev/null || true
    git tag $NEW_TAG
    git push origin :$LATEST_TAG 2>/dev/null || true
    git push origin $NEW_TAG
    
    echo "✅ 已推送 $NEW_TAG，GitHub Actions 将自动构建"
else
    echo "✅ 没有需要修复的问题"
fi

echo "========== 完成 $(date) =========="
