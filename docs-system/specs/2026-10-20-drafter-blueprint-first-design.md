# drafter blueprint-first: a dependable blueprint before any draft

Status: designed with Geoff in chat on 2026-10-20, awaiting his approval. Initiative:
`docs-system`. It follows the acceptance pass (glw907/drafter#56, glw907/cairn-cms#133), which
accepted none of cairn's seven pages, and Geoff's ruling that the next pass gets a page a polished,
fully dependable blueprint before drafter spends anything drafting it. The premise is in
`research/2026-10-20-docs-system-failure-history.md`: the facts and blueprints decided what was
true on the page in every missed pass, and no check today reads a fact against its source.

## Brief

Approving this gives every docs page a gate that proves its blueprint before drafter spends
anything drafting it, and a way to build a new blueprint from the code on your session tokens.
All six wrong claims in B3c's drafts came in through the inputs (a fact, a blueprint sentence, a
stale live page, or a code comment) and none from the drafting seat, so this pass checks the
inputs and drafts nothing.

### What changes

- `drafter read` gains a fact-truth read: each fact a blueprint places is checked against the
  code it cites. The blueprint is blocked when the excerpt contradicts a fact, when a fact claims
  more than the excerpt shows, or when no excerpt can show a verified fact.
- The lock records a hash of the facts a blueprint cites beside its accepted id. A later edit to
  a fact cancels the accept of every page that cites it, and `drafter page` refuses such a page
  before any spend.
- A new blueprint is built from the code, never from a live page. The author runs the gate's
  reads in a loop with no cap on rounds. The skill that guides the build is tuned from that
  build's friction and measured by a fresh session's rebuild.
- `drafter read` runs synchronously by default, so batch latency never enters the build loop.
- The pass proves the gate on the eight cairn blueprints that exist and builds one new blueprint
  for the tidy page, cairn's guide to turning on its AI copy-edit.
- The billing cycle's ceiling rises to 200, if you take the recommended choice below, so the pass
  can run before November 1.

### If you approve

1. The session raises `cycle_ceiling` in `~/.config/drafter/config.toml` per your choice below.
2. A planning session writes the plan under `pass-core` and hands it to `conductor-drafter`. The
   pass runs unattended on `pavilion`, and the standing answers below decide what it can.
3. The pass comes back as one packet: a drafter PR, a cairn PR with the tidy blueprint and the
   fact fixes the gate found, and the proof's numbers.
4. The drafting pass that follows is designed from this pass's record. It drafts only from
   blueprints that hold the new gate's accept, and it carries the three machinery items this
   design leaves: the second fix verdict, the reader loop, and the per-page cap.

### Decide: The cycle ceiling

The pass needs about $45 of reads and the cycle has about $19 left under its $160 ceiling until it
resets on November 1. Every dollar is a read: the fact-truth replay on the eight blueprints twice,
the seeded controls, the eight blueprints driven to the new gate's accept, and the tidy blueprint's
own reads. No draft runs. Your $200 of monthly credit covers it either way.

Source: `drafter spend --json` on 2026-10-20 (total 140.01, open 1.00); `~/.config/drafter/config.toml`
(`cycle_ceiling = 160`, `billing_cycle_day` unset, so 1).

- Raise the ceiling to 200 now, and the pass launches as soon as its plan is ready (recommended)
- Keep 160 and launch the pass after November 1
- Raise it to 200 and also cut the proof to the replay and the tidy page, skipping the eight
  blueprints' re-gating

### Worth knowing

The acceptance pass's pages also failed on their own writing, at the review seats and the
acceptance rules. That is the drafting pass's work, and this pass leaves it alone.

### Standing answers

The pass stops only for a finding that changes this design or for spend past the ceiling, and
everything else has an answer here, which the planner and conductor apply in place of stopping.

- A plan within twice the estimate (1080 path minutes) launches unattended.
- Live spend up to $45 over the launch baseline runs without asking. The meter is `drafter spend
  --since <launch date> --json`, its `total` plus `open.worst`.
