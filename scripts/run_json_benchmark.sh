#!/usr/bin/env bash
set -euo pipefail

# JSON Performance Benchmark Runner
# This script builds and runs the JSON performance benchmark suite

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="$PROJECT_ROOT/cpp/build"
BENCHMARK_EXECUTABLE="$BUILD_DIR/tests/json_benchmark_runner"

echo "🚀 Treon JSON Performance Benchmark Suite"
echo "=========================================="
echo "Project root: $PROJECT_ROOT"
echo "Build directory: $BUILD_DIR"
echo ""

# Check if build directory exists
if [ ! -d "$BUILD_DIR" ]; then
    echo "❌ Build directory not found. Please run build.sh first."
    exit 1
fi

# Build the benchmark executable
echo "🔨 Building JSON benchmark executable..."
cd "$BUILD_DIR"
make json_benchmark_runner

if [ ! -f "$BENCHMARK_EXECUTABLE" ]; then
    echo "❌ Failed to build benchmark executable"
    exit 1
fi


echo "✅ Benchmark executable built successfully"
echo ""

# Run the benchmark
echo "🏃 Running JSON performance benchmark..."
echo "This may take several minutes for large files..."
echo ""

"$BENCHMARK_EXECUTABLE"

echo ""
echo "✅ JSON performance benchmark completed!"
echo "📊 Check the Documents/TreonBenchmarks directory for detailed reports"
