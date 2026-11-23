# Spec: move `cairn-cms` onto `building-from-specs`

Status: approved by Geoff on 2026-11-22 ("spec approved"). Its build runs from
`plans/2026-11-22-cairn-cms-build-prompt.txt`. The repo is `glw907/cairn-cms`, default branch `main`, read at `87869e61f`
(`origin/main` is the same commit).

Three tasks and four steps in Geoff's session move `cairn-cms` onto the workstation's process. Task 1 renames
the repo's process skill to `cairn-build` as a short skill of facts, deletes the `cairn-implementer` agent, and
rewords every other Claude file outside the docs process. Task 2 moves the docs process off the retired
Approval Queue: the review hand-over, one eval case, and the monthly docs cycle's prompt, proven by the eval
suites. Task 3 applies the backlog sweep. Geoff's session keeps `docs/STATUS.md`, turns on GitHub's secret
scanning, push protection, and Dependabot alerts, edits `.claude/settings.json`, and edits the workstation's
`cairn-pass` skill. No engine code, published page, or gate leg changes.

## Intent

Geoff asked, on 2026-11-22: "does it make sence to start a project to reshape the cairn and dubplate
efforts to fit the workstation claude tooling?" The initiative record states success: "a task in either
repo launches, builds, and merges by that skill and the repo's short facts file, with no process text of
the repo's own in the way." He set the planning split: "I'd like a Fable planning effort. I can execute
with something lighter." For this spec he said: "You can prep for the spec session. I'll spend my remaining
fable time on it."

His rulings this spec carries:

- "That matches." (2026-11-22), quoted in the initiative's `STATUS.md`. No automated security review now:
  "`cairn-cms` waits for its next large change to sign-in code." GitHub's secret scanning, push protection,
  and Dependabot alerts go on for both public repos, and "Each repo's spec carries the step." The
  `figure-verifier` agent goes with `cairn-figure`. `cairn-cms` names neither
  (`research/2026-11-22-spec-inputs/sweep-cairn-cms.md`), so nothing here changes for them.