- The replay and the controls run first, and the rest of the proof waits on their bars. A replay
  under 20 of 25, or a control that does not bite, is a traced cause: the session tunes the
  fact-truth prompt and reruns, up to three rounds inside $10 of the $45. A bar still unmet after
  that stops and asks, because it means a read on API credit does not do the hand check's job,
  which is Geoff's condition on the API line.
- A fact-truth finding on today's store is fixed at its source on session tokens when the session
  can show the code line that settles it, and otherwise filed in cairn's backlog with the fact id
  and the excerpt. Either way the finding is counted in the proof's table.
- A blueprint of the eight that does not reach the new gate's accept is reported with its open
  findings, and the run goes on. The loop guard, the traced-cause rule, and the returning-cause
  rule in `pass-core` apply.
- The tidy blueprint takes the rounds it needs. Its reads count toward the $45 and nothing else
  stops them; past the fifth read the session reports the count and keeps going.
- The format may change where the build meets friction (Geoff, 2026-10-20: latitude, not a
  directive). A change beyond the three named under "Calls made in this design" is made when the
  friction log shows the point, documented in `docs/blueprint-format.md`, kept decodable for the
  eight existing blueprints, and listed in the PR's `## Decisions` with the log entry that caused
  it.
- A finding that changes this design, or spend past the ceiling, stops and asks.

## Outcome

A blueprint is dependable at one commit when four checks hold on it, and drafter refuses to draft
a page whose blueprint is not. The eight cairn blueprints hold that accept, or the record names
each one's open findings. The tidy page has a blueprint built from the code that holds it. The
replay and the controls show the gate catches what the acceptance pass's hand check caught, so a
read on API credit does the job the hand check did.

## The gate

The four checks, at one commit of the blueprint, the outline, and the facts store.

| Check | What it proves | Runs as | State today |
|---|---|---|---|
| `drafter check` green | Structure, reader state, handlers, every pointer resolves, and every verified fact has an excerpt that can show it | Deterministic, offline, seconds | Exists; the no-excerpt warning is new |
| The fact-truth read | Every fact the blueprint places says what its source excerpt shows | A seat in `drafter read`, one request per blueprint | New |
| The consistency read | No two placed facts, and no placed fact and a linked page, can both be true | A seat in `drafter read` | Exists |
| The whole blueprint read | The plan is complete and a reader can follow it: steps, states, handlers, order, the introduction | A seat in `drafter read`, held to the read bar | Exists |

The fact-truth read and the lock's hash cover the same set of facts: every fact the blueprint
places or cites, which is the set `drafter check`'s `facts` check verifies and `drafter refs`
lists (fact items, every `facts` list, the introduction's facts, dispositions, and framing
citations). A cited-only fact is read too, since the page's claims rest on it as much as on a
placed one.

The accept writes two fields to the page's lock entry: `accepted`, the blueprint's blob id as
today, and `facts`, a hash over those bullets' text, pointer and tag included, so a moved pointer
lapses the accept as a changed claim does. A bullet edit anywhere in the store changes the hash
of every blueprint that cites it. A change in the code under a pointer does not: the read proves
the fact against the code at the accept's commit, and code that drifts afterward with no fact
edit is the architecture's standing non-goal, covered by the pass rule and the monthly drift
routine, not by this gate. `drafter read` on a lapsed page reads the
change: the fact-truth read over the changed facts, the consistency read, and the blueprint read as
a change read with the fact diff. `drafter page` on a lapsed page refuses before any request and
names the changed facts. This closes drafter #20, where a fact-only edit skipped every read.

The fact-truth read's verdicts, one per fact: `holds`, `wider` (the fact claims more than the
excerpt shows), `contradicts`, and `no-excerpt` (no pointer yields an excerpt that bears on the
claim). `wider` and `contradicts` block. `no-excerpt` blocks a `verified` fact and passes an
`external` or `vendor` one, whose source is not in the repository. A blocking finding names the
fact id, quotes the excerpt, and states the fix as the acceptance pass's fact-check did: the claim
as the code has it. The read never edits a bullet.

