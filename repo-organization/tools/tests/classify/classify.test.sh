#!/usr/bin/env bash
# Tests for classify-docs against a fixture workstation tree and fixture destination clones.
set -uo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
tool="$here/../../classify-docs"
harness="$here/../scope-harness"
fail=0
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
export GIT_AUTHOR_NAME=t GIT_AUTHOR_EMAIL=t@example.invalid GIT_COMMITTER_NAME=t GIT_COMMITTER_EMAIL=t@example.invalid

mk() { mkdir -p "$(dirname "$1")"; printf '%s\n' "${2:-$1}" > "$1"; }

# --- fixture workstation tree ---
ws="$tmp/ws"
d="$ws/docs/superpowers"
mk "$d/specs/2026-01-01-lean-pass-design.md"
mk "$d/specs/2026-01-02-pings-worker-design.md"
mk "$d/specs/2026-01-03-dubplate-thing-design.md"
mk "$d/specs/2026-01-04-drafter-x-design.md"
mk "$d/specs/2026-01-05-mystery-design.md"
mk "$d/specs/2026-01-06-dubplate-same-design.md" same
mk "$d/specs/2026-01-07-dubplate-diff-design.md" ws-copy
mk "$d/specs/2026-01-08-poplar-adapter-design.md"
mk "$d/plans/2026-01-09-dubplate-open-plan.md"
mk "$d/plans/2026-01-10-poplar-live-plan.md"
mk "$d/plans/2026-01-11-dubplate-ghost-plan.md"
mk "$d/plans/2026-01-12-dubplate-finished-plan.md"
mk "$d/plans/archive/2026-01-01-authoring-01.md"
mk "$d/research/2026-01-04-drafter-x-review-mechanics.md"
mk "$d/research/2026-01-05-mystery-folder/a.md"
for p in claude/.claude/workflows/docs-page-chain.js bin/.local/bin/cairn-docs-outline \
  scripts/drafter-gate.sh tests/fixtures/docs-page-chain/a.json tests/fixtures/drafter/b.json \
  tests/docs-page-chain-derivation.test.mjs tests/docs-page-chain-handoff.test.mjs \
  tests/docs-page-chain-outline.test.mjs tests/drafter-prompts-parity.sh tests/drafter-render-prompts.mjs \
  bin/.local/bin/review-desk bin/.local/bin/claude-desk-reminder tests/review-desk.test.sh \
  tests/claude-desk-reminder.test.sh approval-queue-seed/x; do mk "$ws/$p"; done
git -C "$ws" init -q && git -C "$ws" add -A && git -C "$ws" commit -q -m seed
git -C "$ws" mv bin/.local/bin/review-desk bin/.local/bin/approval-queue
git -C "$ws" mv bin/.local/bin/claude-desk-reminder bin/.local/bin/claude-approval-queue-reminder
git -C "$ws" mv tests/review-desk.test.sh tests/approval-queue.test.sh
git -C "$ws" mv tests/claude-desk-reminder.test.sh tests/claude-approval-queue-reminder.test.sh
git -C "$ws" mv approval-queue-seed approval-queue
git -C "$ws" commit -q -m rename

# --- fixture destination clones ---
dub="$tmp/dubplate"
mk "$dub/docs/superpowers/archive/specs/2026-01-06-dubplate-same-design.md" same
mk "$dub/docs/superpowers/specs/2026-01-07-dubplate-diff-design.md" dest-copy
ini="$tmp/initiatives"
mkdir -p "$ini" "$tmp/poplar"

# --- stubs for the one-executor inputs ---
export PROJECTS_ROOT="$tmp/Projects"
mkdir -p "$PROJECTS_ROOT/poplar"
cat > "$tmp/agents.json" <<JSON
[{"name":"poplar-live-exec","cwd":"$PROJECTS_ROOT/poplar/.claude/worktrees/x","state":"working"},
 {"name":"dubplate-ghost-exec","cwd":"$tmp/elsewhere","state":"working"},
 {"name":"dubplate-finished-exec","cwd":"$PROJECTS_ROOT/dubplate","state":"done"}]
JSON
printf '# status\n\n## Current state\n\nnothing\n\n## Next action\n\nFinish dubplate-open first.\n' > "$tmp/status.md"

out=$("$tool" --ws "$ws" --dest dubplate="$dub" --dest initiatives="$ini" --dest poplar="$tmp/poplar" \
  --agents-json "$tmp/agents.json" --status "$tmp/status.md" --map "$tmp/map.tsv" --calls "$tmp/calls.md" 2>&1)
rc=$?
[[ $rc -eq 0 ]] && echo "ok   classify-docs runs" || { echo "FAIL classify-docs rc=$rc: $out"; exit 1; }

