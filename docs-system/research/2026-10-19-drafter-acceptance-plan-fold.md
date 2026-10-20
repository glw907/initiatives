# Fold record: drafter acceptance plan reviews

Target: `docs-system/plans/2026-10-19-drafter-acceptance-plan.md`, folded from `70ecab5`. Reviews:
`2026-10-19-drafter-acceptance-plan-review-{contract,integrity,mechanics}.md` beside this file. Each
finding was checked against drafter `6b110ad` and cairn-cms `517158fae` (and B3c's saved runs under
pavilion's drafter state directory) before it was folded. The planning session's five rulings
(2026-10-19) were applied as given: the small-finding rule follows the design's text; snippets
reach the draft seat only; an escalated page's live text gets a minimal hand edit at close; the
cairn PR lists every small-path finding verbatim with its kind; A1 runs on `opus` at `medium`.

## For Geoff

Nothing. The one design-changing finding (contract #1, mechanics F1) is settled by ruling 1, and
the plan now follows the design's text. Two folds are method calls worth naming in the packet,
though neither changes the design:

- #25 advances the lock only when the read covered the change since the last accept (integrity M2,
  plan finding 15). In this pass the condition holds for all seven, so the outcome is unchanged.
- #23's fix is cairn's `failure_pattern`, and drafter's part is a regression test (mechanics M1,
  plan finding 6). drafter's existing `ForPage` already holds a page once the sibling's line
  parses; a drafter rule on the unparsed tail can't fire on B3c's case.

## Verdicts

Counts: 60 folded, 4 folded in part, 1 pushed back, 3 dropped as optional (68 rows). A finding two
or three reviews share is folded once and marked "dup" on the later rows.

