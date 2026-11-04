# Review: data integrity and failure risk

Target: `shared-standards/specs/2026-11-03-release-gate-and-process-design.md` at initiatives `cafe981`.
Code: cairn-cms `main` at `bb3c8d3a2`. Inputs: `scratchpad/walk/decisions.md`, `build-token.md`.
Lens: crash, concurrency, partial write, upgrade, restore. Read-only; nothing run live.

Ranked by consequence. Each finding: severity, tag, location, defect, fold.

## 1. The stale-registration path deletes shared account state on an unprobed signal

- **Severity:** blocker. **Tag:** correctness.
- **Location:** spec line 138; spec line 136 (reuse by name); `chapter3.mjs:1369-1375` (hop skipped once a trigger exists).
- **Defect.** The spec says: "If the list shows it, the hop deletes the stale registration (the route the smoke already uses, `gate.mjs:249`) and collects a new token." The `cairn-build` registration is shared by design: ruling 6-7 has every later site in the account reuse it. Other sites' triggers hold its uuid. Nothing in the spec checks for those references before the delete. Two outcomes follow:
  - When the signal is right (the token really was deleted), the other sites' builds were already broken. After the delete, their triggers point at a uuid that no longer exists. Re-running the CLI on those sites cannot repair them, because the hop is skipped once a trigger exists (`chapter3.mjs:1369`). The new registration helps only the site being set up.
  - When the signal is wrong, the CLI deletes a live registration and breaks every site on the account. PS has not run yet, so the field is unknown. It might also read the same way for an expired or disabled token, or for a token owned by another account member.
- Ruling 6-7 says the stale registration "is detected and the CLI asks for a new token". Deletion is the spec's own addition and is not in the ruling.
- **Fold.**
  - The CLI never deletes a registration.
  - On a stale signal, register the new token under the same fixed name. The reuse rule then picks the newest entry named `cairn-build` that does not show the stale signal, and is tested for duplicate names. Ruling 6-7 fixes the name, so the fold keeps it.
  - Print one line saying that other sites on the account still point at the dead token, with the manual re-point from `MIGRATION-NOTES`.
  - If the item escalates under the standing answer, the shipped behavior must be "reuse, and the first build fails inside the watch". Deletion must never ship.

## 2. "Narrow token too narrow" fix-forward never reaches the token in use

- **Severity:** major. **Tag:** correctness.
- **Location:** spec line 59; spec lines 135-136; spec line 235.
- **Defect.** The standing answer reads: "add the named key to the narrow set and fix forward to `rc.5`". That change edits only the prefill URL. By then the `rc.4` gate has registered `ci-cairn-build` as `cairn-build`, and teardown never removes a registration (spec line 152). The `rc.5` CLI therefore reuses the same too-narrow token with no prompt, and the `rc.5` gate fails the same way. Real users hit the same trap: a narrow token registered once is reused forever. The only repair path covers a deleted token (stale), not a token with too few permissions.
- **Fold.**
  - Extend the standing answer: before the `rc.5` gate, Geoff (`[you]`) widens `ci-cairn-build` in the dashboard, or the session edits it with a temporary token-management token.
  - Product: when the build watch reports a permission failure, the CLI names the token and the missing permission and tells the owner to edit that token. Re-pasting does not help, because reuse never prompts.

## 3. A stable can publish without the hook, through an auto-allowed dispatch

- **Severity:** major. **Tag:** correctness.
- **Location:** spec line 211 (allow rule), spec lines 206-209 (hook), `publish.yml:31,100,154` (`if: github.event_name == 'release' || inputs.promote == ''`).
- **Defect.** The hook guards only `gh release create`. The publish jobs also run on a dispatch with an empty `promote`. The new allow rule, `Bash(gh workflow run publish.yml --ref v* -f promote=*)`, matches `-f promote=` with an empty value.
- The bypass takes two steps:
  1. Create a `v0.99.0` tag with `git tag` and `git push origin v0.99.0`. Nothing hooks this, and the tag ruleset blocks only update and deletion.
  2. Run `gh workflow run publish.yml --ref v0.99.0 -f promote=`. That publishes the stable, with no prompt and no check from `check-stable-source.mjs`.
- A stable publish cannot be undone.
- **Fold.**
  - In `publish.yml`, the `build` job refuses a stable unless `github.event_name == 'release'`. Dispatch publishing stays for prereleases only.
  - The allow rule requires a non-empty value: `-f promote=0.*`, widened at 1.0.
  - The hook also denies `git push` of a stable `v*` tag.

## 4. A tag whose `package.json` holds another version publishes nothing and goes green

