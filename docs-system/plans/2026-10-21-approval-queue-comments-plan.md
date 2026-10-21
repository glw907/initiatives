# approval-queue comments plan: margin comments, typed replies, and the background Undo

Initiative: docs-system

Path estimate: 450 minutes against the design's 300 (1.5x), inside the 600-minute standing answer.
The arithmetic is under "Path".

Design: `~/Projects/initiatives/docs-system/specs/2026-10-21-approval-queue-comments-design.md`,
approved by Geoff on 2026-10-21 in its design packet (glw907/initiatives#87, merge `20f0ec0`), with
the packet beside it. The approved prototype is
`docs-system/prototypes/2026-10-21-review-comments/`. It holds `comments.html` (round 8, screen 1
and `?round=2`), `round-6-spec.md` (the weight ladder and motion grammar), `fixed-copy.md` (every
reviewed string), `prior-art.md`, `README.md`, and `troubleshooting.blueprint.md`. Packet step 1 is
done (#87 merged). This plan carries step 3, and Geoff runs step 4, the pass's packet.

One addition to the approved scope, ruled by Geoff on 2026-10-21 and relayed by conductor-drafter
("yes, add the #13 print"): a reject on the three document kinds also prints its stored `calls`
(call 3).

One `plan-reviewer` read (mechanics and feasibility) returned 13 majors and 13 minors and no
blockers, all folded (`research/2026-10-21-approval-queue-comments-plan-review-mechanics.md`). The
folds cover:

- a per-item queue, change-doc anchors, and ids after a re-queue
- explicit per-port builds and literal commands, plus CSRF headers on curl
- Undo restoring every kind's panel state, and the `desk.held` readers
- the comment box's Ctrl+Enter, and a strengthened end-to-end check
- standing answers for a red check and for the live restart

The planning session read approval-queue at `3ade397`, the head of glw907/approval-queue#4
(branch `reviewed-pages`, open at planning), and initiatives at `20f0ec0`. The pass builds on `main`
after #4 merges, so lines move; the executor finds each quoted symbol by name.

## Pre-flight

Nothing for Geoff. The conductor checks each item just before launch:

- glw907/approval-queue#4 is merged: `gh pr view 4 -R glw907/approval-queue --json state` prints
  `MERGED`.
- conductor-drafter has cut the live queue over to it. `curl -sf http://127.0.0.1:7907/` exits 0.
  `git -C ~/Projects/approval-queue log -1 --format=%H` equals `origin/main` after `git fetch
  origin`. `~/Projects/approval-queue/approval-queue/build/index.js` is newer than #4's merge commit
  (`stat -c %Y` against `git log -1 --format=%ct <merge>`).
- If #4 merged with changes, standing answer 2 applies.
- `~/Projects/approval-queue` is on `main`, `git status --porcelain` prints nothing, `git rev-list
  --count HEAD..origin/main` prints 0, and `git check-ignore -q .claude/worktrees/x` exits 0.
- No live session works approval-queue other than the conductor (`claude agents --json`). At
  planning the only other row there was `approval-queue-e3`, an idle interactive session.
- `node`, `npm`, `jq`, `gh`, `cairn-run-gate`, and `python3` resolve, and `gh auth status` answers.
- The headless browser resolves: `/var/home/glw907/.npm/_npx/9833c18b2d85bc59/node_modules/playwright-core`
  and `/var/home/glw907/.cache/ms-playwright/chromium_headless_shell-1248/chrome-headless-shell-linux64/chrome-headless-shell`
  both exist.
- Ports 7961, 7971, 7981, 7991, and 7995 are free (`curl -sf http://127.0.0.1:<port>/` fails).
- `~/.claude/docs/voice/approval-brief.md` exists (the gate reads it).
- This plan and its two prompts are committed on initiatives `main`.

## Outcome

The design's outcome, built in glw907/approval-queue:

- The blueprint, page, and change reviews carry a comment margin beside the document.
- Selecting text with the mouse opens a comment box level with the selection.
- Every annotation is a margin card level with its text, including the fact-check notes, the open
  calls, Geoff's comments, and the author's replies.
- Comments save to the item as they are written, and they go to the author in the decision JSON
  with either decision.
- A re-queued item carries the author's typed replies (`--replies`) on re-placed cards. A comment
  whose text is gone shows its original quote.
- The outline sits in the rail under the open item.
- Every decision, of every kind, opens the next item at once and posts after a five-second Undo
  toast.
- The screens take round 6's weight ladder and motion grammar, and the rail widens on wide screens.

End-to-end check (the design's), run in CT on a throwaway instance with a real headless browser
against the fixture (call 14):

1. Round 1: the script answers every call the fixture's notes hold. It posts two comments through
   the UI, C1 on a line in section 2 and C2 on a line in the `:::row`, then sends the item back.
   The printed JSON carries both comments, and each `anchor.quote` equals its posted slice of the
   committed file.
2. The script edits the fixture and commits. It inserts a paragraph above C1's line, so C1's
   offsets no longer match, and deletes C2's line.
3. The script builds a `--replies` file from round 1's printed `comments` (C1 `done`, C2 `kept`)
   and queues the item again with it.
4. Round 2: C1's card shows its reply level with the moved text, and C2's card shows as gone with
   its quote struck through.
5. The script replies to C1 through the UI and approves. It presses Undo within five seconds, and
   no `decision.json` exists five seconds later.
6. The script approves again and waits. The printed JSON's `threads` equals exactly
   `[{"id":"C1","reply":<the reply>}]`, and `comments` is empty.

### Risk class and repo

The pass is `runner`, as the reviewed-pages plan classes the approval tool, and not `live-account`.
It touches one repo, glw907/approval-queue, which has no adapter and no CI.

The decision path is the command's jq programs, `src/lib/server/items.ts`,
`src/lib/server/blueprint.ts`, the item route's form actions, `src/hooks.server.ts`, and, from this
pass, the client-side hold that decides when a decision posts. It gets a task-scope `diff-reviewer`
read beside the gate: A1 and A2 carry it, and A3 doesn't.

Gate: `bash scripts/gate.sh` after `npm ci --prefix approval-queue`, run through `cairn-run-gate`
(see "Commands"). Full-suite home: that gate, local.

### Scope guard

Every subagent prompt carries these two samples (pass-core "Lifecycle" step 1):

> "Avoid over-engineering. Only make changes that are directly requested or clearly necessary.
> Keep solutions simple and focused ... The right amount of complexity is the minimum needed for
> the current task."
> (<https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices>)
>
> "Deliver what was asked, at the scope intended. Make routine judgment calls yourself, and check
> in only when different readings of the request would lead to materially different work ...
> Finish the whole task, and stop short of actions that are clearly beyond what was asked."
> (<https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-opus-5>)

Out of scope, from the design's "Later":

- comments on packets, PRs, designs, and triage lists
- fuzzy re-anchoring
- the `blueprint` skill's handling of comments, which the reviewed-pages pass writes against this
  pass's README contract
- moving the motion tokens into Survey (cairn-themes #1)

Backlog #13's packet half, #14, #15, and #16 are also out of scope (see "Later").

## Calls the plan makes

None changes the design's outcome, check, or bars. The contestable ones go in the PR's
`## Decisions` and the packet's routine row.

1. **The comment contract is fixed here**, so A1 and A3 build against one interface.
   `src/lib/editor/comments.ts` is pure TypeScript with no CodeMirror import, so the server and the
   client share it. It exports:
   - `type ReplyStatus = 'done' | 'kept' | 'answered'`.
   - `interface Anchor { quote: string; prefix: string; suffix: string; from: number; to: number; commit: string; file?: string }`.
     `file` is set only on the change kind, where it names the doc's path and `commit` is the
     item's `meta.head`. On blueprint and page, `commit` is the commit the posted blob was saved
     in.
   - `interface Comment { id: string; text: string; anchor: Anchor }`.
   - `interface Thread { id: string; status: ReplyStatus; text: string; quote: string; anchor: Anchor }`,
     one entry of a `--replies` file. `id` and `quote` are the original comment's, and `text` is
     the author's reply.
   - `const CONTEXT = 32` and `anchorAt(doc, from, to, commit, file?): Anchor`, which takes up to
     32 characters each side.
   - `place(doc, anchor): { from: number; to: number } | null`. It tries, in order:
     1. the offsets, if `doc.slice(from, to) === quote`
     2. the one occurrence of `prefix + quote + suffix`
     3. the occurrence of `quote` nearest the old `from`
     4. `null`

     Matching is exact string matching only (fuzzy matching is "Later"). Every offset is into
     LF-normalized text, as `readBlueprint` and `readChange` normalize it.
2. **Storage and the `comment` action.** `comments.json` in the item directory holds:

   ```ts
   {
     comments: Comment[],
     threads: Array<{ id: string; reply?: string; resolved?: true }>,
     next: number,
   }
   ```

   An absent file reads as empty, with `next` set past the highest id in `replies.json`.
   - **Writes** go through a temp file and `rename`, as `writeDecision` does.
   - **Ordering.** A new per-item queue, keyed by the item directory, orders every write to
     `comments.json`. The `approve` and `reject` actions of the three kinds run on the same queue.
     Each reads `comments.json` inside its step, so no comment lands after a decision has read
     it. For blueprint and page, the per-item step wraps the existing `queued(worktree, file)`
     step.
   - **Ops.** A new `comment` form action takes `op` (`add`, `edit`, `delete`, `reply`, `resolve`,
     or `reopen`) and `id`. `add` also takes `text`, `from`, `to`, and, by kind:
     - blueprint and page: `blob`. The client flushes its pending save first. The server builds
       the anchor from the committed file at that blob, and answers 409 when the blob is stale.
     - change: `file`, mapped through `docs.json` to `docs/<k>/new.md`, which never changes after
       queueing, so there's no blob check.
   - **Errors.** A decided item answers 404, as `save` does, and a `missing` file answers 409. The
     UI hides Comment on a missing file.
   - **Replies.** `reply` with empty text removes Geoff's reply.
   - **Ids** are `C<next>`, and `next` only grows. A deleted id is never reused, and a new comment
     on a re-queued item never takes a thread's id.
3. **The decision JSON.** The approve and reject decisions of the `blueprint`, `page`, and `change`
   kinds gain two fields:
   - `comments: Comment[]`, always present and possibly empty
   - `threads: Array<{ id; reply }>`, only the threads Geoff replied to

   The stored decision takes both from `comments.json` inside its queued step, and the `Decision`
   type in `items.ts` gains them.

   The command's `doc_decision` and `change_decision` jq programs print both on approve and reject.
   A reject on these three kinds also prints the `calls` its stored decision already keeps. That is
   backlog #13's document-kind half: Geoff, 2026-10-21, relayed by conductor-drafter: "yes, add the
   #13 print". `## Decisions` names that source, and `BACKLOG.md`'s #13 is marked partly done, with
   the packet, PR, design, and triage half still open.

   Each kind's `decisions.jsonl` line gains `comments` (the count) and `replies` (the count of
   `threads`). Packet, PR, design, and triage decisions don't change, and `tests/packet.test.sh`
   passes unchanged.

   An anchor keeps the commit it was made at. The author re-places it by quote and context, so
   nothing re-anchors at decision time.
4. **`--replies <file>`** on `blueprint`, `page`, and `change`, beside `--notes`.
   - A jq shape check in the style of the notes check refuses anything but an array of `Thread`,
     refuses duplicate ids, and requires `file` on the change kind.
   - On a change, the check also refuses a thread whose `file` names no doc the change carries, as
     `queue_change`'s notes check refuses an unnamed file.
   - An empty array is accepted. The file is copied to `replies.json` in the item directory.
   - `load` places each thread with `place()` against the doc it names. A `null` placement renders
     as gone, with the round-4 copy: "The text you commented on is gone from the blueprint." The
     kind word is "page" on a page, and `ChangeDoc.kind` on a change.
5. **Resolve.** Only Geoff resolves a thread. `resolve` records `resolved: true` in
   `comments.json`, and `reopen` clears it. An unanswered thread resolves at the decision, so
   `threads` lists only the replied ones (the design's rule).

   A fact-check note's Resolve (round 3) collapses the card in the client only. The state is kept in
   `localStorage` beside the remembered choices, and it changes no decision.
6. **The background Undo.** A new layout-level store, `src/lib/held.svelte.ts`, holds the decision:
   its form data, the item's id, title, and kind, the absolute `action.href` enhance supplies, and
   the toast text.
   - **Deciding.** `ItemPanel` flushes pending saves, takes the form data its `decide` handler
     builds today, and cancels the form's own submit. It hands that data to the store and navigates
     at once to the next waiting item. That item is `nextItem`'s queue order (created, then id),
     skipping every held id. With none left, the page goes to `/`.
   - **Posting.** After 5 seconds the store posts with `fetch` and the `x-sveltekit-action` header,
     as `saveBlueprint` does, and reads the answer with `deserialize`. On success it does what the
     panel's success branch does today, since the panel is gone. It deletes the item's
     `desk.drafts` entry, clears its `desk.calls.<id>` keys, and runs `invalidate('desk:queue')`.
   - **Undo** cancels the post and opens the held item again. The remounted panel seeds `noteText`,
     a packet's `answers` and `verdicts`, a PR's or design's `picks`, and triage rows from the held
     form data, so the item comes back as it was left. The restored item shows "Decision undone.
     Nothing was sent." Saved edits and comments are already on disk.
   - **Edge cases.** A decision made while another is held posts the held one at once. Closing or
     reloading the tab during the hold sends nothing, because the timer dies with the page. A failed
     post (400, 404, 409, or 410) shows an error toast that names the item and links to it.
   - **Held items.** Every reader of `desk.held` changes, because the next item must not freeze.
     The readers are `frozen`, the approve handlers' early returns, and `keys.ts`'s `held` gate. j/k
     skip held ids. A held item is hidden from the rail and the board while held. It shows under
     "Decided this session" with "Approved" or "Sent back" (round 7). The `z` key is Undo while any
     decision is held.
   - **What stays and goes.** The packet's irreversible confirmation still comes first. The
     packet bar's countdown and Pause go. While the pointer or focus is on the toast, its clock
     stops (contestable: the prototype shows no pause, and this keeps the existing pointer pause
     where it now lives). The server's `decide` still returns `next`, and the client ignores it.
7. **Notes move to the margin.** The inline block widgets in `setup.ts` (`NoteWidget` and
   `noteDecorations`) give way to margin cards. Each note's range keeps a `Decoration.mark`
   highlight, an open call keeps `cm-anchor`, and `NoteCard.svelte` renders inside the margin.
   `rangesField` keeps mapping note ranges through edits. A second field maps comment and thread
   ranges the same way, keyed `comment:<id>` and `thread:<id>`.
8. **The change kind** gets one margin per doc section, beside that doc's read-only editor. The
   code diff section has none. `ChangePane.svelte` leaves the change screen: its calls and
   corrections become margin cards, and its doc and code links go to the rail outline under the
   open item. `ReviewPane.svelte` stays only on the packet, PR, design, and triage screens.
9. **Keys** follow the prototype's sheet:
   - Ctrl+Alt+M comments on a selection.
   - Ctrl+Alt+N and Ctrl+Alt+P move to the next and previous comment.
   - While a comment box has focus, `keys.ts` gains a `commentOpen` context. In it, Ctrl+Enter saves
     the comment instead of approving.
   - While any box is open, a decision is refused with fixed-copy's "Save or cancel the comment you
     have open first".
   - Escape closes an empty box and keeps the selection.
   - Only one box is open at a time.
   - The shortcut sheet in `+layout.svelte` lists these keys for the three document kinds.
10. **Copy** is `fixed-copy.md`'s, verbatim, rounds 3 to 7. Any string the build needs that the
    prototype lacks follows the developer-docs register, and `## Decisions` lists it.
11. **Throwaway instances.** None opens a tab on Geoff's screen, runs main's code, or runs another
    port's build:
    - Each instance runs the worktree's own command by absolute path. The `approval-queue` on PATH
      is a symlink into the live main checkout.
    - Each puts `/var/home/glw907/.local/state/aq-comments/bin`, which holds an `xdg-open` that
      exits 0, first on `PATH`.
    - Each first builds its port explicitly. The command builds only when `build/index.js` is
      missing, and the port is baked in at build time (the Host check answers 403 otherwise).
    - Each uses its own state root, `/var/home/glw907/.local/state/aq-comments/<task>`, through
      `XDG_STATE_HOME`.
    - Each is stopped by its full worktree path before the task returns. Nothing runs a generic
      `approval-queue/[b]uild` pattern, which would match the live server.

    "Commands" writes every line out.
12. **The live queue is never touched before the merge.** Nothing runs `npm ci` or `npm run build`
    in `/var/home/glw907/Projects/approval-queue/approval-queue`, and nothing writes under
    `/var/home/glw907/.local/state/approval-queue`.
13. **Reference renders.** T0 renders the prototype headless at 1440, 1100, and 390, light and
    dark, in these states:
    - screen 1 idle
    - screen 1 with a draft open
    - screen 1 with a card current
    - screen 2
    - the drawer, at 1100 only

    It serves `/var/home/glw907/Projects/initiatives/docs-system/prototypes` at `127.0.0.1:7995`.
    It launches the headless shell through `executablePath` with the binary named in "Pre-flight",
    because playwright-core 1.64.0-alpha expects revision 1247 and 1248 is installed. It allows
    network access for jsdelivr's CodeMirror and waits for `window.__ready` before each shot. The
    PNGs go in `/var/home/glw907/.local/state/aq-comments/ref/`, and `visual-verifier` grades
    against them.
14. **The fixture.** `src/lib/fixtures/comments/` holds `comments.blueprint.md`, a synthetic
    blueprint written for the test, not cairn's: front matter, two `##` sections, and one `:::row`.
    It also holds `notes.json`, with one `info` note and one `decide` note. A1 writes it, and A1's,
    A3's, and CT's checks use it.

## Path

The longest chain run in sequence, a pair counting once at its larger estimate:

- T0, launch, worktree, baseline, reference renders: 30.
- The pair A1 (150) beside A2 (120): 150, ending at 180.
- A3, merging the pair, then the margin, the cards, and the outline in the rail: 195, ending at
  375.
- CT, the end-to-end check, the close reviews, one fix chain, renders, and PR-ready: 75, ending at
  450.

Recent approval-queue passes ran at a fifth to a third of their plans (#2: 105 actual against 540;
#4's lane: 181 against 610), so 450 is a ceiling more than a forecast.

Clock: `pass-task-clock` in the pass worktree's git dir,
`/var/home/glw907/Projects/approval-queue/.git/worktrees/comments`, holds the session's own task.
When a subagent returns, the session checks its minutes against twice its estimate.

## Models

- Executor: session `approval-queue-comments` on `claude-opus-5-5` at `medium`, as #4's executor
  ran. It merges, gates, grades renders against the references, and settles review findings on
  the decision path unattended.
- A1, A2, and A3: `general-purpose` on `opus` at `medium`. A1 and A2 carry the decision path,
  specified by contract. A2's client hold has to keep every kind's state through an unmount. A3
  carries CodeMirror geometry and the prototype's interaction model, which the plan specifies by
  behavior, not by code.
- Each code subagent loads `svelte-conventions`, `ts-conventions`, and the `daisyui` skill first. It
  runs the svelte MCP autofixer on each `.svelte` file it writes. It prefers stock DaisyUI
  components; quiet card actions are `btn-ghost btn-sm`, per `round-6-spec.md`.
- Reviewers: `diff-reviewer`, `svelte-reviewer`, `daisyui-a11y-reviewer`, and `visual-verifier`
  from their frontmatter.

A headless agent cannot read `~/.claude/skills`, so every subagent prompt names each skill and
prototype file by absolute path (skills under `/var/home/glw907/.claude/skills/<name>/SKILL.md`).

## Names

Written out literally in every command and subagent prompt, never as shell variables:

- **The pass worktree:** `/var/home/glw907/Projects/approval-queue/.claude/worktrees/comments`,
  branch `worktree-comments`, cut from `main` after #4. It is the session's one `EnterWorktree`,
  named `comments`.
- **The task worktrees:**
  - A1: `/var/home/glw907/Projects/approval-queue/.claude/worktrees/comments-a1`, branch
    `comments-a1`
  - A2: `/var/home/glw907/Projects/approval-queue/.claude/worktrees/comments-a2`, branch
    `comments-a2`

  Both are cut from the pass branch after T0 with `git -C /var/home/glw907/Projects/approval-queue
  worktree add`, and never pushed. A3 and CT work in the pass worktree.
- **STATUS:** `comments-status.md` in the pass worktree's git dir, beside the clock file, never
  committed. It holds the base commit, each worktree and branch, each subagent's start and return,
  each instance's port, the PR, and every overrun.
- **The prototype:**
  `/var/home/glw907/Projects/initiatives/docs-system/prototypes/2026-10-21-review-comments/`.

## Commands

Each line is written out in full where it runs; `<wt>` here stands for the task's worktree path
from "Names", and each port is the task's own (A1 7961, A2 7971, A3 7981, CT 7991). A prompt never
carries the placeholder.

- Setup, in a fresh worktree: `npm ci --prefix <wt>/approval-queue`.
- Gate: `cd <wt> && cairn-run-gate 'bash scripts/gate.sh'`, with the Bash tool's timeout at 600000,
  re-issued on exit 75.
- Build for a port: `APPROVAL_QUEUE_PORT=<port> npm run build --prefix <wt>/approval-queue`. Run it
  before every instance, since an earlier task's build in the same worktree serves another port.
- Queue an item:
  `PATH=/var/home/glw907/.local/state/aq-comments/bin:$PATH APPROVAL_QUEUE_PORT=<port> XDG_STATE_HOME=/var/home/glw907/.local/state/aq-comments/<task> setsid -f <wt>/bin/.local/bin/approval-queue blueprint <temp repo> <title> comments.blueprint.md --notes <temp repo>/notes.json [--replies <file>] > <decision file>`.
  The command starts the server itself, and the decision prints to `<decision file>`.
- Start a server without queuing (A2):
  `HOST=127.0.0.1 PORT=7971 APPROVAL_QUEUE_STATE=/var/home/glw907/.local/state/aq-comments/a2/approval-queue setsid -f node /var/home/glw907/Projects/approval-queue/.claude/worktrees/comments-a2/approval-queue/build`.
  Seed the items with the existing `seed-blueprint.ts` and `seed-packet.ts` fixtures, run the way
  their current callers run them (`grep -rn seed- <wt>/approval-queue <wt>/tests`).
- A form POST with curl: `-H 'Origin: http://127.0.0.1:<port>' -H 'x-sveltekit-action: true'`, or
  SvelteKit's CSRF check answers 403.
- Stop: `pkill -f '^node <wt>/approval-queue/build'`, then check `curl -sf
  http://127.0.0.1:<port>/` fails.

## Standing answers

From the design and its approval, applied in place of stopping:

1. **Path ceiling.** The run proceeds up to 600 path minutes, twice the design's 300. A task past
   twice its estimate writes its minutes to STATUS and goes on under that ceiling. Past 600 the run
   stops. The `claude-clock-stop` hook's "wait for Geoff" line is answered by this standing answer:
   write the minutes to STATUS, rewrite the clock file's `start=` to now, run no `notify-send`, and
   carry on.
2. **#4 merged with changes.** The pass builds on `main` as it stands. It stops only if a change
   alters an outcome here, for example #4's decision JSON or item kinds changed shape. Every other
   difference is absorbed and named in `## Decisions`.
3. **Prototype against data model.** Where the prototype and the app's data model disagree, the
   data model wins, and `## Decisions` names the difference. Everywhere else the prototype wins.
4. **Review fixes.** When a task-scope `diff-reviewer` on the decision path returns `fix`, the run
   fixes it and asks for a fresh read. A cause that returns after one structural fix is escalated
   in the PR as a `gate-failed` item, and the run goes on.
   - **Escalation allowed:** call 6 (fallback: keep #4's in-page hold, which still meets the
     check's Undo clause, and name the departure in the packet), and call 8 (fallback: the change
     kind keeps `ChangePane` and gets no margin).
   - **Escalation not allowed:** calls 1 to 4. A returning cause there stops the run.
5. **Visual verification.** A render that fails `visual-verifier` loops through a fix and a fresh
   verifier for as long as each fix answers a traced cause. It never ends on the builder's own read.
   A cause that returns after one structural fix is escalated: the STRUCTURAL verdict becomes a
   `gate-failed` item in the PR, and the run goes on. Any screen may escalate this way.
6. **Red end-to-end check.** If the end-to-end check is still red after CT's fix chain, the PR
   carries it as a `gate-failed` item, and the conductor's packet carries it as a forced ask. CT
   still finishes and the PR still goes ready. Renders and reviews whose cause is already recorded
   are not rerun.
7. **A stop.** Remove the clock file, write the one question into STATUS, and send
   conductor-approval-queue one message naming it. The conductor asks Geoff.

## Tasks

### T0: launch, baseline, worktrees, reference renders (30 min), by the session

Risk: `runner`, no decision-path edit.

1. The one-executor checks (CLAUDE.md "One executor per worktree"): `pgrep -af
   '[w]orktrees/comments'` prints nothing, and `claude agents --json` shows no other busy session in
   approval-queue. Then `EnterWorktree` with the name `comments` from
   `/var/home/glw907/Projects/approval-queue`. Write STATUS with the base commit
   (`git rev-parse HEAD`), and arm the API-drop wake-up (`/loop` with no interval) per
   `~/.claude/docs/unattended-work-guards.md`.
2. Run setup and the gate in the pass worktree. A red baseline is a stop (standing answer 7).
3. Create `/var/home/glw907/.local/state/aq-comments/bin/xdg-open` (a `#!/bin/sh` script that exits
   0, mode 755) and `/var/home/glw907/.local/state/aq-comments/ref/`.
4. Make the reference renders (call 13). Stop the 7995 server afterward.
5. Cut `comments-a1` and `comments-a2` from the pass branch's head, and run setup in each.

- Files: none committed. Acceptance: the gate is green at the base, the reference PNGs exist, and
  STATUS is written.

### The pair: A1 beside A2

Each subagent works in its named worktree by absolute path (no `isolation`), commits there, and
never pushes. Each prompt carries:

- the scope guard
- the prototype files by absolute path
- calls 11 and 12 quoted
- the task's own lines from "Commands", written out in full

File ownership:

- **A1:** `items.ts`, `blueprint.ts`, the item route's server file and its test, the command,
  `tests/*.test.sh`, `README.md`, `BACKLOG.md`, `comments.ts`, and the fixture.
- **A2:** `hold.ts`, `held.svelte.ts`, `desk.svelte.ts`, `keys.ts` and its test,
  `ItemPanel.svelte`, `+layout.svelte`, `frame.css`, `DecisionBar.svelte`, and `app.css`.

Neither edits the other's files. A1's commits and A2's commits each get the task-scope
`diff-reviewer` read before A3 starts.

#### A1: the comment model and the decision path (150 min), `opus` at `medium`

Risk: `runner`, decision path.

Outcome: calls 1 to 5 and 14 hold in code and tests. A comment posted to the `comment` action
lands in `comments.json` with a correct anchor. Both decisions print `comments` and `threads`, and
a reject also prints `calls`. The log lines carry the counts, and `--replies` queues a placed
thread list.

- `src/lib/editor/comments.ts` with call 1's exports. vitest for `place()` covers each fallback
  step, the `null` case, and a CRLF file. vitest for `anchorAt` covers the document's edges.
- The per-item queue, the `comment` action and its six ops, `comments.json`, and the `Decision`
  type (calls 2, 3, and 5). vitest beside `page.server.test.ts` covers:
  - each op, the stale-blob 409, the missing-file 409, and the decided 404
  - a change doc's `file`
  - ids after a delete and after a re-queue
  - a comment posted during a decision, which the decision either includes or refuses but never
    drops
  - both decisions' stored shape on all three kinds
- The command: `--replies` and its shape check (call 4), and the jq printing and log fields
  (call 3), including a reject's `calls`. Shell tests in `tests/blueprint.test.sh` and
  `tests/page-change.test.sh` extend the existing ones, covering an empty replies array, duplicate
  ids, and an unnamed change file.
- `load` returns `comments` (each with its current placement) and `threads` (placed) for the three
  kinds. A1 adds the data only, and A3 renders it.
- The README adds the new JSON fields and the `--replies` form to "The blueprint kind", "The page
  kind", and "The change kind". A new `### Comments and replies` section under "The decision JSON
  and the decision log" holds the contract the author's side follows:
  - the comment and thread shapes, and the statuses
  - that an author answers every comment
  - that an anchor is re-placed by quote and context
- `BACKLOG.md`'s #13 detail line gains: "Doc-kind half done in the comments pass; packet, PR,
  design, and triage remain."
- Files: `src/lib/editor/comments.ts` and its test, `src/lib/server/items.ts`,
  `src/lib/server/blueprint.ts`, `src/routes/item/[id=id]/+page.server.ts` and its test,
  `bin/.local/bin/approval-queue`, `tests/*.test.sh`, `src/lib/fixtures/comments/`, `README.md`,
  `BACKLOG.md`.
- Acceptance:
  - The gate is green.
  - On a throwaway instance at 7961, with a temp git repo holding the fixture, a curl POST to
    `?/comment` (op `add`, with the CSRF headers) and then `?/reject` print a decision whose
    `comments[0].anchor.quote` equals the posted slice of the committed file.
  - A re-queue with `--replies` loads with each thread placed.
  - `tests/packet.test.sh` is unchanged and passes.

#### A2: the background Undo, the rail, and the weight and motion tokens (120 min), `opus` at `medium`

Risk: `runner`, decision path (the client hold).

Outcome: call 6 holds for every kind. The rail matches round 8, and the global half of round 6 is
in place.

- Call 6: `src/lib/held.svelte.ts`, the toast in `+layout.svelte`, and `ItemPanel.svelte`'s
  `decide`, `beforeNavigate`, `frozen`, and approve handlers, rewritten around it.
  - `hold.ts` stays as the timer, with its pause and resume driven by the toast's pointer and
    focus.
  - `keys.ts` drops the `held` gate, makes `z` Undo while a decision is held, and skips held ids.
  - vitest for the store covers a post after 5 seconds, Undo, a second decision flushing the first,
    a failed post, and seeding a remounted panel's state from the held form data.
- The rail at 1260px and wider: `--rail-w: clamp(18rem, 12rem + 8vw, 23rem)`, `padding-inline:
  20px 12px`, `scrollbar-gutter: stable`, and wrapped titles with no sideways scroll
  (`grid-template-columns: minmax(0, 1fr)`).
- From `round-6-spec.md`, for the surfaces that exist now (the rail, menus, the send-back panel,
  the help sheet, the toast, and the drawers):
  - the four motion tokens and rules 1 to 7
  - thin scrollbars
  - shortcut keys inside buttons as plain `desk-kbd` text
  - quiet `btn-ghost btn-sm` actions where the spec names them

  Reduced motion turns all of it off. A comment on the token block in `frame.css` says the tokens
  move to Survey under cairn-themes #1.
- Files: `src/lib/hold.ts` and its test, `src/lib/held.svelte.ts` and its test,
  `src/lib/desk.svelte.ts`, `src/lib/keys.ts` and its test, `src/lib/components/ItemPanel.svelte`,
  `src/lib/components/frame/{frame.css,DecisionBar.svelte}`, `src/routes/+layout.svelte`,
  `src/app.css`.
- Acceptance: the gate is green. On the A2 server at 7971, holding a seeded blueprint and a seeded
  packet, a real headless browser shows:
  - Approving the blueprint opens the packet at once, and `decision.json` appears only after
    5 seconds.
  - Answering one of the packet's asks, approving, and pressing Undo within 5 seconds leaves no
    `decision.json`. The packet then shows again with that ask still answered and "Decision undone.
    Nothing was sent."
  - Reloading during a hold leaves no `decision.json`.
  - At 320, nothing scrolls sideways.

### A3: merge the pair, then the margin, the cards, and the outline in the rail (195 min), `opus` at `medium`, in the pass worktree

Risk: `runner`, no decision-path edit. It calls A1's actions as they stand.

First, the session merges `comments-a1`, then `comments-a2`, into `worktree-comments` and runs the
gate. It removes both task worktrees and deletes their branches, which were never pushed. Then it
dispatches A3.

Outcome: the blueprint, page, and change screens match `comments.html` screens 1 and 2. The page
and its margin form one unit, and every annotation is a card level with its text. The comment
flows work, a re-queued item shows its threads, and the outline sits in the rail.

- **The unit.** The page and its margin (`--margin-w`) are centered together between the rail and
  the window edge, with one decision bar across the unit. One sticky place bar spans it, showing
  the current section, the next call, Contents below 1024px, and Comments below 1260px.

  Below 1260px the margin becomes a drawer with the same cards, opened from the place bar's
  Comments button or by tapping a highlight. There, a selection shows a Comment button instead of
  opening the drawer.
- **Cards** (calls 7 and 8). `Margin.svelte` lays cards out in document coordinates at their
  anchor's line top, stacked without overlap. The current card sits level with its text, and the
  others glide (motion rule 3).
  - Notes render through `NoteCard.svelte`, and comments and threads through a new
    `CommentCard.svelte`.
  - Cards carry `role="comment"`, and each highlight carries `aria-details` naming its card.
  - Selecting highlighted text makes its card current, and a current card deepens its highlight.
- **The comment flows**, from `README.md` and call 9:
  - A mouse selection opens the box level with the selection's first line.
  - A keyboard selection uses Ctrl+Alt+M, the editor bar's Comment, or the margin's.
  - Escape keeps the selection, and a click back into the text drops an empty box.
  - Save posts to A1's `comment` action.
  - Edit, delete, reply, resolve, and reopen work on saved cards.
  - `keys.ts`, `keys.test.ts`, and `desk.svelte.ts` gain the `commentOpen` context, the comment
    keys, and the decision refusal.
- **Threads** on a re-queued item show Geoff's comment and the author's reply under its status
  head (`Done.`, `Kept.`, or `Answered.`, as `comments.html` renders them). Each has a Reply box,
  Resolve, and Reopen. A gone thread shows its quote struck through, with call 4's copy.
- **The send-back toast** takes its comment count from the review ("Sent back with <n> comments.
  ...", round 4).
- **The rail outline** sits under the open item, built from the review's headings:
  `aria-label="Contents"`, one numbered link per section, and the change kind's doc and code
  links.
  - `ReviewPane.svelte` and `ChangePane.svelte` leave the document kinds' `pane` snippet.
  - The editor bar carries Comment, "Mark my edits", and the save state.
- **Card treatments** come from `round-6-spec.md`'s element table:
  - idle cards at level 0, the current card at level 2
  - highlights as fills only
  - the margin heading without a rule
  - motion rules 1 to 3 for cards and the comment box
- **Copy** follows call 10. The empty margin's text names the kind: "Select text in the blueprint
  ...", with "page" on a page.
- Files:
  - new: `src/lib/components/{Margin,CommentCard}.svelte`, and a CodeMirror field for comment and
    thread ranges
  - changed: `NoteCard.svelte`, `DocEditor.svelte`, `BlueprintView.svelte`, `PageView.svelte`,
    `ChangeView.svelte`, `ItemPanel.svelte`'s `pane` snippet and review wiring,
    `src/lib/editor/{setup.ts,review.svelte.ts}`, `src/lib/{keys.ts,keys.test.ts,desk.svelte.ts}`,
    `src/routes/+layout.svelte` (the rail outline and the sheet's keys), `frame.css`, and tests
- Acceptance: the gate is green. On a throwaway instance at 7981 with the fixture, a real headless
  browser shows:
  - A mouse selection opens the box at the selection's first line, its top within 4px of the
    line's top.
  - Ctrl+Enter saves it without approving, and the card sits level with its highlight.
  - Escape leaves the selection intact.
  - A decision while a box is open is refused with the fixed-copy message.
  - The drawer works at 1100.

  `svelte-reviewer` and `daisyui-a11y-reviewer` accept. `visual-verifier` finds no STRUCTURAL
  difference from the reference renders, given as separate labeled blocks, under standing answer 5.

### CT: the end-to-end check, the close reviews, renders, and PR-ready (75 min), by the session

Risk: `runner`.

1. Run the end-to-end check from "Outcome" on a throwaway instance at 7991, built for 7991 first.
   The headless-browser script stays out of the repo, in
   `/var/home/glw907/.local/state/aq-comments/`. Record each printed JSON in STATUS. A red check
   after the fix chain falls under standing answer 6.
2. Run `diff-reviewer` at whole-branch scope against the design and this plan, beside
   `svelte-reviewer` and `daisyui-a11y-reviewer`. Run one batched fix chain that quotes each finding
   verbatim, then the gate again.
3. Make renders at 1440 and 390, light and dark, of the blueprint (both rounds), page, and change
   screens for the PR body.
4. Push `worktree-comments` to glw907/approval-queue and open the PR. Its body opens with
   `## Brief` per `~/.claude/docs/voice/approval-brief.md` and carries:
   - what landed
   - `## Decisions`: this plan's contestable calls where they landed, call 3's #13 source, and
     every mid-run call
   - `## Planning misses`
   - the score
   - the end-to-end JSON and the renders
   - any `gate-failed` items
   - each "Found, not done" item filed through `log-issue` in approval-queue's `BACKLOG.md`, with
     its number
5. Mark the PR ready, write `READY <pr> <head>` in STATUS, and send conductor-approval-queue one
   message with the PR and head. The executor never runs `approval-queue packet` and never merges.

## Close

The conductor sends one packet, initiative `docs-system`, with glw907/approval-queue#n as its one
part.

- **Rows and asks.** A routine row carries the `## Decisions` lines. Only forced asks appear: a red
  gate, a review `fix` or `escalate`, an open STRUCTURAL verdict, a red end-to-end check, or an
  escalated item.
- **`## If you approve`** lists the merge, the live restart, and the conductor-drafter message from
  "Merge order". Two `[you: ...]` steps follow:
  - `[you: reload the queue tab]`: an open tab keeps the old client until it reloads.
  - `[you: other workstation]`: on `thinkpad-x1`, pull approval-queue and rebuild it before using
    the queue there.
- **`## Not checked`**: how comments read on a real blueprint, which the troubleshooting review
  measures.

## Merge order

On the packet's approve, the conductor, from `/var/home/glw907/Projects/approval-queue`:

1. Check the live state root itself before restarting. Waiting items survive a restart, since
   their state is on disk, but an editor's pending save during the restart would fail. Restart once
   either of these holds:
   - no `blueprint`, `page`, or `change` item waits (no `item.json` without a `decision.json` under
     `/var/home/glw907/.local/state/approval-queue/` whose `kind` is one of them)
   - `/var/home/glw907/.local/state/approval-queue/tab.seen` is more than 5 minutes old, so no tab
     is polling

   Otherwise re-check every 10 minutes for up to 60 minutes. Then restart anyway: saves debounce at
   800 ms, so the window is small. Record the reason in the hand-over.
2. Merge and restart:
   1. `gh pr merge <n> -R glw907/approval-queue --merge --match-head-commit <head>`, then
      `git pull --ff-only`.
   2. `npm ci --prefix approval-queue && npm run build --prefix approval-queue`.
   3. Stop the live server by its exact path:
      `pkill -f '^node /var/home/glw907/Projects/approval-queue/approval-queue/build'`.
   4. Start it with the command's own line: `HOST=127.0.0.1 PORT=7907
      APPROVAL_QUEUE_STATE=/var/home/glw907/.local/state/approval-queue setsid -f node
      /var/home/glw907/Projects/approval-queue/approval-queue/build >>/var/home/glw907/.local/state/approval-queue/server.log 2>&1`.
   5. Check that `curl -sf http://127.0.0.1:7907/` answers within 10 seconds.
3. Message conductor-drafter that the comments pass is live at 7907. The README's
   `### Comments and replies` section is the contract for the `blueprint` skill, and the
   reviewed-pages pass can queue the troubleshooting blueprint again.
4. Remove `/var/home/glw907/.local/state/aq-comments` once no throwaway instance runs (`pgrep -af
   '[w]orktrees/comments'` prints nothing).

## Later

- **A follow-on "decision outcomes" pass**, proposed at about 300 to 360 path minutes and designed
  separately after this pass merges. It would cover approval-queue backlog:
  - #13's packet, PR, design, and triage half
  - #14: a resent item leads with what changed
  - #15: defer
  - #16: a decision whose waiting command died is collected

  Whether and when it runs is Geoff's priority call at that design.
- Comments on packets, PRs, designs, and triage lists (the design's "Later").
- Fuzzy re-anchoring behind `place()`'s last exact step.
- A browser e2e lane in the gate. The CT script stays out of the repo, since the gate has no
  browser today.
