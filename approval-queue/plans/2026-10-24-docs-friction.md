# approval-queue docs friction plan: the decision lifecycle, note anchors, the amend review, and the bugs

Initiative: approval-queue

Design: `~/Projects/initiatives/approval-queue/specs/2026-10-24-docs-friction-design.md`, approved
by Geoff on 2026-10-24 (glw907/initiatives#120). This plan carries the design's "If you approve"
step 1; the conductor carries steps 2 and 3.

Geoff folded three backlog items into this pass after the approval, each quoted in the initiative
record's "## Status" (`~/Projects/initiatives/approval-queue/README.md`):

- **#27.** "Yes, fold #27 and #29 into the docs friction plan." An Undo-restored send-back note
  counts as text the reader typed (call 14).
- **#28.** Geoff chose "Only sent-back parts": only the parts he set to send back count as
  revised, so a part he marked approve inside a rejected packet comes back as a plain row with no
  since diff. The plan review raised how far that reaches, and Geoff ruled through
  `conductor-approval-queue` the same day: only those parts make a resend a revision, and a
  note-only send-back counts every part (call 15).
- **#29.** The live-log size check in `tests/packet.test.sh` fails when another session logs a
  decision mid-gate (call 16).

Path: 370 minutes against the design's 300 estimate (1.23x), inside the 600-minute standing
answer. Task sum: 505. The three folded items add about 20 path minutes; the rest of the rise over
300 is the amend review's editor work and a longer close for six end-to-end steps. The arithmetic
is under "Path". The send-back revisions pass ran its 315-minute path in about 95 minutes
(glw907/approval-queue#7), so 600 is a guard more than a forecast.

One `plan-reviewer` read (mechanics and feasibility) returned 9 majors, 12 minors, and one owner
fork, and no blockers (`research/2026-10-24-docs-friction-review-mechanics.md`). Every finding is
folded, and the fold record is `research/2026-10-24-docs-friction-fold.md`. The fork, how far #28
reaches, went to Geoff as one question, and his answer is call 15. None changes the design. The
folds cover:

- a pid start time, so a reused pid never reads as the waiter, and how `collect` is wired
- `collect` on a change, the slug alias for `p<n>` keys, and the `anchors` dispatch's owner
- a third live-log check, the pair prompts' rerun rule, and a #28 test that cannot pass vacuously
- the queuing command's exit code in CT, and every CT command written out in full

The planning session read approval-queue at `967be66`, dotfiles (glw907/workstation, which the
`glw907/dotfiles` name redirects to) at `31db050`, drafter at `f2ad05e`, and initiatives at
`7e5e5ae`. Lines move; the executor finds each quoted symbol by name.

## Pre-flight

Nothing for Geoff: the design names none, and the one step for him (the claim link) comes after
the merge, in the close packet. The conductor checks each item just before launch:

- glw907/approval-queue#7 is merged: `gh pr view 7 -R glw907/approval-queue --json state --jq .state`
  prints `MERGED` (the design's standing answer: both passes edit `ItemPanel.svelte` and the
  command).
- `/var/home/glw907/Projects/approval-queue` is on `main`, `git status --porcelain` prints
  nothing, `git rev-list --count HEAD..origin/main` prints 0 after `git fetch origin`, and
  `git check-ignore -q .claude/worktrees/x` exits 0. Each runs from that checkout as its own
  command.
- From `/var/home/glw907/.dotfiles`, `git fetch origin` succeeds and
  `git check-ignore -q .claude/worktrees/x` exits 0. The dotfiles worktree is cut from
  `origin/main`, so the checkout's own state doesn't hold the launch.
- No live session works approval-queue other than the conductor (`claude agents --json`, each
  field read with `.get`). The planning session's row (`approval-queue-docs-friction-plan`) has
  ended or sits idle.
- `node`, `npm`, `jq`, `gh`, `git`, and `python3` resolve, and `gh auth status` answers.
- The headless browser resolves: both
  `/var/home/glw907/.npm/_npx/9833c18b2d85bc59/node_modules/playwright-core` and
  `/var/home/glw907/.cache/ms-playwright/chromium_headless_shell-1248/chrome-headless-shell-linux64/chrome-headless-shell`
  exist.
- Ports 7963, 7973, and 7993 are free (`curl -sf http://127.0.0.1:<port>/` fails for each).
- `~/.claude/docs/voice/approval-brief.md` resolves (the gate reads it).
- `/var/home/glw907/Projects/cairn-cms/blueprints/docs/extend/add-a-custom-admin-screen.blueprint.md`
  exists (call 18's long blueprint, read only).
- This plan and its two prompts are on initiatives `main` and in the main checkout: from
  `/var/home/glw907/Projects/initiatives`, `git pull --ff-only`, then `test -f` on each of the
  three files under `/var/home/glw907/Projects/initiatives/approval-queue/plans/`. The planning PR
  is merged by the session that dispatched the planner, not by the conductor.

The drafter gate is not a pre-flight item: it holds only T5, and the conductor checks it there
(standing answer 3).

## Outcome

The design's outcome, built across three repos:

- `approval-queue withdraw <id>` takes a session's queued item off the board.
- Geoff can defer any item but a triage. The waiting command prints
  `{"decision":"defer","id":"<id>"}`, exits 0, and leaves the item under "Deferred" on the board.
- A decision on an item with no waiting session is kept, and `approval-queue collect <id>` logs and
  prints it as the queuing command would have. A second `collect` prints it again and logs
  nothing. The board marks an item whose session is gone: "No session is waiting for this."
- Only a tab carrying the claim cookie counts as Geoff's, so an agent's polling browser no longer
  takes a new item's tab (#17).
- A note can anchor on a quote, on any line, a reader-block line included. `<slug>.heading` and
  `<slug>.p<n>` still load. `approval-queue anchors <file>` prints a file's heading anchors, slugged
  by the rule cairn's pages use (#23, #26).
- A blueprint or page queued after an approve of the same file is an amend review: the diff since
  the approved blob, the unchanged runs folded, `amends: <blob>` in both decision shapes (#22).
- Four bugs are fixed: #19, #9, #2, and #1. The three folded items are fixed: #27, #28, and #29.
- The `approval-packet` skill (dotfiles) and the `blueprint` skill (drafter) describe all of it.

### The end-to-end check

The design's six steps, run in CT on a throwaway instance at port 7993 (call 17). Every step
queues a blueprint, which never calls `gh`, so CT needs no `gh` stub. Each step has its own file
in a fixture repo, so no step's approve turns a later step's file into an amend review. The
commands are under "CT commands", written out in full.

Every browser step that decides or defers waits for the post to land. The client holds a decision
for `HOLD_MS = 5000` in `src/lib/held.svelte.ts`, and the hold pauses while the pointer or focus
sits on the toast. So the script moves the pointer off the toast after the click, then polls the
item directory for `decision.json` or `deferred.json` once a second, for up to 30 seconds.

1. Queue `withdraw.blueprint.md` in the foreground variant, then `withdraw` its id. The queuing
   command exits 143 within 5 seconds, `withdraw` exits 0, and the board (`curl` of `/`) shows no
   row for it.
2. Queue `defer.blueprint.md` in the foreground variant and defer it on the page. The command
   prints `{"decision":"defer","id":"<id>"}` and exits 0. Approve it on the board, then run
   `collect <id>`: the approve prints, and one line with `packet == <id>` lands in
   `decisions.jsonl`. A second `collect` prints the same line and leaves the log's line count
   unchanged.
3. Queue `orphan.blueprint.md`, `kill -KILL` its command (the pid from its id), and load the
   board. The item's row shows "No session is waiting for this."
4. Open `/claim` in one browser context and keep it on the board; keep a second context, never
   claimed, on the board too. Queue `claim-a.blueprint.md`: `xdg-open.log` gains no line. Close the
   claimed context, wait 10 seconds, and note `tab.seen`'s mtime. Let the unclaimed context poll
   for 10 more seconds: the mtime holds. Queue `claim-b.blueprint.md`: `xdg-open.log` gains one
   line.
5. Queue `anchors.blueprint.md` with `anchors-notes.json`, whose notes hold a quote anchor on a
   `:::reader` line and a `<slug>.p<n>` anchor below it. Read both cards' line text from the page.
   Withdraw it, split a bullet above the `p<n>` note, commit, and queue it again. The quote-anchored
   card sits on the same line text as before, and the `p<n>` card has moved up one line, which
   shows the split took effect.
6. Queue `amend.blueprint.md` and approve it on the page. Change one clause, commit, and queue it
   again. The page opens as an amend review: the changed line is marked, the approved text of
   that line shows above it, and the runs more than 3 lines from the change are collapsed. Approve
   it: the printed approve carries `amends`, the blob the first approve logged.

### Risk class and repos

The pass is `runner`, because it edits the `approval-packet` and `blueprint` skills (the design).
No task touches an `auth-data` path, and nothing touches a live account: the pass pushes three
branches and opens three PRs.

- **approval-queue**, glw907/approval-queue, checkout `/var/home/glw907/Projects/approval-queue`.
  No adapter skill and no CI. Gate: `bash scripts/gate.sh` from the worktree after
  `npm ci --prefix approval-queue`, run bare with the Bash tool's timeout at 600000. The gate is
  the full-suite home, local, so there is no CI watch.
- **dotfiles**, glw907/workstation, checkout `/var/home/glw907/.dotfiles`. Gate:
  `bash scripts/gate.sh` from the dotfiles worktree (it wraps `cairn-run-gate` itself), re-issued
  on exit 75. No CI.
- **drafter**, glw907/drafter, checkout `/var/home/glw907/Projects/drafter`. Gate:
  `DRAFTER_DIR=/var/home/glw907/Projects/drafter/.claude/worktrees/docs-friction bash /var/home/glw907/Projects/drafter/.claude/worktrees/docs-friction/scripts/drafter-gate.sh`,
  re-issued on exit 75. No CI on PRs.

The decision path is the command's jq programs and wait loop, `packet-decision.ts`, `items.ts`,
and the item route's actions. T1 carries it, and its commits get a task-scope `diff-reviewer` read
in R1 before T3 starts.

### Commands in a worktree

The worktree guard refuses a compound shell command and a `git -C` into another worktree (the
send-back revisions pass lost several rewrites to it). So every command in this plan is one plain
command run from the directory it acts on: a `cd <dir>` on its own, then each command on its own.
No `&&`, no `;`, and no `git -C` into a worktree, in any task or subagent prompt.

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

Out of scope, from the design: carrying a ruling across items automatically, the polish items (#3
to #8, #10 to #12, #20, the third pass), and any change to how a packet is resent. Anything else
found goes to "Later" or BACKLOG, never into a task.

## Calls the plan makes

None changes the design's outcome or check. The contestable ones go in the PR's `## Decisions`.

1. **The pid (#16).** Every `item.json` the command writes gains `pid: $$` and `pidStart`, the
   process's start time in clock ticks since boot (field 22 of `/proc/$$/stat`): the packet,
   change, blueprint and page, and pr, design, and triage writers. The id already ends in the same
   pid (`id="$(date +%Y%m%dT%H%M%S)-$$"`), but the fields are what the server and `withdraw` read.
   A pid is running only when `/proc/<pid>/stat` exists, its field 22 equals `pidStart`, and its
   state (field 3) is not `Z`. Field 2 is the command name in parentheses and can hold spaces, so
   both readers split the text after the last `)`; in bash, `read -r s </proc/$$/stat; s=${s##*) };
   set -- $s; echo ${20}` prints field 22 (the reviewer probed it against `awk '{print $22}'`).
   - The start time keeps a reused pid from reading as the waiter, even when the new process is
     another queue command, so `withdraw` never sends TERM to another session's command.
   - The state test covers a killed command its parent has not reaped yet: a zombie keeps its
     `stat` and its start time.
   - An item with no `pid` (queued before the pass) reads as unknown: no board mark, and
     `withdraw` refuses it (call 2).
2. **`approval-queue withdraw <id>` (#25).** Dispatched early, beside `approved`. It refuses with
   exit 2 an id that fails `[[ $id =~ ^[0-9]{8}T[0-9]{6}-[0-9]+$ ]]` (the shell spelling of
   `src/params.ts`'s matcher, since bash `=~` has no `\d`), an id with no `item.json`, an item with
   a `decision.json` ("decided; collect it instead"), and an item with no `pid` ("queued before
   withdraw existed; stop its command"). Then, in order:
   - A deferred item (`deferred.json` exists) has its `item.json` removed directly, since its
     waiter may still be printing the defer line and its EXIT trap keeps `item.json`.
   - When the pid is running, it sends TERM: the command's `trap 'exit 143' TERM HUP INT` runs its
     EXIT trap, which removes `item.json` because no `decision.json` exists. `withdraw` waits up to
     5 seconds for `item.json` to go, polling every 0.1 seconds. If it stays because a
     `decision.json` landed meanwhile, `withdraw` exits 1 with "decided while withdrawing; run
     collect"; otherwise it exits 1 naming the item.
   - When the pid is gone, it removes `item.json` itself.
   It prints nothing on stdout and exits 0.
3. **Defer (#15).** The item route gains a `defer` action. It refuses a triage (400), a decided
   item (409, `ALREADY_DECIDED`), and an item already deferred (409, "Already deferred"), and
   writes `deferred.json` (`{"at": <ISO 8601 UTC>}`) through a temp file and `rename`, as
   `writeDecision` does. The command's wait loop ends on `decision.json` or `deferred.json`,
   checking `decision.json` first. On `deferred.json` alone it prints
   `{"decision":"defer","id":"<id>"}`, logs nothing, and exits 0, and its EXIT trap leaves
   `item.json` in place. A deferred item stays in `listWaiting` (it has no `decision.json`), so a
   packet that resends its PRs is refused as "already in the waiting item" until the item is
   withdrawn or decided. The skill says so (T4). When Geoff later approves or sends back a deferred
   item, the app writes `decision.json` as for any item, and it waits for `collect`. `nextItem` in
   `src/lib/queue.ts` skips deferred items, so a decision never opens one next.
4. **`approval-queue collect <id>` (#16).** The decision functions it runs (`append_log`,
   `packet_decision`, `single_log`, `doc_decision`, `change_decision`) are defined after the queue
   `case` and the server and tab block, so `collect` cannot dispatch early as `withdraw` does.
   - The argument parse takes `collect <id>`, refuses with exit 2 an id that fails call 2's regex
     and an id with no `item.json`, and sets `kind=collect` for the parse.
   - It reads `item.json` into the variables the decision step reads and sets `id` and `item` to
     the collected item's. The variables are `kind` (the item's), `repo`, `file` (and `source`
     from it), `worktree`, `pr` (with `pr_repo` and `number` parsed from it as the flag parse
     does), `prhead` (from `prHead`), `number`, `head`, and `initiative`. A change's `item.json`
     has no `pr`, so for a change `collect` sets `pr="$repo#$number"` and `pr_repo=$repo`, which
     `head_unmoved` reads.
   - It skips the queue `case`, the server start, and the tab block, then sets its own EXIT trap,
     which never removes `item.json`, so an interrupted `collect` withdraws nothing.
   - It runs the same wait loop and the same final `case "$kind"` the queuing command runs. A
     deferred item's `deferred.json` does not end `collect`'s wait.
   - Logging once: `append_log` checks, inside its `flock`, whether `decisions.jsonl` holds a line
     whose `packet` is this `id` (`jq -R -n -e 'any(inputs | fromjson? | objects; .packet == $id)'`,
     probed at about 5 ms on the 435-line live log), and appends nothing when it does. An absent
     `decisions.jsonl` means not logged. Every log line carries `packet: $id` today (`partline`,
     `single_log`, `doc_decision`, `change_decision`), so the log itself is the marker, and a
     queuing command and a `collect` racing on one decision log it once. A second `collect` prints
     the decision again and logs nothing.
   - A blueprint send-back reads `git -C "$worktree" rev-parse HEAD` as today; a worktree removed
     since the queue makes it exit 1, nothing logged, as the queuing command would.
5. **The board (#16, #15).** `listWaiting` adds two fields to each `ItemMeta` it returns:
   `deferred: boolean` (a `deferred.json` exists) and `orphaned: boolean` (a `pid` is recorded, it
   is not running by call 1's test, and the item is not deferred). The server reads
   `/proc/<pid>/stat` by the same rule as the command. The layout's queue and the
   board's rows carry both. The board shows deferred items in a "Deferred" group after "Single
   items", and an orphaned row shows "No session is waiting for this." A deferred row carries no
   orphan line, since a deferred item never has a waiter.
6. **The claim (#17).** A `/claim` route's load reads `<state>/claim.token`, creating it on the
   first visit (32 random bytes as hex, opened `wx` so two first visits agree, mode 0600), and sets
   the cookie `desk-claim` to it with `{path: '/', httpOnly: true, sameSite: 'lax', secure: false,
   maxAge: 34560000}`. The page says the browser is now the one the queue opens new items in.
   - `secure: false` is required: SvelteKit 3.0.1's cookie defaults set `secure` true on any host
     but `localhost` in a build (`secure: !__SVELTEKIT_DEV__ && !(url.hostname === 'localhost' &&
     url.protocol === 'http:')`, `node_modules/@sveltejs/kit/src/runtime/server/cookie.js:78`), and
     the queue serves `http://127.0.0.1`.
   - `maxAge` is 400 days because Chrome caps any cookie's lifetime there since M104
     (<https://developer.chrome.com/blog/cookie-max-age-expires>), and "sites can push the expiry
     out again by setting a new cookie with the same name". So each claimed poll sets the cookie
     again, and the 400 days count from the last use.
   - In `src/routes/+layout.server.ts`, a data request touches `tab.seen` only when the `desk-claim`
     cookie equals the token, and then sets the cookie again. With no token file, nothing matches.
   - The command does not change. While no tab is claimed, no poll touches `tab.seen`, so the
     command opens a tab for each new item, as it does when no tab is live. It still touches
     `tab.seen` after its own `xdg-open`, so a command queued within 5 seconds waits up to 5 seconds
     for a claimed poll before opening its own tab.
   - The token is per state root, so a throwaway instance's cookie never matches the live queue's.
     Cookies ignore the port, so the name is shared across instances on 127.0.0.1; a test browser
     context is the only place a throwaway `/claim` runs.
7. **Quote anchors (#23).** A note's `anchor` is a non-empty string, as today, or an object with
   a non-empty string `quote` and optional string `prefix` and `suffix`, and no other key. The
   command's `notes_program` accepts both shapes, for the blueprint, page, and change kinds, and
   names the defect otherwise. `Note.anchor` becomes `string | {quote, prefix?, suffix?}`.
   `placeNotes` places an object anchor with `place()` from `comments.ts`, passing `prefix` and
   `suffix` (empty when absent) and `from = to = 0`. That runs the README's comment steps: the one
   occurrence of `prefix + quote + suffix`, else the occurrence of the quote nearest offset 0,
   which is the first. A quote can sit on any line, since `place` searches the text and skips
   nothing `anchors()` skips. A quote that matches nothing places the note at the top of the
   file, as an unknown string anchor does today. The `blueprint` skill tells authors to quote text
   that occurs once, or to add a prefix or suffix (T5).
8. **The slug rule and `anchors` (#26).** cairn's renderer ids headings with `rehype-slug`
   (`src/lib/render/pipeline.ts:11` and `:119` in cairn-cms), which "computes each id with
   `github-slugger`" (`src/tests/unit/github-slug-contract.test.ts`), and cairn's lockfile resolves
   `github-slugger` 2.0.0, the newest release (`npm view github-slugger version`). drafter ports the
   same 2.0.0 rule for its section ids (`internal/plan/slug.go`). So `notes.ts` drops its `slug()`
   and slugs each heading with one `GithubSlugger` per document from `github-slugger` 2.0.0, a
   new dependency: a repeat takes `-1`, `-2`, as on the page. It slugs the heading's text with
   its inline Markdown stripped, since rehype-slug reads the rendered text; `marked`, already a
   dependency, can lex it. The reviewer's probe shows why: raw Markdown gives `use-foo_bar-_x_` and
   `a-linkhttpx`. Probed: `slug("Set a section's starting state")` is
   `set-a-sections-starting-state`, where today's rule gives `set-a-section-s-starting-state`.
   - The seed: a blueprint's slugger slugs the front matter's `page` first, as drafter's
     `HeadingSlugs` does (`internal/plan/slug.go:65`, called at
     `internal/blueprint/markdown.go:321`), so a heading that repeats the title takes `-1` there
     too. A page's slugger takes no seed, as cairn's `pipeline.ts` runs plain `rehypeSlug`.
   - The old spelling stays accepted (the design's standing answer): where the old rule's section
     slug differs from the new one, `anchors()` maps every key derived from the old slug
     (`<old>.heading`, `<old>.p<n>`, and `<old>.p<n>.<part>`) to the same range as the new key,
     unless a key already holds that name. The README records the rule, the apostrophe example,
     and the alias.
   - `approval-queue anchors <file>` runs `node "$app/src/anchors.ts" <file>`, which prints one
     line per heading outside front matter, code, and directive containers:
     `<slug>.heading<TAB><heading text>`. A file ending in `.blueprint.md` takes the blueprint
     seed; any other takes the page's. A file that is not readable exits 1. `check-brief.ts` stays
     dependency-free ("It imports only `brief.ts` and `packet.ts`, so it runs under plain `node`
     with no `node_modules`"), so `anchors.ts` is its own entry, and it needs the app's
     `node_modules`; the README says so. R1 adds the dispatch to the command, since it needs both
     T1's command and T2's entry.
9. **The amend review (#22).** When `approval-queue blueprint` or `page` queues a file, the command
   reads `decisions.jsonl` for the latest line whose `kind` is the queue's kind, whose `verdict`
   is `approve`, and whose `ref` is `$repo:$source` (lines that don't parse skipped, the file
   guarded as `revision_of` guards it). If one exists and `git -C "$worktree" cat-file blob <its
   blob>` reads, the command writes that text to `approved.md` in the item directory and adds
   `amends: <blob>` to `item.json`. A blob the worktree cannot read queues a full review. An amend
   can also be a revision (call 15 of the send-back plan); both apply.
   - Decisions: `doc_decision` adds `amends: <blob>` to the printed approve and send-back when
     `item.json` carries it. The log lines don't change.
   - Load: a blueprint or page with `approved.md` adds `amend: {blob, original}` to the page data,
     `original` read with CRLF turned to LF as `readBlueprint` reads `doc.md`.
   - Editor: the review adds `unifiedMergeView` from `@codemirror/merge`, a new dependency by
     CodeMirror's author, at its newest release when T3 starts (6.12.3 on 2026-10-24), with
     `original` the approved text, `mergeControls: false`, and `collapseUnchanged: {margin: 3,
     minSize: 4}`. Its typings: "Changed chunks will be highlighted, with uneditable widgets
     displaying the original text displayed above the new text", and with `collapseUnchanged`
     "long stretches of unchanged text are collapsed", leaving 3 lines by default
     (`dist/index.d.ts`). The review opens with its caret on the first changed chunk.
   - Notes and comments work as on a full review. A "Next call for you" or card jump into a
     collapsed stretch opens it first with `uncollapseUnchanged`, exported by the same package. Its
     effect names the collapsed range's exact start (`from != e.value`, merge `dist/index.js:1037`)
     and the package exports no lookup of that range, so T3 finds the start from the view's
     decorations (the block replace covering the target) or rebuilds it from `getChunks` with
     margin 3 and minSize 4.
   - The header labels the item as an amend in the crumb, as "Revision N" is labeled, and the
     description (the author's account of what changed since the approval) sits under the title
     as today.
10. **#19.** When the open-box guard in `beforeNavigate` cancels the navigation Undo started, the
    toast says why the reader stayed put ("Save or cancel your comment, then Undo opens the item
    again" or wording T2 drafts in the editor-copy register), the held decision stays cancelled,
    and the restore completes when that box closes, saved or cancelled. A decision posted on an
    item `held.ids` already holds is refused before `held.hold`, with an announcement that the
    item's decision is already counting down.
11. **#9.** `jumpTo` in `src/lib/editor/setup.ts` computes the scroll from `view.lineBlockAt(pos)`,
    which is CodeMirror's height estimate for a line outside the rendered viewport. The fix lets
    CodeMirror measure first: dispatch the selection with `EditorView.scrollIntoView(pos, {y:
    'start', yMargin: 140})`. A scroll target makes the view render the target's lines ("If
    scrollTarget is given, make sure the viewport includes that position",
    `@codemirror/view` 6.43.15 `dist/index.js:6504`), and its scroll walks every scrolling
    ancestor up to the window (`scrollRectIntoView`, `win = doc.defaultView || window`). Where
    that cannot keep the smooth scroll or the 140px offset, `requestMeasure` reading the line's
    top after the viewport moves is the design's named alternative. Either way the 500px check
    decides.
12. **#2.** `readItem` answers `undefined` for a packet whose `packet.json` does not parse (a
    `SyntaxError`), so the load answers 404 and the actions answer as for a withdrawn item:
    `gone()` returns 410 with "This item was withdrawn by its session; nothing was recorded" to a
    packet post and 404 to any other. The board already names such a row (`toRow`'s
    `single: 'Unreadable'`). The last-branch `reject` and `submit` read `request.formData()` with a
    catch and answer 400 "Not a form post" when it throws.
13. **#1.** `packetFingerprint` adds each part's lane and each ask's rule and bound part ref:
    `[p.ref, p.kind, p.lane, p.verdict, p.head ?? p.sha256 ?? '']` and `[a.question, a.rule,
    a.part?.ref ?? '', choices]`. A page loaded before the merge posts the old fingerprint and is
    told to reload, which is the existing refusal.
14. **#27.** In `ItemPanel.svelte`'s restore effect, before `openNote()`, `drafted` is set to the
    restored note text when it equals `sendBackDraft(openCalls, review?.changedLines ?? 0, ...)`
    rebuilt at that moment, so `noteStart` treats an untouched restored draft as untouched. The
    test fails on `967be66` first; STATUS records the red run.
15. **#28.** Geoff's ruling on the scope, relayed by `conductor-approval-queue` on 2026-10-24 from
    his pick in its question, option B, "Only sent-back parts": "Only the parts he set to send back
    make a resent packet a revision. A resend of only approve-marked parts is a fresh packet. A
    note-only send-back, where he set no part to send back, counts every part as today."
    - A packet send-back's log lines gain `sentBack: true` on each part whose call verdict is
      `send-back` (a routine part's posted verdict or an ask-bound part's tag, as `calls` holds it)
      and `sentBack: false` on every other part.
    - In `revision_program`, a reject line counts when its `sentBack` is not `false`, or when no
      line of its `packet` id has `sentBack: true` (a note-only send-back). A line written before
      the pass has no field, so it counts, as today.
    - A ref is sent back when its latest line is a reject that counts. The packet is a revision,
      needs `## What changed`, and shows Geoff's note when one or more refs are sent back.
      `revises.item` and `revises.parts` (which drive the note and the since diff) take only the
      refs that are sent back, and the revision number counts only the reject lines that count.
    - So a resend of only parts Geoff marked approve inside a rejected packet is a fresh packet:
      the command refuses a `## What changed` section on it, and those parts show as plain rows.
      A resend that mixes them with a sent-back part is a revision, and only the sent-back part
      gets a since diff. The refusal message names the sent-back parts.
16. **#29.** `tests/packet.test.sh`, `tests/blueprint.test.sh` (the same check, line 233), and
    `tests/page-change.test.sh` (lines 25-26 and 330) drop the size comparison of the live
    `decisions.jsonl`. Each asserts instead that no `packet` id
    in the test's own temp `decisions.jsonl` appears in the live log. A live log that grows with
    other sessions' lines passes; a test that wrote to the live log fails, naming the id.
17. **Throwaway instances.** From the send-back plan's call 12, which kept the live queue whole:
    - Each instance runs the worktree's own command by absolute path. The `approval-queue` on PATH
      is the live main checkout's.
    - Each puts `/var/home/glw907/.local/state/aq-docs-friction/bin` first on `PATH`. It holds an
      `xdg-open` that appends its arguments to `xdg-open.log` beside it and exits 0 (T0 writes it,
      mode 755), so no tab opens on Geoff's screen and CT step 4 can count tabs.
    - Each builds its port first, and every queue carries `APPROVAL_QUEUE_PORT` too ("Commands").
      The port is baked in at build time.
    - Each uses its own state root through
      `XDG_STATE_HOME=/var/home/glw907/.local/state/aq-docs-friction/<task>`.
    - Each stops by its full worktree path, `pkill -f '^node <worktree>/approval-queue/build'`, then
      checks that `curl -sf http://127.0.0.1:<port>/` fails. Nothing runs a generic
      `approval-queue/[b]uild` pattern, which would match the live server on 7907.
    - Nothing runs `npm ci`, `npm install`, or `npm run build` in
      `/var/home/glw907/Projects/approval-queue/approval-queue`, and nothing writes under
      `/var/home/glw907/.local/state/approval-queue`. Nothing opens 7907's `/claim`.
    - Browser checks run a Node script kept in `/var/home/glw907/.local/state/aq-docs-friction/`,
      out of the repo, that loads playwright-core from the pre-flight path and launches the
      headless shell through `executablePath`. Each decide or defer waits as "The end-to-end
      check" says. The Playwright MCP tools are a second way in for the session only.
    - A subagent's Bash calls do not keep a `cd` between calls, so a subagent writes every path
      absolute and runs the gate as `bash <wt>/scripts/gate.sh`, which does its own `cd`. The
      session can `cd` once into the dotfiles or drafter worktree and run plain commands there.
18. **The long blueprint.** #9's check copies
    `/var/home/glw907/Projects/cairn-cms/blueprints/docs/extend/add-a-custom-admin-screen.blueprint.md`
    (585 lines) into a temp git repo under `/var/home/glw907/.local/state/aq-docs-friction/`, with a
    notes file holding one `decide` call anchored in its last third. T2's worktree has neither the
    quote shape check nor the new slug, so the anchor is a string `<slug>.p<n>` under a heading of
    letters, digits, and spaces only, which both slug rules spell alike. It is never committed to
    approval-queue, which is public and keeps synthetic fixtures. A unit or component test that
    needs a long document generates one.
19. **Load data, fixed so T1 and T3 build against one interface.**
    - The layout's `queue` entries and the board's rows add `deferred: boolean` and
      `orphaned: boolean` (call 5).
    - The item page's `meta` carries `deferred` and `orphaned` too, and the item data adds
      `canDefer: boolean` (false for a triage, a decided item, or a deferred one).
    - A blueprint or page adds `amend?: {blob: string; original: string}` (call 9).
    - The `defer` action answers `{next}` as `decide` does, so the client's hold and goto work
      unchanged.
20. **The two new dependencies.** `github-slugger` (call 8) and `@codemirror/merge` (call 9) are
    the only additions, each the package the matching system already runs (cairn's renderer, and
    CodeMirror's own merge view), taken with `npm install <name>@<version> --prefix <wt>/approval-queue`
    so the lockfile records it. Each goes in `## Decisions` with its reason.

## Commands

Each line is written out in full where it runs, with `<wt>`, `<port>`, and `<task>` the task's own
("Names"); a prompt never carries the placeholders. Each is one command.

- Setup, in a fresh worktree: `npm ci --prefix <wt>/approval-queue`.
- Build for a port: `APPROVAL_QUEUE_PORT=<port> npm run build --prefix <wt>/approval-queue`, before
  every instance, since an earlier build in the same worktree serves another port.
- Queue an item:
  `PATH=/var/home/glw907/.local/state/aq-docs-friction/bin:$PATH APPROVAL_QUEUE_PORT=<port> XDG_STATE_HOME=/var/home/glw907/.local/state/aq-docs-friction/<task> APPROVAL_QUEUE_PROJECTS=/var/home/glw907/.local/state/aq-docs-friction/<task>/projects setsid -f <wt>/bin/.local/bin/approval-queue <kind> <args> > <decision file> 2> <stderr file>`.
  The command takes its port from `APPROVAL_QUEUE_PORT` and defaults to 7907, so a line that drops
  it reaches the live server. A blueprint or page carries `--description <file>`. A packet names
  initiative `none`.
- Queue in the foreground variant, when a step reads the queuing command's exit code: the same
  line without `setsid -f`, run through the Bash tool with `run_in_background: true`, which
  reports the exit code when the command ends. `setsid -f`'s parent exits 0 at once, so the
  detached line never shows it.
- `withdraw`, `collect`, and `anchors` run with the same environment and no `setsid -f`:
  `PATH=/var/home/glw907/.local/state/aq-docs-friction/bin:$PATH APPROVAL_QUEUE_PORT=<port> XDG_STATE_HOME=/var/home/glw907/.local/state/aq-docs-friction/<task> APPROVAL_QUEUE_PROJECTS=/var/home/glw907/.local/state/aq-docs-friction/<task>/projects <wt>/bin/.local/bin/approval-queue withdraw <id>`
  (or `collect <id>`, or `anchors <file>`). `APPROVAL_QUEUE_PROJECTS` matters to `collect`, since
  `packet_decision` reads a design part's file there for its current hash. A `collect` that waits
  runs through `run_in_background: true`.
- Seed without queuing (T3): the existing `seed-packet.ts` and `seed-blueprint.ts` fixtures, run
  the way their current callers run them (`grep -rn seed- <wt>/approval-queue <wt>/tests`), then
  start the server with `HOST=127.0.0.1 PORT=<port> APPROVAL_QUEUE_STATE=/var/home/glw907/.local/state/aq-docs-friction/<task>/approval-queue setsid -f node <wt>/approval-queue/build`.
- A form post with curl: `-H 'Origin: http://127.0.0.1:<port>' -H 'x-sveltekit-action: true'`, or
  SvelteKit's CSRF check answers 403.
- Stop: `pkill -f '^node <wt>/approval-queue/build'`, then check that
  `curl -sf http://127.0.0.1:<port>/` fails.

### CT commands

Written out for CT, task `ct`, port 7993, so no step drops a variable. `<file>` is the step's
fixture name, `<n>` the step's label (`1`, `2`, `5b`, and so on), and `<id>` the id from that
step's stderr line `approval-queue: queued <id> at http://127.0.0.1:7993/item/<id>`. Each is one
command.

- Build: `APPROVAL_QUEUE_PORT=7993 npm run build --prefix /var/home/glw907/Projects/approval-queue/.claude/worktrees/docs-friction/approval-queue`.
- The fixture repo: a git repo at `/var/home/glw907/.local/state/aq-docs-friction/ct/repo` with
  `blueprints/withdraw.blueprint.md`, `defer`, `orphan`, `claim-a`, `claim-b`, `anchors` (with a
  `:::reader` block and a bulleted section), and `amend` (at least 12 lines, so a run collapses),
  each committed, plus `/var/home/glw907/.local/state/aq-docs-friction/ct/description.md` (two
  paragraphs) and `/var/home/glw907/.local/state/aq-docs-friction/ct/anchors-notes.json`. Each git
  command runs from inside the repo.
- Queue, detached:
  `PATH=/var/home/glw907/.local/state/aq-docs-friction/bin:$PATH APPROVAL_QUEUE_PORT=7993 XDG_STATE_HOME=/var/home/glw907/.local/state/aq-docs-friction/ct APPROVAL_QUEUE_PROJECTS=/var/home/glw907/.local/state/aq-docs-friction/ct/projects setsid -f /var/home/glw907/Projects/approval-queue/.claude/worktrees/docs-friction/bin/.local/bin/approval-queue blueprint /var/home/glw907/.local/state/aq-docs-friction/ct/repo "Check step <n>" blueprints/<file> --description /var/home/glw907/.local/state/aq-docs-friction/ct/description.md > /var/home/glw907/.local/state/aq-docs-friction/ct/step-<n>.out 2> /var/home/glw907/.local/state/aq-docs-friction/ct/step-<n>.err`.
  Step 5 adds `--notes /var/home/glw907/.local/state/aq-docs-friction/ct/anchors-notes.json`.
- Queue, foreground (steps 1 and 2), through `run_in_background: true`:
  `PATH=/var/home/glw907/.local/state/aq-docs-friction/bin:$PATH APPROVAL_QUEUE_PORT=7993 XDG_STATE_HOME=/var/home/glw907/.local/state/aq-docs-friction/ct APPROVAL_QUEUE_PROJECTS=/var/home/glw907/.local/state/aq-docs-friction/ct/projects /var/home/glw907/Projects/approval-queue/.claude/worktrees/docs-friction/bin/.local/bin/approval-queue blueprint /var/home/glw907/.local/state/aq-docs-friction/ct/repo "Check step <n>" blueprints/<file> --description /var/home/glw907/.local/state/aq-docs-friction/ct/description.md > /var/home/glw907/.local/state/aq-docs-friction/ct/step-<n>.out 2> /var/home/glw907/.local/state/aq-docs-friction/ct/step-<n>.err`.
- Withdraw (steps 1 and 5):
  `PATH=/var/home/glw907/.local/state/aq-docs-friction/bin:$PATH APPROVAL_QUEUE_PORT=7993 XDG_STATE_HOME=/var/home/glw907/.local/state/aq-docs-friction/ct APPROVAL_QUEUE_PROJECTS=/var/home/glw907/.local/state/aq-docs-friction/ct/projects /var/home/glw907/Projects/approval-queue/.claude/worktrees/docs-friction/bin/.local/bin/approval-queue withdraw <id>`.
- Collect (step 2), through `run_in_background: true`:
  `PATH=/var/home/glw907/.local/state/aq-docs-friction/bin:$PATH APPROVAL_QUEUE_PORT=7993 XDG_STATE_HOME=/var/home/glw907/.local/state/aq-docs-friction/ct APPROVAL_QUEUE_PROJECTS=/var/home/glw907/.local/state/aq-docs-friction/ct/projects /var/home/glw907/Projects/approval-queue/.claude/worktrees/docs-friction/bin/.local/bin/approval-queue collect <id> > /var/home/glw907/.local/state/aq-docs-friction/ct/collect-<k>.out`,
  with `<k>` 1 and then 2.
- The orphan (step 3): `kill -KILL <the pid after the id's last hyphen>`.
- The log (step 2): `grep -c '"packet":"<id>"' /var/home/glw907/.local/state/aq-docs-friction/ct/approval-queue/decisions.jsonl`
  prints 1 after each `collect`.
- The tab log and mtime (step 4): `wc -l /var/home/glw907/.local/state/aq-docs-friction/bin/xdg-open.log`
  and `stat -c %Y /var/home/glw907/.local/state/aq-docs-friction/ct/approval-queue/tab.seen`.
- The board: `curl -sf http://127.0.0.1:7993/`.
- Stop: `pkill -f '^node /var/home/glw907/Projects/approval-queue/.claude/worktrees/docs-friction/approval-queue/build'`,
  then `curl -sf http://127.0.0.1:7993/` fails.

## Path

The longest chain run in sequence, a pair counting once at its larger estimate:

- T0, worktrees, baseline, stubs: 15.
- The pair T1 (150) beside T2 (105): 150, ending at 165.
- R1, the pair merge, the `anchors` shell case, and T1's task-scope `diff-reviewer` read with its
  fix: 15, ending at 180.
- The pair T3 (90) beside T4 (30): 90, ending at 270.
- T5, the drafter skill, once the conductor says go: 25, ending at 295.
- CT, the six-step end-to-end check, the close reviews, one fix chain, three PRs: 75, ending at
  370.

370 path minutes, under the 600-minute standing answer. The task sum is 505 (15 + 150 + 105 + 15
+ 90 + 30 + 25 + 75).

Clock: `pass-task-clock` in the pass worktree's git dir,
`/var/home/glw907/Projects/approval-queue/.git/worktrees/docs-friction`, holds the session's own
task (three lines: `task=<id>`, `start=<epoch seconds>`, `estimate=<minutes>`). When a pair
subagent returns, the session checks its minutes against twice its estimate. STATUS records T0's
start epoch, and at each task start the session compares the minutes since then, less any time
spent waiting on "start T5", against 600.

## Models

- Executor: session `approval-queue-docs-friction` on `sonnet` at `medium` (pass-core "Models").
  Conductor: `conductor-approval-queue` on `claude-opus-5-5` at `medium`.
- T1, T2, and T3: `general-purpose` subagents on `sonnet` at `medium`, each with `isolation:
  "worktree"` and the `description` `docs-friction task <n>`. Each pair runs in an agent worktree
  branched from the session's HEAD (`worktree.baseRef: "head"`), since a worktree-isolated
  session's subagents cannot write in worktrees cut by hand.
- The session does T0, R1, T4, T5, and CT itself, since dotfiles and drafter lie outside any agent
  worktree.
- Each code subagent loads `svelte-conventions`, `ts-conventions`, and the `daisyui` skill first,
  by absolute path (`/var/home/glw907/.claude/skills/<name>/SKILL.md`), since a headless agent
  can't read the skill list. It runs the svelte MCP autofixer on each `.svelte` file it writes.
- Reviewers: `diff-reviewer`, `svelte-reviewer`, and `daisyui-a11y-reviewer` from their
  frontmatter. The pass has no reference renders, so `visual-verifier` doesn't run; the session
  reads its own renders in the main loop.

## Names

Written out literally in every command and subagent prompt, never as shell variables:

- **The pass worktree:** `/var/home/glw907/Projects/approval-queue/.claude/worktrees/docs-friction`,
  branch `worktree-docs-friction`, the session's one `EnterWorktree` (name `docs-friction`).
- **The dotfiles worktree:** `/var/home/glw907/.dotfiles/.claude/worktrees/docs-friction`, branch
  `docs-friction`, cut in T0 from `/var/home/glw907/.dotfiles` with
  `git worktree add /var/home/glw907/.dotfiles/.claude/worktrees/docs-friction -b docs-friction origin/main`
  after `git fetch origin` there, each its own command.
- **The drafter worktree:** `/var/home/glw907/Projects/drafter/.claude/worktrees/docs-friction`,
  branch `docs-friction`, cut in T5 only, from `/var/home/glw907/Projects/drafter` with
  `git fetch origin` and then
  `git worktree add /var/home/glw907/Projects/drafter/.claude/worktrees/docs-friction -b docs-friction origin/main`,
  so it carries any drafter merge the gate waited for.
- **STATUS:** `docs-friction-status.md` in
  `/var/home/glw907/Projects/approval-queue/.git/worktrees/docs-friction/`, never committed. It
  holds the base commits, each worktree and branch, each subagent's start and return, each
  instance's port, each PR and head, every overrun, every gate rerun under standing answer 10, and
  the signal lines `T5-WAIT`, `READY <prs>`, and `STOP <question>`.
- **Ports:** T2 7963, T3 7973, CT 7993. State roots:
  `/var/home/glw907/.local/state/aq-docs-friction/t2`, `.../t3`, and `.../ct`.
- **The one-executor pattern:** `pgrep -af '[w]orktrees/docs-friction( |/|$)'`, anchored so it
  misses the planner's `docs-friction-plan` worktree.

## Standing answers

From the design and its approval, applied in place of stopping:

1. **Path ceiling.** The run proceeds up to 600 path minutes, twice the design's estimate. A task
   past twice its estimate writes its minutes to STATUS and goes on: the session rewrites the
   clock file's `start=` to now, runs no `notify-send`, and carries on. That answers the
   `claude-clock-stop` hook's "wait for Geoff" line. Past 600 the run stops (answer 8).
2. **Launch order.** The pass launches only after the send-back revisions pass merged, which it
   did on 2026-10-24 (`86d142d`); the pre-flight's first item checks it.
3. **The drafter gate.** T5 starts only once no open drafter PR edits `docs/blueprint-format.md`
   or a file under `claude/.claude/skills/blueprint/`:
   `gh pr list -R glw907/drafter --state open --json number,files --jq '[.[] | select(any(.files[].path; . == "docs/blueprint-format.md" or startswith("claude/.claude/skills/blueprint/"))) | .number]'`
   prints `[]`. On 2026-10-24 it printed `[]`, and no `drafter-9a` session was listed on pavilion.
   The conductor runs the check when STATUS shows `T5-WAIT`, and also asks `conductor-drafter`
   once whether the `drafter-9a` pass, which the design says edits `docs/blueprint-format.md`, has
   work on those files not yet in a PR.
   - Clear (the query prints `[]`, and the answer is "no" or no reply comes in 30 minutes): the
     conductor messages "start T5", and T5 and CT run over three PRs.
   - Not clear: the conductor messages "hold T5". CT runs over the approval-queue and dotfiles PRs
     and reports them ready. The conductor watches for the gate to clear, then messages "start
     T5"; the executor runs T5 and CT's steps for the drafter PR alone, and the drafter PR goes in
     a second packet.
   - A drafter PR that closes unmerged clears the gate as a merge does. T5 cuts from `origin/main`
     as it then stands.
4. **The slug spelling.** If the new slug rule changes a heading anchor an existing notes file
   uses, the command accepts both spellings (the design). Call 8's alias does this for every file,
   with no scan of existing notes.
5. **Review fixes.** A task-scope `diff-reviewer` `fix` on T1 is fixed and read again. A cause that
   returns after one structural fix is escalated in the PR as a `gate-failed` item, and the run
   goes on.
   - **Escalation allowed:** #9's scroll (answer 11), the amend review's editor view (answer 12),
     #19's restore after the box closes (the refusal of a second decision still lands), and any UI
     finding that is not a decision-path defect.
   - **Escalation not allowed:** calls 1 to 4 (the pid test, `withdraw`, defer, `collect` and its
     log-once rule), call 7's shape check, call 15, and call 9's command side. A returning cause
     there stops the run (answer 8).
6. **A red end-to-end step.** If a step is still red after CT's fix chain, the PR carries it as a
   `gate-failed` item, and the conductor's packet carries it as a forced ask. CT still finishes and
   the PR still goes ready. A rerun whose cause is already recorded is skipped.
7. **`main` moved.** If `origin/main` of any of the three repos moves during the run, the session
   merges it into its branch before the PR and reruns that repo's gate. Only a change that alters
   an outcome here stops the run (answer 8).
8. **A stop.** The session removes the clock file, writes `STOP <question>` into STATUS, and sends
   `conductor-approval-queue` one message naming it. It never runs `notify-send` and never asks
   Geoff. The conductor asks him.
9. **A pair merge conflict.** pass-core says a merge conflict stops the line. Here the expected
   overlaps are the README (T1 owns it, T2 rewrites the two note-anchor paragraphs) and the
   command (T1 owns it; T2 touches none of it). A conflict in a file one task owns is resolved by
   keeping both sides, the gate is run, and the resolution is named in `## Decisions`. A conflict
   that needs a choice between two behaviors stops (answer 8).
10. **A gate leg that reads live state.** Four legs read state outside the worktree that other
    sessions change mid-run. `tests/packet.test.sh`, `tests/blueprint.test.sh`, and
    `tests/page-change.test.sh` read the live
    `~/.local/state/approval-queue/decisions.jsonl`, which grows whenever any session logs a
    decision. `tests/approval-queue.test.sh` reads the live register at
    `~/.claude/docs/voice/approval-brief.md`, which changes when a dotfiles PR merges.
    - Until call 16 lands in the session's branch (R1), a red whose only failing assertion is a
      live-log size check is rerun, and STATUS records each rerun. Another session's decision is
      the traced cause, so no rerun count stops the line.
    - After call 16, a red on the new live-log assertion is a real leak: the test wrote to the live
      log. It stops the line until the test is fixed, never rerun.
    - A red in the register test right after a dotfiles merge to `main` is rerun once against the
      new register. A second red is a real failure, and the session reads the register change.
11. **#9 will not hold.** If neither CodeMirror route lands the call in view at 500 wide on the
    long blueprint, T2 records each attempt in STATUS, keeps the 500px check as the guard, and the
    PR carries #9 as a `gate-failed` item. A cause inside CodeMirror is worked around in
    approval-queue, and the session files the upstream issue in BACKLOG through `log-issue` with
    the reproduction. The run goes on.
12. **The amend view.** If `unifiedMergeView` cannot live beside the review's note and comment
    decorations (a decoration conflict, or edits it refuses), T3 falls back to `@codemirror/language`'s
    `foldEffect` over the unchanged runs and a line mark on each changed line, records why in
    STATUS, and drops `@codemirror/merge`. The PR names the fallback in `## Decisions`.
13. **Auto mode blocks an edit.** Unattended drafter and dotfiles passes have edited these skill
    files before. If auto mode still blocks an edit there, that is a stop (answer 8), and the
    conductor asks Geoff.

## Tasks

### T0: worktrees, baseline, and stubs (15 min), by the session

Risk: `runner`, no edit.

1. The one-executor checks: `pgrep -af '[w]orktrees/docs-friction( |/|$)'` prints nothing, and
   `claude agents --json` shows no other busy session in approval-queue. Then `EnterWorktree` with
   the name `docs-friction` from `/var/home/glw907/Projects/approval-queue`. Write STATUS with the
   base commit and T0's start epoch, and arm the API-drop wake-up (`/loop` with no interval) per
   `~/.claude/docs/unattended-work-guards.md`.
2. `npm ci --prefix /var/home/glw907/Projects/approval-queue/.claude/worktrees/docs-friction/approval-queue`,
   then the gate from the pass worktree. A red baseline stops (answer 8), except a live-log size
   red, which answer 10 reruns.
3. Cut the dotfiles worktree ("Names"). T4's gate is its first run there.
4. Write `/var/home/glw907/.local/state/aq-docs-friction/bin/xdg-open` (call 17, mode 755) and the
   long-blueprint repo (call 18).

- Files: none committed. Acceptance: the baseline is green, the dotfiles worktree exists, and
  STATUS is written.

### The pair: T1 beside T2

Both subagents start from the session's HEAD after T0, each in its own agent worktree, run
`npm ci --prefix <its worktree>/approval-queue` first, commit there, and never push. Each prompt
carries the scope guard, "Commands in a worktree", calls 17 and 18 quoted, the task's own calls
quoted whole, standing answer 10's first bullet quoted (T2's worktree keeps the old live-log size
checks, which T1 replaces), and its commands written out with literal paths once the subagent has
read its own worktree path with `git rev-parse --show-toplevel`. Neither subagent edits a test the
other owns to make its gate pass.

File ownership. Neither edits the other's files, with one exception: T2 rewrites the README's two
note-anchor paragraphs (the one under the blueprint kind beginning "A note's `anchor` names a
place", and the page kind's anchor sentence), and T1 owns the rest of the README.

- **T1:** `bin/.local/bin/approval-queue`, `src/lib/server/items.ts` and its test,
  `src/lib/server/packet-decision.ts` and its test, `src/lib/queue.ts` and its test,
  `src/routes/item/[id=id]/+page.server.ts` and its test, `src/routes/+layout.server.ts`,
  `src/routes/+page.server.ts` and `src/routes/page.server.test.ts`, the new `src/routes/claim/`,
  `src/lib/board.ts` and its test, `tests/` (including `page-change.test.sh`'s live-log check)
  except the new `anchors` case (R1's), and `README.md`.
- **T2:** `src/lib/editor/notes.ts` and its test, the new `src/anchors.ts`,
  `src/lib/editor/setup.ts`, `src/lib/editor/review.svelte.ts` and its test,
  `src/lib/held.svelte.ts` and its test, `src/lib/components/ItemPanel.svelte`,
  `approval-queue/package.json` and `package-lock.json`, and the README's two anchor paragraphs.

#### T1: the lifecycle, the claim, and the decision-path fixes (150 min), `sonnet` at `medium`

Risk: `runner`, decision path.

Outcome: calls 1 to 6, call 7's shape check, call 9's command and load side, and calls 12, 13, 15,
16, and 19 hold in code and tests.

- **#29 first (call 16).** Commit it before anything else, in all three shell tests, so the gate's
  live-log legs stop reading other sessions' decisions.
- **The pid, `withdraw`, and `collect` (calls 1, 2, 4).** `tests/approval-queue.test.sh` or a new
  `tests/lifecycle.test.sh` covers, in a temp state root with `curl` and `gh` stubbed as today:
  - every kind's `item.json` carries `pid` and `pidStart`;
  - `withdraw` on a waiting item exits 0, the queuing command exits 143, and `item.json` is gone;
  - `withdraw` on a dead pid (a recorded pid of a process that has exited) removes `item.json`;
  - `withdraw` on a reused pid (an `item.json` edited to name a `sleep` the test started, with a
    `pidStart` that is not the `sleep`'s) sends nothing and removes `item.json`, and the `sleep` is
    still running after;
  - `withdraw` on a deferred item whose waiter is still alive removes `item.json` and exits 0;
  - each refusal in call 2 exits 2;
  - `collect` on a decided, unlogged item logs once and prints the queuing command's line, for a
    packet, a blueprint, a page, a change, and a pr;
  - `collect` of the first decision in a state root with no `decisions.jsonl` logs it;
  - a second `collect`, and a `collect` racing the live queuing command, leave one line per part;
  - an interrupted `collect` (TERM) leaves `item.json` in place.
- **Defer (call 3).** The route test covers each refusal and the written `deferred.json`. The shell
  test covers the printed defer line, exit 0, `item.json` kept, and a later `decision.json` read by
  `collect`. `queue.test.ts` covers `nextItem` skipping a deferred item.
- **The board (call 5).** `items.test.ts` covers `deferred` and `orphaned` for a live pid (the
  test's own), a dead pid, a reused pid (the `sleep`), no pid, and a deferred item.
  `page.server.test.ts` covers the rows.
- **The claim (call 6).** A layout load test covers a poll with the matching cookie (touches
  `tab.seen`, sets the cookie with call 6's options), with another value, with none, and with no
  token file (no touch). A claim route test covers the token made once and reused, and the cookie's
  options.
- **Quote anchors, command side (call 7).** `tests/blueprint.test.sh` and
  `tests/page-change.test.sh` cover a quote anchor accepted, and each refusal: an empty quote, a
  non-string `prefix`, an unknown key, and an object anchor on a change note.
- **The amend, command and load side (call 9).** `tests/blueprint.test.sh` covers a file queued
  after an approve of it (`approved.md` written, `amends` in `item.json` and in the printed approve
  and send-back), after an approve of another file (no amend), after an approve whose blob the
  worktree lacks (no amend), and a page kind with a blueprint approve of the same path (no amend).
  The route test covers `amend` in the load data and its absence.
- **#2, #1, #28 (calls 12, 13, 15).** The route test covers the 404 load and the 410 and 404 posts
  for an unparsable `packet.json`, and 400 for a non-form `reject` and `submit`.
  `packet-decision.test.ts` covers a fingerprint that changes when a lane, a rule, or a bound part
  changes. `tests/packet.test.sh` covers `sentBack` on each log line of a send-back with one part
  set to send back and one to approve. On the resend the `gh` stub moves both parts' heads, so
  `since_diff`'s early return on an unmoved head cannot pass the case alone: the resend's
  `item.json` `revises.parts` names only the first, only it gets `since.patch`, and the
  approve-marked part's recorded head differs from its new one. One case each: a resend of only
  the approve-marked part is not a revision and is refused with `## What changed`; a note-only
  send-back's resend is a revision whose `parts` names every part; the revision number skips a
  round in which the ref was marked approve; and a log written before the pass (no `sentBack`)
  reads as today.
- **README:** `withdraw`, defer and its JSON, `collect`, the pid and the board mark, `/claim` and
  what it is for, the quote anchor's shape (beside T2's paragraphs), the amend review and
  `amends`, and the usage lines.
- **BACKLOG** is the session's at CT, not T1's.
- Acceptance: the gate is green in T1's worktree. R1 carries the `diff-reviewer` read.

#### T2: anchors, the slug, and the editor bugs (105 min), `sonnet` at `medium`

Risk: `runner`, no decision-path edit.

Outcome: calls 7 (placement), 8, 10, 11, and 14 hold in code and tests.

- **Quote placement (call 7).** `notes.test.ts` covers a quote on a bullet, on a `:::reader`
  line, on a heading, a quote that repeats with a prefix that settles it, a quote that repeats with
  none (first occurrence), and a quote that matches nothing (null range). It also covers a split
  bullet above a quote-anchored note leaving it on its line while a `p<n>` note below moves.
- **The slug and `anchors` (call 8).** `npm install github-slugger@2.0.0 --prefix <wt>/approval-queue`.
  `notes.test.ts` covers an apostrophe, a backticked word, `_x_` inside a heading, a link in a
  heading, a repeated heading (`-1`), and the old spelling's alias resolving to the same range. An
  `anchors.ts` test (vitest, calling its exported function) covers the printed lines on a fixture
  with front matter, a code block holding a `#` line, and a directive container. T2 reads cairn's
  `src/lib/render/pipeline.ts` for the page seed and drafter's `HeadingSlugs` for the blueprint
  seed, and records both in STATUS.
- **README:** the two anchor paragraphs: both shapes, the quote placement steps, the slug rule
  with the apostrophe example and the alias, and `approval-queue anchors`.
- **#9 (call 11).** On an instance at 7963, built for 7963 first, queue the long blueprint (call
  18) with the "Commands" queue line (task `t2`) and a `--description` file. At 500 wide, from the
  top, press "Next call for you": the call's line is inside the viewport after the scroll settles
  (wait for two animation frames after the window's `scrollend`, or 2 seconds). Record the
  before-and-after offsets in STATUS, before the fix (the red) and after. A unit test can't
  reproduce the height map, so the browser check is #9's test. Stop the instance by its path
  before returning.
- **#19 (call 10).** `held.svelte.test.ts` covers a refused second decision on a held item, and an
  Undo whose open is cancelled restoring once the box closes. The panel's part of the guard gets a
  component test where the existing tests reach it, else the 7963 instance's browser check, which
  presses Undo inside the 5-second hold with the pointer on the toast (the hold pauses there) and
  then reads the toast and the restore.
- **#27 (call 14).** A test in `review.svelte.test.ts` or the panel's test reproduces the restore,
  fails on `967be66`, then passes.
- Acceptance: the gate is green in T2's worktree, and STATUS holds #9's offsets at 500 wide.

### R1: the pair merge, the `anchors` case, and T1's read (15 min), by the session

The session merges T1's branch, then T2's, into `worktree-docs-friction` (standing answer 9 on a
conflict), and removes both agent worktrees. It adds the `anchors` dispatch and usage line to
`bin/.local/bin/approval-queue` (call 8: a branch placed after `app=` is set, since the `approved`
branch above it runs before `app` exists, that runs `node "$app/src/anchors.ts" "$2"` and exits
with its status), and one case to `tests/blueprint.test.sh`: `approval-queue anchors`
on a fixture heading "Set a section's starting state" prints `set-a-sections-starting-state.heading`
and the heading text. It runs the gate, then the
task-scope `diff-reviewer` read of T1's commits against calls 1 to 7, 9, 12, 13, 15, 16, and 19,
and fixes any `fix` finding (answer 5) before T3 starts. Acceptance: the gate is green and the
read returns `accept`.

### The pair: T3 beside T4

The session dispatches T3 in a new agent worktree and works T4 itself.

#### T3: the lifecycle on screen and the amend review (90 min), `sonnet` at `medium`

Risk: `runner`, no decision-path edit. It reads call 19's load data as T1 left it.

Outcome: calls 3 (the control), 5 (the screen), 9 (the editor and header), and 19 hold on screen.

- Files: `src/routes/+page.svelte` (the "Deferred" group and the orphan line), `src/lib/board.ts`
  only for the group order if T1 left it, `src/lib/components/ItemPanel.svelte` and
  `src/lib/components/frame/DecisionBar.svelte` (the Defer control, through `decide` and
  `held.hold` with a `defer` outcome, hidden when `canDefer` is false),
  `src/lib/components/frame/FrameHeader.svelte` (the amend label),
  `src/lib/components/DocEditor.svelte` and `src/lib/editor/setup.ts` (the merge view and the
  uncollapse on a jump), `approval-queue/package.json` and `package-lock.json`
  (`npm install @codemirror/merge@<newest> --prefix <wt>/approval-queue`), the claim page's
  markup if T1's needs the house layout, and their tests.
- New strings follow the editor-copy register (Microsoft style), and `## Decisions` lists each one:
  "Defer", "Deferred", "No session is waiting for this.", the amend label, and #19's toast.
- Acceptance: the gate is green. On an instance at 7973, built for 7973 first, with T1's seeds or
  queued items (a deferred item, an orphaned item, an amend blueprint with one changed clause, and
  a full blueprint), one light render at 1440 of the board and each item shows each call's layout,
  and T3 reads them. The amend render shows the changed line marked, the approved line above it,
  and a collapsed run. CT makes the full render set. `svelte-reviewer` and `daisyui-a11y-reviewer`
  run at CT on the whole branch, not here. Stop the instance by its path before returning.

#### T4: the approval-packet skill (30 min), by the session

Risk: `runner`.

Outcome: sessions learn withdraw, defer, collect, the claim, the amend review, and #28's reading
where they read them.

- File, in the dotfiles worktree: `claude/.claude/skills/approval-packet/SKILL.md`.
  - Step 6 and 7: a decision of `defer` means Geoff will decide later. The session records the
    item id in its STATUS and ends; a later session runs `approval-queue collect <id>` and acts on
    what it prints. To resend a deferred item, withdraw it first.
  - `approval-queue withdraw <id>` takes back the session's own queued item, in place of killing
    the command.
  - `approval-queue collect <id>` is also how a session picks up a decision on an item whose
    waiting session died (the board's "No session is waiting for this.").
  - Step 7's revision sentence names #28's ruling: only the parts he set to send back make a
    resend a revision, and a part he marked approve comes back as a plain row; when he set no part
    to send back, every part counts, so `## What changed` answers his note.
  - "Blueprints and pages": a blueprint or page queued again after Geoff approved it opens as an
    amend review, and its description says what changed since the approval.
  - One line: a session's browser never opens the queue's `/claim`, which marks Geoff's browser.
- Acceptance: the dotfiles gate is green. `tellgrader --register agent` on the changed lines is run
  and each finding read (advisory).
- Commit on `docs-friction` from inside the dotfiles worktree ("Commands in a worktree"); never
  push until CT.

### T5: the drafter blueprint skill (25 min), by the session, on the conductor's "start T5"

Risk: `runner`.

When T3 and T4 are done, the session writes `T5-WAIT` to STATUS, messages
`conductor-approval-queue` once, and waits for "start T5" or "hold T5" (answer 3). On "hold T5" it
goes to CT for two PRs and comes back to T5 on a later "start T5".

- Files, in the drafter worktree ("Names"): `claude/.claude/skills/blueprint/SKILL.md` (the notes
  paragraph, the queue table, and the Review section) and `new-page.md` (its notes and queue
  steps).
  - The notes paragraph gives both anchor shapes, says to use the quote form for every note below
    a heading (the design), to quote text that occurs once in the file or add a `prefix` or
    `suffix`, and that a quote can sit on a `:::reader` line. It names `approval-queue anchors
    <file>` for the heading anchors.
  - A queued blueprint can be withdrawn with `approval-queue withdraw <id>`; a `defer` decision is
    recorded in STATUS and collected later with `approval-queue collect <id>`.
  - Re-queuing an approved blueprint or page opens an amend review: its `--description` says what
    changed since the approval, and the decision carries `amends`.
- `docs/blueprint-format.md` and `claude/.claude/workflows/docs-page-chain.js`, which the design's
  file list names, carry no note-anchor text at `f2ad05e` (`grep -n -i 'notes\|anchor'` finds only
  section slugs, link anchors, and pointer anchors in the first, and no note writes in the
  second). T5 greps both again at its base and edits a line only if it then describes a note's
  anchor. The PR body says which.
- Acceptance: drafter's gate ("Risk class and repos") is green in the drafter worktree, and
  `grep -n 'anchor' claude/.claude/skills/blueprint/SKILL.md` shows the quote form.

### CT: the end-to-end check, the close reviews, and the PRs (75 min), by the session

Risk: `runner`.

1. Merge T3 into `worktree-docs-friction`, run the gate, and remove its worktree.
2. Build the fixture repo and run the end-to-end check from "Outcome" on an instance at 7993,
   built for 7993 first, with the "CT commands" lines exactly as written. Record each printed
   JSON, each exit code, and each count in STATUS. Answer 6 on a red step.
3. Run `diff-reviewer` at whole-branch scope on the approval-queue branch against the design and
   this plan, and one more `diff-reviewer` read over the dotfiles and drafter branches together,
   beside `svelte-reviewer` and `daisyui-a11y-reviewer` on the approval-queue branch. Run one
   batched fix chain that quotes each finding verbatim (location, finding, fix), then each gate
   again.
4. Close the books:
   - approval-queue `BACKLOG.md`: tick #1, #2, #9, #15, #16, #17, #19, #22, #23, #25, #26, #27,
     #28, and #29, each with a one-line note where a reading or a fallback landed. Each "Found, not
     done" item goes through `log-issue`, tagged `#initiative:approval-queue`.
   - Renders at 1440 and 390, light and dark, of the board (with a deferred and an orphaned row),
     the claim page, and an amend review, read in the main loop, kept out of the repo.
5. Push each branch to its repo, each from inside its worktree with `git push -u origin <branch>`:
   `worktree-docs-friction` to glw907/approval-queue, `docs-friction` to glw907/workstation and,
   after T5, to glw907/drafter. Open each PR ready. Each body opens with `## Brief` per
   `~/.claude/docs/voice/approval-brief.md` and carries what landed, `## Decisions` (this plan's
   contestable calls where they landed and every mid-run call), `## Planning misses`, the score
   (approval-queue PR), any `gate-failed` items, and "Found, not done" with backlog numbers. The
   approval-queue PR carries the end-to-end results. The dotfiles and drafter bodies say they merge
   after the approval-queue PR.
6. Write `READY <pr urls with heads>` in STATUS, then send `conductor-approval-queue` one message
   with each PR and head, the end-to-end result, the review verdicts, every overrun, and every
   departure from the plan. The executor never runs `approval-queue packet` and never merges.

## Close

The conductor sends one packet, initiative `approval-queue`, with the three PRs as parts (two when
answer 3 held T5, the drafter PR following in a second packet).

- **Rows and asks.** Each PR is a routine row whose Why carries its `## Decisions` lines. Only
  forced asks appear: a `gate-failed` item, a review `fix` or `escalate` left open, or a red
  end-to-end step.
- **`## If you approve`** lists the merge order and the live restart from "Merge order" as
  `[session]` steps, then:
  - `[you: open http://127.0.0.1:7907/claim once in Chromium]`: the design's one step for Geoff.
    It marks his browser as the one the queue opens items in. Until he does, every new item opens
    its own tab, as when no tab is live.
  - `[you: reload the queue tab]`: an open tab keeps the old client until it reloads.
  - `[you: other workstation]`: on the other host (`pavilion` or `thinkpad-x1`, whichever the
    conductor is not on), once no item waits in that host's queue (a command from before the pass
    ignores a defer) and before queuing there, run each as its own command:
    `git -C ~/Projects/approval-queue pull --ff-only`,
    `npm ci --prefix ~/Projects/approval-queue/approval-queue`,
    `npm run build --prefix ~/Projects/approval-queue/approval-queue`, and
    `pkill -f "^node $HOME/Projects/approval-queue/approval-queue/build"` (the next
    `approval-queue` call starts the server). Then `git -C ~/.dotfiles pull --ff-only` and
    `git -C ~/Projects/drafter pull --ff-only`, and open `http://127.0.0.1:7907/claim` once in
    Chromium there, since each host's queue keeps its own token. Skip any repo that host lacks.
- **`## Not checked`**: a `collect` after a real reboot (the pid test is covered with a dead and a
  reused pid, not a reboot), and an amend review on a long real blueprint.

## Merge order

On the packet's approve, the conductor, from `/var/home/glw907/Projects/approval-queue`, each merge
with `--match-head-commit <head>` from the decision, each step one command:

1. Check the live state root before merging. A command waiting from before the pass ignores
   `deferred.json`, so an item deferred across the restart would keep its old waiter blocked, and
   an open editor's pending save fails across a restart. So merge once no item waits (an
   `item.json` with no `decision.json` under `/var/home/glw907/.local/state/approval-queue/items/`),
   or, for the doc kinds alone, once `/var/home/glw907/.local/state/approval-queue/tab.seen` is
   more than 5 minutes old. Otherwise re-check every 10 minutes for up to 60, then go on anyway.
   The hand-over names each item still waiting then, and says its session can `withdraw` it only
   after its old command exits, since it has no `pid`.
2. approval-queue first:
   1. `gh pr merge <n> -R glw907/approval-queue --merge --match-head-commit <head>`, then
      `git pull --ff-only` in `/var/home/glw907/Projects/approval-queue`.
   2. `npm ci --prefix /var/home/glw907/Projects/approval-queue/approval-queue`, then
      `npm run build --prefix /var/home/glw907/Projects/approval-queue/approval-queue`.
   3. `pkill -f '^node /var/home/glw907/Projects/approval-queue/approval-queue/build'`.
   4. `HOST=127.0.0.1 PORT=7907 APPROVAL_QUEUE_STATE=/var/home/glw907/.local/state/approval-queue setsid -f node /var/home/glw907/Projects/approval-queue/approval-queue/build >>/var/home/glw907/.local/state/approval-queue/server.log 2>&1`.
   5. `curl -sf http://127.0.0.1:7907/` answers within 10 seconds.
3. dotfiles: `gh pr merge <n> -R glw907/workstation --merge --match-head-commit <head>`, then
   `git pull --ff-only` in `/var/home/glw907/.dotfiles` when the checkout is on `main`, holds no
   uncommitted change in a merged file, and no live session works it; otherwise report it stale.
4. drafter (when in this packet): `gh pr merge <n> -R glw907/drafter --merge --match-head-commit
   <head>`, then pull `/var/home/glw907/Projects/drafter` under the same rule as step 3. A live
   `conductor-drafter` there gets a message to pull instead.
5. Message `conductor-drafter` one line, after step 2 even when the drafter PR is held: notes can
   anchor on a quote, `approval-queue anchors <file>` prints heading anchors by cairn's slug rule,
   `withdraw`, defer, and `collect` exist, and a re-queued approved blueprint opens as an amend
   review. Send the same line to any live session `claude agents --json` shows running an
   extend-blueprints batch.
6. Remove `/var/home/glw907/.local/state/aq-docs-friction` once
   `pgrep -af '[w]orktrees/docs-friction( |/|$)'` prints nothing.

## Later

- A `send-back` verdict on one part inside an approved packet counts as a send-back for revision
  purposes (carried from the send-back plan's "Later").
- The notes check refuses a quote anchor that matches nothing or matches more than once, which
  needs the file at queue time in Node.
- `collect` records its own pid, so the board stops marking an item a `collect` waits on.
- `approval-queue anchors` prints the `p<n>` anchors too.
- Carrying a ruling across items (the design's out of scope; Geoff chose the amend review).
- A browser end-to-end lane in the gate; CT's script stays out of the repo.
