#!/usr/bin/env bash
set -euo pipefail

# Test script for Swift tests only
echo "🍎 Running Swift tests..."

# Build the project first
echo "🔨 Building project..."
xcodebuild -project Treon.xcodeproj -scheme Treon -configuration Debug build

# Run all Swift unit tests
echo "📋 Running all Swift unit tests..."
xcodebuild test -project Treon.xcodeproj -scheme Treon -destination 'platform=macOS' -only-testing:TreonTests

# Run specific test categories
echo "🧪 Running core functionality tests..."
xcodebuild test -project Treon.xcodeproj -scheme Treon -destination 'platform=macOS' -only-testing:TreonTests/ConstantsTests
xcodebuild test -project Treon.xcodeproj -scheme Treon -destination 'platform=macOS' -only-testing:TreonTests/ErrorHandlerTests
xcodebuild test -project Treon.xcodeproj -scheme Treon -destination 'platform=macOS' -only-testing:TreonTests/FileManagerTests
xcodebuild test -project Treon.xcodeproj -scheme Treon -destination 'platform=macOS' -only-testing:TreonTests/FileValidatorTests

echo "🔧 Running JSON processing tests..."
xcodebuild test -project Treon.xcodeproj -scheme Treon -destination 'platform=macOS' -only-testing:TreonTests/JSONFormatterTests
xcodebuild test -project Treon.xcodeproj -scheme Treon -destination 'platform=macOS' -only-testing:TreonTests/JSONNodeTests
xcodebuild test -project Treon.xcodeproj -scheme Treon -destination 'platform=macOS' -only-testing:TreonTests/JSONTreeDisplayTests

echo "📁 Running file management tests..."
xcodebuild test -project Treon.xcodeproj -scheme Treon -destination 'platform=macOS' -only-testing:TreonTests/DirectoryManagerTests
xcodebuild test -project Treon.xcodeproj -scheme Treon -destination 'platform=macOS' -only-testing:TreonTests/PermissionManagerTests

echo "✅ All Swift tests completed successfully!"
