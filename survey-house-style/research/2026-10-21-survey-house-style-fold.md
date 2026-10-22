# Survey house style design: fold record

Target: `survey-house-style/specs/2026-10-21-survey-house-style-design.md`, revised in place from `bacaab5`. Reviews folded: `-review-contract.md` (F1 to F24), `-review-integrity.md` (1 to 16), and `-review-mechanics.md` (1 to 24). Process: `spec-plan-review` "The fold" and `receiving-code-review`. Each finding was checked against the source it cites before a disposition was given.

Counts: 64 findings. 47 folded (several at a root another lens also raised), 2 refused, 6 owner forks across 4 Decide blocks (mechanics 23 merged into one), and 9 dropped as `optional`. Four folded findings also carry a refused part, listed with the finding: contract F18, integrity 3 and 9, and mechanics 15.

## Owner forks

Each fork is a `### Decide:` block in the brief.

| Decide block | Findings |
| --- | --- |
| Release 1.0.0 directly, or a release candidate first | contract F24 (`optional`, raised as a sequencing question), mechanics 13, integrity 2 (its release-candidate part) |
| What the trusted publisher may do | mechanics 14 |
| Whether a visible Survey update needs a render read | integrity 4 |
| How many renders Pass A's sitting carries | contract F15, mechanics 23 (merged into this fork) |

The forced-difference part of mechanics 23 has one correct answer and is not part of the fork. A value that fails contrast is not a taste call, so Claude rules it and the sitting lists it (spec "Pass A").

## Contract lens

- **F1** folded: "Pass C", agent lines. Verified: `site-implementer.md` and `cairn-implementer.md` declare `tools: Read, Write, Edit, Bash, Grep, Glob`, with no Skill tool. The four agents gain the one line, the "reaches subagents" claim is gone, and a headless `site-implementer` dispatch is part of Pass C's acceptance. Root shared with mechanics 7.
- **F2** folded: "The conformance check" (surfaces, matched literals, exemptions, fixtures, message shape, nearest-token rule). Root shared with integrity 5 and mechanics 9.
- **F3** folded: "Contrast" restates 4.5:1 and 3:1, both schemes, sRGB and display-p3, and the committed `cairn-audit.config.json`. The non-vacuity guard is a planted low-contrast value that must exit 1. That probe is cheaper than counting report pairs, whose output shape is unverified.
- **F4** folded: "End-to-end check", the pack listing and post-publish legs. Root shared with integrity 2 and mechanics 18.
- **F5** folded: `fixtures/daisyui-consumer/`. It uses a minimal Tailwind and daisyUI build, the shape the mechanics probe compiled, in place of a SvelteKit app. The proof is the same and it builds faster. `survey-check` also runs on the specimen's source.
- **F6** folded: `fixtures/token-only.html`, the zero-`url(` and zero-`@import` grep, computed-style probes, and the fallback font stack.
- **F7** refused: a token-diff semver gate is new machinery, and with no release history there is no measured defect. The `survey-check` unknown-name error and deprecated-name warning catch a missed major at the app's own gate.
- **F8** folded: "Versioning and release", the checker policy. Checked against ESLint's README: a bug fix that reports more errors is minor, and "`eslint:recommended` is updated and may result in new linting errors" is major. The fold states both lines, not the review's "any new failure is major".
- **F9** refused: a changelog lint is new machinery with no measured defect. The entry rule stays written in "Changelog". The render-read fork keys on bump size, so no marker needs linting.
- **F10** folded: "Pass A", the ledger and its grep count.
- **F11** folded: "Pass B", the trace. The end-to-end check names the amended specimen's path.
- **F12** folded: "Pre-flight" and "Pass A". Root shared with integrity 6 and mechanics 3.
- **F13** folded: "Pass C", hook. Root shared with integrity 11 and mechanics 10. `.survey-version` is not adopted, because Bulwark gets a real `package.json` (see F14) and the hook does not cover Bulwark.
- **F14** folded: "What each app's pass inherits", Bulwark. Root shared with integrity 7 and mechanics 8. The extra `dependency-upgrade` inventory line is not needed. Verified: the skill's step 1 measures "every directory with its own `package.json` and lockfile" (`dependency-upgrade/SKILL.md:35-37`). The staged-bump criterion belongs to Bulwark's own pass.
- **F15** owner fork: Decide on renders.
- **F16** folded: "Risk and estimate". Root at mechanics 2.
- **F17** folded: "Token source and outputs", DESIGN.md. Root at mechanics 5, which probed that `lint` has no dark-scheme concept. `theme-contrast` is the contrast check of record.
- **F18** folded in part: the build fails on a token without `$description`, and the end-to-end check runs the commands `AGENTS.md` names from a clean clone. Refused part: the principle-to-Do/Don't pairing script is new machinery with no measured defect.
- **F19** dropped: `optional`.
- **F20** folded: "Pass C", acceptance, using the skill-creator trigger method (three should-trigger prompts, two should-not).
- **F21** folded: "Pass C", agent lines. They use the same detection rule as the hook, the rule grade adds to the image grade, and a rule failure is STRUCTURAL.
- **F22** dropped: `optional`. The rewrite drops the inaccurate "manifest entries" wording anyway.
- **F23** dropped: `optional`. Mechanics 12's standing answer covers PR #131, which is still open (`gh pr view 131`: OPEN).
- **F24** owner fork: Decide on a release candidate.

