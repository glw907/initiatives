# Survey house style design: mechanics and feasibility review

Reviewer: `plan-reviewer` (Opus, medium), against the spec at commit 044b527. The dispatching session saved this file from the reviewer's handback; the content is the reviewer's, lightly reflowed. Line numbers refer to 044b527. Probes ran in the session scratchpad (`cs/`, `dm/`, `pkg/`, `app/`).

## Probed and confirmed (no finding)

- **daisyUI theme from a package works.** A packed tarball with `@plugin "daisyui/theme"` blocks and an `@theme` block, imported in one line after `@plugin "daisyui" { themes: false; }`, compiled under npm (Tailwind 4.3.3, daisyUI 5.7.50). Both themes and `--font-display` were emitted.
- **Style Dictionary 5.7.0 reads DTCG 2025.10 values**: color objects (srgb with and without `hex`, oklch converted to hex), dimension and duration objects, `shadow`, `cubicBezier`, and `$root`.

## Blockers

**1. npm trusted publishing can't be set up before the package exists, and the pre-flight item can expire.** Blocker, `correctness`, L24, L116.
- npm's `npm trust` docs say the package "must already exist on the npm registry". cairn's `publish.yml` records the same: its trusted publisher "was configured at the first publish ... done by hand because npm cannot bind a trusted publisher to a package that does not exist". `@glw907/survey` returns 404 today, and Claude has no npm auth here (`npm whoami`: ENEEDAUTH).
- A new configuration "must complete its first successful publish within 2 days". Configurations created after Sep 03, 2026 allow only `npm stage publish` by default, so a plain CI `npm publish` fails unless "allow npm publish" is ticked.
- Fold: replace L116 with a named sitting just before the cut, merged with the specimen read. (1) Geoff, logged in with 2FA, publishes a placeholder `0.0.0` with `npm publish --access public` from the repo's first commit. (2) He sets the trusted publisher: repo `glw907/survey`, workflow `publish.yml`, allowed action per finding 14. (3) He sets "Require two-factor authentication and disallow tokens". (4) The workflow publishes 1.0.0 the same day. Checks: `npm view @glw907/survey versions`, `npm trust list @glw907/survey` (npm 11.15 or later), `npm view @glw907/survey@1.0.0 dist.attestations`.

**2. Pass B's risk class is `runner`, not `ordinary`.** Blocker, `correctness`, L112.
- `pass-core` "Lifecycle": "`runner` covers skills, agents, workflows, the gate tools, `.github/workflows`", and "A pass takes its highest task's class". Pass B writes the skill, two agent edits, a PostToolUse hook in tracked `settings.json`, and a release workflow. A `runner` pass "sends a packet for Geoff's read and merge" at close, which the design doesn't foresee.
- Fold: declare Pass B `runner` plus `live-account` and name its merge packet, or split per finding 15 so only the workstation tasks carry `runner`. Say whether `pass-core`'s default path map applies to the new repo.

## Majors

**3. Pass A's first step can't run from pavilion, and "not found" has no answer.** Major, `correctness`, L98.
- `thinkpad-x1` doesn't resolve and isn't in `~/.ssh/config`. `gh api repos/glw907/cairn-themes/commits/dea9839` returns 422, and `git ls-remote` shows no branch holding it.
- Fold: a pre-flight item on thinkpad-x1, `git -C ~/Projects/cairn-themes branch -a --contains dea9839`, pushing a rescue branch if found. Standing answer if absent: the approval queue's four files say "Copied from ... at commit dea983976f… Do not edit", so they are the S1 core verbatim; Pass A uses them and Pass B rebuilds the harness. No question to Geoff.

**4. Changesets can't write a Keep a Changelog file, and cairn doesn't use it.** Major, `correctness`, L67, L24, L102.
- `@changesets/cli` 3.0.3 wrote `## 0.1.0` / `### Minor Changes` / `- 1d901fa: …`; the headings are hard-coded in `@changesets/apply-release-plan`. Its "Version Packages" PR uses `GITHUB_TOKEN`, whose events "will not create a new workflow run", which leaves a hidden UI click per release. cairn's flow is a hand-kept CHANGELOG, `gh release create`, then `publish.yml`.
- Fold: drop Changesets. Copy cairn's `publish.yml` (npm@11 pinned because npm 12.0.0 shipped without sigstore; the already-published guard; dist-tag from the version; `--provenance`). Keep a hand-written `## [Unreleased]`. A gate check that every entry names its rung and the consumer's action. Trusted publishing needs an exact `repository.url`, npm 11.5.1 or later, and Node 22.14 or later.

