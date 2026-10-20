# Plan review, contract and criteria lens: drafter acceptance plan

Target: `docs-system/plans/2026-10-19-drafter-acceptance-plan.md` at `70ecab5` (cited `P:<line>`).
Design: `docs-system/specs/2026-10-19-drafter-acceptance-design.md` (`D:<line>`). Evidence:
`docs-system/research/2026-10-19-drafter-b3c-draft-review.md` (`R:<line>`). Factsheets cited as
`FC:` (cairn) and `FP:` (prompts). Code: drafter `6b110ad`, cairn-cms `517158fae`. B3c run records
read under `~/.local/state/drafter/runs/cairn-cms/` (read-only).

Verdict: the plan maps every design item, check, and outcome clause to a task, and its 31-finding
map is complete: each of the 31 entries resolves to a C2 fact or a C3 blueprint item. But finding 2
changes the approved design even though the plan says no finding does. Four acceptances can pass
vacuously, and two design promises have no check: the 31 fixes are correct, and the accepted pages
carry none of the six wrong claims. Three correctness gaps in the build spec would also survive the
named tests. 22 findings, ranked.

## Blocker

### 1. Finding 2 changes the approved design, and the plan says it doesn't (OWNER FORK)

- Severity blocker, tag `correctness`. Location: P:51, P:61-68, P:172-173, P:339-343.
- Defect: the design says that after the small fix "the deterministic checks run again (the gate
  and the coverage check, no review seat), and it accepts if they pass" (D:79-81), and it calls this
  "one more fix exchange" (D:79). The plan does something else.
  - At the round-2 origin the page goes to the final reader (`stReader1`). The reader can then open
    a final exchange, and its scoped editor and fact re-reads (`steps.go:640-686`).
  - At the coverage origin the page goes to `stRound2`, a full round-2 review by the structure,
    editor, and fact seats (`steps.go:351-352`, `:528-565`).
  - The plan allows "at most two small exchanges" per page (P:343), not one.
  - P:51 says "None changes the approved design", but the design's own standing answer is "A finding
    that changes this design ... stops and asks" (D:57). Because the plan runs unattended, this has
    to be ruled before launch, not at close.
- Why it matters: the reading changes which pages can accept. restrict-admin-access and
  security-model both ended at the coverage point in B3c (run `20261020T014536Z-5f8a8280` and
  `20261019T233356Z-01abf04b`, `record.json` escalation `second fix verdict / coverage`). Under the
  plan they then face a full round 2 and the reader, two more chances to escalate, where the
  literal design accepts them. The bar (5 of 7) and Check 1 both depend on this choice.
- Options:
  - (a) Literal design. Both points accept once the gate and coverage pass. The cost: at the
    coverage point, the redraft itself was never reviewed in round 2, so the page accepts with no
    seat ever reading the redraft.
  - (b) The plan's reading. Continue to where an ok verdict goes (reader, or round 2), with up to
    two small exchanges.
  - (c) Hybrid. At the round-2 point, go to the reader (it is not in `reviewSeats`, `steps.go:30`,
    so "no review seat" still holds). At the coverage point, go to round 2. Cap the page at one
    small exchange: a second small-eligible verdict escalates.
- Recommendation: (c). It keeps the review a clean page gets, honors "one more fix exchange", and
  removes the two-exchange loop. Whichever option is chosen, P:51 must stop saying the design is
  unchanged, and the packet must name this as a design amendment Geoff rules on.

## Major

### 2. #14 as specified is narrower than the design, and nothing replays B3c's flagged prose

