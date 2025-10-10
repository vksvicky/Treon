#!/usr/bin/env bash
set -euo pipefail

# Fail if any Swift or C++ file exceeds 500 lines
OVER=0
while IFS= read -r -d '' f; do
  L=$(wc -l < "$f" | tr -d ' ')
  if [ "$L" -gt 500 ]; then echo "Too many lines ($L): $f"; OVER=1; fi
done < <(git ls-files '*.swift' '*.cpp' '*.hpp' '*.h' -z)

# Fail if any function exceeds 80 lines (heuristic)
while IFS= read -r -d '' f; do
  case "$f" in
    *TreonTests/*|*TreonUITests/*|*tests/*)
      # Skip test files for function length heuristic
      continue
      ;;
  esac
  
  # Check Swift functions
  if [[ "$f" == *.swift ]]; then
    if awk '
    /^[[:space:]]*(public|internal|private)?[[:space:]]*func[[:space:]]+/ {
      # Ignore SwiftUI body functions (modifiers) by name
      if ($0 ~ /func[[:space:]]+body[[:space:]]*\(/) { fn=0; next }
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
  
  # Check C++ functions
  if [[ "$f" == *.cpp || "$f" == *.hpp || "$f" == *.h ]]; then
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
done < <(git ls-files '*.swift' '*.cpp' '*.hpp' '*.h' -z)

exit $OVER

 