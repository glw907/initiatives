# setup-tooling-r12: the friction pre-pass, review record

Branch `setup-tooling-r12` of glw907/cairn-cms, fast lane green at `296193f1c` (the PR's head moves only for a
rebase). Four fresh-context reads ran at `f666ad330`, and each finding is folded or answered below. The pass
class is `runner` with `auth-data` paths (`tool/internal/setup/runner.go` and `tool/internal/providers/github_app.go`),
so the security read ran and its finding has a failing test committed first (`f1e7b8391`, fixed in `2a06339c3`).

## standards:web-auth-security-reviewer

Verdict fix.

- **H1, a manifest code in an error's text.** A failed `ConvertManifest` put the one-time manifest code in the
  `Detail` it built from the request path, and `Detail` reaches stderr, the `step_failed` event an agent relays,
  and the failure screen. Fixed: the call sends through `rawSend` and names the template
  `/app-manifests/{code}/conversions`. The test fails at `f1e7b8391` and passes at `2a06339c3`. The comment on
  `requestSuffix` now says a route with a secret in a segment passes a template.
- **L1, the decoded Cloudflare path.** Fixed: the path keeps its escaped form (`EscapedPath`), with a test.
- **L2, L3, L4.** Accepted: the OAuth error code is a standard RFC 6749 value over TLS, the new identifiers
  (zone, account, repository, installation ids) are not credentials, and a provider error's text carries the same
  suffix in the commands that print one. The detail is in no stored record.

## standards:diff-reviewer (whole branch)

Verdict fix, two blockers, both folded in `296193f1c`.

- `providerStop` read the raw status, so a GitHub 403 that carries a rate limit read as a missing permission.
  Fixed: it takes the classified reason, with a test for a rate-limited 403.
- The refusal sentence's next step named Cloudflare for a GitHub refusal. Fixed: the next step names the provider
  that refused, and only a Cloudflare token run points at the token. The recovery page's first provider row follows.
- Non-blocking, answered: the example check accepts any line that starts with `cairn ` (loose by design, since
  gh's form has comment lines), a blank chooser also leaves its blank state on a stray key (an Enter still needs
  a deliberate key), the driver's blank-screen count assumes the rows follow the count line (true at both golden
  widths), and a trailing dot on `--host` falls through to an open choice (not fixed, rare).

## prose-voice-reviewer (the skill and the help text)

Verdict fix, three blockers and nine warnings. Folded: B1 and B2 as above, B3 (the skill's step 1 now carries the
plan flags), the sandbox refusal's wording and its scope to Claude Code (W1), the skill's bare-call reason (W2),
the token and run paragraphs (W3, W5), the flag list restored (W4), the `detail` description (W6), the help's
sandbox, token, and wait paragraphs (W8), and the posture line (W9). W7 (a Do sentence says "run again" against a
rule that says not to retry) is resolved in the skill: report the failure, and when the fix is a wait or a
permission the person gives, run the same command again with the same flags. That is a judgment call, listed in
the PR's `## Decisions`.

## docs-fact-checker

No finding was false. Nine claims about Claude Code's sandbox and npx, and about resolver caching, are vendor
behavior the checker could not ground in the repository: the sandbox claims were read from
code.claude.com/docs/en/sandboxing on 2026-11-10 (the sandbox is off by default; an exclusion matches the text of
the call; a blocked call may be retried with `dangerouslyDisableSandbox`, which raises a "Bash command
(unsandboxed)" prompt unless an allow rule covers it), and the resolver claim rests on the zone's 1800-second
negative TTL that `tool/internal/setup/watch.go` cites. Four imprecise claims (the host's zone, the HTTPS step's
name, and two lines on `detail`) are reworded.

## tellgrader and Vale

`check:tellgrader` passes on 25 pages, and the Vale gates pass on `docs/` and on the copy golden.

## Fresh re-review of the fold, standards:diff-reviewer, whole branch at `8192bd62a`

Run 2026-11-10 at the conductor's request, in a fresh context, with the auth-data bar on `tool/internal/setup` and
`tool/internal/providers`. The reviewer read the code and the tests, not the commit messages. **Verdict: accept.**
Nothing blocks.

- **The manifest code (security H1): resolved.** At `f1e7b8391` the conversion call still passed the code in the
  path and the new test failed. At `2a06339c3`, `github_app.go:129-133` sends the real URL through `rawSend` and
  names `/app-manifests/{code}/conversions`, and the test passes. A sweep of every other route in the providers
  package found no secret or one-time value in a path segment, and `Detail` is set in one place only
  (`runner.go:697`), from a `ProviderError` match.
- **Raw control bytes: resolved.** Cloudflare paths use `EscapedPath`, with a test that fails on the decoded path.
  A request path to the code host cannot hold an ASCII control byte, because `url.Parse` refuses it before a
  request goes out.
- **The rate-limited 403 (blocker A): resolved.** `fail` passes `ClassifiedReason()`, and `providerStop` checks
  `ReasonRateLimited` and 429 before the 401 and 403 cases. The 5xx rows still read as a wait.
- **The wrong provider named (blocker B): resolved.** Only a Cloudflare token run points at the token, every other
  next step names the refusing provider, and `setup-recovery.md` and the copy golden agree.

Non-blocking, left for the next PR so the head the conductor merges stays this one:

1. No runner-level test drives a rate-limited 403 through `fail`, so a regression in `fail` alone would pass.
2. `CHANGELOG.md` and the BACKLOG #439 Done line say a 401 or 403 reads as a missing permission. A 401 reads as an
   unaccepted credential, and a rate-limited 403 as a wait.
3. BACKLOG has two stray blank lines between #434's Placement and its Done line.
4. The health-check routes in `providers/github.go` interpolate owner, repo, and ref without `PathEscape`. It is
   theoretical, since the routes setup calls escape theirs.
