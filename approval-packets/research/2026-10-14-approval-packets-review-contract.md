# Approval packets design: contract and criteria review

Target: `approval-packets/specs/2026-10-14-approval-packets-design.md` at `c72785d` (branch
`approval-packets-design`). Lens: is every promise testable, does each criterion name its fixture
and its failure reason, can any criterion pass vacuously, and would two implementers build the same
parser, JSON contract, and end-to-end check. Checked against `approval-queue` at `8fbe952`
(`bin/.local/bin/approval-queue`, `src/lib/brief.ts`, `src/check-brief.ts`, `src/lib/cards.ts`,
`src/lib/server/items.ts`, `routes/item/[id=id]/+page.server.ts`, `tests/approval-queue.test.sh`,
`scripts/gate.sh`), the register `~/.dotfiles/claude/.claude/docs/voice/approval-brief.md`, and the
prototype `site/build.mjs` with `packets-v2/`.

Count: 4 blockers, 11 majors, 8 minors (23). Two findings are OWNER FORKs.

## Blockers

### B1. The part model is undefined: what a "part" is, how it is referenced, and which parts the JSON and the log carry

- Severity: blocker. Tag: `correctness`.
- Location: spec:85-86, 105-110, 126, 145-151, 155-162, 250.
- Defect: three different notions of a part coexist and the spec never reconciles them.
  1. The `Part:` grammar is never given. The routine table shows `glw907/drafter#42`, a bare
     path `docs/specs/x-design.md`, and free text `<what the step does>`; the JSON shows
     `step:2`. A `step:2` ref reads as plan step 2 ("If you approve"), but the routine table's step
     rows have free-text Part cells and the plan steps carry `session|irreversible|you` tags, not
     the `session|me|skip` verdicts the JSON gives `step:2`. Two implementers will disagree on
     whether plan steps are parts at all.
  2. An ask with `Part:` naming a PR sets that PR's verdict through its choice tag (spec:125), and
     the duplicate rule (spec:126) forbids the same PR in the routine table. The spec never says
     that ask-bound parts appear in `parts[]` of the decision JSON, so a session reading the JSON
     could miss a PR approved through an ask, or merge it twice if it reads both arrays.
  3. "Every decided part appends one line" (spec:155) leaves an ask with `Part: none` unlogged,
     yet e2e criterion 4 (spec:250) expects four lines from "two asks and two routine PR parts".
     Four is right only if a part-less ask logs a line (with what `ref`?), or if both asks bind to
     PRs (then the routine table would have to be empty, contradicting the fixture). The criterion
     passes or fails depending on an unstated reading.
- Fold: add a "Parts" subsection that fixes:
  - The ref grammar: `<owner>/<repo>#<n>` for a PR; `<repo>:<path>` for a design (see B2);
    `step:<n>` for plan step `n`. A routine `step` row references a plan step by `step:<n>` and is
    the only way a step gets a verdict override; an untagged plan step defaults per its tag.
  - The JSON rule: `parts[]` holds every part exactly once, whichever lane decided it, each with
    `lane` (`ask` or `routine`); `asks[]` holds every ask with its `part` ref or `null`.
  - The log rule: one line per entry of `parts[]` plus one per ask with `part: null` (`ref` set to
    `ask:<index>`), and restate e2e criterion 4 as "two routine lines and two ask lines, with these
    `lane`, `rule`, and `ref` values".

### B2. A design part has no repo, and the command lost its `<repo>` argument

- Severity: blocker. Tag: `correctness`.
- Location: spec:109, 132, 138, 170.
- Defect: the packet command is `packet <initiative> <file>`; the old `<repo>` argument is gone.
  A PR ref carries its repo; a design path (`docs/specs/x-design.md`) and a step carry none. "The
  lead repo ... is the repo of the first part listed" (spec:132) is undefined when that part is a
  design or a step, the board's "repo count" (spec:170) cannot be computed, the sidebar cannot file
  the packet, and "reads design parts from their paths" (spec:138) does not say relative to what
  (the command's cwd? the packet file's directory?). Two design parts named `docs/specs/x.md` in
  two repos also collide in the duplicate check and in the log's `ref`. The prototype sidebars
  worked only because its packets carry `repo:` front matter and a `Repo` column (`packets-v2/*.md`),
  which the spec dropped.
