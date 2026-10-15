# Approval packets design

## Brief

Approving this design replaces the queue's one-item-per-PR model with one packet per session hand-over, grouped by initiative, so a day like 2026-10-14 reaches you as 12 packets holding 7 asks instead of 49 items.

On that day you met 11 changes twice, once as a PR and once as its triage, and several asks left out the facts they turned on. Research on review fatigue and automation bias says fewer, better-researched asks give better decisions. The prototype built from that day's real items shows the shape works.

### What changes

- A session sends one packet per hand-over: at most three asks for you, and every other part as a routine row with the session's verdict preselected.
- Every ask carries its background, sourced facts, and what each choice does, in layers you open only when the summary is not enough.
- The home page becomes a board of initiatives with packets waiting, and follow-ups go to the backlog, never to the queue.
- Each decision is logged per part, and a monthly review sends you proposed rule changes as a packet.

### If you approve

1. The initiative record goes `active`, and a pass plan for `approval-queue` and `workstation` is written to `initiatives/approval-packets/plans/`.
2. The pass builds the packet kind, the board, and the packet screen, rewrites the brief register, and changes `pass-core`'s hand-over rules.
3. The `pr`, `design`, and `triage` commands keep working throughout, so no session in flight breaks.

### Worth knowing

Two visual calls from the polish round are easy to reverse: the summary box has no left rule, and the parts inside the brief sit 24px apart against 32px between sections. The `pass-core` self-merge rule keeps today's meaning, so moving follow-ups out of the queue lets no extra PR merge without you.

### The research

Three reports ground the rules, each with sources and a ranked list of principles. They cover cognition and oversight of automated recommendations, agentic development practice, and decision-interface design. They sit in `research/`, beside three audit ledgers from the polish round.

### The prototype

The prototype rebuilt the 49 items of 2026-10-14 as packets and rendered them in the survey theme. It lives at `~/.local/share/approval-packets/prototype-2026-10-14/`, outside both public repos, because it names private repos and people. Its generator and CSS are the visual reference for the build.

## Scope

The work spans two repos. `approval-queue` gains the packet kind, the board, the packet screen, the decision log, and the monthly review's prompt and log. `workstation` gets the rewritten brief register, the `pass-core` hand-over change, and the review's timer and notify script.

Three things are out of scope. Nothing lands without your approval, and a class earns auto-land only through a later monthly-review ruling. No engine moves decision classes on its own. The queue holds no follow-up lane.

## Who decides what

You decide trade-offs: intent, scope, priority, risk appetite, and fit. The gates decide correctness. A session certifies its own work against the deterministic checks and an independent fresh-context review, and every claim it makes cites its evidence. The DORA research anchors this split. External approval made teams 2.6 times more likely to be low performers, with no measurable drop in change failures, so human approval earns its cost on trade-offs, not on checking correctness (`research/2026-10-14-agentic-dev-practice.md`, principle 1).

Every part of a packet goes into one of two lanes.

An **ask** is a judgment call for you. A part becomes an ask only under one of seven rules:

| Rule | Raised when |
|---|---|
| `irreversible` | The part cannot be undone after it runs. |
| `public-surface` | It changes a public API, a schema, or auth. |
| `cross-repo` | It has effects in a repo other than its own. |
| `owner-call` | It is a product, taste, priority, scope, or budget call. |
| `low-confidence` | The session cannot establish a fact the decision turns on, and says why. |
| `gate-failed` | A check or the independent review failed. |
| `contradicts-ruling` | It departs from a plan or ruling you approved. |

A packet carries at most three asks. Working memory holds about four chunks, and the clinical alert research found that showing only severe alerts raised how often people acted on them (`research/2026-10-14-human-agent-review.md`, principles 1 and 2). A session with more than three asks has unfinished staff work, and the command sends the packet back.

A **routine part** carries the session's verdict, preselected, and one approve covers every routine part. A default reads as an endorsement, so asks never preselect, and "Approve packet" unlocks only after every ask has an answer (`research/2026-10-14-human-agent-review.md`, principle 6).

A follow-up never enters the queue. The session files it in the repo's `BACKLOG.md` through `log-issue`, tagged `#initiative:<id>` when a record fits. When you want a backlog triage, a session runs the existing `triage` kind over that backlog.

## The packet file

