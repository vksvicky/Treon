# Contributing to Treon

## Process
- TDD first: write failing unit/integration tests, then implement.
- No UI tests (stub/mock UI), prefer view-model and integration coverage.

## Testing
- Unit tests in each target; integration tests in `TreonIntegrationTests`.
- Provide mocks/fakes in `TreonTesting`.
- Keep tests deterministic and offline.

## Code Style
- Max 500 lines per file; 50 lines per function (enforced in review/CI scripts).
- Early returns, error-first handling; avoid deep nesting.
- No hard-coded strings/URLs: use `TreonShared.Constants` and `LocalizationKeys`.
- Use `OSLog` via `Loggers` with `.private` for payload content.

## Internationalization
- Centralize user-facing strings in `TreonShared/Resources/Localizable.strings`.
- Avoid concatenation for sentences; prefer format strings.

## Commits/PRs
- Small, focused PRs; include tests and docs where applicable.
- Describe user-visible changes and performance impact.


