# Scripted leg on 2.0.0-dev.7 (run 2611110458)

Graded **pass**. The first scripted run after cairn-cms #235 (merge `6ddcf7102`), on the snapshot `create-cairn-site` 2.0.0-dev.7 and
its six platform packages (tool.yml run 42960355126), engine 0.99.0-dev.1. `latest` and `next` did not move. The conductor's rule for
this leg: #235 changes four harness files the leg exercises, so the leg runs even though no tool code changed beyond text.

## Result

- End state: the site answered 200 on `/` and `/admin`; the stand-in reached the admin at 05:01:40Z; the sign-in mail from
  `no-reply@gate.carin-test.org` reached the mailbox; launcher and platforms 2.0.0-dev.7 and the engine match the candidate.
- Time: the done screen says "Setup took 2:29" (dev.6's leg said 1:59); the first deploy took 0.6 minutes to install, 0.6 to build, and
  0.6 to deploy. Setup sat on "Connect gate.carin-test.org" (Cloudflare issuing the HTTPS certificate) for most of the extra half minute.
  The grade still gives no HTTPS-wait time for a scripted run (BACKLOG #453).
- Screenshots: all 15 screens have a PNG; the two read (summary, done) show the real terminal, so #235's single-quoted capture path
  works. The summary screen is the default address before the driver's edit step.
- Sweep: six targets deleted (repository, custom domain, Worker, database, bucket, App), none failed, none left on the address.

## What it showed about #235's harness changes, live

- `run-gate.sh scripted` refused first on a leftover `gnome-keyring-daemon` and printed the new line naming `cleanroom stop geoff`
  (#441); stopping the clean room cleared it.
- The launcher printed the new `shots:` line beside the run dir (#452).
- The grade read the run dir the launcher printed and passed; the stand-in's address check (`typeof` a string) and the grader's
  authoritative lookup ran on a real site.

## Not shown

The dead-tab mail sign-in (#233) was not exercised: the stand-in signed in through the browser, as in the dev.6 leg. The retry and the
authority wait (#234) have unit tests, and this leg shows only that setup works when DNS does; the host's DNS is still the Cloudflare
DoT configuration recorded in `scripted-dev6.md`.
