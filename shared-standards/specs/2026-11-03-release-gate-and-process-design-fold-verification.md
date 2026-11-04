# Fold verification: release gate and process design

Target: `2026-11-03-release-gate-and-process-design.md` at initiatives `8be2d22`, against the fold
record and the three reviews beside it. Code: cairn-cms `main` at `bb3c8d3a2`. Rulings 1-14 from
`scratchpad/walk/decisions.md`, 15-17 from the spec's Brief. Read-only; no live call was made.

## Verdict

Every blocker (C1, M1, I1) and every major closed at its cited location; the fold record's
dispositions match the revision. The fold's probes hold where rerun or re-read (below). There are
no owner forks. The fold did introduce four defects that can stop the run or falsify a stated
check. Two are in the new rehearsal (findings 1 and 2), and two are in the new `rc.4` command
lines (findings 3 and 4). None needs a new design, each folds in a sentence or two, and none is a
blocker. The passes stay file-disjoint, and `--cli` builds from pass A's worktree against the
`rc.3` engine.

## Probes rerun or re-read

- **npx with a rebuilt tarball (new).** I packed a bin package, ran `npx --yes file:<abs tgz>`,
  repacked it at the same path with changed content, and ran again. It printed `v1` and then `v2`
  (npm 11.20.0). After a fix, a rehearsal rerun picks up the rebuilt tarball, and npx's cache does
  not serve the old build.
- **`--cli` buildability.** `git diff --stat 4644cd35b..bb3c8d3a2 -- packages/create-cairn-site
  src/lib examples/showcase skills claude package.json` is empty, so the bake inputs at main are
  `rc.3`'s. `bake-template.mjs` takes `--engine-spec`/`--dev-spec` (`:363-373`), and
  `assertInstallableSpec` refuses only `file:` and `0.0.0` (`:268-285`). It imports only built-ins
  plus `emit-template.mjs`, which runs the root `node_modules/.bin/wrangler types`
  (`emit-template.mjs:162,180`), so the worktree needs its root install, which pass setup provides.
  `template/` is gitignored.
- **Hooks page.** The `cwd` and `${CLAUDE_PROJECT_DIR}` quotes and the deny shape are verbatim on
  <https://code.claude.com/docs/en/hooks>. The page says the hook receives the command as written.
  It does not expand `$VAR`.
- **`secret-receive`.** `:26` hard-sets `LOCAL_SECRETS`, and `--values`/`--local` are at `:56-59`.
  The flag form is right.
- **A10's six-key claim.** The setup tool's wrangler calls run on ambient credentials
  (`deploy.mjs:103-110,155,199`, `exec.mjs` `accountEnv` sets only the account id). No `/d1` or
  `/r2/` route appears outside tests. The claim holds.
- **Citations spot-checked and holding:** `legs.mjs:96-101,357,382`, `record.mjs:5-8,88-106,142-153`,
  `gate.mjs:245-253,394,426-427`, `run-gate.sh:26,44`, `chapter3.mjs:94,97,911,950,1369-1389`,
  `api.mjs:583,609-624`, `prefill.mjs:44-57,102-110`, `hostname.mjs:147-212`, `dns.mjs:145`,
  `check-stable-source.mjs:43-67,117,158`, `publish.yml:25-31,209-210,225-254`, `test.yml` job `test`.
- **Live registry read** (`npm view dist-tags`, read only). `next` is `0.99.0-rc.2` on all three
  packages, and `create-cairn-site@latest` is `0.99.0-rc.1`.

## Findings, ranked by consequence

### 1. The rehearsal writes four `pass` rows into `rc.3`'s public release body (major, correctness)

**Location.** A14 step 3; A17's last test ("The rehearsal's real `rc.3` body must exit 1 too");
`legs.mjs:468` → `record.mjs:142-153` (`recordLeg` edits release `v<version>`).

**Defect.** Under `--cli`, `--version 0.99.0-rc.3` still names the release whose body takes the
rows (A15 says so). A passing rehearsal therefore writes four `pass` rows with one `Run` id into
`v0.99.0-rc.3`'s public body. That claims `rc.3` passed its gate, when the setup tool that passed
was pass A's tarball. `verdict.mjs 0.99.0-rc.3` then exits 0, which contradicts A17's named test,
and `status.mjs` reports `rc.3` as gated.

**Fold.** Under `--cli`, record to a local file in the run dir, such as `gate-table.md` rendered by
`renderGateSection`, and never edit a release. `verdict.mjs` takes `--file <path>` for the
rehearsal's check. A17's "real `rc.3` body" fixture is the body as captured before the rehearsal.
Alternative: prefix the `Run` cell with `cli:`, and have `verdict` refuse such rows. The local
record is simpler and keeps the public record true.

### 2. The rehearsal's assertions break on any rerun, and a post-rehearsal product fix is unproven (major, correctness)

