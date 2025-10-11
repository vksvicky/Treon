#!/bin/bash

# Get the script directory and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CPP_DIR="$PROJECT_ROOT/cpp"

echo "Building Treon C++ application..."

# Change to cpp directory
cd "$CPP_DIR"

# Create app icon if it doesn't exist
if [ ! -f "resources/icon.icns" ]; then
    echo "Creating app icon..."
    cd resources && ./create_icon.sh && cd ..
fi

# Create build directory
mkdir -p build
cd build

# Configure with CMake
cmake -S .. -B . -DCMAKE_BUILD_TYPE=Debug

if [ $? -ne 0 ]; then
    echo "CMake configuration failed!"
    exit 1
fi

# Build
cmake --build . -j $(sysctl -n hw.ncpu)

if [ $? -ne 0 ]; then
    echo "Build failed!"
    exit 1
fi

echo "Build completed successfully!"
echo "Run tests with: ctest -C Debug"
echo "Run application with: ./Treon.app/Contents/MacOS/Treon"
