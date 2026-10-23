# Survey Pass 3: corrections and grading

Initiative: survey-house-style
Design: `specs/2026-10-21-survey-house-style-design.md` (approved 2026-10-22), "Pass 3: corrections and grading".
Repos: `glw907/survey` (checkout `~/Projects/survey`, the launch checkout); `glw907/workstation` (checkout `~/.dotfiles`); `glw907/survey-notes` (new, private, cloned at `~/Projects/survey-notes`).
Class: `runner` (the survey skill, the output style, the model-review launcher, and `settings.json`), with the `live-account` flag (a new GitHub repo, two PRs, and a GitHub release). The pass hands its two PRs to Geoff in one packet; its conductor merges them after he approves.
Executor: `survey-pass-3`, `sonnet` at `medium`, launched from `~/Projects/survey`. Conductor: `conductor-survey`, `claude-opus-5-5` at `medium`, launched fresh (the Pass 2 conductor is stopped first).
Adapters: `dotfiles-pass` for the workstation PR; `pass-core` defaults elsewhere. Survey's gate is `scripts/gate`.
Estimate: the design's 100 path minutes. This plan's path is 110 (task 3's vendor fetch, which the design did not count); the run stops at 150, the design's 1.5 times rule.

## Pre-flight

One item, done in the planning sitting:

- [you: ask for the push rule] Geoff asks, in the planning session, for one narrow `permissions.allow` rule so a session can push a correction without a prompt: `Bash(git -C /var/home/glw907/Projects/survey-notes push:*)` and `Bash(git -C /var/home/glw907/Projects/survey-notes pull --rebase:*)`. The planner commits the two rules on branch `survey-pass-3` in a `~/.dotfiles` worktree cut from `origin/main` and pushes the branch. The `autoMode` line at `settings.json:353` allows that edit only when Geoff asked for the rule in the session, which is why the planner makes it and the executor does not. Check: `git -C ~/.dotfiles show origin/survey-pass-3:claude/.claude/settings.json | grep -c survey-notes` prints 2.

The planner's pre-launch checks, none of them Geoff's:

- `claude agents --json` lists the Pass 2 conductor `conductor-survey` (id `921fbd88`) as idle and done. Pass 2 is merged and its README line is in, so the planner runs `claude stop 921fbd88` and launches a fresh conductor under the same name.
- `~/Projects/survey` and `~/.dotfiles` are each on `main`, clean, and 0 behind `origin/main` after a fetch.
- `git -C ~/Projects/survey check-ignore -q .claude/worktrees/x` passes.
- `gh repo view glw907/survey-notes` fails (the repo does not exist yet) and `~/Projects/survey-notes` is absent.

## Tasks

The executor's one `EnterWorktree` is in `~/Projects/survey`. The dotfiles worktree is `git -C ~/.dotfiles worktree add .claude/worktrees/survey-pass-3 survey-pass-3` (the planner's branch), worked by absolute path. Every task ends with a commit.

