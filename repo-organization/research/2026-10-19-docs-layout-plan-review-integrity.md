# Docs layout plan review: data integrity and failure risk

Target: `repo-organization/plans/2026-10-19-docs-layout-plan.md` at `5982a17` (branch `docs-layout`),
against `repo-organization/specs/2026-10-19-docs-layout-design.md` and
`repo-organization/research/docs-layout-excluded.tsv`. Lens: crash mid-move, concurrent writers,
partial or corrupting rewrites, mis-resolved links, cross-repo ordering, hooks and checks that
change silently, stale checkouts. All probes were read-only (`git grep`, `git ls-files`, reading
scripts) over the main checkouts on `thinkpad-x1`.

Verdict: the plan can silently corrupt records and links in four ways the end-to-end check can't
see (findings 1, 2, 4, 5), and its workstation guard doesn't detect the failure it exists for
(finding 3). Each fold is cheap and goes in T1's script and test or in a task's bullets. One owner
fork (finding 7).

Confirmed safe, so not findings: no tracked symlink involves the path. No tracked file is
CRLF or non-UTF-8. No relative link escapes a repo root, so the worktree's extra depth can't
mis-resolve one. No two children collide with an existing `docs/<name>`. cairn-cms's npm `files`
list is explicit, so history can't reach the tarball. Neither migration runner checksums file
content: asc applies with `wrangler d1 execute --file`, xc applies with
`wrangler d1 migrations apply`, and `_test-db.ts` reads the SQL. No site build globs the repo's
`docs/`. The 250 excluded files under the old folder carry no relative links, so skipping their
content breaks no link.

## Findings, ranked by consequence

### 1. The pin detector misses about 42 pinned records, which the rewrite then corrupts silently

