#!/bin/bash
# Nbox 自动构建修复脚本 v3.0
# 注意：不要自动替换 withOpacity/withValues，因为 Flutter 3.22 只支持 withOpacity

set -e

REPO_DIR="/workspace/nbox"
cd $REPO_DIR

echo "========== Nbox 全自动构建修复 $(date) =========="

# 1. 确保与远程同步
echo "[1/4] 同步远程仓库..."
git fetch origin main
git pull --rebase origin main 2>/dev/null || true

# 2. 检查 Android 配置
echo "[2/4] 检查 Android 配置..."
if grep -q "flutter.compileSdkVersion\|flutter.targetSdkVersion" android/app/build.gradle 2>/dev/null; then
    echo "  修复: 替换不兼容的 Flutter 属性"
    sed -i 's/flutter.compileSdkVersion/34/g' android/app/build.gradle
    sed -i 's/flutter.targetSdkVersion/34/g' android/app/build.gradle
fi

# 3. 检查是否有破坏性的 API 使用
echo "[3/4] 检查 API 兼容性..."
# 注意：不要替换 withOpacity，Flutter 3.22 不支持 withValues
# 检查是否有 withValues（不应该有）
WITH_VALUES=$(grep -r "withValues" lib/ --include="*.dart" -c 2>/dev/null || echo "0")
if [ "$WITH_VALUES" != "0" ]; then
    echo "  警告: 发现 withValues，替换为 withOpacity"
    find lib -name "*.dart" -exec sed -i 's/\.withValues(alpha: \([0-9.]*\))/.withOpacity(\1)/g' {} \;
fi

# 4. 提交并推送
echo "[4/4] 提交并推送..."
CHANGES=$(git status --porcelain)

if [ -n "$CHANGES" ]; then
    echo "  发现更改，准备提交..."
    git add -A
    COMMIT_MSG="fix: 自动修复 $(date '+%Y-%m-%d %H:%M')"
    git commit -m "$COMMIT_MSG"
    git push origin main

    LATEST_TAG=$(git tag -l 'v*' | sort -V | tail -1)
    if [ -z "$LATEST_TAG" ]; then
        NEW_TAG="v1.0.0"
    else
        VERSION_NUM=$(echo $LATEST_TAG | sed 's/v//')
        IFS='.' read -ra VER <<< "$VERSION_NUM"
        MAJOR=${VER[0]}
        MINOR=${VER[1]}
        PATCH=$((${VER[2]} + 1))
        NEW_TAG="v$MAJOR.$MINOR.$PATCH"
    fi

    echo "  创建标签: $NEW_TAG"
    git tag $NEW_TAG
    git push origin $NEW_TAG

    echo "✅ 已推送 $NEW_TAG"
else
    echo "✅ 没有需要修复的问题"
fi

echo "========== 完成 $(date) =========="
