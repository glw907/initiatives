# Mail filters plan: fold verification

Target: `self-hosting/plans/2026-10-22-mail-filters-plan.md` as revised by the fold (`2026-10-22-mail-filters-plan-review-fold.md`), read against the three reviews and the design (`self-hosting/specs/2026-10-22-mail-filters-design.md`). Sources checked: Stalwart v0.16.27 (sparse clone), sieve-rs 0.7.3, and servers at `e036a70`, all read-only. No server contacted. The reader had no part in the fold.

Verdict: not ready to approve as folded. There are no blockers. Six majors remain. Two are contradictions the fold itself introduced: the rerun standing answers conflict with `move`'s backup check, and the Layout's deactivate rule conflicts with T3's own test. Four are mechanisms that fail against the source or against the probe account. Each fold is a sentence or a test, and none adds machinery.

## Answers to the five asks

1. **Did each blocker and major close at the cited location?** Mostly yes. R1 through R13 are each present where the fold record says. Five closed incompletely: R5 and R2 interact with the new backup check (finding 1), R12's deactivate reaches beyond Geoff's mailbox (finding 2), data 8's empty-list refusal also catches the probe account (finding 3), data 17's exact-path lookup doesn't match how Stalwart matches folders (finding 5), and R11's standing answer gives the wrong remedy for a CPU overrun (finding 6).
2. **Did the fold introduce a contradiction, or a task order that can't build?** Two contradictions (findings 1 and 2). The task order builds: the T1 and T2 pair, then T3, T4, T5, and T6 each depend only on earlier tasks, and the path arithmetic (515 + 180 = 695) holds.
3. **Is every new mechanism quoted from source?** The Brief facts check out against source: 3, 5, 7, 8, 9, 10, and 11, and T3's `maxObjectsInSet` of 500. Fact 9 states the read-back key imprecisely (finding 8). The unquoted mechanisms are the `X-Delivered-to` fallback, the spam threshold, the source of `Return-Path`, and the "live count" (finding 18). The proof the plan relies on for Fact 3 leaves out the case-insensitive folder match (finding 5).
4. **Can Geoff rule the open fork on the evidence given?** Yes. It is a taste call with a clear default, and the packet lists every Inbox leaver before anything moves. One premise is unquantified (finding 20).
5. **Are the recorded errata complete?** E1 through E6 are accurate and correctly located. Three changes of meaning are missing: deactivating other operators' scripts (finding 2, unless that is folded away), always-Inbox overriding the automated test (finding 12), and the unfiltered gap after a vacation ends (finding 13).

## Findings, ranked by consequence

### 1. The rerun standing answers can never satisfy `move`'s backup check
- Severity: major. Tag: correctness.
- Location: plan:198, plan:199; against plan:119 and plan:164-166.
- Defect: `move` refuses a plan with no backup newer than its preview time (plan:119). The rows for "stale plan or hash mismatch" and "stops partway" say to rerun T7 step 4 (a new preview) and then the move. The new preview is newer than step 5's backup, so `move` refuses again. Following the table literally loops, or ends at a stop the table doesn't name. The fold introduced this by adding the backup check to `move` (contract 9) without updating the rows it already had.
- Fold: both rows read "rerun T7 steps 4 and 5, then the move". For the partial-move row, the T7 step 4 diff also accepts ids the manifest already moved, counted as done.

