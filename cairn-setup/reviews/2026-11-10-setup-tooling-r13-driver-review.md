# setup-tooling-r13: the published-path chooser fix, review record

PR glw907/cairn-cms#232, branch `setup-tooling-r13`, head `4f5b39f99`, fast lane green. Class `runner`:
`scripts/gate/**`, tests, and a route escape in `tool/internal/providers/github.go`. No held path and no `auth-data` path.
The failing tests are committed first (`3e4b98d98`) and four of them fail on `main`'s code.

## The cause, from run 2611102143

The first scripted run on the published `2.0.0-dev.5` stopped at the domain screen with a 403 and created nothing. On the
published path npm prints `> create-cairn-site@<version> create-cairn-site` above the TUI. `chooseRow` found the selected
row with the first `> ` line of the whole pane, and a blank chooser has none, so the banner line stood in. The driver sent 9
Downs for a third row that needs 3 and ran past the end of the list. The same token read DNS on `carin-test.org` through
`run-gate.sh sweep --check-scopes` at 21:59Z, so the zone was another domain, the signature of run 1855's `907.life` stop.
Every earlier scripted run used a local binary, which prints no banner.

## standards:diff-reviewer at `4327b6190`

Verdict fix, one blocker.

- **Blocker, folded:** the new catch in `runScripted` awaited `deps.record` without protection, so a failing log write
  would replace the error that ended the leg. The write is now best effort, with a unit test whose `record` rejects.
- **A scripted stop ahead of a failed-page cause, answered:** the reviewer suggested guarding the grade branch so a failed
  stand-in page still wins. A first attempt (`c0e1d6d2b`) read `standInFailed` as a failed page. The second review showed it
  is true for any controls file, including those a successful GitHub page writes, so the guard would hide the recorded cause
  on most failed runs. The guard is reverted (`4f5b39f99`), and the existing ordering stays. That `standInFailed` counts
  successful pages is already true on `main` for the naive leg and is out of this PR's scope.
- **Ref escape, folded:** `url.PathEscape` on a whole ref turns `feature/x` into `feature%2Fx`. `escapeRef` escapes each
  segment and keeps the slashes, with a table test. Every caller passes the repository's default branch.
- **Noted, not changed:** a failing `scripted.jsonl` write leaves no stderr trace; the owner email can appear in a reason
  that quotes a failing `tmux` call, which is PII and no secret, and the full message already goes to stderr.

## standards:diff-reviewer at `c0e1d6d2b`

Verdict fix, one blocker, the page guard above. The record-failure blocker and `escapeRef` read as resolved: the unit test
fails without the try/catch, and `escapeRef` keeps `main`, `feature/x`, and an empty ref. The guard is reverted in
`4f5b39f99`, which returns the grade branches to the order the first review verified, with `escapeRef`'s own test added.

## Not re-reviewed

`4f5b39f99` is the first review's accepted grade ordering, the second review's accepted record fix and `escapeRef`, and one
added test. No third review ran; the conductor can ask for one before the merge.
