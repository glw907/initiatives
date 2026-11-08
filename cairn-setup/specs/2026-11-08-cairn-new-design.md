# cairn new: site setup

## Brief

The 0.99.0-rc.4 setup of 907.life failed. You called `npm create cairn-site` "way too manual,
user-hostile, and fragile", and the clean-room builders who tried it could neither finish it nor
find what they needed before a site existed. Over this brainstorm you set the bar: the lowest
friction a new owner can have, at the web admin's UI and UX standard, easy for an agent to drive,
and as lean as quality allows.

Approving this design replaces the JavaScript wizard with `cairn new`, a command in the existing Go
`cairn` tool. An owner answers a few questions in the terminal, then clicks four approvals in one
browser tab, presses Enter once, and can walk away. Setup creates the repository, the GitHub App,
the Worker, the database, the storage bucket, and email on the owner's domain. It deploys through
GitHub Actions and signs the owner in. The same steps run for an agent through flags, a plan file,
and an event stream. The work also rebuilds the setup docs, adds a Claude Code setup skill and
plugin, and replaces the trail demo with a small standard starter set. `npm create cairn-site`
stays as a thin launcher for the binary.

### If you approve

1. A plan follows, written to `cairn-running-passes`, with the outside-in tests first.
2. The work runs as passes on cairn-cms, plus one small pass on cairn-pub for markdown copies of
   the docs pages.
3. The theme catalog gets a separate brainstorm in parallel. `cairn new` ships offering Waymark,
   and its theme question lists whatever the catalog holds later.
4. A tooling brainstorm in a fresh session designs the release gates that prove setup: the
   real-account leg, the naive-agent run, and the clean room. No release with `cairn new` is cut
   until they exist.

### Worth knowing

- A domain already on Cloudflare and the Workers Paid plan are both required. There's no
  workers.dev path.
- Deploys use GitHub Actions. A private repository on GitHub's free plan gets about 2,000 minutes a
  month, roughly 650 deploys. The docs explain how a busy site moves to Workers Builds by hand.
- GitHub has no API to create or install an App, so every run from zero needs a person for three
  clicks. Cloudflare's consent can be replaced by an API token, which is how tests run.
- Content migration is out of scope. It goes on the roadmap as a possible later feature.

## Intent

A new owner should get from "I want a cairn site" to "I'm signed in to my live site" with as few
decisions, window switches, and waits as the providers allow, and without ever meeting a failure
they can't understand. The terminal teaches gently: it says what each step does and why, and it
opens the browser by itself. The result is a clean new site with a standard starter set, a theme
from the catalog, and an agent that's ready for the first real task.

## Goals

- One opening collects every answer and every approval and ends on one summary with a single
  "go". After that, the owner only watches, or leaves.
- Every failure that can be checked is checked in the opening. A failure while watching is a cairn
  bug.
- A rerun resumes. Nothing locks the owner out.
- Two first-class lanes over one set of setup steps: a person at the terminal, and an agent with a
  plan file. They differ only in who supplies the answers and the approvals.
- The terminal UI meets the admin's bar: the house register, one layout grid, and every Charm
  lever used toward clean, simple beauty, with the prose and the visuals aligned.
- The docs in the cairn repo are the single source of truth for every setup surface.

## Non-goals

- Migrating content from another site or CMS.
- A workers.dev or preview path for owners without a domain.
- Workers Builds as a setup option. A busy site switches by hand, following the docs.
- A switch command, an undo command, or any mode only a minority needs.
- GitHub organizations. Setup supports personal accounts, and the docs say so. Organization
  support is a noted future addition, filed on `ROADMAP.md`.
- Agents other than Claude Code. Plain markdown docs cover others without being designed for them.
- The theme catalog, the conformance corpus, and the theme comparison on cairn.pub. Those belong
  to the theme catalog project.
- The release gates that prove setup. Those belong to the tooling brainstorm.

## Anti-goals

The design has failed, even if every step works, when any of these happens:

- the owner copies a URL, pastes a token, or reads a wall of streamed output;
- a step fails with no explanation, or an error reads as an empty result;
- the owner can't tell which window wants them;
- the stock demo reaches a live domain;
- a sign-in link, token, or key appears in output, a log, or a screenshot.

## The owner

