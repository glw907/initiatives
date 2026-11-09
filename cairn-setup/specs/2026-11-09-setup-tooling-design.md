# Proving cairn setup: the release tooling

Approved by Geoff in chat, 2026-11-09 (session cairn-cms-69).

## Brief

The six `cairn new` passes are merged on cairn-cms `main`, and no release carrying them can be cut
until tooling proves that setup works. The old release gate still drives the retired
`create-cairn-site` wizard (`scripts/gate/legs.mjs`). Every test the six passes added runs offline.
Last time, the rc.4 setup of 907.life stopped again and again for pastes, sign-ins, and settings
changes (`research/recon-rc4-tooling.md`, `907-rebuild/plans/2026-11-08-planning-misses.md`).

This design builds the three legs that prove setup, and they run in a fixed order. First, a naive
Claude Code agent starts in a clean room with nothing from this workstation and is told to set up a
cairn site on the test accounts. A conductor session watches it and plays the owner. The loop
repeats, fixing or filing each friction point, until one run gets the site live and signed in
without obvious flailing. Second, a script drives the interactive `cairn new` screens the way an
owner would. Third, Geoff runs his own install on the same test accounts. Nothing is released
until all three pass and their friction is smoothed. Each round also improves the test drive
itself, so later runs cost less and find more.

Every leg tests the binary and packages an owner gets. Each round's candidate is published to
npm's hidden `gate` dist-tag, as rc.1 to rc.4 were, and `latest` never moves. The workstation repo
gets a generic `cleanroom` tool, grown from the 907-rebuild prototype. cairn-cms gets a rewritten
gate, a project skill for the conductor, and one product change: `cairn new` accepts a Cloudflare
API token in place of the browser consent.

### If you approve

