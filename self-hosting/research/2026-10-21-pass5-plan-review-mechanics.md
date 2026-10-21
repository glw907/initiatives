# Pass 5 plan review: mechanics and feasibility

The `plan-reviewer` agent read commit 9a25e94 on branch `pass5-plan`: the amended Passes 5 and 6 of `plans/2026-10-17-self-hosting-plan.md`, the Pass 5 pre-flight, rules file, executor prompt, and conductor prompt. It checked them against the live workstation permissions and autoMode text, the servers repo at `origin/main`, the Claude Code permissions, permission-modes, and scheduled-tasks docs, Vandelay's README, and the Spamhaus pages. The dispatcher saved its reply here; the findings are as returned.

## What already holds

- The path arithmetic: Pass 5's tasks add to 780 and Pass 6's to 270; the path table adds to 3,235 plus 280 for hand-overs, 3,515; the remaining projection is 3,230; the task sum is 3,985, or 4,345 with hand-overs.
- No amended section still says four mailboxes. C3's eight messages and C5's "three users other than Geoff" are right.
- These forms already match a rule: `provision.sh` exit 3, both halves of the `access.sh --token` pipe, the `apply.sh`, `dns.sh`, and `deploy.sh` forms, and `secret-receive` with the fastmail-members `--values` and `--local` paths.

## Blockers

**B1. The rules patch falls outside the auto-mode exception it relies on.** `rules.md:57-64`, `conductor-prompt.txt:10`, `preflight.md:21-28`. The workstation's autoMode allow text covers `permissions.allow` edits only: "Narrow rules only: never `Bash(*)`, a wildcarded interpreter, a deny or ask rule change, or a change to hooks or autoMode beyond this line." The patch's four deny rules are the excluded case, so the classifier refuses them in the sitting too. The nine `Bash(bash <script> *)` rules may read as a wildcarded interpreter, and the permission-modes docs say broad rules granting arbitrary code execution are dropped on entering auto mode; a `dontAsk` proof can't show whether they survive. Fold: the conductor lands the allow half; Geoff adds the deny lines himself in the same worktree. Make `scripts/dry-run.sh` executable in L1 with a `Bash(scripts/dry-run.sh *)` rule, drop the `bash` forms or record them as Not checked, and add a standing answer that Geoff makes any refused part by hand.

**B2. `scripts/archive.sh` deletes the file it archives.** plan:307 (L5), `prompt.txt:29,35`. The script ends with `rm -f "$file"` after the round trip (line 130 on origin/main). Archiving the Vandelay file itself removes it before the export to ward, the idempotence test, and C1's final pass, and that removal is missing from the prompt's deletions list. Fold: archive a staging copy, once per account rather than per rehearsal round, since each upload is permanent under the Indefinite lock, and list the staging copy's removal.

## Major

**M1. `restore-drill.sh` handles orpheus only.** plan:309 (L7). It hard-codes `[ "$host" = orpheus ] || usage`, the `servers-backup-orpheus` repository, the `drill-orpheus-*` delete guard, and `orpheus-ipv4` for `--hold`, so `restore-drill.sh ward` fails on a usage error. L7 has no Files, Test, or time for ward support, and the script is `auth-data`. Fold: add ward support (per-host bucket, name guard, IP name, Stalwart checks against the snapshot manifest) with Files, Test, and about 45 minutes, runnable during the stock wait; update the path.

**M2. OWNER FORK: the CX33 Decide block names no options in any file, and the executor prompt would override Geoff's answer.** `conductor-prompt.txt:7,21`, `prompt.txt:46`, plan:77. "Never take another server type for ward" beats STATUS, since the prompt wins. `infra/project.env` has one `SERVER_TYPE=cx33` for both hosts. Options: keep waiting; a CX43; another x86 type of at least 4 vCPU and 8 GB. Fold: write the options into the plan's row, add "unless STATUS records Geoff's answer naming a type" to the prompt, and give L2 a per-host type override.

**M3. The Vandelay credential needs an unruled `source` step.** `prompt.txt:31`, `rules.md:47-52`. Vandelay takes credentials only from flags, a prompt, or `VANDELAY_TOKEN`/`VANDELAY_PASSWORD`, with no credential-file option. Shell state doesn't persist between calls, so every run is a compound whose `.` and `set` halves match no rule, and a refusal reads two ways under the stop rules. Fold: one named env file and rules for it, or a small wrapper with its own rule, written in full and proven.

**M4. Live commands are elided with `...`.** `prompt.txt:31`. `restore-drill.sh ward ...`, `archive.sh ...`, `imap-sweep.sh ...`, the Vandelay forms, and the curl forms repeat per account, per round, and in L8, and none names its flags. That is the B3c pattern, where a repeat drops a flag. Fold: write each command in full at the step that runs it.

