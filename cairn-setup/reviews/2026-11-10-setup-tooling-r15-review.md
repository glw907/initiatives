# setup-tooling-r15: request detail, the dial retry, and the resolver, review record

PR glw907/cairn-cms#234, branch `setup-tooling-r15`, head `95ef34ab5`, fast lane green. Class `runner` with `auth-data` paths
(`tool/internal/setup/{runner,approvals,watch}.go`), so the web-auth-security read ran twice. Every behavior change has its failing test
committed first.

## The causes, from three scripted runs

- 2611110006: "A request to Cloudflare failed", the fixed sentence, for a request that got no answer. Its cause was not recoverable
  because that branch showed no detail.
- 2611110010: the first installation sweep failed five seconds after the App was created and read as "may still reach all your
  repositories", though no installation existed. The cause was hidden because the stop is built without a detail.
- 2611110013: the HTTPS wait timed out while the zone's nameserver, 1.1.1.1, and the router answered, and this computer's resolver
  still held "no such record". The trigger of the early lookup is not proved.
- This computer's resolver had 447 timeouts in 87,007 lookups, and the home router was its only upstream. The conductor moved the host
  to 1.1.1.1 and 1.0.0.1 over DNS-over-TLS at about 15:43 local on 2026-11-10 (workstation c253f4d). A pass after that change is not
  evidence the PR alone fixed anything.

## Round one at `4a1b7b4a4`

**web-auth-security: fix.** No critical or high finding. Two medium: `awaitAuthority` retried every error to the deadline, so a network that
blocks port 53 held the run for 15 minutes; and a failed deletion in the first sweep read as a plain provider stop and hid a live
installation. Low findings: the transport's raw cause text could carry a credentialed proxy address, a malformed `Location` header, or
server-chosen text into the event an agent relays; two comments claimed no write is ever re-sent; the 200-byte cut could split a rune.

**whole-branch (diff-reviewer): escalate.** The dial retry reached `Probe` (health, doctor, the site poll) and slowed existing tests, and
one new test really slept three seconds.

Folded in `18ee6b979` and its parents: `TransportError.Error()` prints a fixed kind and never the raw cause; the retry keeps `Probe` at one
attempt; a TLS or proxy error is never retried; `awaitAuthority` stops after six errors in a row; `sweep` marks a failed deletion with a typed
error and the first sweep keeps the installation warning for it; the detail cuts on a rune boundary; the sleeping test is fixed.

## Round two at `cd57ae10c`

**web-auth-security: accept.** Every claimed fix held against the code and the Go 1.27 source. The reviewer attacked `transportClass`: the DNS
error's name is the pinned or proxy host and its text a fixed sentinel or a socket address, no POST is retried after a connection was made,
a cancelled context never retries, and the six-error fall-through is an availability matter that needs a position on port 53. Seven Low items.
Folded: a nil cause no longer panics (test first), the first-sweep comment now says a failed list shows nothing either way, the proxy comment
is exact, the authority comment gives the real time bound, and the docs list every failure kind. Accepted without change: a failed network
deletion has no detail, a resolver's local address can appear in a lookup failure's text (bounded at 60 characters, not secret), and a
body-read error still shows its text up to 200 characters.

**whole-branch (diff-reviewer): escalate on one scope question.** The Cloudflare, GitHub, and npm clients carry the retry and health uses the
same clients, so the health credential and API checks repeat a failed read, which my PR text denied. Decision: accept the retry there
(idempotent reads bounded by their context), correct the four texts that said otherwise, and add `providers.SetDialRetryWait` so the
health test does not sleep. The creds test is 0.00 seconds again.

## Round three at `741c4785d`, and four at `62dde4827`

**whole-branch at 741c4785d: fix, two blockers.** `failure()` set Detail only for a provider error, so the first-sweep delete stop and
the npm template-fetch stop carried none; and `isTLSError` missed an alert the server sent. Folded in `62dde4827`: `failure()` fills Detail
from any `TransportError` through a new `Provider()` (host to cloudflare, github, or npm), with red-first tests holding the exact strings.
The alert fix matched `tls.AlertError`.

**whole-branch at 62dde4827: fix.** That match was wrong. crypto/tls reports a server's alert as a `*net.OpError` with Op `remote error`
and an unexported cause, never as `tls.AlertError`, and my tests had built the error by hand, so they passed against a broken check. A real
handshake (a TLS 1.3-only httptest server and a TLS 1.2-capped client) was classed "transport error" and retried three times. The lesson,
recorded in the PR's Planning misses: a test for how a library reports an error must make the library produce it.

## Round five at `95ef34ab5`: accept

**whole-branch: accept, no blocker.** `isTLSError` matches the `remote error` Op, which only crypto/tls sets (conn.go:733 and :740 in Go 1.27.3);
the real-handshake test fails when the matcher's Op string is changed, and passes `-count=20` with and without `-race`. A stop setup ended
(`ReasonStopped`, `ReasonChainTimeout`) shows no transport detail. A re-read of the whole branch found no new blocking defect.

Non-blocking, filed in the next round's PR with the conductor's typed-error item for body parse and read failures:
- `scripts/gate/grade.mjs:515` treats a null `authoritativeAddress` as "the zone has no address", but `resolve.mjs` also returns null when
  the public resolvers or the nameserver cannot be reached, so a live site on a network that blocks port 53 would grade as failed.
- `scripts/gate/scripted.mjs:357` leaves `cat ${captureFile}` unquoted, which breaks on a path with a space.
- The real-handshake test prints the httptest server's TLS handshake log lines into test output.
- The Detail doc comment lists the body parse and read text, which only `fail()` sets.

## Not proved

Nothing here shows what triggered 2611110013's early lookup. The next scripted runs on the new host DNS, with the cache flushed
before each, are the evidence.