**Location.** A14 steps 2 and 5; standing answer "The rehearsal" ("rerun the affected group");
End-to-end check, "The rehearsal"; Estimate (pass A's tail puts Close and fix rounds after A14).

**Defect.**
- **The prompt count.** A rerun after a failed first attempt meets the `cairn-build` registration
  that attempt made. It reuses that registration with no prompt, so step 5's check fails on a
  correct product: `driver.log` shows `answered "Paste your Workers Builds deploy token"` "exactly
  once across the run". Only a fix to the collect path triggers the uuid delete, under the
  standing answer.
- **The four rows.** A group rerun goes through `--leg A1 --leg A2` (`gate.mjs:394`), not `--all`.
  Under A5 it writes its own `Run` id beside the earlier group's rows, so "four legs pass" comes
  from two runs. The spec does not say whether that counts.
- **Fixes after the rehearsal.** The close review and the 70 fix-round minutes come after A14. A
  close-review fix to `chapter3.mjs`, `prefill.mjs`, or `hostname.mjs` then merges a product the
  rehearsal never ran, which defeats ruling 15.

**Fold.**
- Count the prompt answer across every `driver.log` of the rehearsal's runs: exactly one in total,
  plus exactly one `cairn-build` entry.
- State that the rehearsal passes when each leg's latest row is `pass`, and a group rerun is
  allowed. Only `rc.4` needs one run id.
- Add a rule: a change to pass A's product files after the rehearsal reruns the group that reaches
  the changed code. Group A reaches the A11 and email paths, and the group whose Builds leg runs
  first reaches A10. A10's collect path needs the uuid delete first. Budget it inside the 70
  fix-round minutes.

### 3. `$SHA` does not survive between the conductor's Bash calls, and the hook sees it unexpanded (major, correctness)

**Location.** `rc.4` steps 3-5 ("Set `SHA=$(git rev-parse HEAD)`", then `--commit "$SHA"`,
`--target "$SHA"`); Hook (stable: "`--target` equals its `sha:` line").

**Defect.** The conductor is a Claude Code session, and its Bash tool keeps no shell variables
between calls. In step 4, `--commit ""` watches no run, or the wrong one. In step 5,
`--target ""` makes the tag fall back to the default branch head. That reopens I4, the tag landing
on a commit other than the cut. The hook also receives the command text unexpanded (hooks page).
So a stable cut written the same way, `--target "$SHA"`, is always denied, and `cairn-releasing`
cannot teach it.

**Fold.** Step 3 prints the sha, and steps 4 and 5 paste it as a literal. Or step 3 writes it to
`.git/cairn-cut-sha` and every later command reads it inside the same call. `cairn-releasing`
states that a stable's `--target` must be the literal sha from `check-stable-source`'s `sha:`
line, which the hook can compare.

### 4. The run-id lookups in steps 6 and 8 can watch an older run (major, correctness)

**Location.** `rc.4` step 6 (`gh run list --workflow publish.yml --event release --limit 1`) and
step 8 (`--event workflow_dispatch --limit 1`).

**Defect.** Right after `gh release create` or `gh workflow run`, the new run may not be listed
yet. `--limit 1` then returns the previous release run or dispatch, such as `rc.3`'s or the
pre-flight step 4 dispatch. `gh run watch --exit-status` on a finished green run returns at once.
Then `wait.mjs` times out after 10 minutes while the real publish is still in `ci-green` or
`build`. No standing answer covers that timeout, so the run stops. Step 4 alone says "listing
again until the run appears".

**Fold.** Step 6 lists with `--commit <sha> --event release` and polls until a run for that sha
appears. Step 8 records the newest dispatch id before dispatching, then polls until a newer id
appears whose `headBranch` is `v0.99.0-rc.4`. Alternatively, `wait.mjs` takes the run id and fails
fast when that run fails.

### 5. Pre-flight step 4's old-copy check is always skipped on today's tags (minor, correctness)

**Location.** Your steps 4; `publish.yml` bullet ("P-ENV, tested at pre-flight step 4"); Risks,
P-ENV.

**Defect.** Today `next` is `0.99.0-rc.2` on all three packages and `create-cairn-site@latest` is
`0.99.0-rc.1`. The tags differ, so the check skips, and P-ENV goes untested until the `rc.4`
promotion. The spec reads as if pre-flight settles it. The npm-sitting deprecation text also tells
users to "Install `$p@next`", and `next` is the deprecated `rc.2` until `rc.4` is promoted. The
spec discloses that warning, but the message still points at a deprecated version.

**Fold.** Say plainly that the check is expected to skip, and that the `rc.4` promote, with its
standing answer, is P-ENV's test. Remove "tested at pre-flight step 4". Optionally word the
deprecation as "Install `$p@next` once 0.99.0-rc.4 is out".

### 6. The temporary token is not named, and step 3 deletes it by that name (minor, correctness)

**Location.** Your steps 2, first bullet; Your steps 3 ("Delete the PS token and
`tmp-token-setup` through the API").

**Defect.** Estate rule 6 names this token `tmp-token-setup`, but step 2 never tells you to rename
it, and the template's default name differs. So the step 3 delete finds nothing to delete by that
name. The TTL bounds the risk, so this step is not unsafe. Rule 6 also warns that a fresh token can
verify `active` yet answer `9109` on the token endpoints. Step 2's done-check, which only verifies
the token, cannot catch that. Step 3's done-check also confirms neither deletion.

**Fold.** In step 2, name the token `tmp-token-setup`, and make the done-check a `GET /user/tokens`
read as well as the verify. Add to step 3's done-check that the token list no longer holds the PS
token or `tmp-token-setup`, and that `/builds/tokens` holds no probe name. The changed minting step
is otherwise safe. `ci-cairn-build` is now made in the dashboard, and only the probe's throwaway
token needs the token-management token.

### 7. The production-critical `ci-cairn-build` has no Proton Pass record (minor, correctness)

**Location.** Your steps 2, second bullet; Your steps 3, inventory row.

**Defect.** The workstation rule says "Proton Pass is the authoritative record of every
credential". The spec stores the token only through `secret-receive`, which writes the age store,
and in the Builds registration. Yet this token is the one every real site's Builds deploys will
reuse.

**Fold.** Step 3 also records a Pass item for `ci-cairn-build` (`claude-pass`, value on stdin) and
checks it by name.

### 8. The rehearsal's `npm pack` leaves an untracked tarball in pass A's worktree (minor, optional)

**Location.** A14 step 1. `packages/create-cairn-site/.gitignore` ignores only `template/`.

**Fold.** `npm pack --ignore-scripts --pack-destination <scratch dir>`, and pass that absolute path
to `--cli`.

### 9. Where the hook's tests live is unstated (minor, correctness)

**Location.** Pass B Files ("`.claude/hooks/release-cut-guard.mjs` and its test").

**Defect.** Vitest globs only `src/tests/{unit,integration,component}`. A test placed beside the
hook would never run in CI.

**Fold.** Name it `src/tests/unit/release-cut-guard.test.ts`, which falls inside pass B's
`release-*.test.ts` pattern.

### 10. A harness-only fix after the final candidate must write no CHANGELOG line (minor, correctness)

**Location.** Checks, `check-stable-source.mjs` ignore set (ruling 17); `cairn-running-passes`
carve-out.

**Defect.** The ignore set lets a `scripts/gate/**` change through. But the CHANGELOG predicate
still fails any line in the stable's diff other than a heading, a size marker, or a `Released`
line. A carve-out fix that adds an `## Unreleased` line, as passes normally do, blocks the stable
again.

**Fold.** The carve-out text in `cairn-running-passes` and `cairn-releasing` says that a harness
fix after the final candidate adds no CHANGELOG line. Its record goes in the PR or commit body.

### 11. I2's product half was neither folded nor refused (minor, correctness)

**Location.** Fold record I2 ("Folded with M7"). The integrity review proposed that a Builds
permission failure name the token and the missing key.

**Defect.** The revision carries only the standing answer and A13's docs row. Nothing records the
CLI message as refused.

**Fold.** Add a refusal line to the fold record (for example, "the docs row covers it; the message
goes to Later"), or add the line to A10.

## Checks against the ask

- **Blockers and majors closed at the cited location:** yes, for all of C1-C11, M1-M15, and I1-I7.
  M8, M10, I3, and I6 are partial, and each refusal stands. M8's Worker-upload probe is covered by
  the rehearsal's Builds deploy, which runs before anything publishes. M10's decline override is
  moot under ruling 15. I3's `promote=0.*` is moot once publishing is release-only, and a pushed
  tag without a release publishes nothing. I6's pid skip is redundant under the `flock`.
- **Contradictions introduced:** findings 1 and 2.
- **Order:** the passes are file-disjoint. Pass B's `verdict` job and `status` call pass A's
  `verdict.mjs` only at `rc.4` time, and pass B's tests use a fake runner, so merge order does not
  matter. `--cli` builds from pass A's worktree as shown above.
- **New mechanisms quoted or probed:** yes, plus the npx-cache probe above. The single exception
  is the "Allow npm dist-tag" web checkbox. Only the reviewer asserts it, and `npm help trust`
  shows only that the CLI has no such option. The step's done-check reads the settings page, so a
  missing box surfaces at pre-flight.
- **Stops with standing answers:** findings 2 and 4 are stops that have none. Every other
  anticipated failure maps to an answer.
- **Pre-flight completeness:** it names every act that only you can do: npm login and 2FA, the
  dashboard tokens, the grant, and the `[you]` fallbacks. Each act has a done-check, with the gaps
  in findings 6 and 7. The changed token-minting step is safe.
