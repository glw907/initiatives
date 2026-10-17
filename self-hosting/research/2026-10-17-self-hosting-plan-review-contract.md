# Self-hosting plan review: contract and criteria

Target: `self-hosting/plans/2026-10-17-self-hosting-plan.md` at `7061df9`, read against `self-hosting/specs/2026-10-17-self-hosting-design.md` (the design wins) and `pass-core`. Lens: is every promise testable, does each acceptance name its fixture and the reason it would fail, can any pass vacuously, does every "End-to-end check" row map to a task that proves it, does every Claude-owned design requirement have a task, and are human steps separated with what blocks on them.

Counts: 2 blocker, 13 major, 13 minor, 3 over-ceremony (optional). One finding carries an **OWNER FORK** (B1, row 2).

## Blockers

### B1. Seven "End-to-end check" rows have no task whose acceptance proves them (blocker, correctness)

Location: plan:223 (D6), against design:772-788.

Defect: D6 walks the design's end-to-end check at the very end, but for these rows no earlier task produces the evidence. D6 would fail, and no task is scheduled to do the missing work.

| Design row | Closest task | Gap |
|---|---|---|
| Each of the four mailboxes sends to and receives from the Gmail and Outlook.com test accounts (design:773) | L6 "Sending" row (plan:197), C1 (plan:207) | The rehearsal's Sending row tests sending only, with no per-mailbox requirement. Nothing tests receiving from the test accounts after MX moves, and nothing tests the members' mailboxes. |
| TLS-RPT reports arriving at `tls-reports@` (design:775) | C4 (plan:210) | No task checks that a report arrived. |
| An `m.907.life` alias created at a real service delivers to Stalwart, and a reply through its reverse alias passes DMARC (design:777) | P2 (plan:182) | P2 proves delivery to Fastmail before cutover only. Nothing tests delivery after cutover or the reverse alias. |
| `apply.sh media --check` passes the dubplate host contract (design:779) | M3, M4 (plan:157-158) | Neither acceptance runs the check against the contract read from dubplate's deploy docs. |
| Urgent alerts showed as critical banners on **both** workstations (design:782) | C2 (plan:208) | C2's acceptance names pavilion and the phone only. The thinkpad-x1 subscriber is a STATUS item with no acceptance (plan:145). |
| Every Proton member signed in, import counts match, each member confirmed autofill, every passkey site re-enrolled (design:783) | P1, P4 (plan:181, 184) | No task has an acceptance for member sign-in, for the second operator's and household member C's import counts, or for passkey re-enrollment. The passkey list itself is never produced (see M1). |
| On both hosts, `sync.sh` and `secret-set.sh` work through the agent token with the cache cleared, and `check-drift` reports the expiry (design:784) | W5 (plan:130) | W5 proves a decrypt-and-hash match only. It never runs `secret-set.sh` and never reads the `check-drift` expiry line on either host. |

Fold: give each row an owning task with a named acceptance.
- Row 2 goes to a new C5 or to C4. **OWNER FORK** on how the members' mailboxes are tested:
  - (a) Claude sends a test message from each member's Stalwart account, using the password Claude set, and receives one into it, reading only that test message's headers by Message-ID.
  - (b) Each member sends and receives, and Geoff reports the result.
  - (c) Narrow the row to Geoff's mailbox, and cover the members by the per-mailbox count check plus one inbound message each.
  - Recommendation: (a). It stays inside the design's metadata-only rule (design:302) and costs the household no time.
- Row 4 goes to C4 or D3: a JMAP count over `tls-reports@` of at least one report.
- Row 6 goes to D3 or a new C5. Geoff creates the alias at the service, and the acceptance is the verification mail's arrival in Stalwart plus a reply showing `dmarc=pass`.
- Row 8 goes to M4: `apply.sh media --check` exits 0, and its output lists each row of the contract taken from dubplate's deploy docs.
- Row 11: a thinkpad-x1 F6 install with an acceptance, and C2 names both hosts.
- Row 12: P4 acceptance rows for member sign-in (Geoff confirms from the Family admin view), for the counts the second operator and member C report, and for a re-enrolled tick on every row of the passkey list.
- Row 13: W5 adds a `secret-set.sh` round trip, a `sync.sh` run with the cache cleared, and the `check-drift` expiry line, per host.

### B2. The mail server's health additions have no task (blocker, correctness)

Location: plan:194 (L3), plan:198 (L7), against design:532 and 534.

