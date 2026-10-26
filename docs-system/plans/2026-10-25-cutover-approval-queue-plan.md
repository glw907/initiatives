# Docs-as-code cutover: the Approval Queue's `docs` review

Initiative: docs-system

Design: `~/Projects/initiatives/docs-system/specs/2026-10-25-docs-as-code-cutover-design.md`,
"The Approval Queue", approved by Geoff 2026-10-25 (Approval Queue item 20261025T215556-1865163).
Interface: `~/Projects/initiatives/docs-system/plans/2026-10-25-cutover-contract.md`, the
contract. Where this plan and the contract differ, the contract wins.

Executor: `approval-queue-docs-cutover`, `sonnet` at `medium`, under `conductor-approval-queue`.
Repo: glw907/approval-queue, checkout `/var/home/glw907/Projects/approval-queue`, worktree
`.claude/worktrees/docs-cutover`, branch `worktree-docs-cutover`. Risk class `runner`, with the
`live-account` flag: one scratch PR on glw907/approval-queue for the end-to-end check.

Path estimate: 405 path minutes against the design's 400. The arithmetic is under "Path".

Read at approval-queue `4f1e833` (main, clean, level with `origin/main`). Line numbers below are at
that commit; find each symbol by name.

## Pre-flight

Empty: nothing for Geoff. The conductor checks these before launch:

- The checkout is on `main`, `git status --porcelain` prints nothing, and `git rev-list --count
  HEAD..origin/main` prints 0 after `git fetch origin`; `git check-ignore -q .claude/worktrees/x`
  exits 0.
- No live session other than the conductor and the planning session `approval-queue-fd` works
  the repo (`claude agents --json`, rows whose `cwd` is under the checkout).
- No waiting item of a removed kind: no `items/*/item.json` under
  `/var/home/glw907/.local/state/approval-queue` with `kind` `blueprint`, `page`, or `change` and
  no `decision.json` (none at planning time).
- `node`, `npm`, `jq`, `gh`, `flock`, `cairn-run-gate` resolve, `gh auth status` answers, and port
  7995 is free (`curl -sf http://127.0.0.1:7995/` fails).
- `mkdir -p /var/home/glw907/.local/state/aq-docs-cutover` has run.
- The contract, this plan, and its prompt are on initiatives `main`.

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

Extras go in the PR's "Found, not done", never into the build.

## Outcome

The contract, built: one `docs` kind, written as if the queue had always been a docs-as-code
review, in place of `blueprint`, `page`, `change`, `anchors`, and `approved`. Ruling 8 is the bar:
no name, branch, type, fixture, comment, compat shim, or README line serves a removed kind.
Packets, `pr`, `design`, and `triage` behave as before.

## Calls the plan makes