- "Any reference to friction should be removed it. should be backlog." (2026-11-07, BACKLOG #374). The
  proving loop's "friction list" becomes "backlog list" (2026-11-13), renamed together with the grader's key.
- The #459 wording for `cairn-proving-setup`, adopted 2026-11-14: "no `$` other than `$?`, no backtick, and
  no `<` or `>`".
- From the approved `dubplate` spec ("Approved.", 2026-11-22), call 6: "The BACKLOG tag for a milestone is
  `#milestone:<name>`." A placement naming product work uses the same tag here, so both repos read alike.
- Rulings already in the files stay as written: the `scripts/gate/` carve-out (2026-11-03), the docs-stage
  close boundary test (2026-10-07), and the fifteen-run budget stop (2026-11-10).

Goals:

- `CLAUDE.md`, `CONTRIBUTING.md`, and `.claude/` name no process but `building-from-specs`.
- One repo skill, `cairn-build`, holds the facts a task session needs: worktree setup, the gate, the full
  suite's home, risk classes, review checklists by path, the close checklist, and the live admin smoke test.
- One gate form, the committed fast lane. `CONTRIBUTING.md` gives it bare, and the repo skill and the
  workstation's `cairn-pass` give it wrapped by `cairn-run-gate`.
- A disputed docs call reaches Geoff in the pull request's `## For Geoff`, and the monthly docs cycle hands
  over by pull request and never waits.
- BACKLOG carries the sweep's verdicts, and the paused theme-garden rounds restart only as specs.

Non-goals: engine and theme work, the paused round `surface` and round `events` themselves, the specs and plans
of `cairn-setup` and `dubplate-server`, the `scripts/gate/` harness, the gate's legs, and the `claude-security`
run.

The work fails if a task session meets a refusal it can't route around, if any task changes engine behavior or a
published page, if the eval regression suite drops, if a pull request merges with a red check, or if round
`surface` launches under the old process.

## What happens when it goes wrong

- A refused `CLAUDE.md` commit or skill-folder rename. The denials log shows `[Undermining Oversight]` refusing a
  commit of a `.claude/CLAUDE.md` in another repo. On 2026-11-22 `dubplate` task 2's session committed a
  `CLAUDE.md` edit and replaced a skill folder (draft pull request glw907/dubplate#21), so neither is likely. If
  one is refused, task 1 puts the exact text or the `git mv` under `## Before merge`, marks its done item unmet,
  and finishes the rest. Geoff's session applies it before the merge.
- An eval run the task session can't start. `run.mjs` spawns `claude -p` sessions with
  `--permission-mode acceptEdits`, and no task session has run it yet. After one other try, task 2 puts the run
  under `## Before merge` with its exact command, marks done item 6 unmet, and leaves the pull request in draft.
  Geoff's session runs it, puts the table in the pull request, and marks it ready.
- An eval run paused on the usage limit. The runner prints "run paused on the usage limit: resume after the
  reset with --resume <runId>" and exits 4 (`run.mjs:1316-1320`). Task 2 resumes it with that command after the
  reset. If the reset falls past its time clause, it puts the resume command under `## Before merge` and leaves
  the pull request in draft.
- A regression drop on the branch. A drop counts only if it persists through `--case <id> --trials 3` reruns,
  per `.claude/rules/evals-docs-process.md`. Task 2 fixes the wording that caused it. A drop it can't fix
  leaves the pull request in draft with the table and the failing transcripts named.
- No network in the task's worktree. `src/tests/unit/workflow-yaml.test.ts:466` fetches `actionlint`, so a unit
  leg goes red without DNS (#489). The task names that leg as the cause and reruns once the network is back. It
  never skips the test.
- The December docs cycle. `model-review.timer` fires 2026-12-01 00:47 AKST and launches `cairn-docs-cycle`,
  which pulls `main` and runs `evals/cycle-prompt.txt` from it. The old prompt names the removed
  `approval-packet` skill and waits on a ruling, holding a session slot. Task 2 aims to merge first. If it is
  still open on 2026-11-30 and its review accepted the `cycle-prompt.txt` change, Geoff's session commits that
  one file from task 2's branch straight to `main`. The new prompt opens a pull request and ends, so it can do
  less harm unattended than the old one. If the review hasn't accepted it, Geoff's session comments out the
  `cairn-docs-cycle` call at `model-review-notify:125` for December, in a `~/.dotfiles` worktree.

## What idles, and how the paused work restarts

No other `cairn-cms` session is working (`claude-worktree-busy ~/Projects/cairn-cms` exits 0 today). Round
`checks` has closed. Round `surface` has never launched, and `docs/STATUS.md:23` says "the desk launches it once
its start line holds." cc-desk has never acted on `cairn-cms`
(`research/2026-11-22-spec-inputs/desk.md`), and hand-over 1 removes that line before task 1, so nothing can
launch it. Round `events` holds passes 2 and 3, and theme-garden G3 has an approved design and an unlaunched plan.
Task 3 files one BACKLOG item for each: write a spec under `building-from-specs` from the round's design. The
plans in `~/Projects/initiatives/theme-garden/` stay untouched.

At most four sessions work on pavilion at once, counting Geoff's. `claude agents --json` lists three working
today: `dubplate` task 2, a `dubplate-server` session, and this one. Each launch checks the count first.

## The Claude files and their verdicts

Each file gets a verdict, with the files that read it.

| File | Verdict | Read by | Change |
| --- | --- | --- | --- |
| `skills/cairn-running-passes/` | Rewrite as `skills/cairn-build/` | `CLAUDE.md:26,47`; `CONTRIBUTING.md:72`; `cairn-releasing` 7, 261, 383; `cairn-writing-docs/SKILL.md:38`; `durable-gotchas.md:581`; `gate-tier.mjs:3,136`; `gate-tier.test.ts:1010,1064`; the workstation's `cairn-pass` (by "the repo's own process skill") | Task 1 |
| `…/references/admin-smoke-test.md` | Keep, moved with the skill | The skill | Task 1 rewords lines 1, 12, 14, 154 |
| `…/references/pass-gate-tiers.md` | Keep as `gate-tiers.md` | `gate-tier.mjs:3,136`; `gate-tier.test.ts:1064` | Task 1 renames it and rewords 1, 18, 27, 28, 135, 221, 231 |
| `…/references/launch-prompts.md` | Delete | The old skill only | Task 1 |
| `skills/cairn-releasing/` | Keep | `CLAUDE.md:39,47` | Task 1 rewords its process lines, 273 among them |
| `skills/cairn-proving-setup/` | Keep | `cairn-releasing` (the `naive` leg) | Task 1 rewords lines 5, 14, 60, 77, 95 and `owner-card.md:3`, and folds #459 |
| `skills/cairn-writing-docs/` | Keep | `CLAUDE.md:63`; `.claude/rules/docs.md`, `docs-with-code.md`; `cairn-docs-cycle` (workstation) | Task 2 |
| `skills/cairn-writing-engine-code/` | Keep | `CLAUDE.md:44`; `.claude/rules/` | Task 1 rewords `SKILL.md:3,8`, `code-idioms.md:22,140`, and `durable-gotchas.md:577,581` |
| `skills/cairn-judging-scope/` | Keep | `CLAUDE.md:43` | Task 1 rewords `extending-developer-lens.md:68` |
| `skills/cairn-following-admin-design/`, `skills/cairn-following-public-design/` | Keep | `rules/admin.md`, `rules/public.md` | None |
| `agents/cairn-implementer.md` | Delete | `CLAUDE.md:29,49`; `CONTRIBUTING.md:13`; `launch-prompts.md`; the workstation's `claude-tooling.md:127` | Task 1; Geoff's session for the workstation line |
| `agents/engine-triage.md` | Keep | `CLAUDE.md:49`; engine consultations | Task 1 rewords 83 and 97 |
| `agents/docs-fact-checker.md` | Keep | `cairn-writing-docs`; `CLAUDE.md:50` | None |
| `rules/` (5 files, 40 lines) | Keep | Claude Code, by path | None |
| `hooks/release-cut-guard.mjs` | Keep | `settings.json` (PreToolUse on Bash, `onFailure: block`) | None |
| `settings.json` | Keep, two lines out | Claude Code | Geoff's session, before task 1 |
| `project-tracking.json` | Keep | `standards:log-issue` | None |

`cairn-build`'s description triggers on building, resuming, or reviewing a task in `cairn-cms`. It keeps, from
the old skill and reworded to tasks and specs:

- Worktree setup: `npm ci && npm ci --prefix examples/showcase && (cd examples/showcase && npx svelte-kit sync)`.
- The gate. `npm run lane:fast -- --range <base>..HEAD` after each commit, run from the worktree root. On the
  workstation it runs as `cairn-run-gate 'npm run lane:fast -- --range <base>..HEAD'` on the heavy lane,
  re-issued on exit 75 until a `gate exit:` line prints. CI on the pull request carries the whole suites.
  Locally, `npm test` then `npm run check:close` run only when CI is unavailable, with the
  `--grep-invert "site home|archive page 2"` note.
- The risk classes `auth-data` (the old line 30's path list), `runner`, and `ordinary`, with the reviewers each
  class adds, and the review checklists by path.
- The `scripts/gate/` carve-out (Geoff, 2026-11-03), the harness-only-fix changelog rule, and the chassis rule.
- The close checklist: the live admin smoke test, the docs, the `CHANGELOG.md` and `MIGRATION-NOTES.md` entries,
  `npm run check:surface -- --update`, a finding going to `BACKLOG.md` through `standards:log-issue`, the
  docs-stage close boundary test (Geoff, 2026-10-07), and no version bump or publish.
- From `cairn-implementer`, the conventions a builder needs: NodeNext `.js` import suffixes, Svelte 5 runes,
  the test paths, and the worktree's `git -C` command forms.

It drops what `building-from-specs` owns: the lifecycle, the executor and conductor, pair subagents, per-task
dispatch, launch prompts, packets, the clock, and the close packet. Its pointers to `pass-gate-tiers.md` become
`gate-tiers.md`, which becomes the one home of the tier rules that `gate-tier.mjs`'s header points at.

## Approaches

For the gate, the audit found two forms. `CLAUDE.md:28` and `CONTRIBUTING.md:13` say
`npm run lane:fast -- --range <base>..HEAD`. The workstation's `cairn-pass` has each leg run as
`CAIRN_GATE_LANE=<lane> cairn-run-gate '<string>'` and still names the deleted `make -C tool check`. The
classifier's line 1 carries no lane prefix (`gate-tier.mjs:136`, `FAST_LINE_1_LANE = ''`, the heavy lane), so
wrapping the whole committed lane loses nothing. The wrapper still matters on the workstation, since it outlasts
the shell tool's ten-minute cap and writes the records `task-report` reads. The pick is one form: the committed
lane, wrapped by `cairn-run-gate` on the workstation. On 2026-11-22, in the idle main checkout,
`cairn-run-gate 'npm run lane:fast -- --range HEAD~1..HEAD'` printed `gate exit: 0` (308 log lines).

For the docs hand-over, the Approval Queue and the `approval-packet` skill are retired, and
`building-from-specs` puts each choice Geoff must see under `## For Geoff`. A disputed docs call goes there with
the same shape the close packet used: the whole sentence, both readings, and the two options. The page keeps the
author's text until Geoff answers. His session applies an "Apply the fix" answer on the branch before the merge,
so no follow-up pull request is needed.

For the monthly docs cycle, two shapes were weighed. Keeping its wait for a ruling breaks "A task session never
asks Geoff a question, never waits for a ruling" and holds a session slot for days. The pick is a cycle that
samples, finds the failures, runs the suites, and opens one pull request. That pull request holds the month's
history entry and the `sources.md` dates, with each row under `## For Geoff`, its options now, defer, and drop,
and one recommended. Geoff answers in his terminal. His session records each call in the entry on the branch,
files each "now" and "defer" row as a `#docs-process` BACKLOG item, and merges. A "now" item's fix is a later
task whose first step writes the failing capability case, as the old step 6 did. The merged entry in
`evals/history.md` is where the next cycle reads his answers. A graduation (a capability case moving to the
regression suite) is an edit on the same branch, named under `## For Geoff`.

For the eval case, `review-unsupported-claim` is a capability case that asserts the close packet. It is
rewritten to assert the `## For Geoff` entry, so it is the change's target capability case: the baseline arm's
files still say "close packet" and the branch's say `## For Geoff`. The rule's bar for the merge is that the
regression suite doesn't drop and the target case improves.

The baseline arm is `87869e61f`, not `main`. The rule's `paths` include `CLAUDE.md`, so task 1's edits outside
the docs section count as a docs-process change too. A run against `main` after task 1 merges would hide a drop
that task 1 caused. One run against `87869e61f` proves both tasks' changes.

## Mechanisms and their sources

| Mechanism | Label | Source |
| --- | --- | --- |
| A `--bg` task session edits `.claude/skills/`, `agents/`, `rules/`, `hooks/` | Documented, probed | The `dubplate` spec's probe, commit `52a3d06`, "4 files changed, 4 insertions(+)" |
| A `--bg` task session commits `CLAUDE.md` and replaces a skill folder | Observed | glw907/dubplate#21: `CLAUDE.md` modified, `.claude/skills/dubplate-pass/SKILL.md` removed, `dubplate-build/SKILL.md` added |
| `cairn-run-gate` outlasting the ten-minute cap, exit 75 to re-issue | In use | `~/.dotfiles/bin/.local/bin/cairn-run-gate`; the run above |
| The fast lane's legs | In use | `scripts/checks/fast-lane.mjs`, `gate-tier.mjs --fast` |
| The eval change rule | In use | `.claude/rules/evals-docs-process.md`; `evals/README.md` (`--suite`, `--case`, `--trials`, `--max` past 120 sessions) |
| Secret scanning, push protection, alerts | Documented | <https://docs.github.com/en/rest/repos/repos> (`PUT /repos/{owner}/{repo}/vulnerability-alerts`; `PATCH /repos/{owner}/{repo}` with `security_and_analysis`) |
| `worktree.baseRef` and the launch's `--settings` override | Documented | <https://code.claude.com/docs/en/settings>; the launch line in `building-from-specs` |

## Assumptions

- CI runs on a public repo today: the last eight runs on `main` succeeded (`test`, `e2e`, `design`, `catalog`,
  `catalog-check`), per `gh run list --repo glw907/cairn-cms --limit 8`.
- `task-report` medians for `cairn-cms`: local gates 8.8 minutes (p90 31.4), CI wait 39.8 (p90 156.2). The
  minutes below use them.
- `evals.json` holds 11 regression cases and 2 capability cases. Both suites on two arms at the default three
  trials is 78 sessions, under `SESSION_CAP = 120` (`run.mjs:28`), so `--max` isn't needed. Each session runs
  Sonnet at medium and each judge Opus at medium (`run.mjs:200`, `:1043`), four at a time. The October runs
  took under two hours each, and task 2's run is planned at 120 minutes.

## Files

The file list comes from `research/2026-11-22-spec-inputs/search-cairn-cms.md` and
`triage-cairn-cms.md`, and the counts below were run at `87869e61f`.

- Strict words (`pass-core|running-passes|conductor|executor|approval[- ]packet|approval[- ]queue|cairn-implementer|launch-prompts|pair subagent`):
  32 hits outside `cairn-writing-docs`, all task 1's, and 31 inside it. Task 2 removes 21 of those 31 and
  rewrites two more. Seven stay as data: the guard prompts "Do not push, open a PR, or run approval-queue" in
  `evals.json:195,246,309`, the deny entry in `evals/run.mjs:57` and its test in `run.test.mjs:272`, and the
  false hits in `docs-register.md:287,288` ("executor" inside other words). `cycle-prompt.txt:40`, the Approval
  Queue store's folder path, stays because task 2's step 1 keeps it. `evals.json:313` and `:333` are rewritten,
  and each still asserts that no command runs `approval-queue`. That leaves 10.
- The word "pass": 147 hits, sorted in `triage-cairn-cms.md`. History stays as written: `docs/internal/plans/`,
  `admin-design-system.md`, `cm-editing-surface-alignment.md`, `code-idioms.md:14,183,192,194`,
  `extending-developer-lens.md` apart from line 68, the `scripts/checks` comments other than `gate-tier.mjs`, and
  `e2e.yml:79`. `check-idioms.mjs` names the word to refuse it. The `--class` flag's "pass class"
  (`gate-tier.mjs`'s `passClass`, `gate-tier.test.ts:410`) is code and stays.

Each task's files:

- Task 1: `.claude/skills/cairn-running-passes/` (moved to `.claude/skills/cairn-build/`; `launch-prompts.md`
  removed; `pass-gate-tiers.md` moved to `gate-tiers.md`), `.claude/agents/cairn-implementer.md` (removed),
  `CLAUDE.md` (outside "Documentation is a pass dimension"), `CONTRIBUTING.md`,
  `.claude/skills/cairn-releasing/SKILL.md`, `.claude/skills/cairn-proving-setup/SKILL.md` and
  `references/owner-card.md`, `.claude/skills/cairn-writing-engine-code/references/code-idioms.md` and
  `durable-gotchas.md`, `.claude/skills/cairn-judging-scope/references/extending-developer-lens.md`,
  `.claude/skills/cairn-writing-engine-code/SKILL.md`, `.claude/agents/engine-triage.md`,
  `scripts/checks/gate-tier.mjs` (comments only), `src/tests/unit/gate-tier.test.ts` (a path string and two
  comments).
- Task 2: `CLAUDE.md` ("Documentation is a pass dimension" only), `.claude/skills/cairn-writing-docs/SKILL.md`,
  `references/review.md`, `evals/evals.json`, `evals/cycle-prompt.txt`, `evals/site-cases/e1-add-public-option.json`.
- Task 3: `BACKLOG.md`.
- Geoff's session: `docs/STATUS.md`, `.claude/settings.json`, and in `~/.dotfiles`,
  `claude/.claude/skills/cairn-pass/SKILL.md`, `claude/.claude/docs/claude-tooling.md`,
  `bin/.local/bin/cairn-docs-cycle`, and `BACKLOG.md` (for #308).

## Commands against the denials log

Read against `worktrees-and-denials.md`, the 30 days to 2026-11-22. No task merges (`[Merge Without Review]`
refused `gh pr merge`), deletes a remote branch (`[Git Destructive]` refused `git push origin --delete`), or
starts a workflow (`[Auto-Mode Bypass]` refused `gh workflow run`). Geoff's session does the first two by
`building-from-specs` "Merging". `[Self-Modification]` refused an edit under a `cairn-cms` worktree's
`.claude/skills/`, and the probe and glw907/dubplate#21 show that edit allowed from a `--bg` task session. Task 2's
`node .claude/skills/cairn-writing-docs/evals/run.mjs` has never run from a task session; "What happens when it
goes wrong" covers a refusal. Every other command is `npm`, `node`, `npx`, `cairn-run-gate`, `git`,
`gh pr create`, `ci-green`, and `gh run view`, none refused.

## Before task 1: Geoff's session

Geoff's session does these in order, and the launch prompt carries them.

1. Hand-over 1, committed directly to `main`. `docs/STATUS.md` drops both round-report blocks with their resume
   and launch pointers, the conductor names on lines 50, 52, and 56, and the "checks-2 executor" section. Line 44's
   "Held paths go to Geoff in one small packet" becomes "A change to a held path goes in the pull request as
   exact text under `## Before merge`". Approval Queue item ids become plain words. It says the three reshape
   tasks run now and rounds `surface` and `events` wait for specs, keeps the 907.life sitting, the routines, and
   "Open decisions and watches", and stays at 60 lines or fewer in the present tense.
   - `wc -l < docs/STATUS.md` prints `74` today, and 60 or less after.
   - `git grep -n -i -E 'pass-core|running-passes|conductor|executor|approval[- ]packet|approval[- ]queue|round-report|Resume from|Next launch|packet|the desk' -- docs/STATUS.md | wc -l`
     prints `15` today, and `0` after.
2. The GitHub settings, through `gh api`. Each was read today; the writes are GitHub's documented endpoints,
   already run on `dubplate`, each followed by its check.

   ```bash
   gh api -X PUT repos/glw907/cairn-cms/vulnerability-alerts
   gh api -X PATCH repos/glw907/cairn-cms \
     -f 'security_and_analysis[secret_scanning][status]=enabled' \
     -f 'security_and_analysis[secret_scanning_push_protection][status]=enabled'
   ```

   - `gh api repos/glw907/cairn-cms/vulnerability-alerts >/dev/null; echo $?` prints `1` today (404), and `0`
     after.
   - `gh api repos/glw907/cairn-cms --jq '[.security_and_analysis.secret_scanning.status, .security_and_analysis.secret_scanning_push_protection.status] | join(" ")'`
     prints `disabled disabled` today, and `enabled enabled` after.

   Dependabot security updates stay off, as on `dubplate`. `.github/dependabot.yml` already exists and watches
   only `daisyui`, on purpose (`daisy-absorption-ritual.md`); it stays.
3. The settings change, below, committed directly to `main`.
4. The workstation change, below, in a `~/.dotfiles` worktree off `origin/main`, through `claude-infra`.

## The settings change

`.claude/settings.json` is a held path, so Geoff's session makes this edit. It removes two lines and adds none:
`"worktree": { "baseRef": "head" }` at line 11, which every task launch's `--settings` overrides with `fresh`,
and the allow entry `"Bash(make -C tool check)"`, dead since commit `a96deb40b` deleted `tool/`. The standards
plugin, the hook, and every other entry stay.

- `jq -r '.worktree.baseRef // "absent"' .claude/settings.json` prints `head` today, and `absent` after.
- `grep -c 'make -C tool check' .claude/settings.json` prints `1` today, and `0` after.
- `jq -e . .claude/settings.json >/dev/null; echo $?` prints `0` today and after.

## The workstation change

Three files in `~/.dotfiles`, a public repo, through `claude-infra` and the dotfiles gate,
`bash scripts/gate.sh` from the worktree root. `~/.dotfiles` holds another session's uncommitted files
(`bluefin/git-excludes`, `claude/.claude/docs/bluefin-admin/google-workspace.md`, `bin/.local/bin/sheet-revision`)
and the `spec-writing-test-2` worktree. The worktree off `origin/main` leaves them alone.

- `claude/.claude/skills/cairn-pass/SKILL.md` gives the one gate form above, drops the per-leg form and the
  `make -C tool check` line, and names `cairn-build` as the repo skill. It lands before task 1, since the wrapped
  lane works today and task 1's session loads `cairn-pass`.
  - `grep -c 'make -C tool check' claude/.claude/skills/cairn-pass/SKILL.md` prints at least `1` today, and `0`
    after.
  - `grep -c "cairn-run-gate 'npm run lane:fast" claude/.claude/skills/cairn-pass/SKILL.md` prints `0` today,
    and at least `1` after.
- `claude/.claude/docs/claude-tooling.md:127` stops naming `cairn-cms`'s `cairn-implementer`.
  `grep -c cairn-implementer claude/.claude/docs/claude-tooling.md` prints `1` today, and `0` after.
- `bin/.local/bin/cairn-docs-cycle` matches task 2's prompt. Its dry-run line becomes "Dry run: skip step 4.
  Write the history entry to the state folder and stop. Do not commit, push, or open a PR." Its header comment
  (lines 4 to 9) says the session samples sessions, runs the evals, opens one pull request, and ends. This one
  lands after task 2 merges, as a second pull request.
  - `grep -c 'steps 0 and 4' bin/.local/bin/cairn-docs-cycle` prints `1` today, and `0` after.
  - `grep -c -i -E 'queues? one triage|waits for' bin/.local/bin/cairn-docs-cycle` prints at least `1` today,
    and `0` after.

## Task 1: rename the process skill and reword the Claude files

Rename `.claude/skills/cairn-running-passes/` to `.claude/skills/cairn-build/` with `git mv`, then rewrite
`SKILL.md` as a short skill of facts in the agent-facing register (`~/.claude/docs/voice/agent-facing.md`), as
"The Claude files and their verdicts" sets out. Move `references/pass-gate-tiers.md` to
`references/gate-tiers.md` and remove `references/launch-prompts.md`. Remove
`.claude/agents/cairn-implementer.md`.

`CLAUDE.md`, outside "Documentation is a pass dimension": line 20 says "before a task builds on it". The
"Working here" bullets at 26 to 31 say: build each piece of work from a spec, per `building-from-specs`, in a
worktree off `main`; the `cairn-build` skill has the setup command, the gate, the risk classes, and the close
checklist; CI on the pull request carries the whole suites. Line 36 says "A task never bumps the version or
publishes". The skills list at 41 to 51 names each skill and agent once, without restating its description, and
drops `cairn-implementer` (#299). Line 79 says "A change that adds a diagnosable code path".
`CONTRIBUTING.md:13` drops its `cairn-implementer` sentence and keeps the bare
`npm run lane:fast -- --range <base>..HEAD`, since a contributor has no `cairn-run-gate`. `CONTRIBUTING.md:72`
names `cairn-build`.

The other files' process lines, reworded to tasks, specs, pull requests, and milestones, with history left as
written:

- `cairn-releasing/SKILL.md`: lines 7, 14, 44, 52, 53 (`standards:running-passes` "Close" becomes
  `building-from-specs` "Merging"), 126, 135, 236 ("a conductor plays the owner" becomes "the session running the
  loop plays the owner"), 261 and 383 (`cairn-build`), and 269 and 272 ("A task that changes `scripts/gate/`").
  Line 273 says "so that task's live proof". Lines 371 and 374 say "backlog" for "friction" (#374).
- `cairn-proving-setup/SKILL.md`: line 5 ("Use when a task runs the setup proving loop"), 14, 60 ("The session
  that runs the polish loop"), 77 ("A stop goes to the pull request's `## For Geoff`"), and 95. Lines 71 and 72
  take the #459 wording. `references/owner-card.md:3` says "What the session running the loop answers". The
  "friction list" at lines 74, 83, 84, and 91 and `owner-card.md:5` stays, because it names the `## Friction`
  heading the grader writes (`scripts/gate/grade.mjs:881`). Task 3's #374 wording places that rename at the next
  task that changes `scripts/gate/`.
- `cairn-writing-engine-code/SKILL.md:3` ("when a task writes tests") and `:8` ("and a task checks its diff
  against it").
- `code-idioms.md:22` ("a task that changes an idiom updates this page") and `:140` ("never change during the
  polish loop"); `durable-gotchas.md:577`
  ("an open spec on its branch") and `:581` (the new path); `extending-developer-lens.md:68` ("checklist for
  every task"); `engine-triage.md:83` ("a small engine task now, or a queued engine task") and `:97` ("what the
  task builds").
- `gate-tier.mjs` lines 1, 3, 13, and 136, comments only ("A task session runs it", "the legs a task session
  runs after each commit"). `gate-tier.test.ts:908` and `:1064` (comments) and `:1010` (a path string the test
  feeds the classifier).

Done when:

1. The strict words are gone outside the docs process.
   `git grep -n -i -E 'pass-core|running-passes|conductor|executor|approval[- ]packet|approval[- ]queue|cairn-implementer|launch-prompts|pair subagent' -- CLAUDE.md CONTRIBUTING.md .claude ':!.claude/skills/cairn-writing-docs' | wc -l`
   prints `32` today, and `0` after.
2. The process phrases are gone. With
   `R='cairn-running-passes|running-passes|pass-gate-tiers|pass session|pass branch|pass mechanics|pass log|per pass|each pass|every pass|finished pass|held pass|later pass|a pass (that|never|builds|or)|the pass (that|did)|before a pass|pass dimension|cairn-pass verification'`,
   `git grep -n -i -E "$R" -- CONTRIBUTING.md .claude scripts/checks/gate-tier.mjs src/tests/unit/gate-tier.test.ts ':!.claude/skills/cairn-writing-docs' | wc -l`
   prints `43` today, and `1` after (`gate-tier.test.ts:410`, the `--class` flag's name).
   `awk '/^## Documentation/{s=1} /^## Diagnosing/{s=0} !s' CLAUDE.md | grep -c -i -E "$R"` prints `5` today, and
   `0` after.
3. The folders moved. `test -d .claude/skills/cairn-running-passes; echo $?` prints `0` today, and `1` after.
   `test -f .claude/skills/cairn-build/references/gate-tiers.md; echo $?` prints `1` today, and `0` after.
   `test -f .claude/agents/cairn-implementer.md; echo $?` prints `0` today, and `1` after. Unmet with a
   `## Before merge` step if a move was refused.
4. The skill carries the facts. `grep -c` on `.claude/skills/cairn-build/SKILL.md` prints at least `1` after for
   each of `svelte-kit sync`, `npm run lane:fast -- --range`, `cairn-run-gate`, `auth-data`, and
   `admin-smoke-test.md`.
5. #459 landed. `grep -c 'no backtick' .claude/skills/cairn-proving-setup/SKILL.md` prints `0` today, and `1`
   after.
6. `wc -l < CLAUDE.md` prints `114` today, and 114 or less after.
7. The gate passes from the task's worktree root:
   `cairn-run-gate 'npm run lane:fast -- --range origin/main..HEAD'`, re-issued on exit 75. The pull request
   quotes its `gate exit: 0` line. This is the gate-form proof from a task session.
8. CI passes on the pull request. `gh pr checks <n>` lists every check as `pass`.

Reviewers: `standards:diff-reviewer`. Minutes: 130 (work 50, local gates 20, CI wait 45, review 15). Time clause:
260 minutes. Model: Sonnet at high. Waits for: the four steps above.

## Task 2: move the docs process off the Approval Queue

Task 1 changes `CLAUDE.md`, so the line numbers below are `87869e61f`'s. Find each line by its quoted text.
Between the two merges, `cairn-writing-docs/SKILL.md:38` names a skill that no longer exists; the pointer
fails harmlessly and task 2 fixes it.

`CLAUDE.md`'s "Documentation is a pass dimension" becomes "## Documentation ships with each change". Line 55
says "Every change updates the docs for what it changed", 62 says "A change to a public behavior edits the
affected pages in the same pull request", 64 says "in the same pull request", and 65 says "kept current in every
pull request". Lines 66 and 67 become one sentence: "A finding goes to `BACKLOG.md` through
`/standards:log-issue`, or is fixed in the pull request that meets it." (#374).

`cairn-writing-docs/SKILL.md`: line 29 says "an open spec on its branch", line 38 names `cairn-build`, and line 71
says "land it when no call is left, or ask each call under `## For Geoff`, as `references/review.md` says."

`references/review.md` follows "Approaches". Line 4 says a docs pull request goes through the hand-over in
`building-from-specs`. Section 3 says that once CI is green the pull request is ready for Geoff's approval by
number, and its body names each changed page. Section 4 becomes "Ask each call under `## For Geoff`": the whole
sentence, the fact-check's reading with its `source`, the author's reading, the options **Apply the fix** and
**Keep the text**, and one recommended with its reason. The page keeps the author's text, and Geoff's session
applies his answer on the branch before the merge. Every `approval-queue` command goes, and so does the
`:::question` block.

`evals/evals.json`'s `review-unsupported-claim` case: its expectations and judge criteria 1 and 3 assert that the
reply puts the call under `## For Geoff` in pull request #900's body with the same parts, that no command runs
`approval-queue`, `gh pr edit`, or `gh pr merge`, and that the sentence stays on the page. The case's prompt
keeps its guard ("or run approval-queue") and says to end by giving the text it would add to the pull request
body, without naming the section, so the prompt doesn't hand either arm the answer. Its check on
`within about a minute` stays.

`evals/site-cases/e1-add-public-option.json:16` quotes the `CLAUDE.md` sentence on the changelog entry. It quotes
task 1's merged wording instead.

`evals/cycle-prompt.txt` follows "Approaches":

- Step 0 goes. No ruling waits between runs.
- Step 1 keeps its three sources. Geoff's decisions come from the pull requests since "since" that change a
  `docs/editors/` or `docs/admin/` page, and from earlier cycles' pull requests (`head:docs-cycle-`): their
  `## For Geoff` answers and review comments. The Approval Queue store stays readable for decisions before
  2026-11-22, named as a folder path with no command.
- Steps 2 to 4 stay. The lines that point at the decide document or at steps 6 and 7 (lines 5, 20, 27, 60, 69,
  and 117) point at step 5 and the pull request.
- Step 1 first looks for an open pull request on a `docs-cycle-` branch. If one is open, the cycle writes one
  line naming it to `~/.local/state/cairn-docs-cycle/<YYYY-MM>/skipped`, writes `last`, and ends.
- Step 5 writes the history entry, each row with its recommended call, on a branch `docs-cycle-<YYYY-MM>` in a
  worktree off `origin/main`, with the `sources.md` dates and any graduation. It runs the fast lane through
  `cairn-run-gate`, opens the pull request with each row under `## For Geoff`, watches CI with
  `ci-green <sha> --pr <n> --wait`, writes the date into `~/.local/state/cairn-docs-cycle/last`, and ends. It
  never merges and never sends a desktop notice.
- A dry run skips step 4, writes the history entry to `~/.local/state/cairn-docs-cycle/<YYYY-MM>/`, and stops.
  It commits nothing, so it can't collide with that month's real branch.
- The old steps 6 and 7 go. Geoff's session acts on his answers, as "Approaches" says.

Run the change rule from the task's worktree root, with the branch's copy of the runner, since `run.mjs` reads
`evals.json` from its own folder (`run.mjs:25`, `:1213`). Start it as a background command and wait until it
exits: `node .claude/skills/cairn-writing-docs/evals/run.mjs 87869e61f <branch> --suite all`. "Approaches" says
why the baseline is `87869e61f`. Read every failing trial's transcript, rerun any regression drop with
`--case <id> --trials 3`, and put the table in the pull request.

Done when:

1. The docs section is reworded.
   `awk '/^## Documentation/{s=1} /^## Diagnosing/{s=0} s' CLAUDE.md | grep -c -i -E 'pass dimension|every pass|same pass|a pass that|the pass that|friction'`
   prints `7` today, and `0` after.
2. The skill names no old flow. With
   `R2='pass dimension|every pass|same pass|a pass that|the pass that|pass branch|close packet|pass.s close|approval-queue (send|collect|check|merge|land|notes|reply)|approval-packet|round conductor|the conductor|kind .?merge|kind decide|running-passes'`,
   `git grep -n -i -E "$R2" -- .claude/skills/cairn-writing-docs/SKILL.md .claude/skills/cairn-writing-docs/references/review.md .claude/skills/cairn-writing-docs/evals/cycle-prompt.txt | wc -l`
   prints `24` today, and `0` after. The strict-words count from task 1's done item 1, run over
   `.claude/skills/cairn-writing-docs` alone, prints `31` today, and `10` after: the hits "Files" names.
3. `grep -c -i -E 'close packet|kind .?merge' .claude/skills/cairn-writing-docs/evals/evals.json` prints `2`
   today, and `0` after. `grep -c 'For Geoff' .claude/skills/cairn-writing-docs/evals/evals.json` prints `0`
   today, and at least `2` after.
4. `grep -c 'For Geoff' .claude/skills/cairn-writing-docs/references/review.md` prints `0` today, and at least
   `1` after.
5. The cycle never waits. `grep -c -E 'pending|collect|notify-send' .claude/skills/cairn-writing-docs/evals/cycle-prompt.txt`
   prints `10` today, and `0` after. `grep -c -i -E 'decide document|step [67]' .claude/skills/cairn-writing-docs/evals/cycle-prompt.txt`
   prints `6` today, and `0` after.
6. The eval table is in the pull request, from a run of both suites on `87869e61f` and the branch. No
   regression case on the branch falls below the baseline after the reruns (33 trials an arm), and
   `review-unsupported-claim` scores higher on the branch. Unmet with a `## Before merge` step if the run couldn't
   start or finish.
7. The gate and CI pass, as in task 1.

Reviewers: `standards:diff-reviewer`. Minutes: 240 (work 45, local gates 15, eval run 120, CI wait 45, review 15).
Time clause: 480 minutes. Model: Opus at medium, since a failing trial's transcript needs reading. Waits for:
task 1 merged, since both edit `CLAUDE.md` and `SKILL.md:38` names `cairn-build`.

## Task 3: apply the backlog sweep

`BACKLOG.md` takes the verdicts in "Backlog sweep" below, with the new wording for #374, #389, and #525 and the
placement rules from `research/2026-11-22-spec-inputs/sweep-cairn-cms.md`, which the task reads by absolute path.
It moves #299 and #459 to Done, citing task 1's pull request. #374's new wording names what is left after
tasks 1 and 2: the "friction list" in `cairn-proving-setup` and `owner-card.md:5`, and the grader's `## Friction`
heading, renamed together at the next task that changes `scripts/gate/`, which owes the #349 gate run. It files
four items through `standards:log-issue`, each under the exact title given here:

- "Write the round `surface` spec", from the scope in
  `~/Projects/initiatives/theme-garden/plans/2026-11-17-route-surface-conductor-prompt.txt`, tagged
  `#milestone:surface`.
- "Write the round `events` two spec", for its passes 2 and 3, from the round two design, site basics, tagged
  `#milestone:events`.
- "Write the theme-garden G3 spec", placed when Geoff starts the theme work. It re-checks the plan against `main`
  first.
- "Run a full backlog sweep". Its body says 47 open items carry no `swept` stamp from the last 90 days, 32 cite
  `tool/` paths deleted in `a96deb40b`, and the numbers #491, #492, and #494 each name two items. The sweep
  renumbers them.

Done when:

1. No open item's placement names a pass or round.
   `sed -n '1,/^## Won/p' BACKLOG.md | grep -o -i -E 'Placement:[^.]*' | grep -c -i -E '\b(pass|round)s?\b'`
   prints `66` today, and `0` after. A placement that names the round `surface` or `events` work names its
   milestone tag.
2. `grep -c '^- \[x\] \*\*#299\*\*' BACKLOG.md` and the same for #459 print `0` today, and `1` after.
3. #522 and #308 moved to `## Won't do`. `sed -n '/^## Won/,/^## Done/p' BACKLOG.md | grep -c -E '\*\*#(522|308)\*\*'`
   prints `0` today, and `2` after. #308's entry says it is refiled in `~/.dotfiles/BACKLOG.md`, and the pull
   request's `## For Geoff` gives the item's exact text, since the task can't commit to that repo. Geoff's session
   files it.
4. The four new items exist. For each title above, `grep -c -F '<title>' BACKLOG.md` prints `0` today, and `1`
   after.
5. CI passes on the pull request.

Reviewers: `standards:diff-reviewer`. Minutes: 95 (work 35, local gates 10, CI wait 40, review 10). Time clause:
190 minutes. Model: Sonnet at medium. Waits for: task 1 merged. It shares no file with task 2, so the two may run
at once.

## After task 3: Geoff's session

Once task 2 has merged, the `cairn-docs-cycle` change from "The workstation change". Then one dry run before
2026-12-01: `git -C ~/Projects/cairn-cms pull --ff-only`, then `cairn-docs-cycle --dry-run`. It must write the
history entry under `~/.local/state/cairn-docs-cycle/<YYYY-MM>/` and commit nothing. If it fails to launch, as
November's run did, `journalctl --user -u model-review.service --since 2026-11-01 --until 2026-11-02` holds the
earlier failure to compare.

After task 3, Geoff's session files #308 in `~/.dotfiles/BACKLOG.md` from the pull request's text. Then
hand-over 2, committed directly: `docs/STATUS.md` says the reshape is done and names the round `surface` spec item
by number.

## Merge order

Hand-over 1, the GitHub settings, the settings change, and the workstation change; then task 1; then tasks 2 and
3 in either order; then the launcher line and hand-over 2.

## Backlog sweep

The scoped `standards:backlog-sweep` verdicts. Approving this spec approves these edits, which task 3 makes.

| Item | Verdict | Edit |
| --- | --- | --- |
| #459 Unsandboxed-prompt rule | Fold | Task 1; task 3 moves it to Done |
| #299 Fold the `CLAUDE.md` minors | Fold | Task 1; task 3 moves it to Done |
| #374 Reword "friction" as "backlog" | Reword | Tasks 1 and 2 take `cairn-releasing` and `CLAUDE.md`; the new wording names what is left, placed at the next task that changes `scripts/gate/` |
| #389 `auth-data` map names the new command's files | Reword | "The repo skill's `auth-data` path map", placed at the task that adds the first of those files |
| #525 Waymark brand link overflows at 320 | Reword | Placement: the next task that changes `themes/waymark` |
| #522 Pass 2's changelog undercount | Drop | Move to Won't do; the entry left with `tool/` |
| #308 Failed check labels in the `cairn-run-gate` record | Drop | Move to Won't do; Geoff's session refiles it in `~/.dotfiles/BACKLOG.md` |
| #359, #408, #424, #473, #565, #566, #552, #371, #372, #329, #435, #191, #564, #489, #291 | Keep | None |
| 66 placements naming a pass or round | Reword | "the next pass that touches X" becomes "the next task that touches X"; a closed named pass becomes its file trigger; a product round becomes its `#milestone:<name>` tag; "tidy pass" becomes "tidy task" |

## For Geoff, outside the tasks

`git worktree list` in the main checkout shows 120 entries: 119 agent worktrees under `.claude/worktrees/`, 49
whose tip isn't on `origin/main`, and 1 with uncommitted changes. No task touches them. His session can remove
the merged, clean ones after a dry run and look at the rest. The routine for sveltejs/kit#17368 is due for
deletion at claude.ai/code/routines, which an agent can't do. The November docs cycle failed to launch
(`journalctl --user -u model-review.service`, 2026-11-01: "cairn docs cycle launch failed"). The dry run after
task 2 checks the launch before December's.

## Calls Claude made

1. The repo skill is named `cairn-build`, by `git mv` of the old folder.
2. One gate form: the committed fast lane, wrapped by `cairn-run-gate` on the workstation.
3. `pass-gate-tiers.md` stays as `gate-tiers.md`, the one home of the tier rules.
4. `cairn-implementer` goes; the conventions a builder needs move into `cairn-build`.
5. A disputed docs call goes under `## For Geoff`, and his session applies the answer before the merge.
6. The monthly docs cycle opens one pull request and ends. A "now" row becomes a BACKLOG item whose fix is a
   later task, and the cycle no longer writes fixes itself.
7. `review-unsupported-claim` is rewritten as the target capability case.
8. Task 1 runs no evals. Task 2's one run, against `87869e61f`, covers task 1's `CLAUDE.md` edits as well.
9. History stays as written, and so do the `media-pass-b` and `media-pass-c` spec names, whose CI baselines would
   be orphaned by a rename.
10. `scripts/gate/` stays unchanged, including the grader's `## Friction` heading, and #374 places its rename.
11. The `check-idioms` and `check-leaks` word lists, the `--class` flag's name, the approval-queue deny entry in
    `run.mjs`, the guard prompts in `evals.json`, and the trigger-test prompts stay, since each is data.
12. Dependabot security updates stay off, and `dependabot.yml` stays as it is.
13. `worktree.baseRef` and the dead `make -C tool check` allow line leave `settings.json`.
14. The `cairn-pass` edit lands before task 1, and the launcher line after task 2.
15. Task 1 runs on Sonnet at high, task 2 on Opus at medium, and task 3 on Sonnet at medium. Each task's
    reviewers run on Opus at high, by `building-from-specs` "Models".
16. The `claude-security` run waits for the next large change to sign-in code, per Geoff's ruling.
17. The runner keeps its four concurrent `claude -p` sessions. They are child processes of task 2's session.
    `claude agents` manages background sessions (its help says "Manage background agents"), and a `claude -p`
    child isn't one, so the four-session cap counts task 2 once.
18. If task 2 hasn't merged by 2026-11-30, its reviewed `cycle-prompt.txt` lands directly, and an unreviewed one
    means December's cycle is switched off.
19. A cycle that finds last month's pull request still open skips the month.
