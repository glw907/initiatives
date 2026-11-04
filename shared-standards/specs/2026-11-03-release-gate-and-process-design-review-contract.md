# Review: contract and criteria lens

Target: `shared-standards/specs/2026-11-03-release-gate-and-process-design.md` at initiatives
`cafe981`. Code: cairn-cms `main` at `bb3c8d3a2`. Inputs: `scratchpad/walk/decisions.md`. Read-only
review. Every code claim below was read at that commit and is quoted.

Findings are ranked by consequence. Each has a severity, a tag, a location, the defect, and a fold.

## 1. E5 is recorded and never fixed, but rc.4 cannot pass without mail. E5 also hides harness gaps (blocker, correctness)

**Location.** Spec 274 (E5), 57-58 (standing answers), 260 (B-13).

**Defect.** E5 ("B2 mail does not arrive ... classed as environment") follows the rehearsal rule:
"A failure on the expected list is recorded, not fixed in the harness." No standing answer says
to fix a mail environment cause before rc.4. The A1 standing answer covers only A1's email throw.
But `evaluateLeg` fails B2 whenever no mail arrives:
`if (!results.mail) failures.push('no mail-borne sign-in ran')`, and
`if (!results.mail.fetch?.found) failures.push("the mail session's marker was not fetched")`
(`scripts/gate/legs.mjs:96-101`). If B-13 is real, the rc.4 gate fails B2 for certain, and the
round spends its ceiling.

E5 also matches harness failures. "a missing fetch" covers every failure after the message is
found: `confirmSignIn`, the second `publishViaAdmin` on the fresh context, and the fetch
(`legs.mjs:448-452`). A wrong subject or `sinceMs` filter in `findSignInMessage` looks the same as
mail that never arrived. B2's mail path is new harness surface (A3 adds the "Check your email"
check to `requestSignInLink`), and this entry hides it.

**Fold.** Narrow E5 to this: `findSignInMessage` reports not-found, and an independent read of the
gate mailbox (a JMAP or IMAP query outside the harness, or the Stalwart delivery log) shows no
message from `no-reply@carin-test.org` since the request. A found message whose marker was not
fetched is a harness gap. Add a standing answer: an E5 with an environment cause gets its fix
before rc.4, as A1's does.

## 2. Nothing checks the rc.4 build-token claims, and they can pass without exercising the new path (major, correctness)

**Location.** Spec 235 (end-to-end "The gate"), 136, 253 (P3).

**Defect.** The end-to-end check says one leg "meets the new deploy-token prompt", the later leg
"reuses `cairn-build` with no prompt", and "a Builds deploy with the narrow token serves the
marker ... which settles probe P3." `evaluateLeg` reads only the closing text, the alert, and the
fetches (`legs.mjs:73-105`). The gate passes the same way whether either path ran. Two ways this
goes false while the gate stays green:

- A `cairn-build` registration already exists, from a pass A executor's live test, a probe that
  failed to delete, or an earlier partial rc.4 run. Then no leg meets the prompt.
- The implementation keeps today's fallback by token id. Today's code reuses by
  `candidate.cloudflare_token_id === verified.id` (`chapter3.mjs:1377-1380`), and the gate's setup
  token already has the wide registration (E4). The trigger then deploys with the wide token, the
  marker still shows, and P3 is "settled" against the wrong token.

The trigger and Worker are deleted at teardown (`gate.mjs:425-429`), so after the run nobody can
check which token the trigger used.

**Fold.** (a) Before `--all` in rc.4 step 6, assert that `GET /accounts/<id>/builds/tokens` has no
`cairn-build` entry. (b) In the harness, each Builds leg logs its trigger's `build_token_uuid` (from
`listBuildTriggers`) before teardown. (c) After the run, assert three things: exactly one
`cairn-build` registration exists, its `cloudflare_token_id` equals the verify id of
`CF_CI_CAIRN_BUILD_TOKEN`, and every logged trigger used that uuid. (d) `driver.log` shows
`answered "Paste your Workers Builds deploy token"` exactly once across the run. Write (a) through
(d) into the end-to-end check.

## 3. OWNER FORK: one registration per account turns the token path into a one-shot test and a shared credential (major, correctness)

**Location.** Spec 31, 81, 138, 262 ("Token reach"), 56 (stale handling can be escalated).

