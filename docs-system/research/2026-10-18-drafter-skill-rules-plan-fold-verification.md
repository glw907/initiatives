# drafter skill-rules plan fold: verification read

Reader: fresh context, no part in the fold, 2026-10-18. Read-only except this file.
Plan: `plans/2026-10-18-drafter-skill-rules-plan.md` (uncommitted, 496 lines). Checked against the
fold record, the three reviews, the approved design, drafter `0a7a30b`, cairn `50dc211d9` (via
`git show`), #48's harness at `~/.claude/jobs/e63b19d8/tmp/ft/`, the run records under
`~/.local/state/drafter/runs/cairn-cms/`, and code.claude.com/docs/en/memory (fetched today).

Counts: 0 blockers, 2 majors, 8 minors (4 correctness, 4 optional). No owner fork.

## Did each blocker and major close?

Yes, every one, at the cited location.

| Finding | Closed at |
|---|---|
| Contract B1, integrity M1, mechanics 1 (pair check) | Resolution 2 (plan:125-146), resolution 3 (147-155), SR.3 steps 2-6 and acceptance (390-419), Later (490-496) |
| Contract M1 (escalation counted two ways) | Standing answer 3 (41-42); resolution 7 grade (282-284) |
| Contract M2, integrity M5 (introduced Unplaced) | Resolution 7 grade (284-288); SR.4 row fields (442-443) |
| Contract M3, integrity M4 (run independence) | Resolution 7 session bullet (252-257) and after-run bullet (270-277). See minor 3: the drafter-worktree check is narrower than the review asked. |
| Contract M4 (positive controls) | Resolution 6 last bullet (241-243); resolution 7 (298-302); SR.4 order (432) |
| Contract M5, integrity F2 (first try) | Resolution 7 (289-293) |
| Integrity M2, M3 (durable evidence, stale constants) | Depends on (84-103); resolution 7 last bullet (316-318) |
| Integrity M6 (meter) | Standing answer 4 (43-50) |
| Integrity M7 (timeouts) | Resolution 7 (253-260) |
| Mechanics 2 (breach file linked) | Resolution 4 (167-169); SR.2 grep (371); SR.4 probe (431) |
| Mechanics 3 (vale) | SR.2 (372-375) |

## Mechanisms probed

- `CLAUDE_CODE_DISABLE_AUTO_MEMORY=1`: the quote is verbatim on code.claude.com/docs/en/memory
  ("To disable auto memory via environment variable, set `CLAUDE_CODE_DISABLE_AUTO_MEMORY=1`."), and
  so is "Per repository, shared across worktrees". The page adds: "The `<project>` path is derived
  from the git repository, so all worktrees ... share one auto memory directory". For cairn that is
  `~/.claude/projects/-var-home-glw907-Projects-cairn-cms/memory/`, which holds eight of Geoff's
  memory files (`MEMORY.md`, `docs-rebuild-not-edit.md`, and others) that #48's sessions could load.
  `autoMemoryEnabled` is `true` at `~/.claude/settings.json:246`. The page doesn't say whether the
  variable outranks that setting (minor 6).
- `timeout 900 env ... claude -p ... <file`: coreutils `timeout` without `--foreground` signals the
  whole process group, so tool children die too. Stdin is a file, so no tty problem. `tweak.sh`
  records `claude exit $?`, which will read 124 on a timeout. There's no `-k`, so a child that
  ignores TERM can hang (minor 7).
- `ln -sfn`: `~/.claude/skills/blueprint` is a symlink to
  `/var/home/glw907/Projects/drafter/claude/.claude/skills/blueprint`. With `-n` the link itself is
  replaced, not followed. `format.md` in the skill directory is the relative link
  `../../../../docs/blueprint-format.md`, so in the worktree it resolves to the worktree's page.
  cairn at `50dc211d9` tracks no `.claude` skill that could shadow it.
- The spend formula against `drafter spend --json`: `spendReport` (`cmd/drafter/spend.go:53-59`)
  is `{rows, total, open: {count, worst}}`. `ledger.go:213` sums settled `Total`, and `:223-224`
  sums open `Worst` apart. So `total + open.worst − baseline` reads the right keys. `--since` is
  supported, and the baseline was taken with `open.count` 0. `spend.py:13` needs the `open.worst`
  term added, which the plan lists.
