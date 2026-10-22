# Survey rewrite: mechanics and feasibility review

Reviewer: `plan-reviewer` (Opus, medium), against the spec at ad97b5f. The dispatching session saved this file from the reviewer's handback, condensed without changing any finding. Probes ran on pavilion (Claude Code 2.1.307, Vale 3.24.0, npm 11.19.0) in the session scratchpad `lens2/` (`style/`, `bodychange/`, `sha/`, `pinonly/`, `stylesum/`, `ledger/`).

## Verified

- `claude -p --settings '{"outputStyle":"probe-style"}' --disable-slash-commands` applies a project style; without the flag it does not.
- `claude -p "/output-style"` works headless and marks the current style `(current)` (see m3).
- An auto-mode `claude -p` runs a nested `claude -p`, and writes and commits in a repo outside its working directory (push untested).
- Vale ignores a `SHA256SUMS` file in `styles/Survey/`. A pin-only `.vale.ini` raises nothing.
- `npm access get status` works logged out. The npm trusted-publisher quotes match the docs.
- `~/.claude/docs` and `~/.claude/output-styles` are folded stow links into `~/.dotfiles`, and vendored skills are committed under `claude/.claude/skills/`, so relative symlinks resolve in the repo and in CI.
- Estimate arithmetic adds up (3,200 total, 3,040 path).

## Blockers

**B1. Match and beat thresholds fail by chance.** L218-219, effects at L362, L429, L244. Nine blind pairs per surface: "prefers the baseline in no more than 60%" fails at 6 of 9, P = 0.254 for byte-identical content; across fourteen surfaces P(at least one false miss) = 0.983. "Beat" at the same cut ships a no-op 25% of the time. Pass G must match on all surfaces and has no stop for a miss, and a noise miss has no cause to trace. Fold: a one-sided sign test at α = 0.05 with ties excluded (at n = 9, 8 preferences to beat or to fail a match), or more runs; a first miss re-runs with more runs before tracing; a Pass G stop.

**B2. `sha256sum -c` over the vendored skill has no checksum file and misses stale files.** L166, L170, L274, L329, L340, L398. `fetch_skill` copies only `skills/survey/` blobs (`claude-tooling-sync:397-421`), so `vale/Survey/SHA256SUMS` never arrives. `sha256sum -c` exits 0 with an extra file present. `fetch_skill` never deletes, so a rollback or upstream removal leaves stale files. Fold: commit `skills/survey/SHA256SUMS` and gate it in survey; the dotfiles gate runs `sha256sum -c --strict --quiet` from the skill directory and checks the file set equals the listed set; `fetch_skill` clears the destination first, or the rollback step does.

**B3. Pass H's pack restructure breaks every symlink target and the versioning policy.** L200-207, L270, L277, L284, L158, L372, L374. The registers and output style link to `pack.md`, which Pass H replaces with six files. The output style must stay one file with frontmatter. The approval-queue gate needs at least 6 fenced exemplars and exactly 3 packet exemplars in `approval-brief.md` (`approval-queue/tests/approval-queue.test.sh:209-235`). Removing a slug is major, but Pass H ships minors. Fold: `pack.md` stays each pack's stable entry, built from or linking the six files with every heading kept; `packs/core/` keeps the output style whole; Pass H runs the approval-queue gate with `REGISTER=` at the survey checkout plus a slug check; otherwise Pass H is a major.

## Majors

**M1. Pass D needs Pass C's output.** L111 says D needs nothing from C, but L329 vendors C's `survey` SKILL.md. Fold: D's skill step waits for C; standing answer: D does every other step and the skill step last.

**M2. Eval arms aren't isolated from user scope.** L216, L324. A default `claude -p` arm loaded the global CLAUDE.md and the SessionStart hook; PostToolUse hooks load too. With `--setting-sources project` both dropped and the project style still applied, but the user's auto `defaultMode` drops as well. Fold: arms run with `--setting-sources project --disable-slash-commands --permission-mode <named> --settings '{"outputStyle":"<arm>"}'`; the snapshot carries the global CLAUDE.md "Writing voice" section as the baseline arm's project CLAUDE.md; each scorecard records the drafting model id.

**M3. New minors never reach the workstation or zip repos, and break npm gates.** L168-173, L244, L372. `dependency-upgrade` covers `package.json` directories only (SKILL.md:36, 85); nothing moves the vendored tag or the `.vale.ini` URL; `npm update` fails the `diff -r` gate until the copy is refreshed. Every writing-only minor also triggers the ruled render in each app. Fold: a Survey step in `dependency-upgrade` or a `survey-pin` helper that refreshes the copy, moves the zip URL and runs `vale sync`, and bumps the vendored tag with `update-skills survey`.

**M4. Both hosts can grade the same month.** L235-245, L443-445. `model-review.timer` runs on both hosts (`OnCalendar=monthly`, `RandomizedDelaySec=1h`, `Persistent=true`); step 2's check comes hours before writing; both write `scorecards/<YYYY-MM>.md`, an add/add conflict. Fold: grade only on pavilion with thinkpad-x1 harvesting only, or push a claim file first.

