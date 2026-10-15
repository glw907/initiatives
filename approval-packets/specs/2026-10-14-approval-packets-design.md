# Approval packets design

## Brief

Approving this design replaces the queue's one-item-per-PR model with one packet per session hand-over, grouped by initiative, so a day like 2026-10-14 reaches you as 12 packets holding 7 asks instead of 49 items.

On that day you met 11 changes twice, once as a PR and once as its triage, and several asks left out the facts they turned on. Research on review fatigue and automation bias says fewer, better-researched asks give better decisions. The prototype built from that day's real items shows the shape works.

### What changes

- A session sends one packet per hand-over: at most three asks for you, and every other part as a routine row with the session's verdict preselected.
- Every ask carries its background, sourced facts, and what each choice does, in layers you open only when the summary is not enough.
- The home page becomes a board of initiatives with packets waiting, and follow-ups go to the backlog, never to the queue.
- The server checks every answer against the packet it stored, so a part you did not approve never comes back approved, and a PR merges only at the commit you saw.
- Each decision is logged per part, and a monthly review sends you proposed rule changes as a packet.
- A new `approval-packet` skill teaches every session to build a packet, and every skill, doc, and CLAUDE.md line that names the queue moves to it.

### If you approve

1. The initiative record goes `active`, and a pass plan for `approval-queue` and `workstation` is written to `initiatives/approval-packets/plans/`.
2. The pass lands five PRs in order: the register, then the packet kind and the app in `approval-queue`, then the workstation Claude setup (a new `approval-packet` skill, `pass-core` and the other skills and docs that name the queue), then two wording PRs in `dubplate` and `poplar`.
3. The `pr`, `design`, and `triage` commands keep working throughout, so no session in flight breaks.

### Worth knowing

Two visual calls from the polish round are easy to reverse: the summary box has no left rule, and the parts inside the brief sit 24px apart against 32px between sections. The `pass-core` self-merge rule keeps today's meaning, so moving follow-ups out of the queue lets no extra PR merge without you.

### The research

Three reports ground the rules, each with sources and a ranked list of principles. They cover cognition and oversight of automated recommendations, agentic development practice, and decision-interface design. They sit in `research/`, beside three audit ledgers from the polish round.

### The prototype

The prototype rebuilt the 49 items of 2026-10-14 as packets and rendered them in the survey theme. It lives at `~/.local/share/approval-packets/prototype-2026-10-14/`, outside both public repos, because it names private repos and people. Its generator and CSS are the visual reference for the build, and this spec's grammar governs the packet file wherever the two differ.

### The reviews

Three reviews read this design for mechanics, contract, and data integrity, and the fold record gives each of their 71 findings a disposition. The record is `research/2026-10-14-approval-packets-fold.md`.

## Scope

The work spans four repos. `approval-queue` gains the packet kind, the board, the packet screen, the decision log, and the monthly review's prompt and log. `workstation` gets the rewritten brief register, the new `approval-packet` skill, the changes to every skill, doc, and CLAUDE.md line that names the queue, and the review's timer and notify script. `dubplate` and `poplar` each get a wording change in their pass skills.

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

A packet carries at most three asks. Working memory holds about four chunks, and the clinical alert research found that showing only severe alerts raised how often people acted on them (`research/2026-10-14-human-agent-review.md`, ranked principle 2). A session with more than three asks has unfinished staff work, and the command sends the packet back.

A **routine part** carries the session's verdict, preselected, and one approve covers every routine part. A default reads as an endorsement, so asks never preselect, and "Approve packet" unlocks only after every ask has an answer (`research/2026-10-14-human-agent-review.md`, ranked principle 6).

A follow-up never enters the queue. The session files it in the repo's `BACKLOG.md` through `log-issue`, tagged `#initiative:<id>` when a record fits. When you want a backlog triage, a session runs the existing `triage` kind over that backlog.

## Parts

A packet's parts are its PRs, its designs, and its plan steps. Each part has one canonical ref, and its kind follows from the ref's form:

| Kind | Ref | Resolves to | Verdicts |
|---|---|---|---|
| `pr` | `<owner>/<repo>#<n>` | PR `n` on GitHub | `approve`, `hold`, `send-back` |
| `design` | `<owner>/<repo>:<path>` | `<path>` inside `$APPROVAL_QUEUE_PROJECTS/<repo>`, default `~/Projects` | `approve`, `hold`, `send-back` |
| `step` | `step:<n>` | step `n` of "If you approve" | `session`, `you`, `skip` |