**5. The DESIGN.md gate can't do what L65 and L108 claim.** Major, `correctness`, L65, L108.
- `@google/design.md` 0.4.0 is alpha. It has no light/dark concept. `contrast-ratio` is a warning: a 1.08:1 pair warned and still exited 0. The rule measures only `components` pairs, unreferenced colors raise `orphaned-tokens`, and there's no token type for durations.
- Fold: front matter holds the light set plus a `components` list of the real pairs, and the dark set lives in prose. `theme-contrast` is the contrast authority for both schemes. The gate fails on `summary.errors > 0` or any `contrast-ratio` finding (jq). Pin the CLI exactly. Use lint for structure only.

**6. The `theme-contrast` command and the names it reads aren't stated.** Major, `correctness`, L104, L108, L120.
- Public-scope rules are advisory; `cairn-audit` exits 1 only "under `--fail-on advisory`" (`cairn-cms/src/lib/audit/bin.ts:5-7`). The rule reads fixed names (`rules/static/theme-contrast.ts:182-191`): `--color-muted`, `--cairn-{info,success,warning,error}-ink`, `primary` as focus ring, `--cairn-code-*`. A rename in the builder's hands, or a separate `focus-ring` token, would silently drop pairs from measurement.
- Fold: write `npx cairn-audit --rule theme-contrast --fail-on advisory` with a committed `cairn-audit.config.json` (the 2026-10-07 stylesheet chain). The daisyUI output keeps the names the rule reads; a distinct focus-ring token gets its own 3:1 check. Say whether the `--cairn-code-*` roles are in 1.0.0.

**7. The `survey` skill doesn't reach implementer or reviewer subagents.** Major, `correctness`, L89, L13.
- `visual-verifier`, `daisyui-a11y-reviewer`, and `cairn-implementer` omit `Skill` from `tools`, and the sub-agents docs say unlisted skills are reached "through the Skill tool".
- Fold: give the implementer agents (`cairn-implementer`, `site-implementer`, and whichever implements in approval-queue and the phonebook) the one-line "read the installed DESIGN.md" pointer, and drop the "reaches subagents" claim. A `skills: [survey]` preload is the alternative, but it injects into every dispatch.

**8. Bulwark's pinned sheet is invisible to `dependency-upgrade`.** Major, `correctness`, L68.
- The skill measures `package.json` manifests with `npm outdated`, and the servers repo has none. The fetch is unnamed, and the hook never fires there.
- Fold: the Bulwark role holds a private `package.json` and lockfile with an exact pin, and a build step copies the sheet into the bundle. Otherwise name a step in the monthly review. Say the hook doesn't cover Bulwark.

**9. `survey-check`'s scope and rule don't match the anti-goals.** Major, `correctness`, L78, L53, L79.
- "A literal that no token holds" lets a hard-coded copy of a token's value pass. Surfaces are unnamed (CSS, Svelte `<style>`, `style=`, Tailwind arbitrary values, stock `shadow-*` and `duration-*`). Deprecated names aren't flagged, and Style Dictionary drops `$deprecated` silently. It overlaps cairn-audit's `public-literals`, `radius-scale`, and motion rules on 907.life.
- Fold: flag every color, radius, shadow, and duration literal outside the package's sheets, naming the matching or nearest token. Flag deprecated names with their replacement. List the surfaces. Fixtures: one flagged literal per category, a literal equal to a token value, a deprecated alias, and a clean file. Name which tool owns the overlap on a cairn site.

**10. The hook's states and proof fixture are missing.** Major, `correctness`, L88.
- No detection rule for "a repo that depends on Survey", no location for `survey-check`, no handling of a fresh worktree, a malformed `package.json`, or many findings (`vale-hook` caps at 9000 characters). No real consumer exists in Pass B, so any test passes vacuously.
- Fold: detect through the nearest `package.json` listing `@glw907/survey`; run `<root>/node_modules/.bin/survey-check`. Listed but not installed: one line, "run `npm ci` to enable Survey checks". Malformed manifest: exit 0 silently. Findings through `additionalContext`, capped. Tests follow `tests/test_vale_hook.py` against a scratch consumer, and state the tool-language choice.

**11. The workstation changes say nothing per host.** Major, `correctness`, L84-92.
- `claude-tooling.md`: the live `settings.json` is generated and reaches the host "only through `apply`".
- Fold: both hosts run `git pull`, `stow -R claude bin`, `claude-tooling-sync apply`, `claude-tooling-sync verify`. Prerequisites: `python3` for the hook; Node only in consumer repos. A standing answer for unrelated reversible drift at close.

**12. No stop has a standing answer.** Major, `correctness`, L98-108.
- Unanswered: contrast moving a ruled value, repeated STRUCTURAL findings, Geoff's specimen read sending changes back, an OIDC failure, PR #131 still open, the bar going out of reach.
- Fold: contrast tunes within the hue family and records old value and ratios (as `theme.css:27`). Verifier rounds proceed on a traced cause. Specimen changes inside ruled scope are fixed in the pass; outside it they're a design change. OIDC failure: fix config and re-run the same workflow, never bump (`cairn-release` step 7). PR #131 open: stack on it. Name what may escalate, and what still runs if the bar goes out of reach.

