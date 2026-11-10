# Review: PR glw907/workstation#218, the watcher's cost-unknown rule

Whole-branch `standards:diff-reviewer` at head `61e0563`, read adversarially because the change touches
`cleanroom`'s stop code. Verdict: accept, no blocking finding.

The change adds one condition to `verdict()`: a run stops as `cost-unknown` only when the statusline is
stale, the transcript is advancing, and the transcript has no priced turn. The reviewer confirmed that the
dollar cap and the time cap are checked before that rule and are unchanged, that `observe()` takes the higher
of the statusline's and the transcript's cost, so a priced transcript leaves the $20 cap enforced from it,
and that with neither figure present and the transcript advancing the run still stops. No secret,
environment, user, or process-killing code changed. The two new live tests are not vacuous: the first fails
on the old rule, and the second proves the stop survives for an unpriced transcript.

The reviewer also showed that the change gives an adversarial agent no new way past the caps: the agent
can already refresh the statusline with a low cost through `cleanroom statusline`, which avoids the stale
rule altogether, and a forged transcript line could only disarm the tripwire, not lower the real cap.

Non-blocking, left for the workstation backlog: `usage_cost` does not clamp negative token counts and a
later line with a reused message id can replace a real turn, so either could lower the transcript's cost
(both predate this change); no unit test calls `verdict()` directly, since only live tests cover it and they
skip without tmux and dbus; and the priced-transcript test checks the time cap but not the dollar cap
firing from the transcript alone.
