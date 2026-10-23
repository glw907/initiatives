# Bulwark webmail plan

You approved the Bulwark design this evening (initiatives#114). Planning checked it against Bulwark 1.17.1 and Stalwart 0.16.27 source, and three reviews, a fold, and a verification read rebuilt several mechanisms. Two changes weaken protections the design promised, so they come to you as rulings. The rest stayed inside the design.

Approving launches one pass, `servers-bulwark`, under `conductor-servers`. Phase A starts now, beside `servers-backlog-2`, and builds the role, the theme, the session secret, and the runbook with no live change. Phase B waits for the conductor's "applies done" after backlog-2 merges, then makes the live changes: DNS, ward's Stalwart settings, Bulwark on orpheus. Then come the end-to-end sign-in check and the visual gate against Survey's specimen. The path is 525 minutes against the design's 300, under the 600-minute line, so the standing answer keeps it launching. Two PRs come back in one packet.

Corrections inside the design: Stalwart's CORS is all or nothing; stock Caddy can't throttle, so Bulwark's own sign-in budget does; the theme ships in Bulwark's installed form; the first page a browser sees is stock Bulwark until its first sign-in. Survey's second accent has no hook in Bulwark; the update check is off, and translation and sender icons, which send data to third parties, are closed. Sign-in offers an unticked "Remember me".

## If you approve
1. [session] Commit your two rulings to the plan, then merge glw907/initiatives#115, which files the plan, its reviews, the prompts, and this packet.
2. [session] Hand the pass to `conductor-servers`, which launches phase A.
3. [you: read the pass's packet] Read and decide the two PRs when their packet arrives.

## Not checked
Whether the theme survives Bulwark's own settings screen on a member's first sign-in; T7's theme probe measures it, and a miss goes to the upstream issue.

## Ask: Keep the orpheus allowlist on ward?
Rule: owner-call
Part: glw907/initiatives#115
Recommended: 1
Reason: Without it, wrong passwords from anyone can ban orpheus for a day and take webmail from both of you; the mailbox passwords are generated, so the guessing it allows is impractical.
Summary: Bulwark checks every password from orpheus, so Stalwart's auto-ban would count every webmail typo against orpheus. Allowlisting orpheus prevents that, but lifts Stalwart's sign-in limits for everything on orpheus.

Background: Stalwart bans an address for 24 hours after about 100 failed sign-ins a day. Its option to trust a proxy's forwarded address is global, so any client could fake one. The design's Caddy throttle needs a plugin stock Caddy lacks.

Facts: With the allowlist, Bulwark's budget, 10 tries per address per 15 minutes, is the only limit on the webmail path.
- An allowed address skips the per-address and per-account counts (`crates/common/src/network/security.rs:298-309`)
- Forwarded-header trust is global (`crates/http/src/request.rs:749-775`)
- Bulwark's budgets (`lib/auth/verify-budget.ts:16-23, 113-117`)

Choices:
- Keep it: webmail can't be banned, and distributed guessing gets 10 tries per address per 15 minutes; undone by two plan lines [approve]
- Drop it: Stalwart's limits stay whole, and about 100 wrong passwords a day from anywhere take webmail away for 24 hours [approve]

## Ask: Accept the ban risk the CORS switch opens?
Rule: owner-call
Part: none
Recommended: 1
Reason: It takes a page aimed at this household and costs a day it can recover with the unban step on the emergency screens; a shorter ban weakens it for attackers too.
Summary: Bulwark's browser calls Stalwart directly, which needs Stalwart's one CORS switch. With it on, any web page a household member opens could send wrong passwords from their browser and get their home address banned for a day.

Background: CORS is the browser rule that decides which sites may call a server. Stalwart can only allow every site or none. Another site still can't read mail without a password it already has.

Facts: The switch sends a wildcard origin with no credentials, and ward sends no CORS header today.
- The switch's headers, and ward's preflight probed 2026-10-23 (`crates/common/src/config/network.rs:404-427`)
- The ban length is 24 hours (`roles/stalwart/plan.ndjson:6`)

Choices:
- Accept it: record the risk, and name the cause in the runbook's unban step
- Shorten bans to one hour: the same risk costs an hour, and every attacker's ban is an hour too

## Routine
| Part | Verdict | Fact | Why |
|---|---|---|---|
| step:1 | session | Each ruling's other answer is written out in the plan. | The plan builds whichever you pick. |
| step:2 | session | The conductor agreed to the phase split and its conditions. | Phase A makes no live write. |
| step:3 | you | The pass is `auth-data` and `live-account`. | Nothing merges unread. |
