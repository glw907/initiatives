# Proving round 1

Run `2611100628` (naive), 2026-11-09 and 2026-11-10 UTC, on the dev snapshot `0.99.0-dev.1` (engine) and
`2.0.0-dev.1` (launcher and platform packages), cairn-cms `f105b9fba`. The conductor ended it as a stall
after about 10 minutes at the first approval, and it cost about $0.22 on the subscription token. All four
end-state checks failed: no site was created, so nothing was live, no owner signed in, no sign-in mail
arrived, and the engine read is empty. The record is `run-record.md` in the run directory.

## What happened

The agent read the README and the agent page, ran the dry run, and then stopped and asked the owner to pick
between running setup in the owner's terminal and starting a session that allows unsandboxed commands. It
had not tried the command. After the owner asked it to try, it ran `npx --yes create-cairn-site new --plan`
and then `npx --yes create-cairn-site --plan`. The `--yes` kept both calls out of the sandbox exclusion, so
they ran sandboxed: the setup token was not in their environment, setup fell back to the Cloudflare
approval, and the approval tab listened on a localhost the owner's browser cannot reach. The relay that
feeds the stand-in never saw a URL, so nothing followed the tab. The agent printed the link and asked the
owner to open it.

## Friction the agent met

1. The agent added `--yes` before the package name, which kept the call sandboxed: no setup token, a
   private localhost, and a Cloudflare approval nobody could give. Fixed in glw907/cairn-cms#216 (the agent
   page, the setup skill, and the copy in the binary say to put no npx option before the name).
2. The agent could not tell how to run `cairn` outside the sandbox, stopped, and asked the owner to choose
   between two options, which cost two owner turns. Filed as cairn-cms #427 (glw907/cairn-cms#218).
3. The agent ran the dry run with a `cd` prefix, which the page says not to do, and tried a `new`
   subcommand before the form the page shows. Both were harmless. Covered by #216's wording; no separate item.

## Flailing

- A question about the docs put to the owner: yes, item 2 above. Filed as #427.
- A command repeated after it failed: no. The two `--plan` calls differ and the first did not fail.
- A file or page read three times: no. The grader flagged three reads of one path, and the transcript lines
  it cites (89, 98, 103) are the agent polling a background task's output file, not rereading a document.
- Three or more permission prompts: no. The agent met none.

## Harness items

1. `run-gate.sh grade` crashed after writing the record, with `EACCES` deleting the home's keyrings, which
   the `cleanroom` user owns. Fixed in glw907/cairn-cms#217 (`grade` reports it and finishes). A real
   removal needs a `cleanroom` step: filed as #428 (glw907/cairn-cms#218).
2. The fast lane selected no `test:emit` for a change under `plugins/`, so a skill edit that named a flag the
   tool lacks reached CI red. Filed as #429 (glw907/cairn-cms#218); #216 fixed that instance.
3. The probe could not express the plan's live items. The probe list gained the launcher items instead
   (glw907/workstation#217), and `cleanroom-probe-2.md` records the result.
4. Owner answers sent with `tmux send-keys` need the text and the Enter key in two calls, since one call
   left the text unsent twice. The proving skill is a held path, so the note waits for a held-path PR.
5. `bump.mjs` dropped its version argument and moved the launcher's lockfile entry: #425 and #426
   (glw907/cairn-cms#218), found at the first cut.

## Reading against the three candidate speed fixes

- Connecting the domain while the first deploy runs: no reading. The run stopped before setup created
  anything, so no deploy or HTTPS time exists. Not taken.
- Shipping a lockfile in the template: no reading, for the same reason. Not taken.
- Shortening the agent's path: the record shows about eight tool calls before the first `--plan` and a stop
  to ask the owner, and the stop is the cost. #216 and #427 address the stop; the path itself is short.
  Taken as those two fixes, not as a change to the README.

## Time against the last run

There is no earlier run, so the table is empty.

| Step | This run | Last run | Change |
| --- | --- | --- | --- |
| Goal prompt to the first approval | about 10 minutes | none | none |
| First deploy | not reached | none | none |
| HTTPS wait | not reached | none | none |
| Goal prompt to signed in | not reached | none | none |

## Budget

One naive run of ten, about $0.22 of the clean room's spend. The ledger is
`/var/tmp/cleanroom/ledger.jsonl`.
