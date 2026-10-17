Initiative: approval-packets

# Approval packets pass plan

- **Records worktree**: every record this run reads or writes lives in `/var/home/glw907/Projects/initiatives/.claude/worktrees/approval-packets` (called `$W` below), on the branch `approval-packets-run`, cut from initiatives `main` once the record landed there. Never read or edit these records in the main checkout `/var/home/glw907/Projects/initiatives`: `conductor-initiatives` works there, and it is not kept on any branch of this run.
- **Design**: `$W/approval-packets/specs/2026-10-14-approval-packets-design.md`, as committed at `e910fa8`. Its "Standing answers", "Rulings given at approval", "Landing order", "Risk class and testing", "Workstation Claude infrastructure", and "Estimate" bind this plan. The fold record `$W/approval-packets/research/2026-10-14-approval-packets-fold.md` says why each mechanism exists; read it before changing one. The plan review and its fold are `research/2026-10-14-approval-packets-plan-review-mechanics.md` and `research/2026-10-14-approval-packets-plan-fold.md`.
- **Risk class**: `auth-data` (ruling 1). The approve action, the decision builder, and the command's decision handling are `auth-data` tasks: test-first, with a `diff-reviewer` task-scope read of each commit. Every other task is `runner`. No `live-account` flag: the run touches GitHub only through its own branches and PRs, and merges only on Geoff's approve.
- **Host and start**: pavilion (no lid, no battery). The user timer `approval-packets-launch.timer` started the planner `approval-queue-approval-packets-planner`; a weekly usage limit stopped the 00:01 run, and the planner ran from 08:30 on 2026-10-17. It folds the plan review, lands the record on initiatives `main`, copies the prompts to `/var/home/glw907/.local/share/approval-packets/launch/`, launches `conductor-approval-queue` with the line under "The launch", and removes the timer. The conductor runs the pre-launch checks and launches the executor `approval-queue-approval-packets`. A start this late cannot meet the 09:00 target; the standing answers still apply, and the conductor's 08:00 check fires at its launch.
- **STATUS**: `$W/approval-packets/plans/STATUS.md`, that is `/var/home/glw907/Projects/initiatives/.claude/worktrees/approval-packets/approval-packets/plans/STATUS.md`. This pass spans four repos and no repo's `docs/STATUS.md` owns it, and the record's README status lines are dated status changes, not a ledger. The conductor and the executor write and commit STATUS only there, on `approval-packets-run`, pushed to `glw907/initiatives`; the conductor writes it before the executor's launch and after PR-ready, and the executor owns it in between. At its close the conductor lands it on initiatives `main` as a self-merged hand-over PR.
- **Estimate and path**: the design's line is 720 path minutes. This plan's path is **540 minutes**, 510 of execution and 30 of hand-over, and its sum is 950 (computed under "Path"). The path is under the 720 line, so neither standing answer on the plan's size applies.

## Adapter facts for approval-queue

`approval-queue` has no adapter skill, so these stand in for one (design, "Risk class and testing").

- **Gate**: `bash scripts/gate.sh` with `REGISTER` set. Measured on 2026-10-14: 15 seconds, memory peak 900 MB, no browser, so it takes the light lane: `CAIRN_GATE_LANE=light cairn-run-gate 'REGISTER=<register> bash scripts/gate.sh'`. If the worktree session's Bash guard refuses the quoted string (as `~/.dotfiles/scripts/gate.sh` records it does), run `REGISTER=<register> bash scripts/gate.sh` directly with the Bash `timeout: 600000`.
- **Register for the branch gate**: `REGISTER=/var/home/glw907/.dotfiles/.claude/worktrees/approval-packets-register/claude/.claude/docs/voice/approval-brief.md`, the register on PR 1's branch, until PR 1 merges.
- **Fast lane**: the gate itself; it runs in 15 seconds.
- **Full-suite home**: local. The repo has no CI, so the close runs the gate once on the close head.
- **Worktree setup**: `npm ci --prefix approval-queue` in the new worktree.
- **CI watch**: none.
- **Risk-class path map**: `auth-data` covers the approve action (`approval-queue/src/routes/item/[id=id]/+page.server.ts` actions), the decision builder (the new server module that rebuilds parts and asks and writes `decision.json`), the command's decision handling (the block of `bin/.local/bin/approval-queue` that reads `decision.json`, validates it, joins heads and hashes, prints, and appends the log), and their tests. `runner` covers everything else in the repo.
- **Checklist globs**: `ts-conventions` for `*.ts`; `svelte-conventions`, `svelte-reviewer`, and `daisyui-a11y-reviewer` for `*.svelte`; the `daisyui` skill for any DaisyUI markup.
- **Close checklist**: the gate on the close head; `visual-verifier` on the board and the packet screen (task T8); the PR body's `## Brief` passes `node approval-queue/src/check-brief.ts pr <body file>`.

