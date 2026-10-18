# drafter skill-rules plan fold

Fold of the three plan reviews (`-review-contract.md`, `-review-integrity.md`,
`-review-mechanics.md`) into `plans/2026-10-18-drafter-skill-rules-plan.md`, 2026-10-18. Each
finding was checked against source at drafter `0a7a30b`, cairn `50dc211d9`, and #48's harness at
`~/.claude/jobs/e63b19d8/tmp/ft/` before it was folded. The planning session's seven rulings are
applied as given. A verification read follows.

Counts: 39 findings (contract 12, integrity 16, mechanics 11), 31 roots after convergence. 38
folded, 1 folded in part (its larger half refused). No finding was found wrong on source.

## Rulings applied

| Ruling | Findings it settles | Where in the plan |
|---|---|---|
| 1. Pair check | contract B1, integrity M1, mechanics 1 | Outcome; resolution 2 (reachable pairs via `Compare`, `since.go:50-53`; `f:72yc97`/`f:olofdb` unreachable); resolution 3 ("each bullet SR.3 proves wrong", the "N bullets" PR note); SR.3 steps 2 to 6 and acceptance; Close PR body; merge row 2; Later |
| 2. Escalation is a miss | contract M1 | Standing answer 3 ("It is a miss in the raw count"); resolution 7 grade (`read.go:59`, classification for the record only) |
| 3. Unplaced classified | contract M2, integrity M5 (fork, option a), mechanics 10 | Resolution 7 grade (from `record.json` via `findings.py`); SR.4 row fields |
| 4. First try | contract M5, integrity F2 (option a) | Resolution 7 "First try" bullet |
| 5. Run independence | contract M3, integrity M4 | Resolution 7 session bullet (`CLAUDE_CODE_DISABLE_AUTO_MEMORY=1`, quoted from code.claude.com/docs/en/memory: "To disable auto memory via environment variable, set `CLAUDE_CODE_DISABLE_AUTO_MEMORY=1`"; memory is "Per repository, shared across worktrees") and after-run bullet (drafter worktree HEAD and the two files, restore with `checkout --`) |
| 6. Evidence durability | integrity M2, integrity M3, mechanics 6 | Depends on: harness copied to `~/.claude/jobs/drafter-skill-rules/ft/` (`/var/home` is btrfs, `/tmp` tmpfs, checked with `df -T`), every edit listed, grep gate on `e63b19d8`, `change-read`, `50dc211d9`, `3\.1758`; resolution 7 last bullet; SR.3 and SR.4 write to `<job>` |
| 7. Positive controls | contract M4 | Resolution 6 closing bullet; resolution 7 "Positive controls" bullet with the scaling rule `ceil(17 × N / 21)` (15 of 18, 13 of 15); SR.4 pre-flight order |

## Contract review

- B1, the pair check: folded under ruling 1 (root shared with integrity M1 and mechanics 1).
- M1, escalation stated two ways: folded under ruling 2.
- M2, introduced Unplaced passes: folded under ruling 3.
- M3, runs not independent: folded under ruling 5. Verified: `tweak.sh` passes `--add-dir` to the
  docs and skill directories under `acceptEdits`, and `format.md` is a symlink to
  `docs/blueprint-format.md`.
- M4, no positive control: folded under ruling 7.
- M5, first try undefined: folded under ruling 4.
- m1, vacuous two-conflict row: folded in SR.1 (distinct texts, `"facts":[]` literally). Verified:
  the builder's text is "they disagree" (`blueprint_change_test.go:136`). Root shared with
  mechanics 9.
- m2, missing "fails today": folded in SR.1. Verified: `completeBlueprintRead` returns the
  consistency escalation (`blueprint.go:217`) before the `fix` check (`:228`).
