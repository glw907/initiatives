# Pass 5 plan review: contract and criteria

This review reads the amended Passes 5 and 6 in `plans/2026-10-17-self-hosting-plan.md`, plus `2026-10-21-pass5-preflight.md`, `-rules.md`, `-prompt.txt`, and `-conductor-prompt.txt`, at commit 9a25e94 on branch `pass5-plan`. The design binds them. The lens asks whether every promise is testable, whether each criterion names its fixture and the reason it would fail, and whether any criterion can pass vacuously. It also checks each design criterion against the two-mailbox ruling of 2026-10-20. Findings are ranked by consequence.

## Blocker

### 1. Inbound test mail to the two mailboxes lands at Fastmail during the rehearsal

`correctness`. Locations: `2026-10-21-pass5-preflight.md:145-151` (R1), `2026-10-17-self-hosting-plan.md:127` ("Human steps", Outlook row), `:308` (L6 Sending and Receiving), `2026-10-21-pass5-rules.md:231` (the Gmail send rule).

**Defect.** R1 has Geoff send from Outlook.com "to each of the two mailboxes", and its check reads "your two messages are in Stalwart, found by subject token". Through Pass 5 the apex MX stays on Fastmail (L4), so Outlook delivers to Fastmail and the check can't pass. The Gmail send rule hits the same wall for any message to a 907.life mailbox. Worse, the messages land in the real Fastmail mailboxes. L8 deletes test messages "in Stalwart" only, so the final Vandelay pass in C1 copies them back into the migrated mailboxes. Nothing deletes them in Fastmail, and the Message-ID list never captures the ones Geoff sends from the web app.

**Fold.** Before cutover, the inbound half sends only to an address that ward receives. That's the test account on `probe.907.life`, which already has its MX on ward, or a direct SMTP connection to ward (finding 2). R1 keeps two jobs: Geoff reports landing for ward's sends to Outlook.com, and he sends one message to the test account's `probe.907.life` address. Outlook-to-mailbox and Gmail-to-mailbox move to C3, after the switch, where they already sit. L6 states that no rehearsal message is addressed to a 907.life mailbox, so nothing reaches Fastmail and L8's Stalwart-only deletion stays complete.

## Major

### 2. The Receiving row's "direct SMTP connection" has no command, rule, or reachability check

`correctness`. Locations: `plan:308` (L6), `rules.md:231-232`, `prompt.txt:281`.

**Defect.** The design's Receiving row needs test mail by direct SMTP to port 25. The only send rules are `smtps://...:465` submission forms. Those authenticate as a sender and never exercise inbound. No rule, command form, or pre-flight check shows that pavilion can open port 25 outbound, and residential ISPs commonly block it. The row either stops on a classifier denial or passes on the 465 path, which proves nothing about inbound.

**Fold.** Name the form, for example `curl --url smtp://ward.907.life:25 --mail-rcpt <test account at probe.907.life> ...`, and add its allow rule and dontAsk proof line. Add a pre-flight conductor check that pavilion reaches some public port 25 (an `EHLO` to a known MX). Name the fallback for a blocked port, such as sending from orpheus over its existing SSH rule.

### 3. The scope ruling's own promise has no criterion: A's and B's addresses bounce and no catch-all exists

`correctness`. Locations: `plan:10` (Mail scope), `:305` (L3 acceptance), `:307` (L5 acceptance), `:318` (C1 acceptance).

**Defect.** The ruling says mail to household members A and B "bounces after cutover". The design's address list includes "any catch-all", and `docs/addresses.md` says catch-alls on other users' accounts are invisible to Geoff's token. If one is recreated, or Stalwart's default domain handling accepts unknown local parts, A's and B's mail lands silently in another mailbox. That's a privacy failure, and every L3, L5, and C1 criterion still passes.

**Fold.** L5's acceptance adds two checks. First, ward refuses an SMTP `RCPT TO` for each of A's and B's addresses with a 5xx; finding 2's port-25 path makes that testable. Second, Stalwart's principal and alias list equals the expected set (finding 4), with no catch-all. C1's acceptance repeats the `RCPT` check after the switch.

### 4. The address set L5 creates is unpinned, and its acceptance never reads it back

`correctness`. Locations: `plan:307` (L5), `:290` (mask figures), `:322` (C5); design "Migration" and "Irreversible steps" ("the three @907.life masked addresses").

