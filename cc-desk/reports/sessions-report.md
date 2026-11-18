# The Sessions round's first pass waits for Geoff's approval, and two more are ready behind it

The first pass is finished as [pull request 8](https://github.com/glw907/cc-desk/pull/8). It
teaches the `cc-desk` command to record each background session and decide what it needs next.
The second pass, [pull request 10](https://github.com/glw907/cc-desk/pull/10), makes the command
start, end, and restart those sessions. The third,
[pull request 12](https://github.com/glw907/cc-desk/pull/12), records a session's permission
prompts so Geoff can answer them from a desk session. All three passed their reviews with no
open finding, and their automated checks passed. Pull request 8 can't land until Geoff approves
it and answers its one question: what a session should do after it hits the usage limit for one
model. Pull requests 10 and 12 ask nothing, and they land in order right after pull request 8,
because each carries the ones before it. To answer, Geoff replies in this terminal session with
"approve 8" and the number of his choice. Meanwhile the fourth pass, which lets the command merge
a clean pull request and send back any other, has started from the third pass's branch.

## What waits for Geoff

**When should a session that hit a one-model limit start again?** Pull request 8 holds this
question. Say a session stops on "You've hit your Fable limit". As built, the check starts it
again as soon as the whole account's weekly usage reads under 90 percent. That restart doesn't
count toward the session's limit of two restarts. The account figure can be low while Fable is
still at its limit. So the session can stop and start over and over until Fable's limit resets.
The design asked for this behavior, and the pass built it.

1. Leave it as built, and accept the repeated restarts until the reset.
2. Wait until the reset time printed in the stop message. This is the recommendation, because
   the check already saves that message. A message with no reset time would fall back to
   choice 3.
3. Count every restart after the first, so the limit of two restarts ends the loop.

Any choice lands as a small change in a later pass. Pull request 10 restarts these sessions
through the same rule and adds no other rule, so whatever Geoff picks covers it too.

## What landed

Nothing yet. Pull request 8 is ready and waits for that answer, and pull requests 10 and 12 wait
on it. When a session needs Geoff, the
check names it under "Needs you now" on the status page, with the reason. It records five new
reasons, such as an expired sign-in or a permission prompt. With pull request 10, a session that
vanishes is started again in the same worktree, at most twice, before it shows under "Needs you
now". With pull request 12, a yes or no to a permission prompt ends the session, adds the rule on a
yes, and restarts it. Every test runs against stand-ins, so nothing in these passes starts a real
session.

## What went wrong

The third pass changed one of its acceptance checks. The check asked for a hook input
recorded from a real session. No session could record one safely, so the test uses the example
in Claude Code's hooks reference instead. The fifth pass records a real one.

The first pass's plan file failed the spelling check in the repo's gate on five words. The pass added them to
the word list and noted that the plan should have run the gate on itself.

## What it cost

The first pass planned 90 minutes and took about 70, from its planner's start at 00:23 to a
ready pull request at 01:32. The second planned 90 and took about 70, from 01:35 to 02:44. The third
planned 60 and took about 60, from 02:46 to 03:48. Weekly usage went from 92 percent to 96
percent. No new pass
starts once it reaches 100 percent.

## What is left for later

The first two passes filed these follow-ups in `docs/follow-ups/` on their branches:

- `how-a-stop-clears.md` asks how four kinds of stop clear once Geoff acts.
- `live-sample-of-limit-texts.md` asks for a live capture of the sign-in and limit messages.
- `ended-record-stop-in-needs-you-now.md` fixes a finished session that still shows under
  "Needs you now".
- `building-pass-without-checkout-needs-entry.md` asks that a pass with no recorded checkout
  show under "Needs you now".
- `launch-review-notes.md` holds the second pass's review notes that weren't folded.
- `hook-input-from-a-real-session.md` asks the fifth pass to record a real hook input.
