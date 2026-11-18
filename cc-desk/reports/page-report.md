# The Page round's first four passes wait for Geoff's approval

The Page round builds cc-desk's status page, a local web page that shows what every session is
doing. Its first four passes are finished, and each waits for Geoff's approval.
[Pull request 7](https://github.com/glw907/cc-desk/pull/7) builds the page as a small web app in
`web/`. Every 2 seconds it reads the snapshot file, which the `cc-desk` command writes, and draws
the sidebar and the front page. [Pull request 9](https://github.com/glw907/cc-desk/pull/9) gives
every round and every pass a separate page, and adds a page of rulings.
[Pull request 11](https://github.com/glw907/cc-desk/pull/11) proves the page changes nothing and
passes the WCAG 2.2 AA accessibility checks, and it runs the page as a service at
<http://127.0.0.1:7908/>. [Pull request 13](https://github.com/glw907/cc-desk/pull/13) adds a
link that opens a session in a terminal, and a "Copy command" button beside it. All four passed
their reviews and automated checks, and each raised a choice only Geoff can confirm. To answer,
Geoff replies in this terminal session with "approve 7, approve 9, approve 11, approve 13", or
names a choice he wants changed. Meanwhile the fifth and last pass, which polishes the page's
design, has started from the fourth pass's branch.

## What waits for Geoff

Pull request 7 asks two questions, pull requests 9 and 11 ask one each, and pull request 13
asks three. In PR 7's two, the pass followed the design where the plan or a
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

4. **Pull request 11's page reads "No state yet" until the command runs.** The service is
   installed and running now. It shows "No state yet" until the `cc-desk` command first writes
   its state folder, `~/.local/state/cc-desk`, which doesn't exist yet.
   One acceptance check reads the project's name from the page's data instead of its HTML,
   because the page draws everything in the browser. The recommendation is to approve.

5. **Pull request 13 needs one click from Geoff.** Only a click in Chromium shows what Chromium
   asks when a page opens a `cc-desk://` link. Claude couldn't click, so both the link and the
   button shipped. The click and what to report back are in
   `docs/follow-ups/page-link-chromium-click.md` on the fourth pass's branch. The link opens no
   terminal until the `cc-desk` command is on the browser's `PATH`, which
   `docs/follow-ups/cc-desk-on-browser-path.md` tracks.
6. **Pull request 13 shows no link for some project names.** The state accepts a project name
   with `.` or `_`, and such a project gets the command and the button but no link.
7. **Pull request 13's name rule is narrower than the design's.** The design allowed names
   matching `[a-z0-9-]+`, which lets a name start with a dash. A page could then link to
   `cc-desk://--help/r1` and hand the command a flag. The link takes only
   `[a-z0-9][a-z0-9-]*`, and every name the design refused is still refused.

The recommendation for all three is to approve.

Pull request 7's review also left five small gaps in the tests, such as no test of the front page's question
texts. They need no answer from Geoff and can become follow-ups after it lands.

## What landed

Nothing yet. Pull requests 7, 9, 11, and 13 are ready and wait for Geoff's approval. Each carries
the ones before it, so they land in that order. Pull request 11 also changed one label: the
page's hidden words for a waiting item read "Needs you", to match the page's other text.

## The terminal link

Both the link and the "Copy command" button shipped, because nobody has clicked the link in
Chromium yet. Outside the browser, the link works: `xdg-open cc-desk://alpha/r1` ran a stand-in
command with `alpha r1`. Six addresses built to sneak in an extra command or flag ran nothing.
The fourth pass took screenshots of the "Waiting for you" list before and after, in light and dark
themes. They are copied out of the session's job folder to `/var/home/glw907/.local/state/cc-desk-reports/page-link/shots-before/` and
`/var/home/glw907/.local/state/cc-desk-reports/page-link/shots-after/`.

## What went wrong

The plan expected older versions of TypeScript and SvelteKit, so several of its exact steps were
out of date. The house style kit, Survey, lacks four style values the page needed. The page
defines them itself, and a follow-up asks Survey to add them.

## What it cost

The first pass planned 90 minutes and took about 70, from its planner's start at 00:23 to a
ready pull request at 01:34. The second planned 75 and took about 40, from 01:37 to 02:15. The
third planned 60 and took about 60, from 02:19 to 03:21. The fourth planned 30 and took about
55, from 03:27 to 04:22; its planner set 52 after a reviewer timed CI at 3 to 4 minutes a run.
Weekly usage went from 92 percent to 97 percent. No new pass
starts once it reaches 100 percent.

## What is left for later

- `docs/follow-ups/survey-rail-muted-doc-measure.md` on the pass's branch asks Survey for the
  missing values.
- `npm audit` reports 8 high-severity warnings in packages used only to build and test the page.
  Nothing is filed for them yet.
- `docs/follow-ups/survey-table-header-contrast.md` on the third pass's branch asks Survey to fix
  a table header color that fails the contrast check.
- `page-link-chromium-click.md` and `cc-desk-on-browser-path.md`, on the fourth pass's branch,
  hold Geoff's click and the `PATH` fix that the link needs.
- The workstation's browser doc, `~/.claude/docs/bluefin-admin/browsers.md`, says Claude Code
  drives a `Default` Chromium profile. Pavilion has none, only Geoff's. Nothing is filed for it yet.
