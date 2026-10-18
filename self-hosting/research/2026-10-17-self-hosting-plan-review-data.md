# Self-hosting plan review: data integrity and failure risk (2026-10-17)

Target: `self-hosting/plans/2026-10-17-self-hosting-plan.md` at `7061df9`, read against `self-hosting/specs/2026-10-17-self-hosting-design.md` (the design wins where the two disagree), the research briefs, and `pass-core`. In this review the plan is cited as `plan:N` and the design as `design:N`.

**Verdict.** The plan handles the lock order correctly: buckets start empty, the archive's lock comes first, media's lands after the first verified backup, and mail's after the last rehearsal import. The serious gaps are around that order. The secret store that holds every restic password can silently drop an entry when two sessions write at once, and a new password lives only in an uncommitted working tree. With the repository locked for good, losing that password means the backups can never be opened, and the bucket can't be emptied either. Nothing mechanical stops an unattended session from lifting a lock rule or deleting a bucket. `dns.sh`'s never-delete contract can't carry the photos switch, the MX switch, or the MX rollback. And the two household-data deletes the plan runs unattended (L8's test messages, the Trash/Junk empty) have no selector.

Counts: 1 blocker, 12 major, 14 minor.

Mechanisms come from a source read in this session, as cited: the workstation's `scripts/secrets/secret-set.sh`, Cloudflare's Wrangler R2 command reference (through the Cloudflare docs search), the Ansible `hetzner.hcloud` server module docs, and the fold record's quotes from the R2 bucket-locks page.

## Blocker

### B1. The age store can lose a restic password silently, and a new password lives only in an uncommitted working tree (correctness)

- **Location:** plan:68, plan:160 (M6), plan:194 (L3), plan:124-134 (Pass W running alongside); `~/.dotfiles/scripts/secrets/secret-set.sh:36,155,173,95`.
- **Defect:** `secret-set.sh` reads, modifies, and writes the store with no lock. It decrypts `values.age`, writes everything except `NAME` to a new file (`grep -v "^${NAME}=" "$DEC" > "$NEW"`, line 155), re-encrypts, and `mv "$VALUES.tmp" "$VALUES"` (line 173). The check before that swap confirms only that `NAME` is present (`grep -q "^${NAME}="`), never that the other entries survived. It writes `~/.local/secrets` the same way (`cp "$out" "$LOCAL_SECRETS"`, line 95), and it never commits. If two sessions store a secret at the same moment, the last `mv` wins and the other secret disappears without an error. The plan runs several writers at once on pavilion: conductor-launched server passes, Pass W, Pass 4, and Geoff's import session. `values.age` is a tracked file in the workstation's main checkout (`VALUES` defaults to `$HOME/.dotfiles/secrets/values.age`), so an unattended pass leaves warm uncommitted changes there. The global CLAUDE.md treats warm uncommitted changes as a stop-and-investigate signal. That same rule invites a later session to stash or discard them. M6 and L3 never say when the restic password is generated, stored, verified, or pushed, compared with `restic init` and the lock rule. Once M6 or L7 puts `config` and `keys/` under Indefinite, a lost password leaves a repository nobody can open and nobody can empty ("A bucket cannot be emptied while any bucket lock rules are configured", fold verification line 35).
- **Fold:**
  1. Pass 0's PR (0.10) adds `flock` on a lock file beside `values.age` around the whole read-modify-write in `secret-set.sh`, and around `sync.sh`'s write to `~/.local/secrets`. After re-encrypting, the script checks that the entry count equals the old count plus one for an add, so a dropped entry fails the run. Add a test for both. W1 keeps the lock when it swaps `op` for `ws-pass-key`.
  2. M6 and L3 gain an explicit order:
     1. Generate the restic password on the workstation.
     2. Store it with `secret-set.sh`.
     3. Decrypt it back and compare hashes.
     4. Commit and push `values.age` on a branch the session self-merges, or the workstation's recorded secret-commit path.
     5. Confirm the pushed blob decrypts to the same hash.
     6. Only then run `restic init`.
  3. The lock-rule step (M6, L7) has an entry check that the password's commit is on `origin/main`.
  4. The same rule covers every token a server can't be rebuilt without: the heartbeat, the tunnel, and the R2 write token.

## Major

### M1. Nothing mechanical stops an unattended session from lifting a lock rule or deleting a bucket (correctness)

- **Location:** plan:108 (0.10), plan:141 (F2), plan:160, plan:198; design:443 ("Only Geoff lifts one, by hand, and never as part of an unattended run").
- **Defect:** 0.10 adds deny rules for `hcloud * delete` and `hcloud * disable-protection` only. Unattended sessions source `CLOUDFLARE_API_TOKEN`, a full-account token that can edit bucket configuration. Each Worker carries `wrangler` as a dev dependency (plan:80), and Wrangler ships `r2 bucket lock remove` ("Remove a bucket lock rule"), `r2 bucket lock set` ("Set the lock configuration ... from a JSON file", which replaces the whole set), and `r2 bucket delete`, per the Wrangler R2 command reference. A raw `curl` to the bucket's lock endpoint does the same. The plan says `r2.sh` "only ever adds a rule" but gives no test for that. A `set` with a malformed rule list would remove rules without warning. Today, only the classifier and Claude's instructions guard the one guarantee the lock ruling exists to make.
- **Fold:**
  - 0.10 adds deny rules for `wrangler r2 bucket lock remove`, `wrangler r2 bucket lock set`, `wrangler r2 bucket delete` (with and without an `npx` prefix), and `curl` with `DELETE` or `PUT` against the bucket and lock endpoints. Test each rule against `env`, `command`, and `bash -c` wrappers.
  - F2 builds `r2.sh` on `lock add` only. The gate fails on `lock remove`, `lock set`, or `bucket delete` anywhere in `cloudflare/` or `scripts/`, the same way it treats `disable-protection`.
  - After every `--apply`, `r2.sh --check` lists the live rules and fails if any declared rule is missing. Test that first.
  - The runbook's lift procedure runs only from Geoff's own terminal.

### M2. `dns.sh` can't carry the photos switch, the MX switch, or the MX rollback (correctness)

- **Location:** plan:144 (F5), plan:170 (I1), plan:207 (C1); design:282, design:350, design:355.
- **Defect:** `dns.sh --apply` "writes only declared records" and never deletes one. Switching photos from the proxied CNAME to A and AAAA means deleting the CNAME, because a CNAME can't coexist with other records at the same name. Switching MX to `mail.907.life` means removing Fastmail's MX records, since the design says the new MX is "never mixed with Fastmail's". The rollback means removing ours and putting Fastmail's back, within 30 minutes and "without waiting for Geoff". No allow-listed path does any of this, so the cutover and the rollback would run as improvised raw API calls under time pressure, with nothing recording the prior values.
- **Fold:** F5 gives `dns.sh` record-set semantics. A declared name owns every record of its declared types, and `--apply` replaces that set, deleting only at names the repo declares. The dry run prints each deletion. Test first, and class it `auth-data`. I1 and C1 each start by saving the live record set to `docs/cutover-log.md`, and each prepares its rollback as a committed declaration (`dns/rollback-photos`, `dns/rollback-mx`). L4 or L6 runs the switch and the rollback once against `probe.907.life`, or a scratch name, before cutover day. L4 confirms the apex MX TTL is 300 seconds; design:355 assumes it is, and nothing checks.

### M3. No count check runs between the final Vandelay pass and the MX switch (correctness)

- **Location:** plan:207 (C1 acceptance); design:339-340, design:305.
- **Defect:** The final pass imports into a Stalwart that already holds the rehearsal's full copies. Nothing in the plan or the brief says whether Vandelay's import is idempotent. A second import that duplicates each mailbox, or a pass that stops partway, goes straight to the MX switch. C1's acceptance covers the probe, a send, clients, and Immich mail, and never the counts. The rehearsal's count rows ran once, before the final pass. After the switch, new mail makes the counts drift and harder to read.
- **Fold:** Between steps 2 and 3, C1 reruns the rehearsal's Mail counts and Flags rows against the final archive's `vandelay inspect`, per account. Repeat the Trash and Junk empty there too (design:305). The MX switch waits until both pass. If they fail, cutover stops before the switch, which needs no rollback. L5 or L6 answers the idempotence question: import the same archive twice into a test account and compare the counts.

### M4. L8 deletes "the rehearsal's test messages" from household mailboxes with no selector (correctness)

- **Location:** plan:199 (L8); design:332; plan:197 (the Late mail and reverse-sync rows).
- **Defect:** An unattended run deletes messages from real mailboxes. The task names no rule for picking them, sets no count check before or after, and doesn't say which side it runs on: Fastmail, where L6's reverse sync wrote into a scratch folder in members' live accounts, or Stalwart. A selector that's too wide removes household mail at the source, and the final pass then never carries it.
- **Fold:** Every test message created in L6 carries a fixed header token, and its Message-ID goes into a list kept outside git. L8 deletes only by exact Message-ID from that list, checks each mailbox's count before and after (the difference must equal the list's length), and deletes the scratch Fastmail folder by its name. It deletes nothing else in Fastmail. Class L8 `auth-data`.

