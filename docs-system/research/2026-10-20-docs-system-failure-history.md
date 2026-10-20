# Docs-system failure and progress history, 2026-10-12 to 2026-10-20

Date: 2026-10-20. Initiative: `docs-system`. The seed brief for the brainstorm Geoff ruled on
2026-10-20: how a new docs page first gets a polished, fully dependable blueprint before drafter
spends anything drafting it. Sources are the record's Status list (`docs-system/README.md`), the PR
bodies of glw907/drafter and glw907/cairn-cms, and two research records:
`research/2026-10-19-drafter-edit-quality-analysis.md` and
`research/2026-10-19-drafter-b3c-draft-review.md`. Each fact names its source.

## Brief

This record lists every pass of the docs-system initiative, what it was meant to prove, what it
proved, and why it missed when it missed. Eighteen passes are covered. Eight set a live quality bar and missed
it; ten met theirs, and B3 is the only one of those with a live bar. In every missed pass a blueprint or the facts store carried a defect
the reads or seats found. Until B3c those defects were the reason a bar was missed. From B3c on,
most pages ended at the acceptance machinery or a drafting seat, while the blueprint and facts
defects still decided what was true on the page. For the blueprint-first design, that means the
blueprint and its facts are the cheapest place to catch the failures that matter, but a dependable
blueprint alone would not have produced an accepted page in either drafting pilot.

Addendum, 2026-10-20 evening: the blueprint-first pass ran and ended early at Geoff's ruling,
after its replay, its read at `main`, and its controls (see "The blueprint-first pass" below). It
is the nineteenth pass and the ninth to miss a live bar. Live spend across the eight passes that
spent API credit (B1, change-read, skill-rules, edit-quality, B3, B3c, acceptance, blueprint-first)
is about $183, and no drafted page has yet reached an accepted state.

## Passes and outcomes

Dates are merge dates. "Build bar" means the pass's offline acceptance: the gate, the tests, and an
accepted whole-branch review.

