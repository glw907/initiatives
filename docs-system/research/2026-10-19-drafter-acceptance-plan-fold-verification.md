# Fold verification: drafter acceptance plan

Target: `docs-system/plans/2026-10-19-drafter-acceptance-plan.md` at initiatives `aa04960`, with its
executor and conductor prompts, against the three reviews, the fold record, and the approved design.
Code read at drafter `6b110ad` and cairn-cms `517158fae`. B3c's saved gate logs were probed on this
host. A fresh-context verifier wrote this file read-only. Plan locations are `plan:<line>`.

Verdict: needs fixes. 0 blockers, 3 majors, 5 minors. Every ruling is in the plan, and the plan stays
inside the design. The path sums to 635. Every `correctness` finding is folded or pushed back
soundly. The majors are mechanics the fold wrote that the code doesn't support: the two resume
commands can't run as written, and #25's condition, as the plan specifies it, fails on a reread and
has no source on a resumed read.

## Checks

### (a) Correctness findings folded or pushed back

All 13 contract, 13 integrity, and 19 mechanics `correctness` findings are in the fold table. Each
one is either at the plan location it names, or pushed back on a source that holds. Spot checks:

- Contract #3 (pushed back) holds. `declinedFor`'s only callers are `steps.go:558,628,659,705`
  (round 2, the reader, the final round, and coherence). Under ruling 1, `covSmall` goes only to
  `p.reviewed()` (`handle.go:384-391`, which accepts a whole run) or to an escalation, so none of
  those callers runs after a small exchange. `leftUnresolved` (`page.go:416-428`) then reads the
  small exchange, which is the exchange the escalation ends on.
- Integrity M9 (pushed back in part) holds. `docs/configuration.md:13,118` and cairn's
  `scaffolded-site-files.md:514` document `~/.config` and `~/.local` paths as product paths.
- Integrity m6 (pushed back in part, no host in the commit) holds. drafter is public.
- The optional drops (integrity m5 and o2, mechanics m11) are optional-tagged, and each has a reason
  stated.
- Mechanics B1 is folded, but the resume commands it asked for omit the run's paths (major 1).
- Contract #4's grep list drops "does not clone". That holds: `f:keuj8l` is imprecise, not one of the
  six wrong claims, and the plan's five greps match today's wording of the wrong claims
  (`reference.md:1305` "lapsed between the guard's", `extend.md:741` "except the two",
  `extend.md:867` for `f:qlgggh`).

### (b) Rulings and design

| Ruling | Where in the plan | Holds |
|---|---|---|
| 1. Gate and coverage with no seat or reader; at most one small exchange | finding 2 (`plan:68-80`); A1's small-exchange build and test rows (`:443-449`, `:476-484`) | yes |
| 2. Snippets reach the draft seat only | finding 7 (`:144-162`); standing answer 12; A1 snippet rows (`:504-509`) | yes |
| 3. Minimal hand edit of an escalated page's live text, listed in `## Decisions`; never a drafted page | standing answer 11 (`:340-344`); Close 3 (`:956-958`); Close 7 | yes |
| 4. Cairn PR lists every small-path finding verbatim | Run rules, last bullet (`:913-915`); Close 7 (`:980-981`); both prompts | yes |
| 5. A1 runs on opus at medium | Outcome, executor models (`:272-273`) | yes |

The plan stays inside the design. Ruling 1 is the design's own text (D item 3). Finding 15's
condition and finding 6's routing of #23 through cairn's pattern are method calls the fold record
names for the packet. Finding 8's widening is listed for `## Decisions`.

### (c) Live commands

Every new read and page call is written in full, with `DRAFTER_PAGE_CAP` and its flags: R1's first
read, its reread, R2, R3, R4, the R5 rerun, and the stall-rule rerun. No read combines `--since`
with `--resume`. The R4 dry run, Check 3, and the merge check are dry runs and spend nothing. The two
resume commands are written without the run's paths, and both refuse that form (major 1).

### (d) Stops

Most stops map to a standing answer or to a listed stop-and-ask. Three plan stops appear in neither
prompt's stop list (minor 6).

### (e) Path arithmetic

30 + 150 + 50 + 20 + 55 + 45 + 75 + 90 + 45 + 75 = 635. The build segment is max(150, 85, 100,
60 + 60) = 150. 635 / 400 = 1.59. Under 800.

### (f) New claims checked against source

- Finding 6's #23 handling holds. A Go `regexp` probe ran over both of B3c's saved `gate-4.log` files
  (217 lines each). Today's `failure_pattern` (`drafter.toml:14`) matches 0 lines. The new pattern
  `^  \S+:[0-9]+  \[[a-z-]+\]  ` matches exactly line 50 in each, `docs/extend/add-cairn-to-a-sveltekit-app.md:297  [file-path]  lib/cairn.config.js`.
  Once one line fails, `parse` doesn't mark the log unparsed (`run.go:223-226`), and `ForPage`
  (`run.go:236-251`) finds no failing line that names this page, so it returns foreign. The page is
  then held (`check.go:106-108`). `tailLines = 60` (`run.go:22`) confirms that a rule on the unparsed
  tail can't fire.
