# Docs layout plan review: contract and criteria

Target: `repo-organization/plans/2026-10-19-docs-layout-plan.md` at 5982a17 (branch `docs-layout`).
Design: `repo-organization/specs/2026-10-19-docs-layout-design.md`. Lens: whether each promise can be
tested, whether a criterion can pass vacuously, and whether the plan covers the design's outcome
and stays inside it. Probes were read-only `git grep` and `grep` over `~/Projects/*` and
`~/.dotfiles`.

Verdict: **fix before approval.** There are four major correctness findings: the guards have no
proof that they fire, the exclusion is file-level and too broad, there is a criterion with nothing
to measure against, and the end-to-end check has blind spots. Each has a fold that fits inside the
present tasks. One finding is an owner fork.

## Findings, ranked by consequence

### 1. Major, correctness: neither guard has a check that proves it fires, and each guard covers only half of "the old path comes back"

Location: plan:194-197 (T5 guard), plan:214-218 (T6 guard), plan:251-254 (end-to-end check).

Defect. The design's outcome is "The two guard checks are in place" (design:29), and no criterion
or check tests it.
- **workstation.** `check_no_old_names` (`~/.dotfiles/scripts/check.sh:40-47`) greps file content
  only. It has no test today, because `tests/` holds no check.sh test. A merged branch could
  recreate `docs/superpowers/plans/x.md` whose content never names `docs/superpowers`, and the
  guard would stay silent. That recreation is exactly the design's standing-answer case. The new
  exclusions `:!docs/specs/ :!docs/plans/ :!docs/research/` also blind the guard in the folders
  where a habit-driven new plan would most likely cite the old path.
- **cairn-cms.** The new rule checks file location only. Rule 4 moves to the new paths, so a
  `docs/superpowers/` citation in `src/lib` is no longer banned at all.
- **The end-to-end check.** It runs `git grep`, `test ! -e`, and the gate on a clean tree. A guard
  that can never fire still passes all three.

Fold.
- (a) T5: add `git ls-files docs/superpowers` (non-empty fails) to the workstation guard, beside
  the content grep.
- (b) T6: keep `docs/superpowers/` in rule 4's banned set alongside the four new directories.
- (c) Give each guard a negative proof. In T5 and T6, plant a tracked `docs/superpowers/x.md` in
  the worktree, plus a cited line for the content checks. Run the guard, require exit 1 with the
  right message, then remove the plant. Record the output in the PR body.
- (d) Repeat (c) in T8's end-to-end check against each default branch, so the outcome line has a
  criterion.

### 2. Major, correctness: the guard fixture's role contradicts the new rule 4

Location: plan:82-83, plan:214-218. Evidence: `cairn-cms/scripts/checks/fixtures/idioms/superpowers-path.ts`,
and `src/tests/unit/check-idioms.test.ts:88-97`, `:254`.

Defect. The plan keeps the fixture "so the guard's test fails on it", yet it changes rule 4 to ban
`docs/(specs|plans|research|archive)/`. The fixture holds `docs/superpowers/plans/example.md`, which
the new rule 4 doesn't match. The new location rule doesn't read content either. The existing test
at :97, which expects the fixture to be flagged, will either break or get rewritten into a case
that can't fail. The script also rewrites `:89`'s `docs/superpowers/plans/x.md` to
`docs/plans/x.md`. That happens to suit the new rule. But `:254`'s `'1 docs/superpowers/ path
reference(s)'` is a hand item the plan doesn't name.

Fold. Take fold 1(b), so rule 4 bans both the old and the new paths and the fixture stays
meaningful. Add a second fixture holding a `docs/plans/` path. Name `check-idioms.test.ts:254` and
the message string at `check-idioms.mjs:467,494` as hand items in T6.

### 3. Major, correctness. OWNER FORK: file-level pin exclusion leaves about 300 live citations unrewritten in 99 files

Location: plan:84-89, plan:66-68. Design:34.

Defect. A probe of all 272 pin rows counted 590 old-path lines. Only about 287 of them carry a pin
on the same line (approximate regex). 99 files hold unpinned citations, for example:
- `dubplate/docs/superpowers/specs/2026-09-07-streamer-2-0-design.md`: 14 citations, 1 pinned.
- `initiatives/docs-system/research/2026-10-12-drafter-pipeline-review-contract.md`: 30 citations,
  1 pinned.
