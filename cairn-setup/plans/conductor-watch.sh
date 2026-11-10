#!/bin/bash
# Emits one line per change in: open PRs (cairn-cms, workstation), gate dist-tags,
# the newest clean-room run (naive state.json or scripted.jsonl/run-record.md), and the executor's session state.
prev=""
while true; do
  cur=""
  cur+="cairn PRs: $(gh pr list -R glw907/cairn-cms --json number,headRefName,isDraft --jq 'map("#\(.number) \(.headRefName)\(if .isDraft then " draft" else "" end)")|join(", ")' 2>/dev/null || echo '?')"$'\n'
  cur+="workstation PRs: $(gh pr list -R glw907/workstation --json number --jq 'map("#\(.number)")|join(",")' 2>/dev/null || echo '?')"$'\n'
  cur+="gate: ccs=$(npm view create-cairn-site dist-tags.gate 2>/dev/null || echo '?') engine=$(npm view @glw907/cairn-cms dist-tags.gate 2>/dev/null || echo '?')"$'\n'
  d=$(ls -dt /var/tmp/cleanroom/*/run 2>/dev/null | head -1)
  if [ -n "$d" ]; then
    id=$(basename "$(dirname "$d")")
    if [ -f "$d/state.json" ]; then
      st=$(python3 -I -c 'import json,sys;s=json.load(open(sys.argv[1]));print(s.get("phase") or s.get("status") or s.get("step") or "?")' "$d/state.json" 2>/dev/null || echo unreadable)
      cur+="run $id naive: $st"
    elif [ -f "$d/scripted.jsonl" ]; then
      cur+="run $id scripted: $(tail -n 1 "$d/scripted.jsonl" 2>/dev/null | cut -c1-160)"
    else
      cur+="run $id: no state.json or scripted.jsonl yet"
    fi
    fl=$(tmux capture-pane -p -S -400 -t "cleanroom-$id" 2>/dev/null | grep -m1 -E 'scripted leg (failed|passed)|Setup can.t continue')
    [ -n "$fl" ] && cur+=" | PANE: $(echo "$fl" | cut -c1-120)"
    [ -f "$d/run-record.md" ] && cur+=" | GRADED: $(grep -m1 '^Outcome:' "$d/run-record.md")"
    cur+=$'\n'
  fi
  cur+="executors: $(claude agents --json --all 2>/dev/null | python3 -I -c 'import json,sys
rows=[r for r in json.load(sys.stdin) if (r.get("name") or "").startswith("cairn-cms-setup-tooling-3")]
print(",".join(r.get("name")+"="+("live" if r.get("state") in ("working","idle","busy") else str(r.get("state"))) for r in rows) or "absent")' 2>/dev/null || echo '?')"$'\n'
  if [ -n "$prev" ]; then
    diff <(echo "$prev") <(echo "$cur") | grep --line-buffered '^>' | sed 's/^> //'
  else
    echo "$cur" | sed '/^$/d'
  fi
  prev="$cur"
  sleep 60
done
