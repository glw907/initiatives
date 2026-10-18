# drafter B2 plan: review fold

Target: `plans/2026-10-18-drafter-b2-blueprint-skill-plan.md` at `b7c25f1`, revised in place.
Reviews: `2026-10-18-drafter-b2-review-mechanics.md` (M), `-contract.md` (C), `-integrity.md` (I).
Each finding was checked against source at drafter `9915232`, cairn-cms `50dc211d9`, and dotfiles
HEAD before its disposition. The planning session's six rulings (2026-10-18) are applied as given.

Task renumbering: old B2.1 (the comparison) folds into the scoped-read task (M23), so the new tasks
are B2.1 scoped read, B2.2 skill and install, B2.3 hook, B2.4 format test. Locations below use the
new names.

## Probes run for new mechanisms

- Hook commands run through a shell: a `UserPromptSubmit` hook with `command -v zz-absent-hook
  >/dev/null && zz-absent-hook || true; echo "ran $0" >> probe.txt` in a `claude -p --settings`
  session wrote `ran /bin/sh`, and the session exited 0 (ruling 3).
- `--include-hook-events` with `--output-format stream-json --verbose` emits `hook_started` and
  `hook_response` events carrying the hook's output (same probe), the end-to-end check's evidence.
- Deny beats allow headless: `claude -p --permission-mode acceptEdits --allowedTools "Bash(echo *)"
  --disallowedTools "Bash(echo secret *)"` reported the command in `permission_denials`.
- `claude --help` lists `--model`, `--effort` (low to max), `--allowedTools`, `--disallowedTools`,
  `--permission-mode acceptEdits`, `--output-format stream-json`, `--include-hook-events`.
- `/home` is a symlink to `var/home`; `git rev-parse --show-toplevel` from `/home/...` prints
  `/var/home/...` (M10, I11).
- `DRAFTER_PROMPTS` and `DRAFTER_PAGE_CAP` are derived env names (`internal/config/env.go:13`);
  `drafter read --sync` exists; `read --help` says a resume takes "the same blueprints again".

## Mechanics (M)

1. Folded. B2.4 "Before it": copy `cairn-cms.local.toml`, `check-ignore`, `drafter config --json`
   shows `prompts` (verified `validate.go:40`, cairn `drafter.toml:1-3`, B1 plan B1.5 step 1).
2. Folded (ruling 6). Resolution 9: worktree binary by path with `DRAFTER_PROMPTS`; the skill alone
   is exposed by a temporary link removed at B2.4's end.
3. Folded. B2.2 owns every `install` change, including the hook link; B2.3's `Makefile` `check` line
   lands after the pair merges; `--since` is documented in `--help` only.
4. Folded. Resolution 6: the catalog stays in `docs/blueprint-format.md` (verified `:333`,
   `catalog_test.go:13`, architecture spec:256-257); the skill links it. B2.2 no longer edits the
   format page.
5. Folded. B2.1 Files and acceptance: a golden of the `9915232` render, the real-module test with a
   scope, `module.js` echoing `c.scope` (verified `module.js:18`). Resolution 2 reworded.
6. Folded. Resolution 1's three states and the full field list (verified `blueprint.go:20-31`),
   reorder and level change whole, empty set no call, unresolvable rev exit 2. An undecodable
   blueprint at `<rev>` reads whole (fail closed, per I10) rather than exit 2: a commit that repairs a
   broken blueprint must still be readable.
7. Folded (ruling 1). Resolution 1 states the departure.
8. Folded (ruling 6). Headless `claude -p` per tweak; the transcript must show the `Skill` call; the
   `cmp` is gone.
9. Folded. Resolution 9: `<base>` SHA, `--since <base>`, `git reset --hard <base>` before every tweak.
10. Folded. Resolution 7 uses `--show-prefix`; B2.3 tests the `/home` path.
11. Folded with C14 and I7. Merge order row 3.
12. Folded. B2.2 acceptance names cairn's `.vale.ini` and "in 2 files".
13. Folded. Resolution 1 and B2.1 Files (`internal/plan/facts.go`, export only if needed); verified
    `LoadFacts` takes a directory and `extractBullets` is unexported.
