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

## License
TBD# Test commit
