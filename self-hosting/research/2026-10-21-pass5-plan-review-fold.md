# Pass 5 plan review: fold record

The planner's disposition of every finding in the three lens files beside this one (`-contract`, `-data`, `-mechanics`), against commit 9a25e94. "Fold" means the fold agent writes it into the plan files as stated; "Drop" carries the reason. The fold agent appends a "What changed" section, file by file, when it finishes.

Two facts probed after the reviews, 2026-10-21 about 06:40 UTC: pavilion opens outbound port 25 (Fastmail's and Google's inbound MX hosts each answer `220`), so the direct-SMTP path works from pavilion; and the free DQS link now resolves to `https://www.spamhaus.com/data-access/free-data-query-service/`, which says the service is "for non-commercial users only" and also mentions a separate 30-day trial.

## Rehearsal mail never reaches Fastmail

Contract 1 (blocker), contract 2, data 4. Fold. Before cutover, no rehearsal message is addressed to a 907.life mailbox. Every inbound rehearsal message goes to the Stalwart test account at its `probe.907.life` address (MX on ward from L4), either from Gmail or Outlook.com, or by a direct SMTP delivery from pavilion with `curl --url smtp://ward.907.life:25 --mail-from <...> --mail-rcpt <test account's probe address> --upload-file <msg>` (a new allow rule, proven). R1 becomes: Geoff sends one message from Outlook.com to the test account's probe address, and reports landing for ward's sends to Outlook.com. Mailbox-addressed sends stay in C3, after the switch. A pre-flight conductor check repeats tonight's port-25 reach.

## Pinned address set, refusals, and contacts accounts

Contract 3, 4, 10; mechanics m8. Fold. L1 records in the servers repo's `docs/addresses.md` (private): each 907.life mask with its state at Fastmail, the expected accepted-address set with its count, each contacts-only `accountId` and whether the two tokens reach the same one, and household members A's and B's rows moved to Dropped with the 2026-10-20 ruling. L5's acceptance adds: Stalwart's accepted-address list equals that set, each answering `RCPT TO` with 250 over port 25; A's and B's addresses each refused with 5xx; no catch-all; each distinct contacts-only account imported exactly once into the account `docs/addresses.md` names. C1 repeats the A and B `RCPT` refusal after the switch. C5 cites the recorded mask count in place of "three". L5's Files line names `docs/addresses.md` and `docs/decisions.md`.

## Household members A's and B's masks

Contract 5 (OWNER FORK), data 16, data 17. Fold option (a) without a Decide block, since it gathers a count and changes nothing the ruling decided: in pre-flight item 8, before revoking, Geoff opens member A's and then member B's Masked Email list in their settings and reads the count of enabled masks; item 8 is done in the plan sitting, still holding nothing. The L8 drafted message tells A and B about any masks found and asks them to move any login or recovery address that uses their 907.life address before cutover. C5's packet states that the design's mask and Fastmail-only-login evidence row is waived for A and B under the 2026-10-20 ruling, with the counts Geoff read.

## Evidence rules and vacuous criteria

Contract 6, 7, 8, 9, 11, 12, 13, 14; mechanics m10 (R3). Fold:
- The second operator's report is the second allowed human-evidence source, for the device side of the Clients and Android rows, in the plan, the pre-flight, and the prompt.
- C2: the second operator's verified `alert_to` address becomes a Pass 6 entry condition; C2's check loses its "if".
- L7 under the DMARC-report fallback: acceptance is "fallback wired, its condition muted until cutover"; C1 gains "a DMARC report reached `dmarc-reports@` within 48 hours of the switch" and unmutes it.
- The rules proof runs `claude -p --permission-mode dontAsk --output-format json` and passes only when `permission_denials` lists each command meant to be refused, as well as the allowed forms' log lines.
- L2's acceptance: the DQS check reports no listing, and the cross-check pages agree or `decisions.md` records the fallback.
- L6's acceptance lists the rows in scope, each with its evidence source (API, IMAP, JMAP, DNS, Geoff, the second operator), and names mail-tester under Sending.
- R1 gains a third answer, "not there after 15 minutes", which fails the row.
- L7's acceptance adds: `config.json` shows ward's seven checks true and `mail_urgent` false, `/alerts` shows no ward condition, and the second operator's Stalwart password item reads back by hash.