## Repos, worktrees, and branches

| Repo | Main checkout (never edited) | Pass worktree | Branch, base | PR | Gate |
|---|---|---|---|---|---|
| `glw907/approval-queue` | `/var/home/glw907/Projects/approval-queue` | `.claude/worktrees/approval-packets` (EnterWorktree) | `worktree-approval-packets`, `main` | PR 2 | above |
| `glw907/workstation` | `/var/home/glw907/.dotfiles` | `/var/home/glw907/.dotfiles/.claude/worktrees/approval-packets-register` | `approval-packets-register`, `origin/main` | PR 1 | `bash scripts/gate.sh` |
| `glw907/workstation` | same | `/var/home/glw907/.dotfiles/.claude/worktrees/approval-packets-infra` | `approval-packets-infra`, `origin/main` | PR 3 | `bash scripts/gate.sh` |
| `glw907/dubplate` | `/var/home/glw907/Projects/dubplate` | `/var/home/glw907/Projects/dubplate/.claude/worktrees/approval-packets` | `approval-packets`, `origin/master` | PR 4 | fast `bash scripts/gate.sh --scope-changed`; close `bash scripts/gate.sh --merge` (heavy lane) |
| `glw907/poplar` | `/var/home/glw907/Projects/poplar` | `/var/home/glw907/Projects/poplar/.claude/worktrees/approval-packets` | `approval-packets`, `origin/master` | PR 5 | `bash scripts/gate.sh` (light); CI is the full-suite home, watched with `ci-green <sha> --pr <n> --wait` |

One executor works all four repos. It first creates the other four worktrees with `git -C <repo> worktree add <path> -b <branch> <base>`, then enters the `approval-queue` worktree with `EnterWorktree`, and works in the other four by absolute path. The worktrees come first because an isolated session's `git -C` into a main checkout can be blocked (plan review, m3). It is launched with `--add-dir` for each other repo, so its file tools reach them without a prompt. Pushes name `glw907/<repo>`. The workstation adapter is `dotfiles-pass`, dubplate's is `dubplate-pass`, and poplar's is `poplar-pass`; each adapter's gate, setup, and close checklist apply to its repo's PR. `.claude/worktrees/` is already ignored in all four repos (checked 2026-10-14).

The dubplate and poplar PRs are wording changes inside this pass, not rungs of those repos' own roadmaps, so dubplate's opening dependency sweep and plan archive do not apply. Each PR body says so in one line.

## Standing answers

From the design (Geoff, 2026-10-14), applied in place of stopping:

