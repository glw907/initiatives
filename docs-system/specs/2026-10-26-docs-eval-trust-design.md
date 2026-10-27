# Docs eval trust

Status: drafted 2026-10-26 for Geoff's approval. Initiative: `docs-system`. Repos: cairn-cms and
the workstation (`~/.dotfiles`). Follows glw907/cairn-cms#149 (the docs improvement loop). Inputs: a
read-only grounding of BACKLOG #88, #89, and #91 against `4c6b96bc0`, and the loop pass's T5 runs
under `~/.local/state/cairn-docs-evals/`.

## Brief

This pass makes the docs evals trustworthy: a run with the skill removed will score lower, and a
comparison between two rule sets will measure only those rule sets.

The loop's evals can't do either yet. Every trial runs in a worktree inside cairn's main checkout,
so each session also loads main's `CLAUDE.md` and can reach main's `cairn-docs` skill. In the loop
pass's control run, the skill was deleted from the control arm, yet a session still loaded it (run
`20261027-011510`, `new-page-trap-docs-eval-control-1`). So the finding that no regression case
needs the skill is unproven, and every two-arm table so far has been biased toward `main`.

### What changes

- Trial worktrees move outside the repo tree, so a session sees only its arm's files.
- A control run deletes the skill outright, and a run where the skill still loads counts as a fault.
- The regression suite gains `deficiency`, a case that needs the skill, once a sound control shows it drops.
- The runner logs why a session ended, so lost sessions (#89) can be traced, and two runs can no longer share a results folder.
- The ten near-miss cases stop after a few turns. They spend 47% of a full run's cost doing a task nobody grades.
- Harness edits take a light gate tier (#91), the runner loses its write-only fields and duplicate code, and the cycle launcher refuses an unknown flag (workstation #43).

### If you approve

1. A planning session writes the plan from this design, then hands it to a fresh `conductor-cairn-cms`, and this conductor stops.
2. The executor starts only after the cycle's two fix PRs (behavior search and #87) merge, so the two never edit the same files.
3. The pass ends with one packet holding a cairn-cms PR and a workstation PR.

### Worth knowing

The leak doesn't invalidate this month's cycle. It biases a fix's branch arm toward `main`, which can hide an improvement but can't fake one. The cycle's fix PRs keep their tables, and the next monthly run measures them cleanly.

### Standing answers

The run decides these without you.

- `deficiency` misses pass^3 on `main` under clean fixtures. It stays in capability, and `new-page-trap` carries the control check alone.
- A sound control drops no regression case. The pass ships the isolation and the rest, and raises adding a positive regression case as an ask in its packet. That would change this design's outcome.
- A session is lost again. The new log records the cause, the runner reruns it once, and the PR reports the count. #89 closes only after about 150 graded sessions with no loss.
- A fixture outside the repo hits a trust or permission refusal. The planner probes this before launch. A refusal it can't route around becomes a pre-launch packet item.
- An estimate overrun. Go on up to twice the path (600 minutes). Past that, the clock stop.

## Outcome

A control arm with `cairn-docs` deleted scores below `main` on the regression suite, and both arms
of every run load only their arm's docs-process files. The cycle's change rule then measures what it
claims to.

## Scope

Isolation (cairn-cms, `.claude/skills/cairn-docs/evals/run.mjs`):

- Fixture location. Fixtures go under a directory on `/var/home` outside any repo, so `cp -al`
  still works, at `~/.cache/cairn-docs-evals/fixtures/`. The runner checks at start that no
  ancestor of the fixture root holds a `CLAUDE.md` or `.claude/`.
- Control runs. `--control` deletes `.claude/skills/cairn-docs/` except `evals/` in the
  control arm. A transcript in that arm that shows a `cairn-docs` launch is a harness fault.
- Graduation. `deficiency` moves to `regression` after a 12-session proof
  (`deficiency` and `new-page-trap`, 3 trials, control against `main`).

Reliability (#89):

- End-of-session record. Each session records its exit code, signal, last event type, bytes
  written, and the runner's peak event-loop delay.
- No blocking calls. The remaining synchronous fixture calls (`git worktree add`, the tar
  extract, `cp -al`, `git add` and `git diff`, the fixture removal) run asynchronously.
- Unique run folders. The run id gains the pid, and the runner refuses a results folder that
  already exists.

Lean and organized:

- Near-miss turn cap. The near-miss cases take a per-case `maxTurns` of 4.
  `error_max_turns` already grades. The planner first checks the `20261027-025209` transcripts:
  if any skill call there came after turn 4, the cap rises to cover it, so a late false trigger
  still counts.
- Gate tier. `.claude/` gets a `harness` bucket in `scripts/checks/gate-table.json` that runs
  only `test:emit`, with the table in `docs/internal/pass-gate-tiers.md` and its unit test updated.
- Runner cleanup. The write-only `unknownJudge`, `retried`, and `diagnostics` fields go, and so
  does the duplicate overlay set (`overlayPaths` against `deleteOverlay`). One usage line lives in
  `evals/README.md`.
- Launcher guard. `cairn-docs-cycle` exits 2 with a usage line on any argument but
  `--dry-run` (workstation #43).

## Out of scope

- #87 and the behavior-search fix. The cycle is fixing both under your ruling.
- #90. You deferred it in the cycle's triage.
- `rename-export`'s skipped fact-check. It's the cycle's fourth row.
- #86. It's an e2e install problem, outside the docs process.
- Any change to `SKILL.md`, the rules, or `docs-fact-checker`. This pass changes the
  instrument, not what it measures.

## End-to-end check

On the final branch, `run <control> main --suite regression --trials 3 --control` shows the control
arm below `main` on at least one case, with zero harness faults. Then `run <branch> main --suite
regression` shows no drop, since the branch changes the runner and falls under the change rule.

## Class and estimate

Risk class `runner`. No `live-account` step: eval trials push nothing. No pre-flight items for you.
Path estimate 300 minutes: about 150 of work, about 110 of eval runs (12 proof sessions, then about
78 sessions each for the control and the change-rule runs, four at a time), and 40 for close. The
loop pass ran 340 minutes against 275, with the eval runs as the overrun.
