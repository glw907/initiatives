Initiative: monthly-model-review

# November model review: building the approved designs

Designs: the fifteen `docs/specs/2026-11-0{1,9}-model-review-*-design.md` files in `glw907/workstation`
(main checkout `/var/home/glw907/.dotfiles`), merged as #184 and #190 on 2026-11-10. Geoff approved
all fifteen in chat on 2026-11-10 ("Approved. continue."), taking every recommendation as written.
Four are already built (below), so this plan builds the other eleven. The recommended rulings are
binding:

- Fable escalation: drop the Opus `max` rung, so the ladder reads `xhigh`, then one `fable`
  dispatch at `high`.
- Tellgrader: a finding with `"gate": true` is a Blocker, and any other finding is a Warning.
- Guard hooks: accept fail-closed. A broken `claude-secret-guard` is repaired from a plain terminal.
- `go-ship:14`: add a clause saying that invoking the skill is the choice to skip the close review.
- Open flags: each row's recommendation stands, and each lands as a backlog filing, not an edit.

The four settings designs (subagent effort, guard hooks, skill listing, Playwright allow) are
glw907/workstation#221. The planning session built them interactively and sent them in a separate
packet. Claude Code 2.1.322 came through the `claude-code@latest` cask, so the escalation design's
step 1 is done (`--model fable` answered `claude-fable-5-2` on 2026-11-10). The escalation design
scoped its wording steps as a direct change. They fold into pass S instead, since the audit diff
edits the same `pass-core` section.

Conductor: `conductor-dotfiles` (the name earlier dotfiles passes used). It owns all three passes,
including the `glw907/standards` one, so Geoff gets one packet. Executors: `dotfiles-model-review-skills`
(pass S), `dotfiles-model-review-launcher` (pass L), and `standards-model-review` (pass P). They run
in parallel. Pass S and pass L share one file, `scripts/check.sh`, where each registers a test: pass
L rebases on pass S at merge, and the conductor resolves that one conflict.

Load at start: `pass-core` and `standards:running-passes`. Pass S and L also load `dotfiles-pass`.
Pass S loads `claude-infra` before editing a skill or agent. All prose follows the `writing-voice`
output style. Every dispatch carries `pass-core` step 1's two quoted samples ("Avoid
over-engineering..." and "Deliver what was asked...").

The workstation has no `.github/workflows`, so the local gate on the close head is the full-suite
home there (`dotfiles-pass`). In `glw907/standards`, the `validate` check is CI.

## How a probe sees an edit

`~/.claude/agents` and each `~/.claude/skills/<name>` link into the main checkout, and personal
files outrank project files for skills. A session never sees a worktree edit through `~/.claude`.
Each acceptance probe below therefore copies the edited file into a scratch repo's project `.claude/`
(agents and rules, which project scope serves), or passes it with `--agents`. A skill whose personal
copy shadows the edit is probed by the conductor after merge and `stow -R claude`.

## Pre-flight

No item needs Geoff. The conductor checks each one before launching.

1. **[session] Dotfiles main is current.** `git -C /var/home/glw907/.dotfiles fetch origin`, the
   checkout is on `main`, and `rev-list --count HEAD..origin/main` prints 0.
2. **[session] The standards worktree.** `/var/home/glw907/Projects/standards` is checked out on
   `agent-first-1` for the agent-first initiative, so nothing here switches or pulls it. The conductor
   runs `git -C /var/home/glw907/Projects/standards fetch origin`, then `git -C
   /var/home/glw907/Projects/standards worktree add -b model-review-2026-11
   .claude/worktrees/model-review-2026-11 origin/main`, and launches pass P with that worktree as
   its cwd. Check: `git -C <that worktree> rev-parse HEAD` equals `origin/main`.
3. **[session] No other executor holds these repos.** `claude agents --json` lists no live session
   whose cwd is under either checkout, other than the three executors this conductor launches.
