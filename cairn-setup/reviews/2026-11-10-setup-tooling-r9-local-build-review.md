# Review: PR glw907/cairn-cms#228, the scripted leg runs from a local build

Whole-branch `standards:diff-reviewer`, two passes. At `70119aad7`: fix, two blocking findings. At
`e4f9d07b6`, after one fix commit: accept, no blocking finding.

First pass, blocking:

1. The new `starting` screen test matched whenever the typed command appeared anywhere in the pane. The
   setup TUI renders inline, so the command stays above every later screen, and an unknown screen read as
   `starting`. The 15-second unknown-screen failure never fired, and the leg would run to its 20-minute limit
   naming the wrong step. The reviewer reproduced it with `identify()`. The existing unknown-screen test
   missed it because its fixture left the command line out.
2. A `GATE_CAIRN_BIN` in the caller's environment passed the `GATE_` allowlist into the hand-off file. Without
   `--cairn-bin` the run was then recorded as a registry run while the driver typed that binary, which is a
   local build recorded as the published candidate.

Folded in `e4f9d07b6`: `starting` matches only when the whitespace-squashed pane ends with the typed command
(a wrapped command still matches), with a test of an unknown screen and an npm error line under the command;
the hand-off loop skips `GATE_CAIRN_BIN`, with a test; the `GATE_HOST` and `GATE_ZONE` overrides are dropped,
since an ambient `GATE_HOST=carin-test.org` would have pointed the leg at the bare domain; the binary copy
moves before the harness file; and `verdict.mjs` refuses a row whose tool reads `local build`, so the
"never the release gate's scripted row" claim holds in code. The reviewer confirmed `scripts/gate/verdict.mjs`
is not a held path, and noted that the `publish.yml` promote job runs it, so the change takes effect at
promotion. It only adds a refusal.

Shell injection through `--cairn-bin`: no guard needed. After the copy the typed path is always
`$cleanroom_root/<10-digit id>/cairn`; the flag's value is used only quoted. The reviewer ran the four gate
test files (82 tests), `bash -n scripts/gate/run-gate.sh`, and an `identify()` probe of eight panes.
