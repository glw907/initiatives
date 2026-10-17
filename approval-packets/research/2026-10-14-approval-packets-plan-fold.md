# Fold of the approval-packets plan review

The planner `approval-queue-approval-packets-planner` folded `research/2026-10-14-approval-packets-plan-review-mechanics.md` into the plan, the executor and conductor prompts, and STATUS on 2026-10-17. The timer fired at 00:01, a weekly usage limit stopped that run, and this fold ran from 08:30. Every mechanism below was probed in this session, never stated from memory. Geoff's rulings on the forks (M1, M3) and the record layout (B1) are from 2026-10-14.

## Probes run

- `npx -y @playwright/mcp@latest --version` prints `Version 0.0.83`, and `--help` lists `--executable-path`, `--headless`, `--isolated`, and `--output-dir`.
- Over stdio with no `DISPLAY` or `WAYLAND_DISPLAY`, `@playwright/mcp@0.0.83 --executable-path /usr/bin/chromium-browser --headless --isolated` answered `browser_navigate` on a data URL with its title.
- `claude -p --mcp-config plans/playwright-chromium.mcp.json --model haiku` called `mcp__playwright-chromium__browser_navigate` and reported the page title, so the config file loads under `claude`.
- `claude --help` shows `--mcp-config <configs...>`, which takes several values.
- dubplate's `web/package.json` pins `"playwright": "1.64.0"`, on the checkout and on `origin/master`.
- `systemd-run --user --wait -P gh auth status` succeeds: logged in as glw907, keyring token, HTTPS.
- `ss -ltnp 'sport = :<port>'` prints the listener's `pid=` (checked on a scratch listener; nothing held 7907 at the time).
- `scripts/gate.sh` in approval-queue runs every `tests/*.test.sh`, and the command sets `root="${XDG_STATE_HOME:-$HOME/.local/state}/approval-queue"`.
- `.claude/project-tracking.json` is missing in approval-queue and workstation; approval-queue also has no `BACKLOG.md`.
- `claude-tooling.md` gives an authored skill's manifest as "the directory itself".
- `~/.claude/settings.json` carries the M1 `autoMode.allow` rule, and workstation PR #77 is merged.
- `claude agents --json` lists no `conductor-initiatives`; `--all` shows it exited.

## Dispositions

| Finding | Disposition | Where |
|---|---|---|
| B1 | Folded as Geoff ruled. The record lands on initiatives `main` through a self-merged PR; the launch reads its prompts from `~/.local/share/approval-packets/launch/`; STATUS lives in the worktree `$W` on `approval-packets-run`, cut from `main` after that merge. Every prompt names the `$W` paths. | Plan header, "The launch"; both prompts; STATUS |
| B2 | Already handled: the live unit carries `KillMode=process`. The conductor records its id in STATUS. | Launch unit; STATUS |
| B3 | Folded: nobody asks; the session writes ruling 2's config and `BACKLOG.md` on the repo's pass branch before its first follow-up there; an unknown domain takes the repo name. | Plan "Standing answers", T9; executor prompt |
| B4 | Folded, with a pinned version where the review named `@latest`: `plans/playwright-chromium.mcp.json` runs `@playwright/mcp@0.0.83` against `/usr/bin/chromium-browser`, headless and isolated, with absolute `npx` and `PATH` so it never depends on the launching shell. Its `--output-dir` keeps snapshot files out of the worktree, since the probe wrote `.playwright-mcp/` into its working directory. The executor line loads it with `--mcp-config` before `--model`. The fallback imports `playwright` 1.64.0 from the dubplate pass worktree. | Plan T8, "The launch"; both prompts |
| M1 | Folded as Geoff ruled: the allow rule is live, and the never-retry backstop is a standing answer in the plan and both prompts. The reminder hook script in approval-queue (T5) is a hook, which the rule does not cover, so it falls to the backstop if denied. | Plan "Standing answers"; both prompts |
| M2 | Folded: only approval-queue must be level; the others report "behind" and launch; the conductor's and the planner's rows do not block the pull. | Conductor prompt step 2 |
| M3 | Folded as Geoff ruled: one `SendMessage` to `conductor-initiatives` if listed, and `gh pr view --json mergeable` on all five PRs, before the hand-over. | Plan "Handing over" step 4; conductor prompt 5g |
| M4 | Folded: both logs derive from the command's existing `root`; `tests/packet.test.sh` stubs `curl`, `firefox`, `setsid`, and `gh`, points `XDG_STATE_HOME` and `APPROVAL_QUEUE_PROJECTS` at temp dirs with a fixture record, and asserts the live log unchanged. | Plan T2 |
| M5 | Folded, with the names kept out of the public record: they live in the local `launch/privacy-patterns.txt`, which W1, T9, and the conductor grep with `-F -f`. T9 greps only the added lines of each branch diff, so context lines that already name a public mention do not trip it. | Plan W1, T9, "Handing over" step 2; both prompts |
| M6 | Folded: `--check` runs before `pkill`; exits 0, 1, 2, and 143 each set the next act; the 7907 server is found by its listener with `ss` and `ps`, never `pgrep`; T8 stops its 7917 server. | Plan "Handing over", T8; conductor prompt 5h to 5j and 6 |
| M7 | Folded: the run needs Geoff's login session, and a locked screen is fine; `gh auth status` from a unit is probed. The design's "needs no login session" is left as approved, and the plan's standing-answers row says it governs. | Plan "Standing answers" |
| m1 | Folded: `gh pr create` carries `--title` and `--body-file`. | Plan T9; both prompts |
| m2 | Folded where the launch now lives: the timer's unit already refuses to start a second planner or conductor, and the planner checks `claude agents --json` for a live `conductor-approval-queue` before it launches one. | Launch unit; planner Task 5 |
| m3 | Folded: the conductor never calls `EnterWorktree` and edits only STATUS, the packet, and the hand-over worktree. The executor creates its four other worktrees before it isolates. | Plan "Repos", "Handing over"; both prompts |
| m4 | Not folded (optional, not among the free ones). The plan already names the direct `REGISTER=<path> bash scripts/gate.sh` form as the fallback. | |
| m5 | Folded: a 30-minute hand-over line sits on the path. | Plan "Path", header |
| m6 | Folded: W1 takes isolation for its approval-queue edit and edits the register worktree by path. | Plan "Dispatch note"; executor prompt |
| m7 | Not folded (optional): the adapters' close checklists stand as written. | |
| m8 | Folded: the design is cited at `e910fa8`. | Plan header |
| m9 | Not folded (optional): the command's decision handling already validates refs, verdicts, and heads (T2), and the merge pins `--match-head-commit`. | |
| m10 | Not folded (optional): `pass-core` and the guards doc already require the full re-arm after a restart. | |
| m11 | Folded: W2a takes no inventory entry; the skill's directory is its manifest. | Plan W2a |
| m12 | Folded: T2 records that `scripts/gate.sh` runs `tests/packet.test.sh` through its `tests/*.test.sh` loop. | Plan T2 |
| O1 | Stays, as Geoff ruled: the adapters mandate the reviews and dubplate's `--merge` gate. | |
| O2 | Folded: T0 becomes P0's setup, inside P0's clock. | Plan "Tasks", "Path"; executor prompt |

## Path and sum

The path is 540 minutes: 105 for P0 with its setup, 120, 150, 60, 75 for the close, and 30 for the hand-over. The sum is 950, the earlier 920 plus the hand-over. Both sit under the design's 720-minute line, so the plan launches without a standing answer on its size.
