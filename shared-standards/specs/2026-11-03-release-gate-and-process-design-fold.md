# Fold record: release gate and process design

Target: `2026-11-03-release-gate-and-process-design.md` at initiatives `cafe981`, revised in place.
Code: cairn-cms `main` at `bb3c8d3a2`. Reviews: `-review-contract.md` (C), `-review-mechanics.md`
(M), and `-review-integrity.md` (I). Owner forks C3, C4, M9, and I7 were ruled in chat on
2026-11-03 as rulings 15-17, now in the Brief.

Totals: 75 findings. 53 folded, 4 of them in part with the rest refused. 22 dropped as `optional`.
No owner fork remains.

## Probes and quotes behind new mechanisms

- `npx` with a tarball (A15): local probe on npm 11.20.0. `npx --yes /abs/x.tgz` fails ("Permission denied": npx runs a bare path as a command). `npx --yes file:/abs/x.tgz --dir y` and `npx --yes --package /abs/x.tgz -- probe-bin --dir x` both ran the bin. So the contract review's "npx takes a tarball path" holds only in the `file:` or `--package` form.
- Exact pins for the rehearsal bake: `bake-template.mjs` takes `--engine-spec` and `--dev-spec` (`publish.yml:209`), and `assertInstallableSpec` refuses only `file:` and `0.0.0`. A semver probe gives `satisfies('0.99.0-rc.3', '^0.99.0-rc.3') === true` and `satisfies('0.99.0-rc.4', '^0.99.0-rc.3') === true`. The ruling's stated reason, "a caret does not resolve a prerelease", is not quite right: a caret on a prerelease resolves that prerelease and also floats to a later one. The spec keeps the exact pins and gives the float as the reason.
- A11 `lookup`: local probe on Node v26.13.0. A plain `cb(null, '127.0.0.1', 4)` failed with `ERR_INVALID_IP_ADDRESS`. Answering `opts.all` with an array served the request, and the Host header stayed the made-up hostname.
- Hook `cwd` and the deny shape: the hooks reference says `cwd` "is the worktree root after Claude enters a worktree" and "`${CLAUDE_PROJECT_DIR}` stays put". The deny is `hookSpecificOutput.permissionDecision: "deny"`.
- `npm trust`: `npm help trust` (11.20.0) gives the synopsis `npm trust github [package] --file [--repo] [--env] [--allow-publish] [--allow-stage-publish] [-y]` and says "the registry only supports one configuration per package".
- `secret-receive`: `~/.local/bin/secret-receive:26` sets `LOCAL_SECRETS="$HOME/.local/secrets"`. `--values` and `--local` are its flags (`:56-59`).
- Narrow prefill URL: `prefillUrl([...three keys])` from main's `prefill.mjs` printed a valid URL.
- The CI wait: `gh run list` has `--commit`, `--event`, `--workflow`, and `--json`, and `gh run watch` has `--exit-status`.
- Background gate runs: the Bash tool's `run_in_background` "keeps running across turns and re-invokes you when it exits". No Monitor is needed.
- Ruling 17's derivation: root `files` lists `dist`, not `src/lib`, and `bake-template.mjs` reads `examples/showcase` (excluding `e2e` per `.cairn-template.json`), `skills/`, and `claude/`. A literal reading of "derive from `files`" would ignore an engine source change. The spec therefore uses a fixed ignore set, and a test derives the shipped inputs (`files`, the `dist` sources, and the bake inputs) and fails on any overlap. This is a method call, so it is not a fork.

## Contract and criteria (C)

