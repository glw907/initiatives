# Claude's send mailbox on ward

The 907.life rebuild ends with a close check (P6) that proves 907.life's outbound mail passes DKIM and DMARC at an outside receiver. Today only you can send that test message. You filed servers BACKLOG #65 for a `claude@907.life` mailbox that a session can send from, and you told `conductor-servers` to take it now.

This design adds one Stalwart account on ward, built like credential-hygiene's technical mailbox. Its login stays private, its public alias is `claude@907.life`, and only you hold its account password. Claude gets an app password that can send and can read that mailbox, and nothing else. A helper sends only to a fixed recipient list, starting with your aksailingclub.org Gmail, and prints everything it reads inside the untrusted-content banner. The servers runbook gets a full section on the mailbox, and the operator runbook plan gets an amendment so the second operator's rebuild covers it. Approving starts the plan and one executor. The PRs come back to you in one packet, and after they merge you run one setup script, as you did for pass B.

One question needs you. The session recommends having ward itself refuse this account's mail to any address off the list, so a session that bypasses the helper still can't mail anyone else.

## If you approve
1. [session] Commit this design and the backlog verdicts, and add a dated amendment to the operator runbook plan for the new account.
2. [session] Write and review the plan, then launch `servers-claude-mailbox` under `conductor-servers`.
3. [session] Write the workstation PR for the helper's allow rules and the auto-mode line from the conductor's session.

## Not checked
The exact app-password permissions for an SMTP send come from Stalwart's permission list, and the plan proves them on `probe2` before it builds. The RCPT rule rests on Stalwart's reference page and one forum answer, and gets the same proof.

## Ask: Should ward itself refuse Claude's mail to an address off the list?
Rule: owner-call
Part: glw907/initiatives:907-rebuild/specs/2026-11-07-claude-mailbox-design.md
Recommended: 1
Reason: A rule on ward holds even when a session ignores the helper, and the cost is about 60 minutes.
Summary: The helper's recipient list only stops a session that uses the helper. Ward can enforce the same list for this one account at the RCPT stage.

Background: Auto mode will tell sessions to send only through the helper, but that's an instruction, not a lock. A session holding the app password could call SMTP itself. Stalwart's RCPT stage can test who signed in and refuse a recipient. The same stage governs all of ward's mail, so the plan proves the rule on a probe account and checks that inbound mail and the other accounts still pass.

Facts: Stalwart supports the rule, and ward has no RCPT rule today.
- Stalwart v0.16 sets the RCPT stage on `MtaStageRcpt`, whose rules can test `authenticated_as` (`https://stalw.art/docs/ref/object/mta-stage-rcpt`)
- A forum answer blocks one account's outbound recipients there, JMAP sends included (`https://support.stalw.art/t/how-to-block-outbound-email-address/1233`)
- Ward's Stalwart plan sets no `MtaStageRcpt` object (`servers/roles/stalwart/plan.ndjson`)

Choices:
- Ward refuses it: ward and the helper share one list, and a failed proof falls back to the helper alone with a backlog item [approve]
- The helper only: the runbook names the gap [approve]
- Send back: you change the design in your note [send-back]
