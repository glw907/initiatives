# Mechanics and feasibility review: the self-hosting pass plan

Reviewer: `plan-reviewer` (claude-opus-5-5, medium), 2026-10-17. Target: `self-hosting/plans/2026-10-17-self-hosting-plan.md` at `7061df9` (cited `plan:N`); design at `27a154d` (cited `design:N`). Probes ran in the session scratchpad: grep pattern-file edge cases, restic with a canary object, rootless `podman` with `debian:13`. The `hcloud` source and docs from Claude Code, ntfy, Cloudflare R2, Workers custom domains, Single Redirects, and short-lived certificates were read and quoted.

Verdict: not passing; 2 blockers and 23 majors. Arithmetic: every pass path figure adds up and the 2,950 path is correct; the 3,360 sum is wrong (m1).

## Blockers

**B1 (correctness). `dns.sh` can never delete a record, so three planned moves can't happen.** `plan:144`, `plan:170`, `plan:207`, `plan:210`, `plan:221`; `design:282`, `design:287`, `design:340`, `design:368`. F5 makes `dns.sh` write only declared records and never delete. C1 must replace Fastmail's MX with one `10 mail.907.life`, "never mixed with Fastmail's", which deletes Fastmail's MX; the rollback deletes in reverse. I1 changes `photos.907.life` from a proxied CNAME to A/AAAA, and a CNAME can't coexist with other records, so the CNAME must be deleted; I1's rollback deletes the A/AAAA. D4 removes the `fm*` CNAMEs. Fold: add an `absent` row kind (`--apply` removes, `--check` confirms gone) and a `replaces` row (takes over an existing record by name and type, so SPF updates in place). Test-first against a fake API. I1, C1, and D4 declare their removals; rollback is the reversed declaration.

**B2 (correctness). Pass 1 is launched from a repo Pass 1 creates.** `plan:39`, `plan:118`, `plan:140`; `pass-core` "Execute". When Pass 0 closes there is no servers checkout to launch from, no `HEAD`, nowhere to commit the conductor prompt. Fold: in Pass 0 (with 0.4), `gh repo create glw907/servers --private`, clone to `/var/home/glw907/Projects/servers`, push one README commit, add `.claude/worktrees/` to `info/exclude`. F1 lays down the tree in a worktree.

## Majors

**M1. F5 declares the `mta-sts` record F4's custom domain owns.** `plan:143-144`. Cloudflare: "After you have added the domain or subdomain, Cloudflare will create a new DNS record for you"; "You cannot create a Custom Domain on a hostname with an existing CNAME DNS record". Public resolvers can't list a zone, so undeclared records come only from the API. Fold: F5 declares nothing in Pass 1; `--check` lists the zone through the API and reads declared values from public resolvers.

**M2. The lock checks in M6 and L7 test against the live production repository.** `plan:160`, `plan:198`; `design:781`. A wrong-prefix rule would let the test delete a real pack or overwrite `config`. Probe: a canary under `data/zz/canary-<date>` leaves `restic check` clean (restic 0.19.1, local). Probe: `locks/` is empty after every run, so the delete test needs a fixture. Fold: `r2.sh --check` first; delete test on an uploaded canary in `data/`; overwrite test writes `config`'s own bytes back; upload a dummy under `locks/` first; name each fixture.

**M3. Unattended steps run commands no allow rule covers.** `plan:108`, `plan:142`, `plan:158`, `plan:171`, `plan:172`, `plan:194`. Docs: "An allow rule won't match past an assignment of any other variable"; a rule "doesn't match the same program invoked in a different form". Uncovered: Access app, SSH CA, and tunnel creation (M4, L3); `wrangler d1 create` and `wrangler secret put` (F3); `hcloud server create-image` (I2); SSH to musicbox (I3). No standing answer for a classifier denial. Fold: `cloudflare/access.sh --check|--apply` (auth-data) with an allow rule; D1 and secret steps inside `deploy.sh`; rules for `infra/provision.sh snapshot <host>` and musicbox; spell each rule exactly and require relative invocation from the worktree root; add the classifier-denial standing answer (record, notify, continue).

**M4. Pass 0's token set misses permissions later passes need.** `plan:88`, `plan:116`, `plan:195`. Redirect rules need "Zone > Single Redirect > Edit"; no token covers Tunnel or Access; the Workers token isn't shown to cover a custom domain, an R2 binding, `send_email`, or cron (unquoted). A read-only dry run can't catch it. Fold: add redirect edit to the DNS token; name a Tunnel and Access token; in 0.12 deploy a throwaway `servers-probe` Worker with the real bindings and a custom domain, then delete it; write and delete one test redirect rule.

