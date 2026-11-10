# Review: PR glw907/cairn-cms#222, the stand-in's install button

Whole-branch `standards:diff-reviewer` at head `9812831e7`. Verdict: accept, no finding.

The pattern `/^(approve,\s*)?install/i` matches "Install", "Install & Authorize", and "Approve, Install, &
Authorize" and does not match "Cancel", "Select repositories", "Remove <repo>", or "Reinstall". The old
pattern had three uses, in `chooseInstallAccount`, the control list, and the install click, and all three now
use the exported constant. On the permissions page the stand-in used to click nothing (its authorize pattern
did not match "Approve, Install, & Authorize" either) and `chooseInstallAccount` could click the account link;
now the button is seen and it clicks it. No other control changes.

The line appended to `stand-in.jsonl` is built from constants and a timestamp, carries no error text, URL, or
value, and is written with mode 0600. Its write is caught, the original error has already gone to stderr, and
the exit code is set afterward, so a failed write cannot hide the error. No path held for Geoff is touched.

The BACKLOG commit that followed (`80fb183f2`, #435 and a line of apex evidence for #430) changes
`BACKLOG.md` only.