- Finding 15's #25 condition is sound as a rule, but two gaps remain (majors 2 and 3).
- C1's separate cairn worktree holds. `cairn-implementer` runs `npm ci` and the fast lane in "the
  worktree the dispatch gives you", and it commits there. `gate-tier.mjs` has a non-empty range after
  C1's commit. The cleanup's `branch -d` fails as written (minor 4).
- The resume binary check holds. `version()` (`cmd/drafter/page.go:209-214`) returns
  `debug.ReadBuildInfo`'s pseudo-version, for example `v0.0.0-20261019170720-1486b963235a` in B3c's
  `state.json`, which ends in 12 hex digits. drafter has no tags, and `/drafter` is in `.gitignore`,
  so a rebuild doesn't stamp `+dirty`.

### (g) This file

It exists at the path the executor prompt names.

## Problems

### 1. Major: both resume commands omit the run's paths, and drafter refuses them

- Location: R1's resume command (`plan:762-764`); Run rules, the page resume command (`:885-887`) and
  "a stopped read with R1's resume command" (`:889`).
- Defect: `drafter read` requires at least one blueprint argument (`cmd/drafter/read.go:67-72`,
  "read needs at least one blueprint file"). `drafter page` with no path skips `runPageBlueprints`
  and falls to `readHandoffs`, which refuses with "page needs a handoff file or --workflow-run"
  (`page.go:94-115`, `:198-199`). drafter's printed resume line appends the original arguments
  (`ResumeCommand`, `internal/pipeline/pipeline.go:285-296`), and the resume test passes them
  (`read_test.go:735`, `p.read("--resume", id, p.bp("a"), p.bp("b"))`). Because the executor prompt
  says to run every command exactly as the plan writes it, a stopped run's resume exits 2.
- Fix text. At `plan:762-764`, replace the command with:

  ```
  DRAFTER_PAGE_CAP=<min(10, left/N)> /var/home/glw907/Projects/drafter/.claude/worktrees/acceptance/drafter read --resume <id> --sync --json <the run's blueprint paths, written out as the call that started the run gave them>
  ```

  At `plan:885-887`, replace the command with:

  ```
  DRAFTER_PAGE_CAP=<min(10, left/N)> /var/home/glw907/Projects/drafter/.claude/worktrees/acceptance/drafter page --resume <id> --json <the run's page paths, written out as the call that started the run gave them>
  ```

  After it, add: "A resume takes the run's own paths, copied from the STATUS row of the call that
  started it. They match the resume line drafter prints. `read` refuses a resume with no blueprint,
  and `page` with no path reads its arguments as handoff files."

### 2. Major: a reread with `--since <BASE>` can't advance an entry that already advanced

- Location: finding 15 (`plan:209-216`, "In this pass the condition holds for all seven"); R1's
  reread and "Every new read in this pass passes `--since <BASE>`" (`:754-760`); R5's
  blueprint-cause rerun (`:852-855`); standing answer 8 (`:325-331`); executor prompt, "every new
  read passes `--since <BASE>`".
- Defect: after a page's first scoped accept, its entry's `accepted` is the post-C3 blob, not the
  blob at `BASE`. Under R5 (or standing answer 4's structural fix), a blueprint fix is then reread
  with `--since <BASE>`. That fails finding 15's own condition, so the entry keeps the stale blob, and
  `skipRead` (`draftscope.go:111-114`) is false. The `page --whole` rerun then runs a whole blueprint
  read in the run, which costs more and gives the page another chance to block. R1's check-after
  ("the lock's `accepted` equals `git rev-parse HEAD:<blueprint>`") also fails, and no standing
  answer covers that. The finding's claim that the condition holds for all seven is true only for
  each blueprint's reads before its first accept. R5 is on the path, so this is the expected route,
  not an edge case.
- Fix text:
  - Replace finding 15's last sentence with: "Each blueprint's reads before its first accept meet the
    condition, since A0 step 6 checks that every entry holds `BASE`'s blob. A later reread passes
    `--since` the commit whose blob the entry's `accepted` records (STATUS keeps that commit per
    page as each accept is committed), so the condition still holds, and the read sees every
    blueprint and fact change since that accept."
  - At `:758`, replace "Every new read in this pass passes `--since <BASE>`" with "Every new read
    passes `--since <S>`, where `S` is `BASE` for an entry still at `BASE`'s blob, and otherwise the
    commit STATUS records for that entry's last accept."
  - Make the same change in standing answer 8 and R5, and in the executor prompt's sentence: "every
    new read passes `--since` the base the plan's R1 names (`BASE`, or the entry's last-accept
    commit), and a resume never does".

### 3. Major: A2 doesn't say where finding 15's base comes from on a resume or in `drafter page`