### M5. The Immich rollback has no way to carry uploads made after the freeze, and the next attempt's wipe orphans them (correctness)

- **Location:** plan:170 (I1, "the rollback in the design's 'Photos' applies"); design:415.
- **Defect:** Rolling back means "any uploads made since the freeze are copied back to it". Copying originals into the pod's upload folder doesn't register them in its database, and the plan names no other way. A retry then runs "rehearsal data wiped", which drops the new server's database rows for those assets, leaving their files orphaned. The 150 MB acceptance upload is itself such an asset. Whether the phone apps upload again after a rollback isn't checked anywhere.
- **Fold:** Before the DNS switch, record `/api/server/statistics` and the newest asset id per user. On rollback, first list the assets created after the freeze per user through the new server's API, into STATUS. Re-upload them to the pod with the Immich CLI and each owner's API key, or, if no key is at hand, keep the new server's database and library untouched until the retry imports them. A retry never wipes while that list isn't empty. Class I1 `auth-data`, since it can delete household photos.

### M6. The SFTP copy from the live pod has no fixed direction (correctness)

- **Location:** plan:159 (M5), plan:170 (I1 delta copy); design:407.
- **Defect:** The pod stays production until I4. Its SFTP login can write, and the plan names no tool or flags for the copy. A `sync` that's reversed or that deletes would wipe the household's originals on the pod, and no backup of the pod exists outside PikaPods.
- **Fold:** One committed wrapper, `scripts/pod-pull.sh`, copies from the pod to local only (for example `rclone copy`, never `sync` or `move`, with the destination checked to be local). Test first. Class it `auth-data`. The only write toward the pod is M5's rollback re-upload, through the API.