A packet is one Markdown file. The command parses it and refuses a file that breaks this contract, with exit 2 and a message naming the defect and the register's path.

````markdown
# <Headline: one sentence, what this packet does and what approving causes.>

<Lede: why it matters now, one to three sentences.>

## Background
<Two to four sentences: what the initiative is for, where this packet sits in it, what came before, and a plain meaning for any term a reader would not know. The first sentence is the closed row.>

## If you approve
1. [session] <A step the session runs that can be reverted.>
2. [irreversible] <A step that cannot be undone.>
3. [you: refresh your GitHub login] <A step you run yourself.>

## Not checked
<What the session did not verify. Never a fact an ask depends on.>

## Ask: <the question>
Rule: <one of the seven rules>
Part: <a part reference, or none>
Recommended: <the number of the recommended choice>
Reason: <why, grounded in the facts>
Summary: <one or two sentences carrying the background and the deciding fact>

Background: <one paragraph defining every term and saying why the question exists>

Facts: <one sentence stating the key fact>
- <a fact> (`<its source: a path, a PR number, a commit>`)

Choices:
- <choice>: <what happens, and whether it can be undone> [approve]
- <choice>: <what happens> [hold]

Evidence: <one sentence stating what the excerpt shows>
```text
<a short excerpt: a diff, a finding, a log line>
```

## Routine
| Part | Kind | Verdict | Status | Fact | Why |
|---|---|---|---|---|---|
| glw907/drafter#42 | pr | approve | ok | <the verdict-changing fact> | <one line> |
| docs/specs/x-design.md | design | approve | ok | <fact> | <one line> |
| <what the step does> | step | session | ok | <fact> | <one line> |
````

The command checks these states:

| Input | Result |
|---|---|
| No `# ` headline, or a headline longer than one sentence | Refuse: "the headline is one sentence" |
| No lede paragraph after the headline | Refuse: "missing lede" |
| `## Background`, `## If you approve`, or `## Not checked` absent | Refuse, naming the section |
| A plan step with no tag, or a tag outside `session`, `irreversible`, `you` | Refuse, naming the step number |
| More than three `## Ask:` sections | Refuse: "at most three asks; split the packet or settle one" |
| An ask whose `Rule:` is not one of the seven | Refuse, naming the ask and the rules |
| An ask missing `Summary:`, `Background:`, `Facts:`, `Choices:`, `Recommended:`, or `Reason:` | Refuse, naming the ask and the field |
| A choice with no `: <consequence>` | Refuse: "each choice says what happens" |
| An ask whose `Part:` is a PR, with a choice that has no verdict tag | Refuse: "each choice sets the PR's verdict" |
| A part listed twice, in asks or the routine table | Refuse, naming the part |
| A routine verdict that does not fit its kind | Refuse, naming the row. A `pr` or `design` takes `approve`, `hold`, or `send-back`; a `step` takes `session`, `me`, or `skip`. |
| A PR whose checks fail, with no `gate-failed` ask naming it | Refuse: "a failing check is an ask" |
| A PR already decided at the same head commit | Refuse, naming the earlier decision's time and verdict |
| A packet with no asks and no routine parts | Refuse: "nothing to decide" |

A packet counts as irreversible when any plan step carries `[irreversible]` or any ask carries that rule. The page then asks for one confirmation that names the irreversible steps. The lead repo, which the sidebar files the packet under, is the repo of the first part listed.

The register sets a target of about 250 words from the headline through "Not checked". The command does not enforce it, and the monthly review reports packets over it.

## The command

`approval-queue packet <initiative> <file>` queues a packet. `<initiative>` is the id of a record directory in `~/Projects/initiatives`, or `none`, and the command refuses any other value. For each PR part it fetches the title, head commit, checks, and diff as the `pr` kind does today. It reads design parts from their paths. It then waits for `decision.json`, as every kind does.

When a PR in the new packet also sits in another waiting packet, the command queues it anyway, and both pages mark the part "also in <packet>".

On a decision, the command prints one line of JSON:

```json
{"decision": "approve",
 "parts": [
   {"ref": "glw907/drafter#42", "kind": "pr", "verdict": "approve", "head": "<sha>"},
   {"ref": "docs/specs/x-design.md", "kind": "design", "verdict": "approve"},
   {"ref": "step:2", "kind": "step", "verdict": "session"}],
 "asks": [{"title": "<question>", "rule": "irreversible", "choice": "<label>", "recommended": true}]}
```