- **Severity:** major. **Tag:** correctness.
- **Location:** `publish.yml:78-86` (the version comes from `package.json`, and an already-published version skips with `exit 0`); spec line 225 (`--target main`); spec lines 190-191.
- **Defect.** Nothing compares the tag name with the version in the tree. Step 4 tags `--target main`. Suppose the step 3 push failed, or the bump commit is not on origin `main`, or another session pushed in between. The `v0.99.0-rc.4` tag then lands on a commit that still reads `0.99.0-rc.3`. Every publish guard prints "already on the registry; skipping", and the run is green. `wait.mjs` then times out with no cause named. Under the new tag ruleset the bad tag cannot be moved; recovery means turning the ruleset off and on again by hand.
- **Fold.**
  - The `build` job fails unless `GITHUB_REF_NAME == "v$(node -p "require('./package.json').version")"`, and does the same for both sub-packages.
  - Step 4 uses `--target "$(git rev-parse HEAD)"` after `git fetch` confirms HEAD equals `origin/main`.
  - `preflight` (or a `cut` check) prints that sha.

## 5. The verdict can pass on rows from a different run or an earlier attempt

- **Severity:** major. **Tag:** correctness.
- **Location:** `record.mjs:113-119` (`mergeGateSection` keeps every earlier row and replaces only the same leg's row); spec line 118 (A5 writes in a `finally`); spec line 184 (`gate-verdict`); spec line 314 (M11, a non-fatal record write, deferred to Later); spec line 57 ("rerun only the affected legs").
- **Defect.** The `## Gate` table holds the last row written for each leg, not the rows of one run. Three paths leave a stale `pass` that `gate-verdict` accepts:
  - A rerun's failure row is never written. A5's `finally` calls `recordLeg`, which throws on a `gh` failure (`record.mjs:146,153`). The earlier `pass` stays.
  - A run dies before it reaches a leg, for example when the browser fails to launch at `gate.mjs:381`. No `skipped` rows get written.
  - A partial rerun mixes runs. An A2 `pass` from install a1 then sits beside an A1 `pass` from a later install.
- Promotion on stale rows moves `next` and `create-cairn-site@latest` to a candidate that did not pass.
- **Fold.**
  - An `--all` run first writes a fresh `## Gate` section, four rows of `pending`, and aborts if that write fails.
  - Add a `Run` column carrying the run-dir id. `gate-verdict` requires all four rows to share one run id and refuses duplicate leg rows.
  - A single-leg rerun is still allowed for the rehearsal. For a candidate's verdict, the four rows must come from one run.

## 6. Two gate runs at once: the second tears down the first's live installs

- **Severity:** major. **Tag:** correctness.
- **Location:** `gate.mjs:340-349` (`teardownStale` covers every run dir except its own), `gate.mjs:378` (`if (all) await teardownStale(...)`), `run-gate.sh:19` (the run dir is named to the second, with no lock).
- **Defect.** Nothing stops two `run-gate.sh` processes from running at once. A gate run takes over 90 minutes, so an agent session runs it in the background. A session that believes the first run died, or a second session, can start another `--all`. That run deletes the first run's Worker, D1, R2, repo, and App mid-leg. The first run then writes `fail` rows into the public release body, and both runs may register `cairn-build` twice.
- **Fold.**
  - `run-gate.sh` takes `flock -n ~/.local/state/cairn-gate/lock` and refuses with the holder's pid.
  - `teardownStale` skips any run dir with a live `pid` file.
  - This is a small change inside pass A's files.

## 7. OWNER FORK: the gate's registration becomes production infrastructure

- **Severity:** major. **Tag:** correctness.
- **Location:** spec line 31; spec line 262 ("No probe needed"); spec line 318 (Later: "Delete the old wide `cairn create-cairn-site build token` registration once `rc.4` passes").
- **Defect.** The spec records the coupling but sets no rule for the token's lifecycle.
  - Geoff's step 12 install, and every later real site on the account, deploys with `ci-cairn-build`, a token minted and stored as a gate credential. Rolling it, deleting it, or narrowing it under the estate scheme silently breaks every production build on the account.
  - After `rc.4`, no gate run can exercise the first-connect prompt again without deleting `cairn-build`, which would break production.
  - The Later deletion is unsafe as worded. The inventory says Geoff's real sites' Builds token "hold[s] `ws-admin`" (`cloudflare-estate-inventory.md:81-83`). A registration named `cairn create-cairn-site build token` can exist once per token id, because the old CLI matched on `cloudflare_token_id`. Deleting by name could remove a live site's registration.
- **Options.**
  - **(a)** Accept the coupling for 0.99.0. The inventory row marks `ci-cairn-build` as production-critical, never rolled or deleted without re-pointing every trigger. The Later deletion names the uuid whose `cloudflare_token_id` is `ws-cairn-gate`'s id, and runs only after a read shows no trigger holds it.
  - **(b)** Move the gate to a separate Cloudflare account, so gate registrations never meet real sites. This costs a second account and moving the test zone.
  - **(c)** Give the CLI an environment override for the registration name. This is a test seam in product code, which the scope charter likely refuses.
- **Recommendation:** (a) now, with (b) filed to `BACKLOG.md`.

## 8. A4's kept capture is deleted by the same run and by the next one

- **Severity:** minor. **Tag:** correctness.
- **Location:** spec line 117; `gate.mjs:328` (the cleanup list holds `capture.bin` and `urls.log`); `teardown.mjs:220` (cleanup runs when teardown is clean, whatever the legs did); `gate.mjs:340-349`; `driver.mjs:127` (capture is opened with `flags: 'a'`).
- **Defect.**
  - The teardown after group A runs the cleanup when the teardown itself is clean, even when A1 failed. That deletes the capture A4 means to keep.
  - The next `--all`, which is the `rc.4` gate, runs `teardownStale` over every earlier run dir and deletes their captures too. That includes the rehearsal's F2 evidence and the four earlier `rc.3` runs.
  - One `capture.bin` also collects every CLI run of the whole run, so `cliFailureMessage` can quote an earlier leg's error.
- **Fold.**
  - When any leg fails, write a `failed` marker in the run dir. Cleanup and `teardownStale` skip `capture.bin` in any dir that has the marker.
  - Give each CLI run its own capture file: `capture-<leg>-<n>.bin`.

## 9. A2's `from` offset throws on the second group

- **Severity:** minor. **Tag:** correctness.
- **Location:** spec line 115; `gate.mjs:328` (the teardown after group A deletes `urls.log`); `browser.mjs:250-251`.
- **Defect.** "Each `runCli` passes the file's current size." After group A's clean teardown, `urls.log` no longer exists. A bare `stat` therefore throws on B1's first CLI run in every `--all` run. The planned "tail twice on one file" test cannot catch this.
- **Fold.** `from` is the size, or 0 on `ENOENT`. Add a test that deletes the file between two tails.

## 10. The manual promotion fallback skips the verdict

- **Severity:** minor. **Tag:** correctness.
- **Location:** spec line 60.
- **Defect.** If OIDC refuses the dist-tag change, Geoff moves the tags by hand, and no one has read the `## Gate` table.
- **Fold.** The fallback begins with `node scripts/release/gate-verdict.mjs 0.99.0-rc.4`, and Geoff runs the commands only on exit 0.

## 11. `withdraw` has no recorded rollback target for a promoted candidate

- **Severity:** minor. **Tag:** correctness.
- **Location:** spec line 183; `publish.yml:239` (the `trap` prints dist-tags only on EXIT, after the move).
- **Defect.** Suppose Geoff's install fails on `rc.4` after promotion. `create-cairn-site@latest` cannot be removed, only moved, and its earlier value was the deprecated `rc.1`. No record exists of what `next` and `latest` held before the promote.
- **Fold.**
  - `promote` prints the dist-tags before the move, and `status` stores them in its JSON.
  - `withdraw` takes `--promoted` and prints the moves back to those values, plus the deprecation.

## 12. A partial `bump` sits on top of the uncommitted hand fold

- **Severity:** minor. **Tag:** correctness.
- **Location:** spec lines 178, 223-224.
- **Defect.** Step 2 folds the changelog window by hand and leaves the tree dirty. Step 3's `bump` then writes eight files and runs `emit:template`. A crash part way leaves a mixed tree. `git restore` also discards the hand fold, and a rerun can stack a second `Released` line or a second set of anchors.
- **Fold.**
  - Commit the fold as its own commit before `bump`.
  - `bump` computes every file in memory and checks the results before writing. It is idempotent on rerun, and otherwise refuses a dirty tree, naming `git restore`.

## 13. Captured controls committed as fixtures can leak identity into a public repo

- **Severity:** minor. **Tag:** correctness.
- **Location:** spec lines 121-122, 161.
- **Defect.** The controls files list each button and link by role and name. GitHub pages name the signed-in login, App names, and repo names in their link text. Copying the files into `src/tests/unit/fixtures/` publishes `GITHUB_TEST_LOGIN` and install names in git history, which cannot be withdrawn.
- **Fold.** A scrub step replaces the test login, the `cairn-e2e-gate-*` names, and any email with placeholders before the copy. A unit test asserts that no fixture contains the login.

## 14. A5 puts multi-line failure text into a public release body

- **Severity:** minor. **Tag:** optional.
- **Location:** spec line 118 (`fail: <reasons joined by "; ">`); `record.mjs:1-4` ("the release body is public"); M12 deferred at spec line 315.
- **Defect.** `cliFailureMessage` carries the setup tool's error lines and the last 15 screen lines. Those lines name the owner's email, home paths, and the account id. A `token=` in that text makes `assertNoToken` throw, which leaves no row (finding 5).
- **Fold.** A row carries the first line of the reason, capped at about 160 characters. The full text goes to `<runDir>/<leg>.failure.txt`.

## 15. The spec misstates why older workflow copies are refused

- **Severity:** minor. **Tag:** correctness.
- **Location:** spec line 193.
- **Defect.** "The environment admits only `v*` refs, and the trusted publisher binding then refuses OIDC from every older workflow copy." The older copies run on `v*` tags too, so the ref filter admits them. They are refused only because they declare no `environment:`, so their OIDC token lacks the claim. The tag ruleset also leaves tag creation open, so a new `v*` tag on any commit runs whatever `publish.yml` that commit holds, inside the environment.
- **Fold.**
  - Correct the sentence.
  - Record that the environment guards against stale copies, not against a new tag. Finding 3's fold covers the stable case.

## 16. The end-to-end check assumes no `cairn-build` exists before the `rc.4` gate

- **Severity:** minor. **Tag:** correctness.
- **Location:** spec line 235.
- **Defect.** Any earlier live run of pass A's new hop would leave `cairn-build` on the account, for example an executor checking the CLI by hand. The `rc.4` gate would then see no prompt, and the check could not be met.
- **Fold.** Step 6 of the `rc.4` sequence first reads `GET /accounts/<id>/builds/tokens` and requires that no entry is named `cairn-build`. Pass A's plan forbids live runs of the new hop outside the gate.

## 17. A crash between mint and store at pre-flight loses the token value

- **Severity:** minor. **Tag:** optional.
- **Location:** spec line 81.
- **Defect.** `POST /user/tokens` returns the value once. If the session dies before `secret-set.sh` completes, a live user token is left with no stored value.
- **Fold.** One tested script mints the token, pipes the value straight into `secret-set.sh`, and deletes the token by id if the store write fails.

## 18. P-PROV fix-forward under an immutable tag strands `rc.4` half-published

- **Severity:** minor. **Tag:** correctness.
- **Location:** spec line 257; spec line 191 (each publish job runs on its own).
- **Defect.** Suppose the engine publishes and `publish-dev` fails provenance. `rc.4` then exists on the registry for one package only, and `gate` points at `rc.4` for the engine and at `rc.3` for the dev backend. The tag's workflow cannot be fixed, because the ruleset blocks updating the tag, so the release becomes `rc.5`.
- **Fold.** Say this in the risk row. `status` and `wait` report a `gate` split across packages by name, and `withdraw` deprecates the stranded half.

## 19. `publish.yml` has no concurrency group

- **Severity:** minor. **Tag:** optional.
- **Location:** `publish.yml` (no `concurrency:` key; the same holds for `test.yml` and `e2e.yml`).
- **Defect.** A release event can overlap a manual re-run or a promote dispatch for the same version. npm refuses a duplicate publish, so this is noise rather than corruption. A promote can still overlap a publish that is in flight.
- **Fold.** Add `concurrency: { group: publish-${{ github.ref }}, cancel-in-progress: false }`.

## 20. Pass B's changelog lines live only in the conductor's memory

- **Severity:** minor. **Tag:** optional.
- **Location:** spec line 171.
- **Defect.** "The conductor adds pass B's consumer-visible lines when it folds the window." No artifact carries those lines from the pass to the cut, so a compacted or replaced conductor loses them.
- **Fold.** Pass B's PR body carries a `## Changelog lines` section, and the fold at spec line 223 cites it.

## 21. Over-ceremony: `status` and `verify` overlap

- **Severity:** minor. **Tag:** optional.
- **Location:** spec lines 180, 182.
- **Defect.** Both scripts check dist-tags and provenance on all three packages. Only `verify`'s stable tarball diff is unique.
- **Fold.** Fold `verify` into `status --stable`, which leaves one checklist. Also note that the stable diff runs after an irreversible publish. It detects a bad stable and does not prevent one; `check-stable-source.mjs` is the guard that prevents.

## Checked and sound

- **Older workflow copies cannot promote.** They lack the environment claim. `promote` at `rc.1` through `rc.3` is refused once the npm binding lands.
- **A split `next` is safe.** `check-stable-source.mjs` refuses a stable while `next` differs across the packages (lines 105-108).
- **Promote can be re-dispatched.** `dist-tag add` is idempotent, and the verdict reruns on each dispatch.
- **Teardown keeps the prefix guard.** It refuses any name without `cairn-e2e-gate-` before making a call (`teardown.mjs:68-72`).
- **Smoke registrations are cleaned up by uuid.** Each probe registration is deleted by `build_token_uuid` (`gate.mjs:248-251`). Builds already accepts a second registration of the same token id, which the current smoke proves.
- **The build token never touches state.** It is never written to the state record, so a crash in the trigger hop leaves no secret at rest.