4. **[session] Open PRs.** #221 touches `claude/.claude/settings.json` and `BACKLOG.md`. If it has
   merged, the executors start after it, and the conductor first reruns the write probe below
   under the new fail-closed hooks. If not, pass S's backlog edits rebase on it at close. #166
   (`fresh-checkouts`, untouched since 2026-10-29) edits `pass-core`, `dotfiles-pass`, and
   `scripts/check.sh`. No pass waits for it. Its owner rebases it, and the packet names the
   overlap.
5. **[session] The pre-launch checks** in `pass-core` "Execute".

Permissions checked: each task's writes and credentials were read against auto mode for a
background executor. Pass S writes tracked files under `claude/.claude/{skills,agents,docs,rules}/`,
`claude/.claude/tooling/vendored-skills.json`, `bin/.local/bin/claude-context-budget`, `tests/`,
`scripts/check.sh`, and `BACKLOG.md`. A `claude -p --permission-mode auto` probe from a scratch
dotfiles worktree on 2026-11-10 wrote `claude/.claude/rules/probe.md` and edited
`claude/.claude/agents/site-implementer.md` with no refusal. The probe ran under `-p`, not `--bg`, so
a refusal takes the standing answer below. No pass edits `claude/.claude/settings.json`, the live
`~/.claude/settings.json`, a credential file, or a hook registration. Pass L writes
`bin/.local/bin/model-review-notify`, `docs/model-review/prompt.txt`, two docs under
`claude/.claude/docs/`, and a test under `tests/`. Passes S and L run nested `claude -p` sessions
(about fourteen in all). The planning session ran six nested `claude -p` probes from an interactive
auto-mode session on 2026-11-10 with no refusal, but not from `--bg`, so a refusal takes the
standing answer. Pass P writes only tracked files in its `glw907/standards` worktree and runs
`claude plugin eval` with `--trust-plugin`, so no confirmation prompt hangs it. Every pass pushes
its branch to the repo it names and opens a PR, and none reads `~/.local/secrets`, signs in, or
merges.

Reviewed: `standards:plan-reviewer` (mechanics and feasibility), 2026-11-10. Four blockers, seven
majors, and five minors, all folded into this file. Its one owner fork, the after-merge trigger
check, takes the reviewer's recommendation (pass S task 6).

## Standing answers

- If auto mode refuses a write under `claude/.claude/` or a nested `claude -p`, the executor stops
  that task only and sends the exact refusal to the conductor. The conductor makes the edit by
  path or runs the probe from its session, commits to the executor's branch, and relaunches.
- If an audit hunk no longer applies (`pass-core` and `engine-consult` changed after 2026-11-01),
  the executor applies the hunk's intent by hand to the current text and lists each re-derived hunk
  in `## Decisions`. A hunk whose target text is gone is skipped and listed.
- If a probe contradicts a design (the `/doctor prompt-audit <path>` form ignores plugin files, or
  `/goal` behaves differently under `-p`), the executor records the probe output in the PR, lands
  the parts the probe doesn't touch, and leaves the contradicted step for the packet. This is the
  one stop that reaches Geoff, as an ask in the conductor's packet.
- A pass runs on up to twice its path estimate. If the clock stop fires past that, the executor
  lands and pushes what is done, marks the rest unfinished in the PR body, and reports PR-ready.
  The conductor records the overrun as a planning miss in the packet. Nothing asks Geoff mid-run.
- After the whole-branch review, a round fixes only blocker and major findings. Minor findings go
  to the PR body.

## Pass S: skills and agents (`runner`, 210 path minutes)

Executor `dotfiles-model-review-skills`, `sonnet` at `medium`, branch `model-review-skills`, push to
`glw907/workstation`.

1. **Audit fixes** (60 min). Apply `docs/model-review/2026-11-01-proposed.diff` with
   `git apply -p1 --reject`. On 2026-11-10 the `pass-core` and `engine-consult` hunks failed
   `--check`, so re-derive those by hand per the standing answer. Then amend the `site-implementer`
   DaisyUI hunk per task 2. Acceptance: every one of the 15 audit rows in the audit-fixes design is
   landed or listed as skipped with its reason.
