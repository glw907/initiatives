# Drafter B2 plan review: data integrity and failure risk

Target: `docs-system/plans/2026-10-18-drafter-b2-blueprint-skill-plan.md` (initiatives `b7c25f1`).
Read against the B2 design, the blueprint architecture spec, drafter `9915232`, cairn-cms
`50dc211d9`, and dotfiles `HEAD`. Lens: crash, concurrency, partial write, upgrade, restore, silent
corruption. Findings are ranked by consequence. Line numbers are the plan's unless a file is named.

## Findings

### 1. A resumed scoped read can stamp the lock as a whole accept (major, correctness)

Location: plan:67-70, plan:71-74, plan:146-147; `cmd/drafter/read.go:82`, `read.go:106`,
`read.go:227-265`.

Defect: `recordAccepted` runs in the cmd layer after `pipeline.Run`, and on a resume the cmd layer
knows only `--resume` (`startCommit` reloads `Head` and nothing else). Resolution 3 records "the
since rev and the computed scope" in the run state, but nothing says `recordAccepted` reads them
back. If the resume path tells the pipeline the scope but leaves `recordAccepted` on its current
"every accepted page writes" rule, a resumed scoped accept writes `drafted.lock` as if every
section had been read. That is the failure resolution 4 exists to prevent. Two more gaps sit in the
same field. The plan records "the since rev" without saying it is resolved: the format test passes
`--since HEAD~1`, and a stored `HEAD~1` re-resolved on resume names a different commit once HEAD
moves. And `drafter read` takes several blueprints, so the scope is per page, while the plan names
one "computed scope".

Fold: state that the run records the resolved since commit SHA once per run and the changed ids per
page (in `PageState.Work` or a per-page map). Every decision that depends on the scope (the prompt,
and the lock rule in `recordAccepted`) reads it from state on a resume. Add an acceptance line to
B2.2: "a resumed scoped run that accepts writes no lock entry when the condition fails". The test
must run through `runRead`, not only the pipeline.

### 2. The standing resume rule says to repeat the arguments, and `--since` with `--resume` is a usage error (major, correctness)

Location: plan:36-37 against plan:68-69.

Defect: standing answer 4 says any other exit 3 "gets one `drafter read --resume <run-id>` with the
same arguments". The format test's arguments are `--since HEAD~1 <blueprint>`, and resolution 3
makes `--since` with `--resume` exit 2. The executor either spends its single resume on a usage
error or improvises. A resume that drops `--since` is correct only once finding 1 is folded.

Fold: change the standing answer to "with the same blueprint arguments, without `--since`; the
run's state carries the scope".

### 3. A whole read in the format test writes `drafted.lock` and dirties the worktree (major, correctness)

Location: plan:74, plan:109-114; `read.go:227-265`; `internal/pipeline/start.go:88-101`.

Defect: resolution 4 says "the format test writes no lock". That holds only for a scoped accept.
Resolution 1 makes a read whole whenever a page-level field (`orderReason`, `constraints`,
`framing`) or the outline entry changes, and tweak 5 ("add a section") may well need an
`orderReason` edit. A whole `ok` then writes `blueprints/drafted.lock` into the format-test
worktree as an uncommitted change. `requireClean` counts untracked and modified files, so the next
tweak's read exits 2, which no standing answer covers. If the next agent runs `git add -A`, the
lock rides into that tweak's commit, so the commit no longer records only the agent's first try.

Fold: in resolution 9, after each read the executor records whether `drafted.lock` changed, then
runs `git checkout -- blueprints/drafted.lock` before the next dispatch. Change resolution 4's last
sentence to "a scoped accept on rotate writes no lock; a whole accept writes as today, and the
executor restores the file".

### 4. Resolution 4's condition can stamp sections that were never read against their current inputs (major, correctness)

Location: plan:71-74, plan:55-56.

Defect: the condition ("blob at `<rev>` equals the lock's accepted blob") proves the blueprint's
text is unchanged since the last accept. It does not prove the inputs that text was read against
are unchanged. Suppose a fact bullet or the outline entry changed after the accepting commit but
before `<rev>`. The scope marks only changes since `<rev>`, so a section citing that fact is
neither in scope nor re-read. The scoped accept still records the blueprint as accepted, and the
lock then claims a read that never happened. `LockEntry.Accepted` stores only a blueprint blob
(`internal/blueprint/blueprint.go:169-178`), so the condition has nothing richer to check. The
branch is also dead weight in B2: rotate has no `accepted` (cairn `blueprints/drafted.lock`), so
the format test never exercises it.