### M7. A production rebuild can lose mail accepted after its backup, and `provision.sh` is classed `runner` (correctness)

- **Location:** plan:155 (M1, class `runner`), plan:24 (path map); design:618; design:480-481 (the mail backup restarts Stalwart in step 4, and its trap restarts it too).
- **Defect:** `provision.sh` refuses a rebuild "unless the service is stopped, a backup ran, and a snapshot exists in the same run". But the mail backup unit starts Stalwart again at step 4, and its trap does too. A stop, then the standard backup, then a snapshot and a rebuild leaves Stalwart running and accepting mail between the backup and the disk wipe. That mail is gone, because sending servers don't retry mail that was already accepted. Delete protection doesn't cover rebuilds: Hetzner keeps rebuild protection as a separate flag, which "needs to be the same as delete_protection" (Ansible `hetzner.hcloud` server module, `rebuild_protection`), and the plan never sets it. The script that can wipe a production disk sits in the `runner` class, so it gets no test-first and no `diff-reviewer` read.
- **Fold:** Move `infra/provision.sh` and `scripts/promote.sh` into the `auth-data` path map. The backup unit gains a `--keep-stopped` mode for the pre-rebuild run. `provision.sh` checks, right before the rebuild call, that the service is inactive and that the backup and snapshot both postdate the stop. Test first against the fake `hcloud`.
- **OWNER FORK, rebuild protection:**
  - (a) Turn on rebuild protection for production. A rebuild then needs Geoff, because the gate forbids scripts from calling `disable-protection`.
  - (b) Leave it off and rely on the tested guard. Claude keeps the rebuild authority the design rules.

  Recommendation: (b), with the guard above, because the design grants rebuild authority (design:66).