1. You do the four owner steps for the launcher and platform packages (`cairn-releasing`, "The
   launcher and its platform packages") before round one, because round one publishes them to
   `gate`.
2. A plan follows, written to `cairn-running-passes`, in three passes: the `cleanroom` tool
   (workstation repo), the gate rewrite with the token option and the skill (cairn-cms), then the
   polish loop.
3. The conductor runs the loop unattended and merges each round's fixes under the plan's gates.
   It stops and reports after five naive runs or $100, whichever comes first. When the naive and
   scripted legs pass, you get a one-page runbook for your install and one packet.

### Worth knowing

- Cloudflare's consent click is tested only by your install. Its dashboard sign-in uses
  Turnstile, and nothing scripts past it, so the automated legs pass a token.
- The token option is new public surface. It also serves owners who run setup from CI, and
  `cairn-judging-scope` reads it before it's built.
- One naive run can spend at most $20, and a run that hits the cap counts as failed.

## Intent

A new owner's agent should be able to read cairn's GitHub repo and set up a working site with no
help from anyone who knows cairn. The only way to know that is to watch an agent that knows
nothing try it. Each try should be cheap and quick to repeat, so finding a friction point, fixing
it, and trying again takes as little of anyone's time as possible. Two things improve together
through the rounds: setup itself, and the test drive that measures it. Geoff's install comes last,
and by then the agent's path is smooth.

## Goals

- Prove the agent path the way any new owner would meet it: a naive agent, the published docs,
  the setup skill, the published packages, the test accounts.
- Make each iteration fast and low-friction: start, observe, grade, sweep, fix, repeat, with no
  sitting.
- Learn how to make a run both useful and efficient, and improve the test drive each round the
  way setup improves (Geoff, 2026-11-09).
- Make setup faster round over round. Each run record times setup end to end and per step, the
  round compares those times with the last, and a faster setup counts as an improvement (Geoff,
  2026-11-09).
- Keep the scripted runs as a fast check for later candidates.
- Build `cleanroom` so a later site-rebuild skill can reuse it unchanged.

## Non-goals

- The site-rebuild procedure for Geoff's real sites, which waits for its own brainstorm. The
  notes it needs are in "For site-rebuild later".
- Theme work and content migration. The naive agent sets up a new site and nothing else.
- The product's per-pull-request tests, which the `cairn new` design already covers.
- cairn.pub. It isn't built yet, so the start page is the GitHub repo.
- A without-skill variant. With the repo as the start page, a run already measures whether the
  docs lead the agent to the skill.
- A theme viewer, which belongs to theme-garden. Geoff's ask that it run with no Cloudflare
  account is in G2's T2.3 acceptance (initiatives `f84bef4`).

## Anti-goals

- Any copy, paste, or relay by Geoff during a loop. A run that needs one is a tooling failure,
  even if the site comes up (Geoff, 2026-11-09: "We want to avoid the copy-paste mess we had last
  time").
- A settings change mid-run. The clean room's settings are proven before the first run, and a
  later gap is logged and worked around.
- An error read as an empty result, such as a mailbox query that fails and reports no messages.
- Over-engineering. Each part is the smallest thing that does its job, and anything the existing
  prototype or gate already does is reused.
- A naive agent that knows anything from this workstation: no CLAUDE.md, memory, skills, secrets
  stores, or `~/Projects`.
- A test-only build or hook in any leg. Every leg runs what an owner installs.

## The three legs

### 1. The naive run

The conductor starts it with one command. The harness sweeps the last run's leftovers (dry run
first) and makes a fresh clean home. Then it starts an interactive Claude Code session in a
recorded tmux pane with one goal:

> Set up a new cairn site and sign in as owner. cairn is at https://github.com/glw907/cairn-cms.

The agent reads the README and whatever it links, installs the cairn plugin if the docs say to,
and runs `npm create cairn-site` or `cairn new`. The clean home's npm config names `gate` as its
default tag, so a bare install gets the round's candidate (see "Candidates"). The conductor plays
the owner, using the `cairn-proving-setup` skill and a fixed owner card: the site name (carrying
the run's id), the owner email `cairn-gate@probe.907.life`, and the AI-crawler stance. It types
replies into the pane, and it answers any permission prompt the way a reasonable owner would.
Every prompt counts toward the friction tally.

The stand-in is a Playwright browser signed in as `glw907-test`. It receives the setup tab's link
through the clean room's `BROWSER` and follows the tab's pages. Each page says what to do next,
so the stand-in clicks that step's button after a short pause, as a person reading it would. It
never depends on the agent's event stream, which only the agent's own tool call can see. The
grader checks separately that the agent passed each `waiting` sentence on, and a missed relay is a
finding. The Cloudflare step needs no click, because the clean room passes the token option.

The run ends in one of four ways: the site is live and the stand-in is signed in to its admin, the
cost cap is hit, the time cap is hit, or the conductor judges a stall hopeless. The grader then
writes the run record, and the sweep runs.

A run passes when the site is live, the owner is signed in, the sign-in email reached the test
mailbox, and the conductor finds no obvious flailing in the transcript. Flailing means repeating a
failing command, circling the docs for something they don't say, asking the owner what the docs
should have answered, or stalling on permissions. Friction points are expected and don't fail a
run (Geoff, 2026-11-09). The record times each step, with the provider waits (the first Actions deploy and HTTPS on the
domain) apart from the agent's own time. A run that passes but takes over 10 minutes puts its
slowest steps on the setup list. One passing run ends this leg.

### 2. The scripted human run

This leg runs after the naive leg passes, and it then stays as the fast check on later
candidates. In the same clean room, a script drives the interactive `cairn new` in a tmux pane:
it types each answer (the email as a bracketed paste), presses Enter through each default, and
lets the stand-in follow the tab. Each claim about a screen rests on a screenshot of the real
terminal, per `standards:tui-visual-verify`. No language model runs in this leg, so it costs
nothing but time. It passes on the same end state as the naive run, with no flailing to judge.

### 3. Geoff's install

Geoff runs `npm create cairn-site` from a clean shell (`cleanroom shell`) on the same test
accounts, with no token. It runs the real Cloudflare consent. The shell's private keyring keeps
the setup grant out of his desktop keyring. Links open in a Chromium profile signed in as
`glw907-test`, never `glw907`. He ends with a short friction log. A one-page runbook, written when
the scripted leg passes, tells him exactly that much.

## The loop

1. Run the naive leg.
2. Close the round with two lists. The setup list holds each friction point in the product, the
   docs, or the skill. The test-drive list holds each place the harness, the owner card, the
   grader, or the conductor's procedure cost time or money, missed something, or needed a manual
   step. Each item on both lists is fixed or filed, through `/standards:log-issue` or a pass.
3. Fixes batch into one pass per round. The conductor merges it under the plan's gates. A docs
   or skill fix is live on the repo once it merges. An engine or tool fix publishes a new
   candidate to `gate`.
4. Repeat until one run passes, then run the scripted leg and fix what it finds, then hand Geoff
   the runbook.

The conductor stops and reports to Geoff after five naive runs or $100 of total spend, its own
included, whichever comes first (Geoff, 2026-11-09). Otherwise a round needs Geoff only for a
ruling only he can make (product, taste, scope, budget). Geoff gets one packet at the end, not
one per round.

Round one's known fixes are #392, #403, #404, and a setup-skill gap: the skill never tells an
agent to run `cairn new` in the background. Run in the foreground, the command blocks until an
approval lands, so the agent can't relay the sentence that would get it approved. None of these
blocks starting.

### Which legs rerun after a fix

The scripted human leg reruns on every new commit, because it's cheap. The naive leg and Geoff's
install rerun only when a fix since their last pass touches setup's code (`tool/` setup paths,
the launcher, the template), the setup skill, or the docs a naive run read. The release publishes
a commit whose scripted leg passed and whose other two legs passed on a commit with no such
change since.

## Candidates

Each round's candidate is the existing prerelease path. The engine publishes to `gate` through
`publish.yml`, and the tool, launcher, and platform packages publish to `gate` through `tool.yml`
on a `tool/v*` prerelease tag. `latest` never moves. A round publishes only what changed: a docs
or skill fix needs no publish, because the naive agent reads both from `main`.

The site's first deploy runs `npm install` on GitHub's runner against public npm, which is why a
local registry can't stand in for publishing. Setup pins the site to the engine version it
fetched, so the deploy installs the candidate.

Setup's template fetch defaults to the `latest` dist-tag (`--tag`, `cmd/cairn/new.go:84`). The
clean room sets npm's tag configuration to `gate`, and `cairn new` reads that setting as its
default when no `--tag` is given, so the agent never passes a flag a stranger wouldn't know. Each
round's cut is a light one, and #369's preflight recut mode is its model.

## The clean room

`cleanroom` lives in the workstation repo as `bin/.local/bin/cleanroom`, grown from
`907-rebuild/tools/cleanroom-run`, its settings, and dotfiles #52's spec. It knows nothing about
cairn. Its forms:

- `init`: a clean home with the shipped settings, and canaries that fail if a workstation path or
  credential is readable.
- `probe`: runs a short Claude session in the clean room, with a scripted command list in place
  of a goal: install the candidate, run the agent lane's plan and apply with the token, build,
  start the dev server, take a Playwright screenshot, and push to a scratch branch. It proves the
  permission and network settings under a real session. Geoff approves the settings file and the
  probe's record once, in pre-flight.
- `run`: starts the interactive session in a recorded tmux pane (`script -q -f` for the log) with
  the goal, the credentials, and a cleared environment. It watches cost and time against the
  caps, and it writes a ledger row.
- `shell`: a clean interactive shell in the same environment, for the scripted leg and Geoff.

Credentials enter only from the age store, and nothing asks for a device code. Claude Code reads a
long-lived token from the store. The stand-in's GitHub session reuses the persistent profile and
TOTP flow in `test-accounts.md`. Each clean home gets a private session bus and keyring, so the
released `cairn` has a working keyring and no tool reaches Geoff's desktop keyring (misses 5 and
13). `BROWSER` hands each link to the stand-in, or for Geoff to the test Chromium profile, and to
the log. It never prints a link for a person to copy.