Defect: on the mail server, the design's heartbeat adds the outbound queue's depth and its oldest message's age, plus the nightly per-mailbox counts. The health timer also searches every mailbox, Junk included, for the inbound probe. L3's role list omits `health`, M3 builds it for media only, and L7 only "enables" mail checks. Three urgent or routine conditions depend on these fields: probe confirmation, queue age, and the 10% count drop (design:545-552). So do L7's "the probe arrives" and C2's injected missing-address probe. Without the fields, those acceptances can't pass, or they pass on the Worker's side alone.

Fold: add `health` for mail to L3, with tests against a fixture JMAP response and a fixture queue listing. L3's acceptance then reads: the heartbeat carries queue depth, oldest age, and nightly counts, and a planted probe message in Junk is reported as arrived.

## Major

### M1. Geoff's 1Password import is untasked (major, correctness)

Location: plan:132.

Defect: the import is one paragraph with no estimate, class, acceptance, or test, yet Pass 4's entry gates on it (plan:179). It is also the only source of evidence for the "Cancel 1Password" packet's rows and E2E row 12. The paragraph also leaves out the passkey listing the design requires (design:593).

Fold: make it task W6, class `auth-data` (it covers the `op` read, the export, and the archive). Acceptance:
- The per-vault, per-category count table matches the 1Password listing, or each difference is on the recorded ignored list.
- The passkey list is stored in the private repo.
- Geoff confirms five TOTP codes and two attachments.
- The `archive.sh` round trip passes.
- `/dev/shm` holds no plaintext afterward.

Estimate it, and keep it off the path.

### M2. L6's acceptance needs L7's outputs (major, correctness)

Location: plan:197-198.

Defect: L6 passes when "every row passes in one round", but three rows depend on later work:
- The "Restore" row needs the mail drill, which L7 runs.
- The "Receiving" row needs the monitor's probe, which L7 enables.
- The "Backup growth" row needs a calendar week of nightly backups, which the 150-minute round doesn't show.

As ordered, L6 can't pass before L7.

Fold: either move the drill and probe enablement into L6, or restate L6's acceptance as every row except Restore, the probe half of Receiving, and Backup growth, with L7's acceptance carrying those three. Add the rehearsal week as a calendar wait.

### M3. Human-gated acceptances inside unattended passes don't say what blocks (major, correctness)

Location: plan:170, 173, 184, 197, 208, 210, 222, and the design's "What Geoff does" (design:665-718).

Defect: several acceptances can pass only after a person acts, yet the passes run unattended under `conductor-servers`:
- I1 needs a phone.
- I4 needs the household's sign-in-loop reports.
- P4 needs the members' confirmations.
- L6 needs a member's iPhone and Mac, the second operator's Android phone, and Geoff's landing reports.
- C2 needs the second operator's phone.
- C4 needs "no member reported missing mail".
- D5 needs the second operator.

The plan names some of these as STATUS items, but never says which task or pass stays open on each, or who chases it.

Several of the design's human steps are also missing from the plan:
- The Emergency Access invite to the second operator (design:566, 685). Pass 0.6 lists four invites but not this one.
- Sharing `Servers emergency` with the second operator (design:699).
- Passkey re-enrollment (design:701).
- Members A and B installing their profiles on cutover day (design:713).
- The T+30 Fastmail web steps, including the masked-mail forward with SRS (design:714).
- The 200 GB cleanup's lock lift (design:717).

Fold: add a "Human steps" table per pass, one row per step, with columns for who acts, which acceptance waits on it, and what Claude has ready. Reconcile it against the design's "What Geoff does", line by line.

### M4. The port 25 answer has no route into the session (major, correctness)

Location: plan:72, 190, 50.

Defect: Pass 5's entry condition is "Hetzner approved port 25", and the 14-day standing answer needs someone to read the calendar. Hetzner answers in its console or by mail to Geoff, and no step says how the answer reaches STATUS or who checks the 14 days. The entry condition can't be observed.

Fold: name Geoff's step ("record Hetzner's answer in STATUS"), or a Claude check of the answer's metadata over Geoff's read-only JMAP access, which is a method call that is Claude's to make. The conductor reads the clock daily from the 0.1 filing date.

### M5. 0.5's token-verify acceptance passes for a mis-scoped token (major, correctness)

Location: plan:88.

Defect: Cloudflare's token-verify endpoint confirms a token is active, not its scope. A backup token scoped to the wrong bucket, or one with Admin rights, passes. Per-bucket scope is what keeps one compromised server away from the other's backups.

Fold: for each R2 token, one allowed operation on its own bucket and one refused operation (403) on the other bucket. For each restore token, one refused write. For the DNS token, one refused write on a zone other than 907.life.

