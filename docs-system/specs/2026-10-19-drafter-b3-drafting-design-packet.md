# This packet approves drafter's B3 design, and approving plans and runs it overnight so a page drafts from its blueprint on drafter's own prompts.

Two calls are yours before the run starts: whether cairn's half waits for its own pass, and whether the run may edit the resume code on the money path.

## Background
The docs-system initiative builds drafter, which turns a page's blueprint into a reviewed page. F2 merged tonight (glw907/drafter#52), so B3 is next. B3 makes `drafter page` take a blueprint, writes the lock (drafter's record of what it last drafted), redrafts only the sections a blueprint change touched, and adds drafter's own prompts for every seat, plus a provenance check that ties each sentence to a fact. A seat is one model role in the pipeline, such as the drafter or the editor.

## If you approve
1. [session] Merge glw907/initiatives#38, which files this design.
2. [session] Plan B3 tonight (three lenses, the fold, and a verification read), and hand it to conductor-drafter, which launches the executor.
3. [you: read the pass's packet] Read B3's packet in the morning, with the live check's result.

## Not checked
The 360-minute estimate comes from F2 running far under plan. The plan sets its own figure. The live check measures whether the stock prompts draft a page the gate accepts.

## Ask: Move cairn's half of B3 to its own pass?
Rule: owner-call
Part: none
Recommended: 1
Reason: cairn's half needs a whole blueprint read that accepts, which no read has done, and it needs your ruling on backlog #13 first.
Summary: B3 as planned also converts cairn's remaining plans and drafts its pilot pages, which needs a whole read to accept a cairn blueprint. Four whole reads in a row each blocked on a new finding, so that half can't run tonight.

Background: A whole read reviews an entire blueprint, not just a change. The change read works; the whole read keeps finding something new after each fix. The drafter half uses a synthetic project and doesn't depend on it.

Facts: The whole-read problem is open and unruled.
- Four whole reads of one base each blocked on a different finding (`drafter BACKLOG.md #13`)
- cairn's first blueprint failed six whole reads (`glw907/drafter#43`)
- The onboarding design gates O on a whole read accepting a cairn blueprint (`docs-system/specs/2026-10-18-drafter-onboarding-design.md`)

Choices:
- Split: B3 builds drafting in drafter tonight, and a B3c pass takes cairn's conversion, the whole-read bar, and the pilot drafts after you rule on #13
- Keep one pass: nothing runs tonight, and B3 waits until #13 is ruled and designed in

## Ask: May the run edit the resume code if it needs to?
Rule: contradicts-ruling
Part: none
Recommended: 1
Reason: The lock write likely reaches the resume's file check, and a test-first edit with a reviewer read keeps the safeguard without an overnight stall.
Summary: Your pass 5 ruling treats the money path as high risk, so every pass stops on any edit to `resume.go`. Writing the lock adds a file each run owns, and the resume's file check accounts for each one, so an edit there is likely.

Background: `resume.go` restarts a stopped run without paying twice. `money.go` holds the spending caps. A stop overnight waits until you wake.

Facts: The resume check tracks every file a run writes.
- `checkTree` requires every run file to be at a hash the state accounts for (`internal/pipeline/resume.go:254`)
- Today a run owns only the page and its brief, and the lock is shared by every page (`internal/blueprint/lock.go`)

Choices:
- Allow it: edits to `resume.go` are written test-first and each commit gets a reviewer read before the next task; `money.go` still stops the run
- Keep the stop: a needed `resume.go` edit halts the run until you answer

## Routine
| Part | Verdict | Fact | Why |
|---|---|---|---|
| glw907/initiatives:docs-system/specs/2026-10-19-drafter-b3-drafting-design.md | approve | Its scope is the B1 build sequence's B3 plus the onboarding design's B3 additions, less cairn's half if you split. | It adds nothing those designs didn't name. |
| glw907/initiatives#38 | approve | The PR files the design and this packet. | It changes no behavior. |
| step:1 | session | A merge can be reverted. | The design is a record. |
| step:2 | session | The pass spends API credit, budget $20 of your $200 monthly credit; $24 is spent so far this month. | The live check drafts one synthetic page twice. |
| step:3 | you | The pass comes back to you as one packet. | Nothing merges unread. |
