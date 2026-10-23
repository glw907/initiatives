# Mail filters plan review: fold record

The fold of the three reviews of `self-hosting/plans/2026-10-22-mail-filters-plan.md` at `d9de3e5`:

- contract and criteria, `2026-10-22-mail-filters-plan-review-contract.md`, cited as `con`
- data integrity and failure risk, `2026-10-22-mail-filters-plan-review-data.md`, cited as `data`
- mechanics and feasibility, `2026-10-22-mail-filters-plan-review-mechanics.md`, cited as `mech`

Each finding was checked against Stalwart v0.16.27 (sparse clone at `aa47d8e`), sieve-rs 0.7.3, and servers `main` at `e036a70` before it was taken. A finding that several reviews raised folds once, at the root named below. The planning session settled six reviewer forks before the fold, and they fold as given. One fork stays open for Geoff, as the plan's ruling 1.

Counts: 81 findings (con 27, data 23, mech 31). 77 folded, 8 of them in part with the rest refused; 3 refused whole; 1 owner fork. The fold also found one defect no review raised (F1).

## Probes run by the fold

- sieve-rs `src/compiler/grammar/actions/action_set.rs:174-177`: a variable named `global.<x>` registers as `VariableType::Global` with no capability check beyond `variables`. `src/runtime/context.rs:628-633`: `Context::global_variable(name)` is public. So the template's `set "global.step" "N"` reaches the runner.
- sieve-rs `src/lib.rs:136`: `num_instructions` is `pub(crate)`, so a per-message instruction count can't be read. `src/runtime/mod.rs:375-381`: `with_cpu_limit` is public, so T5 measures headroom by a run at half the limit instead (mech 7's measurement).
- sieve-rs `src/runtime/mod.rs:339`: `Runtime::new` allows every capability. Stalwart `crates/common/src/config/mailstore/scripts.rs:55-95` builds the user compiler and runtime from `SieveUserInterpreter`, whose defaults are at `structs_impl.rs:36813-36845` (102400-byte script, 4096 strings, 15 nested tests and blocks, 128 local variables, 5000 CPU, 1024-byte headers, `disable_capabilities` empty). The plan's old fallback extension list is moot, and its standing-answer row is removed.
- Stalwart `crates/email/src/sieve/ingest.rs:502-520`: a runtime error is logged and the run goes on; with no keep, discard, or redirect, the message files to the Inbox.
- Stalwart `structs_impl.rs:28905-28907` and `crates/smtp/src/inbound/data.rs:520-529`: the spam filter runs only when `is_empty(authenticated_as)`. `crates/smtp/src/inbound/mail.rs:232-251`: an authenticated session's envelope sender is checked, never the header From.
- Stalwart `crates/jmap/src/sieve/set.rs:354-390`: `onSuccessDeactivateScript` clears the active script. `crates/jmap/src/vacation/set.rs:134, 281-295`: the vacation script is named `vacation`, and enabling it replaces the active script.
- Stalwart `crates/jmap/src/mailbox/set.rs:81`: `onDestroyRemoveEmails` defaults to false. `:326-333`: destroy answers `mailboxHasChild` or `mailboxHasEmail`. So prune is safe as long as it never sends the flag, and no live probe of the refusal is needed.
- Stalwart `structs_impl.rs:23293`: `set_max_objects` is 500. `:20429` and `crates/email/src/mailbox/manage.rs:128`: a folder name may run to 255 bytes per level.
- Stalwart `crates/email/src/message/ingest.rs:252`: Stalwart prepends `Delivered-To` at delivery, so the topmost one is ward's.
- sieve-rs `Cargo.toml:13`: `edition = "2024"`, so Rust 1.85 or later.
- servers `scripts/apply.sh:98`: only `base` and `roles/<listed>` reach a host (F1). `:114-118`: roles install after `secrets/render.sh`. `roles/stalwart/install.sh:13`: the Stalwart image tag lives in the repo, so a gate check can catch an upgrade.
- servers `scripts/lib/secrets.sh` exports `STALWART_PASSWORD_*` names; `secrets/templates/ward/stalwart.env:2-5` holds the same names on ward.
- servers `roles/stalwart/plan.ndjson:2`: submission is `[::]:587`, STARTTLS. `docs/cutover-log.md:87`: an unauthenticated port-25 send from the workstation reached ward.
- servers `roles/mail-backup/servers-backup:48-50`: `/var/lib/servers/backup-status.json` and `/var/lib/servers/backup/manifest.json`; `roles/mail-backup/server-restore:63-65`: `list` runs `restic snapshots`; `:163` compares counts within 10.
- servers `.github/workflows/check.yml` runs `scripts/check.sh` in full, and `scripts/check.sh:191-199`'s container leg needs podman, so CI already has it. `tests/container/image.sh` tags by a file hash.
- servers `roles/stalwart/stalwart-apply:44-48`: the 03:20 to 04:00 band refusal. `roles/health/health.sh:34`: failed units reach the heartbeat.
- servers `docs/runbook.md:434`: the `ssh geoff@ward.907.life *` allow rule.