### M8. Pair arms inherit live tokens and allow rules, so their isolation rests on instructions alone (correctness)

- **Location:** plan:64 (dispatch note), plan:84 (the token in the environment), plan:155 (M1 tests against a fake `hcloud`).
- **Defect:** "An arm never touches a live account" is an instruction. Arms are `general-purpose` subagents with every tool. Their Bash starts from the user profile, so `HCLOUD_TOKEN`, `CLOUDFLARE_API_TOKEN`, and the members' IMAP app passwords are in reach, and the session's allow rules (`provision.sh --apply`, `restore-drill.sh`, `dns.sh --apply`) apply to them too. A test that fails to put its fake `hcloud` first on `PATH` runs the real binary against the real project.
- **Fold:** Each arm's setup command unsets the live token variables and points `HCLOUD_CONFIG` at an empty file. The test harness checks that `command -v hcloud` resolves to the fake and that no token variable is set. Every `--apply` path refuses when `SERVERS_TEST=1` is set or when the call comes from inside a `.claude/worktrees/` path. Test first in F1's gate.

### M9. The privacy grep can't see IPs, ntfy topic names, or the second operator's Unix name, and a leaked topic defeats the dead-man check (correctness)

- **Location:** plan:14, plan:112 (0.11), plan:145 (F6), plan:158 (M4); design:540, design:558.
- **Defect:** 0.11 builds the patterns file from "the names, addresses, and usernames Geoff confirms". The plan's own privacy list also keeps IPs, ntfy topic names, and GitHub usernames out of public repos, but Pass 0 doesn't know those values yet: the topics come in F3 and F6, the IPs in M4 and L2, the GitHub email and Unix name in M4. Nothing adds them to the file later. ntfy.sh topics have no authentication, so anyone who learns the routine topic can post the six-hourly all-quiet. That silences the one check that "Silence must not pass for health" rests on. They can also read every alert. The file exists only on the host where Pass 0 ran, and `grep -f` with an empty file matches nothing, so the check passes without saying anything.
- **Fold:** Each task that learns a private value adds it to the patterns file in the same step: F3/F6 the topics, M4/L2 the IPs, M4 the GitHub email and Unix name. The file lives in the age store as one entry, so both hosts get it through `sync.sh`. The check fails if the file is missing or has fewer lines than a recorded count. The grep also covers commit messages and PR bodies on public repos.

### M10. The paper copy of the age key is never checked (correctness)

- **Location:** plan:112 (0.11); design:523; design:641 (the 1Password evidence).
- **Defect:** The age key is written by hand and the kit is locked away. That key is the last way back to every restic password, every token, and every archive once 1Password is cancelled. A slip in the 74-character Bech32 string goes unnoticed until the day the kit is needed. Bech32's checksum would reject the key then, but by then nothing is left to fix it from.
- **Fold:** 0.11 adds a check. Geoff types the paper key back through `secret-receive` into tmpfs. Claude derives the public key with `age-keygen -y` and compares it with the store's recipient. Neither key is printed, and the tmpfs copy is shredded. P4's packet carries the date of that check as an evidence row.

