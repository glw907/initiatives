# Scripted leg on 2.0.0-dev.6 (run 2611110255)

Graded **pass**. The first scripted run after cairn-cms #234 (merge `2a9fed671`, head `95ef34ab5`), on the snapshot
`create-cairn-site` 2.0.0-dev.6 and its six platform packages (tool.yml run 42947572055), with the engine at 0.99.0-dev.1. `latest` and
`next` did not move on either package.

## Result

- End state: the site answered 200 on `/` and `/admin`; the stand-in reached the admin at 02:58:59Z; the sign-in mail from
  `no-reply@gate.carin-test.org` reached the mailbox; launcher, platform packages, and engine match the candidate.
- Time: the tool's done screen says "Setup took 1:59". The scripted events run from 02:56:02Z to 02:59:05Z, about 3 minutes. The
  first deploy took 0.6 minutes to install, 0.3 to build, and 0.2 to deploy. The grade could not give the HTTPS wait or goal-to-sign-in
  time, since a scripted leg writes no setup events (a gap in the grader's scripted path, not in the tool).
- Screenshots: all 15 screens have a PNG, and the three read (welcome, watch, done) show the real terminal. #233's screenshot fix
  rendered junk; #234's `cat` of a `tmux capture-pane -p -e` file works. The footer `[khs] command exited 0` on each is the
  headless shot tool's line.
- Sweep: six targets deleted (repository, custom domain, Worker, database, bucket, App), none failed, none left on the address.

## Confound: the host's DNS changed

The three scripted runs that failed after #233 (2611110006, 2611110010, 2611110013) ran while this computer's resolver sent
every lookup to the home router, which dropped 447 of 87,007 (the 2611110013 stop was a cached negative answer). The conductor moved
the host to 1.1.1.1 and 1.0.0.1 over DNS-over-TLS at about 15:43 local on 2026-11-10 (workstation c253f4d), and the resolver cache was
flushed right before this leg. A pass here therefore does not show that #234's retry or authority wait fixed those stops: one run on a
healthy resolver shows only that the path works when DNS does. The retry and the authority wait have unit tests, and nothing live has
yet exercised them.

## Notes

- `run-gate.sh scripted` refused on a leftover `gnome-keyring-daemon` from an earlier session (2 processes, 2 h 15 min old) and did
  not name `cleanroom stop geoff`: BACKLOG #441, still open.
- I first graded the gate-state stub directory `…/cairn-gate/runs/<id>-scripted`, which holds no run files, and got a meaningless
  `fail`. The grade reads the run dir the launcher prints (`/var/tmp/cleanroom/<id>/run`). The two names invite the mistake.
- My Monitor on the run's files stayed silent for 20 minutes because `cut` in the pipe did not flush per line. `grep --line-buffered`
  alone would have delivered `done` within seconds.
- This leg did not exercise the dead-tab mail sign-in (#233): the stand-in signed in through the browser. Round eight is its first
  live proof.
