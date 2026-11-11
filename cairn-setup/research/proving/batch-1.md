# Batch 1: naive runs on dev.8

One row per run. The naive leg ends at the first graded pass (the plan's reorder, on Geoff's word that a single successful naive run
is enough). Candidate under test: create-cairn-site and the six platform packages 2.0.0-dev.8 on `gate`, engine 0.99.0-dev.1.

| Run | Overall run | Started (AKST) | Agent | Goal to signed in | Cost | Graded | Cause |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 2611110726 | 9 of 15 | 22:26 | Sonnet 5.5, medium | 6.5 min | $0.32 | fail, other | Two grader gaps; the product worked (PR #238) |
| 2611110815 | 10 of 15 | 23:15 | Sonnet 5.5, medium | 3.8 min | $0.31 | fail, other; regraded pass | First grade: the registry read was killed by the room's own stop (exit 241). Regrade on the intact room: pass |

The naive leg ends with run 10: the first graded naive pass.

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


## Run 2611110815

The agent set the site up, the stand-in signed in as owner, and the regraded record is a pass: live (`/` and `/admin` 200), owner
signed in (08:19:46Z), sign-in mail received, launcher, platform package, and engine pin matching the candidate. Goal to signed in
3.8 minutes (agent 3.6, provider wait 0.2); first deploy install 0.6, build 0.5, deploy 0.3; HTTPS wait 0.2. Cost about $0.31. It ran
on the grader from #238 (merge 42f5573fb), which read the apply's events and the registry record correctly.

### What the agent did

1. Cloned the repository, read the docs, and asked the owner the same four questions as a form. I answered from the card.
2. Ran the dry run, then `--plan plan.json` bare in the background. It told the owner the first GitHub approval was waiting and
   quoted the sentence ("Select Create GitHub App to add the App for Cairn gate 2611110815. The admin saves changes to your site
   through the App."). The stand-in had already made the App and both installs within twelve seconds, so the agent's wait was stale
   when I read it.
3. Read the plan and showed the plan table, asking for a go-ahead to apply. My reply, "I've approved that in the browser. Keep
   going.", crossed with that question, and the agent took it as the go-ahead. It ran `--apply plan.json` bare in the background,
   read the end of its output with `tail`, reported the site created and the sign-in emailed, and said it would not handle the link.
4. The stand-in read the mail and opened the link at 08:19:46Z.

No permission prompt appeared. The calls that ran in the sandbox were a `tail` and `cat` of the plan and a `tail` of the apply
output; no unsandboxed prompt came up, so the conductor's rule for them was not tested. This run also used the token mode.

### Two grades

The first grade failed: `read registry record failed: exited 241`, with every end-state check ok. The cause is a race in the
harness. Exit 241 is `sys.exit(-15)` as an unsigned byte, a SIGTERM to the `cleanroom shell` bash. The room's watcher ticks every 15
seconds; when the session's main window is gone it records `exited` and then calls `stop`, which sends SIGTERM to every process of
the room. State recorded `exited` at 23:19:57 and the grader wrote its record at 23:20:01, so the grader's first read inside the room
(the registry record, which is now the first `cleanroom shell` call) ran while that kill was in progress. The same read exits 0
before and after: the conductor ran it at about 23:25 and so did I. Run 2611110726 shows the race from the other side: its record was
written at 22:33:14 and its state flipped to `exited` at 22:33:17, so its grader finished first.

The conductor ruled that a harness race does not count against cairn, and that the run is regraded once on its intact room before
the sweep. The regrade, on the unchanged evidence (the site still answered 200 and the room held the record), is a pass. Both
records are kept: the first in the job's scratch, the second as the run's `run-record.md`. A fix for the race (the grade waits for
the room's state to leave `running` and the stop to finish, or the read retries once on a signal exit) goes in a small harness PR
for the end packet; it does not block.

The record's step table is short (opening-checks, approve-cloudflare, cloudflare-checks, domains, sign-in) because this agent read
only the last lines of the apply's output, so only those events are in the transcript. The grader still has the HTTPS wait and
the sign-in step it needs. A grader that wants the full table would read the event log from the room's task output, not the
agent's reads of it.

### Friction and flailing

None from the agent. Two harness items: the race above, and the grader's step table, which reflects what the agent chose to read.

## For the end packet

- **The watcher match, on a real room.** The grade's wait for `cleanroom _watch <run id>` (cairn-cms#239, cf0941497) was checked
  against a real process with the same argument shape, not against a live room's watcher. The first live room that is graded shows
  whether the match works: the record's reads should list `room settled` as ok, and a grade that starts right after the session ends
  should no longer fail a read with exit 241.
- **The done screen and the Cloudflare grant** (BACKLOG #461). A canary showed that setup's revoke kills the tokens (the access token
  answers 403 after revoke, the refresh token is refused) while Cloudflare keeps the grant "cairn" listed in Connected Applications
  until the owner removes it. The done screen should say where: My Profile, Access Management, Connected Applications. The 907.life
  walk-through already tells Geoff.
- **Optional, from run 10:** the record's step table lists only the events an agent happened to read, so a run where the agent
  reads the end of the apply output shows a short table. The timing it needs is complete. Reading the event log from the room's task
  output would give the full table.