### M6. The privacy grep can't run before 0.11 (major, correctness)

Location: plan:14, 112.

Defect: the plan requires the privacy grep before every commit to a public repo, but its patterns file is created only at 0.11. Before then, 0.1 and 0.2 already write STATUS in the public `initiatives` repo, and 0.10's workstation PR merges, so Pass 0 breaks its own rule.

Fold: move the patterns file to a step 0.0, before 0.1, and leave 0.11 as the recovery kit alone.

### M7. Credentials that arrive after Pass 0 never get a dry run (major, correctness)

Location: plan:116, 190.

Defect: 0.12 passes with the members' credentials "owed". Pass 5's entry needs all four mailboxes' credentials to have "passed the dry run", and E2E row 16 needs every credential reached. No task re-runs the dry run for credentials that arrive later.

Fold: make 0.12's dry run a re-runnable script. L1's precondition runs it for every credential that arrived after Pass 0 and updates the STATUS table.

### M8. Tightening DMARC and SPF omits the design's gate (major, correctness)

Location: plan:210 (C4), 220 (D3).

Defect: the design moves DMARC only after two conditions hold (design:278):
- 14 consecutive days of reports show every listed sender aligned and no unlisted source sending.
- A sign-in mail from the site and a monitor probe both show `dmarc=pass` at Gmail.

C4's acceptance is only that "the packet carries every evidence row", and D3 has no acceptance. Either could pass while the site's sign-in mail fails DMARC, which at `p=reject` drops it. The move to MTA-STS `enforce` also needs the policy's MX list to drop Fastmail's hosts first (design:293).

Fold: C4 and D3 each take the two-part gate as acceptance, with the report window's dates and the two Gmail headers. C4 adds the policy file read back with `mode: enforce` and only `mail.907.life` in its MX list.

### M9. No task proves the script allow rules work unattended (major, correctness)

Location: plan:108, and plan:141, 144, 155.

Defect: 0.10 tests the deny rule and the SSH rule. It can't test the allow rules for `provision.sh`, `apply.sh`, `dns.sh`, `r2.sh`, `deploy.sh`, and `restore-drill.sh`, because the servers repo doesn't exist yet, and no later acceptance proves those commands ran without a prompt or a classifier block. The failure looks like an unattended pass sitting at a prompt overnight.

