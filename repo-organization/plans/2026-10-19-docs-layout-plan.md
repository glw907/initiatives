# Docs layout plan

Initiative: repo-organization

Design: `repo-organization/specs/2026-10-19-docs-layout-design.md`, approved by Geoff on
2026-10-19 (glw907/initiatives#52). Executor: this session, `docs-layout`, which wrote the plan.
Review: three lenses (`repo-organization/research/2026-10-19-docs-layout-plan-review-{contract,mechanics,integrity}.md`)
and the fold (`...-plan-fold.md`). Path estimate: 455 minutes against the design's 240 (1.9x),
under the 480-minute line that would send the plan back to Geoff. The arithmetic is under "Path".

## Pre-flight

None. The one item the design foresaw is checked: `gh auth status` reports `glw907` signed in
with the `repo` and `workflow` scopes, which push to every repo in the list. No step needs a
sign-in, a secret, a dialog, a permission rule, or a browser.

## Findings for the planning session

None of these changes the design's outcome, files, scope, or check. Each PR's `## Decisions`
repeats the ones that touch it.

1. **Relative links.** Files move up one level, so a link out of the old folder loses a `../`, and
   a link into it from outside drops its `superpowers/`. The script resolves each relative link,
   reference definition, `href`, `src`, and relative path token against the file's old location,
   and rewrites it only when the old target exists.
2. **Patterns.** A bare `docs/superpowers` in code or config is often a pattern
   (`docs/superpowers/**`), so outside prose the script rewrites only a path with a name after the
   slash and prints the rest as hand lines. In prose (`.md`, `.mdx`, `.txt`) it applies the
   design's literal swap, and the folder named as a whole becomes the brace list of the folders it
   held (`docs/{plans,research,specs}`), which keeps the sentence true. Tools that test the folder
   name without the path (vale-hook, tellgrader's posthook, cairn-cms's checks) are hand edits the
   tasks name.
3. **Pins.** A line that holds the old path beside a commit id keeps the old path, since it states
   a fact about that commit. The script detects these lines live: an old-path line with a 7-to-40
   hex token holding a digit and a letter. It rewrites every other line of the same file.
4. **Classes.** The design's risk-class line names its `runner` parts: the workstation PR and
   cairn-cms's `scripts/checks/`. A citation the script rewrites in another repo's `.claude/`,
   `Makefile`, migrations, or `src/admin-club/` is the design's `ordinary` docs move. The
   reproduction proof in "Execution rules" shows each such commit is the script's output and
   nothing else. A hand edit takes its path's class.
5. **One sweep.** No PR merges before the packet decision. Merging early would open windows: the
   hooks would lint moved plans, cross-repo citations would point ahead of cairn-cms, and sessions
   on the old skills would recreate the folder. So every PR is built and gated first, and they
   merge together after Geoff decides.
6. **B3c.** B3c holds `cairn-cms/.claude/worktrees/b3c-pilot-pages`, and drafter's chain cites
   cairn-cms paths. So the cairn-cms and drafter branches are built now and rebuilt on the new
   `main` once B3c merges. The rest of the pass runs while it waits.
7. **Fact bullets.** Eleven bullets in cairn-cms's `docs/internal/facts/` cite the old path, and
   the facts check needs each `Source:` to resolve, so they change. drafter's `FactChanged` then
   reports them as changed, and the next `drafter page` run redrafts the sections that cite them.
   T8 measures that scope, and the cairn-cms ask in the packet states it.
8. **Live sessions.** `dotfiles-bf` works in `~/.dotfiles` and `conductor-drafter` in
   `~/Projects/drafter`. This pass works only in its own worktrees and pulls no checkout a live
   session holds; it reports each one stale. No open PR in the list adds an old-path file or
   citation.

## Excluded records

`repo-organization/research/docs-layout-excluded.tsv` names each one by repo and old path, with
its reason. The script matches each row at its old path and its new one. The rows fall in four
kinds.

- **Whole-file records**, whose content never changes (each still moves when it sits in the old
  folder):
  - the design's three: `repo-organization/research/migration-map.tsv`,
    `retire-manifest.tsv`, and `2026-10-14-retirement-log.tsv`
  - the 2026-10-14 migration's records: `research/migration-calls.md`, the tools
    `tools/refs` and `tools/classify-docs`, and their tests `tools/tests/scope-harness`,
    `tools/tests/refs/{lib.sh,refs.test.sh,apply-root.test.sh,scope.test.sh}`, and
    `tools/tests/classify/classify.test.sh`
  - in workstation, `scripts/check-moves.sh`, `tests/check-moves.test.sh`, and
    `tests/fixtures/ci-green/pr-107-files.txt`
  - in initiatives, `approval-queue/specs/assets/2026-10-11-review-desk-ui/pr-b.html`, a mockup that
    replays a past PR
  - in cairn-cms, `CHANGELOG.md` and the harvest records
    `docs/internal/record/harvest/{README.md,relink.json,residue.txt}`
  - this pass's own files: the design, this plan, its launch prompt, the three reviews, the fold,
    the TSV, `tools/docs-layout`, and its test
- **`pin` rows**, 307 files, which only document what the live detector keeps: 138 in cairn-cms,
  116 in dubplate, 24 in workstation, 20 in initiatives, and 9 in phonebook. The detector keeps
  340 lines in them.
- **A `follow` row**: drafter's `tests/fixtures/docs-page-chain/default-run.with-outline-round2.json`,
  a snapshot whose hex ids are placeholders, so the detector is off for it and it follows the
  chain's source.

## Counts

From `docs-layout --dry-run` over each main checkout at the commit shown, with this TSV. T1 and
each task check their own dry run against this row. A count that moves by more than the commits
landed since is traced before the task goes on.

| Repo | Commit | Files moved | Files rewritten | Hand lines | Pinned lines |
|---|---|---|---|---|---|
| cairn-themes | `06793ba8` | 2 | 12 | 0 | 0 |
| aksailingclub-legacy | `9b384880` | 6 | 4 | 0 | 0 |
| phonebook | `35fa92b2` | 13 | 10 | 0 | 10 |
| 907-life | `76f219cf` | 23 | 12 | 0 | 0 |
| ecxc-ski | `109fc4c1` | 60 | 31 | 0 | 0 |
| poplar | `e7a3ee66` | 279 | 141 | 0 | 0 |
| dubplate | `5b8bbdb2` | 518 | 279 | 0 | 128 |
| xcathletes-org | `2003f249` | 14 | 21 | 0 | 0 |
| aksailingclub-org | `48061e1b` | 0 | 18 | 0 | 0 |
| cairn-pub | `f14cb3ae` | 0 | 2 | 1 | 0 |
| workstation | `48a99bf5` | 114 | 80 | 2 | 26 |
| cairn-cms | `11104274` | 660 | 554 | 12 | 155 |
| drafter | `7e7dc63f` | 0 | 7 | 0 | 0 |
| initiatives | `25fea941` | 0 | 68 | 0 | 21 |

The 15 hand lines: cairn-pub `src/lib/docs/link-policy.ts:8`; workstation `scripts/check.sh:43`
and the tellscan testdata `.tellgrader.json:4`; cairn-cms `.tellgrader.json:4`, `.vale.ini:49`,
`scripts/checks/check-idioms.mjs:14,179,184,467,494`, `scripts/checks/docs-links.mjs:6`,
`scripts/checks/transcript-blocks.mjs:28`, `src/tests/unit/check-idioms.test.ts:88,254`, and
`src/tests/unit/check-package-files.test.ts:137`.

## Repo order

1. T1: initiatives (the script, its test, the TSV, the reviews, and this plan; self-merged now,
   since it changes no citation)
2. T2 to T5: cairn-themes, aksailingclub-legacy, phonebook; 907-life, ecxc-ski, poplar, dubplate;
   xcathletes-org, aksailingclub-org, cairn-pub; workstation
3. T6, T7: cairn-cms and drafter, built on today's `main`
4. The B3c wait
5. T8: cairn-cms and drafter rebuilt on the new `main`
6. T9: the close reviews and the packet
7. T10: after Geoff's decision, the sweep: cairn-cms, drafter, workstation, then the rest
8. T11: initiatives' citation rewrite. T12: the end-to-end check and the hand-over

B3c counts as done when glw907/drafter has a merged or closed PR from `worktree-b3c-pilot`,
glw907/cairn-cms has one from `b3c-pilot-pages`, and `claude agents --json` lists no
`drafter-b3c-pilot`. The session waits with a Monitor until-loop over `gh pr list --state all
--head <branch>` and `claude agents --json`, plus a fallback wake-up every 30 minutes. The wait
sits outside the path and has no deadline.

## Execution rules

- **Guards.** The session arms the API-drop wake-up (`/loop` with no interval) per
  `~/.claude/docs/unattended-work-guards.md`. pavilion is a desktop, so there's no lid hold.
- **Clock.** At each task start the session writes `pass-task-clock` in this initiatives
  worktree's git dir (`git -C ~/Projects/initiatives/.claude/worktrees/docs-layout rev-parse
  --absolute-git-dir`), since `claude-clock-stop` reads the session's cwd. A clock stop follows
  `pass-core` "Clock stop": STATUS, `notify-send -u normal`, and a wait for Geoff.
- **Worktrees.** Per repo: `git -C <repo> fetch origin`; where `git -C <repo> check-ignore -q
  .claude/worktrees/x` fails (aksailingclub-legacy today), append `.claude/worktrees/` to the
  file `git -C <repo> rev-parse --path-format=absolute --git-path info/exclude` names; then
  `git -C <repo> worktree add <repo>/.claude/worktrees/docs-layout -b docs-layout
  origin/<default>`, and the adapter's setup command where one applies. The session never calls
  `EnterWorktree`.
- **Commits.** Per repo, in its worktree: `docs-layout --dry-run`, compared with "Counts", then
  `docs-layout <worktree>`. When the repo has a folder to move, commit the pure renames ("Move
  docs/superpowers children up to docs/"), then `docs-layout --finish`. Commit the scripted
  rewrite ("Rewrite citations of docs/superpowers/"). Then make the hand edits and commit them
  apart. A failed apply recovers with `git reset --hard && git clean -fd` in the worktree and a
  fresh run.
- **Proof.** Each worktree then passes three checks, recorded in its PR: `docs-layout --check`
  (exit 0), `docs-layout --links origin/<default>` (exit 0), and the reproduction proof. That
  proof cuts a scratch worktree at `origin/<default>`, runs the script there, commits the same
  way, and requires `git diff <scratch-rewrite> <branch-rewrite>` to be empty.
- **PRs.** Each PR opens as a draft on `glw907/<repo>` with a `## Brief`, the counts, the three
  checks, `## Decisions`, and `## Planning misses`. The score goes in the packet and the last
  initiatives PR.
- **Rebuild.** A branch whose default moved after its gate is rebuilt, never merged: `git reset
  --hard origin/<default>`, rerun the script and its two commits, cherry-pick the hand-edit
  commit, rerun the gate and the three checks, then `git push --force-with-lease`. A cherry-pick
  conflict is resolved by reading both sides and goes in `## Decisions`.
- **Merges.** In the sweep, each PR fetches its default, rebuilds if it moved, then runs `gh pr
  ready <n>` and `gh pr merge <n> --merge --match-head-commit <head>`. The session then pulls the
  main checkout per `pass-core` "Close", or reports it stale.

## Tasks

Every task runs in sequence, one repo at a time, so there are no pairs.

### T1. The script, its test, and this plan (initiatives)

- Outcome: `repo-organization/tools/docs-layout`, stdlib Python like its neighbors, with one
  positional argument (the repo) and the modes `--dry-run`, `--finish`, `--check`, and `--links
  BASE`. It refuses a dirty tree, refuses a `docs/<name>` collision before any move, plans every
  change before it writes, writes through a temp file and a rename, and runs git with
  `GIT_OPTIONAL_LOCKS=0`. It skips symlinks, `.claude/worktrees/`, and `.superpowers/`.
  `--check` exits 1 while a tracked file sits in the old folder or a file outside the whole-file
  records holds an unpinned old-path line. `--links BASE` exits 1 for each relative link that
  resolved at BASE and no longer resolves. A second apply changes nothing.
- Files: `repo-organization/tools/docs-layout`,
  `repo-organization/tools/tests/docs-layout/docs-layout.test.sh`, the TSV, the reviews, the fold,
  and this plan.
- Risk: `ordinary`.
- Test: a fixture repo covering each rule in Findings 1 to 3. It has upward, sibling, anchored,
  titled, reference, and `href` links; a broken link; a link and a token into the old folder; a
  docs-relative mention; a code citation and a code glob; a `.superpowers/` mention; three pin
  shapes and an unpinned line in one file; a whole-file record; a `follow` file; a symlink; and a
  worktree file. It asserts the pure-rename commit, every rewrite, the hand line, `--check` and
  `--links` both ways, a recreated folder, a dirty-tree refusal, a collision refusal, and a no-op
  second apply.
- Acceptance: `bash scripts/gate.sh` green, and the dry-run table above reproduced.
- PR: initiatives, self-merged after its gate, since it moves and rewrites nothing.
- Estimate: 30 minutes (the script and test exist; this is the commit, the gate, and the PR).

### T2. cairn-themes, aksailingclub-legacy, phonebook

- Outcome: per "Execution rules"; no hand lines.
- Gates: cairn-themes and phonebook have none (their `CLAUDE.md` says so), so the three checks are
  the gate. aksailingclub-legacy runs its `test.yml` CI on the PR, watched with `gh pr checks <n>
  --watch --fail-fast`.
- Risk: `ordinary`. aksailingclub-legacy is `live-account`, since its merge redeploys the club
  site; the session watches that deploy run to green after the sweep.
- Estimate: 25 minutes for the three.

### T3. 907-life, ecxc-ski, poplar, dubplate

- Outcome: per "Execution rules". dubplate gets one hand edit: `.gitignore:60` ignores its
  personal-email note by basename at any depth
  (`**/2026-09-04-visual-collaborator-outreach.md`), so the note stays ignored wherever it sits.
  It isn't on pavilion.
- Gates: 907-life and ecxc-ski run `npm run check` after `npm ci` and `npx svelte-kit sync`, per
  `site-pass`. poplar and dubplate run `bash scripts/gate.sh`; poplar's CI runs on the PR.
- Risk: `ordinary`.
- Estimate: 50 minutes for the four.

### T4. xcathletes-org, aksailingclub-org, cairn-pub

- Outcome: per "Execution rules". cairn-pub's hand edit names the four directories in place of
  `docs/superpowers/` in the comment at `src/lib/docs/link-policy.ts:8`.
- Gates: `npm run check` per `site-pass`; aksailingclub-org also watches its PR CI.
- Risk: `ordinary` (Finding 4).
- Estimate: 35 minutes for the three.

### T5. workstation

- Outcome: per "Execution rules", plus the hand edits:
  - `scripts/check.sh`: the retired-names check gains a tracked-file arm that fails when `git
    ls-files docs/superpowers` prints anything, and `docs/[s]uperpowers` joins its content
    pattern, so the line can't match itself. Its pathspec excludes `docs/specs/`, `docs/plans/`,
    and `docs/research/` in place of `docs/superpowers/`, where the pinned records live, plus the
    three whole-file workstation records. This is the guard.
  - `bin/.local/bin/vale-hook` and `tests/test_vale_hook.py`: the skip moves from a `superpowers`
    path segment to a `docs` segment followed by `specs`, `plans`, `research`, or `archive`.
  - tellgrader's `internal/posthook/posthook.go` and its test: the same skip in Go, written after
    `go-conventions` loads.
  - The tellscan testdata `.tellgrader.json:4`: the session reads its test. The glob becomes
    `docs/{specs,plans,research,archive}/**` if the test mirrors the cairn-cms config, and the file
    gets a `record` row if the test only exercises exclusion.
- Proof of the guard: a scratch commit adds `docs/superpowers/plans/x.md` with no old-path text,
  and `bash scripts/gate.sh` must fail on the retired-names check; the commit is then dropped.
- Gate: `bash scripts/gate.sh`, `claude-tooling-sync verify`, and one `gitleaks git` scan, per
  `dotfiles-pass`.
- Risk: `runner`. The PR is an ask in the packet.
- Estimate: 60 minutes.

### T6. cairn-cms, built on today's `main`

- Outcome: per "Execution rules", plus the hand edits, each read before it changes:
  - `scripts/checks/check-idioms.mjs`: rule 4 bans `docs/(specs|plans|research|archive)/` paths in
    `src/lib`. A new rule fails when any tracked file sits in the old folder, with the old name
    built from parts so the script doesn't cite it; this is the guard. The messages at `:14`,
    `:179`, `:467`, and `:494` follow. `src/tests/unit/check-idioms.test.ts` (`:88`, `:254`) gains
    a case for each rule, and the fixture `superpowers-path.ts` is rewritten by the script.
  - `check-leaks.mjs:112`: the ban becomes `(?:\.\./|docs/)(?:internal|specs|plans|research|archive)/`,
    and `check-leaks.test.ts` gains a `docs/specs/` link in a public page.
  - `docs-links.mjs`: it skips `docs/specs`, `docs/plans`, `docs/research`, and `docs/archive` by
    top-level path, plus the two loose briefs (`docs/2026-07-07-fresh-session-brief.md`,
    `docs/2026-08-18-tui-skills-setup-brief.md`); its comment at `:6` follows.
  - `check-tellgrader.mjs`, `check-options.mjs`, `transcript-blocks.mjs:28`, `.vale.ini:49`, and
    `.tellgrader.json:4`: the same four directories and the two briefs; `check-options.test.ts`
    and `check-package-files.test.ts:137` follow.
- Proof of the guard: a scratch commit adds `docs/superpowers/plans/x.md`, and `node
  scripts/checks/check-idioms.mjs` must fail; the commit is then dropped.
- Gate: the cairn-pass fast lane (`node scripts/checks/gate-tier.mjs --fast --range
  origin/main..HEAD`), then CI on the draft PR, watched with `ci-green <sha> --pr <n> --wait`.
- Risk: `runner` (`scripts/checks/**`). The PR is an ask in the packet.
- Estimate: 85 minutes.

### T7. drafter, built on today's `main`

- Outcome: per "Execution rules"; the chain's `PRIOR_ART` and its comments name the new cairn-cms
  paths. No hand lines.
- Gate: `make check`; snapshots regenerate only on a red.
- Risk: `ordinary` (Finding 4). It rides in the packet as a routine row tied to cairn-cms, since it
  must merge right after it.
- Estimate: 15 minutes.

### T8. After B3c: cairn-cms and drafter rebuilt

- Outcome: the session sends `conductor-drafter` a hold note asking it to launch nothing into
  cairn-cms or drafter until the sweep ends. It rebuilds both branches on the new `main` per
  "Execution rules", reruns their gates and CI, and measures Finding 7. The measure is drafter's
  page-scope dry run on each page B3c drafted, read at the new `main` and at the rebuilt branch.
- Estimate: 35 minutes.

### T9. Close reviews and the packet

- Outcome: one whole-branch `diff-reviewer` read of workstation's hand-edit commit, one of
  cairn-cms's, and one dispatch that reads the small hand commits in cairn-pub and dubplate. A
  `fix` verdict is fixed forward and the gate reruns. Then one packet through `approval-packet`:
  two asks, workstation and cairn-cms, with Finding 7's measured scope and Finding 4's class rule
  stated as contestable. drafter and every self-merging PR are routine rows, merged in the sweep
  only if both asks are approved.
- Estimate: 30 minutes, plus Geoff's read.

### T10. The sweep

- Outcome: per "Merges", in order: cairn-cms, drafter, workstation, then the rest. Each main
  checkout is pulled or reported stale. Then tellgrader is installed from the merged workstation
  worktree (`make -C .../writing-voice/evals/tellgrader install`) and confirmed with one hook
  probe, and the aksailingclub-legacy deploy run is watched to green.
- Estimate: 40 minutes.

### T11. initiatives' citation rewrite

- Outcome: per "Execution rules", self-merged.
- Gate: `bash scripts/gate.sh`.
- Estimate: 20 minutes.

### T12. End-to-end check and hand-over

- Outcome: for every repo, in a fresh detached worktree of `origin/<default>`: `docs-layout
  --check` exits 0, `git grep -l 'docs/superpowers'` prints only TSV rows (old paths mapped to new),
  and `test ! -e docs/superpowers` succeeds. Both guard proofs rerun there. The gate reruns only
  where the default branch moved after the PR's gate. A repo that fails gets a follow-up PR by the
  same rules. Then the hand-over per `pass-core` "Close" and "Ledgers". STATUS lists every stale
  checkout and the pulls owed on thinkpad-x1, including its `make ... tellgrader install` and the
  dubplate note's new home, plus drafter BACKLOG's rename-aware `FactChanged` item.
- Estimate: 30 minutes.

## Path

30 + 25 + 50 + 35 + 60 + 85 + 15 + 35 + 30 + 40 + 20 + 30 = 455 minutes. The B3c wait and Geoff's
read sit outside it.

## Stops and their standing answers

- **A clock stop.** As `pass-core` says: STATUS, `notify-send -u normal`, and a wait for Geoff.
  The design records no overrun answer, so the plan grants none.
- **The path ceiling, 910 minutes (twice the plan).** The session finishes the task in flight,
  starts no new repo, and sends the packet with what is built; the packet names what's left.
- **A collision** (`docs/<name>` already holds files). The script refuses before any move. The
  session moves the colliding child to `docs/<name>-superpowers/`, records it in `## Decisions`,
  and goes on. None exists today.
- **A merged branch recreates the old folder** (the design's standing answer). The session reruns
  the script on that repo and opens a follow-up PR by the same rules.
- **A gate fails for a cause the move didn't make** (the design's standing answer). The PR stays
  open, and the packet names the cause; the session confirms it by running the gate on the base.
- **A hand line the plan didn't foresee.** The session reads the file. In a record (a command, a
  pathspec, or a log line), the line stays as written and the file gets a TSV row. A citation gets
  the new path. A pattern gets the four directory names, keeping its behavior, with a line in
  `## Decisions`.
- **Geoff holds cairn-cms or workstation.** Every PR holds with it, since the sweep merges all or
  none. The session acts on his note.
- **A loop guard.** Three gate reruns on one repo for one cause, then a structural fix, then the
  repo is escalated in the packet and the session goes on with the rest. Any repo but workstation
  and cairn-cms can be escalated. The packet lists it as unmet, and the design's outcome is then
  partly met.

## Later

Nothing.
