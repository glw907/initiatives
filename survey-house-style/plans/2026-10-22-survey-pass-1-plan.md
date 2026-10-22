# Survey Pass 1: visual

Initiative: survey-house-style
Design: `specs/2026-10-21-survey-house-style-design.md` (approved 2026-10-22)
Repo: `glw907/survey` (new, public), checkout `~/Projects/survey`; cairn-themes for task 5.
Class: `ordinary`, with the `live-account` flag (creates a GitHub repo and release). The pass merges its own PR.
Adapter: none; `pass-core` defaults. Gate: `scripts/gate` once task 2 lands it.
Estimate: 240 path minutes; the run stops at 360 (the design's 1.5 times rule).

## Pre-flight

None. Geoff's only step is the rulings sitting after task 1, held in chat by the planning session before launch.

## Tasks

1. **Comparison table** (planning session, 60). Outcome: `research/2026-10-22-survey-visual-comparison.md`, one row per difference across the approval queue's copy, the 2026-10-07 spec, and the specimen, each with a recommended value. Accept: Geoff rules every row; the rulings are appended to the file as a table.
2. **Tokens and build** (90). Outcome: `tokens.json` (DTCG) from the rulings; `scripts/build` (Node, no dependencies) writes `theme/survey.css` (daisyUI 5 theme blocks, light and dark), `theme/survey-vars.css`, and the token table in `DESIGN.md`; minimal `package.json` per the design; `scripts/gate` checks the build is current. Accept: `scripts/gate` passes, and a scratch daisyUI 5 project that imports `theme/survey.css` builds and shows the ruled primary and base colors.
3. **Shared CSS and DESIGN.md** (30). Outcome: `theme/components.css` and `theme/fonts.css` from the approval queue's copy, updated only where a ruling changed a value; `DESIGN.md` with principles and four recipes (cairn admin, cairn site, plain app, theme-limited app). Accept: no literal color or radius in the shared CSS that a token covers (`grep` for hex and `oklch(` outside `tokens.json` and built files).
4. **Contrast, skill, release** (40). Outcome: the contrast check probed per the design (devDependencies `@glw907/cairn-cms` and `daisyui`, `cairn-audit.config.json` naming `theme/survey.css`); kept in the gate if it reads the sheet, cut with a note if not. `skills/survey/SKILL.md` (where each piece is; writing files are edited in this repo only). `scripts/release <version>`. `CHANGELOG.md`. Then `scripts/release 1.0.0`. Accept: tag `v1.0.0` and its release exist on GitHub; `npm install github:glw907/survey#v1.0.0` in a scratch dir installs `theme/` and `DESIGN.md`.
5. **cairn-themes hand-off** (20), a pair with tasks 2 to 4 (disjoint repo). Outcome: cairn-themes removes `survey-theme/` and its Survey spec, each replaced by a one-line pointer to `glw907/survey`, and closes its BACKLOG #1 and #2 as moved. Accept: cairn-themes' own gate passes; `grep -r survey-theme` finds only the pointer.

Path: 60 + 90 + 30 + 40 = 220, with task 5 alongside.

## Standing answers

From the design: past 1.5 times the estimate, stop and report; a value that fails contrast is tuned within its hue and listed in `## Decisions`. Plus: a ruling the build can't express in daisyUI 5's theme variables goes into `components.css` and is listed in `## Decisions`.

## Avoid over-engineering

> "Avoid over-engineering. Only make changes that are directly requested or clearly necessary. Keep solutions simple and focused ... The right amount of complexity is the minimum needed for the current task." (<https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices>)

> "Deliver what was asked, at the scope intended. Make routine judgment calls yourself ... Finish the whole task, and stop short of actions that are clearly beyond what was asked." (<https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-opus-5>)
