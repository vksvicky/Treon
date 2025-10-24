# Treon Testing Guide

This document describes the comprehensive testing framework for the Treon JSON viewer application.

## Test Scripts Overview

We have several test scripts to run different types of tests:

### 1. **Rust Tests Only** (`scripts/test_rust.sh`)
```bash
# Run via Makefile
make test-rust

# Or directly
bash scripts/test_rust.sh
```

**What it tests:**
- All Rust backend functionality
- JSON parsing and tree building
- Serialization/deserialization
- FFI functions
- Comprehensive file size tests (10KB to 250MB)
- Performance tests

**Test Categories:**
- `test_comprehensive_file_sizes` - Tests all file sizes (10KB, 1MB, 5MB, 10MB, 25MB, 50MB, 100MB, 250MB)
- `test_rust_json_value_serialization` - Tests all JSON value types
- `test_rust_json_tree_serialization` - Tests complete tree structures
- `test_treon_rust_process_data` - Tests FFI functions

### 2. **Swift Tests Only** (`scripts/test_swift.sh`)
```bash
# Run via Makefile
make test-swift

# Or directly
bash scripts/test_swift.sh
```

**What it tests:**
- Swift unit tests
- Core functionality
- JSON processing
- File management
- Error handling

**Test Categories:**
- Core functionality tests (Constants, ErrorHandler, FileManager, FileValidator)
- JSON processing tests (JSONFormatter, JSONNode, JSONTreeDisplay)
- File management tests (DirectoryManager, PermissionManager)

### 3. **Integration Tests Only** (`scripts/test_integration.sh`)
```bash
# Run via Makefile
make test-integration

# Or directly
bash scripts/test_integration.sh
```

**What it tests:**
- Rust backend integration with Swift
- HybridJSONProcessor integration
- End-to-end workflows
- Large file processing
- Cross-language communication

**Test Categories:**
- `RustBackendIntegrationTests` - Tests Swift ↔ Rust communication
- `HybridJSONProcessorIntegrationTests` - Tests the hybrid processing pipeline
- `HybridArchitectureTests` - Tests the overall architecture
- `SmokeTests` - Basic functionality smoke tests
- `LargeFileTests` - Large file processing tests

### 4. **All Tests** (`scripts/test_all.sh`)
```bash
# Run via Makefile
make test-all
# or simply
make test

# Or directly
bash scripts/test_all.sh
```

**What it tests:**
- Everything! (Rust + Swift + Integration + UI tests)
- Complete test suite
- Full validation of the application

### 5. **Quick Tests** (`scripts/test_quick.sh`)
```bash
# Run via Makefile
make test-quick

# Or directly
bash scripts/test_quick.sh
```

**What it tests:**
- Fastest subset of tests for development
- Critical functionality only
- Quick feedback during development

## Test Coverage

### File Size Coverage
Our tests cover all the file sizes you requested:
- **10KB** - Small files
- **1MB** - Medium files  
- **5MB** - Large files
- **10MB** - Very large files
- **25MB** - Extra large files
- **50MB** - Huge files
- **100MB** - Massive files
- **250MB** - Extreme files

### Test Types Coverage

#### Rust Backend Tests
- ✅ JSON parsing and validation
- ✅ Tree building with depth limiting
- ✅ Serialization/deserialization
- ✅ FFI function testing
- ✅ Performance testing
- ✅ Memory management
- ✅ Error handling

#### Swift Tests
- ✅ Unit tests for all core classes
- ✅ JSON processing logic
- ✅ File management
- ✅ Error handling
- ✅ UI component tests
- ✅ Integration with system APIs

#### Integration Tests
- ✅ Swift ↔ Rust communication
- ✅ HybridJSONProcessor pipeline
- ✅ Large file processing workflows
- ✅ Cross-language data serialization
- ✅ End-to-end functionality

## Running Tests

### During Development
```bash
# Quick feedback during coding
make test-quick

# Test specific functionality
make test-rust    # When working on Rust backend
make test-swift   # When working on Swift code
make test-integration  # When working on integration
```

### Before Committing
```bash
# Run all tests to ensure nothing is broken
make test-all
```

### CI/CD Pipeline
```bash
# Full test suite for continuous integration
make test-all
```

## Test Results

### Expected Output
- **Rust Tests**: 84 tests passing
- **Swift Tests**: All unit tests passing
- **Integration Tests**: All integration scenarios passing
- **UI Tests**: All UI functionality passing

### Performance Benchmarks
- **Small files (1MB)**: < 1 second
- **Medium files (10MB)**: < 5 seconds
- **Large files (100MB)**: < 30 seconds
- **Extreme files (250MB)**: < 60 seconds

## Troubleshooting

### Common Issues

1. **Rust tests failing**: Check if Rust backend is built
   ```bash
   make build-rust
   ```

2. **Swift tests failing**: Check if project builds
   ```bash
   make build
   ```

3. **Integration tests failing**: Check if Rust library is in app bundle
   ```bash
   make build  # This copies the Rust library
   ```

### Debug Mode
To run tests with more verbose output:
```bash
# Rust tests with verbose output
cd rust_backend && cargo test --release -- --nocapture

# Swift tests with verbose output
xcodebuild test -project Treon.xcodeproj -scheme Treon -destination 'platform=macOS' -only-testing:TreonTests -verbose
```

## Test Maintenance

### Adding New Tests
1. **Rust tests**: Add to `rust_backend/src/lib.rs` in the `#[cfg(test)]` module
2. **Swift tests**: Add to appropriate test file in `TreonTests/Unit/`
3. **Integration tests**: Add to `TreonTests/Unit/` with "Integration" in the name

### Updating Test Scripts
- Modify the appropriate script in `scripts/test_*.sh`
- Update this documentation if test categories change
- Ensure all scripts remain executable (`chmod +x`)

## Performance Testing

The test suite includes performance benchmarks for:
- JSON parsing speed
- Memory usage
- Tree building performance
- Serialization/deserialization speed
- Large file handling

These benchmarks help ensure the application meets performance requirements for handling files up to 1GB.