### M11. Merging Pass W moves each host onto the Proton path before that host's agent token exists (correctness)

- **Location:** plan:126-134 (W1, W4, W5), plan:8 (thinkpad-x1's per-host steps); design:596.
- **Defect:** Once W4 merges and the packages are restowed, `secret-set.sh` and `sync.sh` call `ws-pass-key` instead of `op`. W5, Geoff's FIDO2 session, and thinkpad-x1's token come later, and thinkpad-x1's only when Geoff is there. Until then, any unattended server pass on pavilion that stores a secret fails in the middle of a task once the cached key clears. That happens on the next reboot, or when `claude` exits and runs `secret-session-clear`. thinkpad-x1 breaks the next time it pulls. The design's step 5 exists so a cached key can't hide exactly this break.
- **Fold:** `ws-pass-key` reads `op` until the host has a marker file that W5 writes after its hash check passes. Alternatively, W4's install steps refuse to stow on a host whose keyring holds no agent token. Either way, add a test. Unattended passes check, before they start, that the host's token expires more than 14 days after the pass's planned end.

### M12. M4's temporary Access account can be the `geoff` account (correctness)

- **Location:** plan:158 (M4); design:210, design:231.
- **Defect:** M4 tests the terminal "on a temporary account named for his prefix, removed after". If Geoff's GitHub email prefix is `geoff`, that account already exists. It holds Geoff's key and the workstation key Claude uses. Removing it in an unattended pass locks out every path except the Hetzner console.
- **Fold:** M4 first checks that the prefix differs from every existing account. If it matches, M4 tests on the existing account and removes nothing. `userdel` never runs against `geoff` or the second operator's account. Add a test in `apply.sh` or the step's script.

## Minor

1. **The mail drill runs after the lock, but L6's acceptance includes it.** `correctness`, plan:197-198. L6 says "every row passes in one round", yet the Restore row's drill is in L7, after `r2.sh --apply`. A drill that exposes a broken backup shape would then be locked in for good. **Fold:** take the Restore row out of L6's acceptance. In L7, run the drill first and add the lock only after it passes, since the drill's read-only token doesn't need the lock.
2. **The F2 scratch-bucket probe needs Claude to lift a lock.** `correctness` and over-ceremony, plan:141. You can't delete a scratch bucket while an Indefinite rule sits on it, so "deleted after" means Claude removes a rule, which the design reserves for Geoff (design:443). The fold already probed the rule mechanics live (fold record line 43). **Fold:** drop the scratch probe. Prove the rule shape with `r2.sh --check` reading back `servers-archive`'s rules after apply, plus the 409 delete test already in the acceptance. That saves about 15 minutes and removes the exception.
3. **`archive.sh` and the Indefinite lock on a reused name.** `correctness`, plan:141, plan:196. A second upload under an existing key gets a 409 under the lock. Nothing tests that this leaves the plaintext in place. L5 also archives, and so removes, the Vandelay SQLite files that L6's `vandelay inspect` and the final pass may still need. **Fold:** object keys carry a UTC timestamp. Add a test that a 409 exits non-zero and keeps the plaintext. L5 archives a copy, and removes the local archive only after C1.
4. **The hand copy into `Servers emergency` is never checked.** `correctness`, plan:162, plan:198; design:573. Geoff copies restic passwords and tokens by hand. A slip only surfaces in D5, months later, or in a real emergency. **Fold:** Geoff pastes rather than types. Then, in his own `pass-cli` session, he runs a script that prints one hash per item, which Claude compares with hashes from the staged file, the same pattern as the import's count script. Remove the staged file with a trap, so it's gone even if the session crashes.
5. **I2 may be a minor upgrade without its drill copy.** `correctness`, plan:171; design:507. "The current v3 patch", counted from the pod's version, can cross a minor. **Fold:** I2 compares the two versions. A minor or major runs on a drill copy first.
6. **The Immich freeze leaves a gap between the final dump and the pod stop.** `correctness`, plan:170. Background backups in the phone apps keep uploading whatever the freeze message says. An asset uploaded in that gap makes the counts differ, which forces a rollback. **Fold:** read the statistics right before the stop and compare them with the dump's restored counts. On a mismatch, start the pod, dump again, and stop it again before declaring failure.
7. **imapsync direction and delete flags.** `correctness`, plan:209 (C3), design:355. The sweeps run from Fastmail to Stalwart and the rollback runs the other way, using members' IMAP app passwords, which can write. **Fold:** one wrapper with a fixed direction per verb that refuses `--delete1`, `--delete2`, and `--expunge*`. Test first. The sweeps hold the backup's `flock` so they never overlap the 03:30 stop.
8. **The Trash and Junk empty trusts Vandelay's role mapping.** `correctness`, plan:196; design:305. If Vandelay maps another folder to the Trash role, emptying it deletes real mail. **Fold:** empty a mailbox only if its role and name both match and its count equals the archive's Trash or Junk count.
9. **Mixing up account mappings.** `correctness`, plan:196. Importing member A's mail into member B's Stalwart account is a privacy breach that counts catch only by chance. **Fold:** the script resolves the target from the Fastmail account's login address, never from the order of a list, and the dry run shows each pair.
10. **0.12 dry-run output.** `optional`, plan:116. **Fold:** no `curl -v`, and each token passed in a header file, so neither the transcript nor `/proc` shows it.
11. **The monitor's R2 binding can write to the backup buckets.** `optional`, plan:142. Worker bindings read and write. A leaked deploy token can then delete unlocked `index/` and `snapshots/` objects, which `recover` can rebuild. **Fold:** record it in the runbook's Claude infrastructure section as an extra path that writes to the backups.
12. **W3 retires `claude-block-op` while `op` stays installed until P4.** `optional`, plan:128. The hook only limits loops (allow, but deny "3+ op calls in the last 60 seconds", per `claude-block-op`). Retiring it brings back the popup loop it was built to stop. **Fold:** keep it until the P4 uninstall PR.
13. **A final Vandelay pass of each removed Fastmail account.** `optional`, plan:210 (C4); design:639. Removing the three users deletes their Fastmail data. The latest cold copy dates from cutover. **Fold:** add a final archive per account just before the packet, as an evidence row.
14. **Pass 0's operational steps are classed `auth-data`.** `optional`, over-ceremony, plan:84, 88, 96, 104, 116. 0.4, 0.5, 0.7, 0.9, and 0.12 produce no commit, so "test-first" and the `diff-reviewer` read have nothing to act on. The risk lives in the store writes, which B1 covers. **Fold:** class those steps `ordinary` with `live-account`, and keep `auth-data` for 0.10's commits. That saves a few reviewer dispatches and avoids empty ceremony.

## What holds

- Order of buckets, locks, and repositories: empty buckets first (0.5), the archive's Indefinite rule before any archive (F2), media's rules after the first verified backup (M6), and mail's after the last rehearsal import (L7). This matches design:443, and the R2 fact that "Rules apply to both new and existing objects" covers the packs already uploaded.
- Retention against the lock: `--keep-within 35d` on top of the 30-day rule on `snapshots/`, re-derived in fold verification 2.
- `archive.sh`'s check for the age header and its round trip before removing plaintext.
- Drill isolation: a fixed role list, a read-only token, and the two firewalls.
- Delete protection on production plus a gate that fails on `disable-protection`. This doesn't cover rebuilds; see M7.
- Claude never calls `pass-cli` against Geoff's vaults, and the emergency vault is filled through Geoff.
