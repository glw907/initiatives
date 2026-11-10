# setup-tooling-r14: round seven's fixes, review record

PR glw907/cairn-cms#233, branch `setup-tooling-r14`, head `74b886ed1`, fast lane green. Class `runner`: `scripts/gate/**`, tests,
docs, and help text. No held path and no `auth-data` path. The tests for the stand-in, the grader, and the screenshot command were
committed red first.

## The cause, from run 2611102302

Setup finished and the site was live, but the stand-in followed the one tab `cairn new --plan` opens. In the agent lane that tab's
server goes with the plan and `--apply` opens none, so the stand-in sat on a dead page for its 2-minute limit and failed before it
could sign the owner in. The sign-in mail had already been delivered.

## Reviews at `1c7455197`

**standards:diff-reviewer, whole branch: fix, two blockers, both folded in `d44dbb944`.**

- The default opener `handleUrl` signs in on a new page of the browser context, but the stand-in then waited for `/admin` on the
  original dead tab, so a live sign-in would have failed after the page limit. The unit stubs moved the tab and hid it. Fixed: after
  the opener the tab loads `/admin` itself, in the recovery path and in the pre-existing login branch (which had the same flaw). The
  stubs no longer move the tab.
- The nameserver check turns true right after the custom domain is attached, but setup sends the sign-in mail only after its HTTPS
  wait of up to 15 minutes, so a 1-minute mail budget could expire first and the stand-in would request a second link. Fixed: a
  `siteAnswers` wait sits between the nameserver check and the mail search, and the mail budget is 3 minutes.

**prose-voice-reviewer on the sandbox wording: fix, two blockers and several warnings, folded in `d44dbb944`.**

- The refusal looped once the retry parameter was off: the retry runs inside the sandbox too and prints the same message, whose first
  instruction was again to set the parameter. Fixed: a message printed again on the retry means the owner has switched it off, and the
  agent asks the owner to add `cairn *` and `npx create-cairn-site *` to `sandbox.excludedCommands`, then makes the call again.
  The page, the skill, `cairn help agents`, and the refusal say the same.
- "Your tool lists the parameter as off" was a claim about Claude Code that no documentation makes. Removed; the trigger is the same
  message on the retry.
- Also folded: the reason not to ask before the retry returns to the page and the skill, the skill's lead sentence no longer reads as
  "get outside the sandbox first", `cairn new --help` now says to make the call first, the exclusion names both patterns, and the
  CHANGELOG entry reads as an instruction to the agent.

## Re-review at `d44dbb944`

**standards:diff-reviewer: accept, nothing blocking.** The reviewer traced the default opener to the shared context cookie and
confirmed the tab lands on a signed-in path (a failed sign-in ends in a `requireAdmin` failure). It confirmed the sequence
(nameserver, then HTTPS, then mail) is bounded by one deadline and `failPage`, that the HTTPS check does not follow a redirect or send
credentials, and that no existing assertion was loosened. Two non-blocking items were folded in `74b886ed1`: the stand-in's HTTPS
check now matches setup's HTTPS check (a 200 on the home page), and a test covers a site that never answers.

Not changed: one login-branch test stub still moves the tab (the new `goto` overwrites it), a cosmetic short line in the guide text,
and no test shows an opener that fails to sign in ending in a `requireAdmin` failure.

## Not proved by a test

The recovery path against a real site and a real mailbox. The scripted leg that follows the merge reaches the done screen through
the TUI, which exercises neither the dead tab nor the mail path. A naive run in the agent lane is the first live proof, and round eight
is that run.
