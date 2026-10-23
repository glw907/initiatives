# Survey Pass 3 plan: fold verification

Target: `plans/2026-10-22-survey-pass-3-plan.md` at initiatives `510c8df`, read against `research/2026-10-22-survey-pass-3-fold.md`, the three reviews (`-review-mechanics.md`, `-review-contract.md`, `-review-integrity.md`), and the design's "Pass 3". Verified against `~/.dotfiles` `origin/survey-pass-3` (`bcf4496`), `claude` 2.1.308, `claude-tooling-sync`, `model-review-notify`, `model-review.{service,timer}`, `~/Projects/survey/scripts/release`, and the live Claude Code docs (permission-modes, agent-view, permissions, worktrees). The verifier had no part in the fold.

Counts: 1 blocker, 3 major, 8 minor (5 correctness, 3 optional).

## Probes and quotes checked

- **Scope survives a oneshot: reproduced.** `systemd-run --user --wait -q -p Type=oneshot` running `setsid nohup sleep 711 &` and `systemd-run --user --scope --collect -q --unit=verify-probe-keep bash -c "setsid nohup sleep 712 &"`: after the unit exited, `sleep 711` was gone, `sleep 712` lived in `app.slice/verify-probe-keep.scope`, and the scope was `active`; it went `inactive` once the child was killed. The fold's claim at fold:11 holds. The step from "a sleep survives" to "the supervisor survives" rests on M-1's observation that a supervisor spawned by a client sits in that client's cgroup; that is reasonable, and the end-to-end test still cannot exercise it (m5).
- **Background reads outside the working directory: quote verified.** permission-modes: "The prompt doesn't appear in non-interactive `-p` runs or background sessions; reads there run as before." M-2's refusal stands.
- **Background sessions move into a worktree before editing: quote verified, but incomplete.** agent-view gives the move and the skip list, including "The write is outside the working directory". The fold left out the consequence the worktrees doc states, which breaks the monthly release path (B1).
- **Background start mode: quote verified.** agent-view: "the new session starts the way a new `claude` session in that directory would"; `~/.claude/settings.json` has `defaultMode: auto`. M-10's refusal stands.
- **Exact Bash rules: quote verified.** permissions: "A rule with no `*` matches one exact command"; compound commands are split and "A rule must match each subcommand independently."
- **Settings branch: verified.** `origin/survey-pass-3:claude/.claude/settings.json:15-16` holds exactly `Bash(git -C /var/home/glw907/Projects/survey-notes push)` and `Bash(git -C /var/home/glw907/Projects/survey-notes pull --rebase)`, with no `:*`. The worktree shows `## survey-pass-3...origin/survey-pass-3`, clean. The plan:16 cite of `settings.json:353` matches `origin/main`.
- **Skill commands against the rules: match.** plan:40 writes both commands character for character as the rules and says they "run exactly as written". The prompt's steps do not (m1).
- **Vendor fetch: verified.** `fetch_skill` (`claude-tooling-sync:397-422`) reads `branch` from GitHub and never prunes. `update_skills` restows with `-t paths.home`, so `--home "$S/home"` keeps the restow in scratch. The seven register files and `ts-conventions` and `go-conventions` exist. `tellgrader --register` accepts `docs, editor, commit, reply, agent, comments`.
- **Transient-unit PATH: a new defect** (M1). `systemctl --user show-environment` gives `PATH=/usr/lib64/ccache:/usr/local/sbin:/usr/local/bin:/usr/bin`, and `claude` is `/home/linuxbrew/.linuxbrew/bin/claude`. A `systemd-run --user --wait -p Type=oneshot` probe printed "claude not on PATH".

## Closure of the reviews' blockers and majors

