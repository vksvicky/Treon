# Treon

Pure C++ JSON viewer/formatter and query tool with Qt Quick UI. Two-pane interface (tree + formatted text), jq/JSONPath support, file history, and scripting capabilities. High-performance implementation inspired by OK JSON ([docs](https://docs.okjson.app/)).

## Architecture
- **Core Library**: C++ JSON parsing, validation, and data models
- **UI Layer**: Qt Quick for modern, responsive interface
- **Services**: File management, directory memory, error handling
- **Testing**: Comprehensive unit tests and BDD scenarios

## Features
- ✅ Two-pane JSON viewer (tree + text)
- ✅ File validation and error handling
- ✅ Recent files management
- ✅ Cross-platform Qt Quick UI
- ✅ High-performance C++ core
- ✅ TDD/BDD development approach
- 🔄 jq/JSONPath query support (planned)
- 🔄 Scripting capabilities (planned)
- 🔄 CLI interface (planned)

## Build Requirements
- **Qt 6.5+**: Modern Qt Quick framework
- **CMake 3.20+**: Build system
- **C++20**: Modern C++ features
- **Platforms**: macOS, Linux, Windows

## Quick Start
```bash
# Install dependencies (macOS)
brew install qt6 cmake

# Build and run
make build
make run-app

# Run tests
make test
```

## Development
```bash
# Setup development environment
make dev-setup

# Build application
make build

# Run tests
make test

# Clean build artifacts
make clean
```

## Known Issues

### File Size Limitations

**Recommended File Sizes:**
- **Optimal**: Files under 10MB load in under 1 second
- **Acceptable**: Files up to 100MB load in 2-5 seconds
- **Large files**: Files over 100MB may take significantly longer

**Performance Characteristics:**
- **10MB files**: ~0.5 seconds (optimized)
- **100MB files**: ~4 seconds (with UI optimizations)
- **Files >100MB**: Performance degrades significantly and depends on machine configuration

**Machine Configuration Impact:**
- **RAM**: More RAM allows for better memory mapping of large files
- **Storage**: SSD vs HDD affects file reading speed
- **CPU**: Faster processors improve JSON parsing performance
- **Available memory**: System memory pressure can slow down large file processing

**Technical Limitations:**
- Files larger than 100MB use conservative UI updates to maintain responsiveness
- Very large files (>500MB) may cause memory pressure on systems with limited RAM
- JSON validation time scales with file size complexity, not just file size
- Large arrays/objects (>100 items) use virtualized rendering to prevent UI freezing

**Recommendations:**
- For files over 100MB, consider splitting into smaller files if possible
- Ensure adequate system RAM (8GB+ recommended for files >50MB)
- Use SSD storage for better file I/O performance
- Close other memory-intensive applications when working with large JSON files

## License
TBD

## C++ Application (Pure C++ Implementation)

- Location: `cpp/`
- Build: `cmake -S cpp -B cpp/build -G Xcode && cmake --build cpp/build --config Debug`
- Tests: `ctest --test-dir cpp/build -C Debug`
- UI: Qt Quick for modern, performant cross-platform interface
- Dependencies: Qt 6.5+, CMake 3.20+
- Code limits: 500 lines per file, 80 lines per function (enforced by CI)
