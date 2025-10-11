#!/usr/bin/env bash
set -euo pipefail

# JSON Test Configuration Script
# This script allows users to configure which JSON test sizes to run

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_FILE="$PROJECT_ROOT/cpp/tests/json_test_config.json"

echo "🔧 Treon JSON Test Configuration"
echo "================================="
echo ""

# Function to show current configuration
show_config() {
    echo "📋 Current Test Configuration:"
    echo ""
    
    if [ -f "$CONFIG_FILE" ]; then
        echo "Test Sizes:"
        jq -r '.testSizes | to_entries[] | "  \(.key): \(.value.label) (\(.value.sizeBytes | . / 1024 | floor)KB) - \(if .value.enabled then "ENABLED" else "DISABLED" end)"' "$CONFIG_FILE" 2>/dev/null || echo "  Error reading config file"
        echo ""
        echo "Performance Thresholds:"
        jq -r '.performanceThresholds | to_entries[] | "  \(.key): \(.value)ms"' "$CONFIG_FILE" 2>/dev/null || echo "  Error reading config file"
    else
        echo "  No configuration file found at: $CONFIG_FILE"
    fi
    echo ""
}

# Function to enable/disable test sizes
toggle_test_size() {
    local size_name="$1"
    local action="$2"
    
    if [ -f "$CONFIG_FILE" ]; then
        if [ "$action" = "enable" ]; then
            jq ".testSizes.\"$size_name\".enabled = true" "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
            echo "✅ Enabled $size_name test"
        elif [ "$action" = "disable" ]; then
            jq ".testSizes.\"$size_name\".enabled = false" "$CONFIG_FILE" > "$CONFIG_FILE.tmp" && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
            echo "✅ Disabled $size_name test"
        fi
    else
        echo "❌ Configuration file not found"
    fi
}

# Function to run quick tests (small files only)
run_quick_tests() {
    echo "🚀 Running Quick JSON Tests (10KB - 1MB only)"
    echo ""
    
    # Enable only small tests
    toggle_test_size "10kb" "enable"
    toggle_test_size "35kb" "enable"
    toggle_test_size "50kb" "enable"
    toggle_test_size "1mb" "enable"
    
    # Disable large tests
    toggle_test_size "5mb" "disable"
    toggle_test_size "25mb" "disable"
    toggle_test_size "50mb" "disable"
    toggle_test_size "100mb" "disable"
    toggle_test_size "500mb" "disable"
    toggle_test_size "1gb" "disable"
    
    echo ""
    echo "Running tests..."
    "$PROJECT_ROOT/scripts/run_json_benchmark.sh"
}

# Function to run full tests (all enabled sizes)
run_full_tests() {
    echo "🚀 Running Full JSON Tests (all enabled sizes)"
    echo ""
    
    # Enable all tests
    for size in 10kb 35kb 50kb 1mb 5mb 25mb 50mb 100mb 500mb 1gb; do
        toggle_test_size "$size" "enable"
    done
    
    echo ""
    echo "Running tests..."
    "$PROJECT_ROOT/scripts/run_json_benchmark.sh"
}

# Function to run stress tests (large files only)
run_stress_tests() {
    echo "🚀 Running Stress JSON Tests (large files only)"
    echo ""
    
    # Disable small tests
    toggle_test_size "10kb" "disable"
    toggle_test_size "35kb" "disable"
    toggle_test_size "50kb" "disable"
    toggle_test_size "1mb" "disable"
    
    # Enable large tests
    toggle_test_size "5mb" "enable"
    toggle_test_size "25mb" "enable"
    toggle_test_size "50mb" "enable"
    toggle_test_size "100mb" "enable"
    
    # Ask about very large tests
    echo "⚠️  Very large tests (500MB, 1GB) are disabled by default."
    read -p "Enable very large tests? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        toggle_test_size "500mb" "enable"
        toggle_test_size "1gb" "enable"
        echo "⚠️  Very large tests enabled. This may take a very long time!"
    fi
    
    echo ""
    echo "Running stress tests..."
    "$PROJECT_ROOT/scripts/run_json_benchmark.sh"
}

# Main menu
show_config

echo "What would you like to do?"
echo "1) Show current configuration"
echo "2) Run quick tests (10KB - 1MB)"
echo "3) Run full tests (all sizes)"
echo "4) Run stress tests (large files)"
echo "5) Enable/disable specific test size"
echo "6) Exit"
echo ""

read -p "Enter your choice (1-6): " -n 1 -r
echo ""

case $REPLY in
    1)
        show_config
        ;;
    2)
        run_quick_tests
        ;;
    3)
        run_full_tests
        ;;
    4)
        run_stress_tests
        ;;
    5)
        echo "Available test sizes:"
        jq -r '.testSizes | keys[]' "$CONFIG_FILE" 2>/dev/null || echo "Error reading config"
        echo ""
        read -p "Enter test size name: " size_name
        echo "1) Enable"
        echo "2) Disable"
        read -p "Enter action (1-2): " -n 1 -r
        echo ""
        case $REPLY in
            1) toggle_test_size "$size_name" "enable" ;;
            2) toggle_test_size "$size_name" "disable" ;;
            *) echo "Invalid choice" ;;
        esac
        ;;
    6)
        echo "Goodbye!"
        exit 0
        ;;
    *)
        echo "Invalid choice"
        exit 1
        ;;
esac