The whole read still grades claim coverage against the outline entry's `job` and `covers`. The
exception is an outline entry that carries covers ids (the third format change below): there,
`drafter check` proves each id is placed or disposed.

## The build path

For a page with no blueprint, whether or not a live page exists. The author is a Claude Code
session on Opus at high effort, on session tokens, under the `blueprint` skill's new-page path.
The order is the outline entry, the facts, the blueprint, then the gate. Only the gate's reads
spend API credit.

1. Geoff settles the outline entry (job, type, covers, out of scope) because it is the product
   call. The tidy page already has one.
2. Each fact is written from the code. The author sets the pointer and anchor first, runs
   `drafter excerpt <pointer>` to see what the read will see, and writes the claim with the
   excerpt in view. A live page is a map of what to look for and never a source: a claim found
   only on a page is retraced to code, config, or a vendor document, or it is not filed. The three
   stale-page claims in B3c came through facts harvested from pages.
3. The blueprint is written as the new-page path says today, with a placement or a disposition
   for every fact.
4. The loop: `drafter check`, fix, commit, `drafter read` (all three seats), fix on session
   tokens, commit, read again under the bar, until the whole read accepts with no blocking
   finding from any seat. There is no read cap: a blueprint is built once and a dependable one
   saves every later draft, so the path takes the rounds it needs and reports the count.
5. Polish goes before a read, never after an accepted one, as the skill already says.

The controls and the replay below test whether reads on API credit do the hand check's job.

## What it builds

1. **The fact-truth seat** (`stock/prompts.js`, the chain's prompts module in
   `claude/.claude/workflows/docs-page-chain.js`, `internal/pipeline/blueprint.go`,
   `internal/assemble/`). A `facttruth` seat joins the `drafter read` batch beside `consistency`
   and `blueprint`, Opus at medium, one request per blueprint carrying every placed fact's bullet
   and its excerpts, answering the verdict schema above. Its findings carry the kind `fact` and
   block the blueprint as a blueprint-read finding does. It runs in `drafter read` only; `drafter
   page` already has the draft-stage fact seat.
2. **The lock's `facts` field and the lapse rule** (`internal/blueprint/blueprint.go`,
   `lock.go`, `since.go`, `internal/pipeline/blueprint.go`, `cmd/drafter/page.go`, `read.go`).
   A hash over the cited bullets, written at accept, compared at every read and page run. A
   mismatch is `lapsed`: `drafter read` reads the change, `drafter page` refuses before any
   request and prints the changed fact ids. A lock entry with no `facts` field is treated as
   lapsed once. That sends the eight existing accepts through the new gate.
