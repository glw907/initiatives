# Mail filters plan review: data integrity and failure risk

Target: `self-hosting/plans/2026-10-22-mail-filters-plan.md` at `d9de3e5`, read against the design (`self-hosting/specs/2026-10-22-mail-filters-design.md`) and the prior-art research. Servers repo read at `e036a70` (`roles/stalwart/`, `roles/mail-backup/`, `roles/health/`, `cloudflare/monitor/`, `docs/runbook.md`). No server contacted.

Verdict: not ready to approve as written. Two blockers: the undo stops working once `--prune` runs, and the plan never excludes system folders from the move. Ten majors follow. Most of the folds are a sentence in the plan plus one test each, and none of them adds new machinery.

## Blockers

### 1. The undo breaks once `--prune` runs, and the rejection path depends on that undo

- Severity: blocker. Tag: correctness.
- Location: plan:60-62, plan:93, plan:109; design:118.
- Defect: the manifest records each message's "old folders". The design (design:118) says these are folders, and a JMAP move works in mailbox ids. T7 step 5 runs `folders geoff --prune` straight after `resort --apply`. Prune deletes exactly the folders the re-sort emptied: the legacy Fastmail folders, which are every message's old folder. After that, `undo geoff <manifest>` (plan:109, the PR-rejection path) points at mailbox ids that no longer exist, so it fails, or creates nothing, for every message that left a legacy folder. The T3 test "`undo` restores a manifest exactly" (plan:76) runs with no prune in between, so it can't catch this.
- Fold: the manifest records each old and new folder as a full path (`Notifications`, `Lists/Finance Committee`) as well as its id. `undo` resolves by path and recreates any missing folder. Move `--prune` out of T7 into `## After merge`, after Geoff approves the PR, and record each pruned folder's path in a prune manifest. Add a T3 test that runs move, then prune, then undo, and checks that every message is back in a folder with its old path.

### 2. Nothing in the plan keeps the re-sort out of system folders

- Severity: blocker. Tag: correctness.
- Location: plan:58 (`export`), plan:60 (`move`), plan:78 (the mapping); design:94.
- Defect: the design leaves Sent Items, Drafts, Deleted Items, and Junk Mail alone (design:94). The plan never says so. `export` prints "one JSON line per message", and T4's mapping says only "never into the Inbox, never personal mail out of Archive". A builder who follows the plan would classify Geoff's sent mail. His own From address isn't a correspondent, so that mail reaches step 8 or 9 and moves to Notifications/Other. The Scheduled role folder isn't named in the design either, and moving a queued send out of Scheduled could break the send.
- Fold: state it in T3. `move` refuses any message whose current `mailboxIds` include a role folder other than `inbox` or `archive`, and it refuses any target outside an allow-list: Archive, Light, `Lists/*`, `Notifications/*`, and Deleted Items for the Remind set only. Add one test for each refusal. `export` also leaves those folders out, so the preview counts are honest.

## Majors

### 3. `move` overwrites concurrent changes and drops other folder memberships

- Severity: major. Tag: correctness.
- Location: plan:60, plan:93; compare `roles/stalwart/stalwart-jmap:96`, which sets `mailboxIds: {($m): true}`.
- Defect: the pattern the plan copies replaces the whole `mailboxIds`. The move plan comes from an export taken minutes or hours earlier, and Geoff's client (Hylki) and live delivery keep changing mail in the meantime. If Geoff deletes or files a message after the export, the re-sort pulls it back or moves it again. A message in two mailboxes, which JMAP allows, loses its other membership. The manifest then records the export's folders, not what was actually there, so undo restores a state that never existed.
- Fold: `move` patches with `mailboxIds/<from>: null` and `mailboxIds/<to>: true`. Per batch, it first runs `Email/get` on `mailboxIds` and skips any message whose folders no longer match the export, listing the skips in the manifest. The manifest records the folders observed at move time. `undo` works the same way: it moves a message back only if the message still sits where the manifest put it, and reports the rest. Add a test that a message moved between export and apply is skipped.

### 4. A crash, a dropped ssh session, or the backup stop leaves a partial run with a partial manifest

