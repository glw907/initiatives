Initiative: shared-standards

# Agent-first plan: fold record

Plan: `2026-10-31-agent-first-plan.md`, revised from `dab8b17`. Reviews: `plan-review-mechanics.md` (M), `plan-review-contract.md` (C), and `plan-review-integrity.md` (I), in the planning session's scratchpad. The design was not edited; owed errata are below.

## Counts

| Disposition | Count |
|---|---|
| Folded, including questions taken as having one correct answer | 98 |
| Refused, including every `optional` finding | 12 |
| Owner fork | 3 |
| **Total** | **113** |

Each `optional` finding was dropped. Convergent findings folded once, at the root named in their row. Partial refusals are stated in the row.

**Tasks** 41 (was 42). **Path** 745, 285, 1,120, 840; total 2,990 (was 685, 255, 1,320, 780; 3,040). **Sessions** 339 (was 414), ceiling 678. Only pass 4 is over its line.

## What verification changed

These are the places where a probe moved a finding from what the review said.

- **M7's direction reversed.** The review feared site cases at 25 minutes and a 1,240-minute A/B. One S01-shaped session, with the harness's flags at Sonnet medium, took 147 seconds, 43 turns, and a $0.55 list estimate. It built the screen, the guard, and a role, and it ended with 8 type errors it attributed to the fixture, which M8's point explains. Pass 3 falls from 1,320 to 1,120 even after the folds add work, so F4's pass 3 half closed on evidence. It is one sample, so 3.1 and 3.3 re-estimate.
- **The same session confirmed M7's denial point and M8's fixture point.** Four tool errors, two of them a `cd` compound and a piped form, were worked around with no fault recorded. A plain `npm install` of `templates/waymark` failed on a peer conflict against the registry's `0.98.0`.
- **`.svelte` stripping.** Probed: `svelte/compiler` `compile` alone keeps script comments, so its output differs on a comment-only change. Adding `ts.transpileModule` with `removeComments` gives equal hashes for a comment change and different hashes for a code change.
- **The zone.** C4 and M19 left it open. `carin-test.org` was registered for cairn's own spikes and holds only MX and TXT records, so the question has one answer. The plan's old line that the domain and emailed sign-in have "never run live" was too broad: the spikes ran them. The pages have not been run.
- **I-m6's loop.** The ledger's line 5 says armed, but line 64 says it was stopped on purpose, so this folds as a check, not a stand-down.
- **Guidance fixtures.** The published `0.84.4` tarball ships no skills and no `cairn-guidance`, so I-M9's 0.84 fixture cannot exist. The task names the first shipping version.
- **`cairn-docs-cycle` hold.** No skip file or code change is needed. The launcher already reads `CAIRN_DOCS_CYCLE_REPO` and answers a missing directory with "nothing to launch".

## New machinery

| Item | Source | Measured defect |
|---|---|---|
| Tag ruleset on `pre-agent-first` | GitHub REST rulesets: `target` "Can be one of: `branch`, `tag`, `push`" | `gh api` returned `[]` for rulesets and 404 for branch protection; every tag URL and the eval's baseline rest on that tag |
| Branch ruleset on `standards` `main` | Same | `autoUpdate` with no `version` reaches every session from an unreviewed push |
| `guidance-hashes.json` | Debian Policy appendix E: "The comparisons are done by calculating the MD5 message digests of the files, and storing the MD5 of the file as it was included in the most recent version of the package." The design already requires the behavior | `install.ts` has only tree hashes and a site-editable path list, so "a shipped version" has no per-file data |
| `check-skill-budget.mjs` over three trees and `CLAUDE.md` | Anthropic: "Keep the `SKILL.md` body under 500 lines" and "target under 200 lines per CLAUDE.md file". The design: "What must hold every time is a gate or hook" | The gate covers only the packaged token budget |
| `gitleaks` in `standards` | The published tool, installed here | The plan named no tool; a public push cannot be fully undone |

The script forms in 2.3, 2.4, 3.5, and 1.12 are one-off pass tools, not standing machinery, and stay in the state directory. `run.mjs`'s JSONL and `--resume` are what the usage-limit standing answer already assumes: today `results.json` is written once after every job, and an abort returns before that write.

## Mechanics report

