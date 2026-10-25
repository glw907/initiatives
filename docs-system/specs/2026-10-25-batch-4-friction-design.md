# Batch 4 friction: drafter and the approval queue

Status: drafted 2026-10-25 for Geoff's approval. Initiative: `docs-system`. Input: the batch 4
friction record (`research/2026-10-24-extend-blueprints-batch-4-friction.md`), its session log
(`research/2026-10-24-extend-blueprints-batch-4/friction.md`), drafter's `BACKLOG.md` #83 to #109,
and approval-queue's `BACKLOG.md` #40 and #44 to #48. Risk class: `runner` for both passes. The
drafter pass changes the `blueprint` skill, and the approval-queue pass changes the command that
every hand-over runs. No `live-account` flag.

## Brief

Approving this starts two passes that clear every drafter and approval-queue item batches 4 and 5
filed, before the last nine cairn extend blueprints start. In drafter, a blueprint check fails
when a fact it cites has a line pointer with no anchor. New checks catch the slips the register
editor and the fact-checker caught by hand in batch 4, and the drafting commands stop tripping over
a loop, a page edit, or a page that drifted from its blueprint. In the approval queue, page
approvals on one PR stop voiding each other, an approval whose session ended gets an owner, and a
note can be checked and fixed without requeueing.

### What changes

- A named `drafter check` fails on an anchorless `path:N-M` pointer in any fact its blueprints
  cite. The error names the symbol at the cited line, ready to paste as the anchor. The
  store-wide run keeps warning (your 2026-10-25 ruling: the ratchet).
- New warnings catch three Google procedure rules, stale code names in the outline, a drafted page
  whose steps or snippets drifted from its blueprint, and a page whose blueprint's links moved. A
  link to a slug the outline no longer lists is an error.
- The over-claim lint stops firing on bold labels, quoted names, and lines a fact backs.
  `[external]` facts stop warning about vendor paths, and template READMEs can be excerpted.
- `drafter page --commit` commits each accepted page, so one run per blueprint in a loop works.
  `drafter brief --sync` carries sentence ids across a page edit.
- The blueprint skill gets its seven fixes, and `format.md` splits so an author reads only the
  part they need.
- An approval of a `page` item checks the page's own file, not the PR head. `approval-queue
  pending` lists decisions whose session ended before it could act on them. A waiting item's
  notes can be checked and replaced in place.

### If you approve

1. The planning session merges the initiatives PR carrying this design, writes both plans, and
   hands each pass to its conductor. You have no pre-flight steps.
2. Each pass runs unattended and comes back to you as one packet with its PR.

### Standing answers

- A plan up to 1000 path minutes launches without you. Above that it stops and asks.
- Neither pass spends API credit. `make smoke` stays off, `drafter page` runs only with
  `--dry-run` or against a fake server, and the end-to-end checks make no batch call.
- drafter's new build goes to `~/.local/bin/drafter` only when no `drafter page` process is
  running and batch 5's `RESUME.md` says its drafting is done. The live approval queue is pulled,
  rebuilt, and restarted only when no item is waiting. Until then STATUS says so.
- A review finding that a form approved here could satisfy with a smaller change takes that
  change and lists it in the PR's `## Decisions`. Only a finding that needs a different form
  stops.
- Cairn's follow-ups (anchoring the remaining pointers, the `prose_sources` glob, the facts id
  command) go to cairn's `BACKLOG.md` through `log-issue`, never into cairn's tree. The notice
  rendering in the workstation's `docs-page-chain.js` goes to the workstation backlog the same
  way.

## The decisions inside the scope

These are method calls the design makes, so the plans carry them as written.

### drafter: the checks

- **#84, the ratchet.** Today a named check verifies no fact pointers; store verification runs
  only when nothing is named (`cmd/drafter/check.go:226`). The pass adds verification of the
  facts the named blueprints cite, so a named run shows their drift, range, and missing-file
  findings too, and an anchorless line pointer among them is an error. The unnamed run keeps the
  warning, and `drafter gate` is unchanged, so a page run never stops on a fact problem. The error names the declaration or the first identifier on the cited line as the
  suggested anchor. Once cairn's backlog item anchors the rest, a one-line change makes the
  unnamed run fail too. That change is not part of this pass.
- **#85.** The excerpt keeps the doc comment, and the anchor check reads the declaration lines
  only, as cairn's `check:facts` does. Both checkers then agree with no change to cairn.
- **#86.** Three warnings, each naming its rule: an imperative bullet outside a step list, a step
  that joins two actions with "and", and a step whose condition follows its instruction. They are
  warnings because each is a heuristic.
- **#87.** The exhaustive lint skips bold spans and quoted spans, and a line that cites a fact
  settles a count claim. No suppression marker; that waits in "Later".
- **#88.** A named run reports links from other blueprints and published pages to an anchor its
  blueprint no longer has. When `drafter page` stops on a red tree, it prints the failing
  component's first lines from `gate-N.log` and names the file.
- **#89.** A link to a slug the outline doesn't list is an error, in named and unnamed runs.
  This replaces the rename command, which a check makes unneeded.
- **#90.** A backticked identifier in an outline entry's `covers` that resolves nowhere in the
  source tree warns.
- **#91.** A notice is a bullet that opens with its kind and a colon (`- Caution: ...`). The
  kinds are a fixed list, GitHub's alert set: Note, Tip, Important, Warning, and Caution. The
  decoder reads such a bullet as a notice item, the format doc says so, and drafter's stock
  prompts render it as a notice. cairn drafts through the workstation's prompts module, which
  gets the same line through the workstation backlog.