**Defect.** The registration persists, and teardown never touches it (spec 152). Five consequences
follow:

1. **The gate exercises the collect, verify, and register path exactly once, ever.** That is the
   first Builds leg of rc.4. Every later gate run, every #349 rehearsal, and the 1.0 gate only
   reuse. The A12 `promptTable` row then never runs again.
2. **Your step-12 install reuses too, so no human ever opens the narrow prefill URL before the
   stable.** The gate skips that URL (`if (parsed.hostname === 'dash.cloudflare.com') return
   'skip';`, `browser.mjs:35`). The spec's evidence that the rows fill is miscited: lines 52-57 of
   `prefill.mjs` prove `workers_ci`, `d1`, and `workers_r2`. The narrow set uses `workers_scripts`
   with no `workers_ci`, under `zoneId=all` with no zone key. That combination has never rendered.
3. **Your real sites' builds run on the gate's token.** This goes against estate rule 1 ("One token
   per holder and job") and OWASP 3.2.1 ("limit shared secrets"), which the inventory cites.
4. **Rotating or deleting `ci-cairn-build` breaks every real site's builds on the account.** The
   only recovery is the stale-registration handling, which spec 56 lets the run escalate, and no
   re-point route is known (P6).
5. **A regression in A10's prompt path will pass every future gate.**

**Options.**
- (a) Accept the sharing. Add a one-minute pre-flight step: the session prints the narrow prefill
  URL from pass A's code, and you confirm the three rows fill, then cancel. Record the
  inventory row as "shared by the gate and every site on the account", with a rule never to rotate
  without re-pointing. Take stale-registration handling off the may-escalate list.
- (b) Before step 12, delete the `cairn-build` registration. Your install then walks the human
  path and registers your own token. Gate builds afterward run on your token, so the sharing
  reverses but does not end.
- (c) Move the gate to a dedicated Cloudflare account. This ends the sharing and lets each gate
  run delete and re-register. It costs a zone move, Email Sending setup, and new tokens. Belongs
  under Later.

**Recommendation.** (a) for 0.99.0, with (c) under Later. Whatever you choose, add finding 5's
fake-Cloudflare tests, so the prompt path keeps coverage after rc.4.

## 4. OWNER FORK: harness and product paths the rehearsal cannot reach, and why a gap found at rc.4 costs rc.5 (major, correctness)

**Location.** Spec 270-283 (E1, E2), 37 (ruling 1).

**Defect.** Once rc.4 is cut, any fix to `scripts/gate/` on `main` makes the stable unshippable,
because `check-stable-source` refuses any path outside the cut set:
`else if (!ALLOWED.has(path)) errors.push(\`${path}: outside the stable cut's file set\`)`
(`scripts/checks/check-stable-source.mjs:117`). So every harness gap the rehearsal misses becomes
rc.5. The rehearsal misses these:

- **When E1 fires.** A1 fails at the email hop, and A2 is skipped. Then A1's whole tail never runs:
  sign-in, the new A1 publish, `markerCommit`, `fetchCheckAbsent`. Nor does any of A2: `--connect`,
  the Builds hold on a domain install, `robotsHasSitemap`.
- **When E2 and E5 fire.** B2's domain path and mail path never run. Only B1 exercises the new
  publish.
- **Always.** rc.3 cannot exercise the new `promptTable` row, the A10 prompt, or A11. `runCli`
  runs the published package:
  `args: ['--yes', '--prefer-online', \`create-cairn-site@${version}\`, ...]` (`legs.mjs:357`).

**Options.**
- (a) Accept. A gap in these paths costs a version number.
- (b) When E1 or E2 fires, rerun that group under a rehearsal-only `--no-email` flag that flips
  `plan.email`, so the downstream paths still run on rc.3. About 40 minutes.
- (c) Also add one B1 run against `npm pack` of pass A's `create-cairn-site` (npx takes a tarball
  path), then delete the `cairn-build` registration it makes, so finding 2's rc.4 assertions still
  hold. This adds to ruling 14's scope. About 45 minutes.

**Recommendation.** (b) within the ruling. Offer (c) as an add for your call.

## 5. A10 and A11 name no acceptance tests, and A11 as specified has no seam a test can use (major, correctness)

