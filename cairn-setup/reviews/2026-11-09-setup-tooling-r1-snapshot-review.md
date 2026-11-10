# Review: PR glw907/cairn-cms#214, publishing a dev snapshot to gate

Whole-branch `standards:diff-reviewer` at head `d473271fc`. First verdict: fix, one blocking finding.
Folded at `f6103d16b`; the fold has not had a second read.

The review traced every route to a publish. A snapshot cannot reach `latest`, since every validated
snapshot version has a hyphen and the dist-tag maps any prerelease to `gate`. A ref other than `main`, or a
version off the manifests' `x.y.z`, fails before any id-token job runs. Inputs reach shell text only through
`env:`, and the id-token jobs install nothing new. A release event is unchanged, because `inputs.snapshot`
is null there and the `if` expressions stay false. `tool.yml` publishes the six platform packages and then
the launcher at the dev version, and makes no GitHub release.

Blocking, folded: the packed template pinned the dev backend as `^0.99.0-dev.<n>`, which resolves to the
highest 0.99.0 prerelease on the registry (rc.4), because `dev` sorts below `rc`. `cairn new` pins only the
engine exactly. The pack script now takes `--engine-spec` and `--dev-spec`, the build job passes the
snapshot to both, and the workflow test pins the flags.

Non-blocking, folded: a snapshot with `promote` also set, a ref other than `main`, or a bad version fails
at the start of `ci-green`; the stale comments in both workflows are corrected; the tool's native-artifact
check requires `--version` to open with the snapshot; `tool.yml`'s gating has a test.

Non-blocking, left: a snapshot dispatched on a tool-only head waits out `ci-green`'s deadline and fails,
since `test` and `e2e` skip `tool/**` (the workflow header says so), and the tool snapshot's `x.y.z` is
checked against nothing, because the tool holds no manifest version.
