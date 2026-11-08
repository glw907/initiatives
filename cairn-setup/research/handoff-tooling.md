# Hand-off: the setup tooling brainstorm

Geoff asked for a second brainstorm on tooling, in a fresh session. Its job is the tooling that
proves setup, rebuilt around `cairn new`. No release that carries `cairn new` is cut until these
gates exist.

## Launch prompt

> Brainstorm the tooling that proves cairn's site setup, with `standards:brainstorming`. Start from
> `~/Projects/initiatives/cairn-setup/research/handoff-tooling.md` and the design it names.

## Scope (Geoff, 2026-11-08)

- The release gates: the gate's setup legs, the test accounts, backlog #366, and the clean-room
  harness and its settings.
- The Claude tooling that runs those gates: skills, agents, and rules, such as a `site-rebuild`
  skill and a `cleanroom` tool.
- The design already covers the product's tests (offline, per pull request), the setup skill,
  the plugin, and the docs.

## The test shape already settled

- Each release candidate gets one full real run on the test accounts. Playwright clicks GitHub's
  three approvals as `glw907-test`, and an injected Cloudflare token stands in for the consent. It
  waits for the Actions deploy, loads the live site, and signs in through the test mailbox. Every
  resource is tagged with the run and swept afterward. Publishing waits for a pass on that exact
  commit.
- A naive-agent run on each release candidate, with the goal "Set up a new cairn site and sign in
  as owner" and nothing else: no migration, no theme. It reads only cairn's published docs in a
  sandbox with a clean home, is graded by a script, and records turns, stalls, and each docs gap
  with its page. It runs once with the setup skill and once without. Each docs gap is fixed or
  filed before release.
- Geoff's own install stays the last gate. It's the only run that tests Cloudflare's consent click,
  because the dashboard sign-in uses Turnstile and nothing scripts past it. It ends with a short
  friction log.
- Two gate rules: an error is never read as an empty result, and provider-facing copy gets a fact
  check before a cut.

## Inputs

- `recon-rc4-tooling.md`: the rc.4 build session's tooling failures, ranked, with the wins to keep.
- `prior-art-setup-testing.md`: C3, create-next-app, Shopify CLI, Supabase, Vercel's evals,
  quickstarted, and agent-eval practice.
- `~/Projects/initiatives/907-rebuild/plans/2026-11-08-friction-builder-A.md` and `-B.md`.
- `~/Projects/initiatives/907-rebuild/plans/2026-11-08-planning-misses.md`.
- The `cairn new` design: `../specs/2026-11-08-cairn-new-design.md`.
- Never use the `glw907` account for tests, never touch the Cloudflare Workers and Pages GitHub App
  installation on `glw907-test`, and never defeat a bot or Turnstile challenge.