1. **Kinds.** `ItemMeta.kind` is `'pr' | 'design' | 'triage' | 'packet' | 'docs'`. `readItem` and
   `listWaiting` and the decided list return null or skip any other kind, which is how the stored
   decided items of removed kinds stay on disk unlisted (ruling 16). `pending` and `collect` skip
   them the same way (`collect` exits 2: "<id> is a <kind> item, which this queue no longer
   reads").
2. **The editor stays, renamed for its purpose.** The save-by-commit code
   (`src/lib/server/blueprint.ts` `commitText`, `queued`, `queuedItem`), the CodeMirror editor and
   merge view (`src/lib/editor/setup.ts`), the margin, note, and comment cards, and the comment
   store carry over into the `docs` screen. A file or symbol named for a removed kind is renamed
   for what it does (`server/blueprint.ts` becomes `server/docs.ts`; `buildBlueprintApprove`
   becomes `buildDocsApprove`). Code that only a removed kind used goes: named anchors and the
   slugger (`notes.ts`'s slug rule, `anchors.ts`), `waived`, a choice's `text`
   and `edit`, `seed-blueprint.ts`, `fixtures/change/`, `BlueprintView`, `PageView`, `ChangeView`.
   `github-slugger` and `decode-named-character-reference` leave `package.json` if nothing else
   imports them (a removal, so `dependency-upgrade` does not apply).
3. **The quote check's entry.** `node approval-queue/src/check-notes.ts <dir> <notes.json>`: each
   note's `file` resolves under `<dir>`. Exit 0 with no output when every quote is unambiguous; 2
   with one line per defect (`note N1 (docs/x.md): the quote "..." occurs 3 times`) when not; 1 when
   a file cannot be read. The command calls it with the worktree for `notes --check`, and with a
   temporary directory holding each page as the screen shows it for queueing and `notes <id>`.
4. **The screen's posts.** The item route's actions for a `docs` item: `save` (`file`, `blob`,
   `text`; 409 when the file's blob at HEAD is not `blob`), the comment ops (`file` names the page,
   `blob` is its blob), `approve` (`blob:<path>` per page, `call:<id>` per call), `sendback`
   (`note`, optional `call:<id>`), `defer`. One writer per file and one per item, as now.
5. **The code diff** is `diff.patch` with each changed page's file section removed; the screen
   shows it with the existing `FilesDiff` component, above the pages.
6. **The live queue is untouched.** Never run `npm ci`, `npm install`, or `npm run build` in
   `/var/home/glw907/Projects/approval-queue/approval-queue`; never write under
   `/var/home/glw907/.local/state/approval-queue` (the end-to-end check copies one item out of it,
   read-only); never run the `approval-queue` on PATH; never signal a process by pattern except the
   end-to-end check's stop of the build it started, by full path. Tests keep their `mktemp` roots and
   stubbed `gh`, `curl`, `xdg-open`, and `setsid`. On 2026-10-25 a probe's `pkill -f 'drafter page'`
   killed a live run.
7. **The repo is public.** Fixtures are synthetic. No key, account detail, or private path goes in
   a commit, fixture, or PR body.

## Names

- Throwaway root: `/var/home/glw907/.local/state/aq-docs-cutover` (`bin/`, `ct/`).
- End-to-end state: `XDG_STATE_HOME=/var/home/glw907/.local/state/aq-docs-cutover/ct/state`, so
  the command's root is `.../ct/state/approval-queue`. Port `APPROVAL_QUEUE_PORT=7995`.
- The worktree's command: `bash
  /var/home/glw907/Projects/approval-queue/.claude/worktrees/docs-cutover/bin/.local/bin/approval-queue`
  (written `AQ` below; always typed out in full).
- STATUS: `docs-cutover-status.md` in the worktree's git dir
  (`/var/home/glw907/Projects/approval-queue/.git/worktrees/docs-cutover/`), never committed,
  beside `pass-task-clock`.

## Tasks

### T0. Launch, worktree, baseline (15 min), by the session

Risk: `runner`, no edit.

1. One-executor checks: `pgrep -af '[/]Projects/approval-queue/.claude/worktrees/docs-cutover'`
   prints nothing, and `claude agents --json` shows no busy session in the checkout other than this
   session's own row (match it by name), the conductor, and `approval-queue-fd`.
   `EnterWorktree` with the name `docs-cutover`. Write STATUS (base commit, session name and id).
   Arm the API-drop wake-up (`/loop` with no interval) per
   `~/.claude/docs/unattended-work-guards.md`. pavilion has no lid, so no lid hold.
2. `npm ci --prefix approval-queue`, then the gate: `cairn-run-gate 'bash scripts/gate.sh'`, Bash
   timeout 600000, re-issued on exit 75 until it prints `gate exit:`.
3. Write `/var/home/glw907/.local/state/aq-docs-cutover/bin/xdg-open` (`#!/bin/sh`, `exit 0`, mode
   755).

Acceptance: the gate is green at the base; STATUS is written. A red baseline reruns once; a second
red at the same leg is a stop (standing answer 7).

### The pair: A beside B

Each subagent runs `npm ci --prefix approval-queue` in its own worktree first, works only on its
files, runs the gate, commits, and never pushes. Each prompt carries the scope guard, calls 1, 6,
and 7 quoted, its own calls quoted, the contract's path, and each skill file by absolute path
(`/var/home/glw907/.claude/skills/ts-conventions/SKILL.md`,
`/var/home/glw907/.claude/skills/svelte-conventions/SKILL.md`), since a headless agent cannot load
`~/.claude/skills`. Descriptions: `docs-cutover task A`, `docs-cutover task B`.

File ownership:

- **A:** `bin/.local/bin/approval-queue`, `tests/*.sh`, `tests/fixtures/**`.
- **B:** `approval-queue/src/lib/server/**`, `approval-queue/src/routes/item/**`,
  `approval-queue/src/lib/editor/{notes,comments}.ts` and their tests,
  `approval-queue/src/{check-notes,check-brief,anchors}.ts` and their tests,
  `approval-queue/src/lib/fixtures/**`, `approval-queue/package.json`,
  `approval-queue/package-lock.json`.

They meet at the contract's "Between the command and the app" and call 3. The session merges A,
then B, and runs the gate.

#### A. The command: queue, decide, revise, and the helper forms (120 min), `sonnet` at `medium`

Risk: `runner`, decision path. Outcome: the contract's "The command", "The decision", "The approve
refusal", "Revision", "Amend", and "The other commands" hold in `bin/.local/bin/approval-queue`, and the
removed commands are gone.

- Parse `docs` (the usage text lists it and drops the removed forms). Queue: the refusals table in
  contract order; `check_origin` and `pr_head` carry over; the changed pages from the merge base
  and head as the contract says, read with local git; the item directory, `item.json` last, under
  the queue lock with the waiting-item check. `waiting_item` matches `docs` items by
  `"\(.repo)#\(.number)"`.
- Decide: the approve reads the PR head (`head_unmoved`, writing `refused.json` with the contract's
  reason); print and log the contract's shapes; `collect` reloads a `docs` item in
  `load_collected`. Revision: the lookup over `{ref, kind: "docs"}`, `revises.commit` from the
  latest counting reject line, then `since.patch` or `since.json`. Amend: `amend_of` reads the
  latest `docs` line for the ref and, when it is an approve, returns its `commit`; the item gets
  `amends` and `approved.patch` or `approved.json`.
- `notes --check <worktree> <notes.json>` and `notes <id> <notes.json>` per the contract and
  call 3; the notes shape (`notes_program`) and replies shape (`replies_program`) as the contract
  sets them, `file` required on both.
- Remove: `blueprint`, `page`, `change`, `anchors`, `approved`, and every helper only they used
  (`check_blueprint`, `check_description`'s blueprint wording, `doc_kind`, `gh_file`,
  `changed_paths` if unused, `page_blob_at`, `page_unchanged`, `doc_decision`,
  `change_decision`, `queue_change`, `change_notes`). `pending` and `collect` per call 1.
- Tests: delete `tests/blueprint.test.sh` and `tests/page-change.test.sh`; add
  `tests/docs.test.sh` with a `gh` stub serving a synthetic repo (its `origin`
  `https://github.com/glw907/sample.git`, two pages under `docs/`, one under `docs/internal/`, one
  code file). Cases: each refusal row (exit code and message); a queued item's directory and
  `item.json`; an approve at an unmoved head prints and logs the contract's shape with `commit`
  after a simulated review edit commit; a moved head refuses with `refused.json` and nothing
  logged; a `gh` failure at approval exits 1 with no `refused.json`; a send-back then a resend gives
  `revises` with revision 2 and a `since.patch` holding only the fix; a rebased branch gives
  `since.json`; a queue after a logged approve gives `amends` and an `approved.patch` holding only
  the post-approve fix, and no `revises`; `notes --check` and `notes <id>` pass and refuse as the contract says; `collect`
  through `tests/collect-check.sh`; `pending` lists an orphaned `docs` decision and skips a decided
  `page` item; each removed command exits 2 with the usage. `tests/lifecycle.test.sh` and
  `tests/approval-queue.test.sh` lose their removed-kind cases and keep the rest.
- After the gate, the session runs a task-scope `diff-reviewer` on A's commits against the
  contract's sections above; a `fix` is fixed and read again before the merge.
- Acceptance: the gate is green; `grep -n -E 'blueprint|anchors|approved|\bchange\b'
  bin/.local/bin/approval-queue` prints only lines that use the words in their plain sense or
  serve the amend review (the session reads each).

#### B. The app's server side (120 min), `sonnet` at `medium`

Risk: `runner`. Outcome: the app reads, saves, comments on, and decides a `docs` item per the
contract's "Between the command and the app" and calls 1 to 4, and nothing in the server serves a
removed kind.

- `items.ts`: the kinds of call 1; `DocsContent` (title, description, PR meta and body, the code
  diff, `pages` each with `path`, `from?`, `base`, the current text, blob, and commit from the
  worktree's HEAD, or the queued copy and `missing: true` when the worktree or file is gone;
  notes; replies; `revises` with the since diff; `amends` with the approved diff); the decided list's `refused` reason.
- `server/docs.ts` (from `blueprint.ts`): `commitText` and the queues unchanged in behavior;
  `buildDocsApprove` (every page clean and its posted blob at HEAD, every call answered, `commit`
  from the worktree); `sentBackCalls`.
- The item route's `load` and actions per call 4; the comment anchor takes `file` and the page's
  HEAD text.
- `notes.ts`: quote anchors placed per the contract, one list per page; no slug code.
  `comments.ts`: `file` required on an anchor. `check-notes.ts` per call 3, with tests.
  `check-brief.ts`'s header names the kinds it checks (`pr`, `design`, `triage`, `packet`,
  `description`).