- **#92.** The drifted-anchor hint names the line where the whole anchor matches, or says no
  line does.
- **#93 to #95, #105.** An `[external]` fact's paths skip the existence check. An anchor
  followed by more text, `` (`symbol`: more text) ``, reads as the anchor. `facts.prose_sources`
  takes globs, and a file it lists can be excerpted.
- **#96.** `drafter outline` with no slug prints the outline. `drafter refs --out-of-scope <slug>`
  lists the entries whose `outOfScope` names it. A missing blueprint's error uses the
  `.blueprint.md` suffix.
- **#106.** A drafted page goes stale when a link target in its blueprint changes.
- **#107.** A `no-claim` brief sentence may carry a numeral or a code name that appears in a
  code block on the page.
- **#108.** A check of a drafted page warns when its step count, step order, or a snippet's
  identifiers differ from its blueprint's. It is a warning, since a redraft may reword a step.

### drafter: the drafting commands and the skill

- **#104.** `drafter page` already takes several blueprints in one run (`cmd/drafter/page.go:31`);
  the batch 4 failure was a shell loop of one run per page. `drafter page --commit` commits each
  accepted page, its brief, and `drafted.lock` with a fixed message, and the help text's "never
  commits" changes to match. The skill says to pass `--commit` in a loop.
- **#109.** `drafter brief --sync <page>` re-splits the page and keeps each unchanged sentence's
  id. Changed sentences get new ids and print, so the author re-tags them.
- **#83.** Recovery after a create of unknown outcome stops holding other pages: a page whose own
  batch is known keeps advancing while the candidates are checked. The plan sets the mechanism.
- **#97 to #103.** The skill's `format.md` is a link to the published `docs/blueprint-format.md`,
  so the split is of the published doc: the markdown-blueprint part an author reads, and a
  reference part. Links into moved anchors are updated in the same change. A new
  `facts.id_command` setting names the project's id command, and the skill tells an author to
  run it. The skill also records a scratchpad run in
  the fact's note, names values by their identifiers, says how to name a file in the reader's
  site, loosens the task-guide anatomy's item 5, and allows an exact in-place substitution in
  the fact-edit rule.

### approval-queue

- **#48.** An approval of a `page` item compares the page's blob at the PR's current head with
  the blob queued, not the head itself. Another page's commit on the same PR no longer voids it,
  and neither does a head GitHub hasn't updated yet. The waiter runs the check after the app
  writes the decision, so a refusal writes a refused state the board shows, saying the page
  changed and the session requeues it. A `collect` runs the same check.
- **#44.** Only the waiting command writes `decisions.jsonl`, so a decision made after its
  session ended exists only as the item's `decision.json`. `approval-queue pending` lists each
  item with a `decision.json`, no live waiter, and no log line. A session takes one over with the
  existing `approval-queue collect <id>`, which logs it and prints the decision. The blueprint
  skill tells a session to run `pending` first.
- **#45 and #47.** `approval-queue notes --check <file> <notes.json>` runs the queue-time notes
  checks. It adds one the queue lacks today: a quote anchor that matches more than once, which
  the app resolves only when it renders. Queueing refuses such a quote too. `approval-queue notes <id> <notes.json>`
  replaces a waiting item's notes and keeps its id and URL.
- **#46.** The `-1` comes from the shared slugger, which counts the front matter's `page` title
  before the H1 (`approval-queue/src/lib/editor/notes.ts:70-79`). The fix goes there, so the
  command and the screen agree, and a note keyed to an old `-1` anchor resolves through the
  existing alias mechanism. drafter's slugger counts the title too
  (`internal/plan/check.go:228-240`); the drafter plan checks it against how cairn renders the
  page and fixes it if it double counts.
- **#40.** `withdraw` says what it did when the waiter is already gone, with no `proc_stat`
  error.

## Shape

Two passes run side by side. They share no files: the drafter pass touches drafter only, and the
approval-queue pass touches approval-queue only. The blueprint skill line for `pending` lands in
the drafter pass, worded to the command the approval-queue plan names. `conductor-drafter` and
`conductor-approval-queue` each launch, watch, and hand over one pass, as pass-core names a
conductor per repo. That means two packets.

The drafter estimate is 500 path minutes and the approval-queue estimate 240, against the 1000
ceiling. The last two drafter passes ran 600- and 505-minute paths in about 35 minutes each, so
the ceiling is a guard, not a forecast.

Out of scope: #1 (waits on your ruling), drafter's older Medium and Low items, approval-queue's
polish items #37 to #39 and #41 to #43, the record's cairn-cms and workstation items, and the
cairn blueprints, facts, and pages.

## The end-to-end checks

drafter, on a scratch worktree of cairn's `main` with a build of the branch: a named check of a
blueprint citing an anchorless fact exits non-zero and names the suggested anchor, and the
unnamed run warns on the same fact. A link to a removed slug fails. `drafter brief --sync` on a
scratch-edited page keeps the ids of unchanged sentences. `drafter page --commit` against a fake
API server (`api_base_url`) accepts a page and commits it.

approval-queue, on a throwaway state directory and port: two `page` items queued on one test PR
are both approved after a second commit lands on the PR, and a third refuses when its own page
changed. An approval made after its waiter is killed shows in `pending` until `collect` takes
it. `notes` replaces a waiting item's
notes, and its URL still answers.

## Later

- A per-line marker that settles any warning, if the over-claim and procedure lints stay noisy.
- The ratchet's second step, once cairn's pointers are anchored.
- A decision hook that runs a named command on approve, if `pending` goes unread.