The conductor observes the run without asking anyone. It reads the pane through `tmux
capture-pane`, tails the session transcript, and reads `cairn new status` in the clean home. It
replies with `tmux send-keys`. Geoff can watch read-only with `tmux attach -r` if he wants to, and
never has to.

## The cairn side

### The token option

`cairn new` gains a documented way to take a Cloudflare API token in place of the browser
consent, through a cairn-named variable or flag, never `CLOUDFLARE_API_TOKEN`. The old gate hid
the OAuth path by always setting that one (recon item 1). The event stream and the summary say
the token was used. It goes into `cairn help agents` and the agent docs, and `cairn-judging-scope`
reads it first.

### The gate

The gate under `scripts/gate/` is rewritten around `cairn new`. It keeps `browser.mjs`'s GitHub
driver, `totp.mjs`, the record and verdict files, and the teardown, and it retires the wizard's
legs. Its parts:

- the stand-in: follows the setup tab's pages and clicks each step's button;
- the mailbox reader: JMAP against `cairn-gate@probe.907.life`, selecting by sender, subject, and
  time, with every method error a failure;
- the sweep: run-tagged, dry run first, and it checks each API family's write scope before it
  deletes anything (miss 1), and resumes past targets already gone (miss 2). It removes the repo,
  the Worker and its custom domain, the database, the bucket, the DNS records setup created, and
  the tokens setup minted. It deletes the GitHub App through its settings page as `glw907-test`,
  because GitHub has no API for that.
- the grader: reads the transcript and `cairn new status`, and writes the run record, including
  the harness's cost and overhead for the test-drive list;
- the scripted human leg.

### The skill and the release rule

A project skill, `cairn-proving-setup`, holds the conductor's procedure: starting a run, playing
the owner from the card, judging flailing, reading the record, keeping the two lists, and the
budget stop. `cairn-releasing` gains the release rule in "Which legs rerun after a fix". Each docs
gap is fixed or filed, and provider-facing copy is fact-checked before the cut.

## Failures and limits

