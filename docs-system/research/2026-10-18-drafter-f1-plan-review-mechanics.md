# F1 plan review: mechanics and feasibility

Reviewer: `plan-reviewer`, on `plans/2026-10-18-drafter-f1-setup-checks-plan.md` (uncommitted), code at
drafter `da3e1c7`, the change-read worktree at `ec95398`, and cairn `50dc211d9`. Probes in the
planning session's scratchpad (`rev/`). Saved by the planning session from the agent's reply. G1 is
settled as option (a): an unresolved bare `path` source is a warning.

Verdict: feasible, and the pairs touch disjoint files. Three majors to fold before launch.

## Findings

1. **Major, correctness: line-count parity with cairn** (plan:176, 227-231). `check-facts.mjs` counts
   lines as `readFileSync(...).split('\n')` (`validatePointer`, near :702), so a file ending in a newline
   gets an extra empty line, and 14 pointers in cairn's store cite it (`src/lib/github/repo.ts:194-304`,
   303 lines; `migrations/0003_preview.sql:1-24`, 23; `src/lib/public/PreviewBanner.svelte:...-127`,
   126). A natural Go count raises 14 errors `check:facts` doesn't. Fold: the line count is
   `len(strings.Split(content, "\n"))`, used for the clamp too, with a fixture row "cites the line after
   a trailing newline, passes". `f:6hmgmv` (13 lines, split count 14, cited 15) still fails.
2. **Major, correctness: the Vale preflight passes on a global config** (plan:143-154; F1.3 acceptance
   389-391). With `~/.config/vale/.vale.ini` present and no project `.vale.ini`, `vale ls-config` exits 0
   with `RootINI` empty and `SBaseStyles` `{}`. F1.3's in-package "no .vale.ini" rows fail on this
   machine unless HOME is isolated; the e2e row is safe (`e2e/e2e_test.go:71`). Fold: the preflight also
   fails unless `RootINI` equals `<root>/.vale.ini`; F1.3's unit tests `t.Setenv` HOME and
   XDG_CONFIG_HOME to temp dirs, as `cmd/drafter/check_test.go`'s `project()` does; Vale errors are on
   stderr, so quote stderr's first line.
3. **Major, correctness: after `init` and `vale sync`, `drafter read` and `drafter page` refuse the
   tree** (plan:263, 493). `requireClean` refuses untracked files (`internal/pipeline/start.go:87-89`),
   and `vale sync` leaves `.vale/styles/Google/` untracked. Fold into F1.4 (about 5 min): `init` writes
   `.vale/styles/.gitignore` holding `/Google/`; F1.6 asserts `git status --porcelain` is empty with
   the synthetic package in place. (Marked a possible owner fork; the planning session rules it a
   method call: (a), since the alternative leaves `init`'s own next step broken.)
4. **Minor: the basename fallback can't fire through `Fact.Sources`** (plan:168-176). `isSource` drops a
   slashless span that doesn't exist (`internal/plan/facts.go:325-329`); cairn has 30 such pointers.
   Fold: `verify.go` walks spans itself with `parseBody`'s depth rule.
5. **Minor: the merge-order fingerprint check uses the wrong signal** (plan:477-478). `open.count` counts
   ledger reservations (`internal/ledger/ledger.go:223`); a stopped run has `stopped` in `state.json`
   (`internal/run/state.go:28`). Fold: check `grep -l '"stopped"' ~/.local/state/drafter/runs/*/*/state.json`
   prints nothing.
6. **Minor: F1.1's files miss `cmd/drafter/read_test.go`** (plan:306-309), where change-read's
   `TestSummaryCountsDemotedAndAlreadyPresent` asserts exact summary text.
7. **Minor: `prices.date` can name rates it didn't date.** The key-by-key merge (`apply.go:105-111`)
   lets a layer set rates with no date; `allowedIn` also permits `drafter.local.toml` (`layer.go:23`).
   Fold: print `prices: <date> (<source of prices.date>)`, or refuse a non-stock layer that sets
   `prices.models` without `prices.date`; name both channels.
8. **Minor: a missing `drafter` on PATH surfaces after the draft is paid.** Fold: the preflight runs
   `exec.LookPath("drafter")` when `gate.command` starts with `drafter gate`.
9. **Minor: F1.6 step 2 can break its seed fact** (plan:437-438). Fold: append to `drafter.toml`.
10. **Minor: `init` and `gate` have no `--root`.** In-process tests run in `cmd/drafter`, so a missed
    `t.Chdir` writes into the repo. Fold: add `--root` as `check` has it (`cmd/drafter/check.go:37`).
11. **Minor: assertions pass without verification.** Fold: assert `facts store: N pointers checked`.
12. **Minor: unnamed states.** Vale exit 2 maps to gate exit 2; undecodable `ls-config` JSON exits 2;
    an unreadable cited file; a duplicated cited id under a gate's ids filter; `seed` on a non-blueprint
    path; `init` must `MkdirAll` first (`internal/atomicfile/atomicfile.go:15-16`), and "writes nothing"
    holds only for refusals.
13. **Minor: the anchor rule.** cairn tests substring containment (`window.includes(t)`). Fold: say so.
14. **Minor: citations moved by change-read**: `internal/pipeline/blueprint.go:172-173`, `:187-191`;
    `read.go:279-284` (`writeReadSummary` now near :333), `:359-397`; the `drafter read` paragraph of
    `docs/blueprint-format.md`. Fold: widen the find-by-name note.
15. **Optional: the README's Develop section** (`README.md:178-182`) should list Vale for `make check`.
16. **Optional: stale G1 text** (plan:18-37, 64, 334-335). Collapse to the ruling.
17. **Optional: helper collisions in package `main`.** Prefix helpers per task.
18. **Optional: estimates.** 290 is right (1.21x of 240, under 480); two inter-pair merges add a few
    minutes; consider higher effort for F1.2's dispatch.
19. **Optional: who sets `accepted`.** Name the channels `seed` trusts.

## Verified as stated

Stock seat values equal cairn's `drafter.toml`; the stock layer can't trip `checkAllowed`;
`pipeline.Summary` has no `MarshalJSON`; `gate.Env` inherits PATH; Google v0.7.1 (2026-08-04) returns
200; `--output=line` prints `p.md:3:10:Google.Bad:...` and exits 1; a missing package passes
`ls-config` and fails the lint with E201; a synthetic local style works offline under a clean HOME;
`init`'s shape passes today's `drafter check`; the TypeScript resolver resolves all 807 symbol
pointers with no anchor misses; seed and conversion share their entry's inputs (`install.go:90-109`);
no task touches `money.go` or `resume.go`; the pairs' file sets are disjoint; change-read overlaps are
only `page.go`, `read.go`, and `blueprint-format.md`, sequential after its merge.