**M5. "The rehearsal week" means two things.** `preflight.md:90,143`, `prompt.txt:39,75`. The sitting sits in L6 before L7, yet R1 to R3 happen "inside the rehearsal week", which the prompt defines as seven nights of backups after L7's first. Fold: "the sitting days" for R1 to R3, "the backup week" for L8's window; item 7 agrees the session in principle and the conductor books it at the sitting stop.

**M6. R2 rolls ward back past the day's test mail and can collide with the backup band.** `preflight.md:153-159`, plan:308,310. Restoring last night's image erases messages delivered since, whose Message-IDs stay listed, so L8's acceptance fails. Nothing keeps R2 out of 03:20 to 04:00 UTC. Fold: R2 first in the sitting, before any test send that day, and never inside the band.

**M7. Two human steps sit in tasks but not in the pre-flight or the sitting.** plan:305 (L3: "Geoff's Access sign-in opens `ssh-ward.907.life`"), plan:308 (L6 Clients row: Hylki on pavilion is Geoff's GUI app). Fold: an R0 for the Access sign-in and an R4 for Hylki, each with the executor's check, and both in Human steps.

**M8. No answer for a bar that becomes unreachable mid-run.** `prompt.txt:45-63`, plan:308. A row can become unpassable (Microsoft still refusing after delisting and a fresh IP, Gmail locking the account, the second operator unable to attend), and extra rounds would burn 130 each. Fold: finish the other rows, the drill, the monitor, and the runbook; skip a rerun whose cause is traced; close with `## Bar unmet: <row>`; the conductor brings it to Geoff instead of arming the date phase.

**M9. Pre-flight item 2's link leads to two Spamhaus sign-ups.** `preflight.md:34`. The page links both the free non-commercial DQS sign-up and a 30-day trial; a trial key lapses near cutover. Fold: link the free sign-up directly and say it is not the trial.

**M10. The date phase can't find the Message-ID list, and `restic stats` has no home.** `prompt.txt:33,24-25`, plan:310. Fold: name the list's path and recipient in plan and prompt; run `restic stats` on ward over the existing SSH rule, written in full.

**M11. Task clocks can't be resumed after the stock wait.** `prompt.txt:22,29`. The relaunched executor has no record of spent minutes. Fold: `## Waiting: CX33 stock` lists each started task's spent minutes.

## Minor

- **m1.** The Gmail IMAP read and L1's Fastmail JMAP reads have no allow rule. Fold: a `curl --url imaps://imap.gmail.com:993` rule, proven, or route the reads through `dry-run.sh`.
- **m2.** The prompt forbids a pipe on a live script, then prescribes the tunnel-token pipe. Fold: name the exception.
- **m3.** `conductor-prompt.txt:12` runs `scripts/secrets/sync.sh --local` relative to the servers checkout. Fold: the absolute path.
- **m4.** Recurring scheduled tasks expire after seven days; stock can vanish between steps; and if it vanishes after the Primary IPs exist, `provision.sh` fails with a non-3 exit. Fold: recreate the cron on expiry, count days across relaunches, exit 3 when the pinned location lacks stock and the IPs exist.
- **m5.** Item 6 can't show a per-backup restore label on orpheus, which has no backups; item 7 holds launch on a booking whose date depends on stock. Fold: item 6 records the protection and Rebuild labels; item 7 holds only the app names.
- **m6.** Nothing says what thinkpad-x1 gets from the settings and Brewfile changes; `check-drift` will flag vandelay there. Fold: say so, and mark the row pavilion-only.
- **m7.** The Brewfile row needs `tap "stalwartlabs/tap"`.
- **m8.** `docs/addresses.md` still lists four user mailboxes, and L5 has no Files line. Fold: L5 moves household members A's and B's rows to Dropped with the ruling, and lists `docs/addresses.md` and `docs/decisions.md`.
- **m9.** `claude-tooling-sync apply` writes `~/.claude/settings.json` with no rule and may be refused. Fold: Geoff runs it himself in the sitting.
- **m10.** Wording: a fresh Primary IP is inside the $40 ceiling, not a purchase stop; Microsoft's delisting is Microsoft's own sender form; R3 rests on the second operator's report, so name it as a second evidence exception; plan:91's `notify-send` is the conductor's only.

## Over-ceremony

- **o1.** The nine `bash` duplicates of each script rule cost review and proof time, may be dropped in auto mode, and guard a form the prompt forbids.
- **o2.** Re-archiving per rehearsal round adds permanent objects of about 8 GB each under the Indefinite lock.

## Not verified

The Microsoft support article's title, the Hetzner console labels, Gmail 2-Step Verification without a phone, whether `CF_WS_R2_BACKUPS_RO_*` reads `servers-backup-ward`, and whether the classifier accepts a nested `claude -p --permission-mode dontAsk` launch.
