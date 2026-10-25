# approval-queue batch 4 friction plan: page approvals, pending decisions, and notes in place

Initiative: docs-system

Design: `~/Projects/initiatives/docs-system/specs/2026-10-25-batch-4-friction-design.md`, its
"approval-queue" section, approved by Geoff on 2026-10-25 (glw907/initiatives#138, merge
`17746d6`). The design covers two passes; this plan is the approval-queue pass only (backlog #40,
#44, #45, #46, #47, #48). A separate plan carries the drafter pass, whose `blueprint` skill line
tells a session to run `approval-queue pending`, so that command name is fixed here.

Path estimate: 260 path minutes against the design's 240 (1.08x), inside the 1000-minute standing
ceiling. The arithmetic is under "Path". The last three approval-queue passes ran well under plan
(PR #9: 122 minutes against a 415-minute path), so the ceiling is a guard, not a forecast.

The planning session read approval-queue at `f8df477` (main, clean) and initiatives at `fccedb5`.
Line numbers below are at `f8df477`; the executor finds each quoted symbol by name.

One `plan-reviewer` read (mechanics and feasibility) verified every line reference and returned no
blocker, 5 majors, and 13 minors, all folded but one. The folds cover the restart line (a failed
build or a slow shutdown no longer reads as a restart, and `npm ci` runs only on a lockfile change),
where the `notes` forms dispatch, CT's exit codes and pids, a missing conductor-drafter, and the
`import type` form. Kept against the review: both UI reviewers at close, which the planning brief
names.

## Pre-flight

Nothing for Geoff. The conductor checks each item just before launch:

- `/var/home/glw907/Projects/approval-queue` is on `main`, `git status --porcelain` prints nothing,
  and `git rev-list --count HEAD..origin/main` prints 0 after `git fetch origin`.
  `git check-ignore -q .claude/worktrees/x` exits 0.
- No live session other than the conductor works approval-queue (`claude agents --json`, rows whose
  cwd is under `/var/home/glw907/Projects/approval-queue`). A session that only queues items
  through the live command (batch 5's drafting sessions) does not work the repo.
- `node`, `npm`, `jq`, `gh`, `flock`, and `cairn-run-gate` resolve, and `gh auth status` answers.
- Port 7994 is free (`curl -sf http://127.0.0.1:7994/` fails).
- `mkdir -p /var/home/glw907/.local/state/aq-batch4` has run (the executor's `--add-dir`).
- `/var/home/glw907/.claude/docs/voice/approval-brief.md` exists (`tests/approval-queue.test.sh`
  reads it).
- This plan and its two prompts are committed on initiatives `main`.

`npm ci --prefix approval-queue` in the pass worktree is the executor's T0, not a pre-flight item.

## Outcome

The design's approval-queue outcome, built in glw907/approval-queue:

- **#48.** An approve of a `page` item checks that the page's blob at the PR's current head is the
  blob queued, not that the head is unmoved. A sibling page's commit on the same PR no longer voids
  it. A refusal writes `refused.json`, which the rail's "Decided this session" list shows as
  "Refused" with the reason, and the session queues the page again. `collect` runs the same check.
- **#44.** `approval-queue pending` lists each decided item whose session ended before it logged
  the decision. A session takes one over with `approval-queue collect <id>`.
- **#45 and #47.** `approval-queue notes --check <file> <notes.json>` runs the queue-time notes
  checks plus a new one: a quote anchor that matches more than once. Queueing refuses that quote
  too. `approval-queue notes <id> <notes.json>` replaces a waiting item's notes and keeps its id and
  URL.
- **#46.** `approval-queue anchors` and the screen give a blueprint's H1 the title's bare slug, not
  `<slug>-1`. A note keyed to the old `-1` spelling still resolves.
- **#40.** `withdraw` prints `withdrew <id>` and no `proc_stat` error when the waiter is gone.
- The README documents every new command and changed behavior.

End-to-end check (the design's), run in CT on a throwaway state root and port 7994: two `page`
items queued on one test PR are both approved after a second commit lands on the PR, and a third
refuses when its own page changed. An approval made after its waiter is killed shows in `pending`
until `collect` takes it. `notes` replaces a waiting item's notes, and its URL still answers. CT
writes out every step.

### Risk class and repo

The pass is `runner` (the command every hand-over runs), as the design sets, and not
`live-account`: the only GitHub writes are one branch push and one PR. Every task is `runner`. The
repo is glw907/approval-queue, which has no adapter and no CI. Gate and full-suite home are both
`bash scripts/gate.sh` (type check, vitest, then every `tests/*.test.sh`), run locally after
`npm ci --prefix approval-queue`.

The decision path is the command's decision step (`doc_decision`, `change_decision`, `head_unmoved`,
`load_collected`, `append_log`) and `items.ts`'s readers. Task B carries it and gets a task-scope
`diff-reviewer` read beside the gate before the merge into the pass branch.

## Scope guard

Every subagent prompt carries these two samples verbatim:

> "Avoid over-engineering. Only make changes that are directly requested or clearly necessary.
> Keep solutions simple and focused: - Scope: Don't add features, refactor code, or make
> "improvements" beyond what was asked. A bug fix doesn't need surrounding code cleaned up. A
> simple feature doesn't need extra configurability. ... - Defensive coding: Don't add error
> handling, fallbacks, or validation for scenarios that can't happen. Trust internal code and
> framework guarantees. Only validate at system boundaries (user input, external APIs). -
> Abstractions: Don't create helpers, utilities, or abstractions for one-time operations. Don't
> design for hypothetical future requirements. The right amount of complexity is the minimum
> needed for the current task."
> (<https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices>)
>
> "Deliver what was asked, at the scope intended. Make routine judgment calls yourself, and check
> in only when different readings of the request would lead to materially different work. If the
> request seems mistaken or a better approach exists, say so in a sentence and continue with the
> task as asked rather than quietly narrowing, widening, or transforming it. Finish the whole
> task, and stop short of actions that are clearly beyond what was asked."
> (<https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-opus-5>)

Out of scope, from the design: backlog #37 to #39 and #41 to #43, a decision hook that runs a named
command (the design's "Later"), and everything in drafter, cairn-cms, and the workstation.

## Calls the plan makes

None changes the design's outcome or check. The contestable ones go in the PR's `## Decisions`.

1. **The page check (#48).** Today `doc_decision` runs `head_unmoved "$prhead"` on a page approve
   (`bin/.local/bin/approval-queue:1036-1041`), and `head_unmoved` refuses when `pr_head` differs
   from the queued head (626-634). The page approve instead:
   - reads the head with the existing `pr_head` (612-622);
   - reads the page's blob at that head with
     `gh api "repos/<owner/repo>/contents/<path>?ref=<head>" --jq .sha`, each path segment
     URI-encoded as `gh_file` encodes it (650-660). Probed at planning: the contents API's `sha` is
     the git blob id (`README.md` at approval-queue `origin/main` gave `1c8e182...` from both
     `gh api ... --jq .sha` and `git rev-parse <commit>:README.md`);
   - compares it with the blob queued, `item.json`'s `blob` (written at 815-819). A 404 means the
     page is gone at the head and refuses as changed. Any other `gh` failure keeps today's
     "could not read the head ... nothing was logged" exit 1, writes no `refused.json`, and so
     leaves the item in `pending` for a `collect` to retry.
   - The approve's printed `head` and its log line's `head` become the head the check read, which
     is what the README's page section already says ("An approve prints the PR head read at
     approval").
   - `load_collected` (756-758) reads no `blob` today; it gains it, so a `collect` runs the same
     check. `change_decision` keeps `head_unmoved`, since a change review covers the whole PR.
2. **The refused state (#48).** The app never shows a decided item: the item route's load answers
   404 for "an unknown or decided id" (`src/routes/item/[id=id]/+page.server.ts:43-46`). The board
   page lists only waiting items (`src/routes/+page.server.ts`, `listWaiting`), and every screen's
   rail shows "Decided this session" from `listDecided` (`src/lib/server/items.ts:241-259`, loaded
   in `src/routes/+layout.server.ts:35`, rendered in `src/routes/+layout.svelte:35-44` and
   362-371 with `OUTCOMES`). So the refusal shows there:
   - On a refusal (the page check, or `head_unmoved` in `change_decision`), the waiting command or
     `collect` writes `refused.json` in the item directory, `{"at": "<ISO 8601 UTC>", "reason":
     "<sentence>"}`, through a temp file and `mv`, before it prints the stderr line and exits 1.
     `decision.json` stays. The app never writes `refused.json`.
   - `listDecided` reads it, and its rows gain an optional `refused` holding the reason. The rail
     row's outcome reads "Refused", with the reason on a second line in the rail's existing muted
     style.
   - The reasons, fixed copy (editor register): page, "The page changed on its pull request after
     it was queued, so the approval wasn't recorded. The session will queue it again."; change,
     "The pull request moved after it was queued, so the approval wasn't recorded. The session will
     queue it again."
   - The change kind is included because `pending` (call 3) skips a refused item; without the file
     a refused change approve would sit in `pending` forever. `## Decisions` names this.
   - The rail updates on its 2-second `desk:queue` poll, so "Approved" turns to "Refused" within
     seconds of the waiter's check. `listDecided` keys on `decision.json`'s mtime, which
     `refused.json` does not change, and the held row gives way to the server's row once the post
     returns (`held.svelte.ts`'s send `finally`).
   - A later `collect` whose check passes and logs the approve removes `refused.json`, so the rail
     never shows "Refused" beside a logged approve.
3. **`approval-queue pending` (#44).** Only the waiting command and `collect` write
   `decisions.jsonl`, through `append_log` (893-905), and the app never does. A line belongs to an
   item when its `packet` is the item's id (the test at 900). `pending` prints one line per item
   that has an `item.json`, a `decision.json`, no live waiter, and no log line:
   `<id>\t<kind>\t<decision>\t<title>`, oldest id first, and exits 0 (no output when none waits).
   - A live waiter is the `pid` and `pidStart` in `item.json` passing `proc_running` (33-37).
   - It skips an item with `refused.json` (its refusal went to the command that wrote it), a
     `triage` item (a triage decision is never logged: the decision `case` sends it to the `*)`
     branch, 1102), and an item with no `pid` (queued before pids existed; a read-only probe of the
     live state found about 200 such decided items, every one long handled).
   - The same probe found three pid-bearing items it will list on its first live run:
     `20261025T002627-605959`, `20261025T003124-612124`, and `20261025T004112-619117`. They are
     batch 4's P12 page approvals, refused before `refused.json` existed and superseded by the
     requeues that morning. They are approval-queue's own stale state, so conductor-approval-queue
     clears them itself right after the pull (planning-session ruling, 2026-10-25; see "Merge order
     and hand-over" step 3).
   - `pending` is dispatched near the top of the command beside `withdraw` and `approved`, before
     any queuing setup.
4. **The quote check (#47).** `check_notes` (495-510) checks shape only, and quote anchors resolve
   only in the app: `placeNotes` calls `place()` (`src/lib/editor/notes.ts:297-305`), which takes
   the one occurrence of `prefix + quote + suffix`, else the occurrence of `quote` nearest the old
   offset (`src/lib/editor/comments.ts:61-76`). A quote is ambiguous when `prefix + quote + suffix`
   (a missing prefix or suffix reads as empty) does not occur exactly once and `quote` occurs more
   than once, since `place()` then picks among several. Occurrences are counted as `place()` counts
   them, overlapping ones included (`indexOf(x, at + 1)`), so the check and the screen cannot
   disagree. A quote that occurs nowhere is not refused (the design adds only the repeat).
   - The rule is a pure function exported from `comments.ts`, beside `place()`, so the screen's rule
     and the check share one file.
   - A new entry, `approval-queue/src/check-notes.ts`, run as `node <app>/src/check-notes.ts <file>
     <notes.json>`, reads the file with CRLF read as LF (as `src/anchors.ts` does) and prints one
     defect per ambiguous note on stderr, naming the note, the quote, how often it occurs, and the
     fix ("add a prefix or suffix that occurs once"). It exits 0 with nothing printed, 2 on a defect,
     and 1 when it cannot read a file.
   - It imports only `comments.ts` at run time, so it runs under plain `node` with no
     `node_modules`, like `check-brief.ts`. A type it needs from `notes.ts` comes in through
     `import type { Note }` only: Node's type stripping erases that form, but
     `import { type Note }` still loads `notes.ts` and fails on `github-slugger` (probed at plan
     review). This follows `anchors`'s precedent
     of running the app's TypeScript from the command (`node "$app/src/anchors.ts"`, 193-195)
     without its dependency on `node_modules`.
   - `check_notes` runs it after the jq shape check passes, on the blueprint and page kinds, against
     `<worktree>/<file>`, which `check_blueprint` has already proven equal to HEAD (581-591). The
     change kind takes no quote anchors (`notes_program`, 457), so it skips the step.
5. **`approval-queue notes` (#45 and #47).** Two forms. Unlike `pending`, they cannot dispatch
   near the top: the checks they reuse (`notes_program` at 445, `check_notes` at 498,
   `queue_change`'s unnamed-file jq at 714-721) and `$app` (189) are defined later. So `notes` is
   parsed in the argument chain (138-157) as `kind=notes`, its target id in a variable of its own,
   never in `id` or `item`, since the EXIT trap at 185 retires `$item` when it has no decision and
   would take the waiting item off the board. The form runs after `queue_change` is defined
   (after 749) and before the queue step (884), and exits there.
   - `notes --check <file> <notes.json>` (both paths as given, relative to the caller's directory)
     runs the jq shape check as a single-document item
     (`change` false) and then call 4's check against `<file>`. It exits 0 silently, or 2 with the
     same messages queueing prints.
   - `notes <id> <notes.json>` replaces a waiting item's notes. It exits 2 for an id that fails
     `id_pattern`, an id with no `item.json`, an item with a `decision.json`, a kind other than
     blueprint, page, or change, or notes that fail the item's checks. A blueprint or page runs the
     shape and quote checks against the file as the screen shows it (the worktree's HEAD copy of
     `item.json`'s `file`, else the queued `doc.md` when the worktree or file is gone, as
     `readBlueprint` falls back at `items.ts:395-400`). A change runs the change shape check and
     `queue_change`'s unnamed-file check (714-721) against `docs.json`.
   - It writes `notes.json` as `jq -c .` of the file, as queueing does (740, 813), through a temp
     file and `mv`, and prints `replaced the notes of <id> at http://127.0.0.1:<port>/item/<id>` on
     stdout, the port from `APPROVAL_QUEUE_PORT` as the queue line takes it (167-168). The id,
     `item.json`, and the waiter do not change. The item route reads `notes.json` on each load
     (`items.ts:376`, 388), so an open tab shows the new notes on its next load.
6. **The H1 slug (#46).** `sluggerFor` slugs a blueprint's front-matter `page` title before any
   heading (`src/lib/editor/notes.ts:70-79`), so an H1 that repeats the title takes `-1`
   (pinned by `src/anchors.test.ts:32-34` and `src/lib/editor/notes.test.ts:31-32`). The fix:
   the title is seeded only when the blueprint has no H1 (outside front matter and code), since an
   H1 stands for the title. A blueprint with no H1 keeps today's seed, so a `##` heading that
   repeats the title still takes `-1`, as the rendered page gives it.
   - Old keys resolve through the existing alias mechanism (`recorder`, 132-158, which today
     aliases the first version's slug): each key the title-seeded rule gives, where it differs from
     the current key, is also recorded as an alias. `recorder.enter(name, oldName)` carries one
     alias name per section today, so the scan runs a second, title-seeded slugger beside the
     current one and `enter` takes a second alias name. A current key always wins over an alias, as
     now. So `overview-1.heading` on `page: Overview` with `# Overview` resolves to the H1.
   - Edge case, named in `## Decisions`: with `# Overview` and a later `## Overview` under
     `page: Overview`, the old H1 key `overview-1` is now the `##` heading's current key and wins,
     so an old note keyed to the H1 lands on the `##` heading.
   - `src/anchors.ts`'s header comment and the README's slug paragraph (README line 134) change to
     match. The drafter plan checks drafter's own slugger separately; nothing here touches drafter.
7. **`withdraw` (#40).** `proc_stat` runs `read -r s <"/proc/$1/stat" 2>/dev/null` (25). Bash
   applies redirections left to right, so the input redirect fails before stderr is redirected and
   prints `line 25: ...: No such file or directory`. The read is grouped in braces with
   `2>/dev/null` outside them. Every `withdraw` path that exits 0 (64, 74, 81) prints
   `withdrew <id>` on stdout. `tests/lifecycle.test.sh:92` asserts an empty stdout today and
   changes, and so does the README's "`withdraw` prints nothing" (README line 96).
8. **README ownership.** Task B edits the README's `withdraw`, `collect`, and page-kind text and
   adds a `pending` section under "After a hand-over". Task T3 edits the command list (README line
   8), adds a notes section, rewrites the slug paragraph (line 134), and rewrites line 132's "A
   quote that repeats, with no context, takes its first occurrence", which queueing now refuses. Task A edits no README text; its
   commit message lists the README changes its code needs under a `README:` line, and T3 writes
   them. The command's `usage` string (8-16) gains `pending` in B and both `notes` forms in T3.
9. **Throwaway instances and the live queue.** Batch 5's drafting queues page items in the live
   queue during this pass, so:
   - Tests isolate themselves already: every shell test sets `XDG_STATE_HOME` to a `mktemp -d` root
     and stubs `curl`, `xdg-open`, `setsid`, and (where needed) `gh` on `PATH`, so none starts the
     app or reads GitHub (`tests/page-change.test.sh:38-76`), and `live_leak` fails a test whose
     ids reach the live log. New tests keep that shape; vitest touches no state root.
   - Two gate legs read state outside the worktree: `live_leak` (blueprint, packet, page-change)
     reads the live `decisions.jsonl` but greps only for the test's own ids, so batch 5's growing
     log cannot fail it; `tests/approval-queue.test.sh:255` reads the live register. A red on either
     leg reruns the gate once before it counts.
   - Only CT runs an instance: port 7994, state root `/var/home/glw907/.local/state/aq-batch4/ct`
     through `XDG_STATE_HOME`, `/var/home/glw907/.local/state/aq-batch4/bin` first on `PATH` (an
     `xdg-open` that exits 0 and CT's `gh` stub), the pass worktree's own command by absolute path
     (the `approval-queue` on `PATH` is a symlink into the live main checkout), and an explicit
     build for 7994 first (the port is baked in at build time).
   - It stops by its full path, `pkill -f '^node /var/home/glw907/Projects/approval-queue/.claude/worktrees/batch-4-friction/approval-queue/build'`,
     then checks `curl -sf http://127.0.0.1:7994/` fails. Nothing runs a generic
     `approval-queue/[b]uild` pattern, which would match the live server on 7907.
   - Nothing runs `npm ci`, `npm install`, or `npm run build` in
     `/var/home/glw907/Projects/approval-queue/approval-queue`, nothing writes under
     `/var/home/glw907/.local/state/approval-queue`, and nothing opens 7907's `/claim`.

## Names

Written out literally in every command and subagent prompt, never as shell variables:

- **Pass worktree:** `/var/home/glw907/Projects/approval-queue/.claude/worktrees/batch-4-friction`,
  branch `worktree-batch-4-friction`, the session's one `EnterWorktree`, named `batch-4-friction`.
- **STATUS:** `batch-4-friction-status.md` in
  `/var/home/glw907/Projects/approval-queue/.git/worktrees/batch-4-friction/`, beside the clock file
  `pass-task-clock`, never committed. It holds the base commit, each subagent's start and return,
  the end-to-end outputs, the PR, every overrun, and the `READY <pr> <head>` line.
- **Pair subagents:** Agent-tool subagents with `isolation: "worktree"` and descriptions
  `batch-4-friction task A` and `batch-4-friction task B`, cut from the pass branch's head.
- **Throwaway root:** `/var/home/glw907/.local/state/aq-batch4` (`bin/`, `ct/`).

## Commands

- Setup, in a fresh worktree: `npm ci --prefix <worktree>/approval-queue`.
- Gate: `cd <worktree> && cairn-run-gate 'bash scripts/gate.sh'`, with the Bash tool's timeout at
  600000, re-issued on exit 75.
- CT build: `APPROVAL_QUEUE_PORT=7994 npm run build --prefix /var/home/glw907/Projects/approval-queue/.claude/worktrees/batch-4-friction/approval-queue`.
- CT command prefix, for every CT call of the command:
  `PATH=/var/home/glw907/.local/state/aq-batch4/bin:$PATH APPROVAL_QUEUE_PORT=7994 XDG_STATE_HOME=/var/home/glw907/.local/state/aq-batch4/ct /var/home/glw907/Projects/approval-queue/.claude/worktrees/batch-4-friction/bin/.local/bin/approval-queue`.
  It serves `pending`, `collect`, `notes`, and `withdraw` as written.
- CT queue line, for page `<x>` (written out in full for each page; the environment goes before
  `setsid`, and the exit code lands in a file because `setsid -f` discards it):
  `PATH=/var/home/glw907/.local/state/aq-batch4/bin:$PATH APPROVAL_QUEUE_PORT=7994 XDG_STATE_HOME=/var/home/glw907/.local/state/aq-batch4/ct setsid -f bash -c '/var/home/glw907/Projects/approval-queue/.claude/worktrees/batch-4-friction/bin/.local/bin/approval-queue page /var/home/glw907/.local/state/aq-batch4/ct/repo "Approve the page <X>" docs/<x>.md --pr glw907/sample#7 --description /var/home/glw907/.local/state/aq-batch4/ct/description.md >/var/home/glw907/.local/state/aq-batch4/ct/<x>.out 2>/var/home/glw907/.local/state/aq-batch4/ct/<x>.err; echo $? >/var/home/glw907/.local/state/aq-batch4/ct/<x>.rc'`.
  The item id is in `<x>.err`'s `queued <id> at ...` line, the item directory is
  `/var/home/glw907/.local/state/aq-batch4/ct/approval-queue/items/<id>/`, and the waiter's pid is
  `jq -r .pid` of its `item.json`. After a form post, wait up to 30 seconds for `<x>.rc` to exist
  before asserting (the waiter polls each second, then reads the head and the blob). The
  description file follows `tests/page-change.test.sh:51`'s known-good text.
- A form post: `curl -s -X POST -H 'Origin: http://127.0.0.1:7994' -H 'x-sveltekit-action: true'
  --data-urlencode blob=<blob> http://127.0.0.1:7994/item/<id>?/approve`, or SvelteKit's CSRF check
  answers 403. The page approve takes the file's current blob as `blob`
  (`src/lib/server/blueprint.ts:148-157`) and, with no call notes, nothing else.
- CT stop: the `pkill` line in call 9, then `curl -sf http://127.0.0.1:7994/` fails.

## Tasks

### T0. Launch, worktree, baseline (10 min), by the session

Risk: `runner`, no edit.

1. One-executor checks: `pgrep -af '[w]orktrees/batch-4-friction'` prints nothing, and
   `claude agents --json` shows no other busy session under the approval-queue checkout. Then
   `EnterWorktree` with the name `batch-4-friction` from `/var/home/glw907/Projects/approval-queue`.
   Write STATUS with the base commit and arm the API-drop wake-up (`/loop` with no interval) per
   `~/.claude/docs/unattended-work-guards.md`.
2. Setup and the gate in the pass worktree. A red baseline reruns once; a second red at the same
   leg is a stop (standing answer 9).
3. Write `/var/home/glw907/.local/state/aq-batch4/bin/xdg-open` (`#!/bin/sh`, `exit 0`, mode 755).

Acceptance: the gate is green at the base and STATUS is written.

### The pair: A beside B

Each subagent runs setup in its own worktree first, works only on its files, runs the gate, commits,
and never pushes. Each prompt carries the scope guard, calls 2, 8, and 9 quoted, its own calls
quoted, and the skill files it needs by absolute path. File ownership is disjoint:

- **A:** `approval-queue/src/lib/editor/{notes.ts,notes.test.ts,comments.ts,comments.test.ts}`,
  `approval-queue/src/{anchors.ts,anchors.test.ts,check-notes.ts,check-notes.test.ts}`,
  `approval-queue/src/lib/server/{items.ts,items.test.ts}`, `approval-queue/src/routes/+layout.svelte`.
- **B:** `bin/.local/bin/approval-queue`, `tests/lifecycle.test.sh`, `tests/page-change.test.sh`,
  `README.md`.

The contracts between them are fixed in calls 2 (`refused.json`'s path, shape, and reasons) and 4
(`check-notes.ts`'s arguments, output, and exit codes); B does not call `check-notes.ts`, which T3
wires in. The session merges A, then B, into `worktree-batch-4-friction` and runs the gate.

#### A. The app side: the slug, the quote rule, and the refused row (75 min), `sonnet` at `medium`

Risk: `runner`. Outcome: calls 2 (the app half), 4 (the rule and the entry), and 6 hold.

- Call 6: `sluggerFor`'s seed rule and the title-seeded alias in `notes.ts`; `anchors.ts`'s header
  comment. Tests: the two pinned expectations change to the bare slug; a blueprint with no H1 still
  gives a repeating `##` heading `-1`; `anchors()` resolves `overview-1.heading` (and an item key
  under the H1, `overview-1.p0`) to the H1's section; a current key still wins over an alias.
- Call 4: the ambiguity rule in `comments.ts` with vitest cases (a unique quote passes, a repeated
  quote with no context fails, a repeated quote whose context occurs once passes, a repeated
  context fails, an absent quote passes). `check-notes.ts` exports the function that turns a
  document and notes into defect lines and runs it under `import.meta.main`, as `anchors.ts` does;
  `check-notes.test.ts` covers the lines for a string anchor (skipped), a clean quote, and a
  repeated one.
- Call 2, app half: `listDecided` returns `refused` from `refused.json`; `items.test.ts` covers an
  item with and without it. `+layout.svelte`'s decided list shows "Refused" and the reason.
- Loads `/var/home/glw907/.claude/skills/ts-conventions/SKILL.md` and
  `/var/home/glw907/.claude/skills/svelte-conventions/SKILL.md` before writing, and
  `/var/home/glw907/.claude/skills/daisyui/SKILL.md` if it adds a class. Runs the svelte MCP
  autofixer (`mcp__svelte__svelte-autofixer`) on `+layout.svelte`; if the tool is not available to
  the subagent, it says so and the session runs it after the merge.
- Acceptance: the gate is green; `node approval-queue/src/check-notes.ts <file> <notes.json>` exits
  0, 2, and 1 on a clean, an ambiguous, and an unreadable input, run from a worktree with
  `node_modules` moved aside to show it needs none (moved back after).

#### B. The command's decision side: the page check, refused, pending, withdraw (100 min), `sonnet` at `medium`

Risk: `runner`, decision path. Outcome: calls 1, 2 (the command half), 3, and 7 hold.

- Call 1 in `doc_decision` and `load_collected`; call 2's write on the page refusal and on
  `head_unmoved`'s refusal in `change_decision`; call 3's `pending`; call 7. `usage` gains `pending`.
- `tests/page-change.test.sh`: its `gh` stub (38-76) gains the contents `--jq .sha` answer, served
  from a file the test writes so a case can set the page's blob at the head. Cases:
  - another page's commit moves the head and the page's blob is unchanged: the approve exits 0, and
    the printed and logged `head` is the new head;
  - the page's own blob changed at the head: exit 1, nothing logged, `refused.json` holds call 2's
    page reason, and stderr names the file and the PR;
  - the page is gone at the head (404): refused the same way;
  - `gh` cannot answer: exit 1, nothing logged, no `refused.json`;
  - a queue whose head read lagged (queued at an old head, the head then catches up with the page's
    blob unchanged): the approve exits 0;
  - `collect` of an unlogged page approve runs the same check, both ways;
  - a change approve whose PR moved writes `refused.json` with the change reason.
  The existing page cases that assert a moved head refuses are rewritten to the blob rule.
- `tests/lifecycle.test.sh`: `withdraw` of a dead pid prints `withdrew <id>` on stdout and nothing
  on stderr (line 92's empty-stdout assertion changes). `pending` lists a decided item with a dead
  pid and no log line, and skips each of: a live waiter, a logged decision, `refused.json`, a
  triage item, a pidless item, and an undecided item. After `collect`, `pending` prints nothing.
- README: call 8's B parts, `pending`'s contract and its skips, the refused state, and the page
  approve's blob rule.
- After the gate, the session runs a task-scope `diff-reviewer` on B's commits against calls 1 to 3
  and 7; a `fix` is fixed and read again before the merge.
- Acceptance: the gate is green; `tests/packet.test.sh` passes unchanged.

### T3. The command's notes side: `notes --check`, `notes <id>`, the queue-time quote check (70 min), by the session or a `sonnet` subagent

Risk: `runner`. Outcome: calls 4 (the wiring) and 5 hold, and the README is whole.

- `check_notes` runs `check-notes.ts` for the blueprint and page kinds (call 4). The two `notes`
  forms (call 5). `usage` gains both.
- `tests/blueprint.test.sh`: `notes --check` exits 0 on clean notes, 2 on a shape defect and on a
  repeated quote (message names the note and the quote), and 2 on a missing file; queueing a
  blueprint with the repeated quote exits 2 with the same line and queues nothing; `notes <id>`
  replaces a waiting blueprint's `notes.json` (compared with `jq -c`) and keeps `item.json`
  byte-for-byte; it refuses a bad id, an unknown id, a decided item, and bad notes, leaving
  `notes.json` unchanged. `tests/page-change.test.sh`: `notes <id>` on a change item refuses a note
  whose `file` the change does not carry and accepts one it does.
- README: the command list, a notes section (both forms, the quote rule, what an open tab sees),
  and the slug paragraph from A's `README:` line.
- Acceptance: the gate is green.

### CT. The end-to-end check, the close review, and PR-ready (80 min), by the session

Risk: `runner`.

1. **The end-to-end check**, with the "Commands" lines written out in full. Build for 7994.
   Write `/var/home/glw907/.local/state/aq-batch4/bin/gh`: it reads the head from
   `/var/home/glw907/.local/state/aq-batch4/ct/head`, answers `pr view 7 -R glw907/sample --json
   headRefOid` with it, answers B's contents query with `git -C
   /var/home/glw907/.local/state/aq-batch4/ct/repo rev-parse <ref>:<path>` (a missing path prints a
   404 message and exits 1), and exits 1 on anything else. Make the repo
   `/var/home/glw907/.local/state/aq-batch4/ct/repo`: `git init`, origin
   `https://github.com/glw907/sample.git` (the page form's origin check, 598-609), and five
   synthetic pages `docs/a.md` to `docs/e.md` committed, each with two `##` sections, `docs/e.md`
   holding one line twice. Write the head file from `git rev-parse HEAD`. A `--description` file
   with a background and a summary paragraph serves every page.
   1. Queue pages a, b, and c on `glw907/sample#7`.
   2. Commit an edit to `docs/c.md` only and write the new head (the second commit on the PR).
   3. Approve a, b, and c by form post, each with `git rev-parse HEAD:docs/<x>.md` as `blob`.
      a's and b's commands exit 0 and print approves whose `head` is the new head, and
      `decisions.jsonl` gains their two lines. c's command exits 1 with nothing logged, its
      `refused.json` holds the page reason, and `curl -sf http://127.0.0.1:7994/` holds "Refused"
      and the reason under "Decided this session".
   4. Queue d, `kill -KILL` the pid in d's `item.json`, and approve d by form post. `pending` prints d's line and
      not c's. `collect <d>` prints the approve and logs one line. `pending` then prints nothing.
   5. Write `ok.json` (one `info` note with a string anchor), `bad.json` (a quote of e's repeated
      line), and `new.json` (one `info` note with another title), all in
      `/var/home/glw907/.local/state/aq-batch4/ct/`. `notes --check
      /var/home/glw907/.local/state/aq-batch4/ct/repo/docs/e.md
      /var/home/glw907/.local/state/aq-batch4/ct/bad.json` exits 2 naming the quote; queueing e with
      `--notes` and `bad.json` exits 2 with the same line. Queue e with `ok.json`; `notes <e>
      /var/home/glw907/.local/state/aq-batch4/ct/new.json` exits 0 and prints e's URL; `jq -c .` of
      the item directory's `notes.json` equals `jq -c .` of `new.json`; `curl -sf
      http://127.0.0.1:7994/item/<e>` answers 200 and its HTML holds `new.json`'s title. `withdraw <e>` prints `withdrew <e>`.
   6. Stop the instance (call 9). Record every printed JSON and exit code in STATUS.
   A step still red after the fix chain falls under standing answer 7.
2. **BACKLOG.md:** tick #40 and #44 to #48 with the PR number.
3. **The close review:** `diff-reviewer` at whole-branch scope against the design and this plan,
   beside `svelte-reviewer` and `daisyui-a11y-reviewer` (the rail row). One batched fix chain that
   quotes each finding verbatim (location, finding, fix) as its acceptance, then the gate again. A
   second review only on a blocker.
4. **The PR:** push `worktree-batch-4-friction` to glw907/approval-queue and open the PR. Its body
   opens with `## Brief` per `~/.claude/docs/voice/approval-brief.md`, then what landed, the
   end-to-end outputs, the review verdicts, `## Decisions` (at least: the blob check's
   `gh api ... --jq .sha` read, the head printed at approval, the change kind's refused file, the
   rail as the refused state's surface, `pending`'s three skips, the H1 seed rule, the quote rule's
   reading of "more than once", and the `withdraw` stdout line), `## Planning misses`, the score,
   any `gate-failed` item, and each "Found, not done" item filed through `log-issue` in
   approval-queue's `BACKLOG.md` with its number. That list includes at least: an item the command
   refuses as a tool failure (a page whose worktree was removed, a packet decision that does not
   match its packet) gets no `refused.json`, so it stays in `pending`, and `withdraw` refuses a
   decided item.
5. Mark the PR ready, write `READY <pr> <head>` in STATUS, and send conductor-approval-queue one
   message with the PR, its head, the end-to-end result, the review verdicts, every clock overrun,
   and every departure from the plan. The executor never runs `approval-queue packet` and never
   merges.

## Path

The longest chain run in sequence, a pair counting once at its larger estimate:

T0 10 + pair (A 75, B 100) 100 + T3 70 + CT 80 = 260 path minutes. CT is 80: the end-to-end
script and its stub 30, the review and fix chain 35, the PR 15. The task sum is 335.

Clock: `pass-task-clock` in `/var/home/glw907/Projects/approval-queue/.git/worktrees/batch-4-friction`
holds the session's own task. When a pair subagent returns, the session checks its minutes against
twice its estimate.

## Models

- Executor: session `approval-queue-batch-4-friction` on `sonnet` at `medium`.
- A and B: Agent-tool subagents on `sonnet` at `medium`. No task is upshifted to Opus: every
  mechanism is specified here by quoted source, and B's decision-path change gets a task-scope
  `diff-reviewer` read.
- Reviewers: `diff-reviewer`, `svelte-reviewer`, and `daisyui-a11y-reviewer` from their
  frontmatter.
- Conductor: `conductor-approval-queue` on `claude-opus-5-5` at `medium`.

A headless agent cannot read `~/.claude/skills`, so every subagent prompt names each skill file by
absolute path.

## Standing answers

From the design, applied in place of stopping:

1. **Path ceiling.** A plan up to 1000 path minutes launches without Geoff. A clock stop writes its
   minutes to STATUS, rewrites the clock file's `start=` to now, runs no `notify-send`, and carries
   on while the actual path stays under 1000. Past 1000 the executor stops (answer 9).
2. **No API credit.** The pass makes no Claude API call: no `make smoke`, no drafter run, and the
   end-to-end check makes no batch call. Every test and the end-to-end check stub `gh`; the only
   real GitHub calls are the push and the PR.
3. **The live queue restart.** The live approval queue is pulled, rebuilt, and restarted only when
   no item is waiting. Until then the conductor says so (see "Merge order and hand-over" for the
   check and the retry).
4. **Smaller forms.** A review finding that a form approved here could satisfy with a smaller
   change takes that change and lists it in `## Decisions`. Only a finding that needs a different
   form stops.
5. **Other repos.** A cairn-cms or workstation follow-up goes to that repo's `BACKLOG.md` through
   `log-issue`, never into its tree.

Plus the stops this plan writes, each with its answer:

6. **Returning causes.** A cause that returns after its fix gets one structural fix, then escalates
   in the PR body. Escalation is allowed for #46's alias (fallback: ship the seed rule without the
   alias and name the gap), the rail's reason line (fallback: the outcome word alone), and the
   `withdraw` stdout line. It is not allowed for the page check, the refused file, `pending`, or the
   two notes forms: if one still fails after its structural fix, the remaining tasks and the close
   still run, the PR reports the item unmet in its Brief, and the conductor's packet raises it as a
   `gate-failed` ask.
7. **Red end-to-end step.** A step still red after CT's fix chain is a `gate-failed` item in the PR
   and a forced ask in the packet. The PR still goes ready.
8. **A send-back.** Geoff's note is fixed forward: the conductor messages the executor with it,
   quoted with its source.
9. **Any other stop** (a red baseline, the path ceiling, a cause the session cannot trace): remove
   the clock file, write the one question into STATUS, and send conductor-approval-queue one
   message. The conductor asks Geoff once, commits the ruling to this plan on a branch, and
   relaunches the executor with the same name. The executor never runs `notify-send` or asks Geoff.
10. **A busy repo at launch.** A live session working the approval-queue checkout holds the launch;
    the conductor asks that session once and launches when it is idle or answers that it is not
    working the repo.
11. **A pair merge conflict.** Ownership is disjoint, so a conflict means a subagent edited outside
    its files: the session reverts the stray file to the pass branch, keeps the owner's version,
    reruns the gate, and records it in `## Decisions`.
12. **No conductor-drafter at merge time.** The drafter pass may have closed. If `claude agents
    --json` lists no `conductor-drafter`, step 3's message and the `pending` output go into the
    conductor's final message to Geoff instead.
13. **A P12 id that will not clear.** If a `collect` in step 3 fails as a tool failure (a worktree
    gone, `gh` unable to answer), so the id still shows in `pending`, the conductor names the id and
    the `collect` stderr in its final message to Geoff and goes on; the restart does not wait on it.

## Close

The conductor sends one packet, initiative `docs-system`, with glw907/approval-queue#n as its one
part, checked first with `approval-queue packet --check docs-system <file>`.

- **Rows and asks.** The part is a routine row whose Why carries the PR's `## Decisions` lines and
  the end-to-end outputs in brief. Only forced asks appear: a `gate-failed` item, a review `fix` or
  `escalate` left open, or a red end-to-end step.
- **`## If you approve`** lists the merge, the pull, the conductor's clearing of the three
  pre-pass P12 items with `collect` (call 3), the restart under standing answer 3, and the
  conductor-drafter message, then:
  - `[you: reload the queue tab]`: an open tab keeps the old client until it reloads.
  - `[you: other workstation]`: on the other host, once no item waits in that host's queue, pull
    `~/Projects/approval-queue`, then `npm run build` in its `approval-queue/` (`npm ci` first only
    if `package-lock.json` changed), then
    stop its server by its exact path (the next `approval-queue` call starts it).
- **`## Not checked`**: a real GitHub head lag (the stub stands in).

## Merge order and hand-over

One PR. On the packet's approve, the conductor, from `/var/home/glw907/Projects/approval-queue`:

1. Record the pre-merge head, `git -C /var/home/glw907/Projects/approval-queue rev-parse HEAD`,
   then `gh pr merge <n> -R glw907/approval-queue --merge --match-head-commit <head>`, with
   `<head>` from the decision.
2. `git -C /var/home/glw907/Projects/approval-queue pull --ff-only` at once, under pass-core
   "Close"'s checkout rule. The command is live from then on: `~/.local/bin/approval-queue` is a
   symlink into this checkout (`scripts/install.sh`). A waiter already running keeps the copy it
   started with, since a fast-forward replaces the file with a new inode and bash keeps reading the
   old one (probed at planning: a running script printed its old lines after `git merge --ff-only`
   swapped it). The app keeps serving the old build until step 4.
3. Clear the three pre-pass P12 items (call 3) with the live command, now the merged one, one
   command each: `approval-queue collect 20261025T002627-605959`, `approval-queue collect
   20261025T003124-612124`, and `approval-queue collect 20261025T004112-619117`. Each is decided,
   so each returns at once; with the merged code its blob check either logs the approve (exit 0)
   or writes `refused.json` (exit 1, the refusal on stderr). Either outcome clears it. Record each
   exit code and printed line for the final message. Then run `approval-queue pending` and confirm
   it prints none of the three; an id still listed falls under standing answer 13.
   Then message conductor-drafter one line: the batch 4 friction pass has merged;
   `approval-queue pending` and both `notes` forms exist (the drafter skill's `pending` line now
   works); a page approve checks the page's blob, not the PR head; a blueprint's H1 anchor is the
   bare slug, with old `-1` keys still resolving. Add any items `pending` still lists, with their
   ids, kinds, and titles, and whether the restart is done or waiting. With no `conductor-drafter`
   listed, standing answer 12 applies.
4. **The restart (standing answer 3).** Restart only when both of these print nothing:
   - `shopt -s nullglob; for f in /var/home/glw907/.local/state/approval-queue/items/*/item.json; do [ -e "${f%/item.json}/decision.json" ] || echo "$f"; done`
     (a waiting item, deferred ones included, as `listWaiting` counts them, `items.ts:225-238`);
   - `pgrep -af '[a]pproval-queue (pr|design|triage|packet|blueprint|page|change|collect) '`
     (a live waiter or `collect`).
   While either prints, re-check every 10 minutes with a Monitor `until` loop at a 1800000 ms
   timeout, re-armed on every deadline notice; a deadline is never a stop. The first hold is
   reported in step 3's message and in the final message to Geoff, naming the waiting ids. Once
   both print nothing:
   1. Record the live server's pid: `pgrep -f '^node /var/home/glw907/Projects/approval-queue/approval-queue/build'`.
   2. Run the restart under the command's own start lock, so a queue that starts in the window
      waits for it instead of starting a server of its own (the command takes the same lock around
      its start, 841-881). `flock -o` keeps the lock out of the new server's file descriptors, as
      the command's `9>&-` does (probed: the lock is held while the command runs and free after,
      with a `setsid -f` child alive). `npm ci` runs only when the merge changed
      `approval-queue/package-lock.json`: this pass adds no dependency, and `npm ci` would delete
      the `node_modules` that `approval-queue anchors` and the running server's unloaded chunks
      need. The new server starts only after the build succeeds and the old one has stopped
      answering, so a failed build leaves the old server serving and a slow shutdown cannot win the
      port. `<pre-merge head>` is step 1's:

      `flock -o /var/home/glw907/.local/state/approval-queue/start.lock -c '{ git -C /var/home/glw907/Projects/approval-queue diff --quiet <pre-merge head> HEAD -- approval-queue/package-lock.json || npm ci --prefix /var/home/glw907/Projects/approval-queue/approval-queue; } && npm run build --prefix /var/home/glw907/Projects/approval-queue/approval-queue && { pkill -f "^node /var/home/glw907/Projects/approval-queue/approval-queue/build" || true; } && until ! curl -sf http://127.0.0.1:7907/ >/dev/null; do sleep 0.2; done && HOST=127.0.0.1 PORT=7907 APPROVAL_QUEUE_STATE=/var/home/glw907/.local/state/approval-queue setsid -f node /var/home/glw907/Projects/approval-queue/approval-queue/build >>/var/home/glw907/.local/state/approval-queue/server.log 2>&1'`

   3. The restart counts as done only when the `flock` line exits 0, `curl -sf
      http://127.0.0.1:7907/` answers within 10 seconds, and the `pgrep` line of sub-step 1 now
      prints a different pid. A non-zero exit or the old pid means the old build still serves:
      read `server.log`, fix the traced cause, and run the line again; a cause it cannot trace is
      standing answer 9's stop.

   Restart only by these exact paths. A hold that outlasts 24 hours sends Geoff one message naming
   the waiting ids and the lines above, and the conductor ends with the restart left to them.
5. Remove `/var/home/glw907/.local/state/aq-batch4` once `pgrep -af '[w]orktrees/batch-4-friction'`
   prints nothing.
6. **Hand-over.** approval-queue keeps no STATUS file (its `docs/` holds only `decision-review/`,
   and `BACKLOG.md` is its tracker, ticked in the PR), so the conductor reports in the packet and
   in one short message to Geoff: what landed, the restart's state, and that the other workstation
   needs its pull and rebuild. Then it ends as pass-core "Conductor" says.

## Later

- A decision hook that runs a named command on approve, if `pending` goes unread (the design's
  "Later").
- Backlog #41: a `collect` beside a `withdraw` in the same instant.