Fold: add to each first live use (F2's `r2.sh --apply`, F3's `deploy.sh`, F5's `dns.sh`, M1's `provision.sh --apply`, M7's `restore-drill.sh`): "ran in the unattended session with no prompt, and the transcript shows the rule matched". Then fix the rule in the same PR if it didn't.

### M10. M7 doesn't prove the drill's isolation (major, correctness)

Location: plan:161.

Defect: the design's drill properties are no write, heartbeat, tunnel, or Spamhaus credential on the drill server, and outbound traffic closed before any service starts (design:498-502). The acceptance checks only the role-list refusal. "The drill passes" also doesn't name the `restic recover` result.

Fold: the acceptance adds three checks:
- The secret names rendered on the drill host are exactly the restic password and the read-only token.
- Under the closed firewall, an outbound connection to port 25 and port 443 on an outside host fails.
- The recovered snapshot restores and matches the manifest.

### M11. M1 has no test for the rebuild refusal (major, correctness)

Location: plan:155.

Defect: the refusal is the design's only guard on a disk-wiping rebuild (design:618), but M1's acceptance runs the fake-`hcloud` tests without naming this case.

Fold: a fake-`hcloud` test in which a rebuild without a stop, a backup, and a snapshot in the same run exits non-zero, with no `rebuild` call recorded.

### M12. Nothing produces the masked-address evidence for the other three accounts (major, correctness)

Location: plan:192, 210, 218.

Defect: the Fastmail removal packet's evidence includes "Every masked address and Fastmail-only login on the three accounts has moved" (design:639). L1 counts A's and B's masks, and the second operator lists his own in Pass 0, but no task tracks those addresses to moved or produces the evidence row.

Fold: D1's weekly recount covers the three accounts with `MaskedEmail/get` counts. C4's acceptance carries "enabled masks on the three accounts = 0", plus the second operator's confirmation for his Fastmail-only logins.

### M13. Tasks are missing the fields `pass-core` requires (major, correctness)

Location: plan:181 (P1, no class), 199 (L8, no acceptance), 129 (W4, no acceptance), 218-223 (D1, D3, D4, D5, D6, no acceptance), 132 (the import, nothing at all). Most `ordinary` tasks also omit the test and files fields.

Defect: `pass-core` "Plan" requires each task to carry its outcome, files, risk class, acceptance check, test, and clock estimate (SKILL.md:66). A task without an acceptance can't fail, so it passes vacuously.

Fold: fill each field. Suggested acceptances:
- L8: the packet carries the growth figure and the deletion count.
- W4: the PR is open, the gate is green, and the packet is sent.
- D1: the recount job ran once and its report lists the counts.
- D4: the packet carries the design:640 rows.
- D5: the second operator completes both tasks, and each runbook fix has merged.
- D6: each E2E row has an evidence link.

## Minor

### m1. F8's acceptance passes on empty files (minor, correctness)

Location: plan:147.

"Both files exist" passes on empty files. Fold: the prompt names each periodic item:
- the Hetzner US trigger, upgrades, and health
- the 200 GB cleanup packet
- the twice-yearly drill
- the yearly alias export and DKIM rotation
- the quarterly token-renewal reminder

### m2. The lock checks don't name the failure code (minor, correctness)

Location: plan:160, 198.

Fold: name `409 ObjectLockedByBucketPolicy` as the expected failure for the delete and the overwrite, so a 403 from a mis-scoped token doesn't count as a pass. The `locks/` delete stays as the positive control.

### m3. M8 checks the topic, not the subscriber (minor, correctness)

Location: plan:162.

"Reached the routine topic" isn't the E2E's "reached its subscribers". Fold: the notification shows on pavilion at normal urgency.

### m4. The stop-on-failure tests name no fixtures (minor, correctness)

Location: plan:160, 194.

Fold: M6 uses a 27-hour-old dump, a corrupt gzip, and restic exit 3. L3 uses Stalwart killed rather than exiting cleanly, plus the trap restart after a mid-script death.

### m5. 0.4 passes with a read-only token (minor, correctness)

Location: plan:84.

An empty list also passes with a read-only token. Fold: a reversible write, such as creating and deleting a labeled SSH key, and a read of the project's identity.

### m6. P1's acceptance can't be tested by Claude (minor, correctness)

Location: plan:181.

"A member can follow without Claude" is something only a member can show. Fold: Vale plus each member's confirmation, which P4 carries.

### m7. Some of the design's "Not checked" items have no owning task (minor, correctness)

Location: plan:253.

"The rest" leaves the auto-ban loitering question, DMARC Management's API readability, and Hylki's discovery without a task. Fold: add those rows to L6 and L7.

### m8. F1 doesn't move the confirmed address list (minor, correctness)

Location: plan:96, 140.

Fold: F1's acceptance includes moving the confirmed address list into the private repo and removing STATUS's pointer.

### m9. `secrets/registry.md` doesn't exist during Pass 0 (minor, correctness)

Location: plan:68.

The registry lives in the servers repo (design:188), which doesn't exist during Pass 0. Fold: name where its rows are held until F1 creates the file.

### m10. The dubplate backlog request is never filed (minor, optional)

Location: plan:160.

The design sends a request for a local snapshot command to dubplate's backlog (design:472), and no task files it. Fold: add it to M6's "Found, not done".

### m11. The packet count doesn't match the work (minor, optional)

Location: plan:240.

"Eight packets at 40" falls short of nine passes plus five irreversible packets, the cutover-date packet, and a possible options packet. Fold: count the packets and state the basis for the figure.

### m12. The path estimate has no design figure to check against (minor, optional)

Location: plan:10.

The design names no estimate, so `pass-core`'s twice-the-design stop has nothing to measure against. Fold: list the 2,950-minute line as an explicit ask in the plan's packet, beside the overrun rule.

### m13. Nothing proves the masked-mail forward is live (minor, correctness)

Location: plan:209.

Nothing proves the forward with SRS is live, and nothing ends the daily sweep (design:361, 714). Fold: C3 or D4 checks that a test message to a Fastmail mask arrives at Stalwart, then stops the sweep.

## Over-ceremony (optional)

### o1. The "Not checked" row on bucket naming changes nothing (minor, optional)

Location: plan:88, 249.

The row about a token naming a missing bucket, and 0.5's contingency sentence, lead to the same action either way. Fold: drop both. This saves a few hundred tokens per read.

### o2. The weekly recount is written twice (minor, optional)

Location: plan:183, 218.

P3 writes the weekly recount job and D1 sets it up again. Fold: one owner. This saves about 30 minutes.

### o3. "Each `auth-data` commit" doesn't say whether steps without commits count (minor, optional)

Location: plan:7.

Steps 0.4, 0.5, and 0.12 store credentials and make no commit. Fold: say a `diff-reviewer` read runs only where a commit exists, so no read is sent for a credential-store step.
