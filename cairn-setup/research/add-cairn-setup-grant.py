"""Append the cairn-setup autoMode lines to the dotfiles settings.

Run by Geoff: python3 -I add-cairn-setup-grant.py [--no-merge] [--held-in-chain].
  --no-merge       Decide 11 was no: add only the held-files line, which then says Geoff merges.
  --held-in-chain  Decide 12 was no: the conductor merges held-file edits inside each pass's PR.
It edits only autoMode.allow, skips a marker already present, and keeps the file's 2-space format.
This file is the single source of both lines' text; the plan's pre-flight item 2 points here.
"""

import json
import sys

PATH = "/var/home/glw907/.dotfiles/claude/.claude/settings.json"
PLAN = "/var/home/glw907/Projects/initiatives/cairn-setup/plans/2026-11-08-cairn-new-plan.md"
NO_MERGE = "--no-merge" in sys.argv
HELD_IN_CHAIN = "--held-in-chain" in sys.argv

if NO_MERGE:
    HOW_IT_MERGES = "Each change takes effect only after Geoff merges its PR through a packet. "
elif HELD_IN_CHAIN:
    HOW_IT_MERGES = (
        "Each change merges with its pass's PR under the plan's Decide 11 gates, and that pass's "
        "record packet reaches Geoff. "
    )
else:
    HOW_IT_MERGES = (
        "A change to a file under .claude/skills/ or .claude/agents/ goes in a side PR on branch "
        "cairn-new-<n>-held, which merges only on Geoff's approve of its packet (Decide 12); every "
        "other listed file merges with its pass's PR under the plan's Decide 11 gates. "
    )

LINE = (
    "cairn-setup-passes: Edits and commits inside git worktrees of /var/home/glw907/Projects/cairn-cms "
    "(paths under /var/home/glw907/Projects/cairn-cms/.claude/worktrees/) are allowed when they implement "
    f"a task of the approved cairn-setup plan ({PLAN}), limited to: "
    ".claude/skills/cairn-writing-docs/**, .claude/skills/cairn-running-passes/**, "
    ".claude/skills/cairn-releasing/**, .claude/agents/cairn-implementer.md, claude/CLAUDE.md, "
    "scripts/build/setup-overlay/.claude/settings.json, scripts/build/setup-overlay/.mcp.json, "
    ".claude-plugin/marketplace.json, and plugins/cairn/**. "
    + HOW_IT_MERGES
    + "This clears Self-Modification and Instruction Poisoning for that text only; it does not cover the "
    "repo's .claude/settings.json, hooks, permission rules, autoMode, or memory, and it does not cover text "
    "that grants permissions or tells a session to bypass a block. Pair subagents never write these paths; "
    "they hand the content back and the executor writes it. The initiative's last pass removes this line."
)

MERGE_LINE = (
    f"cairn-setup-passes-merge: Under the approved cairn-setup plan ({PLAN}, Decide 11), "
    "`gh pr merge <n> -R glw907/cairn-cms --merge --match-head-commit <head>` is routine for the run's "
    "conductor (conductor-cairn-cms) on the PRs of branches cairn-new-1, cairn-new-2, cairn-new-5, and "
    "cairn-new-6, once on that head: CI is green; the whole-branch diff review is folded with no open "
    "finding and no escalate verdict; npm run check:docs-gate is green; for an auth-data pass the web-auth "
    "security read is folded with no open finding and the live admin smoke passed or the PR records it as "
    "not applicable with the reason; and the conductor has posted the plan's gate record on the PR. "
    "Geoff's approval of that plan is the authorization for these merges. A record packet goes to Geoff "
    "and the merge does not wait on it. This clears Merge Without Review only, for PRs only: never a "
    "version bump, tag, publish, or release, never a cairn-new-<n>-held branch, and never a PR outside "
    "those four branches. The initiative's last pass removes this line."
)

with open(PATH) as f:
    data = json.load(f)
allow = data["autoMode"]["allow"]
wanted = [("cairn-setup-passes:", LINE)]
if not NO_MERGE:
    wanted.append(("cairn-setup-passes-merge:", MERGE_LINE))
for marker, line in wanted:
    if any(entry.startswith(marker) for entry in allow):
        print(f"{marker} already present; unchanged")
    else:
        allow.append(line)
        print(f"added {marker}")
with open(PATH, "w") as f:
    f.write(json.dumps(data, indent=2, ensure_ascii=False) + "\n")
