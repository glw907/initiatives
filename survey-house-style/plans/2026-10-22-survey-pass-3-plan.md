# Survey Pass 3: corrections and grading

Initiative: survey-house-style
Design: `specs/2026-10-21-survey-house-style-design.md` (approved 2026-10-22), "Pass 3: corrections and grading".
Repos: `glw907/survey` (checkout `~/Projects/survey`, the launch checkout); `glw907/workstation` (checkout `~/.dotfiles`); `glw907/survey-notes` (new, private, cloned at `~/Projects/survey-notes`).
Class: `runner` (the survey skill, the output style, the writing-review launcher, and `settings.json`), with the `live-account` flag (a new GitHub repo, two PRs, and a GitHub release). The pass hands its two PRs to Geoff in one packet; its conductor merges them after he approves.
Executor: `survey-pass-3`, `sonnet` at `medium`, launched from `~/Projects/survey`. Conductor: `conductor-survey`, `claude-opus-5-5` at `medium`, launched fresh (the Pass 2 conductor is stopped first).
Adapters: `dotfiles-pass` for the workstation PR; `pass-core` defaults elsewhere. Survey's gate is `scripts/gate`.
Estimate: the design's 100 path minutes. This plan's path is 135: task 3's vendor fetch, its separate launcher script with a systemd test, the release section's clone and worktree steps, and the close's history scan, none of which the design counted. The run stops at 150, the design's 1.5 times rule.
Fold: `research/2026-10-22-survey-pass-3-fold.md` holds the three reviews' dispositions and the rulings.

## Pre-flight

One item, done in the planning sitting:

- [you: ask for the push rule] Geoff asks, in the planning session, for two exact `permissions.allow` rules so a session can push a correction without a prompt. The planner committed them on branch `survey-pass-3` in the `~/.dotfiles` worktree `.claude/worktrees/survey-pass-3` (cut from `origin/main`) and pushed the branch. The `autoMode` line at `settings.json:353` allows that edit only when Geoff asked for the rule in the session, which is why the planner makes it and the executor does not.
  - Done by the planner after the fold (`bcf4496`): the two prefix rules became exact ones, since `push:*` also matches `push --force` (the permissions doc: "A rule with no `*` matches one exact command"). The rules are `Bash(git -C /var/home/glw907/Projects/survey-notes push)` and `Bash(git -C /var/home/glw907/Projects/survey-notes pull --rebase)`. Check: `git -C ~/.dotfiles show origin/survey-pass-3:claude/.claude/settings.json | grep survey-notes` prints two lines, neither containing `:*`.

The planner's pre-launch checks, none of them Geoff's:

- `claude agents --json` lists the Pass 2 conductor `conductor-survey` (id `921fbd88`) as idle and done. Pass 2 is merged and its README line is in, so the planner runs `claude stop 921fbd88` and launches a fresh conductor under the same name.
- `~/Projects/survey` and `~/.dotfiles` are each on `main`, clean, and 0 behind `origin/main` after a fetch.
- `git -C ~/Projects/survey check-ignore -q .claude/worktrees/x` passes.
- `gh repo view glw907/survey-notes` fails (the repo does not exist yet) and `~/Projects/survey-notes` is absent.

## Tasks

The executor's one `EnterWorktree` is in `~/Projects/survey`; its branch is `worktree-survey-pass-3`. The dotfiles worktree is the planner's, `/var/home/glw907/.dotfiles/.claude/worktrees/survey-pass-3` (below, `<dwt>`), reused as is and worked by absolute path. First check: `git -C <dwt> status -sb` shows `survey-pass-3...origin/survey-pass-3`, clean. Every task ends with a commit.

**The vendor fetch**, named once here and rerun wherever a task says so:

