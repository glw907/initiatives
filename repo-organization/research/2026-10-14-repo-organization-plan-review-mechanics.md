# Plan review: mechanics and feasibility

Target: `repo-organization/plans/2026-10-14-repo-organization-plan.md` and its 17 launch prompts, at `f2362ab`. Reviewer: the `plan-reviewer` agent, 2026-10-14. Its definition returns the report as its reply; the planning session (dotfiles-32) saved this file from that reply unchanged in substance.

Counts: 2 blockers, 15 majors (one an OWNER FORK), 30 minors.

Probes ran in `/tmp/claude-1000/-var-home-glw907--dotfiles/21f4a698-dfbc-4195-8331-e518cb1d0a87/scratchpad/plan-mech/`: a real isolated `claude -p --worktree` session (haiku), filter-repo 2.47.0 run from source, stow 2.4.1, and the CLI help text. All Cloudflare calls were read-only GETs. The private out-of-scope repo's name appeared in `claude agents --json` output during probing; it appears nowhere in this file.

## Blockers

**B1. The executor launch line swallows the prompt** (`correctness`, `conductor-prompt.txt:12`). `--add-dir <directories...>` takes any number of values. `claude -p --add-dir A --add-dir B "Reply OK"` failed with "Input must be provided either through stdin or as a prompt argument"; the same line with `--` before the prompt answered `OK`. So every executor launch starts with no prompt. Fold: put `--` before `"$(cat …)"`, or move both `--add-dir` flags ahead of `--name`.

**B2. The G-p5 check fails on the pass's own drafter executor** (`correctness`, `plan.md:57`, `drafter-prompt.txt:6`). `claude agents --json` lists every active session, interactive ones included (a live listing showed `conductor-drafter`, `drafter-p5-cairn`, and directory-named sessions such as `dotfiles-32`). G-p5 fails on any name starting with `drafter-`, so when D1 rechecks it, `drafter-repo-organization` is listed and D1 always stops. W6, W7, I9's drafter rows, and C5 also fail while that session, or any interactive `drafter-NN` session, is alive. Fold: match `conductor-drafter` exactly plus the pass-5 names (prefix `drafter-p5`), or exclude `*-repo-organization`.

## Majors

**M1. R2's wait passes at once** (`correctness`, `retire-prompt.txt:16`, `plan.md:270`). R2 waits for "a commit on branch worktree-repo-organization that touches secrets/values.age" via `gh api`; a path-filtered commit list walks the branch's whole history, and `commits?path=secrets/values.age&sha=main` already returns `b0084ec` (#69). The GitHub deletes would run out of the design's step-5 order. Fold: `gh api repos/glw907/workstation/compare/main...worktree-repo-organization --jq '.files[].filename'` must list `secrets/values.age`, or match W8's commit subject.

**M2. W7's draft check can't pass when W7 runs** (`correctness`, `plan.md:338-344`, `workstation-prompt.txt:29`). It needs every destination on its repo's `origin/main` (dubplate and poplar for docs rows, drafter and approval-queue for code rows), but W7 waits only on PR 1, and the dubplate and poplar executors don't launch until PR 1 merges. Fold: W7 also waits on those four merges; re-derive the path (minor 1).

**M3. W8's override and test can overwrite the live `~/.local/secrets`** (`correctness`, `plan.md:328, 334, 510`). `scripts/secrets/secret-set.sh --delete` always calls `write_local`, which copies to the hard-coded `LOCAL_SECRETS=$HOME/.local/secrets`; `RECIP` and `CACHE` (the real tmpfs age key) are hard-coded too. A test against a temporary store either can't decrypt or rewrites the real `~/.local/secrets` from fixture data, and the real W8 run regenerates pavilion's `~/.local/secrets` from the branch store before merge. Fold: override `VALUES`, `LOCAL_SECRETS`, `RECIP`, and `CACHE` (or run under a temp `HOME` with all four); Review Focus 2 asserts the real `~/.local/secrets` hash is unchanged; state whether the real run regenerates `~/.local/secrets`.

**M4. One W8 acceptance step is refused inside its own session** (`correctness`, `plan.md:333`). `git -C <own main checkout> status` was refused in the probe, and `~/.dotfiles` is the workstation executor's own main checkout. Fold: record `sha256sum ~/.dotfiles/secrets/values.age` at task start and compare at the end (reading by path is allowed), or move the check to the conductor.

**M5. The plan's isolation model is wrong, which kills the clock stop and adds relays** (`correctness`, `plan.md:25, 72, 200, 518`, every prompt's clock lines). The worktree docs (code.claude.com/docs/en/worktrees, "How Claude Code enforces isolation") guard only the launch repo's main checkout, through file edits, a command's working directory, git redirects, and command shape: "None of them tracks which files a shell command writes, so a command that writes into the main checkout without running git there, such as `cp` or a shell redirect, isn't refused." Probe results on Claude Code 2.1.299:

