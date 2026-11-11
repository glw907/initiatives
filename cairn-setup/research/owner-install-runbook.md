# Owner install runbook (dev.7)

Your install of `cairn new`, the test that failed on rc.4. It runs in the clean room, so nothing touches your daily
Chromium, your GitHub, or your Cloudflare token. Your friction log outranks the naive lists: each line gets fixed or
filed. About 15 minutes, plus cleanup.

You need the GitHub test account `glw907-test`, the Cloudflare account `glw907` with the zone `carin-test.org`, and
the mailbox `cairn-gate@probe.907.life`. Port 49152 must be free, so run no `make -C tool check` meanwhile.

## Before

1. From the cairn-cms checkout, check that `gate` serves dev.7 and that no earlier test left anything behind. The
   sweep must list no target; `cleanroom stop geoff` clears a refusal.

   ```
   npm view create-cairn-site dist-tags
   bash scripts/gate/run-gate.sh sweep
   ```

2. Pick a ten-digit id (`date -u +%y%m%d%H%M`). The site name is `Cairn gate <id>`, which is how the sweep finds it.
3. Make a fresh clean room: `cleanroom init geoff --fresh --discard`.
4. Once, ever: open the test profile, `chromium-browser --user-data-dir=$HOME/.local/state/cleanroom/chromium-test`, and
   sign it into GitHub as `glw907-test` and into Cloudflare as `glw907`. Cloudflare's sign-in and its "Verify you are
   human" check are yours to pass: they stop any script, and no run has seen the pages after them.

## The install

5. Open a shell in the clean room, with its browser links going to the test profile:

   ```
   cleanroom shell geoff --open-with "chromium-browser --user-data-dir=$HOME/.local/state/cleanroom/chromium-test"
   ```

6. In that shell, which holds no Cloudflare token (`cleanroom` hands a room only what `--secret` and `--env` name), run
   it, so Cloudflare asks for your consent in the browser: `npm_config_tag=gate npm create cairn-site`
7. Answer as an owner would. Name: `Cairn gate <id>`. Email: `cairn-gate@probe.907.life`. Crawlers: your choice. Host:
   `gate.carin-test.org`, never the bare `carin-test.org` (the sweep refuses a record there).
8. Approve each browser step as it opens: Cloudflare, then the GitHub App, its repositories, and its install. Fix
   nothing and retry nothing. If a step looks wrong, write it down and go on.
9. When it says the site is live, check that the admin opened signed in and that the sign-in mail arrived.

## Friction log

Five lines in `research/owner-install-friction.md`, written as you go: what stopped or surprised you, the screen, how
long you waited, what the words should have said, and whether the sign-in worked. Take a screenshot of each Cloudflare
page. Then the #403 check: in the test profile, Cloudflare, Profile, Manage OAuth authorizations. Is the authorization
there, and is it named "cairn" (`doneRevokeFailed`, `tool/internal/ui/newview/catalogue.go`)?

## Clean up

10. `cleanroom stop geoff`, then two separate calls from the cairn-cms checkout:

    ```
    bash scripts/gate/run-gate.sh sweep
    bash scripts/gate/run-gate.sh sweep --apply
    ```

11. Delete the deploy key by hand: Cloudflare, Profile, API Tokens, `cairn-deploy-<setup's run id>`. No standing token
    can delete a user token.
12. Revoke the OAuth authorization from the #403 check, then sign the test profile out of Cloudflare.