`approve` merges a PR or accepts a design. `hold` leaves the part open with nothing done. `send-back` returns it to the session to fix and send again. A step's `session` means the session runs it, `you` means you run it and the session does not, and `skip` means nobody runs it.

Each PR and design part appears exactly once: on one ask's `Part:` line or in one routine row. An ask-bound part takes its verdict from the tag on the choice you pick. A routine part takes the session's preselected verdict unless you override it. A plan step with no routine row runs as its tag says, and a routine row on `step:<n>` is how you override that step. An ask with `Part: none` changes no part's verdict, and its choices carry no tag, so an ask whose answer should stop a part names that part.

Some asks are forced by the facts, not chosen by the session. A PR with a failing check, or whose review verdict is `fix` or `escalate`, needs a `gate-failed` ask naming it. A PR whose body carries `## Before merge` needs an ask naming it, with the two choices `pass-core` reads: "The session runs it, then merges" `[approve]` and "I'll run it myself" `[hold]`. These are the cards the app raises on its own today (`src/lib/cards.ts`, `cardsFor`), moved into the packet so the cap counts them.

The lead repo, which the sidebar files the packet under, is the repo of the first PR or design part in document order, asks first. The board's repo count is the number of distinct repos among the PR and design refs.

## The packet file

A packet is one Markdown file. The command parses it and refuses a file that breaks this contract, with exit 2 and a message naming the defect and the register's path. The parser lives beside `brief.ts`, imports no package, and uses only erasable TypeScript syntax, so it runs under plain `node` as `check-brief.ts` does today.

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
Part: <a part ref, or none>
Recommended: <the number of the recommended choice, counting from 1>
Reason: <why, grounded in the facts>
Summary: <one or two sentences carrying the background and the deciding fact>

Background: <one paragraph defining every term and saying why the question exists>

Facts: <one sentence stating the key fact>
- <a fact> (`<its source: a path, a PR number, a commit>`)

Choices:
- <label>: <what happens, and whether it can be undone> [approve]
- <label>: <what happens> [hold]

Evidence: <one sentence stating what the excerpt shows>
```text
<a short excerpt: a diff, a finding, a log line>
```

## Routine
| Part | Verdict | Fact | Why |
|---|---|---|---|
| glw907/drafter#42 | approve | <the verdict-changing fact> | <one line> |
| glw907/drafter:docs/specs/x-design.md | approve | <fact> | <one line> |
| step:1 | session | <fact> | <one line> |
````

The grammar, where the template leaves a reading open:

- Sentences are split with `Intl.Segmenter('en', {granularity: 'sentence'})`, as `brief.ts` does, for the headline rule and Background's first sentence.
- The sections appear in the template's order. `## Ask:` sections and `## Routine` are optional, and a `## ` heading inside a code fence never counts.
- A plan step matches `^\[(session|irreversible|you)(?::\s*([^\]]+))?\]\s+`, and a `you` step needs its label, which the page's "You'll need to" line shows.
- An ask's field lines match `^(Rule|Part|Recommended|Reason|Summary): `. `Evidence:` and its excerpt are optional, and every other field is required.
- A choice splits at its first `: `, so a label holds no colon. Its verdict tag is the last token, in brackets.
- A fact bullet ends with its source in backticks inside parentheses.
- A ref is written in its canonical form from "Parts"; the parser normalizes nothing.

The prototype's parser (`site/build.mjs`) differs from this grammar in five ways, and none of them carries over. It reads front matter for `initiative`, `repo`, and `irreversible`; it treats an untagged step as `session`; it parses `Part:` as `#74 Title (repo)`; it falls back to body text when `Summary:` is absent; and it reads no choice tags.

The command checks these states. The first group needs only the file:

| Input | Result |
|---|---|
| No `# ` headline, or a headline longer than one sentence | Refuse: "the headline is one sentence" |
| No lede paragraph after the headline | Refuse: "missing lede" |
| `## Background`, `## If you approve`, or `## Not checked` absent, empty, or out of order | Refuse, naming the section |
| Any other `## ` heading outside a fence | Refuse, naming the heading |
| A plan step with no tag, a tag outside `session`, `irreversible`, `you`, or `[you]` with no label | Refuse, naming the step number |
| More than three `## Ask:` sections | Refuse: "at most three asks; split the packet or settle one" |
| An ask whose `Rule:` is not one of the seven | Refuse, naming the ask and the rules |
| An ask missing `Rule:`, `Part:`, `Summary:`, `Background:`, `Facts:`, `Choices:`, `Recommended:`, or `Reason:` | Refuse, naming the ask and the field |
| An ask with fewer than two choices, a choice with no `: <consequence>`, or two choices with one label | Refuse, naming the ask and the defect |
| `Recommended:` that is not the number of one of the ask's choices | Refuse, naming the ask |
| A choice with no tag when `Part:` names a part, a tag when `Part: none`, or a tag outside that part's verdicts | Refuse: "each choice sets the part's verdict", naming the ask |
| `Facts:` with no bullet, or a bullet with no source | Refuse: "every fact names its source", naming the ask |
| A ref not in canonical form, `step:<n>` outside the plan, or a design path that does not exist | Refuse, naming the ref |
| A part listed twice, in asks or the routine table | Refuse, naming the part |
| `## Routine` that is not one table with the header `\| Part \| Verdict \| Fact \| Why \|`, or a row with a different cell count | Refuse, naming the row |
| A routine verdict outside its kind's verdicts | Refuse, naming the row and the kind's verdicts |
| A packet with no PR or design part | Refuse: "a packet holds at least one PR or design" |

The second group needs the PR data the command fetches:

| Input | Result |
|---|---|
| A PR GitHub reports merged or closed | Refuse, naming the PR and its state |
| A PR already in another waiting item, of any kind | Refuse, naming that item |
| A PR with any check still pending | Refuse: "wait for the checks to finish" |
| A PR with a failing check, or a review verdict of `fix` or `escalate`, and no `gate-failed` ask naming it | Refuse: "a failing gate is an ask" |
| A PR whose body has `## Before merge`, and no ask naming it | Refuse: "a Before merge step is an ask" |
| A PR with no checks at all | Accept; the page shows "No checks" outside any disclosure |

A check fails or is pending as `checksSummary` in `src/lib/pr-summary.ts` classifies it, and the review verdict is `reviewVerdict` from the same file. Both files import nothing, so the packet check can use them under plain `node`.

A packet counts as irreversible when any plan step carries `[irreversible]` or any ask carries that rule. The page then asks for one confirmation that names the irreversible steps by number.

The register sets a target of about 250 words from the headline through "Not checked", counted as whitespace-separated tokens outside code fences. The command does not enforce it, and the monthly review reports packets over it.

## The command

`approval-queue packet <initiative> <file>` queues a packet. `<initiative>` is `none` or matches `^[a-z0-9-]+$` and names a directory holding `initiative.yaml` under `$APPROVAL_QUEUE_PROJECTS/initiatives`. The command refuses any other value with exit 2 and writes the record's `title` into `item.json`.

Queueing runs in this order:

1. The command parses the file. A refusal exits 2 and appends one line, `{time, initiative, defect}`, to `~/.local/state/approval-queue/refusals.jsonl`.
2. It takes `flock` on `$root/queue.lock`, as it already does on `start.lock`, so two commands never both pass the waiting-item check.
3. For each PR part it runs `gh pr view <n> -R <owner>/<repo> --json body,headRefOid,number,url,headRefName,baseRefName,statusCheckRollup,state`, then `gh pr diff`, then reads `headRefOid` again. If the head moved, it fetches again, and after three moves it exits 1. The diff on the page is then always the diff of the head the decision pins.
4. It runs the data checks above.
5. It writes the item directory: `packet.md` (the file as queued), `packet.json` (the parse), and for part `k`, `parts/<k>/pr.json` with the head, `body.md`, and `diff.patch`, or `parts/<k>/doc.md` with its `sha256`. `item.json` names the kind `packet`, the initiative and its title, the lead repo, and every ref, and the command writes it last, as today.
6. It releases the lock, starts the app and opens a tab as every kind does, and waits for `decision.json`.

The page never writes a head or a hash. When `decision.json` appears, the command reads it:

- It accepts only `{"decision": "approve", "parts": [{ref, verdict}], "asks": [{index, choice}]}` whose refs are exactly the packet's refs, each with a verdict of its kind, or `{"decision": "reject", "note": "<text>"}`. Anything else, such as an old server's `submit`, exits 1 and prints nothing.
- For each design part, it compares the source file's `sha256` with the copy you read. A file that changed since queueing comes back `hold` with `"changed": true`, so an approve never attaches to text you did not see.
- It joins each PR's `head` and each design's `sha256` from the item directory and prints one line of JSON.
- It then appends the log lines under the same lock, in one write.