| Action | Result |
|---|---|
| `git -C <another repo>` | allowed |
| `git clone` into the scratchpad | allowed |
| `Write` outside both repos | allowed |
| Bash `printf > <main>/.git/worktrees/<name>/pass-task-clock` | allowed |
| `Write` tool to that same file | refused |
| `git -C <own main>` | refused |
| `Write` into own main | refused |

The clock file is writable with a Bash redirect, and `claude-clock-stop` resolves that git dir from the hook's `cwd`. I8's `values.age` check is feasible as written, and most of C1's relay is unnecessary. Fold: each prompt writes the clock file with `printf 'task=…\nstart=…\nestimate=…\n' > <absolute git dir>/pass-task-clock`, taking the path from `git rev-parse --absolute-git-dir`; drop the "watch 2x by hand" fallback and its "Later" item; correct the split rationale to "own main checkout only".

**M6. The conductor runs tools out of a worktree an executor is editing** (`correctness`, `plan.md:95, 110`, `conductor-prompt.txt:24`). C1, C4a, and C4b run tools by path from the initiatives executor's worktree while it edits it, against the global rule "Never read a file's current state while a background agent edits it." Fold: run them from a detached `git worktree add <tmp> <pushed sha>` or a scratch clone of the pushed branch, and record the sha.

**M7. C5 can delete ecxc-ski-agent-memory before S-ecxc-ski reads it** (`correctness`, `plan.md:114-121` against `401`, `ecxc-ski-prompt.txt:8`). C5 runs after R2, well before PR 1 merges, and the sweeps launch only after that merge. Fold: C5 removes that directory only after the ecxc-ski PR is pushed, or S-ecxc-ski reads from the tar archive.

