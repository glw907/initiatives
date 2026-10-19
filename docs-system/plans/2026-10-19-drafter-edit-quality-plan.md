# drafter edit-quality pass plan: the read loop, a reviewer-grade bar, a handler warning, and the rerun

Initiative: docs-system

Design: `~/Projects/initiatives/docs-system/specs/2026-10-19-drafter-edit-quality-design.md`, from
the analysis `research/2026-10-19-drafter-edit-quality-analysis.md` and Geoff's 2026-10-19 rulings.
Facts below are quoted at drafter `main` `41939c3` (the F1 merge, glw907/drafter#50) and cairn-cms
`50dc211d9`. The format-test protocol is skill-rules' (`plans/2026-10-18-drafter-skill-rules-plan.md`,
resolution 7 and SR.4), whose harness lives read-only under `~/.claude/jobs/drafter-skill-rules/ft/`.
Reviewed by three lenses and folded: `research/2026-10-19-drafter-edit-quality-plan-fold.md`.

## Outcome

The blueprint skill gains a read loop: `drafter check`, then a change read when a key is set, fixes
on the session's own tokens, and a read again, at most three reads, with the last read after the
last change. Case 2 sends a caution with no fact-supplied handler to "Add a caveat", and a decline
rule makes the smaller edit when a request conflicts with a fact or repeats a section. `drafter
check` warns on a non-handler handler (`handler`); the `cited` warning is dropped under the
design's false-fire rule (departure 9). The change read blocks only on wrong, stuck, or
missing-state defects and returns the rest as "Nit:". No blueprint read applies house register
rules. The read's request puts the stable prefix first behind two cache breakpoints. The rerun
measures the loop on a base the whole read accepts.

- Risk class `runner` (the skill, `drafter check`, the read prompt, the assembler and request
  wire). `live-account`: API credit, budget $40 of Geoff's $200 monthly credit, API spend only.
- Executor: `drafter-edit-quality`, `sonnet` at `medium`, worktree `edit-quality`. Pair subagents
  run on `sonnet` at `medium`, `description` `edit-quality task EQ.<n>`. Test sessions run Sonnet
  at `medium`, fresh, with `CLAUDE_CODE_DISABLE_AUTO_MEMORY=1`, on Geoff's subscription.
- Path: 355 minutes. EQ.0 (30), then pair A, EQ.2 (40) with EQ.5 (65), beside the session's EQ.1
  (45), a leg of 65. Then pair B, EQ.3 (40) with EQ.4 (35), beside the session's EQ.6 (45), a leg
  of 45. Then EQ.7 (65), EQ.8 (120), and Close (30). The design's estimate is 180; 355 is inside
  the standing 360 with 5 minutes of slack (see "Departures"). The task sum is 515.
- Clock file: `pass-task-clock` in the drafter worktree's git dir, except EQ.6, EQ.7, and EQ.8,
  which run with the session's cwd in the cairn worktree and write it in that worktree's git dir
  (`git rev-parse --absolute-git-dir` from there). EQ.8 stops and records its clock before it
  removes that worktree. A wait on Geoff removes the clock file first.

### Standing answers

From the design ("Standing answers"; Geoff, 2026-10-19), and the planning session's method calls:

