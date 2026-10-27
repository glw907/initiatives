# Docs eval trust plan

Initiative: docs-system
Design: `docs-system/specs/2026-10-26-docs-eval-trust-design.md`, approved by Geoff on 2026-10-26
(Approval Queue item 20261026T195203-4051357, merge `3790dad` of glw907/initiatives#157), with
unattended planning approved.
Risk class: `runner` (the eval runner, its cases, the gate classifier and its table, and the cycle
launcher). No `live-account` step: eval trials push nothing and are denied `gh`, `git push`, `ssh`,
and `approval-queue`.
Repos: glw907/cairn-cms (main checkout `/var/home/glw907/Projects/cairn-cms`, branch
`docs-eval-trust`) and glw907/workstation (main checkout `/var/home/glw907/.dotfiles`, branch
`docs-eval-trust`).
Executor: `cairn-cms-docs-eval-trust`, Sonnet at medium, launched from the cairn-cms main checkout,
under `conductor-cairn-cms`.
Path estimate: 280 minutes (T1 65, T2 60, T5 30, T6 80, close 45). T3 pairs with T1. T4 runs inline
while T2's acceptance run waits. Design estimate 300; the stop line is the design's 600.
Review: the `plan-reviewer` mechanics lens and a fold, per `spec-plan-review` for a `runner` plan
(`docs-system/research/2026-10-26-docs-eval-trust-plan-review-mechanics.md`).

`run.mjs` below means `node .claude/skills/cairn-docs/evals/run.mjs`, run from the pass worktree as
a background Bash command after the branch's changes are committed.

## Pre-flight

None. Both planning probes below ran clean on pavilion on 2026-10-26, so no step needs Geoff.

Launch dependency (no Geoff step): the cycle `cairn-docs-cycle-2026-10` has merged or closed its
`docs-fix/*` PRs. Neither existed when this plan was written; their content waits on Geoff's triage
ruling. The conductor checks this before the launch (its prompt step 2).

## Planning probes

**Fixture trust.** A detached worktree of cairn-cms at `~/.cache/cairn-docs-evals/fixtures/probe`
(cut from `origin/main` `4c6b96bc0`, with the skill deleted except `evals/` and `CLAUDE.md`
replaced by a marker line) ran `claude -p --model haiku` 2.1.310 with `ANTHROPIC_API_KEY` unset:

- `--max-turns 1 "say ok"` replied `ok` with result `success`, no trust or permission refusal,
  and no permission denials. `apiKeySource` was `none` and `cairn-docs` was absent from the
  init `skills` list.
- `memory_paths.auto` still pointed at
  `~/.claude/projects/-var-home-glw907-Projects-cairn-cms/memory/`, main's project memory, since
  Claude Code maps a linked worktree to its main repository's project. A second run with
  `CLAUDE_CODE_DISABLE_AUTO_MEMORY=1` reported `memory_paths: null`.
- In that second run, a `Skill` call naming `cairn-docs` returned `Unknown skill: cairn-docs`.
  The model listed exactly two loaded `CLAUDE.md` files, `~/.claude/CLAUDE.md` and the fixture's,
  and quoted the marker line.
- `~/.cache` and the cairn-cms checkout share device 56, so `cp -al` from the prepared
  `node_modules` still works. The only `.claude/` or `CLAUDE.md` on the fixture root's ancestor
  path is `~/.claude/`, the user scope every session loads in both arms.

The probe ran no Edit, Bash, or gate call; T1's acceptance trial is the first that does, and a
standing answer covers a refusal there. The same leak shows in the loop pass's control run:
`new-page-trap-docs-eval-control-1` in run `20261027-011510` had no `cairn-docs` in its init skills,
yet its `Skill` call returned `Launching skill: cairn-docs`, found by walking up to the main
checkout's `.claude/skills/`.

**Near-miss turn cap.** The turn index is the 1-based position of the top-level assistant message
(by `message.id`, `parent_tool_use_id` empty) that holds the `Skill` call.

| Run | Skill calls | Latest call | Near-miss calls | Near-miss session length |
| --- | --- | --- | --- | --- |
| `20261027-025209` | 30 | turn 11 (`rename-export-main-1` and `-3`) | all at turn 1 or 2 | 3 to 18 turns, median 5 |
| `20261026-223242` | 30 | turn 20 (`code-and-docs-main-3`, `cairn-docs`) | all at turn 1 or 2 | 2 to 14 turns, median 4 |

The latest call came after turn 4, so under the planning brief's rule ("If any skill call in any
case came after turn 4, set the near-miss cap above it") the cap is `maxTurns: 21`. No near-miss
session in either run reached 21 turns, so the cap only guards a runaway. A proxy that scales each
session's cost by the turns it keeps puts a cap of 4 at about 15% of a full run's cost and a cap of
12 at about 2%. Session start-up dominates a near-miss session's cost, so no turn cap recovers the
47% the design cites. Every late call came in an edit case that loaded the skill once it reached a
docs edit, and every near-miss call of any skill came at turn 1 or 2. The packet asks Geoff about
cap 4 (Close step 3).

**Eval minutes.** From `result.duration_ms` in run `20261027-025209`, a session averages 4.4
minutes for `deficiency`, 0.4 for `new-page-trap`, 0.6 for `fact-checker-key`, and 0.2 to 1.1 for
a near-miss case. A two-arm regression run is about 32 session-minutes per arm, so about 16 minutes
of wall time at four in parallel, plus grading. The loop pass's 48-session runs took 34 to 39
minutes of wall time.

## Standing answers

From the design, applied without Geoff:

- **`deficiency` misses pass^3 on `main` under clean fixtures, or the control doesn't drop on it.**
  It stays in capability, and `new-page-trap` carries the control check alone.
- **A sound control drops no case that needs the skill.** The pass ships the isolation and the
  rest, and the packet raises adding a positive regression case as an ask. That would change the
  design's outcome.
- **A session is lost again.** The end-of-session record captures the cause, the runner reruns it
  once, and the PR reports the count. #89 stays open; it closes only after about 150 graded
  sessions with no loss.
- **A fixture outside the repo hits a trust or permission refusal.** Probed before launch: none.
  A refusal mid-run is a harness fault (below).
- **An estimate overrun.** Go on up to 600 path minutes; past that, the clock stop.

From the plan:

- **A harness fault in any run** (a control arm that launches or lists `cairn-docs`, a missing skill
  in the `main` arm, an ancestor check that refuses, a denied gate command, a trust or permission
  refusal). Trace it, fix or route around it in the runner, list the fix in `## Decisions`, and
  rerun that run. A fault never counts against a case. A cause that returns after its fix gets one
  structural fix; if it returns again, escalate it in the PR and finish the other tasks. T6 step 1
  is the one item the pass can't escalate without missing its outcome, so a fault there that can't
  be routed around is a STOP for the conductor.
- **`main` misses pass^3 on a regression case in T6.** Report the row as it is. The bar compares
  the arms in the same run.
- **T6 step 2 shows a drop.** Its two arms share one overlay and one runner, so a gap between them is
  noise, not a branch defect. Rerun the case for three more trials on both arms, as the change rule
  says (`run.mjs docs-eval-trust main --case <id> --trials 3`), report both tables, and never trace
  it as a runner defect.
- **An errored session** (`is_error` on a subtype other than `error_max_turns`, or a subtype other
  than `success` or `error_max_turns`). Excluded from the rates. The runner reruns a no-result
  session once, unprompted; the executor reruns nothing else by hand and reports it.

## Decisions taken in planning

- **The ancestor check exempts `$HOME/.claude/`.** The design says no ancestor of the fixture root
  may hold a `CLAUDE.md` or `.claude/`. `~/.claude/` is on every path under `$HOME` and is the user
  scope, the same in both arms, so a literal check would refuse every run. The check refuses any
  other ancestor `CLAUDE.md` or `.claude/`, including a `$HOME/CLAUDE.md`.
- **Sessions run with `CLAUDE_CODE_DISABLE_AUTO_MEMORY=1`.** A fixture is a linked worktree of
  cairn-cms, so without it every session loads main's project memory (probe above). The memory is
  the same in both arms, but it sits outside both arms' files and holds docs-process notes. One
  environment line removes it.
- **A control is `run.mjs main main --control`.** With `--control`, the first ref's arm is the
  control: its overlay is laid as usual, then `.claude/skills/cairn-docs/` is deleted except
  `evals/`. Its label is `control` and its recorded overlay hash carries a `-control` tag, so two
  arms on one ref don't collide. A second ref is required. The design writes this as
  `run <control> main`; with clean fixtures, a control branch is no longer needed.
- **The control bar counts only the cases that need the skill**, `new-page-trap` and a graduated
  `deficiency`. A near-miss row can drop in the control arm for nothing: its `CLAUDE.md` still names
  the skill, and an `Unknown skill` call fails `skillNotCalled`. Other rows are reported, not
  counted.
- **T6 step 2 runs as the design names it**, with the regression suite only. This branch edits no
  overlay path, so both arms share an overlay and a runner, and the run shows the new runner
  fault-free on both arms. The rule's capability suite proves a target case, and this pass has none.
- **Two runs make the 12-session proof.** `--case` takes one id, so T5 runs `deficiency` and
  `new-page-trap` separately, six sessions each, rather than widening the flag.
- **The `retried` field becomes `lost`**, holding the first attempt's end-of-session record. The
  design lists `retried` as write-only; the PR body now reads `lost`.
- **No CHANGELOG entry.** Nothing under `.claude/` or `scripts/checks/` ships in the package
  (`package.json` `files`).

## Ground rules for the executor

- Edit only the files each task names. Never edit `SKILL.md`, `.claude/rules/*`,
  `.claude/agents/docs-fact-checker.md`, `CLAUDE.md`, `evals/cycle-prompt.txt`, `evals/history.md`,
  or `evals/sources.md`. The cycle owns the last two, and the design keeps the measured process
  fixed.
- Every `run.mjs` run starts as a background Bash command from the pass worktree, after the
  branch's changes are committed. Wait for it to exit. Read every failing trial's transcript before
  reporting its row.
- If the cycle's `docs-fix/*` PRs merged, the branch starts from that `main`, and their changes to
  `evals.json` and the case prompts stay.
- Headless-session behavior the harness already handles: a denied compound command that the session
  reissues plainly is not a fault, and subagents run in the foreground
  (`CLAUDE_CODE_DISABLE_BACKGROUND_TASKS=1`). glw907/cairn-cms#149 Decisions 7 and 8 record why.

## Tasks

### T1. Isolation (65 minutes, runner; pairs with T3)

Outcome: each trial's fixture lives outside every repository, each session loads only its arm's
docs-process files, and a control arm truly lacks the skill.

Files: `.claude/skills/cairn-docs/evals/run.mjs`, `run.test.mjs`, `README.md`.

- The fixture root is `~/.cache/cairn-docs-evals/fixtures/`, created with `recursive: true`.
  Fixtures are `<root>/docs-eval-<run>-<stem>`, still added with `git worktree add --detach` from
  the repo. `pruneFixtures` scans the new root. The prepared `node_modules` stays where it is.
- At start, before any fixture, the runner walks from the fixture root up to `/` and refuses the
  run (exit 1, naming the path) on any `CLAUDE.md` or `.claude/` it finds, except `$HOME/.claude/`.
- `sessionEnv` adds `CLAUDE_CODE_DISABLE_AUTO_MEMORY=1`.
- `--control` follows the planning decision above. In the control arm, a harness fault is either an
  init `skills` list holding `cairn-docs`, or a `Skill` call naming `cairn-docs` whose output is not
  an `Unknown skill` error. A missing `cairn-docs` in the init skills stays a fault in the other arm.
- README: `--control` in one sentence, matching the new behavior.

Acceptance: `run.mjs main main --control --case deficiency --trials 1` completes with zero faults.
`deficiency` installs `node_modules`, edits docs, and runs the gate, so it is the first trial that
exercises tools in the new location. Each transcript's init `cwd` is under the new root, and the
control trial's init shows no `cairn-docs` and a null `memory_paths`.

Test: `run.test.mjs` adds the ancestor check against a temp tree (a `.claude/` ancestor refuses,
`$HOME/.claude/` passes), the control deletion on a fixture tree, and the control faults against
canned stream-json: a `Launching skill` result and an init list holding `cairn-docs` fault, and an
`Unknown skill` result does not.

### T2. Reliability and cleanup (60 minutes, runner)

Outcome: a lost session leaves a record that can trace it (#89), the runner never blocks its event
loop while sessions stream, two runs can't share a folder, the near-miss cases stop at 21 turns and
still grade, and the runner keeps no field nothing reads.

Files: `.claude/skills/cairn-docs/evals/run.mjs`, `run.test.mjs`, `evals.json`, `README.md`.

- End-of-session record, on each trial's result in `results.json`, from a pure exported
  `endRecord(...)` builder: exit code, signal, the last stream event's `type` (and `subtype` when
  present), bytes written to the transcript, and the runner's peak event-loop delay so far in
  milliseconds. The delay comes from `perf_hooks.monitorEventLoopDelay`, `.enable()`d at run start;
  it reports nanoseconds, so divide `max` by `1e6`. Every return path of `runTrial` after the
  session carries the record, including the timeout, errored, and aborted returns.
- Lost sessions: the rerun keeps the first attempt's record as `lost: { transcript, ...record }` in
  place of `retried`.
- No blocking calls inside the pool: every git, tar, and copy call in `makeFixture`, in
  `extractOverlay`, in grading, and in the fixture removal runs through an async spawn, `commitAll`
  and `git status --porcelain` included. Errors keep their stderr in the thrown message. The setup
  modules and the pre-pool work (`overlayHash`, `prepareModules`) may stay synchronous. The
  `SIGINT` and `SIGTERM` handler keeps a synchronous remover, since it exits at once.
- Unique run folders: the run id gains `-<pid>`. `STATE_ROOT` is created with `recursive: true`,
  then the leaf without it, so an existing folder refuses the run.
- Near-miss cap: a case may carry `maxTurns`, and `validateEvals` checks it is a positive integer.
  `claudeArgs` passes `--max-turns`. Each `near-miss-*` case takes `maxTurns: 21` (planning probe).
  Claude Code 2.1.310 marks an `error_max_turns` result `is_error: true`, so `sessionErrored` returns
  false for that subtype before it tests `isError`.
- Cleanup: remove `unknownJudge` and `diagnostics` from the trial record, along with
  `skillBeforeDocsEdit`, the `attempts` half of `classifyDenials`, and their tests once nothing reads
  them. `deleteOverlay` derives its set from `overlayPaths` over the fixture's file list, so the
  overlay set is written once. The usage line lives only in `README.md`; the header comment points
  there.

Acceptance: `run.mjs main --case near-miss-01 --trials 1` grades, and its result holds all five
end-of-session fields.

Test: `run.test.mjs` covers `endRecord` with all five inputs, `maxTurns` in `claudeArgs` and
`validateEvals`, a canned `{"type":"result","subtype":"error_max_turns","is_error":true}` that
grades, the folder refusal, and the derived overlay deletion against the existing overlay fixture.

### T3. Gate tier (35 minutes, runner; pairs with T1)

Outcome: a diff confined to `.claude/` runs `test:emit` and no other static check, component, or
e2e leg (#91).

Files: `scripts/checks/gate-table.json`, `scripts/checks/gate-tier.mjs`,
`src/tests/unit/gate-tier.test.ts`, `docs/internal/pass-gate-tiers.md`.

- A `harness` bucket with the pattern `.claude/`; `test:emit` lists it.
- `gate-tier.mjs`: the component-leg skip (`gate-tier.mjs:468-470`) also applies when every path
  is a docs, harness, or no-check path. Without it, `componentPlan` runs the whole component
  project for a `.claude/`-only diff ("nothing under src/ to select from").
- `gate-tier.test.ts`: the bucket-pattern table (`:57-86`) gains
  `['harness', '.claude/', '.claude/skills/cairn-docs/evals/run.mjs']`.
- The bucket table and the skip rule in `pass-gate-tiers.md` gain the bucket.
- Both table files are on the classifier's protected list, so the PR waits for CI green.

Acceptance: `node scripts/checks/gate-tier.mjs --fast --range <base>..<a commit touching only
.claude/skills/cairn-docs/evals/run.mjs>` prints the type check (`npm run check`) and `test:emit`,
and no component or e2e leg.

Test: a `gate-tier.test.ts` case for a `.claude/`-only diff, and a mixed diff that still selects
the other buckets' checks and the component leg.

### T4. Launcher guard (10 minutes, runner; inline during T2's acceptance run)

Outcome: `cairn-docs-cycle` refuses any argument but `--dry-run` (workstation #43).

Files: in the workstation worktree `/var/home/glw907/.dotfiles/.claude/worktrees/docs-eval-trust`,
`bin/.local/bin/cairn-docs-cycle`, `tests/cairn-docs-cycle.test.sh`, and one `run` line in
`scripts/check.sh`.

- Any argument other than a lone `--dry-run` prints `usage: cairn-docs-cycle [--dry-run]` to stderr
  and exits 2, before the pull or any launch.
- The test runs the worktree's script with `CAIRN_DOCS_CYCLE_REPO=/nonexistent`, so even a broken
  guard exits 1 at "no checkout" and starts nothing. It checks that `--help` and `--dry-run --x`
  exit 2 with the usage line. Never run the linked copy in `~/.local/bin` with a stray flag: it
  starts a real cycle.
- thinkpad-x1 gets the change on its next dotfiles pull; nothing else is needed there.

Acceptance: `bash scripts/gate.sh` passes in the workstation worktree.

### T5. Proof and graduation (30 minutes, runner)

Outcome: `deficiency` moves to the regression suite if it holds pass^3 on `main` and the control
drops on it under clean fixtures (#88).

1. `run.mjs main main --control --case deficiency --trials 3` (6 sessions).
2. `run.mjs main main --control --case new-page-trap --trials 3` (6 sessions).
3. If `deficiency` is 3/3 on `main` and the control arm scores below `main` on it, set its `suite`
   to `regression` in `evals.json` and commit. Otherwise apply the first standing answer and leave
   it.

Both tables go in the PR body.

### T6. The end-to-end runs (80 minutes, runner)

On the final branch, committed:

1. `run.mjs main main --control --suite regression --trials 3` (78 sessions with `deficiency`
   graduated, 72 without). Bar: the control arm below `main` on `new-page-trap` or a graduated
   `deficiency`, with zero harness faults. Other rows are reported, not counted.
2. `run.mjs docs-eval-trust main --suite regression` (the same count). Bar: no fault, and no drop
   that survives the change rule's rerun (standing answer).

Both tables, each run's lost and rerun counts, and each `lost` record go in the PR body.

### Close (45 minutes)

1. Whole-branch `diff-reviewer` on each PR, loading `ts-conventions` for the `.mjs` and `.ts`
   files, then one fix chain and the fast lane again. The cairn PR's CI is its full-suite home;
   the workstation's is the dotfiles gate on the close head plus one
   `gitleaks detect --source . --log-opts main..HEAD`.
2. Each PR body opens with a `## Brief`, then what landed, the T5 and T6 tables, `## Decisions`,
   `## Planning misses`, and the score. Follow-ups go through `log-issue`. #43 and #91 close in
   their PRs. #88 closes if T6 step 1 meets its bar; otherwise it stays open for the packet's ask.
3. The conductor sends one packet with both PRs. It carries two asks:
   - **The near-miss cap.** "The cap is 21, above turn 20, the latest `Skill` call in any case, as
     the planning rule set. It saves about nothing. No near-miss session called any skill after
     turn 2 in 60 sessions, and a cap of 4 would cut about 15% of a run's cost by a rough proxy."
     Options: keep 21, or lower to 4 (recommended), filed as a cairn BACKLOG item and changed under
     the change rule in a later pass. The answer doesn't hold the merge.
   - **A positive regression case**, only if T6 step 1 missed its bar (the design's standing
     answer).
4. Merge order: glw907/workstation first, then glw907/cairn-cms. The conductor pulls both main
   checkouts.

## End-to-end check

T6: the control arm scores below `main` on a case that needs the skill, with zero harness faults,
and the run on the branch shows no fault and no lasting drop.
