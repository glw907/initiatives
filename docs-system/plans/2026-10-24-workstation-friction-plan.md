# Workstation friction plan: the fact-checker's file, ci-green's held runs, and the sweep checks

Initiative: docs-system

Design: `~/Projects/initiatives/docs-system/specs/2026-10-24-friction-round-2-design.md`,
"The workstation pass", approved by Geoff on 2026-10-24 (glw907/initiatives#121, merge
`de9140d`), with the ask answered "Let it write that file". Packet step 1 is done: the merge, and
cairn-cms #55 filed (`464bf958a`). Drafter #42 and #43 close in the drafter pass's backlog commit,
since drafter-batch-friction's close edits the neighboring lines. This plan carries step 2.

Path estimate: 365 minutes, inside the design's 660-minute standing ceiling. The arithmetic is
under "Path".

The planning session read `~/.dotfiles` at `3bfdcd5`. Lines move; the executor finds each quoted
symbol by name. The adapter is the project-scoped `dotfiles-pass` skill
(`~/.dotfiles/.claude/skills/dotfiles-pass/SKILL.md`); load it with `pass-core`.

One `plan-reviewer` read returned 3 blockers, 6 majors, and 12 minors, all folded. Two changed the
design, and Geoff ruled on both in chat on 2026-10-24:

- `writing-voice.md` is a vendored copy of glw907/survey's file (pinned at `v1.2.0` in
  `claude/.claude/tooling/vendored-skills.json`), so a workstation edit is overwritten. Geoff:
  ship the tell through a Survey release in this pass (T5).
- ci-green's new exit 4 needs a caller rule. Geoff: a cairn executor approves a held run whose
  triggering actor is the repo's own `github-actions[bot]` and re-issues the watch; any other held
  run stops the line for him.

The other folds: T1's test dispatch ran the main checkout's agent (`~/.claude/agents` links into
it); the installed `tellgrader` is a separate binary stow never updates; the remnant regex missed
half the real remnants; the heredoc and the missing parent directory in T1; tellgrader prints
JSON only, and its hook ignores anything but findings; the wrong blueprint commit; the conductor's
name; the repository's name; and the PR-number order at close.

## Pre-flight

Nothing for Geoff. The conductor checks each item just before launch:

- `~/.dotfiles` is on `main`, `git status --porcelain` prints nothing, and
  `git rev-list --count HEAD..origin/main` prints 0 after `git fetch origin`.
  `git check-ignore -q .claude/worktrees/x` exits 0.
- `~/Projects/survey` is on `main` with nothing uncommitted, and no live session works
  `~/.dotfiles` or `~/Projects/survey` (`claude agents --json`, by `cwd`).
- `go`, `node`, `npm`, `jq`, `gh`, `gitleaks`, and `cairn-run-gate` resolve, and `gh auth status`
  answers.
- This plan and its two prompts are committed on initiatives `main`.

## Outcome

The fact-checker agent writes its findings array to a path the dispatch names and checks it with
`jq`. `ci-green` reports an `action_required` run as held, exits 4, and prints the release
command, and `cairn-pass` says what an executor does with it. `tellgrader` reports two new
warnings, the empty "own" and the dangling possessive, in its JSON and its edit hook, without
failing a gate. Survey `v1.3.0` names the empty "own" as a tell, vendored into the workstation. A
word-sweep method page holds the pre-gate checks. The batch author prompt carries record items 56
to 59.

Risk class: `runner` (the adapter's map: an agent, a skill, `ci-green`, `tests/**`, and the
vendored skill under `claude/.claude/skills/`). No `live-account` beyond the Survey release, which
publishes a tag on glw907/survey after Geoff's approval.

## Scope guard

Every subagent prompt carries these two samples verbatim:

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

## Shared rules