- Resume: `read.go` refuses `--since` together with `--resume` ("cannot be used together"), which
  matches standing answer 4. `state.json` carries `head`, as resolution 7 needs.
- The change read for prompt 6: a `link` item cites no fact, so `Scope.Facts` is empty. The
  `since.go:24-25` doc comment says Facts "is never nil on a scoped page", and `changeRead()`
  (`blueprint.go:59-61`) tests only `!= nil`, so prompt 6 stays a change read. The JSON tag has no
  `omitempty`, so a resume keeps `[]`.
- The fact bullets are one line each (`extend.md` 682, 685, 686, 1130, 1133), so "one changed line
  per corrected bullet" can hold.

## Order

- Reset, resume, timeout: these are consistent. Standing answer 4 resumes before any reset.
  Resolution 7 waits for the exit file. A second exit 3 stops for Geoff. Two mechanical gaps remain
  (minor 4).
- The positive controls come before the 21 runs. The order is probe, `ref6`, `ref7`, control 1,
  then rounds a, b, c, then control 2 (plan:261-264, 432). Each control commits on a fresh
  `<base'>`, so the probe's commit can't leak into them.
- The pair correction comes before row 0: SR.3 steps 2-5, then step 6. One gap (major 1).
- The skill link: it's swapped in SR.4's pre-flight, before the probe. It's restored at SR.4's end
  and on every stop path (309-315), by a resumed session, and by the conductor before worktree
  removal (merge row 1). Nothing in SR.3 needs the swap. No gap.

## Path and spend

- Path: SR.3's leg is 40 minutes (it's longer than SR.1's 35 and SR.2's 30), then SR.4 90 and
  Close 30, for 160. The task sum is 35+30+40+90+30 = 225. Both match plan:27-30 and the fold record.
  SR.4's 90 minutes is plausible. #48's sessions ran 10-60 s (`duration_ms` in its streams), and its
  reads finished about 1.5 min apart. So 21 × (session, read, checks) comes to about 60-65 minutes,
  plus the probe, four control reads, and the pre-flight.
- Spend: 21 × $0.375 = $7.875, 27 reads × $0.34 = $9.18, plus the probe at $0.20, gives $17.255,
  about $17.3. That matches plan:56-60 and the fold record. The whole reads B2 ran cost $0.338-0.366,
  so row 0 at $0.34 is fair.

## Findings, ranked by consequence

### Major 1. A reachable pair that row 0 (or a control read) newly names gets no verdict (correctness)

- Location: plan:408-413 (SR.3 step 6); plan:125-146 (resolution 2); fold ruling 1.
- Defect: ruling 1 has every base pair the reads have named, where a prompt can touch it, checked
  before the rate runs. Step 6 revises only when row 0 "still names a corrected pair". Row 0 is a
  whole read of `<base'>`, the first read on that base, and B2's two whole reads both returned
  consistency `conflicts`. If row 0 names a pair outside resolution 2's four, the plan has no step
  for it. That holds even when the pair is reachable by resolution 2's own test (a fact in
  `verify-the-new-key`, or `f:vg42j3`/`f:1pb077`, which prompts cite). Close's "a base conflict
  outside SR.3's pairs goes through `log-issue`" fires only after the 21 runs it could have cost.
  Prompt 7's three runs, or any run that cites `f:vg42j3`, would then score base noise as misses.
  `ref7` catches that only for prompt 7, and only once.
