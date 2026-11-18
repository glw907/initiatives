# The Page round has landed all five pull requests

All five pull requests landed on 2026-11-18, after Geoff approved every call as recommended. The page now serves main's build at http://127.0.0.1:7908/. The rest of this report is as written before the approval.

The Page round builds cc-desk's status page, a local web page that shows what every session is
doing. All five of its passes are finished, and none has landed yet.
[Pull request 7](https://github.com/glw907/cc-desk/pull/7) builds the page as a small web app in
`web/`. Every 2 seconds it reads the snapshot file, which the `cc-desk` command writes, and draws
the sidebar and the front page. [Pull request 9](https://github.com/glw907/cc-desk/pull/9) gives
every round and every pass a separate page, and adds a page of rulings.
[Pull request 11](https://github.com/glw907/cc-desk/pull/11) proves the page changes nothing and
passes the WCAG 2.2 AA accessibility checks, and it runs the page as a service at
<http://127.0.0.1:7908/>. [Pull request 13](https://github.com/glw907/cc-desk/pull/13) adds a
link that opens a session in a terminal, and a "Copy command" button beside it.
[Pull request 15](https://github.com/glw907/cc-desk/pull/15) polishes the spacing, type, and
hierarchy of four pages. Every pass passed its review and its automated checks. Pull requests 7,
9, 11, and 13 raise seven questions between them, and pull request 15 asks nothing. Each pull
request carries the ones before it. Once Geoff approves the first four, all five land in order,
pull request 15 last. To accept every recommendation, Geoff replies in this terminal session
with "approve 7, 9, 11, 13". To change one, he adds the question's number and what he wants, as
in "approve 7, 9, 11, 13, but 3: drop the links".

## What waits for Geoff

Pull request 7 asks two questions, pull requests 9 and 11 ask one each, and pull request 13
asks three. In each, the pass made a choice the design or the plan didn't settle, or settled
differently. The recommendation for every one is to approve it as built.

1. **Pull request 7 turns off SvelteKit's origin check.** SvelteKit is the web framework the
   page is built with. The page design, `docs/specs/2026-11-17-page-design.md`, says the page refuses any
   attempt to change data with the error "405 Method Not Allowed". SvelteKit's origin check,
   which protects forms, refused those attempts first with a different error, 403. The page has
   no forms and refuses every change anyway, so the check guarded nothing. A later pass that adds
   a form must turn the check back on.
2. **In pull request 7, a missing snapshot file clears the page.** The pass plan said the page
   keeps showing the last snapshot. The design says the page shows "No state yet" and nothing
   else. The pass followed the design, and a test deletes the file while the page is open.
3. **Pull request 9 links finished rounds' passes from the front page.** The first pass listed
   passes only under a running round. Pull request 9's acceptance asks for every pass on the
   front page, so finished rounds now list theirs as small, muted links. The other way is to drop
   those links and reach a finished round's passes through the round's page.
4. **Pull request 11's page reads "No state yet" until the command runs.** The service is
   installed and running now. It shows "No state yet" until the `cc-desk` command first writes
   its state folder, `~/.local/state/cc-desk`, which doesn't exist yet. One acceptance check
   reads the project's name from the page's data instead of its HTML, because the page draws
   everything in the browser.
5. **Pull request 13 needs one click from Geoff.** Only a click in Chromium shows what Chromium
   asks when a page opens a `cc-desk://` link. Claude couldn't click, so both the link and the
   button shipped. The click can come after landing, because the button works without it. The
   click and what to report back are in
   `docs/follow-ups/page-link-chromium-click.md`. The link opens no terminal until the `cc-desk`
   command is on the browser's `PATH`, which `docs/follow-ups/cc-desk-on-browser-path.md`
   tracks.
6. **Pull request 13 shows no link for some project names.** The state accepts a project name
   with `.` or `_`, and such a project gets the command and the button but no link. The other
   way is to let the link carry those characters too.
7. **Pull request 13's name rule is narrower than the design's.** The design allowed names
   matching `[a-z0-9-]+`, which lets a name start with a dash. A page could then link to
   `cc-desk://--help/r1` and hand the command a flag. The link takes only
   `[a-z0-9][a-z0-9-]*`, and every name the design refused is still refused. The other way is
   the design's wider rule, which lets that flag through.

Pull request 7's review also left five small gaps in the tests, such as no test of the front
page's question texts. They need no answer from Geoff and can become follow-ups after it lands.

## What each pass built, and its evidence

The round plan numbers the items that say when the page is done, 1 to 10. Each pass answers
some of them, and every item is met. Each pull request lists its acceptance items word for word, with the command that proves each
one and what it printed before the change. These are the main results.

### Pull request 7, the front page

It answers acceptance items 1, 3, 5, and 10. The browser tests for the session forecast, the
order of waiting passes, and redrawing pass, 40 tests in all. A test replaces the snapshot while
the page is open, and the page redraws within 5 seconds. Stopping the server shows "Not
connected" within 10 seconds. The gate now runs the page's tests, and it fails on a skipped
test, a missing browser, or a short run. The pass planted each of those three failures and
showed the gate stopping on each.

### Pull request 9, the item pages

It answers acceptance items 2 and 10. A test collects every round and pass and
fails if one has no link from the front page. With one link turned back into plain text, it
failed and named every unlinked page. The gate went from 40 to 60 tests.

### Pull request 11, reading only

It answers acceptance items 4, 6, 8, and 10. A test walks every page with the
build and state folders set read-only, and every method but GET and HEAD gets 405. The
accessibility scan went from 17 failures in 19 tests to 19 passing, in both themes. The
service answered on 127.0.0.1:7908 against a test state folder, and again after a restart.
The gate reached 91 tests.

### Pull request 13, the terminal link

It answers acceptance items 9 and 10. `xdg-open cc-desk://alpha/r1` ran a
stand-in command with `alpha r1`. Six addresses built to slip in an extra command or flag ran
nothing. The gate reached 130 tests.

### Pull request 15, the polish

It answers acceptance items 7 and 10. Eight changes landed, all in
`web/src/app.css`. They widen the gap between the next-session block and the boards, add
space around the headings in longer text, set state words on the same baseline as their links, and
balance heading lines. "Not started" and "Not designed yet" drop to normal weight. Three
suggested changes were declined as past the round's limit of spacing, type, and hierarchy.
An accessibility review approved it, and a fresh visual check of both themes found no
regression. The gate still passes all 130 tests.

## The terminal link and the screenshots

Both the link and the "Copy command" button shipped, because nobody has clicked the link in
Chromium yet.

The fourth pass took screenshots of the "Waiting for you" list before and after its change, in
light and dark themes. They were copied out of the session's job folder to
`/var/home/glw907/.local/state/cc-desk-reports/page-link/shots-before/` and
`/var/home/glw907/.local/state/cc-desk-reports/page-link/shots-after/`.

The fifth pass took screenshots of the front page, a round page, a pass page, and the rulings
page, in both themes, before and after the polish. They are committed on its branch under
`docs/design-benchmark/page-polish/before/` and `docs/design-benchmark/page-polish/after/`, and
pull request 15 links each pair. Two runs of the screenshot script matched byte for byte.

## What landed

Nothing yet. All five pull requests are ready, and they land once Geoff approves the first four.
The live page at <http://127.0.0.1:7908/> runs the fourth pass's build. The fifth pass didn't
reinstall the service, so the polish reaches the live page only when the landed branch is
installed.

## What went wrong

Every pass recorded where its plan fell short. None of these misses needed a question to Geoff.

- The first pass found the plan expected older versions of TypeScript and SvelteKit, so
  several exact steps were out of date. The house style kit, Survey, lacks four style values the
  page needed. Two plan lines conflicted with the design, and the design won.
- The second pass found the plan left out two line heights and two helper files, and asked
  for page titles the layout already drew.
- The third pass found SvelteKit writes its scripts differently than the plan expected, and
  the plan left out three files the pass touched.
- The fourth pass found that the workstation's browser doc names a `Default` Chromium
  profile that pavilion doesn't have.
- The fifth pass had no plan review before code, as the round plan set. Its plan missed one
  step and two files, and three of its recorded facts came from commands that differed from the
  ones it named.

## What it cost

These figures show how close the plans' estimates came, for planning the next rounds.

| Pass | Planned minutes | Taken minutes | Times, Alaska |
| --- | --- | --- | --- |
| 1, the front page | 90 | about 70 | 00:23 to 01:34 |
| 2, the item pages | 75 | about 40 | 01:37 to 02:15 |
| 3, reading only | 60 | about 60 | 02:19 to 03:21 |
| 4, the terminal link | 30 | about 55 | 03:27 to 04:22 |
| 5, the polish | 90 | about 30 | 04:27 to 04:56 |

Each time runs from the planner's start to a ready pull request. The round planned 345 minutes
and took about 255. The fourth pass's planner raised its estimate to 52 minutes after a
reviewer timed CI at 3 to 4 minutes a run.

Weekly usage for all models went from 92 percent before the round to 98 percent after it. The
stop line is 100 percent, and no new pass starts past it.

## Advisor calls

The advisor is a second model a session consults on a judgment call. It helped with three
choices, and two of them are calls for Geoff. In pull
request 7, the advisor backed turning off the origin check and clearing the page when the
snapshot is missing, which are questions 1 and 2 earlier. In pull request 11, it backed running
the service from a copy of the build in `~/.local/share/cc-desk/page`, so removing a worktree
never breaks the live page. That choice was the pass's to make.

## What is left for later

Each pass filed its follow-ups on its branch under `docs/follow-ups/`.

- `survey-rail-muted-doc-measure.md` asks Survey for the four missing style values.
- `api-project-state-round.md` notes that a project named `api` with a round named `state`
  would have a page no address reaches.
- `pass-needs-reason.md` asks the snapshot to give a pass a reason apart from its round's when nothing waits.
- `survey-table-header-contrast.md` asks Survey to fix a table header color that fails the
  contrast check.
- `page-link-chromium-click.md` holds Geoff's click, and `cc-desk-on-browser-path.md` holds the
  `PATH` fix the link needs.
- `rulings-table-reflow.md` notes that a long ruling could make the rulings table scroll
  sideways on a very narrow screen.

Two items have no follow-up file yet. `npm audit` reports 8 high-severity warnings in packages
used only to build and test the page. The browser doc,
`~/.claude/docs/bluefin-admin/browsers.md`, still names the missing `Default` profile.
