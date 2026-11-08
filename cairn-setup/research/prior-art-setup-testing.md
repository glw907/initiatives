# Prior art: proving "new project from zero" works (research, 2026-11-08)

Verified from CI files or source unless marked.

- create-cloudflare (C3): e2e groups cli, workers, frameworks; keystroke-driven prompts; deploy
  opt-in with a token against a dedicated test account; frameworks group gated (merge queue,
  label, release branch); a 2-hourly cleanup sweeper; a pass only on retry is a reliability bug.
- create-next-app: tests the packed tarball, not the source tree.
- sv create: scaffolds with add-ons and drives them in Playwright on every PR. No deploy.
- Shopify CLI: closest match. Local project needs no credentials; remote project on a dedicated
  e2e org, Playwright does the browser OAuth login once per shard; run-tagged names; cleanup only
  deletes its own run's resources.
- flyctl preflight: real CI org, PRs plus every 2 hours, run-ID prefixes, cleanup workflow.
- Supabase CLI: live e2e against staging; a release gate that requires a live pass on the exact
  SHA; smoke tests against published packages.
- Headless OAuth: token injection is the dominant pattern; the consent click is tested once,
  separately, or not at all. GitHub App manifest and install have no API; a machine account may
  run Playwright.
- Agent onboarding evals: Vercel CLI evals (weekly, non-blocking, PROMPT.md plus EVAL.ts that
  checks the real result, with and without skills, logged-in and not); quickstarted (docs-only
  via a read_docs tool, sandboxed egress, script-graded outcomes such as passed and docs_gap,
  repeats); Microsoft AX articles (the sandbox decides an eval's worth; grade the user's success);
  Anthropic's agent-evals guidance (code graders gate, transcripts debug, pass^k); Mintlify's
  llms.txt benchmark (vendor numbers).
- First-run methods: time to first hello world; friction logs (Stripe, Google); cognitive
  walkthrough; fresh-account dogfooding.
- Lean: a small fast group per PR, a larger matrix behind a gate; retries are a failure signal;
  costs are wall time, leftovers, and scripted logins breaking on provider redesigns.
