#!/usr/bin/env bash
set -euo pipefail

# Quick test script for development (fastest tests only)
echo "⚡ Running quick tests for development..."

# Build the project first
echo "🔨 Building project..."
xcodebuild -project Treon.xcodeproj -scheme Treon -configuration Debug build

# Run only the most critical tests
echo "🧪 Running critical unit tests..."
xcodebuild test -project Treon.xcodeproj -scheme Treon -destination 'platform=macOS' -only-testing:TreonTests/ConstantsTests
xcodebuild test -project Treon.xcodeproj -scheme Treon -destination 'platform=macOS' -only-testing:TreonTests/ErrorHandlerTests
xcodebuild test -project Treon.xcodeproj -scheme Treon -destination 'platform=macOS' -only-testing:TreonTests/JSONNodeTests

# Run a subset of Rust tests (fastest ones)
echo "🦀 Running quick Rust tests..."
cd rust_backend
cargo test --release test_rust_json_value_serialization
cargo test --release test_rust_json_tree_serialization
cd ..

# Run one integration test
echo "🔗 Running one integration test..."
xcodebuild test -project Treon.xcodeproj -scheme Treon -destination 'platform=macOS' -only-testing:TreonTests/RustBackendIntegrationTests/testEmptyJSON

echo "✅ Quick tests completed successfully!"
