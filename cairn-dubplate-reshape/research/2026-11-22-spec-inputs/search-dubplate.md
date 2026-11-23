# Old-process words in dubplate at 907605c

Paths searched: `CLAUDE.md .claude docs/STATUS.md scripts .github docs/standing-rules.md Makefile`

## Strict words

`git grep -n -i -E 'pass-core|running-passes|conductor|executor|approval[- ]packet|approval[- ]queue|cairn-implementer|launch-prompts|pair subagent'`: 21 hits, all listed.

```text
.claude/instructions/api-access.md:14:  for live executors and prefer `deploy.sh` over ad-hoc edits. Read-only
.claude/skills/dubplate-pass/SKILL.md:12:Load `pass-core` first; it holds the lifecycle and the rules this adapter fills in. Paths are
.claude/skills/dubplate-pass/SKILL.md:18:- **One executor per tree.** Before any executor touches the repo or the box, run
.claude/skills/dubplate-pass/SKILL.md:34:- **Plans are just-in-time.** Plan each pass against a tree no other executor is writing, never
.claude/skills/dubplate-pass/SKILL.md:52:  sitting, and the first-launch sitting. The design approval and the packet read are `pass-core`'s.
.claude/skills/dubplate-pass/SKILL.md:63:- **Pair subagents** are `general-purpose`. The dispatch gives the adapter's worktree setup and fast
.claude/skills/dubplate-pass/SKILL.md:148:`launch-base=<sha>`, the branch head at the executor's start. Before each dispatch the session
.claude/skills/dubplate-pass/SKILL.md:155:The clock runs from the first execution commit to PR-ready (`pass-core` `executor.md`, "Score"). A
.claude/skills/dubplate-pass/SKILL.md:230:**Close checklist**: Beyond `pass-core` "Close":
CLAUDE.md:71:BACKLOG's "Rounds to 0.8" holds the run order. Process: the `dubplate-pass` skill (`.claude/skills/dubplate-pass`), loading `pass-core`.
CLAUDE.md:73:first-launch sitting. The design approval and the packet read are `pass-core`'s.
CLAUDE.md:208:- Before any executor touches a worktree, run `claude agents --json` for a live session whose cwd is that
docs/STATUS.md:7:launching the planner as the conductor prompt says. Nothing deployed. Resume from:
docs/STATUS.md:8:`~/Projects/initiatives/dubplate-server/plans/2026-11-17-structure/conductor-prompt.txt`.
docs/STATUS.md:39:standards plugin, the global `CLAUDE.md`, or `pass-core`; a finding that needs one goes to that initiative. The
docs/STATUS.md:44:  one-executor check that reads STATUS's session ids. A pass that reaches G16 first leaves it in BACKLOG #108.
docs/STATUS.md:45:- G17 (Close removes the worktree and branch) belongs to that plan as a `pass-core` step. dubplate adds nothing.
docs/standing-rules.md:123:ruling, fold, pass, and conductor tags, and a name) applies everywhere
scripts/check.sh:126:# ruling, fold, pass, and conductor tags, and a name) fails it outside
scripts/check.sh:807:  citation_narrow='ruled, conductor|Resolution R|rung [0-9]|Task [0-9]|\(C[0-9]|plans/.*\.md:[0-9]|_salvage/.*:[0-9]|Ruled, |\bR-[0-9]+[a-z]+[0-9]*'
scripts/check.sh:808:  citation_wide='ruled, conductor|Resolution R|rung [0-9]|Task [0-9]|\(C[0-9]|plans/.*\.md:[0-9]|_salvage/.*:[0-9]|Ruled, |\bR-[0-9]+[a-z]+[0-9]*|\b[Cc]ontract [A-Z]{0,2}-?[0-9]|\b[Rr]ungs?[ -][0-9]|\b[0-9]{1,2}[a-d]\b|
```

## Loose word

`git grep -n -i -E '\bpass(es)?\b'` minus the strict hits: 63 hits, all listed. `triage-dubplate.md` sorts them.