- Gate: `bash scripts/gate.sh` from the worktree, with the Bash tool's timeout at 600000,
  re-issued on exit 75. It is the fast lane and the full-suite home, and it runs
  `make -C claude/.claude/skills/writing-voice/evals/tellgrader check`,
  `node tests/ci-green.test.mjs`, and `claude-tooling-sync lint --root .`.
- `~/.claude/agents`, `~/.claude/skills`, and `~/.claude/docs` link into the main checkout, and
  `~/.local/bin/tellgrader` is a separately built binary. Nothing edited in the worktree is live
  until the merge (and, for `tellgrader`, `make install`). Every test of edited behavior runs the
  worktree's copy.
- Before editing an agent, a skill, or a doc under `claude/.claude/`, the session loads
  `claude-infra` and follows its rules for where the text lives.
- Go follows `go-conventions` (by path in a subagent:
  `/var/home/glw907/.claude/skills/go-conventions/SKILL.md`); JavaScript follows `ts-conventions`
  (`/var/home/glw907/.claude/skills/ts-conventions/SKILL.md`).
- A pair runs as pass-core "Pairs" says. A mechanical merge conflict is resolved by keeping both
  sides and re-running the gate; only a semantic conflict stops the line.
- New prose follows the `writing-voice` skill's developer register; the `tellgrader` hook runs on
  each edit.

## Tasks

### T0. Enter the worktree (5 min)

`EnterWorktree` with the name `friction-round-2`, from the `~/.dotfiles` main checkout. Arm the
API-drop wake-up (`/loop` with no interval). Acceptance: the branch is
`worktree-friction-round-2`, and the gate is green on the untouched tree.

### T1. The fact-checker writes its findings (#31) (30 min, runner), pair with T2

Outcome: a dispatch that names a findings path gets the array written there, and a dispatch that
names none gets today's reply.

Files: `claude/.claude/agents/fact-checker.md`.

- The opening paragraph's "never run a command that writes" gains one exception. When the dispatch
  names a findings path, the agent runs `mkdir -p "$(dirname <path>)"`, writes its array there in
  one heredoc with a quoted, unique delimiter (`<<'FINDINGS_EOF'`, since claims carry backticks and
  `$`), runs `jq -e 'type == "array"' <path>`, and hands back the path and the verdict counts and
  nothing else. It writes no other file.
- With no path named, the final reply is the array, as today.
- The frontmatter description gains one clause, keeping the whole under the gate's 500-character
  `DESCRIPTION_CAP` (it is 323 now).
- Cite the reason in one line: one run in eight appended prose after the array, and the handback
  needed a transcript parser to save (pilot item 23, batch 2 item 18).

Acceptance: the gate is green. A `general-purpose` agent at the fact-checker's model and effort,
whose prompt is the worktree's `fact-checker.md` body followed by the dispatch, runs on a
three-claim synthetic file in a scratch git repo. The dispatch names a findings path two
directories deep that doesn't exist yet. The agent writes a file `jq -e 'type == "array"'`
accepts, a claim holding a backtick and a `$` survives byte for byte, and the handback holds the
path and the counts.

### T2. ci-green's held state (#32) (75 min, runner), pair with T1

Outcome: a run waiting on approval reads as held, exits 4, and prints the release command, and
cairn executors know what to do with it.

Files: `bin/.local/bin/ci-green` (the exit-code comment), `bin/.local/bin/ci-green-lib.mjs`
(`EXIT`, `classify`, the printer, `finish`, `ciRecord`), `tests/ci-green.test.mjs`, a new fixture
under `tests/fixtures/ci-green/`, and `claude/.claude/skills/cairn-pass/SKILL.md` (its "CI watch"
line).

- The facts, verified live by the reviewer: GitHub reports a held run as `status: "completed"`,
  `conclusion: "action_required"` (cairn-cms run 40079746768, attempt 1, triggering actor
  `github-actions[bot]`). Today `classify`'s `done.filter((r) => r.conclusion !== "success")` makes
  it red. The approve endpoint released it: attempt 2 succeeded.
