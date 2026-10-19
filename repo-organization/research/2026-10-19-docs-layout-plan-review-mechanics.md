# Docs layout plan review: mechanics and feasibility

Reviewer: `plan-reviewer`, at commit `5982a17` (branch `docs-layout`). Saved by the planning
session from the agent's reply, every finding kept, in the agent's numbering. The reviewer noted
that the worktree was being edited during its read (T1's script was being written), so its TSV
figures come from the committed copy.

1. **Blocker, correctness, OWNER FORK.** Four PRs touch `runner` paths but were planned to
   self-merge: dubplate (`.claude/skills/dubplate-pass/SKILL.md`, runner per dubplate-pass:93),
   poplar (`.claude/**` and `Makefile`, runner per poplar-pass:39), phonebook and cairn-themes
   (`.claude/agents/`). Options: (a) add them to the packet; (b) Geoff rules a path-only citation
   rewrite in a `runner` path stays `ordinary`, matching dotfiles-pass:39. Recommends (b).
2. **Major, correctness.** A draft PR can't be merged; `gh pr merge` fails on every self-merge.
   Fold: `gh pr ready <n>` first.
3. **Major, correctness.** The "B3c merged" test passes today, since neither branch has a PR, and
   a stopped `drafter-b3c-pilot` isn't `busy`. `conductor-drafter` may launch the next pass. Fold:
   require a merged PR row per branch, no live session in cairn-cms or drafter, and a hold note.
4. **Major, correctness.** Merging the default branch into a move branch stops on
   `CONFLICT (file location)` (`merge.directoryRenames` defaults to conflict; probed on git 2.56).
   Fold: rebuild instead: reset to `origin/<default>`, rerun the script, cherry-pick the hand
   commit, `git push --force-with-lease`.
5. **Major, correctness.** tellgrader's hook runs an installed binary, so `posthook.go` changes
   nothing until `make ... install`; vale-hook changes only on a pull; T2 to T4 merge long before
   the packet, so hooks lint moved plans and sessions on old skills recreate the folder;
   thinkpad-x1 isn't named. Fold: install tellgrader after the merge, a thinkpad line in the
   hand-over, and hold the T2 to T4 PRs until the packet decision, then merge in one sweep.
6. **Major, correctness.** The workstation guard is content-only, so a recreated folder whose text
   doesn't cite the path passes. Fold: `test -z "$(git ls-files docs/superpowers)"`.
7. **Major, correctness.** The excluded idiom fixture keeps `docs/superpowers/plans/example.md`,
   which the new rule 4 doesn't match, so `check-idioms.test.ts:96-99` goes red. Fold: drop its
   TSV row so the script rewrites it.
8. **Major, correctness plus over-ceremony.** cairn-pub sets no `kit.version.name`, so its build
   is stamped with a timestamp and `diff -r` always differs. Fold: drop the comparison.
9. **Major, correctness, OWNER FORK.** The clock-stop answer and the 830-minute ceiling aren't in
   the design. `claude-clock-stop` reads the clock file from the session's cwd git dir, so files
   in other repos' worktrees never fire. Options: (a) Geoff ratifies; (b) clock stops wait for
   Geoff. Recommends (a).
10. **Major, correctness.** T8 is underestimated (packet rebuilds, merges, the initiatives
    rewrite, a 14-repo rerun, every gate). Fold: split the initiatives rewrite out and rerun gates
    only where the default branch moved.
11. **Major, correctness.** The hand-edit inventory is wrong and T1's "within 5%" names counts the
    plan never gives. Fold: a per-repo table from the dry-run survey.
12. **Major, correctness.** No whole-branch close review for any PR. Fold: one per packet PR,
    scoped to the hand-edit commit; for self-merged PRs record that `--check` verifies the move.
13. **Major, correctness.** `~/.claude/workflows/docs-page-chain.js` links into drafter's main
    checkout, which `conductor-drafter` holds, so it stays stale and `PRIOR_ART` names a missing
    file after cairn-cms merges. Fold: merge cairn-cms and drafter back to back and name the
    drafter pull as a hand-over step.
14. **Major, OWNER FORK.** The B3c wait has no limit. Options: (a) wait; (b) after T5, send the
    packet for what is ready and leave cairn-cms, drafter, and initiatives as a launch prompt.
    Recommends (b).
15. **Minor, optional.** Whole-file pin exclusion keeps about 300 unpinned citations. Fold: skip
    only the pinned lines.
16. **Minor, correctness.** The two loose cairn-cms briefs enter the published-docs checks. Fold:
    add both by name to every skip list.
17. **Minor, correctness.** If the tellscan `.tellgrader.json` stays, `--check` lists it. Fold: add
    it to the TSV in that branch.
18. **Minor, correctness.** An aksailingclub-legacy merge redeploys the live club site. Fold: mark
    it `live-account` and watch the deploy.
19. **Minor, correctness.** aksailingclub-legacy doesn't ignore `.claude/worktrees/`. Fold: the
    `info/exclude` step.
20. **Minor, correctness.** Early self-merges cite cairn-cms paths before cairn-cms moves. Fold:
    the sweep in 5, or record the gap.
21. **Minor, correctness.** cairn-pub's comment is followed by a comma, so it's a hand line. Fold:
    call it a hand edit.
22. **Minor, optional.** cairn-cms `CHANGELOG.md` states past facts. Fold: a record row.
23. **Minor, optional.** drafter snapshot regeneration is unneeded; the suite has
    `UPDATE_SNAPSHOTS` and `UPDATE_GOLDENS`. Fold: `make check`, regenerate only on a red.
24. **Minor, correctness.** Escalating any repo leaves the outcome partly met. Fold: say so.
25. **Minor, correctness.** `--check` on already-broken relative links may print forever. Fold:
    limit it to the literal path.
26. **Minor, optional.** Treating applied migrations as records would make xcathletes-org
    `ordinary`.
27. **Minor, optional.** The plan omits the API-drop wake-up and the lid hold. Fold: add them.

Claims the reviewer checked and found true: no `docs/<child>` collision; no open PR adds an
old-path file or citation; `gh` holds `repo` and `workflow`; every repo allows merge commits;
`~/Projects/workstation` links to `~/.dotfiles`; the pin detector reproduced the TSV; no untracked
or ignored file sits under the old path on pavilion; cairn-cms's npm `files` and cairn-pub's
loader are allowlists.
