# P5 whole-branch reviews (cairn-cms PR #205, branch cairn-new-5)

Reviewed heads: `283abd62b` (first round), `a3aac47b5` (second fact-check), final head `23cb04d62`.

## standards:diff-reviewer, whole-branch (on 283abd62b): fix, folded in `8716a9fb3`

- Blocking, SKILL.md: the plan step told an agent to pass the open-choice flags again after `--plan`,
  which starts a second setup with `--new`. Folded: give known choices on the first `--plan`; an open
  choice is edited in the plan or finished with `--resume <id> --account <a> --zone <z>`; never `--plan`
  again or `--new` to change an answer.
- Blocking, SKILL.md: the "never print a sign-in link" rule left out the stderr fallback when no browser
  opens, which blocks the run to exit 2. Folded: hand that one-time link to the person, keep it out of
  any log.
- Non-blocking, noted in the PR body: the relative `./plugins/cairn` source (valid; a bare-URL marketplace
  add would not resolve it), no plugin `version`, the `cairn new` output change, BACKLOG #405's
  wording (folded), `headingSlug` dropping `_` (today's headings unaffected), the README's
  `npx create-cairn-site` (declared launcher deferral).
- Checks it reran: go tests, plugin-manifest tests, transcript gate, check:template, docs gate, plugin
  validate; the four captures match the built binary byte for byte; each acceptance test fails when its
  subject drifts.

## docs-fact-checker, pass 1 (on 283abd62b): folded in `bd5e6382e`, `505b78b98`, `4a11e293b`

Five wrong claims (create-your-site step order and installation read-back and resume list,
set-up-with-an-agent `ownerEmail`, deploys App access and the Workers Paid sentence, setup-recovery
"retries once") and about a dozen imprecise ones, all corrected against the code. The code never
raises `ReasonWorkersPaid`, so every page says a missing plan shows only as a failed first deploy that
names no cause (filed as BACKLOG #404).

## docs-fact-checker, pass 2 (on the folded lines, `a3aac47b5`): folded in `23cb04d62`

0 wrong, 4 imprecise (all fixed), and 8 unsupported claims that are vendor facts no repo code settles:
GitHub Actions billing figures, Workers Builds limits and token form, Cloudflare Email Sending's DMARC
onboarding (from `research/recon-cloudflare.md`), the daisyUI marketplace's paid plugin, and Claude
Code's marketplace behavior. Two unsupported lines that were not vendor facts were cut or softened.
The declared deferral: five sentences say `npm create cairn-site` installs the binary and runs `cairn new`
(P6 builds the launcher).

## cairn-register-editor (on 283abd62b): fix, folded in the three fold commits

25 findings. Folded: sentences over the 26-word cap, procedures in prose made numbered lists, the
engine-internal names removed from troubleshooting, bare `cairn` named as the CLI, the duplicated
"Sign in again" section replaced by a link, intros that listed headings, idioms. Not folded, with
reasons in the PR body: two troubleshooting heading renames (inbound links pin their slugs),
`set-up-with-an-agent.md` kept for two readers (it is the embedded agent guide), `credentials.md`
kept as one page (a test pins its scope bullets).
