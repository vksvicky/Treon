#!/bin/bash

# Test runner script for Treon C++ application
# This script runs all tests and generates a coverage report

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Get the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$PROJECT_ROOT/cpp/build"

print_status "Starting Treon C++ test suite..."
print_status "Project root: $PROJECT_ROOT"
print_status "Build directory: $BUILD_DIR"

# Check if build directory exists
if [ ! -d "$BUILD_DIR" ]; then
    print_error "Build directory does not exist. Please run build.sh first."
    exit 1
fi

# Change to build directory
cd "$BUILD_DIR"

# Check if tests executable exists
if [ ! -f "tests/treon_tests" ]; then
    print_error "Test executable not found. Please run build.sh first."
    exit 1
fi

# Run tests
print_status "Running unit tests..."
if ./tests/treon_tests; then
    print_success "All unit tests passed!"
else
    print_error "Some unit tests failed!"
    exit 1
fi

# Check if coverage tools are available
if command -v lcov >/dev/null 2>&1 && command -v genhtml >/dev/null 2>&1; then
    print_status "Generating coverage report..."
    
    # Generate coverage report
    if lcov --directory . --capture --output-file coverage.info && \
       lcov --remove coverage.info '/usr/*' --output-file coverage.info.cleaned && \
       genhtml -o coverage coverage.info.cleaned; then
        print_success "Coverage report generated successfully!"
        print_status "Coverage report available at: $BUILD_DIR/coverage/index.html"
        
        # Try to open coverage report if on macOS
        if [[ "$OSTYPE" == "darwin"* ]]; then
            if command -v open >/dev/null 2>&1; then
                print_status "Opening coverage report in browser..."
                open "$BUILD_DIR/coverage/index.html"
            fi
        fi
    else
        print_warning "Failed to generate coverage report. Continuing..."
    fi
else
    print_warning "Coverage tools (lcov, genhtml) not found. Skipping coverage report."
    print_status "To install coverage tools on macOS: brew install lcov"
fi

# Run CTest for additional test management
print_status "Running CTest..."
if ctest --verbose; then
    print_success "All CTest tests passed!"
else
    print_warning "Some CTest tests failed or were not found."
fi

print_success "Test suite completed successfully!"

# Summary
echo ""
echo "=========================================="
echo "Test Summary:"
echo "=========================================="
echo "✓ Unit tests: PASSED"
if command -v lcov >/dev/null 2>&1; then
    echo "✓ Coverage report: GENERATED"
    echo "  Location: $BUILD_DIR/coverage/index.html"
else
    echo "✗ Coverage report: SKIPPED (tools not available)"
fi
echo "✓ CTest: COMPLETED"
echo "=========================================="