## Convergent roots

| Root | Findings | Where the revision carries it |
|---|---|---|
| R1. Step 8 and step 9 look the same in the runner's output | con 1, data 5 | Brief fact 9; T1 sets `global.step`; T2 prints the step; T4 mapping rule 5 and its step-8 and step-9 fixtures |
| R2. A stale plan overrides Geoff's own moves | con 2, data 3, con 24 (in part) | T3 `move`: reads current `mailboxIds`, moves only a single-folder match, patches, manifest from `updated` |
| R3. Undo after prune | data 1, mech 3 | Layout `undo` by path; T3 move, prune, undo test; T7 step 6 live on `probe`; prune moves to After merge step 3 |
| R4. Prune safety | con 12, data 12, mech 17 | T3 prune paragraph and tests; Brief fact 10 |
| R5. Partial move | data 4, mech 15 | T3 batches and per-batch manifest; the "stops partway" standing answer |
| R6. Remind matching | con 3, data 9, mech 16 | Layout `delete-senders.txt`; T4 mapping rule 1, report lists, fixture; T5 count bounds and Trash expiry |
| R7. The fifth gate report | con 4, mech 26 | T4's five sections and test; T5 packet |
| R8. Proton alias check | con 15, mech 9, data 20 (in part) | Layout `signup-aliases.txt`; T2 fixture; T5 records the rewrite |
| R9. Timer, active script, band | con 8, mech 4, mech 19, mech 29, data 8 | Layout timer at 05:15; `install` and `status` verbs; band refusal; T3 tests; T6 runbook |
| R10. Comparison before the move | con 16, mech 10, data 18, data 23 | T4 `diff`; T7 steps 4 and 7; `move`'s hash check |
| R11. Runner limits and errors | con 7, mech 7, data 7 | Brief fact 7; T2 settings, `error` verdict, sieve leg at three times the correspondents; T5 half-limit run; standing answer |
| R12. The off switch and back-out | mech 1, data 6 | `deactivate` verb; `install.sh` deactivates unlisted accounts; T7 step 2 live; After merge back-out in full |
| R13. Spam test | mech 2, data 10, con 18 | Brief fact 8; T2 spam fixtures; T7 step 2 GTUBE on port 25 |

## Dispositions: contract

