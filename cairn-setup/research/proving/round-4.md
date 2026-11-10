# Proving round 4

Run `2611100859` (naive), 2026-11-10 UTC, on the engine `0.99.0-dev.1` and the launcher `2.0.0-dev.2`,
cairn-cms `6bd08160a` (rounds one to three merged). The conductor ended it as a stall at about 20.5 minutes,
about $0.50 on the subscription token. It is the first run to create anything: setup created the site's GitHub
repository and the GitHub App, and stopped on the App's install permissions page. All four end-state
checks failed because no site was deployed. The record is `run-record.md` in the run directory.

## What happened

The agent cloned the repository to read the docs and ran the dry run and the plan call bare, from the work
folder and not from inside the clone, with no option before the name, so both ran outside the sandbox. Setup
reported `credential: token`: no Cloudflare approval. The agent still stopped first to ask the owner which way
to run setup (it asked before it tried), then wrote the plan, asked the owner to confirm the account and the
token, and ran `--apply`. Setup stopped at its Cloudflare checks because `carin-test.org`'s bare address has
DNS records (the open product call, cairn-cms #430), and the owner, who knows the apex holds mail records,
gave the subdomain `gate.carin-test.org`. That deviates from the card's bare address. The second apply passed
the address check, and the stand-in followed the GitHub steps: account prompt, create App, install. GitHub
then showed the install permissions page, whose button reads "Approve, Install, & Authorize". The stand-in
matches `^install` and found no control, so it saved a screenshot and a controls list and ended. Nothing in
`stand-in.jsonl` said so, and the run waited about twelve minutes at setup's `repo-created` step before the
conductor looked.

## Friction the agent met

1. The agent asked the owner which way to run setup before it tried the command. Still open as #427. The
   empty-folder and no-tag lines worked: no wrong-package failure this run.
2. The agent asked the owner to confirm a token it had not set. Open as #431.
3. Setup refused the bare address because of its mail records. Open as #430, Geoff's call; the owner chose a
   subdomain to go on.

## Flailing

- A question about the docs put to the owner: yes, item 1.
- A command repeated after it failed: no. The two apply calls differ: the second followed the plan edit.
- A file or page read three times: no.
- Three or more permission prompts: no.

## Harness items

1. The stand-in's install button name did not match GitHub's permissions page. Fixed in
   glw907/cairn-cms#222 (`INSTALL_BUTTON` matches "Approve, Install, & Authorize" and "Install").
2. The stand-in ended on a page without any line in `stand-in.jsonl`, so the run's watcher saw nothing.
   Fixed in the same PR: it appends a `failed` line.
3. The sweep's apply ran live for the first time and deleted the run's repository and App with no failure
   (`2 target(s), 0 failed`), and a dry run after it listed nothing.
4. `grade` printed the keyrings message and finished, as intended.
5. Three stand-in processes from earlier rounds were still alive, each tailing its old run's URL log; I
   stopped them by hand. `cleanroom stop` does not end the stand-in, which the gate starts. Filed as cairn-cms
   #435 (glw907/cairn-cms#222), together with ending a run when the stand-in does.

## Reading against the three candidate speed fixes

Still no reading: the run stopped before the first deploy, so there is no install, build, or deploy time and
no HTTPS wait. The record's step times show setup's early checks at under a second each. Not taken.

## Time against the last run

| Step | This run | Last run | Change |
| --- | --- | --- | --- |
| Goal prompt to the first apply | about 6 minutes | not reached | first reading |
| Opening and Cloudflare checks | under a second each | not reached | first reading |
| GitHub steps | 6 seconds from account prompt to install, then the failed page | not reached | first reading |
| First deploy | not reached | not reached | none |
| HTTPS wait | not reached | not reached | none |
| Goal prompt to signed in | not reached | not reached | none |

## Budget

Four naive runs of ten, about $1.47 together; the whole ledger, probes and the earlier prototype included,
reads $9.05 of the $100. The ledger is `/var/tmp/cleanroom/ledger.jsonl`.