1. A plan up to 360 path minutes proceeds.
2. A rerun below its bar closes the pass with the result, and the packet asks what's next.
3. A base the whole read still blocks after three fix rounds is recorded, and the test runs on it.
4. The $40 meters API spend only. Test sessions run on the subscription: `tweak.sh` launches each
   under `env -u ANTHROPIC_API_KEY`, and each stream's `init` event must carry
   `"apiKeySource":"none"` (#49's 22 streams all did); a stream that doesn't halts the round. A
   session's `total_cost_usd` is reported beside the spend, never charged against it. The baseline
   `B` is `drafter spend --json`'s cycle `total` plus `open.worst` at launch, written to
   `<job>/baseline`; the pass's spend is the same sum now, minus `B`. drafter holds the bound
   itself: every pass read (in-session, `read.sh`, `row0.sh`, `agree.sh`) runs through
   `<job>/bin/drafter`, which exports `DRAFTER_CYCLE_CEILING=<B+40>` and `DRAFTER_PAGE_CAP=2`
   (`cycle_ceiling` and `page_cap` are env keys, `internal/config/env.go`), so `Reserve` refuses
   any reservation past the budget, orphaned reservations included (`ledger.go:129`: `cycle+r.Worst
   > c.Cycle` returns `ErrCycleCap`). If the billing cycle turns over mid-pass, the executor
   rewrites the ceiling as the new cycle's total plus 40 minus the pass's spend so far. Before each
   dispatch, `drafter spend --json` shows `open.count` 0. Exit 3 with `cycle cap` or `spend limit`,
   or a page escalated on rule `cap`, stops for Geoff after `notify-send -u normal`. Any other exit
   3 gets one `<job>/bin/drafter read --sync --json --resume <run-id> <BP>` (skill-rules standing
   answer 4; `read` needs the blueprint argument, `read.go:62-63`, and a resume without `--sync`
   fails `checkConfig` on the changed `mode`, `resume.go:213-214`), run with `HEAD` reset to the
   run's `state.json` `head` and before the next reset.

## Departures from the design

The packet lists each. All are the planning session's method calls (2026-10-19); none needs
Geoff's ruling before launch. Items 1 to 3 change the design's files or the skill's mechanism, so
the packet names them first.

1. **The loop commits before each read.** `drafter read` reads only a clean, committed tree (its
   help: "The tree must be clean, so each read runs on a committed blueprint, and every input is
   read from the commit the run starts at"; `requireClean` in `internal/pipeline/start.go`). The
   design's "after three reads the session commits" can't run as written. The skill notes `HEAD`
   as the base before the first edit, commits each round, then reads with `--since <base>`. When
   the third read leaves findings open, the session adds one empty commit (`git commit
   --allow-empty`) whose message lists them. An amend would make a sibling of the read's head, and
   `checkPosition` (`internal/pipeline/resume.go:95-110`) refuses a resume unless `HEAD` is the
   recorded head or a descendant; the empty commit keeps the read's head an ancestor and the tree
   unchanged, so the "no read saw" measure still compares trees.
2. **`drafter read` must print its findings.** Its text and `--json` output carry the verdict,
   scope, cost, and counts, and no finding (`writeSummaryText` in `cmd/drafter/page.go`,
   `PageResult` in `internal/pipeline/pipeline.go`). The findings sit only in `record.json` under
   the state directory, which a session would have to find by run id outside the repo. EQ.3: each
   page's result carries the blueprint read's findings (location, text, blocking), the record's
   warnings, and the escalation detail, printed in both forms. This is a new output surface in
   files the design doesn't name.
3. **The cache breakpoints reach past the assembler.** `batch.Message` is one text string and
   `buildWire` sends one text block per message with no `cache_control` (`internal/batch/types.go`,
   `request.go`), and `assemble.Build` joins the whole user turn into one string. The prefix must
   also be byte-stable across a session's reads: the change paragraph names the changed sections
   (`These sections changed: ${scope}` in `blueprintPrompt`), and the facts block lists only placed
   or cited facts (`placedFacts(view)`), so a fix that cites a new fact changes it. The cache key
   "is derived from the exact bytes of the rendered prompt up to each `cache_control` breakpoint"
   and "a single byte difference at position N ... invalidates the cache for all breakpoints at
   positions >= N" (the Claude API skill's `shared/prompt-caching.md`; "Max **4** `cache_control`
   breakpoints per request"; a 512-token minimum prefix on Opus 5.5). So EQ.4 moves the scope
   sentence out of the prompt, EQ.5 moves it to the head of the change block, and the request
   carries two breakpoints: after the inlined register, and after the facts block. `ledger.Worst`
   documents "the most a request can cost" priced with no cache tokens, but a 5-minute cache write
   costs $5 per million against $4 for input on Opus 5.5 (`internal/config/stock.toml`). EQ.5:
   Worst prices input at the higher of the input and 5-minute write rates, so the reservation stays
   an upper bound. `money.go` passes no per-request cache flag and stays frozen, so this raises
   every reservation for every seat (draft, edit, consistency, editor, smoke, dry run) by 25% of
   its input at stock prices, and a page near `page_cap` can escalate on `cap` sooner. The packet
   says the money path's pricing changes while `money.go` and `resume.go` stay untouched; the risk
   class stays `runner` + `live-account`.
4. The skill's read runs with `--sync`. The stock mode is batch, whose latency would break a loop
   the design sizes at under a minute a read (#49's reads settled in about 20 seconds).
5. Cairn holds one blueprint at `50dc211d9`, not the analysis's eleven (`git ls-tree` counts one
   `.blueprint.yaml`, also on `main` and `blueprint-pilot`). The false-fire test runs on it and on
   drafter's own fixtures, a thinner sample than the design assumed.
6. The path is 355 minutes against the design's 180, inside standing answer 1.
7. Grading rules carried from #49, restated in full: a run that fails on infrastructure gets one
   marked rerun, written under `<NAME>-r`; a protocol breach is a miss even when the read accepts
   (the loop's breaches are listed under EQ.8); an accepted read with an "Already present:" finding
   on the change or an introduced "Unplaced:" warning is not an accept; a bar is met only with
   every run made. The test sessions run under `timeout -k 30 1500` (900 before), since each now
   holds up to three reads and two fix rounds.
8. Two probes outside the 21: a loop probe, and a no-key probe for the skill's no-key branch.
9. `cited` drops. The design drops "a warning that fires falsely on cairn's blueprints", and at
   `50dc211d9` it fires on three lead-ins with no fact to cite (`bb-lead`, `push-lead`, `ver-lead`,
   each `mode: claim` with no `facts`). EQ.0 confirms they're unchanged at `<base'>`; if any isn't,
   EQ.2 builds `cited` and runs it through the false-fire test. No lead-in rule is added.
10. The skill doesn't name a nightly backstop. No nightly read exists until B4 builds it, so the
    skill's final report lists the open blocking findings to the user instead.
11. Declines on prompts other than 4 are misses, except a prompt 5 decline whose report names
    `x-editor` as the item already carrying the content and whose smaller edit is accepted.
12. A failed positive control fails the Controls row. Its prompt still runs and the bars stay at
    19 and 20 of 21, as the design states; skill-rules' drop-and-scale rule isn't inherited.
13. Judge agreement reads "misses" as first in-session reads that blocked (EQ.8).

## Depends on, checked at launch

- F1 is merged: glw907/drafter#50, merge `41939c3` (2026-10-18T23:22Z). EQ.0 rechecks against it.
- One executor per worktree: `pgrep -f` on `~/Projects/drafter/.claude/worktrees/edit-quality` and
  `~/Projects/cairn-cms/.claude/worktrees/format-test` finds nothing; `claude agents --json` shows
  no session in drafter or cairn-cms but the launching conductor; both main checkouts are clean and
  on `main`; no branch named `edit-quality`, `worktree-edit-quality`, or `format-test` exists in
  either repo (skill-rules deleted its `format-test`). Other worktrees (`agent-*`,
  `b1-blueprint-format`, `repo-organization`, cairn's `blueprint-pilot` and `repo-organization`)
  don't block, and the executor leaves them alone.
- `DRAFTER_API_KEY` in `~/.local/secrets`, by name only (`grep -c '^export DRAFTER_API_KEY='
  ~/.local/secrets` prints 1); never printed. `drafter config` names `key_env` `DRAFTER_API_KEY`
  and no `key_command`. `drafter spend --json` shows `open.count` 0, and the cycle total plus
  `open.worst` leaves at least $40 under the $160 `cycle_ceiling`.
- `readlink -f ~/.claude/skills/blueprint` is `/var/home/glw907/Projects/drafter/claude/.claude/skills/blueprint`,
  recorded as the link to restore. `~/.local/bin/drafter` is a regular file (`make install` copies
  it); EQ.0 copies it to `<job>/drafter.installed` before anything else.
- skill-rules' harness at `~/.claude/jobs/drafter-skill-rules/ft/`, read-only: `tweak.sh`,
  `read.sh`, `round.sh`, `row0.sh`, `control.sh`, `control.py`, `refedit.sh`, `refedit.py`,
  `spend.py`, `grade.py`, `analyze.py`, `findings.py`, `base.sh`, `c1.patch`, `c2.patch`,
  `t2b.patch`, `t4c.patch`, `t5a.patch`, `p1.txt` to `p7.txt`, and `base-prime.format-patch` (the
  `f:sszb7b` correction, commit `1ca175a2a`).

## Harness

EQ.0 copies the files above, and no evidence file, into the pass's job directory
`~/.claude/jobs/drafter-edit-quality/ft/` (`<job>`; on `/var/home`, never the scratchpad), names it
in the STATUS note, and edits the copy. skill-rules' directory is never written. The edits:

- Every script: `OUT` is `<job>`, `DWT` is this pass's drafter worktree, and `base-sha` holds
  `<base''>` once EQ.7 records it. `cairn-wt-ignored.txt` is re-recorded on the new worktree. Every
  read goes through `<job>/bin/drafter`.
- `<job>/bin/`: EQ.7 step 1 copies the worktree build to `<job>/bin/drafter.real` and
  `docs-page-chain.js` to `<job>/bin/`, and writes both sha256 sums at the head of the rows table.
  `<job>/bin/drafter` is a wrapper script that exports `DRAFTER_PROMPTS=<job>/bin/docs-page-chain.js`,
  `DRAFTER_PAGE_CAP=2`, and `DRAFTER_CYCLE_CEILING=$(cat <job>/ceiling)`, then `exec
  <job>/bin/drafter.real "$@"`. A rebuild or edit in `DWT` during EQ.8 can't reach the runs.
- `<job>/restore.sh`, written before the first swap and named in the STATUS note: `ln -sfn` the
  skill link back to the main checkout's skill directory, and confirms `~/.local/bin/drafter`
  matches `<job>/drafter.installed`. Every stop path runs it; `claude agents
  --json` is rechecked before each round.
- `spend.py`: `BASE` is `<job>/baseline`, the budget is 40 of API spend, and session cost is a
  reported column. `sessions.txt` starts empty.
- `tweak.sh`:
  - `--disallowedTools` drops `Bash(drafter read *)` and keeps `Bash(drafter page *)`,
    `Bash(drafter convert *)`, and `Bash(git push *)`. The other flags are #49's.
  - Launch gate: the session starts only when `HEAD` equals `<base''>` and `git status
    --porcelain` is empty; otherwise it writes `HALT`.
  - A fresh env file per session, `<job>/<NAME>.env`, named by `CLAUDE_ENV_FILE`. The installed
    Claude Code 2.1.302 reads that variable from the process environment, loads the file once per
    session ("Session environment loaded from CLAUDE_ENV_FILE"), and runs it ahead of each Bash
    command (the verification read's probe of the binary). It puts `<job>/bin` first on `PATH` (`PATH` alone would lose,
    since `~/.bashrc` puts `~/.local/bin` first); sets the key with `eval "$(grep '^export
    DRAFTER_API_KEY=' ~/.local/secrets)"`, so the file never holds the value; and blocks pushes with
    `GIT_CONFIG_COUNT=1`, `GIT_CONFIG_KEY_0=remote.origin.pushurl`,
    `GIT_CONFIG_VALUE_0=/dev/null/no-push` (probed: git 2.56 exits 128 on push under it). The loop
    probe proves the route. If it fails its one re-probe, the executor stops for Geoff: there is
    no fallback route, since without the env file the push guard and the no-key unset are gone and
    `~/.bashrc` re-sources both keys. The file is kept as evidence.
  - The session runs as `timeout -k 30 1500 env -u ANTHROPIC_API_KEY ... claude -p ...`.
  - After the session: `flock -w 300 "$(git rev-parse --absolute-git-dir)/drafter.lock" true`
    before any post-check (drafter holds that file with `syscall.Flock`,
    `internal/pipeline/start.go:109`). A timeout marks the run infrastructure.
  - Before any reset, it writes `HEAD`, `HEAD^{tree}`, and the commit chain from `<base''>` to
    `<NAME>.*`, saves `git format-patch <base''>..HEAD` as `<NAME>.patches/`, and writes
    `refs/ft/<NAME>` at `HEAD`, so `agree.sh` and later reads reach the commits after the next
    reset.
  - The session's reads are the new run directories under `~/.local/state/drafter/runs/cairn-cms/`
    whose `state.json` `project` is the cairn worktree, `branch` is `format-test`, and `head` is in
    the session's chain; a resume counts as part of the read it resumes. Each is recorded in order
    with its `state.json` head and its `inputs` hash for the prompts module (compared with
    `<job>/bin/docs-page-chain.js` hashed as `hashFile` in `internal/pipeline/record.go` hashes it;
    `drafter_version` is "dev" for every local build), exit, `record.json` verdicts, findings, and
    warnings, the blueprint seat's ledger cost, cache fields, and reserve-to-settle time, the
    `--since` argument from its Bash command in the stream with `git rev-parse` of it (when the
    argument isn't a literal revision, such as `"$BASE"`, the read's base is checked instead by the
    saved request's `=== blueprint diff ===` block equalling `git diff <base''> <read head> --
    <BP>`), and whether its saved
    blueprint request holds the cached-prefix field and the "Nit:" rule sentence.
  - Orphans: `drafter spend --json` gives only `open.count` and `open.worst` (`spend.go:54-59`),
    so the runs are found from the ledger's reserve lines with no settle, matched by `run_id`. For
    each, `git reset --hard <state.json head>` and `<job>/bin/drafter read --sync --json --resume
    <run-id> <BP>`, the void or settle recorded on the run's row. The next dispatch waits on `open.count` 0.
  - Post-checks: one to three content commits on a linear chain from `<base''>`, plus at most one
    trailing empty commit. It resets to the first commit by recorded SHA to run
    `<job>/bin/drafter check <BP>` there (the first-commit measure), resets back by recorded SHA,
    and compares the recorded `HEAD^{tree}` with the last read's head tree. It asserts the stream's
    `"apiKeySource":"none"`, and halts the round when `mains-post` differs from `mains-pre` in any of
    the three repos (the session holds `--add-dir` write access to `DWT`). The other post-checks
    are #49's.
- `round.sh` no longer calls `read.sh`. A run whose session made no read gets one `read.sh` read
  for the per-shape diagnostic, marked "skill skipped the read".
- `row0.sh` and `read.sh` read with `<job>/bin/drafter`.
- `grade.py` and `analyze.py` print each in-session read (its Bash command, `--since` and its
  resolution, exit, verdict, blocking and "Nit:" counts, cost, cache-read tokens) and the
  session's final `result` text, and count per read the verdict-and-flag disagreements (verdict
  "fix" with no blocking finding, "ok" with one) and "Nit:" findings flagged blocking.
- `refedit.py` and `control.py` assert against `<base''>` and are re-targeted if EQ.6's fixes moved
  their anchor lines; a patch that no longer applies is re-seeded and its row marked "re-seeded".
- New `agree.sh <name> <k>`: resets to `<name>`'s first in-session read's recorded head and runs
  `read.sh` with `--since <base''>`, writing `<name>.agree<k>.*`.
- Gate: `grep -n 'drafter-skill-rules\|worktrees/skill-rules\|1ca175a2\|5\.4739' <job>/*.sh
  <job>/*.py` prints nothing.

The skill link points at `<DWT>/claude/.claude/skills/blueprint` for EQ.7 and EQ.8, set with `ln
-sfn` and confirmed with `readlink -f`. `restore.sh` returns it to the main checkout's skill
directory at EQ.8's end and on every stop path, as skill-rules resolution 7 says.

## Tasks

### EQ.0: recheck against F1, worktrees, and the harness (30 min)

- Risk class: `runner`.
- Outcome: the pass starts on F1's merge with every quoted fact still true, and the harness built.
- Files: none in drafter. The cairn `format-test` worktree and `<job>`.
- Procedure: `EnterWorktree` `edit-quality`, then the gate once (`DRAFTER_DIR="$PWD" bash
  scripts/drafter-gate.sh`); a red baseline stops the line. Confirm `git merge-base --is-ancestor
  41939c3 HEAD`. F1 also touched four files this pass edits: `docs/blueprint-format.md` (the `store`
  check row, "The facts store", and the seed paragraph), `BACKLOG.md` (#9 to #11),
  `cmd/drafter/page.go` (the summary writers take the config and print the `prices:` line), and
  `cmd/drafter/read.go` (`writeReadSummary`'s signature). Re-read those at `HEAD` and confirm this
  plan's anchors: the headings "Check what you add" and "What `drafter read` does with a blueprint",
  the check table, and `TestRealModuleRendersTheBlueprintSeat`'s golden. Create the cairn worktree
  (`git -C ~/Projects/cairn-cms worktree add -b format-test <path> 50dc211d9`), apply
  `base-prime.format-patch` with `git am` (that commit is `<base'>`), copy
  `~/.config/drafter/cairn-cms.local.toml` to `<cairn wt>/drafter.local.toml`, and confirm it is
  ignored. At `<base'>`, confirm `bb-lead`, `push-lead`, and `ver-lead` are each `mode: claim` with
  no `facts` (departure 9), and record the result for EQ.1 and EQ.2. Write `<job>/baseline` and
  `<job>/ceiling` (standing answer 4). Build the harness per "Harness", short of `<base''>` and
  `<job>/bin`'s copies.
- Acceptance: gate green; F1 is an ancestor; each anchor found, or the drift is written into the
  plan's task text before its task starts; `<DWT>/drafter check` in the cairn worktree with no names
  prints the `facts store:` line with 0 errors (#50 recorded 25 `store` warnings, which EQ.1's
  skill text keeps sessions from chasing); the lead-in result recorded; the copy gate's grep prints
  nothing; `git -C ~/Projects/cairn-cms status --porcelain` is empty.

### EQ.1: the skill and the format page (45 min), run by the session beside pair A

- Risk class: `runner`.
- Outcome: design outcomes 1 and 2, and the format page's account of outcomes 3, 4, and EQ.3's
  output.
- Files: `claude/.claude/skills/blueprint/SKILL.md`, `docs/blueprint-format.md`.
- `SKILL.md`:
  - Case 2: the sentence "A caution about something that can go wrong is a `failure` item with a
    handler, not a `sentence`" goes. A `failure` is for a symptom with a handler the facts supply;
    its handler is a step or a handoff that gives the reader a next action and cites the fact
    (the format page's `handler` row, by link). When no fact gives the reader a route, the edit is
    the catalog's "Add a caveat" row, and the report says the case has no handler.
  - A decline rule beside "If no catalog row fits": when the request conflicts with a fact, or asks
    for content a section already carries, make the smaller edit the catalog allows and say in the
    report what was asked and why the edit is smaller, naming the fact id or section id.
  - A "Read" section after "Check", per departure 1: note `git rev-parse HEAD` as the base before
    the first edit; every read uses that base. Run `drafter check <blueprint>`, commit, then
    `drafter read --sync --since <base> <blueprint>`. Fix every blocking finding and any Nits you
    choose in one batch, run `drafter check <blueprint>`, commit, and read again. Polish goes before
    a read, never after an accepted one. Stop at an accept or after the third read. When blocking
    findings remain after the third read, add one empty commit (`git commit --allow-empty`) whose
    message lists each by location, and list them to the user in the final report. Findings
    starting "Already present:" are older defects and stay out of the edit. What blocks and what is
    a Nit is a link to the format page, not a copy. A short table gives each outcome its action:
    - exit 0 with no blocking finding printed: accepted, stop;
    - exit 0 with a blocking finding printed, or exit 1 with the blueprint read's findings: fix and
      read again;
    - exit 1 from a consistency escalation: fix the conflict the change caused, and read again;
    - exit 1 escalated on rule `cap`, or exit 3 naming `cycle cap` or `spend limit`: stop reading,
      commit, and report the stop to the user;
    - any other exit 3: run `drafter read --sync --resume <run-id> <blueprint>` once; it counts as
      the same read (drafter's own printed resume line is correct from EQ.3 on);
    - exit 2 naming the key: skip the reads and say so;
    - exit 2 for a dirty tree, an unresolved `--since`, or config: fix the cause and rerun; it
      isn't a read.
- `docs/blueprint-format.md`:
  - "Check what you add" loses its caution line and gains none. Its intro sentence ("a change read
    blocks on a defect in one") is rewritten to say which lines block in a change read and which
    come back as "Nit:", by a link to "What `drafter read` does with a blueprint".
  - The check table gains `handler` (a `failure`'s `handledBy` names a `fact` item, a `sentence`
    with `mode: verbatim`, or a `link` or `handoff` that sends the reader back to the section holding
    the failure's `from` step), `warning`, and its message carries its fix. It gains `cited` only if
    EQ.0 found a lead-in changed (departure 9).
  - "What `drafter read` does with a blueprint" gains EQ.4's rule (in a change read, a defect that
    makes the page wrong, or leaves a reader stuck or without a state a later step needs, blocks;
    order, pace, heading form, placement, and a restating `use` come back as non-blocking findings
    starting "Nit:"), one sentence that house register rules apply in neither blueprint read, and
    one that the read prints each finding with its location and whether it blocks.
- Acceptance: `grep -n 'is a .failure. item with a handler' SKILL.md docs/blueprint-format.md`
  prints nothing; `grep -n 'a change read blocks on a defect in one' docs/blueprint-format.md`
  prints nothing; the Read section names `--sync`, `--since <base>`, three reads, the empty commit,
  the report to the user, and the outcome table's seven rows, its resume row holding `--sync
  --resume` and the blueprint argument, and holds no "nightly"; every
  `format.md#` anchor in `SKILL.md` names an existing heading; the table holds `handler`; no
  workstation path, cairn register text, or link to `docs-page-chain.js` in either file
  (skill-rules SR.2's greps); `vale --config ~/Projects/cairn-cms/.vale.ini docs/blueprint-format.md`
  adds no error on a changed line (record the baseline at `HEAD` first).
- Test: `make check` (`TestReferenceNamesEverySchemaField` and `TestEditCatalog` pass).

### EQ.2: the `handler` warning (40 min), paired with EQ.5

- Risk class: `runner`.
- Outcome: design outcome 3. `handler` warns with a fix message and never fails the check; `cited`
  is dropped per departure 9 unless EQ.0 found a lead-in changed, in which case it is built as the
  design states and run through the same false-fire test.
- Files: `internal/blueprint/check.go` (the check name and its pass, beside `sections`),
  `internal/blueprint/check_test.go`, `internal/plan/slug.go` (an exported function returning each
  section's heading slug as the plan check computes it, since `slugOf` and the slugger are
  unexported), `cmd/drafter/check.go` (the `Long` text gains the `handler` clause), and any fixture
  under `internal/blueprint/testdata/`, `cmd/drafter/testdata/`, or `e2e/testdata/` whose finding
  count the warning changes, each named in the commit message. No docs (EQ.1 writes the row).
- Rule: `handler` as EQ.1 states it. A section's anchor is its `anchor` field when set, else its
  heading's slug from the plan's slugger. A `link` sends the reader back when its `target` is
  `#<the section's anchor>` or a `[[<section id>]]` form names it; a `handoff` when its `text`'s
  only section reference names it. A `failure` with no `from` gets no back-link test. The message
  names the fix: hand off to the step or section that gives the reader a next action.
- Acceptance: `TestCheckNewChecks` gains table rows, each with a passing twin. Fixture edits on the
  base fixture: a failure handled by a fact item, by a verbatim sentence, by a link to the from
  step's section (by anchor and by `[[id]]`), and by a handoff naming it; one handled by a step
  passes. Each row asserts `Severity` is `warning`, the message names the fix, and `drafter check`'s
  exit stays 0 with only these findings (an `e2e` or `cmd` row). Each fails today: no finding of the
  check exists. False-fire test: build the pair's binary and run `check <BP>` in the cairn worktree
  at `<base'>` (read-only). `handler` must fire on `x-third-verify` (handled by `rec-lead`, a
  verbatim lead-in) and `x-check-threw` (handled by `rec-health-failed`, a `fact` item); a miss on
  either is a bug in the rule. The mechanics probe also expects `x-logs-empty` (handled by
  `rec-logs-observability`, a `fact` item). Every other hit is classified true when #49's reads or
  row 0 named that item, and otherwise quoted by item id in the commit message with the reason it
  is or isn't a defect. A hit the definition covers but that isn't a defect drops the warning from
  the diff, recorded in the commit message; a hit the definition doesn't cover is a bug to fix. Run
  the same over drafter's own fixtures under `testdata/catalog`. The kept hits go to EQ.6's fix
  list.
- Test: `make check`.

### EQ.5: cache order and the cache breakpoints (65 min), paired with EQ.2

- Risk class: `runner`.
- Outcome: design outcome 5 and departure 3. The blueprint read's user turn is three text blocks:
  first the note, the prompt, and the inlined files the prompt names (the register), with an
  ephemeral `cache_control` (5-minute TTL, no `ttl` field); then the facts block, with the same;
  then the blueprint, its outline entry, the change block opened by the scope sentence when there
  is one, and the answer contract. The scope sentence is the one EQ.4 removes from the prompt: "These
  sections changed: <ids>." or, for a page-level change, the prompt's page-form sentence, moved
  verbatim. Every other request's wire is unchanged.
- Files: `internal/batch/types.go` and `request.go` (a user message can carry cached leading
  parts, an exported field that `saveRequest`'s JSON carries; `buildWire` emits each as its own
  text block with `cache_control`, in batch, count, and send params), `internal/assemble/blueprint.go`
  (the facts block apart from the blueprint and entry block, its intro sentence matched to the new
  order), `internal/assemble/assemble.go` (`Build` places the cached parts after the inlined
  files), `internal/pipeline/blueprint.go` (`stageBlueprintRead` passes the facts block as the
  second cached part and prepends the scope sentence to the change text; nothing else in the file
  changes), `internal/pipeline/testdata/module.js` (the fake module's blueprint seat drops its
  `"\nScope: " + c.scope` line), `internal/ledger/price.go` (`Worst` and its doc comment), `docs/setup.md` (the
  reservation sentence at lines 90-91, "the counted input plus every request's `max_tokens` at the
  output price", now says input is priced at the higher of the input and cache-write rates), and
  their tests. `money.go` and `resume.go` are never edited.
- Acceptance:
  - A `batch` test asserts the wire of a message with cached parts: one text block per part, each
    with `cache_control` type `ephemeral` and no `ttl`, then the plain block; a message without
    them sends today's single block. It fails today, since a message has no such part.
  - An `assemble` test asserts the read request: the register ends the first block, the facts
    block is the second, and `=== blueprint ===` and the change block sit in the third. It fails
    today, since the facts follow the blueprint.
  - A `pipeline` test asserts the same on the request a change read builds (the existing
    blueprint harness): the change block, opened by the scope sentence, sits in the third block
    after `=== end outline entry ===`. The scope-line checks in `TestScopeReachesTheBlueprintPrompt`
    and `TestOutlineOnlyChangeRendersTheChangeRead` move to the change block. A row asserts the
    first block is byte-identical for two change reads of one blueprint with different scopes and
    an added citation; on the fake module this proves the assembler's split only, and EQ.4's render
    rows prove the shipped prompt.
  - A `ledger` test asserts `Worst` for an input of N tokens priced at the 5-minute write rate when
    that rate is the higher; it fails today. The rows of `TestWorstFunc` (sync, batch, tier,
    at_the_threshold) and `TestWorstThroughReserve` (its two rows) are updated to the new figures,
    each named in the commit message. `Worst`'s doc comment says it bounds a 5-minute write only.
  - The consistency, draft, and edit requests' wires are byte-identical to today's (an existing
    test, or one row).
  - `git diff --stat 41939c3 -- internal/pipeline/money.go internal/pipeline/resume.go` is empty.
  - The live proof that the prefix reaches the cache is EQ.7's forced pair.
- Test: `make check`.

### EQ.3: `drafter read` prints its findings (40 min), paired with EQ.4

- Risk class: `runner`.
- Outcome: departure 2. A page's result carries the blueprint read's findings (location, text,
  blocking), the record's warnings, and the escalation detail. The text summary prints them under
  the page line, one per line, marked blocking or not; `--json` carries them as fields of each page,
  omitted when empty. The `drafter read` help's output paragraph says so. `ResumeLine`
  (`internal/pipeline/pipeline.go:192`, printed at `cmd/drafter/page.go:225`) adds `--sync` when the
  run's mode is sync, and the page paths, so the printed line is a command drafter accepts.
- Files: `internal/pipeline/pipeline.go` (`PageResult` and `summary`), `cmd/drafter/page.go`
  (`writeSummaryText`), `cmd/drafter/read.go` (the `Long` text only), a pipeline summary test file
  (new, or an existing one EQ.4 doesn't touch), and `cmd/drafter/page_test.go`.
- Acceptance: a change read with one blocking finding, one "Nit:" finding, one "Already present:"
  finding, and an "Unplaced:" warning prints all four in text and in `--json`, each finding's
  blocking flag matching the record. An escalated consistency read prints its detail. An accepted
  read with no findings prints exactly today's lines. The rows fail today, since no output carries
  a finding. A `cmd` row asserts a stopped sync read prints `drafter read --sync --resume <run-id>
  <blueprint>`; it fails today, since the line omits both. `drafter page`'s summary changes only by the same lines when its stage-1 read has
  findings.
- Test: `make check`.

### EQ.4: the reviewer-grade change read and no register rules (35 min), paired with EQ.3

- Risk class: `runner`.
- Outcome: design outcome 4, in `blueprintPrompt`.
  - The change-read paragraph: a finding blocks only when the change makes the page wrong or leaves
    a reader stuck: a claim past its fact, invented output, a handler that loops or dead-ends, a
    state no step supplies, a missing step. Order, pace, heading form, field placement, and a `use`
    that restates its fact are non-blocking, with text starting "Nit:". The paragraph states its
    precedence: "In a change read, this rule replaces the blocking rule above for order, pace,
    heading form, field placement, and a restating `use`: return each as a non-blocking finding
    starting "Nit:". A Nit never makes the verdict "fix"." The source is Google's review standard's
    "Nit:" sentence on the page the paragraph already cites
    (`google.github.io/eng-practices/review/reviewer/standard.html`). Quote it from a fetch of that
    page, never from this plan.
  - The scope sentence (`These sections changed: ${scope}.` and its page form) leaves the prompt,
    per departure 3; the paragraph says the change block opens by naming the sections it touched.
    EQ.5 carries the sentence verbatim.
  - The shared text, so both reads carry it: the register's page anatomy is read only for the
    introduction and closing section it requires for the page's type. Its heading forms and other
    house rules govern prose, and the editor seat applies them; neither blueprint read returns a
    finding under one.
  - The whole read's checklist and its "A checklist item the blueprint fails is a blocking finding"
    bar stay as they are.
- Files: `claude/.claude/workflows/docs-page-chain.js` (`blueprintPrompt` and its doc comment),
  `cmd/drafter/read_test.go` (`TestRealModuleRendersTheBlueprintSeat`),
  `cmd/drafter/testdata/blueprint-prompt.golden.txt`.
- Acceptance: the scoped render holds "Nit:", each of the five blocking classes, the precedence
  sentence, and the standard's quoted sentence, and no longer holds "These sections changed:" (the
  existing want is replaced); the `Scope: "page"` and `Scope: "intro,steps"` renders are
  byte-identical, the property the cache rests on, tested on the real module; the `pageOnly` check
  (`read_test.go:261`) flips to "lacks 'No section's own content changed'"; the unscoped and scoped renders both hold the register sentence; the
  golden is regenerated, and its diff against `41939c3`'s copy is the register sentence alone; the
  test's comment on the golden no longer says "the prompt as it was before scoped reads"; the
  scoped prompt still starts with the unscoped one. The new `wants` fail today.
- Test: `make check` (`prompts-parity` renders the module in Node and in goja and compares them).

### EQ.6: the test base (45 min), run by the session beside pair B

- Risk class: `runner`. No live spend.
- Outcome: design outcome 6, edits only; EQ.7 reads the result.
- Files: none in drafter. In cairn, the `format-test` branch only:
  `blueprints/docs/extend/rotate-the-github-app-key.blueprint.yaml` and, only when a fix needs it,
  `docs/internal/facts/extend.md`.
- Procedure:
  1. Tally the "Already present:" findings across #49's 21 graded reads and row 0
     (`<old job>/t*.read.json` run ids, through the copied `findings.py`, reading `record.json`
     under `~/.local/state/drafter/runs/cairn-cms/`) by item id. The fix list is every item named in
     three or more reads, plus every `handler` hit EQ.2 kept (at least `x-third-verify`,
     `x-check-threw`, and `x-logs-empty`). The analysis also expects `s-rec-checks` referring to its
     own section, the `covers` line split across sections, the rollback route omitting
     `f:sszb7b`'s cache bound, and the duplicated fingerprint rows (`x-fingerprint`, `x-wrong-key`).
  2. Fix each in place. Every prompt's premise survives: no worked example of the no-key answer
     (p1), the warn level unrecorded (p2), no stale-live-result case (p3), no no-fingerprint caution
     (p4), no editor-view section (p5), no link to Cloudflare's bindings page in
     `verify-the-new-key` (p6), and `ver-live-wait` present (p7). Each premise's grep is written in
     `<job>/premises.sh` before the first fix; p1's names the item ids that carry the no-key answer.
     Each grep is shown to bite before the first fix: it fails on a seeded violating line, or on
     the prompt's reference edit where one exists (`ref6`, `ref7`), recorded in `<job>`.
  3. `<DWT>/drafter check <BP>` (EQ.2's build, merged) reports 0 errors and no `handler` warning.
     Commit on `format-test` as one commit.
- Acceptance: the tally is in `<job>` with run ids; each fix is named there by item id with the
  defect it removes, in drafter's own words; `<job>/premises.sh` passes on the commit; `git -C
  ~/Projects/cairn-cms status --porcelain` is empty.

### EQ.7: row 0, the probes, the cache pair, the replays, and the controls (65 min), after pair B and EQ.6

- Risk class: `runner`, `live-account` (about $7).
- Outcome: a base the whole read accepts, the harness proven end to end, the cache proven live,
  the new boundary exercised, and the controls on the new binary and prompt.
- Procedure:
  1. `make -C <DWT> build`, then fill `<job>/bin` per "Harness". Row 0: `row0.sh`, a whole read of
     EQ.6's commit. When it blocks, fix its blocking findings as EQ.6 step 2 does, commit, and read
     again, up to three fix rounds (standing answer 3). Restore `drafted.lock` after a whole accept
     writes it. The last commit is `<base''>`; write `base-sha`, and save `git format-patch
     <base'>..<base''>` in `<job>`. Finish the harness, run its grep gate, and swap the skill link.
  2. Loop probe, a session outside the 21 with p6's prompt. Its stream shows the `Skill` call and
     at least one in-session `drafter read --sync --since` whose `--since` resolves to `<base''>`.
     The run directory's saved request carries the cached parts and the prompt's "Nit:" rule, which
     proves the wrapper and chain. The read's output in the stream lists findings. The final tree
     equals the last read's tree. A failed route is re-probed once, then stops for Geoff.
  3. No-key probe: one session with p6's prompt whose env file omits the key line and unsets
     `DRAFTER_API_KEY`, launched under `env -u DRAFTER_API_KEY` too. It commits, its final `result`
     text names `DRAFTER_API_KEY` and says it skipped the reads, and it creates no run directory.
  4. Cache pair: commit `ref6` on `<base''>` and run `read.sh` twice back to back, within five
     minutes. On each read's `blueprint` seat settle line (the consistency seat's line carries no
     cache tokens), the first read passes when `cache_write_5m + cache_read` is above 0 (the loop
     probe's entry may still be live), the second when `cache_read` is above 0; both rows' cost and reserve-to-settle time are recorded (design outcome 5's second
     read's cost and latency). A zero stops the line before the 21.
  5. Replays, outside the 21 and the bars, reported: #49's `t4c.patch` (handler loops to
     `rec-push-link`), `t5a.patch` (a false claim plus a heading), and `t2b.patch` (placement only)
     on `<base''>`, each re-seeded through `control.py` when it no longer applies, read once by
     `read.sh`. Expected: 4c blocks at the handler; 5a blocks on the claim and returns the heading
     as "Nit:"; 2b returns only "Nit:" findings and accepts.
  6. Positive controls `ref6` and `ref7` on `<base''>` (`ref6`'s second cache-pair read counts as
     its control read), then control 1 (`c1.patch`), each committed by the executor with no session
     and read once by `read.sh`. Control 2 runs after EQ.8's round c.
- Acceptance: row 0's rounds, verdicts, and costs in the `<job>` rows table, ending accepted or
  recorded as still blocking after three rounds; both probes' rows pass as stated; the cache pair
  passes; the replays' verdicts recorded against their expectations; `ref6` and `ref7` accept, and a
  failure fails the Controls row (departure 12); control 1 draws a blocking finding at `s-interval`.

### EQ.8: the rerun (120 min), after EQ.7

- Risk class: `runner`, `live-account` (about $15 expected; at most about $31 if every run reads
  three times).
- Outcome: design outcome 7. The same seven prompts (`<job>/p1.txt` to `p7.txt`, unchanged; prompt 4
  stays as the decline test), three runs each, in rounds a, b, c, fresh sessions, against
  `<base''>`. Then control 2, then the judge-agreement reads.
- Per run, as #49 recorded it: each in-session read's findings, blocking or Nit, the round it closed
  in, and the rule each falls under. Each "Already present:" finding and "Unplaced:" warning is
  classified against `git show <base''>:<BP>` as present at base or introduced, as skill-rules
  resolution 7 does. Also recorded: the base check, the session's final report text, whether it
  declined or narrowed the edit and why, and the session's notional cost.
- How each measure is read:
  - An in-session read counts only when its `--since` resolves to `<base''>` and its saved request
    carries the cached parts and the "Nit:" rule.
  - An in-session read accepts when it exits 0 with no blocking finding, no "Already present:"
    finding on the change, and no introduced "Unplaced:" warning; a consistency escalation is not an
    accept.
  - A run is accepted within N reads when its last in-session read accepts, the final tree equals
    that read's tree, and the session made at most N reads. A run with no in-session read is
    accepted within none.
  - A commit carries a change no read saw when the final `HEAD^{tree}` differs from the last
    in-session read's head tree, or when the session made no read at all.
  - Protocol breaches, each a miss: more than three reads; a read without `--sync`; a read on a
    base other than `<base''>`; a stop with blocking findings open before the third read and before
    an accept; a `drafted.lock` written into the tree; more than three content commits or a
    trailing commit that changes the tree; a run left unaccepted after three reads whose last
    commit message (`git log -1 --format=%B`) doesn't name each blocking finding's location; a
    pushed or main-checkout change.
  - First-try acceptance is the first in-session read's accept, reported per prompt.
  - Minutes waiting per run is the sum, over its run ids, of first reserve to last settle in the
    ledger.
  - Declines: a decline is a run whose committed diff omits a part the prompt names and whose
    final report names the fact id or section id that conflicts. Prompt 4 passes when the diff adds
    no `failure` item, adds a `sentence` with `mode: claim` citing `f:h252kb`, the final report
    names `f:h252kb` or says the case has no handler, and the run is accepted within three reads.
    A decline on any other prompt is a miss in the bars, except a prompt 5 decline whose report
    names `x-editor` and whose smaller edit is accepted (departure 11). Declines are counted on
    every prompt and reported.
  - Judge agreement: every run whose first in-session read blocked, up to the first three in round
    order; fewer qualifying runs report the number found, with no substitute. `agree.sh` re-reads
    each one's first read head twice more. The report gives, per run, how many of the three reads
    blocked and whether they blocked at the same location (the same section id and item id), and
    states the analysis's falsifier reading (fewer than two of three agreeing).
  - Reported beside the rates: the verdict-and-flag disagreements and Nits flagged blocking, and
    the count of findings across row 0 and the 21 whose rule is a house register rule (heading
    form, the transcript rule), expected 0.
- Acceptance: the rows table in `<job>` headed by the note that the base is `50dc211d9` plus the
  `f:sszb7b` correction and EQ.6 and EQ.7's fixes (`<base''>`), with the binary's and chain's
  sha256, then the design's measures, exactly:

  | Measure | Bar |
  |---|---|
  | `drafter check` green on the first commit | 21 of 21 |
  | Accepted within two reads | 19 of 21 |
  | Accepted within three reads | 20 of 21 |
  | Commits carrying a change no read saw | 0 of 21 |
  | First-try acceptance per edit shape, reads per edit, minutes waiting, spend | Reported |
  | Declines on prompt 4 | Counted; a pass when the smaller edit is accepted and the report names why |
  | Judge agreement: three misses read twice more | Reported |
  | Controls | Both bite; both positive controls accept |

  Spend is API spend against $40, with the cached-read share and the cache pair's second read's
  cost and latency beside the first's; session cost is reported beside it. Control 2 draws a
  blocking finding at `s-generate` (its bite). Afterwards: `restore.sh` has run; `readlink -f
  ~/.claude/skills/blueprint` names the main checkout's skill directory; `~/.local/bin/drafter`
  matches `<job>/drafter.installed` (`cmp`); `git -C <cairn wt> ls-remote --heads origin
  format-test` prints nothing; EQ.8's clock is stopped and recorded; then the format-test worktree
  is removed and its branch deleted (the fixes survive as `<job>`'s format-patches); `git -C
  ~/Projects/cairn-cms status --porcelain` is empty.

### Close (30 min)

- The drafter gate on the close head is the full-suite home: `DRAFTER_DIR="$PWD" bash
  scripts/drafter-gate.sh`, re-issued on exit 75. drafter has no CI.
- Whole-branch `diff-reviewer`, told four rules: every format rule in the skill is a link by
  heading, never a copy; nothing in the skill, the format page, or the prompt copies cairn's
  register; the warning never changes `drafter check`'s exit; `money.go` and `resume.go` are
  untouched. One fix chain, then the gate again.
- `BACKLOG.md` through `log-issue`: #8 closes or narrows on the result for prompts 4 and 5; #1
  carries the result and closes if the bars are met. Each other follow-up goes through
  `log-issue`.
- The PR body opens with `## Brief` and carries the measures table and per-prompt counts, the
  classified findings, the departures (with departure 3's pricing note), a "For cairn's backlog"
  section naming each base fix by item id in drafter's words (quoting no cairn text), and the score
  with live spend. Before it opens, `grep -n '/var/home\|\.local/\|jobs/'` on the body prints
  nothing. The executor copies `<job>`'s `<base'>..<base''>` format-patch to
  `~/Projects/initiatives/docs-system/research/2026-10-19-edit-quality-base-fixes.patch`
  (uncommitted, for the conductor), stops at PR-ready, and `conductor-drafter` sends the packet.

## Merge order

`conductor-drafter` runs these rows.

1. glw907/drafter, then `git -C ~/Projects/drafter pull --ff-only && make -C ~/Projects/drafter
   install`; `readlink -f ~/.claude/skills/blueprint` names the main checkout's skill directory.
   Remove the drafter worktree only after this.
2. File each "For cairn's backlog" item in cairn-cms's `BACKLOG.md` through `log-issue`, tagged
   `#initiative:docs-system`, pointing at the initiatives repo's
   `docs-system/research/2026-10-19-edit-quality-base-fixes.patch` by repo path, never a
   workstation path. The conductor commits that patch in the hand-over. `f:sszb7b` was filed by
   skill-rules' row 2 and isn't filed again.
3. The architecture spec's erratum line, pointing at the design, in the initiatives repo's
   hand-over.

## Later

- The imperative-`sentence` warning (an item whose text opens with an action verb, 4b's shape),
  left out of the design; worth a probe once cairn holds more than one blueprint.
- An uncited-claim warning with a lead-in rule, if a larger blueprint sample shows the need
  (`cited` dropped here, departure 9).
- Moving the read prompt into a stock prompt file, with this rule (F2).
- A one-hour cache TTL for the read's prefix if the rerun shows the 5-minute entry lapsing between
  reads (then `Worst` must bound the 1-hour write rate too); a breakpoint for the consistency read.
- A read of the round-two diffs for fixes that satisfy the judge rather than the reader (the
  analysis's "What would prove this wrong").
- The base fixes on cairn's `main` (cairn's backlog, from merge row 2).
- A nightly repair seat (B4 decides), and the skill's backstop sentence once a nightly read exists.
