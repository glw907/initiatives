# Scoped backlog sweep: dubplate

Read-only sweep for the dubplate reshape spec, run 2026-11-22 under `standards:backlog-sweep` in its scoped form.
Nothing in the repo was edited. The spec lists these verdicts, and Geoff's approval of the spec approves the backlog
edits.

## What it read

- Repo: `~/Projects/dubplate`, branch `master`, HEAD `907605ccf255fb71150e7e2704226ba4f4574924` ("Record the
  structure round as paused before pass 3").
- File: `~/Projects/dubplate/BACKLOG.md`, the open sections only: `## Open` (lines 69-448) and `## Later`
  (449-602). It skipped `## Won't do`, `## Done`, and the roadmap section `## Rounds to 0.8` (lines 6-67).
- Scope: items about how work runs under the retired process, and items the audit
  (`~/Projects/initiatives/cairn-dubplate-reshape/research/2026-11-22-audit/README.md`) touches.

## The search

A Python parser read each open `- [ ]` item with its indented body and applied three case-insensitive patterns.

| Pattern | Regex | Hits |
| --- | --- | --- |
| Open items | `^\s*- \[ \]` under Open and Later | 120 |
| Retired process | `pass-core\|running-passes\|conductor\|executor\|packet\|approval queue\|launch[- ]prompt\|adapter\|dubplate-pass\|cairn-running-passes\|cairn-implementer\|pass-gate-tiers\|#process\|\bround'?s close\b` | 7 |
| Process tags | `#(round\|pass):` | 56 |
| Audit findings | `govulncheck\|fuzz\|-race\|data race\|serveUntilDone\|internal/serve/server\.go\|dependabot\|secret[- ]scan\|push protection\|security-guidance\|claude-security\|security[- ]review\|worktree\|CLAUDE\.md\|\.claude\|\bskills?\b\|\bsubagents?\b\|\bagents?\b\|check\.yml\|workflows?/\|gitleaks\|#gate\|\bgate\b\|\bCI\b\|lane:fast\|STATUS\.md` | 28 |

Of the 28 audit hits, 15 matched only on "gate" in the intake-gate sense or on "CI" in passing, and are out of scope:
#18, #24, #40, #57, #64, #83, #84, #92, #96, #98, #126, #129, #132, #137, #166.

## Verdicts

| Item (line) | Verdict | Grounding |
| --- | --- | --- |
| #128 Trim `CLAUDE.md` (95) | fold | `wc` gives 220 lines, 14,449 bytes, grown from the item's 13,705. Folds into the audit's `CLAUDE.md` Shrink (drop "Build process" and the executor rail, get under 200 lines). Size: inside that task. |
| #136 Three gate texts describe the old gate (88) | fold | `docs/standing-rules.md:55` still lists `make check` as "(vet, golangci-lint, test, tidy-check)", but `Makefile:154` is `check: web vet lint test web-rendered tidy-check` and the full form runs those six (`scripts/check.sh:621-625`); the item's `:105` is now `:103`. `.claude/skills/dubplate-pass/SKILL.md:199` still sends a `scripts/checks/` path to the full form, and `grep scripts/checks scripts/check.sh` finds nothing. `web/scripts/gates/ai-tells.ts:3` already names cairn-cms, so that third part is done. The standing-rules part folds into the gate task (govulncheck and fuzz edit "Gate legs"), the SKILL part into the `dubplate-pass` Replace. Size: 5 minutes. |
| #154 Worktree needs `svelte-kit sync` (78) | fold | `dubplate-pass/SKILL.md:207` says only `npm ci --prefix web`, and `web/package.json:12` "check" runs no sync. Folds into the `dubplate-pass` Replace: the new skill's worktree setup names `npx svelte-kit sync` (or the `make web-build` step). Size: 2 minutes. |
| #157 `auth-data` map omits `internal/ops/**` (381) | fold | `dubplate-pass/SKILL.md:220-222` still omits it, and the audit's map list omits it too. Folds into the `dubplate-pass` Replace's risk map. Size: 2 minutes. |
| #108 Adapter and process changes G14-G19 (338) | done | G14: commit `bdf0efd`, `SKILL.md:194-196` has the `--base <task start>` rule. G15: `SKILL.md:68` "Conventions every task follows". G18: commit `7151edb`, `.claude/settings.json` allows `gate.sh*`, `npm ci --prefix web`, `make *`, `gofmt *`, and the `gh pr` forms. G19: `git grep review-desk` finds only `docs/archive/plans`, `docs/research`, and older `docs/plans/*.md`, no current `*-prompt.txt`. G16 and G17 are superseded by `building-from-specs` "Records" and "Merging" step 4. |
| #109 Workstation process changes X1-X6 (342) | drop | `pass-core` is retired. X1 landed (`~/.dotfiles/bin/.local/bin/cairn-run-gate:30` and `:257`, the `CAIRN_RUN_GATE_ACTIVE` marker); X4 and X5 are moot under `building-from-specs`; X2, X3, and X6 belong to `building-from-specs` and the workstation backlog. Strongest case for keeping: an X item may still be open at the workstation. Answer: workstation gaps go to the workstation's own backlog, per the audit, and nobody who changes the workstation reads this one. |
| #170 "Must not be nil" fields unenforced (438) | reword | The item cites a conductor as a ruling; only Geoff's words are rulings. New wording for the sentence: replace "Ruled kept as is for `structure-base` by `conductor-dubplate`, 2026-11-20." with "`structure-base` (PR #18) kept them as is." The rest of the item stands. |
| #158 Should `doctor` refuse an over-broad trusted-proxy range (384) | keep | "the round's close packet" is provenance only; the item was filed on Geoff's pick and the question stands. |
| #105 golangci `allow-serial-runners` (328) | keep | `.golangci.yml` has no `run:` block; the mechanism holds. |
| #135 Vale leg reads no Go comment (89) | keep | `.vale.ini` has no `Grammars = go`, and nothing runs `vale sync`. |
| #168 Process tags in test comments (430) | keep | The citation leg still drops tests (`scripts/check.sh:812`, `grep -v '_test\.go$'`), and the cited strings remain (`internal/engine/tagio/conform_test.go:355`, `:358`). |
| #156 Process tags in guarded packages (372) | keep | `scripts/check.sh:813` still skips `cmd/dubplate-server` and `internal/(serve\|auth\|intake)`; sites remain at `internal/auth/config.go:99,110`, `backup.go:294`, and `serve.go:296`. The serve fix task touches `internal/serve/server_test.go`, which holds sites at `:132` and `:227`; the fold bar is not met because those lines are not the ones the fix rewrites. |
| #164 Two `fmt.Sprintf` strings in `conform/case.go` (402) | keep | `internal/harness/conform/case.go:614` and `:641` still carry the strings, and `component.go:380`. |
| #152 A throw in one rendered row kills the script (76) | keep | `web/scripts/rendered/run.ts` holds 72 `finally` blocks and about ten real `catch` blocks (`:308`, `:353`, `:2411`), so most rows still run in `try/finally` with no catch. |
| #107 `deploy.sh` hardening to a verified unit (335) | keep | `scripts/check.sh` runs only `systemd-analyze verify`, no `security` leg. Product launch work. |
| #143 `TestDoctorBoundaryProbe_TrustedLoopbackEndToEnd` flake (83) | keep | `freePort` at `cmd/dubplate-server/doctorprobe_test.go:359-370` still releases the port before use. Note for the spec: `-race` in CI slows the run and raises the flake risk. |
| #133 `TestBusyTimeout` flake (90) | keep | `internal/store/conn_test.go:360` still uses `time.Sleep(busy / 2)`. Same `-race` note as #143. |

### Grouped verdict: the process tags (56 items)

One verdict for the product items whose only tie to the retired process is a `#pass:` or `#round:` tag.

| Tag | Open uses | Owner state |
| --- | --- | --- |
| `#pass:cleanup-ci` | 2 | Merged (PRs #12-#16) |
| `#pass:cleanup-gate` | 3 | Merged |
| `#pass:cleanup-ops` | 5 | Merged |
| `#pass:cleanup-store` | 2 | Merged |
| `#pass:structure-keys` | 1 | Merged (PR #19, `c286e3d`) |
| `#pass:structure-doctor` | 4 | Paused round; its resume prompt names items by number, not tag |
| `#round:engine` | 1 | Merged (PR #17) |
| `#round:catalog`, `intake`, `launch`, `library`, `playback`, `queue`, `structure` | 8, 11, 9, 1, 10, 2, 1 | Product milestones in "Rounds to 0.8" |

Verdict: **reword** the tags, keep every item.

- Drop the tags whose owner merged (`cleanup-*`, `structure-keys`, `engine`): they name owners that will never take
  the items.
- Drop `#pass:structure-doctor`. The resume prompt
  (`~/Projects/initiatives/dubplate-server/plans/2026-11-17-structure/structure-doctor-planner-prompt.txt:14`) names
  #124, #147, #156, #123, #143, and #144 by number, so retagging breaks nothing.
- Rename the product-milestone `#round:<name>` tags to `#milestone:<name>`, which each milestone's spec reads in its
  scoped sweep. This is the sweep's judgment call; the spec can choose another word. The tags are defined at
  `CLAUDE.md:62` and `.claude/skills/dubplate-pass/SKILL.md:40-41`, which the reshape rewrites anyway.
- Provenance text inside items ("Found by `cleanup-gate` (PR #13)") stays as history.

### Flag for the spec: the roadmap section

`## Rounds to 0.8` (lines 6-67) is a roadmap section, outside an item sweep. It names the retired process ("round"
as the unit of work). If the tags become `#milestone:`, the heading becomes "Milestones to 0.8" in the same edit.

## Not yet in the backlog

Audit findings that need an item and have none. Each needs one only if the spec defers it.

- **The `internal/serve` shutdown race.** `internal/serve/server.go:151` `serveUntilDone` returns without waiting for
  the other `Serve` goroutines, though its comment says "Shutdown closes the listeners it is still serving".
  `TestServeUntilDoneShutsDownWhenOneServeFails` fails 3 times in 50 under `-race`. No open item names
  `serveUntilDone`, shutdown, or this race (the two "race" hits, #84 and #87, are product). Geoff's answer puts the
  fix in the spec before `-race`, so this needs an item only if that task slips.
- **govulncheck in the gate and CI.** No item; the audit adopts it as a spec task.
- **Fuzz targets.** No item for the third parser (`gate.WalkZIP`), for where a timed fuzz run lives, or for a reader
  entry point to `ParseBounded`. File them if the spec defers any.
- **`-race` in CI with a timeout long enough for `conform`.** No item; spec task.
- **`dependabot.yml` and the GitHub security settings** (secret scanning, push protection, Dependabot alerts). No
  item; Geoff said yes and the spec carries the step.
- **STATUS at 61 lines.** No item; the STATUS Shrink.
- **`api-access.md` Shrink.** No item.
- **Leftover worktrees.** No item.
  - `.claude/worktrees/agent-a828799e8800f0243` on branch `worktree-agent-a828799e8800f0243`: its tip `3bd254f`
    ("T2: Prune pre-migrate copies in one package", 2026-11-16) is merged into `master`, but the worktree holds 23
    modified tracked files, so removing it needs a look first.
  - A registered worktree at `~/.claude/jobs/5452379b/tmp/base-tree` (`c286e3d`, detached).
  - The cleanup is Geoff's session's to do.

## Due but not run

The skill makes a full sweep due when more than 15 open items carry no `swept` stamp from the last 90 days. Here 23
do. The brief ruled out a full sweep, so the spec may want to schedule one.

## Counts

fold 4, done 1, drop 1, reword 1 plus the grouped tag reword (56 items), keep 10, duplicate 0.
