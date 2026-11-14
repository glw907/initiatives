Initiative: theme-garden

# Theme catalog 1: the plan review

One `standards:plan-reviewer` read of `2026-11-14-theme-catalog-1-plan.md` on 2026-11-14, against
cairn-cms at `839232fe9`. The planner checked the two blockers and findings M1, M3, and M5 against
the code before folding. Every finding below is folded into the plan unless it says otherwise.

## Blockers

- `npm test` can't include `test:catalog`: `workflow-yaml.test.ts:182` pins the chain to the two
  Vitest scripts. `test:catalog` is now a script, a lane leg, and a `test.yml` step.
- New `test.yml` steps fail `gate-tier.test.ts:744` unless the gate tier names them. C1.8 now edits
  `scripts/checks/gate-tier.mjs` and both tests.

## Changed what a task builds or checks

- C1.1's gate-table edit needed a row in `gate-tier.test.ts`, and its lane check passed on the
  unchanged table. The check is now a test case that fails today.
- `semver` was installed in C1.6 and needed from C1.1, and two paired tasks edited `package.json`.
  C1.1 now installs all three dev dependencies.
- The showcase's menus link to `/admin`, which a demo answers with 404. The demo build removes
  those entries.
- The index read had no outcome for a 5xx or a bad body, either of which could erase the catalog.
  It is now an S3 read where only a missing key means empty.
- The version-rise check couldn't receive its range as a lane leg. It has a default range, and CI's
  two ranges are written out.
- The pre-flight probe covered one of the run's requests. It now covers each, with the lock's reply,
  and its recorded replies seed C1.6's fake bucket.
- The proving environment's branch rule would have refused pull request runs, and the check couldn't
  show the `main` rule. Both are rewritten.
- Also folded: the workflow's setup steps, its dispatch target, the Dependabot skip, two more
  trigger paths, variables in place of a hard-coded Worker name, a committed archive digest, the
  ustar fields, a `tar -tzf` read, a cross-origin fixture and a viewport check for the reference
  page, the set manifest's name and schema, accepted `engine` cases, the C1.8 reads written out, a
  short cache time on proving, `preview_urls` off, a rule for a shared proving target, a row for a
  proving run that can't go green, and a floor on review rounds.

## Not folded

- Whether Go's `archive/tar` reads the hand-written archive is proven in the installer pass, which
  writes that reader. This pass proves it with system `tar`.
- The reviewer could not verify that an Editor token deploys with a `routes` entry, how an
  account-owned R2 token's S3 key pair is issued, or that actionlint accepts an `environment` set
  by an expression. Pre-flight item 5 proves the first two. The third is the executor's to find,
  and two jobs with fixed environments is the fallback.

## Replies recorded at pre-flight

The pre-flight session adds the raw replies from item 5 here.