Fold (recommended, it removes code): a scoped accept never writes the lock in B2. It prints one
line saying so. B3, which defaults `--since` to the accepted blob, designs the lock record and its
condition together, for example by recording the accepting commit as well as the blob. The cost
is a later re-read of an already-read change, which costs credit but loses no data. If the plan
keeps the condition instead, extend it so that any fact or outline change between the accepting
commit and `<rev>` blocks the write. That needs the accepting commit, which the lock does not
hold.

### 5. The merge-order reinstall can leave dangling links, and no rollback is written (major, correctness)

Location: plan:175-176, plan:196-197.

Defect: B2.5 runs `make install` from the worktree, so `~/.claude/skills/blueprint`,
`~/.local/bin/drafter-page-hook`, `cairn-docs-outline`, and `~/.claude/workflows/docs-page-chain.js`
all point into `.claude/worktrees/b2-blueprint-skill`, and `~/.local/bin/drafter` is the branch
binary. Merge-order step 1 runs `make -C ~/Projects/drafter install` without first fast-forwarding
the main checkout. `ln -sfn` never checks that the target exists, so an un-pulled main produces
`skills/blueprint` and `drafter-page-hook` links to paths that do not exist there yet, and the run
still exits 0. Once the dotfiles entry is applied, a dangling hook command errors on every
Edit/Write in every session. If the packet rejects the drafter PR, nothing restores the live
state: the branch binary stays installed, and the links dangle once the worktree is removed. B1
re-linked correctly (the links point at the main checkout today), but the plan does not spell out
the pull.

Fold: merge-order step 1 becomes `git -C ~/Projects/drafter pull --ff-only && make -C
~/Projects/drafter install`, followed by `test -e` on each of the four links. Add to `make
install` a `test -e` on each link source before `ln -sfn`, one line per link. Add a rejection row:
`make install` from main, then `rm ~/.claude/skills/blueprint ~/.local/bin/drafter-page-hook`.
Remove the drafter worktree only after the main-checkout install.

### 6. The other workstation gets the settings entry without the hook command (major, correctness) **OWNER FORK**

Location: plan:102-106; `~/.dotfiles/claude/.claude/settings.json` (shared by `thinkpad-x1` and
`pavilion`).

Defect: the tracked `settings.json` reaches both hosts. Every existing `Write|Edit` hook
(`claude-secret-guard`, `claude-memory-write-check`) lives in the dotfiles `bin` package, which is
stowed on both. `drafter-page-hook` exists only where drafter has been `make install`ed. On a host
without it, `claude-tooling-sync apply` produces an entry whose command is not found, so every
Edit/Write there logs a hook error. The error is non-blocking (exit 127, no `onFailure: block`),
but it repeats on every edit in every repo.

Options:
- (a) The settings command degrades to a no-op when the script is absent, for example
  `sh -c 'command -v drafter-page-hook >/dev/null || exit 0; exec drafter-page-hook'`. That host
  gets no reminder.
- (b) Add a post-merge row: pull and `make install` drafter on the other host before running
  `claude-tooling-sync apply` there.
- (c) Move the script into the dotfiles `bin` package, as its precedent is. This contradicts the
  design's home for it.

Recommendation: (a) now, plus (b) only if Geoff edits docs on both hosts.

### 7. The end-to-end check edits a managed page in cairn's main checkout (major, correctness)

Location: plan:200-201.

Defect: "a fresh `claude -p` session in cairn-cms that edits
`docs/extend/rotate-the-github-app-key.md`" leaves page prose changed in the main checkout. If the
edit is permitted, the page then no longer matches its lock's `page` hash, and the main checkout
is dirty for whoever works cairn next. Page prose is off limits under the architecture.

Fold: run the check in a throwaway cairn worktree that is removed afterward. Alternatively, run it
with Edit denied (`--disallowedTools Edit` or plan mode), since PreToolUse fires before the
permission decision. Observe the context with `--output-format stream-json`, and end with `git -C
~/Projects/cairn-cms status --porcelain` empty.

### 8. The format-test subagent works from the drafter worktree, and `HEAD~1` assumes exactly one commit (major, correctness)

Location: plan:107-114.

