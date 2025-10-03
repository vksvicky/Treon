## Treon (tree + json) Feature Checklist

Reference baseline: OK JSON features and structure documented at [`https://docs.okjson.app/`](https://docs.okjson.app/).

### MVP (macOS 12+)
- **Core JSON viewing**
  - [ ] Two-pane UI: tree navigator + formatted JSON string viewer
  - [ ] Native syntax highlighting themes (light/dark)
  - [ ] Large file support with streaming/chunked parse where possible
  - [ ] Toggle nodes, expand/collapse, search within tree
  - [ ] Filter nodes by path/expression
- **Editing and formatting**
  - [ ] Format/minify JSON (pretty-print and compact)
  - [ ] Sort object properties (toggle)
  - [ ] Expand all child nodes by default (toggle)
  - [ ] In-place value editing for primitives/objects/arrays
  - [ ] Add/remove keys and array elements with validation
  - [ ] Undo/redo support for edits
  - [ ] Detect and display parse errors with precise location (line/column)
- **Validation**
  - [ ] Basic JSON Schema validation (draft-07+ minimal support)
- **Input types**
  - [ ] JSON, JSON Lines, NDJSON
  - [ ] Apple Property List (plist: XML/binary) → JSON conversion
- **File operations**
  - [ ] Open file, recent files, drag-and-drop to open/merge
  - [ ] Copy as formatted/minified JSON
  - [ ] Save as JSON/JSONL/NDJSON/PLIST
- **Processing tools**
  - [ ] Built-in jq support (filter input, preview result)
  - [ ] JSONPath queries with live preview
  - [ ] Optional JMESPath support (alternate query style)
- **History**
  - [ ] Auto-save formatting history to local database (indexed, searchable)
  - [ ] Reopen from history; diff between two history entries
- **Scripts**
  - [ ] Script runner for custom transformations on the text buffer
  - [ ] Script presets: Copy as minified JSON, Convert timestamp, Parse XML, Show text stats
- **Interactions**
  - [ ] Keyboard shortcuts for navigation, format, search, run jq/JSONPath, expand/collapse
  - [ ] Path bar showing breadcrumb to currently selected node
  - [ ] Toolbar actions: open, save, format, sort, expand, jq, JSONPath, history
  - [ ] Quick Look preview for selected node
- **Privacy/Offline**
  - [ ] Strictly offline by default; no data leaves device
  - [ ] Clear UX around any optional network calls (e.g., updates)
- **Performance**
  - [ ] Normal vs Boost mode (disable sort/auto-expand for speed)
  - [ ] Memory-safe handling for large files; progressive rendering

### Nice-to-Have (Post-MVP)
- **Integrations**
  - [ ] macOS Services (send selection to Treon / format in-place)
  - [ ] Quick Look extension for `.json`, `.jsonl`, `.ndjson`, `.plist`
  - [ ] Alfred workflow: quick format, run jq, preview
  - [ ] AppleScript automation hooks for open/format/export

  - Alfred Workflow Spec
    - Keywords
      - `tj` – quick format JSON (clipboard or file arg)
      - `tjq <program>` – run jq program on clipboard/file
      - `tjo <args>` – generate JSON via `jo` (optional, if installed)
      - `tprev` – preview formatted JSON (inline/Quick Look)
      - `ttreon` – open clipboard/file in Treon
    - Inputs
      - Clipboard text, selected file(s) via Alfred File Action, or typed args
    - Actions
      - Run Script (zsh): call Treon CLI or `jq`/`jo`; write output to stdout/temp
      - Script Filter: display preview results inline with subtitles
      - Open URL: `treon://open?path=...` or run AppleScript to activate/open
    - Outputs
      - Copy to clipboard, save to temp file, Quick Look preview, or open in Treon
    - Example scripts
      - Quick format (clipboard): `pbpaste | treon format --indent 2 | pbcopy`
      - Run jq on file: `jq "$query" "$1" | tee /tmp/treon_result.json`
      - Preview: `cat /tmp/treon_result.json` (Script Filter JSON output)
      - Open in Treon: `open "treon://open?path=$1"`
- **URL Schemes**
  - [ ] `treon://open?path=...`, `treon://format?text=...`, `treon://jq?program=...`
- **Navigation/UX**
  - [ ] Zoom in node (focus mode, open in new tab)
  - [ ] Multi-tab/multi-window management
  - [ ] Dark/light mode toggle in-app
  - [ ] Inline node editing with validation
  - [ ] Node annotations and bookmarks
- **Diff/Compare**
  - [ ] Side-by-side JSON diff, structural diff with path-aware highlights
  - [ ] History snapshot diff
- **Data Sources**
  - [ ] HTTP fetch panel with headers/auth presets
  - [ ] Clipboard watcher and paste history
  - [ ] Import ZIP archives of logs → per-file tabs
- **Schema Tools**
  - [ ] Advanced schema validation with error traces and suggestions
  - [ ] Generate JSON from a provided JSON Schema
  - [ ] Auto-complete keys/values based on schema during editing
- **Data Transformation**
  - [ ] Convert JSON ↔ YAML
  - [ ] Convert JSON ↔ CSV (records/arrays)

### AI/ML Enhancements
- **Smart tooling**
  - [ ] Natural language to jq/JSONPath query suggestions
  - [ ] Explain JSON structure (schema inference, field purpose clustering)
  - [ ] Outlier detection in arrays of objects (highlight anomalies)
  - [ ] Auto-generate JSON schema from sample data
  - [ ] Generate sample JSON from natural language prompts
- **Assistive editing**
  - [ ] Fix common JSON issues (dangling commas, quotes) with justification
  - [ ] Suggest field names/values by learned patterns in workspace history
- **Search/Insights**
  - [ ] Semantic search across history and open tabs
  - [ ] Summaries of large payloads (entities, counts, distributions)
  - [ ] Entity extraction (names, emails, IDs) with PII highlighting

### Platform/Architecture Decisions (to compare)
- **Swift (SwiftUI + AppKit where needed)**
  - Pros: Best macOS integration (Services, QL, AppleScript, URL schemes), performance, native look/feel, power-efficient, binaries small
  - Cons: More effort for advanced tree virtualization and custom editors; jq embedding requires bridging (libjq); fewer off-the-shelf web components
  - Fit: Strong match for a pure macOS app with deep system integrations
- **C++ (Qt/Cocoa mix)**
  - Pros: High performance, cross-platform potential later, control over memory
  - Cons: Heavier dev friction on macOS-specific integrations; UI/UX polish takes longer; AppleScript/Services less straightforward
  - Fit: Overkill unless cross-platform is mandatory; integration cost high
- **Electron + React + TypeScript**
  - Pros: Fast UI iteration, huge ecosystem, excellent tree/virtualization libs, easy syntax highlighting, embedding jq via native modules or wasm
  - Cons: Heavier runtime, higher memory, less native feel, extra work for macOS integrations (Services, AppleScript); not purely native
  - Fit: Best for rapid development; not ideal for “pure macOS” requirement
- **Python (PyObjC/PySide)**
  - Pros: Easy scripting and data tooling, quick prototypes
  - Cons: Packaging/signing complexity, performance, macOS-native integrations limited or brittle
  - Fit: Prototype or internal tools; not ideal for polished commercial app

### Recommendation
- If “pure macOS 12+” and native integrations are priorities, choose **Swift (SwiftUI + AppKit interop)**.
- Keep architecture modular so jq/JSONPath engines and parsers are isolated and testable.

### Technical Components (Swift-based)
- **UI**: SwiftUI for primary UI; NSOutlineView/NSViewRepresentable for high-performance tree if needed
- **Parsing**: `JSONSerialization`, `Foundation` `JSONDecoder`, streaming parser for large files; `plist` via `PropertyListSerialization`
- **jq**: bundle `libjq` (C) and expose Swift wrapper; alternatively `jq` WASM if acceptable
- **JSONPath**: pure Swift JSONPath engine or integrate existing library
- **Syntax Highlighting**: TextKit 2 or custom SwiftUI highlighter
- **History DB**: SQLite via GRDB/SQLite.swift with FTS5 for search
- **Scripting**: Sandbox runner with Swift plugins or JSCore; constrained IO
- **Integrations**: NSUserActivity, macOS Services, QL Preview extension, AppleScript, URL schemes
- **Performance**: virtualized tree rendering, background parsing, incremental diffing, Boost mode toggles
 - **OSLog**: Unified logging with subsystem `club.cycleruncode.treon` and categories `ui`, `parsing`, `format`, `query`, `history`, `scripts`, `integrations`, `perf`; private payload logging
 - **Branding**: Bundle IDs under `club.cycleruncode.*`, website `https://cycleruncode.club`, support `support@cycleruncode.club`

### Platform & External Integrations (Future)
- [ ] Cloud Storage: iCloud Drive, Dropbox, Google Drive (open/save and sync helpers)
- [ ] API Hooks: Send JSON to CLI tool or REST endpoint; receive output as new tab

### Signature Treon Differentiators (Checklist)

#### 1.0 (Post-MVP within first stable release)
- [ ] Live data connectors (HTTP/S3/WebSocket) with credential vault
- [ ] Workspace projects (tab groups, pinned datasets, saved queries)
- [ ] Programmable pipelines (parse → filter → map → validate → export)
- [ ] Headless CLI parity for format/validate/diff/export
- [ ] Secrets hygiene (secret detection + redact suggestions)
- [ ] Inspector panels (stats, histograms, distributions, schema traces)
- [ ] Optional JMESPath alongside jq/JSONPath with side-by-side preview

#### 1.5 (Enhancements and collaboration)
- [ ] Shareable local “view links” and export bundles (no data leaves device)
- [ ] Comment threads on nodes with path anchors
- [ ] Semantic diff (structure-aware) across files and history snapshots
- [ ] Multi-format bundles: import/export TAR/ZIP of JSONL partitions
- [ ] Interactive record shaper (pivot/explode/join) with code export
- [ ] Streaming NDJSON ops with backpressure and live metrics

#### 2.0 (AI/ML and scale)
- [ ] NL → jq/JSONPath/JMESPath synthesis with "why" traces
- [ ] Structural drift detection and payload clustering across versions
- [ ] Anomaly/PII guards with redaction packs and compliance export
- [ ] Columnar acceleration option (Arrow-backed queries) for large arrays
- [ ] GPU-accelerated pretty/search (Metal) for very large documents
- [ ] Plugin SDK (Swift) for sources/transforms/exporters/inspectors

### Milestones
- M1: MVP viewer/editor, file I/O, formatting, basic jq/JSONPath, history
- M2: Scripts, integrations (Services, Quick Look), performance Boost mode
- M3: Diff/compare, tabs, URL schemes
- M4: AI/ML assistants and insights

### Phased Execution Plan (Priorities, Dependencies, Estimates)

Legend: Priority (P0 critical, P1 high, P2 medium), Size (S ≤3d, M ≤7d, L >7d), Dep → dependencies

#### Phase 0 – Foundations (P0)
- [ ] App shell, window, menus, preferences (Size: S)
- [ ] Large-file parsing + virtualized tree baseline (Size: L) Dep: App shell
- [ ] Syntax highlighting (Size: M) Dep: App shell
- [ ] Pretty/minify + error location (Size: M) Dep: Parsing

#### Phase 1 – MVP Core (P0)
- [ ] Two-pane viewer (tree + formatted text) (Size: M) Dep: Parsing, Syntax
- [ ] Search/filter in tree (Size: M) Dep: Tree baseline
- [ ] In-place edit + undo/redo (Size: L) Dep: Two-pane
- [ ] File open/save; JSON/JSONL/NDJSON/PLIST (Size: M) Dep: Parsing
- [ ] Basic JSON Schema validation (Size: M) Dep: Parsing
- [ ] jq + JSONPath (basic) (Size: M) Dep: Parsing
- [ ] History (local DB + reopen) (Size: M) Dep: App shell

#### Phase 2 – MVP Polish (P1)
- [ ] Keyboard shortcuts, toolbar, path bar (Size: S) Dep: Two-pane
- [ ] Drag-and-drop open/merge (Size: S) Dep: File I/O
- [ ] Boost mode toggles (Size: S) Dep: Parsing/Tree
- [ ] Quick Look for node preview (Size: M) Dep: Two-pane

#### Phase 3 – Signature 1.0 (P1)
- [ ] Programmable pipelines (GUI + runnable) (Size: L) Dep: jq/JSONPath, History
- [ ] Headless CLI parity (format/validate/diff/export) (Size: M) Dep: MVP Core
- [ ] Inspector panels (stats/schema traces) (Size: M) Dep: Two-pane
- [ ] Secrets detection + redact (Size: M) Dep: Parsing
- [ ] Live connectors (HTTP/S3/WebSocket) (Size: L) Dep: File I/O

#### Phase 4 – Nice-to-Have and UX (P2)
- [ ] Tabs/multi-window (Size: M) Dep: App shell
- [ ] Dark/light toggle (Size: S) Dep: App shell
- [ ] Advanced schema tools (gen/auto-complete) (Size: L) Dep: Basic schema
- [ ] YAML/CSV conversions (Size: M) Dep: Parsing
- [ ] Semantic diff + history diff (Size: M) Dep: History

#### Phase 5 – Collaboration & Streaming 1.5 (P2)
- [ ] Shareable view bundles (Size: M) Dep: History/Export
- [ ] Comments on nodes (Size: M) Dep: History
- [ ] Streaming NDJSON with metrics (Size: M) Dep: Parsing
- [ ] Record shaper (pivot/explode/join) (Size: L) Dep: Pipelines

#### Phase 6 – AI/Scale 2.0 (P2)
- [ ] NL→query synthesis with explanations (Size: L) Dep: jq/JSONPath/JMESPath
- [ ] Drift detection and clustering (Size: L) Dep: History
- [ ] PII guards + compliance export (Size: M) Dep: Secrets detection
- [ ] Arrow-backed acceleration (Size: L) Dep: Pipelines
- [ ] GPU-accelerated formatting/search (Size: L) Dep: Rendering

### Open Questions
- License compatibility for `libjq` bundling and distribution
- Sandbox entitlements for file access and AppleScript
- Target distribution: notarized direct download vs Mac App Store


