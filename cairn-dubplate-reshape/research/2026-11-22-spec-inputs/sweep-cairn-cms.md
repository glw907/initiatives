# Scoped backlog sweep: cairn-cms

Read-only sweep for the cairn-cms reshape spec, run 2026-11-22 under `standards:backlog-sweep` in its scoped form.
Nothing in the repo was edited. The spec lists these verdicts, and Geoff's approval of the spec approves the backlog
edits.

## What it read

- Repo: `~/Projects/cairn-cms`, branch `main`, HEAD `87869e61f6a89cfdbb3be272e68b6b8f09c0dc91` ("STATUS: round
  checks closed, round surface next").
- File: `~/Projects/cairn-cms/BACKLOG.md` (1797 lines), the open sections only: `## High` (line 5, empty),
  `## Medium` (7), and `## Low` (403). It skipped `## Won't do` (486) and `## Done` (532).
- Scope: items about how work runs under the retired process, and items the audit
  (`~/Projects/initiatives/cairn-dubplate-reshape/research/2026-11-22-audit/README.md`) touches.

## The search

A Python parser read each open `- [ ]` item with its indented body and applied the same patterns as the dubplate
sweep, plus one for `Placement:` lines, which cairn-cms uses where dubplate uses tags.

| Pattern | Regex | Hits |
| --- | --- | --- |
| Open items | `^\s*- \[ \]` under High, Medium, and Low | 177 |
| Retired process | `pass-core\|running-passes\|conductor\|executor\|packet\|approval queue\|launch[- ]prompt\|adapter\|dubplate-pass\|cairn-running-passes\|cairn-implementer\|pass-gate-tiers\|#process\|\bround'?s close\b` | 10 |
| Process tags | `#(round\|pass):` | 0 |
| Placement names a pass or round | `Placement:` line matching `\b(pass\|passes\|round\|rounds)\b` | 66 |
| Audit findings | `govulncheck\|fuzz\|-race\|data race\|serveUntilDone\|dependabot\|secret[- ]scan\|push protection\|security-guidance\|claude-security\|security[- ]review\|worktree\|CLAUDE\.md\|\.claude\|\bskills?\b\|\bsubagents?\b\|\bagents?\b\|check\.yml\|workflows?/\|gitleaks\|#gate\|\bgate\b\|\bCI\b\|lane:fast\|STATUS\.md` | 58 |

Follow-up greps over the open items for `dependabot`, `secret scan|push protection`, `baseRef`, `implementer`,
`approval-packet|review\.md`, `cycle-prompt`, `figure-verifier|cairn-figure`, leftover worktrees, STATUS length,
and `pass-gate-tiers|gate form` found nothing.

Of the 10 retired-process hits, #328 matched only "adapter" in the SvelteKit sense and is out of scope. Of the 58
audit hits, most matched "skill", "agent", "CI", or "gate" in a product or clean-room-harness sense. Read and ruled
out of scope: #560, #457, #456, #355, #349 (the `scripts/gate` naive-run harness, not the repo gate), #316, #315,
#304, #301, #333, #423, #64.

## Verdicts

| Item (line) | Verdict | Grounding |
| --- | --- | --- |
| #459 The unsandboxed-prompt rule names no arithmetic expansion (148) | fold | `.claude/skills/cairn-proving-setup/SKILL.md:71-72` still reads "where nothing in the whole command expands a variable other than `$?`". Geoff adopted the replacement on 2026-11-14 (Approval Queue item `20261114-094927-c83bd1`), and the item's placement is the next change to this file. Folds into the audit's `cairn-proving-setup` Shrink, whose "Play the owner" edit rewrites line 60 ("The executor of the polish loop is the conductor") and line 77 ("A stop goes to STATUS and the conductor") of the same section. Fix shape: replace the clause with "no `$` other than `$?`, no backtick, and no `<` or `>`". Size: 2 minutes. |
| #299 Fold the root `CLAUDE.md` minors (277) | fold | B1: `CLAUDE.md` repeats what the skills say. Its "Skills, agents, and rules in this repo" list (`CLAUDE.md:41-50`) restates each skill's description, and the audit's `CLAUDE.md` Shrink rewrites line 47 inside that list. Folds into that Shrink. The item's "two path rules" half names no lines, and the audit keeps `.claude/rules/` (5 files, 40 lines) as the documented form, so the fold closes the item. Size: 5 minutes. |
| #374 Reword "friction" as "backlog" (207) | reword | Part rides the reshape: `CLAUDE.md:66-67` ("A friction finding goes to `BACKLOG.md`... There is no friction log.") sits in the "fixed in the pass that meets it" wording the `CLAUDE.md` Shrink rewrites, and `.claude/skills/cairn-running-passes/SKILL.md:56-57` goes with the skill's Replace. `docs/STATUS.md` holds no use now (`git grep -i friction docs/STATUS.md` is empty). The spec writes "backlog" in those rewrites. New wording below. |
| #389 `auth-data` map names the new command's files (452) | reword | The rebuilt `cairn` command does not exist yet (`docs/STATUS.md`: "the `cairn` command is being rebuilt inside the engine package"), so there is nothing to map. The map at `cairn-running-passes/SKILL.md:30` moves when the audit replaces that skill. New wording below. |
| #525 Waymark's header brand link overflows at 320 (354) | reword | `whitespace-nowrap` still at `themes/waymark/components/SiteHeader.svelte:89`, and at the copies `templates/waymark/src/theme/components/SiteHeader.svelte:89` and `scripts/theme/fixtures/options-theme/components/SiteHeader.svelte:89`. The bug stands; its placement names "pennant pass 4", which merged (#255), and it carries "The conductor should know". New wording below. |
| #522 Pass 2's changelog sentence undercounts (419) | drop | The entry lived in `tool/CHANGELOG.md`, which commit `a96deb40b` deleted with the Go tool; `git grep -n -i 'one sentence in' -- CHANGELOG.md '*/CHANGELOG.md'` finds nothing. Strongest case for keeping: the published tool changelog still carries the undercount. Answer: history is not edited, and `MIGRATION-NOTES.md:125` already names the help line, which the item says. |
| #308 Record failed check labels in the `cairn-run-gate` record (259) | drop | The writer lives in `~/.dotfiles/bin/.local/bin/cairn-run-gate:221-222`, which still writes no label field; the item itself says it "may belong in that repo's backlog", and `~/.dotfiles/BACKLOG.md` has no such item. Strongest case for keeping: the gap is real. Answer: it is, so refile it in `~/.dotfiles/BACKLOG.md`, where the session that changes the writer reads it. |
| #359 SECURITY.md's reporting contact (209) | keep | `SECURITY.md:10` still names a personal address. "Approval Queue" is provenance only. |
| #408 Remove App secrets from a retired wizard record (339) | keep | "Approval Queue" is the record of Geoff's ruling. The cited `tool/internal/record` is gone (`a96deb40b`); the ruling applies to the rebuilt command. |
| #424 Store a narrow deploy token (435) | keep | Same: a ruling record, read against the rebuilt command. |
| #473 An approval order that never installs the App on all repositories (425) | keep | Same; the cited `tool/internal/setup/approvals.go:217` is gone. Geoff's acceptance of the wide grant is conditional on this item. |
| #565 `durable-gotchas.md` heap-prefix advice (25) | keep | `.claude/skills/cairn-writing-engine-code/references/durable-gotchas.md:339-348` still says to set the heap. The audit's edit to this file is one stray word on another line, so the fold bar is not met. |
| #566 Worktree-isolated agent refusals (27) | keep | Not yet in `durable-gotchas.md`; placement rides with #565. |
| #552 Record the pass-3 traps in `durable-gotchas.md` (49) | keep | The three traps are still unwritten. |
| #371 Point the release skill at the reinstall steps (201) | keep | `.claude/skills/cairn-releasing/SKILL.md` still names neither step. The audit's Shrink rewrites line 53, not the dependency step. |
| #372 Make the dependency sweep a numbered release step (203) | keep | Still prose at `cairn-releasing/SKILL.md:56-60`; not the lines the Shrink rewrites. |
| #329 Which skill owns an edit under `skills/` (220) | keep | `cairn-writing-docs` still excludes the packaged skills; the audit's Shrink touches only `references/review.md` and `evals/cycle-prompt.txt`. |
| #435 A stand-in session outlives its run (348) | keep | `scripts/gate/run-gate.sh:207` still says `cleanroom stop geoff`. Its STATUS runbook half is gone (no `cleanroom stop` in `docs/STATUS.md`). |
| #191 Harden the eval harness's session sandbox (474) | keep | The deny list is still unwritten. |
| #564 No test pins that a docs-gate or row run skips the installs (23) | keep | Gate contents, untouched by the audit ("Gate (`npm run lane:fast`) and CI: Keep"). |
| #489 One unit test fails with no DNS (107) | keep | `src/tests/unit/workflow-yaml.test.ts:471` still fetches actionlint. Note for the spec: a gate-form proof run from a task session with no network turns red here. |
| #291 Regenerate a new baseline in any spec (301) | keep | `.github/workflows/e2e.yml:148` still names two specs. |

### New wording for the rewords

**#374.** "Reword 'friction' as 'backlog' where it remains. Geoff (2026-11-07): 'Any reference to friction should
be removed it. should be backlog.' The uses left: `.claude/skills/cairn-releasing/SKILL.md:371,374`,
`docs/internal/record/2026-11-07-dependency-sweep.md:62`, and the open items in `ROADMAP.md` (35 hits) and
`BACKLOG.md` (60 hits). The proving loop's 'friction list' (`.claude/skills/cairn-proving-setup/SKILL.md:74,83,84,91`,
`references/owner-card.md:5`, `scripts/gate/grade.mjs:881`) becomes 'backlog list' (Geoff, 2026-11-13); rename the
grader's key and its tests in the same change. Leave quoted Done and Won't do text, URLs that name
`docs-friction-log.md`, plain English ('low-friction tooling'), and the spellcheck dictionary."

