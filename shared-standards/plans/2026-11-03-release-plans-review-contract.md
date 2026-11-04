# Release plans A and B: contract and criteria review

Lens: contract and criteria (standards:spec-plan-review). Targets, under the initiatives worktree at ed6fd0c:
`plans/2026-11-03-release-gate-a-plan.md` (A), `plans/2026-11-03-release-process-b-plan.md` (B), against
`specs/2026-11-03-release-gate-and-process-design.md` (spec). Code read at cairn-cms `main` bb3c8d3a2.

Counts: 0 blocker, 12 major, 11 minor (2 of them `optional`). Two findings carry an OWNER FORK.

## Coverage map, in brief

Every pass A row (A1-A17) and pass B item maps to a task. The gaps are inside acceptance checks, not
missing tasks. Three spec promises live in no task at all. These are the rc.4 sequence's own checks, the
End-to-end "gate" and "promotion" bullets, and the CI-on-cut and Promotion standing answers (finding 7). Plan B also
adds escalation latitude that the standing answers do not give (finding 1). That makes it the only finding
that changes a ruled item.

## Findings, ranked by consequence

### 1. major, correctness: Plan B widens the standing answers' escalation list (OWNER FORK)

- Location: B:450-455.
- Defect: the spec's standing answers name exactly three escalatable items, all of them pass A items, and say "Anything past them stops"
  (spec:57,60). Plan B lets five spec items escalate: B7/B8, `verify`'s stable tarball comparison, `status`'s
  stable branch, `withdraw`'s promote-log parsing, and `launch-prompts.md`. `verify`'s comparison is the
  safety half of ruling 17 ("`verify` still compares the stable's tarballs with the final candidate's",
  spec:53). Escalating it leaves the ignore set without the guard that justified it. No later pass is
  planned to build it before the stable.
