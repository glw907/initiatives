# Review: PR glw907/cairn-cms#224, the sandbox stop

Whole-branch `standards:diff-reviewer` at head `dfbeca82a`. Verdict: fix, one blocking finding, folded at
`d86f8cae6`. The fold has not had a second read.

Blocking: the check sat above the whole dispatch in `runNew`, so it also refused the no-flag, no-terminal call
that prints the agent guide. That call serves nothing and the page promises it, so the check now applies only
to the plan, apply, and resume modes and to the interactive terminal run, with a test that the guide prints
under `SANDBOX_RUNTIME=1` and that a terminal run is refused.

The reviewer confirmed that plan, apply, resume, and the terminal run all pass the check before anything
serves the tab, that a dry run is correctly exempt, that stopping the interactive terminal run is right (the
tab is as unreachable there, and `d.interactive` needs a TTY the Bash tool does not give), that the message
follows the file's error conventions, that the embedded copy is byte-identical to the page, and that no path
held for Geoff and no `tool/internal/setup/{loopback,signin,runner}*` path is touched.

Non-blocking: the marker is a generic name with no override (a shell that exports it for another reason is
refused; `unset SANDBOX_RUNTIME` clears it, and the PR's Decisions say so); and the dry-run test now asserts
the `dryRun` payload and no error, not only the absence of the word "sandbox". Evidence for the marker: it is
observed, not documented, per a search for a Claude Code page that names it; the PR carries a `// WATCH:`
comment.