**M8. The memory-file glob reads out-of-scope projects' memory** (`correctness`, `plan.md:188`, design `:159`). `~/.claude/projects/*/memory/*.md` reads every project's memory; by name count only, 6 of 10 memory dirs map to no scope repo. T1 also commits check results, and C6 and T1 apply runs rewrite those files. Fold: build the memory dirs from `scope.tsv` (each repo's encoded path plus its `.claude/worktrees` variants) and record results as counts. This narrows a design glob to obey the hard rule; note it as a deviation.

**M9. thinkpad-cleanup "finds" remote-less directories, which implies scanning ~/Projects** (`correctness`, `plan.md:225`, `thinkpad-prompt.txt:7`). Fold: limit it to `scope.tsv` `retire` rows and report which of those lack a remote.

**M10. W4's acceptance can never pass** (`correctness`, `plan.md:283`). In the 2.47.0 source, `print_my_version` prints the first 12 characters of `git hash-object` (`a40bce548d2c`), not a version. Fold: `brew list --versions git-filter-repo` prints `git-filter-repo 2.47.0`.

**M11. Queue items vanish if the conductor restarts, and the id lookup is never stated** (`correctness`, `plan.md:103`, `conductor-prompt.txt:24-31`). `approval-queue` never prints its item id (`date +%Y%m%dT%H%M%S-$$`), and its EXIT trap deletes `item.json` when it leaves without a decision. Background Bash tasks die with a conductor restart, so pending items leave Geoff's queue silently. Fold: look the id up as the newest `items/*/item.json` whose `.title` matches; after any restart, re-hand every `items.tsv` row with no `decision.json` and update the row.

**M12. OWNER FORK: G-p5 gates PR 1, so the whole pass waits on drafter pass 5** (`correctness`, `plan.md:247, 454`). I9's drafter rows wait on G-p5 and PR 1 can't close without I9, so every sweep, W7, and the workstation PR wait on pass 5, whose drafter PR isn't open yet. Option (a): keep the wait. Option (b): mark drafter rows `deferred:p5`, the design's own mechanism, and move them in a short follow-up PR, adding one PR read. Recommendation: (b).

**M13. The conductor's STATUS line dirties ~/.dotfiles** (`correctness`, `conductor-prompt.txt:41`). An uncommitted line in `~/.dotfiles/docs/STATUS.md` fails C6's acceptance (`status --porcelain` empty) and design check 4, and can block `pull --ff-only`. Fold: write stops to `~/.local/state/repo-organization/` plus `notify-send`, and land STATUS only in the C8 hand-over.

**M14. The retire session can't find teardown.tsv "on origin"** (`correctness`, `retire-prompt.txt:5`). The file lives only on `worktree-repo-organization` until PR 1 merges, and the retire worktree branches from initiatives `main`. Fold: `gh api repos/glw907/initiatives/contents/repo-organization/research/teardown.tsv?ref=worktree-repo-organization` (or `main` once merged).

**M15. End-to-end check 3 tests the wrong thing** (`correctness`, design `:218`, `plan.md:132`, `thinkpad-prompt.txt:11`). `approval-queue` starts the server with `setsid -f node "$app/build"` and no `cd`, so the server's working directory is the caller's. Fold: check `/proc/<pid>/cmdline` for the path under `~/Projects/approval-queue/approval-queue/build`. Inherited from the design.

## Minors

1. Path understated (`correctness`, `plan.md:423-458`): C6 is 45 in its task but 30 in the path; with M2's waits and ten sweeps three at a time (about 185 minutes after PR 1), the true path is near 960 to 980 minutes, about 1.15x the design and under 1,680. "Sweep PRs finish before W close" is false. Re-derive the path.
2. The pull rule blocks on the conductor itself (`correctness`, `conductor-prompt.txt:33`): exempt its own row from "no live session".
3. `stow -R bin claude` has no stow directory (`correctness`, `plan.md:126, 478`); there is no `.stowrc`. Use `stow -d ~/.dotfiles -t ~ -R bin claude`.
4. The conductor prompt names no push targets (`correctness`): C0's `--push` and C8's hand-over PRs need `glw907/initiatives` and `glw907/workstation`.
5. Executor prompts say "never merge" outright (`optional`); pass-core "Launch prompt" forbids that wording.
6. The workstation prompt points at a `scope.tsv` that doesn't exist yet (`correctness`, `workstation-prompt.txt:31`); inline the list as `conductor-prompt.txt:7` does.
7. A1's setup step can't run when listed (`correctness`, `approval-queue-prompt.txt:10`): run `npm ci` after the extract merges.
8. No reject path for the dry-run or migration-calls items (`correctness`, `retire-prompt.txt:5`): on reject, the initiatives session revises from the note and the conductor re-hands it.
9. `decision.json` and `items.tsv` trusted without checks (`correctness`): executors confirm `item.json`'s title, take the newest id when titles repeat, and the prompts state that no session writes under `items/`.
10. The check-3 withdraw step has no mechanism (`correctness`, `thinkpad-prompt.txt:11`): send TERM to the waiting command; its trap removes `item.json`.
11. T1 pulls repos it shouldn't (`correctness`, `thinkpad-prompt.txt:9`): limit to `edit` rows.
12. T1 doesn't exclude `.claude/worktrees/` before `git worktree add` (`optional`, `thinkpad-prompt.txt:1`).
13. The draft check uses one pinned commit for everything (`correctness`, `plan.md:342`): diff code rows against each extract's pin (C4a, C4b).
14. Cloudflare scope gaps (`correctness`, `plan.md:265`): KV and Email Routing deletes aren't in the token's verified scopes (estate inventory). R1 runs a pre-flight per resource kind, and the post-query treats 403 or auth errors as failure.
15. Paired tasks may both edit `scripts/test.sh` (`optional`, `plan.md:149-196`): state that it finds tests by glob, and that I3 owns the outside-scope fixture helper.
16. The mode-000 test proves "never read" but not "never named" (`correctness`, `plan.md:167`): assert the fixture's name never appears in output.
17. The approval-queue repo isn't created empty, against the design (`optional`, `plan.md:104` against design `:96, 165`); record the README commit's reason in the PR body.
18. W8 is `auth-data`, against the design's `runner` (`optional`, design `:55`); the plan is right by `dotfiles-pass:33`; flag it in the PR brief.
19. I5 and I6 are `ordinary` but drive secrets and worktree removals (`optional`); no consequence, since the pass is `auth-data`.
20. S-dubplate pre-states Geoff's ruling (`optional`, `plan.md:397`): say "per the map-calls decision".
21. `gh repo delete` needs `--yes` when not interactive (`correctness`, `plan.md:270`).
22. The thinkpad's `~/.local/secrets` is never regenerated (`optional`): T1 runs `secret-set.sh --sync` after the pull.
23. Over-ceremony, Before-merge step 3 (`optional`): a waiting queue command needs no app files and an unlinked script keeps its inode; the `pgrep` gate can go.
24. Over-ceremony, the three-sweeps cap has no stated reason (`optional`): the heavy-lane lock already serializes browser gates; lifting it saves about 60 to 100 path minutes.
25. Over-ceremony, most of C1's relay (`optional`): per M5, the initiatives executor may run the inventory's local legs itself.
26. The conductor prompt points at "Merge order" instead of carrying it (`optional`).
27. The conductor's own `claude` launch line is in neither the plan nor a STATUS (`optional`).
28. `gh repo list` defaults to 30 repos (`optional`); name `--limit`.
29. The initiatives prompt bans git in scratch clones (`optional`, `initiatives-prompt.txt:6`); stricter than the guard, harmless.
30. A PR rejected after its executor has ended has no owner (`correctness`): the conductor relaunches that executor with the note's path.

## Verified with no finding

C0's `gh repo create` flags; PR #69 merged; `git clone --revision` with filter-repo on a detached HEAD, a rename, the commit map, fetching into a worktree, and `log --follow`; stow 2.4.1's restow removing a dangling per-file link; the Worker settings endpoint returning bindings; `CLAUDE.md` at 199 lines; the task sum (2,460) and stated path (875) as arithmetic; every executor prompt naming its `glw907/<repo>` push target; disjoint pair file lists; no committed file naming a repo outside the scope set.
