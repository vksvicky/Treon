#!/bin/bash
set -euo pipefail

# Treon Application Runner Script
# Usage: ./scripts/run_app.sh [debug|release|help]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
BUILD_DIR="$PROJECT_ROOT/cpp/build"
APP_NAME="treon_app"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default mode
MODE="debug"

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

# Function to show help
show_help() {
    cat << EOF
Treon Application Runner

Usage: $0 [MODE]

Modes:
    debug     Run in debug mode (default)
    release   Run in release mode
    help      Show this help message

Examples:
    $0                # Run in debug mode
    $0 debug          # Run in debug mode
    $0 release        # Run in release mode

Environment Variables:
    QT_LOGGING_RULES  Qt logging configuration
    QT_QPA_PLATFORM  Qt platform plugin
    QML_DISABLE_OPTIMIZER  Disable QML optimizations

Debug Options:
    --verbose         Enable verbose output
    --gdb             Run with GDB debugger
    --valgrind        Run with Valgrind memory checker
    --profile         Enable Qt profiling

EOF
}

# Function to check dependencies
check_dependencies() {
    print_status "Checking dependencies..."
    
    # Check if Qt6 is available
    if ! command -v qmake6 &> /dev/null; then
        print_error "Qt6 not found. Please install Qt6:"
        echo "  macOS: brew install qt6"
        echo "  Ubuntu: sudo apt install qt6-base-dev qt6-declarative-dev"
        echo "  Windows: Download from https://www.qt.io/download"
        exit 1
    fi
    
    # Check if CMake is available
    if ! command -v cmake &> /dev/null; then
        print_error "CMake not found. Please install CMake:"
        echo "  macOS: brew install cmake"
        echo "  Ubuntu: sudo apt install cmake"
        echo "  Windows: Download from https://cmake.org/download/"
        exit 1
    fi
    
    print_success "Dependencies check passed"
}

# Function to build the application
build_app() {
    local build_mode="$1"
    print_status "Building application in $build_mode mode..."
    
    cd "$PROJECT_ROOT"
    
    # Create build directory if it doesn't exist
    mkdir -p "$BUILD_DIR"
    cd "$BUILD_DIR"
    
    # Configure with CMake
    local cmake_args=("-DCMAKE_BUILD_TYPE=$build_mode")
    
    # Add debug-specific options
    if [ "$build_mode" = "Debug" ]; then
        cmake_args+=("-DCMAKE_CXX_FLAGS_DEBUG=-g -O0")
        cmake_args+=("-DCMAKE_EXPORT_COMPILE_COMMANDS=ON")
    fi
    
    cmake "${cmake_args[@]}" ..
    
    # Build
    local make_args=()
    if [ "$build_mode" = "Debug" ]; then
        make_args+=("VERBOSE=1")
    fi
    
    cmake --build . --config "$build_mode" "${make_args[@]}"
    
    print_success "Build completed successfully"
}

# Function to check if app exists
check_app_exists() {
    local app_path="$BUILD_DIR/$APP_NAME"
    if [ ! -f "$app_path" ]; then
        print_error "Application not found at $app_path"
        print_status "Building application first..."
        build_app "$MODE"
    fi
}

# Function to setup environment
setup_environment() {
    local build_mode="$1"
    
    # Set Qt environment variables
    export QT_LOGGING_RULES="*.debug=true;qt.qpa.*=false"
    
    # Platform-specific setup
    case "$(uname -s)" in
        Darwin*)
            # macOS
            export QT_QPA_PLATFORM="cocoa"
            ;;
        Linux*)
            # Linux
            export QT_QPA_PLATFORM="xcb"
            ;;
        CYGWIN*|MINGW32*|MSYS*|MINGW*)
            # Windows
            export QT_QPA_PLATFORM="windows"
            ;;
    esac
    
    # Debug-specific environment
    if [ "$build_mode" = "Debug" ]; then
        export QML_DISABLE_OPTIMIZER=1
        export QT_LOGGING_RULES="*.debug=true;*.info=true"
    fi
    
    print_status "Environment configured for $build_mode mode"
}

# Function to run the application
run_app() {
    local build_mode="$1"
    local app_path="$BUILD_DIR/$APP_NAME"
    
    print_status "Starting Treon application..."
    print_status "Mode: $build_mode"
    print_status "Executable: $app_path"
    
    # Change to build directory for proper working directory
    cd "$BUILD_DIR"
    
    # Run the application
    if [ "$build_mode" = "Debug" ]; then
        print_status "Running in debug mode with enhanced logging"
        "$app_path" "$@"
    else
        print_status "Running in release mode"
        "$app_path" "$@"
    fi
}

# Function to run with GDB
run_with_gdb() {
    local app_path="$BUILD_DIR/$APP_NAME"
    
    if ! command -v gdb &> /dev/null; then
        print_error "GDB not found. Please install GDB for debugging."
        exit 1
    fi
    
    print_status "Starting Treon with GDB debugger..."
    cd "$BUILD_DIR"
    gdb --args "$app_path" "$@"
}

# Function to run with Valgrind
run_with_valgrind() {
    local app_path="$BUILD_DIR/$APP_NAME"
    
    if ! command -v valgrind &> /dev/null; then
        print_error "Valgrind not found. Please install Valgrind for memory checking."
        exit 1
    fi
    
    print_status "Starting Treon with Valgrind memory checker..."
    cd "$BUILD_DIR"
    valgrind --tool=memcheck --leak-check=full --show-leak-kinds=all "$app_path" "$@"
}

# Function to run with profiling
run_with_profiling() {
    local app_path="$BUILD_DIR/$APP_NAME"
    
    print_status "Starting Treon with Qt profiling enabled..."
    export QT_LOGGING_RULES="*.debug=true;qt.qpa.*=false"
    export QML_DISABLE_OPTIMIZER=1
    
    cd "$BUILD_DIR"
    "$app_path" "$@"
}

# Parse command line arguments
VERBOSE=false
DEBUGGER=""
PROFILING=false

while [[ $# -gt 0 ]]; do
    case $1 in
        debug|Debug|DEBUG)
            MODE="Debug"
            shift
            ;;
        release|Release|RELEASE)
            MODE="Release"
            shift
            ;;
        help|--help|-h)
            show_help
            exit 0
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        --gdb)
            DEBUGGER="gdb"
            shift
            ;;
        --valgrind)
            DEBUGGER="valgrind"
            shift
            ;;
        --profile)
            PROFILING=true
            shift
            ;;
        *)
            # Pass remaining arguments to the application
            break
            ;;
    esac
done

# Main execution
main() {
    print_status "Treon Application Runner"
    print_status "Mode: $MODE"
    
    # Check dependencies
    check_dependencies
    
    # Setup environment
    setup_environment "$MODE"
    
    # Check if app exists, build if necessary
    check_app_exists
    
    # Run the application with appropriate options
    if [ "$PROFILING" = true ]; then
        run_with_profiling "$@"
    elif [ "$DEBUGGER" = "gdb" ]; then
        run_with_gdb "$@"
    elif [ "$DEBUGGER" = "valgrind" ]; then
        run_with_valgrind "$@"
    else
        run_app "$MODE" "$@"
    fi
    
    print_success "Application finished"
}

# Run main function
main "$@"