### 2. `install.sh` deactivates the active script of every unlisted mailbox, operator2's among them
- Severity: major. Tag: correctness.
- Location: plan:59 ("`deactivate` for each `accounts.json` mailbox the file doesn't list"), plan:72 (`deactivate` takes no condition), plan:126 (the test says "with an active managed script"); design:17 and design:25.
- Defect: the Layout and the verb deactivate unconditionally, while the test assumes a managed-script check. `roles/stalwart/accounts.json` lists `operator2`, `probe2`, and, when unlisted, `geoff`, each with `mailbox: true`. As written, every ward apply from every pass logs in as operator2 and clears his active script, whether that's a vacation reply or a filter he wrote. Clearing is unconditional for an active script (`crates/jmap/src/sieve/set.rs:384-389`). That breaks "the second operator's mailbox is untouched", and no erratum records it. The same rule clears a vacation reply on Geoff's account when T7 step 2 applies with only `probe` listed.
- Fold: give the managed script a fixed name (for example `mail-filters`). `deactivate` clears only when the active script has that name, and otherwise does nothing. `install.sh` calls it only for accounts that hold a script of that name. T3 test: an unlisted account whose active script is `vacation`, or has another name, gets no `SieveScript/set`.

### 3. `render` refuses an empty correspondent list, and `probe` probably has one
- Severity: major. Tag: correctness.
- Location: plan:67 ("Fails on ... an empty correspondent list"), plan:162 (T7 step 2 installs on `probe`), plan:196.
- Defect: the refusal answers data 8, a degraded script on Geoff's account. It also applies to `probe`. Nothing in the servers repo shows that `probe` has contacts or Sent Items, and T7's curl sends store nothing in Sent. If `probe`'s list is empty, `install probe` fails, T7 step 2 can't pass, and the plan's own row (plan:196) closes the pass with `## Bar unmet` and no re-sort. The daily timer would also fail on `probe` every day, which raises a failed unit in the heartbeat.
- Fold: the accounts file carries a minimum correspondent count per account (for example `geoff 50` and `probe 0`), and `render` refuses below that minimum or on any JMAP error. Alternatively, refuse only on a JMAP error or a missing Sent Items folder. T3 test: `probe` with zero addresses renders, and `geoff` with zero fails.

### 4. The workstation render and the ward render may never hash equal, so `move` would always refuse
- Severity: major. Tag: correctness.
- Location: plan:68 ("sorted, de-duplicated"), plan:77 (phase A renders on the workstation), plan:119 (`move` refuses a hash that isn't the active script's), plan:166.
- Defect: the plan header carries the hash of the workstation's render (T7 step 4), and `move` compares it with the script that ward's `install` rendered. Both renders run the same code over the same JMAP data. But `sort` collates by locale (the workstation's `en_US.UTF-8` against ward's sudo or systemd environment), and jq versions can differ, so the bytes can differ. Nothing checks this before T7 step 6. When it fails, finding 1's loop follows. T7 step 3 compares two renders that both run on ward, so it can't catch the gap.
- Fold: the helper exports `LC_ALL=C` and pins its jq output form. T3 test: renders under `LC_ALL=C` and `en_US.UTF-8` are byte-identical. T7 step 3 also checks that the workstation's `scripts/mail-filters.sh` render hash equals `status geoff`.

### 5. `move` finds folders by exact path, while Stalwart matches them case-insensitively and trimmed
- Severity: major. Tag: correctness.
- Location: plan:119 ("finds a target folder by its exact path, creates it when missing, and on 'already exists' reads the folder list again"); plan:15 (Fact 3).
- Defect: `fileinto :create` resolves each path component lowercased and trimmed (`crates/email/src/mailbox/manage.rs:94-110`). `Mailbox/set` create refuses a sibling whose name matches case-insensitively (`crates/jmap/src/mailbox/set.rs:589-601`). List-Ids vary in case between messages, so the runner can return both `Lists/Foo` and `Lists/foo`. Live delivery files both into one folder. `move` creates `Lists/Foo`, then fails to create `Lists/foo` with "already exists", re-reads the list, still finds no exact match, and either stalls or errors. The pre-move diff compares by message id, so the case drift wouldn't show there.
- Fold: `move` and `undo` resolve paths as `mailbox_create_path` does: split on `/`, trim each component, and compare lowercased (cite `manage.rs:94-110`). T1 also lowercases or normalizes the derived list name. Add a T3 case-variant test, which data 17 asked for.

