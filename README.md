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

## Build
- SwiftPM; macOS 12+
- Universal builds by default; Apple Silicon–only builds supported

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

## License
TBD# Test commit
