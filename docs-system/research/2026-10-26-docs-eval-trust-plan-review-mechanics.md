# Docs eval trust plan: mechanics review and fold

The `plan-reviewer` mechanics lens read the uncommitted plan against the design and cairn-cms
`4c6b96bc0` on 2026-10-26. It started no eval run and no `claude -p` session. Its probes were
read-only: the code, `jq` over runs `20261027-025209` and `20261026-223242`, the classifier called
in memory, and a grep of the installed `claude` 2.1.310 binary. The planning session folded the
findings into the plan. Each entry gives the finding, then its disposition.

1. **Major. `error_max_turns` doesn't grade.** The 2.1.310 binary builds the max-turns result with
   `is_error: true`, and `sessionErrored` (`run.mjs:260-263`) returns true on `isError`. A capped
   session would leave the rates, and the auto-rerun (`run.mjs:786`) fires only on "no result".
   *Folded* (T2): `sessionErrored` grades `error_max_turns` before the `isError` test, with a unit
   case.
2. **Major, marked owner fork. T6 step 2 compares identical arms.** The arms differ only by overlay,
   and this branch edits no overlay path, so `docs-eval-trust` and `main` share an overlay hash and
   a runner. The standing answer would send the executor after a runner defect that can't exist.
   *Folded as option (a), not a fork*: the design's check stays, and the standing answer now reads
   a held drop as noise, reported and never traced. Dropping the step would change the design's
   end-to-end check, so the plan keeps it; it costs about 20 minutes of wall time.
3. **Major. The T6 bar can pass on a near-miss row.** Only `new-page-trap` and a graduated
   `deficiency` need the skill. In the control arm, an `Unknown skill` call still fails
   `skillNotCalled`. *Folded*: the bar counts only those two cases. The design's intent is "a case
   that needs the skill".
4. **Major. T5 graduates without the control drop.** The design says `deficiency` graduates "once a
   sound control shows it drops". *Folded*: 3/3 on `main` and the control below `main` on it.
5. **Major. The lost session's record is overwritten.** `run.mjs:788` keeps only the rerun's
   record, and T2 removed `retried`. *Folded*: a `lost` field holds the first attempt's
   end-of-session record, and every early return carries the record.
6. **Major, marked owner fork. The cap of 21 rests on edit-case calls.** Every near-miss call came at
   turn 1 or 2. *Refused as a pre-launch fork*: the planning brief states the rule outright ("If any
   skill call in any case came after turn 4, set the near-miss cap above it"), so the plan applies
   it. The packet carries cap 4 as an ask, with the evidence. A yes is filed for the next cycle
   under the change rule, since cap 4 needs finding 1's fix to grade.
7. **Major. The trust probe used no tool, and nothing answers a refusal mid-run.** *Folded*: T1's
   acceptance runs `deficiency` (it installs, edits docs, runs the gate, and needs the skill), and a
   standing answer treats a mid-run refusal as a harness fault.
8. **Minor. T3 must change `gate-tier.mjs`.** `componentPlan` still runs the whole component project
   for a `.claude/`-only diff, and `gate-tier.test.ts:57-86` needs a row per bucket pattern. The
   fast lane never runs `test:node-projects`. *Folded*.
9. **Minor. The async list misses `commitAll`, `git status`, and `git ls-tree` in `makeFixture`.**
   *Folded*: every git, tar, and copy call inside the pool runs async.
10. **Minor. The signal handler exits before an async removal ends.** *Folded*: the signal path
    keeps a synchronous remover.
11. **Minor. First-run directories.** `pruneFixtures` throws on a missing root, and a non-recursive
    leaf `mkdir` throws `ENOENT` on a missing parent. *Folded*.
12. **Minor. `monitorEventLoopDelay` needs `.enable()` and reports nanoseconds, and a canned stream
    can't test four of the five record fields.** *Folded*: a pure `endRecord` builder, tested with
    all five inputs.
13. **Minor. The errored-session answer misstates the runner**, which reruns only no-result
    sessions. *Folded*.
14. **Minor. Commands written as shorthand.** *Folded*: every command is written in full.
15. **Minor. The launch waits on PRs that don't exist yet.** *Folded*: a launch-dependency line
    beside Pre-flight.
16. **Minor, optional. The eval estimates aren't derived.** *Folded* as one line, since it backs the
    T5 and T6 minutes.
17. **Minor, optional. T4 as a pair.** Agent-tool worktree isolation applies to cairn-cms, not
    `~/.dotfiles`. *Folded*: T4 runs inline during T2's eval wait, and thinkpad-x1 gets it on its
    next pull.
18. **Minor, optional. Control-arm hash, init-skills fault, and the `--keep` check.** *Folded*: the
    control arm's hash is tagged, and an init `skills` list holding `cairn-docs` in the control arm
    is a fault. The acceptance reads the transcript's init `cwd` instead of using `--keep`.
19. **Minor, optional. Shared `node_modules` and gate lock with the cycle.** *Refused*: the
    conductor's launch gate keeps the cycle's runs off while the executor runs.

Over-ceremony in T6 step 1 (30 control near-miss sessions that can't test the skill): *refused*,
since the design names that run. It costs about 20 minutes of wall time.