**Location.** Spec 133-145. Code: `hostname.mjs:200-212`.

**Defect.** The harness has named tests (A9). The product items, which are `auth-data`, have none.
A11's pinned probe "through `node:https.request`" sits outside the only seam, the injected
`fetchImpl` in `confirmHostname(domain, fetchImpl, dns = {})`. A unit test cannot reach it without
real TLS to the domain.

**Fold.** Give A11 a seam: a `dns.pinnedProbe` or a `requestImpl`. Name these tests, each of
which fails on today's code:

- **A11:**
  - Both fetch probes unreachable, authoritative AAAA and A present, pinned probe matches: result
    is `live` (today: `hostname-resolver-lagging`).
  - Pinned probe mismatches: result is not `live`.
  - The pinned request carries `servername` and `Host` equal to the domain.
- **A10, against `test/fake-cloudflare*.mjs`:**
  - A `cairn-build` entry exists: no prompt and no create call.
  - Only the wide registration exists for the setup token's id: the run still prompts. This test
    guards finding 2.
  - The build token is verified through `/user/tokens/verify` and never through `listZones`.
  - `--yes` with `CAIRN_CF_BUILD_TOKEN` registers.
  - `--yes` without it parks on the new catalogue row.
  - A token-shaped argv is refused.
  - The state file never holds the secret.
  - The prompt text does not include "Paste your Cloudflare API token".

## 6. A8's privacy promises and several harness checks have no test (major, correctness)

**Location.** Spec 116, 118, 120, 121, 122.

**Defect.** A9 tests A1 (only optionally), A2, A3's happy path, A4, A6, and the replay. Nothing
tests these:

- **A8's `failPage`:** no screenshot on a `token=` or `code=` URL or on a sign-in page, and no input
  values or query strings in `controls.txt`. These are the promises that keep secrets out of the
  run dir, in an `auth-data` pass.
- **A3:** a loopback `Not found` or `Forbidden` body fails the leg; the confirm must land on
  `/admin`; the send must show "Check your email".
- **A5:** `main` runs group B after A throws.
- **A6:** the hold limit drops once the `Watch progress at` line scrolls off.
- **A7:** the record is chosen by `dir`, and `.retired-` files are skipped.
- **A1 (optional only today):** A9 deletes the editor fixture, and the showcase spec is "if cheap".
  If it is not cheap, nothing tests Publish alone with the `?published=1` wait.

**Fold.** Name a fixture and the expected failure for each item above. Keep a minimal admin-editor
fixture for A1: a dirty editor, Publish answering a 303 to `?published=1`, and `.cairn-feedback`
holding `PUBLISHED_ALERT`. Delete it only once the showcase spec lands. Build the loopback fixtures
from the setup tool's real body strings, such as the landing HTML at `github/oauth.mjs:116`, so
they cannot drift.

## 7. The stable-cut hook has no tests, gives no decision on forms it cannot parse, and is never shown to load (major, correctness)

**Location.** Spec 206-210, 225.

**Defect.**

- **Bypass.** "Any other tag gets no decision." So `gh release create "$TAG" ...`,
  `gh -R glw907/cairn-cms release create v0.99.0`, a tag listed after flags, and a stable with no
  `--target` (gh then uses the default branch) all go through. The user-scope allow
  `Bash(gh release create v* --target * --title *)` (`~/.dotfiles/claude/.claude/settings.json`)
  then lets them run.
- **No proof it loads.** The hook's only live use is rc.4 step 4, the allow path, which succeeds
  whether the hook loaded or not.
- **Ruling 2 coverage.** The ruling's two refusals are spelled out in the spec but have no test.

**Fold.**

- Deny by default when the command contains `gh release create` and the tag is not a literal
  argument.
- Deny a stable that has no `--target`.
- Add unit tests that feed hook JSON on stdin: an rc tag without `--prerelease` is denied; an rc
  tag with it gets no decision; a stable whose `check-stable-source` exits 1 is denied; a stable
  with a different `--target` is denied; a passing stable is allowed; a quoted variable tag is
  denied.
- Add one harmless live probe after merge:
  `gh release create v9.9.9-hookprobe --repo glw907/hookprobe-absent --target main --title x --notes x`,
  with no `--prerelease`. The hook's deny text must come back. If the hook is absent, gh fails on
  the missing repo and nothing is created.