3. **An excerpt for every pointer** (`internal/assemble/excerpt.go`, `internal/plan/verify.go`,
   `cmd/drafter/excerpt.go`). `drafter excerpt <fact-id | pointer>` prints what the read sees. A
   dotted anchor such as `file.ts#outer.inner` resolves to `inner` within `outer`'s declaration
   (drafter #28). `drafter check` warns `no-excerpt` on a verified fact none of whose pointers
   yields an excerpt, so the author sees it before the read does.
4. **Covers ids** (`internal/blueprint/check.go`, `decode.go`, `docs/blueprint-format.md`). An
   outline `covers` entry may be a mapping with `id` and `text` instead of a string. A section may
   list `covers: [<id>, ...]`, and a `dispositions` entry may name a covers id. `drafter check`
   adds a `covers` check: every id is claimed by a section or disposed, and every claimed id
   exists. A string entry stays as it is and is left to the whole read. The two readers that take
   `covers` as strings, `cairn-docs-outline` and the chain's prompts module, accept both forms in
   the same change, so the tidy entry's conversion breaks nothing the drafting pass will run.
5. **Synchronous reads by default** (`cmd/drafter/read.go`, `docs/configuration.md`). `drafter
   read` runs in sync mode unless `--batch` is passed. `drafter page` keeps its mode setting.
6. **The skill, tuned** (`claude/.claude/skills/blueprint/new-page.md`, `SKILL.md`,
   `format.md`, a new `exemplar.md`). The new-page path's step 2 becomes the code-first fact
   rule with `drafter excerpt`, and its step 5 becomes the loop above with no cap. `SKILL.md`'s
   read step names the fact-truth read's findings and the lapse line `drafter page` prints. The
   tuning is evidence-driven, under "The skill" below, and the accepted tidy blueprint becomes the
   skill's canonical exemplar.
7. **The proof** (a throwaway branch of cairn-cms, a research record). The replay, the controls,
   and the eight blueprints' re-gating, under "The proof".
8. **The tidy blueprint** (cairn-cms `blueprints/outline.yaml`, `blueprints/docs/extend/
   turn-on-tidy.blueprint.yaml`, `docs/internal/facts/`). Built by the path above, in a cairn
   session on Opus at high, until the gate accepts it. Its `covers` entry converts to ids as the
   trial of the covers check. No draft of it runs.

## The skill

The `blueprint` skill's new-page path is a deliverable, and this pass measures it. The
edit-quality analysis found that a validator loop and canonical examples change behavior and a
longer rule list does not: the skill-rules pass added seven rules and the rate did not move. The
tuning follows from that.

1. The tidy build keeps a friction log: every point where the author had to guess, back out,
   re-read the format page, or work around a field. Each entry names the step of the skill or the
   field of the format it met.
2. The first read's blocking findings on the tidy blueprint are the skill's misses. Each class is
   folded into the new-page path as a step or an exemplar passage, never as a rule appended to a
   list. A friction point in the format itself is a format change under the standing answer.
3. The accepted tidy blueprint and its fact bullets become `exemplar.md`, linked from the new-page
   path one level deep, with a sentence on each section saying what it shows.
4. The measure. After the tuning, one fresh session on Opus at high rebuilds the tidy blueprint
   from the outline entry on a throwaway branch, following the tuned skill. The exemplar is
   withheld, because it is this page. The record compares its first read's blocking findings
   by seat against the first build's. Fewer is the bar; the count either way goes to the next
   design. The rebuild spends session tokens and about a dollar of reads, and nothing from it is
   kept.
5. `prose-voice-reviewer` reads the skill's text, and the reference depth stays at one level
   (`SKILL.md` to `new-page.md` to `format.md`, never further), per the skill-authoring guidance.

## The proof

Three measurements, and only reads spend. Each goes in the PR body's table and in a research
record under `research/`.

**The replay.** cairn-cms commit `3752e57a2` fixed the 25 fact bullets the hand check found
wrong. Its parent, `517158fae`, holds eight accepted blueprints in its lock, and every one of the
25 is placed by a `fact` item in one of them. The fact-truth read runs over the eight blueprints
at that commit, on a throwaway branch, and the proof counts how many of the 25 bullets it flags. It then runs over the eight at `main`, and the
session reads every finding against the code: a finding the code bears out is a new catch and is
fixed or filed under the standing answer, and one it does not is a false block. Bar: at least 20
of the 25 flagged with verdict `wider` or `contradicts`, and zero false blocks at `main`.

`no-excerpt` is scored on its own. At `517158fae` a stale pointer can earn it before the seat
judges any content, so a bullet flagged only as `no-excerpt` does not count toward the 20. At
`main` a verified fact none of whose pointers yields an excerpt (cairn #25's directory,
dependency, and prose pointers) blocks by the rule, and that is a correct block, not a false one:
it is fixed by re-pointing or retagging under the standing answer and counted in its own column.
A false block is a `wider` or `contradicts` verdict the code does not bear out.

**The controls.** Six seeded defects on a throwaway branch of cairn, one per class the history
names, each in a blueprint that otherwise holds the gate: a step removed (the deploy after the
secret push), a handler that sends the reader back to its own section, a fact pair that cannot
both be true, a bullet widened past its code, a bullet restating a claim the live page makes and
the code does not, and a pointer moved to a dead anchor. Bar: each one bites, and the proof names
which check caught it.

**The build.** The tidy blueprint reaches the gate's accept. Reported: the rounds, the reads,
each round's blocking findings by seat, the spend, and the session minutes. There is no bar on
the count; the figure is the next design's estimate.

After the replay, the eight existing blueprints are driven to the new gate's accept on session
tokens, with their reads on the API. That work also fixes cairn #21's two fact conflicts and the
fact findings the replay raises at `main`. Reported: how many of the eight hold the accept at close,
and the open findings of any that does not.

## Calls made in this design

Geoff ruled the four owner calls in chat: the gate's definition, the API line (judging on the API
through drafter, authoring and fixing on session tokens), the proving ground and the tidy page,
and leaving the machinery to the next pass. The rest are the design's calls.

