#!/usr/bin/env bash
# Runs the shared scope harness over refs check.
set -uo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
harness="$here/../scope-harness"
tool="$here/../../refs"
hook=$(mktemp)
trap 'rm -f "$hook"' EXIT
# The hook plants a retired-target reference in each in-scope canary plan (a history
# file), so the canary reaches refs's output line for it.
cat > "$hook" <<'EOF'
#!/usr/bin/env bash
for f in "$1"/Projects/*/docs/superpowers/plans/"$SCOPE_CANARY_IN".md "$1"/.dotfiles/docs/superpowers/plans/"$SCOPE_CANARY_IN".md; do
  [[ -f $f ]] || continue
  printf 'retired: ~/Projects/%s/notes.md\n' pings >> "$f"
  repo="${f%/docs/superpowers/*}"
  git -C "$repo" add -A && git -C "$repo" commit -q -m plant
done
EOF
chmod +x "$hook"
SCOPE_FIXTURE_HOOK="$hook" REFS_GH=false "$harness" bash -c '"$0" check --host h1 --state-dir "$SCOPE_OUT_DIR"' "$tool"