- Fixtures: a synthetic `docs` item (two pages, a note of each kind, a comment, a reply) for the
  route and item tests, replacing `seed-blueprint.ts` and `fixtures/change/`.
- Tests: `items.test.ts`, `page.server.test.ts` (the route), `notes.test.ts`, `comments.test.ts`,
  `check-notes.test.ts`: a save commits one page and refuses a stale blob (409); an approve refuses
  an uncommitted page, a stale blob, and an open call, and writes the contract's `decision.json`
  otherwise; a send-back writes `commit`; a comment anchors into the named page; a decided `page`
  item reads as null.
- Acceptance: the gate is green (the UI still compiles: B leaves the Svelte files to T2 and keeps
  `svelte-check` green by deleting the removed views' imports where it must, noting each in its
  report).

### T2. The `docs` screen (120 min), by a `sonnet` subagent at `medium` after the pair merges

Risk: `runner`. Description `docs-cutover task T2`. Outcome: the contract's "The screen", as a
first-class view, on the Survey theme the app already uses.

- `DocsView.svelte` (new): title and description, the revision line and since diff (or, on an
  amend, the "Since you approved" diff), the PR row
  (number, branch, checks) and body, the code diff (call 5), then one editor per changed page
  (`DocEditor` in its merge view against `base`, with its margin of notes, comments, and replies).
  Approve locks until every call is answered and every page saved.