Defect: an Agent-tool subagent starts in the executor's cwd, the drafter worktree, and loads
drafter's `CLAUDE.md`. The prompt only names the cairn worktree. An agent that resolves the
blueprint by repo name can edit and commit in `~/Projects/cairn-cms` (main) or in the drafter
worktree. `--since HEAD~1` gives the wrong base when the agent makes no commit (the read then
targets the previous tweak or the revert) or makes two (a fix-up after its own `drafter check`).
In either case the recorded result is not the agent's first try. The subagent could also push,
since the prompt carries no "never pushed" rule.

Fold: before each dispatch, record `base=$(git -C <wt> rev-parse HEAD)` and the main-checkout and
drafter-worktree statuses. After the agent returns, require exactly one new commit on `<wt>`
(`git rev-list --count $base..HEAD` = 1; any other count fails that tweak as first try) and assert
both other trees are unchanged. Read with `--since $base`. Check `git -C <wt> rev-parse
@{upstream}` fails (no upstream), so nothing was pushed.

### 9. Format-test evidence is deleted with the worktree, and the branch leaks (minor, correctness)

Location: plan:113-114, plan:179-180.

Defect: the table records each agent commit by SHA. A failing tweak "is reverted" (unspecified: a
`reset --hard` makes the commit unreachable), and "the worktree is removed". `git worktree remove`
leaves the `format-test` branch in cairn's refs. If someone deletes the branch later, the SHAs the
PR cites stop resolving after gc. So the plan leaks a branch and has no durable evidence.

Fold: after each read, save `git show <sha>` for the tweak into the drafter run's record directory
or a file the PR attaches. Revert with `git revert --no-edit` so the history keeps the attempt.
After the table is recorded, run `git worktree remove` and `git branch -D format-test`.

### 10. An empty change set and a failed decode at `<rev>` are undefined (minor, correctness)

Location: plan:49-57, plan:59-61.

