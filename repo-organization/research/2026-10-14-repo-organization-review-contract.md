# Repo organization design: contract and criteria review

Target: `repo-organization/specs/2026-10-14-repo-organization-design.md` at `9da8e85`. Lens: is every promise testable, does every check name its fixture and failure reason, can any check pass vacuously, do the end-to-end checks cover the outcomes on the thinkpad, and does any "What changes" outcome lack a check.

Line numbers refer to the spec file. Facts were confirmed against the live tree on pavilion, as noted per finding.

Counts: 4 blocker, 9 major, 6 minor (19 findings, 2 of them OWNER FORK).

## Coverage of "What changes" (lines 11 to 16)

| Outcome | Check in the spec | Verdict |
|---|---|---|
| L11 initiatives repo and records | `scripts/check` in CI (L63, L89). No E2E step. | Partial, and it can pass vacuously (F5) |
| L12 every session prints its initiatives | E2E 2, `drafter` only (L181) | Partial (F3) |
| L13 ROADMAP retires, every entry dispositioned | none | **No check** (F6) |
| L14 docs move | E2E 1, reference checker (L136, L180) | Partial, blind to the new paths (F2) |
| L15 drafter and approval-queue move with history | E2E 3 and 4 (L182, L183) | E2E 4 is vacuous (F1). History has no check (F8) |
| L16 eleven deletions, one archive | none after the action | **No check** (F4) |

---

## Blocker

### F1. E2E 4 passes vacuously, because `claude-tooling-sync verify` never looks at workflows
- severity: blocker | tag: correctness | location: spec L150, L183
- Defect: the spec says the manifest records the new source "so `claude-tooling-sync verify` still tracks it", and E2E 4 gates on verify passing. `verify()` in `~/.dotfiles/bin/.local/bin/claude-tooling-sync` (lines 205 to 251) checks settings.json, MCP servers, vendored skills, plugins, and skill-name collisions. It has no workflow branch: the script contains no "workflow" string at all. A missing or dangling `docs-page-chain.js` link passes E2E 4.
- Fold: one of two options. (a) Add a task that extends `verify` with a workflows section (each manifest workflow resolves to a readable file whose realpath is under its recorded source repo). Give it a red fixture: a temp `--home` with the link removed must make verify exit 1. (b) Replace E2E 4 with a direct assertion: `test -f ~/.claude/workflows/docs-page-chain.js` and `realpath` lands under `~/Projects/drafter/`. Either way, the check must fail if the link is missing.

### F2. The reference checker cannot see the paths the migration creates
- severity: blocker | tag: correctness | location: spec L136, L180
- Defect: the checker "scans ... for `docs/superpowers/` paths". Cross-repo entries are rewritten to `initiatives/<id>/specs|plans|research/...` (L127), and those paths carry no `docs/superpowers/` segment. A rewrite that maps an entry to a wrong or missing initiatives path removes a checked reference and adds an unchecked one, so E2E 1 gets greener as the rewrite gets worse. The existing `scripts/check-claude-refs.py` also defers every `~/Projects` and bare repo-relative span to a "cross-repo mode" (its lines 24 and 198) that does not exist yet. Nothing current covers this either.
- Fold: the checker's pattern set is every old path plus every new path in `migration-map.tsv`: any span that matches `docs/superpowers/` or `initiatives/[^/]+/(specs|plans|research)/`. Add a criterion with its fixture: a planted ref to `initiatives/drafter/specs/nonexistent.md` must fail the post-run.

