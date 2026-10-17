# Approval packets design: fold record

Target: `approval-packets/specs/2026-10-14-approval-packets-design.md`, revised in place on branch `approval-packets-design` from `9d1f02a`. Reviews: `2026-10-14-approval-packets-review-mechanics.md` (ids `K-`), `-review-contract.md` (ids `C-`), and `-review-data.md` (ids `D-`). Each finding was checked against `approval-queue` at `8fbe952`, `~/.dotfiles`, `log-issue`, and the prototype before it was folded or refused.

Counts: 71 findings. 64 folded, 5 refused, 2 owner forks. A third fork, the estimate ceiling, comes from folding K-M10, because only Geoff sets a standing answer.

## What the code showed

These checks decided the folds. Each one was read or probed in this session.

- The current fingerprint is `${c.kind}:${c.title}` per card, and picks are positional (`src/lib/cards.ts`, `fingerprint` and `readChoices`). A packet copied from this pattern could shift a pick under an unchanged title (D-B1).
- The keyboard approve checks `approveButton.disabled` (`ItemPanel.svelte:81`), which `aria-disabled` leaves false (D-B2).
- `keys.ts` does not commit on Mod+Enter today: on a non-triage page it sends a rejection when the note is open and otherwise does nothing. K-m4's "commits regardless" is wrong, but Mod+Enter is new in this design, so the lock rule still applies.
- `readItem` treats every kind other than `pr` and `design` as triage (`src/lib/server/items.ts`), and `writeDecision` uses one shared temp name and `rename` (D-M1, D-M9).
- Probe: Node `fs.promises.link` onto an existing `decision.json` fails with `EEXIST` and leaves the file intact (Node v24.21.0, run in the session scratchpad). The exclusive write in D-M9's fold rests on this.
- The command fetches `headRefOid` and the diff in two calls (`bin/.local/bin/approval-queue:45-53`) and already uses `flock` on `start.lock` (D-M5, D-B3).
- `gh help pr merge` lists `--match-head-commit` and `-R`. `gh help pr view` lists `state` and `baseRefOid` among its JSON fields (K-m9, D-m5).
- The shell harness stubs `curl`, `firefox`, `setsid`, and `gh`, never starts the app, and answers every `gh pr view` with `headRefOid: abc123` (K-M8, C-B3). `package.json` has no Playwright.
- The register extractor closes a block on the first bare triple-backtick line and counts every exemplar together (`tests/approval-queue.test.sh:218-222`) (K-B1, C-M8).
- `pr-summary.ts` and `before-merge.ts` import nothing, so the packet check can use `checksSummary` and `reviewVerdict` under plain `node`.
- A survey of `~/Projects` found seven repos with no `.claude/project-tracking.json`: `approval-queue`, `cairn-cms`, `cairn-pub`, `drafter`, `fishwright`, `initiatives`, and `workstation`. `log-issue` step 1 asks first-run questions in that state (K-M7). The review counted five because it checked `BACKLOG.md`, but `cairn-pub` and `workstation` have that file and no config.
- `model-review-notify` runs two unattended `claude -p` sessions. `check-drift-notify` only raises a notification, so it is the right model for the reminder (K-m8).
- Today's drawer is a flat `{#each data.queue}` (`+layout.svelte:176`) (K-m7). `/` redirects to the oldest item, and the empty page navigates to an arriving item and closes itself after 30 seconds (K-M2).
- The hold already lives in the page, and closing the tab during it undoes the decision by design (`ItemPanel.svelte` `@component` and `beforeNavigate`). This settles the Undo mechanism C-M11 asked about.
- SvelteKit's `RequestEvent` carries `cookies`, which a server `load` can read (`@sveltejs/kit/types/index.d.ts:581-583`) (K-m5).
- `~/Projects/workstation` links to `~/.dotfiles`, so `~/Projects/<repo>` resolves for every repo a design ref can name.
- Ranked principle 2 of `research/2026-10-14-human-agent-review.md` is the cap of three. The spec had cited principles 1 and 2, so the cite now names ranked principle 2. Principle 6 was already right. This came from the mechanics review's "Claims verified" note.

## Decisions taken without Geoff

The reviews tagged these as owner forks, but each has one answer that the evidence or the architecture supports, so the fold decided them.