**M5. M2 configures the SSH CA before M4 creates it.** `plan:156` vs `plan:158`. The short-lived-certificate CA is generated per Access application; config is `TrustedUserCAKeys /etc/ssh/ca.pub` "above all other directives". Each server's CA differs. M4 also reads the GitHub email only after a sign-in that's deferred. Fold: `apply.sh` (cloudflared role) installs `ca.pub` fetched from the Access API; cloud-init carries only the drop-in. Create the account from the email given in Pass 0, read the Access authentication log at first sign-in, rename if it differs.

**M6. The port 25 entry and its 14-day clock have no owner.** `plan:50`, `plan:72`, `plan:190`. Hetzner answers by email or console, no API. Pass 5 is checked after Pass 3, past day 14. Fold: the conductor searches Geoff's mailbox read-only over JMAP on each tick; once media exists, test with `nc -vz -w5 <gmail MX> 25`; arm a check at filing plus 14 days that sends the options packet whatever is running.

**M7. Credentials arriving after Pass 0 are never dry-run.** `plan:100`, `plan:116`, `plan:190`. Fold: make 0.12 a re-runnable read-only `scripts/dry-run.sh`; the conductor runs it on each arrival and at Pass 5's entry.

**M8. 0.4's `hcloud context` writes the token to disk.** `plan:84`. `internal/cmd/context/create.go`: `--token-from-env` copies `HCLOUD_TOKEN` into `config.NewContext(name, token)` and calls `cfg.Write`, storing it in `~/.config/hcloud/cli.toml`. Fold: no context; scripts export `HCLOUD_TOKEN` from `~/.local/secrets`.

**M9. The privacy grep can pass without checking.** `plan:14`, `plan:112`. A missing file prints nothing and exits 2; an empty file exits 1 under GNU grep 3.12, while Claude's Bash `grep` (ugrep) matches every line; a blank line matches everything. The file is created at 0.11, after the first public commits; IPs and topic names are never added. Fold: write it in 0.2; run as a script that `test -s`es, rejects blank lines, calls `/usr/bin/grep`, and treats only exit 1 as clean; add "extend the patterns file with every new IP and topic" to the close checklist.

**M10. Pass 6's entry omits Proton membership.** `plan:205`, `plan:207`. Fold: entry adds "members A, B, and the second operator are signed in to Proton Pass", produced by P1.

**M11. Concurrent passes self-merge to one STATUS from one worktree.** `plan:9`, `plan:36`, `plan:39`. Fold: the conductor is the only STATUS writer; other sessions use per-pass initiatives worktrees.

**M12. F1's container leg fails as specified.** `plan:140`, `plan:252`. Probe: rootless `podman` runs `debian:13` here (resolves `plan:252`). Probe: `systemd-analyze verify` fails "Command /usr/bin/restic is not executable" for every uninstalled binary. Probe: `sshd -t` fails "no hostkeys available" without `ssh-keygen -A`. `docker compose config` needs the Compose plugin and env files. Fold: install packages or stub each `ExecStart`, `ssh-keygen -A`, Docker's repo in the image, a dummy `.env` from templates; cache the image.

**M13. The risk classes don't follow the plan's own path map.** `plan:7`, `plan:24`, `plan:124`, `plan:155`, `plan:193`. M1 and L2 marked `runner` while `infra/**` maps to `ordinary`; the drill firewalls, `provision.sh`, and `dns.sh` fall to `ordinary`; Passes 3 and 7 hold only `ordinary` tasks and would self-merge; "heartbeat intake" isn't a path; W5 reads the real Proton account. Fold: map `infra/**` and `cloudflare/dns.sh` to `auth-data`; name `cloudflare/monitor/src/heartbeat.ts`; state the merge path for 3 and 7; mark W5 `live-account`.

**M14. The monitor's switches and states are unspecified.** `plan:142`. A heartbeat able to write flags lets a compromised server silence itself. Fold: flags in repo config, deployed only by `deploy.sh`; the heartbeat writes only its own row, tested; add tests for an empty bucket, missing `config` or `keys/`, a malformed body, an unknown server id, and several open conditions.

**M15. L6 depends on L7 and the calendar.** `plan:197-198`. The Restore row is the mail drill (L7); Backup growth needs a week. Fold: move the drill into L6 or the row to L7; mark Backup growth a calendar item L8 reads.

**M16. W1's acceptance can't pass at W1, and W1 and W2 share a fixture.** `plan:126-127`. `grep -rn '\bop\b'` hits `claude-sudo-setup:15`, `secret-receive:44` (`--op`), `claude-block-op`, and lookalikes in `claude-tierguard`, `kitty-headless-shot`, `claude-secret-guard`. Fold: move the check to W3 or W4 with `(^|[;&|( ])op (read|item|signin|inject|run)`; decide `secret-receive --op`; build the fake `pass-cli` as W0 before the pair.