### 6. The CPU standing answer trims contacts, which can't lower CPU use
- Severity: major. Tag: correctness.
- Location: plan:192, plan:148.
- Defect: sieve-rs counts one instruction per executed test, whatever the length of the key list (`src/runtime/context.rs:126-130`; `Instruction::Test` runs once per test). Trimming Sent Items correspondents therefore lowers script size but never CPU use. A half-limit `error` from T5 would send the executor to trim correspondents until none remain, and every one dropped is a person whose mail no longer reaches the Inbox. That is the design's first anti-goal. The error itself fails safe: ward files the message to the Inbox (`crates/email/src/sieve/ingest.rs:517-519`).
- Fold: split the row. An over-size script trims Sent Items correspondents by age, as written. A CPU error at half the limit means restructuring the template (fewer tests on the common path), never trimming, and a traced cause otherwise stops the pass.

### 7. The approved plan and packet live only in tmpfs, across an unbounded wait
- Severity: minor. Tag: correctness.
- Location: plan:141, plan:152, plan:164.
- Defect: `$XDG_RUNTIME_DIR` is cleared at logout and at reboot. The wait for Geoff's approval is off the path and may span a reboot. T7 step 4 diffs against the approved plan, and no row covers its loss.
- Fold: keep the plan, packet, and corpus under a 0700 directory in `~/.local/state/mail-filters/`, deleted at close. Or add a row: if the approved plan is gone, re-preview, compare per-destination counts with the packet, and stop for the conductor on any difference.

### 8. Fact 9 names the read-back key ambiguously
- Severity: minor. Tag: correctness.
- Location: plan:21.
- Defect: `set "global.step"` registers `VariableType::Global("step")`, with the namespace stripped and the name lowercased (sieve-rs `src/compiler/grammar/actions/action_set.rs:174-177`). The runner must call `global_variable("step")`. A call to `global_variable("global.step")` returns `None`, so every verdict comes back without a step.
- Fold: Fact 9 says the key is `step`.

### 9. The sieve leg's `body` grep fails on legitimate data
- Severity: minor. Tag: correctness.
- Location: plan:87.
- Defect: a plain substring match on `body` hits addresses and domains (`somebody@`, `nobody@`, `anybody.com`) from the data files and the correspondent list.
- Fold: fail on `"body"` in a `require` list, or on the token `body` followed by a tag, never on the bare substring.

### 10. "Three times Geoff's surveyed count" refers to a count no document gives
- Severity: minor. Tag: correctness.
- Location: plan:87.
- Defect: the design and the prior-art research give no correspondent count. T2 runs before T5 measures one, and it's a pair task that can't read Geoff's mailbox.
- Fold: a fixed fixture size, for example 4,000 addresses (about 100 KB at roughly 25 bytes each). Or the leg asserts the byte budget per address and T5 records the real count.

### 11. The runner doesn't pin mail-parser to Stalwart's version
- Severity: minor. Tag: correctness.
- Location: plan:60, plan:87.
- Defect: Stalwart parses the message itself and hands it to `filter_parsed` (`crates/email/src/sieve/ingest.rs:127`). Its lock pins `mail-parser` 0.11.9 (`Cargo.lock:4724-4725`). sieve-rs asks only for `0.11` (`Cargo.toml:75-77`), so a fresh lock may resolve a newer patch, and the "same interpreter" claim then rests on an unpinned header decoder.
- Fold: `mail-parser = { version = "=0.11.9", features = ["full_encoding"] }` in `tools/sieve-run/Cargo.toml`, with the source cited.

