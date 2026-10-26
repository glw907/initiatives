# Docs system retirement inventory

Read-only, 2026-10-25, by a fresh-context agent, for the docs-as-code rulings
(`2026-10-25-docs-as-code-rulings.md`). Read at cairn `origin/main` `f099f2356`, drafter `454587f`,
approval-queue `4f1e833`, dotfiles `43e6cea`. Lines move; find by name.

## drafter (removed whole)

- `make install` placed: `~/.local/bin/drafter` (a 50 MB copy), symlinks `~/.local/bin/cairn-docs-outline`,
  `~/.local/bin/drafter-page-hook`, `~/.claude/workflows/docs-page-chain.js`, `~/.claude/skills/blueprint`.
- Also: `~/.config/drafter/{config.toml,cairn-cms.local.toml}`; `~/.local/state/drafter/` (319 MB:
  spend `ledger.jsonl`, `runs/`, `smoke/`); `~/.local/share/drafter/` (28 MB spike evidence);
  `DRAFTER_API_KEY` in `~/.local/secrets`, the age store, and `~/.dotfiles/secrets/registry.md`, for a
  dedicated Console workspace.
- Dotfiles: `claude/.claude/settings.json` PreToolUse `drafter-page-hook` (guarded by `command -v`),
  `bluefin/bootstrap.sh` clone and install, `bluefin/SECOND-WORKSTATION.md`, `bluefin/untracked-bin.txt`
  (check-drift reconciles it), `scripts/gate.sh` `DRAFTER_BIN`.
- Nothing in cairn runs `drafter`; drafter calls cairn's gate. Nothing needs replacing.
- Repo: no open PRs, 22 open issues, 5 unmerged local branches (all pushed, superseded), 13 worktrees.

## cairn-cms

- Retires: `blueprints/` (14 `.blueprint.md`, 8 `.blueprint.yaml`, `drafted.lock`, `outline.yaml`),
  `drafter.toml` and its `.gitignore` line, `docs/internal/facts/` (6), `docs/internal/briefs/` (86),
  `docs/internal/briefs-rebuilt.json`, `docs/internal/outlines/`, `scripts/checks/{check-facts,check-provenance,migrate-fact-ids}.mjs`,
  `scripts/oneshot/verify-harvest.mjs`, their fixtures and tests, `check:facts` and `check:provenance`.
- Edited: `docs-gate.mjs` (facts and provenance steps, `--brief`) and its test, `close-prebuilt.mjs`,
  `gate-table.json`, the `test.yml` comment, `check-leaks.mjs` and test, `docs-links.mjs` outline
  branch, the review page's plan pane (`scripts/docs-review/embed.mjs`).
- Blocker: `check-options.mjs` imports `loadFactIndex` from check-provenance; 241 rows of
  `docs/internal/option-map.json` cite a fact id. Re-key each to a published reference anchor
  (`docs/reference/<subpath>.md#<heading>`) checked by the anchor checker, in the same commit.
- Stays: links and anchors, Vale and its rule tests, tellgrader, snippets, transcripts, symbols,
  visuals, arm indexes, editor quotes, reference and signatures, readiness, tool conditions, target
  stack, options (re-keyed), leaks (minus retired paths).
- Instructions to rewrite: `CLAUDE.md` "Facts container" bullet, `CONTRIBUTING.md`, the docs
  register's page-plan rule and its rulings and sources lines, `docs/STATUS.md` next action,
  `docs/internal/exemplars/README.md`, ROADMAP stage 2b part 2 entries.
- Friction log: 77 docs-system lines retire; engine and content entries stay. BACKLOG: about 27
  mechanics items go moot (#2-4, #7-8, #18-19, #21, #23, #25-26, #28-30, #35-38, #51, #53-54, #60-61,
  #65-66, #72); page-content items re-aim at pages (#5-6, #9-13, #17, #33, #40, #43-44, #62, #69,
  #71); engine and tooling items stay.
- Published pages carry no fact markers; nothing to strip.
- Leave: product "facts" (`site-facts.json`, `tool/internal/doctor/facts.go`); history records.

## approval-queue

- Decisions: `blueprint` 22, `page` 22 (Geoff's working kind), `change` 1; `anchors` is a helper.
- The blueprint kind's code: `BlueprintView.svelte`, `seed-blueprint.ts`, its fixtures,
  `tests/blueprint.test.sh`, the command's blueprint branches, `approved --kind`'s default.
- The editor, margin, and notes code (about 4,500 lines) serves `page` and `change` only.
- The four blueprint items queued tonight have no `item.json` and no waiter.
- Stored items and log lines are history; keep the data.

## Workstation

- Retire: the `blueprint` skill, the `docs-page-chain` workflow, `cairn-docs-drafter`, the settings
  hook, `~/.config/drafter/`, `claude-tooling.md` lines, `retired-phrases.txt` entry,
  `spec-plan-review` line.
- Rewrite: `fact-checker` (page against code at a commit), `approval-packet` "Blueprints and pages",
  `cairn-implementer`, `site-implementer`, `cairn-pass`, `site-pass` ("file a facts bullet"),
  `engine-consult` (reads the facts store).
- Unchanged: `cairn-register-editor`, `figure-verifier`, `cairn-figure`, `register-check`.
- History: `plan-reviewer.md` lines, `design-refinement`, Survey `approval-brief.md` example,
  `docs/record/*`.

## In flight

- cairn-cms#143 merged. #144 open: keep its 7 pages, the CHANGELOG entry, register Names rows, and
  BACKLOG #75; its 10 blueprint files, 9 briefs, 4 facts files, BACKLOG #76, and ROADMAP fact lines
  are moot.

## Consumer sites

None carry blueprints, facts, or drafter config; the package ships no `docs/internal`.

## Order

1. Close cairn-cms#144 first (deleting on main gives the live session 23 modify/delete conflicts).
2. Re-key `option-map.json` and `check-options.mjs` with the facts deletion.
3. One cairn commit for the gate change and the deletions.
4. Workstation unlinks before the clone goes.
5. Reword skills and agents before removing the `blueprint` skill.
6. Strip the queue's docs kinds after the cairn PRs are decided; keep the stored data.

## Irreversible or history-bearing

Archiving `glw907/drafter` (reversible); deleting the repo or clone (not); the spend ledger and run
state; revoking `DRAFTER_API_KEY` and its workspace; the queue's 45 stored docs items; facts and
friction-log accuracy corrections that need triage into page or engine items before deletion.
