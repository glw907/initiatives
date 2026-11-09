# P6 whole-branch reviews

Branch `cairn-new-6` (PR glw907/cairn-cms#206), range `4e7eb66b3..bb32c76fb` reviewed; folds landed in
`b528fc53b` and `2fba31261` (the final head).

## standards:diff-reviewer (whole branch): fix, then folded

Blocking, all folded:

1. The `auth-data` path map in `cairn-running-passes` still listed `packages/create-cairn-site/src/{github,cloudflare}/**`, so T6.4's acceptance grep printed a line. Removed.
2. `bin.mjs` used `spawnSync` with no signal handling: Ctrl-C ended the launcher while `cairn new` was still stopping, and a SIGTERM to the launcher orphaned the binary. Now async `spawn`, SIGINT/SIGTERM/SIGHUP forwarded, the child's exit status or signal re-raised. Test added (a stand-in binary that traps SIGTERM and exits 7).
3. The launcher suite ran only in `test.yml`, which ignores `tool/**`. Added a Linux step to `tool.yml`'s `check` job. The local fast lane still treats a tool-only diff as the Go gate alone (`isToolPath` precedes the launcher trigger); CI covers it.

Non-blocking, folded: `check-leaks` narrowed to the cairn package names; pack step and upload moved before `Publish release`; `create-cairn-site` described as a rebind, not a first publish; chmod fallback wrapped; stale CHANGELOG sentence and the launcher's `.gitignore` removed; `step_test.go` comment corrected.
Left: `park_test.go` duplicates `vocabulary_test.go`'s check (harmless); ELF `EI_OSABI` not checked (Go cross-builds only); no workflow-yaml test for `tool.yml`'s publish job (coverage note); wizard end-to-end coverage dropped with `create-site.yml` (deliberate in the plan; `setup-matrix.yml` and `e2e.yml` partly cover it); `scripts/gate/cloudflare/` has no tests (filed #409); stale wording in `setup-matrix.yml`, `dev-fold-markers.test.ts`, `workflow-yaml.test.ts`, `admin-sources-css.test.ts`, the transcripts README (comment-only).

## standards:web-auth-security-reviewer: no exploitable blocker in code; release-config blockers

Folded in code:

- B2 (publish on any tag ref, so a dispatch on a tag published): `Publish release` and `publish-npm` now require `github.event_name == 'push'` and a `refs/tags/tool/v` ref; `publish-npm` checks the version's shape before any `npm` call.
- M2: the release job's `checkout`, `setup-go`, and `attest-build-provenance` are pinned by commit sha; the comment that claimed the release job holds no publish credential now says the `--env npm-publish` trusted-publisher binding is what keeps it from publishing.
- L2: the tag name reaches `gh release create` through `env`, not an expression in the shell text.
- L5: the launcher runs a platform package only when its name and version match the launcher's own and it sits in the same `node_modules`; the install hint names the version. Test added.
- L6, L9: chmod wrapped; the `@glw907/` leak exemption narrowed.

Owner steps, not code (written into the `cairn-releasing` skill, "The launcher and its platform packages"):

- B1: the `npm-publish` environment allows tags matching `v*` only, and `*` does not cross `/`, so `tool/v1.2.0` is refused after the GitHub Release exists. Add a `tool/v*` tag policy; never widen to `*`. Prove it with one prerelease tag.
- M1: the `release-tags` ruleset covers `refs/tags/v*` only. Add `refs/tags/tool/v*`.
- M3: after the first tool publish, remove `next` from `create-cairn-site` and deprecate the wizard versions.
- L3: take first-publish tarballs from a dispatch on `main` and verify the attestation with `--source-ref refs/heads/main`.

Escalated as a scope call and filed: M4, the wizard's plaintext App secrets in operator records (#408). Accepted: L1 (tarball digest handoff), L4 (`latest` can move backwards, noted in the skill), L8 (Windows quoting in a local pack run).

## Conductor's delta read (bb32c76fb to 2fba31261): fix, one Medium

Every fold confirmed real (signals and exit status on POSIX, the Linux launcher step, B2, M2 pins checked
against their tags, L2, L5, the leak regex). Launcher suite 11 of 11; actionlint not installed.

| # | Sev | Finding | Fix |
| --- | --- | --- | --- |
| G-1 | Med | `bin.mjs:62-64` forwards SIGINT on Windows, where `child.kill()` terminates abruptly; the console already gives Ctrl-C to `cairn.exe`, so plain, `--json` and agent runs lose their graceful stop | on `win32`, ignore SIGINT in the launcher instead of forwarding it |
| G-2 | Low | `bin.mjs:87-89` exits 0 when the child dies by a signal Node ignores (SIGPIPE) or handles (SIGUSR1 opens the inspector) | after re-raising, `process.exit(128 + os.constants.signals[sig])` |
| G-3 | Low | `bin.mjs:32` `sameModules` refuses pnpm's `.pnpm` layout and npm's nested layout | also accept a `realpathSync` match of the sibling or nested path |
| G-4 | Low | `check-leaks.mjs:83` `\b` stops at `-`, so `@glw907/cairn-cms-private` and suffixed platform names pass | use `(?![\w-])` in place of each `\b` |
| G-5 | Low | `tool.yml:139` runs the launcher suite on Linux only | run it on all three runners |
| Backlog-class, folded because cheap | Low | `tool.yml:74,75,120` unpinned actions in `check`; no workflow `permissions:`; `${{ github.repository }}` in `run:` at :320 | pin by sha; `permissions: contents: read`; move to `env` |

Conductor's call: one fold, checked by the conductor's diff read plus CI, no further round.
