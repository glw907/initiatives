# Mechanics and feasibility review: approval-packets pass plan

Target: `approval-packets/plans/` (plan, executor and conductor prompts, STATUS, launch units) on `approval-packets-design` at `25d8fa1`. Reviewer: `plan-reviewer` (Opus, medium). Probes ran in the session scratchpad; the real timer was never installed.

Verdict: not ready to arm. Four blockers, each with a cheap fold.

## Verified and holds

- Unit quoting: `systemd-analyze --user verify` passes; an argument-dumper dry run split `--add-dir` (five paths), `--model claude-opus-5-5 --effort medium --name conductor-approval-queue`, and the prompt as one 11,170-byte argument; working directory correct; `systemd-analyze calendar` gives Sat 2026-10-17 00:01 AKDT.
- Unit PATH resolves node, npm, npx, gh, jq, cairn-run-gate, ci-green, claude-tooling-sync, notify-send, gitleaks, flock, setsid, curl, stow, vale, tellgrader, chromium-browser; mise `lts` is node 24.21.0.
- `claude --bg`, `--add-dir`, `--model`, `--effort`, `-n/--name` exist in 2.1.299; workspace trust is recorded for all five checkouts (an untrusted one exits "Workspace not trusted" with no dialog).
- Default branches: approval-queue and workstation `main`; dubplate and poplar `master`. `.claude/worktrees/` ignored in all four. Gate scripts exist. Lingering on.
- The 08:00 check works, including a relaunch after 08:00 (negative sleep exits at once; a marker stops a second notify).
- PR 1 breaks nothing on main: the old extractor opens on three-backtick `brief` fences only (`tests/approval-queue.test.sh:221-224`).
- T5 and T6 files are disjoint. Subagent frontmatter `model` beats `CLAUDE_CODE_SUBAGENT_MODEL`; subagents inherit MCP tools.
- Merge authority: each conductor merge waits on a decision JSON with `--match-head-commit`; the executor never merges.

## Blockers

- **B1 (correctness).** The launch inputs exist only on an unpushed branch in a checkout another live conductor (`conductor-initiatives`) works in; `initiative.yaml` exists only on that branch, so a checkout on `main` makes the packet command refuse the initiative. Fold: push; land the record on initiatives `main` as a self-merged hand-over PR; give STATUS its own worktree and repoint the unit and prompts, or copy the prompts to `~/.local/share/approval-packets/launch/`.
- **B2 (correctness).** `Type=oneshot` with default `KillMode` kills the background supervisor and the conductor if `claude --bg` starts the supervisor inside the unit's cgroup (the supervisor exits when idle and restarts on demand). Probe: `setsid -f sleep` died under oneshot and survived with `KillMode=process`. Fold: `KillMode=process`; the conductor writes its id into STATUS first.
- **B3 (correctness).** The live `log-issue` asks setup questions where `.claude/project-tracking.json` is missing (approval-queue, workstation), and ruling 2's no-questions path ships in an unmerged PR; a question parks a background session until 09:00. Fold: the executor prompt says nobody asks; before the first follow-up in a repo, write the config with ruling 2's defaults and `BACKLOG.md` on that repo's pass branch; an unknown domain takes the repo name.
- **B4 (correctness).** T8's browser: the user-scope Playwright MCP has no arguments and fails on a missing `/opt/google/chrome/chrome` (headed by default); the named fallback under `site/` has no `node_modules`. Probe: Playwright with `executablePath: '/usr/bin/chromium-browser'`, headless, no display, works; `@playwright/mcp` 0.0.83 takes `--executable-path`, `--headless`, `--isolated`. Fold: an `--mcp-config` server `playwright-chromium` on the executor launch line (before `--model`, since the option is variadic); the fallback imports `playwright` from the dubplate pass worktree's `web/node_modules` (pinned 1.64.0); dry-run the MCP line before arming.

## Majors

