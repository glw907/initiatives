# drafter reviewed-pages plan: approval-queue approves, drafter drafts

Initiative: docs-system

Path estimate: 780 minutes against the design's 540 (1.44x), inside the 1080-minute standing
answer. 625 of them run before the morning queue; the rest follow Geoff's blueprint approval. The
arithmetic is under "Path".

Design: `~/Projects/initiatives/docs-system/specs/2026-10-21-drafter-reviewed-pages-design.md`,
approved by Geoff on 2026-10-20 (glw907/initiatives#79, merge `c21d687`), with its packet beside it.
The approved prototypes: `docs-system/prototypes/2026-10-20-review-screens/` (`c9b1882`): the
README, `blueprint-review.html` (round 8), `packet.html`, `debug-your-site.blueprint.md`,
`blueprint-notes.json`, `ledger.md`, and the 1440 and 500 PNGs. Packet step 1 is done (#79
merged). This plan carries steps 3 to 6.

One `plan-reviewer` read (mechanics and feasibility) returned 1 blocker, 9 majors, and 5 minors, all
folded: the build-time origin, the worktree chain module for the draft, the clock hook's answer,
Monitor's 30-minute deadline, a relaunch path, the per-run page cap, T1's draft-path seam and file
ownership, edits to a running command, per-task ports, the example items' refs, the admin outline
JSON, the outline's type name, the literal page command, the pid source, and three standing answers.

The planning session read each repo at: drafter `6a42564`, approval-queue `0f17cb5`, workstation
(`~/.dotfiles`) `566ca2d`, cairn-cms `52b3f979e`, initiatives `c9b1882`. Lines move; the executor
finds each quoted symbol by name.

## Pre-flight

Nothing for Geoff. The conductor checks each item just before launch; every one held at planning
(2026-10-20, about 23:30 local):

- The SessionStart hook's `## Host` line reads `pavilion`. The drafter ledger is per machine.
- `DRAFTER_API_KEY` is set in the launching environment, checked by name only, never printed.
  `~/.local/secrets` names it. (`ANTHROPIC_API_KEY` is set too; drafter does not read it.)
- `/var/home/glw907/.local/bin/drafter spend --json` shows `total` plus `open.worst` at or under
  190, so the $200 cycle ceiling leaves the draft its $10. At planning: 172.35 plus 0.997.
- `cycle_ceiling = 200` and `page_cap = 10` in `~/.config/drafter/config.toml`, and
  `~/.config/drafter/cairn-cms.local.toml` exists naming `~/.claude/workflows/docs-page-chain.js`
  as its prompts.
- `go`, `node`, `npm`, `jq`, `vale`, `gh`, `cairn-run-gate`, `ci-green`, `cairn-docs-outline`, and
  `tellgrader` resolve, and `gh auth status` answers.
- The live queue answers: `curl -sf http://127.0.0.1:7907/` exits 0. Port 7917 is free:
  `curl -sf http://127.0.0.1:7917/` fails.
- `~/.claude/docs/voice/approval-brief.md` exists (approval-queue's gate reads it).
- `mkdir -p /var/home/glw907/.local/state/aq-review` has run, so the launch's `--add-dir` names a
  real directory.
- drafter, approval-queue, cairn-cms, `~/.dotfiles`, and initiatives each sit on `main`, print
  nothing for `git status --porcelain`, and print 0 for `git rev-list --count HEAD..origin/main`
  after `git fetch origin`; `git -C <repo> check-ignore -q .claude/worktrees/x` exits 0 in each.
- No live session works any of the five repos other than the conductor and the planning session
  (`claude agents --json`). At planning, `drafter-86` (the planner's parent) was the only busy row
  in drafter.
- This plan and its two prompts are committed on initiatives `main`.

## Outcome

drafter drafts a page from an approved markdown blueprint with its drafting seat and a new final
edit pass that applies the project's editing preferences, then runs its deterministic checks; the
judging seats run only under `--judge`. `drafter check` and `refs` read the markdown blueprint
format, and cairn's eight blueprints are converted to it. approval-queue gains the blueprint, page,
and change-review kinds on one three-pane frame, with a CodeMirror 6 editor that commits each save
to the worktree and a decision log keyed to the committed blob, and the packet, PR, design, and
triage screens move onto the same frame. The workstation gains a fresh-context, read-only
`fact-checker` agent, and the `blueprint` and `approval-packet` skills carry the reviewed-pages
order. cairn's admin troubleshooting page (`docs/admin/troubleshooting.md`) goes through that flow
and merges after Geoff approves its blueprint, then its page.

End-to-end check (the design's): the troubleshooting page merges on cairn `main` after Geoff
approves its blueprint and page in approval-queue, with every fact-check finding fixed or waived,
and `drafter check` and cairn's gate green.

### Risk class and repos

The pass is `runner` (a new agent, the approval tool, skill changes), with `live-account` for API
spend only: one page's draft and edit pass, capped at $10. No GitHub, Cloudflare, or npm account is
touched beyond pushing four branches, opening four PRs, and deleting one cairn branch the design
approved. Each repo's class comes from its adapter's path map:

- glw907/approval-queue: no adapter and no path map in the repo (no CLAUDE.md, no CI). The design
  classes the approval tool `runner`, so every task here is `runner`. The decision path (the
  command's jq program, `src/lib/server/items.ts`, `src/lib/server/packet-decision.ts`, the item
  route's form actions, `src/hooks.server.ts`) is the merge-authorization boundary, so a commit
  touching it gets a task-scope `diff-reviewer` read beside the gate, as an `auth-data` task would.
  The class stays `runner`; only Geoff raises one. Gate: `bash scripts/gate.sh` (README "## Gate"),
  after `npm ci --prefix approval-queue`. Full-suite home: that gate, local.
- glw907/workstation (`~/.dotfiles`): the `dotfiles-pass` adapter, a project skill at
  `/var/home/glw907/.dotfiles/.claude/skills/dotfiles-pass/SKILL.md` (read it by path; it does not
  load outside `~/.dotfiles`). `claude/.claude/{skills,agents}/**` and `claude/.claude/docs/**`
  sit under its `runner` map for skills and agents. Gate: `bash scripts/gate.sh`. No CI.
- glw907/drafter: no adapter skill; pass-core with the repo's own gate,
  `DRAFTER_DIR="$PWD" bash scripts/drafter-gate.sh` (it runs `make check` through
  `cairn-run-gate`). The `blueprint` skill and the chain workflow make it `runner`. No CI, so that
  gate on the close head is its full-suite home.
- glw907/cairn-cms: the `cairn-pass` adapter. `blueprints/**`, `docs/**`, `drafter.toml`, and
  `BACKLOG.md` are `ordinary` in its map; no task here touches `scripts/checks/**`. Gate: the fast
  lane (`node scripts/checks/gate-tier.mjs --fast --range <base>..HEAD`) and CI on the draft PR.

### Scope guard

Every subagent prompt the session writes carries these two samples (pass-core "Lifecycle" step 1):

> "Avoid over-engineering. Only make changes that are directly requested or clearly necessary.
> Keep solutions simple and focused ... The right amount of complexity is the minimum needed for
> the current task."
> (<https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices>)
>
> "Deliver what was asked, at the scope intended. Make routine judgment calls yourself, and check
> in only when different readings of the request would lead to materially different work ...
> Finish the whole task, and stop short of actions that are clearly beyond what was asked."
> (<https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-opus-5>)

Out of scope, from the design's "Later": removing drafter's judging seats, the seven B3c pages,
backlog #33's agentic read, and a drafter-side approval gate. Harvest from the parked
`worktree-blueprint-first` branch only what T1 names; both parked drafter branches stay.

## Calls the plan makes

None changes the design's outcome, check, or bars. The contestable ones go in the named PR's
`## Decisions` and the packet's routine rows.

1. The blueprint review runs on the new approval-queue build from its worktree, on a second
   instance at `127.0.0.1:7917` with its own state root, and the conductor's packet goes to the same
   instance (contestable). Merging the tool PRs first would put unapproved code on `main`, and
   swapping the live server at 7907 to the worktree build would put it under every other session's
   packets overnight (`servers-photos` was busy at planning). A second instance leaves 7907 and its
   state untouched, and it puts the packet and the blueprint in one queue, so Geoff approves the tools
   and the blueprint in one sitting, on the restyled packet screen he is approving. Two costs: Geoff
   opens 7917, not 7907 (the command opens the tab when the first item queues, and the conductor's
   message names the address), and the review instance's decision log is appended to the live log at
   cut-over (see "Merge order"). approval-queue gains one setting for it, `APPROVAL_QUEUE_PORT`
   (default 7907), read by the command, the Host check in `src/hooks.server.ts`, and `paths.origin`
   in `vite.config.ts`. The origin is fixed at build time, so the worktree build is always built with
   `APPROVAL_QUEUE_PORT=7917` and serves only 7917, and main's build at the cut-over is built without
   it. The state root already moves with `XDG_STATE_HOME`.
2. The live app is protected by three rules the executor and every subagent follow. The README's
   `pkill -f 'approval-queue/[b]uild'` matches both instances, so nothing runs it: the review
   instance is stopped only by its full worktree path
   (`pkill -f '^node /var/home/glw907/Projects/approval-queue/.claude/worktrees/reviewed-pages/approval-queue/build'`).
   Nothing runs `npm run build` or `npm ci` in the main checkout
   (`/var/home/glw907/Projects/approval-queue/approval-queue`) before the merge. Nothing writes under
   `/var/home/glw907/.local/state/approval-queue` before the cut-over, and item
   `20261020T184211-205228` (the design packet) is never touched.
3. The page approval is the cairn PR's merge authorization. The design says "you approve the page,
   merge", and the cairn PR's files are `ordinary` in cairn's path map. The page item names the cairn
   PR and its head, and its decision prints both; the conductor merges at that head after a green CI
   and an accepted whole-branch review, with no further packet. If the session must reconcile a fact
   after Geoff's page edits (the design's "your edit to a page is final"), the head moves; the
   conductor then checks that the page blob at the new head equals the approved blob and that every
   later commit touches only the facts or the blueprint, and lists each in the cairn PR's
   `## Decisions`.
4. The decision value stays `reject` in every JSON the command prints and logs; only the button
   reads "Send back with note". The packet consumers (`approval-packet` step 7, the jq program,
   `decisions.jsonl` readers) keep working unchanged.
5. The `fact-checker` agent writes nothing. Its final message is the findings JSON, and the
   dispatching session saves it verbatim to
   `<state root>/findings/<repo>/<page path with / as __>/<commit>.json`. That keeps the agent
   read-only, as the design states, and still lands the findings under approval-queue's state
   directory keyed by page and commit.
6. Until the workstation PR merges, the agent definition lives only in the worktree, so no session
   can dispatch it as `subagent_type: fact-checker`. The session dispatches `general-purpose` on
   `claude-opus-5-5` at `medium` with the definition's body pasted verbatim as the prompt's opening,
   and checks `git status --porcelain` is empty in the checked worktree after it returns. The same
   dispatch shape serves the draft's fact check after the merge, so both checks run one prompt.
7. A blueprint is approved by its blob. The command records the blob of the file at the worktree's
   `HEAD` when Geoff approves (each save is a commit), and `approval-queue approved <path> <blob>`
   exits 0 when the log holds that approve. The `blueprint` skill runs it before any draft. A
   subcommand keeps the state root's location out of the skill, so the review instance and the live
   one answer the same way.
8. The markdown blueprint is drafter's input verbatim. Go decodes it only as far as the checks,
   `refs`, the lock's section hashes, and section scoping need: the front matter, the `:::reader`
   block, each heading as a section (its id the heading's slug, as the lock's `sections` keys are
   today), each section's italic job line, each bullet and numbered step with its `:fact[id]` tags,
   and each `:::row` with its Symptom, Cause, and Fix. The front matter's `type` is the outline's
   type name (`symptom row` for both troubleshooting pages), not the prototype's `troubleshooting`,
   which B1's documentation, T1's fixture, and D2's prompt all correct. The draft request carries the markdown text
   and the cited facts' bullets and excerpts. The YAML reader stays, so cairn's `main` keeps working
   until its PR merges and an older binary is never forced. The prototype's
   `debug-your-site.blueprint.md` is the format by example; B1 writes it into
   `docs/blueprint-format.md`.
9. The edit pass is one API request on a new `edit` seat, using the existing edit contract
   (`assemble.AnswerEdits`), after the draft holds its deterministic gate. A gate red after it goes to
   the gate-fix exchange, as a draft's does. Its prompt carries the docs standard, the project's
   register, and the preferences file verbatim. The draft prompt carries the preferences too. Both
   sit inside the page's $10 cap.
10. The cairn preferences file is `docs/internal/editing-preferences.md`, named by a new
    `[editing] preferences` setting in `drafter.toml`. It carries the showcase's tidy conventions
    (`examples/showcase/src/theme/site.config.yaml:33-38`: fixes on, Oxford comma always, smart
    quotes) and the dictionary. The showcase has no committed personal dictionary
    (`examples/showcase/src/content/.cairn/` holds none), so the file names cairn's Vale vocabulary,
    `.vale/styles/config/vocabularies/Cairn/accept.txt`, as the dictionary and the edit prompt
    receives its words (contestable).
11. The harvest from `worktree-blueprint-first` is `ddb4ef6` (the exports the excerpt code needs),
    `33f9da8` (the wider excerpt view, dotted anchors, `drafter excerpt`, the `no-excerpt` warning,
    `facts.prose_sources`), and `979b864` (a dotted anchor to a returned named function), in that
    order. The draft seat reads the same excerpts, so the troubleshooting draft sees whole
    declarations rather than "declaration not found". `33f9da8`'s hunks in
    `claude/.claude/skills/blueprint/` name the fact-truth seat and the lapse rule, which are not on
    `main`; they resolve to `main`'s text, and S rewrites the skill. drafter backlog #28 closes with
    it. Nothing of the fact-truth seat, the lock's `facts` map, or covers ids is taken.
12. drafter backlog #33 exists only on the parked branch (`061f2e0`). H files it on `main` under
    `## Done` as closed, superseded by this design, so the number is never reused. GitHub issue
    glw907/drafter#33 is a different item (fsync of the state directory) and is never touched.
13. The admin arm. cairn's CLAUDE.md says the admin arm holds no page until its stage rebuilds it,
    and Geoff's approved design names this admin page, so this pass is that stage's first page. The
    admin facts already filed under `## docs/admin/troubleshooting.md` in
    `docs/internal/facts/admin.md` are the starting set, each re-verified against the code before
    the blueprint cites it. Where cairn's gate demands an arm index entry, an `outline.yaml` track
    entry, or a `docs/internal/outlines/admin.json` entry for the index-link command, D1 adds the
    minimal one the gate or the dry run names, listed in the cairn PR's `## Decisions`.
14. Three screens the design names were not prototyped (page review, change review, the restyled
    PR screen), and neither were the design and triage restyles. All five are built on the approved
    frame and design language under standing answer 2. So Geoff sees the PR and change-review
    screens in use before the page sitting, the executor queues one example item of each on the
    review instance, titled "Example, not for approval: ...", and the conductor withdraws both after
    the morning sitting. The approval-queue PR body carries 1440 and 500 renders of all five.
15. Waits on Geoff never ride a background Bash task alone. The command's exit trap deletes
    `item.json` when the command dies, so a session lost to an API drop would take its item out of
    the queue. Each waiting command runs under `setsid -f` with stdout to a decision file, and the
    session watches that file with a Monitor `until` loop re-armed at each 30-minute deadline (see
    "Standing answers"). A relaunched or compacted session finds every decision file in STATUS.

## Path

The longest chain run in sequence, a pair counting once at its larger estimate:

- T0, launch, worktrees, baselines: 30.
- T1, the harvest and the markdown seam: 60.
- The approval-queue lane, beside the drafter lane and the session's work: A1 (150), then the pair
  A2 (90) beside A3 (180) counting 180, then A4 (90), then AM (25): 445, ending at 535.
- CT2, approval-queue's close review, fix chain, and renders: 75, ending at 610.
- Beside the approval-queue lane, the session's chain: the pair B1 (180) beside B2 (180), then BM
  (25), ending at 295; S (40), D1 (45), D2 (120), D3 (90), ending at 590. H (25), C1 (45), and CT1
  (40) run inside the pair and D2 windows, off the path.
- Q, the morning queue: 15, at the join of 610 and 590, ending at 625.
- Geoff's morning sitting (not counted).
- P1, the draft: 40. P2, the draft's fact check and settling: 60. P3, the page queue: 10.
- Geoff's page sitting (not counted).
- P4, the cairn close: 45.

30 + 60 + 445 + 75 + 15 + 40 + 60 + 10 + 45 = 780. The session's chain is 590 to the join, 20
minutes short of the approval-queue lane, so a slip there moves the queue first. Recent drafter passes
ran at a third to a half of their planned path, so the morning queue at 625 planned minutes is likely
by morning from a launch near midnight, but not certain; if it is not queued when Geoff wakes, he
reviews it when it queues (the conductor's message says so).

Clock: `pass-task-clock` in the drafter worktree's git dir,
`/var/home/glw907/Projects/drafter/.git/worktrees/reviewed-pages`, holds the session's own task.
When a subagent returns, the session checks its minutes against twice its estimate. Before each
wait on Geoff the session removes the clock file, and the wait's minutes never count.

## Models

- Executor: session `drafter-reviewed-pages` on `claude-opus-5-5` at `medium`, as drafter's last
  four live passes ran, because it settles fact-check findings against the code, conducts four repos'
  merges and gates unattended, and spends live money.
- Code subagents: `general-purpose` on `sonnet` at `medium` (A1, A2, A4, B1, B2), each loading the
  conventions its files name first: `go-conventions` for Go; `svelte-conventions`, `ts-conventions`,
  the `daisyui` skill, and the svelte MCP autofixer for approval-queue. A3 runs on `opus` at `medium`:
  it carries the decision path and the commit-on-save, which the plan specifies by contract, not by
  code.
- The blueprint author (D2) and any blueprint or fact fixer: `general-purpose` on `opus` at `high`.
- The fact check (D3, P2): `general-purpose` on `claude-opus-5-5` at `medium` with the
  `fact-checker` definition pasted (call 6).
- Reviewers: `diff-reviewer`, `svelte-reviewer`, `daisyui-a11y-reviewer`, `visual-verifier`, and
  `prose-voice-reviewer` from their frontmatter.

A headless agent cannot read `~/.claude/skills` (drafter backlog #2), so every subagent prompt
names the skill and prototype files by absolute path.

## Names

Written out literally in every command and subagent prompt, never as shell variables:

- The drafter worktree: `/var/home/glw907/Projects/drafter/.claude/worktrees/reviewed-pages`,
  branch `worktree-reviewed-pages` (the session's one `EnterWorktree`, name `reviewed-pages`). The
  binary, built there by `make build`: `/var/home/glw907/Projects/drafter/.claude/worktrees/reviewed-pages/drafter`,
  written `BIN` in this plan only.
- STATUS: `reviewed-pages-status.md` in the drafter worktree's git dir, beside the clock file. It is
  never committed. It holds the host, the spend baseline, each worktree and branch, each subagent's
  start and return, each PR, the review instance's port and pid, each queued item id and its decision
  file, and one line per wait (`WAIT geoff <what> <item id>`) that the conductor reads.
- The approval-queue pass worktree:
  `/var/home/glw907/Projects/approval-queue/.claude/worktrees/reviewed-pages`, branch
  `reviewed-pages`, cut from `origin/main`. A2's and A3's worktrees beside it: `.../reviewed-pages-a2`
  and `.../reviewed-pages-a3`, branches `reviewed-pages-a2` and `reviewed-pages-a3`, cut from the
  pass branch's head after A1, never pushed.
- The review instance: the worktree's command,
  `/var/home/glw907/Projects/approval-queue/.claude/worktrees/reviewed-pages/bin/.local/bin/approval-queue`,
  always run with `APPROVAL_QUEUE_PORT=7917 XDG_STATE_HOME=/var/home/glw907/.local/state/aq-review`.
  Its state root is `/var/home/glw907/.local/state/aq-review/approval-queue`, and it serves
  `http://127.0.0.1:7917/`. Every `npm run build` in an approval-queue worktree runs with
  `APPROVAL_QUEUE_PORT=7917` (call 1). If 7917 is taken at T0, the session uses 7918 everywhere this
  plan says 7917 and writes it in STATUS.
- The workstation worktree: `/var/home/glw907/.dotfiles/.claude/worktrees/reviewed-pages`, branch
  `reviewed-pages`, cut from `origin/main`. The main checkout is live through stow and is never
  edited.
- The cairn worktree: `/var/home/glw907/Projects/cairn-cms/.claude/worktrees/reviewed-pages`,
  branch `reviewed-pages`, cut from `origin/main`; its start commit is `CAIRN_BASE` (52b3f979e at
  planning; T0 records the real one).
- The page: `docs/admin/troubleshooting.md`; its blueprint:
  `blueprints/docs/admin/troubleshooting.blueprint.md`.

## Standing answers

From the design and Geoff's rulings on 2026-10-20, applied in place of stopping:

1. The run proceeds up to 1080 path minutes, twice the design's 540. A task past twice its estimate
   writes its minutes to STATUS and goes on while the working minutes since T0's start, less the two
   waits on Geoff, stay under 1080. Past 1080 the run stops. The `claude-clock-stop` hook's line
   ("Write STATUS, run `notify-send -u normal`, and wait for Geoff") is answered by this standing
   answer: write the minutes to STATUS, rewrite the clock file's `start=` to now, run no
   `notify-send`, and carry on.
2. Page review, change review, and the restyled PR screen were not prototyped (nor the design and
   triage restyles); they are built on the approved frame and design language with no further
   sitting, and Geoff reviews them in the running tool when he approves the troubleshooting page's
   blueprint and page.
3. A prototype round, or any round of Geoff's notes on a screen or a document, that ends without his
   approval starts the next round; there is no cap. A send-back on the blueprint or the page is fixed
   forward from its note, the touched lines are fact-checked again, and the item is queued again.
4. A fact-check finding the author disputes goes to Geoff on the review screen with the author's
   note, never resolved between agents. Every other finding is fixed before Geoff sees the item, and
   an author question goes to him as a question note. Loop guard: three fact-check rounds on one
   document. Past it, the run goes on while each round fixes a cause the session has traced; a
   finding that returns after its fix gets one structural fix (the line or the fact rewritten from the
   code), and if it returns again it goes to Geoff as a question note. Any finding may go to Geoff
   that way without breaking the outcome.
5. A draft over its $10 cap stops the draft and reports; nothing retries on credit. A redraft after
   a failed deterministic check counts as drafting and sits inside the cap, and the cap covers every
   run of this page in the pass together. drafter enforces `page_cap` per run
   (`internal/ledger/ledger.go`, `Reserve`), so every run after the first, and every resume, sets
   `DRAFTER_PAGE_CAP` to 10 minus this page's spend so far from `BIN spend --json`, recorded in STATUS.
   A dry run whose worst case passes what remains is the same stop.
6. A red the session traces to this branch's own commits is fixed forward on the branch; a gate
   that exits 75 is re-issued. Only a red from `origin/main` the branch can't fix stops the line.
7. A tool PR Geoff sends back is fixed forward from his note, relayed by the conductor. If the fix
   changes drafting after the page is drafted, the page redrafts inside standing answer 5's cap.
8. B2 keeps `editing.preferences` out of `internal/pipeline/fingerprint.go`; the existing seat loop
   covers the `edit` seat's settings, and a resume after a preferences edit is the documented cost,
   listed in the drafter PR's `## Decisions`. If auto mode refuses H's remote branch delete, the session
   records it in STATUS and the conductor runs the delete after the packet's approve.
9. These stop and ask (STATUS carries one question; the executor waits for the conductor): spend
   that would pass $10 for the page or $200 for the cycle, the path ceiling, a cause the session
   cannot trace, a finding that changes the design, an edit to `internal/pipeline/money.go` or
   `internal/pipeline/fingerprint.go`, and any destructive act this plan does not name. The cairn
   branch deletion in H is named (packet step 4) and needs no question.

The waits on Geoff are the design's two sittings, not stops. Each is a `WAIT geoff` line in STATUS
with no clock file, and the executor watches its decision file; the conductor sends Geoff nothing
for them beyond the morning message and the page notice (see "Close"). A Monitor watch lasts at
most 30 minutes, so each wait is `until [ -s <decision file> ]; do sleep 30; done` with a 1800000 ms
timeout, re-armed on every deadline notice, and the `/loop` tick checks every decision file STATUS
lists. A deadline notice is never a stop.

## Tasks

### T0: launch, baseline, and worktrees (30 min), by the session

1. The one-executor checks: `pgrep -af '[w]orktrees/reviewed-pages'` prints nothing; `claude agents
   --json` shows no session working the five repos but the conductor and this one; no
   `reviewed-pages` worktree exists in any of the four code repos. Repeat the pre-flight's host,
   spend, and port lines.
2. `EnterWorktree` named `reviewed-pages` in drafter. Arm the API-drop wake-up (`/loop` with no
   interval) and the guards `~/.claude/docs/unattended-work-guards.md` names. Run the drafter gate
   once. Invoke the `visual-fidelity` skill now, since approval-queue's screens must match the
   prototypes.
3. Create the other worktrees with `git -C <repo> worktree add -b reviewed-pages
   .claude/worktrees/reviewed-pages origin/main` in approval-queue, `~/.dotfiles`, and cairn-cms.
   Setup: approval-queue `npm ci --prefix approval-queue`; cairn the cairn-pass setup (`npm ci &&
   npm ci --prefix examples/showcase && (cd examples/showcase && npx svelte-kit sync)`); dotfiles
   none. Copy `~/.config/drafter/cairn-cms.local.toml` into the cairn worktree as
   `drafter.local.toml` (ignored at `.gitignore:33`), with its `prompts` line changed to
   `prompts = "/var/home/glw907/Projects/drafter/.claude/worktrees/reviewed-pages/claude/.claude/workflows/docs-page-chain.js"`,
   since the user-scope link points at drafter's main checkout, which carries no `edit` seat and no
   markdown input until the drafter PR merges.
4. Baselines, each recorded in STATUS: approval-queue `bash scripts/gate.sh` through
   `cairn-run-gate`; `bash scripts/gate.sh` in the dotfiles worktree; in cairn,
   `/var/home/glw907/.local/bin/drafter check` (0 errors) and `CAIRN_GATE_LANE=light cairn-run-gate
   'npm run check:facts'`. A red baseline goes to standing answer 6.
5. Record the spend baseline (`/var/home/glw907/.local/bin/drafter spend --json`, `total` and
   `open.worst`) in STATUS.

- Files: none committed. Risk class `runner`. Acceptance: each step's output in STATUS.

### T1: the harvest and the markdown seam (60 min), by the session, drafter

Outcome: the harvest (call 11) on the pass branch, and the markdown types B1 and B2 both build on,
committed before the pair branches.

1. `git cherry-pick ddb4ef6 33f9da8 979b864`, resolving `33f9da8`'s skill hunks to `main`'s text.
   Regenerate any golden whose bytes move only by excerpt content, with its `git diff --stat` in the
   commit message. Move backlog #28 to `## Done`.
2. Add `internal/blueprint/markdown.go`: the suffix `.blueprint.md` beside `.blueprint.yaml` in
   `BlueprintPath`, `PagePath`, and discovery (`.md` wins when both exist; both is a `drafter check`
   error B1 adds); the types `Markdown{Front Front; Text string; Reader Reader; Sections []MDSection}`,
   `Front{Page, Type, Track, Exemplar string}`, `MDSection{ID, Heading string; Level, Line int; Job
   string; Lines []MDLine; Rows []Row}`, `MDLine{Line int; Text string; Facts []string}`, `Row{Line
   int; Symptom, Cause, Fix string; Facts []string}`; and `DecodeMarkdown(file string, data []byte)
   (*Markdown, []plan.Finding)` reading the front matter, headings, and `:fact[id]` tags, with the
   directive blocks left to B1. Its doc comment states the contract B1 completes.
3. The adapter B2 drafts through, stubbed with its doc comment and a working minimum: `(*Markdown)
   View() plan.Plan` (the shape `internal/blueprint/view.go`'s `View` returns for YAML),
   `(*Markdown) CodeSources() []string`, and `(*Markdown) SectionIDs() []string`, plus one
   `blueprint.Load(file string, data []byte)` that returns either form behind the methods the draft
   path calls, so `cmd/drafter/pagebp.go`, `cmd/drafter/draftscope.go`, and the pipeline take a
   markdown blueprint through one seam. File ownership after T1, each file to one task: B1 owns
   `internal/blueprint/{markdown,view,hash,drafted,seed,check,refs,convert}.go`; B2 owns
   `cmd/drafter/{page,pagebp,draftscope}.go` and `internal/pipeline/page.go`, where today
   `p.markdown` and `p.blueprint` test only the `.yaml` suffix, so a `.blueprint.md` would fall into
   the markdown-plan path until B2 fixes it.

- Files: the cherry-picked files, `internal/blueprint/markdown.go` and its test, `BACKLOG.md`.
  Risk class `runner`. Acceptance: the drafter gate green; `BIN excerpt` on a dotted pointer from
  cairn prints the inner declaration. Test: a table test decoding the prototype's front matter and
  three headings from a synthetic fixture.

### The drafter pair: B1 beside B2 (180 min), each `general-purpose` on `sonnet` at `medium`

Dispatched together with `isolation: "worktree"` after T1's commit, `description`
`reviewed-pages task B1` and `... task B2`. Each loads `go-conventions` first, commits, never pushes.
`internal/pipeline/money.go` and `internal/pipeline/fingerprint.go` are never edited;
`internal/pipeline/resume.go` may be edited test-first, with a task-scope `diff-reviewer` read of
each commit that touches it (the B3 ruling).

#### B1: the markdown blueprint reader, its checks, `refs`, and the converter

Outcome: `drafter check` and `drafter refs` read `.blueprint.md`, and `drafter convert markdown`
writes one from a `.blueprint.yaml`.

- The directive reader: a line scanner in `internal/blueprint/markdown.go` (goldmark has no
  directive extension) for `:::reader`, `:::row` (with `**Symptom.**`, `**Cause.**`, `**Fix.**`
  lines), and inline `:fact[id]`, skipping fenced code, completing `DecodeMarkdown`.
- The checks, in `internal/blueprint/check.go` beside the YAML ones: front matter `page` (the
  page's title), `type`, and `track` present, the page path the blueprint's own path maps to listed in
  `outline.yaml`, and `type` matching that entry; one `:::reader` block; each section has its
  italic job line; each `:::row` carries all three parts; headings unique by slug; each `:fact` id
  in the store, with the existing fact-source checks applying; both a `.md` and a `.yaml` for one page
  is an error.
- The lock: section hashes and `drafter seed` work on a markdown blueprint, keyed by heading slug
  (`_intro` for the reader block and the text before the first `##`), so the existing scope code
  (`blueprint.Scope`, `changedSections`) reads it unchanged.
- `drafter refs f:<id>` lists each markdown line and row citing the id by `file:line`.
- `drafter convert markdown <blueprint.yaml>...`: writes the `.blueprint.md` beside it in the
  prototype's shape, deletes the YAML, and rewrites that page's lock entry (`blueprint` blob and
  `sections`) so a converted page with an unchanged page file stays up to date. It refuses a page
  whose lock entry is stale before conversion.
- `docs/blueprint-format.md` documents the format from the prototype; the YAML section stays,
  marked as the older format.

- Files: `internal/blueprint/{markdown,view,hash,check,refs,drafted,seed,convert}.go` and tests,
  `cmd/drafter/{check,refs,convert}.go`, `docs/blueprint-format.md`, synthetic fixtures under
  `internal/blueprint/testdata/`. Risk class `runner`.
- Acceptance: `make check` green; a synthetic markdown blueprint with one of each defect gets one
  finding each; converting a synthetic YAML fixture yields a file `drafter check` passes whose
  sections and fact ids equal the YAML's; `BIN page --dry-run` on the converted fixture reports it
  up to date.
- Test: table tests per check, a converter golden, a lock round trip.

#### B2: the narrowed `drafter page`, the edit pass, and the preferences

Outcome: `drafter page` defaults to the draft seat, the new edit pass, and the deterministic checks;
`--judge` restores today's seats.

- Narrowing: with no `--judge`, `drafter page` on a blueprint skips the blueprint read and the
  consistency read whatever the lock says (`SkipRead` true), runs no review round, reader, coverage,
  or coherence request, and accepts on the deterministic gate after the edit pass. A section redraft
  runs its section exchange, the gate, and the edit pass. `--judge` runs the configured `seats` as
  today. The help text and `docs/configuration.md` say which seats run when.
- The edit seat: `edit` joins `seatNames` (`internal/config/check.go`), `[seat.edit]` joins
  `internal/config/stock.toml` (`claude-opus-5-5`, `medium`, 32000), and the step runs once after the
  draft's gate holds, through the edit exchange (call 9). A gate red after it goes to gate fix.
- Preferences: a new `[editing] preferences = "<path>"` setting, project layer, a repo-relative
  file; `drafter config` shows it; a named file that does not exist refuses the run. The draft and edit
  prompts carry it verbatim.
- Prompts: both modules render the `edit` seat and accept a markdown blueprint's text: the stock
  module (`stock/prompts.js`) and the chain's (`claude/.claude/workflows/docs-page-chain.js`), with
  `make chain-test` and `make prompts-parity` green. `drafter check-prompts` covers the new seat.
- `cmd/drafter/page.go`: `isBlueprintArg` takes `.blueprint.md`; the `--judge` flag.

- Files: `internal/pipeline/{steps,blueprint,check,page,work,handle}.go` and tests (resume.go only
  as above), `internal/config/*`, `internal/prompts/*`, `stock/prompts.js`, `stock/stock_test.go`,
  `claude/.claude/workflows/docs-page-chain.js`, `tests/*.mjs`, `cmd/drafter/{page,pagebp,draftscope}.go`
  and tests,
  `docs/configuration.md`, `README.md`. Risk class `runner`.
- Acceptance: `make check` green; on the synthetic e2e project, a fake-API run of `drafter page` on
  a `.blueprint.md` with no flag sends exactly the draft and edit requests and accepts on the gate; with `--judge` it sends
  today's sequence; a gate red after the edit runs one gate-fix exchange.
- Test: pipeline flow tests on the fake API for both paths; config tests for `editing.preferences`.

### BM: merge, gate, build (25 min), by the session

Merge B1's and B2's branches (a conflict stops the line), run the drafter gate, `make build`. Check
`BIN check` from the cairn worktree reads the YAML blueprints as before (0 errors).

### H: housekeeping (25 min), by the session, inside the pair window

Packet steps 4 and 5.

1. In the cairn worktree, file one item through the `log-issue` convention in `BACKLOG.md` under
   `## Medium`, numbered past the highest (`#28` at planning): "Fix the 23 real fact defects the
   blueprint-first read found at `main`", tagged `#bug` `#cairn-cms` `#initiative:docs-system`,
   dated 2026-10-21, its description pointing at
   `docs-system/research/2026-10-20-blueprint-first-r2/` in glw907/initiatives (the new-catch rows
   of `R2a-classes.md`, `R2b1-classes.md`, and `R2b2-classes.md`) and naming the fact ids. Commit it
   first on the cairn branch.
2. Remove `/var/home/glw907/Projects/cairn-cms/.claude/worktrees/blueprint-first-pages` (clean at
   planning, at `2a12578f6`; check `git status --porcelain` is empty and no process holds it first),
   then `git -C ~/Projects/cairn-cms branch -D blueprint-first-pages` and `git -C
   ~/Projects/cairn-cms push origin --delete blueprint-first-pages`. Record the deleted tip in STATUS
   and the cairn PR body. The branch's only content is lock commits from the escalated reads.
3. In the drafter pass branch, file #33 under `## Done` per call 12.

- Files: cairn `BACKLOG.md`, drafter `BACKLOG.md`. Risk class `ordinary`. Acceptance: `git
  ls-remote origin blueprint-first-pages` prints nothing; both entries follow the BACKLOG format.

### C1: the workstation half (45 min), by the session, inside the pair window

Outcome: the `fact-checker` agent and the `approval-packet` order, in the dotfiles worktree. Read
the `claude-infra` skill and `~/.claude/docs/claude-tooling.md` first, and cite the sub-agents page
(<https://code.claude.com/docs/en/sub-agents>) in the definition and the commit, as
`plan-reviewer.md` does.

- `claude/.claude/agents/fact-checker.md`: `model: claude-opus-5-5`, `effort: medium`, `tools:
  Read, Grep, Glob, Bash`. It reads one blueprint or page and the repository at a named commit,
  checks each fact or claim against the code, and returns one JSON array, each element `{id, line,
  claim, verdict, source, proposed}`, with `verdict` one of `holds`, `wrong`, `imprecise`, and
  `unsupported`, `source` a `file:line`, and `proposed` the corrected sentence. It never edits a
  file, never fixes, and never runs in the session that wrote the document.
- `claude/.claude/docs/claude-tooling.md`: the agent joins the reviewer list that names
  `claude-opus-5-5`.
- `claude/.claude/skills/approval-packet/SKILL.md`: a blueprint and a page are their own queue items
  (`approval-queue blueprint`, `approval-queue page`), never packet parts; a code PR whose blueprint
  and page edits ride in it gets one `approval-queue change` review unless the change adds or removes
  a section or changes the reader's path; and the order, in one short section pointing at the
  `blueprint` skill.

- Files: those three. Risk class `runner`. Acceptance: `bash scripts/gate.sh` green in the worktree;
  `prose-voice-reviewer` accepts the two prose files. Test: the gate.

### The approval-queue lane

Each subagent is `general-purpose`, works in its named approval-queue worktree by absolute path
(no `isolation`, which would cut a drafter worktree), commits there, and never pushes. Each prompt
names the prototype files by absolute path under
`/var/home/glw907/Projects/initiatives/docs-system/prototypes/2026-10-20-review-screens/`, says
`ledger.md`'s "Already right" list is not re-audited, quotes call 2's three rules, and runs the gate
through `cairn-run-gate` from its worktree. Each task's throwaway instance takes its own port and a
temp state root, so two never collide: A1 7927, A2 7937, A3 7947, A4 7957, each built with that
`APPROVAL_QUEUE_PORT`. The task stops its instance by its full worktree path before it returns, and
never runs the pattern the command's port-clash error suggests. A commit touching the decision path gets the task-scope
`diff-reviewer` read before the next task branches.

#### A1: the frame, the shell, and the packet screen (150 min), `sonnet` at `medium`, in the pass worktree

Outcome: every item screen renders inside one three-pane frame matching the prototypes, and the
packet screen is on it.

- The frame from `blueprint-review.html` and `packet.html`: the queue rail pinned left (the
  prototype's rail rows, kinds, and ages), the work centered at reading width, the review pane pinned
  right (calls for you, parts or corrections, outline), the Survey header (crumb, benchmark triangle,
  headline, lede, contour texture, using `src/lib/survey`'s `.site-benchmark` and
  `.site-contour-texture`), the sticky bottom bar ("Send back with note" and "Approve ..."), the keys
  (F8 next call, Ctrl+Enter approve, `?` help), the pane as a modal drawer below 1260px and the rail
  below 1024px. It replaces the drawer shell in `src/routes/+layout.svelte` and the bar in
  `ItemPanel.svelte`; the 5-second hold with Undo and the irreversible confirm stay.
- The packet screen (`PacketBrief`, `PacketAsks`, `PacketRoutine`) restyled to `packet.html`, with
  "Reject with note" renamed "Send back with note" (call 4).
- `APPROVAL_QUEUE_PORT` (call 1) in the command, `src/hooks.server.ts`, and the served origin,
  default 7907, with a test that 7907 behaves as today.

- Files: `src/routes/+layout.svelte`, `src/lib/components/{ItemPanel,PacketBrief,PacketAsks,PacketRoutine}.svelte`,
  new frame components under `src/lib/components/frame/`, `src/app.css`, `src/hooks.server.ts`,
  `vite.config.ts`, `bin/.local/bin/approval-queue`, tests. Risk class `runner` (the Host check is on
  the decision path).
- Acceptance: the gate green; a packet seeded from `tests/fixtures/e2e-packet.md` on a throwaway
  instance at 7927 renders at 1440 and 500, a real browser form POST (send back, then approve on a
  second item) succeeds there, and `visual-verifier` finds no STRUCTURAL difference from
  `packet-1440.png`; `tests/packet.test.sh` passes unchanged, so the packet decision JSON is the same.

#### A2: the PR, design, and triage screens on the frame (90 min), `sonnet` at `medium`, paired with A3

Outcome: `PrView`, `DesignView`, and `TriageView` render inside the frame in the same design
language: the Survey header, the work at reading width, the review pane holding the decide cards,
evidence, or row groups, and the shared bar.

- Files: `src/lib/components/{PrView,DesignView,TriageView,BriefBlock,DecideCards,DetailRows,Disclosure}.svelte`
  and their tests. It does not touch `ItemPanel.svelte`, the routes, or the server. Risk class
  `runner`.
- Acceptance: the gate green; each screen renders from the existing fixtures at 1440 and 500 with no
  horizontal scroll at 320; `svelte-reviewer` and `daisyui-a11y-reviewer` accept.

#### A3: the blueprint kind, the editor, the notes, and the decision log (180 min), `opus` at `medium`, paired with A2

Outcome: `approval-queue blueprint` queues a markdown blueprint in an editable review that matches
`blueprint-review.html`, and the decision lands in the log keyed to the committed blob.

- The command form: `approval-queue blueprint <worktree> <title> <file> [--notes <notes.json>]`,
  `<file>` relative to `<worktree>`. It refuses a file that is not committed or a worktree with
  uncommitted changes to it, and a notes file that does not match `blueprint-notes.json`'s shape
  (`id`, `kind` of `info`, `decide`, or `question`, `anchor`, `title`, `body`, optional `was`, `now`,
  `sides`, `choices`).
- The screen: the document in a CodeMirror 6 editor modeled on cairn's (`markdown({ base:
  markdownLanguage })`, line wrapping, a highlight style, and directive marking ported from cairn's
  `src/lib/admin/markdown-directives.ts` regexes and `editor-highlight.ts`'s `cairnDirectivePlugin`,
  with a provenance comment); notes inline under the line their anchor names; the review pane's calls,
  corrections, and outline; save on pause and on Ctrl+S, each save a commit in `<worktree>` (`git -C
  <worktree> commit -- <file>`, message "Edit <file> in review"). The CodeMirror packages are taken
  through the `dependency-upgrade` skill at their newest production versions and bundled, since the
  CSP allows only self.
- The decision: approve prints `{"decision":"approve","file":...,"commit":...,"blob":...,"calls":[{"id":...,"choice":...}]}`
  with the blob at the approving commit; send back prints `{"decision":"reject","note":...}`. Each
  writes one `decisions.jsonl` line (`kind` `blueprint`, `ref` `<worktree's repo>:<file>`, `blob`,
  `commit`, and each waived note with its reason).
- `approval-queue approved <file> <blob>` (call 7), and README sections for the new forms.

- Files: `bin/.local/bin/approval-queue`, `src/routes/item/[id=id]/+page.server.ts`,
  `src/lib/server/items.ts`, `ItemPanel.svelte`'s kind dispatch only, new
  `src/lib/components/{BlueprintView,DocEditor,NoteCard,ReviewPane}.svelte` and `src/lib/editor/*.ts`,
  `approval-queue/package.json` and its lockfile, `README.md`, tests, a synthetic fixture under
  `src/lib/fixtures/`. Risk class `runner`, with the task-scope `diff-reviewer` read.
- Acceptance: the gate green; on a throwaway instance at 7947 with a temp state root and a temp git
  repo holding the prototype's `debug-your-site.blueprint.md` and `blueprint-notes.json`, an edit
  commits through a real browser save, Ctrl+Enter approves through a real form POST, the printed blob equals `git rev-parse HEAD:<file>`, `approved` exits
  0 for it and 1 for the previous blob, and a decide note's choice appears in `calls`;
  `visual-verifier` finds no STRUCTURAL difference from `blueprint-review-1440.png` and `-500.png`.
- Test: vitest for the decision and log paths, a shell test in `tests/` for the command form.

#### A4: the page and change-review kinds (90 min), `sonnet` at `medium`, in the pass worktree after A2 and A3 merge

Outcome: the page review and the change review reuse A3's editor, notes, and pane on the frame.

- `approval-queue page <worktree> <title> <file> --pr <owner/repo#n> [--notes <notes.json>]`: the
  drafted page in the editor with its notes, the PR and its head shown and printed in the decision
  (call 3), the same log line with `kind` `page`.
- `approval-queue change <owner/repo#n> <title> [--notes <notes.json>]`: one review for a code PR
  carrying blueprint and page edits, the changed blueprint and page shown as documents with their
  diffs and notes, the code diff as the PR screen shows it. Built and tested against a fixture made
  from a past cairn change that edited a blueprint and its page (the executor picks it from `git -C
  ~/Projects/cairn-cms log -- blueprints docs/extend` and names it in the PR body).

- Files: `bin/.local/bin/approval-queue`, the item route, `items.ts`, new `PageView` and
  `ChangeView` components, tests, fixtures. Risk class `runner`, with the task-scope read.
- Acceptance: the gate green; each kind queues, edits, approves, and logs on a throwaway instance;
  renders at 1440 and 500 pass `daisyui-a11y-reviewer`.

#### AM: merge and build (25 min), by the session

Merge `reviewed-pages-a2` and `reviewed-pages-a3` into the pass branch after A1, then A4's commits
land there; run the gate; `APPROVAL_QUEUE_PORT=7917 npm run build --prefix approval-queue` in the
pass worktree only. Push to
glw907/approval-queue and open the draft PR.

### S: the skill (40 min), by the session, drafter, after BM

Outcome: the `blueprint` skill carries the reviewed-pages order and the markdown format.

- `claude/.claude/skills/blueprint/SKILL.md` and `new-page.md`: a new page runs author the blueprint
  from the code (the `.blueprint.md` format, facts filed or re-verified first), fact-check it with a
  fresh agent (the `fact-checker` definition), fix or dispute every finding, queue it with
  `approval-queue blueprint`, draft only after `approval-queue approved` exits 0 for its blob
  (`drafter page`, no `--judge`), fact-check the draft, settle, queue `approval-queue page`, merge. An
  established page whose code changed: the blueprint and page edits ride in the code PR with one
  `approval-queue change` review, unless the change adds or removes a section or changes the reader's
  path, when the blueprint change is approved first. API credit pays for drafting only.
- `format.md` stays the symlink to `docs/blueprint-format.md`; `anatomies.md` and
  `introductions.md` change only where they name YAML fields.

- Files: the skill directory. Risk class `runner`. Acceptance: `prose-voice-reviewer` accepts; the
  drafter gate green.

### CT1: the drafter and workstation close reviews (40 min), by the session, inside D2's window

`diff-reviewer` at whole-branch scope on each branch against the design and this plan, with the
`go-conventions` checklist for drafter; one batched fix chain per branch quoting each finding
verbatim; the gate again. Push glw907/drafter and glw907/workstation and open both draft PRs, bodies
opening with `## Brief`.

### D1: cairn's setup and conversions (45 min), by the session, after BM

1. `BIN convert markdown` on the eight blueprints (listed by `ls blueprints/docs/*/*.blueprint.yaml`),
   then `BIN check` 0 errors and `BIN page --dry-run` on each converted blueprint reporting it up to
   date. A converted file that reads wrong against the prototype's shape is fixed by hand and the
   cause folded into B1's converter on the drafter branch.
2. `docs/internal/editing-preferences.md` (call 10) and `[editing] preferences` in `drafter.toml`;
   `BIN config` from the cairn worktree shows it.
3. The outline entry for `docs/admin/troubleshooting.md` (type `symptom row`, its job, covers, and
   out-of-scope written from the register's "The admin track" and the debug page's "What it leaves to
   other pages"), a minimal `docs/internal/outlines/admin.json` holding that one page (the index-link
   command reads it and exits 2 without it), and any minimal index or track entry call 13 allows.

- Files: `blueprints/**`, `blueprints/drafted.lock`, `drafter.toml`,
  `docs/internal/editing-preferences.md`, `blueprints/outline.yaml`. Risk class `ordinary`.
- Acceptance: `BIN check` 0 errors; `cairn-docs-outline link --worktree
  /var/home/glw907/Projects/cairn-cms/.claude/worktrees/reviewed-pages --outline
  docs/internal/outlines/admin.json --page docs/admin/troubleshooting.md` exits 0; the cairn fast lane
  green. Push glw907/cairn-cms (branch
  `reviewed-pages`) and open its draft PR; CI watch per cairn-pass.

### D2: the troubleshooting blueprint, built from the code (120 min), by the session with one author subagent

One `general-purpose` author on `opus` at `high` writes
`blueprints/docs/admin/troubleshooting.blueprint.md` in the cairn worktree, editing only that file and
`docs/internal/facts/admin.md`, never committing, never running a live command. Its prompt names, by
absolute path: the skill's `SKILL.md`, `new-page.md`, `format.md`, and `anatomies.md` in the drafter
worktree; `docs/internal/docs-register.md` ("The admin track" and the editor brief it names); the
prototype's `debug-your-site.blueprint.md` as the format exemplar; the existing facts under
`## docs/admin/troubleshooting.md` in `docs/internal/facts/admin.md`; and the debug page's
blueprint for the boundary between the two pages. Each fact it cites is re-verified against the code
and re-pointed or minted (`node scripts/checks/check-facts.mjs --mint`) where needed. The session
runs `BIN check` and `npm run check:facts`, commits once `git status --porcelain` names only those
files, and pushes.

- Risk class `ordinary`. Acceptance: `BIN check` 0 errors and `check:facts` OK at the commit.

### D3: the blueprint's fact check, settled (90 min), by the session

1. Dispatch the fact check (call 6) on the blueprint at its commit; save the findings (call 5).
2. Settle each finding as the author: fix it (the author subagent from D2, resumed with the
   findings, or the session for a one-line fix), dispute it with a note, or raise it as a question.
   A fix that edits a fact runs `BIN refs f:<id>` first and lists the citers in STATUS.
3. Fact-check the fixed lines again, loop per standing answer 4, until no finding is unsettled.
4. Write the notes file in `blueprint-notes.json`'s shape: `info` with `was` and `now` for each fix,
   `decide` with `sides` and `choices` for each dispute, `question` for each author question; anchors
   in the prototype's `<heading-slug>.p<n>` form. Commit and push the blueprint.

- Risk class `ordinary`. Acceptance: every finding has a disposition; `BIN check` and `check:facts`
  green at the commit.

### CT2: approval-queue's close review, fixes, and renders (75 min), by the session, after AM

`visual-verifier` on every screen against the prototype PNGs (separate labeled blocks) and, for the
unprototyped five, against the frame's devices; `diff-reviewer` at whole-branch scope with
`svelte-reviewer` and `daisyui-a11y-reviewer`; one batched fix chain quoting each finding verbatim;
the gate and the build again (`APPROVAL_QUEUE_PORT=7917 npm run build --prefix approval-queue`).
Renders at 1440 and 500 of every screen go in the PR body. A STRUCTURAL
verdict left after the fix chain is a `gate-failed` ask in the packet, never a silent pass.

### Q: the morning queue (15 min), by the session

1. Start the review instance on the final build: if one runs, stop it by its full path (call 2),
   check `curl -sf http://127.0.0.1:7917/` now fails and no throwaway instance (7927 to 7957) still
   runs; the worktree command starts it on the next queue. From here on, the worktree's
   `bin/.local/bin/approval-queue` changes only through a task worktree and `git merge` (git replaces
   the file, so a waiting command keeps reading its old copy; bash reads a script as it runs), and the
   review build is replaced only when no item at 7917 waits. Check `curl -sf http://127.0.0.1:7907/` still
   answers and the live server's pid is unchanged.
2. Remove the clock file. Queue the blueprint under `setsid -f` (call 15):
   `APPROVAL_QUEUE_PORT=7917 XDG_STATE_HOME=/var/home/glw907/.local/state/aq-review setsid -f <the
   worktree command> blueprint /var/home/glw907/Projects/cairn-cms/.claude/worktrees/reviewed-pages
   "Approve the plan for Troubleshooting" blueprints/docs/admin/troubleshooting.blueprint.md --notes
   <notes file> > /var/home/glw907/Projects/drafter/.git/worktrees/reviewed-pages/blueprint-decision.json 2>&1`.
   Queue the two example items (call 14) the same way to their own decision files: a `pr` item naming
   glw907/approval-queue#3 and a `change` item naming the merged cairn PR behind A4's fixture (both
   merged, neither a packet part), so the packet's waiting-item check never refuses a part. Write each item id in STATUS; its pid is the id's suffix
   after the dash (the command's `$$`), checked with `ps -p`.
3. Mark the drafter, approval-queue, and workstation PRs ready; their bodies carry `## Decisions`,
   `## Planning misses` (if any), and the score so far. Write `WAIT geoff blueprint <item id>` in
   STATUS, then a `READY tools` line naming the three PRs and their heads, and send conductor-drafter
   one message saying the same, with the blueprint's item id. Then watch the decision file with Monitor; do not edit the cairn worktree while
   the review is open, since Geoff's saves commit there.

### P1: the draft (40 min, live), by the session, after the blueprint approval

1. On `approve`: check `approval-queue approved blueprints/docs/admin/troubleshooting.blueprint.md
   <blob>` exits 0 against the review state root; check the cairn worktree's `HEAD` holds Geoff's
   saves and his call choices; run `BIN check`. A choice that asked for a rewrite the screen did not
   apply is applied now and listed in the cairn PR's `## Decisions`. On `reject`: standing answer 3.
2. Meter: `BIN spend --json`; `total` plus `open.worst` plus 10 at or under 200, else standing
   answer 9. `BIN page --dry-run blueprints/docs/admin/troubleshooting.blueprint.md` from the cairn
   worktree: worst case at or under what remains of the $10 cap, else standing answer 5.
   Before the meter, `BIN check-prompts` from the cairn worktree is green, which shows the worktree
   chain module renders the `edit` seat.
3. `DRAFTER_PAGE_CAP=10 BIN page blueprints/docs/admin/troubleshooting.blueprint.md`, in the
   background, logging to the git dir; record the run id and spend in STATUS. Exit 0 goes to P2. Exit 1
   (an escalation, a cap stop among them) goes to standing answer 5 for a cap and to a traced fix and
   a new run under standing answer 5's remaining cap otherwise. Exit 3 resumes in full:
   `DRAFTER_PAGE_CAP=<10 minus spend so far> BIN page --resume <run id>
   blueprints/docs/admin/troubleshooting.blueprint.md`. Exit 2 (could not start) is traced and fixed
   before any rerun.

### P2: the draft's fact check, settled (60 min), by the session

As D3, on `docs/admin/troubleshooting.md` at its commit, with the author's fixes made by hand edits
to the page (and the blueprint or fact where a claim was wrong at its source); then cairn's docs gate
for the page (`npm run check:docs-gate -- --page docs/admin/troubleshooting.md --brief <its brief>`
through `cairn-run-gate`) green, and the notes file written.

### P3: the page queue (10 min), by the session

Queue the page on the live instance if the approval-queue PR has merged and 7907 runs the merged
build (the `CUTOVER` line in STATUS, written from the conductor's message), else on the review
instance. `<n>` is the cairn PR's number from STATUS. The review form:
`APPROVAL_QUEUE_PORT=7917 XDG_STATE_HOME=/var/home/glw907/.local/state/aq-review setsid -f
/var/home/glw907/Projects/approval-queue/.claude/worktrees/reviewed-pages/bin/.local/bin/approval-queue
page /var/home/glw907/Projects/cairn-cms/.claude/worktrees/reviewed-pages "Approve the page for
Troubleshooting" docs/admin/troubleshooting.md --pr glw907/cairn-cms#<n> --notes <file>`. The live
form, after `CUTOVER`: the same with no environment prefix and
`/var/home/glw907/.local/bin/approval-queue` as the command. Either runs under `setsid -f` to
`page-decision.json` in the drafter worktree's git dir. Remove the clock file, write `WAIT geoff page
<item id>` with the address, and send conductor-drafter the same line.

### P4: the cairn close (45 min), by the session, after the page approval

On `approve`: Geoff's edits are final; where one changed a claim, update the blueprint or the fact in
the same PR. The cairn fast lane and CI green; `diff-reviewer` at whole-branch scope with the
cairn-pass checklists, scoped to the hand-written files (the page, the blueprint, the facts, the
preferences file, the outline entry, the backlog item; the eight conversions by their `BIN check`
result and the converter's tests); `prose-voice-reviewer` on the page; one fix chain. Mark the cairn
PR ready, write `READY cairn <head> <approved blob>` in STATUS, and send conductor-drafter the
same line. On `reject`:
standing answer 3.

## Close

The executor's close is CT1, CT2, Q, and P4: every PR's full-suite home green, one whole-branch
review per PR, the fix chain, and PR bodies opening with `## Brief` and carrying what landed, the
`## Decisions` (this plan's calls 1 to 15 where they touched that PR, and every mid-run call), the
`## Planning misses`, the score, and each "Found, not done" item filed through `log-issue` with its
number. The executor never runs `approval-queue packet` and never merges; conductor-drafter hands
over and merges.

### What goes in the packet

One packet, sent by the conductor with the review instance's command once Q reports, so it lands
beside the blueprint item at 7917 by morning. Initiative `docs-system`. Parts, in merge order:
glw907/approval-queue#n, glw907/workstation#n, glw907/drafter#n. The cairn PR is not a part; the
Background says it follows the page approval (call 3).

- Routine rows by default, one per PR, each carrying its `## Decisions` one line apiece: call 1 (the
  second instance and the cut-over), call 4, calls 5 and 6, call 7, calls 8 to 11, call 14 and the
  unprototyped screens under standing answer 2, the harvest, and the narrowing's `--judge`.
- Forced asks: a PR with a failing gate, a review verdict of `fix` or `escalate`, a STRUCTURAL
  visual verdict left open, or a `## Before merge` section. None is expected.
- `## If you approve`: the merges in "Merge order", then `[you: other workstation]`: on
  `thinkpad-x1`, pull drafter and run `make install`, pull approval-queue and rebuild it, and pull the
  dotfiles, before running drafter or the queue there. A line in the Background says the blueprint
  review sits beside this packet in the same queue, and that the page review follows the draft.
- `## Not checked`: how the page review reads on Geoff's own edits, which the page sitting measures.

## Merge order

On the packet's approve, the conductor, from each main checkout:

1. glw907/approval-queue with `--match-head-commit <head>`. Then in
   `/var/home/glw907/Projects/approval-queue`: `git pull --ff-only`, `npm ci --prefix approval-queue
   && npm run build --prefix approval-queue`, stop the live server by its exact path (`pkill -f
   '^node /var/home/glw907/Projects/approval-queue/approval-queue/build'`), and start it with the
   command's own line (`HOST=127.0.0.1 PORT=7907 APPROVAL_QUEUE_STATE=/var/home/glw907/.local/state/approval-queue
   setsid -f node /var/home/glw907/Projects/approval-queue/approval-queue/build >>/var/home/glw907/.local/state/approval-queue/server.log 2>&1`),
   then check `curl -sf http://127.0.0.1:7907/` answers within 10 seconds. Waiting items survive the
   restart, since their state is on disk. Send the executor one message naming the cut-over; it
   writes the `CUTOVER` line in its STATUS.
2. glw907/workstation with `--match-head-commit <head>`; `git -C ~/.dotfiles pull --ff-only` (the
   agent and the skill are live at once); `claude-tooling-sync verify`.
3. glw907/drafter with `--match-head-commit <head>`; pull; check `BIN`'s state dir holds no
   unfinished run from this pass other than the page draft (hold `make install` on a hit); `make
   install`.
4. After the page approval (P4): glw907/cairn-cms with a merge commit (never squash or rebase) and
   `--match-head-commit <head>`, checked per call 3, stopping on a `drafted.lock` conflict rather than
   resolving it by hand; pull `~/Projects/cairn-cms`; `drafter check` there 0 errors.

The review log's cut-over, in this order: the conductor withdraws the two example items by
stopping their commands (the pid is each item id's suffix; the exit trap removes `item.json`); checks
no item at 7917 waits (every item dir with an `item.json` has a `decision.json`); appends
`/var/home/glw907/.local/state/aq-review/approval-queue/decisions.jsonl` to the live
`/var/home/glw907/.local/state/approval-queue/decisions.jsonl` under `flock` on the live
`queue.lock`; and stops the review instance by its full path. The cairn page's approval
then logs on whichever instance held it, and an approval logged at 7917 reaches the live log at this
step.

## Later

- Remove drafter's judging seats (the design's "Later").
- The review instance's `APPROVAL_QUEUE_PORT` may become a general multi-instance setting; nothing
  else uses it now.
- `drafter-page-hook` matches only `<page>.blueprint.yaml`, so after cairn's conversion a page edit
  loses its blueprint pointer. S fixes it if the hook lives in drafter's `bin/.local/bin/` (it does:
  `make install` links it); otherwise it is filed under "Found, not done".