### F3. The SessionStart check can pass with the wrong repo name, and passes silently when the clone is missing
- severity: blocker | tag: correctness | location: spec L113, L181
- Defect: the spec doesn't say how the hook maps the session to a record's `repos` value. The workstation repo's cwd is `~/.dotfiles` (basename `.dotfiles`, no `glw907/.dotfiles` remote name), and the records list `workstation`. A cwd-basename implementation prints nothing in the repo most records name, and E2E 2 (drafter only) would still pass. A worktree session (`<repo>/.claude/worktrees/<name>`) has the same gap. On a thinkpad without the clone, a hook that finds no YAML prints nothing, which looks the same as "no initiatives". The spec names no fixture.
- Fold: state the mapping (the GitHub remote's repo name from `git remote get-url origin`, resolved from the worktree's main repo) and the missing-clone behavior (print a one-line warning, never silence). Criteria, as hook tests against a fixture initiatives tree: (a) cwd `~/.dotfiles` prints the `workstation` records; (b) a worktree path prints its parent repo's records; (c) `done` and `withdrawn` records are excluded; (d) an unlisted repo prints nothing; (e) a missing clone prints the warning. Add (a) to the thinkpad E2E.

### F4. Retirement has no post-condition check, and the inventory can find zero ties
- severity: blocker | tag: correctness (live-account) | location: spec L160 to L168, L178 to L183
- Defect: no check confirms the deletions and archive happened, or that no tied resource outlived its repo. The inventory's Cloudflare leg can pass vacuously: global CLAUDE.md says `$CLOUDFLARE_API_TOKEN` is sourced for interactive shells only, so an unsourced script, or a 403 from a read-only scope, returns an empty list. That empty list reads as "no ties", and then the pass deletes the repos whose Workers it never saw. The gh legs can come back empty the same way on an expired token.
- Fold: (1) The inventory script sources `~/.local/secrets` itself and exits nonzero on any API error or auth failure, never on an empty result. Give it a positive fixture: run it once against a repo known to have a tie (for example an active site repo with a Worker) and assert it reports at least one row before trusting the retirement run. (2) Add a post-check to the E2E on both machines: `gh repo view glw907/<r>` fails for each of the 11, `gh repo view glw907/aksailingclub-legacy --json isArchived` is true, no `~/Projects/<r>` directory remains, and a re-run of the inventory's Cloudflare leg finds nothing bound to a retired name.

## Major

### F5. `scripts/check` can pass on an empty repo
- severity: major | tag: correctness | location: spec L63, L89, L93 to L103
- Defect: "validates every record and the index" passes when the glob matches no `*/initiative.yaml`, and an empty index agrees with zero records. The spec gives no schema (required keys, `status` enum, `id` equal to its directory name, `repos` resolving to real GitHub repos or a stated non-repo token like "Google Docs" at L102) and no failing fixture.
- Fold: the check fails on zero records. Each rule gets a red fixture under `scripts/check`'s tests (bad status, id/dir mismatch, unknown repo, index drift). The E2E asserts the seven records at L97 to L103 exist with their stated status.

