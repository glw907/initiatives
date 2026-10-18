# Why small blueprint edits miss the read, and what to do about it

Status: analysis for Geoff, 2026-10-19, from the three format-test passes (drafter#47, #48, #49),
the 26 run records under `~/.local/state/drafter/runs/cairn-cms/20261018T22*`, the architecture
and onboarding specs, the skill, the read prompt, and the pipeline code. Read-only: nothing here
changed a repo. Initiative: `docs-system`.

## Brief

The format is not the problem. Every one of the 21 edits decoded, passed `drafter check`, and
landed as one clean commit. What fails is editorial judgment inside the content the agent writes:
whether a handler leads anywhere, whether a claim is wider than its fact, whether a new section
belongs between a step and its check. Edits pass in proportion to how little of that judgment
they need: a link or a removal needs none (6 of 6), an example, fact, or failure row needs some
(6 of 9), a caution or a section needs the agent to reason about the reader's whole path (0 of 6).
Written rules did not move the rate because the misses were not rule lookups. They were reasoning
the author's own context cannot do well, and two of the six shapes were requests the page should
not have satisfied as asked: the skill itself forced a caution into a failure row with no honest
handler, and the section prompt asked for exposition the recovery section already carries.

The measure is also wrong. First-try acceptance by an adversarial developmental editor grades a
$0.30 edit by the bar of a whole-page read, blocks on items Google's review standard calls nits,
counts cairn's house rules against a stock system that will not have them, and carries judge
variance: two of the nine misses were defects that identical sibling edits passed with an advisory
note. No code team measures its developers by zero-comment first pushes.

Recommendation: keep `drafter check` green on the first try as the offline promise (met, 21 of
21), and make the gate "accepted by a read in the same session", two reads in the common case and
three at most, with the read run by the skill in the author's own session, where the context to
fix the finding still exists. Alongside: fix the two
skill defects the evidence names, add two mechanical warnings for the handler shapes that recur
on the base itself, make the change read's blocking bar reviewer-grade (wrong, stuck, or missing
state blocks; order, heading, and placement are nits), and rerun the test on a base the whole read
accepts. Expected cost about $0.35 to $0.70 per edit, under a minute a round, inside the caps
that already exist. Option 2 (an Opus writer) does not address the cause. Option 3 (accept 57%)
is the safe floor the nightly read already provides, and it moves every fix into the morning
report, which is the expensive seat. The architecture's goal should change: it conflates
structural correctness, which an offline check proves, with editorial correctness, which only a
read proves.

Revised 2026-10-19 after Geoff's rulings and his cost-split idea. The three-layer split (free
local checks, an API read for the judgment, fix and polish on the session's own tokens with local
tools, then the read again) works with this recommendation and is now its shape. The currencies
are not dollars: Geoff's $200 of monthly API credit covers every read this design can run
(a two-read edit is about $0.70, a four-edit pass about $3, against drafts at $3 to $4.50 a
page), and the scarce resource is his subscription. So the line between polish and another read
is drawn by the guarantee, not the price: the last read comes after the last change, and the
committed blueprint is one a read accepted. Fixes and polish happen between reads in one pass, so
the common case is two reads and under three minutes of waiting. Vale on blueprint prose is
feasible but useless here: probed on the test blueprint it raised 152 findings on 145 prose
fields, nearly all register rules for published prose, and none on any of the nine miss shapes. A
same-context self-review is disproved by the data; a fresh-context Sonnet pre-review would spend
the scarce resource to save the free one, so it is not worth an arm.

## Geoff's rulings (2026-10-19)

| Decision | Ruling |
|---|---|
| 1. Split the architecture's goal | Yes. The loop is the skill's default when a key is set. |
| 2. The change read's blocking bar | Reviewer-grade: wrong, stuck, or missing state blocks; the rest is a Nit. |
| 3. Register rules in a blueprint read | They do not apply. The editor seat holds them on prose. |
| 4. The loop as the default | Folded into 1. |
| 5. Priority | A small pass after F1. |
| 6. Prompt 4's fate | The planning session's method call: keep one decline test. |

Geoff's idea, in his words: "Is it possible that we should [add] a final local check where we have
tooling available? (linters, etc.) That way the cost is split. The API credits do most of the work,
and the final polish is handled using normal tokens?" The section "The cost split" weighs it. The
budget frame for it: Geoff has about $200 of API credit a month beside his Claude Max
subscription, he is drafter's primary audience, and reads and drafts inside that credit cost him
nothing while sparing the subscription, which is the scarcer resource. A second API read is not a
cost; its price is latency and whether the committed change was judged.

## The evidence

### What the four runs measured