- Severity: major. Tag: correctness.
- Location: plan:60, plan:78 (`resort --apply` pipes the plan to `move` over ssh), plan:93; `roles/mail-backup/servers-backup:211` (Stalwart stops at 03:30 UTC).
- Defect: about 30,000 updates run as many `Email/set` batches inside one ssh session from the workstation. The plan doesn't say when the manifest is written. If it's written at the end, a laptop sleep, a network drop, a SIGHUP, or a JMAP 429 or 5xx partway through leaves moved mail with no record, and undo is impossible. Nothing keeps `resort`, `install`, or `--prune` out of the 03:20-04:00 band, as `stalwart-apply:44-48` does for its own restarts. A run that crosses 03:30 hits a stopped Stalwart in the middle of a batch.
- Fold:
  - `move` appends each batch's confirmed `updated` ids to the manifest and flushes after every batch. It writes `notUpdated` ids as failures.
  - `move` runs on ward detached from the ssh session (`systemd-run --unit=mail-filters-move`, or `nohup` with a log), so a dropped connection doesn't kill it.
  - `move` retries a transient error with backoff, then stops cleanly.
  - Each run's manifest is one file. A rerun starts from a fresh export, which makes it idempotent, and `undo` takes manifests newest first.
  - `move`, `install`, and `folders --prune` refuse the 03:20-04:00 UTC band and take a lock of their own.

  Add a test that kills `move` partway and checks that the manifest matches what moved.

### 5. The runner's output can't separate step 8 from step 9, so the mapping can't be built as designed

- Severity: major. Tag: correctness.
- Location: plan:74 (the runner prints "the folders it would be filed into, or `keep`"), plan:78; design:98-100.
- Defect: step 8 (unknown bulk mail) moves to Notifications/Other. Step 9 (a stranger, with Geoff only on Bcc) stays in the Inbox or Archive. Both steps file to Notifications/Other, so T4 sees the same verdict for both. As planned, the mapping will either move strangers' old Bcc mail out of the Inbox and Archive, which goes against design:100, or never move any bulk mail.
- Fold: the runner reports which step matched. The template sets `set "step" "N"` before each terminal action, and the runner reads the variable back from sieve-rs. If sieve-rs can't expose it, `render --resort` swaps each Inbox-class or step-9 target for a sentinel folder name. That is one substitution, and the classification stays the same. Add T2 fixture cases for steps 8 and 9 in the Inbox, in Archive, and in a legacy folder.

### 6. The off switch isn't built

- Severity: major. Tag: correctness.
- Location: plan:76 ("applies to no account until … lists one"), plan:82 ("`install` with an empty accounts file"), plan:109.
- Defect: removing an account from the accounts file stops future installs. Nothing deactivates a script that's already active. The runbook's off switch and the rejection path ("clears the accounts file … which deactivates the script") both depend on behaviour no task builds or tests. This is the lever needed most if the live script starts misfiling.
- Fold: add a `deactivate ACCOUNT` verb (`SieveScript/set` with `onSuccessDeactivateScript: true`, in its own request). `install.sh` deactivates every account that has an active script but is missing from the accounts file. Add a T3 test, run it once on `probe` in T7 step 2, and name `deactivate` in the T6 runbook.

### 7. The runner doesn't enforce Stalwart's limits, and nothing measures CPU or growth

- Severity: major. Tag: correctness.
- Location: plan:72 (the T1 acceptance lists 100 KB, 4,096-byte strings, and 15 nesting levels, but not 5,000 CPU instructions or 128 variables), plan:74, plan:76; design:88; research:39.
- Defect: sieve-rs's default compiler and runtime limits aren't Stalwart's user-script limits, so the parity run can pass a script that ward rejects, or that ward aborts at run time. The research only inferred that one `address :is "from" [list]` test saves CPU. Nothing establishes what ward does when a script hits the CPU limit for one message. Sent Items recipients grow every day, and the timer grows the script with them. Once it passes 100 KB, `validate` fails every day and the script freezes, silently.
- Fold:
  - Build the runner with Stalwart's user-script limits from the same source read T2 already does (`structs_impl.rs` around 36828): script size, string size, nesting, CPU, and variables.
  - Treat any runtime error in the preview as a stop. In the move plan, a message with a runtime error stays where it is.
  - Extend the T1 acceptance: CPU used on the worst-case path (a step-9 message that falls through every test), and headroom with a fixture of five times today's correspondent count.
  - Record the 100 KB headroom in the runbook. `render` warns past 75%.
  - Read ward's runtime-error path once (`crates/email/src/sieve/ingest.rs`) and record whether mail falls back to the Inbox.