row() { awk -F'\t' -v p="$1" '$2 == p' "$tmp/map.tsv"; }
want() { # old_path column value
  local got
  got=$(row "$1" | cut -f"$2")
  if [[ $got == "$3" ]]; then echo "ok   $1 col $2 = $3"; else echo "FAIL $1 col $2: want '$3', got '$got'"; fail=1; fi
}
S=docs/superpowers
want $S/specs/2026-01-01-lean-pass-design.md 6 stays
want $S/specs/2026-01-02-pings-worker-design.md 6 leaves-with-pings
want $S/specs/2026-01-03-dubplate-thing-design.md 6 moved
want $S/specs/2026-01-03-dubplate-thing-design.md 4 $S/specs/2026-01-03-dubplate-thing-design.md
want $S/specs/2026-01-04-drafter-x-design.md 6 deferred:p5
want $S/specs/2026-01-04-drafter-x-design.md 4 docs-system/specs/2026-01-04-drafter-x-design.md
want $S/specs/2026-01-04-drafter-x-design.md 5 docs-system
want $S/specs/2026-01-05-mystery-design.md 6 flagged
want $S/specs/2026-01-06-dubplate-same-design.md 6 collision-identical
want $S/specs/2026-01-07-dubplate-diff-design.md 6 collision-differs
want $S/specs/2026-01-08-poplar-adapter-design.md 3 poplar
want $S/plans/2026-01-09-dubplate-open-plan.md 6 deferred:dubplate-open
want $S/plans/2026-01-10-poplar-live-plan.md 6 deferred:poplar-live
want $S/plans/2026-01-11-dubplate-ghost-plan.md 6 moved
want $S/plans/2026-01-12-dubplate-finished-plan.md 6 moved
want $S/plans/archive 6 stays
want $S/research/2026-01-04-drafter-x-review-mechanics.md 6 deferred:p5
want $S/research/2026-01-05-mystery-folder 6 flagged
want bin/.local/bin/review-desk 6 history
want bin/.local/bin/review-desk 4 bin/.local/bin/approval-queue
want tests/claude-desk-reminder.test.sh 6 history
want approval-queue/ 6 moved
want bin/.local/bin/claude-approval-queue-reminder 6 moved
want tests/approval-queue.test.sh 6 moved
want tests/drafter-render-prompts.mjs 6 deferred:p5
want tests/fixtures/docs-page-chain/ 6 deferred:p5
want claude/.claude/workflows/docs-page-chain.js 3 drafter
pin=$(git -C "$ws" rev-parse HEAD)
bad=$(awk -F'\t' 'NR > 1 && $7 != "'"$pin"'"' "$tmp/map.tsv" | wc -l)
[[ $bad -eq 0 ]] && echo "ok   every row records the pin" || { echo "FAIL $bad rows lack the pin"; fail=1; }
cols=$(head -1 "$tmp/map.tsv")
[[ $cols == $'source_repo\told_path\tnew_repo\tnew_path\tinitiative\tstate\tpin' ]] \
  && echo "ok   map columns" || { echo "FAIL map columns: $cols"; fail=1; }

# docs rows equal the entries counted apart from the classifier
entries=$(find "$d/specs" "$d/plans" "$d/research" -mindepth 1 -maxdepth 1 | wc -l)
docrows=$(grep -c "^workstation	$S/" "$tmp/map.tsv")
[[ $entries -eq $docrows ]] && echo "ok   $docrows docs rows for $entries entries" || { echo "FAIL $docrows docs rows for $entries entries"; fail=1; }
codeonly=$(awk -F'\t' '$2 !~ /^docs\// && $6 != "history"' "$tmp/map.tsv" | tail -n +2 | wc -l)
[[ $codeonly -eq 15 ]] && echo "ok   15 code rows" || { echo "FAIL code rows: $codeonly"; fail=1; }

# per-repo counts printed: stays, leaves-with-pings, and flagged rows count under workstation
total=$(grep -c . "$tmp/map.tsv")
for pair in "workstation	5" "approval-queue	10" "poplar	2" "total	$((total - 1))"; do
  if grep -qx "$pair" <<< "$out"; then echo "ok   count line '${pair/	/ }'"; else echo "FAIL missing count line '${pair/	/ }' in: $out"; fail=1; fi
done

# the brief: one Decide block per flagged and collision-differs row, and it passes the queue's check
blocks=$(grep -c '^### Decide:' "$tmp/calls.md")
expect=$(awk -F'\t' '$6 == "flagged" || $6 == "collision-differs"' "$tmp/map.tsv" | wc -l)
[[ $blocks -eq $expect && $blocks -eq 3 ]] && echo "ok   $blocks Decide blocks" || { echo "FAIL $blocks Decide blocks, want $expect"; fail=1; }
checker="$HOME/.dotfiles/approval-queue/src/check-brief.ts"
if [[ -f $checker ]] && command -v node >/dev/null; then
  if node "$checker" design "$tmp/calls.md" >/dev/null 2>&1; then echo "ok   brief passes check-brief"; else echo "FAIL brief fails check-brief"; fail=1; fi
else
  echo "skip brief check (no check-brief on this machine)"
fi

# scope harness: the outside canary never leaks, the in-scope canary does appear
cat > "$tmp/run-classify.sh" <<EOF
#!/usr/bin/env bash
set -e
copy=\$(mktemp -d)
cp -a "$ws" "\$copy/ws"
printf 'x\n' > "\$copy/ws/docs/superpowers/plans/2026-02-01-\${SCOPE_CANARY_IN}-plan.md"
"$tool" --ws "\$copy/ws" --agents-json "\$SCOPE_AGENTS_JSON" \
  --map "\$SCOPE_OUT_DIR/map.tsv" --calls "\$SCOPE_OUT_DIR/calls.md"
rm -rf "\$copy"
EOF
chmod +x "$tmp/run-classify.sh"
bash "$harness" "$tmp/run-classify.sh" || fail=1

exit $fail
