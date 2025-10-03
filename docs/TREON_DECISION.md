## Treon Platform Decision (Draft)

Reference baseline: OK JSON feature set and UX parity [`https://docs.okjson.app/`](https://docs.okjson.app/)

### Requirements Snapshot
- Pure macOS 12+ experience; deep macOS integrations (Services, Quick Look, AppleScript, URL schemes)
- Fast, responsive UI on large JSON (10–200MB), with Boost/Normal modes
- Offline/privacy-first; notarized, optionally App Store
- Features: two-pane viewer, jq, JSONPath, history DB, scripting, DnD

### Evaluation Criteria
- C1. macOS-native integration depth
- C2. Runtime performance (CPU/latency) on large JSON
- C3. Memory footprint and energy efficiency
- C4. UI/UX polish and fidelity to macOS conventions
- C5. Development velocity and ecosystem
- C6. Packaging/signing/notarization friction
- C7. Risk/complexity for jq + JSONPath integration
- C8. Team skills + hiring pool

### Options Overview

1) Swift (SwiftUI + AppKit interop)
- Pros: Best native integration (Services, QL, AppleScript, URL schemes), power-efficient, small binaries, first-class macOS UX. Straightforward plist support. Good sandboxing. Mature notarization.
- Cons: Need libjq binding (C bridge) or WASM; custom high-performance tree/editor work. Smaller off‑the‑shelf component ecosystem vs web.

2) Electron + React + TypeScript
- Pros: Exceptional dev velocity; rich component ecosystem (virtual trees, editors, syntax highlighting). Easy to prototype AI/ML UI. jq via native module or WASM.
- Cons: Heavier memory/CPU; less native feel; extra effort for Services/AppleScript/QL; not “pure macOS”. Larger binaries.

3) C++ (Qt/Cocoa mix)
- Pros: High performance, full control; cross‑platform option later.
- Cons: Costly macOS integrations; UI polish slower; signing/AppleScript/Services more work. Overkill for single‑platform.

4) Python (PyObjC/PySide)
- Pros: Rapid scripting/data tooling prototypes.
- Cons: Packaging/signing brittle; performance/memory weaker; integrations limited. Better for internal tooling than polished product.

### Scorecard (relative 1–5; higher is better)

| Criteria | Swift | Electron | C++ | Python |
|---|---:|---:|---:|---:|
| C1 Native integrations | 5 | 2 | 3 | 2 |
| C2 Performance | 5 | 3 | 5 | 2 |
| C3 Memory/Energy | 5 | 2 | 5 | 2 |
| C4 macOS UX fidelity | 5 | 3 | 3 | 2 |
| C5 Dev velocity | 3 | 5 | 2 | 3 |
| C6 Packaging/signing | 5 | 4 | 3 | 2 |
| C7 jq/JSONPath risk | 4 | 4 | 4 | 3 |
| C8 Skills/hiring | 3 | 5 | 3 | 3 |

Overall (unweighted): Swift ≈ 35, Electron ≈ 28, C++ ≈ 28, Python ≈ 19

### Recommendation Paths (you decide which fits your priorities)
- If “pure macOS”, deep integrations, and performance are top: choose Swift.
- If fastest time-to-market and web talent reuse are top: choose Electron.
- If future cross‑platform with max performance is required: consider C++/Qt, with higher integration cost.
- For quick internal prototype only: Python can suffice.

### Risk Notes
- libjq bundling: BSD-2-Clause; ensure license compliance. Swift bridging via modulemap/C wrapper.
- JSONPath: choose a maintained Swift library or implement a minimal engine; web has more mature options.
- Large files: need streaming/segmented parsing and virtualized tree rendering regardless of stack.

### Proposed Next Steps
- Choose weighting for criteria (e.g., C1=3, C2=3, C3=2, C4=2, C5=1, C6=1, C7=2, C8=1) and we’ll compute a weighted score.
- If Swift: draft initial module layout and milestone plan (M1–M3) below.

### Initial Swift Module Layout (draft)
- AppKit/SwiftUI
  - TreonApp (app lifecycle)
  - MainWindow, TwoPaneView, Toolbar, PathBar
  - TreeNavigator (NSOutlineView via NSViewRepresentable for performance)
  - CodeView (TextKit 2-based syntax view)
- Core
  - JSONParsing (streamed parse, incremental model)
  - PlistCodec (PropertyListSerialization)
  - JSONPathEngine
  - JQBridge (libjq integration)
  - Formatter (pretty/minify/sort/expand toggles)
- History
  - HistoryStore (SQLite/GRDB with FTS5)
- Scripts
  - ScriptRunner (sandboxed Swift/JSCore)
- Integrations
  - Services, QuickLookExt, AppleScriptBridge, URLSchemes

### Swift Framework Architecture (club.cycleruncode)
- Product bundle identifier root: `club.cycleruncode`
- Modules (Swift Packages/Frameworks)
  - `TreonUI` – SwiftUI/AppKit bridges for tree, code view, toolbars
  - `TreonCore` – parsing, formatting, validation, transforms
  - `TreonQuery` – jq/JSONPath/JMESPath bridges and engines
  - `TreonHistory` – persistence and search
  - `TreonScripts` – script engine and presets
  - `TreonIntegrations` – Services, QL, AppleScript, URL schemes, Alfred hooks
  - `TreonCLI` – headless commands used by Alfred/CI
- OS Logging (Unified Logging)
  - Subsystem: `club.cycleruncode.treon`
  - Categories: `ui`, `parsing`, `format`, `query`, `history`, `scripts`, `integrations`, `perf`
  - Use `Logger(subsystem: "club.cycleruncode.treon", category: "parsing")`
  - Log privacy: `.private` for payload content; info-level summaries only
- Branding and metadata
  - App Name: Treon
  - Team/Org: CycleRunCode Club
  - Website: `https://cycleruncode.club`
  - Support: `support@cycleruncode.club`
  - URL Scheme: `treon://`

### UI Parity & Theming
- Follow OK JSON’s two-pane structure (tree + formatted view) with macOS-native styling
- Themes: light/dark with accent color; monospace font options
- Toolbar and path bar mirror OK JSON affordances; keyboard-first interactions

### Milestones (Swift)
- M1: Viewer/editor, large-file parsing baseline, jq/jsonpath basic, history list
- M2: Scripts, Services + Quick Look, Boost mode perf, DnD and plist
- M3: Diff/compare, tabs, URL schemes, polish and notarization


