"""Append the theme-garden autoMode lines to the dotfiles settings.

Run by Geoff: python3 -I add-theme-garden-grant.py [--no-merge | --remove], then claude-tooling-sync apply,
then commit claude/.claude/settings.json in ~/.dotfiles.
  --no-merge  Decide G-1 was no: add only the held-files line, which then says Geoff merges.
  --remove    The run's record packet: remove both theme-garden-passes lines.
It edits only autoMode.allow, skips a marker already present, and keeps the file's 2-space format. It
writes a temporary file beside the settings and renames it over them (os.replace, an atomic rename(2)
on POSIX), so an interrupted run never leaves the settings truncated.
This file is the single source of both lines' text; the plan's pre-flight item 3 points here.
"""

import json
import os
import sys

PATH = "/var/home/glw907/.dotfiles/claude/.claude/settings.json"
PLAN = "/var/home/glw907/Projects/initiatives/theme-garden/plans/2026-11-08-theme-garden-plan.md"
NO_MERGE = "--no-merge" in sys.argv
REMOVE = "--remove" in sys.argv
MARKERS = ("theme-garden-passes:", "theme-garden-passes-merge:")

if NO_MERGE:
    HOW_IT_MERGES = "Each change takes effect only after Geoff merges its PR through a packet. "
else:
    HOW_IT_MERGES = (
        "Each change merges with its pass's PR under the plan's Decide G-1 gates, and the run's "
        "record packet reaches Geoff with the held-file edits in their own row. "
    )

LINE = (
    "theme-garden-passes: Edits and commits inside git worktrees of /var/home/glw907/Projects/cairn-cms "
    "(paths under /var/home/glw907/Projects/cairn-cms/.claude/worktrees/) are allowed when they implement "
    f"task T1.6 or T2.6 of the approved theme-garden plan ({PLAN}), limited to: "
    ".claude/skills/cairn-following-public-design/**, .claude/skills/cairn-following-admin-design/references/**, "
    ".claude/skills/cairn-running-passes/references/**, and .claude/skills/cairn-writing-docs/** "
    "(its references/docs-register.md and its evals/ cases). These edits repoint paths and describe the "
    "theme contract; they change no step, rule, or trigger. "
    + HOW_IT_MERGES
    + "This clears Self-Modification and Instruction Poisoning for that text only; it does not cover the "
    "repo's .claude/settings.json, hooks, permission rules, autoMode, or memory, and it does not cover text "
    "that grants permissions or tells a session to bypass a block. Pair subagents never write these paths; "
    "they hand the content back and the executor writes it. The initiative's G2 close removes this line "
    "through Geoff's record packet."
)

MERGE_LINE = (
    f"theme-garden-passes-merge: Under the approved theme-garden plan ({PLAN}, Decide G-1), "
    "`gh pr merge <n> -R glw907/cairn-cms --merge --match-head-commit <head>` is routine for the run's "
    "conductor (conductor-cairn-cms) on the PRs of branches theme-garden-1 and theme-garden-2, once on that "
    "head: CI is green; the whole-branch diff review is folded with no open finding and no escalate verdict; "
    "npm run check:docs-gate is green; for theme-garden-1 the web-auth security read is folded with no open "
    "finding and the live admin smoke passed; and the conductor has posted the plan's gate record on the PR. "
    "Geoff's approval of that plan is the authorization for these merges. A record packet goes to Geoff "
    "after theme-garden-2 merges, and neither merge waits on it. This clears Merge Without Review only, for "
    "PRs only: never a version bump, tag, publish, or release, and never a PR outside those two branches. "
    "The initiative's G2 close removes this line through Geoff's record packet."
)

with open(PATH, encoding="utf-8") as handle:
    settings = json.load(handle)

allow = settings.setdefault("autoMode", {}).setdefault("allow", [])
if REMOVE:
    kept = [entry for entry in allow if not entry.startswith(MARKERS)]
    changed = len(allow) - len(kept)
    allow[:] = kept
    verb = "removed"
else:
    wanted = [LINE] if NO_MERGE else [LINE, MERGE_LINE]
    changed = 0
    for line in wanted:
        marker = line.split(":", 1)[0] + ":"
        if any(entry.startswith(marker) for entry in allow):
            print(f"skip: {marker} already present")
            continue
        allow.append(line)
        changed += 1
    verb = "added"

tmp = PATH + ".tmp"
with open(tmp, "w", encoding="utf-8") as handle:
    json.dump(settings, handle, indent=2, ensure_ascii=False)
    handle.write("\n")
os.replace(tmp, PATH)

print(f"{verb} {changed} line(s) in {PATH}; now run: claude-tooling-sync apply, then commit it in ~/.dotfiles")