- Fold: either restore a `Repo` column in the routine table and a `(repo)` suffix on ask `Part:`
  lines (the prototype's shape), or make the design ref `<repo>:<path>` with `<repo>` resolved as
  `~/Projects/<repo>` and the path relative to that checkout; state that a step's repo is the lead
  repo; define the lead repo as the repo of the first PR or design part in document order (asks
  first, then routine rows), and refuse a packet whose parts are all steps unless it names one.
  Add a states row: "a design path that does not exist" refuses, naming the part.

### B3. The end-to-end check names a harness that does not exist

- Severity: blocker. Tag: `correctness`.
- Location: spec:245-252.
- Defect: "using the stubbed `gh` the current end-to-end test uses" points at
  `tests/approval-queue.test.sh`, which stubs `curl`, `firefox`, and `setsid`, never starts the
  app, and writes `decision.json` by hand. Criteria 1 (board lists the packet), 2 (Approve stays
  locked), and 3 (override one row to `hold` and approve) need the real app and a driven browser.
  The repo has no browser driver (no Playwright in `approval-queue/package.json`) and no CI. Two
  implementers will build different things: one adds Playwright, one writes `decision.json` by hand
  and calls criteria 2 and 3 met. The stub also answers every `gh pr view` with
  `headRefOid: abc123` and `number: 42` regardless of its argument and with a passing check, so
  criterion 3's "the other approved at its head" passes vacuously (both heads are `abc123`), and
  the duplicate-part and failing-check states cannot be exercised through it.
- Fold: split the check into named layers, each with its fixture:
  - Shell (`tests/approval-queue.test.sh`, extended): a `gh` stub keyed by PR number
    (`STUB_DIR/pr-<n>.json`) so two PRs carry distinct heads (`aaa111`, `bbb222`) and one fixture
    PR carries a failing check; the test writes a `decision.json` in the documented shape (B4) and
    asserts stdout, the log lines, and exit codes.
  - Server (vitest on `+page.server.ts` actions, as `page.server.test.ts` does today): the approve
    action refuses a post with an unanswered ask, an unknown ref, or a verdict outside the part's
    kind (B5), and builds `parts[]` with the fetched heads.
  - Visual gate (criterion 6): Chromium driven from the main loop with the Playwright MCP, graded
    by `visual-verifier` against named prototype shots. State that the lock and the hold override
    are also exercised there by hand, and that it is a gate, not a test in `gate.sh`.
  Adding Playwright as a dependency is the alternative; if chosen, the spec must say so, since a
  new dependency is a design call.

### B4. The `decision.json` contract between page and command is unspecified

- Severity: blocker. Tag: `correctness`.
- Location: spec:138, 142-153.
- Defect: the spec gives the stdout JSON but not the file the page writes and the command waits
  for. Today the `pr` kind adds `head` after the fact (`jq '. + {head: $h}'` in the command), and
  the server writes `{decision, choices}` (`items.ts` `Decision`). For a packet, it is open whether
  the page writes heads (and so could write a head the command never fetched), whether the command
  joins heads from its own `pr.json` per part, and whether `decisions.jsonl` is appended by the
  server action or by the command after it reads `decision.json`. That last choice decides whether
  a log line exists for a decision the command never printed (command killed while waiting) and
  whether two concurrent packets interleave writes. "A PR's `head` must be the commit the page
  showed" (spec:241) is untestable until it is said which side owns `head`.
- Fold: state that the page writes `decision.json` as `{decision, parts: [{ref, verdict}], asks:
  [{index, choice}]}` with no heads; the command joins each PR's `head` from the item directory's
  per-PR fetch record, validates every ref against the parsed packet, and alone appends
  `decisions.jsonl` (one `O_APPEND` write of all lines, after printing stdout). Name the per-part
  item files (for example `parts/<n>/pr.json`, `diff.patch`) the way the current command names
  `pr.json` and `body.md`. Add a shell test: a `decision.json` naming an unknown ref or an
  approve for a part held at fetch makes the command exit 1 and print nothing.

## Majors

### M1. A rejected or held packet blocks its own re-hand-over (**OWNER FORK**)

- Severity: major. Tag: `correctness`.
- Location: spec:129, 251.
- Defect: "A PR already decided at the same head commit" refuses re-queueing. "Decided" includes
  `hold`, `send-back`, and every part of a rejected packet. A packet rejected for a wording defect
  in its brief (head unchanged) can never be sent again without a new commit, and a held PR cannot
  be re-asked after you and the session talk it over. The source of "earlier decision" is also
  unstated: the log line (spec:158-159) carries no `head`, so the check cannot read
  `decisions.jsonl` as specified and must scan item directories.
- Options: (a) only an `approve` at the same head blocks; (b) `approve` and `send-back` block,
  `hold` and reject do not; (c) every verdict blocks, as written, and the session must push a commit
  to re-ask.
- Recommendation: (a). It matches the purpose (no double merge authorization) and keeps reject
  cheap. Either way, add `head` to the log line and name the log as the lookup source, and make e2e
  criterion 5 assert the message names the earlier time and verdict, so a refusal for any other
  reason (bad initiative, parse error) cannot satisfy it.

### M2. The monthly review asks for numbers the log does not hold (**OWNER FORK**)

- Severity: major. Tag: `correctness`.
- Location: spec:155-162, 234-235.
- Defect: "packets the command refused for more than three asks" and refusals for parts decided
  twice happen before anything is queued, so they never reach `decisions.jsonl`. "Packets over the
  brief's word target" needs a word count, and the log line has none. Three of the five report
  bullets cannot be computed from the stated input.
- Options: (a) the command appends each refusal to `refusals.jsonl` (`time`, `initiative`,
  `defect`) and each queued packet's line carries `words`; (b) drop the three bullets from the
  review.
- Recommendation: (a). It is a few lines in the command, no app code, and keeps the review's
  promise. Specify the word-count rule (headline through "Not checked", whitespace-separated
  tokens, fences excluded) so the review and any later check count the same.

### M3. Ask grammar leaves several refusals undefined

- Severity: major. Tag: `correctness`.
- Location: spec:84-103, 122-125.
- Defect: missing states and loose fields:
  - `Recommended:` is "the number of the recommended choice"; base (the prototype uses 1-based)
    and range are not checked. An out-of-range or non-numeric value is not a states row.
  - No minimum choice count. A one-choice ask passes and is a vacuous question.
  - The verdict tag set on a choice is not given. Is `[send-back]` allowed? Is a tag allowed,
    required, or forbidden when `Part:` is a design or `none`? Is the tag the last token on the
    line?
  - The choice label/consequence split: the prototype splits at the first `": "`, so a label
    containing `": "` silently mis-splits; the spec should say so.
  - `Rule:` and `Part:` absent are not in the "missing field" row (spec:123), and `Evidence:` is
    shown but never declared optional or required.
  - `Facts:` promises "sourced facts" (spec:12, 209) but no row refuses a fact bullet with no
    backticked source, or a `Facts:` with no bullets.
- Fold: add states rows for each, with the message, and write the grammar as the prototype parses
  it (field lines `^(Rule|Part|Recommended|Reason|Summary): `, `Background:` continuing to the next
  field, fact bullets matching `\(([^()]*`[^()]*)\)\.?$`). Recommend: 1-based, two to four
  choices, tag required when `Part:` is a PR and forbidden otherwise, tag set `approve|hold|send-back`,
  at least one fact bullet, every bullet sourced.

### M4. The routine table's columns and values are partly undefined

- Severity: major. Tag: `correctness`.
- Location: spec:105-110, 127.
- Defect: `Status` is shown only as `ok`; its other values (the page later speaks of "a failing or
  unchecked part", spec:183) are never listed, and nothing ties `Status` to the fetched checks. A
  `Kind` outside `pr|design|step`, a missing or reordered column, a row with too few cells, and a
  `## Routine` with prose instead of a table (the prototype keeps a `routineNote`) have no states
  rows. A step verdict `me` conflicts with the plan tag `you` and the prototype token `you`; a PR
  verdict `send-back` conflicts with the prototype token `sendback`.
