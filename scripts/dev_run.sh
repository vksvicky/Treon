#!/bin/bash
set -euo pipefail

# Treon Development Runner Script
# Quick development script with hot reload and debugging features

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[DEV]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to show help
show_help() {
    cat << EOF
Treon Development Runner

Usage: $0 [COMMAND] [OPTIONS]

Commands:
    run         Run the application (default)
    build       Build the application
    test        Run tests
    clean       Clean build artifacts
    watch       Watch for changes and rebuild
    debug       Run with debugger
    profile     Run with profiling
    help        Show this help

Options:
    --verbose   Enable verbose output
    --no-build  Skip building (assume already built)
    --fast      Fast build (skip tests)

Examples:
    $0                    # Run application
    $0 build              # Build only
    $0 test               # Run tests
    $0 watch              # Watch mode
    $0 debug              # Debug mode
    $0 run --no-build     # Run without building

EOF
}

# Function to build with development settings
dev_build() {
    local fast_build="${1:-false}"
    
    print_status "Building for development..."
    
    cd "$PROJECT_ROOT"
    
    # Create build directory
    mkdir -p cpp/build
    cd cpp/build
    
    # Configure for development
    cmake -DCMAKE_BUILD_TYPE=Debug \
          -DCMAKE_CXX_FLAGS_DEBUG="-g -O0 -Wall -Wextra" \
          -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
          ..
    
    # Build
    if [ "$fast_build" = "true" ]; then
        print_status "Fast build (skipping tests)..."
        cmake --build . --config Debug --target Treon
    else
        print_status "Full build with tests..."
        cmake --build . --config Debug
    fi
    
    print_success "Build completed"
}

# Function to run tests
run_tests() {
    print_status "Running tests..."
    
    cd "$PROJECT_ROOT/cpp/build"
    
    if [ ! -f "tests" ]; then
        print_error "Tests not found. Building first..."
        dev_build false
    fi
    
    ctest -C Debug --output-on-failure --verbose
    print_success "Tests completed"
}

# Function to clean build artifacts
clean_build() {
    print_status "Cleaning build artifacts..."
    
    cd "$PROJECT_ROOT"
    rm -rf cpp/build/
    rm -rf build/
    
    print_success "Clean completed"
}

# Function to run the application
run_app() {
    local no_build="${1:-false}"
    
    if [ "$no_build" = "false" ]; then
        dev_build true
    fi
    
    print_status "Starting Treon application..."
    
    cd "$PROJECT_ROOT/cpp/build"
    
    # Set development environment
    if [ "$VERBOSE" = true ]; then
        export QT_LOGGING_RULES="*.debug=true;*.info=true;*.warning=true;*.critical=true"
        print_status "Verbose logging enabled"
    else
        export QT_LOGGING_RULES="*.debug=false;*.info=false;*.warning=true;*.critical=true"
    fi
    export QML_DISABLE_OPTIMIZER=1
    export QT_QPA_PLATFORM="cocoa"  # macOS default
    
    ./Treon.app/Contents/MacOS/Treon
}

# Function to watch for changes
watch_mode() {
    print_status "Starting watch mode..."
    print_status "Watching for changes in cpp/ directory..."
    
    # Check if fswatch is available (macOS)
    if command -v fswatch &> /dev/null; then
        print_status "Using fswatch for file monitoring..."
        fswatch -o cpp/ | while read; do
            print_status "Files changed, rebuilding..."
            dev_build true
            print_status "Rebuild complete. Press Ctrl+C to stop watching."
        done
    # Check if inotifywait is available (Linux)
    elif command -v inotifywait &> /dev/null; then
        print_status "Using inotifywait for file monitoring..."
        while inotifywait -r -e modify,create,delete cpp/; do
            print_status "Files changed, rebuilding..."
            dev_build true
            print_status "Rebuild complete. Press Ctrl+C to stop watching."
        done
    else
        print_error "No file watcher found. Please install:"
        echo "  macOS: brew install fswatch"
        echo "  Linux: sudo apt install inotify-tools"
        exit 1
    fi
}

# Function to run with debugger
debug_mode() {
    print_status "Starting debug mode..."
    
    dev_build true
    
    cd "$PROJECT_ROOT/cpp/build"
    
    # Set debug environment
    if [ "$VERBOSE" = true ]; then
        export QT_LOGGING_RULES="*.debug=true;*.info=true;*.warning=true;*.critical=true"
        print_status "Verbose logging enabled"
    else
        export QT_LOGGING_RULES="*.debug=false;*.info=false;*.warning=true;*.critical=true"
    fi
    export QML_DISABLE_OPTIMIZER=1
    
    if command -v lldb &> /dev/null; then
        print_status "Using LLDB debugger..."
        lldb ./Treon.app/Contents/MacOS/Treon
    elif command -v gdb &> /dev/null; then
        print_status "Using GDB debugger..."
        gdb ./Treon.app/Contents/MacOS/Treon
    else
        print_error "No debugger found. Please install:"
        echo "  macOS: Xcode Command Line Tools"
        echo "  Linux: sudo apt install gdb"
        exit 1
    fi
}

# Function to run with profiling
profile_mode() {
    print_status "Starting profile mode..."
    
    dev_build true
    
    cd "$PROJECT_ROOT/cpp/build"
    
    # Set profiling environment
    if [ "$VERBOSE" = true ]; then
        export QT_LOGGING_RULES="*.debug=true;*.info=true;*.warning=true;*.critical=true"
        print_status "Verbose logging enabled"
    else
        export QT_LOGGING_RULES="*.debug=false;*.info=false;*.warning=true;*.critical=true"
    fi
    export QML_DISABLE_OPTIMIZER=1
    export QT_PROFILER_TYPE=1
    
    print_status "Profiling enabled. Check Qt Creator or use QML profiler."
    ./Treon.app/Contents/MacOS/Treon
}

# Parse command line arguments
COMMAND="run"
NO_BUILD=false
FAST_BUILD=false
VERBOSE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        run|build|test|clean|watch|debug|profile|help)
            COMMAND="$1"
            shift
            ;;
        --no-build)
            NO_BUILD=true
            shift
            ;;
        --fast)
            FAST_BUILD=true
            shift
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        --help|-h)
            show_help
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Main execution
main() {
    print_status "Treon Development Runner"
    print_status "Command: $COMMAND"
    
    case $COMMAND in
        run)
            run_app $NO_BUILD
            ;;
        build)
            dev_build $FAST_BUILD
            ;;
        test)
            run_tests
            ;;
        clean)
            clean_build
            ;;
        watch)
            watch_mode
            ;;
        debug)
            debug_mode
            ;;
        profile)
            profile_mode
            ;;
        help)
            show_help
            ;;
        *)
            print_error "Unknown command: $COMMAND"
            show_help
            exit 1
            ;;
    esac
}

# Run main function
main