**13. OWNER FORK: 1.0.0 straight away, or a candidate first.** Major, `optional`, L20, L24, L102.
- 1.0.0 freezes names before any consumer has used them.
- Options: (a) 1.0.0 as designed; (b) `1.0.0-rc.1` on `next`, the approval queue converges on an exact pin, then promote; Bulwark still waits for 1.0.0; (c) stay on 0.x. Recommendation: (b).

**14. OWNER FORK: the trusted publisher's allowed action.** Major, `optional`, L24, L116.
- Options: (a) allow `npm publish`, hands-off like cairn; (b) stage-only, a 2FA approval per release. Recommendation: (a).

**15. The Pass B estimate looks short, and the pass mixes risk classes.** Major, `correctness`, L102, L112.
- 420 minutes covers the repo, the move out of cairn-themes, three custom Style Dictionary formats, the specimen port, `survey-check` with fixtures, the hook and tests, the skill and agent and CLAUDE.md edits, AGENTS.md, ten screenshots, and the publish sequence.
- Fold: Pass B is the repo, tokens, outputs, specimen, and release (`ordinary` plus `live-account`; the workflow file is `runner`). Pass C, in the workstation repo, is the hook, skill, and agent lines (`runner`). `survey-check` goes with the pass that ships its first consumer gate. Re-estimate each.

## Minors

**16. Style Dictionary's DTCG support is overstated, and the light/dark layout is unnamed.** Minor, `correctness`, L64. The page says 2025.10 "does not have full support yet". A group with `$extends` was dropped silently and `$deprecated` ignored. Fold: pin exactly, forbid `$extends`, emit deprecation through a custom format, name the layout (a base group plus `light` and `dark` groups, filtered per platform).

**17. The CSS-variable sheet's scheme switch is unnamed.** Minor, `correctness`, L65, L108. Fold: light in `:root`; dark under `@media (prefers-color-scheme: dark)` plus `[data-theme="survey-dark"]`; no `url()` or font imports.

**18. The package manifest shape is unstated.** Minor, `correctness`, L65. Fold: `daisyui ^5` and `tailwindcss ^4` as `peerDependencies`; Fontsource as `dependencies`; explicit `exports` for each CSS file, DESIGN.md, the token JSON, and the `survey-check` bin. End-to-end: a scratch daisyUI project installs the `npm pack` tarball and builds with the one-line import.

**19. Pass A's output location is ambiguous.** Minor, `correctness`, L98. Fold: Pass A writes the rulings and amended specimen to `initiatives/survey-house-style/`, and Pass B moves them into the repo.

**20. The move out of cairn-themes leaves live references.** Minor, `correctness`, L28, L102. Cited in `cairn-themes/.claude/agents/cairn-themes-implementer.md`, `cairn-themes/docs/STATUS.md`, `907-life/BACKLOG.md`, `phonebook/docs/plans/2026-10-07-phonebook-phases-0-2.md`, `initiatives/approval-queue/plans/2026-10-11-review-desk.md`, `initiatives/self-hosting/specs/2026-10-21-bulwark-design.md:22,46`, and the four vendored headers. Fold: update the live ones, leave dated records, and leave a pointer README.

**21. Fresh worktrees have no `node_modules`.** Minor, `correctness`, L75, L89-90. Fold: the skill and agent lines say to run `npm ci` first and never fall back to the GitHub copy.

**22. The lever ladder overstates what Bulwark gets.** Minor, `optional`, L58. Bulwark's sanitizer strips `url()`, so it gets only the fallback stack. Fold: say so.

**23. Over-ceremony in Pass A's sitting.** Minor, `optional`, L96. Fold: Claude rules mechanically forced differences in one table; only taste differences and promotions get renders.

**24. Over-ceremony in the spec text.** Minor, `optional`, L13, L69/L91, L78/L88. The CLAUDE.md line and the hook are each described twice, "two reviewer agents" reads as new agents, and the spec is past one page. Fold: de-duplicate and tighten.

## Files read

The spec; `cairn-themes/docs/specs/2026-10-07-survey-design.md`; `approval-queue/approval-queue/src/lib/survey/*` and `src/app.css`; `cairn-cms/.github/workflows/publish.yml`; `cairn-cms/src/lib/audit/{config.ts,bin.ts,rules/static/theme-contrast.ts}`; the `cairn-release`, `dependency-upgrade`, and `pass-core` skills; `~/.claude/docs/claude-tooling.md`; `vale-hook`; the `visual-verifier`, `daisyui-a11y-reviewer`, and `cairn-implementer` agents; the Bulwark design.