An approve prints:

```json
{"decision": "approve",
 "parts": [
   {"ref": "glw907/drafter#41", "kind": "pr", "lane": "ask", "verdict": "approve", "head": "<sha>"},
   {"ref": "glw907/drafter#42", "kind": "pr", "lane": "routine", "verdict": "hold", "head": "<sha>"},
   {"ref": "glw907/drafter:docs/specs/x-design.md", "kind": "design", "lane": "routine", "verdict": "approve", "sha256": "<hash>"},
   {"ref": "step:2", "kind": "step", "lane": "routine", "verdict": "session"}],
 "asks": [
   {"index": 1, "part": "glw907/drafter#41", "rule": "gate-failed", "choice": "<label>", "followed": true},
   {"index": 2, "part": null, "rule": "owner-call", "choice": "<label>", "followed": false}]}
```

`parts` lists every part exactly once, whichever lane decided it. `followed` says whether you picked the recommended choice. A reject prints `{"decision": "reject", "note": "<text>"}` with no parts, and nothing merges.

On approve, the session runs "If you approve" in order. It merges each PR whose verdict is `approve` with `gh pr merge <n> -R <owner>/<repo> --merge --match-head-commit <head>`, prefixed `PREMERGE_DONE=<n>` after it runs a PR's `## Before merge` steps. It skips a step whose part is not approved and a step set to `you` or `skip`. It stops at the first failure, such as a merge the head check refuses, and runs nothing after it, including any `[irreversible]` step. It reports what it did with each part and sends what remains as a new packet.

The log is `~/.local/state/approval-queue/decisions.jsonl`. It gets one line per entry of `parts`, plus one per ask with no part, whose `ref` is `ask:<index>`:

```json
{"time": "<ISO>", "packet": "<id>", "initiative": "<id>", "ref": "<part>", "kind": "pr",
 "lane": "ask", "rule": "gate-failed", "verdict": "approve", "head": "<sha>",
 "recommended": "<label>", "chosen": "<label>", "overridden": false}
```

A routine line has no `rule`, and its `recommended` and `chosen` are verdicts. A design line carries `sha256` in place of `head`. A reject logs one line per part with `"verdict": "reject"`. The `pr` and `design` kinds append one line per decision with `"lane": "single"`, so the review can tell when they fall out of use. The log never authorizes or blocks a merge.

The `pr`, `design`, and `triage` kinds keep working, and the `pr` kind gains the waiting-item check. The board shows `pr` and `design` items in a "Single items" group, and `triage` stays the tool for a backlog triage. Removing `pr` and `design` goes to "Later", once the monthly review shows a month without them.

## The app

The approved prototype is the visual reference. Its settled decisions carry over as written. The board, the packet screen, and the sidebar all use stock DaisyUI components in the survey theme.

**The server** enforces every rule that guards a merge, since the page can be stale or bypassed. The approve action for a packet:

- rebuilds the parts and asks from the item's `packet.json` and part records, never from the post;
- refuses (400, "The packet changed; reload the page") a post whose fingerprint differs from the rebuilt one, a `sha256` over every part's ref, kind, preselected verdict, and head or hash, and every ask's title, choice labels, and tags;
- reads each routine verdict by ref (field `part:<ref>`), never by position, and refuses a post that omits a part, names an unknown ref, or sends a verdict outside the part's kind, so no part is ever defaulted;
- reads each ask's answer by choice label (field `ask:<index>`), refuses an unanswered ask or a label the ask does not hold, and sets an ask-bound part's verdict from that choice's tag alone;
- refuses an irreversible packet's approve without its confirmation field;
- writes `decision.json` through a temp file named for the request, synced to disk, then `link`ed into place, which fails with `EEXIST` when a decision already exists, so a second post returns 409 "Already decided".

`readItem` switches on the kind and returns nothing for an unknown kind, so an unknown kind is a 404, not an empty triage. The listing skips an item whose JSON does not parse, so one damaged file never takes down the board.

**The board** is the home page. `/` renders the board whenever anything waits and today's empty state when nothing does, and it no longer redirects to the oldest item. The board lists each initiative with packets waiting, as an aligned list and not as cards. Each row shows the packet headline, its ask rules and repo count beneath, the ask count, and its age in tabular figures. One labeled sort control offers "Asks first", the default, and "Oldest first". The choice lives in a cookie that the server's `load` reads, so the first render is already in that order and hydration never reorders it. The board refreshes through the tab's existing 2-second poll and never navigates on its own. Its links replace the history entry, as every desk navigation does, so the empty state's `window.close()` keeps working. A decision returns the tab to `/`. Below 640px each row stacks, with the initiative on its own line.

