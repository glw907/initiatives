# Proving round 3

Run `2611100806` (naive), 2026-11-10 UTC, on the engine `0.99.0-dev.1` and the launcher `2.0.0-dev.2`,
cairn-cms `2822e5ebe`, with the watcher fix from glw907/workstation#218 stowed. The conductor ended it as a
stall after about 9.3 minutes, at about $0.35 on the subscription token. All four end-state checks failed
because no site exists. The record is `run-record.md` in the run directory.

## What happened

The agent read the docs and ran `npx create-cairn-site new --dry-run`, then `npx create-cairn-site
--dry-run`. Both answered with the retired 0.99 wizard's "Retired: this wizard writes secrets to disk"
notice and `Unknown option '--help'`, though the run sets `npm_config_tag=gate` and round two's plain call
resolved the 2.0 launcher. The agent looked up the dist-tags, pinned `@gate`, and added `-y`:
`npx -y create-cairn-site@gate --plan ...`. That call matched no sandbox exclusion, so it ran sandboxed, setup
printed an approval link on a localhost the owner's browser could not reach, and the agent asked the owner to
change the sandbox settings or run the command in a terminal. The owner nudged it twice (the card says to
answer from the card and a reasonable owner's answer for the rest): once to try it as the docs show, and once
to run the plain command with no extra options and no version or tag. The agent still judged the plain name to
be the retired wizard, said it could not go further, and the conductor ended the run.

## Friction the agent met

1. A plain `npx create-cairn-site` resolved the retired wizard in this run and the 2.0 launcher in round two.
   The cause is unread. Filed as cairn-cms #433 (glw907/cairn-cms#221).
2. The agent wrote `new` after the name in its first call, as round one's agent did, so the launcher ran
   `cairn new new`. Fixed in the agent page and the setup skill (glw907/cairn-cms#221 says no `new` after the
   name); the launcher tolerance is filed as #434 (same PR).
3. The agent added `-y` and a `@gate` tag, each of which takes the call out of the sandbox exclusion. The page
   named `--yes` and not `-y`, and said nothing of a tag. Fixed in the same paragraph (#221).
4. The agent still asked the owner whether to run outside the sandbox before it tried. Open as #427.

## Flailing

- A question about the docs put to the owner: yes, item 4 and the sandbox choice that followed.
- A command repeated after it failed: yes, mildly. It ran the dry run twice in the plain form and a third time
  pinned, each after the retired wizard rejected the flags; the cause is item 1, not the agent.
- A file or page read three times: no.
- Three or more permission prompts: no.
- The conductor's two owner nudges are recorded here as owner help, and a run that needs them is not a pass.

## Harness items

1. The watcher fix held: the run was stopped by the conductor and not by the statusline rule.
2. `grade` finished with the keyrings message, as round one's fix intends.
3. The probe's launcher check passes with a plain `npx` in the probe but a plain `npx` resolved the wrong
   package in this run. A resolved-version check in the probe is the next step (#433).

## Reading against the three candidate speed fixes

No reading for the first two fixes: no run has reached a deploy. For the third, the agent's path to the first
setup call was short, and the cost was in the stops and the wrong package, not in the number of reads. Not taken.

## Time against the last run

| Step | This run | Last run | Change |
| --- | --- | --- | --- |
| Goal prompt to the stop | 9.3 minutes (conductor stall) | 9.8 minutes (watcher stop) | none worth reading |
| First approval | the Cloudflare approval, unreachable | none: the token replaced it | worse |
| First deploy | not reached | not reached | none |
| HTTPS wait | not reached | not reached | none |
| Goal prompt to signed in | not reached | not reached | none |

## Budget

Three naive runs of ten, about $0.93 together. The ledger is `/var/tmp/cleanroom/ledger.jsonl`.