| # | Finding | Disposition |
|---|---|---|
| 1 | Step 8 vs 9 | Folded, R1. |
| 2 | Stale plan | Folded, R2. |
| 3 | Remind | Folded, R6. |
| 4 | Fifth report | Folded, R7. |
| 5 | "Personal-looking" undefined, misses unseen | Folded: T4 defines the report's own test and adds the misses list; two fixtures. |
| 6 | Security gate ruled by Claude (fork) | Folded as settled (fork 1): T5 runs both previews, the packet shows the hits, Geoff picks; `security-folder.txt` holds his choice. |
| 7 | Runtime limits | Folded, R11. |
| 8 | Timer skips probe-first | Folded in part, R9: a failed validate sends no `set` and exits non-zero (tested); the runbook keeps probe-first for template and helper changes. Refused: the "last verified on probe" hash marker, which is new state with no measured defect behind it, since data edits are proven by the sieve leg and the preview over the real corpus. The narrowing of design:90 is erratum E1. |
| 9 | Snapshot safeguard on later re-sorts | Folded into `move` itself: refuses a plan with no backup newer than its preview, and one older than 24 hours. T3 test. |
| 10 | Fixture answers left to the builder | Folded: T2's fixture table, with the instruction that a failing fixture is traced, never edited. |
| 11 | Duplicate system folders | Folded: T4 mapping rule 2, fixtures. |
| 12 | Prune untested | Folded, R4. |
| 13 | Flags and read state | Folded: `move` never sends a `keywords` path (T3 test); T7 step 7 re-reads every moved id's keywords. |
| 14 | Undo never run live | Folded: T7 step 6 runs move, prune, and undo on `probe`. |
| 15 | Proton aliases | Folded, R8. |
| 16 | T7 tolerances | Folded, R10: diff by id in step 4; step 7 re-reads each moved id rather than per-folder arithmetic, which is exact and needs no tolerance. |
| 17 | End-to-end list half on probe | Folded as settled (fork 5): T7 step 3 sends a list post to `geoff@907.life`; After merge deletes it by Message-ID and prunes its folder. |
| 18 | Offline spamtest | Folded, R13: corpus runs with spamtest unknown; mapping rule 4 keeps a Junk verdict in place. |
| 19 | No-body rule unenforced | Folded: the sieve leg greps for `body` and `:contents`. |
| 20 | Builder-verify facts | Folded: T5 records List-Post separation; T7 steps 2 and 3 exercise Sieve's header reads live. |
| 21 | T3 acceptance trivial | Folded: replaced by the role's own tests, among them `install.sh` with an empty accounts file. |
| 22 | After-merge hash drifts | Folded: compared with `render geoff` at check time. |
| 23 | T6 acceptance, probe testing | Folded: T6 covers testing on `probe` and names every verb. |
| 24 | Multi-folder messages, `:create` parity | Folded: `move` skips a message in two folders; T1 caps list names at 64 bytes, under ward's 255. |
| 25 | T2 `ordinary` (optional) | Refused: the runner decides where Geoff's mail goes, and mech 25 argues the opposite way for T1; the task-scope read stays. |
| 26 | Six decisions entries (optional) | Folded, free: one entry citing the research and this record. |
| 27 | Leg cache (optional) | Folded, free: the cache requirement and "cached time" are gone; CI's podman is proven by the container leg. |

## Dispositions: data

| # | Finding | Disposition |
|---|---|---|
| 1 | Undo breaks after prune | Folded, R3, with prune moved to After merge. Refused: a separate prune manifest, since undo recreates folders by path from the move manifest. |
| 2 | System folders not excluded | Folded: `export` leaves out role folders other than Inbox and Archive; `move` refuses a role-folder source and a target outside the allow-list; T3 tests. |
| 3 | Concurrent changes | Folded, R2. |
| 4 | Partial run | Folded in part, R5: per-batch manifest, band refusal, idempotent rerun, a failing-batch test. Refused: a detached `systemd-run` move, retry with backoff, and a lock, since the per-batch manifest and the current-state check already make a rerun safe. |
| 5 | Step 8 vs 9 | Folded, R1. |
| 6 | Off switch | Folded, R12. |
| 7 | Limits and growth | Folded in part, R11. Refused: a warning past 75% of 100 KB, which the three-times fixture in the gate covers. Ward's runtime-error path was read at the fold (Brief fact 7). |
| 8 | Timer can install a degraded script | Folded in part, R9: `render` fails on a JMAP error or an empty list; compare with the active script, not a local file; schedule outside the band; non-zero exit reaches the heartbeat. Refused: the 10% shrinkage check, which needs a stored count and answers no observed failure; a JMAP error, the realistic cause, already fails the run. The design:90 narrowing is erratum E1. |
| 9 | Remind match and expiry | Folded in part, R6, with the expiry period in the packet. Refused: capping Deleted Items moves at the approved count, since `move` applies only the plan's listed ids; and copying the Remind slice of the manifest, an optional backup measure. |
| 10 | Spam step untested | Folded, R13, with fixtures at 9, below, at, and above the threshold. |
| 11 | Upgrade breaks parity | Folded, as a gate check rather than a runtime one: the sieve leg fails when `roles/stalwart/install.sh`'s tag differs from `tools/sieve-run/stalwart-tag`, and `preview` refuses when ward's image tag differs. |
| 12 | Prune can destroy mail | Folded in part, R4. Refused: a live probe that Stalwart refuses to destroy a folder with mail, since the source shows it (`mailbox/set.rs:326-333`). |
| 13 | Unread or flagged Inbox mail (fork) | Owner fork, open: the plan's ruling 1. The tasks build the recommended answer, flagged mail stays and unread automated mail moves, and the packet lists every message leaving the Inbox. |
| 14 | Later re-sorts and Geoff's own filing (fork) | Folded as settled (fork 2): `legacy-folders.txt`; T4 mapping rule 5 moves personal and step-9 mail to Archive only from a legacy folder. Erratum E2. |
| 15 | Backup check and wording | Folded: T7 step 5 compares the backup manifest's count; the order is re-preview, backup, move, so the snapshot is newer than the plan applied; T6 names undo as the rollback. |
| 16 | Role-address parity live | Folded: T1 matches role addresses on To as well; T7 step 3 sends to `dmarc-reports@` and records the stored `Delivered-To`; T2 feeds the envelope sender from `Return-Path`. |
| 17 | Twin list folders | Folded: `move` finds a folder by exact path and re-reads on "already exists". |
| 18 | Export paging, render source | Folded in part: `move` refuses a plan whose script hash isn't the active one's. Refused: `queryState` paging, since a skipped or repeated export line is harmless under `move`'s current-state check, and `export` de-duplicates by id. |
| 19 | Manifests outside the backup (optional) | Refused: optional, and not free. |
| 20 | Dropped requirements | Folded: Proton at R8; the Spam folder at con 11. |
| 21 | Own addresses as correspondents | Folded: `correspondents` leaves out the login and aliases; T2 fixture. |
| 22 | Step order vs GitHub | Folded: T1 says step 6 leaves out category-domain senders. |
| 23 | Over-ceremony (optional) | Folded, free: con 26 and R10. |

