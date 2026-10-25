# Operator runbook plan: fold verification

Target: `self-hosting/plans/2026-10-25-operator-runbook-plan.md` at initiatives `c309c9a`, read against the fold record (`2026-10-25-operator-runbook-plan-fold.md`) and the mechanics, contract, and data reviews. Code was read at servers `f37a5a7` and dotfiles `86f71a3`. This read is fresh-context and read-only. The second operator's identifiers appear only as roles.

Count: 0 blockers, 6 majors, 9 minors.

## Closure of the reviews' blockers and majors

Every blocker closed at its cited location: mechanics B2 (T2 cloud-init per `base/keys/` directory), B3 (forward scrub, ruling 2), and B4 (T2's podman line); contract B1 (T10 key, `git archive`, mechanical grading) and B2 (T1 derivation, the exact OWED list in "Calls", which matches `scripts/dry-run.sh`'s `NEEDS_*` rows at lines 157 and 558-593); data B1 (T1 stores the deployed form and parses with `${line%%=*}`) and B2 (the same root as mechanics B2). Mechanics B1 closed for the backup and the heartbeat, but V-M1 below finds that its third caller, `server-restore`, isn't covered on a rebuilt ward. Data B1 has a residual, which V-M2 below records.

The majors closed at their cited locations, with three exceptions: mechanics M7 is half closed (V-M5), data M1's probe-first step isn't mechanized (V-M6), and contract M8's fold can't run as written (V-M3).

## Sample of the fold's probes, rechecked

These matched the source or a rerun probe:

- `sync.sh:192-197` (the `ws-pass-key` cache fill) and `:235-241` (`IFS='=' read`, `printf 'export %s=%q'`); `secret-set.sh:42` (`RECIP`), `:54` (`flag_path`), `:89-91` (`flock`), and `:114`; `scripts/lib/secrets.sh:33-37` (`_secrets_take` keeps the right-hand side raw).
- `~/.claude/settings.json:89` holds the `secret-set.sh` rule that pre-flight 7 copies.
- `htpasswd -niB -C 10 U` prints the line plus one blank line; `htpasswd -vi` exits 0 on the right password and 3 on a wrong one; `openssl passwd -6 -salt <salt> -stdin` reproduces the hash; `httpd-tools-2.4.69` owns `htpasswd`. (`openssl` on `PATH` resolves to Homebrew's, not the base image's; either works.)
- `golang.org/x/crypto@v0.58.0/bcrypt/bcrypt.go:24` (`DefaultCost` 10) and `:95-97` (`ErrPasswordTooLong` past 72).
- `roles/stalwart/plan.ndjson:6` (`authBanPeriod` 86400000), `roles/webdav/install.sh:72` (start on `.env` alone), `cloudflare/deploy.sh:30` (no `--check`), `roles/stalwart/stalwart-jmap:37` (`show ACCOUNT`), `mail-filters-refresh.service:7` (`Type=oneshot`), `tests/stalwart.test.sh:39-40`, `tests/check.test.sh:28`, and the workstation `secrets/registry.md:557` (the Yahoo account texts Geoff's phone).
- `privacy-check.sh` exits 0 on the plan, the fold record, and the design at `c309c9a`.

## Path arithmetic

The arithmetic holds. The pairs are 160 (T1 140, T2 160), 135 (T3 105, T3b 135), 135 (T4 65, T5 135), 150 (T6 150, T7 120), and 140 (T8 140, T9 90), and the singles are T10 75 and T11 85, for 880. The tasks sum to 1,400. A "no" on ruling 1 raises T3b to 195 and the path to 940. A "no" on ruling 4 raises T2 to 180 and the path to 900. Both together give 960. 880 is 280 over the design's 600 and under the 1,200 ceiling. V-M1's fold adds a few minutes to T3b and leaves the path at 880, since T3b would still run inside its 135.

## Majors

**V-M1. A ward he rebuilds fails `server-restore` at its count check, and ruling 1's evidence omits it** (major, correctness). Plan:23 (Brief fact 5 names `server-restore:158` as a caller), plan:42 (ruling 1), plan:156 and plan:161 (T3b's skip and its test).
Defect: `roles/mail-backup/server-restore:158-166` compares the restored counts with the snapshot's manifest as `($now[.key] // -999) - .value`, then dies on any key off by more than 10. On a ward with no `stalwart-geoff.env`, ruling 1's skip drops Geoff's mailbox from `now`, so the manifest's key for that mailbox reads -999. The script then exits 1 with "counts differ from the manifest" after it has restored the mail and started Stalwart. That is the bus-day rebuild path, the one ruling 1 exists for. Ruling 1 says only that "the backup and heartbeat go on", so Geoff rules without knowing that the restore step reports failure. T3b's test covers `counts` alone.
Proposed fold: T3b's skip also covers `server-restore`'s comparison. An account that `counts` skipped is left out of the comparison, with the same warning line. Add a `server-restore` test with the file absent. Add to ruling 1's text: "and `server-restore` compares the other mailboxes only". The rebuild screen says so as well.