The owner is comfortable in a terminal. They probably have a GitHub account but no repository for
the site, and may have no Cloudflare account. Most make one site. They probably read cairn.pub's
before-you-start page first, and the welcome screen points there in case they didn't.

## Prerequisites

The before-you-start page lists each prerequisite, linked to the provider's instructions:

- a GitHub account;
- a Cloudflare account. "Continue with GitHub" on Cloudflare's sign-up works. Only the in-form
  Sign up link keeps the return path;
- the Workers Paid plan, $5 a month;
- git and Node 24 on the computer that runs setup. Setup leaves a working copy of the site there.
- a domain already on Cloudflare, either registered there or added from another registrar. Adding
  one changes its nameservers, and activation can take hours. The page links Cloudflare's guides
  for both.

The domain is required because Email Sending needs a domain on Cloudflare DNS, and without email
nobody can sign back in or invite an editor. The opening checks each prerequisite. A failed check
names the section of the page to read, and the next run resumes there. A zone that's still pending
says so.

## The flow

The prototype in `research/prototype/` shows every screen, and the review page in
`research/review/` shows each one at 80 and 60 columns in both themes. The copy deck,
`research/copy-deck-final.md`, holds every string. The layout grid, `research/layout-grid.md`, is
binding. Setup runs inline, not full screen, so the final frame stays in scrollback. The minimum
window is 50 columns. A window that's too small says so, with the size it needs.

1. **Welcome.** It says what setup does, that the owner approves four requests in the browser, and
   that they need a domain on Cloudflare and Workers Paid. It links the before-you-start page. Over
   SSH or in a remote session, setup says to run `cairn new` on the computer you browse with, and
   stops.
2. **Questions in the terminal.** The site name, with the repository name previewed live, and the
   AI-crawler stance. The theme question appears only when the catalog holds more than one theme.
   With Waymark alone, the summary shows the theme with its one-line description: "An
   intentionally neutral look that's easy to edit." No brand color, and no "do this now?"
   confirmations.
3. **"Press Enter to open your browser."** Setup opens a local loopback page once. Every approval
   chains in that one tab, and each page says what happened and what's next.
4. **Four approvals.** See the next section.
5. **The account and domain questions.** A Cloudflare account question appears only when the
   owner has several accounts. The domain question appears only when the account has several
   active zones. It's a separate short
   step, which fits 60 by 24 with five domains.
6. **The summary.** Every derived value with a one-line reason, such as "based on your site name".
   The repository, Worker, database, and bucket names are read-only, because the repository already
   exists by then. A taken repository name gets a suffix, and the summary says why. Two rows are
   editable: the sign-in email, and the site's address. The address defaults to the bare domain
   plus `www`, and the owner can change it to a subdomain of the chosen zone, such as
   `blog.example.com`, which gets no `www`. It comes from the Cloudflare account. A "Deploys" row states the
   Actions limit and links cairn.pub's deploys page.
7. **One Enter.** That's the only "go".
8. **The watch.** A fixed plan of eight steps ticks off. Only the current step shows its sentence.
   There's no streamed output. The screen says the owner can leave.
9. **Done.** The live URL, that the owner is signed in, that a sign-in link also went by email, and
   three next steps.

The two browser pages, `done.html` and `error.html`, are in `research/prototype/pages/`.

### The watch plan

1. Create the database.
2. Create the storage bucket.
3. Set up email on the domain.
4. Push the site to GitHub.
5. Store the deploy key in GitHub.
6. Run the first deploy.
7. Connect the domain and wait for HTTPS.
8. Sign in to the admin.

Setup writes the site from the template into a local folder named for the repository, in the
directory where `cairn new` ran. It commits there with the repository as `origin`, and step 4 pushes
from that folder. While the first deploy runs, setup installs the site's dependencies in the folder,
so the owner's agent can start work at once. The copy deck adds one sentence for this to step 4.
Every Cloudflare write goes through the API. Wrangler runs only in the Actions job.

The template comes from the npm registry at run time. Setup downloads the engine's published
package at its `latest` dist-tag, checks npm's integrity hash, and writes the site so it pins that
engine version. A flag picks another dist-tag for release-candidate testing. The tool and the
engine keep their separate release lines, and the tests use a packed local tarball. Waymark's
template lives in the engine package today, and the theme catalog adds entries the same way.

## Approvals