**#389.** "Name the rebuilt `cairn` command's setup and credential files in the repo skill's `auth-data` path map:
the App key and secret storage, the over-grant sweep, the deploy-key mint, the push token, the Worker secret, and
the provider write calls. A fix to any of them gets a failing test first and a per-task security read. Source: P1
whole-branch diff review. Placement: the task that adds the first of those files."

**#525.** "Waymark's header brand link overflows a 320 px viewport when the site name is long. `whitespace-nowrap`
on the brand link's name span (`themes/waymark/components/SiteHeader.svelte:89`, copied at
`templates/waymark/src/theme/components/SiteHeader.svelte:89` and
`scripts/theme/fixtures/options-theme/components/SiteHeader.svelte:89`) makes 'The Turnagain Geographic Society'
(32 characters) run 13 px past the viewport at 320 on every page of the organization demo (`scrollWidth` 333). The
footer wordmark wraps at the same width. A theme must hold the 320 bar for any site name a developer sets.
Placement: the next task that changes `themes/waymark`, before the first live Waymark demo with a long site name."

### Grouped verdict: placements that name a pass or round (66 items)

cairn-cms carries no `#pass:` or `#round:` tags. Its tie to the retired process is the `Placement:` line, and 66
open items have one naming a pass or round: #570, #569, #568, #567, #563, #564, #565, #566, #490, #523, #513, #510,
#509, #507, #506, #504, #503, #492 (twice), #491 (twice), #494 (twice), #488, #484, #483, #481, #480, #461, #462,
#463, #464, #459, #457, #456, #416, #410, #401, #402, #468, #469, #470, #435, #525, #501, #500, #499, #498, #526,
#527, #528, #493, #537, #534, #532, #512, #522, #472, #473, #422, #421, #389, #391, #396, #397, #540.

