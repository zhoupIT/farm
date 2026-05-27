#!/bin/zsh
set -e

# 这个脚本负责把 Swift 源代码编译成真正可以双击打开的 .app。
# 使用方式：
#   cd 到项目目录后运行：zsh scripts/build_app.sh

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_DIR="$PROJECT_DIR/.build/direct-release"
APP_DIR="$PROJECT_DIR/王者农场小助手.app"
EXECUTABLE="$BUILD_DIR/WangZheFarmAssistant"

rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# 这里直接调用 swiftc，而不是依赖 Swift Package Manager。
# 原因：有些只安装 Command Line Tools 的 Mac，SwiftPM 的 Manifest API
# 会和系统 SDK 小版本不一致；swiftc 直接编译源文件更稳。
swiftc \
  -O \
  -parse-as-library \
  -target arm64-apple-macosx14.0 \
  "$PROJECT_DIR/Sources/WangZheFarmAssistantApp/"*.swift \
  -o "$EXECUTABLE"

rm -rf "$APP_DIR"
mkdir -p "$APP_DIR/Contents/MacOS"
mkdir -p "$APP_DIR/Contents/Resources"

cp "$PROJECT_DIR/AppBundle/Info.plist" "$APP_DIR/Contents/Info.plist"
cp "$EXECUTABLE" "$APP_DIR/Contents/MacOS/WangZheFarmAssistant"
cp -R "$PROJECT_DIR/Sources/WangZheFarmAssistantApp/Resources/"* "$APP_DIR/Contents/Resources/"
chmod +x "$APP_DIR/Contents/MacOS/WangZheFarmAssistant"

echo "已生成：$APP_DIR"