- `classify` takes held runs out of `red`, and so out of `planReruns`. `EXIT` gains `held: 4`.
  Red wins over held, and held wins over missing and pending, since waiting never clears a held
  run. Beside a red, the output still prints the held lines.
- The output names each held run, its triggering actor, and
  `gh api -X POST repos/<owner>/<repo>/actions/runs/<id>/approve`, with the repository from
  `run.repository.full_name`. The new fixture keeps that field (the existing fixtures strip it):
  a trimmed capture of `gh api repos/glw907/cairn-cms/actions/runs/40079746768/attempts/1`.
- `--wait` returns at once on held, without a sleep. The `kind: "ci"` record carries
  `outcome: "held"`.
- `cairn-pass` "CI watch": exit 4 is held. When the held run's triggering actor is the repo's own
  `github-actions[bot]`, the executor runs the printed approve command and re-issues the watch; any
  other actor's held run stops the line for Geoff (his ruling, 2026-10-24).
- `## Decisions` notes that an approved run shows `run_attempt: 2`, so a green verdict afterward
  prints its rerun line and the clock restarts; that wart stays.

Acceptance: the gate is green; tests cover one held run alone (exit 4, the actor, the command),
held beside a red (exit 1, held lines still printed), held beside pending (exit 4), and `--wait`
returning on held with the injected `sleep` never called.

### T3. tellgrader's two warnings (Survey #1's check, #2) (90 min, runner), pair with T4

Outcome: `tellgrader` reports a warning for the empty "own" and for a dangling possessive, in its
JSON and its edit hook, and neither changes the exit code or the tell rate.

Files: `claude/.claude/skills/writing-voice/evals/tellgrader/internal/tellscan/` (`checks.go`,
`scan.go`, the `Report` type, their tests), `internal/posthook/` (`keptFindings` and its tests),
and `MEASURES.md` if it lists checks.

- `Report` gains `Warnings []Finding`, initialized to `[]Finding{}` so the JSON carries `[]`. Warnings
  stay out of `Counts`, `Findings`, `tells_per_1000_words`, and the gate's exit code. tellgrader
  prints JSON only; there is no text mode to add.
- `empty-own`: `(?i)\b(?:'s|’s|its|their|our|your|his|her) own\b`. A contrast keeps "own" legal and the
  scan can't tell, so it is a warning by design.
- `dangling-possessive`, the tested pattern (14 of 14 remnants in cairn-cms `3960d4913`, one false
  hit in about 4.2M words): `(?i)\b(?:its|their)(?:[.,;:!?)]|\s(?:the|a|an|and|or|to|in|is|are|when|but)[ \t\n,.;:])`.
  Exactly one whitespace character rejects code spans Scan has blanked; the trailing character
  rejects "its in-flight". Go RE2 has no lookahead, so keep this form.
- The edit hook (`tellgrader --hook`) surfaces warnings scoped to the changed lines, as it does
  findings, marked as warnings.
- `## Decisions` records why a separate `Warnings` field instead of a non-gating finding: it keeps
  the two out of `tells_per_1000_words`.

Acceptance: the gate is green; a table test holds the 14 remnant lines of `3960d4913`'s removed
side as recall cases (copied into a test fixture), the contrast sentence (warns, by design), and
clean sentences including "its in-flight" and a blanked code span; `TestGoldenRegressionScans`
passes unchanged; the JSON carries `warnings`; the hook test shows a warning on a changed line and
none on an unchanged one.

### T4. The word-sweep method page (record item 61) (40 min, runner), pair with T3

Outcome: a session running a scripted word sweep has one page that says how, including the two
pre-gate checks.