- m3, partial sample: folded in resolution 7's bar bullet.
- m4, section-read tally: folded in SR.4 (the definition, "prompts 1 to 5 of 15", "sessions that
  read the section, of 21").
- m5, prompt 7 too easy: folded in part. The PR body states prompt 7 exercises only the "the item
  goes" branch (Close). Refused: rewriting prompt 7 now. The design has the prompts written before
  the skill changes, the per-prompt counts already show an easy prompt, and a new removal would
  need its own probing for a gain the rate line already exposes.
- m6, "the checks" wording: folded in resolution 4 and its table ("the steps (the actions the
  reader takes)").

## Integrity review

- M1, pair rule missing: folded under ruling 1 (root at contract B1).
- M2, evidence on tmpfs: folded under ruling 6.
- M3, stale harness constants: folded under ruling 6. Verified each constant: `OUT` in all four
  `.sh` files, `DWT=.../change-read` in `read.sh` and `tweak.sh`, `50dc211d9` in `base.sh`,
  `control.sh`, `read.sh`, `tweak.sh`, `spend.py`'s `BASE = 3.1758…`, hardcoded paths in
  `analyze.py` and `findings.py`. (`control.py` holds no jobs path, as the verification read
  noted; the grep gate covers it either way.) `tweak.sh` has no `git clean` and no HEAD
  check. Root shared with mechanics 6.
- M4, sessions can edit drafter files: folded under ruling 5 (root at contract M3).
- M5, Unplaced hides introduced conflicts: folded under ruling 3. The optional product note
  (`--json`'s `demoted` can't tell the two kinds apart, `pipeline.go:93-96`) is folded into
  Close's backlog #6 entry, since it is one clause.
- M6, meter misses open reservations and dead sessions: folded in standing answer 4 (`total +
  open.worst - baseline`; a session with no `result` event charged $0.90) and in `spend.py`'s
  edit. Verified: `ledger.go` sums `Total` from settled lines only and `Open.Worst` apart; the JSON
  keys are `total` and `open.worst` (`cmd/drafter/spend.go:53-59`).
- M7, tool timeouts: folded in resolution 7 (`timeout 900`, `run_in_background`, the next reset
  waits for the exit file, a read with no exit file resumed from the newest run directory whose
  `state.json` `head` is the commit). Verified: `state.json` carries `head`.
- m8, reset before resume: folded in standing answer 4. Verified: `checkPosition` needs HEAD to
  be the run's head or a descendant (`resume.go:94-110`).
- m9, amended base passes: folded in resolution 7's after-run check (`HEAD^` is `<base'>`).
- m10, push or main commit via `git -C`: folded in resolution 7 (`ls-remote` per run and at SR.4's
  end, main checkouts' branch and HEAD before and after).
- m11, link not restored on crash: folded in resolution 7 (`ln -sfn`, STATUS note, restore on
  resume and before the conductor removes the worktree, re-swap after a stop).
- m12, ignored files survive: folded in SR.3 step 1 (record) and resolution 7's before-run check.
- m13, branch deletion loses the correction: folded in SR.3 step 5 (`git format-patch` in
  `<job>`), SR.4's end, and merge row 2.
- m14, control 1 placement: folded in resolution 7 (control 1 before round a, control 2 after
  round c).
- m15, workstation paths in the PR: folded in resolution 7 (rows use relative paths) and Close
  (grep on the body).
- F2, infrastructure failure: settled by ruling 4 (root at contract M5).

## Mechanics review

- 1, pair check: folded under ruling 1 (root at contract B1). SR.3 is 40 minutes, as the review
  estimated.
- 2, the self-check links a breach file: folded in resolution 4 (`blueprintPrompt` named, not
  linked), SR.2's grep, and SR.4's probe check.
- 3, vale acceptance unmeetable: folded in SR.2. Verified: 3 `Google.Quotes` errors at 311:9,
  311:62, 370:8, and "in 1 file" (`SKILL.md` matches no glob).
- 4, two unsourced clauses: folded in resolution 4 (marked as drafter's own rule, sourced to
  `#items` and the "Add a failure case" row).
- 5, spend projection low: folded in standing answer 4. Verified: #48's five sessions averaged
  $0.375, its reads $0.31 to $0.35, its probe $0.19, worst session plus read $0.81.
- 6, harness edits: folded under ruling 6 (root at integrity M3).
- 7, tweak 5 cited `f:vg42j3`: folded in resolution 2. Verified in `t5.patch`: it cites
  `f:ogokfy` and `f:vg42j3`.
- 8, vacuous grep: folded in SR.2 (full `SKILL.md` path).
- 9, vacuous two-conflict row: folded at contract m1.
- 10, classify Unplaced: folded under ruling 3.
- 11, `ConsistencyPrompt` line: folded in resolution 4 and its table (line 25). Verified.

## Path and spend

- Path 160 minutes (was 140): SR.3 40 beside SR.1 35 and SR.2 30, then SR.4 90 (was 75: the
  harness edits and grep gate, two positive-control reads, the per-run checks), then Close 30. Task
  sum 225. Over the design's 150, inside the standing 300.
- Spend about $17.3 of $20: 21 sessions at $0.375 ($7.88), 27 reads at $0.34 ($9.18: 21 graded,
  2 controls, 2 positive controls, row 0 and its possible revision), probe $0.20. About $2.7 left
  for reruns and resumes, of which about $1.7 is room before the $1 cap stop. Pre-dispatch
  margin raised to $0.90.

## Against the approved design

- Outcome 4's "the base moved by that one bullet" now reads "N bullets" (ruling 1); the PR says so.
- The path estimate passes the design's 150 (160), inside the standing 300.
- Outcome 5's "same harness": sessions now run with auto memory off and under `timeout 900`; the
  flags are #48's.
- Outcome 5's bar of 17 of 21 scales if a positive control drops a prompt (ruling 7); a prompt is
  dropped, never rewritten (verification ruling on major 2).
- Three grading rules, the planning session's method calls: an introduced "Unplaced:" warning is a
  miss; a protocol breach is a miss even when the read accepts; an infrastructure failure gets one
  marked rerun. The plan lists them, with the rest, under "Departures from the design".
- Outcome 1's "each linked to its source": `blueprintPrompt` is cited by name, not linked, and two
  clauses cite drafter's own format rule; the task-section line says "steps" for "checks".

## Verification

Folded from `2026-10-18-drafter-skill-rules-plan-fold-verification.md` (0 blockers, 2 majors, 8
minors) under the planning session's rulings. All 10 folded, none refused, and the unlisted-departure
note folded too. Each was checked on source first: `tweak.sh` writes `.exit` before its post-checks;
`read.sh` has no resume mode; `citableTags` is `verified`, `external`, `vendor`
(`internal/plan/facts.go:32`); #48's streams carry a Read's `offset` and `limit`; cairn's memory
directory holds eight files.

- Major 1, a pair row 0 newly names gets no verdict: folded in SR.3 step 6 (a newly named reachable
  pair gets steps 2 to 4 under the same rule, inside the one amend and one re-read; an unreachable
  one goes to Later) and in resolution 7's positive-control bullet (a pair `ref6`, `ref7`, or
  control 1 newly names is judged, recorded, sent to `log-issue`, and doesn't move `<base'>`).
- Major 2, the executor could rewrite a prompt: folded drop-only in resolution 7 (the executor
  never rewrites a prompt; the PR names a dropped prompt and its blocking finding) and in standing
  answer 4 (the rewritten-prompt reserve is gone).
- Minor 3, the drafter-worktree check too narrow: folded in resolution 7's after-run check (whole
  tree `status --porcelain`; restore with `checkout -- .` and `clean -fd docs claude`). Verified:
  `.gitignore` holds `/drafter`.
- Minor 4, the wait and the resume under-specified: folded in Depends on (`tweak.sh` writes
  `<name>.done` after every post-check; `read.sh`'s `RESUME=<run-id>` mode) and in resolution 7
  (the wait keys on `.done` and `.read.exit`; no matching run directory is an infrastructure
  failure).
- Minor 5, the kept tag turns false: folded in SR.3 step 4 (a citable kind, its parenthetical
  updated to the new `Source:`).
- Minor 6, the memory switch unconfirmed: folded in Depends on and resolution 7 (the listing of
  cairn's memory directory before and after the probe and every run; a change is a breach).
- Minor 7, `timeout` without `-k`: folded (`timeout -k 30 900`; 124 or 137 in `<name>.exit` is the
  timeout signature).
- Minor 8, Close's reviewer rule would flag the plan's sourcing: folded in Close ("or drafter's own
  code or format rule marked as such").
- Minor 9, the section-read tally not computable: folded, not dropped. `analyze.py` can compute it
  once edited, since the stream carries `offset` and `limit`; the edit is in Depends on.
- Minor 10, headroom: folded in standing answer 4 ("about $1.7" before the $1 cap stop).
- Beyond the design, unlisted: folded. The plan gains "Departures from the design", listing the
  three grading rules as the planning session's method calls beside the other departures. The PR's
  rate section names them (Close). The departures list above records them as well.

Path and spend after this fold: 160 path minutes (task sum 225), unchanged, since major 1's extra
judging rides SR.3's existing revision budget and the harness edits fit SR.4's 90. Spend about
$17.3 of $20, unchanged, with about $1.7 of room before the $1 cap stop.