## Dispositions: mechanics

| # | Finding | Disposition |
|---|---|---|
| 1 | Back-out can't run | Folded, R12. |
| 2 | GTUBE can't pass | Folded, R13. |
| 3 | Undo after prune | Folded, R3. |
| 4 | Active-script authority (fork) | Folded as settled (fork 3, option a): `install` re-installs and re-activates, but not while `vacation` is active (logs "filtering paused"); T6 says filters change only through the data files. Erratum E3. |
| 5 | Hold line never set | Folded: T7 step 2. |
| 6 | Live commands not in full | Folded: T7's sends, reads, backup check, and the ssh forms of the move and prune. |
| 7 | Runner parity, size standing answer | Folded, R11, with the per-message count replaced by the half-limit run (the count isn't public). |
| 8 | T1 can't meet its test | Folded: the renderer moves into T1; measurement moves to T5. |
| 9 | Proton check | Folded, R8. |
| 10 | Count comparison stops for nothing | Folded, R10. |
| 11 | Packet storage, codes in subjects | Folded as settled (fork 4): the packet stays under `$XDG_RUNTIME_DIR/mail-filters/`, never committed; full subjects in the sample, digits masked in security hits. |
| 12 | Classifier hold, password source | Folded as settled (fork 6): `secrets_load` for `STALWART_PASSWORD_GEOFF`; the move runs as an ssh command under the existing rule; `claude-pass` is gone. Erratum E4. |
| 13 | No answer for an unmet bar or a spent guard | Folded: two standing-answer rows. |
| 14 | End-to-end narrowed (fork) | Folded as settled (fork 5); see con 17. |
| 15 | Partial move | Folded, R5. |
| 16 | Remind and Spam merge in no task | Folded: R6 and con 11. |
| 17 | Prune tests | Folded, R4; the pruned folders are recorded in After merge step 3. |
| 18 | Workstation env | Folded: the Layout names `STALWART_ACCOUNTS`, the env file's key, and `MAIL_FILTERS_DATA`. |
| 19 | The backup band | Folded, R9: verbs refuse the band, the timer runs at 05:15, a standing answer waits until 04:00, and T7 step 5 notes the brief stop. |
| 20 | Entry pulls an unpicked digest | Folded: Entry pulls `rust:1` and states Rust 1.85 or later. |
| 21 | CI rebuilds cold (optional) | Folded, free: the image tag follows `tests/container/image.sh`. |
| 22 | New fake JMAP server (optional) | Folded, free: tests use the existing fake `curl`. |
| 23 | Backup older than the final dry run | Folded: T7 re-previews before the backup. |
| 24 | Runner details | Folded: topmost `Delivered-To`, `Return-Path`, `:create` on every `fileinto`, `--network=none`, label off. |
| 25 | T1's `ordinary` marker | Folded: T1 carries the design's class. |
| 26 | Other report dropped | Folded, R7. |
| 27 | Test-id and probe folder cleanup | Folded: every T7 message goes to `mail-test-ids.sh`; After merge prunes `probe`. |
| 28 | tmpfs size (optional) | Refused: optional; the reviewer's own estimate, a few hundred MB, fits the 1.6 GB tmpfs. |
| 29 | Timer runs only `geoff` | Folded: the timer iterates the accounts file. |
| 30 | T7 tight (optional) | Folded, free: T7 is re-estimated at 130 in the re-total. |
| 31 | IMAP resync (optional) | Folded, free: one clause in the packet. |

## Found by the fold

- **F1.** The plan put the data and the template at the repo root, `mail-filters/`. `scripts/apply.sh:98` ships only `git ls-files base roles/<listed>`, so ward would never get them, and the role's helper would have nothing to render. Folded: they move to `roles/mail-filters/data/`.

## Owed errata to the design

The design is unedited. These are changes of meaning the revised plan carries, for the design's owner to record:

- **E1** (design:90, "Every change is ... tested on the `probe` account first, and activated only after a probe delivery succeeds"). The plan keeps probe-first for template and helper changes. A data edit is proven by the sieve leg and the preview over the real corpus, and installs through the same path the timer runs daily; the timer's correspondent refresh has no probe delivery.
- **E2** (design:99-100, "In any other user folder, it moves to Archive"). Only folders in `legacy-folders.txt` send personal and step-9 mail to Archive; a later re-sort never moves mail out of a script destination for that reason (planning fork 2).
- **E3** (design silent). The managed script is authoritative and the timer re-installs it over any other edit, and filtering pauses while a vacation reply is on (planning fork 3) Turning a vacation reply off leaves no script active, so mail lands unfiltered in the Inbox until the next 05:15 run or a hand-run `install geoff` (verification 13).
- **E4** (design:127, "read through `claude-pass`"). The workstation reads `STALWART_PASSWORD_GEOFF` with `secrets_load` (planning fork 6).
- **E5** (design:123, "it doesn't ship, and security mail falls back"). Geoff picks between the two previews; the fallback is his call, not a rule (planning fork 1).
- **E6** (design:94-98, every message is re-filed), conditional on ruling 1: flagged Inbox mail stays under either answer, and with a no, unread Inbox mail stays too.
- **E7** (design:74, the always-Inbox list "adds senders by hand" to the known correspondents, who reach the Inbox only when the message "isn't automated"). An always-Inbox sender reaches the Inbox even with bulk markers, which is what the list's name promises (verification 12).
- **E8** (design:77, step 8's bulk markers). Step 8 tests the same automated markers as step 5, email-provider stamps included, so a stamped receipt from an unknown domain reaches Other at step 8 and a re-sort moves it, rather than leaving it at step 9 (verification 22).
- **Moot: deactivating other operators' scripts** (verification 2, design:17). The verification fold names the managed script `mail-filters` and deactivates only that script, so operator2's mailbox and any vacation reply are untouched and no erratum is owed.

## Not verified

- That `mail.907.life` is a name on the certificate ward presents on port 587. The plan takes it from the JMAP URL; T7 step 2's first send proves it or names the fix.
- The Trash expiry period on ward; T5 reads it.
- That ward's JMAP session advertises `maxObjectsInSet`; the default is read from source, and `move` takes the session's value.
- How Proton Pass rewrites `m.907.life` headers; T5 reads it from the corpus.

## Verification fold

The fold of `2026-10-22-mail-filters-fold-verification.md`: 23 findings, no blockers. Each was checked in source before it was taken.

Probes: `crates/email/src/mailbox/manage.rs:94-110` trims and lowercases each path component; `crates/jmap/src/mailbox/set.rs:589-601` refuses a case-insensitive sibling with `alreadyExists`; sieve-rs `src/runtime/context.rs:122-130` counts one per executed instruction; `crates/email/src/message/delivery.rs:46-48` sets spam at 50; Stalwart `Cargo.lock:4724-4725` pins `mail-parser` 0.11.9; `crates/smtp/src/inbound/data.rs:763-772` adds `Return-Path`; servers `roles/stalwart/stalwart-status:3-5` prints counts without Trash and Junk.

Counts: 22 folded, 0 refused, 1 optional folded because it is free. Path: T2 120 to 125, T3 170 to 180, T7 130 to 135; the planned path is 715 minutes.

| # | Finding | Disposition |
|---|---|---|
| 1 | Rerun rows loop on the backup check | Folded: both rows say "rerun T7 steps 4 and 5, then the move"; T7 step 4 counts ids the manifest already moved as done. |
| 2 | `install.sh` deactivates operator2's scripts | Folded: the managed script is named `mail-filters`, `deactivate` clears only that, and a T3 test covers an unlisted account with `vacation` or another script. Its erratum is moot. |
| 3 | `render` refuses probe's empty list | Folded: the empty-list refusal is dropped and `render` fails only on a JMAP error, with a T3 test for each case. Data 8's realistic cause, a JMAP hiccup, is still caught; a per-account minimum would be new data that answers no measured defect. |
| 4 | Cross-host render hash drift | Folded: the helper runs with `LC_ALL=C` and `jq -c`; a T3 test compares two locales; T7 step 3 also compares the workstation's render. |
| 5 | Exact-path matching vs Stalwart's | Folded: `move` and `undo` match as `fileinto :create` does (Brief fact 3), and a T3 test resolves `Lists/Foo` and `Lists/foo` to one folder. T1 keeps the List-Id's case, since lowercasing every list name reads badly and the matching already merges variants. |
| 6 | CPU standing answer trims contacts | Folded: the row is split; a CPU error means restructuring the template. Brief fact 7 states the per-instruction count. |
| 7 | Plan and packet in tmpfs over the wait | Folded as a standing-answer row: re-preview and compare counts with the packet. Moving them to `~/.local/state` was not taken, since planning fork 4 placed the packet under `$XDG_RUNTIME_DIR`. |
| 8 | Fact 9's key | Folded: the key is `step`. |
| 9 | `body` grep hits `nobody@` | Folded: the leg matches a `body` test or a `"body"` requirement as a token. |
| 10 | Unknown correspondent count | Folded: a fixed 4,000-address fixture. |
| 11 | mail-parser unpinned | Folded: `mail-parser = "=0.11.9"`, cited. |
| 12 | Always-Inbox overrides automated | Folded as erratum E7; the fixture stays. |
| 13 | Gap after a vacation ends | Folded: E3 and T6 say so. |
| 14 | Probe undo can't match "before" | Folded: the probe move targets the notification case's existing folder, and the comparison is by path and count. |
| 15 | Keyword check vs Geoff reading mail | Folded: `move` records keywords from its per-batch read, and T7 step 7 compares with those. |
| 16 | Loop lacks the backup; probe-first pauses Geoff | Folded: T6's loop adds the backup and one sentence on the pause. |
| 17 | Crafted list posts' To | Folded: T2's note and T7 steps 2 and 3 put the list address on To and the recipient on RCPT only. |
| 18 | Unquoted mechanisms | Folded: T5 records the `Delivered-To` values on migrated mail; the threshold, `spam_status`, and `Return-Path` are cited; T7 step 5 reads `stalwart-status counts`. |
| 19 | A role failure aborts later roles | Folded: `install.sh` fails only on its own files and starts `mail-filters-refresh.service`, whose failure never fails the apply. |
| 20 | Ruling 1's premise unquantified | Folded: ruling 1 and T5's packet carry the unread and flagged counts of the automated mail leaving the Inbox. |
| 21 | `undo` ignores the band | Folded: `undo` joins the refusing verbs and the band row. |
| 22 | Step 8 narrower than step 5 | Folded: step 8 uses step 5's markers, a T2 fixture covers a stamped receipt, and erratum E8 records it. |
| 23 | Layout gaps (optional) | Folded, free: `roles/mail-filters/accounts` is named; only the run is network-less. |
