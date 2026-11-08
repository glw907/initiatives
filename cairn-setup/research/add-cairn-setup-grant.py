"""Append the cairn-setup-passes line to autoMode.allow in the dotfiles settings.

Run by Geoff: python3 -I add-cairn-setup-grant.py [--no-merge]. It edits only that one list,
does nothing if the marker is already present, and keeps the file's 2-space format.
"""

import json
import sys

PATH = "/var/home/glw907/.dotfiles/claude/.claude/settings.json"
LINE = (
    "cairn-setup-passes: Edits and commits inside git worktrees of /var/home/glw907/Projects/cairn-cms "
    "(paths under /var/home/glw907/Projects/cairn-cms/.claude/worktrees/) are allowed when they implement "
    "a task of the approved cairn-setup plan "
    "(/var/home/glw907/Projects/initiatives/cairn-setup/plans/2026-11-08-cairn-new-plan.md), limited to: "
    ".claude/skills/cairn-writing-docs/**, .claude/skills/cairn-running-passes/**, "
    ".claude/skills/cairn-releasing/**, .claude/agents/cairn-implementer.md, claude/CLAUDE.md, "
    "scripts/build/setup-overlay/.claude/settings.json, scripts/build/setup-overlay/.mcp.json, "
    ".claude-plugin/marketplace.json, and plugins/cairn/**. Each change takes effect only after its PR "
    "merges under the plan's merge gates (Decide 11) and its record packet reaches Geoff. This clears "
    "Self-Modification and Instruction Poisoning for that text only; it does not cover the repo's own "
    ".claude/settings.json, hooks, permission rules, autoMode, or memory, and it does not cover text that "
    "grants permissions or tells a session to bypass a block. Pair subagents never write these paths; they "
    "hand the content back and the executor writes it. The initiative's last pass removes this line."
)

MERGE_LINE = (
    "cairn-setup-passes-merge: Under the approved cairn-setup plan "
    "(/var/home/glw907/Projects/initiatives/cairn-setup/plans/2026-11-08-cairn-new-plan.md, Decide 11), "
    "`gh pr merge <n> -R glw907/cairn-cms --merge --match-head-commit <head>` is routine for the run's "
    "conductor (conductor-cairn-cms) on the PRs of passes P1, P2, P5, and P6 (branches cairn-new-1, "
    "cairn-new-2, cairn-new-5, cairn-new-6), once on that head CI is green, the whole-branch diff review "
    "is folded with no open finding and no escalate verdict, the docs gate is green, and for an auth-data "
    "pass the web-auth security read is folded with no open finding and the live admin smoke passed. "
    "Geoff's approval of that plan is the authorization for these merges. A record packet goes to Geoff "
    "and the merge does not wait on it. This clears Merge Without Review only, for PRs only: never a "
    "version bump, tag, publish, or release, and never a PR outside those four branches. The initiative's "
    "last pass removes this line."
)

with open(PATH) as f:
    data = json.load(f)
allow = data["autoMode"]["allow"]
wanted = [("cairn-setup-passes:", LINE)]
if "--no-merge" not in sys.argv:
    wanted.append(("cairn-setup-passes-merge:", MERGE_LINE))
for marker, line in wanted:
    if any(entry.startswith(marker) for entry in allow):
        print(f"{marker} already present; unchanged")
    else:
        allow.append(line)
        print(f"added {marker}")
with open(PATH, "w") as f:
    f.write(json.dumps(data, indent=2, ensure_ascii=False) + "\n")
