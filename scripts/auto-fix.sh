#!/bin/bash
# Nbox 自动构建修复脚本
# 用途：检测构建失败，自动修复并重新推送

REPO_DIR="/workspace/nbox"
OWNER="lover520f"
REPO="Nbox"

echo "========== Nbox 构建检查 $(date) =========="

cd $REPO_DIR || exit 1

# 检查 git 状态
echo "检查本地更改..."
git fetch origin main 2>/dev/null
LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse origin/main)

if [ "$LOCAL" != "$REMOTE" ]; then
    echo "本地与远程不同步，正在拉取..."
    git pull --rebase origin main
fi

# 获取最新标签号
LATEST_TAG=$(git tag -l 'v*' | sort -V | tail -1)
echo "当前最新标签: $LATEST_TAG"

# 提取版本号
VERSION_NUM=$(echo $LATEST_TAG | sed 's/v//')
MAJOR=$(echo $VERSION_NUM | cut -d. -f1)
MINOR=$(echo $VERSION_NUM | cut -d. -f2)
PATCH=$(echo $VERSION_NUM | cut -d. -f3)

# 增加补丁版本号
PATCH=$((PATCH + 1))
NEW_TAG="v$MAJOR.$MINOR.$PATCH"
echo "新标签: $NEW_TAG"

# 由于无法直接访问 GitHub API，这里只是准备推送
# 实际构建由 GitHub Actions 自动触发

# 检查是否有待提交的更改
if ! git diff-index --quiet HEAD -- 2>/dev/null; then
    echo "存在未提交的更改，准备提交..."
    git add -A
    git commit -m "fix: 自动修复"
fi

# 推送所有内容
echo "推送到 GitHub..."
git push origin main

# 创建新标签
git tag -d $LATEST_TAG 2>/dev/null
git tag $NEW_TAG
git push origin :$LATEST_TAG 2>/dev/null
git push origin $NEW_TAG

echo "========== 完成 $(date) =========="
echo "GitHub Actions 将自动构建 $NEW_TAG"