| Situation | Standing answer |
|---|---|
| Plan path over 1,440 minutes | Launch anyway up to 2,160 path minutes; past that, stop, write STATUS, and notify. (This plan's path is 540.) |
| A task passes twice its estimate | Rewrite the clock file's `estimate=` once, to four times the original, and continue. Past four times, stop, write STATUS, run `notify-send -u normal`, and wait. |
| Merging | Every PR waits for Geoff's approve in Design & PR Approvals. The conductor merges only on approve, at the approved head. |
| Host and start | Pavilion, user timer at 2026-10-17 00:01. Lingering keeps the user manager running, but the run still needs Geoff's login session: `gh` reads its token from the keyring over HTTPS remotes, and `notify-send` and Firefox need the graphical session. A locked screen is fine. The design's "needs no login session" is wrong on this point, and this row governs. `gh auth status` succeeded from a `systemd-run --user` unit on 2026-10-17. |

From the coordinator (Geoff, 2026-10-14), added after the design:

| Situation | Standing answer |
|---|---|
| Target | By 09:00 on 2026-10-17 all five PRs are done and waiting in Design & PR Approvals: PR 1 as a `pr` item, PRs 2 to 5 as one packet. After Geoff's approve the conductor merges in landing order, rebuilds and restarts the app, pulls each main checkout, and confirms the new queue serves. The conductor is still running and waiting at 09:00; it does not end at hand-over. |
| Not PR-ready at 08:00 | The conductor sends one `notify-send -u normal` naming where the run is and what remains, and the run keeps going. Nothing is trimmed and nothing ships half-done. |
| The auto-mode classifier denies an edit | A narrow `autoMode.allow` rule (workstation PR #77) clears edits and commits to CLAUDE.md files, `claude/.claude/docs/**`, and `.claude/skills/**` inside `.claude/worktrees/` of approval-queue, `~/.dotfiles`, dubplate, and poplar for this plan's tasks. A denied edit is never retried: the session records the site in STATUS, sends one `notify-send -u normal`, continues other work, and names the site under its PR's "Not checked". |
| A repo has no backlog config | Nobody asks a setup question. Before the first follow-up in a repo without `.claude/project-tracking.json` (approval-queue and workstation today), the session writes it with ruling 2's defaults (`"backlog_path": "BACKLOG.md"`, the repo's name as its one domain, `"default_priority": "medium"`) and creates `BACKLOG.md` if missing, on that repo's pass branch. A follow-up whose domain is unknown takes the repo's name. |

## Handing over the packet before PR 2 merges

The design hands PRs 2 to 5 over as one packet, so the packet must go out while PR 2, which adds the kind, is still open. The installed command cannot send it: `~/.local/bin/approval-queue` links to the main checkout, which has no `packet` kind, and the server on `127.0.0.1:7907` is the main checkout's build, which would render a packet as an empty triage (fold record, D-M1).

The command finds its app by its own real path (`app=$(realpath "$(dirname "$(realpath "$0")")/../../../approval-queue")`), and it starts `node "$app/build"` only when nothing answers on 7907. So the conductor serves the packet from a build of PR 2's head:

1. `git -C /var/home/glw907/Projects/approval-queue worktree add --detach /var/home/glw907/Projects/approval-queue/.claude/worktrees/handover <PR 2 head>`, then `npm ci` and `npm run build` in its `approval-queue/`.
2. The conductor writes the packet at `/var/home/glw907/.local/share/approval-packets/handover/2026-10-17-packet.md` and greps it with `grep -n -i -F -f /var/home/glw907/.local/share/approval-packets/launch/privacy-patterns.txt <packet>`, which must print nothing. That local file lists the private repos and the people's names; it is never committed, since every repo here is public.
3. The hand-over worktree's own command checks the file without queuing: `.../handover/bin/.local/bin/approval-queue packet --check approval-packets <packet>`. A refusal is fixed before anything stops.
4. If `claude agents --json` lists `conductor-initiatives`, the conductor sends it one `SendMessage` saying the hand-over server will hold 127.0.0.1:7907 from the hand-over worktree and asking it not to restart 7907 until Geoff decides; if it is not listed, no message. The conductor also runs `gh pr view <n> -R glw907/<repo> --json mergeable` on all five PRs, and a `CONFLICTING` PR is fixed forward before sending.
5. `pkill -f 'approval-queue/[b]uild'` stops the running server. The state root is files, so every waiting item survives. Running the check first keeps this downtime short.
6. The same command without `--check` (`packet approval-packets <packet>`, a background Bash task) starts the hand-over build on 7907 with the same state root. The server is identified by its listener, never by `pgrep`, which would also match T8's 7917 server: `ss -ltnp 'sport = :7907'` gives the pid, and `ps -o args= -p <pid>` must name the hand-over path. If it names the main checkout, the conductor kills the packet command (its trap withdraws the item), stops that server, and sends again.

The packet command's exit sets the next act. Exit 0 prints the decision JSON, and the conductor acts on it. Exit 1 is a tool failure (the app did not answer, a head moved three times, or a `decision.json` the command rejects, such as an old server's `submit`): the conductor stops whatever holds 7907, restarts the hand-over build, and sends again. Exit 2 is a refusal: it fixes the packet or the PR it names and sends again. Exit 143 means the command was killed and its trap withdrew the item: it sends again.

Other sessions keep working throughout. Their `pr`, `design`, and `triage` commands still come from the main checkout, and the hand-over build serves those kinds unchanged, which T2 and T4 make an acceptance check. The `~/.local/bin` links are never touched. After the packet's approve, the conductor merges PR 2, pulls, rebuilds the main checkout's app, restarts the server from it, confirms it serves, and removes the hand-over worktree. Until then, each fallback tick reads the 7907 listener with `ss` and restarts the server from the hand-over build if anything else holds the port.

The conductor never calls `EnterWorktree`. It works by path, so its `git -C` into the main checkouts stays open, and it edits nothing under the approval-queue main checkout outside `.claude/worktrees/handover`. Its own files are STATUS in `$W` and the packet under `/var/home/glw907/.local/share/approval-packets/`.

PR 1 goes as a `pr` item through the installed command, as the design says. The packet's first plan step waits for PR 1 to merge, because `approval-queue` main's register test reads the live register (`~/.claude/docs/voice/approval-brief.md`, the workstation main checkout) and needs PR 1's packet exemplars once PR 2 merges.

## Dispatch note

Every pair dispatch carries these two samples verbatim (`pass-core` "Lifecycle" step 1), and anything beyond a task goes to its PR's "Found, not done" list, filed through `log-issue`:

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

Pair arms are `general-purpose` subagents at `model: sonnet`, effort `medium`, with `description` `approval-packets task <id>`. An arm in `approval-queue` takes `isolation: "worktree"`, runs `npm ci --prefix approval-queue` first, commits, and never pushes. An arm in another repo takes no isolation, since isolation would copy the wrong repo; it works in the pass worktree named in its task by absolute path, commits on that branch, and never pushes. W1 spans two repos: it takes `isolation: "worktree"` for its `approval-queue` edit and edits the register worktree by absolute path, committing in each. The session merges the `approval-queue` arms into its branch, runs the gate, and pushes every branch that moved.

