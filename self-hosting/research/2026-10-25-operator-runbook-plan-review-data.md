# Operator runbook plan: data-integrity and failure-risk review

Target: `self-hosting/plans/2026-10-25-operator-runbook-plan.md` at initiatives `9552ef9`, against the approved design `self-hosting/specs/2026-10-25-operator-runbook-design.md`. The code was read at servers `f37a5a7` and in the dotfiles main checkout. This review is read-only and reopens no design ruling.

Lens: what happens on a crash, a concurrent writer, a partial write, an upgrade, or a restore, and whether data can be lost or silently corrupted.

Count: 2 blockers, 7 majors, 8 minors, plus 1 OWNER FORK.

Findings are ranked by consequence. Each one gives a severity, a tag, a location, the defect, and a proposed fold.

---

## B1. The cutover can silently change every server secret that has a shell-special character (blocker, correctness)

Location: plan:101-104 (T1 `secrets_load`, the main loop, acceptance) and plan:214 (the before-merge check). Code: `servers/scripts/lib/secrets.sh:33-37`, `dotfiles/scripts/secrets/sync.sh:241` and `secret-set.sh:114`.

Defect: today `~/.local/secrets` is written with `printf 'export %s=%q'`, and `_secrets_take` keeps the right-hand side raw, without unquoting it. So every servers script now gets the `%q`-escaped string. I checked this: a value `pa$s!w0rd#1` loads as `pa\$s\!w0rd#1`. The servers and Stalwart therefore hold the escaped form for any value with `$ ! space ' " ( ) * ? [ ] { } | & ; < > \` or a backtick. T1 puts the raw value in the store and makes the store win. The first apply after the merge then renders a different value for each such name. The consequences:

- The admin login breaks, so `stalwart-apply` can't sign in.
- `RESTIC_PASSWORD` changes, so backups fail with "wrong password".
- The tunnel token and the Worker secrets change through `deploy.sh`.

T1's acceptance compares `values.age` with `servers.age`, which hold the same raw bytes, so that check is blind to the change. The before-merge check compares names only. A second quirk adds to this. `sync.sh` and `secret-set.sh` split lines with `IFS='=' read -r key value`, which drops a single trailing `=`; `A=abc=` reads as `abc`. A value with one base64 pad has been truncated in `~/.local/secrets` too. If T3 reuses that loop for the merged render, the truncation carries into the new path.

Fold:

1. In the T1 main loop, compare for each moved name the value `secrets_load` yields before the change (from `~/.local/secrets`) with the value it yields after (from the store). Compare in-process, print only `same` or `differs`, and treat any `differs` as a stop.
2. Decide per differing name which form the live service holds. The installed file on the host is the authority. Store that form.
3. Add a T1 test that round-trips a value containing `$`, `!`, a space, and a trailing `=` byte-exactly from the store to a rendered file.
4. T3's merged render parses with `${line%%=*}` and `${line#*=}`, never `IFS='=' read`.

## B2. The second operator can't reach a rebuilt, provisioned, or drill host (blocker, correctness)

Location: plan:48, plan:108-109 (T2 ssh user and keys). Code: `servers/base/cloud-init.yaml:11-20`, `infra/project.env:13-14`, `infra/provision.sh:346`, `scripts/promote.sh:151`, `scripts/restore-drill.sh:348`, `roles/cloudflared/operators.sh:50-77`.

Defect: on a fresh host, cloud-init creates only `geoff`, with `base/keys/*.pub`. The `<his account>` account, and its sudo, appear only when the `cloudflared` role runs during an apply. T2 keeps cloud-init inlining only `base/keys/geoff/`, and `project.env`'s `SSH_USER` "follows" `SERVERS_SSH_USER`. That leaves two outcomes for him:

- With `SERVERS_SSH_USER=<his account>`, `provision.sh`, `promote.sh`, and `restore-drill.sh` ssh to an account that doesn't exist yet.
- With `geoff`, his key isn't there.

The browser terminal needs the `cloudflared` role, which also comes from that first apply. The `geoff` password is locked, so the Hetzner console doesn't help. On the bus day he can't rebuild a lost server or run the monthly restore drill. The design requires both: "keep everything running the way Geoff runs it now", and the upkeep list includes drills. T2's file list also omits `promote.sh`, `restore-drill.sh`, and `provision.sh`.

Fold: render cloud-init's `users:` from `base/keys/<name>/`, one user per directory, each with `sudo: ALL=(ALL) NOPASSWD:ALL` and its own keys. Extend `tests/base.test.sh` to compare each directory with its cloud-init user. Point `provision.sh`, `promote.sh`, and `restore-drill.sh` at `SERVERS_SSH_USER`. Add a step to the sitting checklist: commit his key, and cloud-init follows. Add a T2 test that provisions with the fake as `<his account>`.

## M1. A wrong hash locks Geoff out, and Stalwart's 24-hour auth ban widens it to the whole webmail (major, correctness)

Location: plan:129 (T3b main loop), plan:220-225 (after merge, step 1), plan:79 (the standing answer). Code: `roles/stalwart/plan.ndjson:6` (`authBanPeriod` 86400000), `roles/bulwark/compose.yaml:16`, `roles/stalwart/build-plan:32`.

Defect: the hash is computed on the workstation from `~/.local/secrets`. Per B1, that store doesn't necessarily hold the string Stalwart has today. Nothing checks the hash against the live credential before the apply replaces it; the upsert rewrites `credentials` on every run. If the two don't match, Geoff's clients and Bulwark start failing to sign in. Bulwark signs in to `https://ward.907.life` from orpheus's address, so its retries can get orpheus's IP banned for 24 hours, and the webmail fails for every household member. The standing answer, re-applying from the first parent, restores the credential but doesn't lift a ban. The WebDAV side has the same mismatch path, without the ban.

Fold:

1. Before any after-merge apply, run an on-host comparison as root on ward and orpheus, printing only `match` or `mismatch`. On ward, recompute the new `$6$` hash with its salt against the plaintext installed in `/etc/servers/stalwart.env`. On orpheus, check each new htpasswd line against the `RCLONE_PASS` installed for that member. A `mismatch` stops before `--apply`.
2. Switch the probe account to `secret_hash` in the same change, and apply and sign it in before Geoff's entry.
3. Add the Stalwart command that lists and lifts a ban to the standing answer.

## M2. An apply from any branch or stale checkout rolls the server secrets back to that branch's store (major, correctness)

Location: plan:101 (the store wins), plan:119 (`SERVERS_STORE` defaults to the main checkout), plan:171.

Defect: until now, every apply rendered from a single latest `~/.local/secrets`. After the change, `secrets_load` makes "the store" win, but the plan never says which file that is: the running repo's `secrets/servers.age` or `~/Projects/servers/secrets/servers.age`. If it's repo-relative, an apply from a worktree, an old branch, or an un-pulled checkout silently renders that snapshot's values. Say his laptop missed a rotation Geoff made: an old tunnel token, R2 key, or password goes back onto the host. Meanwhile the workstation renders from the main checkout, so the two readers can disagree.

Fold: name the path `secrets_load` reads, which should be the running repo's. `apply.sh --apply` (and `render.sh`) refuse unless `git rev-parse HEAD:secrets/servers.age` equals `origin/main:secrets/servers.age` after a fetch. The override is an explicit `SERVERS_STORE_BRANCH_OK=1`, which a pass sets for its own store edits. `--check` prints which store blob it would use.

## M3. Two operators writing the store can silently lose a rotation (major, correctness)

Location: plan:100 (`store.sh`), plan:157 (rotation on his machine), plan:87 (the #22 merge answer covers text appends only).

Defect: `servers.age` is one opaque binary in git with two independent writers, Geoff and him, on two machines. If both write from the same base, git reports a binary conflict, and the usual fix ("take mine") drops the other person's change without a word. The plan's name-drop check runs inside one write and can't see this. Within one machine, nothing serializes `store.sh` with itself or with `sync.sh`, which reads the store while holding `secret-store.lock`. Two concurrent `set` calls lose one update. If a write isn't a tmp-and-rename, a crash in the middle leaves a truncated file. A crash after the server apply but before the commit and push leaves a value that only the server holds.

Fold:

1. `store.sh` writes only on `main`, level with `origin/main` after a fetch.
2. It holds the shared `${XDG_RUNTIME_DIR}/secret-store.lock` around the read, modify, and write.
3. It writes `servers.age.tmp` and renames it into place.
4. Add a `secrets/servers.age binary` line to `.gitattributes`.
5. The rotation page orders the steps: `store.sh set`, then commit and push, then apply. It notes that git history keeps the old ciphertext.

## M4. A rotation of Geoff's plaintext doesn't update its hash, so the next apply reverts his password (major, correctness)

Location: plan:43, plan:126-129 (two derived copies: the plaintext in the workstation store, the hash in the servers store), plan:45 ("as Stalwart admin he can reset Geoff's password").

Defect: say Geoff rotates `STALWART_PASSWORD_GEOFF` or `WEBDAV_PASSWORD_GEOFF` with `secret-set`. The servers store keeps the old hash. The next apply then:

- sets the old password in Stalwart (`build-plan` upserts it on every run), and
- renders the new plaintext into `stalwart-geoff.env`.

His clients break, `mail-filters` and `stalwart-jmap` break, and M1's ban follows. The same reversion catches the second operator if he resets Geoff's password in Stalwart's admin UI: the next apply undoes it. That's true of every account, which the docs never say.

Fold: where both copies exist (Geoff's workstation), `render.sh` checks that each `*_HASH_GEOFF` or `WEBDAV_HTPASSWD_GEOFF` verifies against its plaintext. It recomputes in-process and fails with the name on a mismatch. `secret-set` on those two names prints the matching `store.sh set-hash` command. `docs/changes.md` says a password change goes through the store, never only through Stalwart's UI, or the next apply undoes it.

## M5. The htpasswd switch is proven only against text, and a mistake there leaves a share open to the internet (major, correctness)

Location: plan:128, plan:130 (`tests/webdav.test.sh` checks only the unit text and the env files), plan:221. Code: `roles/webdav/install.sh:71-76`, `scripts/dry-run.sh:549-563`.

Defect: there are three ways it can go wrong.

- rclone runs with no authentication when it gets neither `--htpasswd` nor `RCLONE_USER` and `RCLONE_PASS`. T3b removes the env pair, so a wrong `%d` or `LoadCredential` path, or a dropped flag, serves `/srv/webdav/<name>` to anyone through Caddy. Alternatively, the unit fails to start.
- `install.sh` starts a member when `NAME.env` exists, not when its `.htpasswd` exists. A render that skipped the `.htpasswd` file therefore starts a unit with a missing credential.
- The first real proof that `htpasswd -nBi` output works against the pinned rclone 1.75.2 is the production apply after the merge.

On his side, the `webdav-geoff` row goes OWED, because `NEEDS_webdav_geoff` gates the whole row, including the 401 half that needs no password. So his dry run never shows whether Geoff's share is closed.

Fold:

1. The container leg runs the pinned rclone with an htpasswd file that the real tool generated. It must answer 401 with no login and 200 with the password.
2. A unit test fails if `ExecStart` lacks `--htpasswd`.
3. `install.sh` starts a member only when both files exist.
4. `dry-run.sh` splits the no-login 401 probe out of each `webdav-*` row, so it runs without the password.

## M6. The two-factor step uses a call that doesn't exist, and nothing checks the other members first (major, correctness)

Location: plan:61 (pre-flight 2).

Defect: Cloudflare's documented update call is `PUT /accounts/{account_id}`, not `PATCH` (developers.cloudflare.com/tenant/how-to/manage-accounts, "Update account"). A `PATCH` returns 404 or 405, which the plan's "if 403" fallback doesn't cover. That pushes the executor to improvise a `PUT` with a partial body, which risks resetting other account settings. Enforcement also blocks the dashboard for any current member without two-factor until they enroll, and the plan doesn't list the members first. API tokens aren't affected. Cloudflare's 2FA documentation says support often won't bypass two-factor for a locked-out user. On the bus day he is the only Super Administrator, so losing his second factor would lock the household out of the account. The sitting checklist has no step for his backup codes.

Fold:

1. Pre-flight 2 runs `GET /accounts/{id}`, changes only `settings.enforce_twofactor`, sends the whole object back with `PUT`, then compares a second GET field by field with the first.
2. On a 403, 404, or 405, Geoff uses the dashboard.
3. Before any of this, `GET /accounts/{id}/members` records each member's two-factor state, by name and state only. A member without two-factor stops the step.
4. Sitting step 1 adds "save your Cloudflare and Hetzner backup codes"; where they go is the OWNER FORK at the end.

## M7. The key sync can lock out direct ssh with no preview and no atomic write (major, correctness)

Location: plan:48, plan:109, plan:220.

Defect: the after-merge step only confirms `authorized_keys` once the apply has already rewritten it. `--check` shows nothing about keys, so a key in `~geoff/.ssh/authorized_keys` that isn't in `base/keys/geoff/` is removed without warning. (The thinkpad key was added by hand on 2026-10-24.) The plan doesn't specify the write. An `install /dev/stdin` over a broken ssh pipe truncates the file in place. A wrong owner or mode on `~/.ssh` or the file makes sshd's StrictModes reject every key. The empty-set refusal covers only `geoff`; an `<his account>/` directory holding only a README, or a malformed line, empties his set. The browser terminal (certificate authentication) is the fallback, but it fails in the same Cloudflare outage #38 exists for.

Fold:

1. `--check` prints, per account, the key fingerprints it would add and remove.
2. The sync writes `authorized_keys.new` with the owner, `0600`, and a `0700` `~/.ssh`. It validates every line with `ssh-keygen -l -f`, checks the count, then renames.
3. The refusal applies to any managed account whose set would be empty or holds an invalid line.
4. Tests cover a truncated stream and a README-only directory.

---

## m1. Merging the workstation PR can drop a secret written to main during the pass (minor, correctness)

Location: plan:54, plan:120, plan:210-214.

Defect: `values.age` is checked against main only at entry. If another session runs `secret-set` on main during the pass, the PR's `values.age` is a binary conflict, and resolving it to the branch's copy drops the new name without a word. The before-merge check compares the host's names before and after, which misses a name the pass never saw.

Fold: the before-merge step checks that the branch's merge-base blob of `values.age` still equals `origin/main`'s. If it doesn't, redo the T3 deletions on main's current file in the worktree before merging.

## m2. Nothing checks that the ciphertext went to the right recipients (minor, correctness)

Location: plan:99-103.

Defect: the "decrypts and drops no name" check decrypts only with the writer's own identity. Several mistakes get past it: a `recipients.txt` edit that drops Geoff's workstation key, a stray line, or T4's throwaway recipient left in the worktree's store after a `rekey` that had no scratch path. Any of these writes a store one operator can't open, or one a shredded key could have opened. Nobody notices until that operator's next sync.

Fold: give `store.sh` `SERVERS_STORE` and `SERVERS_RECIPIENTS` overrides, and have T4 use them, never the worktree file. Every write checks that the header's `-> X25519` stanza count equals the number of `recipients.txt` lines. A gate test fails if `recipients.txt` lacks the workstation `RECIP` from `secret-set.sh:42`, or if the stanza count differs from the line count.

## m3. No gate stops a plaintext committed as the store (minor, correctness)

Location: plan:99.

Defect: no check stops a plaintext file committed under `secrets/servers.age`, or a stray `servers.age.tmp` or decrypted copy in `secrets/`.

Fold: a gate check fails unless `secrets/servers.age` begins with `age-encryption.org/v1`. It also fails on any untracked or tracked file in `secrets/` outside the expected set. `.gitignore` gets `secrets/*.tmp`.

## m4. A hard-failing loader breaks #22 and every fake-driven test without an identity (minor, correctness)

Location: plan:101, plan:87.

Defect: `secrets_load` now fails when the store or identity is missing. #22's `ward-book-check.sh` calls `secrets_load`, and so does every script the tests drive. CI holds no identity. The standing answer for #22 covers only the text appends.

Fold: under `SERVERS_TEST=1`, a `SECRETS_STORE` override, which may be empty, skips the store. Whichever of the two merges second runs the full suite after merging `origin/main`.

## m5. The htpasswd render needs a bare-value template, and bcrypt has a 72-byte limit (minor, correctness)

Location: plan:128.

Defect: `render.sh` writes `NAME=value` lines for every template except `.txt`, so an htpasswd template under any other name renders `WEBDAV_HTPASSWD_GEOFF=geoff:$2y$...`, which isn't an htpasswd line. bcrypt also ignores bytes past 72, and newer Go bcrypt refuses to generate a hash from longer input.

Fold: name the template `webdav-<name>-htpasswd.txt`, a bare `.txt` row, and test the rendered bytes. `set-hash --bcrypt` refuses input over 72 bytes.

## m6. The moved names keep stale copies that drift (minor, correctness)

Location: plan:46, plan:163.

Defect: after the split, three kinds of copy can drift from the store: the plaintexts of the two members kept "for their Proton Pass copies", the restore kit's restic password and R2 key, and `docs/runbook.md:309`'s instruction to decrypt `origin/main:secrets/values.age` for the restic password. That instruction now points at a store that no longer holds the name.

Fold: `docs/upkeep.md` gets a checklist line that compares each Proton Pass copy with the store, by hash and in-process. T5's re-pointing covers every `values.age` instruction for a moved name.

## m7. A stale-name write and the optional row can each fail in hard-to-see ways (minor, correctness)

Location: plan:81, plan:127.

Defect: the duplicate-name refusal fires inside the render, after `secret-set` has already renamed the new `values.age` into place. A habitual `secret-set` of a name that moved leaves every project's sync broken until someone deletes it. Separately, the optional `stalwart-geoff.env` row skips without a sound when the name is unset, which also covers up a typo on Geoff's own workstation.

Fold: `secret-set` refuses a name the servers store holds before it writes. The refusal names `store.sh set` as the right route. `render.sh` prints the skip line on stderr, and `--check` lists optional rows that would be skipped.

## m8. Host keys come from a client's cache, and the mint leg runs on every local edit (minor, optional, partly over-ceremony)

Location: plan:145, plan:111.

Defect: the fingerprints for the emergency screen come from pavilion's `known_hosts`, a trust-on-first-use cache, not from the hosts themselves. His machine has no `known_hosts` entry, so `BatchMode` fails on first contact. The ssh errors from T2 will show that, but the only fix offered is accepting the key blindly. Separately, the `mint` leg builds and runs a container on every `scripts/`, `secrets/`, `base/`, or `tests/` change in the local light lane. That's heavier than its job, which is catching a portability regression.

Fold: read `/etc/ssh/ssh_host_ed25519_key.pub` from each host over an authenticated session. Commit it as `hosts/HOST/ssh_host_ed25519.pub` and pass it as `UserKnownHostsFile`; a rebuild updates the file. Run the `mint` leg in CI and the full gate only, not in the light lane.

---

## OWNER FORK: where his Cloudflare and Hetzner two-factor recovery codes live

The ruling that he is the sole Super Administrator, with two-factor enforced, makes these codes the single point of failure on the bus day (M6).

Options:

1. His own Proton Pass vault, beside his age key.
2. `Household IT`, where Geoff and Claude can also read them.
3. Paper, with the recovery kit.

Recommendation: option 1, with a note on the accounts page that says where they are. It matches the 2026-10-25 ruling that keeps his age key out of the vaults Geoff and Claude can read. Losing his Proton account is already covered by Proton's own recovery.

## No finding

I checked the following and found no gap:

- The broad-token boundary: `dns.sh`, `access.sh`, `deploy.sh`, `archive.sh`, and `restore-drill.sh` all read `CF_WS_SERVERS_TOKEN`, so only `r2.sh` needs his own token, as the plan says.
- `<his account>`'s sudo: `operators.sh` already gives it, so `apply.sh` as `<his account>` passes `sudo -n true`.
- The env parsers in `stalwart-apply`, `stalwart-jmap`, and `mail-filters` read values as data, so a `$6$` hash survives them.
- The rollback route: after the merge, `~/.local/secrets` is the merged render and still holds every plaintext name, so a re-apply from the first parent can find its values. M1 and M4 still apply.
- The servers repo is private, so committing the ciphertext there adds no exposure.