1. **Corrections in the skill and the output style** (30, `runner`). Outcome, on the Survey branch:
   - `skills/survey/SKILL.md` gains a `## Corrections` section. When Geoff corrects Claude's wording in chat (rewrites a sentence, strikes a phrase, or names a tell), Claude writes one file to `~/Projects/survey-notes/corrections/`, named `<YYYY-MM-DD>T<HHMMSS>-<host>.md` from `date +%FT%H%M%S` and `hostname -s`. The file holds a short frontmatter (`date`, `host`, `repo`, `audience`, naming the register file when one applies) and four sections: Before, After, Context, Reason. Reason quotes Geoff, or says "not stated"; Claude never supplies a reason of its own. Then `git -C /var/home/glw907/Projects/survey-notes add <file>`, a commit, `git -C /var/home/glw907/Projects/survey-notes pull --rebase`, and `git -C /var/home/glw907/Projects/survey-notes push`, in the same turn, before going on. If `~/Projects/survey-notes` is missing, Claude clones `glw907/survey-notes` there first (this is how thinkpad-x1 gets it). Code corrections are out; a correction to a commit message or a comment's wording is in.
   - The skill's `description` gains the trigger: when Geoff corrects Claude's wording. The existing UI trigger stays.
   - `skills/survey/SKILL.md` gains a `## Releasing a change` section that states the release sequence Pass 2 ran, once, for this pass's close and the monthly session to follow: the Survey PR; `scripts/release <version>` after its merge; the workstation PR that vendors the Survey branch with `claude-tooling-sync update-skills --home <scratch>/home survey` (`<scratch>/home/.dotfiles` linked to the dotfiles worktree) and then sets the entry's `branch` to the tag; the `## Before merge` check that the vendored commit and the tag carry the same `skills/survey` (`git diff --quiet <commit> v<version> -- skills/survey`); then the workstation merge, a pull of `~/.dotfiles`, and `stow -R claude`.
   - `skills/survey/writing/writing-voice.md` gains one short paragraph, after the opening, naming the step: when Geoff corrects your wording, log it through the `survey` skill's "Corrections" section, then go on. Nothing else in the file changes.
   - `skills/survey/writing/technical-doc-go.md:10` says the vendored `Survey` style where it says `glw907` overlay (the fix Pass 2's PR deferred to 1.2).
   - `CHANGELOG.md` gets a dated `[1.2.0]` entry (`### Added`: the two sections and the output-style paragraph; `### Changed`: the description and the line-10 fix), and `npm version 1.2.0 --no-git-tag-version` sets `package.json` and `package-lock.json` together.

   Files: `skills/survey/SKILL.md`, `skills/survey/writing/writing-voice.md`, `skills/survey/writing/technical-doc-go.md`, `CHANGELOG.md`, `package.json`, `package-lock.json`. Accept: `git diff --stat origin/main` names only these six; `git diff origin/main -- skills/survey/writing/writing-voice.md` adds one paragraph and removes nothing; `tellgrader --register agent skills/survey/SKILL.md skills/survey/writing/writing-voice.md` exits 0; `scripts/gate` passes. Then push the branch and open the Survey PR as a draft.
2. **The notes repo** (10, `ordinary`, `live-account`). Outcome: `gh repo create glw907/survey-notes --private --clone` run from `~/Projects`, then one commit on `main`, pushed: a `README.md` stating what the repo holds, the correction file's name and format (task 1's), and the monthly folder's layout (task 3's); `corrections/.gitkeep`; `monthly/.gitkeep`; and a `.vale.ini` with `StylesPath = /var/home/glw907/Projects/survey/vale`, `MinAlertLevel = suggestion`, and `[*.md]` `BasedOnStyles = Survey`, so a run lints against the Survey checkout's current style with no sync. A new empty repo's first commit lands on `main` directly; there is nothing to review against. Accept: `gh repo view glw907/survey-notes --json visibility -q .visibility` prints `PRIVATE`; `git -C ~/Projects/survey-notes status -sb` shows `main...origin/main` with nothing ahead; `vale --config ~/Projects/survey-notes/.vale.ini ~/Projects/survey-notes/README.md` runs without a config error.
3. **The monthly writing review** (45, `runner`), in the dotfiles worktree. Outcome:
   - `docs/model-review/writing-prompt.txt` drives one unattended session. It names ten fixed samples, each a one-line task that stays the same month to month: a commit message, a PR body opening with `## Brief`, a terminal reply reporting a finished task, a web developer doc section, a Go developer doc section, an editor doc paragraph, a skill section (agent-facing), a TypeScript doc comment, a design brief, and an error string with its help line. Each sample names its register file and its `tellgrader --register` value (`commit`, `docs`, `reply`, `docs`, `docs`, `editor`, `agent`, `comments`, `docs`, `comments`). The session drafts each into `~/Projects/survey-notes/monthly/<YYYY-MM>/<nn>-<kind>.md`, runs `vale --config ~/Projects/survey-notes/.vale.ini` and the sample's `tellgrader` on each, and writes `report.md` there: the findings per sample, a comparison with the previous month's folder (when one exists), and the month's files in `corrections/`. It then proposes Survey changes, each with a before-and-after example, only where a correction or a repeated finding supports it. With no proposal it commits the folder, pulls with rebase, pushes, and ends. With proposals it follows the survey skill's "Releasing a change" (task 1) up to the packet: the Survey PR (one commit per change, a minor `CHANGELOG.md` entry) and the workstation vendoring PR. It sends both in one packet through `approval-packet`, initiative `survey-house-style`, waits for the decision, and on approve runs the merge order the skill states. The session runs `claude-opus-5-5` at `medium`, since the samples measure how the daily model writes.
   - `bin/.local/bin/model-review-notify` gains a block after the review session, guarded by `[[ "$(hostname -s)" == pavilion ]]`. It launches `claude --bg --model claude-opus-5-5 --effort medium --name survey-writing-$(date +%Y-%m) "$prompt"` from `~/Projects/survey` after `git -C ~/Projects/survey pull --ff-only` and `git -C ~/Projects/survey-notes pull --ff-only`, where `$prompt` is the prompt file plus the dry-run sentence under `--dry-run`. A background session stays open for the packet; the `-p` review session could not. A failed launch prints a line and leaves the review's exit status alone.
   - `docs/model-review/prompt.txt` gains one sentence in its hand-over step naming the writing review as the launcher's separate session, so the review session does not run it itself.
   - The vendored skill moves to 1.2.0: the `survey` entry in `claude/.claude/tooling/vendored-skills.json` takes the Survey PR's branch for `update-skills --home <scratch>/home survey`, then `branch` becomes `v1.2.0` and `commit` keeps the head the files came from (Pass 2's task 4 procedure).

   Files: `docs/model-review/writing-prompt.txt`, `docs/model-review/prompt.txt`, `bin/.local/bin/model-review-notify`, `claude/.claude/tooling/vendored-skills.json`, `claude/.claude/skills/survey/**`. Accept: `bash scripts/gate.sh` passes; `bash -n bin/.local/bin/model-review-notify` passes; `cmp` shows each vendored file equals the Survey branch's copy; `readlink -f ~/.claude/output-styles/writing-voice.md` still lands in the vendored writing folder. End-to-end test: run the launcher's claude line by hand from `~/Projects/survey` with the dry-run sentence appended and the name `survey-writing-test`. It must leave `~/Projects/survey-notes/monthly/2026-10/` holding ten drafts and `report.md` in a local commit, with no PR and no packet. The executor pushes that commit as the first month's baseline, then runs `claude stop` on the test session.
