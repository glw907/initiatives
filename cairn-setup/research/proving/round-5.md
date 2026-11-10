# Proving round 5

Run `2611100930` (naive), 2026-11-10 UTC, on the engine `0.99.0-dev.1` and the launcher `2.0.0-dev.2`. The
docs were cairn-cms `6bd08160a` (rounds one to three merged). The harness ran from the worktree at
`80fb183f2`, which carried #222's install-button fix before it merged. The conductor ended the run as a stall
at about 10 minutes, about $0.23 on the subscription token, with nothing created.

## What happened

The agent read the docs, then used an interactive question dialog to ask the owner for the site name, owner
email, AI crawler posture, and domain. The owner answered each from the card; the domain was the subdomain
`gate.carin-test.org`, as in round four, because the apex holds mail records (#430), a deviation from the card's
bare address. A permission prompt for a dry run with a `$TMPDIR` variable was answered "Yes" once. The agent
stopped to ask the owner to run setup in a terminal, and after the owner asked it to try, it ran `cd
$TMPDIR/site && npx create-cairn-site --plan ...`. The `cd` in the same call kept the whole call sandboxed:
no setup token, so a Cloudflare approval, and an approval page on a localhost the owner's browser cannot reach.
The round-three docs line that says to run the call from an empty folder had pushed the agent to `cd`.

## Friction the agent met

1. The agent combined `cd` and `npx` in one call, which the sandbox runs sandboxed. Fixed in
   glw907/cairn-cms#223: the page and the skill say to change folder in a separate call first.
2. The agent asked the owner to run setup before it tried (#427, still open).
3. The agent used a question dialog for the owner's answers. The card's answers fit it, and the owner had to
   type the free-text answers into its `Type something` row. No fix needed; the harness note is below.

## Flailing

- A question about the docs put to the owner: yes, item 2.
- A command repeated after it failed: no.
- A file or page read three times: no.
- Three or more permission prompts: no, one.

## Harness items

1. An agent that asks with a choice dialog is answered with keys, not text: the number selects an option, and
   the `Type something` row takes free text. The conductor's skill (a held path) does not say so; the note
   waits for a held-path PR.
2. `cleanroom stop` still leaves the stand-in session running (#435); I ended it by hand.
3. The run's sweep dry run after it lists nothing.

## Reading against the three candidate speed fixes

No reading again: the run never reached a deploy. Not taken.

## Time against the last run

| Step | This run | Last run | Change |
| --- | --- | --- | --- |
| Goal prompt to the stop | about 10 minutes (conductor stall) | 20.5 minutes (conductor stall) | not comparable |
| First approval | the Cloudflare approval, unreachable | the stand-in followed the GitHub steps | worse |
| First deploy | not reached | not reached | none |
| HTTPS wait | not reached | not reached | none |
| Goal prompt to signed in | not reached | not reached | none |

## Budget

Five naive runs of ten, $1.70 together; the whole ledger, probes and the earlier prototype included, reads
$9.29 of the $100.
