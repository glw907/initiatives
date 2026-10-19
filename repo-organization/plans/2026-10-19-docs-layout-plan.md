# Docs layout plan

Initiative: repo-organization

Design: `repo-organization/specs/2026-10-19-docs-layout-design.md`, approved by Geoff on
2026-10-19 (glw907/initiatives#52). Executor: this session, `docs-layout`, which wrote the plan.
Path estimate: 415 minutes against the design's 240 (1.73x), under the 480-minute line that would
send the plan back to Geoff. The arithmetic is under "Path".

## Pre-flight

None. The one item the design foresaw is checked: `gh auth status` reports `glw907` signed in
with the `repo` and `workflow` scopes, which push to every repo in the list. No step needs a
sign-in, a secret, a dialog, a permission rule, or a browser.

## Findings for the planning session

None of these changes the design's outcome, files, scope, or check. Each is decided here, and each
PR's `## Decisions` repeats the ones that touch it.

1. **A plain prefix swap breaks relative links.** Files move up one level, so a link out of the
   old folder (`](../../internal/x.md)` in `docs/superpowers/plans/`) loses its target, and a
   link into it from outside (`](../superpowers/plans/x.md)` in `docs/internal/`) needs its
   `superpowers/` dropped. The script resolves each relative link and path token against the
   file's old location, and rewrites it only when the old target exists. A cairn-cms survey counts
   103 upward links inside the old folder and 34 files with a relative `superpowers/` token.
2. **Several tools test for the folder name, not a path.** Rewriting their prefix would widen a
   pattern (`docs/superpowers/**` would become `docs/**`), so the script never rewrites
   `docs/superpowers` unless a name character follows the slash. It prints each other occurrence
   as a hand item. The hand list per repo is under "Tasks". Beyond the design's cairn-cms list it
   adds `check-leaks.mjs`, `check-options.mjs`, `check-tellgrader.mjs`, `.vale.ini`,
   `.tellgrader.json`, and four unit tests in cairn-cms, plus `vale-hook`, the tellgrader
   `posthook.go`, and `scripts/check.sh`'s pathspec in workstation. Each keeps its present
   behavior: what skipped `superpowers` now skips `specs`, `plans`, `research`, and `archive`
   under `docs/`.
3. **Three more PRs touch `runner` or `auth-data` paths, so they join the packet.** drafter's
   `claude/.claude/workflows/docs-page-chain.js` is a workflow (`runner`). aksailingclub-org's
   `migrations/**` and `src/admin-club/**`, and xcathletes-org's `migrations-platform/*.sql`, are
   `auth-data` in `site-pass`'s path map, though each edit is a comment. Each `auth-data` PR gets
   a task-scope `diff-reviewer` read. The asc migrations are applied by hand with
   `wrangler d1 execute`, and xc's by `wrangler d1 migrations apply`, which tracks file names, so a
   comment edit in an applied migration changes nothing that runs.
4. **cairn-cms ships one PR, and it goes to the packet.** Its link, Vale, tellgrader, leak, and
   options checks skip a directory named `superpowers`. A move without them would put about 660
   history files under the published-docs checks, and CI would fail. So the move and the check
   scripts land together.
5. **B3c works in cairn-cms too.** It holds `cairn-cms/.claude/worktrees/b3c-pilot-pages`, and
   drafter's chain reads cairn-cms paths. A 620-file rewrite in cairn-cms would conflict with its
   branch. So cairn-cms waits for B3c with drafter, and goes just before it.
6. **initiatives goes last, after the packet merges.** The B3c plan and the docs-system records
   live there, and their cairn-cms citations would point at paths that don't exist until cairn-cms
   merges. The script and this plan land first in their own PR, since the script lives here.
7. **Merged sites deploy.** 907-life, ecxc-ski, and cairn-pub deploy on a push to `main`, and
   their PRs merge themselves. The 907-life and ecxc-ski diffs touch only `docs/` and the
   `CLAUDE.md` family, which no build reads. cairn-pub's diff edits a comment in
   `src/lib/docs/link-policy.ts`, so its task builds the base and the head and compares the build
   output before it merges.
8. **Live sessions in workstation.** `dotfiles-bf` works in `~/.dotfiles` and
   `workstation-proton-mail-read` in its own worktree (PR #102). This pass works in its own
   worktree, never pulls a checkout that holds a live session, and reports that checkout as stale.
   None of the open PRs in the list (asc-legacy #150 to #157, initiatives #7 and #50, workstation
   #85, #86, and #102) adds a file under the old path or cites it.

## Excluded records

`repo-organization/research/docs-layout-excluded.tsv` names each one by repo and old path, with
its reason, 294 rows. The script reads it, skips each listed file's content, and still moves the
file when it sits under `docs/superpowers/`. The end-to-end check maps each old path to its new
one. The rows fall in five groups.

- The design's named records: `repo-organization/research/migration-map.tsv`,
  `retire-manifest.tsv`, and `2026-10-14-retirement-log.tsv` (the last two cite no old path, so
  their rows are a no-op).
- Records of the 2026-10-14 migration: `repo-organization/research/migration-calls.md`; the tools
  `repo-organization/tools/refs` and `classify-docs`; their tests `tools/tests/scope-harness`,
  `tools/tests/refs/{lib.sh,refs.test.sh,apply-root.test.sh,scope.test.sh}`, and
  `tools/tests/classify/classify.test.sh`; and in workstation `scripts/check-moves.sh`,
  `tests/check-moves.test.sh`, and `tests/fixtures/ci-green/pr-107-files.txt`. These match or
  replay the map's old paths, so a rewrite would change what they check.
- This pass's own files, which name the old path as their subject: the design, this plan, its
  launch prompt, the TSV, `repo-organization/tools/docs-layout`, and its test.
- The guard fixture `cairn-cms/scripts/checks/fixtures/idioms/superpowers-path.ts`, which must
  hold the old path for the guard's test to fail on it.
- 272 files whose old-path line carries a commit pin (`Target: docs/superpowers/... at
  a0fa4b6`): 122 in cairn-cms, 107 in dubplate, 15 in workstation, 9 in phonebook, and 19 in
  initiatives. The detector matches a line that holds `docs/superpowers/` and either a 40-hex id
  or a 7-to-12-hex id after `at`, `pin`, `pinned`, `commit`, or `revision ... at`. One hit is
  dropped: drafter's `tests/fixtures/docs-page-chain/default-run.with-outline-round2.json` is a
  snapshot the handoff test compares against the chain's output, so it follows the generator.

No GitHub permalink pins an old path to a commit (`blob/<sha>/docs/superpowers` matches nothing),
so no URL needs keeping.

## Repo order

1. initiatives (the script, its test, the TSV, and this plan; no citation rewrite yet)
2. cairn-themes, aksailingclub-legacy, phonebook (smallest, docs only)
3. 907-life, ecxc-ski, poplar, dubplate
4. xcathletes-org, aksailingclub-org, cairn-pub
5. workstation
6. After B3c merges: cairn-cms, then drafter
7. The packet. After Geoff's decision: the merges, then initiatives' citation rewrite
8. A rerun of the script over every repo, the end-to-end check, and the hand-over

B3c counts as merged when glw907/drafter and glw907/cairn-cms list no open PR from
`worktree-b3c-pilot` or `b3c-pilot-pages`, each such branch's PR is merged, and `claude agents
--json` shows no busy `drafter-b3c-pilot`. The session waits on that with a Monitor until-loop
over `gh pr list` and `claude agents --json`, with a 30-minute fallback wake-up. The wait sits
outside the path.

## Execution rules

- Each repo gets `git -C <repo> worktree add <repo>/.claude/worktrees/docs-layout -b docs-layout
  origin/<default>` after `git -C <repo> fetch origin`, and the adapter's setup command where it
  has one. The session never calls `EnterWorktree`.
- In each worktree, in order: run `docs-layout --dry-run <worktree>`, read every hand item, run
  `docs-layout <worktree>`, make the hand edits, and run `docs-layout --check <worktree>`, which
  must print only excluded records. Then commit the move in one commit (`git mv` keeps history)
  and the hand edits in a second, so a reviewer reads the hand edits alone. The gate follows.
- Each PR opens as a draft on `glw907/<repo>` with a `## Brief`, the counts (files moved, files
  rewritten, hand edits), `## Decisions`, and `## Planning misses`. The score goes in the packet
  and in the last initiatives PR, never in each docs PR.
- A docs-only PR in an `ordinary` repo merges itself with `gh pr merge <n> --merge` after its gate,
  and the session pulls the main checkout per `pass-core` "Close".
- A PR that goes to the packet stays a draft until the packet, then is marked ready.

## Tasks

Each task carries a clock file per `pass-core` "Clock stop". Every task runs in sequence; there
are no pairs, since the prompt runs one repo at a time.

### T1. The move script and its fixture test (initiatives)

- Outcome: `repo-organization/tools/docs-layout`, Python 3 like its neighbors, with one positional
  argument (the repo path) and `--dry-run` and `--check`. Apply runs `git mv` for each child of
  `docs/superpowers/` into `docs/`, refusing before any move when `docs/<name>` already holds a
  tracked file. It then rewrites each tracked text file (`git grep -I`) that the TSV doesn't list:
  `docs/superpowers/` followed by a name character becomes `docs/`, and each relative markdown
  link, reference definition, HTML `href` or `src`, and `superpowers/` path token is resolved
  against the file's old location and rewritten when the old target exists. It prints every other
  occurrence of `docs/superpowers` or a relative `superpowers/` as `hand <file>:<line>`. It skips
  `.superpowers/`, symlinks, and `.claude/worktrees/`. `--check` prints each tracked file that
  still cites the old path and isn't excluded, plus `docs/superpowers` if it exists, and exits 1
  when it prints anything. A second apply changes nothing.
- Files: `repo-organization/tools/docs-layout`,
  `repo-organization/tools/tests/docs-layout/docs-layout.test.sh`,
  `repo-organization/research/docs-layout-excluded.tsv`, this plan.
- Risk: `ordinary`.
- Test: a fixture repo with a spec, a plan linking `../../internal/x.md` and `../specs/y.md`, a
  loose file, an outside file linking `../superpowers/plans/p.md`, a `docs/superpowers/**` glob, a
  `.superpowers/` mention, an excluded file, a broken relative link, and a collision. It asserts
  the moves, each rewrite, the hand line for the glob, the untouched exclusion and broken link, the
  collision refusal, `--check`'s exit codes, and a no-op second run.
- Acceptance: `bash scripts/gate.sh` green; `--dry-run` over each repo's main checkout prints the
  move and rewrite counts above within 5%, plus the hand lines this plan names.
- PR: initiatives, self-merged.
- Estimate: 70 minutes.

### T2. cairn-themes, aksailingclub-legacy, phonebook

- Outcome: each repo's old folder is gone and its citations rewritten. Hand items: none foreseen.
- Gates: cairn-themes and phonebook have none (their `CLAUDE.md` says so), so the gate is
  `docs-layout --check` plus `git diff --stat` reading only renames and docs. aksailingclub-legacy
  runs its `test.yml` CI on the PR, watched with `gh pr checks <n> --watch --fail-fast`.
- Risk: `ordinary`. Three PRs, each self-merged.
- Estimate: 25 minutes for the three.

### T3. 907-life, ecxc-ski, poplar, dubplate

- Outcome: as T2. Hand items foreseen: none in 907-life and ecxc-ski. poplar's `Makefile` and
  `internal/theme/theme.go` carry comment citations the script rewrites. dubplate's `.gitignore`
  line 60 is a concrete path, so the script rewrites it, and its Go constants in
  `internal/harness/conform/case.go` and two `grade` tests name files that move with them.
- Gates: 907-life and ecxc-ski run `npm run check` after `npm ci` and `npx svelte-kit sync`, per
  `site-pass`. poplar and dubplate run `bash scripts/gate.sh`; poplar's CI runs on the PR.
- Risk: `ordinary`. Four PRs, each self-merged.
- Estimate: 70 minutes for the four (dubplate's gate is the long one).

### T4. xcathletes-org, aksailingclub-org, cairn-pub

- Outcome: as T2. xcathletes-org and aksailingclub-org hold citations only in comments in code and
  migrations. cairn-pub holds one comment in `src/lib/docs/link-policy.ts`, which the script
  rewrites to `docs/specs/` and friends; the hand edit names the four directories in place of
  `docs/superpowers/`.
- Gates: `npm run check` per `site-pass`, then cairn-pub's full close (`npm run check && npm test
  && npm run build`) at base and head, with `diff -r` over the two build outputs. aksailingclub-org
  watches its PR CI.
- Risk: `auth-data` for xcathletes-org and aksailingclub-org (comment-only, Finding 3), with a
  task-scope `diff-reviewer` read; `ordinary` for cairn-pub, self-merged.
- Estimate: 55 minutes for the three.

### T5. workstation

- Outcome: the move and rewrite, plus the hand edits:
  - `scripts/check.sh`: the retired-names check excludes `docs/specs/`, `docs/plans/`, and
    `docs/research/` in place of `docs/superpowers/`, excludes the three workstation records, and
    adds `docs/[s]uperpowers` to its pattern, so the line can't match itself. This is the guard.
  - `bin/.local/bin/vale-hook` and `tests/test_vale_hook.py`: the skip moves from a `superpowers`
    path segment to a `docs` segment followed by `specs`, `plans`, `research`, or `archive`.
  - `claude/.claude/skills/writing-voice/evals/tellgrader/internal/posthook/posthook.go` and its
    test: the same skip in Go, written after `go-conventions` loads.
  - The tellscan testdata `.tellgrader.json` exclude glob becomes `docs/{specs,plans,research,archive}/**`
    if its test reads the glob as the cairn-cms config's mirror, and stays if the test only
    exercises exclusion. The session reads the test and records which in `## Decisions`.
  - `site-pass`'s `docs/superpowers/{plans,specs}/` and any other glob-shaped hand line.
- Gate: `bash scripts/gate.sh`, then `claude-tooling-sync verify` and one `gitleaks git` scan, per
  `dotfiles-pass`.
- Risk: `runner`. The PR goes to the packet.
- Estimate: 55 minutes.

### T6. cairn-cms (after B3c merges)

- Outcome: the move and rewrite, plus the hand edits, each read before it changes:
  - `scripts/checks/check-idioms.mjs`: rule 4 bans `docs/(specs|plans|research|archive)/` paths
    in `src/lib`, and a new rule fails when any tracked file sits under the old folder. The rule
    builds the old name from parts, so the script doesn't cite it. This is the guard. Its fixture
    `superpowers-path.ts` stays, and `src/tests/unit/check-idioms.test.ts` gains a case for each
    rule.
  - `docs-links.mjs`, `check-tellgrader.mjs`, `check-options.mjs`, and `check-leaks.mjs`: the
    skipped directory set becomes `specs`, `plans`, `research`, and `archive`, plus the two loose
    briefs by name if their links fail the published-docs checks. Their tests
    (`check-options.test.ts`, `check-leaks.test.ts`, `check-package-files.test.ts`) follow.
  - `.vale.ini`'s `[docs/superpowers/**]` section and `.tellgrader.json`'s exclude glob name the
    four directories.
  - `check-consumers.mjs`, `transcript-blocks.mjs`, `check-surface-leaks.json`, and
    `packages/create-cairn-site/src/cloudflare/api.mjs` carry comment or string citations the
    script rewrites; the session reads each diff line.
  - `CONTRIBUTING.md` and `docs/STATUS.md` carry `superpowers/` prose the script reports.
- Gate: the cairn-pass fast lane (`node scripts/checks/gate-tier.mjs --fast --range
  origin/main..HEAD`), then CI on the draft PR, watched with `ci-green <sha> --pr <n> --wait`.
- Risk: `runner` (`scripts/checks/**`), with `packages/create-cairn-site/src/cloudflare/**` an
  `auth-data` comment edit, so a task-scope `diff-reviewer` read. The PR goes to the packet.
- Estimate: 80 minutes.

### T7. drafter (after cairn-cms opens its PR)

- Outcome: the rewrite (drafter holds no old folder). The chain's `PRIOR_ART` constant and its
  comments name the new cairn-cms paths. The handoff snapshots regenerate with the test suite's
  own update command, and the session reads their diff for path-only changes.
- Gate: `make check`.
- Risk: `runner`. The PR goes to the packet, merged after cairn-cms.
- Estimate: 25 minutes.

### T8. The packet, the merges, initiatives, and the close

- Outcome: before the packet, each packet PR merges its default branch and reruns the script and
  its gate. One packet through `approval-packet` carries workstation, cairn-cms, drafter,
  aksailingclub-org, and xcathletes-org, with merge order workstation, cairn-cms, drafter, then
  the two sites. After the decision: merges with `--match-head-commit`, checkout pulls or stale
  reports, then initiatives' citation rewrite in its own self-merged PR. The script then runs once
  more over every repo; any repo it changes gets a follow-up PR. Then the end-to-end check: for
  each repo, on its default branch, `git grep -l 'docs/superpowers'` prints only TSV rows (old
  paths mapped to new), `test ! -e docs/superpowers` succeeds, and the gate is green. Then the
  hand-over per `pass-core` "Close" and "Ledgers".
- Risk: as each PR.
- Estimate: 35 minutes of path, plus Geoff's read.

## Path

Every task runs in sequence: 70 + 25 + 70 + 55 + 55 + 80 + 25 + 35 = 415 minutes. The B3c wait and
Geoff's read sit outside it.

## Stops and their standing answers

- **A clock stop on a task.** The session traces the overrun, sets `estimate=` to twice the first
  figure once, records it in that PR's `## Decisions`, and goes on. A second overrun on the same
  task goes on while each fix has a traced cause.
- **The path ceiling, 830 minutes (twice the plan).** The session finishes the repo in flight,
  opens no new repo, and sends the packet with what landed; the packet lists each repo left.
- **A collision** (`docs/<name>` already holds files). The script refuses before any move. The
  session moves the colliding child under `docs/<name>-superpowers/`, records it in
  `## Decisions`, and goes on. None exists today.
- **A merged branch recreates the old folder** (the design's standing answer). The session reruns
  the script on that repo and opens a follow-up PR, self-merged unless it touches a packet path.
- **A gate fails for a cause the move didn't make** (the design's standing answer). The PR stays
  open, and the packet names the cause. The session checks the cause by running the gate on the
  base.
- **A hand item the plan didn't foresee.** The session reads the file. A comment or prose
  citation gets the new path. A pattern gets the four directory names, keeping its behavior, and a
  line in `## Decisions`.
- **cairn-pub's build output differs.** The PR stays open and joins the packet, with the diff.
- **B3c hasn't merged when T5 ends.** The session waits on the Monitor. Nothing else runs, and no
  question goes to Geoff.
- **A loop guard.** Three gate reruns on one repo for one cause, then a structural fix, then the
  item is escalated in the packet and the session goes on. Any repo but workstation and cairn-cms
  can be escalated without breaking the outcome, since those two hold the guards.

## Later

Nothing.
