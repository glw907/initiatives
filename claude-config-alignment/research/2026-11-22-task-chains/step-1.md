# Step 1 record: the stub chain

The stub chain of `specs/2026-11-22-task-chains-design.md` ran on 2026-11-23 in `glw907/cc-desk-scratch`.
The tick launched the child with no message from Geoff, and auto mode didn't refuse it. Done items 1, 2,
4, 5, and 6 are met. Item 3 is unmet: deleting the parent's branch closed the child's pull request. Task 1
therefore retargets each child before the parent's branch is deleted, and it doesn't carry the auto mode
line.

The tick ran in Geoff's open session (Opus 5.5, a `claude --bg` job he talks to), not a fresh Sonnet
session. The spec picked Sonnet to save cost, and the model doesn't change what the classifier sees.
The loop was cron job `049da521`, armed by `/loop 15m` at 10:25.

## Results by done item

1. Met. At the 10:30 tick, a cron-fired loop turn with no message from Geoff, the tick read
   `chain-proof-a` ready and ran the launch line for `chain-proof-b`. It printed
   `backgrounded · 8437eacf · chain-proof-b` at 10:30:54, with no refusal.
   `claude agents --json --all` then listed `chain-proof-b`.
2. Met. `git merge-base --is-ancestor 22fdd8e8ceffe7d7bc719c6d1f3536c3d0a1145f origin/worktree-chain-proof-b`
   exited 0. The body's first line read `Built on #23 at 22fdd8e8ceffe7d7bc719c6d1f3536c3d0a1145f.`
3. Unmet. Geoff approved PR 23 ("PR 23 is approved."). It merged as `428224d`, and
   `git push origin --delete worktree-chain-proof-a` ran at 11:42:44. A Monitor until-loop read PR 24's
   `baseRefName` 13 times, every 5 seconds from 11:42:53 to 11:43:59. Every read printed
   `worktree-chain-proof-a`, and no `gh pr edit` ran before them. PR 24's timeline shows why:
   `base_ref_deleted` at 20:42:45Z, then `closed` at 20:42:46Z. The repo has `delete_branch_on_merge`
   off. GitHub retargets a child only when GitHub deletes the merged branch itself
   (<https://github.blog/changelog/2020-05-19-pull-request-retargeting>). A plain push delete closes the
   child.
4. Met after recovery. The recovery merged nothing:
   - `git push origin 22fdd8e8...:refs/heads/worktree-chain-proof-a` restored the branch.
   - `gh pr reopen 24` reopened the pull request.
   - `gh pr edit 24 --base main` retargeted it.
   - `git push origin --delete worktree-chain-proof-a` ran again, and PR 24 stayed `OPEN` on `main`.

   Then `git rev-list --count --no-merges origin/worktree-chain-proof-b..origin/main` printed `0`. The
   base change started a new `gate` run, 45262530298, which `gh pr checks 24` listed as pending and then
   as pass in 18 seconds. The head stayed `8ec9cad4184e4e84b2485442a2b41ace228d4377`.
5. Met. Geoff approved PR 24 ("24 approved."). It merged as `afafdc4`, and
   `git show origin/main:chain/b.txt` printed `a` then `b`.
6. Met. At the 10:45 tick both sessions read `done` and both pull requests were ready. The tick deleted
   cron job `049da521` and wrote the sitting note: PR 23 then PR 24, both ready, no task stopped, usage
   71 percent (all models) at both launches.

## Findings for task 1

- Retarget before the delete. After a parent merges, run `gh pr edit <child> --repo <r> --base <default>`
  for each open child, and only then `git push origin --delete <parent-branch>`. The recovery ran in that
  order and the child stayed open.
- The ready check parses the `task-score` JSON. `chain-proof-a` wrote
  `"verdict": "accept", "openFindings": 0, "unmet": 0`, with spaces, so a literal match of
  `"verdict":"accept","openFindings":0,"unmet":0` misses it. `chain-proof-b` wrote it with no spaces.
- `claude agents --json --all` carries `done` in the `state` field. `status` reads `busy` or `idle`.
- `gh pr checks` exits 8 while a check is pending, so a tick that reads exit 8 treats CI as pending.
- The auto mode line isn't needed. The launch from a loop turn wasn't refused.

## Sessions and branches

| Task | Session | Pull request | Merge | Branch |
| --- | --- | --- | --- | --- |
| `chain-proof-a` | 057f2f92, `done` | #23, base `main` | `428224d` | deleted |
| `chain-proof-b` | 8437eacf, `done` | #24, base `main` after recovery | `afafdc4` | deleted |

Both worktrees are removed, and the main checkout is at `afafdc4`.