| Finding | Disposition | Where, or why |
|---|---|---|
| M1 engine cases miss the end state | folded | Root: `agent-first-3-preview` in 3.6, "The eval's shape". E1 graded by the arm's own gates. `norms.ts` moved to 3.6. Also closes C6 |
| M2 comment-only proof | folded | 3.4 takes the baseline; 3.5 and Mechanisms name the forms and exemptions. Also closes I-m1 |
| M3 wrong software in the sittings | folded | 4.8 bake and pack, `cairn` from #160's head, `/work/cairn-docs`; sitting rule's stand-ins |
| M4 auto-update acceptance | folded | 1.1, stop row, Mechanisms quote |
| M5 routine cannot be deleted | folded | Pre-flight item 7, 4.2. The `update` route was not taken: its schema is unverified and Geoff's delete does the job |
| M6 docs-process rule | folded | 1.11, "Taken" row |
| M7 suite time, denial, background | folded | Path, 3.1, Eval size; probed, see above. Timeout stays at 40 minutes |
| M8 harness spec and commands | folded | 3.1, "The commands", rerun bars |
| M9 Evaluate before its content is public | folded | Moved into 4.13; 4.4 reads the PR heads |
| M10 missing standing answers | folded | Stop table: escalable items and nine new rows, the last one general |
| M11 Lean bar vacuous | folded | Acceptance: fixed bar, TSDoc counted, tokens defined, 10 percent band |
| M12 residue fails at 4.6 | folded | Name list exemption, 4.6, 4.13; 4.7 names `cairn-writing-docs`. Also closes I-m2 |
| M13 no per-host statement | folded | Root at I-M1 |
| M14 `plan-reviewer` lens | folded | Inventory row, 1.5, 1.6 |
| M15 stacked branch conflicts | folded | Root at I-B1. The proposed pass 3 step is unneeded, since the fixes land on `main` in 1.2 |
| M16 plugin eval cases have no task | folded | 3.2 writes three; 3.6 runs them |
| M17 `content-draft` and `content-review` | folded | Inventory rows |
| M18 bare names in other repos | folded | Root at I-M2 |
| M19 zone | folded | "Taken" row; pre-flight's optional item removed |
| M20 TSDoc tags | folded | 3.4, Mechanisms |
| M21 purge conflicts with the runbook | folded | Root at I-M10 |
| M22 usage-limit wait | folded | Stop row, Path, Eval size |
| M23 fixed `standards` SHA | folded | "The eval's shape", 3.7 |
| M24 `verify` reads live state | folded | 1.7 test |
| M25 auto mode | folded | Pre-launch checks, with read-safe forms because the real commands are the tasks |
| M26 Evaluate wording | folded | Root at C8 |
| M27 MIT notices | refused | `optional`; carried by C29 |
| M28 name the scan tool | refused | `optional`; carried by C20 |
| M29 reuse the old Containerfile | refused | `optional` |
| M30 gate `--json` warnings | refused | `optional`; carried by C17 |
| OC1 1.11 to regression only | folded | Eval size, 1.11 |
| OC2 ablation to one trial | folded | Eval size, 3.3. The A/B is the retirement proof |
| OC3 smoke reused as trial 1 | folded | Eval size, 3.3, 3.7 |
| OC4 A/B baseline first | folded | 3.7, "The commands" |
| OC5 code intelligence to S01 and E1 | folded | Eval size |
| OC6 plugin eval to three skills | folded | Eval size, 3.6 |
| OC7 fold 1.2 into 1.3 | folded | Task 1.3. Number 1.2 now holds I-B1's task |
| OC8 fold 2.1 into 2.5 | refused | I-M5, I-M7, and I-M13 need the census before 2.3 rewrites what it reads; live obligations must move before removal |
| OC9 fold 4.10 into 4.9 | folded | 4.9 keeps both sittings. Later tasks renumber |
| OC10 1.5's dispatch into 1.12 | folded | 1.5, 1.12 |
| OC11 drop 4.5's spot check | folded | 4.5 |
| OC12 samples at 20 | folded | 2.3, 2.4 |
| F1 container credential | **owner fork** | Ruling 1 |
| F2 marketplace fallback | **owner fork** | Ruling 2 |
| F3 docs-process rule | folded | Taken: the design already sends `CLAUDE.md` through the A/B |
| F4 path ceilings | **owner fork** | Ruling 3, pass 4 only; pass 3 closed by the probe |
| F5 Lean target | folded | Taken: the disposition tables fix the pages, and a miss still reaches Geoff with the figure |

