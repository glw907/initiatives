# approval-queue send-back revisions plan: structured send-backs, revisions, and the blueprint header

Initiative: approval-queue

Design: `~/Projects/initiatives/approval-queue/specs/2026-10-24-sendback-revisions-design.md`,
approved by Geoff on 2026-10-24 through its packet (glw907/initiatives#119, merge `dd50ff3`). This
plan carries the design's "If you approve" step 1; the conductor carries steps 2 and 3.

Geoff's ruling on the design's one ask, settled: **"Hide the opener."** While the send-back note is
open, the bar's "Send back with note" opener hides, so the note's Cancel and Send back are the only
controls (call 9).

Path: 305 minutes against the design's 210 estimate (1.45x), inside the 420-minute standing
answer. Task sum: 440. The arithmetic is under "Path". The last approval-queue pass ran its
450-minute path in about 153 minutes (glw907/approval-queue#5), so 420 is a guard more than a
forecast.

The planning session read approval-queue at `c8018fd`, dotfiles (glw907/workstation, which the
`glw907/dotfiles` name redirects to) at `3bfdcd5`, drafter at `a1fc918`, and initiatives at
`dd50ff3`. Lines move; the executor finds each quoted symbol by name.

## Pre-flight

Nothing for Geoff. The conductor checks each item just before launch:

- `/var/home/glw907/Projects/approval-queue` is on `main`, `git status --porcelain` prints
  nothing, `git rev-list --count HEAD..origin/main` prints 0 after `git fetch origin`, and
  `git check-ignore -q .claude/worktrees/x` exits 0.
- `git -C /var/home/glw907/.dotfiles fetch origin` succeeds and
  `git -C /var/home/glw907/.dotfiles check-ignore -q .claude/worktrees/x` exits 0. The dotfiles
  worktree is cut from `origin/main`, so the checkout's own state doesn't hold the launch.
- No live session works approval-queue other than the conductor (`claude agents --json`, each
  field read with `.get`). The planning session's own row (`approval-queue-ea`) has ended or sits
  idle.
- `node`, `npm`, `jq`, `gh`, and `python3` resolve, and `gh auth status` answers.
- The headless browser resolves: both
  `/var/home/glw907/.npm/_npx/9833c18b2d85bc59/node_modules/playwright-core` and
  `/var/home/glw907/.cache/ms-playwright/chromium_headless_shell-1248/chrome-headless-shell-linux64/chrome-headless-shell`
  exist.
- Ports 7962, 7972, and 7992 are free (`curl -sf http://127.0.0.1:<port>/` fails).
- `~/.claude/docs/voice/approval-brief.md` resolves (the gate reads it).
- `/var/home/glw907/Projects/cairn-cms/blueprints/docs/extend/add-a-custom-admin-screen.blueprint.md`
  exists (call 13's long blueprint, read only).
- This plan and its two prompts are committed on initiatives `main`.

The drafter gate is not a pre-flight item: it holds only T5, and the conductor checks it there
(standing answer 2).

## Outcome

The design's outcome, built across three repos:

- A packet send-back returns Geoff's verdicts and ask picks as `calls`, beside his note.
- A packet that resends a part Geoff sent back is a revision. It carries `## What changed`, and the
  command refuses it without the section, and refuses the section on a packet that is not a
  revision. The page shows "Revision N", Geoff's earlier note (closed), the session's bullets
  (open), and, for a PR part whose head moved, "Changes since you sent it back" ahead of its files.
- A blueprint or page resend gets the same badge.
- `approval-queue blueprint` and `page` take a required `--description <file>`. The header shows
  the title, the description's paragraphs, then today's counts as a status line.
- Typing in the send-back note leaves the document's scroll position alone, and one send-back
  control shows at a time.
- A send-back waits for a failed save, as approve does (#18). An answered call no longer comes back
  as "Still open" (#24).
- Every kind prints its queued link on stderr (#21).
- The `approval-packet` skill, the approval-brief register, and the drafter `blueprint` skill
  describe all of it.

### The end-to-end check

The design's five steps, run in CT on a throwaway instance at port 7992 (call 12) with `gh`
stubbed as `tests/packet.test.sh` stubs it, plus a stub branch for `gh api .../compare/...`:

1. Queue a two-PR packet (parts A and B, both in routine rows), set B's routine verdict to `hold`
   on the page, and send it back with a note. The printed JSON is `{decision: "reject", note,
   calls}`, and `calls` holds both parts' verdicts as the screen held them (A's preselected
   verdict, B's `hold`).
2. Move A's stubbed head to a commit the compare stub answers `ahead`, and resend the packet
   without `## What changed`. The command exits 2, and stderr names the earlier item's id.
3. Resend with the section. The page shows "Revision 2" in the crumb, then the description, then
   the closed note holding step 1's text, then the bullets, ahead of the plan. Part A's detail
   shows "Changes since you sent it back" ahead of its file list; part B shows none.
4. Queue a blueprint with `--description` holding three paragraphs. The header shows the title,
   the three paragraphs, then the status line, and stderr carries
   `approval-queue: queued <id> at http://127.0.0.1:7992/item/<id>`.
5. On the long blueprint (call 13), at 1440 and at 500 wide, scroll to the middle of the document,
   open the note, and type twenty characters with real key events. The scroll offset of the
   element that scrolls the document (the window or the frame's scroll container, whichever moved
   in T2's reproduction) does not change, and the bar shows no "Send back with note" button while
   the note is open.

### Risk class and repos

The pass is `runner`, because it edits the `approval-packet` and `blueprint` skills and the
register (the design). No task touches an `auth-data` path, and nothing touches a live account:
the pass pushes three branches and opens three PRs.

- **approval-queue**, glw907/approval-queue, checkout `/var/home/glw907/Projects/approval-queue`.
  No adapter skill and no CI. Gate: `bash scripts/gate.sh` from the worktree after
  `npm ci --prefix approval-queue`, run bare: PR #5 recorded that the worktree-isolation guard
  refuses `cairn-run-gate '<string>'`, and this gate script has no wrapper. The gate is the
  full-suite home, local, so there is no CI watch.
- **dotfiles**, glw907/workstation, checkout `/var/home/glw907/.dotfiles`. Gate:
  `bash scripts/gate.sh` from the dotfiles worktree (it wraps `cairn-run-gate` itself). No CI.
- **drafter**, glw907/drafter, checkout `/var/home/glw907/Projects/drafter`. Gate: `make check`
  from the drafter worktree. No CI on PRs.

The decision path is the command's jq programs, `packet-decision.ts`, `items.ts`, and the item
route's actions. T1 carries it, and its commits get a task-scope `diff-reviewer` read before T3
starts.

### Scope guard

Every subagent prompt carries these two samples (pass-core "Lifecycle" step 1):

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

Out of scope, from the design: revision handling for the single `pr`, `design`, and `triage`
kinds; the `change` kind's headline; the decision lifecycle items (#15, #16, #17, #25); and the
anchor items (#23, #26).

## Calls the plan makes

None changes the design's outcome or check. The contestable ones go in the PR's `## Decisions`.

1. **The send-back `calls` (#13, packet half).** A packet's `decision.json` on reject is
   `{decision: "reject", note, calls}`. `calls` is one array, in this order:
   - one `{ref, verdict}` per part, in `packet.parts` order, steps included. A routine part's
     verdict is the posted `part:<ref>` field. An ask-bound part's verdict is the tag of the
     posted `ask:<n>` choice. Either is `null` when the post lacks it or names a value outside
     `VERDICTS` for the part's kind.
   - one `{ask, question, choice}` per ask, where `ask` is its 1-based index and `choice` is the
     posted label, or `null` when none was picked or the label is not one of the ask's.

   The server builds it from the packet it rebuilt (refs and questions are the server's), next to
   `buildApprove` in `packet-decision.ts`. A send-back is never refused for its fields, and the
   fingerprint is not checked, since a send-back authorizes nothing. The `Decision` type gains the
   field. The command's `decision_program` accepts a reject whose keys are `[decision, note]` or
   `[calls, decision, note]`, checks the `calls` shape when present, and prints
   `{decision: "reject", note, calls}`, with `calls: []` when the stored decision has none. That
   keeps a decision from a server built before the pass readable during the restart window. The
   log lines don't change.
2. **The revision lookup (#14, packets).** When `approval-queue packet` checks a file, with or
   without `--check`, it reads `decisions.jsonl` for each `pr` and `design` ref the parse names.
   - A ref is sent back when its latest log line (file order, lines that don't parse skipped, as
     the `approved` subcommand skips them) has `verdict == "reject"` and kind `pr` or `design`. A
     ref whose latest line is an approve, a hold, or a `send-back` verdict inside an approve is not
     sent back. The design says "the latest reject line"; taking the latest line keeps a ref that
     was sent back, then approved, from reading as a revision forever.
   - The packet revises when one or more refs are sent back. `revises` is the `packet` id of the
     latest such line. `revision` is one more than the number of distinct `packet` ids among every
     reject line naming any of the packet's refs, so the first resend is "Revision 2".
   - `item.json` gains `revises: {item, revision, parts: [{ref, head} | {ref, sha256}]}`, the parts
     taken from that item's reject lines. The earlier item's `decision.json` supplies the note and
     calls at load time.
   - The section rule: a revising packet without `## What changed`, or a packet that revises
     nothing with it, is refused through `refuse_packet` (exit 2, logged to `refusals.jsonl`). The
     message names the earlier item's id and the refs it sent back, or says no part was sent back.
     The check runs before the queue lock and before any fetch, so a refusal writes no item
     directory.
3. **`## What changed` in the grammar.** `parsePacket` accepts one `## What changed` section after
   the description and before `## If you approve`. Its body is a bulleted list of at least one
   bullet and nothing else. `Packet` gains `whatChanged?: string[]`. A second copy, an empty
   section, prose outside the list, or the section out of order is a parse refusal with the
   register path, like the other sections. Whether the section is required is the command's call 2,
   since the file alone can't show a revision. A `packet.json` stored before the pass reads with no
   `whatChanged`.
4. **The since-send-back diff.** While queuing (never under `--check`), for each PR part named in
   `revises.parts` whose fetched head differs from the recorded one, the command runs
   `gh api repos/<owner>/<repo>/compare/<old>...<new>` under the queue lock, after `fetch_pr`.
   Probed on 2026-10-24 against glw907/approval-queue: the answer's `status` is `ahead` when the
   old head is an ancestor of the new, `behind` the other way round, and an unknown commit answers
   HTTP 404. The same path with `-H 'Accept: application/vnd.github.diff'` prints a unified diff.
   - `status == "ahead"`: the diff goes to `parts/<k>/since.patch`.
   - Any other status, or a 404 or 422: `parts/<k>/since.json` holds `{"gone": true}`. The old
     head is no longer behind the new one (a force-push), and the part says so.
   - Any other `gh` failure is a tool failure, exit 1, as `fetch_pr` treats one.
   - An unmoved head or a design part gets neither file.
5. **The description (#3 of the design).** `blueprint` and `page` take a required
   `--description <file>`. The paragraph rule `parsePacket` applies today moves into one exported
   function in `packet.ts`, and the title rule (no closing punctuation, at most `TITLE_MAX`) into
   another. `parsePacket` calls both, with its messages unchanged. `check-brief.ts` gains a mode,
   `node check-brief.ts description <file> <title>`, that runs both checks. It exits 0 printing
   the paragraphs as JSON, and exits 2 with the messages and the register path. The command runs
   it in `check_blueprint`, before any item directory exists, and copies the file to the item's
   `description.md`. A missing `--description` exits 2 with a message that names the flag, the two
   or three paragraphs it holds, and the README section, so a session still on the old skill text
   can correct itself. Sentence case stays the register's guidance, since no check reads it today.
6. **The doc header.** `FrameHeader` renders the description and the status line together; today
   it renders one or the other. A blueprint or page shows the crumb, the `<title>` as the headline,
   the description's paragraphs, then `docLede`'s text as the status line. The fixed "Approving
   this blueprint lets drafter write ..." headline goes. An item queued before the pass, with no
   `description.md`, shows its title and the status line.
7. **The revision on the page.** The crumb carries a DaisyUI `badge` reading "Revision N" on a
   revising packet, blueprint, or page. On a packet, a "What changed" block sits between the header
   and `PacketBrief`: Geoff's earlier note, closed, in a DaisyUI `collapse` (or a `<details>` with
   the defect recorded, per backlog #5), then the session's bullets, open. An empty earlier note
   shows "You sent it back without a note." A blueprint or page gets the badge only. New strings
   follow the editor-copy register (Microsoft style), and `## Decisions` lists each one.
8. **The since diff on the page.** Where a packet PR part shows its file groups today
   (`PacketRoutine.svelte`, and the bound part's detail in `PacketAsks.svelte`), a part with
   `since.patch` shows "Changes since you sent it back" with the same file grouping first, then the
   full file list. A part with `since.json` shows one line saying the head Geoff sent back is no
   longer in the branch, so only the full list follows. T3 drafts that line.
9. **The send-back control (Geoff's ruling).** While `desk.noteOpen` holds, the bar's `reject`
   snippet renders no opener. Cancel and Escape close the note and put focus back on the opener
   once it renders again. Ctrl+Enter still sends.
10. **#18.** `decide` checks `review.saveFailed` after its flush and refuses before holding the
    decision. The announcement takes `approveDoc`'s form with the verb that fits:
    `Not sent back: <save status>` for a send-back, `Not approved: <save status>` for an approve.
11. **#24.** T2 traces why an answered call comes back as "Still open". If `openCalls` counts it,
    the fix is in the count (`review.svelte.ts`), which also fixes the bar's "Make N calls" line.
    If the count is right and the cause is a note prefilled before the call was answered, the fix
    is in `prefill()`'s timing: an untouched prefill is rebuilt when the note opens. Either way the
    test pins the record's case: answer a call, then open the note, and no "Still open" line names
    it.
12. **Throwaway instances.** From PR #5's calls 11 and 12, which kept the live queue whole:
    - Each instance runs the worktree's own command by absolute path. The `approval-queue` on PATH
      is the live main checkout's.
    - Each puts `/var/home/glw907/.local/state/aq-sendback/bin` first on `PATH`. It holds an
      `xdg-open` that exits 0 (T0 writes it, mode 755), so no tab opens on Geoff's screen.
    - Each builds its port first: `APPROVAL_QUEUE_PORT=<port> npm run build --prefix
      <worktree>/approval-queue`. The port is baked in at build time.
    - Each uses its own state root through
      `XDG_STATE_HOME=/var/home/glw907/.local/state/aq-sendback/<task>`.
    - Each stops by its full worktree path, `pkill -f '^node <worktree>/approval-queue/build'`,
      then checks that `curl -sf http://127.0.0.1:<port>/` fails. Nothing runs a generic
      `approval-queue/[b]uild` pattern, which would match the live server on 7907.
    - Nothing runs `npm ci` or `npm run build` in
      `/var/home/glw907/Projects/approval-queue/approval-queue`, and nothing writes under
      `/var/home/glw907/.local/state/approval-queue`.
    - Browser checks run a Node script kept in `/var/home/glw907/.local/state/aq-sendback/`, out of
      the repo, that loads playwright-core from the pre-flight path and launches the headless
      shell through `executablePath`, as PR #5 did. The Playwright MCP tools are a second way in
      for the session only.
13. **The long blueprint.** The scroll checks copy
    `/var/home/glw907/Projects/cairn-cms/blueprints/docs/extend/add-a-custom-admin-screen.blueprint.md`
    (585 lines) into a temp git repo under `/var/home/glw907/.local/state/aq-sendback/`. It is
    never committed to approval-queue, which is public and keeps synthetic fixtures. A unit or
    component test that needs a long document generates one.
14. **The register's exemplar test.** `tests/approval-queue.test.sh` checks every fenced exemplar
    in the register and asserts exactly three packet exemplars. T4 adds a fourth, a revision. So
    T1 changes the test to pass against both the register on dotfiles `main` (three packets) and
    T4's register (four, one with `whatChanged`). It asserts the three existing shapes, plus a
    revision shape when a packet exemplar carries `whatChanged`. The live register changes only
    when the dotfiles PR merges, after approval-queue's, so main's gate stays green between the
    merges.
15. **Load data, fixed so T1 and T3 build against one interface.** The item route's `load` adds:
    - for a packet: `revision?: number`, `sentBack?: {note, calls}` from the earlier item's
      `decision.json`, `whatChanged?: string[]`, and on a PR part `since?: {groups} | {gone: true}`,
      where `groups` has the shape the part's file groups have today.
    - for a blueprint or page: `description?: string[]` and `revision?: number`. The doc kinds use
      call 2's lookup on their own log ref (`<repo>:<file>`, kind `blueprint` or `page`), with no
      section rule; their replies already answer each comment.

## Path

The longest chain run in sequence, a pair counting once at its larger estimate:

- T0, worktrees, baseline, stubs: 15.
- The pair T1 (120) beside T2 (90): 120, ending at 135.
- The pair T3 (90) beside T4 (45): 90, ending at 225.
- T5, the drafter skill, once the conductor says go: 20, ending at 245.
- CT, the end-to-end check, the close reviews, one fix chain, three PRs: 60, ending at 305.

305 path minutes, under the 420-minute standing answer. The task sum is 440 (15 + 120 + 90 + 90 +
45 + 20 + 60).

Clock: `pass-task-clock` in the pass worktree's git dir,
`/var/home/glw907/Projects/approval-queue/.git/worktrees/sendback`, holds the session's own task
(three lines: `task=<id>`, `start=<epoch seconds>`, `estimate=<minutes>`). When a pair subagent
returns, the session checks its minutes against twice its estimate.

## Models

- Executor: session `approval-queue-sendback-revisions` on `sonnet` at `medium` (pass-core
  "Models"). Conductor: `conductor-approval-queue` on `claude-opus-5-5` at `medium`.
- T1, T2, and T3: `general-purpose` subagents on `sonnet` at `medium`, each with `isolation:
  "worktree"` and the `description` `sendback-revisions task <n>`. PR #5's planning miss: a
  worktree-isolated session's subagents cannot write in worktrees cut by hand, so each pair runs in
  an agent worktree branched from the session's HEAD (`worktree.baseRef: "head"`).
- The session does T0, T4, T5, and CT itself, since dotfiles and drafter lie outside any agent
  worktree.
- Each code subagent loads `svelte-conventions`, `ts-conventions`, and the `daisyui` skill first,
  by absolute path (`/var/home/glw907/.claude/skills/<name>/SKILL.md`), since a headless agent
  can't read the skill list. It runs the svelte MCP autofixer on each `.svelte` file it writes.
- Reviewers: `diff-reviewer`, `svelte-reviewer`, and `daisyui-a11y-reviewer` from their
  frontmatter. The pass has no reference renders, so `visual-verifier` doesn't run; the session
  reads its own renders in the main loop.

## Names

Written out literally in every command and subagent prompt, never as shell variables:

- **The pass worktree:** `/var/home/glw907/Projects/approval-queue/.claude/worktrees/sendback`,
  branch `worktree-sendback`, the session's one `EnterWorktree` (name `sendback`).
- **The dotfiles worktree:** `/var/home/glw907/.dotfiles/.claude/worktrees/sendback-revisions`,
  branch `sendback-revisions`, cut in T0 with `git -C /var/home/glw907/.dotfiles worktree add
  /var/home/glw907/.dotfiles/.claude/worktrees/sendback-revisions -b sendback-revisions
  origin/main`.
- **The drafter worktree:** `/var/home/glw907/Projects/drafter/.claude/worktrees/sendback-revisions`,
  branch `sendback-revisions`, cut in T5 only, from `origin/main` after `git -C
  /var/home/glw907/Projects/drafter fetch origin`, so it carries the batch-friction merge.
- **STATUS:** `sendback-status.md` in
  `/var/home/glw907/Projects/approval-queue/.git/worktrees/sendback/`, never committed. It holds
  the base commits, each worktree and branch, each subagent's start and return, each instance's
  port, each PR and head, every overrun, and the signal lines `T5-WAIT`, `READY <prs>`, and
  `STOP <question>`.
- **Ports:** T2 7962, T3 7972, CT 7992. State roots:
  `/var/home/glw907/.local/state/aq-sendback/{t2,t3,ct}`.

## Standing answers

From the design and its approval, applied in place of stopping:

1. **Path ceiling.** The run proceeds up to 420 path minutes. A task past twice its estimate writes
   its minutes to STATUS and goes on: the session rewrites the clock file's `start=` to now, runs
   no `notify-send`, and carries on. That answers the `claude-clock-stop` hook's "wait for Geoff"
   line. Past 420 the run stops (answer 8).
2. **The drafter gate.** T5 starts only once `conductor-drafter` has merged the batch-friction PR:
   `gh pr list -R glw907/drafter --head worktree-batch-friction --state merged --json number`
   prints a non-empty array. The conductor runs that check when STATUS shows `T5-WAIT`.
   - Merged: the conductor messages "start T5", and T5 and CT run over three PRs.
   - Not merged: the conductor messages "hold T5". CT runs over the approval-queue and dotfiles
     PRs and reports them ready. Once the batch-friction PR merges, the conductor messages "start
     T5"; the executor then runs T5 and CT's steps for the drafter PR alone, and the drafter PR
     goes in a second packet.
3. **A scroll cause inside CodeMirror.** The pass works around it in this repo, and the session
   files the upstream issue as a BACKLOG item through `log-issue` with the reproduction (the
   design).
4. **A scroll bug that will not reproduce.** If neither the headless script nor the Playwright MCP
   tools reproduce it at 1440 and 500 on the long blueprint, T2 keeps the end-to-end step 5 check
   as the guard, records each attempt in STATUS, and the PR carries the scroll item as a
   `gate-failed` item. The run goes on.
5. **Review fixes.** A task-scope `diff-reviewer` `fix` on T1 is fixed and read again. A cause that
   returns after one structural fix is escalated in the PR as a `gate-failed` item, and the run
   goes on.
   - **Escalation allowed:** the scroll fix (answer 4), the since-send-back diff (fallback: no
     since section, with the full list as today), #24, and any UI finding that is not a
     decision-path defect.
   - **Escalation not allowed:** calls 1, 2, 3, and 5 (the `calls` JSON, the revision rule, the
     grammar, and `--description`). A returning cause there stops the run (answer 8).
6. **A red end-to-end check.** If a step is still red after CT's fix chain, the PR carries it as a
   `gate-failed` item, and the conductor's packet carries it as a forced ask. CT still finishes and
   the PR still goes ready. A rerun whose cause is already recorded is skipped.
7. **`main` moved.** If `origin/main` of any of the three repos moves during the run, the session
   merges it into its branch before the PR and reruns that repo's gate. Only a change that alters
   an outcome here stops the run (answer 8).
8. **A stop.** The session removes the clock file, writes `STOP <question>` into STATUS, and sends
   `conductor-approval-queue` one message naming it. It never runs `notify-send` and never asks
   Geoff. The conductor asks him.

## Tasks

### T0: worktrees, baseline, and stubs (15 min), by the session

Risk: `runner`, no edit.

1. The one-executor checks: `pgrep -af '[w]orktrees/sendback'` prints nothing, and `claude agents
   --json` shows no other busy session in approval-queue. Then `EnterWorktree` with the name
   `sendback` from `/var/home/glw907/Projects/approval-queue`. Write STATUS with the base commit,
   and arm the API-drop wake-up (`/loop` with no interval) per
   `~/.claude/docs/unattended-work-guards.md`.
2. `npm ci --prefix /var/home/glw907/Projects/approval-queue/.claude/worktrees/sendback/approval-queue`,
   then the gate from the pass worktree. A red baseline stops (answer 8).
3. Cut the dotfiles worktree ("Names") and run its gate once as a baseline.
4. Write `/var/home/glw907/.local/state/aq-sendback/bin/xdg-open` (`#!/bin/sh`, `exit 0`, mode
   755), and the long-blueprint repo (call 13).

- Files: none committed. Acceptance: both baselines are green and STATUS is written.

### The pair: T1 beside T2

Both subagents start from the session's HEAD after T0, each in its own agent worktree, run
`npm ci --prefix <its worktree>/approval-queue` first, commit there, and never push. Each prompt
carries the scope guard, calls 12 and 13 quoted, the task's own calls quoted whole, and its
commands written out with literal paths once the subagent has read its own worktree path with
`git rev-parse --show-toplevel`.

File ownership. Neither edits the other's files.

- **T1:** `bin/.local/bin/approval-queue`, `src/lib/packet.ts` and its test, `src/check-brief.ts`,
  `src/lib/server/items.ts` and its test, `src/lib/server/packet-decision.ts` and its test,
  `src/routes/item/[id=id]/+page.server.ts` and its test, `src/lib/fixtures/`, `tests/`, and
  `README.md`.
- **T2:** `src/lib/components/ItemPanel.svelte`, `src/lib/editor/review.svelte.ts` and its test,
  `src/lib/components/DocEditor.svelte`, `src/lib/components/frame/` (`DecisionBar.svelte`,
  `frame.css`), and `src/app.css`.

#### T1: the command and the server (120 min), `sonnet` at `medium`

Risk: `runner`, decision path.

Outcome: calls 1 to 5, 14, and 15 hold in code and tests, and every kind prints its queued link
(#21).

- **Calls (call 1).** vitest beside `packet-decision.test.ts` covers a send-back with a routine
  verdict changed, an ask answered and one not, an unknown label (`null`), and a missing field
  (`null`). The route test covers the stored `decision.json`. `tests/packet.test.sh` covers a
  printed reject with `calls`, a stored reject without `calls` (prints `calls: []`), and a `calls`
  of the wrong shape (refused, nothing logged, exit 1, as today's shape errors).
- **Revisions (calls 2 and 4).** `tests/packet.test.sh` gains revision cases. Its `queue` helper
  removes `$state/items` first, and a revision needs the earlier item on disk, so the revision
  cases use a helper that keeps it. The `gh` stub gains a `compare` branch answering from
  `$STUB_DIR/compare-<old>.json` (status) and `compare-<old>.diff`. Cases:
  - a resend without the section exits 2, names the earlier id, and leaves no item directory;
  - a first packet with the section exits 2;
  - a resend with the section queues with `revises` in `item.json` and `revision` 2, and a third
    round reads 3;
  - a ref sent back and then approved reads as no revision;
  - `--check` applies the same rule and fetches no compare;
  - a moved head writes `since.patch`, a `diverged` answer and a 404 write `since.json`, and an
    unmoved head writes neither.
- **The grammar (call 3).** `packet.test.ts` covers the section accepted in place, and each
  refusal: twice, empty, prose outside the list, and out of order.
- **The description (call 5).** `packet.test.ts` covers the extracted rules with `parsePacket`'s
  messages unchanged. `tests/blueprint.test.sh` and `tests/page-change.test.sh` pass
  `--description` on every queue and cover a missing flag, a one-paragraph file, a four-paragraph
  file, a title ending in a period, an 81-character title, and that a refusal leaves no item
  directory.
- **#21.** After the `curl -sf "$base/item/$id"` check passes, every kind prints `approval-queue:
  queued <id> at <base>/item/<id>` to stderr. The shell tests assert the line on each kind and that
  stdout holds only the decision JSON. The tests' `curl` stub answers 0, so the line prints under
  it.
- **Load (call 15).** The route test seeds a revising packet (earlier item with `decision.json`,
  `since.patch` on one part, `since.json` on another) and a blueprint with `description.md`, and
  asserts each field. An item without the new files loads with none of them.
- **The register test (call 14).** `tests/approval-queue.test.sh` passes against the live register
  and against a copy of it with a fourth, revision exemplar added in a temp file through
  `REGISTER=`.
- **README:** the packet reject's `calls`, revisions and `## What changed`, the since diff,
  `--description` on the blueprint and page kinds (with the usage line), and the stderr line.
- **BACKLOG** is the session's at CT, not T1's.
- Acceptance: the gate is green. The session's task-scope `diff-reviewer` read of T1's commits
  returns `accept` (answer 5 on `fix`).

#### T2: the send-back box (90 min), `sonnet` at `medium`

Risk: `runner`, no decision-path edit.

Outcome: typing in `#note` leaves the scroll alone, the opener hides while the note is open
(call 9), and #18 and #24 are fixed (calls 10 and 11).

- **The scroll.** Seed the long blueprint (call 13) on an instance at 7962, built for 7962 first,
  with state root `/var/home/glw907/.local/state/aq-sendback/t2` and the `xdg-open` stub first on
  `PATH`. Reproduce at 1440 and 500: scroll to the middle, open the note, type twenty characters
  with real key events, and record which element's scroll offset moves and by how much. Trace the
  cause (the design names scroll anchoring and CodeMirror's height map as likely; probe with
  `overflow-anchor` and with CodeMirror's own measure) and fix it at the cause. A cause inside
  CodeMirror gets a workaround here and the reproduction in STATUS for answer 3. Record the
  before and after offsets in STATUS. If it will not reproduce, answer 4.
- **The opener (call 9).** Escape, Cancel, and a send leave focus where `closeNote` puts it today.
- **#18 (call 10)** and **#24 (call 11)**, each with a test: #18 in the store or component test
  that drives a failed save, #24 in `review.svelte.test.ts` or the panel's test for the record's
  case.
- Stop the 7962 instance by its path before returning.
- Acceptance: the gate is green. On the 7962 instance, the headless script shows the offset
  unchanged at both widths after twenty characters, and no "Send back with note" button while the
  note is open, and Escape returns focus to it.

### The pair: T3 beside T4

The session merges T1's branch, then T2's, into `worktree-sendback`, runs the gate, and removes
both agent worktrees. Then it dispatches T3 in a new agent worktree and works T4 itself.

#### T3: the header, the revision, and the since diff on the page (90 min), `sonnet` at `medium`

Risk: `runner`, no decision-path edit. It reads call 15's load data as T1 left it.

Outcome: calls 6, 7, and 8 hold on screen.

- Files: `src/lib/components/ItemPanel.svelte` (the doc header, the badge, and the What changed
  block), `src/lib/components/frame/FrameHeader.svelte`, `src/lib/components/PacketRoutine.svelte`,
  `src/lib/components/PacketAsks.svelte`, a new component for the What changed block if
  `ItemPanel.svelte` would otherwise grow by more than a screen, and their tests.
- Acceptance: the gate is green. On an instance at 7972, built for 7972 first, with seeded items
  (a revising packet with one moved and one force-pushed PR part, a blueprint with a description,
  and a blueprint from before the pass), renders at 1440 and 390 in light and dark show each call's
  layout, and the session reads them. `svelte-reviewer` and `daisyui-a11y-reviewer` run at CT on
  the whole branch, not here.

#### T4: the register and the approval-packet skill (45 min), by the session

Risk: `runner`.

Outcome: sessions learn the send-back calls, revisions, and `--description` where they read them.

- Files, in the dotfiles worktree:
  - `claude/.claude/skills/survey/writing/approval-brief.md`: the packet contract gains `## What
    changed` (its place, its bulleted list answering each call or point of the note, required on a
    revision and refused otherwise), the packet skeleton shows it, and a fourth `packet`-fenced
    exemplar is a revision. The exemplar's PRs and design refs follow the existing exemplars'
    synthetic drafter refs.
  - `claude/.claude/skills/approval-packet/SKILL.md`: step 7 says a reject carries `calls` and
    the note, and the session fixes forward from both, then resends a packet with `## What changed`
    answering each call and each point of the note. The command marks it a revision and refuses
    it without the section. The `approval-queue blueprint` and `page` lines (today around lines 82
    to 88) gain `--description <file>`.
- Acceptance: the dotfiles gate is green. `REGISTER=/var/home/glw907/.dotfiles/.claude/worktrees/sendback-revisions/claude/.claude/skills/survey/writing/approval-brief.md
  bash tests/approval-queue.test.sh` passes in the pass worktree with T1 merged, and finds four
  packet exemplars, one revision. `tellgrader --register agent` on the register's changed lines is
  run and each finding read (advisory).
- Commit on `sendback-revisions`, never push until CT.

### T5: the drafter blueprint skill (20 min), by the session, on the conductor's "start T5"

Risk: `runner`.

When T3 and T4 are done, the session writes `T5-WAIT` to STATUS, messages
`conductor-approval-queue` once, and waits for "start T5" or "hold T5" (answer 2). On "hold T5"
it goes to CT for two PRs and comes back to T5 on a later "start T5".

- Files, in the drafter worktree ("Names"): `claude/.claude/skills/blueprint/SKILL.md` (the queue
  table's `blueprint` and `page` rows, and the Review section) and `new-page.md` (its queue step).
  Each `approval-queue blueprint` and `page` line gains `--description <file>`. The skill tells
  the author what the paragraphs cover: a background paragraph on the page's reader and job and
  what came before, then one or two paragraphs on what this blueprint, or this draft, proposes. It
  names the title rule (sentence case, no closing punctuation, at most 80 characters), and that a
  queue prints its link on stderr. The edits build on the batch-friction text as merged.
- Acceptance: `make check` is green in the drafter worktree, and `grep -n 'approval-queue
  \(blueprint\|page\)'` over the two files shows `--description` on every queue line.

### CT: the end-to-end check, the close reviews, and the PRs (60 min), by the session

Risk: `runner`.

1. Merge T3 into `worktree-sendback`, run the gate, and remove its worktree.
2. Run the end-to-end check from "Outcome" on an instance at 7992, built for 7992 first, through
   the worktree's own command with the `xdg-open` stub and the `gh` stub first on `PATH` and
   `XDG_STATE_HOME=/var/home/glw907/.local/state/aq-sendback/ct`. Record each printed JSON and
   each offset in STATUS. Answer 6 on a red step.
3. Run `diff-reviewer` at whole-branch scope on each branch against the design and this plan,
   beside `svelte-reviewer` and `daisyui-a11y-reviewer` on the approval-queue branch. Run one
   batched fix chain that quotes each finding verbatim (location, finding, fix), then each gate
   again.
4. Close the books:
   - approval-queue `BACKLOG.md`: tick #18, #21, and #24; #13's detail line says the packet half
     is done and the single PR, design, and triage kinds remain; #14's says packets and the
     blueprint and page badge are done and the single kinds remain. Each "Found, not done" item
     goes through `log-issue`, tagged `#initiative:approval-queue`.
   - Renders at 1440 and 390, light and dark, of the revising packet, its part details, and the
     blueprint header, read in the main loop, kept out of the repo.
5. Push each branch to its repo (`worktree-sendback` to glw907/approval-queue,
   `sendback-revisions` to glw907/workstation and, after T5, to glw907/drafter) and open each PR
   ready. Each body opens with `## Brief` per `~/.claude/docs/voice/approval-brief.md` and carries
   what landed, `## Decisions` (this plan's contestable calls where they landed and every mid-run
   call), `## Planning misses`, the score (approval-queue PR), any `gate-failed` items, and "Found,
   not done" with backlog numbers. The approval-queue PR carries the end-to-end JSON. The dotfiles
   and drafter bodies say they merge after the approval-queue PR.
6. Write `READY <pr urls with heads>` in STATUS, then send `conductor-approval-queue` one message
   with each PR and head, the end-to-end result, the review verdicts, every overrun, and every
   departure from the plan. The executor never runs `approval-queue packet` and never merges.

## Close

The conductor sends one packet, initiative `approval-queue`, with the three PRs as parts (two when
answer 2 held T5, the drafter PR following in a second packet).

- **Rows and asks.** Each PR is a routine row whose Why carries its `## Decisions` lines. Only
  forced asks appear: a `gate-failed` item, a review `fix` or `escalate` left open, or a red
  end-to-end step.
- **`## If you approve`** lists the merge order and the live restart from "Merge order" as
  `[session]` steps, then:
  - `[you: reload the queue tab]`: an open tab keeps the old client until it reloads.
  - `[you: other workstation]`: on the other host, pull approval-queue and rebuild it
    (`npm ci --prefix approval-queue && npm run build --prefix approval-queue`, then restart the
    server), and pull `~/.dotfiles` and `~/Projects/drafter`, before queuing there.
- **`## Not checked`**: how a revision reads on a real resend, which the next real send-back shows.

## Merge order

On the packet's approve, the conductor, from `/var/home/glw907/Projects/approval-queue`, each
merge with `--match-head-commit <head>` from the decision:

1. Check the live state root before restarting: restart once no `blueprint`, `page`, or `change`
   item waits (an `item.json` with no `decision.json` under
   `/var/home/glw907/.local/state/approval-queue/items/` whose `kind` is one of them), or once
   `/var/home/glw907/.local/state/approval-queue/tab.seen` is more than 5 minutes old. Otherwise
   re-check every 10 minutes for up to 60, then restart anyway (saves debounce at 800 ms), and
   record the reason in the hand-over.
2. approval-queue first:
   1. `gh pr merge <n> -R glw907/approval-queue --merge --match-head-commit <head>`, then
      `git -C /var/home/glw907/Projects/approval-queue pull --ff-only`.
   2. `npm ci --prefix /var/home/glw907/Projects/approval-queue/approval-queue && npm run build
      --prefix /var/home/glw907/Projects/approval-queue/approval-queue`.
   3. `pkill -f '^node /var/home/glw907/Projects/approval-queue/approval-queue/build'`.
   4. `HOST=127.0.0.1 PORT=7907 APPROVAL_QUEUE_STATE=/var/home/glw907/.local/state/approval-queue
      setsid -f node /var/home/glw907/Projects/approval-queue/approval-queue/build
      >>/var/home/glw907/.local/state/approval-queue/server.log 2>&1`.
   5. `curl -sf http://127.0.0.1:7907/` answers within 10 seconds.
3. dotfiles: `gh pr merge <n> -R glw907/workstation --merge --match-head-commit <head>`, then
   `git -C /var/home/glw907/.dotfiles pull --ff-only` when the checkout is on `main`, holds no
   uncommitted change in a merged file, and no live session works it; otherwise report it stale.
4. drafter (when in this packet): `gh pr merge <n> -R glw907/drafter --merge --match-head-commit
   <head>`, then pull `/var/home/glw907/Projects/drafter` under the same rule as step 3. A live
   `conductor-drafter` there gets a message to pull instead.
5. Message `conductor-drafter` one line: `approval-queue blueprint` and `page` now require
   `--description <file>` (two or three paragraphs), the title takes the packet title rule, and a
   queue prints its link on stderr. Send it after step 2 even when the drafter PR is held, since
   its sessions queue blueprints.
6. Remove `/var/home/glw907/.local/state/aq-sendback` once `pgrep -af '[w]orktrees/sendback'`
   prints nothing.

## Later

- A `send-back` verdict on one part inside an approved packet counts as a send-back for revision
  purposes (call 2 keeps the design's reject-only rule).
- Revision handling for the single `pr`, `design`, and `triage` kinds (the design's out of scope).
- A browser end-to-end lane in the gate; CT's script stays out of the repo.
