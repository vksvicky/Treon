#!/bin/zsh
set -euo pipefail

# Build script for Treon Rust Backend
# This script builds the Rust backend and prepares it for integration with the Swift app

echo "🚀 Building Treon Rust Backend..."

# Check if Rust is installed
if ! command -v cargo &> /dev/null; then
    echo "❌ Error: Rust/Cargo not found. Please install Rust from https://rustup.rs/"
    exit 1
fi

# Check Rust version
RUST_VERSION=$(cargo --version | cut -d' ' -f2)
echo "📦 Using Rust version: $RUST_VERSION"

# Navigate to rust backend directory
cd "$(dirname "$0")/../rust_backend"

# Clean previous builds
echo "🧹 Cleaning previous builds..."
cargo clean

# Build in release mode for performance
echo "🔨 Building Rust backend in release mode..."
cargo build --release

# Check if build was successful
if [ $? -eq 0 ]; then
    echo "✅ Rust backend built successfully!"
    
    # Show build artifacts
    echo "📁 Build artifacts:"
    ls -la target/release/
    
    # Show library size
    if [ -f "target/release/libtreon_rust_backend.a" ]; then
        LIB_SIZE=$(ls -lh target/release/libtreon_rust_backend.a | awk '{print $5}')
        echo "📊 Static library size: $LIB_SIZE"
    fi
    
    if [ -f "target/release/libtreon_rust_backend.dylib" ]; then
        DYLIB_SIZE=$(ls -lh target/release/libtreon_rust_backend.dylib | awk '{print $5}')
        echo "📊 Dynamic library size: $DYLIB_SIZE"
    fi
    
    echo ""
    echo "🎯 Next steps:"
    echo "1. The Rust backend is ready for integration"
    echo "2. Run 'make build' to build the complete Swift + Rust app"
    echo "3. Run 'make run-app' to test the hybrid implementation"
    
else
    echo "❌ Rust backend build failed!"
    exit 1
fi