**M5. Pass F's dry-run acceptance can't run.** L235, L357, L476. `model-review-notify` has no ledger argument; `--dry-run` still runs the whole model review and ends with "commit on your branch and stop"; the step drafts about 126 pieces. Fold: a `writing-review [--dry-run] [--ledger DIR] [--surfaces S]` launcher that step 9 calls; acceptance runs one surface on a scratch ledger.

**M6. `npm deprecate` needs Geoff.** L162, L417, L487. Trusted publishing covers "npm publish, npm stage publish, and the dist-tag operations", not deprecate, and tokens are disallowed. Fold: the standing answer cuts the patch without asking; the exact `npm deprecate` goes in the close packet as Geoff's step, named under pre-flight and sittings.

**M7. The cairn-editor channel assumes a draft commit `content-draft` never makes.** L230, L278, L355. `content-draft` only offers to save or commit; cairn reads `frontmatter.draft` (`cairn-cms/src/lib/content/manifest.ts:110`); all five sites allow squash, which can drop the trailer. Fold: commit the draft to the default branch with `draft: true` and `git commit --trailer 'Survey-Draft: site-content'`; any PR merges with `--merge`, never squash; about 20 minutes.

**M8. Several estimates aren't credible, and the pack count is wrong.** L109, L372, L474-478. There are 12 packs (11 plus `core`), not 14. Pass H's 40 to 45 minutes per pack, Pass G's 30-minute match run, Pass E's 15 minutes per repo, and Pass F's dry run are all low. Fold: re-cut against a per-surface eval cost measured in Pass D, and name eval concurrency.

**M9. Pass E's approval-queue bump needs the ruled render.** L337-345, L53. 1.0.0 to 1.1.0 is a minor bump in an app, and the app serves from `main`'s `build/`. Fold: add the render read and worktree build to that PR, with minutes.

**M10. The publish workflow can't retry after a workflow fix, or upload `Survey.zip` as copied.** L160, L416. A release event runs the workflow at the tag's commit; cairn's `publish.yml` has `permissions: contents: read`; the already-published guard skips a re-run's publish. Fold: an upload job with `contents: write` and `gh release upload --clobber`; retry a workflow fix by `workflow_dispatch` from `main` at the same version, or by recreating the tag.

## Minors

- **m1.** The comment packs' source text is undefined. Name each section (ts §0 at line 34 and "TSDoc doc-comment shape" at 73; svelte §0 at 31; python §0 at 36 and "Docstring shape" at 73) and `cmp` against the extracted bytes.
- **m2.** `~/.dotfiles` holds no `glw907` copy (the 2026-09-28 audit, DC-12). The five repo copies are identical (sha prefix 371c9a66). Snapshot from poplar at a recorded commit.
- **m3.** With a dangling output-style symlink, `/output-style` still exits 0; only `(current)` disappears. Assert `- writing-voice (current):` and `readlink -e` the link.
- **m4.** skill-creator's viewer saves free text per `run_id` with no verdict field, static mode downloads `feedback.json`, and Chromium names repeats `feedback (1).json`. Use a first-word ship/edit/reject convention, static mode in Pass D, and a `feedback*.json` harvest glob.
- **m5.** "send-back" is a verdict, not an item kind. Match `verdict == send-back`.
- **m6.** `aggregate_benchmark` runs from a hash-named plugin cache (16 versions on pavilion). Copy `aggregate_benchmark.py` (Apache-2.0) into `evals/` at a recorded commit.
- **m7.** "Fell two months running" with at most 5 samples fires by chance about 1/6 of the time per surface. Require a drop beyond one standard deviation, or a three-month window.
- **m8.** Pass H may start with no real scorecard. Fall back to Pass D's baseline means.
- **m9.** Pass G's new Vale rules must ship at `suggestion`.
- **m10.** `@glw907/survey` is a devDependency in cairn-cms.
- **m11 (optional).** The zip gate needs the network. Download in CI only, or cache by tag.

## Over-ceremony (optional)

- **o1.** Pass G's fourteen-surface match run measures nothing that changed once arms are isolated. Replace it with the Vale fixtures and a findings diff.
- **o2.** Pass E re-runs trigger prompts for an unchanged description. Drop it, or keep it as the one end-to-end trigger check.
- **o3.** Two one-line Pass F tasks stand alone. Merge them.
- **o4. OWNER FORK: monthly grading volume.** (a) As written: 126 drafts and about 200 judge calls, about 320 model calls a month. (b) One run per task monthly, with a three-run confirmation only where a grade fell: about 110 calls. Recommendation: (b), unless usage headroom easily covers (a).

## Stops checked

Pass G's all-surface match has no answer (B1). Deprecation hides a Geoff-only step (M6). Pass D's wait for 1.0.0 is a recorded STATUS stop. Every other stop at L404-463 has a standing answer.