### 8. The refresh timer can install a degraded script, silently, with no probe delivery

- Severity: major. Tag: correctness.
- Location: plan:76, plan:48; design:90 ("activated only after a probe delivery succeeds").
- Defect:
  - If `correspondents` fails or comes back short, from a JMAP hiccup or from running during the 03:30 stop, `render` produces a valid script with an empty or short known-correspondent list. Its hash changes, so `install` pushes it. From then on, contacts writing with Geoff on Bcc go to Notifications/Other, and contacts at category domains go to category folders. That is hidden personal mail with no error anywhere.
  - The timer's schedule isn't given, so it can land in the backup band.
  - "Only updates when the hash changes" is checked against nothing named. If the comparison is against a local file, a restore or a web-admin edit drifts and is never repaired.
  - A daily install with no probe delivery departs from design:90 without saying so.
- Fold:
  - `render` fails closed. It needs `pipefail` and a non-empty JMAP result, and it refuses when the correspondent count falls more than 10% below the last installed count, a number the role keeps.
  - The timer runs outside 03:20-04:00, under a lock shared with `install`.
  - The unit exits non-zero on any failure, so `failed_units` in `roles/health/health.sh:34` raises it.
  - Compare the hash with the active script from `SieveScript/get`, not with a local file.
  - Add a `## Decisions` line that narrows design:90: probe-first applies to template and data changes, and a timer run changes only the correspondent list.

### 9. Remind deletion has no defined match, and the undo for it expires

- Severity: major. Tag: correctness.
- Location: plan:78 (only "the number of Remind messages"); design:20, design:112; `roles/stalwart/stalwart-status:4` ("Trash expires").
- Defect: no task defines how a Remind message is recognised. No rule handles Remind in the script, so the match lives in a second rule language in T4, untested. Deleted Items expires, so after the expiry window a wrong match is permanent loss. The undo for these moves also runs out, which the design's "until Trash expires" admits and the plan never tells Geoff. The mailbox-drop alert fires above 10% (`cloudflare/monitor/src/alerts.ts:22`), about 3,000 messages here, so a runaway match of a few hundred raises nothing.
- Fold: put the match in a data file (`mail-filters/delete-senders.txt`, sender domains), and add a T4 fixture test. The packet lists every Remind hit by sender and subject, not just a count. `move` caps the Deleted Items moves at the approved count and refuses to go past it. Find the Trash expiry period on ward, state it in the packet, and copy the Remind slice of the manifest to the workstation.

### 10. The spam step is never really tested, and a wrong comparator hides mail in Junk

- Severity: major. Tag: correctness.
- Location: plan:74 (T2 tests "a spam-scored message going to Junk"), plan:90 (GTUBE over authenticated submission), plan:117; research:57.
- Defect: offline, spamtest is "unknown", so the runner never runs the comparator. If the template leaves out `:comparator "i;ascii-numeric"`, `:value "ge" "50"` compares as strings, so a score of `9` counts as at least `50`. Ham then lands in Junk, which is the worst way to hide mail. The live check sends GTUBE from `probe2` over authenticated submission, and spam filters commonly skip authenticated senders, so the case may pass or fail for reasons unrelated to the script. That sends the standing answer at plan:120 around a loop of template fixes. The fallback extension list at plan:117 also leaves out `spamtestplus` (`:percent` needs it) and `special-use` (`:specialuse` needs it).
- Fold: the runner takes a spam score per fixture. T2 adds cases at 0, 9, 49, 50, and 100 and checks that only 50 and 100 file to Junk. For the live case, deliver GTUBE so the filter scans it, through an unauthenticated SMTP session on ward's port 25 from localhost, and read its `X-Spam-Score`. If Stalwart rejects it outright, record that, since a rejection is also a fail-safe result. Add `spamtestplus` and `special-use` to the plan:117 list.

### 11. A Stalwart upgrade silently breaks parity

