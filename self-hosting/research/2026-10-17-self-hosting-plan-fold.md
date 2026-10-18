# Self-hosting plan fold (2026-10-17)

Fold of the three lens reviews of `self-hosting/plans/2026-10-17-self-hosting-plan.md` at `7061df9`: mechanics (`...-plan-review-mechanics.md`), contract (`...-plan-review-contract.md`), and data (`...-plan-review-data.md`). Fold agent: `claude-opus-5-5`, under `superpowers:receiving-code-review` and `spec-plan-review` "The fold". Each finding was checked against the plan, the design at `27a154d`, and the workstation source before it was folded. Every `optional` finding is dropped. Convergent findings fold once, at the root named in their row.

Counts: 104 findings. 87 folded, 13 of them through another finding's root, 7 with a part refused, and 3 with the method changed; none refused in whole; 1 owner fork (mechanics M17) plus one owner-fork sub-part (contract B1, row 2); 16 dropped as optional. Round 2 (the verification read, below) turned data M7's rebuild-protection call into a third owner fork, so three rulings go to Geoff, under the plan's "Rulings needed". One candidate fork was taken in the plan instead, with the reason below. Round 3 adds the second verification read's 9 findings: 8 folded and 1 owner-fork evidence fold, none dropped.

## Findings

Locations name the revised plan's task ids and sections.

### Mechanics