## Integrity lens

- **1** folded: "Versioning and release" (first publish) and "Pre-flight". Root shared with mechanics 1. The placeholder moves to pre-flight because it needs no pass output. The trusted-publisher link stays at Pass B's close because of npm's 2-day first-publish window.
- **2** folded in part: the packed-artifact legs ("End-to-end check") and the rollback rule ("Versioning and release", in `AGENTS.md`). The release-candidate part is an owner fork.
- **3** folded: "Versioning and release", workflow. Publishing runs only on a release or a dispatch, as in cairn's `publish.yml`. Pass B's close puts the specimen read before the release. Refused part: a GitHub environment approval adds a gate the release trigger already makes unnecessary.
- **4** owner fork: Decide on the render read.
- **5** folded: "The conformance check", names. Root at contract F2. The extra step that runs `survey-check` around a major bump is not adopted: the app's gate already runs it, and `dependency-upgrade` runs the gate.
- **6** folded: "Pre-flight", "Pass A", and "Pass B" provenance (the core starts from the approval queue's vendored copy at a recorded commit). Verified: the vendored `theme.css` header reads "Copied from cairn-themes/survey-theme/core/theme.css at commit dea9839... Do not edit", and `cairn-themes/survey-theme/` holds only `reference/`.
- **7** folded: "What each app's pass inherits" and "CSS-variable sheet", which gets a version header and a `url(`-free gate. Root shared with contract F14. The live-theme and restore check is named as the Bulwark pass's design.
- **8** folded: "What each app's pass inherits", approval queue. Pass A reads at recorded commits. Verified: the approval queue's `README.md:22` says the command builds on first use when `build/index.js` is missing.
- **9** folded in part: "Pass B" provenance takes a fresh copy without history, in place of `filter-repo`, and `files` leaves out `reference/`. Refused part: `gitleaks` in the gate. A fresh copy of four named files carries no history, and the reviewer found the seven commits clean, so there is no measured defect.
- **10** folded: "Pass B", leaving cairn-themes (push first, then one pointer commit with a grep gate). Root shared with mechanics 20.
- **11** folded: root at contract F13 ("Pass C", hook).
- **12** folded: "Pass A", outputs. The fold takes the initiatives path (mechanics 19) over the cairn-themes path, since `pass-core` puts cross-repo research in `initiatives/<id>/`.
- **13** dropped: `optional`. Its substance folds at mechanics 4.
- **14** dropped: `optional`.
- **15** dropped: `optional`. Mechanics 5 (one contrast authority) covers it.
- **16** dropped: `optional`. Same root as mechanics 2.

## Mechanics lens

- **1** folded: root for the trusted-publishing setup. See integrity 1.
- **2** folded: "Risk and estimate". Pass B is `runner` and `live-account`, and Pass C is `runner`. Pass B uses `pass-core`'s default classes, since Survey has no adapter.
- **3** folded: "Pre-flight" and its standing answer for an empty result.
- **4** folded: "Versioning and release". Changesets is dropped and cairn's `publish.yml` copied. Its gate check on changelog entries is refused, as at F9.
- **5** folded: "Token source and outputs", DESIGN.md. The jq rule that fails on `contrast-ratio` findings is not adopted. A second contrast gate would bring back integrity 15's disagreement risk.
- **6** folded: "Contrast" and "daisyUI theme" (the names the rule reads, focus ring as primary, no `--cairn-code-*`). Verified at `theme-contrast.ts:175-195`, `config.ts:7` and `:403`, and `bin.ts:5-7`. The vendored core defines `--cairn-*-ink` and `--color-muted`, and no `--cairn-code-*`.
- **7** folded: root at contract F1.
- **8** folded: root at contract F14.
- **9** folded: root at contract F2. Which tool owns the overlap on a cairn site: cairn-audit, with `engine-consult` deciding whether `survey-check` also runs.
- **10** folded: root at contract F13. The hook is stdlib Python under the workstation's tool-language rule, with tests on the `tests/test_vale_hook.py` pattern.
- **11** folded: "Pass C", hosts. Verified: `check-drift` warns "clone is behind origin" (line 47) and runs `claude-tooling-sync verify` (lines 294-295).
- **12** folded: "Stops and standing answers".
- **13** owner fork: Decide on a release candidate.
- **14** owner fork: Decide on the trusted publisher's action.
- **15** folded in part: the split into Passes A, B, and C, with new estimates. Refused part: moving `survey-check` to the first app's pass. It ships in the package with its own fixtures, and the hook in Pass C would have nothing to run without it.
- **16** folded: "Token source and outputs", source.
- **17** folded: "CSS-variable sheet".
- **18** folded: "Package shape" and the pack leg.
- **19** folded: root at integrity 12.
- **20** folded: "Pass B", leaving cairn-themes. The live pointers are listed below.
- **21** folded: "Agent-friendly by construction" and "Pass C", agent lines.
- **22** dropped: `optional`.
- **23** merged into the owner fork on renders (see above).
- **24** dropped: `optional`. The rewrite removed the duplicates anyway.

## Live pointers Pass B rewrites

Pass B rewrites these:

- In cairn-themes: `CLAUDE.md`, `README.md`, `docs/STATUS.md`, `BACKLOG.md` items #1 and #2, and `.claude/agents/cairn-themes-implementer.md`.
- `907-life/BACKLOG.md`.

Left as dated records: `phonebook/docs/plans/2026-10-07-phonebook-phases-0-2.md`, `initiatives/approval-queue/plans/2026-10-11-review-desk.md`, and `initiatives/self-hosting/specs/2026-10-21-bulwark-design.md`. The approval queue's four vendored headers change in its own adoption pass.

## Mechanisms introduced, and their evidence

- npm trusted publishing: <https://docs.npmjs.com/trusted-publishers>, fetched 2026-10-22. Quoted: "A newly created trusted publisher configuration must complete its first successful publish within 2 days"; "Configurations created after Sep 03, 2026 are automatically set to allow `npm stage publish`"; staged versions need a maintainer's 2FA approval; npm 11.5.1 or later and Node 22.14.0 or later; an exact `repository.url`; and the setting "Require two-factor authentication and disallow tokens". The rule that the package must exist first comes from the mechanics review's `npm trust` quote and from `cairn-cms/.github/workflows/publish.yml:92`.
- The release trigger, npm 11 pin, `--provenance`, dist-tag from the version, and already-published guard: `cairn-cms/.github/workflows/publish.yml`, read here.
- ESLint's semver policy: the `eslint/eslint` README, "Semantic Versioning Policy" (quoted at F8).
- The ignore comment's reason after two hyphens: <https://stylelint.io/user-guide/ignore-code>, "You may also include a description at the end of the comment, after two hyphens". The measured cases are `frame.css:9` and `:295`, per the contract review.
- The hook's `additionalContext`, 9000-character cap, and changed-line scope: `vale-hook` lines 5-7, 19, 32, and 134.
- Relied on from the mechanics review's probes: Style Dictionary 5.7.0 with DTCG 2025.10, `$extends` dropped, `$deprecated` ignored; `@google/design.md` 0.4.0 behavior; Changesets 3.0.3 headings; the daisyUI theme compiled from a packed tarball.
- The brief passes the approval-queue brief parser: `node src/check-brief.ts design <spec>` exited 0.

## Owed

- The session that sends this design stages the `0.0.0` placeholder package (a `package.json` with name, version, `repository.url` set to `glw907/survey`, and a README saying it is a placeholder) before the packet, so Geoff can publish it in the approval sitting.
- The estimates (210, 460, and 160 path minutes) have no theme-work score behind them. The planner checks them against each plan.
- On an `auth-data` or `live-account` pass, `spec-plan-review` calls for a verification read of this fold. Pass B is `live-account`.
