# Docs layout pass: STATUS

Plan: `repo-organization/plans/2026-10-19-docs-layout-plan.md`. Design: `repo-organization/specs/2026-10-19-docs-layout-design.md`.

## Current state

Done (2026-10-19). In thirteen repos, every child of the retired planning folder now sits directly under `docs/`, and every citation of the old path is rewritten. Geoff approved the packet with both `gate-failed` asks taken as "Merge anyway". All thirteen PRs merged at the heads he approved, except workstation#107. Its `main` moved one commit after the packet, so it was rebuilt by the plan's rule and merged at `29bd418`. initiatives#61 rewrote this repo's own citations.

The end-to-end check passed in all fourteen repos on a fresh detached worktree of each default branch. In each, `docs-layout --check` exits 0, the retired folder is gone, and every file that still names the old path is a row in `research/docs-layout-excluded.tsv`. A file planted in the old folder turns both guards red: cairn-cms's `check-idioms` rule 8 and workstation's retired-names check in `scripts/check.sh`. tellgrader is reinstalled from the merged workstation, and a hook probe skips `docs/plans/` while it still flags `docs/extend/`. The old club site's deploy finished green.

## Next action

None for this pass. Owed elsewhere:

- thinkpad-x1: pull every repo above. Then run `make -C ~/.dotfiles/claude/.claude/skills/writing-voice/evals/tellgrader install`. dubplate's private outreach note, if present there, now belongs at `docs/research/2026-09-04-visual-collaborator-outreach.md`; `.gitignore` ignores it by name at any depth.
- drafter BACKLOG #27 (`6b110ad`): make `FactChanged` rename-aware, so a fact bullet whose only change is a moved `Source:` path doesn't count as changed. Until it lands, a scoped `drafter page` run redrafts cairn-cms `docs/extend/debug-your-site.md` whole. The acceptance rerun drafts every page whole anyway.

## Records

- Merged: cairn-cms#131, drafter#54, workstation#107, cairn-themes#2, aksailingclub-legacy#158, phonebook#2, 907-life#3, ecxc-ski#4, poplar#4, dubplate#9, xcathletes-org#3, aksailingclub-org#15, cairn-pub#3; initiatives#54, #58, #61.
- glw907/approval-queue#3 lets a packet carry a PR over 300 files. Geoff chose that fix mid-run, which is the pass's one planning miss (recorded in cairn-cms#131).
- Two reds merged on Geoff's waiver, and both predate the move. 907-life's Workers Builds preview upload runs with no build step. aksailingclub-org has five Playwright visual tests that fail on `main` too.
- Close reviews: workstation `accept`; cairn-cms `accept`; cairn-pub `fix`, withdrawn as `accept` once the reviewer saw that cairn-cms has no `docs/archive/`; dubplate `accept`.

## Score

| Row | Figure |
|---|---|
| Work and review | Plan path 455 minutes. Actual, from PR timestamps: T1 to T7 about 50 minutes (20:24Z to about 21:10Z), T8 to T12 about 45 minutes, so about 95 in all. |
| Gates on the critical path | Each repo's gate once per build. Rebuilds reran drafter once and workstation three times. |
| CI waits on the path | None; CI ran in the background. |
| Fix rounds and reds | One drafter red (a false pin, fixed by a TSV row), one workstation red (a stale base, rebuilt), and no review fix rounds. |
| Close | The packet and one decision. |
| Attended events | The design, one mid-run question (the approval tool's diff limit), and the packet read. The B3c wait and Geoff's reads sit outside the path. |