**V-M2. T3's merged render escapes the stored form a second time, so its acceptance fails for every name T1 marks `differs`** (major, correctness). Plan:26 (Brief fact 8), plan:130 (T1 values loop), plan:148 and plan:151 (T3 render and acceptance), plan:251 (Before merge 3).
Defect: T1 stores X, the form `secrets_load` yields today. Since `_secrets_take` keeps the right-hand side raw, X is exactly `%q` of the original value. T3's writers then put each servers-store line through `printf 'export %s=%q'` (`sync.sh:241`), so `~/.local/secrets` holds `%q(X)`. The new loader is unaffected, because the store wins, and a shell that sources the file gets X. The old loader reads `%q(X)`, which differs from X whenever X holds a backslash. T3's acceptance feeds the overlay to "the old and new `secrets_load`" and expects `same`, so it fails on exactly the names the T1 standing answer anticipates. The same thing would hit outside the tests. Any servers checkout still on the old loader after the workstation merge (the ward-probes worktree before its rebase, an un-pulled clone) loads the double-escaped value. An apply or deploy from it then renders that value onto a host, and the stale-store guard can't stop it, because the guard is new code.
Proposed fold: (1) T3's acceptance compares the new loader fed the overlay with T1's recorded result, and says that the old loader is expected to differ on the `differs` names. (2) In Before merge 3 and After merge 6, every servers checkout and worktree that might apply or deploy (pavilion, thinkpad-x1, `.claude/worktrees/ward-probes`) carries the new `scripts/lib/secrets.sh` before the workstation PR merges. (3) Under `## Decisions`, record that an interactive shell sourcing `~/.local/secrets` now gets the deployed form for those names.

**V-M3. T4's rekey to A alone fails T1's own write check** (major, correctness). Plan:126 (each write "checks that the output decrypts"), plan:165 (T4's scratch store "rekeyed ... to A's recipient alone").
Defect: `rekey` decrypts the input with the identity it finds first, which on pavilion is Geoff's cached key, and then verifies the output. When the recipients file names A alone, Geoff's key can't open the output, so the decrypt check refuses the write. Setting `SERVERS_AGE_IDENTITY` to A instead fails at the input, which only Geoff's key opens. As written, the step can only run outside `store.sh`, by piping plaintext to `age -r` by hand. That skips the stanza and name checks and the pinned permission rule.
Proposed fold: write T4's rekey as two `store.sh rekey` runs on the scratch store. The first uses recipients Geoff plus A and the cached identity. The second uses `SERVERS_AGE_IDENTITY=<A>` and recipients A alone. T1's tests cover the two-step handoff to a new sole recipient.

**V-M4. The route check's `--check` runs need git, and the container has no git directory** (major, correctness). Plan:128 ("`--check` prints which store blob it would use"), plan:142 (the podman line mounts `$WORKTREE:/repo:ro` only), plan:141 (the tool list doesn't name `git`), plan:168 ("Both `--check` runs exit 0").
Defect: today `apply.sh --check` exits before its one git call (`scripts/apply.sh:98`), so it needs no git. T1's guard adds `git rev-parse HEAD:secrets/servers.age` to `--check`. A worktree's `.git` is a file that points to `/var/home/glw907/Projects/servers/.git/worktrees/<name>`, and route-check.sh doesn't mount that path, so git fails in the image and T4's acceptance can't pass. The plan also doesn't say which blob the guard reads when `SERVERS_STORE` points at a scratch file. In that case the committed blob and the store in use are different files.
Proposed fold: route-check.sh mounts the main checkout's `.git` read-only at the same absolute path, or T4 runs against a `git clone --local` of the branch in `/dev/shm`. Add `git` to `tools/mint-packages.txt`. State the override case: when `SERVERS_STORE` is set, `--check` prints the override path and skips the blob comparison, and `--apply` refuses.

**V-M5. A moved name rotated between T11 and the merge is still lost** (major, correctness). Plan:239 (T11 store recheck), plan:249 (Before merge 1). Mechanics M7 asked for the recheck "at T11 and before merge". The fold record (line 37) folded T11 only.
Defect: the packet can wait days. If Geoff rotates a moved name on main in that time, Before merge 1 sees the `values.age` blob change and redoes T3's deletions on main's current file. That deletes the new value, while the servers store still holds the old one. The first apply after the merge then puts the old value back on the host. After merge 1 covers only Stalwart and WebDAV.
Proposed fold: Before merge 1 reruns T11's per-name comparison first (the old loader on pavilion's current `~/.local/secrets` against the new loader on the servers branch's store), and `store.sh set` updates any `differs` name on the servers branch before the deletions are redone.