Files: one new page in `claude/.claude/docs/` (its name and any pointer set by `claude-infra`'s
rules; a pointer from the `writing-voice` skill's router is the likely home). Agents and docs need
no manifest entry, since each directory is its own manifest (`claude-tooling.md`, "Layout").

- The PR #137 method in short: split the work into slices, one agent and worktree each, at most
  two at once; remove by judgment, keeping a real contrast, idioms, and identifiers; prove code
  changes with a compile-equivalence check, except where runtime text changes on purpose; close
  with a whole-branch review. Source: initiatives
  `docs-system/research/2026-10-23-extend-blueprints-batch-2-handoff/RESUME.md` step 4 and
  `tools/sweep-prompt.md`.
- Before any gate, the two exact commands:
  `git diff --numstat <base>...HEAD | awk '$1 != $2'` (a word sweep keeps each line's count, so an
  emptied file shows at once), and
  `tellgrader <files> | jq '[.. | objects | select(has("warnings")) | .path as $p | .warnings[] | select(.check == "dangling-possessive") | {path: $p, line, excerpt}]'`
  (tellgrader prints one object for one file and an array for several; the filter reads both).
- One line each for the two incidents: the emptied `gate-tier.mjs` (cairn-cms #55) and the 14
  remnants repaired in cairn-cms `3960d4913`.

Acceptance: the gate is green; both commands run as written against a scratch repo; a
fresh-context `prose-voice-reviewer` read returns no blocking finding.

### T5. The Survey release (Survey #1's tell) (90 min, runner)

Outcome: Survey `v1.3.0` names the empty "own" as a tell, and the workstation PR vendors it.

Files: in `~/Projects/survey`, `skills/survey/writing/writing-voice.md`, `package.json`,
`package-lock.json`, `CHANGELOG.md`; in the pass worktree, `claude/.claude/skills/survey/**` and
`claude/.claude/tooling/vendored-skills.json`.

- Follow the vendored `survey` skill's "Releasing a change" steps 1 and 2
  (`claude/.claude/skills/survey/SKILL.md`), with two changes: the workstation side vendors into
  this pass's worktree, not a second worktree, and steps 3 to 6 run after Geoff's approval, by the
  conductor, as the PR's `## Before merge`.
- The Survey change, on a branch in a Survey worktree
  (`git -C ~/Projects/survey worktree add .claude/worktrees/empty-own -b empty-own origin/main`):
  one bullet under "Avoid these structural habits:" naming the empty "own" (a possessive plus
  "own" that adds nothing), pointing at the contrast example the file already has near line 90
  ("The site declares its own role names, or uses the default pair") as the case that keeps it.
  `npm version 1.3.0 --no-git-tag-version`, a dated `CHANGELOG.md` entry, and Survey's own check
  (`npm test` or what its README names). Push the branch and open the Survey PR on glw907/survey.
- Vendor it per step 2.2 to 2.5, then set the manifest's `branch` to `v1.3.0`. The `diff -r` of
  step 2.5 prints nothing.

Acceptance: the Survey PR is open with its check green; the gate is green in the pass worktree;
`diff -r <survey worktree>/skills/survey <pass worktree>/claude/.claude/skills/survey` prints
nothing; the manifest names `v1.3.0` and the Survey branch head as `commit`.

### T6. The batch author prompt (record items 56 to 59) (25 min, ordinary)

Outcome: the next docs pass's author prompt carries the four fixes.

Files: `~/Projects/initiatives/docs-system/research/2026-10-23-extend-blueprints-batch-2-handoff/author-template.txt`,
committed to initiatives `main` from a detached worktree cut from `origin/main` and pushed with
`git push origin HEAD:main`, since other sessions work in the initiatives checkout.

- 56: "bare code fences" becomes "a fence with no `Code:` bullet above it".
- 57: the old phrasing isn't in the template, so the method section gains one line: "Where a
  fixture question meets a concrete snippet, write the snippet and raise the fixture as a note."
- 58: the retired-name warning (line 17) names a placeholder the session fills per page from the
  outline, never a fixed list.
- 59: the credential line (line 48) names its facts from the page's plan, never a fixed list.

Acceptance: `grep` finds each of the four new phrasings and none of the old ones for 56, 58, and
59; the commit is on initiatives `main`.

### C. Close (80 min)

1. The end-to-end check, its outputs in the PR body:
   - Build the worktree's tellgrader to scratch:
     `go build -o <scratch>/tellgrader ./cmd/tellgrader` in the worktree's tellgrader directory.
     Run it with `--register docs` on a scratch file holding lines 21 and 22 of
     `git -C /var/home/glw907/Projects/cairn-cms show 60b908cee:blueprints/docs/extend/arrange-the-admin-sidebar.blueprint.md`
     (the two "own" lines Geoff flagged), a remnant sentence, and the contrast sentence: a warning
     for each, the exit code unchanged.
   - `ci-green`'s held fixture test output.
   - T1's scratch dispatch: the file path, `jq` accepting it, and the handback.
2. Whole-branch `diff-reviewer` against the design and this plan, loading the adapter's checklist
   globs (`go-conventions` for `*.go`, `ts-conventions` for `*.mjs`), one batched fix chain, the
   gate again, and one `gitleaks git` scan of the branch history.
3. Open the PR on glw907/workstation (the repo `git -C ~/.dotfiles remote get-url origin` names)
   from `worktree-friction-round-2` with `## Brief`, what landed, the end-to-end outputs,
   `## Decisions`, `## Planning misses`, the found-not-done list, the score, and `## Before merge`:
   the Survey merge, the release from a fresh clone (`scripts/release 1.3.0`), and the check
   `git -C "$R/survey" diff --quiet <vendored commit> v1.3.0 -- skills/survey`, in order.
4. Then tick `~/.dotfiles` #31 and #32 with the PR number in a follow-up commit on the branch.
   Survey #1 and #2 tick in the Survey PR before its merge, by the conductor if the PR is already
   up. Stop at PR-ready and message conductor-.dotfiles.

## Path

T0 5 + pair (T1 30, T2 75) 75 + pair (T3 90, T4 40) 90 + T5 90 + T6 25 + C 80 = 365 minutes. The
task sum is 435.

## Standing answers

1. A clock stop writes its minutes to STATUS, rewrites `start=`, and carries on while the actual
   path stays under 660 minutes. Past 660 the executor stops and the conductor asks Geoff.
2. No API credit beyond the session's own agents: T1's scratch dispatch is a subagent, never an
   API seat.
3. A review finding that a smaller change can satisfy takes it and lists it in `## Decisions`.
   Only a finding that needs a different design stops.
4. A cause that returns after its fix gets one structural fix, then escalates in the PR body. T4
   and T6 can be escalated that way without breaking the outcome; T1, T2, T3, and T5 cannot. If one
   of those still fails after its structural fix, the rest and the close still run, and the PR
   reports the item unmet in its Brief.

## Merge order and hand-over

Two PRs: glw907/survey (T5) and glw907/workstation. Both go in one packet, the workstation PR with
its `## Before merge` ask ("The session runs it, then merges"). The workstation PR merges before
the drafter stage-advance PR, whose skill line tells a session the fact-checker can write its file.

conductor-.dotfiles merges on Geoff's approve, in this order:

1. The Survey PR, with `--match-head-commit`.
2. The release from a fresh clone, per the survey skill's step 4.
3. The `## Before merge` check, then `PREMERGE_DONE=<n> gh pr merge <n> -R glw907/workstation
   --merge --match-head-commit <head>`.
4. Pull `~/.dotfiles`, run `stow -R claude`, check that `claude -p "/output-style"` run from `/tmp`
   lists `writing-voice (current)`, and run
   `make -C ~/.dotfiles/claude/.claude/skills/writing-voice/evals/tellgrader install` so
   `~/.local/bin/tellgrader` is the merged build. Then `claude-tooling-sync verify`.
5. Remove the Survey worktree, tell conductor-drafter the workstation PR merged, and end as
   pass-core says.
