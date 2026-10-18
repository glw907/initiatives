# This packet approves the self-hosting pass plan, and approving starts Pass 0, which you and Claude run together.

Three reviews and two verification reads have tested the plan, and three questions remain yours.

## Background
The self-hosting design you approved on 2026-10-17 moves 907.life mail, photos, music, and passwords onto two Hetzner servers and Proton Pass. This plan splits it into nine passes: Pass 0 gathers every credential with you present, a workstation pass moves the scripts from 1Password to Proton Pass, and passes 1 to 7 build and cut over. Path minutes are the hands-on clock time along the longest chain of passes; calendar waits such as Hetzner's answer and T+30 aren't counted.

## If you approve
1. [session] Squash-merge glw907/initiatives#10, which files the plan, its reviews, and the fold records on main.
2. [session] Write STATUS and the Pass 0 checklist, and draft the port 25 request text.
3. [you: run Pass 0 with Claude] File the port 25 request first, then the accounts, tokens, and the permissions PR.

## Not checked
Every token's exact Cloudflare scope is proven only in Pass 0's dry run, which writes and reverts one change per token. The fold record lists eleven design corrections; ten change no ruling, and the last follows the rebuild ask.

## Ask: Should Claude test the household members' mailboxes itself?
Rule: owner-call
Part: none
Recommended: 1
Reason: It stays inside the rule that Claude reads only metadata, and it costs the household no time.
Summary: The finish line needs each of the four mailboxes to send and receive test mail. Claude can do it with the passwords it set, reading only the test messages' headers, or each member does it with you.

Background: The design's end-to-end check sends from and to each mailbox through a Gmail and an Outlook.com test account. Claude sets each member's Stalwart password before cutover and shares it with them through Proton Pass.

Facts: Claude would read only the test messages it sent, found by their message ids.
- C3 signs in, sends and receives one message per test account, reads those headers, and deletes the test messages by id with counts before and after (`self-hosting/plans/2026-10-17-self-hosting-plan.md`, "Rulings needed" 1)
- A member who changed their password before C3 gets the household session for their mailbox alone (same section)

Choices:
- Claude tests each mailbox: no household time, and only the test messages are read
- Each member tests with you: you report the results, and the cutover pass waits on that session

## Ask: Should 3,515 path minutes be the plan's line, with a ceiling of 5,273?
Rule: owner-call
Part: none
Recommended: 1
Reason: Recent passes all ran under plan, and these passes add live accounts and people to wait on, so 1.5 times leaves honest headroom.
Summary: The design named no estimate, so the plan sets one. Past the line the conductor keeps going and tells you; past the ceiling it stops.

Background: A clock stop pauses a task that runs past twice its estimate. The standing answer says what happens instead of pausing, so an unattended pass keeps moving.

Facts: The four recent passes with scores ran at 0.19 to 0.79 of their planned path.
- dubplate intake-1 0.79, dubplate admin-api-1 0.68, the approval-packets run 0.19, workstation #75 0.57 (`self-hosting/plans/2026-10-17-self-hosting-plan.md`, "Rulings needed" 2)
- None of those touched a live account or waited on a person (same section)

Choices:
- Line 3,515, ceiling 5,273: a task past twice its estimate extends once to four times, then stops and notifies you
- Line 3,515, no headroom: the conductor stops at the first pass close past the line, and each task stops at twice its estimate

## Ask: Who may turn off a production server's protection?
Rule: owner-call
Part: none
Recommended: 1
Reason: It keeps every guard on Claude's scripts whole, and the second operator still has a path when you can't be reached.
Summary: Hetzner ties rebuild protection to delete protection, and restoring a backup image is a rebuild. So rebuilding or image-restoring a production server needs someone to turn protection off first.

Background: The design lets Claude rebuild servers, puts delete protection on production, and fails the gate on any scripted protection change. Those three can't all hold. The mail rehearsal's image restore and the second operator's broken-mail screen both need protection off.

Facts: Hetzner's API requires the two flags to match, and an image restores only through rebuild.
- "currently delete and rebuild attribute needs to have the same value" (`docs.hetzner.cloud/cloud.spec.json`, server change_protection)
- Rebuild "overwriting its disk with the content of an Image ... (`backup` or `snapshot` Image)", and no separate restore action exists (`docs.hetzner.cloud/cloud.spec.json`, server rebuild)
- A project member "Can create, modify and delete all resources in the project", so the second operator can change protection in the console (Hetzner Cloud FAQ)

Choices:
- You and the second operator: you turn it off for Claude's rebuilds and the rehearsal restore, and his emergency screen tells him to turn it off, restore, and turn it back on
- You only: as above, but his emergency screen says to call you first
- Claude's rebuild script: it turns protection off and on itself, with one named exception to the gate and the deny rule

## Routine
| Part | Verdict | Fact | Why |
|---|---|---|---|
| glw907/initiatives:self-hosting/plans/2026-10-17-self-hosting-plan.md | approve | Every blocker and major from three reviews and two verification reads is closed in the plan text. | Your design rulings and both approval rulings bind it. |
| glw907/initiatives#10 | approve | `scripts/check` passes, and the PR files only records. | The record stays proposed until Pass 0 starts. |
| step:1 | session | A squash merge can be reverted. | Records only. |
| step:2 | session | STATUS is a self-merged hand-over. | Nothing is built yet. |
| step:3 | you | Pass 0 needs your logins, FIDO2 keys, and purchases. | It's the one long attended session. |