| # | Sev | Disposition | Where |
|---|---|---|---|
| C1 | blocker | Folded. E5 is now never "expected". A mail standing answer adds the out-of-harness mailbox query and Stalwart's DMARC verdict: no mail means an environment fix before `rc.4` (on ward, stop for Geoff), and a found message means a harness gap. | Standing answers; The rehearsal's rules |
| C2 | major | Folded, adapted to rulings 15-16. Reuse is by name only, and the token-id match goes. There is a pre-rehearsal "no `cairn-build`" read, triggers log their token uuid, a four-part assertion runs after the rehearsal, and the `rc.4` check expects exactly one registration and no prompt. | A10; A12; A14 steps 2, 5; rc.4 step 7; End-to-end check |
| C3 | major, fork | Folded as ruling 16. The prefill citation was corrected (`workers_scripts` at `prefill.mjs:44-50`). Geoff renders the three-key URL at pre-flight step 2 and makes `ci-cairn-build` from it. The inventory marks it production-critical, a WATCH notes the coverage loss, and fake-Cloudflare tests cover the prompt path. | Brief; Your steps 2-3; A10 |
| C4 | major, fork | Folded as rulings 15 and 17. The rehearsal runs pass A's product, and harness-only fixes after the final candidate no longer force an rc. Option (b)'s `--no-email` flag is unneeded, since a product or environment fix lands before the group reruns. | A14; A15; Checks |
| C5 | major | Folded. A11 gets an injected `dns.pinnedProbe` seam, and A10 and A11 get named tests. | A10; A11 |
| C6 | major | Folded. Named tests for A3, A5, A6, A7, and A8 privacy. The admin-editor fixture stays until a showcase spec replaces it, and loopback fixtures come from the tool's strings. | Pass A tests; A9 |
| C7 | major | Folded. The hook denies a non-literal tag and a stable without `--target`, gets stdin tests and a harmless live probe, and the spec names the channels it does not see. | Claude infra, Hook |
| C8 | major | Folded at the root with I5. The reader moves beside the writer as `scripts/gate/verdict.mjs` in pass A, using an exported `parseGateRows`, with the four extra refusal cases. This keeps one parser and keeps the passes' files disjoint. | A17; Pass A tests; `publish.yml` verdict |
| C9 | major | Folded with I15. Line 193 is corrected and made conditional on P-ENV, and pre-flight step 4 adds the old-copy dispatch check. | `publish.yml`; Your steps 4; P-ENV |
| C10 | major | Folded with I10. The hand fallback starts with `verdict.mjs`, and the end-to-end check names the run id. | Standing answers; End-to-end check |
| C11 | major | Folded at the root with M13. `verify` applies `check-stable-source`'s exported rules by file kind, including slugs and hashes. | Release scripts, `verify`; Checks |
| C12 | minor | Folded. `status` checks the verdict for a prerelease and `latest` for a stable. | Release scripts |
| C13 | minor | Folded. The test puts a stable on top and adds an rc row, and the claim was corrected. | Checks |
| C14 | minor | Folded. `bump` renames in place (rc.3 precedent) and gets a `checkStableSource` round-trip test. The manifest count is now three (M19's correction rides here). | Release scripts, `bump` |
| C15 | minor | Folded. Each anticipated failure names its distinguishing capture line, and E4 is gone. | The rehearsal's rules |
| C16 | minor | Folded: a Risks row and A10's source-scan test. | Risks; A10 |
| C17 | minor | Dropped (optional). P-SOA's note on A11 coverage rides the P-SOA row anyway. | none |
| C18 | minor | Dropped (optional). | none |
| C19 | minor | Folded. A record failure in the `finally` is caught and logged, and the leg's error stands. | A5 |
| C20 | minor | Dropped (optional). | none |

## Mechanics and feasibility (M)

| # | Sev | Disposition | Where |
|---|---|---|---|
| M1 | blocker | Folded. The flag form, a `grep -c` done-check, and the rule 6 text corrected in the workstation commit. | Your steps 2, 3 |
| M2 | major | Folded. A web step only, "tick" the dist-tag box, quoting `npm help trust`. | Your steps 1 |
| M3 | major | Folded at the root with I3. Publish jobs run only on `release: published`, and the bare-dispatch path and its test go (recovery is a rerun). The hook denies a non-literal tag and runs the check in the input's `cwd`. | `publish.yml`; Hook |
| M4 | major | Folded. A `lookup` that answers both forms, a local-server test, and an injectable seam. | A11 |
| M5 | major | Folded. A fixed 1-second comparison, and a second test with real progress that must not fail. | A6; Pass A tests |
| M6 | major | Folded. Wait for `test` green on the cut sha before the tag, plus a CI standing answer. | rc.4 step 4; Standing answers |
| M7 | major | Folded with I2 at pre-flight, rehearsal, and post-`rc.4` points. | Standing answers |
| M8 | major | In part. D1 and R2 write probes with the narrow token run at pre-flight and in the smoke. The Worker upload probe is refused: the rehearsal's Builds deploy uses the narrow token's Workers Scripts right before anything publishes. | Your steps 3; A12 |
| M9 | major, fork | Folded as ruling 15. Option (c) is superseded. | A14; A15 |
| M10 | major | In part. "Rerun the affected group" was folded. The decline-override standing answer is refused: under ruling 15, the F2 fix lands in pass A and the real group reruns. | Standing answers |
| M11 | major | Folded. | Pass B Files |
| M12 | major | Folded. `run_in_background`, with the quote, and the unattended guards. | A14; rc.4 sequence |
| M13 | major | Folded with C11. | Release scripts, `verify` |
| M14 | major | Folded. Geoff makes `ci-cairn-build` in the dashboard from the narrow prefill, and the probe script is a `[you]` item with token roles named. | Your steps 2, 3 |
| M15 | major | Folded. The grant covers the hook, the agent file, and the skills, with the denial evidence. | Your steps 5 |
| M16 | minor | Dropped (optional). | none |
| M17 | minor | Folded with C2. | A14; End-to-end check |
| M18 | minor | Dropped (optional). | none |
| M19 | minor | Dropped (optional). The count was corrected inside C14's rewrite. | none |
| M20 | minor | Folded. The standing answers state their rules with no `cairn-releasing` line citations. | Standing answers |
| M21 | minor | Folded. The `node scripts/release/` prefixes and the run-id lookups. | rc.4 sequence |
| M22 | minor | Dropped (optional). The `rc.4` gate figure still rose to 115, on M12's measured 60-110+ and A14's own figure. | Estimate |
| M23-M27 | minor | Dropped (optional). M27's concurrency concern is folded through I6. | none |
| M28 | minor | Folded. | A13 |
| M29 | minor | Folded as ruling 16. | Later |
| M30-M34 | minor | Dropped (optional). | none |

## Data integrity and failure risk (I)

| # | Sev | Disposition | Where |
|---|---|---|---|
| I1 | blocker | Folded as ruling 16. The CLI never deletes. A stale entry gets a new registration, with a dated fallback name if PS shows duplicates are refused. Reuse takes the newest live entry, the CLI prints a one-line warning, and an escalation ships as reuse. PS now tests duplicate names. | A10; PS; Standing answers |
| I2 | major | Folded with M7. Geoff edits `ci-cairn-build` at a set point, and `setup-recovery.md` gets a row for the too-narrow token. | Standing answers; A13 |
| I3 | major | In part, at the root with M3. Release-only publishing closes the dispatch bypass. Refused: narrowing the allow rule to `promote=0.*` (an empty `promote` now runs nothing) and a `git push` hook (a pushed tag without a release publishes nothing). | `publish.yml`; Allow rules |
| I4 | major | Folded. `build` checks the tag against all three manifests, and the release targets the literal `$SHA`. | `publish.yml`; rc.4 steps 3, 5 |
| I5 | major | Folded with C8. A `Run` column, a fresh `pending` section per `--all`, and the one-run-id rule. | A5; A17 |
| I6 | major | In part. The `flock` was folded. The pid-file skip in `teardownStale` is refused as redundant, since the lock already prevents a live run beside it. | A16 |
| I7 | major, fork | Folded as ruling 16. | Brief; Your steps 3; Later |
| I8 | minor | Folded. Per-run capture files and a `failed` marker that cleanup and `teardownStale` respect. | A4 |
| I9 | minor | Folded. `from` is 0 on a missing file, with a test. | A2; Pass A tests |
| I10 | minor | Folded with C10. | Standing answers |
| I11 | minor | Folded. `promote` prints the tags before moving, and `withdraw` prints the moves back. | `publish.yml`; `withdraw` |
| I12 | minor | Folded. The fold gets its own commit, and `bump` is in-memory, refuses a dirty tree, and is idempotent. | rc.4 step 2; `bump` |
| I13 | minor | Folded. A scrub step and a no-login test. | A9 |
| I14 | minor | Dropped (optional). | none |
| I15 | minor | Folded with C9. | `publish.yml` |
| I16 | minor | Folded with C2. The read moved to before the rehearsal, which is now the first live run. | A14 step 2 |
| I17 | minor | Dropped (optional). Also moot, since Geoff makes the token in the dashboard. | none |
| I18 | minor | Folded. | P-PROV; `wait`; `withdraw` |
| I19-I21 | minor | Dropped (optional). | none |

## Estimate

The path rose from 620 to 875 minutes in the review fold, then to 900 in the verification (see Verification):

- Pass A goes from 500 to 675. Lane 1 grows from 270 to 360 (A16, A17 moved in from pass B, A5's run table, A4 and A2 fixes, named tests, and the scrub). The tail adds 75 for `--cli` and 10 for the rehearsal's assertions.
- Pass B goes from 450 to 520. Lane 2 grows from 305 to 375 (release-only publishing, the tag check, the ignore set, and the hook's denials and tests).
- `rc.4` goes from 120 to 200: the CI wait, and the gate set to 115.

The path stays under the 1,240 ceiling. Ruling 13 says "twice the path, about 1,240". The spec keeps the approved 1,240 rather than doubling the new path to 1,750. That is the conservative reading, so no ruling is needed. Raising the ceiling would be Geoff's call.

## Verification

Source: `2026-11-03-release-gate-and-process-design-fold-verification.md` (V), read against the spec at `8be2d22`. Each finding was checked before folding.

Totals: 11 findings. 9 folded (one of them by removing the mechanism), 1 refused with its gap recorded in Later, 1 owed as optional. No owner fork.

Probes and quotes behind this round:
- The Bash tool keeps no shell state between calls: "Shell state (env vars, functions) does not persist" (the session's Bash tool description).
- `gh workflow run --help` (gh 2.103.3): "The created workflow run URL will be returned if available." `gh run list` has `--commit` and the JSON fields `databaseId` and `headBranch`.
- `claude-pass` passes stdin through, so `item create login --from-template -` keeps the value off the command line (`~/.local/bin/claude-pass` header). The estate inventory names `Workstation` as one of the agent's vaults (`cloudflare-estate-inventory.md:184-186`).
- V's own npx rebuild probe shows a rerun picks up a repacked tarball at the same path, so a fix reaches the next rehearsal run.

| # | Sev | Disposition | Where |
|---|---|---|---|
| V1 | major | Folded. Under `--cli`, rows merge into a local file named by `--record-file` and never into a release body. `verdict.mjs --file` reads it. A17's real-body test uses `rc.3`'s body as captured before the rehearsal. | A15; A17; A14 steps 3, 5 |
| V2 | major | Folded. The prompt answer is counted once across every rehearsal `driver.log`. The rehearsal record keeps each leg's latest row, and the one-run-id rule holds per group under `--file`; `rc.4` keeps one id for all four. A product change after the rehearsal passed reruns the group that reaches it before merge, out of the fix-round minutes. | Standing answers, "The rehearsal"; A14 step 5; A17; End-to-end check |
| V3 | major | Folded. No shell variable crosses steps: step 3 prints the sha, and later commands paste it. The hook denies a stable whose `--target` is not a literal 40-hex sha, with a test for `--target "$SHA"`. `cairn-releasing` carries the literal-sha rule. | rc.4 sequence; Hook; `cairn-releasing` |
| V4 | major | Folded. Step 6 lists by `--commit <sha> --event release` until a run appears. Step 8 takes the id from the URL `gh workflow run` prints, falling back to a larger id with `headBranch` `v0.99.0-rc.4`. | rc.4 steps 4, 6, 8 |
| V5 | minor | Folded by removal. The old-copy check always skips while `next` and `create-cairn-site@latest` differ, so it is gone from step 4 and the standing answers. The P-ENV row states what stays untested and the residual. The deprecation message now reads "once 0.99.0-rc.4 is out". | Your steps 1, 4; `publish.yml`; P-ENV |
| V6 | minor | Folded. Step 2 names the token `tmp-token-setup` and adds a `GET /user/tokens` read for the `9109` case. Step 3's done-check confirms both deletions and no leftover probe registration. | Your steps 2, 3 |
| V7 | minor | Folded. Step 3 records `ci-cairn-build` in Proton Pass through `claude-pass`, checked by name. | Your steps 3 |
| V8 | minor | Owed (optional): `npm pack --pack-destination <scratch>` keeps the tarball out of pass A's worktree. The plan may take it. | none |
| V9 | minor | Folded. The hook's test is `src/tests/unit/release-cut-guard.test.ts`. | Pass B Files |
| V10 | minor | Folded. The carve-out text says a harness-only fix after the final candidate writes no `CHANGELOG.md` line. | `cairn-running-passes` |
| V11 | minor | Refused for 0.99.0. The `setup-recovery.md` row covers the too-narrow token, and a watch message naming the token and key costs product code in an `auth-data` pass for a failure the standing answer already handles. It goes to Later. | Later |

The verification moved the path from 875 to 900. Pass A lane 1 rose from 360 to 385 for the local record mode and the per-group verdict. That is still under 1,240.

## Owed

- V8: `--pack-destination` for the rehearsal tarball (optional).
- No ratified document's meaning changed.
