# The Page round's first two passes wait for Geoff's approval

The Page round builds cc-desk's status page, a local web page that shows what every session is
doing. Its first two passes are finished, and each waits for Geoff's approval.
[Pull request 7](https://github.com/glw907/cc-desk/pull/7) builds the page as a small web app in
`web/`. Every 2 seconds it reads the snapshot file, which the `cc-desk` command writes, and draws
the sidebar and the front page. [Pull request 9](https://github.com/glw907/cc-desk/pull/9) gives
every round and every pass a separate page, linked from the front page, and adds a page of rulings.
Both passed their reviews and automated checks, and each raised a choice only Geoff can confirm.
To answer, Geoff replies in this terminal session with "approve 7, approve 9", or names a choice
he wants changed. Meanwhile the third pass, which tests the whole page and runs it as a service on this computer,
has started from the second pass's branch.

## What waits for Geoff

Pull request 7 asks two questions, and pull request 9 asks one. In PR 7's two, the pass followed the design where the plan or a
library pulled the other way. The recommendation is to approve both as built.

1. **The page turns off SvelteKit's origin check.** The design says the page refuses any attempt
   to change data with the error "405 Method Not Allowed". SvelteKit's origin check, which
   protects forms, refused those attempts first with a different error, 403. The page has no
   forms and refuses every change anyway, so the check guarded nothing. A later pass that adds a
   form must turn the check back on.
2. **A missing snapshot file now clears the page.** The pass plan said the page keeps showing
   the last snapshot. The design says the page shows "No state yet" and nothing else. The pass
   followed the design, and a test deletes the file while the page is open.

3. **Pull request 9 links finished rounds' passes from the front page.** The first pass listed
   passes only under a running round. Pull request 9's acceptance asks for every pass on the front
   page, so finished rounds now list theirs as small, muted links. The other way is to drop those
   links and reach a finished round's passes through the round's page. The recommendation is to keep
   them.

Pull request 7's review also left five small gaps in the tests, such as no test of the front page's question
texts. They need no answer from Geoff and can become follow-ups after it lands.

## What landed

Nothing yet. Pull requests 7 and 9 are ready and wait for Geoff's approval. Pull request 9
carries pull request 7's changes, so 7 lands first.

## What went wrong

The plan expected older versions of TypeScript and SvelteKit, so several of its exact steps were
out of date. The house style kit, Survey, lacks four style values the page needed. The page
defines them itself, and a follow-up asks Survey to add them.

## What it cost

The first pass planned 90 minutes and took about 70, from its planner's start at 00:23 to a
ready pull request at 01:34. The second planned 75 and took about 40, from 01:37 to 02:15.
Weekly usage went from 92 percent to 94 percent. No new pass
starts once it reaches 100 percent.

## What is left for later

- `docs/follow-ups/survey-rail-muted-doc-measure.md` on the pass's branch asks Survey for the
  missing values.
- `npm audit` reports 8 high-severity warnings in packages used only to build and test the page.
  Nothing is filed for them yet.