A reject prints `{"decision": "reject", "note": "<text>"}`, and no part merges. On approve, the session merges each PR whose verdict is `approve` at its `head`, with `gh pr merge <n> --merge --match-head-commit <head>`. A part with `hold` or `send-back` stays unmerged, and the session reports what it did with each one.

Every decided part appends one line to `~/.local/state/approval-queue/decisions.jsonl`, the log the monthly review reads:

```json
{"time": "<ISO>", "packet": "<id>", "initiative": "<id>", "ref": "<part>", "kind": "pr",
 "lane": "ask", "rule": "gate-failed", "recommended": "<label>", "chosen": "<label>", "overridden": false}
```

A routine part logs `"lane": "routine"` with no rule.

The `pr`, `design`, and `triage` kinds keep working unchanged. The board shows `pr` and `design` items in a "Single items" group, and `triage` stays the tool for a backlog triage. Removing `pr` and `design` goes to "Later", once the monthly review shows a month without them.

## The app

The approved prototype is the visual reference. Its settled decisions carry over as written. The board, the packet screen, and the sidebar all use stock DaisyUI components in the survey theme.

**The board** is the home page. It lists each initiative with packets waiting, as an aligned list and not as cards. Each row shows the packet headline, its ask rules and repo count beneath, the ask count, and its age in tabular figures. One labeled sort control offers "Asks first", the default, and "Oldest first", and the order never shuffles while you look. The choice is remembered per browser. Below 640px each row stacks, with the initiative on its own line.

**The sidebar** groups waiting packets by initiative, then by lead repo, as the current drawer does.

**The packet screen** shows four parts in order, each styled for its job:

1. The summary: the headline in display type and the lede, alone in the tinted box.
2. Background: a muted, borderless row whose closed state is its first sentence. Open, it keeps the same size and color.
3. "If you approve": a vertical timeline. A dot marks a session step, a lock an irreversible step, and a person icon a step you run, in the primary ink. A "You'll need to" line above the timeline lists your steps.
4. "Not checked": a neutral panel whose icon and thin left rule carry the warning hue.

Asks follow. Each ask is a radio group with nothing preselected. Its question, its summary, and its choices with their consequences sit in the open, while Background, Facts, and Evidence sit in collapses whose summary lines state their point in full sentences. Choosing an option reveals the session's recommendation and its reason.

The routine table follows the asks. Each verdict shows as text, icon, and color. A two- or three-option override sits in each row, and an overridden row takes a left rule. Each part's detail, such as the PR's diff and checks or the design doc, opens behind a disclosure whose summary states the verdict-changing fact. A failing or unchecked part keeps that fact outside any disclosure.

**The decision bar** stays at the bottom of the viewport.

- "Approve packet" uses `aria-disabled`, not `disabled`. While locked it says what it waits on ("Answer 2 more asks"), and pressing it moves focus to the first open ask.
- Mod+Enter commits.
- A 5-second Undo holds every commit, pausing while the pointer is over the bar. It announces itself through a persistent status region.
- Below 640px the bar compacts to two rows.

These measured fixes from the polish round are part of the build, and the audit ledgers in `research/` hold the values:

- Unchecked radio rings use the field-border token (3.6:1 in both themes).
- Drawer focus retries each frame until the drawer is visible.
- Board rows take a stretched link with one tab stop each.
- The routine headers and the note placeholder meet AA in light.
- The two fonts that shift layout are preloaded.
- The real Monaspace 600 face is loaded.
- Brief and secondary prose are set at 56ch.
- Quotes are curly.
- Paragraphs use `text-wrap: pretty`.

## The register

`approval-brief.md` is rewritten around the packet. It keeps its three standards (the inverted pyramid, the Federal Plain Language Guidelines, and Nielsen Norman Group on web writing and progressive disclosure) and adds four rules.

1. **Layer, summary first.** Every block a reader can open has a closed state that states its point as a full sentence. The writer drafts that sentence first and the detail second. Most decisions should be possible from the closed states alone (Geoff, 2026-10-14).
2. **Completed staff work.** An ask arrives researched. The session reads the files, PRs, review findings, and logs the decision turns on, and cites each fact's source. A question the facts settle is a routine part, not an ask.
3. **Not checked never hides a deciding fact.** When an ask turns on an unchecked fact, the session checks it, or raises the ask as `low-confidence` and says why the fact is out of reach.
4. **Background for every packet.** Two to four sentences place the packet in its initiative and define any term a reader would not know.

