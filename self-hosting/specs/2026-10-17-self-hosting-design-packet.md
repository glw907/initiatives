# This packet approves the self-hosting design, and approving starts a plan whose first pass you and Claude run together.

Every question from the research is answered, three reviews and two verification reads have tested the design, and two decisions remain yours.

## Background
The self-hosting initiative moves 907.life mail, photos, music, and passwords off Fastmail, PikaPods, and 1Password onto two Hetzner servers in the EU and Proton Pass, with backups in Cloudflare R2. This packet carries the design and the PR that files it. Pass 0 is an attended first pass that gathers every credential, so the later passes run unattended. restic is the backup tool, and an R2 bucket lock is a rule that stops anyone deleting stored files.

## If you approve
1. [session] Squash-merge glw907/initiatives#8, which files the design and its reviews on main without the early commit that named two household members.
2. [session] Write the pass plan from the design and send it to you as a packet.
3. [you: run Pass 0 with Claude] Set up every account, credential, and permission rule in one attended pass.

## Not checked
Fastmail's current plan, whether a Fastmail admin can create credentials for another user, and Hetzner stock on order day. Pass 0 and the mail pass check each, and the design names a fallback for each.

## Ask: How deep should the backup lock go?
Rule: owner-call
Part: none
Recommended: 1
Reason: restic stores each piece of data once, so tonight's backup still depends on months-old files, and only a permanent lock keeps every backup restorable if a server is taken over.
Summary: A 30-day lock leaves old backup files deletable, which breaks every backup. A permanent lock prevents that, and storage grows by about 15 to 40 GB a year.

Background: Each server writes its own backups to R2. If an attacker controls a server, its R2 token could delete backup files that no lock covers. restic deduplicates, so a recent snapshot reuses files uploaded long ago, starting with the first full copy of the photos.

Facts: A local probe deleted only the first backup's files and broke the newest restore.
- After the deletion, `restore latest` recovered 976 KiB of 3.8 MiB (`self-hosting/research/2026-10-17-self-hosting-design-fold-verification.md`)
- A forget and prune of expired snapshots ran clean beside a locked newer one (`self-hosting/research/2026-10-17-self-hosting-design-fold.md`)

Choices:
- Lock for good: no server can destroy its backups; storage costs about $0.25 to $0.60 a month more each year, and a cleanup comes to you past 200 GB
- Lock 30 days and prune monthly: storage stays flat, but a taken-over server can break every backup

## Ask: If Hetzner refuses or stalls the port 25 request, what then?
Rule: owner-call
Part: none
Recommended: 1
Reason: Your ruling sends mail directly with no relay, so a refusal is a new decision best made with Hetzner's actual answer in hand.
Summary: Mail can't cut over until Hetzner opens port 25. The design pauses the mail passes and comes back to you, or you can pre-approve a relay for that case.

Background: Hetzner blocks outbound mail on port 25 until a customer's request is approved, case by case. A relay is an outside service that sends mail on your behalf over port 587, which Hetzner leaves open.

Facts: The account is old enough to file the request.
- Hetzner lifts the block on request after one month and a paid invoice (`self-hosting/research/2026-10-17-mail-cutover.md`)

Choices:
- Pause and ask: after a refusal or 14 days with no answer, the mail passes stop and an options packet comes to you
- Pre-approve a relay: SMTP2GO's free tier or Amazon SES is set up only in that case, and you still create the relay account

## Routine
| Part | Verdict | Fact | Why |
|---|---|---|---|
| glw907/initiatives:self-hosting/specs/2026-10-17-self-hosting-design.md | approve | Every blocker and major from three reviews and two verification reads is closed in the spec text, and both servers start as CX33s at about $24 a month. | Your rulings of 2026-10-17 are recorded in its "Rulings" section. |
| glw907/initiatives#8 | approve | `scripts/check` passes, and the PR only files records. | The record stays proposed until the plan is approved. |
| step:1 | session | A squash merge can be reverted. | Your ruling of 2026-10-17 keeps the early commit off main. |
| step:2 | session | The plan comes back to you before any pass runs. | Nothing is built yet. |
| step:3 | you | Pass 0 needs your logins and FIDO2 keys. | It's the one long attended session. |