- Fold: in SR.3 step 6, judge any pair row 0 names that resolution 2 didn't list. If it's reachable
  under resolution 2's test, give it steps 2-4 (verdict, and a correction when the code proves one
  side wrong). Its correction shares the one amend and the one re-read the step already allows. If
  it's unreachable, add it to Later beside `f:72yc97`/`f:olofdb`. Treat a pair that `ref6`, `ref7`,
  or control 1 newly names the same way in the row. It doesn't move `<base'>` then, and goes to
  `log-issue`. SR.3 stays near 40 minutes, since row 0 already budgets one revision.

### Major 2. The fold lets the executor write a new prompt after the skill changes, and doesn't list that as a departure (correctness)

- Location: plan:298-302 (resolution 7, positive controls: "makes its prompt rewritten (once ...)
  or dropped"); plan:59-60 (reserve "a rewritten prompt's reference read"); fold record:115-123
  (departures list); design:53-57 ("two new prompts ... written by the planner before the skill
  changes").
- Defect: the design guards the new prompts' rate by having the planner write them before the skill
  changes. A rewrite in SR.4 is written by the executor, after SR.2 lands, by an agent that has just
  authored "Check what you add". Its prompt and reference edit get no `drafter check` probe and no
  review, which is exactly the contamination the design's wording rules out. Ruling 7, as the fold
  record states it, is "positive controls with a scaled bar". The scaled bar implies a drop. The
  rewrite branch is the fold's addition. "Against the approved design" lists the scaled bar but not
  the rewrite.
- Fold: drop only. A reference edit that can't pass removes its prompt, and the bar scales as
  written (15 of 18, or 13 of 15). The PR names the dropped prompt and the reference read's
  blocking finding. Delete "rewritten (once, its new reference read the same way)" and the
  reserve's "a rewritten prompt's reference read". If the planning session wants the rewrite kept,
  list it under "Against the approved design" instead, with the condition that the planner (not the
  executor) writes it.

### Minor 3. The drafter-worktree after-run check is narrower than the session's write reach (correctness)

- Location: plan:273-277.
- Defect: sessions get `--add-dir <drafter wt>/docs` under `acceptEdits`. The check covers only
  `docs/blueprint-format.md` and the skill directory. An edit to another `docs/` page, or a new
  untracked file under `docs/`, passes unseen. And `git checkout -- <file>` doesn't remove an
  untracked file. Integrity M4's fold asked for the whole worktree. That's safe here: the built
  binary is `/drafter` in `.gitignore`, so a whole-tree `status --porcelain` stays empty after
  `make build`.
- Fold: `git -C <drafter wt> status --porcelain` (whole tree) is empty and HEAD is unchanged. On a
  breach, run `git -C <drafter wt> checkout -- . && git -C <drafter wt> clean -fd docs claude`
  before the next run, and note it on the row.

### Minor 4. Two harness mechanics are under-specified for the wait and the resume (correctness)

- Location: plan:257-260 ("the next reset waits for the previous script's exit file"); plan:52-56
  (resume); plan:97-100 (harness edits).
- Defect:
  - `tweak.sh` writes `<name>.exit` at line 23, before its post checks and its `drafter check`
    (lines 24-33). A waiter keyed on that file can start `read.sh` while `tweak.sh` is still running.
  - `read.sh` has no resume mode. A resume would be typed by hand outside the harness, and its JSON
    and exit code wouldn't land in `<job>` under the row's name.
  - When a read leaves no exit file, the plan doesn't say what happens if no run directory matches
    the commit (the read died before starting).
- Fold: add to the "Depends on" edit list:
  - `tweak.sh` ends by writing `<name>.done`, and the wait keys on that file (or on the
    `run_in_background` completion notice).
  - `read.sh` takes `RESUME=<run-id>`, drops `--since`, and writes `<name>.resume.json` and
    `<name>.resume.exit`.
  - A read with no exit file and no matching run directory is an infrastructure failure under the
    first-try bullet.

### Minor 5. The SR.3 correction keeps a tag whose prose the correction makes false (correctness)

- Location: plan:403-405 (SR.3 step 4: "its tag kept in the facts file's form").
- Defect: `f:sszb7b` (planning's likely target) ends `[external: GitHub and Cloudflare (... neither
  half is cairn source)]`. Step 4 adds a cairn code reference to its `Source:`. Kept word for word,
  the tag then contradicts the bullet. Only the tag's kind is load-bearing (`citableTags`,
  `internal/plan/facts.go:32`).
- Fold: "its tag stays a citable kind (`verified`, `external`, or `vendor`), and any parenthetical
  is updated to match the new `Source:`".

### Minor 6. Nothing confirms that the memory switch takes effect (optional)

- Location: plan:252-257; SR.4 probe (429-431).
- Defect: the docs quote is exact, but the page doesn't say whether the variable outranks
  `autoMemoryEnabled: true` in user settings. Nothing in the stream shows that memory was loaded.
- Fold: the probe and each run record `ls -l --time-style=full-iso` of the cairn memory directory
  before and after. A change there is a breach. That costs one line in `tweak.sh`.

### Minor 7. A child that ignores TERM can outlive the timeout, and the timeout's exit code isn't named (optional)

- Location: plan:97-98, 289-293.
- Fold: use `timeout -k 30 900`. Name exit 124 or 137 in `<name>.exit` as the timeout signature
  for the infrastructure branch.

### Minor 8. Close's reviewer rule would flag the plan's own sourcing (correctness)

- Location: plan:461-463 against plan:175-181.
- Defect: `diff-reviewer` is told "every rule in 'Check what you add' cites a published source".
  Resolution 4 deliberately sources two clauses to drafter's own format rule and the agreement line
  to drafter's `ConsistencyPrompt`. A literal reviewer returns fix on all three.
- Fold: "cites a published source, or drafter's own code or format rule, marked as such".

### Minor 9. The section-read tally can't be computed from the harness as copied (optional)

- Location: plan:440-441 (row field: "a Read ... whose range takes in the heading's line");
  `analyze.py:19-20`.
- Defect: `analyze.py` prints only `file_path`, not `offset` or `limit`. So "range takes in the
  heading's line" can't be judged from its output, and the edit list (plan:93-100) leaves it
  untouched.
- Fold: add `analyze.py` to the edit list. It prints `offset` and `limit` for each Read, and any
  Grep or Bash command that names `check-what-you-add` or the heading.

### Minor 10. There's less real headroom than the $2.7 reads (optional)

- Location: plan:49-60.
- Defect: a cap under $1 stops for Geoff once the sum passes $19.00. So the room before a stop is
  about $19.00 − $17.26 = $1.74, roughly two infrastructure reruns at about $0.72 each. Sessions
  that now also read the new section could run past #48's $0.375 mean. A 10% rise is about $0.8.
  The worst outcome is a pause for Geoff mid-round, not a lost result, and the rounds keep the
  sample even.
- Fold: state "about $1.7 before the $1 cap stop" in standing answer 4 so the stop isn't a surprise.
  No budget change is needed.

## Beyond the design, unlisted

Besides major 2, the fold's "Against the approved design" omits three grading rulings. Each narrows
or widens the design's bar of "17 of 21 runs accepted on the first try, by the raw count"
(design:56-57):
- An accepted read with an introduced "Unplaced:" warning counts as a miss (ruling 3).
- A protocol breach counts as a miss even when the read accepts (inherited from #48).
- An infrastructure failure gets one rerun (ruling 4).

These are the planning session's rulings, not defects, but the packet should list them. Fold: add
three lines to the fold record's departures, and one to the PR's rate section. The remaining items
check out. The `ConsistencyPrompt` source was settled point 1. The F1 launch is Geoff's ruling
(plan:62-64). Row 0, the probe, and the four control reads bring the reads to 27 against the
design's "runs 23" (design:75), all within the $20.

## Checked and sound

- The fold record's claims hold on source: `read.go:59` exit 1; `resume.go:94-110`; `spend.go`
  keys; `blueprint_change_test.go:136` "they disagree"; the consistency escalation (`:217`) before
  the `fix` check (`:228`); `TestChangeReadConsistency`'s harness. One harmless inaccuracy: the fold
  record says `control.py` holds a jobs path, and it holds none. The grep gate covers it either way.
- SR.1's rows match the code. With the rule, an unplaced conflict beside a `fix` reaches
  `a.Verdict == "fix"` and escalates on `blueprint`. Today it escalates on `consistency`.
- Depends on: drafter and cairn have no `format-test` or `skill-rules` worktree or branch today, and
  the jobs directory doesn't exist yet. `~/.config/drafter/cairn-cms.local.toml` points `prompts` at
  `~/.claude/workflows/docs-page-chain.js`, which links to the main checkout. That's right for row 0
  on the installed binary. SR.4's `DRAFTER_PROMPTS` override points at the worktree.
- `money.go` and `resume.go` aren't in any task's files, and SR.1 gates on their diff.