| Run | Read scope | Pass | What the misses were |
|---|---|---|---|
| B2 (#47) | By section | 0 of 5 | Older defects in the touched section, 34 of 37 findings |
| change-read (#48) | By change | 1 of 5 | Defects in added content, 4 of 4; one base fact conflict |
| skill-rules (#49) | By change, rules added | 12 of 21 | Defects in added content, 9 of 9 |

The scoping work is done. From #48 on, no blocking finding sat on untouched content, both seeded
controls bit in every run, and the base's older defects came back as "Already present:" and let
the change through. The skill-rules rate is the first clean measure of the skill's output.

### The rate by edit shape

| Prompt | Shape | Passed | What the agent had to author |
|---|---|---|---|
| 6 | Add a link | 3 of 3 | A target URL and a placement |
| 7 | Remove a claim | 3 of 3 | Nothing; a deletion |
| 1 | Add an example | 2 of 3 | One item whose content agrees with two facts |
| 2 | Correct a fact | 2 of 3 | A fact bullet and the placements that cite it |
| 3 | Add a failure case | 2 of 3 | A symptom, a cause, and a handler, against one fact |
| 4 | Add a caution | 0 of 3 | A failure row whose handler leads somewhere, in a page with two failure lists |
| 5 | Add a section | 0 of 3 | A section, its place, its heading, and claims against three facts |

The rate tracks the amount of reader-path reasoning the edit demands, not the YAML the edit
touches. The architecture's second pilot risk, "the format may be too heavy for small edits"
(architecture spec, lines 545 to 550), is retired by this data: 21 of 21 commits were well formed
on the first try.

### The nine misses, read against the records

Each miss below is from the run's `record.json`, with the diff from its change block.

| Run | Blocking finding | Class | Would it reach the page? |
|---|---|---|---|
| 1a | A `code` item claims `githubAppToken` is absent "since a `?live=1` request mints no token", resting on `f:1pb077`, which it does not cite; and a transcript with `HTTP/2 503`, a protocol version no fact states | Fact grounding | Yes: an uncited claim and an invented line |
| 2b | A sentence in a failure's `cause` ("logged at warn level, so a query filtered to errors misses it") is query guidance, not a cause, and a reader who filtered to errors never reaches the row | Placement | Mildly: the fact is true, the field is wrong |
| 3b | The cause says "the site keeps a settled live-check result"; `f:1pb077` says each isolate does, so the stale answer is possible, not certain | Overclaim | Yes: a reader may misread a fresh failure as stale |
| 4a | The handler re-pushes the same PEM, which by `f:h252kb` gives the same answer: a loop with no exit; and the new failure has no row in the recovery list | Reader path | Yes: a reader is stuck |
| 4b | The handler computes a local openssl fingerprint, which never identifies the Worker's key, so `key-identified` is never produced for `s-live` and `s-delete`; openssl is given to no reader; three actions in one `sentence` | Reader path, state | Yes: a reader is stuck, and Windows readers cannot run it |
| 4c | The handler is `rec-push-link`: back to the push section, the same loop | Reader path | Yes |
| 5a | A claim that the editor-facing window is "the time the developer takes to run the checks" is false; a "What editors see while you check" heading; the section duplicates `x-editor` and sits between the push and its proof | Fact, heading, order | The claim yes; the rest is design |
| 5b | The heading again; exposition between the push step and the checks; "every request that needs GitHub fails" overstates `f:7u49xs` | Heading, order, overclaim | The overclaim yes |
| 5c | The heading again; "not an outage" contradicts `f:ogokfy`; the same exposition placement; a `use` that restates `f:vg42j3` | Heading, fact, order, use | The contradiction yes |

Three things stand out.

**The judge is not consistent on the nit boundary.** Run 2c added nearly the same sentence as 2b
to the same `cause` field; the read called it "advisory only ... neither edit breaks any checklist
item" and accepted. Run 3a's cause said "the site keeps a settled live result for 60 seconds", the
same overclaim as 3b's; the read wrote "Advisory on the change ... No checklist item fails" and
accepted. Two of the nine misses are the judge's call on a finding its sibling read demoted. With
a consistent judge, prompts 1 to 3 score 8 of 9, not 6 of 9. A bar that includes judge variance
cannot be read to the single edit.

**Prompt 4 is a request the facts cannot satisfy, and the skill made it worse.** `f:h252kb` says
the check "omits `fingerprint` with no message when it cannot compute it." Nothing in the facts
store gives a reader a route out: the key cannot be identified from the response, and the page's
delete step relies on that identification. The honest edit is a caveat (a `sentence` claim: a
pass with no fingerprint does not identify the key) with a hand-off to recovery, or a report that
the case has no handler. The format page's catalog has that row ("Add a caveat: a `sentence` item
with `mode: claim`"). The skill overrides it: "A caution about something that can go wrong is a
`failure` item with a handler, not a `sentence`" (SKILL.md, case 2, added when backlog #4 closed),
and "Check what you add" repeats it. A `failure` requires `handledBy`, so all three Sonnet runs
invented a handler, and Opus correctly saw each as a loop or a dead end. A rule written from the
previous pass's miss created this pass's failure class. The second finding on 4a and 4c, that the
case needs a row in both [[verify-the-new-key]] and [[recover-from-a-failed-key]], is a property of
this page: it keeps two failure lists for the same checks (`x-fingerprint` and `x-wrong-key`
duplicate, as the read itself notes "Already present:" in 7a, 7b, and 5c). A caution edit on this
page is lose-lose: add one row and the lists disagree; add two and the duplication grows.

**Prompt 5 asks for the wrong edit, and the agents complied.** The prompt says "Add a short
section ... what editors see while a bad new key is in service, and for how long, so they know what
to expect while they run the checks." That dictates the heading's shape, the placement (between
push and verify), and content the recovery section already carries (`x-editor`,
`rec-editor-fact`, `rec-editor-timing`). The skill says "Prefer an item edit when one does the
job," and the right answer was a sentence in the push hand-off plus a link, or a decline. All three
runs built the section the prompt described. Of the blocking findings, the heading rule is cairn's
register ("the register's 'No question or teaser headings' rule ... 'What each posture emits' is
its killed specimen"), not the standard: Google's headings guide asks for a noun phrase on a
conceptual heading and says nothing about question or "What" headings. The placement finding is
sound under Diátaxis ("no digression, explanation, teaching" in a how-to; "They get in the way of
the action; if they're important, link to them") and the Red Hat structure checklist. The
overclaims are real.

So of the nine misses: three are fact-grounding defects that would reach the page as wrong prose
(1a, 3b, 5c's contradiction), three are a reader-path dead end the request's premise made
unavoidable (4a, 4b, 4c), two are the design and heading of a section the page did not need (5a,
5b, with real overclaims riding along), and one is a nit the judge blocked once and waved once
(2b).

### What the read is, and what it costs

Each change read sends Opus 5.5 at medium effort about 60,000 input tokens, uncached (every ledger
row shows `cache_read: 0`): the 1,187-line blueprint, its outline entry, every placed fact, the
diff, and the register sections the prompt names. It returns 2,000 to 4,000 tokens and costs
$0.29 to $0.46, median about $0.32, plus about $0.03 for the consistency seat. From the run
directory timestamps a read completes in under a minute. The prompt's stance is "an editor's ...
Developmental editors", and "A checklist item the blueprint fails is a blocking finding", with the
change-read paragraph narrowing *which items* block (those the change adds, alters, or causes),
not *how severe* an item must be to block. The checklist includes order and pace, headings
through the register's anatomies, a `use` that restates its fact, and durable fields that narrate
planning. All of those block today.

The read also reads a base that fails the whole read: row 0 of the skill-rules test, the corrected
base read whole, escalated on the push steps' missing encode failure. The same handful of base
defects came back as "Already present:" in nearly every run: `x-third-verify` handled by a
lead-in sentence, `x-check-threw` handled by a `fact` item, `s-rec-checks` referring to its own
section, the `covers` line split across sections, the rollback route omitting `f:sszb7b`'s cache
caveat. Every test edit was made into a page the judge already considers defective.

### What the sessions did

Every session fired the skill, read the blueprint whole, made one commit, and left a clean tree.
Twelve of 21 read "Check what you add"; they missed at the same rate as the nine that did not. The
sessions ran Sonnet at medium effort with the 1,187-line blueprint, the facts file, the format
page, and the skill in context before they wrote a line.

## Diagnosis

### Why link and removal edits pass and caution and section edits fail

The information the agent authors. A link carries a URL; a removal carries nothing; neither can
contradict a fact or strand a reader. An example, a fact correction, or a failure row carries one
item's content against one or two facts, and the agent gets that right two times in three, and
would more often with a consistent judge. A caution on this page, under this skill, demands a
handler the facts do not supply, in a page with two failure lists. A section demands a placement
argument, a heading, and three claims against three facts, for content the page already has. The
failing shapes are the ones where the correct output disagrees with the request or with the page's
existing design. That is editorial judgment, and it is what the Opus read exists to supply.

### Why written rules did not move behavior

Three reasons, each with published backing.

1. **The rules were written to past misses, and the next misses had new shapes.** #48's misses
   were an invented transcript, recovery before diagnosis, a caution with no next action, a teaser
   heading. #49's rules covered those. #49's misses were a loop-back handler, a missing paired row,
   three actions in a sentence, a claim wider than its fact. The defect space of "content that
   misleads a reader" is open-ended; a seven-line list samples it. Anthropic's context engineering
   guidance names the pattern: "teams will often stuff a laundry list of edge cases into a prompt.
   We do not recommend this," and prefers "a set of diverse, canonical examples" because "For an
   LLM, examples are the 'pictures' worth a thousand words."
2. **The agent believed it had followed the rules.** Each of the 4a, 4b, and 4c handlers was, to
   its author, a next action. Seeing that "re-push" returns the same answer requires holding
   `f:h252kb`, the fingerprint's offline derivation, and the downstream `key-identified` state in
   mind at once. The rule "its handler is a next action" is satisfied in the author's reading. The
   gap is not knowledge of the rule but a second reading with fresh attention, which is why the
   Claude Code best practices say "A fresh context improves code review since Claude won't be
   biased toward code it just wrote" and recommend that "the agent doing the work isn't the one
   grading it."
3. **The rules landed in the least-read place.** They sit at the end of a long reference the skill
   links by heading from a "Check" step after the edit is written; nine sessions never read them.
   The skill-authoring guidance expects this: Claude "may partially read files when they're
   referenced from other referenced files" and "Keep references one level deep." The same guidance
   says what works instead: "Prefer scripts for deterministic operations" and "Common pattern: Run
   validator → fix errors → repeat. This pattern greatly improves output quality."

A fourth, smaller factor: the sessions ran Sonnet at medium with a 1,187-line blueprint already in
context. The best practices page's first constraint applies: "LLM performance degrades as context
fills."

### Is the read's bar right for a blueprint edit?

Partly. Separate the checklist into what the read caught:

- **Fact grounding and reader state** (uncited claims, invented output, overclaims, contradictions,
  a step whose state no earlier step produces, a handler that strands the reader). These are
  defects a page would carry, and the controls prove the read sees them reliably. They are the
  read's job, and some would otherwise surface only at drafting (the fact seat) or never.
- **Order, pace, heading, field placement, a `use` that restates.** These are the developmental
  editor's concerns, and they are judgment calls on which the judge itself splits (2b against 2c).
  Google's review standard separates them: "if it's not very important, prefix it with something
  like 'Nit:'", and the reviewer "should favor approving a CL once it is in a state where it
  definitely improves the overall code health." The Red Hat guide the prompt cites does the same:
  "Required changes must be fixed before the writer can merge," and "Optional changes do not have
  to be addressed." Today's prompt makes every checklist item required.
- **House rules.** The heading finding in all three prompt-5 runs and the transcript rule in 1a cite
  cairn's register. The stock system has no register (onboarding design, "The house register,
  optional"). A read that blocks on them is grading a project against a document it does not have.

So the read is catching real defects and also grading prose quality a blueprint need not carry
yet, with a severity rule that does not distinguish the two.

### Is first-try acceptance by an adversarial Opus editor the right measure?

No, not as the gate. It is a useful diagnostic per edit shape, which is how it earned its keep in
#49. As a gate it fails on four counts: it includes judge variance; it measures the author's
single draft rather than whether the change reaches the page correct; it ignores the cost side,
which is what the anti-goal ("agents find blueprints harder to change than prose") is about; and
it has no analogue in the practice it borrows from. Google's standard calls the goal "continuous
improvement," and the Claude Code guidance on an adversarial reviewer warns that "A reviewer
prompted to find gaps will usually report some, even when the work is sound ... Tell the reviewer
to flag only gaps that affect correctness or the stated requirements, and treat the rest as
optional."

Anthropic's own agent guidance supports a loop over a one-shot bar where the criteria are clear:
the evaluator-optimizer workflow "is particularly effective when we have clear evaluation
criteria," and it "is crucial for the agents to gain 'ground truth' from the environment at each
step." The format test proves the criteria are clear enough for the evaluator (both controls, every
run). What is missing is the optimizer's turn.

### Where in the lifecycle quality should be enforced

Layered, like code, with each layer catching what it is cheapest to catch there:

| Layer | When | Catches | Cost | Today |
|---|---|---|---|---|
| `drafter check` | Every edit, offline | Structure: ids, state tokens, handlers exist, facts resolve | Seconds | 21 of 21 |
| Mechanical warnings (new) | Every edit, offline | Recurring shapes: a handler that is not a handler, an uncited claim | Seconds | None |
| Change read in the author's session (new default) | Edits that add or alter content | Fact grounding, reader path, state, with the author's context still present to fix | $0.30 to $0.70, under a minute a round | Exists as `drafter read --since`; the skill never runs it |
| Nightly change read | Every changed blueprint, before drafting | The same, as the backstop that gates spend | $0.35 a page | Designed, B4 |
| Fact and provenance seats | Drafting | Prose that departs from its fact | Inside the draft's cost | Exists on the chain, B3 for stock |
| Pull request review | Morning | Everything else | Geoff's attention | Merge off until the pilot criteria hold |

The author's session is the right home for the first read because it is the only place the fix is
cheap: the agent still has the code, the fact, and the intent in context. By night that context is
gone, and the fix lands on Geoff's desk as a "needs you" item.

### The cost split

Geoff's idea reads as three layers: free local checks before any spend, an API read for the
judgment, then the session fixes and polishes on its own tokens with local tools and reruns the
local checks. It works with the recommendation above and sharpens it, with one line to draw and
two things the evidence settles.

**The budget frame.** The money is not the constraint. Each read is about $0.35; a two-read edit is
$0.70, a three-read edit about $1.05, a cairn pass with four blueprint edits $3 to $4. A nightly
draft is $3 to $4.50 a page. All of it sits inside $200 of monthly credit that otherwise expires,
and none of it touches the subscription. What a read does cost is under a minute of waiting and,
if skipped, the guarantee. Prompt caching (cache reads on Opus 5.5 at 0.05x) is still worth
measuring for headroom and latency, but it no longer decides anything.

**Where the line sits.** The planning session's tension is real: polish after the last read is
unjudged change, and a session that rewrites a handler while tidying a Nit can reintroduce the
defect the read exists to catch. The first draft of this analysis drew the line on what the fix
touched (a structural field goes back through the read, prose-only polish does not), to save the
second read. With the read free, that trade is the wrong one: it buys a saved read with an
unjudged commit. The line that holds the guarantee is simpler:

- The last read comes after the last change. A committed blueprint is one a read accepted, or the
  reads ran out and the commit message says what remained.
- Fixes and polish happen between reads, in one pass: every blocking finding, plus whichever Nits
  the author chooses, then `drafter check`, then the read again. Batching keeps the common case at
  two reads. Polishing after an accepted read starts another round, so the skill tells the author to
  polish before the read, not after it.
- Three reads cap a round trip. After the third, the author commits and lists the open findings;
  the nightly read is the backstop and the morning report the channel.

The author's own `git diff` against the accepted revision shows whether anything changed after
the last accept; no new code holds the line, and the nightly read catches a breach. What Geoff's
split still buys is real: the free layer runs first and catches the deterministic shapes before
any read, and the fixing itself, the part that needs the author's context and the session's
tools, runs on session tokens between reads instead of in the morning report. The second read is
the price of the guarantee, and inside the budget it is a minute.

**A local editorial pass in the session.** Two forms, with different evidence.

- *Same context, same author.* Disproved. "Check what you add" is exactly this: the author walks
  the read's checklist over its own edit before committing. Twelve sessions did it and missed at the
  rate of the nine that did not, and each of the 4a, 4b, and 4c authors believed its handler was a
  next action. The judge variance adds a second reason: even Opus at medium splits on the nit
  boundary, so a Sonnet author grading itself would be noisier still on the calls that matter.
- *Fresh context, same model, on subscription tokens.* Untested here. The Claude Code guidance
  supports it in principle ("A fresh context improves code review since Claude won't be biased
  toward code it just wrote") and the narrow questions the read catches reliably are closed ones
  given the fact text and the section: does the handler lead to a state the next step requires;
  does the claim say more than the cited fact; is each claim cited. Against it: 4b's defect needed
  the whole page (`key-identified` is consumed two sections later); the architecture's "Why" counts
  API credits as the money that expires unspent and interactive Claude Code time as the resource to
  protect; and under the budget frame a Sonnet pre-review spends the scarce resource (subscription
  tokens and session minutes on every edit) to save the free one (an Opus read on a third of them).
  Not worth an arm in the rerun. The deterministic parts of those questions are already the two
  `drafter check` warnings, which is the local editorial pass that costs nothing.

**Vale on the blueprint.** Probed on the test blueprint with Vale 3.24.0 and cairn's styles. Two
mechanisms work: a `[formats] yaml = md` map, which lints the whole file as Markdown (203 findings,
some on keys and ids, line numbers against the YAML), or extracting the prose fields to Markdown,
which is what `drafter check` would have to do to hand Vale the text (145 fields, 152 findings).
The findings are the published-prose register: 112 of 152 are `Google.Semicolons`,
`Google.Passive`, `Google.Contractions`, and `Google.Parens`, and the rest are acronyms, word
lists, quotes, and three `Cairn.ProseProcedure` hits on planning text that describes a procedure
on purpose. Run on a snippet carrying three of the miss shapes (the "What editors see" heading, the
`HTTP/2 503` line, the three-action sentence), Vale returns nothing; `Cairn.Headings` catches an
`-ing` lead or a question mark, not a clause. Blueprint fields are notes to a drafter in the
agent-facing register, which the architecture says "isn't graded as published prose." Vale's place
is the drafted page, where `drafter gate --page` runs it in F1. Not a layer here. If a project ever
wants its vocabulary checked on blueprints, `drafter check` would hand Vale the extracted fields
with only the `Vocab` and names styles on; that is a later want, not this pass.

So the three layers, as built: (1) `drafter check` with the two warnings, free, every edit;
(2) a change read when a key is set; (3) the author fixes and polishes on its own tokens, reruns
(1), and reads again, up to three reads. The fixing is where "normal tokens" do the work; the
judgment stays on the credit that would otherwise expire, and the last word is the read's.

### Would a different item model, templates, a command, or a mechanical check remove the failure class?

- **Item model: one change.** Restore the caveat. The catalog already has "Add a caveat: a
  `sentence` item with `mode: claim`"; the skill's case 2 and "Check what you add" must stop
  rerouting every caution to `failure`. A `failure` is for a symptom with a handler the facts
  supply; a caveat is a claim with facts, which may hand off to recovery. Nothing else in the model
  caused a miss.
- **Templates for sections.** They would not have helped prompt 5; the fault was the request. The
  stock anatomies F2 ships give a task guide its steps-first shape, which is the rule the read
  applied; that is enough.
- **A structured authoring command** (`drafter add failure ...`). It would make YAML the agent
  already writes correctly. No.
- **Mechanical checks: two, as warnings.** Both recur on the base blueprint itself in nearly every
  run's "Already present:" list, which proves they are detectable without a model and that agents
  and people miss them:
  1. `handler`: a `failure`'s `handledBy` names a `fact` item, a `sentence` with `mode: verbatim`, or
     a `link` or `handoff` whose target is the section that holds the failure's `from` step. Evidence:
     `x-third-verify` to `rec-lead`, `x-check-threw` to `rec-health-failed` (base, every run), 4c's
     `rec-push-link` loop.
  2. `cited`: an `example` or a `sentence` with `mode: claim` and an empty `facts` list. Evidence:
     1a's claim beyond its citations; the format page's own first line of "Check what you add."
  A third, a `sentence` whose text opens with an imperative verb (4b's three actions), is more
  heuristic; worth a try as a warning, dropped if it fires falsely on the 11 cairn blueprints.
- **A change to what the read judges.** Yes: a severity rule, not a scope rule. The scope rule is
  done.

## The options

### Option 1: the self-read loop

The skill runs `drafter read --since <base>` on its own edit, fixes what blocks, up to two rounds.
The bar becomes `drafter check` green first try plus read accepted within two rounds.

- Cost: about $0.35 a read, so $0.70 for the common two-read edit and about $1.05 at the
  three-read cap, under three minutes of waiting. A cairn pass with two to four blueprint edits
  spends $2 to $4; a month of heavy use is tens of dollars of a $200 credit that otherwise
  expires, and none of it is subscription usage. The real cost is latency, under a minute a read.
  Prompt caching would trim both: cache reads on Opus 5.5 are "0.05x the base input price" with a
  five-minute lifetime, and the stable parts (the prompt, the register sections, the facts) are
  most of the 60,000 tokens. Today the blueprint comes first in `BlueprintBlock`, ahead of the
  facts, so a changed blueprint invalidates everything after it ("changing any block at or before
  the breakpoint produces a different hash"). Reordering the block, facts and register first,
  blueprint and diff last, is a small assembler change to measure, not a promise.
- What it gives up: the goal's "checked offline in seconds" for the editorial half of correctness,
  which was never checked offline anyway. The offline half stays: `drafter check` in seconds.
- Risks: a judge that blocks nits sends the author chasing them (the severity rule below is the
  mitigation); an author may learn to satisfy the judge by hedging or deleting content (the fact
  seat at drafting and a sample read of round-two diffs are the checks); a project with no key has
  no loop (it keeps `drafter check` and the warnings, and the nightly read remains the backstop).
- Anti-goal: the loop runs inside the agent's own session with no human step, and its feedback
  arrives in a minute instead of overnight. That is less friction than today's silent rejection,
  not more. "Give Claude something that produces a pass or fail, and the loop closes on its own."
- Setup ergonomics: `drafter read --since` exists; the key, `workspace_id`, and the caps are already
  what onboarding asks for; the stock prompts arrive in F2. Nothing new to install.

### Option 2: keep first-try, stronger writer

Hand cautions and new sections to an Opus subagent. It does not address the cause: on prompt 4
an Opus writer under the same skill rule invents a handler too, unless it declines, and declining
is a skill rule, not a model property. On prompt 5 the request itself is wrong. It doubles the
Claude Code cost of those edits, adds a classification the skill must make ("is this edit
complex?"), and the skill-rules evidence gives no sign that writer strength was the limit: the
failing shapes were traps, and the passing shapes passed on Sonnet. Not recommended. The
implementer agents already carry a `model: opus` upshift when a plan asks for one, which covers the
rare case.

### Option 3: accept 57% for now, let the nightly run catch it

This is the floor the architecture already provides: a blocked blueprint sets the page aside, the
page keeps its old prose, and the report says why. No bad page reaches `main`. Its cost is where
the fix happens: in the morning report, with the author's context gone, by Geoff or by a fresh
session that has to reconstruct the intent. At 43% of content edits, that is a standing queue of
"needs you" items, each one a docs change that a pass believed it had made. Revisiting after B3 and
B4 also means the measure stays uncalibrated through two more passes. Acceptable only as the
backstop under option 1, which it already is.

### Option 4: a nightly repair seat

Not on the table, raised here so it is weighed. The read already returns a `rewrite` for each
finding; a nightly seat could apply the rewrites as a bot commit and redraft. It keeps the
author's edit offline-only and costs the same money at night. Against it: the fix is made without
the code or the intent (4b's rewrite needs to know the fingerprint is derived offline; the read
knew, but a general repair will not always), blueprints drift toward the judge's taste with no
author in the loop, and the morning PR carries blueprint edits nobody asked for. The
evaluator-optimizer pattern puts the optimizer where the task context is. Keep as a B4 fallback for
pages the loop left blocked, not as the first line.

### Option 5 (recommended): the loop, with the bar, the skill, and the base fixed

Option 1 plus the four fixes the evidence names, in one small pass before B3, with the prompt
changes landing in F2 where the stock prompts are written.

## The recommendation

### What it builds

1. **The skill (SKILL.md, `docs/blueprint-format.md`).**
   - Case 2 stops rerouting a caution to `failure`. New wording of the rule: a `failure` item is for
     a symptom with a handler the facts supply; when no fact gives the reader a route, the edit is
     the catalog's "Add a caveat" row (a `sentence` claim citing its facts, with a `link` to the
     recovery section when one applies), and the report says the case has no handler. "Check what
     you add" loses its third line and gains none; the section shrinks rather than grows.
   - A decline rule, next to "If no catalog row fits, stop and say so": when the request conflicts
     with a fact or asks for content a section already carries, make the smaller edit the catalog
     allows and say in the report what was asked and why the edit is smaller. A docs maintainer
     pushes back on a bad request the way a developer pushes back on a bad PR ask.
   - A "Read" step after "Check", in Geoff's three layers: `drafter check` and its warnings first,
     free. Then, when `drafter.toml` configures a key, one `drafter read --since <base>` on the edit.
     Then fix on the session's own tokens, in one pass: each blocking finding, and whichever Nits
     the author chooses. Rerun `drafter check`, then read again. The last read comes after the last
     change: any edit after an accepted read starts another round, so polish goes before the read.
     Three reads cap the round trip; after that, commit with the open findings in the commit
     message. The read never blocks the commit; the nightly read is the backstop. Without a key,
     skip the reads and say so.
2. **`drafter check` (`internal/blueprint/check.go`).** The `handler` and `cited` warnings above,
   each with a fix message. Try the imperative-`sentence` warning behind the same gate and drop it
   if it fires falsely on cairn's blueprints.
3. **The change read's severity rule (`blueprintPrompt` in the chain, then the stock prompt in
   F2; `internal/pipeline/blueprint.go` keeps the blocking flag).** In a change read, a finding
   blocks when the change would make the page wrong or leave a reader without a route or a state a
   later step needs: a claim that contradicts or exceeds its fact, invented output, a handler that
   loops or dead-ends, a dependency no precondition or step supplies, a missing step the job needs.
   Order, pace, heading form, field placement, and a `use` that restates are reported as
   non-blocking findings that start "Nit:". The whole read before drafting keeps today's
   developmental bar, because that read gates a $3 to $4.50 draft and a redraft is where structure
   gets fixed. Register-only rules (heading forms, the transcript rule) block in neither read of a
   blueprint; the editor seat enforces them on prose, where they apply.
4. **The assembler (`internal/assemble/blueprint.go`).** Put the facts and the register sections
   before the blueprint and the diff, and mark a cache breakpoint after them, so a second read
   reads the stable prefix from cache. Measure the second read's cost and latency in the ledger
   before claiming either; inside the credit this is headroom, not savings.
5. **The test base.** Before the rerun, fix the base blueprint's recurring "Already present:"
   items (the two non-handler handlers, the self-reference in `s-rec-checks`, the `covers` split,
   the rollback caveat, the duplicated fingerprint rows), and read it whole until it accepts. The
   onboarding design already requires an accepted whole read before O; doing it now makes the
   format test measure the skill instead of the base. The fixes go to cairn's `main` through its
   own pass.

### How it is measured

The same seven prompts, three runs each, Sonnet at medium, fresh sessions, the same harness.

| Measure | Bar | Why |
|---|---|---|
| `drafter check` green on the first commit | 21 of 21 | The offline promise; met today |
| Accepted by the change read within two reads | 19 of 21 | The gate; 90% with one fix pass is the rate code review would call healthy |
| First-try acceptance, per shape | Reported, no bar | The diagnostic that found the two skill defects; it keeps finding them |
| Accepted within three reads | 20 of 21 | The cap; with the second read free, a third is the honest limit before the nightly backstop |
| Reads per edit, and session minutes waiting | Reported; expected about 2 reads and under 3 minutes | The latency side of the anti-goal; the dollars sit inside $200 a month |
| Spend, whole test | Reported against the monthly credit, with the cached-read share | Headroom, not savings: 21 edits at two reads is about $15, a tenth of a month |
| Committed after the last accepted read | 0 of 21 commits carry a change the last read did not see | The guarantee holds |
| Declines and smaller edits on prompts 4 and 5 | Counted; a pass when the committed smaller edit is accepted and the report names the conflicting fact or section | A correct refusal is the right output for a bad request |
| Judge agreement | Three misses read twice more each; report the split | About $3; tells the next pass how much of a miss is the judge |
| Controls | Both bite every run; both positive controls accept | Unchanged |

Prompt 4 should also be read as written against the fixed base and the fixed skill; if it still
scores 0 of 3, the prompt is the defect and a caution prompt with an honest handler replaces it.

### Where it lands in the order

F1 is running. The skill, check, and base work is one small pass of its own (call it S, after F1;
risk class low, no `auth-data` path), because B3 drafts from blueprints that agents are already
editing under the current skill. The severity rule and the cache order land in F2, where the stock
read prompt is written, so a new project never sees cairn's register through the read. The rerun
follows F2. B4's design then inherits the loop as the first line and the nightly read as the
backstop, and decides whether option 4's repair seat earns a place for pages the loop left blocked.

### The architecture's goal

Change it. The current line, "An agent can make a typical small change to a blueprint correctly
on its first attempt, checked offline in seconds," should read: "An agent can make a typical small
change to a blueprint with `drafter check` green on its first attempt, in seconds and offline, and
the change is accepted by the blueprint read in the same session, within three reads, with no
human step." The anti-goal stays as written; the loop is how it is kept. The pilot's second risk ("the
format may be too heavy") is retired on the evidence, and a third takes its place: the read's
blocking bar may be set at the editor's taste rather than the reader's need, which the Nit rule and
the judge-agreement measure watch.

## What would prove this wrong

- The two-round acceptance rate on prompts 1 to 5 stays under 80% after the skill fix, the Nit
  rule, and the fixed base. Then the limit is the author's reasoning, and option 2 or a stronger
  loop (an Opus author for the fix pass, on API credit) is the next test.
- Round-two diffs fix the judge rather than the content: hedged claims, deleted rows, a handler
  replaced by a bare link. A read of the 21 round-two diffs shows it. Then the loop needs the fact
  seat's discipline (every fix cites its fact) or it is doing harm.
- The `handler` and `cited` warnings fire falsely on more than a handful of the 11 cairn blueprints,
  and agents start ignoring warnings. Then they come out.
- Agents in real passes skip the read step or edit prose anyway, visible as page-hook fires in
  session logs and as "needs you" items in the nightly report that trace to edits made under the
  new skill. Then the anti-goal is live and the friction is somewhere this analysis did not find.
- Reads per edit average near three, or the waiting runs past five minutes an edit. Then the
  loop's latency is the friction the anti-goal names, and the cap drops to two reads with the
  nightly read taking the rest.
- Commits carry changes made after the last accepted read in more than one of 21, or the nightly
  read later blocks on a post-read polish. Then the skill's "polish before the read" rule is not
  landing, and the read step moves into a hook that runs on commit.
- Monthly read and draft spend approaches the credit. At $0.35 a read and $3 to $4.50 a draft
  that takes hundreds of edits and dozens of drafts a month, so this is a signal that the system
  is in heavy use, and the caps already in the money settings are the response.
- Judge agreement on the three re-read misses is under two of three. Then the Nit rule did not
  settle the boundary, and the rubric needs examples of blocking and non-blocking findings (the
  "canonical examples" the context-engineering guidance asks for) before any bar is trusted.

## Decisions

The six owner decisions this analysis raised are ruled; "Geoff's rulings" above records them. What
remains is the planning session's, as method calls:

1. **The polish line**: the last read comes after the last change, with a cap of three reads.
   Recommended. The alternative this analysis first drew (prose-only polish without a read) saved a
   read that costs nothing inside the credit and gave up the guarantee; it is withdrawn.
2. **No fresh-context Sonnet pre-review**, not even as a test arm, because it spends subscription
   tokens to save API credit. Recommended; revisit only if the credit ever binds.
3. **Vale stays off blueprints.** Recommended on the probe; a later `Vocab`-only check through
   `drafter check` is noted, not planned.

## Sources

- drafter#47, #48, #49 PR bodies (`gh pr view <n> -R glw907/drafter`); run records under
  `~/.local/state/drafter/runs/cairn-cms/20261018T22*` (`state.json` for the scope and change
  block, `record.json` for findings and cost, `requests/*.json` for the model, effort, and size);
  `~/.local/state/drafter/ledger.jsonl` for usage and cache fields.
- `2026-10-17-blueprint-architecture-design.md` (goals, anti-goals, the pilot's risks, lines
  54 to 81 and 535 to 550); `2026-10-18-drafter-onboarding-design.md` ("The house register,
  optional"; O's acceptance).
- `claude/.claude/skills/blueprint/SKILL.md` (case 2), `docs/blueprint-format.md` ("The edit
  catalog", "Check what you add"), `blueprintPrompt` in `claude/.claude/workflows/docs-page-chain.js`,
  `internal/pipeline/blueprint.go`, `internal/assemble/blueprint.go` (`BlueprintBlock` order),
  `internal/assemble/consistency.go`.
- `blueprints/docs/extend/rotate-the-github-app-key.blueprint.yaml` and
  `docs/internal/facts/extend.md` in cairn-cms (`f:h252kb`, `f:1pb077`, `f:ogokfy`, `f:vg42j3`,
  `f:7u49xs`).
- The Vale probe, 2026-10-19: Vale 3.24.0 with a throwaway config pointing at cairn's
  `.vale/styles` (`Packages = Google, Microsoft`, `Vocab = Cairn`, `Google.FirstPerson = NO`), run
  three ways: the blueprint as is under cairn's `.vale.ini` (0 files matched, since no section
  covers `blueprints/`), the whole file under `[formats] yaml = md` (203 findings), and the 145
  prose fields extracted to Markdown (152 findings). The snippet test carried the 5c heading, the
  1a `HTTP/2 503` line, and the 4b three-action sentence, and returned no finding.
  `.vale/styles/Cairn/Headings.yml` matches `^[A-Z][a-z]+ing\b` and `\?$` only.
- Anthropic, "Building effective agents": the evaluator-optimizer workflow "is particularly
  effective when we have clear evaluation criteria"; "it's crucial for the agents to gain 'ground
  truth' from the environment at each step." <https://www.anthropic.com/engineering/building-effective-agents>
- Anthropic, "Effective context engineering for AI agents": the edge-case "laundry list" and
  "diverse, canonical examples"; the attention budget. <https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents>
- Claude Code best practices: "Give Claude a way to verify its work"; "A fresh context improves
  code review"; "Add an adversarial review step" and its caution on reviewers that always find
  gaps; "LLM performance degrades as context fills." <https://code.claude.com/docs/en/best-practices>
- Skill authoring best practices: "Keep references one level deep"; "Prefer scripts for
  deterministic operations"; "Run validator → fix errors → repeat"; "Build evaluations first."
  <https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices>
- Prompt caching: cache reads at 0.05x base input on Opus 5.5; the five-minute lifetime; prefix
  invalidation. <https://platform.claude.com/docs/en/build-with-claude/prompt-caching>
- Google engineering practices, "The standard of code review": continuous improvement over
  perfection; "Nit:". <https://google.github.io/eng-practices/review/reviewer/standard.html>
- Google developer documentation style guide, "Headings and titles": noun phrases for conceptual
  headings; no rule on question headings. <https://developers.google.com/style/headings>
- Red Hat peer review guide, Structure checklist; required against optional changes.
  <https://redhat-documentation.github.io/peer-review/>
- Diátaxis, "How-to guides": "no digression, explanation, teaching"; "if they're important, link
  to them." <https://diataxis.fr/how-to-guides/>
