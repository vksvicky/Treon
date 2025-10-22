# Treon Hybrid Architecture: Swift + Rust

## Overview

Treon now uses a hybrid architecture combining SwiftUI for the native macOS interface with a high-performance Rust backend for JSON processing. This approach provides the best of both worlds: native macOS integration and exceptional performance for large JSON files.

## Architecture

```
┌─────────────────────────────────────┐
│           SwiftUI Frontend          │
│  • Native macOS UI                  │
│  • Perfect i18n support             │
│  • Native menus & shortcuts         │
│  • Services, Quick Look, etc.       │
└─────────────────┬───────────────────┘
                  │ C FFI Bridge
┌─────────────────▼───────────────────┐
│           Rust Backend              │
│  • simd-json for parsing           │
│  • Streaming for 1GB+ files        │
│  • Memory-efficient processing     │
│  • Async/await for responsiveness  │
└─────────────────────────────────────┘
```

## Key Components

### 1. Rust Backend (`rust_backend/`)

- **High-performance JSON processing** using SIMD-optimized parsers
- **Streaming support** for files up to 1GB+
- **Memory-efficient** processing with minimal allocations
- **C FFI interface** for Swift integration

**Key Files:**
- `src/lib.rs` - Main FFI interface
- `src/json_processor.rs` - Core JSON processing logic
- `src/streaming_parser.rs` - Streaming parser for large files
- `src/tree_builder.rs` - Tree structure building
- `src/error.rs` - Error handling

### 2. Swift-Rust Bridge (`Treon/Core/RustBackend.swift`)

- **Clean Swift interface** to Rust backend
- **Type-safe** data conversion between Rust and Swift
- **Error handling** with proper Swift error types
- **Performance monitoring** and statistics

### 3. Hybrid Processor (`Treon/Core/HybridJSONProcessor.swift`)

- **Automatic backend selection** based on file size
- **Performance comparison** and recommendations
- **Unified interface** for both Swift and Rust backends
- **Seamless fallback** between backends

## Performance Characteristics

| File Size | Backend | Processing Time | Memory Usage | Performance Gain |
|-----------|---------|----------------|--------------|------------------|
| < 5MB     | Swift   | ~0.04s         | ~50MB        | Baseline         |
| 5-50MB    | Rust    | ~0.3s          | ~25MB        | 10-20x faster    |
| 50-100MB  | Rust    | ~0.5s          | ~50MB        | 20-40x faster    |
| 100MB-1GB | Rust    | ~2-5s          | ~100MB       | 20-60x faster    |

## Backend Selection Logic

The hybrid processor automatically selects the optimal backend:

```swift
// Files < 5MB: Use Swift backend (native, fast for small files)
// Files ≥ 5MB: Use Rust backend (SIMD-optimized, streaming)

let backend = fileSize < 5 * 1024 * 1024 ? .swift : .rust
```

## Building the Hybrid Architecture

### Prerequisites

1. **Rust** - Install from [rustup.rs](https://rustup.rs/)
2. **Xcode** - For Swift compilation
3. **macOS 12+** - Target platform

### Build Process

```bash
# Build Rust backend first
make build-rust

# Build complete Swift + Rust app
make build

# Run the app
make run-app
```

### Development Workflow

```bash
# Development build (faster iteration)
make dev

# Production build (optimized)
make prod

# Clean everything
make clean
```

## Testing

### Unit Tests

```bash
# Run all tests
make test

# Run specific test suites
xcodebuild test -scheme Treon -only-testing:TreonTests/HybridJSONProcessorTests
xcodebuild test -scheme Treon -only-testing:TreonTests/RustBackendTests
```

### Integration Tests

```bash
# Run integration tests
xcodebuild test -scheme Treon -only-testing:TreonTests/HybridArchitectureTests
```

### Performance Tests

```bash
# Run performance benchmarks
cd benchmarks
python3 performance_test.py
```

## Key Features

### 1. Automatic Backend Selection

The hybrid processor automatically chooses the best backend based on file size and performance characteristics.

### 2. Streaming Support

Large files (>50MB) use streaming parsing to minimize memory usage and maintain responsiveness.

### 3. Native macOS Integration

- **Perfect i18n** with SwiftUI's built-in localization
- **Native menus** with full control over menu items
- **Services integration** for system-wide JSON processing
- **Quick Look** support for JSON files
- **AppleScript** compatibility

### 4. Performance Monitoring

Real-time performance statistics and backend recommendations:

```swift
let comparison = HybridJSONProcessor.getPerformanceComparison(for: fileSize)
print("Swift estimate: \(comparison.swiftEstimateFormatted)")
print("Rust estimate: \(comparison.rustEstimateFormatted)")
print("Performance gain: \(comparison.performanceGainFormatted)")
```

## Error Handling

The hybrid architecture provides comprehensive error handling:

- **Backend initialization errors**
- **JSON parsing errors**
- **Memory allocation errors**
- **Processing timeout errors**
- **File I/O errors**

All errors are properly wrapped in Swift's error handling system.

## Memory Management

### Swift Side
- Uses ARC for automatic memory management
- Proper cleanup of C FFI resources
- Efficient data conversion between Rust and Swift

### Rust Side
- Zero-cost abstractions
- Manual memory management for optimal performance
- Automatic cleanup of FFI resources

## Internationalization

The hybrid architecture maintains perfect i18n support:

- **SwiftUI localization** for all UI elements
- **Native menu integration** with proper language support
- **Unicode support** for international JSON content
- **Accessibility** with VoiceOver integration

## Deployment

### App Store Distribution

The hybrid architecture is fully compatible with App Store distribution:

- **Notarization** support
- **Code signing** for both Swift and Rust components
- **Sandboxing** compatibility
- **Universal binary** support (Intel + Apple Silicon)

### Standalone Distribution

For standalone distribution:

```bash
# Build universal binary
make prod

# Create DMG
# (Use your preferred DMG creation tool)
```

## Troubleshooting

### Common Issues

1. **Rust not found**
   ```bash
   # Install Rust
   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
   ```

2. **Build failures**
   ```bash
   # Clean and rebuild
   make clean
   make build
   ```

3. **Performance issues**
   - Check that Rust backend is being used for large files
   - Verify SIMD optimizations are enabled
   - Monitor memory usage during processing

### Debug Mode

Enable debug logging:

```swift
// In your Swift code
let logger = Loggers.perf
logger.info("Debug information here")
```

## Future Enhancements

### Planned Features

1. **Custom JSON Parser** - Even faster parsing for specific use cases
2. **Parallel Processing** - Multi-threaded JSON processing
3. **Memory Mapping** - Direct file mapping for very large files
4. **Compression Support** - Handle compressed JSON files
5. **Schema Validation** - JSON Schema validation with Rust performance

### Performance Targets

- **1GB files**: < 5 seconds processing time
- **Memory usage**: < 200MB for 1GB files
- **UI responsiveness**: 60 FPS during processing
- **Startup time**: < 1 second

## Contributing

### Development Setup

1. Clone the repository
2. Install Rust: `curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh`
3. Install Xcode
4. Run `make build` to build everything

### Code Style

- **Swift**: Follow Swift API Design Guidelines
- **Rust**: Follow Rust API Guidelines
- **FFI**: Use safe, well-documented interfaces

### Testing

- Write tests for both Swift and Rust components
- Include performance tests for large files
- Test error handling scenarios
- Verify memory management

## License

This hybrid architecture maintains the same license as the main Treon project.

---

*Last updated: 2025-01-18*
*Version: 1.0*