The visual reference is local only: `~/.local/share/approval-packets/prototype-2026-10-14/` (`site/build.mjs`, `site/src/input.css`, `after/` for the polished screens, `shots/` for the board and gate-failed states). All five repos are public. Nothing from `packets-v2/` or the shot files is committed verbatim, and the register's exemplars replace every private repo and person's name. The names to keep out are listed in `/var/home/glw907/.local/share/approval-packets/launch/privacy-patterns.txt`, one fixed string per line, which no repo carries.

## Tasks

The order keeps the path short: each pair runs two arms whose files are disjoint, and the browser gate T8 runs in the main loop while the P3 arms run.

### P0's start: set up the run

Before dispatching P0, in the main loop and inside P0's clock (15 minutes of setup on top of the arms' 90): the four other worktrees exist on their branches, the session is in the `approval-queue` worktree, dependencies are installed, the guards are armed, and STATUS names the session. Acceptance: `git -C <each worktree> rev-parse --abbrev-ref HEAD` prints its branch; `approval-queue/node_modules` and dubplate's `web/node_modules` exist in their worktrees; STATUS names `approval-queue-approval-packets` and its id. Class `runner`.

### T1. Parse and check a packet file (pair P0, arm A)

- **Outcome**: a dependency-free parser implements "The packet file" grammar and the first states table, and `check-brief.ts packet <file>` exits 0 with the parse as JSON, or 2 with the defect and the register's path.
- **Repo and files**: `approval-queue`: a new `approval-queue/src/lib/packet.ts` and `packet.test.ts` beside `brief.ts`; `approval-queue/src/check-brief.ts`; fixtures under `approval-queue/src/lib/fixtures/` (a baseline packet and one-edit refusals); `tests/fixtures/e2e-packet.md`, the design's end-to-end packet (ask 1 bound to `#41` as `gate-failed`, ask 2 with `Part: none`, routine `#42` and `#43`).
- **Class**: runner.
- **Acceptance**: `npx vitest run src/lib/packet.test.ts` (in `approval-queue/`) passes, asserting the baseline's parsed headline, lede, tagged steps, each ask's fields, and routine rows; every row of the first states table has a one-edit fixture that asserts its exact message and the register path; `node approval-queue/src/check-brief.ts packet tests/fixtures/e2e-packet.md` exits 0 with no `node_modules` on the path; `brief.ts`'s existing tests pass unmodified.
- **Test**: vitest, as above.
- **Estimate**: 90 minutes. **Pair**: P0 with W2a.

### W2a. Write the `approval-packet` skill and point `pass-core` at it (pair P0, arm B)

- **Outcome**: the user-scope skill holds the seven-step hand-over procedure from "Workstation Claude infrastructure", naming the register and never restating it, and `pass-core` names the packet and points to the skill at each site the design lists (Lifecycle step 1, Conductor, Close's triage and hand-over, `## Before merge` and `choices`, Scope, the clock stop's attended events, Launch prompt), with the four sender-side rules.
- **Repo and files**: `workstation`, worktree `approval-packets-infra`: a new `claude/.claude/skills/approval-packet/SKILL.md`; `claude/.claude/skills/pass-core/SKILL.md`. An authored skill's manifest is its directory (`claude/.claude/docs/claude-tooling.md`, the "Skills (authored here)" row), so the skill takes no inventory entry; that doc's inventory lists third-party pieces.
- **Class**: runner. Invoke `claude-infra` and `writing-voice` first.
- **Acceptance**: `bash scripts/gate.sh` in the worktree passes; `claude-tooling-sync lint --root <worktree>` passes; `grep -n 'approval-queue pr\|approval-queue design\|approval-queue triage' claude/.claude/skills/pass-core/SKILL.md` prints no line that sends a PR, design, or follow-up list as its own item; the skill names `approval-queue packet --check <initiative> <file>`.
- **Test**: the gate (Vale and tellgrader run on each edit as hooks).
- **Estimate**: 90 minutes. **Pair**: P0 with T1.

### T2. Queue a packet and hand its decision back (pair P1, arm A)

