Initiative: cairn-setup

# Proving cairn setup: the tooling passes

Design: `../specs/2026-11-09-setup-tooling-design.md` (approved by Geoff in chat, 2026-11-09; binding
at initiatives `e0cc554`, which carries his 10-minute line and 3-minute stall check)
Research: `../research/handoff-tooling.md`, `../research/recon-rc4-tooling.md`,
`../research/prior-art-setup-testing.md`, `~/Projects/initiatives/907-rebuild/plans/2026-11-08-planning-misses.md`
Repos: `glw907/workstation` (pass 1, main checkout `/var/home/glw907/.dotfiles`) and
`glw907/cairn-cms` (passes 2 and 3, main checkout `/var/home/glw907/Projects/cairn-cms`). Records go
to `glw907/initiatives` (`/var/home/glw907/Projects/initiatives`).
Base: cairn-cms `main` at `f7e5e1ff5` and workstation `origin/main` at `daaa950`, read 2026-11-09.
Conductor: `conductor-cairn-cms`, the single conductor for cairn-setup and theme-garden.
Load at the start of every pass: `pass-core`, then the repo adapter (`dotfiles-pass` for pass 1,
`cairn-pass` and `cairn-running-passes` for passes 2 and 3); `standards:python-conventions` for
`cleanroom`; `standards:go-conventions` and `standards:golang-spf13-cobra` for `tool/**`;
`standards:ts-conventions` for `scripts/gate/**`; `cairn-writing-docs` for `docs/**`;
`standards:tui-visual-verify` for the scripted leg; `cairn-releasing` for every cut;
`claude-api` for the cost table's prices.

Every dispatch in this plan carries `pass-core` step 1's two quoted samples ("Avoid
over-engineering..." and "Deliver what was asked..."). Nothing below adds a feature the design does
not name. Each part reuses the 907-rebuild prototype (`907-rebuild/tools/`) or the existing gate
(`scripts/gate/`) wherever that already works, and the task says which.

## Pre-flight

Items 1 to 6 are one sitting for Geoff, carried by the conductor's next packet. Items 7 to 9 are the
conductor's, before the launches they name.

1. **[you] Rule on Decides S-1 to S-4 and approve this plan's backlog edits, estimate, and standing
   answers** in the conductor's next packet. Check: `grep -cE '^Ruled: ' <this file>` prints `4`.