1. `git push origin worktree-survey-pass-3` from the Survey worktree. `fetch_skill` reads GitHub at the manifest's `branch`, so an unpushed fix vendors a stale head.
2. `S=$(mktemp -d); mkdir "$S/home"; ln -s <dwt> "$S/home/.dotfiles"`.
3. `rm -rf <dwt>/claude/.claude/skills/survey`, since `fetch_skill` never removes a file upstream dropped.
4. Set the `survey` entry's `branch` in `<dwt>/claude/.claude/tooling/vendored-skills.json` to `worktree-survey-pass-3`, run `<dwt>/bin/.local/bin/claude-tooling-sync update-skills --home "$S/home" survey`, then set `branch` to `v1.2.0`; `commit` keeps the head the files came from.
5. Check: `diff -r <survey worktree>/skills/survey <dwt>/claude/.claude/skills/survey` prints nothing.

1. **Corrections in the skill and the output style** (40, `runner`). Outcome, on the Survey branch:
   - `skills/survey/SKILL.md` gains a `## Corrections` section. When Geoff corrects Claude's wording in chat (rewrites a sentence, strikes a phrase, or names a tell), Claude writes one file to `~/Projects/survey-notes/corrections/`, named `<YYYY-MM-DD>T<HHMMSS>-<host>.md` from `date +%FT%H%M%S` and `hostname -s`. The file holds a short frontmatter (`date`, `host`, `repo`, `audience`, naming the register file when one applies) and four sections: Before, After, Context, Reason. Reason quotes Geoff, or says "not stated"; Claude never supplies a reason of its own.
   - The section then gives the commands, run in the same turn before going on: `git -C /var/home/glw907/Projects/survey-notes add corrections/<file>`, `git -C /var/home/glw907/Projects/survey-notes commit -m "Log a correction" -- corrections/<file>`, `git -C /var/home/glw907/Projects/survey-notes pull --rebase`, and `git -C /var/home/glw907/Projects/survey-notes push`. The last two run exactly as written so the allow rules match. A failed pull or push leaves the commit local and Claude goes on; the next correction's push carries it.
   - If `~/Projects/survey-notes` is missing, Claude runs `gh repo clone glw907/survey-notes /var/home/glw907/Projects/survey-notes` first (this is how thinkpad-x1 gets it). If the clone or the write fails, Claude says so and skips the log; it never writes the file anywhere else. Code corrections are out; a correction to a commit message or a comment's wording is in.
   - Context is the surrounding sentence only, and never holds a secret, a token, mail content, or a third party's personal data; Before, After, and Reason stay verbatim (Ruling 1, Geoff, 2026-10-22).
   - The section states the public-artifact rule: a Survey file, a PR body, or `CHANGELOG.md` never quotes a correction file, its Context, a private repo's name, a path, or a person. An example there is written fresh to show the same pattern.
   - The skill's `description` gains the trigger: when Geoff corrects Claude's wording. The existing UI trigger stays.
   - `skills/survey/SKILL.md` gains a `## Releasing a change` section: the release sequence for this pass's close and the monthly session, written as this plan's "Merge order" generalized to `<version>`. It covers:
     - the version bump (`npm version <version> --no-git-tag-version`) and a dated `CHANGELOG.md` entry in the Survey PR;
     - the workstation PR, built in its own worktree: `git -C /var/home/glw907/.dotfiles fetch -q origin && git -C /var/home/glw907/.dotfiles worktree add .claude/worktrees/survey-<version> -b survey-<version> origin/main`, then the vendor fetch above with that path as `<dwt>`, the Survey PR's branch, and the new tag;
     - after approval, `gh pr merge <n> -R glw907/survey --merge --match-head-commit <head>`, then the release from a fresh clone, never the main checkout: `R=$(mktemp -d); gh repo clone glw907/survey "$R/survey"`, then `npm ci` and `scripts/release <version>` in `$R/survey`. A fresh clone is on `main`, clean, and at `origin/main`, as `scripts/release:10-13` requires, and worktree isolation covers only the repo a session launched from and the main checkout its worktrees link from (the worktrees doc), so an isolated session can release from it;
     - the workstation PR's `## Before merge` check (`git -C "$R/survey" diff --quiet <vendored commit> v<version> -- skills/survey`), its merge with the `PREMERGE_DONE=<n>` prefix and `--match-head-commit <head>`, a pull of `~/.dotfiles`, `stow -R claude`, the check that `claude -p "/output-style"` run from `/tmp` lists `writing-voice (current)`, and `git -C /var/home/glw907/.dotfiles worktree remove .claude/worktrees/survey-<version>`;
     - the rollback, which pins the vendored entry to the previous tag and reruns the fetch.
   - `skills/survey/writing/writing-voice.md` gains one short paragraph, after the opening, naming the step: when Geoff corrects your wording, log it through the `survey` skill's "Corrections" section, then go on. Nothing else in the file changes.
   - `skills/survey/writing/technical-doc-go.md:10` says the vendored `Survey` style where it says `glw907` overlay (the fix Pass 2's PR deferred to 1.2).
   - `.gitignore` gains `STATUS.md`, so the pass's STATUS file doesn't make `scripts/release:12` refuse a dirty tree.
   - `CHANGELOG.md` gets a dated `[1.2.0]` entry (`### Added`: the two sections and the output-style paragraph; `### Changed`: the description and the line-10 fix), and `npm version 1.2.0 --no-git-tag-version` sets `package.json` and `package-lock.json` together.

   Files: `skills/survey/SKILL.md`, `skills/survey/writing/writing-voice.md`, `skills/survey/writing/technical-doc-go.md`, `.gitignore`, `CHANGELOG.md`, `package.json`, `package-lock.json`. Accept:
   - `git diff --stat origin/main` names only these seven.
   - `git diff origin/main -- skills/survey/writing/writing-voice.md` adds one paragraph and removes nothing, and `grep -c 'Corrections' skills/survey/writing/writing-voice.md` prints 1.
   - `head -4 skills/survey/SKILL.md | grep -c -i 'correct'` prints at least 1, and the `description` stays under 500 characters (`claude-tooling-sync`'s cap).
   - `grep -c glw907 skills/survey/writing/technical-doc-go.md` prints 0, and `grep -c 'surrounding sentence' skills/survey/SKILL.md` prints at least 1 (Ruling 1).
   - `grep -c -E 'npm version|npm ci|PREMERGE_DONE|match-head-commit|output-style' skills/survey/SKILL.md` prints at least 5.
   - `tellgrader --register agent skills/survey/SKILL.md skills/survey/writing/writing-voice.md | jq '[.[].findings[]] | length'` is no higher than the same count taken before the task's first edit, or the Survey PR's `## Decisions` lists each added finding with its disposition.
   - `scripts/gate` passes.

   Then push the branch and open the Survey PR as a draft.
2. **The notes repo** (10, `ordinary`, `live-account`). Outcome: `gh repo create glw907/survey-notes --private --clone` run from `~/Projects`, then one commit on `main`, pushed. It holds a `README.md` stating what the repo holds, the correction file's name and format (task 1's), and the monthly folder's layout (task 3's); `corrections/.gitkeep`; `monthly/.gitkeep`; and a `.vale.ini` with `StylesPath = /var/home/glw907/Projects/survey/vale`, `MinAlertLevel = suggestion`, and `[*.md]` `BasedOnStyles = Survey`, so a run lints against the Survey checkout's current style with no sync. A new empty repo's first commit lands on `main` directly; there is nothing to review against. Accept: `gh repo view glw907/survey-notes --json visibility -q .visibility` prints `PRIVATE`; `git -C ~/Projects/survey-notes status -sb` shows `main...origin/main` with nothing ahead; `vale --config ~/Projects/survey-notes/.vale.ini ~/Projects/survey-notes/README.md` runs without a config error.
3. **The monthly writing review** (55, `runner`), in `<dwt>`. Outcome:
   - `docs/model-review/writing-prompt.txt` drives one unattended session. It names ten fixed samples, each a one-line task that stays the same month to month, with its register source and its `tellgrader --register` value:
     - a commit message (`commit-and-pr.md`, `commit`);
     - a PR body opening with `## Brief` (`commit-and-pr.md`, `commit`);
     - a terminal reply reporting a finished task (`writing-voice.md`, `reply`);
     - a web developer doc section (`technical-doc-web.md`, `docs`);
     - a Go developer doc section (`technical-doc-go.md`, `docs`);
     - an editor doc paragraph (`editor.md`, `editor`);
     - a skill section (`agent-facing.md`, `agent`);
     - a TypeScript doc comment (the `ts-conventions` skill, `comments`);
     - a design brief (`approval-brief.md`, `docs`);
     - an error string with its help line (the `go-conventions` skill, `comments`).

     The prompt's steps, in order:
     1. Check for last month's unfinished review: `gh pr list -R glw907/survey --state open --search 'in:title "Monthly writing review"'`, and the same for `glw907/workstation`. If either lists a PR, the session drafts and reports as below, names those PRs under `## Proposals`, makes no new proposals, runs `notify-send -u normal "Writing review: last month's PRs still open" "<the PR URLs>"`, and ends.
     2. Draft each sample into `~/Projects/survey-notes/monthly/<YYYY-MM>/<nn>-<kind>.md` (the run month). Run `vale --config ~/Projects/survey-notes/.vale.ini` and the sample's `tellgrader` on each.
     3. Write `report.md` there. It opens with a `# ` title and a plain `Survey commit: <sha>` line naming the commit Vale ran against, then holds one `## <nn>-<kind>` section per sample giving the Vale alert count and the `tellgrader` finding count. Three sections follow: `## Previous month`, the comparison with the newest earlier `monthly/` folder; `## Corrections`, every file in `corrections/` that no earlier `report.md` lists, named one per line (all of them on the first run); and `## Proposals`. Each of the three says "none" with a reason when empty, and each proposal carries `Before:` and `After:` lines. Only these 13 sections use `## `.
     4. Commit the folder, staging only `monthly/<YYYY-MM>/`. Run `git -C /var/home/glw907/Projects/survey-notes pull --rebase` and `git -C /var/home/glw907/Projects/survey-notes push`, exactly as written so the allow rules match, before any proposal work.
     5. Propose a Survey change only where a correction or a repeated finding supports it. A repeated finding is the same rule or tell in two consecutive months, or in three or more samples in one month. Public artifacts follow task 1's public-artifact rule; the packet may cite correction file names, since the queue is local.
     6. With no proposal, end. With proposals, follow the survey skill's "Releasing a change" up to the packet: the Survey PR (one commit per change, a minor `CHANGELOG.md` entry) and the workstation vendoring PR, each titled `Monthly writing review <YYYY-MM>: ...`. Write both PR numbers and the packet file's name under `## Proposals`, commit, and push with the step 4 commands. Then send both PRs in one packet through `approval-packet`, initiative `survey-house-style`, wait for the decision, and on approve run the merge order the skill states.

     The session runs `claude-opus-5-5` at `medium`, since the samples measure how the daily model writes.
   - `bin/.local/bin/survey-writing-review` (new, bash) launches that session. It first exports the same PATH as `model-review-notify:10` (`$HOME/.local/bin:$HOME/.local/share/mise/shims:/home/linuxbrew/.linuxbrew/bin:/usr/bin:$PATH`), since a transient user unit gets only the manager's PATH and the session inherits the launcher's. It then runs `git -C ~/Projects/survey pull --ff-only`, then `git -C ~/Projects/survey-notes pull --rebase && git -C ~/Projects/survey-notes push`, printing a line naming any refusal and going on; `--dry-run` skips all three, as the review's own dry run skips its pull. It then runs this from `~/Projects/survey`: `systemd-run --user --scope --collect --unit=survey-writing-$(date +%Y-%m) claude --bg --model claude-opus-5-5 --effort medium --name survey-writing-$(date +%Y-%m) "$prompt"`. `$prompt` is the prompt file read from the script's own repo, plus, under `--dry-run`, the sentence "Dry run: commit in survey-notes and stop. Do not push, open a PR, or send a packet." The scope keeps the session out of the timer unit's cgroup, which systemd kills when `model-review.service` (`Type=oneshot`) exits. A probe on 2026-10-22 showed a child in its own scope surviving the oneshot while a plain `setsid` child died (fold record). A failed launch prints a line and exits nonzero.
   - `bin/.local/bin/model-review-notify` keeps each failure's status instead of exiting at once. An audit failure sets `status=1` and skips the review, since the review reads the audit's report; a review failure sets `status=1`. In both cases a block guarded by `[[ "$(hostname -s)" == pavilion ]]` then runs `survey-writing-review` (passing `--dry-run` through) and prints a line on failure; the script ends with `exit "$status"`. A failed review no longer skips the writing month, and the writing review's result never changes the review's exit status.
   - `docs/model-review/prompt.txt` gains one sentence in its hand-over step naming the writing review as the launcher's separate session, so the review session does not run it itself.
   - The vendored skill moves to 1.2.0 through the vendor fetch above.

   Files: `docs/model-review/writing-prompt.txt`, `docs/model-review/prompt.txt`, `bin/.local/bin/survey-writing-review`, `bin/.local/bin/model-review-notify`, `claude/.claude/tooling/vendored-skills.json`, `claude/.claude/skills/survey/**`. Accept:
   - `bash scripts/gate.sh` passes; `bash -n` passes on both scripts; `grep -c 'export PATH=' bin/.local/bin/survey-writing-review` prints 1.
   - `grep -c -- '--register' docs/model-review/writing-prompt.txt` prints 10, each named register file exists under `claude/.claude/skills/survey/writing/`, and each named skill exists under `claude/.claude/skills/`. `git diff origin/main -- docs/model-review/prompt.txt` adds one sentence.
   - The vendor fetch's `diff -r` prints nothing.
   - `readlink -f <dwt>/claude/.claude/output-styles/writing-voice.md` lands in `<dwt>/claude/.claude/skills/survey/writing/`.

   End-to-end test, on the timer's own path. `systemd-run --user --wait -q -p Type=oneshot --unit=survey-writing-launch-test <dwt>/bin/.local/bin/survey-writing-review --dry-run` exits 0, and after it exits, `claude agents --json` lists `survey-writing-2026-10`; take its id from there. Wait with a Monitor until-loop on `git -C ~/Projects/survey-notes log -1 --format=%H -- monthly/2026-10`, timeout 40 minutes; on timeout, run `claude logs <id>` and take the launch standing answer. The run must leave a local commit holding ten drafts (`ls ~/Projects/survey-notes/monthly/2026-10/[0-9][0-9]-*.md | wc -l` prints 10) and a `report.md` for which `grep -c '^## '` prints 13, with no PR and no packet. The executor pushes that commit as the first month's baseline, then runs `claude stop <id>`.