Verdict: **reword** the placements, keep the items.

- Replace "the next pass that touches X" and "the next pass on X" with "the next task that touches X". The trigger
  (a file or a surface) is what matters, and it survives.
- Replace a named pass or round that has closed ("pennant pass 4", "`checks-3`", "the round's close packet") with
  the file trigger the item already implies. #525 and #522 are taken above.
- Keep milestone placements that name product work ("the installer round", "round two, the pass that writes the
  blog set") as milestones, in whatever word the spec picks for the dubplate tags, so the two repos match.
- "A tidy pass" becomes "a tidy task".

## Not yet in the backlog

Audit findings that need an item and have none. Each needs one only if the spec defers it.

- **GitHub security settings.** Secret scanning, push protection, and Dependabot alerts are off
  (`gh api repos/glw907/cairn-cms --jq '.security_and_analysis'`). `.github/dependabot.yml` exists. Geoff said yes;
  the spec carries the step.
- **`worktree.baseRef`.** `.claude/settings.json:11` sets `"worktree": { "baseRef": "head" }`, which the user
  settings and the task launch's `--settings` already override. `.claude/settings*` is a held path, so the edit is
  Geoff's session's.
- **`cairn-implementer`.** `.claude/agents/cairn-implementer.md` is still present, and `CLAUDE.md:29` and `:49`
  name it.
- **`cairn-running-passes`.** Line 8 defers to `standards:running-passes`, which standards commit `b187695` removed.
- **`cairn-releasing:53`.** Points at "`standards:running-passes` "Close"", which is gone.
- **`cairn-writing-docs`.** `references/review.md:4` names the `approval-packet` skill, which does not exist, and
  `:51` says "Under a conductor, the conductor sends it". `evals/cycle-prompt.txt` too.
- **STATUS at 74 lines.** `docs/STATUS.md` carries conductor resume pointers, two `round-report` blocks, and a
  "checks-2 executor" section.
- **One gate form.** `CLAUDE.md:28` says `npm run lane:fast -- --range <base>..HEAD`; `cairn-pass` says
  `cairn-run-gate '<string>'`.
- **Leftover worktrees.** `git worktree list` gives 120 entries: 119 agent worktrees, 1 with uncommitted changes,
  and 49 whose tip is not on `origin/main`. The cleanup is Geoff's session's to do, after a dry run.
- **`figure-verifier`.** Goes with `cairn-figure` (standards PR 25). That lives in the standards repo, not this
  backlog.

## Noticed outside the scope

- **Duplicate item numbers.** #491, #492, and #494 each name two different open items (lines 101, 103, 105 and
  372, 378, 381), and #493 sits beside them at 375. A later sweep or the next `log-issue` should renumber one set.
- **Items citing deleted paths.** 32 open items cite `tool/` paths that commit `a96deb40b` deleted. They need
  grounding against the rebuilt command in a full sweep.
- **A full sweep is due.** 47 open items carry no `swept` stamp from the last 90 days, past the skill's 15. The
  brief ruled out a full sweep, so the spec may want to schedule one.

## Counts

fold 2, reword 3 plus the grouped placement reword (66 items), drop 2, keep 15, done 0, duplicate 0.