| Finding | Disposition | Where | Verdict |
| --- | --- | --- | --- |
| C-B1, I-1, M-1 (session dies with the oneshot) | folded | plan:83, :94, :118 | Closed in mechanism (probe reproduced). The test as written fails first time on PATH (M1). |
| C-M1 (report criteria vacuous) | folded | plan:77, :94 | Closed; heading count ambiguous (m3). |
| C-M2, I-4, M-5 (month window) | folded | plan:76-77 | Closed. |
| C-M3 (release section incomplete) | folded | plan:44, :55 | Steps present, but the section cannot run from an isolated session (B1) and names no dotfiles worktree (M2). |
| C-M4, I-10 (main checkout) | refused | fold:31, :62 | Refusal not supported: isolation blocks the release steps (B1). |
| C-M5 (no correction test) | folded | plan:108, :125 | Closed. |
| C-M6 (tellgrader vacuous) | folded | plan:56 | Closed. |
| I-2 (death during packet wait) | partial | plan:80, :124 | Closed for reboots. An idle-stop risk is not examined (m4). |
| I-3 (two runs collide) | partial | plan:75 | Closed as argued. |
| I-5 (leak to public repos) | folded plus Ruling 1 | plan:42 | Closed. |
| I-6 (force push) | folded | plan:17; branch `:15-16` | Closed, verified. |
| I-7 (unpushed corrections) | partial | plan:40, :83 | Closed. |
| I-8 (folder uncommitted before wait) | folded | plan:78 | Closed. |
| M-2 (`--add-dir`) | refused | fold:75 | Refusal stands (quote verified). |
| M-3 (`claude-tooling-sync apply`) | folded | plan:104, :109 | Closed. |
| M-4 (thinkpad-x1) | folded | plan:41, :109 | Closed. |
| M-6 (worktree add fails) | folded | plan:28 | Closed, verified. |
| M-7 (release blocked) | Ruling 2 | fold:100 | Ruling rests on a false premise (M3). |
| M-8 (commands written out) | folded | plan:30-36, :40-41 | Closed. |

## Findings

### B1. The monthly session cannot run "Releasing a change" from the main checkout once it has edited Survey files

- Severity: blocker. Tag: correctness.
- Location: plan:44 (the "Releasing a change" section: "a pull of `~/Projects/survey` on `main`, `npm ci`, and `scripts/release <version>`"), plan:80 (prompt step 6 follows that section), fold:13 and fold:31 (C-M4's refusal), fold:62 (I-10's refusal).
- Defect: the fold refused C-M4 because a `--bg` session "moves itself into a worktree before editing". It is right that the session moves. But the worktrees doc, "How Claude Code enforces isolation", says that once the session is in its worktree it is blocked from the main checkout, "whether the session is interactive or runs in the background": "Claude Code blocks a Bash, PowerShell, or Monitor command whose working directory resolves to the main checkout", and "blocks a Bash or Monitor command that redirects git into the main checkout ... through `git -C`". A proposal edits Survey files, so the session is isolated in `~/Projects/survey/.claude/worktrees/...`. After the merge, the steps that pull `~/Projects/survey`, run `npm ci` there, and run `scripts/release` all target the main checkout, and `scripts/release:10` refuses any branch but `main`, so the release cannot move into the worktree. The workstation already records this failure: `model-review-notify:19-21` says "the session cannot pull the main checkout after its own self-merge, so the pull happens here." The dry-run end-to-end test stops before any proposal, so nothing in the pass would show it. The blocked-release standing answer (plan:123) covers only a classifier block, so the first month with a proposal ends with a merged Survey PR, no tag, no notice, and an open workstation PR. The design promises that "an approved change is a Survey minor", and that promise does not execute as written.
- Proposed fix: in "Releasing a change", after the Survey merge and before the pull, have the session call `ExitWorktree` (the worktrees doc: "Claude can still exit it with the `ExitWorktree` tool"; enforcement applies "while a session is isolated"). Then run the pull, `npm ci`, and `scripts/release` with the main checkout as the working directory. Before folding, confirm in one probe that a background session which has exited its worktree can run `git -C ~/Projects/survey status`. Widen plan:123 to "the release is blocked or refused, by the classifier or by worktree isolation". Re-sort fold:31 and fold:62 from "refused" to "folded" with this mechanism.

### M1. The launcher sets no PATH, so the end-to-end test's unit cannot find `claude`