**V-M6. "Proven on a test login before Geoff's" has no step that does it** (major, correctness). Plan:155 (T3b, the probe account's `secret_hash`), plan:260-263 (After merge 1 and 2). This is data M1's fold item 2.
Defect: After merge 2 applies ward once, and that one apply carries the probe's credential and Geoff's together, so the probe never signs in before Geoff's credential changes. After merge 1 proves that each hash matches its installed plaintext. It doesn't prove that Stalwart v0.16.27 stores a pre-hashed credential as it is, and that rests on a source read alone. If the source read is wrong, Geoff's mailbox is the first live test, and the 24-hour ban follows.
Proposed fold, either (a) or (b), with (a) recommended. (a) A T3b container test runs the pinned Stalwart image, applies a plan with a `$6$` secret, and signs in over JMAP, the way T3b's rclone test does. If the image won't run under rootless podman, that goes under `## Not checked`. (b) Split the change into two commits applied in order: the probe's switch first, then `stalwart-jmap show probe` signs in, then Geoff's switch. Either way, drop the sentence's claim or make it true.

## Minors

**V-m1. One after-merge check passes vacuously** (minor, correctness). Plan:264. `systemctl show -p Result mail-filters-refresh.service` has no `ssh geoff@ward.907.life` prefix. Run on pavilion, it reads a unit that doesn't exist and prints `Result=success` with exit 0 (probed). Proposed fold: prefix the ssh, as the `start` line has it.

**V-m2. Entry and Close disagree on unanswered rulings** (minor, correctness). Plan:68 requires "every ruling is answered" before launch. Plan:275 makes "any ruling Geoff hasn't answered at plan approval" an ask in the packet. Proposed fold: drop the Close sentence, or let Entry launch on the recommended answers with that ruling carried to the packet.

**V-m3. T5 needs T4's outputs, but they run as a pair** (minor, correctness). Plan:166 records the host fingerprints "for T5's screen". Plan:168 makes T4's title list the source of item names for "the docs tasks". T5 writes the emergency screens in parallel with T4. Proposed fold: T5 writes marked placeholders for the fingerprints and `Household IT` titles. The main loop fills them after T4, before T5's acceptance runs.

**V-m4. The stub proof doesn't cover the form T4 runs** (minor, correctness). Plan:87 and plan:165. T4 calls `store.sh` with leading assignments (`SERVERS_STORE=... SERVERS_RECIPIENTS=... .../store.sh rekey`). Nothing shows that a `Bash(<path>/store.sh *)` rule matches a command with assignments in front. If it doesn't, auto mode prompts or denies mid-pass. Proposed fold: the pre-flight 7 stub proof runs that exact form. If it's denied, `store.sh` takes `--store` and `--recipients` flags, guarded like `flag_path`.

**V-m5. `SERVERS_STORE_BRANCH_OK=1` on `store.sh rekey` does nothing** (minor, correctness). Plan:205. The guard lives in `apply.sh --apply`, `render.sh`, and `deploy.sh` (plan:128). The fold refused data M3's write-only-on-main rule for `store.sh`. Proposed fold: drop the variable from that line, or name the apply it is for.

**V-m6. The stale-hash check covers only Geoff's logins** (minor, correctness). Plan:157. The other two members keep both their plaintext and their htpasswd line in the servers store. A `store.sh set` rotation without `set-hash` leaves the share on the old password, and nothing shows it until `dry-run.sh`. Proposed fold: `render.sh` runs the same check wherever a member's plaintext and hash both render, which for those two is every operator's machine. T7's rotation steps name both commands.

**V-m7. The probe account's hash name is never named** (minor, correctness). Plan:155, 162, and 260. After merge 1 compares "the new `$6$` hash ... for the probe account", but no task names that store variable, adds it to `stalwart.env`, or lists it in T3b's acceptance. The probe's plaintext must also stay in `stalwart.env`, since `stalwart-status counts` and `scripts/webmail-check.py:23` sign in with it. Proposed fold: name `STALWART_PASSWORD_HASH_TEST`, add it to the template and to T3b's `store.sh names` acceptance, and say that the plaintext stays.

**V-m8. "Allowed history paths" in the workstation repo has no list** (minor, correctness). Plan:214. The list at plan:178 names servers paths only. Proposed fold: list the workstation paths that may keep "Servers emergency", or require zero hits there.

**V-m9. The fold record's totals line misplaces the ceiling** (minor, correctness). Fold record:5. "task sum 1,165 to 1,400, under the 1,200 ceiling" reads as if 1,400 were under 1,200. The ceiling applies to the path. Proposed fold: "Path 720 to 880 minutes, under the 1,200 path ceiling; task sum 1,165 to 1,400."

## Rulings for Geoff

The evidence given is enough to rule 2, 3, 4, 5, and 6. Each states the question, the recommendation, and the other answer's build and cost, and ruling 6's premise checks out against the workstation registry. Ruling 1 isn't ready until V-M1's fold adds the `server-restore` consequence to its text.

## Privacy

`~/Projects/servers/scripts/privacy-check.sh` exits 0 on this file.