Defect: resolution 2 encodes "whole" as an empty `scope`. A `--since` that finds no changed section
(the agent made no blueprint change, or a fact changed that no section cites) also yields an empty
scope. So it silently becomes a paid whole read, and a format-test tweak would then be graded on
the non-converging whole read (#43). The rule for a blueprint, outline, or fact file that exists at
`<rev>` but fails to decode is not stated either. If a decode failure collapses to "no difference",
an unread change never enters the scope.

Fold: make three outcomes explicit: scoped (ids), whole (structural, absent, or undecodable at
`<rev>`, fail-closed), and unchanged. Unchanged prints "nothing changed since `<rev>`" and exits 0
with no API call. Add the unchanged case and an undecodable case to B2.1's table test.

### 11. The hook's path math and exit codes need two rules (minor, correctness)

Location: plan:90-100; precedent `~/.dotfiles/bin/.local/bin/claude-memory-write-check:4`.

Defect:
- On Bluefin, `/home` is a symlink to `var/home`. `git rev-parse --show-toplevel` returns
  `/var/home/...`, so stripping it from a `file_path` given as `/home/glw907/...` fails, and the
  reminder silently misses.
- A `Write` to a new file in a directory that does not exist yet makes `git -C <dir>` fail with
  exit 128.
- The precedent runs `set -euo pipefail`. A copy of it exits with whatever failed: jq returns 5 on
  a malformed payload, and git returns 128. Both are non-blocking but show a hook error. Any path
  that exits 2 would block every Edit/Write on the workstation (PreToolUse exit 2 blocks).

Fold: compute the relative path with `git -C <first existing ancestor> rev-parse --show-prefix`,
which gives no string stripping and no symlink mismatch. Walk up to the first existing ancestor
directory. End the script on every path with an explicit `exit 0`, either with no `set -e` or with
`trap 'exit 0' ERR`. Add two test cases: a malformed payload and a new file in a missing
directory, each exiting 0 with no output. Latency is not a concern: the script runs one jq and one
git rev-parse, in parallel with the two existing Write|Edit hooks.

### 12. Concurrent writers share the Makefile, the format page, and the `./drafter` build (minor, correctness)

Location: plan:20-21, plan:141-166.

Defect: B2.2, B2.3, and B2.4 run concurrently. B2.3 and B2.4 both edit `Makefile` `install`, and
B2.4 also edits `check`. B2.2 and B2.3 both may edit `docs/blueprint-format.md`. `make check`
writes `./drafter` at the repo root (the `build` target, `prompts-parity`, and `install-test` via
`make install`). If any two writers share a tree, one gate can test another's half-written binary.
If they are isolated, the shared hunks conflict at integration.

Fold: give each concurrent writer its own worktree. Assign the `Makefile` `install` hunk to B2.3
only (B2.4 adds just its `check` line and the hook link after B2.3 lands), and put the `--since`
documentation in `--help` so B2.3 owns `docs/blueprint-format.md`.

### 13. The state schema must not bump (minor, correctness)

Location: plan:67-70, plan:140; `internal/run/state.go:15`.

Defect: the plan does not say whether the new state field changes `StateSchema`. A bump to 3
makes every open run under schema 2 unresumable (`LoadState` refuses it), which breaks standing
answer 4's resume for any run open at install. An additive `omitempty` field needs no bump: an old
state with no field resumes as whole, which is its correct meaning.

Fold: one sentence in resolution 3: "the field is additive with `omitempty`; `StateSchema` stays 2".

### 14. Tweak 5 may be graded on a whole read (minor, correctness) **OWNER FORK**

Location: plan:115-120, plan:52-54.

Defect: if adding a section moves `orderReason` or the outline entry, resolution 1 makes the read
whole. That read inherits #43's non-convergence, so tweak 5 could fail on a bar defect the scoped
read was built to remove. The miss would count against the four-of-five ergonomics bar.

Options:
- (a) The executor picks tweak 5's content so the new section needs no page-level edit, and
  records that choice.
- (b) Keep the tweak as a developer would ask it. If the read is whole, classify its findings
  under standing answer 3's bar-defect rule, and grade the tweak on `drafter check` alone.
- (c) Grade it as is.

Recommendation: (b). It keeps the tweak honest and the bar about ergonomics.

### 15. A crash mid-B2.5 loses the paid results table (minor, optional)

Location: plan:178-180.

Defect: the table lives only in the executor's context until the PR body is written. A session
crash or compaction mid-test loses rows that cost credit. The run records survive under the
drafter state directory, but nothing maps them to tweaks.

Fold: append each row (tweak, base, commit, check result, run id, verdict, cost) to a file in the
drafter worktree's git dir as soon as it is recorded.

### 16. A subagent can run an uncapped `drafter read` (minor, optional)

Location: plan:111-112, plan:33-35.

Defect: the subagent does not inherit the executor's `DRAFTER_PAGE_CAP`. The user config sets
`page_cap = 10`, so a subagent that runs `drafter read` on its own (the skill teaches `check` and
`refs`, but nothing forbids `read`) can spend up to $10 outside the $10 standing budget's per-run
caps.

Fold: after each tweak, the executor reads `drafter spend --since 2026-10-18 --json` and applies
standing answer 4's under-$1 stop before the next dispatch. Each row records any read the agent
ran.

### 17. The launch check's `pgrep` always matches (minor, optional)

Location: plan:39-41.

Defect: `pgrep -af 'drafter|cairn-cms|dotfiles'` excludes only itself. The Bash tool's `bash -c`
wrapper carries the pattern, so the check always finds a process (verified: it matched its own
wrapper). cairn-cms also has a locked `repo-organization` worktree, and drafter has 15 stale
`agent-*` worktrees, all clean. A literal reading of "no session works cairn-cms" stops the pass
at launch.

Fold: check by worktree, per the global rule: `pgrep -f '<worktree path>'` for the two worktrees
this pass creates, plus `git status` on the three main checkouts.

### 18. Over-ceremony in B2.3's acceptance (minor, optional)

Location: plan:156-159.

Defect: B2.3 asks for both a `skill-creator` review and a rule-by-rule manual check of every
rule-shaped sentence against the format page. The second step is a token-heavy pass by the
executor with no deterministic output. The format test (B2.5) is itself the skill's real
acceptance. Cost: roughly 10 to 15 minutes and one long-context read.

Fold: keep the `skill-creator` review and drop the manual sweep. Alternatively, reduce the sweep
to "every link to `docs/blueprint-format.md` resolves to a heading", which a grep can check.

## Not findings

- `WriteLock` and `State.Save` go through `atomicfile`, and `recordAccepted` holds the worktree
  flock, so a crash or a concurrent run cannot leave a torn `drafted.lock` or state file. Losing
  the record after accept and before it is written is documented and recoverable (`read.go:224-226`).
- A resume reads the prompts module from the run directory, so a run started before the B2 install
  keeps its old prompt.
- cairn ignores `.claude/worktrees/` (`.git/info/exclude`) and has no git hooks, so the format-test
  worktree does not show in the main checkout's status.