| Review and id | Verdict | Where in the plan | Note or disproving source |
|---|---|---|---|
| contract #1 | folded (ruling 1) | finding 2; A1 build and tests; Close 7 `## Decisions` | |
| contract #2 | folded | C1 #14 rule, tests (sentences 152, 225), the replay | gate-1.log of run `20261020T023009Z-7a23e89e` confirms linked paths and bare spans among the hits |
| contract #3 | pushed back | none | Under ruling 1 the small path never reaches round 2, the reader, or coherence, the only callers of `declinedFor` (`steps.go:558,628,659,705`). `leftUnresolved` (`page.go:416-428`) then reads the small exchange, which is the right set at that escalation. |
| contract #4 | folded | C3 verifier and absence greps | `drafter check` checks pointers only, as the record says |
| contract #5 | folded | Check 2 wrong-claim greps | |
| contract #6 | folded | finding 16; standing answer 8; R1 reread and check after; R5 | `skipRead` compares the blob only (`draftscope.go:111-114`) |
| contract #7 | folded | R2 step 1, one sweep before any draft | |
| contract #8 | folded | finding 9 (kind `small`, step `stSmall`, phase `covSmall`, token `s6b`); A1 record row | `findingRecord` has no `Kind` (`record.go:66-73`) |
| contract #9 | folded | C1 leak test on a temporary root | `runLeakCheck(root)` takes a root (`check-leaks.mjs:523`) |
| contract #10 | folded | finding 5; A1 zero-blocking row | `afterRound2` escalates any fix today (`steps.go:587-593`) |
| contract #11 | folded | finding 3 switch list; A1 files and schema rows | `commandBlocks` (`commands.go:27`), `shapes.go:49` |
| contract #12 | folded | A1 first test row (count and stage order) | |
| contract #13 | folded | Check 1 | `writes[].gate_fix` and `gate-<n>.log` exist (`record.go:37-50`) |
| contract #14 | folded | finding 7; A3 step 3 greps all five headers | blueprint `:301,355,382,452,467` |
| contract #15 | folded | finding 7; A1 snippet rows | `resolve` drops an untracked path (`files.go:139-142`); `fileBlock` checks no tracking (`:221-236`) |
| contract #16 | folded | A1 schema row; A2 acceptance; A3 step 1 | |
| contract #17 | folded (optional, free) | finding 8; A3 step 3 grep `no excerpt:`; Close 7 | `excerpt.go:50-82` has five forms |
| contract #18 | folded | A0 step 6 | |
| contract #19 | folded (optional, free) | C3 prompt carries factsheet section 6 rows | |
| contract #20 | folded | A1 #23 rows (sibling restored, tree red resume); C1 probe through Go `regexp` | `gate.parse` compiles with Go (`run.go:183`) |
| contract #21 | folded (optional, free) | A2 docs, behavior-sync sentence | |
| contract #22 | folded in part (optional) | A0 step 1 drops the repeated pre-flight; one named-test check at A3 | the findings section stays whole: its decisions are cited by number across the tasks |
| integrity M1 | folded | Run rules, "Background" | no signal handling (`grep signal` finds none in `cmd`, `internal`) |
| integrity M2 | folded | finding 15; A2 build and tests | `--since` skips `readBars` (`read.go:122-131`) |
| integrity M3 | folded (dup of contract #6) | standing answer 8 | |
| integrity M4 | folded, narrowed by ruling 1 | finding 9; A1 resume and hold rows | both origins now end the same way, so one phase `covSmall` and no origin field; the resume and hold rows stay, from each origin |
| integrity M5 | folded | Run rules (binary check, no commits while stopped); Close 8 backlog | `drafter_version` is written (`start.go:136`) and never read; resume loads facts fresh (`resume.go:59-63`) |
| integrity M6 | folded | C1 own worktree `acceptance-gate`; C2 commits alone | `cairn-implementer` runs `npm ci` and commits (its definition, `:11,37`); `gate-tier.mjs:8-11` fails on an empty range |
| integrity M7 | folded | Run rules, tree red; A1 test row | `pipeline.go:452-453`; `pagebp.go:186-188` |
| integrity M8 | folded | Close 2 and 5; Check 3 after every later commit | |
| integrity M9 | folded in part | Close 4 | Pushed back on the bare `~/.config` and `~/.local` patterns: drafter's `docs/configuration.md:13,118` and cairn's `docs/extend/scaffolded-site-files.md:514` document product paths there, so the grep reads added lines for `~/.local/share/cairn` and `cairn-cms.local.toml` instead |
| integrity m1 | folded | Merge order 1 | `Stopped` has `omitempty` (`run/state.go:28`) |
| integrity m2 | folded (dup of contract #18) | A0 step 6 | |
| integrity m3 | folded | Merge order 2; Close 8 backlog | |
| integrity m4 | folded in part (optional) | The meter, cap rounded down to the cent | the `DRAFTER_CYCLE_CEILING` fence is dropped as optional |
| integrity m5 | dropped (optional) | none | `spend --json` rows are per repo and seat, so no per-page spend reaches the session; the short cap fails safe as `cap` |
| integrity m6 | folded in part | A0 step 3 empty commit; abandoned runs mirrored in commit bodies | Pushed back on the host in the commit: drafter is public, and the executor prompt bars host names from both repos; the host goes in STATUS |
| integrity m7 | folded (optional, dup of mechanics M6) | A0 step 1 | |
| integrity m8 | folded (optional, free) | Run rules stall restore; R3 step 2 index check | `page.go:358-367` leaves a changed index file |
| integrity m9 | folded | finding 4; A1 record row | `missFinding` puts the kind in `Text` only (`steps.go:370-380`) |
| integrity m10 | folded | C4 acceptance `ACC check` | |
| integrity o1 | folded (optional, free) | Close 3, "once each" | |
| integrity o2 | dropped (optional) | A3 step 2 keeps the check, reason stated | the cairn worktree's `check-prompts` renders with cairn's local layer, which `make check`'s parity run on drafter's fixtures doesn't |
| integrity F1 | folded (ruling 4) | Run rules last bullet; Close 7 cairn PR; prompts | |
| mechanics B1 | folded | R1 reread and resume; Run rules page resume and stall rerun; The meter | caps read fresh on resume (`fingerprint.go:14-15`); `--since` and `--resume` exclusive (`read.go:72-74`) |
| mechanics M1 | folded | finding 6; A1 #23 test; A1 files drop `internal/gate/` | `tailLines = 60` (`run.go:22`); both gate-4 logs are 217 lines with the sibling at line 50 |
| mechanics M2 | folded | finding 7; A1 files add `files.go`; snippet rows incl. directory sources | scaffolded `:307,704` are directories |
| mechanics M3 | folded (dup of contract #6) | standing answer 8 | |
| mechanics M4 | folded (dup of contract #11) | finding 3 | `schema_test.go:65` list included |
| mechanics M5 | folded (ruling 3) | standing answers 9 and 11; C1 lane after its own commit; C3 explicit range | |
| mechanics M6 | folded | A0 step 1 pgrep | the planning session's own pgrep matched its wrapper shell |
| mechanics M7 | folded | standing answer 10; A0 step 2; A3 step 2 | |
| mechanics M8 | folded | R1 outcome and check after; R2 to R5 drafting only R1-accepted pages | a blocked change read writes nothing (`bar.go:85-90`) |
| mechanics m1 | folded | A3 step 3 | `draftscope.go:80` reads the committed lock; `start.go:128`; `client.go:81-104` |
| mechanics m2 | folded | finding 3; A1 `Link` row | Claude API docs, "Enum value casing", read 2026-10-19 |
| mechanics m3 | folded (dup of contract #10) | finding 5 | |
| mechanics m4 | folded (dup of integrity M6) | C1 own worktree | |
| mechanics m5 | folded | C1 probe, exactly line 50 | |
| mechanics m6 | folded | C1 #15 | tokenizer `/[\w./@-]+/g` (`check-symbols.mjs:314`) |
| mechanics m7 | folded | R1 fix subagent; C4 | |
| mechanics m8 | folded | Pre-flight; A0 step 1; conductor prompt | `spend --json` read 100.71 plus 0.997 at fold time |
| mechanics m9 | folded (ruling 5) | Outcome, executor models | |
| mechanics m10 | folded | finding 3; A1 `TestSchemaShapes` row | `case AnswerRead, AnswerReader2` (`schema.go:19`) |
| mechanics m11 | dropped (optional) | none | merging C4 into A3 moves no path minutes, and the separate task keeps its own commit and skip rule |
| mechanics m12 | folded (optional, dup of contract #17) | A3 step 3 | |
| mechanics m13 | folded (optional, dup of contract #16) | A2 acceptance; A3 step 1 | |
| mechanics F1 | folded (ruling 1, dup of contract #1) | finding 2 | |
| mechanics F2 | folded (ruling 2) | finding 7; standing answer 12 | |

Two cited lines had drifted and were corrected in the plan: integrity M4's `check.go:139-143`
reads `check.go:104-107` at `6b110ad`, and integrity M1's `resume.go:34-38` run lock reads
`resume.go:51`.

## Path

A2 85 (finding 15's condition and its rows), C1 100 (the replay), C3 60 (the verifier), A3 50 (C1's
merge), R1 55 (the citer rereads), and Close 75 (the leak greps, the wrong-claim greps, the hand
edits, the Check 3 reruns). The build segment stays 150, at A1. The new path is 30 + 150 + 50 + 20
+ 55 + 45 + 75 + 90 + 45 + 75 = 635 minutes, under the 800-minute ceiling.

Files changed: the plan, the executor prompt, the conductor prompt, and this record.
