#!/bin/bash
set -euo pipefail

# Deploy Rust library to app bundle
# This script is designed to be run as an Xcode build phase

echo "📦 Deploying Rust library to app bundle..."

# Get the app bundle path from Xcode environment variables
APP_BUNDLE="${BUILT_PRODUCTS_DIR}/${PRODUCT_NAME}.app"

if [ ! -d "$APP_BUNDLE" ]; then
    echo "❌ App bundle not found at: $APP_BUNDLE"
    exit 1
fi

# Create Frameworks directory if it doesn't exist
FRAMEWORKS_DIR="$APP_BUNDLE/Contents/Frameworks"
mkdir -p "$FRAMEWORKS_DIR"

# Check if Rust library exists (use SRCROOT for absolute path)
RUST_LIB="${SRCROOT}/rust_backend/target/release/libtreon_rust_backend.dylib"
if [ ! -f "$RUST_LIB" ]; then
    echo "❌ Rust library not found at: $RUST_LIB"
    echo "🔨 Building Rust backend..."
    cd "${SRCROOT}/rust_backend" && cargo build --release
    cd "${SRCROOT}"
fi

# Copy the Rust library to the app bundle
cp "$RUST_LIB" "$FRAMEWORKS_DIR/"

echo "✅ Rust library deployed to: $FRAMEWORKS_DIR/libtreon_rust_backend.dylib"

# Verify the library was copied
if [ -f "$FRAMEWORKS_DIR/libtreon_rust_backend.dylib" ]; then
    echo "✅ Verification: Rust library is present in app bundle"
else
    echo "❌ Verification failed: Rust library not found in app bundle"
    exit 1
fi
