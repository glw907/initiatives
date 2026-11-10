# Proving round 3

Run `2611100806` (naive), 2026-11-10 UTC, on the engine `0.99.0-dev.1` and the launcher `2.0.0-dev.2`,
cairn-cms `2822e5ebe`, with the watcher fix from glw907/workstation#218 stowed. The conductor ended it as a
stall after about 9.3 minutes, at about $0.35 on the subscription token. All four end-state checks failed
because no site exists. The record is `run-record.md` in the run directory.

## What happened

The agent cloned the cairn-cms repository into its work folder to read the docs, stayed in the clone, and
ran `npx create-cairn-site new --dry-run`, then `npx create-cairn-site --dry-run`. Both failed at once with
`create-cairn-site: command not found`, exit 127. The npm debug log shows why: `npm exec` ran with its working
directory inside the clone, matched the name against the clone's `packages/create-cairn-site` workspace,
which is not installed, and exited before it fetched anything. The tag was not at fault: a sandboxed
`npm view create-cairn-site version` in the same run printed `2.0.0-dev.2`. The agent took the failure for a
resolution problem, asked for `create-cairn-site@latest` (the retired 0.99 wizard, which printed "Retired:
this wizard writes secrets to disk" and `Unknown option '--help'`), concluded that the plain name meant the
wizard, pinned `@gate`, and added `-y`:
`npx -y create-cairn-site@gate --plan ...`. That call matched no sandbox exclusion, so it ran sandboxed, setup
printed an approval link on a localhost the owner's browser could not reach, and the agent asked the owner to
change the sandbox settings or run the command in a terminal. The owner nudged it twice (the card says to
answer from the card and a reasonable owner's answer for the rest): once to try it as the docs show, and once
to run the plain command with no extra options and no version or tag. The agent still judged the plain name to
be the retired wizard, said it could not go further, and the conductor ended the run.

## Friction the agent met

1. A plain `npx create-cairn-site` run from inside a clone of the cairn-cms repository fails with `command
   not found`, because `npm exec` matches the local project's uninstalled package of the same name first. The
   agent misread that as a wrong-candidate problem. Fixed in glw907/cairn-cms#221: the agent page and the setup
   skill say to run the call from an empty folder. #433 now asks only for a probe item that fails if either
   side of the sandbox resolves the retired wizard (glw907/workstation#220).
2. The agent wrote `new` after the name in its first call, as round one's agent did, so the launcher ran
   `cairn new new`. Fixed in the agent page and the setup skill (glw907/cairn-cms#221 says no `new` after the
   name); the launcher tolerance is filed as #434 (same PR).
3. The agent added `-y` and a `@gate` tag, each of which takes the call out of the sandbox exclusion. The page
   named `--yes` and not `-y`, and said nothing of a tag. Fixed in the same paragraph (#221).
4. The agent still asked the owner whether to run outside the sandbox before it tried. Open as #427.

## Flailing

- A question about the docs put to the owner: yes, item 4 and the sandbox choice that followed.
- A command repeated after it failed: yes, mildly. It ran the dry run twice in the plain form and a third time
  pinned, each after a failure whose cause (item 1) the output did not make plain.
- A file or page read three times: no.
- Three or more permission prompts: no.
- The conductor's two owner nudges are recorded here as owner help, and a run that needs them is not a pass.

## Harness items

1. The watcher fix held: the run was stopped by the conductor and not by the statusline rule.
2. `grade` finished with the keyrings message, as round one's fix intends.
3. The probe list now fails if a launcher call reaches the retired wizard, in the sandbox or out of it, and no
   longer hard-codes a version (cairn-cms #432 and #433; glw907/workstation#220). The probe passes on it, 37
   of 37 items, on the unchanged template.
4. The plan's stop "`npm create cairn-site` resolves `latest` despite `npm_config_tag`" was checked and is not
   met: the tag reaches a sandboxed call, and no wrong candidate ran. The record stays `fail, stall`.

## Reading against the three candidate speed fixes

No reading for the first two fixes: no run has reached a deploy. For the third, the agent's path to the first
setup call was short, and the cost was in the stops and the failed launcher calls, not in the number of reads. Not taken.

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