- The fact-truth read is a drafter seat on the API, not a fresh-context subagent on session
  tokens. A read costs well under a dollar a blueprint, repeats on demand, and leaves a record the
  lock can hold. Geoff's line is judging on the API, so long as the loop works as well there as
  the hand check did; the replay and the controls measure that.
- `no-excerpt` blocks a verified fact. The tag claims the code shows the claim, so a pointer that
  cannot show it is the defect. cairn has 19 directory pointers, 18 dependency paths, and 35 prose
  pointers left (cairn #25); a fact with one excerptable pointer among several passes, and the
  rest are re-pointed where the replay meets them.
- Three format changes, each contestable and each reversible: the lock's `facts` field, the
  dotted-anchor pointer form drafter already accepts but could not excerpt, and the optional
  covers ids. The first two the gate needs; the third makes the inventory checkable where an
  author wants that. The bullet grammar does not change, because the acceptance pass proved the
  store's 3,014 pointers resolve under it and nothing in the history faults the grammar. Any
  further change waits for the friction log, per the standing answer.
- Builder-check folds, each the design's call: the replay and controls gate the rest of the proof
  and a miss gets three prompt rounds before it stops; `no-excerpt` scores in its own column and
  never toward the 20; the read and the hash cover placed and cited facts alike; the hash covers
  bullets only, never the code under them; and the covers mapping form ships with both string
  readers updated.
- The skill's measure is one fresh-session rebuild of the same page. A second page would measure
  more and cost a second build; the rebuild measures the skill on the one page whose first build
  is recorded, which is enough to say whether the tuning moved anything.
- Covers ids are optional. A string entry is the common case today and the whole read grades it;
  ids make the inventory checkable for a page whose author wants that, and the tidy page tries
  it. Rolling the other 25 entries over is not this pass.
- `drafter read` goes synchronous by default. The acceptance pass's seven-blueprint sync read cost
  $2.61 and finished in minutes; its batch reads sat for hours. Nothing about a blueprint read
  earns the batch discount.
- The eight existing blueprints take the new gate in this pass. Geoff's ruling is that the
  drafting pass drafts only from gated blueprints, and gating them is session work plus cheap
  reads, so leaving it would only move the work into the drafting pass's path.
- The author of a new blueprint runs at high effort on session tokens, with no read cap. Geoff's
  note: a perfectly crafted blueprint is built once and saves time on every draft, so it is worth
  the extra time, attention, and credits.
- The tidy page is a task guide of 3,445 words with a live page as the map, an outline entry with
  a `job` and nine `covers` lines, and code under `src/lib/admin/tidy-*` and
  `src/lib/sveltekit/tidy-*` that facts can cite line by line.

## Out of scope

- Drafting any page. No `drafter page` run spends in this pass; the one `drafter page` call in the
  check is a refusal that spends nothing.
- The acceptance machinery: the second fix verdict, the reader loop (drafter #18), the per-page
  cap. These are the drafting pass's entry conditions, as step 4 of "If you approve" says.
- Batch latency as a cause. Sync reads sidestep it at the blueprint stage; the drafting stage
  still waits on batches, and the drafting pass decides what to do about that.
- Blueprints for cairn's other 17 managed pages. The build path is proven on one.
- The nightly run, the morning report, human write-back (B4 and B5), and the onboarding pass (O).

## Check

One end-to-end check, run by the session at close in the cairn worktree.

1. `drafter read blueprints/docs/extend/turn-on-tidy.blueprint.yaml`, with no mode flag, runs
   synchronously and prints `accepted`
   with no blocking finding from the fact-truth, consistency, or blueprint seat, and the lock entry
   for `docs/extend/turn-on-tidy.md` holds `accepted` and `facts`.
2. Edit one bullet a `fact` item of the blueprint places to a claim the code does not make,
   commit, and run
   `drafter page blueprints/docs/extend/turn-on-tidy.blueprint.yaml`. It refuses before any
   request with the lapse line naming that fact id, and `drafter spend --since <that minute>`
   shows no new row.
3. `drafter read` on the same blueprint then blocks on that fact with verdict
   `contradicts`, quoting the excerpt. Revert the edit.

## Shape

- Risk class `runner`: the skill, both prompts modules, and drafter's pipeline. `live-account` for
  API spend only; no GitHub, Cloudflare, or npm account is touched beyond pushing branches. Highest
  class `runner`, so the pass returns to Geoff as a packet.
- Estimate: 540 path minutes. Recent passes ran B3 at 300 actual against 690 planned, F2 at 30
  against 310, and acceptance at 629 against 635 with five hours of batch waits. This pass has
  about 200 minutes of drafter code, the replay and controls at sync speed, the eight blueprints'
  fixes (the acceptance pass's 31 took about 90), and the tidy build with the skill's tuning and
  rebuild after it. The tidy build is the one open-ended item.
- Budget: $45 of reads over the launch baseline, under the raised cycle ceiling.
- Executor: Opus at medium, as the two live passes before it ran. Pair subagents at Sonnet medium
  for the drafter code; the tidy build and the fact fixes in a cairn session on Opus at high.
- Repos: drafter (the code, the skill, the docs), cairn-cms (the tidy blueprint, the facts, the
  throwaway proof branches), initiatives (the research record).

## Pre-flight

Nothing for Geoff beyond the decision above. The conductor checks each item before launch:

- `cycle_ceiling` in `~/.config/drafter/config.toml` reads 200, or the date is past November 1.
- The SessionStart hook's `## Host` line reads `pavilion`.
- `DRAFTER_API_KEY` is set in the launching environment, checked by name. `~/.local/secrets`
  names it (one line, 2026-10-20).
- `~/.config/drafter/cairn-cms.local.toml` exists and its `prompts` line names the chain
  (`~/.claude/workflows/docs-page-chain.js`), true on 2026-10-20.
- `drafter spend --json` shows `total` plus `open.worst` at least $45 under the ceiling.
- `go`, `node`, `vale`, `yq`, `cairn-run-gate`, and `cairn-docs-outline` resolve.
- cairn-cms commit `517158fae` is reachable from `main` (true on 2026-10-20: it is the merge of
  glw907/cairn-cms#131).

## Later

- Covers ids for the other 25 outline entries, once the tidy trial shows the check earns its keep.
- A store-wide consistency sweep, pairwise over facts no page places together. The per-page read
  covers what a page can carry; a conflict between two unplaced facts waits for a page to place
  them.
- The drafting pass: the three machinery items, drafting from gated blueprints only, and the
  batch question.
- drafter's own docs, once drafter is ready for production (Geoff, 2026-10-19).