The register's exemplars become packets. They include one with two asks, one routine-only packet, and one with a `gate-failed` ask, drawn from the prototype with private names replaced. The approval-queue tests extract them and run the parser over them, as they do for the brief exemplars today.

## The sender side

Three changes in `pass-core`'s "Close" section move the sender to packets.

1. **One packet per hand-over.** The session that hands work to Geoff sends one `approval-queue packet` when it reaches a decision point. A conductor running a sweep sends one packet for the PRs it holds at that point, not one per executor PR. A design brought for approval is a design part in a packet.
2. **Follow-ups go to the backlog.** Each "Found, not done" item is filed through `log-issue` in its repo's `BACKLOG.md`, tagged `#initiative:<id>` when a record fits, and listed in the PR body with its backlog number. No paired triage item is sent.
3. **The self-merge rule keeps its meaning.** An `ordinary` pass merges its own PR only when it found no follow-ups at all, as it does today. A pass that filed any follow-up sends a packet. Moving follow-ups out of the queue lets no extra PR merge without Geoff.

The PR body still opens with `## Brief`. That is the record on GitHub, while the packet is the hand-over.

## The monthly decision review

The review copies the monthly model review's shape and adds no app code.

1. A `decision-review.timer` (monthly, persistent) in `workstation`'s `upkeep` package runs `decision-review-notify`, which sends a normal-urgency reminder. Nothing runs unattended.
2. You start a session from `docs/decision-review/prompt.txt` in `approval-queue`. The session reads the month's `decisions.jsonl` and reports:
   - the override rate per ask rule and per routine verdict
   - asks you always answered with the recommendation, as candidates to move to routine
   - routine parts you overrode, as candidates to become asks
   - packets the command refused for more than three asks, and parts decided twice
   - packets over the brief's word target
3. The session sends its proposed edits to the ask rules, the register, or `pass-core` as a packet under the `approval-packets` initiative. A rule changes only through a ruling you approve.
4. `docs/decision-review/log.md` gets one line per month, quiet months included.

## Risk class and testing

The pass is `runner`, because it changes a skill (`pass-core`) and the gate's register test. The decision JSON is merge authorization, so the whole-branch review reads it closely. A part you did not approve must never reach `"verdict": "approve"`, and a PR's `head` must be the commit the page showed.

The parser gets table-driven tests over every row of the states table, plus the register's exemplars. The decision builder gets tests showing that a held or sent-back part, and every part of a rejected packet, never carries `approve`.

The end-to-end check hands over a fixture packet with two asks and two routine PR parts, using the stubbed `gh` the current end-to-end test uses. It then confirms six things:

1. The board lists the packet under its initiative.
2. Approve stays locked until both asks are answered.
3. Overriding one routine part to `hold` and approving prints JSON with that part held and the other approved at its head.
4. `decisions.jsonl` gains four lines.
5. Handing over the approved PR again at the same head exits 2.
6. The packet page renders as the prototype does at 390 and 1440 pixels in both themes, judged from screenshots read in the main loop.

## Later

These are not built in this pass.

- Removing the `pr` and `design` kinds, after a month without them.
- Moving a decision class to auto-land, by monthly-review ruling only.
- Showing per-class override rates beside a recommendation, once the log has enough history.

## Rulings behind this design

All from Geoff, in the design session of 2026-10-14.

- Review unit: one packet per hand-over, with the board's initiative grouping.
- The sender side is in scope.
- The home page is a board of initiatives with packets waiting.
- Prototypes come first, built from real items.
- The design follows the research, and the UI follows the UI research.
- Nothing lands without approval yet. "I want to make sure we're not doing a crazy amount of over-engineering to create an adaptive system."
- A monthly review of decisions, "so we can slowly evolve the system."
- Briefs need more background, in the house register, and every decision comes with enough to decide "without researching elsewhere."
- Use expanding sections in journalistic layers: decide from a good summary, drill down when needed.
- Restyle the brief's four parts to show the hierarchy. Background text stays consistent when opened. "Not checked" draws the eye less.
- A polish pass with latitude to go deeper where the research supports a better-working page.