- Location: A2 build (`plan:522-528`); A2 tests (`:538-542`); A2 files (`:518-519`).
- Defect: `recordReads(lock, start, s)` (`bar.go:74`) gets only the summary, and `PageResult`
  (`internal/pipeline/pipeline.go:103-134`) carries no `since`. On `read --resume`, `f.since` is
  empty (`read.go:74-76` forbids it). The per-page base survives only in work state (`p.w.Since`,
  `work.go:139`). In `drafter page`, the read diffs against the entry's own blueprint blob
  (`pageScopeFor` sets `old.Blueprint = e.Blueprint`, `draftscope.go:136`), not against a
  `--since` revision. With no source named, a stopped R1 read that resumes either refuses every
  accept, which leaves the seven on whole reads in the waves, or compares against the wrong commit.
  The existing subtest "a stopped run resumes with its scope" (`read_test.go:720-748`) covers this
  path, but A2's test list doesn't name it.
- Fix text. Add to A2's build: "`PageResult` gains `Since string \`json:\"since,omitempty\"\``, set
  from `p.w.Since` where `Summary` builds each result (`pipeline.go:268`), so a resumed read carries
  its base. `internal/pipeline/pipeline.go` joins A2's files; A1's list doesn't name it, so the pair
  stays disjoint. `drafter read` compares the prior `accepted` with `git rev-parse
  <r.Since>:<blueprint>`. In `drafter page`, the read's base is the entry's own `blueprint`, so the
  condition there is a prior `accepted` equal to the prior `blueprint`." Add to A2's tests: "a read
  stopped after a scoped accept and resumed with its paths advances `accepted` when the condition
  holds (the `read_test.go` resume subtest gains a committed prior entry), and keeps the entry when
  it doesn't."

### 4. Minor: Close 9's `branch -d` runs where the branch isn't merged

- Location: Close 9 (`plan:996-998`).
- Defect: `acceptance-gate` has no upstream, so `git branch -d` checks it against the HEAD of the
  checkout it runs in. Run in `~/Projects/cairn-cms`, that HEAD is `main`, and the branch is merged
  only into `acceptance-pages`. A scratch repo reproduced it: from the main checkout, "error: the
  branch 'gate' is not fully merged"; from the merging worktree, it deleted.
- Fix text: "`git -C ~/Projects/cairn-cms worktree remove .claude/worktrees/acceptance-gate`, then
  `git -C /var/home/glw907/Projects/cairn-cms/.claude/worktrees/acceptance-pages branch -d
  acceptance-gate` (that worktree's HEAD holds the merge, so `-d` succeeds)."

### 5. Minor: A0 step 1's session check catches the executor itself, and the prompt orders A0 differently

- Location: A0 step 1 (`plan:383-390`); executor prompt, "Your first act is `EnterWorktree`".
- Defect: "`claude agents --json` shows no session working in drafter or cairn-cms other than the
  conductor" also matches the executor, which runs in drafter, and the planning session
  `drafter-acceptance-plan`, which the conductor prompt excuses. The check fails on itself, and no
  standing answer covers that. The executor prompt also puts `EnterWorktree` first, while the plan
  runs step 1's checks before step 2's `EnterWorktree`.
- Fix text: in A0 step 1, "other than the conductor, the planning session
  `drafter-acceptance-plan`, and this session". In the executor prompt, "Your first act is A0 step
  1's one-executor checks, then `EnterWorktree` with the name `acceptance`".

### 6. Minor: three plan stops aren't in either prompt's stop list

- Location: A0 step 6's lock mismatch (`plan:417-418`); A0 step 1's repeated cycle headroom
  (`:383-384`); standing answer 10's red from `origin/main` and A3 step 2's whole-tree red the branch
  can't fix (`:336-339`, `:695-696`). Both prompts' stop lists.
- Defect: each stops the line, but neither prompt names it, so the executor can't tell whether to
  write a STATUS question for the conductor.
- Fix text: append to the executor prompt's stop list, and to the conductor prompt's "goes to Geoff"
  list: "or a stop the plan names: A0 step 6's lock mismatch, cycle headroom over 110 at A0, or a red
  from `origin/main` the branch can't fix (standing answer 10)".

### 7. Minor: the conductor prompt states half of finding 2's cost

- Location: the conductor prompt, the packet paragraph.
- Defect: it gives only the coverage origin's cost. Finding 2 (`plan:77-80`) also names the round-2
  origin's cost, where the final reader never reads the fixed page.
- Fix text: "the small-finding rule's cost as the plan's finding 2 states it: at the coverage origin
  no seat reads the redraft before acceptance, and at the round-2 origin the final reader never reads
  the fixed page; at either, the gate and the coverage check are the only guards".

### 8. Minor: one carried line citation has drifted

- Location: Run rules, "a resume loads facts from the working tree (`resume.go:59-63`)"
  (`plan:903`).
- Defect: `plan.LoadFacts` is at `resume.go:73-77`. Lines 59-63 are `checkPosition` and
  `CheckWorkspace`.
- Fix text: "(`plan.LoadFacts`, `resume.go:73-77`)".

needs fixes