- Severity: major. Tag: correctness.
- Location: plan:83 (`bin/.local/bin/survey-writing-review`), plan:94 (the end-to-end test runs that script directly under `systemd-run --user`).
- Defect: a transient user unit gets the manager's PATH, `/usr/lib64/ccache:/usr/local/sbin:/usr/local/bin:/usr/bin`. `claude`, `vale`, and `gh` live in `/home/linuxbrew/.linuxbrew/bin`, and `tellgrader` lives in `~/.local/bin`. A probe unit printed "claude not on PATH". On the timer path the script inherits `model-review-notify:10`'s export, but the plan's test bypasses that script, so the test's first run fails at launch. The agent-view doc also says a background session "runs with the `PATH` of the shell you dispatched it from", so a launcher without the export would start a session that cannot run `vale` or `tellgrader`. The standing answer's one rerun would probably absorb the failure, but the plan should name the fix rather than leave it to be discovered.
- Proposed fix: plan:83 adds that the script first exports the same PATH as `model-review-notify:10` (`$HOME/.local/bin:$HOME/.local/share/mise/shims:/home/linuxbrew/.linuxbrew/bin:/usr/bin:$PATH`). Task 3's accept adds `grep -c 'export PATH=' bin/.local/bin/survey-writing-review` prints 1.

### M2. "Releasing a change" names no dotfiles worktree for the monthly session's vendoring PR

