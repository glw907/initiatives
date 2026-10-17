# B1 plan review fold

Target: `plans/2026-10-17-drafter-b1-blueprint-format-plan.md`, revised in place from `2e44160`.
Reviews: `2026-10-17-drafter-b1-review-mechanics.md`, `-contract.md`, `-integrity.md`. Each finding
was checked against drafter `d3447d9` and cairn-cms `9754d6357` before its disposition. Two YAML
probes on drafter's pin (`go.yaml.in/yaml/v3` v3.0.5) reconfirmed mechanics 7 and 10. "R<n>" names
the plan's design resolution n; "S<n>" names its "Settled by the planning session" item n.

Counts over 68 findings: 59 folded or taken (six of them in part, each refused part with its
reason), 5 dropped as optional, 4 settled by the planning session (contract M2; contract m6 and
integrity 6, one ruling; mechanics 14). Path estimate 600 to 755 minutes at the fold, then 780
after the verification read below (design estimate 300, approval 900).

## Convergent findings, folded once

- The lock write on accept (mechanics 2 and 3, contract B1, integrity 1): folded as R14, written once
  by `read.go` after a run with no stop, plus the synthetic handoff in B1.4. Integrity 1's variant
  (one blueprint per run, the lock as the page's file through a `writeFiles` variant) is refused:
  it changes the page write model to keep a multi-page lock writer B1 doesn't need, and R14 leaves
  both `resume.go` and the write model untouched.
- The seat made required for every run (mechanics 4, contract M12, integrity 2): R13, with the
  merge order in Close step 7.
- The consistency read taking `*plan.Plan` (mechanics 2, contract M10, integrity 8): R9, the
  blueprint view.
- The wrong binary, module, and missing local config (mechanics 1, integrity 5): B1.5 preamble and
  step 1.
- Hash definitions (mechanics 17 and 18, contract M4, integrity 4 and 6 first three parts): R8, with
  blob ids for files, no commit field, coverage's region rule for sections, and the seed refusing a
  dirty page.

## Mechanics

1. folded: B1.5 preamble and step 1 (worktree binary, `DRAFTER_PROMPTS`, local config copy, `config --json` before spend).
2. folded: R9 and B1.4's synthetic handoff, routed to a new start step.
3. folded: R14 and B1.4's two-blueprint rows; "records the write in state" dropped.
4. folded: R13 and B1.4's `drafter page` validation row.
5. folded: R6 (module prompt plus drafter's own block, no code excerpts, no facts file) and the golden-request row.
6. folded: B1.2's pair note moves the e2e row and the cross-task `check` rows after the merge.
7. folded: B1.3 writes set fields only and keeps `items: []`; fixture gains an empty-items section.
8. folded: `convert plan --outline` reads exemplars from the JSON outline; `registerSections` dropped per R1.
9. folded: B1.2's lock check allows an accepted-only entry for an outline page.
10. folded: R3's quoting rule and decode error, and a B1.1 refusal test.
11. folded: Close step 7's `## Before merge` and step 8's merge order.
12. folded: B1.2's "can't run" rows, continue past a decode failure, `refs`' two exit-1 messages, `convert`'s title-line skip, B1.4's exit-2 row. An accepted id already equal needs no state: the write is idempotent.
13. folded in part: who sets each privileged field (B1.1 docs), `blueprints` in `allowedIn` without env (B1.2), the untrusted hand-edited id under Later. No new enforcement, since B1 has no writer that trusts those fields.
14. settled (S3): clock in the cairn worktree's git dir, removed during batch reads.
15. folded: `anatomy` names a register entry; B1.5 step 2 gives the mapping.
16. folded: `convert outline` ignores `kept`; B1.5 step 2 adds `migration-notes.md` by hand; an unmanaged entry needs only `path`.
17. folded: R8.
18. folded: R8 and B1.3 (blob id at HEAD, refuse a dirty page).
19. folded: R1 drops the blueprint's `page` block.
20. folded: R11 (one namespace, the item pattern).
21. folded: resume row stops with a batch in flight after the first page settles; `fix` row has an earlier accepted id; converted fixture has one `Only` and one plain `use`; edit-catalog fixtures must differ (B1.1); timing on 11 copies (B1.5 step 9).
22. dropped: optional, adds a heuristic check; `convert` lists heading references for the reshape instead.
23. taken: consistency and blueprint in one stage-1 batch (B1.4), which halves batch waits and makes the dry run cover the read.
24. folded: B1.5 is `runner` and `live-account`.
25. folded: B1.5 step 3 files friction in cairn's friction log; Close step 5 runs cairn-pass's close checklist.
26. folded: B1.5 step 7 commits the lock.
27. taken: the live smoke run is dropped from B1.5; the `blueprint` row reuses `AnswerRead`, already in the smoke.
28. folded: Close step 4's grep scope; the drafter PR opens ready, since it has no CI.

## Contract

- B1. folded: see convergent findings; the two-blueprint rows replace the vacuous one-blueprint resume row.
- M1. folded: B1.5 step 8, a control read with two seeded gaps after the loop ends.
- M2. settled (S1): a miss closes B1; B1.5's milestone acceptance reads "accepted, or missed with every open finding classified".
- M3. folded: R6 and the golden-request row.
- M4. folded: R8; B1.5's criterion is `git rev-parse HEAD:<blueprint>` against the committed lock.
- M5. folded: B1.1's edit-catalog test requires a difference in the row's kinds, in one section, with fact-bullet rows changing a facts file. The `refs` assertion on the changed fact is not added: B1.2's `refs` rows cover it.
- M6. folded: B1.2's failing fixture per adapted check.
- M7. folded: R10 drops "Departures" to stderr and the commit message; the read reports durable fields that narrate history; `convert` lists heading references in framing.
- M8. folded: R10 collects framing citations by matching backticked tokens against the store, with no new `facts` list to keep in step with the prose.
- M9. folded: R12 reads every stage-1 input at the run's start commit, so no refusal is needed; B1.4 row.
- M10. folded: R9.
- M11. folded: R1 (no `page` block, `registerSections` to `register.<track>`, exemplar shape).
- M12. folded: see convergent findings.
- m1. folded in part: `anatomy` names the register entry. Resolving it against the register file is refused: that parses one project's register layout in a generic tool, and the read catches a wrong name.
- m2. folded: as mechanics 16.
- m3. folded: B1.5 step 9 and its acceptance.
- m4. folded: B1.2's convention-departure warning.
- m5. folded: B1.3's suffix and judgment list, with a fixture.
- m6. settled (S2), and B1.3 refuses a page with uncommitted changes.
- m7. folded: B1.4's files list the "seven seats" docs; Close step 6 records the pipeline spec amendment.
- m8. dropped: optional. The rewritten smoke row names the seat's answer and effort anyway.
- m9. folded: B1.4's exit-2 and dry-run-writes-no-lock rows, and the `drafter read --resume` hint.
- m10. dropped: optional.
- m11. folded: B1.1's `example` fields and R4's optional `use`.
- m12. dropped: optional.
- m13. taken: as mechanics 23.
- o1. taken: as mechanics 27.

## Integrity

1. folded: see convergent findings; its own variant refused there.
2. folded: R13 and the Close merge order. A project whose `seats` omits `blueprint` can't skip the read, since `drafter read` always runs it.
3. folded in part: R12 stamps the bytes the read saw and B1.5 forbids edits during a read. The second lock field, `acceptedInputs`, is refused: B4's detection already counts a fact or outline change as a page change (call 5), so it's under Later as a B4 input, not B1 machinery.
4. folded: R8 (blob ids, no commit field).
5. folded: as mechanics 1. `make install` waits for the merge (Close step 7).
6. folded: the three mechanical parts by R8 and B1.3; the owner fork settled (S2).
7. folded: as mechanics 9.
8. folded: R9.
9. folded: the `cap` escalation and exit-3 rules in Shape's approvals; the meter reworded. The smoke cap is moot with the smoke run dropped.
10. folded: B1.3's exclusive create, refusal of an existing entry, worktree lock, and recovery note.
11. folded: lock commit (B1.5 step 7), fetch before the worktree (Shape), no edits during a read and existing facts to "Found, not done" (B1.5 step 6). The restore of an unwritten page needs no change once nothing is edited during a read.
12. dropped: optional. The dry-run half is answered by mechanics 23; the blank-line lock layout doesn't remove work.
13. folded in part: the one-executor launch check in Shape, as directed. The baseline gate stays.

## Verification read

Source: `2026-10-17-drafter-b1-fold-verification.md` (1 blocker, 1 major, 7 minors), each checked
against drafter `d3447d9`. Path 755 to 780: B1.2 130 to 140, B1.4 210 to 225.

- B-1. folded: B1.4 skips the chain's args guard (`docs-page-chain.js:606-608`) when `HOST` is set, plus a `read_test.go` row loading the real module through a `read.go` handoff. Supplying args was rejected: `:649` runs `registerSectionsFor` on each `args.pages` entry and throws on an unknown track (`:634`), and B1's outline has no track. The Workflow guard and the parity matrix (full args) are unchanged.
- M-1. folded: R10 collects a backticked token the store holds on any number of bullets, or one with the store's shared id prefix through `:`; `Facts` gains an exported count. B1.2 rows for a typo'd and a doubled framing id.
- m1. folded: R14 takes `run.TryLock` in `read.go`, writes only on no error and no stop, and leaves the file byte-identical when nothing changed.
- m2. folded: R9 names the exported `plan.Outline` constructor (B1.2 files), line 1 for page-level findings, and one `_framing-<field>` synthetic item per framing field.
- m3. folded: B1.4's prompt names neither the page nor the blueprint path; the golden row asserts no `=== file:` block for either and the blueprint's bytes once.
- m4. folded: R12 builds the resumed outline entry from `Head` read through `run.LoadState`; the facts store's fresh reload is stated as the exception.
- m5. folded: B1.5 step 8's seeded gaps must pass `drafter check`, and an accept discards the lock change.
- m6. dropped: optional, and carrying `track` adds a field now; R1 already hands the track to B3.
- m7. folded: R8 names `git rev-parse <commit>:<path>` for committed files and `git hash-object` for the new blueprint, with no call to the unexported helper.
- Planning session: Close step 6 no longer edits the initiatives repo; the drafter PR body carries the pipeline spec amendment, and the conductor commits it in its hand-over.

## For Geoff's packet

Routine rows, each settled with its reason and visible so Geoff can veto it. Nothing waits on them.

1. A missed milestone closes B1 (plan S1). A scope call: the build has its own acceptance, and pass 5's "not pilot-ready" close is the precedent.
2. Every converted page redrafts once (plan S2). It keeps call 15's letter, since the reshape is a blueprint change, but not its "at no cost": the spend lands in B3 and B4, on pages the pilot drafts anyway.
3. No `page` block; job, type, title, and path live only in the outline and the path rule (R1). The design names both homes (design:107 and :133); one home follows design:90-92.
4. No `registerSections` field (R1). `register.<track>` already holds them; B3 finds each page's track.
5. Blob ids and no commit field in the lock (R8). The lock's format is left to the builder, and a commit can't name itself. B4's hunk diff reads the blob (`git cat-file blob <id>`), not `git show <commit>:<page>` (design:306).
6. The framing's "Departures" section is dropped to the commit message (R10), per format change 4 (design:243-246).

## Rulings for Geoff

None. Every remaining choice had one answer the code or the design settles.
