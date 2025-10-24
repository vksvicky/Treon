# Treon

Native macOS JSON viewer/formatter and query tool. Two-pane UI (tree + formatted text), jq/JSONPath, history, scripts — with a roadmap for pipelines and AI assists. Baseline inspired by OK JSON ([docs](https://docs.okjson.app/)).

## Modules
- TreonShared: constants, logging, localization
- TreonCore: parsing/formatting/validation
- TreonQuery: jq/JSONPath engines (stubs initially)
- TreonHistory: persistence
- TreonScripts: script runner
- TreonIntegrations: macOS Services, QL, AppleScript, URL schemes
- TreonUI: SwiftUI/AppKit bridges (later)
- TreonCLI: headless CLI

## Quick Start

**Building and Running:**
```bash
# Build everything (recommended)
make build

# Run the app
make run-app

# Run tests
make test
```

**If you get "Failed to process data with Rust backend" error:**
```bash
# Quick fix
make clean && make build
```

## Build
- SwiftPM; macOS 12+
- Universal builds by default; Apple Silicon–only builds supported
- **Hybrid Swift + Rust architecture** for high-performance JSON processing

## CLI
```bash
echo '{"a":1}' | treon format
echo '{
  "a": 1
}' | treon minify
```

## Alfred Workflow (spec summary)
- Keywords: `tj`, `tjq`, `tjo`, `tprev`, `ttreon`
- Quick format: `pbpaste | treon format | pbcopy`
- Run jq: `jq "$query" "$1" | tee /tmp/treon_result.json`

## Branding
- Bundle root: club.cycleruncode
- Website: https://cycleruncode.club
- Support: support@cycleruncode.club

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

## Troubleshooting

### Rust Backend Issues

If you encounter the error "Failed to parse JSON: Processing failed: Failed to process data with Rust backend", follow these steps:

#### Quick Fix (Recommended)
Use the automated build system:
```bash
# Clean and rebuild everything
make clean
make build

# Or run the app directly
make run-app
```

#### Manual Fix
If the automated build doesn't work, manually copy the Rust library:
```bash
# 1. Build the Rust backend
cd rust_backend && cargo build --release

# 2. Find your app bundle (replace with your actual path)
APP_BUNDLE="/Users/$(whoami)/Library/Developer/Xcode/DerivedData/Treon-*/Build/Products/Debug/Treon.app"

# 3. Create Frameworks directory and copy library
mkdir -p "$APP_BUNDLE/Contents/Frameworks"
cp rust_backend/target/release/libtreon_rust_backend.dylib "$APP_BUNDLE/Contents/Frameworks/"
```

#### For Xcode Users
If you're building directly in Xcode and getting the error:

**Option 1: Add Build Phase (Recommended)**
1. Open `Treon.xcodeproj` in Xcode
2. Select the 'Treon' target in the project navigator
3. Go to the 'Build Phases' tab
4. Click the '+' button and select 'New Run Script Phase'
5. Set the script to: `bash ${SRCROOT}/scripts/deploy_rust_lib.sh`
6. Move this phase to run AFTER 'Copy Bundle Resources'
7. Name it 'Deploy Rust Library'

**Option 2: Pre-build Script**
Run this before building in Xcode:
```bash
bash scripts/pre_build.sh
```

**Option 3: Use Makefile**
Instead of building in Xcode, use:
```bash
make build
```

#### Verification
To verify the Rust backend is working:
```bash
# Run a quick test
xcodebuild test -project Treon.xcodeproj -scheme Treon -destination 'platform=macOS' -only-testing:TreonTests/RustBackendIntegrationTests/testEmptyJSON
```

If the test passes, the Rust backend is properly configured.

### Common Issues

#### "Library not found" errors
- Ensure the Rust library is in the correct location: `Contents/Frameworks/libtreon_rust_backend.dylib`
- Check that the library was built with `cargo build --release`
- Verify the app bundle path is correct

#### Performance issues with large files
- Files >100MB may take longer to process
- Ensure adequate system RAM (8GB+ recommended)
- Use SSD storage for better performance
- Close other memory-intensive applications

#### Build failures
- Clean everything: `make clean`
- Rebuild Rust backend: `cd rust_backend && cargo clean && cargo build --release`
- Rebuild Swift app: `xcodebuild clean && xcodebuild build`

### Development Workflow

**Recommended workflow to avoid issues:**
1. Always use `make build` or `make run-app` for development
2. If you must use Xcode directly, run `bash scripts/pre_build.sh` first
3. For testing, use `make test` or the individual test scripts
4. For CI/CD, ensure the Rust library deployment is included in your build process

**Scripts available:**
- `make build` - Build everything with automatic Rust library deployment
- `make run-app` - Build and run the app
- `make test` - Run all tests
- `scripts/pre_build.sh` - Prepare for Xcode builds
- `scripts/deploy_rust_lib.sh` - Deploy Rust library to app bundle

## License
TBD