- Severity: major. Tag: correctness.
- Location: plan:44 ("the workstation PR, which runs the vendor fetch above with the PR's branch and the new tag"), plan:30-36 (the fetch is written against `<dwt>`, the planner's worktree), plan:80.
- Defect: the vendor fetch's `<dwt>` is this pass's planner worktree. The generalized section never says where the monthly session gets its own. `~/.dotfiles` is outside the session's working directory, so the agent-view skip ("The write is outside the working directory") applies, and the session would branch and edit in the `~/.dotfiles` main checkout. That breaks "one executor per worktree" and leaves the checkout off `main` for days during the packet wait. C-M4's fold proposal asked for this ("Have 'Releasing a change' say that the vendoring happens in a `~/.dotfiles` worktree"), and the refusal dropped it with the rest.
- Proposed fix: the section's workstation step opens with `git -C /var/home/glw907/.dotfiles fetch -q origin && git -C /var/home/glw907/.dotfiles worktree add .claude/worktrees/survey-<version> -b survey-<version> origin/main`, and the fetch then runs with that path as `<dwt>`. The close removes that worktree after the merge.

### M3. Ruling 2's evidence is incomplete, so Geoff cannot rule on it as framed

- Severity: major. Tag: correctness.
- Location: fold:100 (Ruling 2), plan:123.
- Defect: the ruling treats the classifier as the only thing that might stop the monthly release. Its evidence is that "the conductors released v1.0.0 and v1.1.0 under the classifier". Those conductors never edited Survey files, so they were never isolated, and they ran from a planner launch of an approved plan, not a timer prompt. Under B1 the release fails whichever way Geoff rules, so a "no" taken on this evidence leaves a path that cannot finish, and a "yes" adds a settings rule that does not unblock it.
- Proposed fix: fold B1 first, then restate Ruling 2 with both obstacles named. One is worktree isolation, fixed by `ExitWorktree`. The other is the classifier's public-surface consent, for which no block has been measured, and the widened standing answer records one. Keep the recommendation if it still holds.

### m1. The prompt's push commands are not written out, so they cannot match the exact rule

- Severity: minor. Tag: correctness.
- Location: plan:78 (prompt step 4: "Run `git -C ... pull --rebase` and push"), plan:80 (step 6: "commit, and push").
- Defect: an exact-match rule matches one exact command, and "push" in prose leaves the form to the session (`git push`, `git -C ~/Projects/survey-notes push`, or a remote and branch). In auto mode an unmatched push falls to the classifier, so this rarely blocks, but the fold's stated purpose (fold:58: "The exact rules match the commands the skill writes out") is met only in the skill.
- Proposed fix: write `git -C /var/home/glw907/Projects/survey-notes push` in steps 4 and 6, with plan:40's line "run exactly as written".

### m2. Task 1's add and commit name the file two ways

- Severity: minor. Tag: correctness.
- Location: plan:40 (`add <file>` against `commit ... -- corrections/<file>`).
- Defect: with `-C`, a bare `<file>` resolves against the repo root, so `add <file>` stages nothing unless `<file>` already carries `corrections/`, and then the commit pathspec doubles it.
- Proposed fix: `git -C /var/home/glw907/Projects/survey-notes add corrections/<file>`.

### m3. The report heading count can be thrown off by the Survey-commit line

- Severity: minor. Tag: correctness.
- Location: plan:77 ("It names the Survey commit Vale ran against"), plan:94 (`grep -c '^## '` prints 13).
- Defect: if the session writes the commit as a `## Survey commit` heading, the count is 14 and a correct report fails the test.
- Proposed fix: plan:77 says the report opens with a `# ` title and a plain `Survey commit: <sha>` line, and that only the 13 named sections use `## `.

### m4. A days-long packet wait in an unattended background session may be stopped as idle

- Severity: minor. Tag: correctness.
- Location: plan:80 ("send both PRs in one packet through `approval-packet` ... wait for the decision"), plan:124.
- Defect: agent-view says the supervisor stops a session that is "Finished or waiting for your next message, and unattached for about an hour". It names subagents, workflows, monitors, and session-scoped scheduled tasks as counting as working, and does not say whether a background Bash command does. approval-packet step 6 sends the packet "as a background Bash command and stay open". If the stop applies, every month with proposals ends in plan:124's case, and the release waits for the next month's notice.
- Proposed fix: prompt step 6 waits on the packet command under a Monitor, since monitors count as working. Alternatively, the fold could cite a background conductor that survived a multi-hour packet wait as evidence.

### m5. The end-to-end test cannot reach the no-supervisor case, and a same-month relaunch collides on the scope name

- Severity: minor. Tag: optional.
- Location: plan:83 (`--unit=survey-writing-$(date +%Y-%m)`), plan:94, fold:27.
- Defect: the executor's own supervisor runs during the test, so the test passes whether or not the scope holds a fresh supervisor (the fold concedes this). When the scope does hold one, the scope lives as long as that supervisor, and a second launch in the same month fails with "unit already exists".
- Proposed fix: the PR's `## Decisions` names the November run as the first no-supervisor run. Either drop `--unit` and let systemd name the scope, or add `-%d%H%M` to its name.

### m6. Whether the review runs after a failed audit is unstated

- Severity: minor. Tag: correctness.
- Location: plan:84 ("The audit and review failures set `status=1`").
- Defect: today a failed audit exits before the review (`model-review-notify:29-32`), and the review prompt points at the audit report. The new text can be read as running the review on a failed audit.
- Proposed fix: say that an audit failure sets `status=1` and skips the review, that a review failure sets `status=1`, and that the writing block runs in both cases.

### m7. The new `model-review-notify` block is checked only by `bash -n`

- Severity: minor. Tag: optional.
- Location: plan:84, plan:89, plan:94.
- Defect: the end-to-end test calls the launcher directly, so nothing exercises the host guard, the `--dry-run` pass-through, or the `exit "$status"`.
- Proposed fix: `grep -n -E 'hostname -s|survey-writing-review|exit "\$status"' bin/.local/bin/model-review-notify` prints three lines.

### m8. Task 2 depends on a working-directory change

- Severity: minor. Tag: optional.
- Location: plan:60 (`gh repo create glw907/survey-notes --private --clone` "run from `~/Projects`").
- Defect: an executor isolated in a Survey worktree has to `cd` out of that worktree for the clone to land at `~/Projects/survey-notes`. A path-explicit form avoids the move.
- Proposed fix: `gh repo create glw907/survey-notes --private`, then `gh repo clone glw907/survey-notes /var/home/glw907/Projects/survey-notes`, the same clone command task 1 uses.

## No contradiction or order defect found beyond the above

The task order builds. Task 1 pushes before task 3's fetch. The fetch's `branch` swap and the `## Before merge` content diff agree with `fetch_skill`. Merge step 1 tags before step 2's check. The rules go live at step 2, before the smoke test's pushes in step 3. The path arithmetic (plan:9, :97, fold:5) agrees. Ruling 1 can be ruled on as given.
