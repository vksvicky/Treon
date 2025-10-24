#!/bin/bash

# Comprehensive File Size and Performance Tests
# Tests all file sizes from 1KB to 1GB with performance benchmarks

set -e

echo "🧪 COMPREHENSIVE FILE SIZE AND PERFORMANCE TESTS"
echo "================================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    local status=$1
    local message=$2
    case $status in
        "SUCCESS")
            echo -e "${GREEN}✅ $message${NC}"
            ;;
        "FAILURE")
            echo -e "${RED}❌ $message${NC}"
            ;;
        "WARNING")
            echo -e "${YELLOW}⚠️  $message${NC}"
            ;;
        "INFO")
            echo -e "${BLUE}📊 $message${NC}"
            ;;
    esac
}

# Function to run tests and capture results
run_test_suite() {
    local test_name=$1
    local test_class=$2
    local description=$3
    
    echo ""
    echo "🧪 Running $test_name..."
    echo "Description: $description"
    echo "----------------------------------------"
    
    local start_time=$(date +%s)
    
    if xcodebuild test -project Treon.xcodeproj -scheme Treon -destination 'platform=macOS' -only-testing:TreonTests/$test_class 2>&1 | tee /tmp/test_output.log; then
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        print_status "SUCCESS" "$test_name completed in ${duration}s"
        return 0
    else
        local end_time=$(date +%s)
        local duration=$((end_time - start_time))
        print_status "FAILURE" "$test_name failed after ${duration}s"
        return 1
    fi
}

# Function to extract test results from output
extract_test_results() {
    local output_file=$1
    local passed=$(grep -c "Test Case.*passed" "$output_file" 2>/dev/null || echo "0")
    local failed=$(grep -c "Test Case.*failed" "$output_file" 2>/dev/null || echo "0")
    echo "$passed $failed"
}

# Main test execution
echo "Starting comprehensive testing at $(date)"
echo ""

# Initialize counters
total_passed=0
total_failed=0
total_tests=0

# 1. Comprehensive File Size Tests
if run_test_suite "Comprehensive File Size Tests" "ComprehensiveFileSizeTests" "Tests all file sizes from 1KB to 1GB"; then
    results=$(extract_test_results /tmp/test_output.log)
    passed=$(echo $results | cut -d' ' -f1)
    failed=$(echo $results | cut -d' ' -f2)
    total_passed=$((total_passed + passed))
    total_failed=$((total_failed + failed))
    total_tests=$((total_tests + passed + failed))
    print_status "INFO" "File Size Tests: $passed passed, $failed failed"
else
    print_status "WARNING" "File Size Tests had issues - check output above"
fi

# 2. Rust Backend Performance Tests
if run_test_suite "Rust Backend Performance Tests" "RustBackendPerformanceTests" "Performance benchmarks and memory efficiency tests"; then
    results=$(extract_test_results /tmp/test_output.log)
    passed=$(echo $results | cut -d' ' -f1)
    failed=$(echo $results | cut -d' ' -f2)
    total_passed=$((total_passed + passed))
    total_failed=$((total_failed + failed))
    total_tests=$((total_tests + passed + failed))
    print_status "INFO" "Performance Tests: $passed passed, $failed failed"
else
    print_status "WARNING" "Performance Tests had issues - check output above"
fi

# 3. Large File Encoding/Decoding Tests
if run_test_suite "Large File Encoding/Decoding Tests" "LargeFileEncodingDecodingTests" "Tests encoding/decoding for large files"; then
    results=$(extract_test_results /tmp/test_output.log)
    passed=$(echo $results | cut -d' ' -f1)
    failed=$(echo $results | cut -d' ' -f2)
    total_passed=$((total_passed + passed))
    total_failed=$((total_failed + failed))
    total_tests=$((total_tests + passed + failed))
    print_status "INFO" "Encoding/Decoding Tests: $passed passed, $failed failed"
else
    print_status "WARNING" "Encoding/Decoding Tests had issues - check output above"
fi

# 4. Large File Hybrid Processor Tests
if run_test_suite "Large File Hybrid Processor Tests" "LargeFileHybridProcessorTests" "Tests HybridJSONProcessor with large files"; then
    results=$(extract_test_results /tmp/test_output.log)
    passed=$(echo $results | cut -d' ' -f1)
    failed=$(echo $results | cut -d' ' -f2)
    total_passed=$((total_passed + passed))
    total_failed=$((total_failed + failed))
    total_tests=$((total_tests + passed + failed))
    print_status "INFO" "Hybrid Processor Tests: $passed passed, $failed failed"
else
    print_status "WARNING" "Hybrid Processor Tests had issues - check output above"
fi

# 5. Rust Backend Debug Tests
if run_test_suite "Rust Backend Debug Tests" "RustBackendDebugTests" "Basic Rust backend functionality tests"; then
    results=$(extract_test_results /tmp/test_output.log)
    passed=$(echo $results | cut -d' ' -f1)
    failed=$(echo $results | cut -d' ' -f2)
    total_passed=$((total_passed + passed))
    total_failed=$((total_failed + failed))
    total_tests=$((total_tests + passed + failed))
    print_status "INFO" "Debug Tests: $passed passed, $failed failed"
else
    print_status "WARNING" "Debug Tests had issues - check output above"
fi

# Summary
echo ""
echo "📊 COMPREHENSIVE TEST SUMMARY"
echo "=============================="
echo "Total Tests: $total_tests"
echo "Passed: $total_passed"
echo "Failed: $total_failed"

if [ $total_tests -gt 0 ]; then
    success_rate=$((total_passed * 100 / total_tests))
    echo "Success Rate: $success_rate%"
    
    if [ $success_rate -ge 80 ]; then
        print_status "SUCCESS" "Overall test suite is healthy ($success_rate% success rate)"
    elif [ $success_rate -ge 60 ]; then
        print_status "WARNING" "Test suite has some issues ($success_rate% success rate)"
    else
        print_status "FAILURE" "Test suite has significant issues ($success_rate% success rate)"
    fi
else
    print_status "WARNING" "No tests were executed"
fi

echo ""
echo "🔍 ANALYSIS RECOMMENDATIONS"
echo "============================"

# Check for specific failure patterns
if grep -q "Failed to decode Rust backend result" /tmp/test_output.log 2>/dev/null; then
    print_status "WARNING" "Rust backend serialization issues detected"
    echo "  - Check Rust JSON serialization format"
    echo "  - Verify Swift Codable struct alignment"
    echo "  - Test with smaller files to identify threshold"
fi

if grep -q "Failed to process data with Rust backend" /tmp/test_output.log 2>/dev/null; then
    print_status "WARNING" "Rust backend processing issues detected"
    echo "  - Check Rust library loading"
    echo "  - Verify FFI function signatures"
    echo "  - Test Rust backend independently"
fi

if grep -q "memory" /tmp/test_output.log 2>/dev/null; then
    print_status "INFO" "Memory usage patterns detected"
    echo "  - Review memory efficiency results"
    echo "  - Consider memory optimization for large files"
fi

echo ""
echo "📋 NEXT STEPS"
echo "============="
echo "1. Review test output above for specific failure patterns"
echo "2. Check /tmp/test_output.log for detailed error messages"
echo "3. Run individual test classes to isolate issues"
echo "4. Use performance benchmarks to identify optimization opportunities"
echo "5. Focus on the threshold where failures begin (likely around 15-50MB)"

echo ""
echo "Testing completed at $(date)"