2. **site-implementer reach** (20 min). Add `Skill` to `site-implementer.md`'s tools line, word lines
   44-45 as "invoke the `standards:daisyui` skill", and rewrite `claude-infra`'s reach sentence
   (about line 63) per the design. Acceptance: in a scratch copy of a site repo, put the edited
   agent at `.claude/agents/site-implementer.md` and dispatch it on a small admin-markup task. Its
   transcript shows a `Skill` call for `standards:daisyui`. Discard the scratch copy.
3. **Fable escalation** (10 min). In `pass-core` "Models", replace "then `max` (one session-only
   adjudication), then one `fable` dispatch" with "then one `fable` dispatch at `high`". In
   `claude/.claude/docs/claude-tooling.md` (about line 37), name the `fable` alias without a version.
   Run after task 1, since both edit `pass-core`.
4. **Tellgrader authority** (15 min). `register-check/SKILL.md:28-30` and `prose-voice-reviewer.md:30`
   per the design and the ruling above. `cairn-register-editor.md` keeps its "facts" line.
5. **Standards overlays, workstation side** (50 min). Add `claude/.claude/rules/vale.md` scoped with
   `paths:` to `**/.vale.ini` and `**/styles/**`, with the design's content. Cut the Vale sentence in
   `claude-tooling.md` to a pointer. Add a `rules/` row to its layout table. Teach
   `claude-context-budget` to count `claude/.claude/rules/*.md`, with a test case registered in
   `scripts/check.sh`. Add the `golang-spf13-cobra` `description` overlay to `vendored-skills.json`,
   dropping the two "see" sentences. Acceptance: in a scratch repo with the rule copied to
   `.claude/rules/vale.md`, a session running `standards:vale-setup` shows the rule loaded when it
   writes `.vale.ini`, and `styles/` stays out of `.gitignore` (the design's step 5). Then
   `claude-tooling-sync verify` passes.
6. **log-project trigger check** (15 min here). Run the "before" half now: three should-trigger and
   two should-not prompts in fresh `claude -p` sessions against the current skill, and commit the
   prompts and results in the PR body. The personal skill shadows any project copy, so the "after"
   half runs in the conductor after merge and `stow -R claude`. If a should-trigger prompt stops
   triggering, the conductor reverts the `log-project` description hunk by commit.
7. **Open flags filed** (15 min). One `BACKLOG.md` entry per "Rulings wanted" row and per "No ruling
   needed" item that needs work, through `standards:log-issue`, tagged
   `#initiative:monthly-model-review`. Items that land in another repo (`glw907/standards`,
   `glw907/survey`) say so in the entry. The monthly checklist line goes to pass L.
8. **Close** (25 min). Gate, `claude-tooling-sync verify`, `gitleaks git` on the branch, one
   whole-branch `standards:diff-reviewer`, PR body per `pass-core` "Close". Report PR-ready to the
   conductor. Never run `approval-queue`.

## Pass L: the review launcher (`runner`, 165 path minutes)

Executor `dotfiles-model-review-launcher`, `sonnet` at `medium` with `--advisor opus` (the advisor
trial), branch `model-review-launcher`, push to `glw907/workstation`.

The advisor design names "the next `ordinary` pass". This pass is `runner` because its tests land
under `tests/` and `scripts/check.sh`. It is the next Sonnet executor in this repo, and the class
doesn't change what the trial measures, so it takes the trial. The decision goes in the PR's
`## Decisions`.

1. **Advisor check** (5 min). Run `/advisor` with no argument, which the advisor page says prints
   the current advisor under `-p`, or read the session transcript for advisor calls. The page says
   a `--bg` session that can't start it "starts the session without the advisor instead of
   exiting". If it's absent, note it and carry on without the trial.
2. **Single run** (30 min). The single-run design's steps 1 to 3 in `model-review-notify`: the
   `pavilion` check, the pull retry with `notify-send` and exit 1, and the existing-branch check.
   The retry delay reads an environment override (default 60 seconds), so the test runs fast.
3. **`/goal` launch** (30 min). The unattended-completion design's step 1, with the condition it
   names, and its step 2 section in `claude/.claude/docs/unattended-work-guards.md`. Prove the
   launch form with two small `claude -p` goal runs: one whose condition needs two steps, and one
   whose condition is met by stopping early, as a quiet month or a dry run would. These replace a
   full `--dry-run`, which spends a whole Opus `high` review and also starts the writing review and
   the docs cycle. Say so in `## Decisions`; the December run is the full test.
4. **Standards audit in the launcher** (45 min). The standards-audit design's steps 1 and 2. The
   standards main checkout sits on a feature branch, so the launcher never pulls it. It fetches
   `/var/home/glw907/Projects/standards`, keeps a detached worktree at
   `.claude/worktrees/model-review-audit`, moves it to `origin/main` each run, and runs the second
   audit from there into a second report. Both report paths go to the session. Probe
   `/doctor prompt-audit plugins/standards` once from pass P's worktree or a fresh detached one at
   `origin/main`, and keep its report in
   `docs/model-review/2026-11-10-prompt-audit-standards-probe.md`. If the path form doesn't read the
   plugin's files, the standing answer applies.
5. **Prompt lines** (10 min). In `docs/model-review/prompt.txt`: step 1 reads both reports, and a
   design for the plugin lands in `glw907/standards`. The skill listing probe runs each month, and
   its warning is a gap. Checklist item 2 reads `claude/.claude/docs/fable-post-cutoff-system.md`,
   and item 7 is skipped.
6. **Pricing record** (15 min). The pricing-record design's four steps in
   `claude/.claude/docs/fable-post-cutoff-system.md`. Re-read the pricing page first, and cite the
   date read.
7. **Tests** (15 min). A test under `tests/` with stubbed `git`, `hostname`, `claude`, `notify-send`,
   `survey-writing-review`, and `cairn-docs-cycle` on PATH, and the retry delay set to 0. It covers
   the wrong host, a failed pull, an existing branch, and the normal path, where `claude` is
   reached. Register it in `scripts/check.sh`.
8. **Close** (15 min). As pass S task 8, plus the trial's score lines in the PR body: the main
   session's advisor calls and its subagents' calls counted apart (the page says "Subagents inherit
   the configured advisor"), clock stops, fix rounds, and session usage. Compare them with pass S,
   the same-size Sonnet pass running beside it without an advisor, as the design's step 2 asks.

## Pass P: the standards plugin (`runner`, 75 path minutes)

Executor `standards-model-review`, `sonnet` at `medium`, launched with the worktree from pre-flight
2 as its cwd, branch `model-review-2026-11`, push to `glw907/standards`. It never calls
`EnterWorktree`, since the conductor made its worktree from `origin/main`. The plugin's README holds
the rules: every edit stays portable, and changes land by PR with the `validate` check.

1. **Findings table** (45 min). The standards-audit design's table: rows 2, 22, 15, 16, 17, 18, 20,
   and "new". Retest each against `origin/main` first, since the design read `af14ad5`.
2. **Fold sentence** (5 min). The standards-overlays design's step 3 in `spec-plan-review`.
3. **go-ship clause** (5 min). Per the ruling above.
4. **Evals** (10 min). `claude plugin eval plugins/standards --case 'go-conventions*'
   --trust-plugin`.
5. **Close** (10 min). `bash scripts/scan.sh`, `bash scripts/check-skill-lines.sh`, and
   `node scripts/check-references.mjs` locally, push, watch `validate` with `ci-green`, and run one
   whole-branch `standards:diff-reviewer`. Report PR-ready to the conductor.

## Merge order and the packet

Merge order: glw907/workstation pass S, then pass L rebased on it (the `scripts/check.sh` conflict),
then glw907/standards pass P. After the workstation merges, pull `/var/home/glw907/.dotfiles`, run
`stow -R claude` so `~/.claude/rules` links, and run pass S task 6's "after" half. After pass P
merges, run `claude plugin update standards@glw907-standards`, then check the version with `claude
plugin list`.

The conductor sends one packet once all three PRs are ready, through `approval-packet`. It carries
each PR as a routine row with its `## Decisions` lines, names #166's overlap with pass S in
`## Not checked`, and raises any standing-answer stop from a probe as its one ask. The packet's
initiative is `monthly-model-review`.
