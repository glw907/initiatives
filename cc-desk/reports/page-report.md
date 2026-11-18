# The Page round's first pass waits for Geoff's approval

The Page round builds cc-desk's status page, a local web page that shows what every session is
doing. Its first pass is finished as [pull request 7](https://github.com/glw907/cc-desk/pull/7).
The page now exists as a small web app in `web/`. Every 2 seconds it reads the snapshot file,
which the `cc-desk` command writes, and draws the sidebar and the front page. Its 40 browser
tests pass, and so does its automated check. It can't land until Geoff approves it, because its
review raised two choices only he can confirm. To answer, Geoff replies in this terminal session
with "approve 7", or names the choice he wants changed. Meanwhile the second pass, which adds
the page's list of items, has started from the first pass's branch.

## What waits for Geoff

Pull request 7 asks two questions. In each, the pass followed the design where the plan or a
library pulled the other way. The recommendation is to approve both as built.

1. **The page turns off SvelteKit's origin check.** The design says the page refuses any attempt
   to change data with the error "405 Method Not Allowed". SvelteKit's origin check, which
   protects forms, refused those attempts first with a different error, 403. The page has no
   forms and refuses every change anyway, so the check guarded nothing. A later pass that adds a
   form must turn the check back on.
2. **A missing snapshot file now clears the page.** The pass plan said the page keeps showing
   the last snapshot. The design says the page shows "No state yet" and nothing else. The pass
   followed the design, and a test deletes the file while the page is open.

The review also left five small gaps in the tests, such as no test of the front page's question
texts. They need no answer from Geoff and can become follow-ups after it lands.

## What landed

Nothing yet. Pull request 7 is ready and waits for Geoff's approval.

## What went wrong

The plan expected older versions of TypeScript and SvelteKit, so several of its exact steps were
out of date. The house style kit, Survey, lacks four style values the page needed. The page
defines them itself, and a follow-up asks Survey to add them.

## What it cost

The first pass planned 90 minutes. It took about 70 minutes, from its planner's start at 00:23
to a ready pull request at 01:34. Weekly usage went from 92 percent to 93 percent. No new pass
starts once it reaches 100 percent.

## What is left for later

- `docs/follow-ups/survey-rail-muted-doc-measure.md` on the pass's branch asks Survey for the
  missing values.
- `npm audit` reports 8 high-severity warnings in packages used only to build and test the page.
  Nothing is filed for them yet.