All four run in one loopback tab, in this order. Cloudflare goes first so the domain check runs
before anything exists on GitHub.

1. **Cloudflare OAuth consent: "Allow".** A cairn-owned public client, authorization code with
   PKCE, on a loopback redirect. API Tokens Write is a sensitive scope the owner has to tick. Setup
   checks the granted scopes and asks again on the spot if one is missing. Proven on a private
   client (`research/spike-cloudflare-oauth.md`).
2. **GitHub App from a manifest: "Create".** The manifest asks for `administration: write`,
   contents, metadata, workflows, and secrets write. A signed-out owner signs in mid-chain and lands
   back on Create. Proven (`research/spike-github-app.md`).
3. **A plain install on all repositories: "Install & Authorize".** Setup uses the user token to
   create the repository, then deletes the all-repositories install with the App JWT within about
   five seconds.
4. **An install preselected to only the new repository: "Approve, Install & Authorize".** Setup
   reads back `repository_selection: selected` with exactly that repository, and refuses an
   over-grant. The installation token pushes the site and its workflow. Proven 4 of 4 runs.

Two tradeoffs come with this chain. An all-repositories install exists for about five seconds.
`administration: write` stays on the App for the repository's life, though the Worker requests
content-only installation tokens. Dropping it would cost one more approval.

The whole chain has a 30-minute limit, with a countdown in the last five minutes.

## After consent

Setup mints short-lived, narrow Cloudflare tokens from the OAuth token, and wrangler takes them as
`CLOUDFLARE_API_TOKEN`. There's no `wrangler login`. Every OAuth refresh revokes the old access
token, so setup persists each new pair at once and never hands a superseded token to a subprocess.
A token minted for Workers Scripts Write is needed to create a new Worker. The OAuth token alone
can't. OAuth tokens live in the keyring, through `tool/internal/secrets`, only while setup runs.
Setup revokes and deletes them when it finishes. Nothing is kept for a second site. Each site gets
a GitHub App of its own.

## Deploys

Each push runs one GitHub Actions job: install, check, build, then `wrangler deploy`. A concurrency
group cancels a deploy that a newer push supersedes. The deploy key is a narrow, long-lived
Cloudflare token with the scope of today's "cairn-build" token (Workers Scripts, D1, R2), minted
from the OAuth grant. The App stores it as a repository secret, sealed to the repository's public
key. GitHub emails the owner about a failed run by default. The admin doesn't show deploy status, and
the App asks for no Actions permission. An admin view of a failed deploy is a backlog item.

The cost is GitHub's free Actions allowance on private repositories: about 2,000 minutes a month,
roughly 650 deploys at an estimated three minutes each. When it runs out, deploys stop until the
month resets. Public repositories are unlimited. Workers Builds includes 6,000 minutes with Workers
Paid. A new docs page records this decision and explains how a busy site moves to Workers Builds by
hand.

## The sign-in

The engine keeps one live sign-in link per email and expires it after 10 minutes
(`issueToken` in `src/lib/auth/store.ts`, `TOKEN_TTL_MS` in `src/lib/auth/crypto.ts`). Setup works within that, with no
change to the engine's auth code. When the site is live and the setup tab is still open, setup
issues a link and the tab redirects through it at once, signed in. Then setup asks the live site
to send its ordinary sign-in email, which issues a fresh link. If the owner walked away, that link
may have expired by the time they read it, so the email says to sign in again from the site's
sign-in page. The done screen and the copy deck say "Setup also sent a sign-in email" and promise
nothing about how long it lasts. The link never appears in the terminal, in agent output, or
in a log. If the email doesn't arrive, the site's ordinary sign-in page sends another.

## Failures and limits

A failure reads in four parts: what happened, why, what setup already did, and what to do. The
copy deck's Workers Paid failure is the model. A rerun resumes from the last completed step.

| Limit | Value | When it's crossed |
|---|---|---|
| The approval chain | 30 minutes, with a countdown in the last 5 | Setup stops. Nothing outside the completed approvals exists. Rerun resumes. |
| HTTPS on the domain | 15 minutes | The four-part failure. Rerun resumes at the domain step. |
| Minimum window | 50 columns, and each step's row count | The too-small screen, until the window grows. |
| Ctrl+C before anything exists | n/a | "Setup stopped. Nothing was created." |
| Ctrl+C after | n/a | "Setup stopped. To resume, run cairn new again." |