### F6. The ROADMAP retirement has no check, and "entry" is undefined
- severity: major | tag: correctness | location: spec L111, L13
- Defect: no criterion asserts that no `ROADMAP.md` remains, or that every entry got a disposition. "About 80 entries" doesn't hold up against the tree. Shapes differ by repo: `workstation` has 22 bullets, `aksailingclub-org` 19 `###` headings, and `cairn-cms` 284 bullets in 3,598 lines. A disposition parser that splits on the wrong unit covers a fraction of the file and still "applies every call".
- Fold: define an entry per repo shape (the parser's unit, stated in the plan) and write each repo's entry count into the triage item. Criteria: the dispositions applied equal that count, and `find ~/Projects -maxdepth 2 -name ROADMAP.md` (plus `~/.dotfiles`) returns nothing. Re-estimate the triage tasks from the cairn-cms size.

### F7. The migration map can classify zero entries, and its total is never checked
- severity: major | tag: correctness | location: spec L125, L132
- Defect: the spec gives the count (173, confirmed: 25 specs, 60 plans, 88 research), but no criterion ties the map to it. A classifier that skips research folders, or treats a folder as one entry where it holds many files, still writes a valid TSV. "Flags an entry the rule can't place" has no fixture either.
- Fold: criteria: map rows equal `ls docs/superpowers/{specs,plans,research} | wc -l` at the pass's start commit. Every row has a non-empty new path or an explicit `stays`/`leaves-with-pings`. After the deletions merge, the paths left under `docs/superpowers/` equal exactly the `stays` rows. Add a fixture entry the rule can't place, which must come out flagged.

### F8. "With their history" has no check
- severity: major | tag: correctness | location: spec L15, L148 to L150
- Defect: the spec promises that `git log` on a moved file reaches its first commit, but no step tests it. A plain copy into `drafter` passes every E2E step.
- Fold: criterion: for one file per move (`docs-page-chain.js`, the approval-queue app's `package.json`), `git log --follow --format=%H -- <path> | tail -1` in the new repo equals the same command's result in `workstation` at the pre-move commit.

### F9. The drafter install target would write into `workstation`'s tree
- severity: major | tag: correctness | location: spec L150
- Defect: `~/.claude/workflows` is a folded stow link (`~/.claude/workflows -> ../.dotfiles/claude/.claude/workflows`, confirmed). "An install target in drafter links it" into `~/.claude/workflows/` would therefore create an untracked symlink inside `~/.dotfiles/claude/.claude/workflows/`. That dirties `workstation` on both machines, and `stow -R` may refuse or unfold it. No check would catch this.
- Fold: decide the mechanism in the spec. Either workstation stows the directory unfolded (`--no-folding` for `claude`) so other repos can drop links beside it, or the drafter link is tracked in workstation as a relative symlink to `~/Projects/drafter/...`. Criterion: `git -C ~/.dotfiles status --porcelain` is empty after the drafter install on the thinkpad.

### F10. E2E 3 blocks on a human decision and names no fixture
- severity: major | tag: correctness | location: spec L152, L182
- Defect: `approval-queue design` waits for Geoff's decision and prints it as JSON (script header). It also refuses a source without a valid brief (`check_brief`, exit 2), and it resolves its app with `realpath $0/../../../approval-queue`, a layout the move breaks. The spec doesn't say which brief file the step uses, whether a human click is part of the check, or what failure looks like. As written, an unattended run can't complete step 3, and an exit 2 from a bad fixture could be read as a working install.
- Fold: name a committed fixture brief in the new repo. The check passes when the item appears at `http://127.0.0.1:7907` (poll the index for its id) and the command is then cancelled. Assert exit 0 from the brief check, and fail on exit 1. Add an explicit criterion that the app path resolves from the new install, not the old relative layout.

### F11. The thinkpad has no pre-migration baseline, and its auto-memory is never rewritten
- severity: major | tag: correctness | location: spec L136, L178, L180
- Defect: the auto-memory files are machine-local (`~/.claude/projects/*/memory`, not stowed; 5 files cite `docs/superpowers` on pavilion). The rewrite and the baseline run happen on pavilion. On the thinkpad, E2E 1 has no "pre-migration run" to diff against, and nothing rewrites its memory files. Either the thinkpad check fails on unrewritten memory, or it gets waved through without a baseline.
- Fold: the thinkpad cleanup script (L168) also runs the rewrite over the thinkpad's auto-memory. Its baseline is the pavilion baseline filtered to repo-tracked files, and machine-local files must come back with zero broken refs. State the thinkpad baseline's provenance in E2E 1.

### F12. Rewriting historical fixtures corrupts data, or the checker flags it
- severity: major | tag: correctness | location: spec L136
- Defect: "applies the map across every repo" reaches test data that records history, such as `tests/fixtures/ci-green/pr-107-files.txt` (a PR's file list) and the `docs-page-chain` JSON runs. Rewriting changes what those fixtures assert. Not rewriting them leaves them for the post-run checker to flag as "new" broken paths. The spec rules on HISTORY.md (L136) but not on this class. The goldens that "regenerate in workstation" mostly live under `tests/fixtures/docs-page-chain/`, which moves to `drafter` (L150), so the spec doesn't say which repo regenerates them, or in what order relative to the extract.
- Fold: add an exclusion list (fixture data recording past PRs or runs) that both the rewrite and the checker honor, with each file named. Order the rewrite after the drafter extract, so the goldens are regenerated and pass in `drafter`'s CI rather than `workstation`'s gate.

### F13. Most rule and tooling promises have no check
- severity: major | tag: correctness | location: spec L113, L115 to L121, L174
- Defect: none of these has a criterion: the CLAUDE.md "Initiatives" section, the `log-project` rewrite, the `pass-core` `Initiative: <id>` header line, the adapter pointers, `bootstrap.sh` cloning (no initiatives string in `bluefin/bootstrap.sh` today), `check-drift` warning when the clone is missing or behind, the memory fold and delete, and the GitHub descriptions being set.
- Fold: one line each in the plan's acceptance checks: `check-drift` warns with the clone moved aside (red fixture) and when it is one commit behind. `bootstrap.sh` in a temp HOME dry-run clones it. `gh repo view --json description` matches the dry-run text for each of the six repos. The memory file is gone and its facts appear in `initiatives/drafter/README.md`. A `log-project` dry run writes a valid record that `scripts/check` accepts.

## Minor

### F14. ROADMAP triage for repos about to be deleted or archived
- severity: minor | tag: optional (over-ceremony) | location: spec L111, L22, L160 to L162
- Defect: `healthy-diet` (17 lines) and `aksailingclub-legacy` (10 lines) carry ROADMAPs, and "one triage item per repo" sends each to Geoff although both repos go away. With 13 repos in all, that is 13 queue round trips. **OWNER FORK**: (a) one triage item per repo as approved; (b) drop the triage for retired repos, with their ROADMAPs read only for record-worthy entries in the inventory; (c) batch the small repos (under 50 lines) into one item. Recommendation: (b) plus (c). That saves about 9 queue round trips and the session time to draft them, and Geoff's per-repo call survives for the large repos.

### F15. The estimate ceiling has no breakdown to check it against
- severity: minor | tag: optional | location: spec L28
- Defect: 840 path minutes appears with no task chain and no score source, so the ceiling can't be audited until the plan exists. `pass-core` "Plan" requires the design estimate to come from recent scores. The spec cites the source section but not the scores.
- Fold: name the scores the estimate was set from in one line.

### F16. A plan held open by a live pass has no tracked follow-up
- severity: minor | tag: correctness | location: spec L144
- Defect: "a short follow-up then moves it" has no tracker. If the follow-up is lost, E2E 1 still passes, since the path still resolves at its old home.
- Fold: the migration map marks such rows `deferred:<pass>`, `scripts/check` or the reference checker reports a nonzero deferred count, and a BACKLOG item is filed in `workstation`.

### F17. Worktree removal names a criterion only by example
- severity: minor | tag: correctness | location: spec L172
- Defect: "merged" is undefined (merged into which branch, and squash merges do not show as merged in `git branch --merged`). With squash merges, a merged worktree can look unmerged, which is safe but sends extra items to the dry run. The other way, a check that compares against a stale local `main` can call an unmerged worktree merged.
- Fold: define merged as "the branch's PR is merged (per `gh pr list --state merged --head`) or its tip is an ancestor of `origin/main` after fetch". Require a fetch first.

### F18. The record status history is untested
- severity: minor | tag: optional | location: spec L81
- Defect: "A status change adds a dated line to the README" isn't enforced, so YAML status and README history can drift.
- Fold: `scripts/check` asserts the README's last dated status line equals the YAML `status`.

### F19. The thinkpad local cleanup script has no dry-run or check
- severity: minor | tag: correctness | location: spec L168
- Defect: the thinkpad script removes directories, but it isn't in the dry-run item. The global rule "show a dry run first" applies, and nothing confirms that the thinkpad's own clones were inventoried for unpushed work before removal (L166 inventories pavilion).
- Fold: the script runs the inventory's local legs (unpushed branches, stashes) on the thinkpad first and prints its dry run. It refuses a repo with unpushed work. The thinkpad E2E asserts the directories are gone.