### 12. Unrecorded erratum: always-Inbox overrides the automated test
- Severity: minor. Tag: correctness.
- Location: plan:109 (fixture: "An always-Inbox sender with bulk headers, 5, Inbox"); design:69-74.
- Defect: in the design, the always-Inbox list adds senders to the known correspondents. A known correspondent reaches the Inbox only when the message "isn't automated". The fixture makes the list override bulk headers. That's a reasonable reading of the list's name, but it changes the design's meaning without an erratum.
- Fold: add E7 to the fold record: "always-Inbox senders reach the Inbox even with bulk markers". Or change the fixture to the design's reading.

### 13. E3 leaves out the unfiltered gap after a vacation reply ends
- Severity: minor. Tag: correctness.
- Location: fold record E3; plan:71, plan:154.
- Defect: turning a vacation reply off clears the active script (`crates/jmap/src/vacation/set.rs:290-295`). Mail then lands unfiltered in the Inbox until the next 05:15 run reactivates the managed script, which can be close to a day. This fails safe, but Geoff will notice it.
- Fold: one clause in E3 and in T6's runbook: after a vacation, run `install geoff` or wait for the next morning's run.

### 14. The probe undo check can't match "the state before"
- Severity: minor. Tag: correctness.
- Location: plan:166.
- Defect: the move creates `Notifications/Other` on `probe`, which no step-2 case fills. After prune and undo it stays as a new, empty folder, and the recreated list folder has a new id. So "`folders probe` matches the state before" fails as written.
- Fold: compare paths and per-folder counts, ignoring empty folders, or move the post to the notification case's existing category folder.

### 15. T7 step 7's keyword check fails if Geoff reads mail during the run
- Severity: minor. Tag: correctness.
- Location: plan:167.
- Defect: the comparison is against step 4's export. Hylki sets `$seen` whenever Geoff reads a message in the meantime.
- Fold: `move` records each message's keywords from its per-batch read in the manifest, and step 7 compares against those.

### 16. T6's loop leaves out the backup, and probe-first switches off Geoff's filtering
- Severity: minor. Tag: correctness.
- Location: plan:154.
- Defect: the loop reads "edit, preview, apply ward, re-sort", but `move` refuses without a backup newer than the preview, so a later re-sort needs `systemctl start servers-backup.service` (a brief Stalwart stop) or must wait for the nightly run. Separately, "apply with only `probe` listed" deactivates Geoff's script for the test window. That's safe, since spam still reaches Junk without a script, but the runbook doesn't say so.
- Fold: add the backup step to the loop, and one sentence on the pause.

### 17. The crafted list posts must not carry the recipient on To or Cc
- Severity: minor. Tag: correctness.
- Location: plan:162 (the step-2 list post), plan:163 (the end-to-end list post).
- Defect: at step 5, a list post with Geoff (or `probe`) on To or Cc is personal and goes to the Inbox. Unless the header To is the list address, the design's end-to-end check lands in the Inbox and reads as a failure.
- Fold: state the headers. To is the list address, the recipient appears only on RCPT, and List-Id and a mailto List-Post are present.

### 18. Unquoted mechanisms
- Severity: minor. Tag: correctness.
- Location: plan:87, plan:113, plan:165.
- Defect and fold, item by item:
  - The `X-Delivered-to` fallback has no source. Also, the topmost `Delivered-To` on 30,000 migrated messages is Fastmail's, not ward's. T5 should record the values seen. Only step 3 reads the envelope, and it also matches on To.
  - The spam threshold is never stated. It's 50 (`crates/email/src/message/delivery.rs:46-48`; `spamfilter.rs:701-715`). The runner should build the fixture status exactly as `spam_status` does (`spamfilter.rs:98-104`).
  - `Return-Path` as the envelope sender: Stalwart adds it at SMTP (`crates/smtp/src/inbound/data.rs:763-772`). Cite it.
  - Geoff's "live count" in T7 step 5 should be `stalwart-status counts`, the same reader `servers-backup` uses (`roles/mail-backup/servers-backup:121-123`), which leaves out Trash and Junk.