Setup finds an unfinished run by its record in the tool's store, not by a directory flag. Today's
wizard keys resume on `--dir`, which is its main weakness (`research/recon-core.md`). With one
unfinished run, `cairn new` resumes it. With several, it asks which one.

A run where the App exists but its install never finished resumes at the install. Setup stores the
App's id and key as soon as the manifest converts, so the rerun reopens the install page for that
same App.

## The agent lane

The agent lane runs the same setup steps with a different view:

- flags for every answer, and a plan file through `cairn new --apply plan.json`;
- a `--plan --json` dry run that lists every derived name and every step;
- an NDJSON event stream: step started, done, and failed, waiting, resumed, and a final summary;
- stable exit codes, in a table documented in `cairn help agents`;
- named waiting states for the four approvals. Each one carries the exact sentence the agent shows
  the person, such as "In the setup tab, select Create." The run blocks until the callback lands.
  A killed run resumes like any other.
- a status command that reads the progress of a run, including one the agent didn't start.

The agent lane runs in two calls, the way `terraform plan` and `apply` do. `cairn new --plan
plan.json` runs the questions from flags and the four approvals, then stops where the summary
would appear. It writes the full derived plan to `plan.json`, including the account's domains when
there are several and the email taken from the Cloudflare account. Nothing exists on Cloudflare
yet. The agent shows the plan to the person, fills in any choice it lists as open, and runs `cairn
new --apply plan.json`. That second call is the summary's single Enter, so a person reviews the
names and the email in both lanes before anything is created. An unanswered required field in a
non-interactive run is a usage error that names the flag, never a prompt. Run without a terminal,
`cairn new` with no plan prints the agent guide, whose first step is installing the cairn plugin.

## Architecture

`cairn new` lives in the Go tool under `tool/`, which ADR-0001 governs:

- a spine package, for example `internal/setup`, holds a pure planner and a runner. `Plan(Answers)`
  returns every derived name and every step with its actor. The runner takes injected provider
  clients and emits typed events. It does no printing and asks no questions.
- `tool/internal/providers` gains the write surface setup needs. Today it's read-only.
- two views consume the same event stream. The Bubble Tea view maps events to messages through a
  command, and the agent view writes NDJSON.
- the Bubble Tea, Huh, and Bubbles dependencies need an ADR-0002-style addendum, and
  `render/purity_test.go`'s count of direct requires changes with it. This is also the tool's first
  Bubble Tea program, so ADR-0001's deferred component-architecture ADR gets written now: one model,
  with components as plain structs, per `standards:elm-conventions`.
- Fang v2 themes the whole tool's Cobra help and errors in Warm Stone.

`npm create cairn-site` becomes a thin launcher. It installs the prebuilt binary for the platform
through optional dependencies, the pattern esbuild uses, and runs `cairn new`. The JavaScript
wizard under `packages/create-cairn-site` retires, and `MIGRATION-NOTES.md` says so.

## Copy, layout, and look

Every string follows the cairn admin's Voice (Microsoft UI text, professional and restrained) and
the tool's binding copy standard, `tool/docs/design/copy-standard.md`, including its messages
tables, `make check-copy`, and section 2.7's error grammar for agent-mode stderr. The copy deck is
the starting text. The register editor has passed it.

The layout grid governs every screen: content at column 2, list text at column 4, values at column
20, one blank line between blocks, and footers that hold key hints only. Paragraphs wrap balanced,
and hyphens don't break.

These Charm levers are in use: a window title per phase, the terminal progress indicator through
`tea.View.ProgressBar`, bubbles `help` with `key.Binding` for every footer, a Warm Stone `huh.Theme`,
`Style.Hyperlink`, and balanced wrapping. These are deliberately left out: lipgloss tables and
lists, the stopwatch and timer, `tea.Println`, notifications, the bell, animation, mouse, and faint
text.

The prototype met three Huh v2.0.3 limits. Unfocused fields ignore the theme, pages pad to the
tallest field, and descriptions wrap after sizing. It worked around them with a custom theme, one
form per field, sizing before build, and a rebuild on resize. The prototype's code shows each one.

## Starter content

Today every new site gets the showcase's trail demo: 14 posts, 11 of them one-line topic-filter
fixtures, a "trail crew" author page, and a fragment. That demo reached the live 907.life domain.
`cairn new` writes a small, friendly starter set instead, in the house register (cairn's editor
brief over Microsoft):