**Defect.** L5 creates "each 907.life mask that is enabled at Fastmail". The design's irreversible-step evidence names three such masks. The 2026-10-21 measurement finds five on 907.life "in any state", four of Geoff's and one of the second operator's. No line says which states count as "accepted": whether a disabled mask still receives at Fastmail decides whether dropping it changes delivery. L5's acceptance (inspect counts, idempotence, archive round trip) never checks that any address exists. C5's packet still has to cite "the three @907.life masked addresses exist in Stalwart", which now matches neither count.

**Fold.** In L1, record each 907.life mask's state, with the expected address set and its count, in `docs/addresses.md` (private repo). In L5, the acceptance adds "Stalwart's list of accepted addresses equals that set, each also answering `RCPT TO` with 250". In C5, cite the recorded count in place of "three".

### 5. A's and B's masked addresses go unmeasured, and the T+30 packet deletes them **(OWNER FORK)**

`correctness`. Locations: `plan:322` (C5), `preflight.md:94-101` (item 8); design "Triage" step 1 and the "Irreversible steps" Fastmail row.

**Defect.** The design leaves open whether A and B hold masks ("Claude checks over each one's API token in the mail pass"). The old L1 counted them, and the amended L1 doesn't. Item 8 revokes the only tokens that could check. C5's packet removes A's and B's users. If either holds a mask used at a real service, that sign-in breaks with no warning. The design's evidence row ("every masked address ... on the three accounts has moved") is then unprovable, and C5 records no departure for it.

**Options.** (a) Before revoking in item 8, Geoff opens each member's Masked Email list in the same settings view, reads the count of enabled masks, and the L8 message tells A and B about any he finds. (b) Leave the count unknown, and have C5's packet record that departure from the design's evidence row.

**Recommendation.** (a). It adds one look to a step Geoff already takes, and it turns a silent loss into a stated one.

### 6. C2's check on the second operator can pass vacuously

`correctness`. Locations: `plan:319` (C2), `:136` ("Human steps"), `preflight.md:176` (owed). The monitor's `alert_to` at servers origin/main holds one address today.

**Defect.** "The second operator confirms both if his address is among them". His address is owed outside the pass, so C2 passes with no proof he hears an urgent alert. The design's end-to-end check requires that urgent alerts "arrived on the second operator's phone".

**Fold.** Make his verified `alert_to` address an entry condition for C2. Otherwise, write C2's acceptance as a recorded gap: a "Not checked" row and an owed end-to-end item, never an "if".

### 7. L7's inbound-probe fallback can't pass before cutover

`correctness`. Locations: `plan:306` (L4: reports to `dmarc-reports@` "bounce at Fastmail until the MX switch"), `:309` (L7), `prompt.txt:301`.

**Defect.** If Email Sending can't reach `probe.907.life`, the standing answer switches to the DMARC-report fallback, in which ward confirms an aggregate report arrived in the last 48 hours. Before the switch, those reports go to Fastmail and bounce, so ward never gets one. L7's acceptance ("the probe arrives") is then unreachable in Pass 5, and the executor would loop or stop.

**Fold.** Under the fallback, L7's acceptance becomes "fallback wired and its condition muted until cutover". C1 gains "a DMARC report reached `dmarc-reports@` within 48 hours of the switch", or C5 gains it, given the 14-day window.

### 8. Evidence rules conflict on R3 (the second operator's apps)

`correctness`. Locations: `preflight.md:5`, `:143`, `:167`; `prompt.txt:289`.

**Defect.** The pre-flight and the prompt both say Geoff's word is the evidence only for landing at Outlook.com. R3's check rests partly on the second operator's report: items appear "in his apps by his report". That half is the design's "sync both ways". A literal executor must either refuse that evidence and stop, or pass the row on one direction only.

**Fold.** Name the second operator's report as the second allowed human-evidence source, scoped to the server-to-device direction of the Clients and Android rows, in all three places.

### 9. The rules' `dontAsk` proof can pass without testing a deny

`correctness`. Location: `rules.md:248-250`.

**Defect.** Part of the pass condition is that the log "shows no entry" for `imapsync --host1 x`, the `--prune` export, and `access.sh --token orpheus`. A session that never attempted them, or a stub that failed to run, leaves the same empty log. The deny half of the proof is therefore vacuous, and the proof gates launch.

**Fold.** Run the session with `--output-format json`. The pass condition then also needs `permission_denials` to list each of the three denied commands, as well as the allowed forms' log lines.

### 10. The contacts-only accounts have no identity fixture

`correctness`. Locations: `plan:290` ("Each token also reaches a second, contacts-only account"), `:307` (L5), design "Rehearsal" Contacts row ("the shared account included").