```text
.claude/skills/dubplate-pass/SKILL.md:2:name: dubplate-pass
.claude/skills/dubplate-pass/SKILL.md:4:  The dubplate adapter for the lean pass process: gate, fast lane, full-suite home, worktree setup,
.claude/skills/dubplate-pass/SKILL.md:6:  resuming, or closing a dubplate pass, or when a fresh dubplate session follows a STATUS launch
.claude/skills/dubplate-pass/SKILL.md:10:# Dubplate pass
.claude/skills/dubplate-pass/SKILL.md:16:## Rules the pass carries
.claude/skills/dubplate-pass/SKILL.md:23:  records each running pass's session name and id. The box (`5.78.148.42`) is production: no writes
.claude/skills/dubplate-pass/SKILL.md:31:- **Concurrent passes.** Passes run inside a round, one at a time unless the round design pairs
.claude/skills/dubplate-pass/SKILL.md:32:  them. Each design names the files it touches, so two passes never edit the same one. With two
.claude/skills/dubplate-pass/SKILL.md:38:  spec, CH, W, PS, `docs/roster-walk.md`) is edited in place by the pass that changes what it says,
.claude/skills/dubplate-pass/SKILL.md:39:  as a task in that pass. There is never an owed list.
.claude/skills/dubplate-pass/SKILL.md:41:  "Rounds to 0.8" section of BACKLOG. A pass's plan reads the items tagged `#pass:<its pass>`.
.claude/skills/dubplate-pass/SKILL.md:46:  so the test cannot pass vacuously. The plan-review lenses check these four.
.claude/skills/dubplate-pass/SKILL.md:53:- **Dependency sweep.** The sweep runs once a round, as the first task of the round's first pass
.claude/skills/dubplate-pass/SKILL.md:60:- **Web review passes the visual identity spec.** Dispatches to the `web/` reviewers carry
.claude/skills/dubplate-pass/SKILL.md:82:`Makefile` as gate machinery, which promotes a scoped run to full. The pass whose first task is the
.claude/skills/dubplate-pass/SKILL.md:83:round's sweep passes `--base <task start>` (a full 40-hex id) on every later fast lane. `check.sh`
.claude/skills/dubplate-pass/SKILL.md:85:time, never coverage. Other passes pass no `--base`.
.claude/skills/dubplate-pass/SKILL.md:169:A stop is a question `advisor.md` "What always stops" lists, or a pass with no task left. Commit and
.claude/skills/dubplate-pass/SKILL.md:194:with master. A pass whose first task moves `go.mod`, `go.sum`, or `web/package*.json` passes
.claude/skills/dubplate-pass/SKILL.md:196:exclude the sweep; any other pass passes no `--base`. A `--base` that is not a full 40-hex commit
.claude/skills/dubplate-pass/SKILL.md:203:pass touched `cmd/harness` or `internal/harness`, also run
.claude/skills/dubplate-pass/SKILL.md:235:  plus one gitleaks pass over `master..HEAD` with git history, the only leg that sees a secret one
.claude/skills/dubplate-pass/SKILL.md:239:- Archive the plan with `git mv docs/plans/<this-pass>.md docs/archive/plans/`.
CLAUDE.md:48:named in the plan and built by the pass that first consumes it, and nothing is exported ahead of a caller.
CLAUDE.md:62:- `BACKLOG.md`: open items, tagged `#round:<name>` or `#pass:<name>` for the round or pass that takes each, with the
CLAUDE.md:151:pass end fans out by surface and passes the visual identity spec's path to the `web/` reviewers.
CLAUDE.md:198:  owner's function, and passes its transaction when both changes must
CLAUDE.md:212:  each running pass's session name and id.
Makefile:17:# subprocess, which Go's test cache cannot see, so a cached pass can
Makefile:20:# run is verbose and the recipe fails unless all three report a pass,
Makefile:30:		printf '%s\n' "$$out" | grep -q -- "^--- PASS: $$t " \
Makefile:31:			|| { printf '%s\n' "$$out"; echo "make test: $$t did not run and pass"; exit 1; }; \
Makefile:140:# carries TestRendered's own pass event; the target keeps go test's
docs/STATUS.md:4:**Round structure is paused after passes 1 and 2 of 3, at Geoff's request on 2026-11-20.** `structure-base` (PR #18, `5d1e6e9`)
docs/STATUS.md:5:and `structure-keys` (PR #19, `c286e3d`) are merged. Pass 3, `structure-doctor`, has no worktree, branch, or session: its planner
docs/STATUS.md:16:Pass `structure-base` (PR #18, merged) moved code only: `_salvage` left the tree, `internal/engine/store` became
docs/STATUS.md:18:Pass `structure-keys` (PR #19) moved every setting into the package that reads it, each with a `config.go`, a
docs/STATUS.md:22:`intake-1` is the last product pass on master. A passing album waits in `matching` with no exit until
docs/STATUS.md:24:pass carries sits in BACKLOG under its `#round:<name>` or `#pass:<name>` tag.
docs/STATUS.md:30:Pass 3 of round `structure`, `structure-doctor`, is next, per BACKLOG's "Rounds to 0.8"; `intake-2` takes #159.
docs/STATUS.md:37:governs: `proposed` settles nothing, and `active` means Geoff approved it. G16 and G17 sit in its "Pass 3: process",
docs/STATUS.md:38:and the `cairn-run-gate` changes in "Pass 1: fixes and settings". dubplate edits nothing in `~/.dotfiles`, the
docs/STATUS.md:42:- `gate-1` goes ahead on G1 to G15 and G18. G14 and G15 change the `dubplate-pass` adapter only.
docs/STATUS.md:48:  names `npm ci --prefix web`, and shorter default output. A pass that depends on one checks that it has landed.
docs/STATUS.md:54:- R-6d21 overrides the settings-home pass's rule that the server never reads its environment. Geoff may reopen it;
docs/standing-rules.md:10:still says 2.0). Every other pass plan weighs its surface against that
docs/standing-rules.md:17:tables, chromaprint); a pass plan names which entries it consulted and
docs/standing-rules.md:18:adopts or declines each with a reason, so no pass rebuilds what a
docs/standing-rules.md:24:named in the plan of the pass that first consumes it and built there,
docs/standing-rules.md:39:pass, over those files and the pinned binaries (rclone, golangci-lint,
docs/standing-rules.md:127:`_test.go` files) stays a warning; pass `cleanup-gate` moves it to
scripts/check.sh:31:#                             every merge gate and every pass end runs.
scripts/check.sh:66:#                             gate plus one gitleaks pass over the
scripts/check.sh:799:  # to the pass that wrote it and is noise to every later reader. The em
scripts/check.sh:881:  # literal pattern. An empty list is a failure, never a pass.
scripts/deploy.sh:75:  echo "deploy.sh: --check and --apply are mutually exclusive; pass one, or neither to check." >&2
scripts/deploy.sh:93:    echo "deploy.sh: no HOST given and can't look one up (need HCLOUD_TOKEN + hcloud). Pass an IP, or provision first." >&2
scripts/deploy.sh:98:    echo "deploy.sh: couldn't resolve the musicbox server's IP via hcloud. Pass an IP, or provision first." >&2
scripts/deploy.sh:197:  echo "dubplate deploy -> $SSH_TARGET (check: nothing will be applied; pass --apply to write the box)"
scripts/gate.sh:5:# that execs cairn-run-gate passes, and keeps the lane lock and the run records
scripts/provision.sh:126:# stops the script: render_firewall_rules passes the substitution as an
scripts/vale-comments.sh:10:# Pass --check-vendor to additionally assert the vendored Survey overlay
scripts/vale-comments.sh:22:# Pass --only followed by Go file paths to read just those, as the scoped
```