4. **Close** (25). One `diff-reviewer` dispatch at whole-branch scope reads both branches and the notes repo's commit against the design and this plan, then one batched fix chain and the gates again. After any change under `skills/survey/` on the Survey branch, the executor reruns task 3's vendor fetch and its `cmp`. Each PR body opens with `## Brief` and carries `## Decisions` and `## Planning misses`. The workstation PR carries `## Before merge`: the vendored-commit check from the "Releasing a change" section, run after `scripts/release 1.2.0`. The executor writes PR-ready into `~/Projects/survey/STATUS.md` and reports to `conductor-survey`. It sends no packet and merges nothing.

Path: 30 + 10 + 45 + 25 = 110, all in sequence.

The launch prompt names the three push targets: `glw907/survey`, `glw907/workstation`, and `glw907/survey-notes`.

## Merge order (the conductor, after Geoff approves the packet)

1. The Survey PR: `gh pr merge <n> -R glw907/survey --merge --match-head-commit <head>`, pull `~/Projects/survey`, `npm ci`, then `scripts/release 1.2.0`. Check: `gh release view v1.2.0 -R glw907/survey --json assets` lists `Survey.zip`.
2. The workstation PR's `## Before merge` check, then its merge with the `PREMERGE_DONE=<n>` prefix. Pull `~/.dotfiles`, run `stow -n -v -R claude` and then `stow -R claude`. Check that `claude -p "/output-style"` run from `/tmp` lists `writing-voice (current)`, and that `claude-tooling-sync verify` is red on nothing but the `autoMode` drift Pass 2 recorded.
3. The initiative README gains "Pass 3 done", and `initiative.yaml` takes `status: done` and `survey-notes` in `repos`, committed as a hand-over the conductor merges itself.

## Standing answers

From the design: past 150 path minutes, stop and report.

Plus:

- **The end-to-end run fails to launch** (`claude --bg` refused or the session errors before drafting). The executor traces the cause; if it is the launcher, it fixes and reruns once. A second failure ships the launcher block anyway, the PR's `## Decisions` names the failure, and the first real run on 2026-11-01 is the test.
- **A sample draft trips tellgrader's gate or Vale.** That is a finding for `report.md`, never a failure of the pass.
- **The output style after the merge.** If `claude -p "/output-style"` does not list `writing-voice (current)`, the conductor pins the vendored entry back to `v1.1.0`, reruns `update-skills`, merges that as a hand-over, and reports in STATUS.
- **A push to `survey-notes` prompts despite the rule.** The executor records it in `## Decisions`; the correction file stays committed locally, and the push runs in the next attended session.

## Later

A correction intake beyond chat (approval-queue edits, the cairn editor), per the design. A sample set larger than ten. A `vale` style for the samples beyond Survey's seven rules.

## Avoid over-engineering

> "Avoid over-engineering. Only make changes that are directly requested or clearly necessary. Keep solutions simple and focused ... The right amount of complexity is the minimum needed for the current task." (<https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices>)

> "Deliver what was asked, at the scope intended. Make routine judgment calls yourself ... Finish the whole task, and stop short of actions that are clearly beyond what was asked." (<https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-opus-5>)