- `ItemPanel`, `keys.ts`, `held.svelte.ts`, `desk.svelte.ts`, `FrameHeader`, `+layout.svelte`,
  `routes/+page.svelte` and `+page.server.ts`: the `docs` kind where the removed kinds were;
  delete `BlueprintView`, `PageView`, `ChangeView`, and every branch for them.
- The prompt names `/var/home/glw907/.claude/skills/svelte-conventions/SKILL.md`,
  `/var/home/glw907/.claude/skills/ts-conventions/SKILL.md`, and
  `/var/home/glw907/.claude/skills/daisyui/SKILL.md`, and the README's "Home-grown parts" rule
  (stock DaisyUI class first). It runs the svelte MCP autofixer (`mcp__svelte__svelte-autofixer`)
  on each changed `.svelte` file; if the tool is missing it says so and the session runs it.
- Tests: `review.svelte.test.ts` and `held.svelte.test.ts` cover two pages saving independently
  and the approve lock.
- Acceptance: the gate is green; `grep -rn -i -E 'blueprint|PageView|ChangeView|amend|waived|slug'
  approval-queue/src` prints nothing the session cannot justify in plain sense or as the amend
  review.

### T3. README, BACKLOG, and the residue sweep (30 min), by the session

Risk: `runner`.

- README: the command list and the kinds as they now are; one "The docs kind" section built from
  the contract (command, refusals, notes, replies, the screen, the decision, revision, the approve
  refusal, the amend review, the helper forms); "Comments and replies" and "After a hand-over" read for `docs`; the
  blueprint, page, change, `approved`, and anchors sections gone (the amend review is rewritten
  for `docs`).