- Note `gh api .../releases` as a known path around the hook.

## 8. gate-verdict re-implements a parser that `record.mjs` keeps private, and its refusal tests are hand-built (major, correctness)

**Location.** Spec 184, 236. Code: `scripts/gate/record.mjs:88-106` (`function parseRows`, not
exported).

**Defect.** gate-verdict "imports only the constant", so it carries a second parser for a table the
gate writes. Cells use `escapeCell`'s `\|`. A5 changes the verdict cell to `fail: <reasons joined
by "; ">`, so `failures[0]` (`legs.mjs:478`) no longer feeds it. Hand-typed fixtures can agree with
the gate-verdict parser and disagree with the writer. The three named refusal cases do not cover:

- a `gh` read failure (the `verdict` job's `GH_TOKEN` missing)
- a body with no `## Gate`
- duplicate rows for one leg
- a row with a different cell count

`record.mjs` is not in pass A's file list (spec 108), so pass B can own the change.

**Fold.** Pass B exports `parseGateRows` from `record.mjs` and gate-verdict uses it. The fixtures
come from `renderGateSection`, plus the real rc.3 body after the rehearsal, which must exit 1.
Add the four cases above, each exiting 1. Optionally require each `Marker` to start with
`gate-<V>-<leg>-`.

## 9. Line 193's claim about older workflow copies hangs on P-ENV and gives the wrong reason (major, correctness)

**Location.** Spec 193, 256.

**Defect.** "The environment admits only `v*` refs, and the trusted publisher binding then refuses
OIDC from every older workflow copy." The tags `v0.99.0-rc.1` through `rc.3` are `v*` refs, so the
environment admits them. The old `promote` job is refused only because it sets no `environment:`
(`publish.yml:225-230` shows `permissions:` and no environment). That holds only if npm checks the
environment claim on a dist-tag change, which is P-ENV, an open unknown. If npm does not check it,
`gh workflow run publish.yml --ref v0.99.0-rc.3 -f promote=X` moves `next` with no verdict.

**Fold.** Restate line 193 as conditional on P-ENV. Add a check after the binding: dispatch the
rc.3-tag workflow with `promote=` set to the version that `next` and `create-cairn-site@latest`
both already name. A refusal proves the binding. A success changes nothing and proves the hole.
Skip the check if the two tags differ.

## 10. The end-to-end check and the promotion standing answer contradict each other (major, correctness)

**Location.** Spec 236 and 60.

**Defect.** The round is done only when `promote ran in npm-publish`. The standing answer lets you
run `npm dist-tag add` by hand when the trusted publisher refuses. On that path the stated outcome
(spec 102, "promoted by the hardened `promote`") cannot hold, and the run has no rule for what
counts as done.

**Fold.** Say which one governs. Recommended: the fallback counts only after the `verdict` job has
passed on that run id. The end-to-end check then names the run id and records "promotion by hand
under P-ENV".

## 11. `verify`'s stable rule will fail on a correct stable (major, correctness)

**Location.** Spec 182.

**Defect.** "allows only lines that become equal once the candidate version is replaced with the
stable version, plus the date line." The tarball ships `MIGRATION-NOTES.md` (root `files`), whose
anchors are slugs, not versions: `(./CHANGELOG.md#0990-rc3)`. Replacing `0.99.0-rc.4` with
`0.99.0` never turns `#0990-rc4` into `#0990`. `guidance-hashes.json` is also in `files` and is
outside the rule. The first stable then fails `verify` after the irreversible publish.

**Fold.** Have `verify` apply `check-stable-source`'s `RULES` (export them) to each file's diff
across the tarballs, including its slug-aware MIGRATION-NOTES predicate. Test with the real
rc.2 and rc.3 tarballs, which must fail, and a synthetic pair, which must pass.

## 12. `status` cannot finish for a stable (minor, correctness)

**Location.** Spec 180. `status` always includes `gate-verdict`, but a stable's release has no
`## Gate` table, so `status 0.99.0` never exits 0. **Fold.** Check the gate only for a prerelease.
For a stable, check `latest`.

## 13. The breaking-means-minor test can pass vacuously (minor, correctness)

**Location.** Spec 198. Code: `check-version.mjs:113-120`.