- **What the repeat-decision rule refuses** (K-M4, C-M1, D-M4, D-m5). The command refuses a PR that GitHub reports merged or closed, and a PR already in another waiting item, and nothing else. The double meeting the old rule guarded against was a PR plus its triage, and packets remove that case by construction. Reading the log on the merge path would let a record authorize or block a merge, so no merge rests on the log. A held PR can be sent again, and the register makes it come back as an ask under `contradicts-ruling`, so a deliberate hold never loses to a preselected default. This uses one field on a call the command already makes.
- **Where refusals and word counts come from** (C-M2, K-M3, D-M11). Refusals get one line in `refusals.jsonl`, the command keeps `packet.md` in the item directory, and the register fixes the word-count rule. Each of the review's bullets now has an input, and no new app code is needed.
- **Hosts** (K-M3). Queue state is per host (`XDG_STATE_HOME`), and no channel between hosts exists (`~/.ssh/config` defines no host), so each host's review covers its own log. A merged view goes to "Later".
- **No Playwright dependency** (C-B3). The interaction promises run in the main-loop browser gate that `pass-core` and `visual-verifier` already use. Logic runs in vitest, and the command runs in shell.
- **No "now" disposition** (K-M7). `pass-core` "Scope" already puts work the pass would otherwise build on wrongly into the pass, so every remaining follow-up is backlog work, or dropped and kept in the PR body.

## Dispositions

