#!/bin/zsh
set -euo pipefail
# Build and run the Treon app from Xcode project

echo "🔨 Building Treon app..."
xcodebuild -project Treon.xcodeproj -scheme Treon -configuration Debug -derivedDataPath build

echo "📦 Deploying Rust library to app bundle..."
APP_BUNDLE="build/Build/Products/Debug/Treon.app"
FRAMEWORKS_DIR="$APP_BUNDLE/Contents/Frameworks"
mkdir -p "$FRAMEWORKS_DIR"
cp rust_backend/target/release/libtreon_rust_backend.dylib "$FRAMEWORKS_DIR/"
echo "✅ Rust library deployed to: $FRAMEWORKS_DIR/libtreon_rust_backend.dylib"

echo "🚀 Launching Treon app..."
open "$APP_BUNDLE"

