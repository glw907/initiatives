# Review: PR glw907/cairn-cms#230, what the scripted loop found

Two reviews of the branch, which touches `tool/internal/setup/runner.go` (an `auth-data` path, for one config
field) and the scripted leg's harness. Heads `5cbc32cf1`, then `8d5906e45` after the review findings.

## Whole-branch `standards:diff-reviewer`: accept, nothing blocking

The nameserver wait uses the same deadline as the site wait (separate deadlines would wait 30 minutes), ends
in every branch (an answer, an error that is not a DNS not-found, the deadline, a cancelled context), and is
skipped without an `Authority` or nameservers. The first test fails without the call. The watch label changes
only on the confirmed branch, and a refused address restores the old one. Only the `summary-set` screen sends
Enter at the summary, and it needs both "Enter set up" and an address row showing `gate.carin-test.org`. A
launcher or platform mismatch is skipped only for `harness.local`, so an unread launcher still fails a
published-snapshot scripted run, and tests cover both. Non-blocking: a not-found on the nameserver's name
reads as an absent host; no test asserts that `NameServers[0]` is the one asked; the grader's repository
lookup has no unit test; `summary-editing` retypes the host on each reopen if setup refuses the subdomain
(it fails closed); and the shared lookup change reaches `cairn health`'s serving check, now in the PR body.

## `standards:web-auth-security-reviewer`: accept with two Low fixes

No credential, token, or one-time link reaches a DNS query or a log: the query holds the owner's chosen host,
and `Probe` carries no credential. The wait is bounded (each query 15 s, the deadline checked after every
not-found), it can never skip or replace `siteAnswers`, and the `cairne2e` seam is a build-tag file that no
release build sets. Two Low findings, both folded in `8d5906e45`: the direct query was not rooted, so Go's
resolver also sent the machine's search suffixes to the zone's nameserver (a small privacy leak, and an early
stop if a suffix matched a wildcard on another zone the owner holds), and an AAAA-only query would have waited
the full 15 minutes on a zone with IPv6 off, so an A answer now counts. A log event for a skipped wait was
declined: the Go tool has no event channel for it, and a skipped wait falls back to the former behavior.

## CI

The first push failed `npm run check`: `scripts/gate/scripted.mjs` declared `const steps = []`, which the
type check read as `any[]`. Fixed in `fa8419f80`; `npm run check` reports 0 errors. The adapter-cloudflare
module errors in that output are the local environment's and appear on `main` too.