- a home page and archive page one;
- an About page and an author page;
- a Contact page with a placeholder address the owner replaces. Setup never publishes the sign-in
  email. cairn has no contact form, and a form would be site functionality under the scope charter;
- a handful of short how-to posts, one task each, such as adding a page or inviting an editor;
- one post that shows every element rendering, on the model of Astro's markdown style guide;
- each directive once, one image, and one video.

The set is identical for every theme, so an owner can compare themes on the same pages. Its images
ship with the site and are never hot-linked. Waymark's posts load theirs from Unsplash today. The
topic-filter fixtures move to the showcase and the tests. The conformance corpus for theme authors
is the theme catalog project's work.

## Docs

The markdown docs in the cairn repo are the single source of truth. cairn.pub already renders them
from the installed package, and every other surface derives from them:

- the CLI's no-terminal agent guide embeds the agent page at build time;
- a generator writes the flag and event reference from the setup steps into a docs page, and a gate
  fails when the page and the code disagree;
- the setup skill, the README section, the npm readme, and the site's agent guide link to the docs
  pages and don't restate them.

The pass rebuilds the setup pages under `docs/admin/` from their briefs in the `cairn-writing-docs`
skill: before-you-start, create-your-site, credentials, setup-recovery, own-your-domain, and
troubleshooting, plus any other page that describes the old wizard. It adds these pages:

- setting up with an agent;
- deploys: the Actions limit, and moving to Workers Builds;
- the suggested plugins;
- the generated setup reference.

The GitHub README and the npm readme each open with a short "Setting up with an agent" section. On
cairn.pub, a small cairn-pub pass serves each docs page as plain markdown, stamped with the engine
version it describes. There's no llms.txt, because evidence that agents use it is thin. Content
migration goes on `ROADMAP.md` as a possible later feature.

## Claude Code tooling

Claude Code is the single target agent.

- **The cairn plugin** holds one skill, `cairn-setting-up-a-site`. It's thin: when to use setup,
  the attended start and the unattended run, how to hand each approval to the person, how to read
  events and exit codes, how to resume, and the hard rules, such as never printing a sign-in link.
  It defers to `cairn help agents` for detail and ends by handing off to `cairn-extending-a-site`.
- **A marketplace** named `cairn`, declared in the cairn-cms repo's `.claude-plugin/marketplace.json`.
  The plugin is the only thing an owner or agent installs before a site exists.
- **The scaffold's `.claude/settings.json`** declares the vendor marketplaces and plugins: Svelte
  from `sveltejs/ai-tools`, Cloudflare from `cloudflare/skills`, and daisyUI from
  `saadeghi/daisyui`. Its `.mcp.json` adds the Svelte MCP server. Claude Code offers them when the
  folder is trusted, but plugins from external sources still need one install per person, so the
  setup skill has the agent run those installs as setup's last step. GitHub's plugin isn't in the
  default set.
- **The site's agent guide,** `claude/CLAUDE.md` in the package, gets a plugin section that links
  the plugins docs page.

The site's four packaged skills keep shipping with the engine through `cairn-guidance install`,
versioned with the site's pinned engine. They don't move into the plugin.

## Testing

The product's tests are part of this work and come first in the plan:

- every pull request runs `cairn new` from the built binary and the packed npm launcher, never from
  source;
- agent mode runs end to end against recorded GitHub and Cloudflare responses, with goldens for
  `--plan --json`, the event stream including the four waiting states, and the exit codes;
- every question's every answer goes through scaffold, `cairn-manifest --check`, and a build. That
  alone would have caught #365;
- golden frames at 80 and 60 columns through teatest v2, and a `standards:tui-visual-verify`
  screenshot of the real terminal before any claim about a screen;
- a resume after each approval, and one failure for each provider.

The release gates are the tooling brainstorm's design: one full real run on the test accounts per
release candidate, a naive-agent run with and without the setup skill, and your own install as the
last gate. That install is the only run that tests Cloudflare's consent click, because its sign-in
uses Turnstile and nothing scripts past it.

## Decided by Geoff

All on 2026-11-08 unless marked.