- Severity: major. Tag: correctness (the design's "iterate going forward").
- Location: plan:16, plan:74; design:94.
- Defect: the runner pins sieve-rs `=0.7.3`, which matches v0.16.27 only. After an upgrade, `preview` and `resort` keep running against a different interpreter. The user-script limits, the `:create` behaviour, and the raw-header quirk in Brief fact 6 may change too. Nothing notices, and the daily timer keeps installing.
- Fold: the role installs `mail-filters` with the Stalwart version it was checked against. `preview`, `resort`, and the timer read `/etc/servers/stalwart-image` and refuse on a mismatch, with a runbook line that says how to re-pin. The cost is one comparison.

### 12. Prune is the one path that can destroy mail, and nothing pins it to the safe form

- Severity: major. Tag: correctness.
- Location: plan:62, plan:93; design:119.
- Defect: `Mailbox/set destroy` with `onDestroyRemoveEmails: true` deletes the folder's mail. The plan forbids `destroy` for `move` and says nothing about this flag for prune. Live delivery can `:create` a folder and drop a message in it between prune's count read and its destroy. Prune's handling of folders with children (`Notifications`, `Lists`, `Notifications/Tech`) isn't defined either.
- Fold: a T3 test that prune never sends `onDestroyRemoveEmails`, and that a `mailboxHasEmail` or `mailboxHasChild` refusal is a skip, not an error. "Empty" means no mail and no children. One probe check in T7 step 2 confirms that Stalwart refuses to destroy a folder that holds a message.

## OWNER FORKs

### 13. Moving unread or flagged Inbox mail out of the Inbox

- Severity: major. Tag: correctness (the "hidden" anti-goal, design:32).
- Location: plan:80 (the packet samples 50 human messages); design:94-98.
- Defect: the Inbox holds 623 messages, and the first re-sort moves every one the rules call automated. Geoff may be keeping unread or flagged mail there as a to-do, and a misclassified one ends up where he won't look. The packet's 50-message sample covers all 30,000 messages, not the Inbox in particular.
- Options:
  - (a) Move every message as the rules say, and list every message leaving the Inbox in the packet, by sender and subject.
  - (b) Option (a), and also leave every `$flagged` Inbox message, and every unread one, where it is.
  - (c) Leave the Inbox out of the first re-sort entirely.
- Recommendation: (b). Listing 623 rows is cheap, and the hold-back costs one condition in the mapping.

### 14. What later re-sorts do to Geoff's own filing and to the script's own output

- Severity: major. Tag: correctness.
- Location: plan:78; design:19, design:38, design:99.
- Defect: "personal mail in any other user folder goes to Archive" is right for the legacy Fastmail folders. The design reruns the re-sort after every rule change, though. Each run will then pull mail Geoff filed by hand (a personal note from his bank, moved to Notifications/Money) into Archive. It will also undo the script's own step-9 filing to Notifications/Other, since the re-sort sends step 9 to Archive. So the re-sort never agrees with the script, and every run moves the same mail again.
- Options:
  - (a) Keep the rule for every run.
  - (b) Apply "personal to Archive" only to folders that aren't script destinations, meaning the legacy folders. Later runs move mail only between script destinations, and only when the verdict changes.
  - (c) Option (b), plus an "ignore" list of message ids that Geoff has filed by hand.
- Recommendation: (b). It makes the re-sort idempotent and adds no machinery.

## Minors

### 15. The backup check proves a snapshot exists, not that it holds the mail, and the plan's wording contradicts its own step order

- Severity: minor. Tag: correctness.
- Location: plan:92, plan:93, plan:123; `roles/mail-backup/server-restore:163`; runbook:100.
- Defect: T7 step 4 records a snapshot id and time. The backup's own `manifest.json` already carries Geoff's message count, and the plan doesn't compare it. The standing answer says "a snapshot newer than the preview", but step 5 runs a fresh preview after the backup, so read literally the executor should stop. A restore also replaces the whole store, Oliver's mail and all post-snapshot mail included, so it isn't the rollback for a bad re-sort. The manifest undo is.
- Fold: step 4 compares the snapshot manifest's `counts["geoff@907.life"]` with the live count (within 10, as `server-restore` does). Reword plan:123 as "a snapshot taken after the approved preview and before the first move". The T6 runbook says undo is the rollback and a restore is for disaster only.

### 16. The parity of the role-address and envelope tests is never checked live

- Severity: minor. Tag: correctness.
- Location: plan:74, plan:90; design:93; research:42, research:53.
- Defect: step 3 matches on the envelope recipient. Live, that's the lowercased RCPT TO alias. Offline, it's the stored `Delivered-To`, which may be the account's address, or a Fastmail value on migrated mail. `probe` has no aliases, so step 2 never exercises step 3. Any `envelope "from"` test in the template has no offline input either.
- Fold: in T7 step 3, also send `probe` to `dmarc-reports@907.life`. Confirm it lands in Notifications/Tech/Reports, and read its stored `Delivered-To`. The template matches role addresses on To as well as on the envelope, and leaves `envelope "from"` unused, or the runner feeds it from `Return-Path`.

### 17. List folders created by `move` may not match those created by `:create`

- Severity: minor. Tag: correctness.
- Location: plan:60.
- Defect: names derived from List-Id come from outside mail. If `move` builds names, case, or truncation differently from Stalwart's `mailbox_create_path`, or if it races live delivery, Geoff gets twin folders.
- Fold: `move` finds a folder by its exact path, creates it only when it's missing, and on "already exists" reads the list again. Add a test with a `/`, a long name, and a case-variant name. The allow-list in finding 2 stops a crafted name from reaching a role folder.

### 18. The export's paging and the source of the move plan

- Severity: minor. Tag: correctness.
- Location: plan:58, plan:93; `stalwart-jmap:80-90` (position paging).
- Defect: position paging over a list that changes while it's read skips or repeats messages. The step-5 preview renders from the repo on the workstation, so it isn't guaranteed to be the script ward has active.
- Fold: page with a stable sort and check `queryState`, then take the export again if it changed. `resort` asserts that the render's hash equals the active script's hash (`SieveScript/get`) before `--apply`.

### 19. Manifests live only on ward, outside the backup, and carry only ids

- Severity: minor. Tag: optional.
- Location: plan:60.
- Defect: `/var/lib/servers/mail-filters/manifests/` isn't in the restic set (`servers-backup:195`), so a rebuild loses every undo record. JMAP ids alone don't survive a re-import.
- Fold: add each message's Message-ID to the manifest, and copy the manifest to `$XDG_RUNTIME_DIR` on the workstation after the run, or add the manifest directory to the backup set.

### 20. Requirements dropped from the design

- Severity: minor. Tag: correctness.
- Location: plan:72-80; design:82, design:109.
- Defect: no task checks how Proton Pass rewrites `m.907.life` alias headers (design:82). The Spam (1) to Junk Mail merge (design:109) has no step. Prune removes only empty folders, and a re-sort may file Spam's one message anywhere.
- Fold: add the Proton header check to T5. In T7, move the Spam message to the Junk role folder before prune.

### 21. The correspondent list includes Geoff's own addresses

- Severity: minor. Tag: correctness.
- Location: plan:57.
- Defect: Sent Items includes mail to himself and to his aliases, so `geoff@907.life`, `geoff-login`, and the masks become "known correspondents". Mail with a forged From of his own address skips the automated-mail tests.
- Fold: `correspondents` drops the account's login and every alias.

### 22. The step order conflicts with the GitHub case

- Severity: minor. Tag: correctness.
- Location: plan:72 ("the nine steps in the design's order"), plan:74.
- Defect: in the design's order, lists (6) come before categories (7), yet GitHub mail, which carries a mailto List-Post, has to reach Tech. T2's fixture will catch this, but only after the template is written.
- Fold: T1 says the step-6 test excludes category-domain senders, or that a category pre-check runs before step 6.

### 23. Over-ceremony

- Severity: minor. Tag: optional.
- Location: plan:82, plan:93.
- Defects:
  - "One `docs/decisions.md` entry for each Brief fact" (plan:82) is six entries for facts the research file already records. One entry that points to the research costs about 10 minutes and some tokens less.
  - T7 step 5's "counts match the approved packet within the mail that arrived since" can't be measured, because Geoff's own moves change the counts too. It invites a judgment stop.
- Fold: replace the step-5 check with a diff by message id between the approved plan and the new plan, reporting ids added, dropped, and retargeted. Stop only on a retargeted id whose rules didn't change.