**Defect.** When the top heading is a prerelease, the Unreleased simulation cuts to its core:
`pre.length > 0 ? \`${lMajor}.${lMinor}.${lPatch}\``. With rc.3 on top, that is 0.99.0, a minor
over 0.98.0. So the new patch branch never runs in this round. "Fails on the pass that writes it"
is false until a stable sits on top. A test fixture with an rc on top passes against today's code.

**Fold.** The test fixture puts a stable on top, so old code returns `ok` and the test fails. Also
add one row for an rc line, `0.99.1-rc.1` over `0.99.0`, carrying a breaking line, which must fail.

## 14. `bump`'s changelog transformation is unspecified and untested against its consumer (minor, correctness)

**Location.** Spec 178.

**Defect.** The spec does not say whether `bump` renames `## 0.99.0-rc.N` or inserts a new heading,
and nothing checks that its output satisfies `check-stable-source`.

**Fold.** Add a test: a fixture repo at rc.4, then `bump 0.99.0`, then `checkStableSource` with a
fake runner returns `ok`. State rename or insert.

## 15. Expected failures name symptoms, not the evidence that tells them apart (minor, correctness)

**Location.** Spec 270-273.

**Defect.** E3's symptom, "the closing block lacks X", is also what a bad screen capture, sentence
drift, or a too-short `cli.screen` produces. E1's "exit code 1" fits any throw.

**Fold.** Each expected entry names the capture line that must appear: the
`hostname-resolver-lagging` row text for E3, and an `ensureSendingDomain` or `sendTestMessage`
error line for E1. With no such line, the failure is not expected. Move E4 under "known, not
judged", since it is not a failure.

## 16. The six-key setup token is proven only by grep, and the gate cannot catch it (minor, correctness)

**Location.** Spec 135. Code: `gate.mjs:38-40`.

**Defect.** The gate hands the wide `ws-cairn-gate` (Workers CI, Email, D1, R2) to the CLI as
`CLOUDFLARE_API_TOKEN`. Chapter 1's wrangler calls inherit it too
(`cloudflare/deploy.mjs:199`, `bootstrap.mjs:114`). A missing key in the six-key set therefore
first shows at your step 12, after promotion, and costs rc.5.

**Fold.** State this as a known gap in Risks. Optionally have the smoke mint nothing but assert the
source grep in a unit test (no `/d1` or `/r2/` route under `src/cloudflare` outside tests).

## 17. P-SOA and A11 hide each other (minor, optional)

If the SOA minimum drops, the rc.4 gate probably never hits the pinned path. **Fold.** Say that A11
is proven by unit tests only. If the line "this machine's resolver may take up to 30 minutes"
appears in a capture, record it.

## 18. Pre-flight done-checks read only what the step wrote (minor, optional)

Step 4 checks rulesets by name only, so a ruleset at `enforcement: evaluate` or with the wrong rules
passes. Step 5's `grep -c` proves only that the grant script wrote its line. **Fold.** Step 4:
`--jq '.[]|[.name,.enforcement]'`, plus `GET .../rulesets/<id>` for the rule types. Step 5 is fine
as a done-marker. The real proof is pass B's settings write.

## 19. A5 writes rows in a `finally` that can mask the leg's error (minor, correctness)

`recordLeg` throws when the release read fails (`record.mjs:144-145`). Thrown inside `finally`, that
replaces the leg's own error. **Fold.** Catch and log the record failure, and rethrow the
original.

## 20. Over-ceremony (minor, optional)

- **`status`, `verify`, and `wait` overlap.** `status` re-checks the dist-tags and provenance that
  `verify` checks, and `wait` is `status` polled for one field. Fold `wait` into
  `status --wait <tag>` and have `status` call `verify`'s core. That saves an estimated 30-45 of
  pass B's 225 script-lane minutes, plus one test file and its review.
- **#348's fixtures from `controls.txt`.** A file of role and name lines produces fixture pages
  that are still hand-built, with real labels. If GitHub auto-approves the authorize step, the
  consent page will not be captured at all. Keep the label capture, and drop the claim that the
  fixtures are "captured from real pages".
- **An older allow rule stays.** The user-scope `Bash(gh workflow run publish.yml -f promote=*)`
  remains alongside the new `--ref v*` rule. Retire it in the dotfiles PR.
