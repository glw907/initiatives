# Review: PR glw907/cairn-cms#227, the clean-room budget and the mail-only apex

Whole-branch `standards:diff-reviewer` at head `87907ace3`, then one changelog-only commit (`365fa60cc`).
Verdict: accept, no blocking finding. The proving skill's edit (a held path) is a separate commit, `304a7f458`.

The budget change drops the `cleanroom cost` term, so the spend is every ledger row (probe rows included,
a running row at its full cap). The ten-run cap, the $5 floor, and the $20 cap are unchanged, and
`--conductor-transcript` is accepted and ignored. The cap test would fail if the executor were still priced:
the rig's fake `cleanroom cost` answers $1.00, which would make the cap $14.00 against the asserted $15.00.
The eleventh-run test covers both sides, and the floor test at $96 refuses and names the budget stop.

`checkAddress` is the only caller of `DNSRecordsNamed` and the only place `ReasonAddressRecords` is raised
(the summary's recheck calls the same function). An MX and TXT apex passes and an A-record apex is refused;
the Worker custom-domain and route refusals are unchanged. The three admin pages, the CHANGELOG, and
MIGRATION-NOTES match the code, and a search of docs and skills found no stale wording. A separate fresh
`docs-fact-checker` run held all 13 claims on the changed lines.

Non-blocking, with what I did:

- The refusal message in `messages.go` still says "DNS records". Left: it is copy, with a docs
  row and goldens, and filed for a later pass.
- The CHANGELOG repeated #225's subdomain sentence. Removed.
- No test pins the floor allowing a start at exactly $95 spent. Left: the refusal side and the cap test
  discriminate.
- A bare `--conductor-transcript` with no value fails under `set -e`. It predates the branch and the value
  is ignored now.

The reviewer ran `go test ./internal/setup ./cmd/cairn` and the gate-run test file, not `make -C tool check`;
the executor ran that through the light lane (exit 0).