The 13 "departures" in that report are verdicts, not findings. The one flagged for Geoff is erratum E6.

## Contract report

| Finding | Disposition | Where, or why |
|---|---|---|
| C1 bars can close unmet | folded | Acceptance states, 14-case floor, stop row |
| C2 mapped case need not test its page | folded | 3.2 evidence and "retired without test" list; 3.8 |
| C3 nothing proves contract arrived | folded | 3.5 statement inventory and Go test |
| C4 Editor bar without email | folded | Taken: `carin-test.org` required, invited second address. Stand-in two is now limited to Part 2's site |
| C5 graders have no negative control | folded | 3.2 known-bad per case, 3.3 |
| C6 E1 grader | folded | Root at M1 |
| C7 3.8 regression and rerun bar | folded | 3.8 frozen sweep, rerun bars. Sums stay 3.7's and the PR says so, rather than a second full run |
| C8 Evaluate items with no home | folded | 4.4 brief map; items 5 and 7 reworded |
| C9 Evaluate scope vacuous | folded | 4.13 allowed reads; item 9. The list adds `docs/editors`, `docs/admin`, and `CONTRIBUTING.md`, since items 2 to 4 and 8 live there |
| C10 Contribute green without work | folded | #75, red-before test, dispatch assertion, 4.8 confirms it open |
| C11 "names only what a clone has" | folded | 1.12 one-off resolver with a seeded bad name |
| C12 "easily" unmeasured | folded | Taken: the comparison, as the design says "easier still" |
| C13 fixes unproved on merged pages | folded | 4.10 diff in the Acceptance row and retest on live sites. A fresh install is refused: it needs another App in Geoff's browser, and the retest covers the changed steps |
| C14 Part 2 has no prompt or grader | folded | 4.9 prompt, browser list, judge assertions |
| C15 editorial bar has no row | folded | "Human pages" bar, stop row, 4.10 |
| C16 no cut call | folded | 4.5 adds Cut; the keep, streamline, or rewrite step stands |
| C17 "clean" lets a session overrule | folded | Taken: blockers and majors are asks. Fixed rule list, exact warnings |
| C18 form rules not gated | folded | 1.9 budget gate; 1.3 CI line |
| C19 residue grep partial | folded | Name list patterns. Seeded hits and an export diff refused: a grep needs no proof, and `check:surface` guards exports |
| C20 scan undefined | folded | 1.1, 1.3, 1.4, 1.5 |
| C21 guidance fixtures synthetic | folded | Root at I-M9 |
| C22 lifecycle never tested alone | folded | 1.6, 1.12 |
| C23 most pages in no proof | folded | 4.5 coverage column; key rotation and one forced failure in the sittings |
| C24 fast lane negative | folded | 1.8 |
| C25 ledger sample | folded | 2.3 |
| C26 snippet fixture | folded | 3.4 |
| C27 tarball grep | folded | 4.1 |
| C28 unattached scope lines | folded | 4.1, 4.2, 4.13 |
| C29 notices and manifest path | folded | 1.3, 1.4, 1.7, `vhs-cli-demos` row |
| C30 passing-trial medians | folded | Acceptance |
| C31 engine cases unbound | folded | Contribute bar |
| C32 Geoff stands in for a reader | refused | `optional` |
| C-OC1 plugin eval | refused | `optional`; OC6 reduced it |
| C-OC2 1.11 | refused | `optional`; OC1 applied |
| C-OC3 code intelligence rule | refused | `optional`; OC5 reduced it |
| C-OC4 4.5 records calls thrice | refused | `optional` |

## Integrity report