**M17. OWNER FORK. No estimate to measure against.** `plan:10`. (a) Approve 2,950 as the line with a ceiling, such as 4,425, then stop; (b) rebase on recent actual-against-planned ratios. Recommend (a), naming line and ceiling in the packet.

**M18. M8's stale-snapshot test needs a bucket that doesn't exist.** `plan:162`. Fold: F3 states whether it reads upload time or the snapshot's `time`; if upload time, M6 creates `servers-scratch-stale` two days ahead and `deploy.sh` takes an override binding; if snapshot time, `restic backup --time`.

**M19. Both pairs share files.** `plan:142-143`, `plan:155-156`. F3 runs F4's `deploy.sh`; both need the gate's Worker leg; M2 edits `check.sh`. Fold: F1 builds the Worker leg as a loop over `cloudflare/*/package.json` and a stub `deploy.sh`; M2's gate check lands in the main loop after the merge.

**M20. L2's blocklist checks have no unattended path.** `plan:193`. MXToolbox's API takes an account key (unquoted). Fold: query DNSBLs over DNS (Spamhaus via DQS, Barracuda, SpamCop, UCEPROTECT); WebFetch MXToolbox's free page as a cross-check.

**M21. The 1Password export waits in RAM until `archive.sh` exists.** `plan:132`; `design:594`. Fold: Geoff's import enters after F2 merges.

**M22. No task creates the monitor's secrets.** `plan:142`, `plan:145`, `plan:160`. Fold: F3 generates topics and heartbeat tokens through `secret-set.sh`, `deploy.sh` pushes them; M6 and L3 generate restic passwords; each listed in the runbook.

**M23. The mail health fields have no task.** `plan:194`, `plan:198`; `design:532`, `design:534`. Fold: name queue depth, oldest age, nightly counts, and the probe search in L3 under `roles/health`, with tests.

## Minors

- **m1.** The task sum is 3,595, not 3,360 (Pass W 300, Pass 1 515, Pass 2 660); the eight packets aren't named.
- **m2.** `check-drift` can't be clean until 0.10 merges; `proton-pass-cli` 2.4.2 is in homebrew/core beside the tap; Homebrew holds with `brew pin`, it can't install a pinned version.
- **m3.** 0.5's `r2 bucket list` is `wrangler`, which isn't global; use the REST API; name the verify endpoint for account versus user tokens; store the S3 key pair (access key id is the token id, secret is the SHA-256 of the value).
- **m4 (optional).** Drop 0.5's "If the dashboard…" sentence and the `plan:249` row.
- **m5.** 0.7 should name the age store as the address list's home until F1.
- **m6.** 0.10's guard hooks are unnamed; the classifier-or-rule signal is undocumented. Quote the auto-mode drop list ("Narrow rules … stay in effect") and prove the rule in a `claude -p --permission-mode dontAsk` probe.
- **m7.** Untasked: Emergency Access for the second operator, sharing `Servers emergency`, and putting the age key into the `Workstation` vault before W5.
- **m8.** F2: test refusal with the age step stubbed to pass input through; name the round-trip object `test/roundtrip-<date>.age`; name `rclone` as the upload tool.
- **m9.** F6's 13-hour read needs `systemd-run --user --on-active=13h`.
- **m10 (optional).** F7's link check should accept 2xx or 3xx.
- **m11 (optional).** Fold F8 into F7, W4 into W3, L8 into L7.
- **m12.** I4's `restic check --read-data` on the first post-cutover media snapshot needs a named step and run time.
- **m13.** C2 checks pavilion only; C3's daily sweep needs a timer; C4 and D3 omit the Gmail `dmarc=pass` pre-checks (`design:278`); C1 omits re-emptying Trash and Junk after the final Vandelay pass (`design:305`).
- **m14.** Hylki is already installed (Flatpak `co.hyprlab.Hylki` 1.44.0) but missing from `bluefin/flatpaks.txt`; D6's 30 minutes can't cover the live end-to-end rows.
- **m15 (optional).** Upload only final archives to the Indefinite archive, not every rehearsal round's.
- **m16.** Tasks don't list their files (`pass-core` step 4), acute for Pass 0, P1 (no class either), and the I-tasks.
- **m17.** Pass 1 edits three repos; create those worktrees first and launch with `--add-dir`; fold F6 and F8 into one workstation PR.
- **m18.** Media has no DNS name for the SSH rule; declare `media.907.life` or generate `~/.ssh/config.d` outside git. 0.9 assumes a Zero Trust organization exists.
- **m19.** Pass W is owned by `conductor-servers` though launched from the workstation; state the exception. Passes 3, 4, and 5 may overlap on `dns.sh` declarations; state the order.
- **m20 (optional).** F1 at 75, M7 at 90, and L3 at 150 look low against the clock stop.
- **m21.** The dubplate snapshot-command request (`design:472`) is never filed; add to M6.
