#!/usr/bin/env bash
set -euo pipefail

# Test script for integration tests only
echo "🔗 Running integration tests..."

# Build the project first
echo "🔨 Building project..."
xcodebuild -project Treon.xcodeproj -scheme Treon -configuration Debug build

# Run Rust backend integration tests
echo "🦀🍎 Running Rust backend integration tests..."
xcodebuild test -project Treon.xcodeproj -scheme Treon -destination 'platform=macOS' -only-testing:TreonTests/RustBackendIntegrationTests

# Run HybridJSONProcessor integration tests
echo "🔄 Running HybridJSONProcessor integration tests..."
xcodebuild test -project Treon.xcodeproj -scheme Treon -destination 'platform=macOS' -only-testing:TreonTests/HybridJSONProcessorIntegrationTests

# Run hybrid architecture tests
echo "🏗️ Running hybrid architecture tests..."
xcodebuild test -project Treon.xcodeproj -scheme Treon -destination 'platform=macOS' -only-testing:TreonTests/HybridArchitectureTests

# Run smoke tests
echo "💨 Running smoke tests..."
xcodebuild test -project Treon.xcodeproj -scheme Treon -destination 'platform=macOS' -only-testing:TreonTests/SmokeTests

# Run large file tests
echo "📊 Running large file tests..."
xcodebuild test -project Treon.xcodeproj -scheme Treon -destination 'platform=macOS' -only-testing:TreonTests/LargeFileTests

echo "✅ All integration tests completed successfully!"