**Defect.** The design knew of one shared contacts-only account, reached through Geoff's token. The measurement finds one per token. If both tokens see the same shared account, L5 imports it twice, once under each owner, and the Contacts row still passes, because it compares per address book. Nothing names which Stalwart account receives it.

**Fold.** L1 records each contacts-only `accountId`, whether the two are the same, and the target Stalwart account (private repo). L5's acceptance imports each distinct id exactly once.

## Minor

### 11. L2's acceptance can't be met by its own recorded fallback

`correctness`. Locations: `plan:304` and `:365` ("Not checked").

**Defect.** The acceptance demands that "both lookup pages report no listing". "Not checked" says those pages may not render for WebFetch, and that the DQS check then stands alone.

**Fold.** Change the acceptance to: "the DQS check reports no listing, and the cross-check pages agree or `decisions.md` records the fallback."

### 12. L6's acceptance doesn't enumerate the amended row set or the mail-tester leg

`correctness`. Location: `plan:308`; design "Delivery".

**Defect.** "Every row in scope passes in one round" leaves the executor to derive the set after the Apple and Receiving changes. The design's outbound test includes mail-tester, which no amended text, rule, or prompt mentions. A round can pass without it.

**Fold.** List the rows in scope in the acceptance, each with its evidence source (API, IMAP, Geoff, or the second operator). Name mail-tester under Sending.

### 13. R1 omits the design's "a missing message is a failure"

`correctness`. Location: `preflight.md:148`.

**Defect.** Geoff reports "Inbox or Junk". Microsoft's documented failure is a silent drop, so a report of "nothing arrived" has no defined outcome.

**Fold.** Add a third answer, "not there after 15 minutes", and state that it fails the row.

### 14. L7's acceptance omits what L7 turns on and stores

`correctness`. Location: `plan:309`.

**Defect.** The acceptance never checks four things L7 does:

- that the seven monitor flags are deployed;
- that `mail_urgent` reads false;
- that `/alerts` is quiet once `heartbeat_ward` is on;
- that the second operator's Stalwart password item exists in `Servers emergency`, which is Pass 6's entry.

"Every hash matches" covers values, not the item set.

**Fold.** Add to the acceptance: `config.json` shows the seven flags true and `mail_urgent` false, `/alerts` shows no ward condition, and the operator item reads back by hash.

### 15. The imap-sweep backup band is a clock heuristic

`optional`. Location: `plan:308`.

**Defect.** "Refuses to start between 03:20 and 04:00 UTC" assumes ward's stop always falls inside that band. A long first rsync would push the stop later. The consequence is only a failed sweep, since Stalwart refuses connections while stopped, not lost mail.

**Fold.** Keep the band, and also check `systemctl is-active` on ward's backup service over the existing SSH rule. Or leave it as is, with a "Not checked" line.

### 16. The prompt's command forms conflict with each other and with the rules

`correctness`. Location: `prompt.txt:281`.

**Defect.** "No pipe on a live script" sits beside the required `cloudflare/access.sh --token ward | secret-set.sh ...` pipe. Vandelay's credential comes "from a file you source", and `source file` matches no allow rule, so the classifier decides that call, which is the failure mode the rules file exists to remove.

**Fold.** Exempt the `--token ward` pipe by name. For Vandelay, write the exact form, for example `env -S` or a `--config` file if Vandelay takes one, and add its rule. Otherwise, record that the classifier decides the call.

### 17. C3's "household-session path" no longer has a definition

`correctness`. Location: `plan:320`.

**Defect.** The path was written for household members A and B (`plan:20`). With one member left, C3 points to steps no section defines.

**Fold.** One sentence in C3: the second operator sends and receives one message per test account in a session with Geoff, and Geoff reports the headers.

### 18. The Apple consequence is asserted without a source

`optional`. Location: `plan:288`.

**Defect.** "No household member with a mailbox uses an Apple device" is recorded as following from the ruling, but nothing cites it.

**Fold.** Cite design "Cutover" step 6, which sends profiles only to A and B.

### 19. Over-ceremony: the same figures are restated across five places

`optional`. Locations: the sizes and masks appear at `plan:290`, `preflight.md:13`, and `prompt.txt:263`, and L1 measures them again (`plan:303`).

**Defect.** L1 measures again the night after the pre-flight's read. The executor reads the same figures three times before it starts. The cost is small: a few minutes of L1 and a few hundred tokens per read.

**Fold.** Keep the figures in the plan alone. L1 records a delta only if a figure moved by more than 5%, or drops the measurement and cites `plan:290`.
