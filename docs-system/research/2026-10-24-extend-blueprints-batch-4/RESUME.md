# Extend blueprints batch 4

Attended run on `pavilion`, started 2026-10-24 about 20:30. Geoff asked for the next three
blueprints, with friction collected for the drafter and approval-queue backlogs.

## State

- Base: `ebp4-base` (pushed, `85bcc6cff`) is `origin/extend-blueprints-2` at `de8a1064e` with
  the five approved batch 3 blueprint branches merged and their stale links repointed. When
  PR #139 merges, `extend-blueprints-2` can take `ebp4-base` by merge.
- Premise check: all five candidates kept (three TRIM for this batch, see `friction.md`).
- Pages and worktrees (`.claude/worktrees/ebp4-<slug>`, deps and `drafter.local.toml` in place):
  theme-your-public-site and act-on-newly-published-entries authoring; add-an-island waits for a
  free slot (two agents at once). Prompts: `prompt-<slug>.txt` in this folder.
- Flow per page: author, `cairn-register-editor`, apply, commit, fresh `fact-checker` (findings
  path per the blueprint skill), settle, fresh check of changed lines, notes JSON,
  description file, `approval-queue blueprint ... --description ... --notes ...` under
  `setsid -f`, decision to `decision-<slug>.json` here.
- Friction: `friction.md` here. At the end, write it into the batch record and file each item
  through `log-issue` in its owning repo (drafter, approval-queue, cairn-cms, workstation).

## Done

- 20:35 Base merged and pushed; premise check done; two authors launched.
- 21:05 act-on-newly-published-entries queued (`4d84038aa`, pushed): item 20261024T210221-500462, decision to `decision-act.json`. Its branch also fixes the sveltekit reference's publish-actions paragraph.
- 21:05 theme-your-public-site: register edit applied by its author (`a6a8d7136`); fact-check running.
- 21:05 add-an-island: authored (`a8552c77f`); islands reference fixed on its branch (`3595def38`); register edit being applied by its author.
- 21:12 add-an-island queued (`90ab5b374`, pushed): item 20261024T211146-511448, decision to `decision-island.json`. Branch also fixes the islands reference's root-layout example.
- 21:12 theme-your-public-site queued (`6887e10dc`, pushed): item 20261024T211229-512193, decision to `decision-theme.json`. Branch also fixes core.md's preview-background sentence.
- 21:15 Friction record committed (initiatives `16550b0`); a filing agent is filing it into drafter, approval-queue, cairn-cms, and dotfiles backlogs.
- 21:20 Friction filed: drafter #84-#103 (`584b7e0`), approval-queue #44-#47 plus #40 addendum (`d98d2d4`), cairn-cms #57-#62 plus #37, #53, #56 addenda (`022daa849`), dotfiles #34-#36 (`a04316a`).

## Next session starts here

1. Collect the three decisions (`decision-act.json`, `decision-theme.json`, `decision-island.json`). If a waiting command died, its item was deleted by its exit trap; requeue from the same notes and description files. On a send-back, fix forward, fact-check the touched lines, and requeue.
2. Each blueprint branch carries one published reference fix (sveltekit.md, islands.md, core.md). On approval, merge the three `ebp4-*` branches into `ebp4-base`, then draft the pages through `drafter page` as batch 3's pages did.
3. Still unowned from batch 2: PR glw907/cairn-cms#139 (both pages approved 16:26) needs ready, CI, and merge; then `extend-blueprints-2` can merge `ebp4-base`.