- `dubplate/.../2026-09-25-rung-5d-boundary-deployment-close.md`: 19 citations, 1 pinned.

These are living specs and plans, not records of a past path. The end-to-end check would pass
because they sit in the TSV. That is the "exclusion list too broad" vacuity: the check proves the
list, not the outcome. The design's own wording ("any file whose old path sits beside a commit
pin") supports the file-level reading. Its outcome ("except the records ... that state a past path
as a fact") supports the line-level one.

Options:
- (A) Line-level. The TSV keeps its pin rows, the script skips only the pinned lines, and `--check`
  and the end-to-end check allow only those lines. This needs a TSV column, or the script runs the
  detector at check time.
- (B) File-level, as planned. About 300 stale citations remain inside 99 excluded files.
- (C) File-level for `research/` review records only, and line-level for `specs/` and `plans/`.

Recommendation: (A). It meets the outcome as written and costs about 15 minutes in T1. The detector
already exists, so the line rule is the same regex.

### 4. Major, correctness: T1's acceptance has no counts to measure against

Location: plan:154-155.

Defect. The criterion reads "prints the move and rewrite counts above within 5%", but no per-repo
counts appear above. The plan gives only cairn-cms figures (103 upward links, 34 files, about 660
and 620 files) and the design's totals (about 1,700 and 1,400). "The hand lines this plan names"
is partial too: T5's "and any other glob-shaped hand line" and T6's "the prose the script reports"
are open-ended. As written, the criterion can't fail.

Fold. Add a per-repo table to T1. Its columns are files under `docs/superpowers` (`git ls-files |
wc -l`), files citing the old path (`git grep -l | wc -l`), minus TSV rows, and the expected hand
lines by file:line. The criterion becomes: the dry-run's move count equals `ls-files` exactly, the
rewrite count equals cited minus excluded exactly, and every hand line printed is in the table or
is added to it with a reason before T2. Exact counts are cheaper to state than 5% and catch more.

### 5. Major, correctness: the end-to-end check misses relative citations and broken rewrites

Location: plan:251-254, plan:142-144 (`--check`).

Defect. The design's outcome bans any citation of the path. A relative `../superpowers/plans/x.md`
in `docs/internal/` cites it, and `git grep 'docs/superpowers'` doesn't see it. The plan counts 34
such files in cairn-cms alone. The script also leaves a relative link untouched when its old
target is missing. That's correct, but no criterion distinguishes "left because already broken"
from "left because the resolver missed". Link integrity after the move, which is Finding 1's
riskiest rewrite, is checked only in the T1 fixture and by cairn-cms's own `docs-links.mjs`, which
skips the moved folders. Elsewhere a mis-resolved `../../internal/x.md` passes every gate.

Fold. `--check` gains two reports: every remaining relative `superpowers/` token that resolves
into the old folder, and every relative link in a moved or rewritten file whose target existed at
the base commit but doesn't exist at HEAD. Exit 1 on either. Then T8's end-to-end check runs the
new `--check`, not only `git grep`. This replaces nothing in the design and costs about 20 minutes
in T1.

### 6. Major, correctness: the end-to-end check reads checkouts the plan says it won't pull

Location: plan:58-60, plan:250-253.

Defect. The plan never pulls a checkout that holds a live session (workstation's `~/.dotfiles` has
`dotfiles-bf`) and reports it stale instead. The end-to-end check then runs "on its default
branch". If that means the checkout, workstation fails on a stale tree and the close stalls. It's
a false fail, but it lands on the hand-over.

Fold. Run the check against `origin/<default>` after a fetch: `git grep -l 'docs/superpowers'
origin/main`, `git ls-tree -d origin/main docs/superpowers` (must be empty), and the guard proofs
in a fresh scratch worktree at `origin/main`.

### 7. Minor, correctness: `--check`'s contract is stated two ways

Location: plan:117-118 against plan:142-144.

