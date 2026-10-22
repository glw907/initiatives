# Survey house style design: fold verification

Target: `survey-house-style/specs/2026-10-21-survey-house-style-design.md` at `df4c436` (branch `survey-house-style`). Fold record: `-fold.md`. Reviews: `-review-{contract,integrity,mechanics}.md`. Process: `pass-core` and `spec-plan-review`. Reader: a fresh-context verifier with no part in the fold. Line numbers refer to the spec at `df4c436` unless a file is named.

Counts: 0 blockers, 1 major, 11 minors (7 `correctness`, 4 `optional`).

## Verdict

Every blocker and every major from the three reviews closes at the location the fold cites, or sits in a `### Decide:` block, or has a refusal with a stated reason. The brief parses: `node src/check-brief.ts design <spec>` exited 0. The fold introduces no task order that cannot build. Pass A's ledger and specimen feed Pass B. Pass B's packed tarball feeds Pass C's scratch app, and Pass C does not need the published package. One defect is new. The placeholder publish that pre-flight hands Geoff leaves out `--access public`. On a scoped name, that fails or creates a private package, and npm provenance needs a public package.

## Closure check, by review

| Finding | Closes at | Result |
| --- | --- | --- |
| contract F1 (blocker) | 176-177, 180 | closed. Verified: all four agents declare `tools:` without Skill (`site-implementer.md:4`, `cairn-implementer.md:4`, `visual-verifier.md:6`, `daisyui-a11y-reviewer.md:4`). `claude --agent` exists for the headless dispatch. |
| contract F2 (blocker) | 122-131 | closed: surfaces, matched literals, exemptions, nearest-token rule, message shape, fixtures |
| contract F3 (blocker) | 120 | closed. Verified: `--rule`, `--fail-on advisory`, and `cairn-audit.config.json` exist (`cairn-cms/src/lib/audit/config.ts:7`, `:403`). The rule measures sRGB and display-p3 at 4.5:1 and the focus ring at 3:1 (`theme-contrast.ts:34-37`, `:255-256`). An unresolved pair counts as an advisory "unmeasured" finding (`:245-252`), so a missing pair also exits 1 under `--fail-on advisory`. The audit cannot pass vacuously. |
| contract F4 (blocker) | 196, 200 | closed |
| contract F5, F6 | 197, 198 | closed |
| contract F7, F9 | refused (fold:28, :30) | reason stated and sound (no measured defect; Changesets dropped) |
| contract F8 | 146 | closed, matching ESLint's policy |
| contract F10, F11 | 157, 168, 199 | closed (see minor 10 on the count's file set) |
| contract F12 | 225, 228 | closed |
| contract F13 | 178, 180 | closed. Verified: `vale-hook` uses `additionalContext` (line 154), `CHAR_CAP = 9000` (line 19), and changed-line scoping |
| contract F14 | 187 | closed. Verified: `dependency-upgrade/SKILL.md:33-37` measures every directory with its own `package.json` and lockfile |
| contract F15 | Decide on renders, 53-61 | owner fork |
| integrity 1 (blocker) | 150, 226 | closed in mechanism; see the major below for the command |
| integrity 2, 3 | 149-151, 170, 193-200 | closed; the release-candidate part is a fork |
| integrity 4 | Decide on render read, 43-51 | owner fork |
| integrity 5 | 128 | closed in part; see minor 5 |
| integrity 6 | 166, 225 | closed in part; see minor 6 |
| integrity 7, 8 | 113, 187-188, 155 | closed |
| mechanics 1, 2 (blockers) | 150, 219, 226 | closed |
| mechanics 3-12, 15 | as listed in fold:68-82 | closed. Spot-checked 6 (cairn-audit names), 10 (hook), 11 (hosts), 12 (stops) |
| mechanics 13, 14 | Decide blocks, 25-41 | owner forks |

## Mechanisms spot-checked

- **npm trusted publishing.** I fetched <https://docs.npmjs.com/trusted-publishers> on 2026-10-22. The page confirms the 2-day first-publish window, that new configurations allow `npm stage publish` and need `npm publish` ticked under "Allowed actions", npm 11.5.1 or later with Node 22.14.0 or later, and an exact `repository.url`. It also says "Require two-factor authentication and disallow tokens" "only affects traditional token authentication", so it is compatible with OIDC. The page does not say that the package must exist before a link is made. That rule rests on cairn's `publish.yml:92` comment and the mechanics review's `npm trust` quote, and the fold record says so (fold:104). The page also says provenance is automatic for public packages, and "requires a public repository and a public package". That last clause is why the major below matters.
- **cairn's `publish.yml`.** Verified: it runs on `release` and `workflow_dispatch` (lines 13-16), pins `npm@11` (line 44), passes `--provenance` with a version-derived tag (line 85), and has the already-published guard (lines 80-83). It runs Node 24, which is at least 22.14.
- **Contrast gate command.** Verified as above. `cairn-public.css` supplies `--cairn-code-*` as aliases of Survey's own roles (`cairn-public.css:28-35`). So the claim that Survey ships no `--cairn-code-*` (line 112) still lets the code pairs resolve through the config's chain. No finding.
- **Hook contract.** Verified against `vale-hook` and the PostToolUse block in tracked `settings.json` (`vale-hook` at `timeout: 15`). See minor 4 on the Bulwark sentence.
- **survey-check scope.** Coherent and testable. See minors 5 and 11.
- **Bulwark's pin.** Verified against `dependency-upgrade` step 1. An exact pin still shows in `npm outdated` when `latest` moves.

## Decide blocks

Geoff can rule all four from the evidence given. Each block states its cost, its source, and a recommendation. The trusted-publisher block leaves out what its second option does to the workflow and to Pass B's close (minor 3).

## Findings

### Major

**M1. major, `correctness`, spec:226 and fold:114.**
Defect: the pre-flight step says only "publish the `0.0.0` placeholder", and the package the session stages carries no `publishConfig`. `@glw907/survey` is scoped, and npm publishes a scoped package as restricted by default. On a free account the publish fails at the sitting. On a paid account it creates a private package, and npm's trusted-publishers page says provenance "requires a public repository and a public package". So Pass B's first CI publish could ship without provenance, or fail, inside the 2-day link window. The mechanics review's fold (mechanics 1, step 1) named `npm publish --access public`, and the fold dropped it. The step also gives no check to show it was done, which `pass-core` step 4 requires ("done and checked").
Proposed fix: in fold:114, add `"publishConfig": {"access": "public"}` to the staged `package.json`. Write the step as `npm publish --access public`, with the check `npm view @glw907/survey version` returning `0.0.0` from a logged-out shell. Name `npm access get status @glw907/survey` reading `public` as the second check.

### Minors

**1. minor, `correctness`, spec:226 and 31.**
Defect: the `0.0.0` placeholder takes the `latest` dist-tag. Under the recommended release-candidate option, `latest` stays on an empty placeholder through Pass B and the whole approval-queue pass. A bare `npm i @glw907/survey` installs the empty package, and a sweep's `npm outdated` shows `latest` 0.0.0 below the installed rc. Integrity 1 asked to show that the placeholder never reaches `latest`. Fold:49 records integrity 1 as folded but drops that part without a refusal.
Proposed fix: add `npm deprecate @glw907/survey@0.0.0 "Placeholder; install 1.0.0 or later"` to the pre-flight step. State that `latest` moves on the first stable publish. Alternatively, record the dropped part as refused in fold:49.

**2. minor, `correctness`, spec:228.**
Defect: "One named sitting remains, at Pass B's close" contradicts Pass A's rulings sitting (line 159) and Pass C's merge approval (line 22).
Proposed fix: write "Two more sittings follow: Pass A's rulings and Pass B's close (specimen read, trusted-publisher link, merge approval). Pass C closes on a merge packet."

**3. minor, `correctness`, spec:41 and 170.**
Defect: the "staged only" option does not say that the workflow must call `npm stage publish` in place of cairn's `npm publish`. It also leaves out that Pass B's post-publish check (line 200) can run only after Geoff's 2FA approval, which adds a step to the close and to every later release. Geoff can't weigh that cost from the block.
Proposed fix: add to the option: "`publish.yml` runs `npm stage publish`, and each release's post-publish check waits for your approval."

**4. minor, `correctness`, spec:178 and fold:34.**
Defect: "It does not cover Bulwark, whose sheet is a build output" is not what the detection rule does. Line 187 gives the servers repo a `package.json` that lists `@glw907/survey`, so the hook fires on any `.css` or `.html` edit under that directory. Fold:34 gives "the hook does not cover Bulwark" as the reason to drop `.survey-version`, which is circular.
Proposed fix: write "In the servers repo it checks only hand-written CSS; the copied sheet is a build output and is not edited", or exclude the copied sheet's path by name.

**5. minor, `correctness`, spec:128.**
Defect: the unknown-name error covers only "Survey's token prefix". Integrity 5 also named `--site-*`. The daisyUI output's role names (`--color-muted`, `--cairn-*-ink`) are fixed by `theme-contrast`, so a rename there is unlikely. But a removed `--site-*` property in the shared CSS still fails silently in a consumer, which is integrity 5's defect.
Proposed fix: "An unknown name under Survey's token prefix or `--site-*` is an error". Read the `--site-*` set from the shipped shared CSS.

**6. minor, `correctness`, spec:225.**
Defect: the thinkpad-x1 step leaves out `git stash list`, which integrity 6 named. Also, `git branch -a --contains dea9839` prints an error ("malformed object name") when the commit is absent, and the step does not say that the error means "not found". "If any shows Survey work" is a judgment Geoff is left to make with no criterion.
Proposed fix: add `git stash list`. Add: "an error from the last command means the commit is absent; Survey work is any path under `survey-theme/`, or any commit or stash that touches it."

**7. minor, `correctness`, spec:202-215.**
Defect: four foreseeable stops have no standing answer:
- Pass C's `site-implementer` dispatch does not read DESIGN.md.
- A should-trigger prompt misses (line 214 covers only should-not misses).
- The post-publish check fails after a successful publish (line 151's rollback rule exists, but no stop routes to it, and a patch needs another release).
- Pass B's `grep -rni survey` in cairn-themes returns a hit outside the fold's pointer list.

`pass-core` step 1 requires an answer for each.
Proposed fix: answer each in place:
- Reword the agent line once and re-run, then escalate.
- Treat a should-trigger miss the same as a should-not miss.
- Deprecate the version and cut a patch through the same workflow, with no question.
- Rewrite a live hit, leave a dated record, and list both in `## Decisions`.

**8. minor, `optional`, spec:167 and 219.**
Defect: the Build list names `publish.yml` but no CI workflow for PRs, while line 219 makes "CI on PRs" Pass B's full-suite home.
Proposed fix: add "a PR CI workflow running the gate" to line 167.

**9. minor, `optional`, spec:131 and 178.**
Defect: on 907.life the hook runs `survey-check` whenever its `package.json` lists the package, even if `engine-consult` decides that `survey-check` does not run there.
Proposed fix: add to line 131: "the hook follows that decision; a site that opts out lists no `survey-check` in its gate, and the hook skips a repo whose gate does not name it." Or accept the gap, since the hook is advisory.

**10. minor, `optional`, spec:157.**
Defect: "the named files" for the grep count is ambiguous. Line 155 names the six approval-queue files, the 2026-10-07 spec, and the specimen, and F10 asked that the specimen be counted.
Proposed fix: "in the six approval-queue files and the approved specimen".

**11. minor, `optional`, spec:199 and 160.**
Defect: line 199 cites `reference/<date>-amended-specimen.html`. That path reads as the survey repo's own `reference/` directory, which line 166 fills with other files. Line 160 puts the file in `initiatives/survey-house-style/reference/`.
Proposed fix: at 199, write `initiatives/survey-house-style/reference/<date>-amended-specimen.html` at the commit Pass B cites.

## Pre-flight items

Both items are steps only Geoff can do. Claude has no npm auth (mechanics 1: `npm whoami` returns ENEEDAUTH), and pavilion cannot reach thinkpad-x1 (mechanics 3). Neither item needs a pass's output. Each still needs its check named (M1, minor 6).
