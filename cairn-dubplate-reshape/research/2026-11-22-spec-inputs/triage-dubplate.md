process 43, ordinary 20, unsure 0

# Triage of the loose word "pass" in dubplate

## Files named for the old process

- `.claude/skills/dubplate-pass/` (the skill directory and its `name: dubplate-pass`); the file's hits are counted below only where the line itself uses the old sense.

## process

.claude/skills/dubplate-pass/SKILL.md:2: name: dubplate-pass
.claude/skills/dubplate-pass/SKILL.md:4: The dubplate adapter for the lean pass process: gate, fast lane, full-suite home, worktree setup,
.claude/skills/dubplate-pass/SKILL.md:6: resuming, or closing a dubplate pass, or when a fresh dubplate session follows a STATUS launch
.claude/skills/dubplate-pass/SKILL.md:10: # Dubplate pass
.claude/skills/dubplate-pass/SKILL.md:16: ## Rules the pass carries
.claude/skills/dubplate-pass/SKILL.md:23: records each running pass's session name and id. The box (`5.78.148.42`) is production: no writes
.claude/skills/dubplate-pass/SKILL.md:31: - **Concurrent passes.** Passes run inside a round, one at a time unless the round design pairs
.claude/skills/dubplate-pass/SKILL.md:32: them. Each design names the files it touches, so two passes never edit the same one. With two
.claude/skills/dubplate-pass/SKILL.md:38: spec, CH, W, PS, `docs/roster-walk.md`) is edited in place by the pass that changes what it says,
.claude/skills/dubplate-pass/SKILL.md:39: as a task in that pass. There is never an owed list.
.claude/skills/dubplate-pass/SKILL.md:41: "Rounds to 0.8" section of BACKLOG. A pass's plan reads the items tagged `#pass:<its pass>`.
.claude/skills/dubplate-pass/SKILL.md:53: - **Dependency sweep.** The sweep runs once a round, as the first task of the round's first pass
.claude/skills/dubplate-pass/SKILL.md:82: `Makefile` as gate machinery, which promotes a scoped run to full. The pass whose first task is the
.claude/skills/dubplate-pass/SKILL.md:85: time, never coverage. Other passes pass no `--base`.
.claude/skills/dubplate-pass/SKILL.md:169: A stop is a question `advisor.md` "What always stops" lists, or a pass with no task left. Commit and
.claude/skills/dubplate-pass/SKILL.md:194: with master. A pass whose first task moves `go.mod`, `go.sum`, or `web/package*.json` passes
.claude/skills/dubplate-pass/SKILL.md:196: exclude the sweep; any other pass passes no `--base`. A `--base` that is not a full 40-hex commit
.claude/skills/dubplate-pass/SKILL.md:203: pass touched `cmd/harness` or `internal/harness`, also run
.claude/skills/dubplate-pass/SKILL.md:239: - Archive the plan with `git mv docs/plans/<this-pass>.md docs/archive/plans/`.
CLAUDE.md:48: named in the plan and built by the pass that first consumes it, and nothing is exported ahead of a caller.
CLAUDE.md:62: - `BACKLOG.md`: open items, tagged `#round:<name>` or `#pass:<name>` for the round or pass that takes each, with the
CLAUDE.md:151: pass end fans out by surface and passes the visual identity spec's path to the `web/` reviewers.
CLAUDE.md:212: each running pass's session name and id.
docs/STATUS.md:4: **Round structure is paused after passes 1 and 2 of 3, at Geoff's request on 2026-11-20.** `structure-base` (PR #18, `5d1e6e9`)
docs/STATUS.md:5: and `structure-keys` (PR #19, `c286e3d`) are merged. Pass 3, `structure-doctor`, has no worktree, branch, or session: its planner
docs/STATUS.md:16: Pass `structure-base` (PR #18, merged) moved code only: `_salvage` left the tree, `internal/engine/store` became
docs/STATUS.md:18: Pass `structure-keys` (PR #19) moved every setting into the package that reads it, each with a `config.go`, a
docs/STATUS.md:22: `intake-1` is the last product pass on master. A passing album waits in `matching` with no exit until
docs/STATUS.md:24: pass carries sits in BACKLOG under its `#round:<name>` or `#pass:<name>` tag.
docs/STATUS.md:30: Pass 3 of round `structure`, `structure-doctor`, is next, per BACKLOG's "Rounds to 0.8"; `intake-2` takes #159.
docs/STATUS.md:37: governs: `proposed` settles nothing, and `active` means Geoff approved it. G16 and G17 sit in its "Pass 3: process",
docs/STATUS.md:38: and the `cairn-run-gate` changes in "Pass 1: fixes and settings". dubplate edits nothing in `~/.dotfiles`, the
docs/STATUS.md:42: - `gate-1` goes ahead on G1 to G15 and G18. G14 and G15 change the `dubplate-pass` adapter only.
docs/STATUS.md:48: names `npm ci --prefix web`, and shorter default output. A pass that depends on one checks that it has landed.
docs/STATUS.md:54: - R-6d21 overrides the settings-home pass's rule that the server never reads its environment. Geoff may reopen it;
docs/standing-rules.md:10: still says 2.0). Every other pass plan weighs its surface against that
docs/standing-rules.md:17: tables, chromaprint); a pass plan names which entries it consulted and
docs/standing-rules.md:18: adopts or declines each with a reason, so no pass rebuilds what a
docs/standing-rules.md:24: named in the plan of the pass that first consumes it and built there,
docs/standing-rules.md:39: pass, over those files and the pinned binaries (rclone, golangci-lint,
docs/standing-rules.md:127: `_test.go` files) stays a warning; pass `cleanup-gate` moves it to
scripts/check.sh:31: #                             every merge gate and every pass end runs.
scripts/check.sh:799: # to the pass that wrote it and is noise to every later reader. The em

## unsure


## ordinary

.claude/skills/dubplate-pass/SKILL.md: 4
CLAUDE.md: 1
Makefile: 5
scripts/check.sh: 2
scripts/deploy.sh: 4
scripts/gate.sh: 1
scripts/provision.sh: 1
scripts/vale-comments.sh: 2
