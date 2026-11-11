# Batch 1: naive runs on dev.8

One row per run. The naive leg ends at the first graded pass (the plan's reorder, on Geoff's word that a single successful naive run
is enough). Candidate under test: create-cairn-site and the six platform packages 2.0.0-dev.8 on `gate`, engine 0.99.0-dev.1.

| Run | Overall run | Started (AKST) | Agent | Goal to signed in | Cost | Graded | Cause |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 2611110726 | 9 of 15 | 22:26 | Sonnet 5.5, medium | 6.5 min | $0.32 | fail, other | Two grader gaps; the product worked (PR #238) |

## Run 2611110726

The agent set the site up and the stand-in signed in as owner. All four end-state checks passed: `/` and `/admin` answered 200, the
owner reached the admin, the sign-in mail arrived, and the installed launcher, platform package, and engine pin matched the candidate.
The grader still failed the run, for two reasons that belong to the harness and not to cairn. Neither had shown before: round 7 finished a setup too, but its stand-in
failed on a dead page, and the grader settles that cause ahead of the checks that carry these two gaps. This is the first naive run
to sign in as owner.

### What the agent did

1. Cloned the repository, read the README and the agent page, and asked the owner four questions as one form: site name, owner email,
   AI crawlers, host. I answered from the owner card (the card's address for the host).
2. Ran the dry run, then `--plan plan.json` as a bare background call, then showed the plan table and asked whether the owner address
   was right and whether to apply. I said yes.
3. Ran `--apply plan.json` as a bare background call. It finished with exit 0 in about two minutes. The agent checked the site with
   `curl` (home 200, `/admin` redirecting to `/admin/login`), told the owner the sign-in link had been emailed, and said it would not
   handle the link.
4. The stand-in read the sign-in mail and opened the link at 07:32:57Z, and reached the admin a second later.

No permission prompt appeared, no unsandboxed prompt, no command was repeated after failing, and the agent put no question to the owner
beyond the card. This run used the token mode (the clean room carries a setup token in the environment), so the Cloudflare approval was
skipped. The no-token path is proved by the rehearsal and by the live setup, not by this run.

### Why the grader failed it

The record said: "timing check failed: the HTTPS wait is missing: no finished domains step in setup events; read registry record failed:
no registry record under .config/cairn/sites."

1. The grader reads setup's events from tool results in the transcript, and it kept only lines that begin with a brace. The agent read
   the apply's output with its Read tool, which prints each line behind a line number and a tab, so the events from `scaffold` through
   `domains` and `sign-in` were skipped. They are in the transcript: 38 events, the `domains` step done in 0.2 minutes.
2. The registry directory (`~/.config/cairn`) in the clean home is 0700 and owned by the clean room's user. The grader runs as the
   outside user, so its directory listing was refused and read as "no record". The record exists (step `live`, with the repository
   named). My first account of this said a finished setup deletes the record; that was wrong, and the conductor's trace of the
   permission denial was right.

Fixed in glw907/cairn-cms#238 (the grader strips a leading line number, and reads the record through `cleanroom shell` as the clean
room's user), with the failing tests committed first. The resources of run 2611110726 were swept the same night (repository, custom
domain, Worker, database, bucket, App: six deleted, none failed). Run 2611110726 is not regraded: its site is gone, and the plan's
ruling for a harness failure is to rerun on the same build.

### Friction and flailing

None from the agent. One item for the grader PR's planning-miss note: a grader failure on a read is traced to the error the read
returned before the cause is named.
