#!/bin/bash
set -euo pipefail

# Build script for Treon C++ application
echo "Building Treon C++ application..."

# Check if Qt6 is available
if ! command -v qmake6 &> /dev/null; then
    echo "Error: Qt6 not found. Please install Qt6 development packages."
    echo "On macOS: brew install qt6"
    exit 1
fi

# Create build directory
mkdir -p build
cd build

# Configure with CMake
cmake .. -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Debug

# Build
cmake --build . --config Debug

echo "Build completed successfully!"
echo "Run tests with: ctest -C Debug"
echo "Run application with: ./treon_app"