| Limit | Value | When it's crossed |
|---|---|---|
| Cost of one naive run | $20 (Geoff, 2026-11-09) | The harness stops the session. The run fails, and the record says where the cost went. |
| The whole loop | five naive runs or $100, conductor included (Geoff, 2026-11-09) | The conductor stops and reports to Geoff with both lists. |
| Wall time of one naive run | 60 minutes | The harness stops the session. The run fails, and the record names the step it reached. |
| Wall time of a passing naive run, goal prompt to signed in | 10 minutes | Geoff, 2026-11-09: "It's hard to imagine a successful setup taking more than 5 or 10 minutes." A pass that takes longer goes on the setup list as a friction item, with the record's time per step. |
| No progress outside an approval | 3 minutes | The conductor reads the pane and decides: reply as the owner, or end the run as a stall. |
| A tab page the stand-in can't read or clear | 2 minutes | The run fails, and the record carries the page's screenshot, never one showing a secret. |
| Harness overhead per run (sweep, home, start) | 5 minutes | An item on the test-drive list. |
| The scripted human run | 20 minutes | The run fails at its step. |
| A sweep target the token can't delete | n/a | The dry run fails before anything is deleted, and names the missing scope. |

Runs are sequential, because every run uses the bare `carin-test.org` and `www` address. A run
whose sweep did not finish blocks the next one.

## For site-rebuild later

`cleanroom` stays generic, so a site-rebuild skill reuses `init`, `probe`, `run`, and `shell` as
they are. The pieces it adds are its own: real accounts in place of the test accounts, a retire
step before setup, the theme from the catalog, the real content, and the domain attached last
(miss 15). The owner card, the stand-in, the run record, and the two lists carry over as
patterns. Outside mail checks go through the Gmail connector (miss 4).

## Decided by Geoff

All on 2026-11-09.

- The agent path is confirmed by a naive agent with the setup skill, on the test accounts, so it
  matches any new owner's experience.
- The scripted run stays as a fast check for the future.
- The order: naive runs until one passes without obvious flailing, then the scripted human run,
  then Geoff's install on the test accounts.
- Friction points are expected. The goal is to find and smooth them.
- The conductor needs an easy way to observe and interact, with no copy-paste mess.
- $20 is the cap per run, and the loop stops after five naive runs or $100.
- A naive run may go 60 minutes, but a successful setup should take no more than 5 to 10.
- A faster setup is an improvement, tracked across rounds.
- Each round's candidate publishes to npm's `gate` dist-tag.
- The start page is the GitHub repo, since cairn.pub isn't built yet.
- Site-rebuild waits for its own brainstorm, with notes kept here.
- The theme viewer's no-Cloudflare requirement goes to theme-garden.
- A release only when everything is fully tested and polished.
- Fast, low-friction iterations, no over-engineering, and the test drive improves each round
  alongside setup.

## Claude's calls

- Every leg runs the published packages, with no test-only build, so the token becomes a
  documented option (contestable: it's new surface, and the scope check runs first).
- `cairn new` takes its default template tag from npm's tag setting.
- The clean room gets a private session bus and keyring, in place of a dead bus.
- The stand-in follows the setup tab's pages rather than the agent's events. The grader checks
  relays separately.
- The probe is a real Claude session with a command list, so it proves the settings.
- No without-skill variant.
- The conductor merges each round's fixes under the plan's gates. Geoff gets one end packet.
- Which legs rerun after a fix, as stated in the loop.
- `cleanroom` is a stdlib Python script, per the tool-language rule and dotfiles #52. It moves to
  Go only if it needs a package or a second file.
- Runs are sequential on the bare test address, swept between runs.
- The time, stall, page, overhead, and scripted-run limits in the table, and the split of provider
  waits from the agent's own time in each record.

## Left to the builder

- How the session reads its running cost. Check the source against a known turn before trusting
  it (miss 11).
- Which long-lived credential Claude Code takes in the clean home, minted once and kept in the
  age store.
- Whether npm passes its tag setting to the `cairn` process it launches, or the clean room sets
  it in the environment as well.
- Which keyring daemon backs the private session bus, proven by the probe.
- Whether setup mints its deploy key from the supplied token, and which scopes the token needs.
  Check the gate token's scopes first.
- The token option's name, the run record's fields, and the light cut's version numbering.
- The network allowlist the probe proves, covering GitHub, npm, the Cloudflare API, the test
  zone, and Anthropic.

## Sources

- `research/handoff-tooling.md`: the scope and the settled test shape.
- `research/recon-rc4-tooling.md` and `research/prior-art-setup-testing.md`.
- `~/Projects/initiatives/907-rebuild/plans/2026-11-08-planning-misses.md` and the two friction
  files beside it.
- `specs/2026-11-08-cairn-new-design.md`.
- `~/.claude/docs/test-accounts.md`.
- conductor-cairn-cms's read of the gate and test state, 2026-11-09 (main `9a193ca13`).
- The builder check on this design's first draft, 2026-11-09.