### 19. A failure in the mail-filters role aborts every later role in a ward apply
- Severity: minor. Tag: correctness.
- Location: plan:59, plan:117; `scripts/apply.sh:121-124` (`die` on the first role that fails).
- Defect: `mail-filters` installs between `stalwart` and `health`. If its `install.sh` fails on a per-account install (a JMAP hiccup right after a Stalwart restart, or finding 3's refusal), `health`, `cloudflared`, and `mail-backup` don't install in that apply. That affects other passes' deploys.
- Fold: `install.sh` fails only when its own files fail to install. It starts `mail-filters-refresh.service` for the per-account installs, and a failure there reaches the heartbeat. T7 reads `status`, so that check is unchanged.

### 20. Ruling 1's premise is unquantified
- Severity: minor. Tag: correctness.
- Location: plan:31.
- Defect: "most automated mail in the Inbox was never opened" has no number behind it. Geoff can still rule, but the yes-or-no question is cheap to back with counts.
- Fold: T5's packet adds the count of unread and of flagged Inbox messages that would leave under each answer, and Geoff may revise the ruling at the preview sitting.

### 21. `undo` doesn't refuse the backup band
- Severity: minor. Tag: correctness.
- Location: plan:63.
- Defect: `undo` moves mail just as `move` does, so a run that crosses 03:30 meets a stopped Stalwart in the middle of a batch.
- Fold: add `undo` to the verbs that refuse 03:20 to 04:00.

### 22. Design-level: step 8's bulk markers are narrower than step 5's automated test
- Severity: minor. Tag: correctness. This predates the fold.
- Location: design:72, design:77; plan:85, plan:138.
- Defect: a receipt with an ESP stamp but no List-Unsubscribe, no `Precedence`, and no no-reply sender fails step 5 and skips step 8. At step 9 it lands in Other. In a re-sort, a step-9 verdict stays put, so receipts like this already in the Inbox stay there. That cuts against "everything automated gets sorted", and the 623-message Inbox is where they sit.
- Fold: step 8 uses the step-5 automated test as its marker set. Record that as an erratum, or as a `## Decisions` line, and add a T2 fixture: an ESP-stamped receipt from an unknown domain gives step 8, Other.

### 23. Small Layout gaps
- Severity: minor. Tag: optional.
- Location: plan:59, plan:87.
- Defect and fold:
  - The repo file that becomes `/etc/servers/mail-filters/accounts` is never named. Name it, for example `roles/mail-filters/accounts`, and say that `install.sh` copies it.
  - "Build and run in the pinned container with `--network=none`": the cargo build fetches crates, so only the run is network-less. Say so.

## Verified at this read

- Fact 3: `manage.rs:126-131` checks each component against `mailbox_name_max_len`, which defaults to 255 (`structs_impl.rs:20429`).
- Fact 5: `sieve/set.rs:354-390`. A script create or update activates itself only when `isActive` is sent (`:147-149`, `:482-484`), so a separate activation request holds as planned.
- Fact 7: `scripts.rs:55-95` and the defaults at `structs_impl.rs:36813-36845`; the error path at `ingest.rs:507-519`.
- Fact 8: `structs_impl.rs:28905-28907`.
- Fact 10: `mailbox/set.rs:81` and `:326-333`.
- Fact 11: `vacation/set.rs:134` and `:281-295`.
- `set_max_objects` is 500 (`structs_impl.rs:23293`).
- `Delivered-To` is prepended when `add_delivered_to_header` is on, which is the default (`ingest.rs:251-259`, `structs_impl.rs:28860`).
- sieve-rs is `edition = "2024"`, and Stalwart locks sieve-rs 0.7.3.
- The servers citations check out: `apply.sh:98`, `stalwart-apply:44-48`, `runbook.md:434` and `:478-479`, `cutover-log.md:87`, `tests/container/run.sh:8`, `mail-test-ids.sh add` and `list`, and `/etc/servers/stalwart-image` (`roles/stalwart/install.sh:69`).