- **Outcome**: `approval-queue packet [--check] <initiative> <file>` runs "The command" steps 1 to 6 and its decision handling exactly as the design states; the `pr` kind gains the waiting-item check; `pr` and `design` decisions append a `"lane": "single"` line.
- **Repo and files**: `approval-queue`: `bin/.local/bin/approval-queue`; a new `tests/packet.test.sh`, which `scripts/gate.sh` runs through its `tests/*.test.sh` loop, with a `gh` stub that answers by PR number from `$STUB_DIR/pr-<n>.json` (heads `aaa111`, `bbb222`, `ccc333`; failing, pending, and `MERGED` fixtures); fixtures under `tests/fixtures/`. `tests/approval-queue.test.sh` is not edited in this task.
- **Isolation from live state**: both log paths, `refusals.jsonl` and `decisions.jsonl`, derive from the command's existing `root="${XDG_STATE_HOME:-$HOME/.local/state}/approval-queue"`, never a hard-coded `~/.local/state` path. `tests/packet.test.sh` stubs `curl`, `firefox`, `setsid`, and `gh` on `PATH` as `tests/approval-queue.test.sh` does, sets `XDG_STATE_HOME` and `APPROVAL_QUEUE_PROJECTS` to temp dirs, and seeds a fixture `initiatives/<id>/initiative.yaml` under the latter, so the initiative checks never read the real records. It records the live `~/.local/state/approval-queue/decisions.jsonl` size before the run and asserts it unchanged after.
- **Class**: auth-data (the decision handling). Test-first: the decision-handling tests commit first and are recorded red, then the code. `diff-reviewer` reads each commit at task scope.
- **Acceptance**: `bash tests/packet.test.sh` passes, covering every row of the second states table with its message, the initiative refusals, `--check` queuing nothing, a `decision.json` in the server's shape printing the expected JSON with each part's own head, a design part whose file changed coming back `hold` with `"changed": true`, an unknown ref or a `submit` exiting 1 with empty stdout, and end-to-end checks 3 (command half), 4 (four log lines with the fixture's `lane`, `rule`, and `ref`), and 5 (`#43` reported `MERGED` exits 2 naming the state); `bash tests/approval-queue.test.sh` passes with `git diff main -- tests/approval-queue.test.sh` empty; `diff-reviewer` returns `accept` on each commit.
- **Test**: shell, as above.
- **Estimate**: 120 minutes. **Pair**: P1 with T4.

### T4. Read packets and authorize their approve on the server (pair P1, arm B)

- **Outcome**: the server reads packet items and enforces every rule in "The app" under "The server": `readItem` switches on the kind and 404s an unknown one, the listing skips an unparseable item, and the approve action rebuilds parts and asks from the item's files, checks the fingerprint, reads verdicts by ref and answers by label, requires the irreversible confirmation, writes `decision.json` through a per-request temp file and `link` (409 on `EEXIST`), and answers a withdrawn item with the design's message.
- **Repo and files**: `approval-queue`: `approval-queue/src/lib/server/items.ts` and `items.test.ts`; a new decision-builder module under `approval-queue/src/lib/server/` with its test; `approval-queue/src/routes/item/[id=id]/+page.server.ts` and `page.server.test.ts`.
- **Class**: auth-data. Test-first; `diff-reviewer` reads each commit at task scope.
- **Acceptance**: `npx vitest run src/lib/server src/routes/item` passes with every refusal in the design's server layer (unanswered ask, missing part, unknown ref, verdict outside the kind, unheld label, stale fingerprint, missing irreversible confirmation), a valid post writing every part once with ask-bound parts carrying their chosen tag and no held or sent-back part carrying `approve`, a reject carrying no parts, a second post returning 409, end-to-end check 2, and check 3's server half (`#42` held, `#43` approve); the existing `pr`, `design`, and `triage` cases in both test files pass unmodified, so the hand-over build serves the old kinds as today; `diff-reviewer` returns `accept` on each commit.
- **Test**: vitest, as above.
- **Estimate**: 100 minutes. **Pair**: P1 with T2.

### T5. Build the board, the sidebar, and the docs (pair P2, arm A)

- **Outcome**: `/` renders the board whenever anything waits (no redirect), as the design's board paragraph states, with the cookie sort read in `load`, replace-history links, the 2-second poll refresh, stretched links with one tab stop, and stacking below 640px; the sidebar groups packets by initiative, then lead repo, with `pr` and `design` items under "Single items"; drawer focus retries each frame until the drawer is visible. The README documents the `packet` kind, `--check`, and the decision log; the reminder hook names the packet hand-over through `approval-packet` and keeps its skip clause; `docs/decision-review/prompt.txt` and `docs/decision-review/log.md` exist as "The monthly decision review" sets out.
- **Repo and files**: `approval-queue`: `approval-queue/src/routes/+page.server.ts`, `+page.svelte`, `+layout.server.ts`, `+layout.svelte`, `page.server.test.ts`; `README.md`; `bin/.local/bin/claude-approval-queue-reminder` and `tests/claude-approval-queue-reminder.test.sh`; `docs/decision-review/`. It adds no rule to `src/lib/survey/**` or `app.css`, which T6 owns; any style it needs sits in its own component.
- **Class**: runner.
- **Acceptance**: `npx vitest run src/routes/page.server.test.ts` passes with end-to-end check 1 (`/` lists the seeded packet under its initiative) and both sort orders from the cookie; `bash tests/claude-approval-queue-reminder.test.sh` passes with the new wording; `npm run check` reports 0 errors and 0 warnings.
- **Test**: vitest and shell, as above.
- **Estimate**: 100 minutes. **Pair**: P2 with T6.

### T6. Build the packet screen and the decision bar (pair P2, arm B)

- **Outcome**: the packet screen renders the four brief parts, the asks, and the routine table as "The packet screen" states, in stock DaisyUI in the survey theme matching the prototype; the decision bar follows "The decision bar" (`aria-disabled` lock with its message and focus move, Mod+Enter only when unlocked, the 5-second hold with `pause()` and `resume()` and a status region, two rows below 640px); a decision returns the tab to `/`; the withdrawn message offers the board; the polish list's measured fixes land, except the drawer focus and board links, which are T5's.
- **Repo and files**: `approval-queue`: `approval-queue/src/routes/item/[id=id]/+page.svelte`; new packet components under `approval-queue/src/lib/components/`; `ItemPanel.svelte`; `approval-queue/src/lib/hold.ts`, `keys.ts`, and their tests; `approval-queue/src/app.html` (font preloads); `approval-queue/src/lib/survey/**` and `app.css`.
- **Class**: runner.
- **Acceptance**: `npx vitest run src/lib/hold.test.ts src/lib/keys.test.ts` passes with pause and resume and with Mod+Enter committing only when unlocked; `npm run check` reports 0 errors and 0 warnings; the `svelte` MCP autofixer reports no issue on each new component; the full gate passes.
- **Test**: vitest, as above; rendering is graded in T8.
- **Estimate**: 150 minutes. **Pair**: P2 with T5.

### W1. Rewrite the register and its test (pair P3, arm A)

- **Outcome**: `approval-brief.md` is rewritten around the packet with the four rules from "The register", keeps its `brief` and `brief-triage` exemplars, and adds three `packet` exemplars in four-backtick fences (two asks, routine-only, a `gate-failed` ask) with private names replaced; the register test's extractor matches the closing fence to the opening fence's width, sends `packet` exemplars to `check-brief.ts packet`, and asserts the three shapes from the parse.
- **Repo and files**: `workstation`, worktree `approval-packets-register`: `claude/.claude/docs/voice/approval-brief.md`. `approval-queue`: the register block of `tests/approval-queue.test.sh` only (the old kinds' cases stay unchanged).
- **Class**: runner. Invoke `writing-voice` first.
- **Acceptance**: `REGISTER=<register worktree file> bash tests/approval-queue.test.sh` passes and fails when one packet exemplar is removed (run it once to see the failure); `bash scripts/gate.sh` passes in the register worktree; `grep -n -i -F -f /var/home/glw907/.local/share/approval-packets/launch/privacy-patterns.txt <register>` prints nothing.
- **Test**: the register test, as above.
- **Estimate**: 60 minutes. **Pair**: P3 with W2b.

### W2b. Move every other queue rule to the packet (pair P3, arm B)

- **Outcome**: each remaining site in the design's "Existing pieces that change" table names the packet: `spec-plan-review` (an owner fork is a `### Decide:` block ruled as an ask), `log-issue` (ruling 2's no-questions path), the `writing-voice` router row, `docs/voice/commit-and-pr.md`, the global `CLAUDE.md` pass-process line, `docs/STATUS.md`'s follow-ups line, `BACKLOG.md` item 11, and the `dubplate` `CLAUDE.md`, `dubplate-pass`, and `poplar-pass` lines ("The design approval and the packet read"); the monthly review's `decision-review.timer` and `.service` in the `upkeep` package run a new `decision-review-notify` modeled on `check-drift-notify`, enabled in `bluefin/bootstrap.sh` beside `model-review.timer` and recorded where that timer is recorded.
- **Repo and files**: `workstation`, worktree `approval-packets-infra`: `claude/.claude/skills/{spec-plan-review,log-issue,writing-voice}/SKILL.md`, `claude/.claude/docs/voice/commit-and-pr.md`, `claude/.claude/CLAUDE.md`, `docs/STATUS.md`, `BACKLOG.md`, `upkeep/.config/systemd/user/decision-review.{timer,service}`, `bin/.local/bin/decision-review-notify`, `bluefin/bootstrap.sh`, `README.md`. `dubplate` worktree: `CLAUDE.md`, `.claude/skills/dubplate-pass/SKILL.md`. `poplar` worktree: `.claude/skills/poplar-pass/SKILL.md`.
- **Class**: runner. Invoke `claude-infra` and `writing-voice` first.
- **Acceptance**: `bash scripts/gate.sh` passes in the infra worktree; `systemd-analyze --user verify` passes on both new units; `bash -n` passes on the notify script; `grep -rn 'approval-queue pr\|approval-queue triage\|the PR read' ` over the changed files prints only the backlog-triage use the design keeps; dubplate's `bash scripts/gate.sh --scope-changed` and poplar's `bash scripts/gate.sh` pass in their worktrees.
- **Test**: each repo's gate.
- **Estimate**: 60 minutes. **Pair**: P3 with W1.

### T8. Grade the screens in a driven browser (main loop, beside P3)

- **Outcome**: end-to-end check 6 and the hand-exercised promises pass: the board and the packet screen render as the prototype does at 390 and 1440 pixels in both themes, and the lock with its focus move, Mod+Enter, the hold with its pause and status region, an override and its left rule, the recommendation reveal, the irreversible confirmation, the sort control, and the 640px stacking of the board and the bar each work.
- **Repo and files**: `approval-queue` worktree; fixes land in T5's or T6's files, which no P3 arm touches. Shots go to `/var/home/glw907/.local/share/approval-packets/t8-shots/`, the browser server's output directory.
- **Class**: runner.
- **How**: build the worktree's app and serve it with `HOST=127.0.0.1 PORT=7917 APPROVAL_QUEUE_STATE=<scratch state root>`, seeding the scratch root with the end-to-end packet the way the command writes an item. Never touch the live server on 7907, `~/.local/state/approval-queue`, or the `~/.local/bin` links. Read the browser section of `~/.claude/docs/bluefin-admin.md` first, then drive Chromium from the main loop (never Firefox) through the `playwright-chromium` MCP server, whose tools are `mcp__playwright-chromium__browser_*`. The executor's launch line loads it with `--mcp-config` from `launch/playwright-chromium.mcp.json` (`@playwright/mcp@0.0.83` with `--executable-path /usr/bin/chromium-browser --headless --isolated`; probed 2026-10-17, it navigates with no display). Never use the user-scope `playwright` server, which takes no arguments and fails on a missing `/opt/google/chrome/chrome`. If `playwright-chromium` cannot launch a browser, drive `chromium-browser` with a scratch script that imports `playwright` from the dubplate pass worktree's `web/node_modules` (pinned `1.64.0` in dubplate's `web/package.json`) with `executablePath: '/usr/bin/chromium-browser'` and `headless: true`; the repo takes no Playwright dependency. Read every shot in the main loop. At T8's end, stop the 7917 server.
- **Acceptance**: `visual-verifier`, given the shots and the prototype's `after/` and `shots/` images as separate labeled blocks, returns no STRUCTURAL finding; each promise above is exercised and recorded, with its shot or snapshot named in the PR body.
- **Test**: the gate itself.
- **Estimate**: 60 minutes. **Pair**: runs in the main loop while P3's arms run (the browser gate cannot be a subagent, since its shots are read in the main loop); the clock file names `P3+T8` at 60.