| Id | Finding | Disposition | Where the revision carries it |
|---|---|---|---|
| K-B1 | Extractor cuts packet exemplars at the inner fence | Folded, with C-M8 | "The register": four-backtick `packet` fence, width-matched close, shapes asserted from the parse |
| K-B2 | Decision JSON's privileged fields name no channel | Folded at the root with D-B1, D-B4, C-B4 | "Parts" (verdict sources), "The command" (heads joined by the command), "The app" server list |
| K-M1 | Steps have two identities; `me` steps still merge | Folded, with C-B1, D-M7 | "Parts": `step:<n>` names plan step n; "The command": the session skips a step set to `you` or `skip` and any step whose part is not approved |
| K-M2 | Board-as-home conflicts with the redirect, auto-advance, and auto-close | Folded | "The app", the board paragraph: no redirect, poll refresh, replace links, return to `/` |
| K-M3 | Review cannot see refusals; log is per host | Folded, with C-M2, D-M11; host fork decided | "The command" step 1; "The monthly decision review" step 2; see "Decisions taken without Geoff" |
| K-M4 | Repeat rule blocks re-sends and misses `pr` | Folded at the root with C-M1, D-M4 | Second states table; "The command", the `"lane": "single"` lines |
| K-M5 | Lead repo undefined for design and step parts | Folded, with C-B2 | "Parts": refs carry the repo, lead-repo rule, a packet needs at least one PR or design |
| K-M6 | States table misses states the code distinguishes | Folded, with C-M3, C-M4, D-M6 | Both states tables: pending, merged or closed, `Recommended:` range, choice count, sources, routine table shape |
| K-M7 | `log-issue` blocks in repos without a config | Owner fork | "Rulings needed" 2; the brief's second Decide block |
| K-M8 | End-to-end check cannot run on the harness | Folded, with C-B3 | "Risk class and testing": three layers, keyed `gh` stub, browser gate |
| K-M9 | Cross-repo landing order breaks a gate | Folded, with C-M9 | "Landing order" |
| K-M10 | No path-minute estimate or standing answers | Folded; the ceiling is fork 3 | "Estimate"; "Rulings needed" 3 |
| K-M11 | Risk class understates merge authorization | Owner fork | "Rulings needed" 1; adapter facts in "Risk class and testing" |
| K-m1 | `pass-core` sites beyond "Close" change | Folded | "The sender side", first paragraph |
| K-m2 | Self-merge basis changes (optional fork) | Refused | Optional, and Geoff approved the rule's current meaning |
| K-m3 | Name who appends the log and when; keep the packet file | Folded | "The command": the command appends after printing; `packet.md` is kept |
| K-m4 | `hold.ts` lacks pause; Mod+Enter must respect the lock | Folded | "The decision bar" |
| K-m5 | A `localStorage` sort reorders on hydrate | Folded | Board paragraph: cookie read in `load` |
| K-m6 | Initiative validation details | Folded, with C-M10 | "The command", first paragraph |
| K-m7 | The flat-drawer claim is false | Folded | "The sidebar" |
| K-m8 | `model-review-notify` is not a reminder (optional) | Folded (free correction) | "The monthly decision review": modeled on `check-drift-notify` |
| K-m9 | Parser stays dependency-free; merges need `-R` (optional) | Folded (free; `-R` is a correctness fix) | "The packet file" intro; the merge line in "The command" |
| K-O1 | Fold the review into the model review (optional) | Refused | Not free: the model review runs unattended, and an unattended session cannot wait on a packet decision |
| K-O2 | Spec runs past the page limit (optional) | Refused | The reviewer judged it acceptable at spec depth; precision needs the length |
| C-B1 | The part model is undefined | Folded at the root with K-M1, D-M7, D-B4 | "Parts"; `parts` lists every part once; log rule `ask:<index>`; end-to-end step 4 restated |
| C-B2 | A design part has no repo | Folded, with K-M5 | "Parts": `<owner>/<repo>:<path>` under `$APPROVAL_QUEUE_PROJECTS`; missing path refuses |
| C-B3 | The end-to-end check names a harness that does not exist | Folded, with K-M8 | "Risk class and testing"; no Playwright dependency (decided) |
| C-B4 | The `decision.json` contract is unspecified | Folded, with K-B2 | "The command": page shape with no heads, command validation, command-only log writer |
| C-M1 | A rejected or held packet blocks its re-hand-over | Folded at the root with K-M4, D-M4 (fork decided) | Second states table; "Decisions taken without Geoff" |
| C-M2 | The review asks for numbers the log lacks | Folded, with K-M3 (fork decided) | `refusals.jsonl`, `packet.md`, the word-count rule |
| C-M3 | The ask grammar leaves refusals undefined | Folded | The grammar list and the first states table: 1-based, at least two choices, tags tied to `Part:`, sourced facts |
| C-M4 | The routine table's columns are partly undefined | Folded | Exact header; `Status` dropped because the command derives it from the fetch; `Kind` dropped because the ref's form gives it; tokens `send-back` and `you` |
| C-M5 | The prototype contradicts the contract | Folded | "The packet file": five divergences listed; brief "The prototype" |
| C-M6 | Parser criteria can pass vacuously | Folded | Parser layer: baseline fixture, one-edit refusals; data rows moved to the command layer |
| C-M7 | The decision-builder criterion is one-sided | Folded | Server layer: positive cases and server-side refusals |
| C-M8 | Exemplar extraction breaks; the count is vacuous | Folded, with K-B1 | "The register" |
| C-M9 | Cross-repo landing order | Folded, with K-M9 | "Landing order" |
| C-M10 | The initiative check reads the real home directory | Folded, with K-m6 | `$APPROVAL_QUEUE_PROJECTS`, a directory with `initiative.yaml` |
| C-M11 | Many page promises have no criterion | Folded | Browser-gate checklist in "Risk class and testing"; Undo keeps today's client-side hold, so the `pagehide` post is not adopted |
| C-m1 | Name the sentence splitter | Folded | Grammar list: `Intl.Segmenter` |
| C-m2 | Section order, unknown and empty sections | Folded | Grammar list; first states table |
| C-m3 | `[you: ...]` grammar | Folded | Grammar list: the regex, label required |
| C-m4 | Duplicate comparison needs normalization | Folded | Canonical refs only, nothing normalized |
| C-m5 | "Failing check" is undefined for pending | Folded, with D-M6 | Second states table: pending refuses; `checksSummary` classifies |
| C-m6 | Two `recommended` fields (optional) | Folded (free rename) | stdout `asks[].followed` |
| C-m7 | Reject output and log lines | Folded | "The command": reject carries no parts and logs `"verdict": "reject"` per part |
| C-m8 | Two mechanisms for one PR in two packets (optional) | Folded, at the root with D-B3 | "Also in" marking removed; waiting-item refusal |
| D-B1 | A post can map a pick onto the wrong part or default one | Folded at the root with K-B2 | Server list: full-model fingerprint, refs not positions, missing part refused |
| D-B2 | The server never enforces the lock | Folded | Server list (unanswered ask, irreversible confirmation); "The decision bar" handlers |
| D-B3 | A PR held in one packet merges through another | Folded | A PR already in another waiting item refuses, under `queue.lock`; a held PR re-sent comes back as an ask (register rule 2). No in-process mutex is needed once two waiting packets cannot share a PR |
| D-B4 | Ask-bound PRs have no place or head in the JSON | Folded, with C-B1 | `parts` lists ask-bound parts with heads; `asks[].part` |
| D-M1 | An old server renders a packet as empty triage | Folded in part | Command accepts only packet shapes (exit 1, prints nothing); exhaustive `readItem`; restart in the install step. The `/version` build id is refused: once the command refuses a wrong shape, a stale server can only stall a packet, never merge one, and a build id adds machinery that only moves the error earlier |
| D-M2 | A killed session leaves a decidable orphan | Refused | Every kind carries this exposure today, the command-owned log keeps the orphan out of the record, and nothing merges. A pid and start-time check costs more than the wasted decision it saves. Listed in "Later" |
| D-M3 | The log cannot back the dedupe; writer and atomicity unstated | Folded | Log line gains `verdict`, `head`, `sha256`; the command writes it in one write under `flock`. The dedupe no longer reads the log |
| D-M4 | What the dedupe refuses is unsettled | Folded at the root with K-M4 (fork decided, option b) | "Decisions taken without Geoff" |
| D-M5 | The diff can differ from the pinned head | Folded | "The command" step 3: re-read the head, refetch, exit 1 after three moves |
| D-M6 | Only failing checks are enforced | Folded | "Parts", forced asks; second states table: review `fix` or `escalate`, pending, `## Before merge` |
| D-M7 | `step:N` has no link to a plan step | Folded, with C-B1 | `step:<n>` names plan step n; out-of-range refuses; confirmation names steps by number. Not adopted: requiring a row for every irreversible step, since the confirmation and reject already cover it |
| D-M8 | A design approval names a path, not the content | Folded | `sha256` of the copy; a changed file comes back `hold` with `"changed": true` |
| D-M9 | Two posts both pass the waiting check | Folded | Per-request temp file, `link` to `decision.json`, 409 on `EEXIST` (probed) |
| D-M10 | A partial merge has no order or stopping rule | Folded, with D-m7 | "The command": plan order, stop at first failure, no irreversible step after it, remainder as a new packet |
| D-M11 | The review reads data no log records | Folded, with K-M3 | `refusals.jsonl`, `packet.md` |
| D-M12 | A `Part: none` ask cannot hold a part | Folded | "Parts": a `Part: none` ask changes no verdict and carries no tags; an ask that should stop a part names it |
| D-m1 | One corrupt JSON file breaks the board | Folded | Temp file synced before the link; the listing skips an unparseable item |
| D-m2 | No input lock for new controls during the hold | Folded | "The decision bar": every control locks |
| D-m3 | An indefinite pause becomes a silent undo (optional) | Refused | Optional and not free; closing during the hold already undoes by design |
| D-m4 | Choice-tag vocabulary; duplicate labels | Folded, with C-M3 | Tags are the part's verdicts; duplicate labels refuse |
| D-m5 | A merged or closed PR is not refused | Folded, with K-M4 | Second states table |
| D-m6 | Old kinds sit outside the dedupe and the log | Folded | The `pr` kind gains the waiting-item check; `pr` and `design` log `"lane": "single"` |
| D-m7 | Step order relative to merges (optional) | Folded (free, with D-M10) | "The command": plan order |
| D-m8 | The log is single-copy state (optional) | Folded (free) | "The monthly decision review" step 4: counts in `log.md` |

## Owner forks

Three questions go to Geoff, each as a `### Decide:` block in the brief and as a numbered item in "Rulings needed".

1. Raise the merge-authorization tasks to `auth-data` (K-M11). Recommend yes.
2. Let a session start a backlog in a repo that has none (K-M7). Recommend yes.
3. Plan unattended with a 1,500-minute ceiling (K-M10). Recommend yes.

## Verification

- `node ~/Projects/approval-queue/approval-queue/src/check-brief.ts design <spec>` exits 0. Its three Decide blocks each parse with two choices and one `(recommended)`.
- `tellgrader --register docs` reports no findings on the spec.
