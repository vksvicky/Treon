#!/bin/bash

# Treon C++ Test Runner with Coverage Report
# This script runs all tests and generates coverage reports

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
BUILD_DIR="cpp/build"
COVERAGE_DIR="coverage"
COVERAGE_REPORT="coverage_report.html"

echo -e "${BLUE}🧪 Treon C++ Test Runner with Coverage${NC}"
echo "================================================"

# Check if we're in the right directory
if [ ! -f "cpp/CMakeLists.txt" ]; then
    echo -e "${RED}❌ Error: Please run this script from the project root directory${NC}"
    exit 1
fi

# Check if build directory exists
if [ ! -d "$BUILD_DIR" ]; then
    echo -e "${YELLOW}⚠️  Build directory not found. Building first...${NC}"
    make build
fi

# Check for coverage tools
COVERAGE_AVAILABLE=false
if command -v gcov &> /dev/null; then
    COVERAGE_AVAILABLE=true
    echo -e "${GREEN}✅ gcov found - coverage reporting enabled${NC}"
else
    echo -e "${YELLOW}⚠️  gcov not found - coverage reporting disabled${NC}"
fi

# Create coverage directory
mkdir -p "$COVERAGE_DIR"

echo -e "${BLUE}🔨 Building with coverage flags...${NC}"
cd "$BUILD_DIR"

# Configure with coverage if available
if [ "$COVERAGE_AVAILABLE" = true ]; then
    cmake .. -DCMAKE_BUILD_TYPE=Debug -DCMAKE_CXX_FLAGS="--coverage -fprofile-arcs -ftest-coverage"
    make clean
    make -j$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 4)
else
    cmake .. -DCMAKE_BUILD_TYPE=Debug
    make -j$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 4)
fi

echo -e "${BLUE}🧪 Running tests...${NC}"
echo "================================================"

# Run tests with verbose output
if ctest -C Debug --output-on-failure --verbose; then
    echo -e "${GREEN}✅ All tests passed!${NC}"
    TEST_RESULT=0
else
    echo -e "${RED}❌ Some tests failed!${NC}"
    TEST_RESULT=1
fi

echo "================================================"

# Generate coverage report if available
if [ "$COVERAGE_AVAILABLE" = true ] && [ "$TEST_RESULT" = 0 ]; then
    echo -e "${BLUE}📊 Generating coverage report...${NC}"
    
    # Run gcov on all source files
    find . -name "*.gcno" -exec gcov {} \; > /dev/null 2>&1
    
    # Collect coverage data
    echo -e "${BLUE}📈 Collecting coverage data...${NC}"
    
    # Create a simple coverage summary
    echo "# Treon C++ Coverage Report" > "../$COVERAGE_DIR/coverage_summary.md"
    echo "Generated on: $(date)" >> "../$COVERAGE_DIR/coverage_summary.md"
    echo "" >> "../$COVERAGE_DIR/coverage_summary.md"
    
    # Find all .gcov files and create summary
    echo "## Coverage Summary" >> "../$COVERAGE_DIR/coverage_summary.md"
    echo "" >> "../$COVERAGE_DIR/coverage_summary.md"
    echo "| File | Lines | Executed | Coverage |" >> "../$COVERAGE_DIR/coverage_summary.md"
    echo "|------|-------|----------|----------|" >> "../$COVERAGE_DIR/coverage_summary.md"
    
    TOTAL_LINES=0
    TOTAL_EXECUTED=0
    
    for gcov_file in *.gcov; do
        if [ -f "$gcov_file" ]; then
            # Extract filename (remove .gcov extension)
            filename=$(basename "$gcov_file" .gcov)
            
            # Count lines and executed lines
            lines=$(grep -c "^[[:space:]]*[0-9]" "$gcov_file" 2>/dev/null || echo 0)
            executed=$(grep -c "^[[:space:]]*[1-9]" "$gcov_file" 2>/dev/null || echo 0)
            
            if [ "$lines" -gt 0 ]; then
                coverage=$((executed * 100 / lines))
                echo "| $filename | $lines | $executed | ${coverage}% |" >> "../$COVERAGE_DIR/coverage_summary.md"
                TOTAL_LINES=$((TOTAL_LINES + lines))
                TOTAL_EXECUTED=$((TOTAL_EXECUTED + executed))
            fi
        fi
    done
    
    # Calculate overall coverage
    if [ "$TOTAL_LINES" -gt 0 ]; then
        OVERALL_COVERAGE=$((TOTAL_EXECUTED * 100 / TOTAL_LINES))
        echo "" >> "../$COVERAGE_DIR/coverage_summary.md"
        echo "## Overall Coverage: ${OVERALL_COVERAGE}%${NC}" >> "../$COVERAGE_DIR/coverage_summary.md"
        echo "" >> "../$COVERAGE_DIR/coverage_summary.md"
        echo "Total Lines: $TOTAL_LINES" >> "../$COVERAGE_DIR/coverage_summary.md"
        echo "Executed Lines: $TOTAL_EXECUTED" >> "../$COVERAGE_DIR/coverage_summary.md"
        
        echo -e "${GREEN}📊 Overall Coverage: ${OVERALL_COVERAGE}%${NC}"
        echo -e "${GREEN}📁 Coverage report saved to: $COVERAGE_DIR/coverage_summary.md${NC}"
    fi
    
    # Move gcov files to coverage directory
    mv *.gcov "../$COVERAGE_DIR/" 2>/dev/null || true
    mv *.gcno "../$COVERAGE_DIR/" 2>/dev/null || true
    mv *.gcda "../$COVERAGE_DIR/" 2>/dev/null || true
    
    echo -e "${GREEN}✅ Coverage report generated successfully!${NC}"
else
    echo -e "${YELLOW}⚠️  Coverage report not generated (gcov not available or tests failed)${NC}"
fi

cd ..

echo "================================================"
if [ "$TEST_RESULT" = 0 ]; then
    echo -e "${GREEN}🎉 Test run completed successfully!${NC}"
    if [ "$COVERAGE_AVAILABLE" = true ]; then
        echo -e "${GREEN}📊 Coverage report available in: $COVERAGE_DIR/${NC}"
    fi
else
    echo -e "${RED}💥 Test run completed with failures!${NC}"
fi

echo "================================================"
echo -e "${BLUE}📋 Test Summary:${NC}"
echo "• Build: ✅ Success"
echo "• Tests: $([ $TEST_RESULT = 0 ] && echo "✅ All passed" || echo "❌ Some failed")"
echo "• Coverage: $([ "$COVERAGE_AVAILABLE" = true ] && echo "✅ Generated" || echo "⚠️  Not available")"

exit $TEST_RESULT