### T9. Close all five PRs

- **Outcome**: `pass-core` "Close" runs on each branch, every PR is marked ready, and STATUS says PR-ready with each PR's number and head.
- **Repo and files**: all five worktrees; STATUS; each repo's `BACKLOG.md` for follow-ups, under the standing answer for a repo with no backlog config (approval-queue has neither file, and workstation has `BACKLOG.md` but no `.claude/project-tracking.json`).
- **Class**: auth-data (the whole-branch review gives any unread `auth-data` task its read).
- **Steps**: each full-suite home is green on its head (the `approval-queue` gate; the workstation gate on both branches; dubplate's `bash scripts/gate.sh --merge` as a background task, started once W2b pushes; poplar's CI through `ci-green`). One whole-branch `diff-reviewer` per branch, run side by side. `skill-creator`'s review of `approval-packet` and `/skill-doctor` on it (if `/skill-doctor` cannot run from this session, say so under the PR's "Not checked"). `claude-tooling-sync lint --root` on the infra worktree; one `gitleaks git` branch-history scan on each workstation branch. One batched fix chain quoting each finding verbatim, then the gates again. Follow-ups filed through `log-issue` with `#initiative:approval-packets`. The privacy check runs on each of the five branches, `git -C <worktree> diff origin/<base>...HEAD | grep '^+' | grep -i -F -f /var/home/glw907/.local/share/approval-packets/launch/privacy-patterns.txt`, and on each PR body file with the same `grep -i -F -f`; each must print nothing, or each hit must be text already public on the base branch, named in the PR body. Each PR is created with `gh pr create --title <title> --body-file <file>`, since there is no TTY. Each PR body opens with `## Brief` (passing `check-brief.ts pr`), carries what landed, each `auth-data` verdict, a `## Review` section whose last backticked verdict is the whole-branch verdict, and the score, and lists no `## Before merge` unless a step is truly needed before merging.
- **Acceptance**: `gh pr view <n> -R glw907/<repo> --json isDraft,headRefOid` shows `false` and the head STATUS records, for all five; each whole-branch verdict is `accept` or overruled with its reason in the PR body; `node <aq worktree>/approval-queue/src/check-brief.ts pr <body>` exits 0 for each body.
- **Test**: the gates above.
- **Estimate**: 75 minutes. **Pair**: none.