Defect. The execution rules say `--check` "must print only excluded records". T1 says it prints
only files that are not excluded, and exits 1 when it prints anything. Under the first reading,
the exit code can't be the gate.

Fold. Use T1's wording in both places: print nothing, exit 0 on success.

### 8. Minor, correctness: T1's fixture test misses cases the plan relies on

Location: plan:149-153.

Defect. The fixture lacks five cases the plan depends on:
- An excluded file under `docs/superpowers/` that must still move, with `--check` mapping its old
  path to its new one.
- A reference-style definition and an HTML `href` or `src`, both named in the outcome.
- A symlink and a `.claude/worktrees/` path, both of which the outcome skips.
- `docs/superpowers` followed by a non-name character mid-prose, such as a closing backtick or a
  full stop.
- A pinned line beside an unpinned line in one file, if fork 3 takes (A).

Each skip rule is promised and has no test.

Fold. Add these cases to the fixture and assert each.

### 9. Minor, correctness: the packet grows from two PRs to five without the design's Brief saying so

Location: plan:36-42, plan:246-249. Design:19.

Defect. The approved "If you approve" promised that the workstation and cairn-cms PRs come in one
packet. The plan adds drafter, aksailingclub-org, and xcathletes-org. `site-pass`'s path map
forces this, so it is not a design change. But the packet should open by saying why, or it reads
as scope creep.

Fold. Make the packet's first routine row "three more PRs joined because of `site-pass` path
classes", citing Finding 3.

### 10. Minor, correctness: workstation merges before cairn-cms, so its cross-repo citations dangle in between

Location: plan:248.

Defect. After the rewrite, workstation's skills cite cairn-cms `docs/specs/...` paths that don't
exist until cairn-cms merges. The window is short, but the checks of a session started in it would
fail on those links.

Fold. Merge in the order cairn-cms, workstation, drafter, then the sites. Alternatively, record
the window in `## Decisions`.

### 11. Minor, optional: over-ceremony in cairn-pub's base and head builds

Location: plan:53-57, plan:185-186, plan:281.

Defect. Running the full close (`check`, `test`, `build`) twice, then `diff -r`, for a one-line
comment edit in `link-policy.ts` costs about 10 to 15 minutes. If the output carries any
nondeterminism, it sends the PR to the packet with no real cause.

Fold. Check that `git diff origin/main..HEAD -- src` changes only comment lines, then run the
normal gate. Drop the `diff -r` stop at :281.

### 12. Minor, optional: over-ceremony in T8's gate reruns

Location: plan:253.

Defect. Rerunning 14 repo gates locally after the merge repeats CI. dubplate's gate is "the long
one".

Fold. "The gate is green" becomes the default branch's latest CI run at the merge commit, via
`gh run list --branch main --limit 1`, or `ci-green` where it exists. Rerun locally only in the
repos without CI: cairn-themes and phonebook, whose gate is `--check`.

### 13. Minor, optional: over-ceremony in the diff-reviewer reads on comment-only migration edits

Location: plan:40-42, plan:188-189, plan:231-232.

Defect. There are three task-scope `diff-reviewer` dispatches for edits that are comment-only by
construction. Their cost is tokens, not risk.

Fold. Keep them, because the `auth-data` bar requires them, but give one dispatch all three diffs
with the single criterion "only comment lines and path strings change".

## Coverage against the design

| Design outcome line | Plan coverage | Gap |
|---|---|---|
| No tracked file under `docs/superpowers/` | T1 to T8, end-to-end `test ! -e` | Finding 6 (runs on the checkout, not `origin`) |
| No tracked file cites it, except records | Script rewrite, `--check`, end-to-end grep | Findings 3 and 5 |
| Skills, agents, `CLAUDE.md`, and the monthly-review prompt name the new paths | Prefix rewrite in T5 (`docs/model-review/prompt.txt:22,26,31` are prefix cases) | None. The grep covers it. |
| Two guards in place | T5 and T6 | Findings 1 and 2 |
| Standing answers (recreated folder, foreign gate failure, drafter last) | plan:273-277, 101 | None |

The only work beyond the design is the cairn-cms wait for B3c (Finding 5) and the larger packet
(Finding 9). Both are justified.
