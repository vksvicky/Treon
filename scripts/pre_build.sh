#!/bin/bash
set -euo pipefail

# Pre-build script to ensure Rust library is ready and deployed
# Run this before building in Xcode to avoid the "Failed to process data with Rust backend" error

echo "🔨 Pre-build setup for Treon..."

# Build Rust backend if needed
if [ ! -f "rust_backend/target/release/libtreon_rust_backend.dylib" ]; then
    echo "🔨 Building Rust backend..."
    cd rust_backend && cargo build --release
    cd ..
    echo "✅ Rust backend built"
else
    echo "✅ Rust backend already built"
fi

# Deploy Rust library to app bundle
echo "📦 Deploying Rust library to app bundle..."

# Find ALL app bundles in DerivedData
APP_BUNDLES=$(find ~/Library/Developer/Xcode/DerivedData -name "Treon.app" -path "*/Build/Products/Debug/*")

if [ -z "$APP_BUNDLES" ]; then
    echo "⚠️  No app bundles found. Please build the project in Xcode first, then run this script."
    echo "📋 Pre-build setup complete (Rust library ready for deployment)!"
    exit 0
fi

# Deploy to all found app bundles
echo "📱 Found app bundles:"
echo "$APP_BUNDLES"
echo ""

DEPLOYED_COUNT=0
for APP_BUNDLE in $APP_BUNDLES; do
    echo "📦 Deploying to: $APP_BUNDLE"
    
    # Create Frameworks directory and copy library
    FRAMEWORKS_DIR="$APP_BUNDLE/Contents/Frameworks"
    mkdir -p "$FRAMEWORKS_DIR"
    cp rust_backend/target/release/libtreon_rust_backend.dylib "$FRAMEWORKS_DIR/"
    
    # Verify the library was copied
    if [ -f "$FRAMEWORKS_DIR/libtreon_rust_backend.dylib" ]; then
        echo "✅ Rust library deployed to: $FRAMEWORKS_DIR/libtreon_rust_backend.dylib"
        DEPLOYED_COUNT=$((DEPLOYED_COUNT + 1))
    else
        echo "❌ Failed to deploy to: $APP_BUNDLE"
    fi
    echo ""
done

echo "📊 Deployed to $DEPLOYED_COUNT app bundle(s)"

echo "📋 Pre-build setup complete!"
echo ""
echo "✅ You can now run the app in Xcode without the Rust backend error."