## The permission rules

Mechanics B1, o1, m1, m9; contract 16 (pipe). Fold:
- The rules file splits into an allow half, which the conductor lands on Geoff's ask, and a deny half, which Geoff types himself into `claude/.claude/settings.json` in the same worktree before the PR opens (exact lines given). The workstation's autoMode text excludes "a deny or ask rule change".
- Drop every `Bash(bash <script> ...)` form. L1 makes `scripts/dry-run.sh` executable (`git update-index --chmod=+x` and `chmod +x`), and the rule is `Bash(scripts/dry-run.sh)` plus `Bash(scripts/dry-run.sh *)`. The conductor's pre-launch dry-run runs before L1 and keeps `bash scripts/dry-run.sh`, which is read-only; a refusal there is the conductor's to run by hand. Not checked gains "whether auto mode keeps every new rule", which the first live use answers.
- Add `Bash(curl --url imaps://imap.gmail.com:993 *)` and the port-25 rule above, both proven.
- Standing answer, in the conductor prompt and the plan's classifier-denial row: if the classifier refuses any part of the rules edit or `claude-tooling-sync apply`, Geoff makes that part by hand in the sitting.
- The prompt names its one pipe exception, the tunnel-token pipe.

## Archives

Data 2, data 11; mechanics B2, o2. Fold. L5 archives a copy, never the working archive: after Vandelay exits, `sqlite3 <archive> ".backup <staging copy>"`, then `PRAGMA integrity_check` and `vandelay inspect` on the copy, then `scripts/archive.sh` on the copy, which deletes it (added to the deletions list). Once per account per pass, never per round. Before L5 runs on real data, `archive.sh` gets a disk-backed work directory under `~/.local/state/self-hosting/` (0700) in place of tmpfs, test-first, as part of L5. C1 archives each final Vandelay archive the same way. C5 runs one last Vandelay pass of the second operator's account before its packet and archives it, and the packet names both archive objects' keys and times.

## C1 reconciliation

Data 3. Fold. L5's test adds: with the test account as source and a second Stalwart test account as target, run a pass, then delete, move, and flag one message each at the source, run a second pass, and record what Stalwart shows; and kill one run partway and rerun it. C1 is written now with both branches: if Vandelay carries deletes and moves, nothing more; if not, the final pass reconciles by Message-ID (a Stalwart message whose Message-ID is absent from the final archive is destroyed, counts read before and after), named in Pass 6's deletions. No Vandelay run into ward starts unless it can finish before 03:20 UTC, or after 04:00.

## Relaunch safety and the Message-ID list