14. Folded. B2.1 Files; scope in the `work` struct; `StateSchema` stays 2.
15. Folded. Resolution 3: reject in `RunE` via `usageError` (verified `main.go` maps only
    `exitError`; read's `SetFlagErrorFunc` would not see a flag-group error).
16. Folded. B2.4 reads non-blocking findings from `responses/*.json` (verified `blueprint.go:158`
    records findings only on `fix`); no code change.
17. Folded with C12. Resolution 2.
18. Superseded by ruling 5. Resolution 4.
19. Folded. Resolution 5 `install -d`.
20. Folded (free). Resolution 8 appends to the existing `Write|Edit` group (verified
    `settings.json:82`).
21. Folded. Resolution 7 (no `set -e`, `exit 0` everywhere, missing `jq`); B2.3 test cases.
22. Folded (free). B2.4 runs `cd`'d into the cairn worktree; reads use `--sync`, which removes the
    batch waits for about $0.2 more per read.
23. Folded (free). Old B2.1 merged into the scoped-read task; each task has a risk-class line.
24. Folded with I17. Launch check by worktree path.
25. Folded. Resolution 9 tweak 2.
26. Folded (ruling 4). Standing answer 2.
27. Folded. `docs-page-chain.js:997-1406`.

## Contract (C)

1. Folded. Resolution 9 seeded control, outside the bar; a lenient `ok` is a bar defect. Under
   ruling 2 it informs the diagnosis and never changes the raw count.
2. Folded. `--disallowedTools "Bash(drafter read *)"` (probed) plus the transcript check, simpler
   than a prompt line plus spend-and-runs diffing.
3. Folded. Resolution 9: no `Skill` call, or a read under `~/Projects/initiatives` or of the chain,
   is a breach and a miss; B2.4 row records reads outside the worktree and the skill.
4. Folded. Resolution 9 prompt rules, verbatim prompts in rows, tweak 2 reworded, `refs` column.
5. Settled by ruling 2. Resolution 9 grade bullet: raw count decides, adjusted count for diagnosis.
6. Folded. Resolution 9 pass rule; check failure skips the read; scope used and files touched in the
   row; drafter prints the scope (B2.1 acceptance).
7. Folded with M9 and I8.
8. Folded (ruling 1) with M7; reorder and level change whole in the table test.
9. Folded with M6 and I10.
10. Folded with M5.
11. Folded. Resolution 2 narrows the cross-section clause to what the read can see; B2.1's
    real-module test asserts the paragraph.
12. Folded with M17.
13. Folded. `readlink -f` check in B2.4; `cmp` dropped.
14. Folded with M11 and I7. Merge order row 3 checks both halves, names `conductor-drafter`, and runs
    in a throwaway worktree.
15. Folded at no extra run: the end-to-end rotate session names no skill and records whether the
    skill fired; a miss goes to the backlog, not a gate (the design does not promise triggering).
16. Folded with I18. B2.2 drops the `skill-creator` review and the manual sweep; keeps the heading
    grep; the rule goes to the Close `diff-reviewer`.
17. Folded. B2.3 acceptance: `jq -e` on the output, a no-`jq` `PATH` case, and I11's cases.
18. Superseded by ruling 5. B2.1 acceptance tests the two branches that remain: scoped writes no
    lock, whole writes.

## Integrity (I)

1. Folded. Resolution 3: resolved SHA once, per-page state and ids in `work`, the lock rule reads
   state on resume; B2.1 acceptance runs through `runRead`.
2. Folded. Standing answer 4: resume without `--since`.
3. Folded (ruling 5). Resolution 9's `git reset --hard <base>` restores a tracked `drafted.lock` a
   whole read wrote, before the next tweak and before any clean-tree check.
4. Folded (ruling 5). Resolution 4.
5. Folded in part. Ruling 6 removes the branch install, so no rollback row is needed. Merge order
   row 1 pulls `--ff-only` before install, `test -e` on the links, and removes the worktree after.
   Refused: a `test -e` guard per link in `make install`; the pull removes the cause, so the guard
   adds machinery for a case that no longer arises.
6. Settled by ruling 3. Resolution 8 (probed through `/bin/sh`).
7. Folded with M11 and C14.
8. Folded with M9 and C7, plus the main-checkout and no-upstream checks.
9. Folded. Patches saved per row; `git branch -D format-test` at the end. `reset --hard` is kept
   over `git revert` because the patch file holds the evidence and every tweak must start from
   `<base>`.
10. Folded with M6 and C9.
11. Folded with M10 and M21: `--show-prefix`, first existing ancestor, explicit `exit 0`, malformed
    payload and missing-directory cases.
12. Folded with M3. pass-core "Pairs" already isolates pair worktrees.
13. Folded. Resolution 3.
14. Settled by rulings 1 and 2: graded raw; a whole read shows in the row's scope column and its
    findings are classified for the diagnostic count.
15. Folded (cheap). B2.4 appends each row to a file in the drafter worktree's git dir.
16. Folded via C2's deny rule; the meter is checked before every dispatch.
17. Folded with M24.
18. Folded with C16.

## Counts

- 63 findings (M 27, C 18, I 18).
- Folded: 62, of which 11 apply the session's rulings (M2, M7, M8, M18, M26, C5, C18, I3, I4, I6,
  I14), and many are convergent (folded once at the root, cross-referenced above).
- Folded in part: 1 (I5); its `make install` link guard is refused.
- Owner forks remaining: none.

Path: 420 to 495 minutes (B2.1 240 in the pair, B2.3's `check` line 5, B2.4 155, Close 45,
post-merge 50), inside the 780 ceiling.