| Pass | Date | Goal or bar | Outcome | Cause of the miss | Class |
|---|---|---|---|---|---|
| Pass 0 (drafter#1) | 10-13 | Plan format and `check-plan`; build bar | Met | None | |
| Format additions (drafter#6) | 10-13 | Fold cairn's 11 real page plans' format findings | Met | None. The real plans exposed format gaps, all taken as optional additions | |
| Passes 1 to 4 and follow-ups (drafter#11, #16, #24, #30, #31) | 10-14 | Config, key and money, prompts, page parts, ledger fixes; build bar | Met, no API spend | None at merge. Pass 2's reviews found a double-counting settle and a resume that could cancel a billed batch (drafter#16) | drafter mechanics, caught before merge |
| Pass 5 (drafter#37) | 10-14 | Pilot-ready: one real cairn page through drafter | Missed: both real pages escalated at the chain's plan read, 2 and 3, then 3 and 3 blocking findings; no drafter stage ran | Plan content: rotate lacked a deploy step after `wrangler versions secret put`; restrict had failures with no step and a step depending on a warning seen only after deploy | blueprint content |
| B1 (drafter#46, cairn-cms#128) | 10-18 | Rotate's blueprint accepted | Missed: six of six reads answered fix (7, 5, 5, 2, 3, 4 blocking); $1.53 of $10 | Blueprint gaps, with several fixes seeding the next round's findings; one finding judged wrong (a `from` asked for, then refused) | blueprint content; read seat |
| B2 (drafter#47) | 10-18 | Four of five small tweaks accepted | Missed: 0 of 5; diagnostic 3 of 5 | Scope was a whole section, so 34 of 37 findings were older defects in the base blueprint | read seat; blueprint content |
| Change-read (drafter#48) | 10-18 | Four of five | Missed: 1 of 5; $4.52 of $10 | Every miss was a blocking finding on content the tweak added (invented output, a recovery before its failure, a teaser heading); two consistency escalations on a base fact pair | blueprint content; facts store |
| Skill-rules (drafter#49) | 10-18 | 17 of 21 first-try accepts | Missed: 12 of 21; $15.37 of $20 | Caution and section edits passed 0 of 6. The analysis found two of nine misses were judge variance and one failure class came from the skill's own rule; fact `f:sszb7b` overstated the code | blueprint content; read seat; planning and process; facts store |
| F1 setup checks (drafter#50) | 10-18 | No false `store` error against cairn's `check:facts` | Met after a fix for 8 false errors; no spend | None at close. Stale range on `f:6hmgmv` found and filed | facts store, found |
| Edit-quality (drafter#51) | 10-19 | 19 of 21 within two reads, 20 within three, 0 unread commits | Missed: 15, 17, 1; $9.44 of $40 | Two of four misses were consistency escalations on base fact conflicts the change never touched (#12); one session stopped early; one mislabel | drafter mechanics; facts store; read seat |
| F2 (drafter#52, cairn-cms#129) | 10-19 | Stock prompts, tracks, `introPlan`; offline rows | Met, no spend | None. One review blocker fixed | |
| B3 (drafter#53) | 10-19 | Three live drafting rows on synthetic `tally` | Met on the twentieth live run; $17.15 of $20 | The thin `tally` blueprint and facts were rewritten across runs; one reader call in four hit 32,000 tokens; a batch sat 110 minutes | blueprint content; facts store; drafting seats; infrastructure |
| B3c (drafter#55, cairn-cms#132) | 10-20 | Three of eight drafted pages accepted | Missed: 0 of 8; $61.43 of $80; five stops for rulings | Four endings at cairn's gate or a facts defect, three at the second-fix-verdict rule, rotate's blueprint never held | project gate (added below); drafter mechanics; blueprint content; facts store; planning and process |
| Acceptance (drafter#56, cairn-cms#133) | 10-20 | Five of seven accepted | Missed: 0 of 7; $40.30 of $50 | Two pages at the read on fact-to-fact conflicts; three on second fix verdict; one at the $10 cap after a `--sync` rerun; one reader loop | facts store; drafting seats; budget and caps; infrastructure; planning and process |
| Blueprint-first (branches only, no PRs) | 10-20 | Replay 20 of 25; zero false blocks at `main`; six of six controls | Replay 17 of 25 after two tuning rounds, passed by ruling on 10 of 13 false or over-claiming bullets; 3 false blocks at `main`; six of six controls, one caught only by the blueprint seat; about $33 of $45; ended by ruling before E, B, S, RB, and K | The fact-truth seat reads excerpts, not the repository: 225 of R2's 254 findings were pointer blocks, where the excerpt lacked code the claim needed. It also read a held claim in view as "holds" in 8 replay misses, and the bar counted "omits" bullets the seat has no verdict for | read seat (new fact-truth seat); facts store; planning and process |

I added one class, project gate: cairn's own docs checks flagging prose they should pass. It ended
four of B3c's eight pages (cairn-cms#132, backlog #14 and #15) and is neither drafter code nor
the facts store.

## What each pass proved

| Pass | What held up |
|---|---|
| Pass 0 to pass 4, follow-ups | `check-plan`, layered config, the key resolver, a ledger that reserves before it spends, goja prompts, the page parts. No later pass spent past its live budget (each PR's spend line) |
| Pass 5 | `drafter page`, stop and resume, the live smoke on production shapes; the two real runs found no drafter fault (drafter#37) |
| B1 | `drafter check` over all 11 stage 2b pages in 0.82 seconds; a control read with a step removed still blocked (drafter#46) |
| B2 | Every session fired the skill and left one clean commit; the page hook named the right blueprint; the seeded control was caught (drafter#47) |
| Change-read | No blocking finding on an untouched item; all 21 "Already present:" findings sit in the base; both controls bit (drafter#48) |
| Skill-rules | Link and removal edits passed 6 of 6; an empty consistency conflict no longer blocks (drafter#49) |
| F1 setup checks | 0 errors and 51 warnings over 3,014 fact pointers, against cairn's `check:facts` OK (drafter#50) |
| Edit-quality | `drafter check` green on the first commit 21 of 21; 1.48 reads per edit; prompt cache read 38,893 tokens per in-session read; judge agreement held (drafter#51) |
| F2 | The stock module, `require_prompts`, the `introPlan` check; the #12 replay turned all four saved conflicts into "Already present:" (drafter#52) |
| B3 | Drafting from a blueprint on stock prompts; a one-item edit redrafts one section; an unchanged run spends nothing (drafter#53) |
| B3c | The read bar, with Check 1 met live on security-model; seven of eight blueprints accepted; seven of eight drafts reader-grade, and no wrong claim among 514 came from the drafting seat (drafter#55, the B3c draft review) |
| Acceptance | Every live finding carried its kind; the scoped accept advanced five blueprints; 31 of 31 fact fixes verified; the gate replay left one hit; the stall rule abandoned one run cleanly at zero open spend (drafter#56, cairn-cms#133) |
| Blueprint-first | The offline build: the lock's `facts` hash and lapse rule, `drafter excerpt`, dotted anchors, covers ids, all gates green in about a third of their estimates. The fact-truth seat caught 23 distinct real fact defects at `main` the earlier reads had not, and its controls 3 and 4 bit on seeded fact errors. `drafter check` caught the moved pointer (control 6) offline. The meter held every live call inside the ceiling (blueprint-first STATUS) |

## Recurring patterns

### Blueprint and fact gaps drive the blueprint-stage misses

From pass 5 to edit-quality, every missed bar traces to the content of a plan or blueprint, either
the base page or the content an edit added. Pass 5's plans lacked steps (drafter#37). B1's six reads
kept finding missing state, such as no step recording the old key's fingerprint (drafter#46). In the
three format tests, the misses moved from older base defects (B2, 34 of 37 findings) to content the
tweak itself wrote (change-read, 4 of 4; skill-rules, 9 of 9). The edit-quality analysis puts it
plainly: the format is sound, and what fails is editorial judgment inside authored content. Edits
pass in proportion to how little reader-path reasoning they need: 6 of 6 for links and removals,
0 of 6 for cautions and sections.

The evidence does not fully support "gaps alone". The same analysis found two of nine skill-rules
misses were judge variance, and one failure class came from the skill's own rule forcing a caution
into a failure row with no honest handler. B2's zero came from the read's scope, not the edits.

### The drafting pilots ended mostly in machinery and seats, not inputs

Across B3c and acceptance, 15 page endings break down as follows. B3c had four at cairn's gate or a
facts defect, two at a second-fix-verdict rule blind to a finding's kind, one at a missing snippet
input, and one at rotate's blueprint (the B3c draft review). Acceptance had two at fact conflicts,
three at the second fix verdict, one at the cap, and one at a reader fault (cairn-cms#133). Inputs
directly ended about four of the fifteen. The B3c review found seven of eight drafts reader-grade,
and the acceptance PR says the pages "failed on their own writing". That part of the record weighs
against the claim that blueprint and fact gaps dominate.

It also qualifies that weight. All six wrong claims in B3c's 514 entered through a fact bullet, a
blueprint sentence, a stale live page, or a code comment, none from the drafting seat. Acceptance's
second-fix verdicts include fact-claim findings, such as a claim past `f:vhxkab`. Inputs decide
truth; the machinery decides acceptance.

### The facts store carries conflicts no pass owned

Fact pairs that disagreed at base escalated reads in change-read, skill-rules, and edit-quality
(drafter#48, #49, #51), and two acceptance pages never drafted for the same reason (cairn-cms#133).
`drafter check` verifies that a source pointer resolves, not what the fact says (the B3c draft
review). In acceptance's read rounds, the fixes for blocked reads were mostly fact edits, and two
of them touched facts already-accepted blueprints cited (cairn-cms#133, standing answer 8).

### Fixes seed the next finding, and whole reads rarely converge

B1's counts ran 7, 5, 5, 2, 3, 4, and several fixes caused the next round's findings (drafter#46).
In B3c, rotate's re-push handler blocked three times and the stop rules were written in response
(drafter#55). A whole read of the rotate base escalated in skill-rules, and in edit-quality four
whole reads each blocked on a different finding (drafter#49, #51).

### Time, money, and plan gaps compound

Batch latency took about five hours of the acceptance pass, and the forced `--sync` rerun at twice
the price is what reached the $10 cap (drafter#56). B3 abandoned a batch at 110 minutes. B3c
stopped five times for rulings, each a planning miss, and acceptance once more (drafter#55, #56).

## What the blueprint-first design can rely on

The record gives the brainstorm a working base. `drafter check` is dependable as the offline
promise: 21 of 21 edits passed it on the first commit, and it runs over a whole doc set in under a
second (drafter#51, #46). Fact sources resolve against the repo with no false errors on cairn's
3,014 pointers (drafter#50). The change read judges only what a change adds, its controls bite in
every run, and it agrees with itself on rereads (drafter#48, #51). The read bar lets a blocked
whole read be driven to an accept, shown live on security-model, and the scoped accept now
advances the lock (drafter#55, #56). Seven of seven non-rotate blueprints in B3c and five of seven
in acceptance reached an accepted read. Every live finding carries a kind (drafter#56). The
drafting seat is faithful to its inputs: no invented claim in 514 checked (the B3c draft review).
The ledger never let a pass overspend, and the stall rule abandons a run cleanly.

What it cannot rely on yet: a whole read accepting a large base in few rounds, a facts store free
of conflicting pairs, a judge that draws the nit line the same way twice, and batch latency short
enough to keep a live loop under an hour.

## What a dependable blueprint would have had to catch

This lists only failures the record shows, pass by pass.

- Pass 5: a deploy step after the secret push, failures placed at the step that causes them, and
  steps whose inputs exist before they run.
- B1: state a later step needs, such as the old key's fingerprint, and handlers that cannot delete
  the active key or name the wrong endpoint.
- B2 to edit-quality: the base defects that came back every run (handlers that are lead-ins or
  facts, a section pointing at itself, a split `covers` line), so a small edit lands on a base a
  whole read accepts. It would also need a way to refuse a request the facts cannot satisfy, as in
  prompt 4 (the edit-quality analysis).
- B3: steps, and facts no wider than the code they cite.
- B3c: rotate's rollback handler, steps that lived only in a handoff, a stale outline line, the
  five fact or blueprint sources of the six wrong claims, and three facts citing a dead anchor.
- Acceptance: the two fact-to-fact conflicts before any drafting, and fact edits checked against
  every blueprint that cites them.

It would not have caught B3c's gate false positives or second-fix-verdict endings, acceptance's
reader loop, or its cap. Whether acceptance's drafting findings had a blueprint-side cause, such as
a placement the blueprint left open, the sources do not say.

## The blueprint-first pass

Source: the executor's STATUS (`blueprint-first-status.md` in drafter's `blueprint-first` worktree
git dir), the plan's "Rulings during the run", and the conductor's session. The pass built its
offline half fast and well: T1, the D1 and D3 pair, M1, D2, and D4 each closed at a third or less of
its clock. Its live half answered the one new question the design asked, whether an API seat
reading source excerpts can judge a fact true, and the answer was "partly, at high noise".

- The replay at cairn `517158fae`, against the 25 bullets the B3c hand check found wrong: 10 of 25
  on the first prompt, 17 of 25 after two tuning rounds ($9.14 of the $10 tuning pool), against a
  bar of 20. On a 66-fact request, restrict's first read answered one entry and lost two bullets
  to an empty answer; round 1 fixed that. Geoff ruled the replay passed on the 13 false or
  over-claiming bullets, where it flagged 10 (ruling 1). Twelve of the 25 were "omits" bullets, true as
  far as they go, which the design's verdicts (holds, wider, contradicts) cannot flag.
- The read at `main` on the final prompt: all eight blueprints escalated. The fact-truth seat raised
  254 findings. 28 were new catches (23 distinct real fact defects), 225 were pointer blocks, and 1
  was a false block. A fresh-context check moved two more pointer rows to false blocks, so the
  count is 3 against a bar of zero. Pointer blocks came from history halves only CHANGELOG.md shows,
  directory and prose pointers with no excerpt, enum members held in another file, absence
  claims, drifted line pointers, and excerpt windows ending one line short.
- The controls: six of six bit. Control 5's seeded false claim ("a missing `AUTH_DB` throws") was
  caught only by the blueprint seat; the fact-truth seat read it as holding with the settling code
  in its excerpt.
- Spend: about $33 of the $45 ($10.83 for the replay, $9.14 tuning, $10.71 for the read at `main`,
  the rest controls). M1's dry-run pricing projected $62 for the whole plan before the first live
  call.

Planning misses this pass adds:

- The replay bar counted "omits" bullets that the design's verdict set cannot flag, so 20 of 25
  was out of reach by construction. The bar should have been set on the false and over-claiming
  bullets alone.
- The tuning pool ($10) was about one full replay rerun ($9.83), so standing answer 3's three rounds
  could never run in full. The executor stopped after two, when the third could no longer reach the
  bar.
- The plan launched with a projection ($62) well over its ceiling ($45) and relied on E yielding.
  The design's estimate never priced a full pass.
- The executor's launch prompt let it refuse its conductor's messages, so each of Geoff's two
  rulings took a stop and a relaunch. pass-core now has the executor take its conductor's messages
  as instructions (dotfiles #113), and the auto-mode classifier still blocks a conductor's relayed
  ruling as self-modification. The delegation question is open.

What the pass suggests for the next design, as evidence and not as a ruling: the seat's real
catches (23 at `main`, 10 of 13 in the replay) came with about eight pointer blocks for each catch.
Its recurring miss was code just outside the excerpt. B3c's hand fact-check ran on session tokens
with repository access and found all 6 wrong claims in 514 with a file:line each. The executor's
own recommendation for a next pass is the same shape: a fact-truth read with repository access.