2. **[you] The four owner steps before the first tool tag** (`cairn-releasing`, "The launcher and its
   platform packages"), because pass 3's first task publishes the launcher and the six platform
   packages to `gate`. In a Ptyxis terminal: `npm login` as glw907 (password and TOTP from Proton
   Pass), then `bash /var/home/glw907/Projects/initiatives/cairn-setup/plans/setup-tooling-owner-steps.sh`
   (a dry run, which prints each step's state), then the same with `--apply`. The script reads each
   step's state first, skips what is done, stops at the first failure, and logs to
   `~/.local/state/cairn-setup/owner-steps-<time>.log`, so a rerun resumes. Its dry run was run by the
   planner on 2026-11-09 and printed the four steps' pending actions. Check: a final dry run prints
   only `done:` lines for steps 1 to 4.
3. **[you] Mint the clean room's Cloudflare token.** Dashboard: Manage Account > Account API Tokens >
   Create, named `ws-cairn-cleanroom`, account-owned, no expiry, no IP filter. Account
   `120c269ad6d3dfbe6d63a0bb53758ca0`: Workers Scripts Edit, D1 Edit, Workers R2 Storage Edit, Email
   Sending Edit, Account Settings Read. Zone `carin-test.org` only: Zone Read, DNS Edit, Workers
   Routes Edit. The conductor then launches `secret-receive CF_WS_CAIRN_CLEANROOM_TOKEN` and Geoff
   pastes the value into its dialog. It is one token for setup, the site's deploy key, and the sweep
   (see "Calls settled here"), so no other Cloudflare token is needed: `ws-cairn-gate` lacks Account
   Settings Read and Workers Routes, and it is user-owned only for Workers Builds, which setup no
   longer uses. Check: the name is in the store (`grep -c '^export CF_WS_CAIRN_CLEANROOM_TOKEN='
   ~/.local/secrets` prints `1`, a name check only); T2.3's smoke proves the scopes.
4. **[you] The clean room's Claude Code credential**, per Decide S-3. On yes: console.anthropic.com
   > Workspaces > Create `cleanroom` with a monthly spend limit of $100, then an API key in it; the
   conductor launches `secret-receive ANTHROPIC_CLEANROOM_API_KEY`. On no: `claude setup-token` in a
   Ptyxis terminal, then `secret-receive CLAUDE_CLEANROOM_OAUTH_TOKEN`. Either value is pasted once,
   here, and never during a run. Check: the name is in the store; T1.6's probe session answers its
   first turn.
5. **[you] Bring the workstation checkout up to date, then add the auto mode grant.** The checkout is
   2 ahead and 2 behind `origin/main`: its `ef11c10` and `af7f797` are Geoff's grant edits, unpushed,
   and origin carries PR #214 (`daaa950`). Run `git -C ~/.dotfiles pull --no-rebase && git -C
   ~/.dotfiles push origin main` (the two sides touch different lines). Then `python3 -I
   /var/home/glw907/Projects/initiatives/cairn-setup/plans/add-setup-tooling-grant.py --dry-run`,
   the same without the flag, `claude-tooling-sync apply`, and a commit of
   `claude/.claude/settings.json` in `~/.dotfiles`. The script is the one source of the six lines'
   text. It also removes the 907-rebuild prototype's clean-room line, which the first new line
   replaces, and takes `--remove` for the end packet's undo. Check: `git -C ~/.dotfiles rev-list
   --count origin/main...main` prints `0`; `grep -c 'setup-tooling-' ~/.claude/settings.json` prints
   `6`; `grep -c 'Configuring the clean-room builder sandbox' ~/.claude/settings.json` prints `0`.
6. **[you] Nothing else.** No other step in passes 1 to 3 needs Geoff before packet B, and none in
   the loop needs him before the end packet, except a stop this plan names.
7. **[session] Auto mode probe, after item 5 and before any launch.** A `claude --bg` probe session
   in the cairn-cms main checkout cuts a scratch worktree under `.claude/worktrees/`, cites task T2.7,
   edits one line of `.claude/skills/cairn-releasing/SKILL.md`, commits, and reverts the commit. In a
   scratch worktree of `~/.dotfiles` it writes `bin/.local/share/cleanroom/settings.json` holding
   `{"sandbox": {"excludedCommands": ["cairn"]}}`, commits, and reverts. It removes both scratch
   worktrees and their branches. Check: the probe's log shows both commits and both reverts, with no
   refusal.
8. **[session] Overlap check before pass 2 launches.** `gh pr list -R glw907/cairn-cms --state open`
   and `git -C /var/home/glw907/Projects/cairn-cms worktree list` show no open PR or live pass branch
   whose diff touches `scripts/gate/**`, `tool/**`, `plugins/cairn/**`, `.claude/skills/cairn-releasing/**`,
   `.claude/skills/cairn-proving-setup/**`, or `docs/admin/set-up-with-an-agent.md` (`gh pr diff <n>
   --name-only`). theme-garden G2 touches none of them in its plan. Check: the command output, pasted
   into STATUS.
9. **[session] Launch checks** per `pass-core` "Execute" for each pass, from its repo's main checkout.
   Pass 3 also needs item 2 done and both PRs of packet B merged.

Permissions checked: each task's writes and credentials were read against auto mode for a `claude
--bg` executor. Pass 1 writes tracked files in its `~/.dotfiles` worktree, including the clean room's
settings template, which the `setup-tooling-cleanroom-config` line covers (pre-flight item 7 proves
it), and runs `cleanroom` forms that hand the test credentials into a clean home by store name
(`setup-tooling-cleanroom-run`). Pass 2 writes tracked files in its cairn-cms worktree, runs the
fast lane, `make -C tool check`, Node tests, and `bash scripts/gate/run-gate.sh --smoke` and `sweep`
(dry run), which source the store inside the harness, never in the session. Its held files are
`.claude/skills/cairn-releasing/**` and `.claude/skills/cairn-proving-setup/**`
(`setup-tooling-held-files`, item 7). Pass 3 runs the naive, scripted, and probe legs, answers the
clean room through `tmux send-keys`, applies the sweep after its dry run (`setup-tooling-sweep`),
publishes prereleases to `gate` (`setup-tooling-candidates`), and opens round PRs that the conductor
merges (`setup-tooling-merge`). Three grants are first used live inside a run: the sweep's apply, the
publish, and the round merge. Each line was written against the auto mode classifier's categories
as the theme-garden grants were, and a refusal has a standing answer. No task edits Claude's own
settings, hooks, or permission rules, and no task reads a secret value into a session.

Reviewed: see "Review" at the end of this file.

## Rulings before launch

### Decide S-1: probe part two runs without a packet when nothing changes

The design has Geoff approve the clean room's settings and the probe's record once. The probe
cannot run `cairn new` until a candidate carrying the token option is published, which needs pass 2
merged, which needs packet B. So T1.6 runs part one (everything but the cairn steps) before packet B,
and Geoff approves the settings and that record there. Part two, the cairn steps, runs as T3.2 on the
first candidate. **Recommendation: yes. When part two passes with the settings file byte-identical
to the one packet B approved, the run goes on and part two's record rides the end packet. A
settings change needed by part two sends a small packet before the first naive run.** No adds a
packet between T3.2 and T3.3 every time.

### Decide S-2: the clean room's token reaches the production Cloudflare account

`ws-cairn-cleanroom` can edit any Worker, database, and bucket on account `120c...0ca0`, the account
that serves the live sites, because Cloudflare scopes those groups to the account and offers no
per-name limit. The naive agent holds it in its environment. The mitigations are the clean room's
deny rules (`*wrangler delete*`, `*-X DELETE*`, `*d1 delete*`, `*r2 bucket delete*`, and the rest the
prototype carries), the $20 and 60-minute caps, the run-tagged names, and the conductor watching
every run. The alternative is a second Cloudflare account for tests: Workers Paid at $5 a month,
the `carin-test.org` zone and its Email Sending moved, and `test-accounts.md` rewritten, which
changes the design's test accounts. **Recommendation: accept the production account with these
mitigations.** No stops the plan for a design change.

### Decide S-3: the clean room's Claude Code credential

The design's caps are dollars. An API key in a Console workspace with a $100 monthly limit makes
every figure real spend, and the provider enforces the loop's ceiling for the naive runs
regardless of the harness. A subscription token (`claude setup-token`) costs nothing extra, but its
dollars are Claude Code's estimate and it draws on Geoff's plan limits. **Recommendation: yes, the
API key.** No uses the subscription token, and the caps read the estimate.

### Decide S-4: the estimate-overrun ceiling

The chain's expected actual is about 1,035 minutes ("The design's estimate"). **Recommendation: the
run goes on past the plan's path while each cause is traced and the chain's actual minutes stay under
2,070, twice the expected actual.** Past that, the conductor stops and asks. Geoff may name another
figure.

## Calls settled here

The design leaves these to Claude ("Claude's calls") or to the builder ("Left to the builder").
Each is settled from the code, and the executor builds it as written.

- **The token option.** `cairn new` reads `CAIRN_CF_SETUP_TOKEN`, an environment variable only,
  never a flag, so the token never reaches argv. When it is set, setup skips approval 1 (the
  Cloudflare consent, `tool/internal/setup/approvals.go:32`), uses the token for every Cloudflare
  call, and stores it as the site's deploy key (the `CLOUDFLARE_API_TOKEN` Actions secret,
  `tool/internal/providers/github_write.go:22`) in place of minting one
  (`cloudflare_write.go:268`). It mints nothing, deletes no minted key, revokes no grant
  (`runner.go:562`), and writes nothing to the keyring for Cloudflare. It reads no user email
  (`opening.go:210`), because an account-owned token cannot call `/user`, so `--email` (or the plan's
  email) is required with it. Using the supplied token as the deploy key keeps the option free of
  token-management scope: a token that could mint tokens could mint any token on the account, and the
  estate's rule 6 keeps no standing token that can. The docs say the deploy secret then holds the
  supplied token and that an owner may replace it with a narrower one. A resume needs the variable
  again and stops naming it when absent. The scrub registers the value, and `childenv` already strips
  every `CAIRN_*_TOKEN` from child processes (`childenv.go:31`). The `approve-cloudflare` step's done
  event and the summary each say which credential ran (`token` or `approval`). Scope verdict
  (`cairn-judging-scope`, run in planning): **accept.** It belongs to the operator's tool, not the
  engine's consumer surface. It serves owners who run setup from CI as well as the automated legs.
  Its leanest form is one variable with no flag, no file, no stored copy, and no mint. T2.7 records it
  in `docs/internal/engine-rulings.md` as `scope-verdict-setup-token`.
- **The template tag.** With no `--tag`, `cairn new` takes `npm_config_tag` from its environment
  (npm's own form for its `tag` setting, which npm reads from the environment too), else `latest`.
  The clean room sets `npm_config_tag=gate` in its environment, so npm resolves `npm create
  cairn-site` to the `gate` launcher and `cairn` reads the same value whether npm or the agent
  started it. The flag's default moves from the literal `latest` (`tool/cmd/cairn/new.go:84`) to
  that rule, and `--tag` still wins.
- **The sandbox and the setup tab.** Claude Code's docs say a sandboxed command's localhost "is
  private to that command" on Linux, and `allowLocalBinding` has no effect there
  (<https://code.claude.com/docs/en/sandboxing>). `cairn new`'s tab listens on `127.0.0.1`, so a
  browser outside could never reach it. The clean room's settings therefore list `cairn`,
  `create-cairn-site`, `npm create cairn-site`, `npm init cairn-site`, and `npx create-cairn-site` in
  `sandbox.excludedCommands`. Those run outside the sandbox with the clean environment and the clean
  `HOME`, under the Bash deny rules. The probe's canaries include a compound command that joins an
  excluded word to a read of a canary file. The same fact is an owner-facing gap: T2.7 adds one line
  to the setup skill and the agent page saying `cairn` must run outside an agent's sandbox, and T2.0
  files the product side.
- **The keyring.** Each clean session runs under `dbus-run-session` with `gnome-keyring-daemon
  --unlock --components=secrets` given an empty password on stdin, so `zalando/go-keyring`
  (`tool/internal/secrets/keyring.go:7`) reaches a private Secret Service and never Geoff's desktop
  keyring (misses 5 and 13). Both binaries are on this host (`dbus-run-session` from Homebrew,
  `gnome-keyring-daemon` in `/usr/bin`). The probe proves a write and a read.
- **The cost source.** The clean home's settings set a `statusLine` command that writes the JSON
  Claude Code passes it, whose `cost.total_cost_usd` is the session's running cost, to the run
  directory. `cleanroom cost <transcript.jsonl>` sums a transcript's token usage against a price
  table taken from the `claude-api` skill, and T1.6 checks the two against each other on the probe's
  session (miss 11). The pass 3 executor counts its own spend with `cleanroom cost` on its own
  transcript. The $100 counts the naive runs, the probe sessions, and the pass 3 executor, which is
  the design's conductor (it plays the owner). `conductor-cairn-cms`'s watching is not counted, since
  it serves two initiatives.
- **The credential choice.** Decide S-3.
- **The clean room's shape.** `cleanroom` grows from `cleanroom-run`: `env -i`, a clean `PATH`, the
  sandboxed settings, and `script -q -f` for the log. Homes live at `/var/tmp/cleanroom/<name>/home`
  and run directories at `/var/tmp/cleanroom/<name>/run` (mode 0700). The settings template is
  `bin/.local/share/cleanroom/settings.json`, which stows to `~/.local/share/cleanroom/`. It is data,
  so the tool stays one code file under the tool-language rule. `init` also seeds the clean home's
  `~/.claude.json` so the first session shows no onboarding, trust, or API-key screen, and sets
  `DISABLE_AUTOUPDATER=1`. Credentials enter through `--secret STORE_NAME[:ENV_NAME]`: the tool reads
  the value from `~/.local/secrets` itself, so a value never sits in argv or in the calling session.
  `BROWSER` is a relay `init` writes into the clean home: it appends each URL to the run directory's
  `urls.log`, which the clean room's sandbox cannot read, and with `--open-with <cmd>` also runs
  that command. It never prints a link. #52's `signin` and `turn` forms are dropped: credentials come
  from the store with no device flow, and `run`'s interactive session replaces the headless turn.
  #52's `teardown` becomes cairn's sweep, since it is cairn-specific.
- **The network allowlist** the probe proves: `registry.npmjs.org`, `github.com`, `api.github.com`,
  `codeload.github.com`, `*.githubusercontent.com`, `api.cloudflare.com`, `carin-test.org`,
  `*.carin-test.org`, `*.workers.dev`, `code.claude.com`, `docs.claude.com`, `cdn.playwright.dev`,
  and `playwright.download.prss.microsoft.com`. The excluded commands bypass the proxy. Claude Code's
  own API traffic leaves from its own process, outside the sandbox.
- **The run tag.** The owner card's site name is `Cairn gate <run id>`, with the run id
  `YYMMDDHHMM` in UTC, so setup's derived names (`tool/internal/setup/names.go:65`) all carry
  `cairn-gate-<run id>`: the repository and Worker, `-auth` for the database, `-media` for the bucket,
  and the App under its prefix. The sweep matches `cairn-gate-` anywhere in a name.
- **The run record's fields.** Run id; leg; the candidate's engine, tool, and launcher versions; the
  cairn-cms `main` commit the agent read; start and end; outcome (`pass`, or `fail` with `cost`,
  `time`, `stall`, `page`, or `other`); the three end-state checks (live, owner signed in, sign-in
  mail in the mailbox), each with its evidence line; minutes from the goal prompt to signed in; a
  per-step table from setup's events (`tool/internal/setup/events.go:64` timestamps) and the
  stand-in's, splitting each step's agent minutes from its provider wait (the first Actions deploy and
  HTTPS on the domain); cost in dollars and turns; each permission prompt with its command; each
  missed relay (a `waiting` sentence never passed on); the conductor's flailing notes; harness
  overhead minutes (sweep, init, start); the items this run added to the two lists; and each step's
  change against the last run's record.
- **The release rule's mechanics.** The candidate's release body keeps its `## Gate` table, now with
  three legs (`naive`, `scripted`, `owner`) and a `Version` column naming the candidate each passed
  on. `record.mjs carry --from <version> --to <version>` copies the `naive` and `owner` rows forward
  only when `git diff --name-only v<from> v<to>` touches none of the rerun paths, one constant in
  `record.mjs`: `tool/internal/setup/**`, `tool/internal/providers/**`, `tool/internal/secrets/**`,
  `tool/internal/ui/newview/**`, `tool/cmd/cairn/new*.go`, `tool/cmd/cairn/help_agents.go`,
  `packages/create-cairn-site/**`, `templates/**`, `scripts/build/setup-overlay/**`, `plugins/cairn/**`,
  `README.md`, and `docs/admin/**`. Round one's record lists the pages the agent read, and the round
  that reads it corrects the constant. `verdict.mjs` then needs one `pass` row per leg, `scripted` on
  the release's own version and the other two on it or an earlier prerelease of the same `x.y.z`.
  `publish.yml`'s verdict and promote jobs keep their calls, so no workflow changes.
- **The light cut.** Each round's candidate is `cairn-releasing` steps 2 (the preflight only) and 6,
  with a one-paragraph note and no doc sweep. The engine takes `0.99.0-rc.5`, then `rc.6` and on. The
  tool module is `tool/v2` (`tool/go.mod`), so its first tag is `tool/v2.0.0-rc.1`, then `rc.2` and
  on. A round publishes only what changed. A docs or skill fix publishes nothing, since the naive agent
  reads both from GitHub `main`. #369's recut mode is not needed: every round's cut carries a non-empty
  `## Unreleased`, and a publish that fails partway reruns its workflow (`cairn-releasing`, step 9's
  last paragraph).
- **The dependency sweep** runs once, in T3.5, before the final candidate that Geoff installs,
  because a stable is cut only from the final candidate's tree (`cairn-releasing` step 6) and a release
  starts from current dependencies (step 2). Rounds skip it.
- **Who plays the owner.** The design's conductor, the session that watches each run, plays the
  owner, and keeps the two lists, is pass 3's executor `cairn-cms-setup-tooling-3`, following the
  `cairn-proving-setup` skill. `conductor-cairn-cms` launches it, merges its round PRs, and sends the
  packets. The executor never asks Geoff; it writes a stop to STATUS and the conductor asks.
- **The stand-in's pace.** It waits 3 seconds on each tab page before it clicks, as a person reading
  it would, and 2 minutes at most for a page it can read and clear.
- **The old gate.** Kept and reused: `browser.mjs` (`ensureGithubSession`, `handleUrl`'s GitHub page
  handling, `tailUrlLog`, `confirmSignIn`, `deleteGithubApp`, `failPage`, and `publishViaAdmin` with
  its `gate-publish.spec.ts`, left as they are), `totp.mjs`, `resolve.mjs` (the negative-cache pin for
  `carin-test.org`), `fetch-check.mjs`, `record.mjs`, `verdict.mjs`, and `legs.mjs`'s
  `findSignInMessage` JMAP reader, moved into `mail.mjs`. Retired: `legs.mjs`, `driver.mjs` (the clack
  prompt driver), `teardown.mjs`, `tail.mjs`, the `xdg-open` shim, and `cloudflare/` (#409), with
  their tests.
- **#349's standing rule.** "A pass that changes `scripts/gate/` ends with one run against the current
  `gate` candidate" cannot hold for pass 2: the current candidate is rc.4, the retired wizard. Pass 2's
  live proof is T3.2 on the first candidate, and T2.7 rewrites the rule around the new legs.
- **The live admin smoke** (`cairn-running-passes` close checklist, `auth-data`) does not apply to pass
  2: its `auth-data` paths are the Go tool's setup runner, and no engine auth path changes. The tool's
  end-to-end suite (`tool/cmd/cairn/new_e2e_test.go`) is its offline proof and T3.2 its live one. Pass
  2's PR records this under `## Decisions`.
- **Owner card.** Site name `Cairn gate <run id>`; owner email `cairn-gate@probe.907.life`; AI
  crawlers declined; the GitHub account in the browser (`glw907-test`); the Cloudflare account
  `glw907` and the zone `carin-test.org` with the bare address; the default theme; yes to Workers
  Paid; yes to the plugins the docs suggest. Any other question gets a reasonable owner's answer and a
  line in the record.

## Backlog verdicts

Scoped sweep (`standards:backlog-sweep`) over the items the design touches, read against cairn-cms
`main` at `f7e5e1ff5` and workstation `origin/main` at `daaa950`.

| Item | Verdict | Grounding and placement |
| --- | --- | --- |
| cairn-cms #366 | fold | Part (d), the live leg per candidate, is what the naive and scripted legs are. Pass 3 marks it done when the scripted leg passes. Already tagged. |
| cairn-cms #369 | keep | Not needed by the loop ("The light cut"). Its placement line gains: "Not needed by the setup-tooling loop; build it when a recut of the same version is needed." |
| cairn-cms #390 | fold | T2.2 drops `Subscriptions` (`cloudflare_write.go:200`, `runner.go:38`, every fake) and `ReasonWorkersPaid` (`failure.go:20`, `messages.go:103`, `newview/failure.go:17`): the route answers 403 to setup's grant, so it can never have a caller. Already tagged. |
| cairn-cms #392 | fold | T2.2 sets `auto_init: false` in `tool/scripts/record-fixtures/run.mjs`. T3.2's live run confirms the public-key and secret-PUT routes on a repository with no commits, since setup stores the deploy key before the first push. Already tagged. |
| cairn-cms #403 | fold | T2.2 checks `doneRevokeFailed` (`tool/internal/ui/newview/catalogue.go:151`) against Cloudflare's current docs. The live check needs an OAuth grant, so it moves to Geoff's install: the runbook asks him to confirm the menu path and the name "cairn", and the item closes there. Already tagged. |
| cairn-cms #404 | fold | Setup shows the Workers Paid copy only when the subscriptions read says the plan is absent, and that read can never succeed (#390). T2.2 has the generic first-deploy failure (`deploy.go:287`) name Workers Paid as the first thing to check, and the deploys page gains the same sentence. Already tagged. |
| cairn-cms #409 | fold | T2.3 deletes `scripts/gate/cloudflare/`. The sweep's few Cloudflare calls get their own tested client. Already tagged. |
| workstation #52 | fold | Pass 1 builds `init`, `probe`, `run`, and `shell`, plus `cost`; `signin` and `turn` are dropped and `teardown` becomes cairn's sweep ("The clean room's shape"). T1.1 adds `#initiative:cairn-setup` beside `#initiative:907-rebuild` and a placement line; T1.7 marks it done. |
| new, cairn-cms | file | T2.0 files, Low: "`cairn new` run inside an agent's Linux sandbox waits on a setup tab the browser cannot reach", tagged `#initiative:cairn-setup`, placement "the setup skill and the agent page say so (T2.7); a product check that names the cause waits on a run that meets it". |

The full sweep is not due on either repo for this design.

## The design's estimate

The design carried no estimate, so the planner set one from recent scores for Geoff to approve with
this plan. Actual against planned path, from merged PRs' score rows: #205 65 of 540 (0.12), #207 175
of 1,015 (0.17), #201 240 of 1,190 (0.20), #204 210 of 765 (0.27), #203 210 of 510 (0.41), and the
release gate pass #195 480 of 900 (0.53). The recent median is 0.20, but live-account harness work
has run closest to plan (#195, 0.53), and passes 2 and 3 are that kind of work. **Factor: 0.53** for
the harness passes. Pass 3's runs are wall-clock time and take no factor.

Sized top-down: pass 2 is like #195 (a harness rewrite with live accounts), about 480 actual; pass 1
like #205 (one tool with tests), about 100 actual, and it runs beside pass 2; pass 3 is about three
naive runs at 45 minutes with their sweeps, the probe, the scripted leg, and the final candidate
(about 315 live minutes) plus four fix rounds at about 60 (240), so about 555 actual. Divided by the
factor where it applies: pass 2 about 900 path minutes and pass 3 about 1,050. **Estimate: 1,950
path minutes** on the chain (pass 2, then pass 3), with pass 1 off it. Expected actual: about 1,035
minutes.

The plan's chain below is 1,870 (pass 2 800, pass 3 1,070), 0.96 of the estimate, under the
twice-estimate line (3,900).

## Order and packets

1. Pre-flight items 1 to 7 (packet A, from the conductor).
2. Pass 1 and pass 2 run side by side, in different repos, under one conductor.
3. Packet B: pass 1's PR (`runner`), pass 2's PR (`auth-data`), the probe's part-one record, and the
   settings file. Geoff approves; the conductor merges pass 1, runs `stow -R bin` and `claude-tooling-sync
   verify` in `~/.dotfiles`, then merges pass 2, and pulls both checkouts.
4. Pass 3 runs the loop. Round PRs merge under `setup-tooling-merge` with no packet.
5. The end packet: the runbook, both lists, the ledger, every round PR as a routine row, the held-file
   edits in their own row, and the grant's removal as a `[you]` step. Geoff then runs his install.

| Pass | Slug | Class | Path minutes | Merge |
| --- | --- | --- | --- | --- |
| 1 | `setup-tooling-1` the clean room (workstation) | `runner` (`tests/**`) | 485, off the chain | conductor, after packet B |
| 2 | `setup-tooling-2` the gate, the token option, and the skills (cairn-cms) | `auth-data` (T2.1) with `runner` | 800 | conductor, after packet B |
| 3 | `setup-tooling-3` the polish loop (cairn-cms) | `runner`, round fixes take their own class | 1,070 | round PRs: conductor under the grant |

Each task block below is what a pair dispatch quotes verbatim. Every task writes `.pass-task-clock`
at its start, commits, and runs the adapter's fast lane at its end (`bash scripts/gate.sh` in the
workstation repo; `npm run lane:fast -- --range <base>..HEAD` in cairn-cms, and `make -C tool check`
for `tool/**`). An `auth-data` task commits its failing test first. No pass bumps a version; only pass
3's cuts publish, and only to `gate`.

### Pass 1 `setup-tooling-1`: the clean room (workstation, `runner`)

Outcome: `cleanroom` in `bin/.local/bin`, a stdlib Python tool that knows nothing about cairn, with
`init`, `probe`, `run`, `shell`, and `cost`, its settings template, and a probe record that proves
the settings under a real session. Pairs: T1.1 with T1.5.

**T1.1 `init`, the settings, and the canaries** (120 min, `ordinary`). Outcome: `cleanroom init
<name>` makes `/var/tmp/cleanroom/<name>/{home,run}` (0700), copies
`bin/.local/share/cleanroom/settings.json` into `home/.claude/settings.json`, seeds `home/.claude.json`
(onboarding done, the work folder trusted, the API key approved by its last 20 characters, the
form Claude Code stores), writes the `BROWSER` relay into the clean home, and writes a canary file with
a random value at `~/.local/state/cleanroom/canary` in Geoff's home. A rerun of `init` on an existing
name refuses unless `--fresh`, which removes the old home and run directory first, after printing
what it removes. The template starts from `907-rebuild/tools/cleanroom-settings.json` and adds: the
allowlist under "Calls settled here"; `excludedCommands` for the five launcher forms; `defaultMode`
`default`, so permission prompts show; the `statusLine` command (`python3 -I <tool> statusline <run
dir>`); deny rules for `Read(//var/tmp/cleanroom/*/run/**)` and `Read(//var/home/glw907/.local/state/cleanroom/**)`;
`env` with `NODE_USE_ENV_PROXY=1`. Every deny rule the prototype has stays. Files:
`bin/.local/bin/cleanroom`, `bin/.local/share/cleanroom/settings.json`, `tests/test_cleanroom.py`,
`BACKLOG.md` (#52's tag and placement). Acceptance: `init` twice without `--fresh` exits non-zero and
changes nothing; with `--fresh` it rebuilds; the written settings equal the template plus nothing
else; the seeded `~/.claude.json` parses and names the work folder; no file under the new home names
a path in Geoff's home except the read-only tool directories the template allows. Test: those cases
under a temporary root.

**T1.5 The design-stage planning-miss check** (40 min, `ordinary`; pairs with T1.1). Outcome:
`claude-launch-guard` denies a planner launch (`*-planner-prompt.txt`) whose prompt names a
`specs/*-design.md` that lacks a backlog-sweep section, an estimate, or a pre-flight list, each found
by a `##` heading matching `backlog|sweep`, `estimate`, or `pre-flight` (case folded). The reason
names what is missing. Files: `bin/.local/bin/claude-launch-guard`, `tests/test_claude_launch_guard.py`.
Acceptance: a planner launch naming a design with all three goes through; one missing any is denied,
naming it; a planner launch naming no design goes through. Test: those three cases.

**T1.2 `run`, `shell`, and `cost`** (150 min, `ordinary`). Outcome: `cleanroom run <name> --goal
<text> [--secret STORE[:ENV]]... [--env K=V]... [--cap-usd 20] [--cap-min 60]` starts `tmux` session
`cleanroom-<name>` running `script -q -f run/session.log` around `env -i` (`HOME`, a clean `PATH`
that holds `node`, `claude`, `git`, and Homebrew, `LANG`, `TERM`, `TMPDIR`, `BROWSER`, the
`--secret` and `--env` values), `dbus-run-session`, the unlocked `gnome-keyring-daemon`, and an
interactive `claude "<goal>"` in `home/work`. It returns at once, printing the session name and the run
directory. A watcher in the tmux session's second window writes `run/state.json` every 15 seconds:
elapsed minutes, the statusline cost, the transcript's last-write time, and the state (`running`,
`stopped:cost`, `stopped:time`, `exited`). At either cap it sends the session `C-c` twice, then kills
it after 30 seconds, and appends one row to `/var/tmp/cleanroom/ledger.jsonl` (name, start, end,
state, cost, turns). `cleanroom shell <name> [--tmux <session>] [-c <command>] [--open-with <cmd>]`
opens the same environment without Claude: interactive in the terminal, detached in a named tmux
session, or running one command and exiting with its status. `cleanroom cost <transcript.jsonl>`
prints the transcript's dollar total from its usage and the price table. Files:
`bin/.local/bin/cleanroom`, `tests/test_cleanroom.py`. Acceptance: a `--secret` value appears in the
clean environment and nowhere in argv (`/proc/<pid>/cmdline` of every process the run starts) or in
any file under the run directory; a run past `--cap-min 1` with a stub `claude` ends as
`stopped:time` with a ledger row; `shell -c 'env'` prints none of the calling shell's variables beyond
the clean set; `DBUS_SESSION_BUS_ADDRESS` inside points at the private bus, never `/run/user/1000/bus`;
`cost` on a fixture transcript matches its hand-computed total. Test: those cases, with a stub
`claude` on `PATH`.

**T1.3 `probe`** (80 min, `ordinary`). Outcome: `cleanroom probe <name> --commands <file>
[--secret ...]` runs `run` with a goal that tells the session to run the file's commands in order and
report each one's exit, then reads the pane every 5 seconds. A permission prompt on screen is
recorded with its command and answered "No", so the probe never widens anything itself. It writes
`run/probe.md`: each command, its result, every prompt, every sandbox denial the transcript shows,
and the canary verdicts (the canary's value appearing anywhere in the transcript or the pane log
fails the probe). The generic list `bin/.local/share/cleanroom/probe-commands.md` holds: reads of the
canary file, `~/.local/secrets`, `/tmp`, `/run/user/1000`, and `/var/tmp/cleanroom/<name>/run`, each
expected to fail; `cairn --version && cat <canary>` and the same with each other excluded word,
expected to print no canary value; `env` with no workstation variable; `npm view` and `npm install` of
a public package; a keyring write and read through `secret-tool` on the private bus; a Playwright
screenshot of a local page with the system Chromium; a dev server and a `curl` to it in one command;
`git clone` of a public repository; and a push to a scratch branch of `glw907-test/cleanroom-probe`,
which the probe creates if absent and deletes after (it needs `--secret GITHUB_TEST_TOKEN`). Files:
`bin/.local/bin/cleanroom`, `bin/.local/share/cleanroom/probe-commands.md`, `tests/test_cleanroom.py`.
Acceptance: with a stub session that prints a known prompt, the record shows the prompt answered
"No" and the probe fails; a stub that echoes the canary value fails the probe; a clean stub passes.
Test: those three.

**T1.4 Records and inventory** (30 min, `ordinary`). Outcome: `~/.claude/docs/cloudflare-estate-inventory.md`
gains the `ws-cairn-cleanroom` row (scopes from pre-flight item 3, store name, "the clean room's
setup token and the cairn gate's sweep"); `~/.claude/docs/test-accounts.md` names the clean room, the
token, and the Claude credential under its Cloudflare and a new "Clean room" section; the tool's
module docstring and `--help` are its doc. Files: `claude/.claude/docs/cloudflare-estate-inventory.md`,
`claude/.claude/docs/test-accounts.md`, `bin/.local/bin/cleanroom`. Acceptance: `bash scripts/gate.sh`
passes, Vale included. Test: the gate.

**T1.6 Probe, part one** (60 min, `live-account`). Outcome: the executor runs `cleanroom init probe
--fresh`, then `cleanroom probe probe --commands bin/.local/share/cleanroom/probe-commands.md --secret
ANTHROPIC_CLEANROOM_API_KEY:ANTHROPIC_API_KEY --secret GITHUB_TEST_TOKEN:GH_TOKEN --env
npm_config_tag=gate` (the Claude credential per Decide S-3), from its own `claude --bg` session, so the
grant is proven under a background session. Each failure that is a settings gap is fixed in the
template within the `setup-tooling-cleanroom-config` line, and the probe reruns until it passes.
`cleanroom cost` on the probe's transcript is checked against the statusline's last figure (within 5
percent, or the difference is explained in the record). The sanitized record goes to
`/var/home/glw907/Projects/initiatives/cairn-setup/research/cleanroom-probe-1.md`, committed to the
initiatives repo's `main`, never with a value, a link, or a token. Files: the template (fixes only),
the record. Acceptance: the record shows every item passing, zero permission prompts, no canary
value, and the cost check. Test: the probe itself.

**T1.7 Close** (45 min). The whole-branch `standards:diff-reviewer` with `standards:python-conventions`;
one batched fix chain; `bash scripts/gate.sh` on the head; one `gitleaks git` branch-history scan;
#52 to `## Done`; the PR opens with a `## Brief` and carries `## Decisions`, `## Planning misses` (the
entry under "Planning misses at design", plus T1.5 as its fix), and the score. The PR body's brief
names the settings file and the probe record for Geoff's read in packet B. The executor reports
PR-ready to the conductor and ends; it never sends a packet.

Chain: max(T1.1 120, T1.5 40) + T1.2 150 + T1.3 80 + T1.4 30 + T1.6 60 + T1.7 45 = **485**.

### Pass 2 `setup-tooling-2`: the gate, the token option, and the skills (cairn-cms, `auth-data`)

Outcome: `cairn new` takes a Cloudflare token and npm's tag setting; round one's known tool fixes
land; the gate under `scripts/gate/` is rebuilt around `cairn new` with the stand-in, the mailbox
reader, the sweep, the grader, the scripted leg, and the three-leg release rule; and the skills and
docs say all of it. Pairs: T2.1 with T2.3, T2.2 with T2.4, T2.5 with T2.6. T2.7 is the executor's
own (held files).

**T2.0 Ledgers** (10 min, `ordinary`). Outcome: the backlog verdicts above land. Files:
`BACKLOG.md`. Acceptance: #369's placement line carries the new sentence; the new Low item exists
with its tag and placement; #390, #392, #403, #404, #409, and #366 are unchanged here (each closes
in the task that fixes it). Test: `grep` for each.

**T2.1 The token option** (180 min, `auth-data`, test first; dispatch with `model: opus`). Outcome:
"The token option" under "Calls settled here", built as written. Files: `tool/cmd/cairn/{env.go,new.go,new_wire.go,messages.go,help_agents.go}`,
`tool/internal/setup/{runner.go,approvals.go,opening.go,resume.go,summary.go,events.go}` and the deploy
key's call site, their tests, `tool/testdata/flags.json` if the generated reference changes.
Acceptance: with `CAIRN_CF_SETUP_TOKEN` set and `--email` given, the end-to-end suite's fakes see no
OAuth authorize, exchange, or revoke call, no `/user` call, no `POST /user/tokens`, and a deploy-key
secret PUT whose sealed value opens to the supplied token; without `--email`, the run refuses before
any call and names the flag; a resume without the variable stops and names it; the token's value
appears in no event, record, log line, or child environment (the scrub's existing test extended to
it); the `approve-cloudflare` done event and the summary carry `token`, and an OAuth run carries
`approval`; `cairn help agents` lists the variable. Test: those cases, failing first.

**T2.2 The tag default and round one's tool fixes** (100 min, `ordinary`; after T2.1, same files in
part). Outcome: "The template tag" as written; #390's drop; #404's sentence ("If the account isn't
on Workers Paid, the first deploy fails: check the plan first.") at the head of the generic deploy
failure's next step; #392's `auto_init: false`; #403's copy checked against Cloudflare's docs page for
revoking an OAuth app's access, corrected if the docs' menu path differs, with the page cited in a
comment. Files: `tool/cmd/cairn/new.go`, `tool/internal/setup/{deploy.go,failure.go,messages.go,runner.go}`,
`tool/internal/providers/cloudflare_write.go`, `tool/internal/ui/newview/{failure.go,catalogue.go}`,
every fake that implements `Subscriptions`, `tool/scripts/record-fixtures/run.mjs`, `docs/admin/deploys.md`.
Acceptance: no `--tag` with `npm_config_tag=gate` fetches the `gate` dist-tag in the fetch test's fake
registry, `NPM_CONFIG_TAG` likewise, `--tag latest` wins over both, and neither set fetches `latest`;
`grep -rn 'Subscriptions\|ReasonWorkersPaid' tool/` prints nothing; the deploy failure's golden shows
the sentence; #390, #392, #404 move to `## Done` with this commit, #403 gains "copy checked against
<page>; live check in Geoff's install". Test: the fetch cases and the updated goldens.

**T2.3 The sweep, the mailbox reader, and the smoke** (200 min, `runner`; pairs with T2.1). Outcome:
`scripts/gate/sweep.mjs` lists every resource whose name carries `cairn-gate-` (glw907-test's
repositories through `GITHUB_TEST_TOKEN`, its GitHub Apps through the settings page in the stand-in's
browser, and on the Cloudflare account through `CF_WS_CAIRN_CLEANROOM_TOKEN` the Workers, their custom
domains on `carin-test.org` and `www`, the databases, the buckets, and the DNS records setup made),
prints the delete list, and with `--apply` deletes in dependency order (domains, Worker, database,
bucket emptied first, DNS records, repository, App), skipping a target already gone and logging each
step to the run directory. Before any delete, the dry run proves each family's write scope with one
throwaway create and delete named `cairn-gate-probe-<time>` (the old smoke's pattern), and a missing
scope fails the dry run naming the family (miss 1). `scripts/gate/mail.mjs` takes
`findSignInMessage` from `legs.mjs` and fails on every JMAP method error, never reading one as an empty
result. `run-gate.sh` keeps its lock, run directory, and allowlisted environment, swaps the
allowlist's Cloudflare names for `CF_WS_CAIRN_CLEANROOM_TOKEN`, and takes `--smoke` and `sweep [--apply]`.
`gate.mjs`'s smoke checks the new token at `/accounts/<id>/tokens/verify`, the GitHub machine account,
TOTP, and the mailbox. Deleted: `legs.mjs`, `driver.mjs`, `teardown.mjs`, `tail.mjs`, `xdg-open`,
`cloudflare/`, and their unit tests. Files: `scripts/gate/{sweep.mjs,mail.mjs,run-gate.sh,gate.mjs}`,
the deletions, `src/tests/unit/gate-{sweep,mail,env,main}.test.ts`. Acceptance: the sweep's fakes show
a dry run that deletes nothing; a family whose probe create answers 403 fails the dry run before any
delete; an `--apply` after a partial run skips the gone targets and finishes; a name without
`cairn-gate-` is never listed; a JMAP `error` method response throws; `gate.mjs` imports nothing from
a deleted file; `node scripts/gate/sweep.mjs` against the live accounts (through `run-gate.sh sweep`)
prints a dry run with every scope probe passing. Test: those cases on fakes, plus the one live dry
run, whose output goes into the commit body.

**T2.4 The stand-in** (150 min, `runner`; pairs with T2.2). Outcome: `scripts/gate/stand-in.mjs
<run dir>` tails `urls.log` (`tailUrlLog`), opens each URL in the machine account's persistent
context (`ensureGithubSession`), and follows the tab: on each cairn tab page it reads the page's
next-step button by its accessible name, waits 3 seconds, and clicks; on GitHub's pages it reuses
`handleUrl`'s App-create and install handling, with TOTP for sudo and the mailbox for a new-device
code. A page it cannot read or clear in 2 minutes fails through `failPage`, whose screenshot rule
(never a sign-in page or a URL carrying a token) holds. When setup's tab offers the sign-in link it
follows it; under `--apply` it reads the sign-in mail through `mail.mjs` and opens its link. It ends
when an admin page shows the owner signed in (`requireAdmin`). It writes `stand-in.jsonl` (page kind,
action, timestamp) for the grader. Files: `scripts/gate/{stand-in.mjs,browser.mjs}`,
`src/tests/unit/gate-stand-in.test.ts`. Acceptance: against fixture pages for each tab page, it
clicks the named button after the pause and logs it; an unknown page fails at 2 minutes with a
screenshot and a controls file; a sign-in page is never shot; the mail path opens the newest message
for the owner after the run's start, never "the newest message". Test: those cases with a fake page
and a fake clock.

**T2.5 The grader, the record, and the entries** (200 min, `runner`). Outcome:
`scripts/gate/grade.mjs <run dir>` writes `run-record.json` and `run-record.md` with "The run
record's fields". It reads the clean home's transcript, setup's events in it, `stand-in.jsonl`, the
registry record under the clean home's `~/.config/cairn/sites/`, `cairn new status` through
`cleanroom shell <name> -c`, the mailbox, and `https://carin-test.org/` and `/admin` through
`gateFetch`; it diffs each step against the last record in `~/.local/state/cairn-gate/proving/`. A
read that fails is a failed check, never an empty one. `record.mjs` and `verdict.mjs` take the three
legs, the `Version` column, and `carry` ("The release rule's mechanics"). `run-gate.sh` gains `probe`,
`naive`, `scripted`, `grade <run dir>`, and `shell`: `naive` runs the sweep's dry run and apply, then
`cleanroom init <run id> --fresh`, starts the stand-in, and starts `cleanroom run` with the design's
goal sentence, the credentials as `--secret`, `npm_config_tag=gate`, and the caps; it prints the tmux
session and the run directory and returns. Files: `scripts/gate/{grade.mjs,record.mjs,verdict.mjs,run-gate.sh}`,
`scripts/gate/README.md`, `src/tests/unit/gate-{grade,record,verdict}.test.ts`. Acceptance: on a
fixture run directory the record carries every field, splits the deploy and HTTPS waits from agent
time, and shows a per-step delta against a fixture previous record; a mailbox error marks the mail
check failed; `verdict` passes three `pass` rows with `scripted` on the release's version and fails
when `scripted` is on an earlier one; `carry` refuses when the diff touches a rerun path and copies
when it does not; `publish.yml` is unchanged. Test: those cases.

**T2.6 The scripted human leg** (120 min, `runner`; pairs with T2.5). Outcome:
`scripts/gate/scripted.mjs <run dir>` starts `cleanroom shell <name> --tmux <session>` with the
credentials and `npm_config_tag=gate`, types `npm create cairn-site`, answers each screen of the
interactive `cairn new` (the owner card's name, the email as a bracketed paste, Enter on every
default), starts the stand-in, and waits for the done screen, failing at 20 minutes with the step it
reached. Each claim about a screen rests on a `kitty-headless-shot` of the real terminal attached
read-only to the session (`tmux attach -r`), per `standards:tui-visual-verify`; a text capture is
never the evidence. Files: `scripts/gate/scripted.mjs`, `src/tests/unit/gate-scripted.test.ts`.
Acceptance: against a recorded pane sequence it types each answer at its screen and never before;
the email goes in bracketed-paste codes; a screen it does not know fails the leg naming it. Test:
those cases with a fake tmux.

**T2.7 Skills, docs, and rulings** (150 min, `ordinary`, held files; the executor writes them). Outcome:
- `.claude/skills/cairn-proving-setup/SKILL.md` with `references/owner-card.md`: start a run
  (`run-gate.sh naive`), watch it (a Monitor on `run/state.json` and `stand-in.jsonl`, `tmux
  capture-pane`, `cairn new status`), play the owner from the card through `tmux send-keys`, answer
  permission prompts as a reasonable owner would, the 3-minute stall rule, judge flailing (the
  design's four kinds), grade, keep the two lists in
  `~/Projects/initiatives/cairn-setup/research/proving/round-<n>.md` with every item fixed or filed,
  the per-round time comparison, and the budget stop (five naive runs or $100).
- `.claude/skills/cairn-releasing/SKILL.md`: step 7 rewritten around the three legs, the light cut,
  the release rule from the design's "Which legs rerun after a fix" with `record.mjs carry`, and
  #349's rule restated for the new legs.
- `plugins/cairn/skills/cairn-setting-up-a-site/SKILL.md`: run `cairn new` in the background (the
  Bash tool's `run_in_background`, or with its events to a file) so each `waiting` sentence can be
  relayed while it blocks; `cairn` must run outside an agent's sandbox; the token option for an
  unattended run.
- `docs/admin/set-up-with-an-agent.md` and `docs/admin/setup-reference.md`: the token option, its
  scopes, the deploy secret it becomes, and the sandbox line. `docs/internal/engine-rulings.md`:
  `scope-verdict-setup-token`. `CHANGELOG.md` under `## Unreleased` and `MIGRATION-NOTES.md`: the token
  option, the tag default, the Workers Paid sentence (each `Consumers must: nothing.`).
Files: those. Acceptance: `npm run check:docs-gate` and Vale pass; a fresh `docs-fact-checker` returns
no finding on the changed lines; the skill names only commands that exist on the branch. Test: the
docs gate and the fact-check.

**T2.8 Close** (90 min). The whole-branch `standards:diff-reviewer`, `standards:web-auth-security-reviewer`
on T2.1's paths, and `standards:go-conventions` for `tool/**`; one batched fix chain; the fast lane;
CI green on the draft PR; the PR body opens with a `## Brief` and carries `## Decisions` (the live
smoke call and #349's), the auth-data verdict, `## Planning misses` (the entry below), and the score.
The executor reports PR-ready to the conductor and ends; it never sends a packet.

Chain: T2.0 10 + max(T2.1 180, T2.3 200) + max(T2.2 100, T2.4 150) + max(T2.5 200, T2.6 120) + T2.7
150 + T2.8 90 = **800**.

### Pass 3 `setup-tooling-3`: the polish loop (cairn-cms)

Outcome: a naive run passes without obvious flailing, the scripted leg passes, every item on both
lists is fixed or filed, the final candidate carries current dependencies, and Geoff has a one-page
runbook for his install. The executor follows `cairn-proving-setup`. Round fixes go to
`setup-tooling-r<n>` branches cut from `main` (cairn-cms in the pass worktree, workstation fixes in a
`~/.dotfiles` worktree by absolute path), one PR per repo per round, merged by the conductor under
`setup-tooling-merge`.

**T3.1 Round one's candidate** (75 min, `runner`, `live-account`). Outcome: the light cut of engine
`0.99.0-rc.5` and the tag `tool/v2.0.0-rc.1`, both on `gate`; `wait.mjs` and `verify.mjs` pass for the
engine, and `npm view create-cairn-site@gate version` prints `2.0.0-rc.1` with the six platform
packages at the same version. Acceptance: those reads. Test: the reads.

**T3.2 Probe, part two** (75 min, `live-account`). Outcome: `run-gate.sh probe` runs `cleanroom probe`
with `scripts/gate/probe-commands.md`: `npm create cairn-site` resolving the `gate` launcher,
`cairn new --plan` then `--apply` with the token and the owner card, the stand-in following the tab,
a build and the dev server in the site folder, a Playwright screenshot of it, and a push to a scratch
branch of the new repository. Then `grade` and the sweep. This is the gate's first live run and
#349's proof, and it confirms #392's routes. Acceptance: the end state's three checks pass, the
record carries every field, and the sweep leaves nothing tagged. On Decide S-1's yes, an unchanged
settings file goes on to T3.3.

**T3.3 The rounds** (615 min for three rounds; at most five naive runs). Each round: `run-gate.sh
naive`, watched and answered as the owner (60 minutes at most, a $20 cap); `grade`; the two lists
written to `research/proving/round-<n>.md` and committed to the initiatives repo; each item fixed in
the round's PRs or filed through `standards:log-issue` (`#initiative:cairn-setup`, or the workstation
backlog for a harness item); the conductor's merge; a light cut when an engine or tool path changed.
The round ends when its fixes are merged and published, or filed. The loop ends at the first naive
run that passes without obvious flailing. A passing run over 10 minutes from the goal prompt to signed
in puts its slowest steps on the setup list and still ends the leg.

**T3.4 The scripted leg** (80 min, `live-account`). `run-gate.sh scripted` on the current candidate,
its fixes as one more round, and #366 to `## Done` when it passes.

**T3.5 The final candidate** (180 min, `runner`, `live-account`). With no other cairn-cms worktree
live (the conductor holds theme-garden launches for it), the `standards:dependency-upgrade` sweep on
`main`: every minor and patch, each major held and listed for the end packet. Then a light cut, the
scripted leg on it, and the naive leg again when the sweep touched a rerun path, both carried into
the release body by `record.mjs`. Acceptance: `verdict.mjs <version>` reports only the missing
`owner` row.

**T3.6 The runbook and the end** (45 min). Outcome:
`~/Projects/initiatives/cairn-setup/research/owner-install-runbook.md`, one page: `cleanroom init
geoff --fresh`; sign a new Chromium profile at `~/.local/state/cleanroom/chromium-test` into GitHub as
`glw907-test` once; `cleanroom shell geoff --open-with "chromium-browser
--user-data-dir=$HOME/.local/state/cleanroom/chromium-test"`; `npm_config_tag=gate npm create cairn-site`
with no token, through the real Cloudflare consent; confirm the Connected Applications path and the
name "cairn" (#403); a five-line friction log; the sweep, plus the deploy key named `cairn-deploy-<run
id>` deleted in the Cloudflare dashboard (no standing token can delete a user token). The executor
writes STATUS, the ledger's totals, and the lists' final state, reports PR-ready to the conductor, and
ends. The conductor sends the end packet and, on Geoff's report, writes the `owner` row.

Chain: T3.1 75 + T3.2 75 + T3.3 615 + T3.4 80 + T3.5 180 + T3.6 45 = **1,070**.

## Stops and standing answers

Approved with this plan; each is applied in place of stopping.

| Stop | Standing answer |
| --- | --- |
| Clock stop: a task past twice its estimate | With the cause traced and the rest in scope, reset `start=` once with `estimate=` the remaining work and record it in `## Decisions`. On a second stop on the same task, the conductor splits the rest into a follow-up task in the same pass or replaces the unit the fixes keep missing. It asks only for a cause it cannot trace |
| Path ceiling (Decide S-4) | Go on while the cause is traced and the chain's actual minutes stay under the ruled ceiling; record the overrun in the score. Past it, or on an untraced cause, the conductor asks with the trace and a recommendation |
| The loop's budget: five naive runs or $100 (Geoff's) | No sixth run and no spend past $100. The executor writes STATUS with both lists, the ledger, and a recommendation; the conductor sends them in a packet. This stop always reaches Geoff |
| A naive run hits $20 or 60 minutes | The harness stops it, the run counts as failed, and the round goes on to its fixes |
| No progress outside an approval for 3 minutes | The executor reads the pane and replies as the owner, or ends the run as a stall (a failed run) |
| A tab page the stand-in can't read or clear in 2 minutes | The run fails with the page's screenshot; the fix is a stand-in change on the test-drive list |
| A run that needs a copy, paste, or relay by Geoff | A tooling failure even if the site comes up (design anti-goal). End the run as failed and fix the harness; never relay to Geoff |
| The sweep's dry run names a missing scope | No delete runs. The conductor brings Geoff the one scope to add to `ws-cairn-cleanroom` as a `[you]` step, and records a planning miss |
| A sweep target fails to delete | The sweep resumes past gone targets on its next run; a run whose sweep did not finish blocks the next run until it does |
| A probe item fails before packet B | Fix the template within `setup-tooling-cleanroom-config` and rerun. A fix the line does not cover goes into packet B as an ask |
| A probe item fails in T3.2 | Decide S-1 |
| The compound-command canary leaks the canary value | Add deny rules for the compound forms around the excluded words (`Bash(cairn *&&*)`, `Bash(cairn *;*)`, `Bash(cairn *|*)`, and the same for the other four) and rerun the probe; if a form still leaks, stop: the conductor asks, since the excluded command is the design's only path to the tab |
| `npm create cairn-site` resolves `latest` despite `npm_config_tag` | Record it; the clean room's environment already sets the variable, so the cause is npm's resolution. The agent is never told a flag. The conductor asks only if no setting reaches it |
| A GitHub page the harness cannot pass (a challenge) | Never defeat a challenge. Rerun once headed; if it holds, the conductor asks Geoff once, and the fix is filed |
| The first Actions deploy fails on a provider outage | One rerun after 15 minutes |
| A publish fails partway | `gh run rerun <id> --failed` on the same release (`cairn-releasing`); a consumed version takes the next `rc` number |
| Auto mode refuses a step a grant line was written to cover | The executor writes STATUS and waits; the conductor brings Geoff the narrowed line as a `[you]` step and records a planning miss |
| A round fix would change the design, or needs a product, taste, scope, or budget call | The executor writes STATUS and waits; the conductor asks |
| The dependency sweep finds a major | Hold it, record its unblock trigger, and list it in the end packet |
| A red on the fast lane or CI | Fix forward or revert the commit. A known trap (`durable-gotchas.md`) reruns once. A red traced to executor reasoning moves the next task to `high` |
| A merge gate in `setup-tooling-merge` fails | No merge; fix forward and rerun the gate. An `escalate` stops: the conductor asks |
| A found item outside the task | `standards:log-issue`, tagged `#initiative:cairn-setup`, listed in the PR |

**Judgment calls the run can plausibly meet, with answers:** file and function names under
`scripts/gate/` and in `cleanroom` (choose and record); the record's field names (as listed, a rename
recorded); a tab button's accessible name (read it from the page source under `tool/internal/setup/`);
a host the probe shows missing (add it within the grant and record it); an owner-card question the card
does not answer (a reasonable owner's answer, recorded); whether an item belongs on the setup list or
the test-drive list (where the fix lands decides it).

**Items the run may escalate without breaking its outcome** (after a structural fix fails): the
per-screen screenshots of the scripted leg (its end state stays), the statusline-against-transcript
cost check (the statusline figure stays), and the probe's dev-server and screenshot items. An
escalated item drops its acceptance criterion with it. **Not escalable**: the token option, the tag
default, the sweep's scope probes and resume, the mailbox's error rule, the canaries, the caps, the
release rule, and the per-round time comparison.

## Later, not planned here

- The site-rebuild skill, after its own brainstorm. It reuses `cleanroom` unchanged; the design's "For
  site-rebuild later" carries its notes.
- #369's recut mode, if a recut of the same version is ever needed.
- Setup's theme question (theme-garden step 4) changes the owner card when it lands.
- The stable cut and the tool's stable tag, after Geoff's install passes (`cairn-releasing` steps 8
  and 9).

## Planning misses at design

The design was approved in chat (session cairn-cms-69, 2026-11-09) without four things `pass-core`
asks a design to carry: the scoped backlog sweep with a verdict per item, an estimate in path minutes,
the pre-flight list, and standing answers for the stops it foresaw. This plan supplies all four, and
its pre-flight items 3 to 5 and Decides S-1 to S-4 ride the conductor's next packet before the first
launch. The miss repeats theme-garden's of 2026-11-08, whose fix landed in `approval-packet` (a design
part without the three is not sent). That fix could not catch this one, because a chat approval
never reaches a packet, and `pass-core` step 1 already says a design is approved through a packet,
never in chat. The fix that generalizes is a check where the planner starts: T1.5 has
`claude-launch-guard` deny a planner launch whose design lacks a sweep, an estimate, or a pre-flight
section. Pass 1's PR carries it, and pass 2's PR copies this entry into its `## Planning misses`.

## Review