- Fold, OWNER FORK. (a) Keep all of them required, so a failure stops under Spend. (b) Allow escalation
  only for B7/B8 ("not reproduced" is the probe's natural outcome) and `launch-prompts.md`, and keep
  `verify`'s comparison, `status`'s stable branch, and `withdraw` required. (c) Accept plan B's list as
  written. Recommendation: (b). The three kept items are fake-tested pure functions at small cost, and
  ruling 17 leans on `verify`.

### 2. major, correctness: The stable-cut hook fails open, and "allow or no decision" lets its test pass vacuously

- Location: B:270-311.
- Defect: the hooks reference says "Exit code 1 without valid JSON output is a non-blocking error ...
  If your hook is meant to enforce a policy, use `exit 2`". It also documents `onFailure: "block"`
  (code.claude.com/docs/en/hooks, read 2026-11-03). An uncaught throw in the hook therefore lets a stable
  `gh release create` through. Causes include a JSON parse error, an ENOENT spawning the check from a
  subdirectory `cwd`, or a `sha:` line that does not parse. No acceptance case covers a crash. "A passing
  stable gets an allow or no decision" also accepts either outcome, and an explicit `allow` is a broader
  grant than the spec needs. The user rule already permits the command.
- Fold:
  - Set the entry's handler to `onFailure: "block"`.
  - Wrap the body so that any exception on a command holding `gh release create` emits a deny.
  - Add test cases for a missing stub check script (deny) and for garbage stdout from the check (deny).
  - Require "no decision" for a passing stable.
  - Add `"if": "Bash(gh release create *)"` to the handler, so the node process does not spawn on every
    Bash call. This settles the "runs on every Bash call" question: the spec says "on `Bash`" but does not
    forbid the documented `if` filter. Keep the in-hook substring check, since the docs call `if`
    best-effort.

### 3. major, correctness: `ci-green` and `build`'s ref check have no executable test, and their first run is under an immutable tag

- Location: B:179-187, B:209-227.
- Defect: the acceptance tests the YAML's shape only, through `needs`, permissions, and pins. Nothing executes the
  check-runs poll, its `e2e`-for-stable branch, its 45-minute bound, or `GITHUB_REF_NAME == v<version>`.
  `publish.yml` never runs on a pull request (B:462). The spec notes that a new tag runs "the `publish.yml`
  its own commit holds" (spec:227). Together, a defect in either step blocks `rc.4` from ever publishing
  from its release, through rerun or otherwise. It costs `rc.5` and a permanent version number.
- Fold: run each step's script body in `workflow-yaml.test.ts` under stubs, the way the promote stub-npm
  tests already do (`:270-323`). Cover a stubbed `gh api`/`curl` returning `test` in_progress, then success
  (pass); failure (fail); a stable missing `e2e` (fail); and a ref mismatch on one manifest (fail).

### 4. major, correctness: Under `--cli`, the pending-row write is not proven to stay off the release body

- Location: A:99-108 (T4), A:125-131 (T6).
- Defect: T4 adds an `--all` pre-write of four `pending` rows through the release-body path. T6's
  acceptance says "a leg's row lands in the record file, and an injected `gh` sees no call", which is
  scoped to a leg's row. A T6 that reroutes only `recordLeg` passes that test. The first rehearsal
  `--all` would then write four `pending` rows into `rc.3`'s public release body, the exact harm A15 exists to
  prevent (spec:135).
- Fold: T6 adds a `main(['--all','--cli',…,'--record-file',…])` test with injected deps. It asserts zero
  `gh` calls across the whole run, the pending pre-write included, and that the record file holds the four
  `pending` rows before A1 starts.

### 5. major, correctness: The trigger-uuid check passes vacuously when nothing is logged

- Location: A:139-148 (T7), A:219-223 (R1 step 5); spec:193,275.
- Defect: T7's outcome has each Builds leg log its trigger's build-token uuid, but no acceptance case
  tests that log. R1's check, "Every trigger uuid logged ... equals that entry's uuid", holds over an
  empty set. A swallowed `listBuildTriggers` error, or the wrong field name (which the spec leaves to the
  rehearsal to confirm), yields no lines and a passing check. The rc.4 End-to-end bullet inherits the same
  hole.
- Fold: T7 adds a test with a fake `listBuildTriggers` asserting one log line per Builds leg, with the uuid,
  and a visible failure line when the read fails. R1 step 5 and the rc.4 check require exactly one logged
  uuid for each of A2 and B1 in the deciding run, each equal to the entry's.

### 6. major, correctness: Nothing checks the sparse-checkout import contract between the two plans

- Location: A:115 (T5), A:100,126 (T4 and T6 extend `record.mjs`), B:223-225.
- Defect: pass B's `verdict` job sparse-checks out only `verdict.mjs` and `record.mjs` and runs no install.
  T5 states the contract, Node built-ins and `./record.mjs` only, but tests nothing. T4 and T6 both add
  code to `record.mjs`. B's test deliberately does not read those files. The first check is the `rc.4`
  promote dispatch, where an added import fails `verdict`.
- Fold: T5 adds a test that parses both files' import specifiers and allows only `node:*` and
  `./record.mjs`. The same test runs `node scripts/gate/verdict.mjs --file <fixture>` from a temp dir
  holding only those two files.

### 7. major, correctness: The rc.4 sequence, the End-to-end gate and promotion checks, and two standing answers live in no task

- Location: B:506-509 (the only hand-off), spec:256-276, spec:66-67.
- Defect: neither plan owns the rc.4 run. Plan B points at "the `rc.4` sequence" and nothing carries its
  acceptance. Step 8 goes from `verdict` straight to promote. These End-to-end gate checks appear in no
  step:
  - `driver.log` shows no deploy-token answer;
  - every trigger used the rehearsal's uuid;
  - exactly one `cairn-build` exists afterward.

  Step 7 reads the registrations with a sourced-secret `curl`, which is the form plan A's D4 built the
  smoke info line to avoid (A:309). Other gaps:
  - The "CI on the cut commit" and "Promotion"/P-ENV fallback standing answers have no home.
  - A group rerun during `rc.4` cannot pass `verdict` without `--file`, because all four rows need one
    `Run` id. Any `rc.4` rerun must therefore be `--all`, and nothing says so.
- Fold: add an "rc.4 run sheet" section to plan B's "After merge", or a short third plan the conductor
  launches. It maps each of steps 1-8 to its check:
  - step 7 reads through `run-gate.sh --smoke`'s info line, before and after;
  - the End-to-end gate bullet is checked after the gate run, with the uuid count per finding 5 and no
    `teardown left:` line per finding 8;
  - the rerun rule is `--all`;
  - the CI and Promotion standing answers apply, with the P-ENV record line.

### 8. major, correctness: A's teardown change after the rehearsal gets no live run (D5)

- Location: A:228-236 (R2), A:310 (D5), A:267 (S5); spec:274, spec:46, spec:61.
- Defect: R2 changes `scripts/gate/teardown.mjs`'s 7003 handling after R1's pass check. The End-to-end
  check requires the rehearsal to pass "against the code that merges", and ruling 10 singles out teardown
  as needing more than a dry run. The spec's rerun rule is written for product files only, but D5 uses that
  silence to exempt the one harness file the rulings protect. Teardown errors do not fail a leg (they print
  `teardown left:`, `gate.mjs:330`), so neither the `rc.4` verdict nor anything else would notice a leak.
  The account is the production account (ruling 16). Close-review harness fixes after R1 have the same gap.
- Fold options:
  - (a) Reorder. R2 lands after the first full `--all` that produced teardown logs, and R1's deciding pass
    check runs after it.
  - (b) Extend S5 to any change in `teardown.mjs`, `legs.mjs`'s `evaluateLeg`, or the prompt table after the
    deciding run. The first rerun group covers it.
  - (c) Keep D5, and make "no `teardown left:` line" an explicit rc.4 step-7 check, with
    `--teardown-stale` as the remedy.

  Recommendation: (a), since it costs no extra run. Use (c) as the floor in any case.

### 9. major, correctness: Plan B's pre-flight grant goes beyond the approved spec step 5 (OWNER FORK)

- Location: B:20-36; spec:110.
- Defect: the approved grant covers "pass B's worktree". The plan widens it to every
  `.claude/worktrees/agent-*` worktree and to a `~/.dotfiles` skill. Pass A's pair subagents run in
  `agent-*` worktrees at the same time, so pass A's pairs could also write `.claude/` files under a grant
  scoped for pass B. That is a self-modification grant on a security-relevant surface, and it was not
  approved.
- Fold, OWNER FORK. (a) Approve the wider grant as written. (b) Keep the grant at pass B's worktree plus the
  one dotfiles file. The pair subagents write `.claude/` content as patch files, and the executor applies
  them in the pass worktree, which is plan B's own refusal path made primary (B:438). (c) Run B5-B7 inline
  in the pass worktree, at about 135 more path minutes. Recommendation: (b). It keeps the pairs, holds the
  approved scope, and adds roughly 10 minutes.

### 10. major, correctness: `verify` does not specify which dist-tags a prerelease must show

- Location: B:239-243, B:257-262; spec step 6 (spec:265).
- Defect: rc.4 step 6 runs `verify 0.99.0-rc.4` right after `wait … gate`, before promotion. B4 says only
  "checks dist-tags", and no test fixes the expected tag for a prerelease. A `verify` that expects `next`
  fails at step 6 and blocks the P-PROV check, which is its job on rc.4.
- Fold: state the expected tag in B4. Take `--tag <t>`, defaulting to `gate` for a prerelease and `latest`
  for a stable. Add tests: prerelease on `gate` passes, prerelease with `gate` behind fails, and a stable
  checks `latest`.

### 11. major, correctness: P3's docs acceptance passes on deletion alone

- Location: A:195.
- Defect: every check is a negative grep, or a gate that passes on less text. `docs-fact-checker` reads
  changed lines and cannot see an omission. The spec's promised content can be missing and P3 still
  passes:
  - the `setup-recovery.md` row ("edit the token registered as `cairn-build`"), which is the only recovery
    path for "narrow token too narrow" on a real site;
  - the `build-token-missing` refusal row;
  - the DNS line;
  - the README's new two-token text.
- Fold: add positive greps. `setup-recovery.md` names `cairn-build` and `build-token-missing`.
  `own-your-domain.md` or `create-your-site.md` names `Paste your Workers Builds deploy token` and the
  30-minute resolver line. `MIGRATION-NOTES.md` holds the re-point steps.

### 12. major, correctness: The spec's A3 rule "Never log a URL carrying `code=`" is untested on an auth-data path

- Location: A:57-64 (T1); spec:128.
- Defect: T1 tests that no PNG is written on `code=` and that `controls.txt` holds host and path only, but
  nothing checks the log stream. The OAuth `code` sits in the loopback redirect T1 now follows.
- Fold: the T1 loopback test captures the session's log output and asserts that no line contains `code=`.

### 13. minor, correctness: `--headed` plumbing is untested

- Location: A:64.
- Defect: T1 tests only `launchBrowser`'s default. Standing answer S11, which is the rehearsal's and
  `rc.4`'s fallback, depends on `run-gate.sh --headed` reaching `makeSession`.
- Fold: add a `gate-env` test that `--headed` passes through, and a `makeSession` test that
  `{ headed: true }` launches headed.

### 14. minor, correctness: Authorize's consent branch is untested

- Location: A:61.
- Defect: only the 302 auto-approve path has a test. "Clicks only when GitHub shows consent" has none.
- Fold: add one fixture with a consent page, then the loopback; the leg passes and the button is clicked
  once.

### 15. minor, correctness: B6's greps miscount, and B6 cannot check pass A's flags

- Location: B:349-361.
- Defect: `grep -c` counts lines, not the seven names. "Every command and flag the skill names exists in
  B2 or B4" cannot verify `--headed`, `--cli`, `--record-file`, the lock, or `verdict.mjs`. Those are pass
  A's, and they are absent from pass B's tree.
- Fold: grep each script name in a loop. Add a post-merge conductor check in the finding 7 run sheet that
  greps each pass A flag the skill names against merged `main`.

### 16. minor, correctness: `verify`'s real-tarball case skips the fetch and diff code

- Location: B:257-259.
- Defect: the `rc2-rc3.json` fixture is already the diff output, so the tarball fetch, extract, and
  per-file diff code never runs against the real `rc.2`/`rc.3` tarballs the spec names (spec:215).
- Fold: add one test, behind the heavy lane or a network flag, that runs the full path on the two packed
  tarballs. Alternatively, commit the two smallest packages' tarballs as fixtures.

### 17. minor, correctness: The hook's flag forms are untested

- Location: B:298-305.
- Defect: `gh release create` takes `-p` as the short form of `--prerelease`, `--target=<sha>`, and
  `--prerelease=false`. As written, an rc with `-p` is denied (false positive), and `--prerelease=false`
  on an rc reads as a prerelease (false negative).
- Fold: add the three cases to the hook tests.

### 18. minor, correctness: The hook resolves the check script against a raw `cwd`

- Location: B:278.
- Defect: a session whose `cwd` is a subdirectory gets ENOENT. With finding 2's fold that becomes a deny,
  but a confusing one.
- Fold: run `git -C <cwd> rev-parse --show-toplevel` and run the check from there. Add one test.

### 19. minor, correctness: `preflight` compares against a possibly stale `origin/main`

- Location: B:126-128.
- Defect: without a fetch, `HEAD == origin/main` can pass on a stale ref.
- Fold: `git fetch origin main` first, or compare with `git ls-remote origin refs/heads/main`. The test
  fakes that call.

### 20. minor, correctness: B2's real-tree bump check depends on merge order

- Location: B:162-164.
- Defect: if pass A merges first and pass B rebases, `## Unreleased` sits over `## 0.99.0-rc.3`, and
  `bump` correctly refuses. The check then cannot produce its eight-file listing.
- Fold: run the check on a scratch commit that drops `## Unreleased`, or state that it runs on B's
  launch-time base only.

### 21. minor, optional: `// WATCH:` at the hop has no check

- Location: A:154.
- Defect: ruling 16 requires the `// WATCH:` at the hop, and no acceptance check looks for it.
- Fold: grep for `WATCH:` at the hop with both notes.

### 22. minor, optional: Over-ceremony

- Location: A:217, A:125-128 (D3), A:224.
- Defect: R1 arms four wake signals: the background exit notification, a Monitor until-loop, the new
  `exit` file, and `/loop`. D3 adds `run-gate.sh` surface for the backstop alone. "Run dirs are listed in
  the PR body" is a record, not a pass criterion.
- Fold: keep the notification and `/loop`, which the guard doc requires. The Monitor can poll the lock
  (`flock -n` succeeds once the run ends) with no new file. Move the run-dir listing to Close step 8.

### 23. minor, correctness: R1's pass check does not look at teardown

- Location: A:219-224.
- Defect: no teardown condition is part of R1's pass check.
- Fold: add "the deciding runs print no `teardown left:` line". This pairs with finding 8.

## The plans' own calls, checked against the rulings

- **A: a teardown change triggers no rerun (D5).** It contradicts ruling 10's protection of teardown and the
  End-to-end clause "against the code that merges". See finding 8.
- **A: P-SOA moved to pre-flight (PF3, D1).** This does not contradict a ruling. Ruling 11 makes the
  change conditional on Cloudflare allowing it, and the spec's Risks row already accepts that A11's live
  path may go unexercised. PF3 records the before and after values. No finding.
- **B: `withdraw` prints only.** This is consistent with the spec's conditional (spec:216). The quoted
  npm page was re-read on 2026-11-03: "OIDC authentication supports `npm publish`, `npm stage publish`, and
  the dist-tag operations described above", with no mention of `deprecate`. Ruling 8 holds. No finding.
- **B: the hook runs on every Bash call.** The spec says "on `Bash`". The documented `if` handler field
  removes the per-call node spawn at no contract cost. It is folded into finding 2.
- **B: the widened grant.** This changes an approved pre-flight item. See finding 9, an OWNER FORK.
- **B: the extra escalatable items.** These change the standing answers. See finding 1, an OWNER FORK.