**The sidebar** groups waiting packets by initiative, then by lead repo, as the prototype does. Today's drawer is a flat list.

**The packet screen** shows four parts in order, each styled for its job:

1. The summary: the headline in display type and the lede, alone in the tinted box.
2. Background: a muted, borderless row whose closed state is its first sentence. Open, it keeps the same size and color.
3. "If you approve": a vertical timeline. A dot marks a session step, a lock an irreversible step, and a person icon a step you run, in the primary ink. A "You'll need to" line above the timeline lists your steps.
4. "Not checked": a neutral panel whose icon and thin left rule carry the warning hue.

Asks follow. Each ask is a radio group with nothing preselected. Its question, its summary, and its choices with their consequences sit in the open, while Background, Facts, and Evidence sit in collapses whose summary lines state their point in full sentences. Choosing an option reveals the session's recommendation and its reason.

The routine table follows the asks. Each verdict shows as text, icon, and color. A two- or three-option override sits in each row, and an overridden row takes a left rule. Each part's detail, such as the PR's diff and checks or the design doc, opens behind a disclosure whose summary states the verdict-changing fact. A failing or unchecked part keeps that fact outside any disclosure.

**A withdrawn item.** When a session withdraws an item while its page is open (the command exits and its trap removes `item.json`), a decision posted from that page returns "This item was withdrawn by its session; nothing was recorded" and offers the board. It never shows a bare "not found" (Geoff hit this on 2026-10-14).

**The decision bar** stays at the bottom of the viewport.

- "Approve packet" uses `aria-disabled`, not `disabled`. While locked it says what it waits on ("Answer 2 more asks"), and pressing it moves focus to the first open ask. The click and keyboard handlers check the lock state, since `aria-disabled` leaves the button's `.disabled` false.
- Mod+Enter commits when the packet is unlocked and does nothing while it is locked.
- A 5-second Undo holds every commit, as `startHold` does today, and every control locks while it runs. The hold pauses while the pointer is over the bar, which needs `pause()` and `resume()` in `src/lib/hold.ts`. It announces itself through a persistent status region. Closing the tab during the hold undoes the decision, as it does today.
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
2. **Completed staff work.** An ask arrives researched. The session reads the files, PRs, review findings, and logs the decision turns on, and cites each fact's source. A question the facts settle is a routine part, not an ask. A PR you held before comes back as an ask under `contradicts-ruling`, never as a routine row.
3. **Not checked never hides a deciding fact.** When an ask turns on an unchecked fact, the session checks it, or raises the ask as `low-confidence` and says why the fact is out of reach.
4. **Background for every packet.** Two to four sentences place the packet in its initiative and define any term a reader would not know.

The register keeps its `brief` and `brief-triage` exemplars, which the `pr`, `design`, and `triage` kinds and every PR body still need. It adds three packet exemplars drawn from the prototype with private names replaced: one with two asks, one routine-only packet, and one with a `gate-failed` ask. Each sits in a four-backtick `packet` fence, because a packet holds a three-backtick Evidence fence that would end a three-backtick exemplar early. The register test's extractor matches the closing fence to the opening fence's width, sends `packet` exemplars to `check-brief.ts packet`, and asserts from the parsed output that the three shapes are present, not just a count.

## The sender side

`pass-core` changes in four places: the design hand-over in "Lifecycle" step 1, the conductor's hand-over in "Conductor", the triage shape and hand-over in "Close", and the `## Before merge` paragraph in "Close". The rules:

1. **One packet per hand-over.** The session that hands work to Geoff sends one `approval-queue packet` when it reaches a decision point. A conductor running a sweep sends one packet for the PRs it holds at that point, not one per executor PR. A design brought for approval is a design part in a packet.
2. **Follow-ups go to the backlog.** Each "Found, not done" item worth doing is filed through `log-issue` in its repo's `BACKLOG.md`, tagged `#initiative:<id>` when a record fits, and listed in the PR body with its backlog number. An item not worth doing stays in the PR body, marked dropped. No triage item is sent. Work the pass would otherwise build on wrongly is fixed in the pass, as "Scope" already says, so no "now" disposition remains. Ruling 2 below sets what happens in a repo with no backlog.
3. **The self-merge rule keeps its meaning.** An `ordinary` pass merges its own PR only when it found no follow-ups at all, as it does today. A pass that filed any follow-up sends a packet. Moving follow-ups out of the queue lets no extra PR merge without Geoff.
4. **Acting on the decision** follows "The command": plan order, the `-R` merge at the decision's head, and a stop at the first failure.