- `BACKLOG.md`: each open item that only a removed kind had (#53, and any other the session finds)
  is ticked `[x]` with "Dropped: the docs-as-code cutover (PR #n) removed the kind." Done items stay.
- The residue grep: `git grep -n -i -E
  'blueprint|\bpage kind|change kind|anchors|approved|waived|fact|drafter|slug|\.yaml' --
  . ':!BACKLOG.md'`; fix each hit that names or serves a removed kind.
- Acceptance: the gate is green; the grep's remaining hits are listed in STATUS with why each is
  plain sense.

### T4. The end-to-end check (60 min), by the session

Risk: `runner`, `live-account`. Every command below is typed out with full paths; `AQ` stands for
the worktree's command. Every `AQ` call runs with `PATH=/var/home/glw907/.local/state/aq-docs-cutover/bin:$PATH
XDG_STATE_HOME=/var/home/glw907/.local/state/aq-docs-cutover/ct/state APPROVAL_QUEUE_PORT=7995`,
and a queuing call runs under `setsid -f` with stdout to a file in `.../ct/`. Browser steps use the
Playwright MCP tools (`mcp__playwright__*`) against `http://127.0.0.1:7995`.

1. Build for 7995: `cd /var/home/glw907/Projects/approval-queue/.claude/worktrees/docs-cutover/approval-queue && APPROVAL_QUEUE_PORT=7995 npm run build`.
2. **A stored item of a removed kind.** `mkdir -p .../ct/state/approval-queue/items` and `cp -a
   /var/home/glw907/.local/state/approval-queue/items/20261025T212225-1831472` into it (a decided
   `page` item). After the first queue below starts the app: the board's HTML (`curl -sf
   http://127.0.0.1:7995/`) does not hold that id or its title, `curl -s -o /dev/null -w '%{http_code}'
   http://127.0.0.1:7995/item/20261025T212225-1831472` prints 404, and `AQ pending` prints nothing
   for it.
3. **The scratch PR.** `gh repo clone glw907/approval-queue .../ct/clone`; in it, branch
   `scratch-docs-review-e2e` from `origin/main`, add `docs/scratch/first.md` and
   `docs/scratch/second.md` (each a heading and three short synthetic paragraphs) and a code change
   (`scripts/scratch-e2e.sh`, a two-line script), commit, push, and `gh pr create -R
   glw907/approval-queue --draft --title "Scratch: docs review end-to-end check" --body-file
   /var/home/glw907/Projects/approval-queue/.claude/worktrees/docs-cutover/tests/fixtures/e2e-brief.md`.
   Clone again to `.../ct/mover` for step 7.
4. **Queue and edit.** Write a description file (a background paragraph and a summary paragraph)
   and a notes file with one `info` note quoting a sentence of `first.md`. Queue `AQ docs
   .../ct/clone glw907/approval-queue#<n> "Scratch docs review" --description <file> --notes
   <file>`. In the browser: open the item; the PR body, the code diff (holding
   `scripts/scratch-e2e.sh` and neither page), and both pages show. Type a word into
   `second.md`, wait 2 s; `git -C .../ct/clone log -1 --format=%s` prints `Edit
   docs/scratch/second.md in review`. Select a phrase in `first.md`, comment "Tighten this.", Save.
5. **Send back.** Send back with the note "Scratch send-back.", move the mouse off the toast, then poll for the decision file for up to 60 s (the hold pauses under pointer or focus, `held.svelte.ts:110`). The command's file holds
   `{"decision":"reject",...}` with `pr`, `head` (the pushed head), `commit` (the edit commit),
   and one comment whose anchor names `docs/scratch/first.md`; `decisions.jsonl` gains one `docs`
   line.
6. **Resend.** As a session would: `git -C .../ct/clone push origin HEAD:scratch-docs-review-e2e`,
   commit a fix to `first.md`, push, write a replies file answering C1 (`done`), and queue again
   with `--replies`. The screen shows "Revision 2" and a since diff holding the fix and not the
   edit commit; `item.json` holds `revises.revision` 2.
7. **A moved head.** In `.../ct/mover`, pull, commit a change to `docs/scratch/second.md`, push.
   Approve in the browser, move the mouse off the toast, then poll for the decision file for up to 60 s: the command exits 1, `refused.json` holds the contract's
   reason, stderr names both heads, `decisions.jsonl` gains nothing, and the board's "Decided this
   session" shows "Refused".
8. **Approve at the head.** `git -C .../ct/clone pull --ff-only`; queue again (still Revision 2).
   Type a word into `first.md`, wait 2 s, approve, move the mouse off the toast, then poll for the decision file for up to 60 s. The printed line's keys are exactly
   `decision, pr, head, commit, calls, comments, threads`; `head` is the PR's head (`gh pr view
   <n> -R glw907/approval-queue --json headRefOid`); `commit` is `git -C .../ct/clone rev-parse
   HEAD` and its parent is `head`; `git -C .../ct/clone show --stat HEAD` holds the edit.
9. **The other kinds.** Queue `AQ pr glw907/approval-queue "Scratch PR item" <n>` and send it back
   in the browser; queue a one-part packet whose part is a design file under
   `APPROVAL_QUEUE_PROJECTS=.../ct/projects` (initiative `none`; `AQ packet --check` passes
   first) and approve it; queue a triage item shaped as `tests/approval-queue.test.sh` builds one
   and submit it. Each prints its decision as before.
10. **Removed commands.** `AQ blueprint`, `AQ page`, `AQ change`, `AQ anchors x`, and `AQ approved
    x y` each exit 2 and print the usage, which names none of them.
11. **Clean up.** `gh pr close <n> -R glw907/approval-queue --delete-branch`; stop the instance
    with `pkill -f '^node /var/home/glw907/Projects/approval-queue/.claude/worktrees/docs-cutover/approval-queue/build'`,
    then `curl -sf http://127.0.0.1:7995/` fails. Record every printed JSON, exit code, and the PR
    number in STATUS.

Acceptance: every step's check holds. A step still red after a traced fix falls under standing
answer 5.

### CT. Close: review, residue read, PR-ready (60 min), by the session

Risk: `runner`.

1. **The close review.** `diff-reviewer` at whole-branch scope against the design, the contract,
   and this plan, beside `svelte-reviewer` and `daisyui-a11y-reviewer` (the new screen). One batched
   fix chain whose dispatch quotes each finding verbatim (location, finding, fix) as acceptance,
   then the gate. A second review only on a blocker.
2. **The residue read** (below). Fix each finding whose cause traces, rerun the read, repeat until
   clean (no round cap; standing answer 4).
3. **The PR.** Push `worktree-docs-cutover` to glw907/approval-queue and open the PR (draft first
   if CI-less pushes still need a PR to exist). Body: `## Brief` per
   `~/.claude/docs/voice/approval-brief.md`; what landed; the end-to-end record; the review and
   residue verdicts; `## Decisions` (at least: call 1's kind allowlist, call 2's renames, call 3's
   entry, call 5's code diff, the scratch PR's number and its closing, and that the retired docs
   agents leave the live tree only when the workstation PR merges, a departure from the design's
   "unlink and remove" forced by that held PR); `## Planning misses`; the
   score per `pass-core` "Score"; "Found, not done" filed through `log-issue` in approval-queue's
   `BACKLOG.md`; and this plan's "Merge and install" steps as the conductor's, not a
   `## Before merge` (the PR is safe under a plain merge and pull; the install restarts the app).
4. Mark the PR ready, write `READY <pr> <head>` in STATUS, and send `conductor-approval-queue`
   one message: the PR, its head, the end-to-end result, the review and residue verdicts, every
   clock overrun, and every departure from the plan. Never merge, never install, never run
   `approval-queue packet`.

## The residue read

After the close review's fix chain. Dispatch with the Agent tool, `subagent_type:
general-purpose`, `model: opus`, description `docs-cutover residue read`, this prompt with
`<head>` filled in:

```
You are reading one repository for leftovers of a retired system. You have not seen that system and
need not understand it; report what names it or serves it.

Repository: /var/home/glw907/Projects/approval-queue/.claude/worktrees/docs-cutover at commit <head>.
Read only. Never edit, never run a command that writes, never start a server.

The retired system: a docs pipeline with "blueprints" (page plans, files named *.blueprint.md or
*.blueprint.yaml), a "facts store" or "facts container" with fact ids like f:abc123 and :fact[...]
tags, a tool named "drafter", a "docs page chain" workflow, and four Approval Queue item kinds:
"blueprint", "page", "change", and "anchors", plus an "approved" command. (The "amend review" of
an approved item queued again is kept, rewritten for "docs"; do not report it.)
Named note anchors of the form <slug>.heading or <slug>.p<n> served those kinds.

What replaced it: one "docs" kind, documented in README.md and in
/var/home/glw907/Projects/initiatives/docs-system/plans/2026-10-25-cutover-contract.md. Read the
contract's "Removed" section first.

Report every place in the tree (code, tests, fixtures, types, comments, README, package.json) that
names or serves anything retired: a branch, a type member, a test case, a fixture, a comment, a
compat path, or a sentence. The plain English words "page", "change", and "approved" are fine when
they mean a web page, a docs page under review, an edit, or Geoff's approval, not a retired kind.

Allowed, do not report: BACKLOG.md items marked [x]; the README's "History" section; git history;
docs/decision-review/ logs.

Reply with one JSON array and nothing else:
[{"path": "...", "line": 12, "text": "<the line>", "why": "<what retired thing it names or serves>"}]
An empty array means clean.
```

## Merge and install (the conductor's)

The conductor merges once the design's bar holds: the gate green on the PR head (`cairn-run-gate
--receipt 'bash scripts/gate.sh'` from the worktree prints a passing receipt for that head, else
it runs the gate), the whole-branch review accepted, the end-to-end record complete, and the
residue read clean.

1. `gh pr merge <n> -R glw907/approval-queue --merge --match-head-commit <head>`.
2. Check no waiting item of a removed kind exists (pre-flight's check). Then, holding the start
   lock:

   ```
   flock /var/home/glw907/.local/state/approval-queue/start.lock bash -c '
     git -C /var/home/glw907/Projects/approval-queue pull --ff-only &&
     cd /var/home/glw907/Projects/approval-queue/approval-queue &&
     npm ci && npm run build &&
     pkill -f "^node /var/home/glw907/Projects/approval-queue/approval-queue/build"; true'
   ```

   The flock line must exit 0; on a failure read `server.log` in the state directory, fix the traced
   cause, and run it again.
3. Start the new app. Write the triage file:

   ```
   cat >/var/home/glw907/.local/state/aq-docs-cutover/install-triage.json <<'TRIAGE'
   {"headline":"The new queue started.","lede":"This item checks the install and is withdrawn at once.","rows":[{"action":"Withdraw this check","why":"It only proves the app answers.","proposed":"now"}]}
   TRIAGE
   ```

   Then `PATH=/var/home/glw907/.local/state/aq-docs-cutover/bin:$PATH setsid -f approval-queue
   triage glw907/approval-queue "Install check" /var/home/glw907/.local/state/aq-docs-cutover/install-triage.json >/var/home/glw907/.local/state/aq-docs-cutover/install.out 2>/var/home/glw907/.local/state/aq-docs-cutover/install.err`
   (the `xdg-open` stub keeps a tab from opening at night).
   Read the id from the `queued` line in `install.err`, check `curl -sf http://127.0.0.1:7907/`
   answers and `pgrep -f '^node /var/home/glw907/Projects/approval-queue/approval-queue/build'`
   prints a new pid, then `approval-queue withdraw <id>`, which prints `withdrew <id>`.
4. `approval-queue docs` with no arguments exits 2 with the new usage: the live command is the new
   one. Note the install time for the hand-over.

## Path

T0 15 + pair (A 120, B 120) 120 + T2 120 + T3 30 + T4 60 + CT 60 = 405 path minutes. The task sum
is 525. The design set 400 for the Approval Queue; the plan is 1.01 times it.

## Models

- Executor: `approval-queue-docs-cutover` on `sonnet` at `medium`.
- A, B, T2: Agent-tool subagents on `sonnet` at `medium`. A carries the decision path and gets a
  task-scope `diff-reviewer` read before its merge.
- Reviewers and the residue read: `claude-opus-5-5` (`model: opus`), from frontmatter or the
  dispatch.
- Conductor: `conductor-approval-queue` on `claude-opus-5-5` at `medium`.

## Standing answers

From the design, made concrete for this repo, applied in place of stopping:

1. **Merges.** The conductor merges this PR when the gate (`bash scripts/gate.sh`, which runs
   `npm run check`, `npm test`, and every `tests/*.test.sh`) is green on its head, the
   whole-branch review accepts it, T4 passes, and the residue read is clean. A `cairn-run-gate`
   exit 75 is reissued until it prints `gate exit:`. The executor never merges.
2. **Install before cairn.** The cairn-cms main PR merges only after "Merge and install" step 4.
3. **The interim.** Until the workstation PR merges, the live `approval-packet` skill describes the
   removed commands; no session queues docs overnight but the conductor, which reads the contract.
4. **The residue read.** Each finding is fixed while its cause traces, with no round cap. A finding
   whose cause doesn't trace holds this PR for the morning packet: the executor reports it, still
   marks the PR ready, and the conductor raises it as a `gate-failed` ask instead of merging.
5. **A red step.** A gate leg or end-to-end step that stays red after a traced fix gets one
   structural fix (replace the unit the patches missed); if it returns, the executor escalates it
   in the PR and goes on with the rest. Escalation is allowed for the since diff's display
   (fallback: the "Revision N" line alone) and the board's "Refused" row. It is not allowed for the
   decision shapes, the approve refusal, the save-by-commit, the removed kinds' absence, or
   packets, `pr`, `design`, and `triage` deciding as before; one of those still red holds the PR for
   the morning packet as a `gate-failed` ask.
6. **Ceilings.** This plan's path is 405 against the design's 400 and the run's 900-minute
   ceiling. A task past twice its estimate keeps going while each step fixes a traced cause; the
   clock-stop hook's "wait for Geoff" line is answered here: write the minutes to STATUS, rewrite
   `start=` to now, run no `notify-send`. Past the ceiling the conductor has the executor finish the
   task in flight and stop.
7. **Stops.** A finding these answers can't settle is escalated in the PR and the run goes on with
   the independent work. The executor stops only on a cause it can't trace or an irreversible act
   this plan doesn't name: it removes the clock file, writes the one question in STATUS, and sends
   `conductor-approval-queue` one message. It never runs `notify-send` and never asks Geoff.
8. **Other repos.** A cairn-cms or workstation follow-up goes to that repo's `BACKLOG.md` through
   `log-issue`, never into its tree.
9. **A pair merge conflict** stops the line: the session resolves it in the merge, reruns the gate,
   and records the resolution in `## Decisions`.