- Severity: blocker. Tag: `correctness`.
- Location: plan:84-89 (the detector); design:34 ("any file whose old path sits beside a commit
  pin").
- Defect: the detector matches a 40-hex id, or a 7-to-12-hex id directly after `at`, `pin`,
  `pinned`, `commit`, or `revision ... at`. A scan of every old-path line outside the TSV that
  carries a hex token with a digit and a letter finds 64 lines in 43 files. Forty-two of them are
  real pins in shapes the detector misses:
  - `at HEAD 27b254ac` (cairn-cms `research/2026-10-03-sveltekit-3-plan-review-*.md`, five files)
  - `(main, 4365ac34)` (cairn-cms `research/2026-09-27-theme-pass-b-review-*.md`, four files)
  - `@ main (d565ab77)`, `@ 439f1b0`, `(committed 174ee8c8`, `` (`b74d3ae`, `` (cairn-cms
    `docs/internal/history/STATUS-archive-*`, initiatives
    `approval-queue/research/2026-10-11-review-desk-ui-review-mechanics.md:8`)
  - `at dotfiles 5a35388`, where a word sits between `at` and the id (workstation
    `docs/superpowers/research/2026-09-28-infra-*`, seven files)
  - `revision 2 (1d69ab8)`, `as of c58caf2`, `from add2517c`, `Base: 254d7860` (dubplate and
    cairn-cms fold records)
  - a replayable command at two pins, `git diff bd7525d d3ffc29 -- docs/superpowers/plans/`
    (workstation `research/2026-10-10-lean-pass-cutover-plan-final-verification.md:3`)

  The one remaining hit is drafter's placeholder id `0123456789abcdef…` in a fixture. The rewrite
  turns each missed record into a claim about a path that never existed at that commit. The
  end-to-end check (plan:252) only tests that the listed rows still cite the old path, so it can't
  see a record that should have been listed and wasn't. The TSV is also a snapshot: a review record
  written by any session between T1 and that repo's task isn't in it.
- Fold: in T1, run the pin detector live at apply time and union its hits with the TSV, which
  becomes the hand-override list. Widen the detector to any line that holds the old path and a
  7-to-40-hex token with at least one digit and one letter, then print those hits for a one-pass
  read: 64 lines today, and the drafter fixture is the only one to drop. Add one fixture line per
  missed shape to T1's test. Regenerate the TSV from the widened detector before T1 merges.

### 2. A rerun can rewrite every excluded record that has already moved

- Severity: major. Tag: `correctness`.
- Location: plan:66-68, plan:144 ("A second apply changes nothing"), plan:246-251 (the packet
  rerun and the T8 rerun).
- Defect: the TSV keys each row on its old path. Only the end-to-end check is said to map old to
  new (plan:68). After the first apply, each of the 250 excluded files under the old folder sits at
  `docs/<child>/…`. If the script looks exclusions up by old path only, the packet-time rerun and
  the T8 rerun rewrite every pinned record they were meant to keep. T1's test asserts a no-op
  second run, but the plan doesn't say the fixture's excluded file sits under the old folder, so
  the test may never exercise this.
- Fold: the script matches each TSV row at its old path and at its mapped new path. In T1's
  fixture, the excluded file sits under `docs/superpowers/` and carries a pin, and the second-run
  assertion covers that file.

### 3. The workstation guard can't see the old folder come back

- Severity: major. Tag: `correctness`.
- Location: plan:195-197; design:14 and design:36; `~/.dotfiles/scripts/check.sh:43`.
- Defect: `check_no_old_names` is a content `git grep`. The plan adds `docs/[s]uperpowers` to its
  pattern and excludes `docs/specs/`, `docs/plans/`, and `docs/research/` wholesale. A file
  recreated at `docs/superpowers/plans/x.md` passes unless its own text cites the path. And a stale
  citation written into a new plan or spec, the most likely regression, is excluded. The cairn-cms
  guard is path-based (plan:215-216) and does catch recreation. The workstation guard doesn't.
- Fold: the workstation guard fails when `git ls-files docs/superpowers` prints anything. Its
  content arm excludes only the workstation rows of the TSV, at their new paths, rather than the
  three history directories.

### 4. A crash, or a link with an anchor, can leave upward links broken with every check green

- Severity: major. Tag: `correctness`.
- Location: plan:134-144 (apply order and `--check`), plan:116-119.
- Defect: apply runs `git mv` and then resolves each relative link "against the file's old
  location". Two silent paths:
  - **Crash.** If apply dies after the moves and before the rewrites, the rerun moves nothing.
    It resolves `../../internal/x.md` from the file's new location, finds no target, and leaves
    the link alone. Python's `open(…, 'w')` also truncates before writing, so a crash mid-write
    can leave a file half-written.
  - **Anchor or title.** cairn-cms has 108 upward links in the old folder, 18 with `#anchor`, and
    poplar has one more. If the existence check doesn't strip `#…`, a title, or angle brackets, the
    link stays unrewritten. It carries no `superpowers` token, so it isn't printed as a hand item
    either.

  `--check` looks only for old-path citations, so it passes in both cases. cairn-cms's
  `docs-links.mjs` skips the history directories, so CI doesn't catch them either.
- Fold: three parts, all in T1.
  - Apply refuses a dirty tree. The recovery for any failed apply is
    `git reset --hard && git clean -fd` in the disposable worktree, then a fresh run. The
    execution rules (plan:116) say so.
  - The script plans every move and rewrite before it changes anything, and writes each file as
    bytes through a temp file and a rename.
  - `--check` gains a resolution-preservation test: every relative link or reference definition
    that resolved at the base commit resolves at head, with the old-to-new map applied. T1's
    fixture adds an anchored link, a titled link, and a reference definition.

### 5. A partial run leaves cross-repo citations and the live skills pointing at a layout that doesn't exist

- Severity: major. Tag: `correctness`.
- Location: plan:94-103 (repo order), plan:244-250 (merge order), plan:268-269 (the ceiling stop),
  plan:284-286 (the loop guard).
- Defect: T2 to T5 rewrite every `docs/superpowers/` token unconditionally, including citations of
  another repo's files. aksailingclub-org's `site-visual.spec.ts` and `home-images.ts` cite
  cairn-cms assets, and the workstation skills cite cairn-cms paths. A probe counts 57 tokens in
  workstation and 122 in poplar that don't resolve inside their own repo. Some of these are foreign
  citations and some are deleted files. Self-merged repos ship those rewrites days before cairn-cms
  moves (it waits on B3c). If the ceiling stop or the loop guard leaves cairn-cms unmoved, or Geoff
  declines its PR, the rewrites stay wrong for good.

  The packet merges workstation first (plan:248). Once that merge is pulled, sessions follow the
  new skills and write `docs/plans/` in any repo that hasn't moved. In cairn-cms, with its check
  scripts still skipping only `superpowers`, each new plan then falls under the published-docs
  checks and fails CI. That's the failure Finding 4 of the plan (plan:43-46) exists to prevent.
- Fold: T2 to T7 rewrite a bare old-path token only when its target exists in the same repo's old
  folder. A token that resolves elsewhere is printed as `foreign <file>:<line>` and deferred to the
  T8 rerun, which runs after every move has merged, as initiatives already is. Add one standing
  answer: workstation merges only in the same decision as cairn-cms, and if cairn-cms is held,
  workstation is held with it.

### 6. Concurrent sessions: the B3c wait ignores `conductor-drafter`, self-merges never recheck main, and the T8 rerun has no stated tree

- Severity: major. Tag: `correctness`.
- Location: plan:105-109, plan:123-124, plan:249-251.
- Defect:
  - **The wait.** It clears when `drafter-b3c-pilot` is idle, but `conductor-drafter` is the
    session that dispatches the next drafter or cairn-cms pass. If it branches from pre-move
    `main` while T6 runs, its branch conflicts with the 620-file rewrite or recreates the folder.
    cairn-cms holds three more worktrees today (`blueprint-pilot`, `drafter-require-prompts`,
    `repo-organization`).
  - **Self-merges.** `gh pr merge --merge` runs with no fetch and no `--match-head-commit`. A file
    another session added under the old path on `main` after the worktree was cut merges in
    cleanly, recreates the folder, and isn't seen until T8.
  - **The T8 rerun** ("over every repo", plan:250) names no tree. Run on a main checkout, apply
    would mutate `~/.dotfiles` under `dotfiles-bf`, against the one-executor rule.
- Fold:
  - The wait also requires no live session holding a cairn-cms or drafter worktree with commits
    ahead of `main` (`claude agents --json`, `git worktree list`, `pgrep -f`). The session posts
    a hold note to the conductor's STATUS or initiative record before T6 starts.
  - Before each self-merge: `git fetch`. If `origin/<default>` moved, merge it, rerun the script
    and `--check`, then merge with `--match-head-commit`.
  - T8's rerun is `--check` over a fresh fetch, with apply only in a new worktree.

### 7. OWNER FORK: the fact-bullet rewrite puts B3c's pages back in drafter's draft scope

- Severity: major. Tag: `correctness`.
- Location: plan:211-233 (T6), with no mention of the facts store.
- Defect: `docs/internal/facts/extend.md` and `reference.md` hold 11 fact bullets whose text or
  `Source:` cites the old path (`f:2w1yrc`, `f:swjwxb`, `f:6rao75`, `f:py57s1`, and others).
  drafter's `FactChanged` (`internal/blueprint/since.go:205`) reports a fact as changed when its
  text or its `Sources` differ. `pageScopeFor` (`cmd/drafter/draftscope.go:111`) compares facts at
  the lock entry's introducing commit with those at head. So after the move, every page that cites
  one of those facts stops being "up to date with drafted.lock", and the next `drafter page` run
  redrafts the citing sections. On `b3c-pilot-pages`, that's
  `add-a-second-sign-in-group`, `debug-your-site`, and `security-model`. Leaving the bullets alone
  doesn't work, since the facts check needs each `Source:` to resolve.
- Options:
  - (a) Accept: T6 runs `drafter page --dry-run` on the three pages before and after the move, and
    the packet states the extra scope and its estimated spend.
  - (b) A drafter change: `FactChanged` treats a `Source` that differs only by a recorded rename
    as unchanged. This is drafter `runner` code, outside the design's scope, so it would be an
    engine-style ask after this pass.
  - (c) Re-stamp the lock after the move. drafter has no command for it, and the file says "do not
    edit by hand".
- Recommendation: (a) for this pass, with (b) logged to drafter's backlog.

### 8. dubplate's personal-email note becomes trackable on a host where it exists

- Severity: major. Tag: `correctness`.
- Location: plan:171-172; `dubplate/.gitignore:60`.
- Defect: line 60 ignores `/docs/superpowers/research/2026-09-04-visual-collaborator-outreach.md`,
  which "holds personal email addresses and stays uncommitted (Geoff's ruling)". It isn't on this
  host, so it may live on `pavilion`. The script rewrites the line to `/docs/research/…`, but
  `git mv` moves only tracked files. On a host where the note exists, it stays at the old path and
  is no longer ignored. A later `git add docs/`, or the follow-up rerun, could commit it.
- Fold: the dubplate hand edit keeps the old ignore line beside the new one, and the hand-over
  tells Geoff to move the note on `pavilion` by hand. Treat any `.gitignore` path under the old
  folder this way.

### 9. Live hooks and the live chain switch over late, partly, or never

- Severity: major. Tag: `correctness`.
- Location: plan:58-60, plan:198-201, plan:235-242, plan:249-250.
- Defect:
  - **tellgrader.** `~/.local/bin/tellgrader` is a built binary (built 2026-10-13, not stowed),
    so merging `posthook.go` changes nothing live until `make -C …/tellgrader install` runs. The
    plan never runs it.
  - **vale-hook.** It's stowed, so it changes only when `~/.dotfiles` is pulled, and the plan
    won't pull that checkout while `dotfiles-bf` is live. Until then the old hooks skip only a
    `superpowers` segment, so every spec or plan write in an already-moved repo gets advisory Vale
    and tellgrader findings for days. That costs tokens but blocks nothing.
  - **The chain.** `~/.claude/workflows/docs-page-chain.js` is a symlink into drafter's main
    checkout, and its `PRIOR_ART` names a cairn-cms path. Between the cairn-cms merge and the
    drafter merge and pull, every chain run, including the ones `conductor-drafter` dispatches,
    tells its seats to quote a file that doesn't exist. That degrades the review seats silently
    rather than failing them.
  - **pavilion.** Its `~/.dotfiles` and checkouts keep the old skills until pulled, and no guard
    outside workstation and cairn-cms catches the folder coming back.
- Fold:
  - T8 merges cairn-cms and drafter back to back and pulls drafter's main checkout at once, with
    no chain run allowed between; the hold note from Finding 6 covers this.
  - After the workstation pull, run tellgrader's `make install` and confirm with one hook probe.
  - The hand-over lists `~/.dotfiles` (if stale) and every `pavilion` checkout as pulls Geoff
    owes.

### 10. cairn-pub's build comparison fails every time and costs about 20 minutes

- Severity: major. Tag: `optional`.
- Location: plan:53-57, plan:185-187, plan:281.
- Defect: `cairn-pub/svelte.config.js` sets no `kit.version.name`, so SvelteKit stamps each build
  with `Date.now()`. Two builds always differ under `diff -r`, so the standing answer "build output
  differs" fires every time and sends cairn-pub to the packet for nothing. Running
  check + test + build twice also costs about 20 of T4's 55 minutes, for a diff that touches only a
  `//` comment in one `.ts` file.
- Fold: replace the base and head build with a mechanical proof that every changed line in
  `src/**` is a comment: `git diff -U0` piped through a check for a `//`, `*`, or `/*` lead after
  the `+` or `-`. Then run cairn-pub's normal `npm run check`. That saves about 20 minutes and
  removes a spurious packet item.

### 11. Historical command records outside the TSV will be rewritten

- Severity: minor. Tag: `correctness`.
- Location: plan:278-280 (the unforeseen-hand-item standing answer).
- Defect: cairn-cms's `docs/internal/record/harvest/residue.txt:4-6` records the `git grep`
  commands the harvest ran, with `':!docs/superpowers'` pathspecs. `relink.json` and `README.md`
  in the same folder are harvest records too. Each pathspec prints as a hand item, and the standing
  answer says "a pattern gets the four directory names", which rewrites a record of what was run.
- Fold: add the three harvest files to the TSV as records. The standing answer adds: a hand item
  inside a record (a command, a pathspec, or a log line) stays as written.

### 12. One shipped page carries an unpinned `blob/main` URL into the old folder

- Severity: minor. Tag: `correctness`.
- Location: plan:91-92.
- Defect: `cairn-cms/docs/reference/public-css.md:120` links to
  `github.com/glw907/cairn-cms/blob/main/docs/superpowers/research/2026-09-29-theme-pass-c-ink-derivation.md`.
  `docs/reference` ships in the npm package, and cairn.pub renders docs from the installed version.
  Once cairn-cms merges, every published version's link 404s until a release ships the rewritten
  URL and cairn-pub upgrades to it. The plan's claim that "no URL needs keeping" covers only
  commit-pinned URLs.
- Fold: the hand edit rewrites this URL to a tag pin
  (`blob/v<current>/docs/superpowers/…`), which stays valid for every version. Or, if the 404
  window is acceptable, `## Decisions` records that.

### 13. One commit holding both the rename and the rewrite can lose rename detection

- Severity: minor. Tag: `correctness`.
- Location: plan:118-119 ("`git mv` keeps history").
- Defect: git infers renames from similarity of 50% or more. A small file with many citations,
  once renamed and rewritten in the same commit, can drop below that and show as a delete and an
  add, which breaks `git log --follow` and blame for that file.
- Fold: three commits per repo: the pure `git mv` (100% similarity), then the scripted rewrite,
  then the hand edits. It costs nothing, and reviewers then read the rewrite apart from the
  renames.

### 14. Two cairn-cms check edits are described as one shape, and one is a ban, not a skip

- Severity: minor. Tag: `correctness`.
- Location: plan:219-222.
- Defect: `check-leaks.mjs:112` doesn't skip a directory. It bans `(?:\.\./|docs/)(?:internal|superpowers)/`
  in public tiers. Edited as a "skipped directory set", a published page could cite `docs/specs/x.md`
  and the leak check would pass. Separately, `docs-links.mjs`'s `walkMarkdown` matches its skip set
  against basenames at every depth. Adding `specs`, `plans`, `research`, and `archive` there would
  later skip any nested published directory with one of those names. Nothing is affected today,
  but the widening is latent.
- Fold: T6 lists `check-leaks.mjs` separately, with the ban becoming
  `(?:internal|specs|plans|research|archive)/`. `docs-links.mjs` skips by top-level path
  (`docs/<name>`) rather than by basename. `check-leaks.test.ts` gains a case for a `docs/specs/`
  link in a public page.

### 15. The B3c wait has no exit for a closed, unmerged PR

- Severity: minor. Tag: `correctness`.
- Location: plan:105-109.
- Defect: if B3c's PR is closed without merging, or its branch is renamed, the until-loop never
  clears. The 30-minute fallback only re-wakes the same wait.
- Fold: the loop also clears on a closed PR with no live `drafter-b3c-pilot`. The session then
  rechecks the drafter and cairn-cms worktrees per Finding 6 and goes on.

### 16. Dry runs on live main checkouts can contend for `index.lock`

- Severity: minor. Tag: `optional`.
- Location: plan:154-155 (T1's acceptance runs `--dry-run` over each main checkout).
- Defect: `git status` and `git mv -n` refresh the index and take `index.lock` briefly. In
  `~/.dotfiles`, under `dotfiles-bf`, that can make one of that session's git commands fail with
  "index.lock exists".
- Fold: run T1's acceptance dry runs with `GIT_OPTIONAL_LOCKS=0`, or against a fresh
  `git worktree add --detach` of each default branch.

### 17. Task-scope `diff-reviewer` reads on comment-only `auth-data` diffs are over-ceremony

- Severity: minor. Tag: `optional`.
- Location: plan:36-42, plan:188-189, plan:231-232.
- Defect: for xc's migrations, asc's migrations and `src/admin-club/**`, and cairn-cms's
  `api.mjs`, the plan foresees comment-only edits. A model read of a mechanical path swap costs
  about 5 to 10 minutes and a subagent's tokens per PR, three times over, and proves less than a
  deterministic check does.
- Fold: replace each read with the comment-only proof from Finding 10 (SQL `--`, JS `//`, `*`,
  `/*`). Dispatch `diff-reviewer` only if a changed line in an `auth-data` path fails that proof.
  Whether the `auth-data` bar allows this substitution is a `site-pass` rule; if it doesn't, keep
  the reads and note the cost.
