#!/bin/bash

# Script to enable/disable tests in CMakeLists.txt

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

CMAKELISTS_FILE="cpp/CMakeLists.txt"

# Function to show help
show_help() {
    cat << EOF
Treon Test Toggle Script

Usage: $0 [COMMAND]

Commands:
    enable     Enable tests in CMakeLists.txt
    disable    Disable tests in CMakeLists.txt
    status     Show current test status
    help       Show this help

Examples:
    $0 enable     # Enable tests
    $0 disable    # Disable tests
    $0 status     # Check current status

EOF
}

# Function to check current status
check_status() {
    if grep -q "# Tests (disabled for now)" "$CMAKELISTS_FILE"; then
        echo -e "${YELLOW}⚠️  Tests are currently DISABLED${NC}"
        return 1
    elif grep -q "enable_testing()" "$CMAKELISTS_FILE"; then
        echo -e "${GREEN}✅ Tests are currently ENABLED${NC}"
        return 0
    else
        echo -e "${RED}❌ Unknown test status${NC}"
        return 2
    fi
}

# Function to enable tests
enable_tests() {
    echo -e "${BLUE}🔧 Enabling tests...${NC}"
    
    # Replace disabled tests section with enabled tests section
    sed -i.bak 's|# Tests (disabled for now)|# Tests|g' "$CMAKELISTS_FILE"
    sed -i.bak 's|# enable_testing()|enable_testing()|g' "$CMAKELISTS_FILE"
    sed -i.bak 's|# add_subdirectory(tests)|add_subdirectory(tests)|g' "$CMAKELISTS_FILE"
    
    # Remove backup file
    rm -f "$CMAKELISTS_FILE.bak"
    
    echo -e "${GREEN}✅ Tests enabled successfully!${NC}"
    echo -e "${BLUE}💡 Run 'make clean && make build' to rebuild with tests${NC}"
}

# Function to disable tests
disable_tests() {
    echo -e "${BLUE}🔧 Disabling tests...${NC}"
    
    # Replace enabled tests section with disabled tests section
    sed -i.bak 's|# Tests|# Tests (disabled for now)|g' "$CMAKELISTS_FILE"
    sed -i.bak 's|^enable_testing()|# enable_testing()|g' "$CMAKELISTS_FILE"
    sed -i.bak 's|^add_subdirectory(tests)|# add_subdirectory(tests)|g' "$CMAKELISTS_FILE"
    
    # Remove backup file
    rm -f "$CMAKELISTS_FILE.bak"
    
    echo -e "${GREEN}✅ Tests disabled successfully!${NC}"
    echo -e "${BLUE}💡 Run 'make clean && make build' to rebuild without tests${NC}"
}

# Parse command line arguments
case "${1:-status}" in
    enable)
        enable_tests
        ;;
    disable)
        disable_tests
        ;;
    status)
        check_status
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo -e "${RED}❌ Unknown command: $1${NC}"
        echo "Run '$0 help' for available commands"
        exit 1
        ;;
esac
