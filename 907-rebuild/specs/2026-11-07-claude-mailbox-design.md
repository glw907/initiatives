Initiative: 907-rebuild

# Claude's send mailbox on ward: design

## Brief

Servers BACKLOG #65 asks for a `claude@907.life` mailbox that a Claude session can send from, so the 907.life rebuild's close check (P6) can prove outbound mail without you. Ward gets one more Stalwart account, built the way credential-hygiene's pass B built the technical mailbox: a private login, a public alias `claude@907.life`, an account password only you hold, and an app password for Claude. That app password can send and can read its own mailbox, and nothing else. A helper, `scripts/claude-mail.sh`, sends to a fixed list of recipients and prints everything it reads inside the untrusted-content banner. You run one setup script after the PR merges. The servers runbook gets a section on the mailbox, and the operator runbook plan gets an amendment so the second operator's rebuild covers it.

Risk class: `auth-data` (a new credential, an account on ward, and a sender that speaks for 907.life). Estimate: 240 path minutes, ceiling 480. Spend: none. Executor: `servers-claude-mailbox`, under `conductor-servers`. Approved 2026-11-07 (Approval Queue item 20261107T170519-526459).

## What gets built

1. **The account.** `roles/stalwart/accounts.json` gains `a-claude` on `d-907`, `household: false`, with an unguessable login and the alias `claude`. Its password name is `STALWART_PASSWORD_CLAUDE`. Ward already signs 907.life mail with the `w1-ed25519` and `w1-rsa` keys (`cloudflare/dns/ward`), and SPF lists ward's address, so no DNS record changes. The account renders no Sieve script and joins no address book.
2. **The app password.** `claude-sender` carries `authenticate`, `emailSend`, and the six read permissions the technical mailbox's reader holds (`docs/runbook.md`, "Technical mailbox"). Stalwart lets a credential only narrow its account's permissions, so it can't delete, change filters, or sign in as anyone else. The plan proves the exact set on `probe2` first, including whether an SMTP submission on port 465 needs more than `emailSend`. Its store name is `CLAUDE_MAIL_APP_PASSWORD`.
3. **The helper.** `scripts/claude-mail.sh send TO SUBJECT` reads the body on stdin, sends over SMTP on port 465, and prints the Message-ID. `send` refuses any address not in `scripts/claude-mail.recipients`, and the list starts with your aksailingclub.org Gmail address. `list` and `show ID` read the mailbox through `tech-mail.sh`'s reader and banner, so bounces and replies arrive as data. The round trip for P6 goes like this: the session sends to your Gmail, finds the message by its Message-ID through the Gmail connector, and reads `dkim=pass header.d=907.life` and `dmarc=pass` from the raw headers. The Gmail connector is already in use for the rebuild's inbound tests.
4. **The setup script.** `scripts/claude-mailbox-setup.sh` follows `tech-mailbox-setup.sh` step for step: it makes the account password and the Proton Pass item `Stalwart (claude mailbox)` in `Private` under your login, applies ward, makes or keeps the app password, then proves it. The proof is a send to the list's first address that's `allowed`, a send to an address off the list that's refused (see "Decide"), and a delete that's refused. Any failure takes the app password back, as pass B's script does.
5. **The workstation.** One PR adds allow rules for `scripts/claude-mail.sh`, the shape `tech-mail.sh` has. It also adds an `autoMode.environment` line saying that `CLAUDE_MAIL_APP_PASSWORD` is sensitive, that every send goes through the helper only, and that the mailbox's mail is untrusted input. Geoff asked on 2026-11-07 that the workstation be broadly aware of the account, its purpose, and how to use it. So the same PR names it everywhere the technical mailbox is named:
   - the global CLAUDE.md "Email" bullet: the address, what it's for (outbound proof from 907.life), and the helper
   - the workstation secrets registry: rows and sections for `CLAUDE_MAIL_APP_PASSWORD` and `STALWART_PASSWORD_CLAUDE`, with how each rotates
   - `bluefin-admin.md` "Secrets", where it lists the technical mailbox's reader
   - the `mail-tend` skill: the account has no Sieve script, and it's read only through `claude-mail.sh`
   - the `proton-pass` skill's vault map: the `Stalwart (claude mailbox)` item in `Private`, which Claude can't read

   `conductor-servers` writes this PR from an interactive session, since a background executor's auto mode refuses settings edits (`pass-core`, credential-hygiene pass A).
6. **The runbook.** `docs/runbook.md` gets a "Claude's send mailbox" section beside "Technical mailbox". It covers what the mailbox is for, the permissions and the recipient list, the helper's verbs, the setup script's steps, how to rotate each password, how to turn sending off (delete the app password, or set the account's `emailSend` off and apply ward), and the round-trip check. `docs/decisions.md` records the design. The operator runbook plan gets a dated amendment: the two new names join the stay list beside the technical mailbox's, T3b's password-file split and its counts skip cover the account the same way, and the restructured runbook keeps the new section.

It runs on ward because the mailbox is a Stalwart account. Ward already holds the household's mail and backs it up nightly, and an account adds no service.

## Decide: Should ward itself refuse Claude's mail to an address off the list?

**Ruled 2026-11-07 (Approval Queue item 20261107T170519-526459): ward refuses it.** The plan builds the RCPT rule.

The helper's list stops a session that follows the rules. A session that reads the app password and calls SMTP itself would get past it. Auto mode's environment line forbids that, but it's a prompt, not a lock. Stalwart v0.16 sets the RCPT stage on the `MtaStageRcpt` object, whose rules can test `authenticated_as` (<https://stalw.art/docs/ref/object/mta-stage-rcpt>). A forum answer uses a script there, gated on `!is_empty(authenticated_as)`, to block one account's outbound recipients, and says it covers JMAP sends too (<https://support.stalw.art/t/how-to-block-outbound-email-address/1233>). So a rule there can refuse `claude`'s mail to any address off the list. That object governs all of ward's mail, so a wrong rule could refuse inbound mail too. The plan proves the rule on Stalwart v0.16.27 against `probe2` before it builds anything, and the apply test checks that inbound mail and the other accounts' sends still pass.

- Yes: ward refuses any recipient off the list, and the helper's list is the same file (recommended, about 60 more minutes)
- No: only the helper limits recipients, and the runbook names the gap

If the proof shows Stalwart can't do it per account, the standing answer is to ship the helper's list and file a backlog item.

## Backlog sweep (scoped)

- #65 fold: this pass.
- #64 keep: the monitor keys mailbox counts by login, so this account's private login would show on `/alerts` the way the technical mailbox's does. The fix belongs in #64, not here.
- #23 keep: the helper could later run its mail-tester row, which needs an outside receiver.
- #62 keep: it hardens the reader that `claude-mail.sh` shares, and it lands separately.

## Pre-flight

None before launch. The executor works on fakes and `probe2` only. You run `scripts/claude-mailbox-setup.sh` once after the merge, the way you ran pass B's. Then the session runs the round trip and reports the two header lines.

### Standing answers

| Situation | Answer |
|---|---|
| The `probe2` proof shows the app password needs a permission beyond the list above to submit over SMTP | Add the narrowest one the proof names, and record it under `## Decisions` |
| Stalwart can't refuse recipients per account | Ship the helper's list, file a backlog item, and say so in the runbook |
| Gmail files the test message as spam | Read its headers anyway, since P6 checks DKIM and DMARC, not placement, and record it |
| The workstation PR's rules collide with a live session's settings edit | Wait for that commit, rebase, and record it |