| Id | Disposition | Where the revision carries it, or why |
|---|---|---|
| B1 | folded (root, with data M2) | F5's set-replacement semantics and `absent` rows; I1, C1 save the live set and commit the rollback declaration; L4 rehearses switch and rollback on a scratch name |
| B2 | folded | 0.0 creates, clones, and seeds the servers repo; F1 lays the tree in a worktree |
| M1 | folded | F5 declares nothing in Pass 1; `--check` lists the zone through the API |
| M2 | folded (root, with contract m2) | M6 acceptance: `r2.sh --check` first, named canary under `data/zz/`, `config` overwritten with its own bytes, dummy under `locks/`, 409 code; L7 "as M6 does"; superseded by round 2, B1: the lock moved to I1 and C1 |
| M3 | folded | 0.10 allow rules (`access.sh`, `provision.sh snapshot`, `deploy.sh` carrying the `d1` and `secret put` steps, musicbox SSH), relative form; F1 `dontAsk` stub probes; standing answer for a classifier denial |
| M4 | folded (root, with contract M5) | 0.5 token list adds Single Redirect Edit and the Access and Tunnel token; 0.12 probe Worker, redirect write and delete, tunnel create and delete |
| M5 | folded | M2 drops the CA lines; M4's `access.sh` creates the per-application CA and the cloudflared role installs `ca.pub`; account from the 0.8 email, renamed after the Access log check |
| M6 | folded (root, with contract M4); part refused | Standing answer "The port 25 answer" (daily JMAP query, 14-day options packet). Refused: the `nc` test from media, because whether Hetzner's unblock reaches a running server is unsourced and the JMAP check answers the defect |
| M7 | folded (root, with contract M7) | 0.12 `scripts/dry-run.sh`; standing answer on arrival; Pass 5 entry and L1 |
| M8 | folded | 0.4: no `hcloud context`, token through the environment |
| M9 | folded (root, with contract M6 and data M9) | "Privacy" and 0.0: `privacy-check.sh` fails on missing, empty, or blank-line patterns, calls `/usr/bin/grep`, exit 1 only is clean; close checklist extends the patterns |
| M10 | folded | Pass 6 entry adds Proton sign-in |
| M11 | folded; part refused | Header "STATUS": the conductor is the only writer, executors hand lines over in their PR body. Refused: per-pass initiatives worktrees, since one writer removes the race |
| M12 | folded | F1 container leg: cached image with Docker's repository and the role packages, `ssh-keygen -A`, dummy `.env`, binaries installed or stubbed; the podman row in "Not checked" closes on the review's probe |
| M13 | folded (with data M7's class part) | Path map: `infra/**`, `cloudflare/{dns,access}.sh`, `heartbeat.ts` named; M1 and L2 now `auth-data`; Pass 7's merge path in the header; W5 and W6 `live-account` |
| M14 | folded | F3: flags in repo config deployed by `deploy.sh`, heartbeat writes only its row, the added test cases |
| M15 | folded (root, with contract M2 and data minor 1) | L6 scope excludes Restore, the probe half of Receiving, and Backup growth; L7 runs the drill and probe; L8 reads Backup growth after the rehearsal week |
| M16 | folded | W0 builds the shared fake first; the `op` check moves to W3 with the review's regex; `secret-receive --op` removed in P4 |
| M17 | owner fork | Ruling 2 (line 3,490, ceiling 5,235, overrun answer) |
| M18 | folded | F3 reads upload time (the Worker can't decrypt a snapshot); M6 creates `servers-scratch-stale` two days ahead; M8 uses `deploy.sh`'s override binding |
| M19 | folded | F1 builds the Worker leg as a loop and stubs `deploy.sh`; M2's gate check lands in the main loop after the pair |
| M20 | folded | L2: Spamhaus over DNS through DQS (RFC 5782 form), MXToolbox and multirbl pages as a cross-check; a "Not checked" row for the pages |
| M21 | folded (root, with contract M1) | W6 enters after F2 merges |
| M22 | folded | F3 generates topics and heartbeat tokens; M4 the tunnel token; M6 and L3 the restic passwords, each through M6's storage order |
| M23 | folded (root, with contract B2) | L3 `roles/health` for mail, with fixture tests and the Junk probe acceptance |
| m1 | folded | "Path": task sum 3,955 plus nine hand-overs, 4,315; hand-overs named and their basis given |
| m2 | folded; part refused | 0.3: `brew pin`, `check-drift` clean after 0.10. Refused: switching to homebrew/core's formula (probed: `proton-pass-cli 2.4.2`), since the design names Proton's tap and both pin the same way |
| m3 | folded | 0.5: REST bucket list, S3 pair stored; the verify-endpoint check gives way to 0.12's allowed and refused operations |
| m4 | dropped (optional) | 0.5's rewrite no longer carries the sentence or its "Not checked" row, since the buckets come first either way |
| m5 | folded through B2 | 0.7 commits the list in the servers repo, which exists from 0.0 |
| m6 | folded | 0.10 names the guards (deny rules and the lock, no hook script), quotes the drop list, proves rules in `dontAsk` |
| m7 | folded (root, with contract M3) | 0.6 Emergency Access invite; "Human steps" rows for sharing `Servers emergency` and the age key into `Workstation` before W5 |
| m8 | folded | F2 test with the age step stubbed; `test/roundtrip-<date>.age`; `rclone` named |
| m9 | folded | F6: `systemd-run --user --on-active=13h` |
| m10 | dropped (optional) | |
| m11 | dropped (optional) | |
| m12 | folded | I4: `restic check --read-data --no-lock` on the first post-cutover snapshot, timed in the packet |
| m13 | folded | C2 both hosts; C4 daily sweep timer; C5 and D3 the two-part DMARC gate; C1 repeats the Trash and Junk empty |
| m14 | folded | D2 records the Flatpak in `flatpaks.txt` (probed: `co.hyprlab.Hylki 1.44.0` installed, absent from the file); D6 at 60 |
| m15 | dropped (optional) | |
| m16 | folded (root, with contract M13) | Each task carries files, class, test where it has one, acceptance, minutes |
| m17 | folded | "Repos and sessions": other worktrees first, `--add-dir`; Pass 1 puts F6 and F8 in one workstation PR |
| m18 | folded | M4 declares `media.907.life`; 0.9 handles a missing Zero Trust organization |
| m19 | folded | "Repos and sessions": the conductor owns Pass W's PR; one `dns.sh` file per name group |
| m20 | dropped (optional) | F1 and M7 rose anyway, for scope the fold added |
| m21 | folded (root, with contract m10) | M6 files dubplate's request through `log-issue` |

### Contract

| Id | Disposition | Where the revision carries it, or why |
|---|---|---|
| B1 | folded, except row 2 an owner fork | Row 2: ruling 1, plan written to (a) in C3. Row 4: C5 `tls-reports@` count. Row 6: C5 alias test. Row 8: M4 acceptance. Row 11: F6b and C2. Row 12: P4 acceptance rows. Row 13: W5 |
| B2 | folded through mechanics M23 | L3 |
| M1 | folded | W6, with its own acceptance, off the path |
| M2 | folded through mechanics M15 | L6, L7, L8 |
| M3 | folded | One "Human steps" table, reconciled against "What Geoff does" line by line. One table, not one per pass, because the conductor chases rows across passes |
| M4 | folded through mechanics M6 | Standing answer |
| M5 | folded through mechanics M4 | 0.12 allowed and refused operation per token |
| M6 | folded through mechanics M9 | 0.0 |
| M7 | folded through mechanics M7 | 0.12, L1 |
| M8 | folded | C5 and D3 acceptance; C5 policy read-back with only `mail.907.life` |
| M9 | folded; method changed | F1 proves each allow rule against stubs in a `dontAsk` session instead of reading transcripts after first live use, since that mode denies "anything that would prompt" |
| M10 | folded | M7 acceptance: rendered secret names, outbound 25 and 443 refused, recovered snapshot matches |
| M11 | folded (with data M7) | M1 test |
| M12 | folded | D1 counts the three accounts; C5 carries enabled masks at zero and the second operator's confirmation |
| M13 | folded | Every task's fields; acceptances for L8, W4, D1, D4, D5, D6, P1 |
| m1 | folded | F8 acceptance names each periodic item |
| m2 | folded through mechanics M2 | M6 |
| m3 | folded | M8: notification on pavilion at normal urgency |
| m4 | folded | M6 and L3 fixtures |
| m5 | folded | 0.4 SSH key create and delete |
| m6 | folded | P1 Vale; member confirmations as P4 rows |
| m7 | folded | L6 closes the three unchecked items |
| m8 | folded through mechanics B2 | 0.7 |
| m9 | folded through mechanics B2 | 0.0 creates `secrets/registry.md` |
| m10 | dropped (optional) | Mechanics m21 carries the same item as a correctness minor |
| m11 | dropped (optional) | Mechanics m1 names the hand-overs |
| m12 | dropped (optional) | Mechanics M17 carries it |
| m13 | folded | C4 forward proof stops the sweep |
| o1 | dropped (optional) | |
| o2 | dropped (optional) | |
| o3 | dropped (optional) | |

### Data

| Id | Disposition | Where the revision carries it, or why |
|---|---|---|
| B1 | folded; part refused | 0.10 `flock` and the survivor check (every old name must survive, which covers an update as well as an add); M6's storage order, used by M4, L3, and L7. Refused: requiring the commit on `origin/main` before the lock, because `secrets/**` is `auth-data` in `dotfiles-pass`, so its merge is Geoff's and would stall the pass; a pushed branch gives the off-machine copy, as workstation PR #81 did; superseded by round 2, B1: the lock moved to I1 and C1, and the refusal was reversed |
| M1 | folded; part refused | 0.10 deny rules; F2 `lock add` only, gate fails on `lock remove`, `lock set`, `bucket delete`, `--check` after every apply. Refused: wrapper tests and `curl` deny patterns, because a deny rule "doesn't match the same program invoked in a different form" and "isn't a security boundary around the program" (permissions docs), so those tests fail by design, and a `curl` PUT pattern would also catch routine R2 object writes. The runbook lift procedure is already Geoff's by the design |
| M2 | folded through mechanics B1 | F5, I1, C1; L4 adds the scratch-name rehearsal and the TTL check |
| M3 | folded | C1 count and flag rows before the switch; L5 idempotence probe |
| M4 | folded | L6 header token and Message-ID list; L8 deletes by exact id with counts; class `auth-data` |
| M5 | folded | I1 statistics and newest asset ids before the switch; the rollback list; re-upload with the Immich CLI; no wipe while the list holds |
| M6 | folded | M5 `scripts/pod-pull.sh`, `rclone copy` only, test-first |
| M7 | folded; owner fork (round 2) | Path map; M1's checks; L3's `--keep-stopped`. Round 1 took the rebuild-protection question as no fork, on the premise that protection could stay off; the verification read showed Hetzner couples rebuild to delete protection, so it is ruling 3 |
| M8 | folded; part refused | Adapter "Test harness" and `SERVERS_TEST=1` refusal. Refused: unsetting tokens in the setup command, because shell state doesn't persist between Bash calls (the Bash tool's contract); and refusing `--apply` inside `.claude/worktrees/`, because the main-loop executor works in one and every live step would refuse |
| M9 | folded through mechanics M9; part refused | Each task adds its private values to the patterns file; the check covers commit messages and PR bodies. Refused: holding the file in the age store (the private repo carries it to both hosts with no new store) and a line-count floor (no measured defect past the missing, empty, and blank cases the check covers) |
| M10 | folded; method changed | 0.11: Geoff types the paper key into `age-keygen -y`, which prints only the public recipient. `secret-receive` always pipes into the age store (its header: "the value is piped straight into secret-set.sh --stdin"), so it can't hold the key in tmpfs alone |
| M11 | folded; method changed | W1: `ws-pass-key` reads `op` only where the keyring holds no agent token, a check of real state rather than a marker file; `check-drift` shows the path; standing answer on token expiry. This keeps `claude-block-op` until P4, since `op` stays callable |
| M12 | folded | M4's prefix check and the `userdel` guard |
| minor 1 | folded through mechanics M15 | L7 runs the drill before the lock; superseded by round 2, B1: the lock moved to I1 and C1 |
| minor 2 | folded | F2 drops the scratch-bucket probe |
| minor 3 | folded | F2 timestamped keys and the 409 test; L5 keeps local archives until C1 |
| minor 4 | folded | M8 and L7 hash check through W3's hash mode; the staged file removed by a trap |
| minor 5 | folded | I2 compares versions |
| minor 6 | folded | I1 reads statistics right before the stop |
| minor 7 | folded | C4 `scripts/imap-sweep.sh` |
| minor 8 | folded | L5 role, name, and count match |
| minor 9 | folded | L5 resolves targets from the login address |
| minor 10 | dropped (optional) | |
| minor 11 | dropped (optional) | |
| minor 12 | dropped (optional) | W3 keeps `claude-block-op` for data M11's reason, not this one |
| minor 13 | dropped (optional) | |
| minor 14 | dropped (optional) | |

## Owner forks

1. Contract B1 row 2, how the members' mailboxes get the send and receive test: ruling 1.
2. Mechanics M17, the estimate line and ceiling with the overrun answer: ruling 2.
3. Data M7 with verification M1, production rebuilds under coupled protection: ruling 3.

Taken in the plan, not asked:

- **The conductor launching each pass** (the plan's proposed standing answer): `pass-core` "Conductor" says the conductor "launches the next committed prompt from the main checkout after the 'Execute' pre-launch checks", so the process already sets it.

## Probes and quotes

Probes ran in `/tmp/claude-1000/-var-home-glw907--dotfiles/26c03024-495f-48eb-8c85-7a70bf66decd/scratchpad/fold-probes`. No live account was called.

| Mechanism | Evidence |
|---|---|
| GNU grep pattern-file edge cases | Probe, grep 3.12: a missing file exits 2, an empty file exits 1 and matches nothing, a blank line exits 0 and matches every line |
| `flock` | Probe, util-linux 2.42.4: a second `flock -n` on a held lock exits 1 |
| `secret-set.sh` race and no commit | Source read: `grep -v "^${NAME}=" "$DEC" > "$NEW"`, the check `grep -q "^${NAME}="` on the new store alone, `mv "$VALUES.tmp" "$VALUES"`; no `git` call. Workstation PR #81 (`immich-pikapods-key`) committed `values.age` and `registry.md` on a branch |
| Tokens in Claude's Bash | Probe: `HCLOUD_TOKEN`, `CLOUDFLARE_API_TOKEN`, and Fastmail variables are set (names only read) |
| `systemd-run --user --on-active` | Probe: `--on-active=SECONDS  Run after SECONDS delay` |
| `restic backup --time` | Probe, restic 0.19.1: the flag exists; not used, since F3 reads upload time |
| `age-keygen -y` | Probe: an identity on stdin prints its `age1...` recipient, equal to the generated public key |
| `brew pin`, `proton-pass-cli` | Probe: `brew pin` usage prints; homebrew/core has `proton-pass-cli 2.4.2` |
| Hylki | Probe: `co.hyprlab.Hylki 1.44.0` installed; not in `bluefin/flatpaks.txt` |
| `op` call sites | Probe: `\bop\b` matches 21 lines; the review's regex matches `sync.sh:161`, `secret-set.sh:71`, `claude-sudo-setup:15`, and `secret-receive:12,44` |
| `secret-receive` | Source header: "the value is piped straight into secret-set.sh --stdin" |
| `claude --permission-mode dontAsk` | `claude --help` lists `dontAsk`; permission-modes docs: "anything that would prompt is denied" |
| Rule order, assignments, forms | Permissions docs: "Rules are evaluated in order: deny, then ask, then allow"; "An allow rule won't match past an assignment of any other variable"; a rule "doesn't match the same program invoked in a different form, so a deny or ask rule ... isn't a security boundary around the program" |
| Auto mode and allow rules | Permission-modes docs: the drop list (blanket `Bash(*)`, wildcarded interpreters, package-manager run commands, `Agent`, `Monitor`), then "Narrow rules like `Bash(npm test)` stay in effect" |
| Single Redirect permission | Cloudflare redirect API docs: "_Zone_ > _Single Redirect_ > _Edit_" |
| Access and Tunnel permissions | Cloudflare permissions reference: "Access: Apps and Policies Edit", "Cloudflare Tunnel Edit", "Access: Audit Logs Read" |
| Per-application SSH CA | Cloudflare short-lived certificates (legacy): "In the Application dropdown, choose the Access application ... Copy its CA public key"; API reference: `POST /{accounts_or_zones}/{account_or_zone_id}/access/apps/{app_id}/ca`, requiring "Access: Apps and Policies Write" |
| R2 S3 credentials | Cloudflare R2 tokens: "Access Key ID: The `id` of the API token. Secret Access Key: The SHA-256 hash of the API token `value`." |
| JMAP query filters | RFC 8621 4.4.1: `from` "Looks for the text in the From header field of the message"; `after`: "The receivedAt date-time of the Email must be the same or after this date-time" |
| DNSBL queries | RFC 5782 2.1: the name is formed by "reversing the order of the octets"; section 6: a client "MUST interpret any returned A record as meaning that an address or domain is listed" |
| `rclone copy` | rclone docs: "Doesn't delete files from the destination" |
| imapsync delete flags | imapsync README: `--delete1` "Deletes messages on host1 server after a successful transfer"; `--delete2` "Delete messages in the host2 account that are not in the host1 account"; `--expunge1` "Expunge messages on host1 just before syncing a folder" |
| Immich CLI | Immich docs: login "using an API key", then `immich upload` |
| Custom domain owns its record | Mechanics review's quote of Cloudflare: "After you have added the domain or subdomain, Cloudflare will create a new DNS record for you" |
| `hcloud context` writes the token | Mechanics review's read of `internal/cmd/context/create.go` (`config.NewContext(name, token)`, `cfg.Write`) |
| Rootless `podman` with `debian:13`, the `sshd -t` and `systemd-analyze` failures, a canary in `data/` | Mechanics review's probes, taken as recorded there |

## Owed design errata

The design is not edited. Each item is a place where the revised plan changes the design's meaning, for the next design revision to carry.

1. **"DNS"**: `dns.sh` "reports any record it doesn't declare ... without ever deleting one." The plan gives each declared name and type its whole record set, so `--apply` deletes within a declared set (Fastmail's MX at cutover, photos' CNAME) and at `absent` rows, and still never touches an undeclared name or type. The design's own MX switch and photos switch need this.
2. **"What Geoff does", Pass 0 step 4**: the token list gains Single Redirect Edit on the DNS token and an Access and Tunnel token (Apps and Policies Write, Tunnel Edit, Audit Logs Read).
3. **"What Geoff does", Pass 0 closing paragraph, and "End-to-end check"**: the dry run makes one allowed and one refused operation per token, some of them reversible writes (a test object, a probe Worker, a redirect rule, a tunnel), not "one read-only call".
4. **"Workstation wiring" and "Migration order" step 4**: `ws-pass-key` reads `op` on a host whose keyring holds no agent token, and `claude-block-op` stays beside `claude-block-pass`, both until the 1Password uninstall in step 10.
5. **"Claude's operating authority"**: the pre-rebuild backup runs with the service kept stopped (the mail unit's `--keep-stopped` mode), and `provision.sh` checks that the backup and snapshot postdate the stop; the standard mail unit restarts Stalwart at its step 4, which would let mail arrive between the backup and the wipe.
6. **"Access"**: the CA lines and `ca.pub` land with the cloudflared role through `apply.sh`, not through cloud-init, because each Access application has its own CA, which exists only after the application does.
7. **"Claude's operating authority" and "Rulings" (Claude's authority on Hetzner)**, pending ruling 3: under the recommended answer, Claude rebuilds a production server only after Geoff turns its protection off, because Hetzner couples rebuild protection to delete protection. Unlike items 1 to 6, this touches a ruling. Geoff took the recommended answer on 2026-10-17.
8. **"Order of work" items 2 and 5**: media's lock rules move from the media pass to the first step of the Immich cutover (I1), and mail's from the mail pass to the first step of the mail cutover (C1), each once the restic password is on `origin/main`. The timing still meets "Lock rules" ("after `restic init` and the first verified backup on media, and after the last rehearsal import on mail, before cutover").
9. **"Claude's operating authority"**: the design's "guard hooks" are deny rules plus the secret-store lock; 0.10 adds no hook script.
10. **"Migration order" step 10**: 1Password's uninstall moves from "once step 5 has passed on both" to P4's PR, because `ws-pass-key`'s `op` branch (item 4) needs it until then.
11. **Rehearsal table, "Image restore" row, and the runbook's broken-mail-server path**, pending ruling 3: restoring a backup image in place is a Hetzner rebuild, so under the recommended answer each needs protection turned off first and back on after, by Geoff in L6 and, on the second operator's emergency screen, by the second operator himself. Geoff ruled so on 2026-10-17.

## Round 2: the verification read

Fold of `self-hosting/research/2026-10-17-self-hosting-plan-fold-verification.md` (1 blocker, 2 majors, 16 minors), read against the plan at `e43cdb5`. Each finding was checked before folding. All 19 are `correctness` and all fold; none is left owed.

| Id | Disposition | Where the revision carries it, or why |
|---|---|---|
| B1 | folded; parts refused | New section "Secrets in the age store": every secret goes into the pass's own workstation worktree (`VALUES` pointed there, which the script's header documents), is committed after each store, and rides in a draft PR from the first push, so the main checkout's `values.age` never changes and `git pull --ff-only` keeps working. 0.10's PR carries every Pass 0 credential; Pass 1's workstation PR carries F3's names. Media's lock moves to I1's first step and mail's to C1's, each gated on the password's commit being on `origin/main`; the design citation checks out (design "Lock rules": "after `restic init` and the first verified backup on media, and after the last rehearsal import on mail, before cutover"), and "Order of work" items 2 and 5 become erratum 8. A `values.age` conflict is resolved by a merge of `origin/main` and re-storing the branch's names, never a rebase or a side pick; no force-push. W5's round trip uses scratch `VALUES` and `LOCAL_SECRETS`. The lock file moves to `$XDG_RUNTIME_DIR`. Refused: `secret-pull.sh`, because no published source or team runs it and the measured defect it answers (a pull blocked by a dirty `values.age`) can't arise once nothing writes the main checkout's store. Refused: relying on `refs/pull/<n>/head` as a backstop, which the verifier left unprobed; the no-force-push rule and the draft PR carry the copy |
| M1 | owner fork | Ruling 3, recommended (a). Quote, Hetzner's own API spec (`https://docs.hetzner.cloud/cloud.spec.json`, `/servers/{id}/actions/change_protection`): "If true, prevents the Server from being deleted (currently delete and rebuild attribute needs to have the same value)" and "If true, prevents the Server from being rebuilt (currently delete and rebuild attribute needs to have the same value)". Weighed against the design: (a) narrows the rebuild grant in "Rulings" to rebuilding after Geoff's flip, while (b) keeps the grant but breaks the "Claude's operating authority" rule that no script disables protection. Both are design-level, so Geoff rules; (a) is recommended because no production rebuild is planned and a packet is cheap. The plan is written to (a): standing answer, M1, and its fake `hcloud` modelling the coupling |
| M2 | folded | Pass 1's workstation PR carries F3's names (the producer); F6b's entry is that PR merged plus Geoff at thinkpad-x1, with a `--ff-only` pull and `sync.sh --local`; new F6c (5 min, attended) clones the servers repo there |
| m1 | folded | D4 `absent` rows for `fm1` to `fm3` |
| m2 | folded | 0.10 SSH proof targets `geoff@mail.907.life`, which doesn't resolve until L4 |
| m3 | folded | 0.10 deny rule `hcloud * rebuild` |
| m4 | folded | "Path" states the sequence as a conservative bound; ruling 2 sums only the passes on the path |
| m5 | folded | Ruling 2's basis, from merged PR Score sections: dubplate #6 (intake-1, about 9.5 hours against a 725-minute path), dubplate #4 (admin-api-1, about 475 against 695), approval-queue #2 and workstation #78 (about 105 against 540), workstation #75 (about 20 against 35) |
| m6 | folded | "Secrets in the age store": the workstation registry holds every name, the servers registry the reader |
| m7 | folded | Pass 2 and Pass 5 headers create the workstation worktree and launch with `--add-dir` |
| m8 | folded | M4 renders F3's heartbeat token and generates only the tunnel token |
| m9 | folded | 0.10's survivor check exempts the `--delete` name, with a test |
| m10 | folded | 0.12's refused DNS write is a TXT at a fixed scratch name |
| m11 | folded | M8 names its three waits; Pass 2's path note |
| m12 | folded | Errata 9 and 10 |
| m13 | folded | L2 checks the IPv4 only, since Stalwart sends over IPv4 only |
| m14 | folded | Ruling 1 carries both facts; C3 deletes its messages by Message-ID and routes a changed password to the household path |
| m15 | folded | M8 names the route: an R2 REST `DELETE` in the main loop on a `servers-scratch-` name, or the monthly review on a denial |
| m16 | folded | Data M7's row and "Owner forks" updated |

Probes and quotes for round 2:

| Mechanism | Evidence |
|---|---|
| Hetzner protection coupling | Hetzner's OpenAPI spec, fetched to the scratchpad: the two `change_protection` field descriptions quoted above |
| `secret-set.sh` path overrides | Source, lines 33 to 37: "Each path can be overridden from the environment, so a test or a worktree edit can point the script at a scratch store without touching the live one", then `VALUES`, `LOCAL_SECRETS`, `CACHE` defaults |
| Recent actual-against-planned paths | `gh pr list --state merged` and `gh pr view` Score sections on glw907/approval-queue, glw907/dubplate, glw907/workstation, glw907/cairn-cms, as cited in ruling 2 |
| Pull, conflict, and PR #81 timing | The verification read's probes, taken as recorded there |

Path after round 2: unchanged at **3,490**. M6 (-15) and L7 (-15) hand their lock steps to I1 (+15) and C1 (+15). F6c adds 5 minutes off the path, so the task sum is 3,960 and the total with hand-overs 4,320.

## Round 3: the second verification read

Fold of `self-hosting/research/2026-10-17-self-hosting-plan-fold-verification-2.md` (2 majors, 7 minors, 5 of the minors `correctness`), read against the plan at `af54e36`. Each finding was checked against the workstation scripts at `2739239` and Hetzner's sources before folding. This is the last round, so no verification read follows.

| Id | Disposition | Where the revision carries it, or why |
|---|---|---|
| N1 | folded, method changed | Checked: `secret-set.sh` honors `VALUES` and `LOCAL_SECRETS` from the environment (its lines 33 to 37) and rewrites the whole plaintext file from the store it read (`write_local`); `sync.sh` hardcodes both paths to its own checkout and `$HOME/.local/secrets` (lines 25 to 27); `secret-receive` hardcodes `$HOME/.local/secrets` for its post-store check (line 19). So every branch store rewrites `~/.local/secrets` and the last writer wins. The fold takes the verifier's overlay with the smallest script change: 0.10 adds `--values` and `--local` flags over the existing overrides, and `secret-receive` passes both through and checks the `--local` path, with a test. Each pass stores into its worktree and an overlay at `$XDG_RUNTIME_DIR/self-hosting/secrets-<pass>`, so `~/.local/secrets` is written only from `main` and never loses a live name. The servers loader `scripts/lib/secrets.sh` (0.12, tested) sources the overlays and then `~/.local/secrets`, so `main` wins a repeated name. The "If another session regenerates it" sentence is gone. `sync.sh` and W5's compare stay as written |
| N2 | owner-fork evidence folded | Quote, Hetzner `cloud.spec.json`, `/servers/{id}/actions/rebuild`: "Rebuilds a Server overwriting its disk with the content of an Image ... The Image can either be one you have created earlier (`backup` or `snapshot` Image) or it can be a completely fresh `system` Image provided by us"; the spec's paths have no restore action (only `enable_backup` and `disable_backup`). Ruling 3 now names L6's in-place image restore (certain) and the runbook's broken-mail screen as the known production rebuilds, drops "no production rebuild is planned", and carries the second operator's question as its second part, recommended yes. Quote, Hetzner Cloud FAQ (`docs.hetzner.com/cloud/general/faq/`), role table: Member "Can create, modify and delete all resources in the project, such as Floating IPs, Volumes, servers, images, etc., except for creating and deleting DNS zones", and Restricted is barred from, among others, "Creating or deleting servers" and "Creating Snapshots". The table doesn't name protection, so the ruling says so. Under (a): a "Human steps" row where Geoff turns protection off, runs the console restore, and turns it on; L6's acceptance reads protection on again; F7's mail screen carries the protection steps; D5 has him find the setting without changing it. Erratum 11 |
| n1 | folded | The lock gate checks content: decrypt `origin/main:secrets/values.age` and compare the password's hash, since the workstation repo allows squash and rebase merges and the ancestry check gives a false negative after a squash |
| n2 | folded | 0.10 adds the two flags and one narrow allow rule for the main checkout's `secret-set.sh` and `secret-receive` with `--values` under the self-hosting worktrees and `--local` under the runtime directory, proven by a `--dry-run` in the same `dontAsk` session. Quote: the plan's own permissions quote, an allow rule "won't match past an assignment of any other variable" |
| n3 | folded | "The main checkout's store stays clean": `git -C ~/.dotfiles diff --quiet -- secrets/values.age` in the conductor's pre-launch checks and in the close checklist |
| n4 | folded | The closing session test-merges `origin/main` before the packet, decrypts the branch store to `/dev/shm` under a trap (checked: `secret-set.sh` shreds its copy on exit), and re-stores the branch's names |
| n5 | folded | F3: the topic names and heartbeat tokens are generated in the main loop into Pass 1's worktree and overlay |
| n6 | folded | M1: a trap re-enables both flags on every exit path after Geoff's flip; the fake `hcloud` fails a rebuild and protection ends on |
| n7 | folded (costs nothing) | The three round-1 rows carry "superseded by round 2, B1"; F6c follows F6b |

Path after round 3: **3,515** (Pass 0 435: 0.10 +15 for the flags, their test, and the allow rule; 0.12 +10 for the loader and its test). Task sum 3,985; with hand-overs 4,345. Ruling 2's ceiling at 1.5 times is 5,273. Owed design errata: 11.
