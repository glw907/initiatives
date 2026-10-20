# drafter acceptance, cairn's seven pages

Status: designed 2026-10-19, awaiting Geoff's approval. Initiative: `docs-system`. It follows B3c
(glw907/drafter#55, glw907/cairn-cms#132), which drafted eight cairn pages and accepted none, and
the brainstorm Geoff ran on 2026-10-19 over that result. The read of the eight drafts and the
fact-check of seven are in `research/2026-10-19-drafter-b3c-draft-review.md`. Geoff ruled in the
brainstorm that drafter's own docs wait until drafter is ready for production, so this pass measures
on cairn's pages, whose drafts are known.

## Brief

Approving this fixes the three things that ended B3c's drafts, reruns cairn's seven accepted
blueprints through `drafter page`, and brings you the accepted pages in one cairn PR to read. The
bar is five of seven accepted at $50. The read found seven of the eight drafts reader-grade, and the
fact-check found six wrong claims in 514, every one from a fact or a blueprint and none from the
drafting seat. The pass is planned and run without you once the docs-layout sweep merges, and it
comes back as one packet.

### Decide: The bar and the budget

B3c spent $61 on eight pages and accepted none. The seven drafts now exist, each escalation has a
traced cause, and each cause has a fix below. One whole draft with its reviews cost $2 to $8 in B3c.
The fact fixes change several blueprints, so each edited one takes a scoped read first, at about
$0.22 each.

Source: cairn-cms#132's page table; `drafter spend --since 2026-10-19`.

- Five of seven accepted, $50 ceiling with the existing $10 page cap (recommended)
- Four of seven, $40
- Seven of seven, $80

### Decide: Fix the thirty fact-check findings before the rerun

The fact-check lists 6 wrong and 24 imprecise claims, each with the draft line, the code line, and
the fix. All thirty live in cairn's facts store or blueprints, so a rerun on them reproduces the
same sentences, and your read would meet known errors. Fixing them is session work by agents under
the `blueprint` skill, with no API spend, about 90 path minutes.

Source: `research/2026-10-19-drafter-b3c-draft-review.md`, "The findings, page by page".

- Fix all thirty at the source in this pass, before the rerun, so the pages you read carry no known
  error (recommended)
- Fix the six wrong claims, and file the 24 imprecise ones in cairn's backlog
- Fix none here, and file all thirty for cairn's docs sessions

### Standing answers

The planner and conductor apply these in place of stopping.

- A plan within twice the estimate (800 path minutes) launches unattended once the sweep merges.
- Live spend up to the ruled ceiling runs without asking. The meter is `drafter spend --since
  <launch date> --json`, its `total` plus `open.worst`.
- An escalated page is reported with its finding, and the run continues. The loop guard, the
  traced-cause rule, and the returning-cause rule in `pass-core` apply as B3c's rulings set them.
- When the bar becomes unreachable, the run finishes every page that can still accept, closes, and
  reports the count.
- A finding that changes this design, or spend past the ceiling, stops and asks.

## Outcome

Five or more of cairn's seven non-figure stage 2b pages hold a draft that drafter accepted, that
passed cairn's docs gate, and whose lock entry matches, in one cairn PR for Geoff's read. drafter's
acceptance rules weigh what a finding is, cairn's gate passes the prose it flagged, and the facts
and blueprints behind the seven carry no claim the fact-check found wrong.

## What it builds

1. **cairn's gate.** `check:provenance` stops reading a linked symbol or path in a no-claim
   sentence as a claim, and stops reading "npm package" as a command (cairn #14). `check:symbols`
   stops reading the `#lib/...` import alias as a file path (#15). The three facts that cite
   `section-action.ts#createSectionAction.wrap` are re-anchored (#16), and `blueprints` joins
   `check:leaks`' scan roots (#20).
2. **The facts and blueprints.** The thirty findings, per the decision above, each edited at its
   source with the research record's file and line. The misleading doc comment at
   `admin-action.ts:155-156` is filed for cairn's backlog, not edited here.
3. **drafter's escalation rule.** Every finding that can end a page carries a kind: a review
   seat labels its findings, and the coverage check's misses already carry the blueprint item's
   kind. After the second fix verdict, a page whose open findings are all of a small kind (a link,
   a handoff, a heading, or a brief citation) gets one more fix exchange scoped to those findings,
   then the deterministic checks run again (the gate and the coverage check, no review seat), and
   it accepts if they pass. A page with any open finding of another kind escalates as today: a
   fact, a claim, a code sample, a register or voice finding, a missing step, misplaced content.
   The list of small kinds is closed, so the editor seat keeps its force. The rule applies at the
   round-2 verdict and at the coverage check's second miss (`afterCoverage` in
   `internal/pipeline/steps.go`), where restrict-admin-access and security-model ended; the
   reader and coherence retests keep their rules. The fact seat's strictness does not change.
4. **The edited blueprints' reads.** A fact or blueprint fix under item 2 changes the blueprint
   or a fact it cites, so before the rerun each edited blueprint gets `drafter read --since
   <pre-fix commit>`, which advances the lock on an accept (#25). Those reads count against the
   ceiling (about $0.22 each in B3c). A read that blocks takes the loop guard; a blueprint that
   will not accept is reported, and its page counts as escalated, not as a design stop.
5. **drafter's inputs.** A blueprint `code` item that names a file in the project reaches the
   draft seat with that file's contents, so a snippet the page must quote is never left to the
   model's memory. The claude-code page's two snippets are the fixture.
6. **drafter's run rules.** A gate red that names only a sibling page of the same run holds the
   page instead of spending a fix round (#23); a scoped accept advances the lock (#25); the stock
   draft ceiling rises above 64000 tokens (#26).
7. **The rerun.** `drafter page --whole` on each of the seven, smallest first, on cairn's chain
   module as B3c ran it. Each page ends accepted or escalated with its finding and stop rule.
8. **Geoff's read.** One cairn PR carrying the accepted pages, their briefs, and the lock.

The numbers above are `BACKLOG.md` item numbers in each repo (cairn #14 to #20, drafter #23 to
#26), not GitHub issues. The order of work is items 1 and 2, then 4, then 3, 5, and 6, then 7.

## Calls made in this design

- Rotate stays out. Its blueprint's recovery handler is a writing problem for a cairn session
  with the `blueprint` skill, and its draft grew 80 percent against the live page.
- No code-grounded fact check joins drafter in this pass. The fact-check shows the need: 6 wrong
  claims passed `drafter check` because it verifies that a source pointer resolves, not what the
  fact says. That is a design of its own ("Later"), and it changes the facts contract, so it
  does not ride on a pass whose job is to prove acceptance.
- cairn stays on its chain module, as B3c ran. Moving cairn to the stock prompts is B5's job.
- The three figure pages stay out until drafter takes figures.

## Check

1. One page end to end, restrict-admin-access: `drafter page --whole` on the fixed gate and rule
   reaches `accepted` in `drafted.lock`, spending no round on a provenance hit the fixed check no
   longer raises and ending on no link or handoff finding.
2. Each of the seven ends accepted or escalated with a recorded finding, and the accepted count
   meets the ruled bar. Each accepted page passes `npm run check:docs-gate -- --page <page>
   --brief <brief>` in cairn.
3. Each accepted page's lock entry matches its page, its blueprint, and `accepted`.

## Shape

- Out of scope: rotate; drafter's own docs; O, B4, and B5; a code-grounded fact check; the three
  figure pages; the docs-layout sweep's moves.
- Risk class `runner`: drafter's pipeline and chain, and cairn's `scripts/checks`. `live-account`
  for API spend. `money.go` and `fingerprint.go` stay untouched; `resume.go` follows B3's ruling.
- Repos: `glw907/drafter` (items 3, 5, and 6) and `glw907/cairn-cms` (items 1, 2, 4, 7, and 8, on
  one branch). Merge order: drafter first, then cairn with a merge commit. Item 3's third exchange
  may touch `resume.go`, under B3's ruling: test-first, each commit read by `diff-reviewer` at task
  scope.
- Depends on: the docs-layout sweep's PRs (glw907/drafter#54, glw907/cairn-cms#131) merged, since
  that session asked for no launch into either repo until then. The executor runs on `pavilion`,
  where B3c ran; the conductor is `conductor-drafter`.
- Estimate: 400 path minutes. B3c planned 795 and ran about 640 with five stops; B3 planned 690 and
  ran about 300; F2 planned 310 and ran about 30. The rerun's API waits dominate this one.

## Pre-flight

Nothing for Geoff. The executor copies `~/.config/drafter/cairn-cms.local.toml`, present on this
workstation, into the cairn worktree as `drafter.local.toml` and runs `drafter config` there. The
conductor checks the two sweep PRs are merged before launch.

## Later

- A code-grounded fact check: give the fact seat each cited fact's source excerpt beside its bullet,
  or have the `blueprint` skill's fact-writer read the whole function it summarizes. The evidence is
  the research record's "Where the six wrong claims came from".
- The misleading doc comment in `admin-action.ts` and the stale lines in the live security-model
  page (312-314, the tidy and dictionary claim) that the drafts inherited.