Data 5, 8; mechanics M10, M11. Fold:
- The prompt: on any start, first rebuild the overlay from the branch store (`/var/home/glw907/.dotfiles/scripts/secrets/sync.sh` with the branch's `--values` and `--local`), and never generate a name already present in the branch store or `~/.local/secrets`; a name that seems to need replacing is a stop.
- The Message-ID list lives at `~/.local/state/self-hosting/mail-test-ids.age` (0600), encrypted to the workstation recipient. The build PR body records its entry count and SHA-256; L8 stops if the file is missing or its hash differs.
- `restic stats --mode raw-data` runs on ward over the existing SSH rule, written in full.
- `## Waiting: CX33 stock` lists each started task's spent minutes, and the relaunch reads them.

## The image restore and the sitting

Data 6, 20; mechanics M5, M6, M7, m5. Fold:
- R2 runs first on its day, before any test send, and never between 03:20 and 04:00 UTC. After it, the executor runs `scripts/apply.sh ward --check`, then `--apply` if it shows drift. L8's acceptance: for each listed Message-ID, destroy the copies found; the count difference equals the number found; listed-but-absent IDs are reported, never searched for another way.
- Names: "the sitting days" for R0 to R4 inside L6; "the backup week" for L8's seven nights.
- New R0 (Geoff: one Access sign-in each to `ssh-ward.907.life` and the Stalwart admin page) and R4 (Geoff: add the test account in Hylki and report whether discovery found Stalwart), each with the executor's check, and both in Human steps.
- Items 6 and 7 hold the sitting days, not the launch. Item 6 records the protection and Rebuild labels; the backup-restore label is read in R2. Item 7 gets the app names and agrees the session in principle; the conductor books it at the sitting stop.

## The imap-sweep wrapper

Data 7, 12, 13; contract 15. Fold:
- Pass 5's rules allow `scripts/imap-sweep.sh rehearse *` and `scripts/imap-sweep.sh rehearse-clean` only. `sweep` and `rollback` get their rules in Pass 6's own pre-flight. `rollback` refuses unless the apex MX, read from a public resolver, is ward, tested.
- `rehearse` refuses if its folder already exists without the wrapper's marker under `~/.local/state/self-hosting/`; `rehearse-clean` refuses unless the folder's message count equals the count `rehearse` logged; both tested.
- The Trash-expiry row runs in the test account on a message imported with an old `receivedAt`.
- The band guard also checks `systemctl is-active` on ward's backup service over SSH.

## Vandelay commands

Mechanics M3, M4. Fold. L5 adds `scripts/vandelay-run.sh` (auth-data, test-first): `scripts/vandelay-run.sh import <account> <archive>`, `export <account> <archive>`, `inspect <archive>`. It loads the account's credential through `scripts/lib/secrets.sh` into `VANDELAY_TOKEN` or `VANDELAY_PASSWORD` inside the script, runs JMAP, CalDAV, and CardDAV imports in turn, refuses `--prune`, and supports `--dry-run`. The rules replace the raw `vandelay` allows with `Bash(scripts/vandelay-run.sh *)`; Geoff's deny half keeps the `vandelay` `--prune` denials. The prompt writes each live command in full at the step that runs it: each Vandelay call per account, `imap-sweep.sh rehearse` and `rehearse-clean`, `restore-drill.sh ward` with and without `--type`, the curl sends.

## The drill for ward

Mechanics M1. Fold. L7 adds ward support to `scripts/restore-drill.sh` (auth-data, test-first): per-host repository, `drill-ward-*` name guard, ward's IP name for `--hold`, and Stalwart checks (JMAP login, mailbox counts against the snapshot manifest), about 45 minutes, runnable during the stock wait.

## Server type, stock, and the bar

Mechanics M2, M8, m4, m10; data 14. Fold:
- The CX33 row in Standing answers names the Decide options and says the conductor records Geoff's pick in STATUS. The options: keep waiting (recommended), or a CPX22. A CX43 is no option: no CX type was in stock in any EU location on 2026-10-21. The prompt's "Never take another server type" gains "unless STATUS records Geoff's answer naming one". L2 gives ward a per-host type (`WARD_SERVER_TYPE` in `infra/project.env`, defaulting to `cx33`).
- `provision.sh` exits 3 when the pinned location lacks stock and the Primary IPs already exist.
- The conductor recreates its daily check on the seven-day expiry and counts days from L2's first refusal across relaunches.
- A listed Primary IP is renamed with a `-listed` suffix before a fresh one is allocated, a rerun skips it (tested), and the third listed allocation stops. Each fresh IP sits inside the $40 ceiling.
- Bar unmet: once a row can't pass, finish the other rows, L7, and the runbook, skip a rerun whose cause is traced, and close the build phase with `## Bar unmet: <row>`; the conductor brings it to Geoff and doesn't arm the date phase.
- Microsoft's delisting wording follows the design's "Delivery" text exactly.
- The plan's classifier-denial row's `notify-send` is the conductor's only.

## Small folds

- Data 9: the conductor's sitting step 2 fetches and test-merges `origin/main` into the credentials branch before the push; a `values.age` conflict follows the plan's conflict rule and checks every name's hash.
- Data 10: L3 adds a test that renders orpheus's installed backup and health files on `main` and on the branch and asserts them byte-identical or lists each intended difference; the build PR's `## After merge` runs `scripts/apply.sh orpheus --check`.
- Data 15: covered by running `restic stats` on ward.
- Data 18: drop `r2-archive-rw` from the conductor's check and L1's acceptance run (each run leaves an undeletable object).
- Data 19, contract 19: L1 drops its re-measurement and copies the 2026-10-21 figures into `decisions.md`; L1 keeps 60 for the pins above.
- Contract 17: C3 defines its session: the second operator sends and receives one message per test account with Geoff beside him, and Geoff reports the headers.
- Contract 18: cite design "Cutover" step 6 for the Apple consequence.
- Mechanics M9: item 2 links `https://www.spamhaus.com/data-access/free-data-query-service/`, for non-commercial users, and says to choose the free service, not the 30-day trial.
- Mechanics m3: absolute `sync.sh` path in the conductor prompt.
- Mechanics m6, m7: the Brewfile row adds `tap "stalwartlabs/tap"` and marks vandelay pavilion-only; thinkpad-x1 picks up the rules at its next pull and skips vandelay.

## Path

The folds raise Pass 5's path and Pass 6's. The fold agent sets each task's new estimate, recomputes the table and the running projection, and reports whether the path passes the 3,515 line; the standing answer for that is to keep launching and say so.

## What changed

The fold agent wrote every disposition above into the five plan files on branch `pass5-plan`, on top of 4ed699b.

`plans/2026-10-17-self-hosting-plan.md`:
- "Mail scope": the ruling's waiver of the mask and Fastmail-only-login evidence for A and B, stated in C5's packet with Geoff's counts.
- "Standing answers": the CX33 row names the Decide options (keep waiting, recommended, or a CPX22; no CX43) and STATUS as the record; the blocklist row adds the `-listed` rename, the third-allocation stop, and the $40 ceiling; the classifier-denial row makes `notify-send` the conductor's only and has Geoff make any refused part of a rules edit or `claude-tooling-sync apply` by hand; a new row for a rehearsal row that can no longer pass (`## Bar unmet`).
- "Human steps": item 8's mask counts beside A's revocation; item 6 and item 7 rows hold the sitting days; new R0 (Access sign-ins) and R4 (Hylki) rows; the Outlook.com row sends to the test account's probe address; C2's row loses its "if", with a new row for the second operator's `alert_to` address as Pass 6's entry; a row for the C3 session.
- Pass 5: the Apple consequence cites design "Cutover" step 6; the port-25 probe fact; a paragraph that no rehearsal message goes to a 907.life mailbox; the entry splits the rules into the conductor's allow half and Geoff's deny half; `dry-run.sh` becomes executable in L1; "the sitting days" and "the backup week" defined. L1 (60) drops the re-measurement, copies the figures, records the address set, contacts accounts, and A's and B's Dropped rows, and drops `r2-archive-rw`. L2 (95) adds `WARD_SERVER_TYPE`, the second exit 3, the `-listed` rename and cap, and the DQS acceptance with its fallback. L3 (210) adds a second test account, the probe address in `addresses.md`, orpheus's byte-identity test, `apply.sh orpheus --check` after merge, and moves Geoff's sign-ins to R0. L5 (190) adds `vandelay-run.sh`, the disk work directory for `archive.sh`, `rcpt-check.sh`, the Brewfile tap and pavilion-only note, the backup-band rule, the reconciliation test, the copy-then-archive path, and the address and contacts acceptance. L6 (205) lists the rows with evidence sources and mail-tester, names the Message-ID list's path and hash record, adds the wrapper's marker, count, MX, and `is-active` refusals, narrows Pass 5 to `rehearse` and `rehearse-clean`, confines Trash expiry to the test account, and runs R2 first on its day with `apply.sh ward --check` after. L7 (125) adds ward support to `restore-drill.sh`, the muted DMARC fallback, and the fuller acceptance. L8 (40) adds the list's hash stop, `restic stats` on ward, the found-copies acceptance, and the masks and recovery-address lines in A's and B's message.
- Pass 6: entry adds the second operator's `alert_to` address. C1 (165) adds the backup-band rule, both reconciliation branches, archiving the final archives, the A and B refusal after the switch, and the DMARC report within 48 hours. C2 loses its "if". C3 defines the household-session path. C5 (80) runs and archives one last pass of the second operator's account, names both archive keys, cites the recorded mask count, and states the A and B waiver.
- "Path" and "Not checked": the table, both paragraphs, and the task sum recomputed; a row for whether auto mode keeps every new rule.

`plans/2026-10-21-pass5-preflight.md`: the evidence sentence names three human sources; two new "Checked tonight" rows (port 25, the DQS page); item 1 split into the conductor's allow half and Geoff's typed deny half, with the by-hand fallback; item 2 links the free DQS page and warns off the trial; item 5 test-merges `origin/main` and uses the absolute `sync.sh` path; items 6 and 7 hold the sitting days, with item 6 limited to the protection and Rebuild labels and item 7 to the names and agreement; item 8 reads A's and B's mask counts first; the conductor checks drop `r2-archive-rw` and add the port-25 reach; `STALWART_PASSWORD_TEST2` added; "The rehearsal sitting" became "The sitting days" with R0 and R4 new, R1 sent to the probe address with the third answer, R2 first on its day with the restore label and `apply.sh --check`, R3 resting on the second operator's report for the device side.

`plans/2026-10-21-pass5-rules.md`: rewritten in two halves, every `bash <script>` form dropped, `dry-run.sh` in its executable form, `imap-sweep.sh` narrowed to `rehearse *` and `rehearse-clean`, raw `vandelay` allows replaced by `scripts/vandelay-run.sh *`, new rules for `rcpt-check.sh`, port 25, and Gmail IMAP; the live-call table matches the prompt's forms; the proof runs with `--output-format json` and lists 13 allowed forms and 7 refused forms checked against `permission_denials`.

`plans/2026-10-21-pass5-prompt.txt`: the overlay rebuild and never-regenerate rule on every start; new clock estimates; spent minutes in `## Waiting`; the stock-wait order adds L5's scripts and L7's drill code; every live command written in full per task, with the one named pipe exception; the Message-ID list's path and recipient; the deletions list adds the staging copies and the test accounts' messages; the Brewfile tap; the sitting days R0 to R4 and three evidence sources; the server-type rule yields to a STATUS answer; Microsoft's wording follows the design; the bar-unmet answer; the list-hash stop.

`plans/2026-10-21-pass5-conductor-prompt.txt`: the Decide options and the path line in the brief; the allow and deny split and the by-hand fallbacks; the test-merge before the credentials push; absolute `sync.sh` paths; item 8's counts in STATUS; the seven-day cron recreation and cross-relaunch day count; booking item 7's session at the sitting stop; the bar-unmet handling; `apply.sh orpheus --check` after the build merge; `notify-send` as the conductor's only; Pass 5 planned at 985 and the projection.

Path figures: Pass 5 is 985 minutes (was 780) and Pass 6 is 335 (was 270). The planned path is 3,785, which passes the 3,515 line by 270 and stays inside the 5,273 ceiling; the standing answer is to keep launching and say so in the next packet, and the plan, the conductor prompt, and the plan packet's brief say so. The running projection is about 3,500. The task sum is 4,255, or 4,615 with hand-overs.

Judgment calls the fold made:
- `scripts/rcpt-check.sh` is new in L5. The record asks for a 250 `RCPT TO` from every accepted address and also forbids any rehearsal message to a 907.life mailbox, and a `curl` send would deliver to those mailboxes. A session that stops before `DATA` meets both.
- `rehearse` runs both halves of the design's Late mail row (the date-scoped sweep into Stalwart and the reverse into the scratch folder), since the record gives Pass 5 no `sweep` rule.
- L3 creates the second test account that L5's reconciliation test targets, as `STALWART_PASSWORD_TEST2`.
- `restic init` and `restic stats` on ward run through `sudo systemd-run ... --property=EnvironmentFile=/etc/servers/backup.env`, the env file the backup role already reads, so the call needs no new rule.
- Contract 2's fallback (sending from orpheus) wasn't written, since pavilion reached port 25 on 2026-10-21 and the pre-launch check repeats it.

Not folded: data finding 1 (L4's SPF declaration makes `dns.sh` own the whole apex TXT set, and the redirect rules' entrypoint PUT) has no disposition in this record, so L4 is unchanged. It is a major correctness finding against a live zone and needs a disposition before the plan packet goes out.

## Data 1, folded by the planner after the fold agent

The dispositions above missed data finding 1, and the fold agent reported it unfolded. The planner read the live zone, read-only, on 2026-10-21 about 07:10 UTC: the apex held one TXT record (the SPF), and the zone's dynamic-redirect phase held no rules. So nothing would have been lost tonight, but either set can grow before L4 runs. L4 now lists the live apex TXT set first, declares each record verbatim, and changes only the SPF value. Its redirect code adds rules through the entrypoint's rules endpoint, with a test that a pre-existing rule survives. Its acceptance checks that the apex TXT set differs only in the SPF value. L4 keeps its 60 minutes.
