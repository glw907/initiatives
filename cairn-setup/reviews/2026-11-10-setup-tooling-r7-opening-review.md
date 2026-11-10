# Review: PR glw907/cairn-cms#225, the opening checks a given subdomain

Whole-branch `standards:diff-reviewer` at head `389a28ae5`. Verdict: accept, no finding.

A given `--host`, trimmed and lowercased, that fits the chosen zone now replaces the kept address, so the
address, its checks, and the record all use the subdomain. The reviewer walked each path through the
opening. A resume or an apply builds its answers from the record, so the given host equals the kept one and
nothing changes. An open-choice stop keeps the same normalized value, so the two reads agree. With several
zones the read runs after the zone is chosen. A host outside the zone is ignored and the default address is
checked as before, then the summary refuses it as before. A bare-domain host still checks the apex and `www`.
The only behavior change is the subdomain case, and a subdomain with a record on it is still refused.

The harness limit moves to ten, refused at the eleventh. The test covers the boundary from both sides, is not
vacuous (a name must match `^\d{10}$`, and the old helper's names reached eleven digits at the tenth and
collided with the scripted row), and `naiveRows` has no other user. The `// WATCH:` change is a comment only.
No loopback, signin, or runner source file and no path held for Geoff is touched. The reviewer ran `go vet`,
`go test ./internal/setup ./cmd/cairn`, and the gate-run test file, and did not rerun my remove-the-fix
experiment.