- The domain on Cloudflare is required, with links to Cloudflare's guides. No workers.dev path.
- Deploys through GitHub Actions. The docs explain the limit and the manual move to Workers Builds,
  and setup explains it on the summary.
- Waymark's description says it's an intentionally neutral, easy-to-edit default.
- Every string follows the house register, with no AI tics, on one regular layout grid.
- Every Charm lever is used, leaning toward clean, simple beauty, with prose and visuals aligned.
- Two lanes, human and agent, with the attended start and unattended finish as the best case for
  both.
- Claude Code is the single target. Only the cairn plugin is installed before setup, and the vendor
  plugins are installed at its end. The docs and the process carry the plugin suggestions.
- The markdown docs in the cairn repo are the single source of truth.
- The plan includes the docs fixes and the Claude Code tooling.
- Setup makes a clean new site. Content migration may come later.
- Starter text is in the house register, with a Contact page and an archive, standard across
  themes. A friendly starter set and a separate conformance set.
- `cairn new` first with Waymark, and the theme catalog as a parallel project.
- The site's address defaults to the bare domain and `www`, and the owner can change it during
  setup.
- Personal GitHub accounts only, with organizations noted for a future addition.
- The admin doesn't show deploy status in this work. GitHub's failed-run email covers it, and the
  admin view goes on the backlog.

## Claude's calls

- The flow order: Cloudflare's approval first, names settled before the browser opens, the domain
  question after the approvals.
- Names are read-only on the summary. Only the email and the address are editable.
- No theme question while the catalog holds one theme. Theme options wait for the catalog.
- Agent runs block on waiting states. There's no separate park mode, because resume covers a
  killed run.
- Resume is keyed on the store record, not on a directory.
- Setup never changes a DNS record it didn't create. The opening checks the chosen address, and an
  address that already points somewhere is refused there with what to do. When the owner edits the
  address on the summary, setup checks it again before the Enter takes effect.
- Setup leaves a local working copy with dependencies installed, and wrangler runs only in Actions.
- The template is fetched from npm at the engine's `latest` dist-tag, so the tool and the engine
  keep separate release lines.
- The agent lane is two calls, plan then apply, so a person reviews the summary in both lanes.
- The sign-in redirect happens before the sign-in email, so the engine's auth code doesn't change.
- A Cloudflare account question appears only when there are several accounts.
- The npm launcher uses the esbuild optional-dependencies pattern.
- The four site skills stay in the engine package and don't move to the plugin.
- No llms.txt.
- The design lives in a new initiative record, `cairn-setup`, because the work spans cairn-cms and
  cairn-pub.

## Left to the builder

- Detecting Workers Paid in the opening. No API is known to read the plan. Try the account
  subscriptions API under the OAuth scopes first, then a probe in the opening. The first-deploy
  failure copy is the fallback, and it already exists.
- For a subdomain address such as `blog.example.com` or `docs.example.com`: whether a Worker
  custom domain gets its certificate at any depth or only one level down, and whether sign-in email
  sends from the zone or the subdomain. An address setup can't serve is refused on the summary.
- Whether the Cloudflare redirect accepts any loopback port. Only the registered one was tried.
- Whether a plugin marketplace entry can point at the npm package, so the plugin versions with the
  engine. Otherwise, a `git-subdir` source in the cairn-cms repo.
- Whether a brand-new sending domain's first email lands in spam, and the sign-in email's wording.
- The exit-code table, the event schema's field names, and the schema command's name.
- The starter set's exact pages and copy, within the list above, through the register check.
- Going public with the Cloudflare OAuth client: a name, logo, client URL, and DNS TXT verification.
  The step is permanent.

## Sources

Everything below is in this record's `research/` folder.

- `design-summary.md`: the running notes from the brainstorm.
- `copy-deck-final.md` and `layout-grid.md`: the copy and the grid, both binding.
- `prototype/` and `review/`: the throwaway prototype and the screen review page.
- `spike-github-app.md` and `spike-cloudflare-oauth.md`: the approval spikes.
- `recon-core.md`, `recon-github.md`, `recon-cloudflare.md`, `recon-gotool.md`, and
  `recon-browserless.md`: reads of today's wizard, the providers, and the Go tool.
- `recon-rc4-tooling.md`: what failed in the rc.4 build session.
- `prior-art-compare.md` and `prior-art-setup-testing.md`: how other tools set up and test setup.