The PR body still opens with `## Brief`. That is the record on GitHub, while the packet is the hand-over.

## Workstation Claude infrastructure

Every rule about the queue moves to the packet in the same pass, in the home where it executes (`claude-infra`: "A rule lives where it executes"). A survey of `~/.dotfiles`, `~/.claude`, and every project's `CLAUDE.md` and `.claude/` on 2026-10-14 found the sites below, and the pass changes each one. Anthropic's guidance for the split: "Put it in a skill if it's reference material Claude needs sometimes", and CLAUDE.md carries only a fact that applies every turn (<https://code.claude.com/docs/en/features-overview>).

**One new skill, `approval-packet`**, user scope, in `~/.dotfiles/claude/.claude/skills/approval-packet/`, with its entry in the tooling manifest and the inventory in `claude-tooling.md`. It holds the procedure a session follows at a hand-over, which today is spread across `pass-core` and the register:

1. When to send a packet, and that a conductor's sweep is one hand-over.
2. Gathering the parts and giving each its canonical ref.
3. Sorting each part into a lane by the seven ask rules, including the forced asks (a failing check, a `fix` or `escalate` review, a `## Before merge` step).
4. Researching each ask as completed staff work: which files, PRs, findings, and logs to read, and citing each fact's source. A question the facts settle becomes a routine part.
5. Writing the layers summary first, per the register.
6. Checking the file before sending with `approval-queue packet --check <initiative> <file>`, which runs the same parser and refusals without queuing. The command gains this flag for the skill.
7. Acting on the decision JSON: the per-part merges in plan order, a stop at the first failure, the report back, and the follow-ups filed through `log-issue`.

The register stays the prose standard. The skill names it and never restates it. `pass-core` points to the skill at each hand-over site and keeps the lifecycle rules.

**Existing pieces that change:**

| Site | Change |
|---|---|
| `pass-core` "Lifecycle" step 1 (the design hand-over), "Conductor" (puts each PR or design before Geoff; ends when the triage is acted on), "Close" (the triage shape and hand-over, `## Before merge`, `choices`), "Scope", the clock stop's list of attended events, and "Launch prompt" | Each names the packet and points to `approval-packet`, as "The sender side" sets out. |
| `spec-plan-review` | An owner fork becomes a `### Decide:` block in the design's brief, so Geoff rules it as an ask in the design's packet. |
| `log-issue` | The no-questions path, by ruling 2. |
| `writing-voice` router row for the approval brief | Names the packet brief and the PR-body brief, and keeps the triage file for backlog triage. |
| `docs/voice/commit-and-pr.md` | A PR body still opens with `## Brief`, as the record on GitHub, and the packet is the hand-over. |
| `docs/voice/approval-brief.md` | As "The register" says. |
| The global `CLAUDE.md` "pass process" line ("Geoff's touchpoints are the design in chat and the PR") | Names the packet as the touchpoint. |
| `claude-approval-queue-reminder` (in `approval-queue`) | On `gh pr create`, it tells the session to include the PR in its hand-over packet through `approval-packet`, in place of `approval-queue pr`. It keeps its skip clause for an executor whose conductor hands over and an `ordinary` pass that merges itself. |
| `~/.dotfiles/docs/STATUS.md` (follow-ups owed to the next pass) | Follow-ups go to `BACKLOG.md` through `log-issue`. |
| `~/.dotfiles/BACKLOG.md` item 11, "Approval queue hardening" | The item is updated to drop what this pass delivers: a malformed `item.json` or `decision.json` no longer takes down the index, since the board skips an unreadable item and names it, and the shell tests gain the start-the-app branch the command's tests now exercise. The rest stays open. |
| `dubplate` `CLAUDE.md` and `dubplate-pass`, and `poplar-pass` ("The design approval and the PR read are `pass-core`'s") | "The design approval and the packet read". |
| `approval-queue` `README.md` | Documents the `packet` kind, `--check`, and the decision log. |

**Pieces that stay as they are, and why:**

- `settings.json`. The hook entries keep their command names, and the `gh pr merge * --match-head-commit *` allow rule already covers the `-R` form.
- `claude-merge-guard`. Merges stay one PR at a time, and the guard still reads each PR's own `## Before merge` and its `PREMERGE_DONE=<n>`. The packet raises that section as a forced ask, so the session answers it before the guard checks.
- The agents and the `docs-page-chain` workflow, which name no queue term. They report to a conductor, not to Geoff.

The pass's close runs `claude-tooling-sync verify`, `/skill-doctor` on `approval-packet`, and Anthropic's `skill-creator` review of it, per `claude-infra` step 6.

## The monthly decision review

The review shares the timer shape of the monthly model review and the notify shape of `check-drift-notify`, which only raises a notification. It adds no app code.

1. A `decision-review.timer` (monthly, persistent) in `workstation`'s `upkeep` package runs `decision-review-notify`, which sends a normal-urgency reminder. Nothing runs unattended.
2. You start a session from `docs/decision-review/prompt.txt` in `approval-queue`. Queue state lives per host, so the session reviews the host it runs on. It reads that host's `decisions.jsonl`, `refusals.jsonl`, and each queued `packet.md`, and reports:
   - the override rate per ask rule and per routine verdict
   - asks you always answered with the recommendation, as candidates to move to routine
   - routine parts you overrode, as candidates to become asks
   - packets refused for more than three asks, and parts that appeared in more than one packet
   - packets over the brief's word target
3. The session sends its proposed edits to the ask rules, the register, or `pass-core` as a packet under the `approval-packets` initiative. A rule changes only through a ruling you approve.
4. `docs/decision-review/log.md` gets one line per host per month, quiet months included, with the month's counts, so a lost log costs at most one month of history.

## Landing order

The pass lands five PRs in this order, so each gate stays green and no session in flight breaks:

1. `workstation`: the register with its packet exemplars, keeping the old ones. Nothing reads the packet exemplars yet, so this breaks nothing.
2. `approval-queue`: the packet kind with `--check`, the app, the reminder hook's new wording, the README, and the review's prompt. Its branch gate runs with `REGISTER` pointing at the register on the first PR's branch until that PR merges. The pass's install step rebuilds the app and restarts the server.
3. `workstation`: the `approval-packet` skill, the `pass-core`, `spec-plan-review`, `log-issue`, and `writing-voice` changes, `commit-and-pr.md`, the global `CLAUDE.md` line, `STATUS.md`, backlog item 11, the tooling manifest and inventory, and the review's timer and notify script. They name `approval-queue packet` only once the command exists.
4. `dubplate`: the `CLAUDE.md` line and `dubplate-pass`.
5. `poplar`: `poplar-pass`.

PRs 4 and 5 are wording only and may land in either order after PR 3. The conductor hands PRs 2 through 5 over together as one packet, the first under the new kind, through `approval-packet`. PR 1 goes before them as a `pr` item, since the packet kind does not exist until PR 2 merges.

The old kinds' shell tests stay green, unchanged, through all five.

## Risk class and testing

The pass is `auth-data`, because a pass takes its highest task's class and ruling 1 makes the merge-authorization tasks `auth-data`. Its other tasks are `runner`, since they change skills (`pass-core`, `approval-packet`) and the gate's register test. `approval-queue` has no repo adapter, so the plan header states the adapter facts: the gate is `bash scripts/gate.sh`, the full-suite home is local with no CI, and the path map names the approve action, the decision builder, and the command's decision handling as the merge-authorization path. The whole-branch review reads that path closely. A part you did not approve must never reach `"verdict": "approve"`, and a PR's `head` must be the commit the page showed.

The tests run in three layers:

- **Parser (vitest).** One valid baseline packet parses, and the test asserts its parsed shape: headline, lede, plan steps with their tags, each ask's fields, and the routine rows. Each refusal fixture is one edit from that baseline and asserts the exact message and the register path, so a parser that refuses everything fails.
- **Server (vitest, as `page.server.test.ts` does today).** `/` lists a seeded packet under its initiative. The approve action refuses an unanswered ask, a missing part, an unknown ref, a verdict outside the part's kind, a label the ask does not hold, a stale fingerprint, and a missing irreversible confirmation. A valid post writes every part exactly once, an ask-bound part carries its chosen tag, held and sent-back parts never carry `approve`, a reject carries no parts, and a second post returns 409.
- **Command (shell, `tests/approval-queue.test.sh` extended).** The `gh` stub answers by PR number from `$STUB_DIR/pr-<n>.json`, so parts carry distinct heads (`aaa111`, `bbb222`, `ccc333`), and fixtures cover a failing, a pending, and a `MERGED` PR. Every row of the second states group refuses with its message. A `decision.json` in the server's shape prints the expected JSON and log lines. One naming an unknown ref, or a `submit`, exits 1 and prints nothing.

The end-to-end check hands over a fixture packet with two asks and two routine PRs: ask 1 bound to `#41` as `gate-failed`, ask 2 with `Part: none`, and routine parts `#42` and `#43`. It then confirms six things:

1. `/` lists the packet under its initiative (server layer).
2. An approve posted with ask 2 unanswered returns 400 (server layer).
3. A post that holds `#42` writes a decision that the command prints with `#42` held and `#43` approved at `ccc333`, its own head (server layer, then command layer).
4. `decisions.jsonl` gains four lines: three parts and the part-less ask, with the `lane`, `rule`, and `ref` the fixture implies.
5. Handing over `#43` again, once the stub reports it `MERGED`, exits 2 and names that state.
6. The packet page renders as the prototype does at 390 and 1440 pixels in both themes. Chromium, driven from the main loop with the Playwright MCP server, takes the shots, and `visual-verifier` grades them against the prototype's shots in `shots/`.

Step 6 is a gate, not part of `gate.sh`. In the same session the driven browser exercises, by hand, the promises no unit test can reach: the lock and its focus move, Mod+Enter, the hold with its pause and status region, an override and its left rule, the recommendation reveal, the irreversible confirmation, the sort control, and the 640px stacking of the board and the bar. The repo takes no Playwright dependency.

## Standing answers

Geoff gave these on 2026-10-14 for the unattended run, and the planner, conductor, and executor apply them in place of stopping.

| Situation | Standing answer |
|---|---|
| Planning | Unattended. The planner writes the plan, runs its review, commits the conductor prompt, and arms the launch without Geoff. |
| The plan's path passes twice the estimate (1,440 minutes) | Launch anyway up to three times the estimate, 2,160 path minutes. Past that, stop, write STATUS, and notify. |
| A task passes twice its estimate (the clock stop) | Rewrite the clock file's `estimate=` once, to four times the original, and continue. Past four times, stop, write STATUS, and notify. |
| Merging | Every PR waits for Geoff's approve in Design & PR Approvals. The conductor merges only on approve, at the approved head. |
| Host and start | Pavilion, launched by a user timer at 2026-10-17 00:01 local time. Lingering is on, so the launch needs no login session. |

## Estimate

The design's estimate is 720 path minutes: 600 for the queue work and 120 for the Claude infrastructure. The closest recent pass is `workstation` PR 43, "Rebuild the approval queue around a brief", which touched the same app, command, register, and `pass-core` with a planned path of 555 minutes. This pass adds the merge-authorization tests and two screens, and it reuses the brief parser's groundwork. Recent scores ran well under plan: PR 43 took about 70 minutes against 555, PR 74 about 150 against 455, PR 61 about 20 against 180, and `approval-queue` PR 1 about 15 against 95. The expected clock is therefore 100 to 200 minutes, and the 720-minute figure is the line the plan's path is held to. The infrastructure's 120 minutes cover the new skill with its audit and about fifteen small edits across three repos. "Standing answers" sets what the run does on an overrun.

## Later

These are not built in this pass.

- Removing the `pr` and `design` kinds, after a month without them.
- Moving a decision class to auto-land, by monthly-review ruling only.
- Showing per-class override rates beside a recommendation, once the log has enough history.
- Marking an item whose waiting command has died, so you never decide a packet nobody will act on. Every kind carries this exposure today, and the command-owned log keeps such a decision out of the record.
- One review across both hosts' logs.

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

## Rulings given at approval

Geoff approved this design on 2026-10-14 and took both recommendations.

1. **The merge-authorization tasks are `auth-data`.** The approve action, the decision builder, and the command's decision handling are test-first tasks with a `diff-reviewer` read per commit, and the pass runs as `auth-data` under the conductor.
2. **A session may start a backlog in a repo that has none.** `log-issue` gains a no-questions path that writes `.claude/project-tracking.json` with defaults (`BACKLOG.md`, the repo's name as its one domain, `medium`) and creates `BACKLOG.md` where it is missing.