## Path

| Step | Tasks | Path minutes |
|---|---|---|
| P0 | setup (15), then T1 (90) and W2a (90) | 105 |
| P1 | T2 (120) and T4 (100) | 120 |
| P2 | T5 (100) and T6 (150) | 150 |
| P3 | W1 (60) and W2b (60), with T8 (60) in the main loop | 60 |
| T9 | close | 75 |
| Hand-over | the conductor's packet, its checks, and the hand-over server | 30 |
| **Path** | | **540** |

The sum over every task is 950 minutes. The 09:00 target is held against the path plus the hand-over, so the hand-over line sits on the path. The chain is set by its dependencies: T2, T4, and W1 need T1's parser; T5 and T6 need T4's server data; W1's register test edit follows T2 out of `tests/approval-queue.test.sh`'s way; W2a and W2b depend on nothing and fill the workstation arms. 00:01 to 08:00 is 479 minutes of clock, and recent passes ran at a fifth to a third of plan (design, "Estimate").

## After the executor: the conductor's hand-over and merge

PR-ready ends the executor. The conductor then hands PR 1 over as a `pr` item and PRs 2 to 5 as one packet under `approval-packets`, built through the `approval-packet` skill read from PR 3's head, as "Handing over the packet before PR 2 merges" sets out. The packet's plan steps known now, in order:

1. `[session]` Wait for `glw907/workstation#<PR 1>` to merge; if Geoff holds or rejects it, stop here.
2. `[session]` Merge `glw907/approval-queue#<PR 2>` at its head; pull the checkout; `npm ci` and `npm run build` in its `approval-queue/`; restart the server from the main checkout; confirm `/` answers and `pgrep -af 'approval-queue/[b]uild'` names the main checkout.
3. `[session]` Merge `glw907/workstation#<PR 3>`; pull `~/.dotfiles`; `stow -R claude bin upkeep`; `systemctl --user daemon-reload`; `systemctl --user enable --now decision-review.timer`; `claude-tooling-sync verify`.
4. `[session]` Merge `glw907/dubplate#<PR 4>` and pull the checkout.
5. `[session]` Merge `glw907/poplar#<PR 5>` and pull the checkout.

PRs 3 to 5 merge only after PR 2 has merged, since they name a command that exists only then. No `## Before merge` step is known at plan time.

## The launch

The user timer `approval-packets-launch.timer` and its service (the unit files beside this plan) start the planner, which removes both once the conductor runs. The run needs Geoff's login session, as the standing answers say. The launch reads its prompts and the browser server's config from `/var/home/glw907/.local/share/approval-packets/launch/`, where the planner copies them from this directory: `2026-10-17-approval-packets-conductor-prompt.txt`, `2026-10-17-approval-packets-executor-prompt.txt`, and `playwright-chromium.mcp.json`. `privacy-patterns.txt` lives only there.

The planner launches the conductor from the approval-queue main checkout with exactly this line:

```sh
cd /var/home/glw907/Projects/approval-queue && /home/linuxbrew/.linuxbrew/bin/claude --bg --add-dir /var/home/glw907/.dotfiles /var/home/glw907/Projects/dubplate /var/home/glw907/Projects/poplar /var/home/glw907/Projects/initiatives /var/home/glw907/.local/share/approval-packets --model claude-opus-5-5 --effort medium --name conductor-approval-queue "$(cat /var/home/glw907/.local/share/approval-packets/launch/2026-10-17-approval-packets-conductor-prompt.txt)"
```

The conductor launches the executor from the same checkout with exactly this line. `--mcp-config` sits before `--model` because it takes several values, and `--model` ends its list:

```sh
cd /var/home/glw907/Projects/approval-queue && /home/linuxbrew/.linuxbrew/bin/claude --bg --add-dir /var/home/glw907/.dotfiles /var/home/glw907/Projects/dubplate /var/home/glw907/Projects/poplar /var/home/glw907/Projects/initiatives /var/home/glw907/.local/share/approval-packets --mcp-config /var/home/glw907/.local/share/approval-packets/launch/playwright-chromium.mcp.json --model sonnet --effort medium --name approval-queue-approval-packets "$(cat /var/home/glw907/.local/share/approval-packets/launch/2026-10-17-approval-packets-executor-prompt.txt)"
```

The `--mcp-config` file was dry-run on 2026-10-17: `claude -p --mcp-config <file> --model haiku` called `mcp__playwright-chromium__browser_navigate` on a data URL and reported its title.