- **M1 (correctness, OWNER FORK).** The auto-mode classifier can block edits to CLAUDE.md files and Claude docs (Self-Modification, Instruction Poisoning); three blocks in a row pause a background session. Today's `autoMode.allow` covers only skill files in `~/.dotfiles` worktrees, and dubplate and poplar are outside it. Options: (a) a narrow allow rule for this pass, (b) a never-retry backstop only, (c) accept. Recommend (a) with (b) as backstop.
- **M2 (correctness).** The pre-launch level check is too strict: only approval-queue must be level (the others branch from fetched `origin/<default>`), and the conductor's own row blocks its own pull. Fold: level only for approval-queue; report others "behind" in STATUS and launch; exempt the conductor's own row.
- **M3 (correctness, OWNER FORK).** `conductor-initiatives` is live: it restarts 7907, re-hands items after restarts, checks the serving build path, and writes workstation `docs/STATUS.md`. Options: (a) hold while it's live, (b) launch and coordinate (one `SendMessage` at hand-over, plus `gh pr view --json mergeable` on all five PRs). Recommend (b).
- **M4 (correctness).** T2's fixtures are underspecified: without the existing test's stubs (`curl`, `firefox`, `setsid`, `gh`) and `XDG_STATE_HOME`, the new test reaches the live server and opens Firefox; the initiative check passes vacuously against real records; a hard-coded log path writes into the live `decisions.jsonl`. Fold: both log paths derive from `${XDG_STATE_HOME:-$HOME/.local/state}/approval-queue`; the test stubs all four and sets `XDG_STATE_HOME` and `APPROVAL_QUEUE_PROJECTS` to temp dirs with a fixture `initiative.yaml`; it asserts the live log is unchanged.
- **M5 (correctness).** The privacy check covers only the register. Private repos: aksailingclub-legacy, cairn-pub, cairn-themes, fishwright, phonebook, xcathletes-org. Fold: T9 greps those names and the named people over `git log -p origin/<base>..HEAD` on all five branches and each PR body; the conductor greps the packet before `--check`; the people list is explicit.
- **M6 (correctness).** Hand-over states: `pkill` runs before `--check`, lengthening downtime; packet exits 1, 2, and 143 are unhandled; `pgrep` can match T8's 7917 server. Fold: `--check`, then `pkill`, then send; exit 0 acts, 1 resets the server and re-sends, 2 fixes and re-sends, 143 re-sends; match the 7907 listener's pid via `ss -ltnp 'sport = :7907'`; T8 stops its 7917 server.
- **M7 (correctness).** "Lingering ... needs no login session" is false for `gh` (keyring token, HTTPS remotes), `notify-send`, and Firefox; a locked screen is fine. Fold: say "stay logged in" in the install section, probe `gh auth status` from a unit when arming, and correct the standing-answer wording.

## Minors

- m1 (correctness): `gh pr create` needs `--title` and `--body-file` without a TTY.
- m2 (correctness): guard against a second conductor in `ExecStart` (`claude agents --json | jq` on `conductor-approval-queue`).
- m3 (correctness): once isolated, a session's `git -C` into the main checkout is blocked; the conductor never edits under the approval-queue main checkout outside `.claude/worktrees/handover`, and writes the packet under `~/.local/share/approval-packets/`.
- m4 (optional): name `REGISTER=<path> bash scripts/gate.sh` as the gate call, since the quoted `cairn-run-gate` form is refused in isolated sessions; note gate time is unrecorded.
- m5 (correctness): add a hand-over line of about 30 minutes to the path, so 09:00 is held against path plus hand-over.
- m6 (correctness): W1 spans two repos; it takes worktree isolation for approval-queue and edits the register worktree by absolute path.
- m7 (optional): say which dubplate-pass and poplar-pass close steps apply to a wording PR.
- m8 (optional): the design pin is stale; cite `e910fa8`.
- m9 (optional): before merging, the conductor checks the printed decision against the packet's refs, kind verdict sets, and live `headRefOid`, and writes the per-part plan to STATUS.
- m10 (optional): on a supervisor restart (a cask upgrade), re-arm the full guard set per "Restart recovery".
- m11 (optional): an authored skill's manifest is its directory; drop the misfiled inventory entry.
- m12 (optional): record that command tests live in a new `tests/packet.test.sh`, which `gate.sh` runs.

## Over-ceremony

- O1: full Opus reviews and dubplate's heavy `--merge` gate on two one-line wording PRs; the adapters mandate them, so they stay unless Geoff waives.
- O2: T0 stands alone; fold it into P0's start.