4. **Close** (30). One `diff-reviewer` dispatch at whole-branch scope reads both branches and the notes repo's commit against the design and this plan, then one batched fix chain and the gates again. After any change under `skills/survey/` on the Survey branch, the executor reruns the vendor fetch. One `gitleaks git` branch-history scan runs on the workstation branch (`dotfiles-pass` close checklist). Each PR body opens with `## Brief` and carries `## Decisions` and `## Planning misses`. The workstation PR carries `## Before merge`: the vendored-commit check from the "Releasing a change" section, run after `scripts/release 1.2.0`. The executor writes PR-ready into `~/Projects/survey/STATUS.md` and reports to `conductor-survey`. It sends no packet and merges nothing.

Path: 40 + 10 + 55 + 30 = 135, all in sequence.

The launch prompt names the three push targets: `glw907/survey`, `glw907/workstation`, and `glw907/survey-notes`.

## Merge order (the conductor, after Geoff approves the packet)

1. The Survey PR: `gh pr merge <n> -R glw907/survey --merge --match-head-commit <head>`, then the release from a fresh clone as "Releasing a change" states (`R=$(mktemp -d); gh repo clone glw907/survey "$R/survey"`, then `npm ci` and `scripts/release 1.2.0` in `$R/survey`; step 2's check runs there too), then pull `~/Projects/survey`. Check: `gh release view v1.2.0 -R glw907/survey --json assets` lists `Survey.zip`.
2. The workstation PR's `## Before merge` check, then its merge with the `PREMERGE_DONE=<n>` prefix and `--match-head-commit <head>`. Pull `~/.dotfiles`, run `stow -n -v -R claude`, then `stow -R claude` and `stow -R bin` (the new script), then `claude-tooling-sync apply`. The live `settings.json` is generated, so the push rules take effect only here. `apply` also writes the tracked `autoMode` over the live one; the one differing line is the merge line Geoff changed in `42420d7`, so this brings the live file current. Checks:
   - `claude -p "/output-style"` run from `/tmp` lists `writing-voice (current)`;
   - `grep -c Corrections ~/.claude/output-styles/writing-voice.md ~/.claude/skills/survey/SKILL.md` shows at least 1 in each file;
   - `claude-tooling-sync verify` exits 0.
3. The corrections smoke test. From `/tmp`, run `claude -p` twice with a scripted correction: first a sentence, its rewrite, and a stated reason; then a second correction with no reason. Each run must leave exactly one new file matching `^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{6}-pavilion\.md$`. Each file holds `date`, `host`, `repo`, and `audience` and the four headings, with Reason quoting the scripted reason (the second says "not stated"), and `git -C ~/Projects/survey-notes log origin/main -2 --name-only` names both. Then `git rm` both in one commit and push, so the November review doesn't read fixtures as corrections.
4. A STATUS line for thinkpad-x1, as a routine row in the hand-over: on its next session there, pull `~/.dotfiles` and run `stow -R claude`, `stow -R bin`, and `claude-tooling-sync apply`. The first correction there clones the notes repo, and the launcher's host guard skips the writing review there.
5. The initiative README gains "Pass 3 done", and `initiative.yaml` takes `status: done` and `survey-notes` in `repos`, committed as a hand-over the conductor merges itself.

## Standing answers

From the design: past 150 path minutes, stop and report.

Plus:

- **The end-to-end run fails to launch or dies.** The systemd unit fails, `claude agents` doesn't list the session after the unit exits, or the session errors before drafting. The executor traces the cause; if it is the launcher, it fixes and reruns once. A second failure ships the launcher anyway, the PR's `## Decisions` names the failure, and the first run on 2026-11-01 is attended.
- **A sample draft trips tellgrader's gate or Vale.** That is a finding for `report.md`, never a failure of the pass.
- **The output style after the merge.** If `claude -p "/output-style"` does not list `writing-voice (current)`, the conductor pins the vendored entry back to `v1.1.0`, reruns the vendor fetch, merges that as a hand-over, and reports in STATUS.
- **A `survey-notes` push prompts or is refused**, for any push the pass makes, since the allow rules go live only at merge step 2. The executor records it in `## Decisions`; the commit stays local, and the conductor pushes after the merge.
- **A tag exists without its release** (`scripts/release` pushed the tag, then `gh release create` failed). Run `gh release create v<version> -R glw907/survey --title v<version> --notes "<the CHANGELOG entry>" <a Survey.zip built from vale/Survey>` by hand, then go on. The same answer holds for the monthly session.
- **The monthly session's release is blocked or refused**, by the classifier or by worktree isolation; no `autoMode` release rule backs it (Ruling 2, Geoff, 2026-10-22). The session writes the block into `report.md`, commits and pushes it, runs `notify-send -u normal "Writing review: release blocked" "<the PR URL>"`, and stops.
- **A monthly session dies before acting on a decision**: a reboot, a respawn, or the supervisor's idle stop, which agent-view does not say spares a session waiting on a background command. The workstation PR's `## Decisions` names the idle stop as untested until the first month with a proposal. Its PRs stay open and `report.md` names them; next month's run finds them at its first step and notifies.
- **The corrections smoke test fails.** The conductor files it through `log-issue` and reports in STATUS; the merge stands.

## Later

A correction intake beyond chat (approval-queue edits, the cairn editor), per the design. A sample set larger than ten. A `vale` style for the samples beyond Survey's seven rules. `fetch_skill` pruning files upstream removed, in place of the vendor fetch's `rm -rf`.

## Avoid over-engineering

> "Avoid over-engineering. Only make changes that are directly requested or clearly necessary. Keep solutions simple and focused ... The right amount of complexity is the minimum needed for the current task." (<https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices>)

> "Deliver what was asked, at the scope intended. Make routine judgment calls yourself ... Finish the whole task, and stop short of actions that are clearly beyond what was asked." (<https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-opus-5>)