| Finding | Disposition | Where, or why |
|---|---|---|
| I-B1 stack never reconciled | folded | New task 1.2 before pass 1 moves its paths; 4.4, 4.7. Verified by the stack diff |
| I-B2 cutover guard inverted | folded | Pass 1 "Cutover", stop row naming 1.6 and 1.7 as one unit. Erratum E1 |
| I-B3 live checkout on a feature branch | folded | Pre-flight item 1, stop row, header, 1.3. Verified: `google-sheets-tooling`, no PR, `values.age` modified |
| I-M1 `thinkpad-x1` | folded | Cutover step 5, 1.7. Also closes M13 |
| I-M2 name sweep beyond push targets | folded | Header, pass 1 order, 1.7, stop row. Live hits are cairn-themes 2, phonebook 2, dubplate 1, the rest being plans. Also closes M18 |
| I-M3 moved paths unswept | folded | Name list, 1.7. Verified: `docs-register.md` in 14 workstation files |
| I-M4 unattended cycle | folded | Pre-launch check, 3.1, 4.2, 4.13. The fix uses the launcher's existing env |
| I-M5 live work list in the removed tree | folded | 2.1 fourth class, 2.5 |
| I-M6 reduction sampled, not accounted | folded | 2.3 rules and table, 2.4 |
| I-M7 tag unprotected | folded | First act, 2.1, 2.5. Arms use the SHA, so `run.mjs` needs no compare |
| I-M8 `deletion-list.json` | folded | 2.5, 4.1, 4.2 |
| I-M9 guidance deletion | folded | 4.3. Also closes C21. The 0.84 fixture refused: that version ships none |
| I-M10 teardown | folded | 4.8 sheet, 4.12. Also closes M21 |
| I-M11 container state and App scope | folded | 4.8 bind mount and ledger duty; taken: narrowed install, since the page's step still runs |
| I-M12 eval cannot survive a crash | folded | 3.1, 3.7 wake-up. Also closes M23 |
| I-M13 filters fail open | folded | 2.1, 2.5, pass 2 header |
| I-M14 unreviewed push reaches both hosts | folded | 1.3 ruleset; taken: no pin, since the ruleset restores the gate |
| I-m1 proof contradicts its files | folded | Root at M2. A CSS normal form refused: CSS is not `auth-data`, and CI's visual baselines cover it |
| I-m2 open plans | folded | Root at M12; 2.1 states the 9 |
| I-m3 rotate-key gap | folded | 4.1, page table row |
| I-m4 no state record across repos | folded | Header ledger |
| I-m5 state on one host | folded | Evidence tables go in the PR. The resume-input copy refused: local state is the standing risk of every pass and changes no result here |
| I-m6 old loop | folded | Pre-launch check; see above |
| I-m7 ambient credentials | folded | 4.8, 4.9 |
| I-m8 token lifetime | folded | Taken: removed at 4.13. `--env-file` in pre-flight item 2 |
| I-m9 mirror creation | folded | 4.8, public |
| I-m10 revocation unverified | folded | 4.12 |
| I-m11 second plugin copy | folded | "The eval's shape", 3.1. The notices half is C29 |
| I-O1 code intelligence and plugin eval | refused | `optional`; OC5 and OC6 reduced them |
| I-O2 1.12 duplicates 4.11 | refused | `optional`; 1.12 is Contribute's interim proof |

## Rulings owed

Three, in the plan's `## Rulings owed`, each with a recommendation and what each answer builds: the container token (yes), the marketplace fallback (yes), and pass 4's ceiling of 900 (yes).

## New `[you]` items

- Pre-flight item 1: bring `~/.dotfiles` to `main`. Holds pass 1.
- Pre-flight item 7: delete the drift routine at the stage A packet.
- Added inside the sittings: narrow each App's installation, rotate the Part 1 key, bring a second address, trigger one failure.

## Owed errata

The design was not edited. Each of these changes what a ratified line says.

| Id | Design says | Plan does | Why |
|---|---|---|---|
| E1 | Pass 1: enable the plugin "in the same commit that removes the local copies" | Enables it by additive install before the merge | One commit is atomic in git, not on the machine |
| E2 | Pre-flight: "No step needs you before planning. Pass 4 has one named sitting" | Seven items and two sittings | Discovered in planning, plus Geoff's own request |
| E3 | Pass 3: "proving comment-only moves by identical emitted JS in `dist`" | A comment-stripped normal form | `dist` keeps comments |
| E4 | Pass 2 is `ordinary` | `runner` | The path map, by the gates it touches |
| E5 | "`claude plugin eval` covers the plugin's skills"; the code intelligence plugin "is tried in the treatment arm" | Three skills; two cases | Geoff's lean instruction; neither decides a retirement |
| E6 | "Skill names follow one pattern across the set" | Authored plugin skills keep their names | The namespace already separates them |
| E7 | Evaluate answers "from the README and evaluator set" | Allowed reads add `CONTRIBUTING.md`, `docs/editors`, and `docs/admin` | Brief items 2 to 4 and 8 live there |
| E8 | Pass 4 removes "the drift routine" | Geoff deletes it | An agent cannot |
