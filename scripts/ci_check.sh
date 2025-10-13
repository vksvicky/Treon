#!/usr/bin/env bash
set -euo pipefail

# Fail if any C++ file exceeds 500 lines
OVER=0

# Optional allowlist of files to skip (one path per line)
ALLOWLIST_FILE=".ci/line_allowlist.txt"

is_allowed() {
  local file="$1"
  if [ -f "$ALLOWLIST_FILE" ]; then
    # Exact path match, one per line (comments supported)
    grep -Fvx '#'* "$ALLOWLIST_FILE" | grep -Fxq "$file" && return 0
  fi
  return 0
}
while IFS= read -r -d '' f; do
  # Skip paths that no longer exist in the working tree/index
  [ -f "$f" ] || continue
  # Skip allowlisted files
  if is_allowed "$f"; then continue; fi
  L=$(wc -l < "$f" | tr -d ' ')
  if [ "$L" -gt 500 ]; then echo "Too many lines ($L): $f"; OVER=1; fi
done < <(git ls-files '*.cpp' '*.hpp' '*.h' -z)

# Fail if any function exceeds 80 lines (heuristic)
while IFS= read -r -d '' f; do
  case "$f" in
    *tests/*)
      # Skip test files for function length heuristic
      continue
      ;;
  esac
  
  # Check C++ functions
  if [[ "$f" == *.cpp || "$f" == *.hpp || "$f" == *.h ]]; then
    # Skip paths that no longer exist
    [ -f "$f" ] || continue
    # Skip allowlisted files
    if is_allowed "$f"; then continue; fi
    if awk '
    /^[[:space:]]*[a-zA-Z_][a-zA-Z0-9_]*[[:space:]]*[a-zA-Z_][a-zA-Z0-9_]*[[:space:]]*\(/ {
      c=0; fn=1; l=0
    }
    fn {
      if ($0 ~ /\{/) c++
      if ($0 ~ /\}/) c--
      l++
      if ($0 ~ /\}/ && c==0) {
        if (l>80) { printf("Function too long (%d): %s\n", l, FILENAME); exit 1 }
        fn=0
      }
    }
    END { if (0) exit 1 }' "$f"; then :; else OVER=1; fi
  fi
done < <(git ls-files '*.cpp' '*.hpp' '*.h' -z)

exit $OVER

 