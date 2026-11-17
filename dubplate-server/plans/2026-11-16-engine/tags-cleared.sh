#!/usr/bin/env bash
# Print each line of tags-to-clear.txt whose comment text is still in its
# file, then the count. Run from the repo root. Exits 1 when a line is left.
set -uo pipefail
here=$(cd "$(dirname "$0")" && pwd)
left=0
while IFS= read -r row; do
  file=${row%%:*}
  rest=${row#*:}
  text=${rest#*:}
  if [ -f "$file" ] && grep -qF -- "$text" "$file"; then
    printf 'STILL %s\n' "$row"
    left=$((left + 1))
  fi
done <"$here/tags-to-clear.txt"
printf 'left %s\n' "$left"
[ "$left" -eq 0 ]