- Severity major, tag `correctness`. Location: P:430-433 (C1 #14), P:441-444 (tests), D:68-69,
  D:62-63 (Outcome: "cairn's gate passes the prose it flagged").
- Defect: C1 frees only "a code span that is the whole text of a Markdown link". The design frees
  "a linked symbol or path in a no-claim sentence". The B3c scaffolded-site-files brief (run
  `20261020T023009Z-7a23e89e`, `final.brief.json`) shows why the difference matters:
  - Sentence 225 links "[The `site-facts.json` contract](...)". That is a linked path that is not
    the link's whole text, so it stays flagged under C1's rule.
  - Sentences 40 and 201 carry code spans outside any link, and 229 is a cited-but-unmatched path.
    So R:30 ("Every hit is a linked name") is itself inaccurate: 4 of the 8 hits survive C1's rule.
  - add-cairn's first gate (`20261019T233356Z-01abf04b/.../gate-1.log`) holds about 50 hits. Only 2
    are "npm package". About 22 are "the name/path X is in no cited fact", which #14 does not touch.
  - No task measures the Outcome clause against the real flagged prose. C1's tests are synthetic
    sentences only.
- Fold:
  - Widen C1's rule to any code span inside link text.
  - Add a C1 or A3 step, free: run `node scripts/checks/check-provenance.mjs` over the B3c final
    briefs of scaffolded-site-files, add-cairn, and add-a-second-sign-in-group on the fixed check.
    Record in STATUS the hits that remain by class, and copy sentences 152 and 225 into C1's unit
    fixtures. That turns "passes the prose it flagged" into a number. It also predicts before any
    spend that add-cairn will still need gate-fix rounds, which matters for the bar.

### 3. The coverage-origin small exchange overwrites the redraft exchange that round 2 reads

- Severity major, tag `correctness`. Location: P:337-343, P:363, P:366.
- Defect: round 2 tells each seat which of its findings the redraft declined, through
  `p.declinedFor(seat)` over `p.w.Ex` (`steps.go:558`, `:567-578`). `p.w.Ex` is set once by the
  redraft (`steps.go:520`) and stays live through the gate and coverage. A new small exchange that
  replaces `p.w.Ex` at the coverage point leaves round 2 with the small exchange's coverage-only
  findings, so every seat's declined block goes missing. `leftUnresolved` (`page.go:416-428`) has
  the same problem at a later escalation. No named test covers this, and the "covRedraft ... then
  round 2 reads" row (P:363) passes either way.
- Fold:
  - Keep the redraft exchange: hold the small exchange in its own field, or restore `p.w.Ex` after
    it.
  - Add the test row "coverage-origin small path: the round-2 request of a seat whose round-1
    finding the redraft declined still carries that declined block". It fails if `Ex` is
    overwritten.

### 4. Nothing independently verifies the 31 source fixes

- Severity major, tag `correctness`. Location: P:478-481 (C2 acceptance), P:500-501 (C3
  acceptance), D:63-64 ("the facts and blueprints behind the seven carry no claim the fact-check
  found wrong").
- Defect: every acceptance is mechanical or self-reported:
  - `drafter check` and `check:facts` prove that pointers resolve, not what the claims say. R:183-184
    names exactly this as the gap that let the six wrong claims through.
  - "The agent's report lists each fact with its finding number" and "the commit body's map covers
    31 findings" are attestations, not checks.
  - Close's diff-reviewer reads against plan and design, not against the code lines.
- Fold: before the C2+C3 commit, run one fresh-context read-only check (an Opus subagent at medium,
  no API spend, about 15 minutes). Hand it the 31 entries and FC section 5's "Code on main" column.
  For each finding it returns fixed or not fixed, with the edited fact or item line and the code
  line. A not-fixed result blocks the commit. For the six wrong claims, also add `grep` absence
  checks:
  - `grep -n 'separate `--connect`' blueprints/docs/extend/scaffolded-site-files.blueprint.yaml`
  - `grep -n 'does not clone' docs/internal/facts/extend.md`
  - `grep -n 're-includes' docs/internal/facts/extend.md`
  - the `f:v1jj2k` lapse wording
  - the `f:cvv6to` "exceptions" wording

### 5. No check that the accepted pages are free of the six wrong claims

- Severity major, tag `correctness`. Location: P:666-685 (Checks), P:699-703 (Close 3), D:41-42 ("so
  the pages you read carry no known error").
- Defect: the design's ruled recommendation promises that Geoff reads pages with no known error.
  The live pages carry the same wrong claims (FC section 11: restrict-admin-access.md:206,
  security-model.md:312-314, debug-your-site.md:149-153, scaffolded-site-files.md:126/:160-166/:186),
  and a draft can bring them back from a seat input or from the model's own memory. No check reads
  the accepted drafts for them.
- Fold: add a Check 2 sub-row at close. For each accepted page, grep for each wrong claim's phrase,
  one pattern per R:65-72 row:
  - `.dev.vars.example` as a scaffold file
  - `LICENSE` in the scaffold tree
  - `!.dev.vars.example`
  - "separate `--connect`"
  - "lapsed after the guard"
  - tidy and dictionary "outside" the map

  A hit fails the row. It is reported, never hand-fixed (P:656-658).

### 6. R1 skips already-accepted blueprints whose cited fact a fix round changed

- Severity major, tag `correctness`. Location: P:562-566, P:570-571, P:642 (R5 reads "its own path
  only"), D:87-91.
- Defect: when a read blocks, the fix subagent may edit a fact, and the session then re-reads "only
  those [still-blocked] blueprints". `skipRead` compares only the blueprint blob
  (`cmd/drafter/draftscope.go:93`, `:112-114`), so `page --whole` will not re-read either. The seven
  share many facts (FC section 6: `f:cvv6to` in restrict and security, `f:nls26c` in second and
  scaffolded, `f:qca0t0` in restrict and scaffolded, and `f:7cv105` and `f:hwffph` in nearly all
  seven). An edit to one of these after another citer accepted means that citer drafts on a fact no
  read has judged. That defeats design item 4.
- Fold: after each R1 or R5 fix round that touched `docs/internal/facts/`, re-read every blueprint
  that cites a changed fact (`ACC refs f:<id>` for each changed id), not only the blocked ones.
  Check after: for each fact id changed since R1's first read, every citer among the seven has a
  read in STATUS after the change.

### 7. The per-wave inbound-anchor sweep can edit a page that already accepted

- Severity major, tag `correctness`. Location: P:578-580, P:600, P:617, P:656-658, P:682-685 (Check
  3).
- Defect: the sweep retargets "every link elsewhere in `docs/` into `<page>.md#<anchor>`". Two
  plan rules then collide with a check:
  - The seven link each other. B3c's restrict-admin-access ended on a link to
    `security-model.md#limits-of-access-map-coverage`, so R4's sweep for security-model can edit
    restrict-admin-access, which R3 accepted.
  - That edit breaks Check 3's `page` equals `git hash-object <page>`.
  - It also breaks the rule that a drafted page is never edited by hand.
- Fold: run one sweep for all seven before R2. R1 has fixed every blueprint by then, so the anchors
  are known. No accepted page then ever sits under a sweep. A link inside one of the seven pages
  needs no retargeting, because its own draft will rewrite it.

### 8. record.json's kind and the small exchange have no test, and the golden is simply regenerated

- Severity major, tag `correctness`. Location: P:326-328, P:353-384, P:663-664, P:670-675 (Check 1),
  P:714-716 (the cairn PR table).
- Defect: Check 1's last clause, STATUS's "the kinds, and whether a small exchange ran", and the
  PR's page table all read `record.json`. Today `findingRecord` has no `Kind`
  (`internal/pipeline/record.go:66-73`), and the small exchange would show only as a `writes[].kind`
  string whose name the plan never fixes. The only record-side acceptance is regenerating
  `record.golden.json` with `UPDATE_GOLDEN=1`, which passes by construction.
- Fold:
  - Name the new exchange kind's string.
  - Add a test row: after the small path, `record.json` holds each finding's `kind`, a `writes`
    entry with that exchange kind, and the small exchange's stage in `stages`.
  - Require that the regenerated golden's diff adds only `kind` fields and the new entries; the
    commit message quotes the diff stat.

### 9. The #20 tests pass whether or not `blueprints` is scanned

- Severity major, tag `correctness`. Location: P:436-437, P:447-448.
- Defect: neither test exercises the scan root:
  - "`profileFor(...)` returns the T3 profile" passes even if `SCAN_ROOTS` never gains
    `'blueprints'` (`check-leaks.mjs:478-500`, `:528`).
  - "the leak check over today's `blueprints/` reports 0" also passes when nothing under it is
    scanned. FC:143 shows today's run already reports 0 for that reason.
- Fold: add a test that plants a T3-class leak in a temporary `blueprints/` file, such as a
  workstation home path (C1), and asserts that `runLeakCheck` flags it. It fails without the
  `SCAN_ROOTS` change.

### 10. A fix verdict with no blocking finding counts as "all small" by default

- Severity major, tag `correctness`. Location: P:100-103 (finding 5), P:344-346, P:361.
- Defect: "Non-blocking findings never count", and the small path opens when every blocking
  finding is small. A seat that answers `fix` with only "Nit:" or "Already present:" findings has
  no blocking finding, so it falls into the small path by default and opens an exchange with nothing
  to fix. Today it escalates (`steps.go:587-593`). The row at P:361 includes one blocking `heading`,
  so it does not reach this case.
- Fold: decide this branch (recommended: escalate as today, since the seat contradicts its own
  verdict rule, FP section 1 `findingRule`). Add the test row "round 2 fix with zero blocking
  findings: `second fix verdict`".

### 11. The new blueprint-read answer value has switches the plan doesn't list

- Severity major, tag `correctness`. Location: P:78-83 (finding 3), P:324-329 (A1 files), P:333-336.
- Defect: moving the blueprint read off `AnswerRead` means a new `assemble.Answer`, and three
  switches outside `answerSchema` key on that value:
  - `commandBlocks` runs seat inputs only for `AnswerDraft` and `AnswerRead`
    (`internal/assemble/commands.go:27`). A new value silently drops any `seat.blueprint.inputs`.
    The goldens have no inputs, so they won't catch it.
  - `inputBlocks` (`assemble.go:124-147`).
  - The smoke shapes pin the blueprint seat to `AnswerRead` (`internal/smoke/shapes.go:49`). The
    smoke would then send the kind schema for a seat whose production request no longer does, and
    `make smoke` sits outside `make check`, so nothing would flag it.

  `internal/smoke/` is not in A1's file list.
- Fold: add `internal/smoke/shapes.go` and `internal/assemble/commands.go` to A1's files. Add the
  test row "a blueprint seat with an `inputs` command still inlines its output". Make the commit
  message name every switch the new answer joined, as P:386-387 already asks for exchange kinds.

## Minor

### 12. The small exchange's scope has no test

- Severity minor, tag `correctness`. Location: P:356-357, P:363, D:79.
- Defect: no row asserts that the small exchange's request carries exactly the open small findings,
  and not round 1's or the redraft's. No row asserts that no structure, editor, or fact request is
  staged between the small exchange and the next step.
- Fold: add both assertions to the row at P:356-357: count the findings in the exchange's request
  and list the stages in order.

### 13. Check 1's last clause is not the design's, and it names the wrong record field

- Severity minor, tag `correctness`. Location: P:670-675, D:118-120.
- Defect: the design asks that the page end "on no link or handoff finding". The plan instead checks
  that "its last open findings, if a small exchange ran, were `link` or `handoff` only". That is a
  different predicate, and it is vacuous when no small exchange ran. "No gate-fix exchange whose
  findings are check-provenance lines" names a field `record.json` doesn't have. Gate fixes show as
  `writes[].gate_fix` and `gate_excerpts` (`record.go:37-38`, `:45-50`) and in the run directory's
  `gate-<n>.log`.
- Fold: measure "spent no round" as: no `gate-<n>.log` of the run that precedes a `gate_fix: true`
  write contains `marked no-claim but states the name` for a name inside link text, or `"npm
  package"`. Restate the last clause as the design's (status `accepted` implies it).

### 14. A3 greps two of claude-code's five snippet sources

- Severity minor, tag `correctness`. Location: P:527-528, D:92-94.
- Defect: the blueprint holds five `code` items. The four under `claude/snippets/` are
  `claude-md-import.txt`, `settings-hook.json`, `check-cairn.json`, and `check.yml`. The fifth is
  `templates/waymark/.github/workflows/check.yml`, from another directory (blueprint :301, :355,
  :382, :452, :467). The grep covers only two of the five, so the path that resolves from a
  different tree goes untested.
- Fold: grep for all five `=== file: <path> ===` headers.

### 15. The untracked-snippet test row contradicts the code it relies on

- Severity minor, tag `correctness`. Location: P:383-384.
- Defect: "an untracked ... file gets `fileBlock`'s 'not inlined' line", but the repo's resolver
  drops an untracked path before `fileBlock` runs (`internal/assemble/files.go:139-142`), and
  `fileBlock` writes "not inlined" only for a missing or oversize file (`:224-229`).
- Fold: state the intended behavior: either "not inlined: untracked" from the new code, or a run
  warning. Test that.

### 16. A2's golden check can't see A1's change

- Severity minor, tag `correctness`. Location: P:374-376, P:416.
- Defect: A2 confirms `read-dryrun-count.golden.json` unchanged, but in its own pair worktree, which
  lacks A1's schema change. The check can only catch A2's own edits. The real guard is A3's
  `make check` after the merge.
- Fold: assign both golden checks to A3 step 1 by test name (`TestReadDryRunRequestGolden`,
  `TestBlueprintReadRequestGolden`), and have A1 run both itself.

### 17. Finding 8 widens #16, and the excerpt grep is too narrow

- Severity minor, tag `optional`. Location: P:127-136, P:530-531, P:539-546, D:70-71.
- Defect: re-anchoring facts beyond #16's three is a scope addition, though it changes pointers
  only. It belongs in `## Decisions` and the packet, which P:51 doesn't say. A3 lists only "no
  excerpt: declaration not found". C2's new line-range pointers could fail another way, and
  `assemble/excerpt.go:50` emits several "no excerpt:" forms.
- Fold: grep every `no excerpt:` block for the fact ids the seven cite, and list the widening in the
  PR's `## Decisions`.

### 18. "One base serves every scoped read" is checked only at planning

- Severity minor, tag `correctness`. Location: P:229-231, P:302-303.
- Defect: BASE is `origin/main` at A0. The claim that each of the seven lock entries' `accepted`
  equals its blueprint blob was verified only at `517158fae` (FC section 7).
- Fold: in A0 step 6, for each of the seven, check that the lock's `accepted` equals
  `git rev-parse BASE:<blueprint>`. A mismatch stops the line.

### 19. C3 doesn't hand cross-page citers their changed facts

- Severity minor, tag `optional`. Location: P:487-492.
- Defect: a C2 fact edit can leave another page's item inconsistent. For example, `f:nls26c` is
  cited by `wm-dev-vars` on add-a-second-sign-in-group (FC:306), and that page's live text still
  tells readers to edit `.dev.vars.example` (FC:578-579). Each C3 subagent gets only its own
  findings and C2's fact list, so the inconsistency surfaces in a paid R1 read.
- Fold: give each C3 subagent its page's rows of FC section 6 for every fact C2 changed, with
  "reconcile each citing item's text".

### 20. Test and verification details

- Severity minor, tag `correctness`. Location: P:377-380, P:449-451.
- Defects and folds:
  - No #23 row covers a held page whose sibling escalates and is restored (`page.go:317-319`). Add:
    "held on a sibling's unparsed red, the sibling escalates, the page re-gates green and goes on."
  - The `failure_pattern` probe doesn't name a regex engine. drafter compiles it with Go's `regexp`
    (`internal/gate/run.go:183`). Run the probe through Go (a scratch `regexp.MatchString`, or a
    `gate.parse` call on the saved log), not `grep`.

### 21. A2 edits drafter's docs, which the design lists as out of scope

- Severity minor, tag `optional`. Location: P:393-394, P:404-407, D:128.
- Defect: the design's Shape puts "drafter's own docs" out of scope. A2 edits
  `docs/blueprint-format.md` and `docs/configuration.md`, which costs a prose-voice-reviewer read
  at close (P:694-695). The edits may be the expected behavior-sync rather than the deferred
  docs-drafting effort, but the plan never says so.
- Fold: state that these are behavior-sync edits required by the `blueprint` skill's "code changes
  documented behavior" rule, not the deferred drafter-docs pass. Or keep only `configuration.md`'s
  value change and file the rest.

### 22. Over-ceremony, small

- Severity minor, tag `optional`. Location: P:36-47 with P:293; P:201-205 with P:505; P:49-164.
- Defects:
  - A0 reruns the Pre-flight that the conductor ran just before launch (a few minutes).
  - The named-test `PASS` check runs at pair return and again at A3 step 1 (seconds).
  - The 14-finding section is about 115 lines of rationale that every executor turn re-reads. Its
    decisions are already restated in each task's Build, so it costs tokens each turn and no clock
    time.
- Fold: keep A0's one-executor checks and drop the repeated Pre-flight. Keep one named-test check
  (A3). Optionally move findings 6 to 14's evidence into the factsheets and keep one line of
  decision each.

## Questions answered

- **Every design item, Check, and Outcome clause mapped?**
  - Items 1 to 8 map to C1/C2, C2/C3, A1, R1, A1/A3, A1/A2, R2 to R5, and Close.
  - Checks 1 to 3 map to P:670-685.
  - Two Outcome or brief clauses have no check: "cairn's gate passes the prose it flagged" (#2) and
    "carry no claim the fact-check found wrong" (#4, #5).
- **Plan reading inside the design?**
  - Findings 1, 3 to 7, and 9 to 14 stay inside it or are method calls. Finding 1's reorder follows
    a dependency the design itself states (D:88-89).
  - Finding 2 changes it (#1).
  - Finding 8 is a small, pointer-only scope addition (#17).
- **31 findings each covered with a verifiable acceptance?** Covered, yes: every entry maps to a
  named fact in C2's list (P:465-471) or a C3 item, the three unplaced facts included. Verifiable,
  no (#4).
- **Checks 1 to 3 measurable from what the run records?**
  - Check 2 and Check 3 are, from the run summary, `record.json`'s `escalation`, `drafted.lock`,
    and git.
  - Check 1 is measurable only once #8 lands (`kind` and the small exchange in `record.json`) and
    #13 names the gate-log source.
