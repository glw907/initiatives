# Proving round 7

Run `2611102302` (naive), 2026-11-10 UTC, on the published snapshot: engine `0.99.0-dev.1`, launcher and platform
`2.0.0-dev.5`, cairn-cms `00f1aec44` (the pre-pass #231 and the driver fix #232 merged). Graded `fail, page`: setup
finished, and the stand-in died before it could sign the owner in. About $0.36 on the subscription token, 4.9 minutes from
the goal prompt to a finished site. Swept clean. This is the first naive run to reach a deploy.

## What happened

The agent cloned the repository and read the setup guide, then stopped and asked the owner how to run outside the sandbox,
saying its session had `dangerouslyDisableSandbox` turned off. The clean room sets `allowUnsandboxedCommands: false`, so that
was true. After the owner's answers from the card (and "try it the way the docs show"), it ran the dry run and the plan as bare
calls from an empty folder, and both ran outside the sandbox through the exclusion list with the token (`credential: token`).
It told the owner setup was using the token and asked for a go-ahead on the plan, which the owner gave. It followed "leave the
new address alone": no `curl` or `dig`. Plan then apply finished the site: `GET /` and `GET /admin` answered 200, the sign-in mail
from `no-reply@gate.carin-test.org` reached the mailbox, and the versions matched. The agent could not sign in, and the stand-in
had already stopped.

## Friction the agent met

1. The agent asked the owner how to run outside the sandbox before it tried (#440; the earlier #427 closed in #231). The pre-pass
   docs led with the retry parameter, which this room switches off, so the agent read that it could not. Fixed in #233: the bare call
   comes first, an exclusion is what lets it out, the retry is the fallback.
2. The agent did not visit the address to check the site after setup, because the guidance said to leave it alone until the
   `summary` event and the agent treated it as a standing rule. Fixed in #233: visit it once the event arrives.
3. A grader read, `cairn new status`, exited 1 (npm's ETARGET without the gate tag). Harness. Fixed in #233 (#444).

## Flailing

- A question about the docs put to the owner: yes, item 1.
- A command repeated after it failed: no.
- A file or page read three times: no.
- Three or more permission prompts: no, none (the grader's prompt list is empty).

## Harness items

1. The stand-in followed the one tab `--plan` opens. The tab's server goes with the plan and `--apply` opens none, so the stand-in
   sat on a dead page for its 2-minute limit (23:04:24 to 23:06:27 UTC) and wrote `failed`. No naive run could pass its end state
   until it signs in by mail after apply. Fixed in #233 (#442).
2. Every per-screen screenshot of every scripted run was the error text "server exited unexpectedly": the headless terminal ran
   `/usr/bin/tmux` 3.5a against the leg's Homebrew 3.8 server. T3.4's screenshots were never real before. Fixed in #233 (#443), checked by the
   next scripted run.
3. The three GitHub `waiting` sentences counted as missed relays though the stand-in cleared each within 0 to 12 seconds. Fixed in
   #233 (#444).
4. A fresh scripted run refused on four leftover `gnome-keyring-daemon` processes; `cleanroom stop geoff` cleared them (#441).

## Reading against the three candidate speed fixes

The first deploy, reached for the first time in a naive run, took install 0.6, build 0.3, and deploy 0.4 minutes. The HTTPS wait is
missing: the grader found no finished `domains` step in the setup events, so it cannot time it. There is no reading of the
three fixes yet, and none is taken.

## Time against the last run

| Step | This run | Last run | Change |
| --- | --- | --- | --- |
| Goal prompt to the first plan call | about 1.5 minutes | about 5 minutes | faster |
| Opening and Cloudflare checks | under a second each | refused at the checks | better: the apex and subdomain fixes |
| GitHub steps | 0.3 minutes, three approvals | not reached | new |
| First deploy | 1.3 minutes (install 0.6, build 0.3, deploy 0.4) | not reached | new |
| HTTPS wait | not measured | not reached | none |
| Goal prompt to signed in | not signed in; setup finished at 4.9 minutes | not reached | none |

## S-2 evidence (the narrow sandbox exclusion)

The four exclusion patterns (`cairn *`, `npm create cairn-site`, `npm create cairn-site -- *`, `npx create-cairn-site *`) matched the
agent's bare calls and ran them outside the sandbox with no prompt. The token reached only those calls. The agent made no call
outside the exclusion list and raised no unsandboxed prompt (prompts: []). What it did not show: the agent never tried an
unsandboxed retry, because the parameter is off in this room, so the exclusion list is the only path here. The cost to the owner was
one question turn. The leak scan and the denied-name scan are not part of this grade.

## Budget

Seven naive runs of ten (three remain); the round's clean-room cost was about $0.36, and the whole ledger reads about $10.3 of the $100.
The ledger is `/var/tmp/cleanroom/ledger.jsonl`.