- Fold: fix the header as an exact string the parser matches; list `Status` values (`ok`,
  `failing`, `unchecked`) and say the command overwrites a PR row's `Status` from its fetched checks
  (or refuses a mismatch); add rows for an unknown kind and a malformed table; pick one token set
  and note where the prototype differs.

### M5. The prototype is called the reference parser but contradicts the contract

- Severity: major. Tag: `correctness`.
- Location: spec:32, 168 (and the brief to this review).
- Defect: `build.mjs` treats an untagged plan step as `session` (the spec refuses it, spec:120),
  reads YAML front matter for `initiative`, `repo`, and `irreversible` (the spec has none), parses
  `Part:` as `#74 Title (repo)` (the spec shows `glw907/drafter#42`), uses `sendback` and `you`
  tokens, falls back to body text when `Summary:` is absent (the spec refuses), and does not parse
  choice verdict tags at all. An implementer told to follow the prototype builds a different
  parser.
- Fold: say the prototype is the visual reference only and the spec's grammar governs, and list
  these five divergences in one line each so nobody ports them.

### M6. Parser criteria can pass vacuously

- Severity: major. Tag: `correctness`.
- Location: spec:243.
- Defect: "table-driven tests over every row of the states table" asserts refusals. A parser that
  refuses everything passes all of them. Two rows (failing checks, already decided) are not parser
  states: they need `gh` data and history, so a parser-only table cannot cover them as claimed.
