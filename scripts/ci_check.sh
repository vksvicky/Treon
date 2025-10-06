#!/usr/bin/env bash
set -euo pipefail

# Fail if any Swift file exceeds 500 lines
OVER=0
while IFS= read -r -d '' f; do
  L=$(wc -l < "$f" | tr -d ' ')
  if [ "$L" -gt 500 ]; then echo "Too many lines ($L): $f"; OVER=1; fi
done < <(git ls-files '*.swift' -z)

# Fail if any function exceeds 80 lines (heuristic)
while IFS= read -r -d '' f; do
  if awk '/^[[:space:]]*(public|internal|private)?[[:space:]]*func[[:space:]]/{c=0; fn=1} fn{if($0 ~ /\{/ ) c++; if($0 ~ /\}/) c--; if($0 ~ /\}/ && c==0){fn=0} if(fn) l++; if(!fn && l>80){print "Function too long (" l "): " FILENAME; exit 1}}' "$f"; then :; else OVER=1; fi
done < <(git ls-files '*.swift' -z)

exit $OVER

 