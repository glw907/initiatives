# Review: PR glw907/cairn-cms#212, the rc.5 cut (setup-tooling round one)

Whole-branch `standards:diff-reviewer`, head `5e8c293e6`, base `ddd0c21e2`. Verdict: accept, no blocking findings.

The fold (`65cf6dd5e`) moves the `## Unreleased` window of `CHANGELOG.md` and `MIGRATION-NOTES.md` under
the rc.4 heading as `### Since rc.4`. Every line pairs with a moved line, the duplicate release-size marker
is the one line dropped, and the `Consumers must:` count is 5 before and after. The bump (`5e8c293e6`)
touches exactly the seven files `bump.mjs` writes, and the rc.5 section holds one marker.

Non-blocking:

- `package-lock.json` bumps the `packages/create-cairn-site` entry to rc.5 while its manifest stays at rc.4
  (the launcher versions with the tool). `bump.mjs` replaces four lockfile lines blindly and requires four.
  Installs are unaffected. Filed with the round's list.
- The rc.4 deploy-step bullets in `MIGRATION-NOTES.md` now follow the "Since rc.4" prose with no heading. Wording only; left for the stable's notes pass.
- `bump.mjs` skips its version argument when no `--date` is given. Filed with the round's list.