- Fold: require one valid baseline fixture that parses cleanly and asserts its parsed shape
  (headline, lede, plan step types, ask fields, routine rows), and derive each refusal fixture from
  it by one edit, asserting the exact message and that the message names the register path (as
  `refuse` in the shell test does today). Move the two data-dependent rows to shell tests with the
  keyed `gh` stub (B3).

### M7. The decision builder criterion is one-sided

- Severity: major. Tag: `correctness`.
- Location: spec:241-243.
- Defect: "never carries `approve`" for held, sent-back, and rejected parts passes for a builder
  that emits no parts, or that drops approved parts. Nothing tests that the server refuses a posted
  verdict the page did not offer (a step posted as `approve`, a ref not in the packet, an ask left
  unanswered); today's `cardsFor` plus `fingerprint` re-derive the card list server side, and the
  spec carries no equivalent.
- Fold: add the positive cases (every part appears once, approved parts carry `approve` and the
  fetched head, `parts[]` length equals the packet's part count) and the server-side refusals
  (unanswered ask, unknown ref, verdict outside the kind's set, packet text changed since load via a
  fingerprint of the parsed packet).

### M8. Register exemplar extraction breaks on the packet shape, and the count can pass vacuously

- Severity: major. Tag: `correctness`.
- Location: spec:213.
- Defect: the extractor in `tests/approval-queue.test.sh` opens on `^```brief(-triage)?$` and
  closes on the first `^```$`. A packet holds a nested ` ```text ` evidence fence, so its closing
  line ends the exemplar early. The count check is `n -ge 3` over all fences, so the old brief
  exemplars alone satisfy it with zero packet exemplars. The spec also does not say whether the
  rewritten register keeps the `brief` and `brief-triage` exemplars, which the `pr`, `design`, and
  `triage` kinds still need (spec:164, 223).
- Fold: name the fence (` ````packet ` with four backticks, closed by ` ```` `), add `packet` to
  `check-brief.ts`, keep the old exemplars, and assert per kind: at least three `packet`
  exemplars, of which one has two asks, one has zero asks, and one has a `gate-failed` ask (assert
  these from the parsed output, not by count).

### M9. Cross-repo landing order breaks the gate

- Severity: major. Tag: `correctness`.
- Location: spec:36, 213, 239.
- Defect: `gate.sh` reads the live register at `~/.claude/docs/voice/approval-brief.md`. If
  `approval-queue` lands requiring packet exemplars before `workstation` ships them, its gate
  fails; if the register lands first, nothing breaks, but the spec does not say so, and the
  `pass-core` change must not land before the command it calls exists (spec:20 promises no
  in-flight session breaks).
- Fold: state the order: register with packet exemplars (keeping old ones), then `approval-queue`,
  then `pass-core`; and the check that proves step 3 of "If you approve": the old-kind shell tests
  stay green unchanged.

### M10. The initiative check reads the real home directory

- Severity: major. Tag: `correctness`.
- Location: spec:138.
- Defect: "the id of a record directory in `~/Projects/initiatives`" makes the shell tests depend
  on Geoff's real initiatives checkout. "Record directory" is also undefined (any directory, or one
  holding `initiative.yaml`?).
- Fold: `APPROVAL_QUEUE_INITIATIVES` (default `~/Projects/initiatives`) and "a directory holding
  `initiative.yaml`"; add the refusal message and a states row for it.

### M11. Many page promises have no criterion

- Severity: major. Tag: `correctness`.
- Location: spec:132, 140, 170-190.
- Defect: no test or gate item covers: the irreversible confirmation naming the steps; "also in
  <packet>" on both pages; the sort control, its default, its no-shuffle rule, and its per-browser
  memory; the 640px stacking of board rows and the bar; Approve's focus move to the first open ask;
  Mod+Enter; the 5-second Undo, its hover pause, and its status region; the recommendation hidden
  until a choice is made; the overridden row's left rule; a failing part's fact outside any
  disclosure. The Undo also has an unstated mechanism: if the page delays the post by 5 seconds,
  closing the tab inside the window loses the decision; if the server delays the write, Undo needs
  a cancel endpoint.
- Fold: one checklist under "Risk class and testing" assigning each to a layer (vitest for pure
  logic such as sort order and verdict options; the visual gate for layout, focus, and keyboard),
  and one sentence fixing Undo as client-side with the post sent at expiry or on `pagehide`.

## Minors

### m1. The headline rule needs its sentence splitter named

- Severity: minor. Tag: `correctness`. Location: spec:117.
- Defect: "longer than one sentence" is ambiguous on `e.g.`, version numbers, and paths. The
  current parser uses `Intl.Segmenter('en', {granularity: 'sentence'})` (`brief.ts:148`); the
  prototype uses a regex.
- Fold: name `Intl.Segmenter` so both parsers agree; same for Background's "first sentence"
  (spec:74).

### m2. Section order, unknown sections, and empty sections are unstated

- Severity: minor. Tag: `correctness`. Location: spec:119.
- Defect: no row says whether sections must appear in order, whether an unknown `## ` heading (such
  as `## Worth knowing`) refuses or is ignored, or whether an empty `## Not checked` passes.
  Headings inside fences must not count (the current parser tracks fences; say so).
- Fold: fixed order, unknown headings refuse, empty "Not checked" refuses (the register can say
  "Nothing." is a valid body).

### m3. The `[you: ...]` tag grammar is unstated

- Severity: minor. Tag: `correctness`. Location: spec:79, 120.
- Defect: whether `[you]` without a label is valid, and whether `[session: ...]` takes a label, is
  left to the prototype's regex.
- Fold: write the regex `^\[(session|irreversible|you)(?::\s*([^\]]+))?\]\s+` and say the label is
  required for `you` (the "You'll need to" line, spec:178, shows it).

### m4. Duplicate-part comparison needs normalization

- Severity: minor. Tag: `correctness`. Location: spec:126.
- Defect: `glw907/drafter#42` versus `drafter#42`, or a design path with `./`, compare unequal.
- Fold: compare canonical refs after B1's grammar resolves them.

### m5. "Failing check" is undefined for pending checks

- Severity: minor. Tag: `correctness`. Location: spec:128.
- Defect: a pending or missing check is neither pass nor fail. `checksSummary` has states; the spec
  should name which count.
- Fold: "any rollup row whose `checksSummary` state is `fail`"; pending sets `Status: unchecked`
  and needs no ask.

### m6. Two fields called `recommended` mean different things

- Severity: minor. Tag: `optional`. Location: spec:150, 159.
- Defect: stdout `asks[].recommended` is a boolean (chose the recommendation); the log's
  `recommended` is a label.
- Fold: rename the boolean `followed`, matching the log's `overridden`.

### m7. The reject output and its log lines are unstated

- Severity: minor. Tag: `correctness`. Location: spec:153, 155.
- Defect: whether a reject writes log lines (the review's override rates need to know) and whether
  the reject JSON carries any parts is open.
- Fold: a reject logs one line per part with `chosen: "reject"`, and its JSON carries no parts.

### m8. Over-ceremony: two overlapping mechanisms for one PR in two packets

- Severity: minor. Tag: `optional`. Location: spec:129, 140.
- Defect: "also in <packet>" cross-page marking needs cross-packet state on every load, and the
  same-head refusal already blocks the worst case. After one packet approves the PR, the other page
  still offers approve; the session's `--match-head-commit` merge then fails harmlessly. The
  marking costs a build task and a test for a rare case.
- Fold: keep the refusal, drop the marking to "Later", or mark only on the second packet's page at
  queue time (a static field the command writes into `item.json`).

## What holds up

The states table is the right shape and most rows already name their message; the merge line
(`--merge --match-head-commit <head>`) is exact; the three-ask cap, the `aria-disabled` lock, and
the per-part log are each concrete enough to test once B1 and B4 fix what a part is and who writes
what.
