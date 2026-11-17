# The route to cairn's target version

Initiative: theme-garden. Written 2026-11-17 by `cairn-route-design` from cairn-cms at `79d326bed`
on `main`, fetched again before sending and unchanged. This file is the second of two design files
behind the queue page "Approve cairn's target version and the route that builds it?". The first,
`2026-11-17-route-target.md`, describes the repo the route ends at. This one gives the rounds and
passes in run order, the verdict on every stopped pass, and what happens to each leftover.

The route starts after the pass that deletes the Go tool, which Geoff approved as
`20261117-185742-aee396`. Every pass here is designed against the repo without `tool/`.

## How the route runs

Geoff set the rule in two queue pages, and this design follows both.

- `20261117-191347-b03bf4`, "Every project asks its questions up front and reports at the end":
  "The design page is the one sitting. It carries every question whose answer changes what gets
  built." And: "After you approve the design, the work runs to its end without asking you anything
  more."
- `20261117-191047-0ef56b`, "The desk records clean merges of approved designs without asking".

So the queue page for this design is the one sitting. From Geoff's approval the rounds launch one
after another until the release candidate is ready. No round plans a merge document as a
touchpoint. A pass with no call for Geoff and no `auth-data` path lands as `approval-packet` step 1
says. Any other pass sends a `merge` document of its own as soon as its pull request is ready,
which standing answer 25 sets out. Its first paragraph states the five facts the clean-merge page
names:

1. The design's approval, by queue id.
2. That the pull request does what its pass in this file says and nothing outside it.
3. The reviewer's verdict.
4. The state of every check on the pull request.
5. That the document asks nothing, or the one thing it asks.

The desk records Geoff's approve when all five hold. Each round ends with a `report` at
`reports/<round>-report.md`. The route ends with one report on the whole: what cairn is now, what
was cut and why, and what Geoff does next.

Five things still reach Geoff whenever they come up, as `b03bf4` lists: spending past a ceiling,
an act that can't be undone, a secret or a step only he can take, a question about sign-in or
stored personal data, and work beyond what he approved. "Steps only Geoff can take" below lists
the ones this design already knows.

## Rulings

Geoff approved the queue page on 2026-11-17 at 21:16Z as `20261117-210356-a03b21`. He took the
recommended option on all nine questions. Where a row, an acceptance item, or a standing answer
below is worded for an answer still to come, plan the form its line here gives.

1. Ruled: the site commands are `cairn pages`, `cairn take-over <page>`, `cairn changes <page>`,
   and `cairn give-back <page>`.
2. Ruled: the workstation's list of sites is dropped. No `cairn sites` and no `cairn adopt`.
   `cairn health` checks the site whose folder it runs in.
3. Ruled: shell completion is left out.
4. Ruled: all three groups of published names are removed, with no alias: the old bin names, the
   template files, and the theme archives.
5. Ruled: the release covers three themes (Waymark, Pennant, Survey) and two kinds of site
   (`blog` and `organization`). `cairn new` offers those two kinds.
6. Ruled: a theme serves the kinds it was drawn for. The manifest keeps `kinds`, Survey lists
   `blog`, and `cairn new` offers a kind's listed themes. A developer can still name any theme
   in the record, and `cairn doctor` notes an untested pair.
7. Ruled: rounds run one at a time. No second track runs.
8. Ruled: the 85 percent usage stop returns at the weekly reset on November 20.
9. Ruled: a round's overrun ceiling is twice the minutes its plans add up to.

One later ruling changes who launches a round. Under `20261117-210640-4135d8` the desk that ran
on 2026-11-17 launches nothing new, and every round of the route waits for the revised desk.
`plans/2026-11-17-route-start-lines.md` holds each round's launch as a full command, so a
session with no memory of that day can start round 1 from it. Where this file says the desk
launches a conductor, read the revised desk.

## The route at a glance

Design minutes are path minutes by the formula the structure design used
(`specs/2026-11-17-structure-round-design.md`): work minutes times 1.3, plus 40 for an `ordinary`
or `runner` pass and 70 for an `auth-data` pass. The first draft called that a `pass-core` rule.
`pass-core` asks for path minutes and fixes no formula. Foundation passes 1 and 2 planned at about
1.6 times their design minutes, so the third column is what I expect the plans to total. The
evidence for 1.6 is thin: the deletion planned at 300 minutes against a design figure of 460. A
round's overrun ceiling is twice the minutes its plans add up to (ruling 9).

| Order | Round | Passes | Design minutes | Expected plan minutes | Builds on |
| --- | --- | --- | --- | --- | --- |
| 0 | `tool-delete` (approved, executing) | 1 | 460 | 300, its plan's figure | `main` |
| 1 | `checks` | 3 | 600 | 960 | `tool-delete` |
| 2 | `surface` | 4 | 860 | 1,376 | `checks` |
| 3 | `layers` | 3 | 740 | 1,184 | `surface` |
| 4 | `errors` | 3 | 860 | 1,376 | `layers` |
| 5 | `stock` | 3 | 1,031 | 1,650 | `errors` |
| 6 | `editor` | 4 | 980 | 1,568 | `stock` |
| 7 | `themes` | 2 | 758 | 1,213 | `stock` |
| 8 | `made-site` | 3 | 830 | 1,328 | `themes` |
| 9 | `command` | 2 | 678 | 1,085 | `made-site` |
| 10 | `site-cmds` | 2 | 738 | 1,181 | `command` |
| 11 | `features` | 2 | 630 | 1,008 | `site-cmds` |
| 12 | `basics` | 3 | 580 | 928 | `features` |
| 13 | `access` | 3 | 1,316 | 2,106 | `command` |
| 14 | `setup` | 3 | 1,207 | 1,931 | `access`, `basics` |
| 15 | `survey` | 2 | 704 | 1,126 | `themes`, `features` |
| 16 | `release` | 3 | 1,160 | 1,856 | all |

The sixteen rounds hold 45 passes and 13,672 design minutes, about 21,900 as planned. With the
deletion the figures are 14,132 and about 22,200. The plan review's class corrections added 172
of those design minutes, in rounds 5, 7, and 8. The second reader's question on `cairn update`
added 60, in round 10, and moved 50 from round 8 to round 7 with `shellFor`.

**How long that is.** Usage sets the pace, and the clock doesn't. Three passes give a measure of
it: foundation pass 1 spent 136 path minutes for 3 points of the weekly allowance, pass 2 about
37 minutes a point, and Pennant pass 4 about 15 while other sessions ran. At 15 to 45 minutes a
point and an 85 percent stop, a week buys between 1,300 and 3,800 path minutes. The route's
21,900 expected minutes would then take from six weeks to four months if cairn had the whole
allowance. It doesn't, since dubplate and the desk draw on the same one. Three measurements are
few, and each round's report gives the minutes and the points it spent, so the figure firms up
as the route runs.

## Why this order

The order follows one rule from the brief: each file is written once.

**The check runner comes first.** Every later pass adds or removes a check. With one list and one
runner in place, a pass adds a row. Without it, each pass would edit `package.json`, the gate
table, the gate tiers, and two workflow files, and a later pass would rewrite all of them.

**The engine's names, layers, and errors come before any new folder.** `stock`, `features`,
`themes`, `scaffold`, and `cli` are about 15,000 new lines. Written after `check:layers` and
`check:errors` exist, they are held to the rules from their first commit, and no sweep comes back
for them. Written before, they would be swept.

**The template is never cleaned.** The stopped designs tidied `templates/waymark` in several
passes. The folder is generated from the showcase, and nothing has read it since the Go tool
went. `stock-1` deletes it before the first pass that reshapes the showcase, so no pass keeps a
generated copy in step through three rounds of moves. The first draft deleted it in
`made-site-3`, and the plan review counted four passes editing a tree on its way out. The bake
scripts and the starter overlays stay until `made-site-3`, because `made-site-2` reads them to
write `siteFiles`.

**The least-proven idea runs first in its round.** `stock-1` proves the published paths, the
shipped source with declaration maps, the virtual site config, and the Tailwind source line on one
page end to end, before sixty route files depend on them.

**The editor split follows routing.** The routing pass changes the edit screen and the rename
dialog. Splitting `EditPage.svelte` first would make routing edit five new files. Splitting it
right after means `features` and `basics` add nothing to a file about to be split.

**The command comes after the site it makes.** `cairn doctor`, the page commands, and `cairn new`
all read `scaffold`. They are written once `scaffold` is final.

**Features come after the page commands.** `cairn add` writes shells with the same function
`cairn update` uses, so `features-1` reuses it.

**Setup comes last among the code.** `cairn new` writes everything the earlier rounds define, so
it is the last thing to settle. Survey follows, in the new theme form, and the docs are written
against commands that exist.

## Shared assumptions

Each assumption carries a probe I ran or a quoted source. The probes ran in a clone at `79d326bed`.

| # | Assumption | Evidence |
| --- | --- | --- |
| A1 | The repo has no `tool/`, no Go lane, and no launcher when round 1 starts | The approved deletion design, acceptance items 1 to 17 (`2026-11-17-tool-deletion-design.md`) |
| A2 | A route file made only of re-exports builds, prerenders, and runs under `vite dev` | Site-update hand-over, "What ran", item 1: "Route files made only of re-exports build, prerender, and run under `vite dev`." Spike on `@sveltejs/kit` 3.2.0, Vite 8.3.8, wrangler 4.163.0 |
| A3 | TypeScript shells type-check | Same hand-over, item 5: "`svelte-check` reports 0 errors on 238 files with `.ts` server shells and `lang=\"ts\"` page shells." |
| A4 | Wrangler applies migrations from the package | Same hand-over, item 3: "Wrangler applies D1 migrations from `node_modules/<package>/migrations` when `migrations_dir` points there." |
| A5 | A site can't override a stock route with a second file | Same hand-over, item 4: "Two route groups that claim one path stop the build in SvelteKit's `prevent_conflicts`." |
| A6 | A typed `parts` prop lets a site replace one part of a stock view | Same hand-over: "This ran. The build prerendered the club's rows inside the stock page." |
| A7 | Shipped source with declaration maps gives go-to-definition on readable source | SvelteKit, "Packaging", quoted in the target file's sources. Nobody has run it on this repo. `stock-1` proves it first |
| A8 | `dist` must keep stripping TypeScript from `.svelte` files | `ls scripts/build/transpile-dist-svelte.mjs` prints the path. Its header gives the Vite 8 reason |
| A9 | A package's CSS entry can carry the Tailwind source line for its components | `grep -n '^@source' src/lib/admin-sources.css` prints `11:@source ".";` |
| A10 | `actionlint` runs without Go | Release `v1.7.12` on GitHub carries prebuilt archives and a checksums file. npm `actionlint` 2.0.6 is the same linter as WebAssembly. `checks-3` picks one |
| A11 | The keyring package works on this workstation | Command hand-over: `@napi-rs/keyring` 2.1.2 ran on Linux with the `secret-service` store. macOS, Windows, a locked keyring, and musl are untested, so the environment variables stay the documented way on those |
| A12 | The fast lane takes about a minute | Foundation conductor's hand-over: 400 files, 5,799 tests, about 66 seconds |
| A13 | `main` requires no status check | The deletion design's probe of `gh api repos/glw907/cairn-cms/rulesets` |
| A14 | The launch line's flags exist | `claude --help` on 2026-11-17 lists `--bg`, `--effort`, and `-n, --name`. It doesn't list `--advisor`. The line in `planner.md` "Launch" carries it and launched the deletion's planner today. That planner launched the executor `cairn-cms-tool-delete` the same way at 19:54Z, and it was running as job `2d4cd0a4` at 20:45Z. Prompts point at that section and copy no flag |

## Standing answers

The twelve in `round-run.md` hold in every round. These are added.

13. **Usage.** No usage stop applies before the weekly reset on November 20 at 10:59 pm Alaska
    time (Geoff, `20261117-055811-900560`). From the reset, standing answer 4's 85 percent stop
    returns (Geoff, `20261117-091516-5c3656`, answer 11). A conductor that reaches the stop
    starts nothing new, lets the pass in flight finish, and waits for the next reset with its
    clock stopped. At 100 percent a running pass stops where it is with its commits pushed, and
    the conductor relaunches it after the reset (`20261117-055811-900560`). No session buys
    extra usage. Geoff kept the stop at 85 percent (ruling 8).
14. **Overrun.** A round that passes twice the minutes its plans add up to finishes the pass in flight,
    starts nothing new, and its conductor sends one `decide` page. This is "spending past a
    ceiling".
15. **A plan over twice its expected minutes** parks and sends a `decide` page, as `planner.md`
    says of a plan over twice its estimate. A plan under that goes ahead with no page. The
    estimate each planner prompt states is the pass's expected minutes, its design minutes times
    1.6, and the prompt states the park figure beside it. This is my call. Measured against the
    design figure, a plan that lands where I expect would have 25 percent of room before it
    parked, and the pages that followed would tell Geoff nothing new.
16. **A file the design didn't list.** A pass whose outcome needs an edit to a file this design
    doesn't name makes the edit and lists it under `## Decisions`. The outcome and the acceptance
    items bound the pass. The file lists are my reading of today's code.
17. **A late round's file list is stale.** Rounds 9 to 16 are designed against code that earlier
    rounds write. The round's first planner reads the landed code, corrects the file lists, and
    re-prices. Standing answer 15 then applies to the new price.
18. **A snapshot under a test dist-tag** is approved for any pass that needs a published package
    to test against, as `planner.md` allows. No pass publishes under `latest` or `next`.
19. **A retired form.** A pass that removes or renames a command, a flag, or a document kind runs
    the search `ready.md` "A retired form" names and lists the hits in its pull request. It edits
    no setting, hook, or skill outside the repo.
20. **The conductor cuts each worktree.** The repo's implementer agent works in the main checkout
    unless a worktree exists, so the conductor creates the worktree before it launches a planner.
21. **A step only Geoff can take isn't done when its pass is reached.** The conductor runs every
    pass that doesn't build on the step, says so in the round's report, and the pass waits. The
    table under "Steps only Geoff can take" names what each step holds.
22. **Geoff's look at the terminal screens.** `access-3` ends with a `decide` page of screenshots.
    The route doesn't wait for the answer. Changes Geoff asks for land as one more pass before
    `release-3`.
23. **A check's removal.** A pass may remove a check together with the code it guards, as Geoff's
    direction page allows. The pull request names the check and the code.
24. **A held file.** Approving the queue page approves the edits to held files that the pass
    tables list: workflow files, `.github/ci-green.json`, and `scripts/release/**`.
25. **A merge document goes when its pass is ready.** This replaces the second rule under
    `round-run.md` "Queue rules", which sends one close packet per round after the last pass ends.
    A pass that can't land by `approval-packet` step 1 sends its own `merge` document when its
    pull request is ready. The next pass of the chain launches as `round-run.md` "The order table"
    says, from the waiting pass's branch. It lands once the waiting pass has landed, and joins no
    packet. Ruling `0ef56b` is the reason. The desk records a clean merge, so one packet per round
    would gain Geoff nothing and would hold up to four pull requests in a stack until the round's
    end. Each conductor prompt quotes this answer, because the conductor reads `round-run.md`.
26. **A round's end.** A round ends when each of its passes has landed, or a `decide` answer of
    Geoff's has moved or dropped it. A parked pass keeps the round open. The conductor then sends
    the round's report, whose title opens `Cairn route, round <id>:`. The report's last section
    quotes the next round's start line. The conductor writes the next round's conductor prompt
    into `docs/STATUS.md` as the next launch, and ends. The desk launches the next conductor when
    the start line holds. No conductor launches another.

## Long rounds

`round.md` says the longest chain in a round holds about 600 planned path minutes. Fourteen of the
sixteen rounds pass that in design minutes. The guide exists because a pass that waits for Geoff
holds every later landing. Under `20261117-191047-0ef56b` a clean merge no longer waits, and Geoff
ruled on the structure design that rounds longer than the guide stay as designed
(`20261117-091516-5c3656`, answer 5). The rounds keep their size.

## Launch checks, run early

`ready.md` asks the designing session to run the checks that come before the first launch.

| Check | Command | Output on 2026-11-17 |
| --- | --- | --- |
| Usage | `claude -p "/usage" --model haiku < /dev/null` | "Current week (all models): 82% used · resets Nov 20, 11pm (America/Anchorage)", read at 21:01Z. It read 74% at 18:30Z and 81% at 20:50Z |
| Live sessions in the repo | `claude agents --json` | At 21:01Z one row works under cairn-cms: `cairn-cms-tool-delete`, the deletion's executor, which launched at 19:54Z. No row's name starts `conductor-` |
| The deletion's pull request | `gh pr view 260 --repo glw907/cairn-cms --json state,isDraft` | Open, a draft, at `29e5340e8` when read at 21:01Z: 994 files changed and 113,518 lines deleted. At 20:40Z it stood at `a96deb40b` |
| Launch flags | `claude --help` | See A14 |
| Main checkout on `main`, level with `origin/main` | Not run | My brief forbids me the main checkout's path on a command line. The first conductor runs it |
| Busy check | Not run | Same reason. It would print busy today, because the deletion's executor works under the checkout |

Round 1 doesn't start on approve unless the deletion has closed by then. It waits for the deletion
pass to merge and close, which the deletion's executor and the desk end. The desk then launches
the round's conductor.

## Start lines

Each part is a state a command reads.

- **`checks`** starts when four things hold.
  1. The queue shows this design approved: a `decision-*.json` file in this page's folder under
     `~/.local/state/approval-queue/store/` holds `"action": "approve"`.
  2. The deletion has merged: `git ls-tree origin/main tool` prints nothing.
  3. The deletion has closed, which a merge alone doesn't show. `git worktree list` in the main
     checkout names no `tool-delete` worktree, and `git branch --list tool-delete` prints nothing.
     The close removes both.
  4. `claude agents --json` lists no working row named `conductor-cairn-cms` and none whose name
     starts `cairn-cms-tool-delete`.
- **Every later round** starts when three things hold.
  1. The previous round's report is sent. `grep -l '^# Cairn route, round <previous>:'
     ~/.local/state/approval-queue/store/*/v1.md` prints one path. A conductor sends that report
     once, as its last act, so the file exists only when the round has ended. Standing answer 26
     fixes the title.
  2. `claude agents --json` lists no working row named `conductor-cairn-cms`. Every round's
     conductor has that name, as `conductor.md` sets it.
  3. `gh pr list --repo glw907/cairn-cms --state open --search "head:<previous>-"` prints nothing.

The first draft of the later line read the report's block in `docs/STATUS.md` and a row named
after the round. The plan review found both always true. The block is written at a round's first
launch, and no conductor carries a round's name.

No other round is approved or running in the repo. The foundation, structure, `site-events`, and
`site-basics` rounds are stopped (`20261117-182825-8b4207`), and this route replaces them.

Rounds run one at a time (ruling 7). "A second track" below records the option Geoff turned
down.

## Order tables and hand-offs

`round.md` asks a round design for an order table. Each round's pass table below is that table.
It gives each pass, what it depends on, and its minutes. Two of the order table's columns follow
a rule, so the 45 rows don't repeat them.

- **The planner prompt** of a pass is `plans/2026-11-17-route-<pass>-planner-prompt.txt`, and a
  round's conductor prompt is `plans/2026-11-17-route-<round>-conductor-prompt.txt`, both under
  `theme-garden/` in the initiatives repo.
- **The wait mark.** A pass whose class cell says `auth-data`, `live-account`, or "held files"
  sends a `merge` document whatever its review says. Every other pass lands by `approval-packet`
  step 1 on a reviewer's accept.

I write the 45 planner prompts and the 16 conductor prompts when Geoff approves, and commit them
before I tell the desk the start lines. My brief sets that order, and it bars me from editing a
prompt file or committing in the initiatives repo before the approve. Each conductor prompt
copies its round's table with the prompt paths filled in and quotes standing answers 13 to 26.
The "Leftovers" acts marked "Me, on approve" happen in the same sitting, before the first
hand-off, so no conductor ever sees a stale prompt beside a new one.

The desk launches every round's conductor. It reads the round's start line, and when the line
holds it launches the conductor from the main checkout as `conductor.md` "Hand-off" says. A
conductor runs one round and ends. Standing answer 26 says what it leaves behind.

## What every pass holds

Four rules hold for every pass, and each planner copies them into its plan's acceptance. The
stopped structure design carried the first and third for every pass, and they bind the route's
passes too.

1. No test is deleted to make a change pass.
   `git diff --diff-filter=D --name-only <base>...HEAD -- src/tests | wc -l` prints `0`, apart
   from tests of code the pass's row deletes. The plan lists those by path.
2. No check is lost. From round 1 on, `node scripts/checks/run.mjs --list` names every check it
   named at the base, apart from a check the pass's row deletes.
3. The words follow the standard. A pass that writes words a person reads, such as an error
   message, a command's output, a docs page, or a changelog entry, runs the repo's four-gate
   prose review (`register-check`) on them for their audience.
4. A kept pass keeps its design's items. Where the table under "What happens to the stopped
   work" says Keep or Change, the stopped design's acceptance items for that pass bind the
   route's pass under its new name. The planner reads them in
   `specs/2026-11-17-structure-round-design.md`, or the routing design for `stock-2`, and copies
   each into the plan. It drops an item only when the item names a file the route has deleted
   by then or a rule this design changes, and the plan says which.

Rule 4 exists because the route renames passes. `errors-2` here is the structure design's
`guarded-3`, `errors-3` is its `errors-2`, `editor-1` is its `guarded-4`, and `editor-2` to
`editor-4` are its `editor-1` to `editor-3`. An item written for the old name still binds.

## Round 1: `checks`

**Outcome.** One list names every check, one runner runs a group of them, and CI calls the runner.
A later pass adds a check by adding a row.

| Pass | Outcome | Files | Class | Minutes | Depends on | Shares a file with |
| --- | --- | --- | --- | --- | --- | --- |
| `checks-1` | `scripts/checks/registry.mjs` is the one list. `run.mjs` builds once and runs a group. `package.json`, the close gate, the docs gate, the gate tiers, and the fast lane read it | `scripts/checks/{registry,run,gate-tier,close-prebuilt}.mjs`, `gate-table.json`, `package.json` | `runner` | 260 | none | `checks-2`, `checks-3` |
| `checks-2` | Every check script has one form: a shared helper, `OK` or `FAIL`, an exit code. Scripts the route deletes later are skipped: the template drift checks and `check-chassis-boundary.mjs` | `scripts/checks/*.mjs` | `runner` | 180 | `checks-1` | `checks-1` |
| `checks-3` | Each CI job calls the runner with one group. `actionlint` runs without Go. `check:definitions` runs in CI because it is in the list | `.github/workflows/{test,design}.yml`, `.github/ci-green.json`, `src/tests/unit/workflow-yaml.test.ts` | `runner`, held files | 160 | `checks-1` | `checks-1` |

**Acceptance.**

1. `node scripts/checks/run.mjs --list | wc -l` prints the number of `check:*` scripts in
   `package.json`, which is 34 after the deletion. Today: `run.mjs` and `registry.mjs` are
   missing.
2. A unit test fails when a `check:*` script in `package.json` has no row in the registry, or a
   row has no script. Today: no such test, and `package.json` holds 37 such scripts. The deletion
   leaves 34. The registry is the only list:
   `grep -c "check:" scripts/checks/close-prebuilt.mjs scripts/checks/gate-tier.mjs scripts/checks/gate-table.json`
   prints `0` for each. Today: 40, 33, and 42. A second test compares the checks `check:close`
   runs with the ones it ran at the base, listed in the test, and a third counts the builds in
   one group run and finds one.
3. `grep -c -E "npm run check:|scripts/checks/" .github/workflows/test.yml .github/workflows/design.yml`
   prints `0` for both. Today: `test.yml:23`, `design.yml:1`. A unit test holds each CI job's
   group equal to the checks that job ran at the base, which the test lists from the base's
   workflow file. This is the structure design's item "Each job runs every check it ran
   before", and it catches a group that leaves a check out.
4. `grep -rl "setup-go" .github/workflows` prints nothing. Today (before the deletion):
   `setup-matrix.yml`, `test.yml`, `tool.yml`. After the deletion `test.yml` is left.
5. The workflow test still lints every workflow file, and a deliberately broken workflow in a
   fixture fails it. `src/tests/unit/workflow-yaml.test.ts` keeps at least the 51 test cases it
   holds today. In CI the test fails when the `actionlint` binary is missing. It doesn't skip,
   as `check:tellgrader` does today.
6. A deliberately failing fixture check makes `node scripts/checks/run.mjs <group>` exit non-zero
   and print `FAIL` with the check's name. The checks after it in the group still run and
   report.
7. `checks-2`: a unit test reads the registry and, for every row not on the skip list, finds
   that the script imports the shared helper and ends its output with a line starting `OK` or
   `FAIL`. The skip list names only scripts a later round deletes, each with that round.

**Folds.** #485, #370, #540 (its first half), #489. **Rewords.** #429, #406.

**Merge order.** 1, 2, 3. `checks-3` edits held files, so its merge document says so in fact 2.

## Round 2: `surface`

**Outcome.** The published names nobody should use are gone, as Geoff ruled in
`20261117-091516-5c3656` (answers 1, 2, 6, and 7). The passes are the structure design's, kept.
Their file lists lose every `tool/` path.

| Pass | Outcome | Files | Class | Minutes | Depends on | Shares a file with |
| --- | --- | --- | --- | --- | --- | --- |
| `surface-1` | The sidebar reads the access map alone: `ownerOnly` and `roles` leave nav entries and sections, and `navFilter` goes. `tidy: { client }` becomes `tidyClient`, and `timeoutMs` is removed. The guard that names the removed `preview` key and the three guards for misplaced adapter keys are deleted. Backlog #102, #112, #130, and #161 leave "Won't do" with Geoff's words and the date | `src/lib/sveltekit/{admin-nav,cairn-admin,content-routes-context,content-routes-shell}.ts`, `src/lib/content/adapter.ts`, `src/lib/render/pipeline.ts`, `src/lib/nav/site-config.ts`, `src/lib/reproductions/fixtures.ts`, `examples/showcase/**` outside `admin/signups`, `skills/cairn-extending-a-site/**`, `docs/admin/**`, `BACKLOG.md` | `ordinary` | 200 | none | `surface-2` to `-4` (the snapshot, the changelog, the migration notes) |
| `surface-2` | `validate` replaces `refine` and `behavior` on a fieldset, and replaces `behavior` on a block definition. A failure refuses the save, and a throw fails the save and the build. `BehaviorTable`, `FieldBehavior`, and the log event `content.field_behavior_failed` go. The ruling gains its "Executed" line | `src/lib/index.ts`, `src/lib/content/{concepts,fieldset,types,taxonomy-enforce}.ts`, `src/lib/render/{registry,component-validate}.ts`, `src/lib/log/{events,events-list}.ts`, `docs/internal/engine-rulings.md`, `examples/showcase/**` outside `admin/signups`, `skills/**`, `docs/admin/**` | `ordinary` | 220 | `surface-1` | as above |
| `surface-3` | `ExpandableRow`, the `themeOverride` prop, the `previewMint` prop, and the `formatExpiry` prop are gone. Eight admin components lose a built-in trigger button that no caller renders. `check:self-use` no longer passes a component because a story file mentions it | `src/lib/admin/**` outside `csrf-context.ts` and `CsrfField.svelte`, `src/lib/admin-toolkit/**`, `src/lib/public/PreviewBanner.svelte`, `src/lib/reproductions/**`, `scripts/checks/check-self-use.mjs`, `skills/**` | `runner` | 220 | `surface-2` | as above |
| `surface-4` | `createCairnAdmin` is the one way to mount the admin. `ContentRoutesConfig` leaves `/sveltekit`. The `spellcheckDictionary` fields go, and each dictionary value has one home | `src/lib/sveltekit/content-routes*.ts`, `src/lib/sveltekit/{cairn-admin,index}.ts`, `src/lib/content/{types,compose}.ts`, `src/lib/nav/site-config.ts`, `src/lib/admin/{spellcheck.ts,MarkdownEditor.svelte,EditPage.svelte}`, `src/lib/reproductions/stories/{support,editor}.ts`, the showcase's `src/chassis/cairn.server.ts` | `ordinary` | 220 | `surface-3` | as above |

Every pass also edits the snapshot `scripts/checks/api-surface.md`, `CHANGELOG.md`,
`MIGRATION-NOTES.md`, and `src/tests/**`. No pass edits `src/lib/auth/**`: the sidebar change
leaves `auth/access.ts` alone, so none of the four is `auth-data`.

**The template is generated.** `templates/waymark` is the output of `npm run emit:template` over
the showcase, and `check:template` fails when the two differ. A pass that changes the showcase
runs the command and commits what it writes. That holds until `stock-1` deletes the template,
so no file list in rounds 2 to 4 names a template file.

**Acceptance.** Every pass meets this item: `npm run check:surface` passes with the updated
snapshot, and the snapshot's diff removes exactly the names this design's row for the pass
gives and adds none. A removed name kept under an alias adds a name, so it fails. The items below are
the structure design's, less each `tool/` and `templates/` path, with today's counts read at
`79d326bed`.

`surface-1`:

1. The three flags are off the sidebar.
   `grep -c 'ownerOnly' src/lib/sveltekit/{admin-nav,content-routes-shell,content-routes-context}.ts src/lib/reproductions/fixtures.ts`
   prints `0` for each file, `grep -c 'roles?: string\[\]' src/lib/sveltekit/admin-nav.ts` prints
   `0`, and
   `grep -rn 'navFilter' src/lib --include=*.ts --include=*.svelte | grep -v '\.test\.' | grep -v 'src/lib/auth/' | wc -l`
   prints `0`. Today: 10, 2, 1, and 2; then 2; then 13. `ownerOnly` stays in `section-action.ts`
   and `admin-action.ts`, where it is a server gate.
2. The tidy option has its new name. `grep -c 'tidyClient' src/lib/sveltekit/cairn-admin.ts`
   prints 1 or more,
   `grep -cE 'tidy\?:' src/lib/sveltekit/cairn-admin.ts src/lib/sveltekit/content-routes-context.ts`
   prints `0` for both, and `grep -c 'timeoutMs' src/lib/sveltekit/content-routes-context.ts`
   prints `0`. Today: 0; 1 and 1; 2.
3. The leftover guards are gone. ``grep -c 'has no `preview` key' src/lib/sveltekit/cairn-admin.ts``
   and `grep -c 'ADAPTER_MISPLACEMENTS' src/lib/nav/site-config.ts` print `0`. Today: 1 and 3.
4. The four backlog items moved, and none was deleted.
   `awk '/^## Won.t do/{f=1;next} /^## /{f=0} f' BACKLOG.md | grep -cE '#(102|112|130|161)\b'`
   prints `0`, and the same `awk` over `## Done` prints `4`. Today: 4 and 0.
5. A new test shows that an editor sees no link to an owner-only page under the access map alone.

`surface-2`:

1. The old hooks are gone.
   `grep -rlE '\brefine\b|BehaviorTable|FieldBehavior|behavior\?:|field_behavior_failed' src/lib --include=*.ts --include=*.svelte | grep -v '\.test\.' | wc -l`
   prints `0`, and
   `grep -rlE '\brefine\b|behavior\.<|field_behavior_failed' skills examples/showcase/src docs/admin | wc -l`
   prints `0`. Today: 8 and 3.
2. One integration test saves an entry whose `validate` returns a failure. The save is refused,
   with the message on the field the hook named.
3. One integration test saves an entry whose `validate` throws. The save fails with a server
   error and commits nothing.
4. One unit test of `validateComponent` gives a block definition a `validate` that returns a
   failure and gets it back keyed by attribute.
5. `awk '/cleanup-one-validate-hook/{f=1;next} f&&/^#+ /{f=0} f' docs/internal/engine-rulings.md | grep -c 'Executed'`
   prints `1`. Today: `0`.

`surface-3`:

1. The four unused pieces are gone.
   `for n in ExpandableRow themeOverride formatExpiry; do grep -rl $n src/lib skills --include=*.ts --include=*.svelte --include=*.md | wc -l; done`
   prints three zeros,
   `grep -rnE 'previewMint(\?| =|: boolean|=\{)|\{previewMint\}' src/lib --include=*.svelte | wc -l`
   prints `0`, and `grep -rl 'previewMint={false}' skills examples | wc -l` prints `0`. Today: 6,
   4, and 2; then 6; then 1. The bare word `previewMint` stays as the name of a form action.
2. No component carries a trigger nobody renders.
   `grep -rn 'trigger={false}' src/lib --include=*.svelte | wc -l` and
   `grep -rlE 'trigger\?: boolean' src/lib --include=*.svelte | wc -l` both print `0`. Today: 15
   lines, and 8 files.
3. A new unit test gives `check:self-use` a component only a story mentions and expects a
   failure.

`surface-4`:

1. `ContentRoutesConfig` isn't published under that name or another. After a fresh build, the
   only name in the snapshot at the base that is missing at `HEAD` is `ContentRoutesConfig`, and
   `HEAD` adds no name. `grep -c 'ContentRoutesConfig' scripts/checks/api-surface.md` prints `0`.
   Today: `1`.
2. Each dictionary value has one home.
   `grep -rl 'dictionary-en-us.txt' src/lib --include=*.ts --include=*.svelte | grep -v '\.test\.' | wc -l`
   and the same for `\.cairn/dictionary.txt` both print `1`, and
   `grep -c 'spellcheckDictionary' src/lib/content/{types,compose}.ts src/lib/sveltekit/content-routes-entry-read.ts`
   prints `0` for each. Today: 6 files and 3 files; then 1, 1, and 2.
3. The existing spellcheck tests and the showcase's editor end-to-end spec pass unchanged.

**One edit a later round replaces.** `surface-1` and `surface-4` each change one line in the
showcase's `src/chassis/cairn.server.ts`, which `made-site-1` deletes. The line has to compile in
between, so the edit stays.

**Merge order.** 1, 2, 3, 4. No held file, no `auth-data` path.

## Round 3: `layers`

**Outcome.** `check:layers` holds the dependency order in the target file, with no exceptions.

| Pass | Outcome | Files | Class | Minutes | Depends on | Shares a file with |
| --- | --- | --- | --- | --- | --- | --- |
| `layers-1` | The server side obeys the order. `src/lib/site` holds the adapter, the runtime, and the site record's type and validation. `check:layers` exists with nine listed exceptions | `src/lib/{content,site,delivery,render,media,nav}/**`, `scripts/checks/{check-layers.mjs,layers.json}` | `runner` | 280 | none | `layers-2`, `layers-3` (`layers.json`) |
| `layers-2` | The admin side obeys the order. `CairnHead.svelte` is in `public`. `design` is folded into `audit`. Four exceptions are left | `src/lib/{admin,admin-toolkit,sveltekit,public,audit,design}/**`, `scripts/checks/layers.json` | `runner` | 200 | `layers-1` | as above |
| `layers-3` | `src/lib/mail` is the one sender. `CairnPlatformBindings` lives in `sveltekit`. `env.ts` and `email.ts` are gone, and `CairnEnv` leaves the root entry. `auth.send`, `SendMagicLink`, `EmailRecipient`, `EmailAttachment`, `cc`, `bcc`, and `attachments` go. The last four exceptions go, and `layers.json` loses its `exceptions` key | `src/lib/{mail,auth,sveltekit}/**`, `src/lib/{env,email}.ts`, `layers.json` | `auth-data` | 260 | `layers-2` | as above |

**Acceptance.**

1. `ls scripts/checks/layers.json` prints the path, and `src/lib/site` and `src/lib/mail` each
   hold a non-test `.ts` file that another layer imports. Today: all three missing. A unit test
   fails when a folder under `src/lib` has no row in `layers.json`, or when the rows' order
   differs from the target file's table. A later round that adds a folder adds its row, and
   this test fails until it does.
2. `grep -rlE "from .\.\./(sveltekit|admin|delivery|render|media|nav|auth|github|islands|site)/" src/lib/content --include=*.ts | grep -v test | wc -l`
   prints `0`. Today: `9`. The grep is a quick reading. `check:layers` is the measure, and item
   5 says which import forms it reads.
3. `ls src/lib/env.ts src/lib/email.ts` fails for both. Today: both present.
4. `node -e "const l=require('./scripts/checks/layers.json'); process.exit('exceptions' in l ? 1 : 0)"`
   exits 0 after `layers-3`. After `layers-1` it exits 1 with nine exceptions listed, and after
   `layers-2` it exits 1 with four. Today the file is missing and the command throws. The key
   is the check's only allow list: a unit test greps `check-layers.mjs` and finds no `src/lib`
   path written into it.
5. A fixture that imports upward makes `check:layers` exit non-zero and name the import. There
   is one fixture for each form: a relative path, the package's name, `$lib`, an `import()`
   type, a re-export, and an import inside a `.svelte` file.
6. `layers-3` only: the live admin smoke passes, with the sign-in message sent through `mail`.
   `grep -rn "EMAIL\.send(" src/lib --include=*.ts | grep -v test` prints one line, and it is
   under `src/lib/mail/`. Today: one line, in `src/lib/email.ts`.
7. `layers-2`: `git ls-files src/lib/public/CairnHead.svelte` prints the path, and
   `ls -d src/lib/design` fails. Today: the file is `src/lib/delivery/CairnHead.svelte`, and
   `src/lib/design` exists.
8. `layers-3`: `grep -c CairnEnv src/lib/index.ts` prints `0`, and
   `grep -rlE "SendMagicLink|EmailRecipient|EmailAttachment" src/lib --include=*.ts | grep -v test | wc -l`
   prints `0`. Today: 1, and 4 files.

**A difference from the structure design.** It moved the sender into `auth`. The target puts it
in `mail`, below `content`, because the contact form in `basics-2` sends mail too and mustn't
import `auth`.

**Merge order.** 1, 2, 3. `layers-3` is `auth-data` and sends a merge document.

## Round 4: `errors`

**Outcome.** Every failure an owner or a site developer can fix is a typed `CairnError` with a
registered condition, and `check:errors` holds it. A throw that marks a programmer's mistake
stays a plain `Error` on a named list. Each duplicated function has one copy.

This is the typed-error rule Geoff approved in `20261117-070713-d82261`, as the structure
design applied it. Its list holds 55 throws at most, each with a one-line reason. The route
doesn't convert every throw: that would mean about 170 registered conditions, most of which no
owner could act on.

| Pass | Outcome | Files | Class | Minutes | Depends on | Shares a file with |
| --- | --- | --- | --- | --- | --- | --- |
| `errors-1` | The 105 plain throws outside the guarded folders are sorted: one an owner or site developer can fix becomes a typed error, and a programmer's mistake goes on the check's list. `check:errors` exists. The sweep skips code a later round deletes: the three bins' hand-written parsers and the site-facts functions | `src/lib/**` outside `sveltekit`, `auth`, `github`, `auth-crypto`; `scripts/checks/check-errors.mjs` | `runner` | 300 | none | `errors-2`, `errors-3` (`diagnostics`) |
| `errors-2` | The 64 plain throws in `sveltekit`, `auth`, `github`, and `auth-crypto` are sorted the same way. The four refusal pages share one page. A redirect or error thrown by the rate-limit resolver passes through (#320) | those four folders | `auth-data` | 300 | `errors-1` | as above |
| `errors-3` | One function reads the media manifest. One `parseMdast`. Log event names come from one table. `entry.prior_read_failed` becomes `entry.save_prior_read_failed`. The dev package imports the dev-flag rules | `src/lib/{media,render,log,sveltekit}/**`, `packages/cairn-cms-dev/**` | `ordinary` | 260 | `errors-2` | as above |

**Acceptance.**

1. `npm run check:errors` exists and passes. Today: the script is undefined.
2. `grep -rn "throw new Error" src/lib --include=*.ts --include=*.svelte | grep -v -E "\.test\.|/tests/" | wc -l`
   prints 55 or fewer, and each is on the check's list by file and message with a one-line
   reason. Today: `169`, of which 64 are in the four folders `errors-2` covers. The check reads
   every way to raise a plain error: `throw new TypeError(` and its kin, an `Error` built on
   one line and thrown on another, and `Promise.reject(new Error(`. A fixture for each fails
   it. Today 53 more throws name an error class, `CairnError` among them, and the plan sorts
   the ones that aren't.
3. A fixture with a plain throw in a covered folder makes `check:errors` exit non-zero. So does
   a fixture that throws a `CairnError` whose condition isn't registered.
4. `grep -rln "entry.prior_read_failed" src packages docs skills | grep -v test | wc -l` prints
   `0`. Today: 4 files, one of them `skills/cairn-extending-a-site/references/log-events.md`.
5. `errors-2` only: the live admin smoke passes, and a test shows a resolver's `redirect` reaches
   the response. No status code changes. The counts of `error(4`, `error(5`, `fail(4`, and
   `redirect(3` in the four folders equal the base's (today 43, 3, 124, and 35), and so does
   the count of `status: ` followed by a 4xx or 5xx code. A test renders each of the four
   refusals and finds the one shared page.
6. Site code can't construct the engine's typed error (answer 7). A test imports every path in
   the built package's `exports`, wildcard paths included, and fails if any exported value is
   the `CairnError` constructor under any name. `stock-1` reruns it over the paths it adds.
7. `errors-3`: one function reads the media manifest and one is named `parseMdast`, each shown
   by a grep the plan writes with today's count beside it. A unit test fails on a log call
   whose event name isn't in the table. `packages/cairn-cms-dev` holds no copy of the dev-flag
   rules: the plan names the duplicated function, and a grep finds one definition.

**Folds.** #323, #320. **Kept open.** #418 and #537 stay in the backlog. Each changes what the
Markdown pipeline emits, and neither sits in lines `errors-3` rewrites.

**Merge order.** 1, 2, 3. `errors-2` is `auth-data` and sends a merge document.

## Round 5: `stock`

**Outcome.** Everything a site runs, whatever its look, lives in `src/lib/stock` and is reached by a
published path. The showcase still holds its routes, now thin. The template's generated tree is
gone.

| Pass | Outcome | Files | Class | Minutes | Depends on | Shares a file with |
| --- | --- | --- | --- | --- | --- | --- |
| `stock-1` | First the generated template goes: `templates/`, `emit-template-dir.mjs`, `pack-engine-template.mjs`, their tests, `check:template`, `emit:template`, and the `template` entry in `files`. Then the frame, proven on the home page. The package publishes `./stock/*` and `./themes/*`, ships `src/lib/{stock,features,themes}` beside `dist` with declaration maps, and serves `virtual:site-config` from the Vite plugin with the record check inside it (#546). `stock/site.ts` is the one module that imports the virtual id. The showcase's home route is a shell over a stock loader and a Waymark view. A check holds that a view's relative imports resolve to published paths | `templates/**`, `scripts/build/{emit-template-dir,pack-engine-template}*`, `scripts/release/bump.mjs`, `scripts/gate/record.mjs`, `package.json`, `svelte.config.js`, `tsconfig.json`, `src/lib/{stock,themes/waymark,vite}/**`, `examples/showcase/src/routes/(site)/+page.*`, `scripts/checks/**` with `check-package-files.mjs`, `src/tests/**` | `auth-data`, `runner`, held file | 475 | none | `stock-2`, `stock-3` (`package.json`, `src/lib/stock/**`) |
| `stock-2` | Routing, as Geoff approved it in `20261117-080523-be1fbe`: the value `'custom'`, the catch-all leaves those addresses alone, and the edit screen and rename dialog show the full address for every kind. `conceptEntryLoad` lives in `stock` | `src/lib/{content,delivery,sveltekit,admin,stock}/**` | `ordinary` | 200 | `stock-1` | `stock-1`, `stock-3` (`src/lib/stock/**`); `editor-2` (`EditPage.svelte`) |
| `stock-3` | Every other loader, endpoint, and param matcher moves from the showcase's chassis and routes into `stock`. The directive vocabulary and the base style sheets move with them. The showcase's server route files become re-exports. The chassis keeps two files, `cairn.server.ts` and `dev-gate.ts`, which the request hook and the admin layout import until `made-site-1` | `src/lib/stock/**`, `examples/showcase/src/{chassis,routes,site}/**` | `auth-data` | 356 | `stock-2` | `stock-1`, `stock-2` |

**Acceptance.**

1. `ls -d src/lib/stock` prints the path, and
   `node -e "const e=Object.keys(require('./package.json').exports);process.exit(e.some(k=>k.startsWith('./stock'))&&e.some(k=>k.startsWith('./themes'))?0:1)"`
   exits 0. Today: missing, and it exits 1. The first draft grepped `package.json`, which a
   `files` entry also satisfied. A script resolves every target in `exports`, with its `types`
   and `svelte` conditions, against the list `npm pack --dry-run` prints, and fails on a target
   the package doesn't ship.
2. `npx tsc --showConfig | grep -c '"declarationMap": true'` prints `1`, and
   `node -e "console.log(require('./package.json').files.filter(f=>f.startsWith('src')))"` lists
   the three shipped source folders. `npm pack --dry-run | grep -c '\.test\.ts'` prints `0`, and
   `check-package-files.mjs` holds that. Today: `0`, `[]`, and no `src` file is packed.
3. In a site that installs the packed tarball, `tsc`'s go-to-definition target for the stock home
   loader is a `.ts` file under the package's `src/lib/stock`. A script in the pass resolves the
   declaration map and fails when the target is a `.d.ts` file. The same script reports the
   target for the Waymark home view, a `.svelte` file. `svelte-package` 3.0.3 rewrites the
   sources of a `.d.ts.map`, and nobody has shown that it writes one for a `.svelte` file. If it
   does, the target is under `src/lib/themes/waymark`. If it doesn't, the target is the
   `.svelte` file under `dist`, the pass says so under `## Decisions`, and the target file's
   sentence on shipped source is corrected. `cairn takeover` copies from `src/lib` either way.
   The script reads each target inside the installed tarball, so a map that points at a file
   the package doesn't ship fails.
4. `grep -rln "virtual:site-config" src/lib | grep -v -E "stock/site.ts|/vite/"` prints nothing,
   and `check:layers` fails on a fixture that names the id elsewhere. Today: the id appears
   nowhere. The Vite plugin resolves the id for `stock/site.ts` alone and refuses any other
   importer, which a unit test shows. That closes a second spelling the grep would miss.
5. The showcase builds, prerenders, and passes its end-to-end suite with the home route as a
   shell. The showcase installs the package by a `file:` link, which hides a wrong `files` or
   `exports` entry. The script from item 3 therefore also builds and prerenders the site that
   installed the tarball, and it stays in the registry as a check.
6. `stock-2`: `grep -rnE "export (async )?function conceptEntryLoad" src/lib/stock | wc -l`
   prints `1`, and the same grep over the rest of `src/lib` prints `0`. Today: 0 under `stock`.
   The routing design's acceptance items hold as written, less its template route edits.
7. `stock-3`: `git ls-files examples/showcase/src/chassis` prints two paths, `cairn.server.ts` and
   `dev-gate.ts`. Today: 28 files. No file under the showcase's `src/routes` that ends
   `.server.ts` or `+server.ts` holds more than re-exports and literal page options, apart from
   `hooks.server.ts` and `routes/admin/+layout.server.ts`. A script in the pass checks that.
   The plan lists the old and new path of each directive file and base style sheet, and
   `git ls-files` finds none at an old path.
8. `stock-1`: `ls -d templates` fails, `npm pack --dry-run` lists no path under `template`, and
   `grep -c '"check:template"\|"emit:template"' package.json` prints `0`. Today: 216 tracked
   files under `templates/`, and `2`.

**What stays of the template's build.** `bake-template.mjs`, `emit-template.mjs`, the overlays,
the starter scripts, the exclude markers, and `check:chassis-boundary` stay until `made-site-3`.
A test of the bake that a move in this round or the next breaks is deleted by the pass that
breaks it, and the pass lists the deletion under `## Decisions`.

**Two runtimes for three rounds.** From `stock-1` until `made-site-1` the showcase runs partly on
stock loaders and partly on its chassis. Each round report in between names the routes on each.

**Folds.** #546, #548, #496a, #538, #533, #526 (reworded to the new path).

**Merge order.** 1, 2, 3, each on the one before. `stock-1` and `stock-3` are `auth-data` by the
repo's path map, and each sends a merge document. `stock-1` deletes the template's copies of the
migrations, and `stock-3` turns the preview and sign-up routes into shells. The request hook
moves in `made-site-1`.

## Round 6: `editor`

**Outcome.** The edit screen is five state modules, child components, and one dialog shell, and
the admin's client code reaches the server one way. The passes are the structure design's
`guarded-4`, `editor-1`, `editor-2`, and `editor-3`, kept.

| Pass | Outcome | Files | Class | Minutes | Depends on | Shares a file with |
| --- | --- | --- | --- | --- | --- | --- |
| `editor-1` | `postAdminAction` and `useMediaUrl()` are the admin's two ways to call the server | `src/lib/admin/**`, `src/lib/sveltekit/csrf*` | `auth-data` | 190 | none | `editor-2` to `-4` (`EditPage.svelte`) |
| `editor-2` | State moves into five modules. `EditPage.svelte` is under 2,200 lines | `src/lib/admin/**` | `ordinary` | 280 | `editor-1` | as above |
| `editor-3` | Markup moves into child components. `EditPage.svelte` is under 1,600 lines. The visual baselines are byte-identical | `src/lib/admin/**` | `ordinary` | 200 | `editor-2` | as above |
| `editor-4` | Every dialog uses `AdminDialog.svelte`. A refusal after the dialog closed is announced (#298) | `src/lib/admin/**` | `ordinary` | 310 | `editor-3` | as above |

**Acceptance.**

1. `grep -rn "postAdminAction" src/lib | wc -l` is above `0`, and
   `grep -rl "X-Cairn-CSRF" src/lib/admin --include=*.ts --include=*.svelte | grep -v '\.test\.' | wc -l`
   prints `1`, the module that defines `postAdminAction`. Today: `0` uses, and 8 files build the
   header. `grep -rl "useMediaUrl" src/lib/admin | wc -l` is above `0`, and a grep the plan
   writes for a media address built by hand prints one file. Today: `0` uses.
2. `wc -l src/lib/admin/EditPage.svelte` prints under 2,200 after `editor-2` and under 1,600 after
   `editor-3`. Today: `2924`. For `editor-2`,
   `git diff --stat <base>...HEAD -- src/tests/component/EditPage.test.ts` prints nothing, and
   the file passes the same number of tests as at the base, 242 today. The pass changes no
   test file except to add its new modules to the reset-coverage list. Both are the structure
   design's items for this pass.
3. After `editor-3`, the end-to-end visual baselines match with no file updated.
4. `editor-1` only: the live admin smoke passes.
5. After `editor-4`, `grep -rl '<dialog' src/lib/admin --include=*.svelte` prints
   `AdminDialog.svelte` alone, and a test opens each dialog and finds that shell. Today: 18
   files, and no `AdminDialog.svelte`.
6. `editor-4`: a test closes a dialog, has the server refuse the action, and finds the refusal
   in a live region (#298).

**Merge order.** 1, 2, 3, 4. `editor-1` sends a merge document.

## Round 7: `themes`

**Outcome.** Waymark and Pennant are folders under `src/lib/themes`, each a set of views and named
parts over the stock loaders. The top-level `themes/` folder is gone.

| Pass | Outcome | Files | Class | Minutes | Depends on | Shares a file with |
| --- | --- | --- | --- | --- | --- | --- |
| `themes-1` | Each theme holds a view for every stock page, its named parts, tokens, modes, fonts, and a manifest. A view takes a typed `parts` prop. The showcase's page files become shells, written by `shellFor` in `src/lib/scaffold/shell.ts` through a repo script. `app.html` is byte-identical across themes. `cairn-site.json` gains a `theme` key | `src/lib/themes/**`, `themes/**` (moved), `src/lib/scaffold/**`, `scripts/build/write-shells.mjs`, `scripts/checks/layers.json`, `examples/showcase/src/routes/**`, `schema/cairn-site-1.schema.json`, `src/lib/site/**` | `auth-data` | 484 | none | `themes-2` (`src/lib/themes/*/manifest`) |
| `themes-2` | The theme tools read the new folders. `lay-in.mjs` and `theme-names.mjs` are deleted. The catalog becomes a gallery of demos, with no archive and no version-rise rule | `scripts/{theme,catalog}/**`, `.github/workflows/{catalog,catalog-check,design}.yml`, `schema/cairn-catalog-1.schema.json` | `runner`, held files | 274 | `themes-1` | `themes-1` |

**Acceptance.**

1. `ls -d themes` fails, and `ls -d src/lib/themes/waymark src/lib/themes/pennant` prints both.
   Today: `themes` present, the others missing.
2. The theme contract check passes. It scans views and parts, and it fails on a fixture view
   and on a fixture part that each import a path the package doesn't publish.
3. The showcase builds under each theme by changing only the `theme` key and running the shell
   script. Each build's home page links its theme's style sheet and not the other's. `cmp`
   finds `app.html` identical between the two builds, which shows no theme needs one of its
   own.
4. The showcase's visual baselines, which are Waymark's, match with no file updated. Pennant has
   no baseline suite today. `themes-1` makes one first: it lays Pennant into the showcase at
   the base, records the pages, and its last commit matches them.
5. `ls scripts/theme/lay-in.mjs scripts/theme/theme-names.mjs` fails for both. Today: both
   present.
6. `node -e "const s=require('./schema/cairn-site-1.schema.json');process.exit(s.properties.theme?0:1)"`
   exits 0, and a test shows a record naming a theme the package doesn't hold fails the record
   check. Today: it exits 1.
7. The catalog's pull-request run passes on the proving environment. `catalog.yml` publishes
   only on `main`, so `themes-2` isn't recorded as landed until its first run there passes.
8. `shellFor` is the only writer of shells: the script's output equals the showcase's route
   files, and a test fails when a hand edit makes one differ.

**Where `shellFor` starts.** The first draft had `made-site-2` write `shellFor`, two rounds
after this one first needs it. `themes-1` writes it, with a table of the routes that are shells
so far. Each later pass that turns a route into a shell adds a row. `made-site-2` adds
`siteFiles` and `wranglerConfig` beside it and deletes the script.

**What the live catalog shows.** `catalog.yml` publishes on a push to `main`. When `themes-2`
merges, the live catalog becomes a gallery. The archives already in its bucket stay there,
unlisted, and the route's closing report names them for Geoff, since deleting them can't be
undone.

**Folds.** #535. **Drops.** #410, #488, #415, whose subject `lay-in.mjs` is deleted.

**Merge order.** 1, 2. `themes-1` is `auth-data` by the path map, because the preview and sign-up
page files become shells, and it sends a merge document. `themes-2` edits held files and sends
one too.

## Round 8: `made-site`

**Outcome.** `scaffold` says what a made site contains, the showcase equals it, and what is left
of the template's build is deleted.

| Pass | Outcome | Files | Class | Minutes | Depends on | Shares a file with |
| --- | --- | --- | --- | --- | --- | --- |
| `made-site-1` | The request hook and the admin mount live in `stock`. A site's `hooks.server.ts` and its admin route files are shells. The dev gate stays in the hook and loads `@glw907/cairn-cms-dev` | `src/lib/stock/**`, `src/lib/sveltekit/**`, the showcase's `hooks.server.ts`, `routes/admin/**`, and `src/chassis/**` (deleted) | `auth-data` | 265 | none | `made-site-2` (showcase routes) |
| `made-site-2` | `src/lib/scaffold` gains `siteFiles` and `wranglerConfig` beside `shellFor`, and the shell script from `themes-1` is deleted. The showcase is the files `siteFiles` returns for its record, plus the paths the equality test lists as the showcase's. A test holds the two equal. The made site's `check.yml` runs the unit tests. The showcase's `migrations/` folder is deleted, and `wranglerConfig` points `migrations_dir` at the package's `migrations` folder. The showcase's sign-up demo keeps its second database, `migrations-app/`, and `admin/signups`, which the equality test lists as the showcase's own | `src/lib/scaffold/**`, `examples/showcase/**` with its `wrangler.jsonc` and `migrations/`, `sets/**` | `auth-data` | 380 | `made-site-1` | `made-site-3` (`package.json`) |
| `made-site-3` | The rest of the template's build is deleted: `bake-template.mjs`, `emit-template.mjs`, the overlays, the starter scripts, the exclude markers, and `check:chassis-boundary` | `scripts/build/**`, `scripts/checks/**`, `examples/showcase/**` (markers), `package.json` | `runner` | 185 | `made-site-2` | `made-site-2` |

**Acceptance.**

1. The built package's `scaffold` entry exports `siteFiles`, `shellFor`, and `wranglerConfig`,
   which a `node -e` import shows. Today: no such entry.
2. The equality test runs both ways. Every file `siteFiles` marks as a shell or as generated is
   in the showcase byte for byte. Every file in the showcase is one of those, or a file
   `siteFiles` marks as the owner's, or a path on the test's list. Deleting one shell fails it,
   and so does adding a file that is on no list. The list holds paths and no patterns.
3. `wranglerConfig(record, resources)` round-trips. A test parses its output and finds the
   site's address, every binding the record's features need, `migrations_dir` pointing into the
   package, the assets folder, the compatibility date, and the Worker name and resource ids it
   was given, each written by serializing the value (#551).
4. `ls scripts/build/bake-template.mjs scripts/build/emit-template.mjs` fails for both, and
   `grep -rl "cairn-template:exclude" examples scripts | wc -l` prints `0`. Today: both scripts
   exist.
5. `made-site-1` only: the live admin smoke passes against the showcase, with the hook as a
   shell, and `git ls-files examples/showcase/src/chassis | wc -l` prints `0`.
6. `made-site-2`: `ls -d examples/showcase/migrations` fails, and
   `npx wrangler d1 migrations apply AUTH_DB --local` in the showcase applies the package's
   files, `0002_audit.sql` among them. Today: the showcase holds its own four files and lacks
   that one. `npm pack --dry-run` lists the `migrations` folder, since a made site reads it
   from the installed package.

**What the equality test covers.** It compares the two kinds of file the package writes and
rewrites: shells and generated files. Content and `wrangler.jsonc` are the owner's from the
first write, so the showcase's posts, which its end-to-end tests read, and its local address sit
outside the comparison. The showcase's record says `blog`, and the blog's starter content
doesn't exist until `basics-3`. That is no conflict, because starter content is the owner's and
is never compared. The list of the showcase's own paths holds the sign-up demo
(`migrations-app/`, `routes/admin/signups/**`), the test routes, and the test fixtures.

**Whose file `wrangler.jsonc` is.** It is the owner's. The record doesn't hold a Worker name, a
database id, or a bucket name, and it gains none. `cairn new` creates those resources and passes
them to `wranglerConfig(record, resources)`, which writes the file once. After that `doctor`
reads it and compares only what the record fixes: the site's address in production, the
bindings each feature in the record needs, and `migrations_dir`. A binding, a cron, or a
variable the owner added passes. The showcase's `APP_DB` and its local address are two such
additions, and `command-2` holds that `doctor` passes on them.

**Migrations.** The package's `migrations/` folder is one sequence, and every made site applies
all of it. That gives every site the `audit_log` table from `0002_audit.sql`, empty until the
site wires the audit sink. The showcase's copies carry the same file names, so a database that
applied them sees one new migration. A site's second database is the site's: `wranglerConfig`
writes the first `wrangler.jsonc`, and the file is the owner's after that.

**Folds.** #388, #481 in part (the set's place in `scaffold`), #484, #551.

**Merge order.** 1, 2, 3. `made-site-1` and `made-site-2` are `auth-data` and each sends a merge
document.

## Round 9: `command`

**Outcome.** The package has one bin, `cairn`, with its frame and its first real command.

| Pass | Outcome | Files | Class | Minutes | Depends on | Shares a file with |
| --- | --- | --- | --- | --- | --- | --- |
| `command-1` | `src/lib/cli` holds `bin.ts`, `commands/`, and `report/`. Arguments parse with `parseArgs`. `audit`, `guidance`, and `manifest` are subcommands, and their three bins and hand-written parsers are gone. `cairn help agents` prints the agent contract. One ESLint rule keeps `cli/`, `node:http`, `node:child_process`, and the keyring out of every other folder | `src/lib/cli/**`, `src/lib/{audit,guidance,vite}/bin*`, `package.json`, `eslint.config.js`, `schema/**` | `ordinary` | 326 | none | `command-2` (`cli/bin.ts`) |
| `command-2` | `cairn doctor` runs its local checks on the site's real config, evaluated through Vite. `site-facts.json` and its writer and readers are gone. The check ids the docs cite are derived from the check modules | `src/lib/cli/doctor/**`, `src/lib/vite/**`, `scripts/checks/tool-check-ids.mjs`, `schema/**` | `runner` | 352 | `command-1` | `command-1` |

**Acceptance.**

1. `node -e "console.log(Object.keys(require('./package.json').bin).join(' '))"` prints `cairn`.
   Today: `cairn-manifest cairn-audit cairn-guidance`.
2. `grep -c "no-restricted-imports" eslint.config.js` prints at least `1`, and a fixture that
   imports `cli/` from `stock` fails lint. Today: `0`. So does a fixture in `stock` for each
   of `node:http`, `node:child_process`, and the keyring package.
3. `grep -rl "site-facts" src/lib scripts examples skills docs .claude | wc -l` prints `0`.
   Today: 8 files under the first three folders, and 5 more under `templates/` that `stock-1`
   deletes. The second reader counted 7 under `skills`, `docs`, and `.claude`, and the plan
   records the figure it reads.
4. `cairn doctor --json` on the showcase exits 0 and validates against its schema file. The
   showcase carries a second database and a local address, neither of which the record fixes,
   and `doctor` passes on both. On a showcase copy with one binding removed from
   `wrangler.jsonc` it exits non-zero, names `config.site-record`, and carries the remedy
   (#550).
5. A test compares every command's `--help` output with a recorded file, and fails on a fixture
   command whose flag description changed. A file the pass recorded from its own output proves
   nothing by itself, so the plan holds each command's help text, written from the target
   file's command table, and the recorded files equal the plan's. The docs flag check from
   `release-1` will read the same source.

**Folds.** #550, #407, #302 (the `doctor` half).

**Merge order.** 1, 2.

## Round 10: `site-cmds`

**Outcome.** A site can list its pages, take one over, see what changed, give it back, and update.

| Pass | Outcome | Files | Class | Minutes | Depends on | Shares a file with |
| --- | --- | --- | --- | --- | --- | --- |
| `site-cmds-1` | `cairn pages`, `take-over`, `changes`, and `give-back`, for a page and for a named part, with the saved copy under `.cairn-stock/` | `src/lib/cli/site/**`, `src/lib/cli/commands/**`, `schema/**` | `ordinary` | 404 | none | `site-cmds-2` (`cli/site/`) |
| `site-cmds-2` | `cairn update`: a clean-tree check, the install, the type and record checks, the restore on failure, and the plain report. It writes shells for added routes, rewrites an untouched shell or generated file whose stock text changed, removes the untouched shell of a route the new version dropped, and leaves every edited file alone, naming it | `src/lib/cli/site/**` | `ordinary` | 334 | `site-cmds-1` | `site-cmds-1` |

**Acceptance.** Each runs in a temporary copy of the showcase.

1. After `cairn take-over` of the home page, the route file holds the theme's source with no
   relative import left, the site builds, and `.cairn-stock/index.json` names the file, the
   package version, and the module it came from. `.cairn-stock/` holds the untouched copy. The
   home page's built HTML is byte-identical before and after.
2. `cairn give-back` on an untouched take-over restores bytes equal to `shellFor`. On an edited
   one it exits non-zero and changes nothing. With `--force` it restores.
3. After a stock view changes in a second packed version, `cairn changes` prints a diff whose
   changed lines are the lines that changed and no others, with no network call. A test runs
   it with the network denied.
4. `cairn update` to a version whose stock part lost a prop that a taken-over page passes exits
   non-zero, names the page and the type error, and leaves `git status` clean with the old
   version installed.
5. `cairn update` to a version that adds a route writes that route's shell, and leaves alone a
   path the site already occupies, naming it in the report.
6. `cairn pages --json` validates against its schema file and lists every route `siteFiles`
   gives for the showcase's record, each marked stock or taken over.
7. `cairn update` to a version whose `shellFor` writes different text for a route rewrites an
   untouched shell to the new text. `cairn pages` shows that route as stock before and after.
   A shell the developer edited is left alone and named in the report.
8. `cairn update` to a version that changes a generated file rewrites a copy nobody edited. An
   edited copy is left alone, and the report names it and prints the change to apply by hand.
   The test uses `vite.config.ts` and a workflow file.
9. `cairn update` to a version that drops a route deletes that route's untouched shell and
   names it. A taken-over page at that route is left alone and named.

**How the command knows a file is untouched.** `.cairn-stock/index.json` records a hash of each
shell and generated file as the command last wrote it. `new`, `add`, `update`, `take-over`, and
`give-back` each keep it current. A file whose hash matches is untouched, however the package
was installed. A site with no index, such as a copy of the showcase, gets one on the first
command: each file equal to the installed version's `siteFiles` output is recorded as stock, and
every other file is the owner's. The first draft compared a shell with the installed version's
`shellFor`, and the second reader saw that a shell whose stock text changed would then look
taken over.

**Merge order.** 1, 2.

## Round 11: `features`

**Outcome.** A feature is one folder in the package and one line in a site's record, and events is
the first one. This round replaces `site-events` and foundation pass 6.

| Pass | Outcome | Files | Class | Minutes | Depends on | Shares a file with |
| --- | --- | --- | --- | --- | --- | --- |
| `features-1` | The feature form: `definitions/features.json` rows, `src/lib/features/<id>` with a concept, loaders, and a plain view, and `cairn add <feature>`. Events is built in it. A test feature proves the `wrangler.jsonc` contribution as Geoff ruled in `20261117-062058-a38126`: one variable, one binding matched by name, one concept with a content folder | `definitions/features.json`, `src/lib/features/**`, `src/lib/scaffold/**`, `src/lib/vite/**`, `src/lib/stock/site.ts`, `src/lib/cli/site/**`, `schema/**` | `ordinary` | 430 | none | `features-2` (`features/events`) |
| `features-2` | Waymark and Pennant each draw the events list and an event's page | `src/lib/themes/{waymark,pennant}/**` | `ordinary` | 200 | `features-1` | `features-1` |

**Acceptance.**

1. `node -e "console.log(require('./definitions/features.json').features.map(f=>f.id).join(' '))"`
   prints `events`. Today: the list is empty.
2. In a copy of the showcase without events, `cairn add events` writes the feature's shells and
   one line in `cairn-site.json`, and the site builds with an events list at its address. The
   build's output holds the list and one page for each event in the fixture content.
3. The test feature's variable, binding, and content folder appear in the made site. A request
   to the local Worker reads the variable and the binding. `cairn doctor` passes on the site,
   and fails naming the feature once the binding is removed from `wrangler.jsonc`.
4. An event's address appears in the sitemap and the link picker, and the catch-all doesn't serve
   it.
5. Pennant's events pages match the mock-up in the approved events design,
   `research/pennant-mockups/events-1.html`. A fresh `standards:visual-verifier` gets a render
   of that file as its reference and returns no structural difference. The pass first runs the
   verifier on a render with the date column removed and records that it fails, so the bar is
   known to catch a fault. Waymark draws the list and the page plain, in its own type and
   colour over the stock layout, as the events design says. No mock-up exists for it, and the
   verifier reads its renders at phone and desktop width for overflow and collision alone.
6. A feature reaches the running site through generated code alone. The Vite plugin writes the
   `virtual:site-config` module from the record, with one import for each listed feature's
   concept. A test reads the generated source for the showcase's record and finds that its
   imports name only `features/*` paths and the site's own files. `check:layers` passes, and
   `stock/site.ts` imports no feature.

**The reference the first draft named doesn't exist.** It pointed at the earlier `events`
round's renders. That round merged its feed pass and never ran the other two, and its report is
an unsent draft, so nobody has rendered an events page. The approved look is the Pennant
mock-up alone. The round's report shows Geoff each theme's events pages.

**A ruling this overturns.** `20261117-070713-d82261` kept a feature's type in the site's code.
The update page (`20261117-182244-aa5943`) puts stock code in the package, so the feature's
concept lives in `features/events`.

**Merge order.** 1, 2.

## Round 12: `basics`

**Outcome.** A made site has search, a contact form, and the links a small organization expects.
This round replaces `site-basics` passes 1 to 3.

| Pass | Outcome | Files | Class | Minutes | Depends on | Shares a file with |
| --- | --- | --- | --- | --- | --- | --- |
| `basics-1` | Search over the built site with Pagefind, as a feature | `src/lib/features/search/**`, `src/lib/themes/**`, `definitions/features.json`, `src/lib/scaffold/**` | `ordinary` | 140 | none | `basics-2`, `basics-3` (`src/lib/themes/**`, `definitions/features.json`) |
| `basics-2` | The contact form, as a feature that sends through `mail`. A demo's form is a stand-in that sends nothing, and bot-check setup is a documented manual step (`20261117-062058-a38126`) | `src/lib/features/contact/**`, `src/lib/themes/**`, `definitions/features.json`, `src/lib/scaffold/**` | `auth-data` | 220 | `basics-1` | as above |
| `basics-3` | Topic pages, social links, link-preview tags, and a blog set with neutral starter tags and posts | `src/lib/stock/**`, `src/lib/themes/**`, `sets/blog/**` | `ordinary` | 220 | `basics-2` | as above |

**Acceptance.**

1. The showcase's built site answers a search for a word in a starter post, in an end-to-end
   test.
2. A posted contact form reaches the fake mail binding once, addressed to the site's
   `CONTACT_TO` variable. A fake Siteverify records one call for that post. A post without the
   bot-check token is refused, and so is one the fake Siteverify rejects. A demo build's
   contact page holds a switched-off button and no form address, and the build holds no server
   code for the form.
3. `sets/blog/cairn-set.json` names the kind `blog`, and a test builds a blog site from
   `siteFiles` and finds the set's starter posts and tags in the output. Today: `sets` holds
   `organization` alone.
4. A post's page carries link-preview tags that a test reads, and a topic's page lists its posts.
   The record's social links appear in each theme's footer, which a test reads.
5. `basics-2` only: the live admin smoke passes. Three tests cover what the smoke doesn't. A
   name or subject holding a line break adds no mail header. The recipient comes from the
   site's variables and never from the posted form. A burst of posts from one address is
   refused by the rate limit.

**Who gets the mail.** The site-basics design settled it. The recipient is the `wrangler.jsonc`
variable `CONTACT_TO`, which `cairn new` writes as the owner's sign-in address, and a subject
can carry an address in `CONTACT_TO_<ID>`.

**What a demo is.** Geoff ruled that a demo's form is a stand-in, and no design said what marks
a build as a demo. A demo is a build the gallery's publisher makes. The publisher passes
`demo: true` to the package's Vite plugin, and the contact view reads it from the site's
config. The record has no demo field, so an owner's site can't become one by an edit to the
record.

**Folds.** #388, #481, #484 (the rest of each).

**Merge order.** 1, 2, 3. `basics-2` sends a merge document.

## Round 13: `access`

**Outcome.** The command can hold a credential, talk to Cloudflare and GitHub, read a live site's
state, and draw its screens. The passes share only the command's index files, where each adds
lines of its own: `cli/bin.ts`, `cli/commands/**`, `schema/**`, and `package.json`. `access-3`
builds on nothing in the other two, so a parked `access-1` doesn't hold it.

| Pass | Outcome | Files | Class | Minutes | Depends on | Shares a file with |
| --- | --- | --- | --- | --- | --- | --- |
| `access-1` | Credentials and providers: the keyring and environment readers, `cairn auth set / unset / list / check`, the transport rules, the Cloudflare client, and a fake provider server for tests. The output scrubber covers every stored value | `src/lib/cli/{secrets,providers,report,commands}/**`, `schema/**`, `package.json`, `src/tests/**`, the path map in `.claude/skills/cairn-running-passes/SKILL.md`, `scripts/checks/gate-table.json` | `auth-data` | 430 | none | `access-2`, `access-3` (the index files) |
| `access-2` | `cairn health` with its nine probes and `cairn logs`, run in a site's folder | `src/lib/cli/health/**`, `src/lib/cli/commands/**`, `schema/**` | `ordinary` | 326 | `access-1` | as above |
| `access-3` | The terminal view: the palette for light and dark grounds, ground detection, a pure `frame(state)`, the prompts, and every screen `cairn new` shows. Ends with Geoff's look | `src/lib/cli/term/**`, `src/lib/cli/commands/**`, `package.json` | `ordinary` | 560 | none | as above |

**Acceptance.**

1. With the environment variable and a keyring entry both set, the command uses the environment's
   value. A test shows it.
2. A child process the command starts carries none of `CLOUDFLARE_API_TOKEN`,
   `CLOUDFLARE_API_KEY`, `CLOUDFLARE_EMAIL`, or `GITHUB_TOKEN`. A test dumps the child's
   environment. The command starts a child through one helper alone. The ESLint rule from
   `command-1` allows `node:child_process` in that file and nowhere else, so the one test
   covers every child.
3. A stored token's value never appears in any output of a run against the fake, text or
   `--json`. A test greps the captured output for the whole value, for any run of eight of its
   characters, and for its base64 and URL-encoded forms. It runs on a success and on each
   failure the fake can force: a 401, a 500, a timeout, and a refused redirect.
4. The provider client refuses a redirect and a second host, and times out at 15 seconds. Each
   has a test against the fake.
5. `cairn health --json` against the fake validates against its schema and exits with the
   documented code for each of a pass, a warning, and a failure. For each of the nine probes, a
   test makes the fake fail that probe alone and finds the probe's id in the output.
6. Each screen's frame equals its recorded text at 80 and 120 columns, and
   `standards:tui-visual-verify` passes on screenshots of the real terminal on a light and a dark
   ground. The frames are recorded after Geoff's look, from the screens he approved, so the
   test holds what he saw and not what the pass first drew.
7. `cairn auth list` shows no value, only names and where each is stored.
8. The repo's path map names the command's credential code as `auth-data`.
   `grep -c "src/lib/cli/" .claude/skills/cairn-running-passes/SKILL.md` prints at least `1`, for
   the three folders `secrets`, `providers`, and `setup`. Today: `0`. Without the line, round 14's
   passes would be classed `ordinary` by the map and reviewed as such.

**Where the screenshots come from.** `standards:tui-visual-verify` drives `kitty-headless-shot`,
so `access-3` needs no desktop session and runs like any other pass.

**Geoff's look.** `access-3` sends one `decide` page with the screenshots. Standing answer 22 says
what happens if he asks for changes.

**Rewords carried as requirements.** #393, #437, #389, #508, and the Go terminal items the sweep
kept (#461 to #464, #401, #402, #468 to #470, #472, #473) are read as a list of behavior the new
screens must have. The planner turns each into an acceptance line or closes it as not applying.

**Merge order.** 3, 1, 2. The terminal view needs nothing from the other two and its page for
Geoff goes out earliest that way. A later pass that meets a conflict in an index file resolves
it. `access-1` sends a merge document.

## Round 14: `setup`

**Outcome.** `npm create cairn-site` takes an owner from nothing to a deployed site and a sign-in
link, and an agent can drive it.

| Pass | Outcome | Files | Class | Minutes | Depends on | Shares a file with |
| --- | --- | --- | --- | --- | --- | --- |
| `setup-1` | The runner: the step table, resume state in the site folder, the `--json` event stream, `--plan`, `--apply`, `--dry-run`, and the local steps (write the files from `scaffold`, install, commit). `cairn new` asks the kind and the theme | `src/lib/cli/setup/**`, `src/lib/cli/commands/new.ts`, `schema/**` | `auth-data` | 430 | none | `setup-2` (`cli/setup/`) |
| `setup-2` | The provider steps against the fake: the browser sign-in on the loopback, the GitHub App, the deploy key, the database and bucket, the domain, the wait for HTTPS, the first deploy, and the sign-in link. A CI job makes a site with the real `cairn new` against the fake, builds it, and runs its tests | `src/lib/cli/{setup,providers}/**`, `.github/workflows/test.yml` | `auth-data`, held file | 499 | `setup-1` | `setup-1` |
| `setup-3` | The launcher, about 40 lines. `publish.yml` publishes the engine, the dev package, and the launcher at one version. One live run makes a real site and takes it down | `packages/create-cairn-site/**`, `.github/workflows/publish.yml`, `scripts/release/**`, `scripts/gate/**` | `auth-data` and `live-account`, held files | 278 | `setup-2` | none |

**Acceptance.**

1. A run stopped after any step resumes from that step with `npx cairn new` in the site folder. A
   test stops it after each step in turn.
2. `cairn new --dry-run --json` prints the plan, validates against its schema, and contacts
   nothing. A test runs it with the network denied.
3. The deploy workflow a made site holds installs from a lockfile with scripts off (#423). A test
   reads the file `scaffold` returns.
4. A deploy token the run stores is scoped to Workers, D1, and R2, and the run checks the supplied
   token before using it (#422, #424). Each has a test against the fake. The fake refuses a
   permission-group id that isn't on Cloudflare's published list, which the plan cites with the
   date it was read. The live run in `setup-3` is the proof: its deploy token deploys, and a
   call with it to an endpoint outside those three products is refused.
5. The CI job's made site passes `cairn doctor`.
6. `setup-3`: the live run ends with a sign-in link that opens the admin, recorded in the
   harness's run folder, and the take-down leaves no Worker, database, bucket, or repository,
   which the harness's sweep confirms.
7. The launcher has no dependency: `node -e "console.log(Object.keys(require('./packages/create-cairn-site/package.json').dependencies||{}).length)"`
   prints `0`. Its source is under 60 lines, and it asks npm for the engine at the launcher's
   own version. A test reads the version it asks for and finds no `latest`.
8. `cairn new --plan` writes a plan file that validates against its schema, and
   `cairn new --apply <file>` runs that plan with no prompt. A test applies a recorded plan
   against the fake and finds the steps run equal the plan's.
9. The kinds and themes `cairn new` offers equal the ones `sets/` and the theme manifests give
   under Geoff's answers on the queue page. A test reads the prompt's choices.

**Which kinds `cairn new` offers.** A kind picks a site's starter content, and only `organization`
has any today. `basics-3` adds the blog's. `cairn new` offers the kinds that have starter content,
so it offers those two (ruling 5).

**Which themes go with a kind.** Each theme's manifest lists the kinds it was made for: Waymark
lists `blog`, and Pennant lists `organization`. The catalog reads the list to pick a demo's
content, and nothing compares it with a site's kind. The queue page asked Geoff whether a theme
serves the kinds it lists or every kind, and he took the first answer (ruling 6). Under it the
manifest keeps `kinds`, Survey lists `blog`, `cairn new` offers a kind's listed themes, and each
listed pair has a demo and a baseline. A developer can still name any theme in the record. The
site builds, since every theme holds every view, and `doctor` says the pair is one nobody has
tested. Under the second answer the key leaves the manifest and each theme gains a demo and a
baseline for the other kind, about 300 design minutes across `themes-2`, `basics-3`, and
`survey-2`. If Geoff adds the other three kinds, Waymark lists them under the first answer. That
call is mine.

**What waits for Geoff here.** The live run needs one browser sign-in to Cloudflare, and
publishing the launcher from CI needs npm's trusted-publisher setting for `create-cairn-site`.
Both are in "Steps only Geoff can take". `setup-1` and `setup-2` run without either.

**Rewords carried as requirements.** #391, #395 to #397, #405, #408, #421, #398 to #400, #553,
#245, #383, #302, #304, and the harness items #453, #456, #457, #459, #435, #428, #356, #349,
#355.

**Merge order.** 1, 2, 3. All three send a merge document.

## Round 15: `survey`

**Outcome.** Survey is the third theme in the package, matched to the specimen and the five
mockup screens Geoff approved on 2026-11-09.

| Pass | Outcome | Files | Class | Minutes | Depends on | Shares a file with |
| --- | --- | --- | --- | --- | --- | --- |
| `survey-1` | `src/lib/themes/survey`: a view for every stock and feature page, the named parts, a derived copy of Survey's tokens, its two options, the directive styling, and self-hosted fonts | `src/lib/themes/survey/**` | `ordinary` | 469 | none | `survey-2` |
| `survey-2` | Survey's gallery entry and demos, and Survey as a choice in `cairn new` | `scripts/catalog/**`, `src/lib/scaffold/**`, `definitions/**` | `ordinary` | 235 | `survey-1` | `survey-1` |

**Acceptance.**

1. The theme contract check passes on Survey.
2. A fresh `standards:visual-verifier` grades each of the five screens against its approved
   mockup, with the reference and the render as separate images, and reports no structural
   difference. The pass first gives the verifier the home screen rendered under Waymark and
   records that it reports a structural difference, so the bar is known to catch a fault. The
   five screens are `home.html` (mockup A), `post.html`, `directives.html`,
   `phone-archive-404.html`, and `map-detail.html`, all under `reference/g3/mockups/`. The
   sixth file there, `inks.html`, is no screen. It carries Geoff's approval of two inks, water
   blue and revision purple, and a test finds both among the theme's tokens.
3. The showcase builds under Survey by changing only the `theme` key and rewriting its shells
   with `shellFor`.
4. `theme-contrast` passes on both of Survey's modes.
5. `cairn new --dry-run --json` lists Survey among the themes. The CI job from `setup-2` also
   makes a Survey site against the fake, builds it, runs its tests, and passes `cairn doctor`
   on it. A listing alone would pass on a Survey site that doesn't build.

The design of 2026-11-09 (`specs/2026-11-09-theme-garden-3-survey-design.md`) stays the source for
the look. Its plan was drawn for a copied folder, so the planner writes a new one.

**Merge order.** 1, 2.

## Round 16: `release`

**Outcome.** The docs describe the command and the site that exist, a release candidate is
published under a test dist-tag, and the two automated gate legs have passed on it.

| Pass | Outcome | Files | Class | Minutes | Depends on | Shares a file with |
| --- | --- | --- | --- | --- | --- | --- |
| `release-1` | The command's docs. Every file that carries the deletion's note is rewritten against the command, and the note is gone. The deletion's design counts 38 such files, and the pass's planner records the count it finds. The flag check and the quoted-output check return, fed by the command | `docs/admin/**`, `skills/**`, `plugins/**`, `claude/**`, `scripts/checks/**` | `runner` | 430 | none | `release-2` (`docs/README.md`) |
| `release-2` | The site developer's guide to the update model, the theme author's guide, `docs/architecture.md` with the layer table, and docs stage 5 | `docs/**`, `skills/**` | `ordinary` | 404 | `release-1` | `release-1` |
| `release-3` | The gate's `scripted` and `naive` legs pass against a snapshot. The changelog and migration notes are final. The version files are ready for the cut | `scripts/gate/**`, `scripts/release/**`, `CHANGELOG.md`, `MIGRATION-NOTES.md` | `runner`, held files | 326 | `release-2` | none |

**Acceptance.**

1. `grep -rl "The cairn command is being rebuilt" docs skills plugins claude | wc -l` prints `0`.
   That phrase is the one the deletion's own check greps for. On the deletion's branch at
   `a96deb40b` one file carries it, and the deletion's design expects 38 when it lands. Deleting
   a page would also empty the grep. The plan lists the files that carry the note at the base,
   and each exists at the head or the plan names the page that replaced it.
2. The flag check fails when a docs page names a flag the command doesn't have, shown on a
   fixture page.
3. The quoted-output check fails when a quoted block differs from its recorded run, shown on a
   fixture.
4. Every page follows the repo's docs register, and the docs gate inside `check:close` passes.
   Each pass lists `~/.claude/docs/voice/written-for-people.md` and the repo's
   `docs-register.md` in its plan. A linter can't grade a register, so each pass runs the
   repo's four-gate prose review (`register-check`) on every page it wrote, and its pull
   request records each page's verdict.
5. The gate's `scripted` and `naive` legs each record a pass against the snapshot, in the
   harness's run folder.
6. `npm run check:close` passes on the head commit.
7. `release-2`: a test compares the layer table in `docs/architecture.md` with
   `scripts/checks/layers.json`, row for row. The site developer's guide walks `take-over`,
   `changes`, `give-back`, and `update`, and its quoted output passes the quoted-output check.
   A fixture theme made by following the theme author's guide passes the theme contract check.
   The plan names the page that answers each item `ROADMAP.md` lists for docs stage 5.

**Folds.** #368, #372, #556, #549 (with #274 as its duplicate), #168, #552.

**What the round doesn't do.** It doesn't cut the release. Publishing under `latest` can't be
undone, so the cut waits for Geoff's word after the closing report.

**Merge order.** 1, 2, 3.

## A second track

The busy check reads the main checkout as busy while any session works under it, so two rounds
can't share it. Geoff ruled for one line (ruling 7), so nothing in this section runs. A second
track would have run in a second clone of the repo beside the first, with a second conductor,
and the check used unchanged.

Two rounds can leave the main line without breaking the write-once rule: `editor`, once `stock`
has landed, and `access`, once `command` has landed. Together they are 2,296 of the route's
13,672 design minutes. Each pass in either track still rebases on `origin/main` before its merge,
and the three files every pass edits (`BACKLOG.md`, `CHANGELOG.md`, `docs/STATUS.md`) will
conflict now and then. A conflict there is resolved by the pass that meets it.

I recommend one line. The weekly usage limit sets the route's pace, and a second track reaches
that limit sooner without moving the release.

## What happens to the stopped work

Kept means the target needs the work as designed. Changed means it needs the work in another
form. Dropped means the target doesn't need it.

| Stopped pass | Verdict | Reason | Where it goes |
| --- | --- | --- | --- |
| Foundation 4, `composer` | Drop | It composed a site by copying files, and the update model ends copying | `scaffold` in `made-site-2` replaces it |
| Foundation 5, `chassis` | Change | The chassis moves whole into the package | `stock-3` |
| Foundation 6, `add` | Change | `cairn add` writes shells and one record line, in TypeScript | `features-1` |
| Foundation 7, routing | Keep | The approved design holds. Its template route edits go | `stock-2` |
| The CI edits in #259 | Drop | CI calls the runner, so every listed check runs there by construction | `checks-3`, `themes-2`, `made-site-2` |
| `checks-1`, one list | Keep | Every later pass adds a check | `checks-1` |
| `checks-2`, one form | Change | It skips scripts the route deletes | `checks-2` |
| `surface-1` to `surface-4` | Keep | Geoff ruled the names out. File lists lose `tool/` | `surface-1` to `-4` |
| `layers-1`, `layers-2` | Keep | The order is the target's first 19 rows | `layers-1`, `layers-2` |
| `errors-1`, sweep | Change | It skips code a later round deletes | `errors-1` |
| `errors-2`, duplicates | Keep | As designed | `errors-3` |
| `editor-1` to `editor-3` | Keep | As designed, after routing | `editor-2` to `-4` |
| `guarded-1`, CI calls the runner | Change | It joins the round that builds the runner | `checks-3` |
| `guarded-2`, bindings and mail | Change | The sender becomes the `mail` layer, not part of `auth` | `layers-3` |
| `guarded-3`, routes | Keep | As designed | `errors-2` |
| `guarded-4`, admin's calls | Keep | As designed | `editor-1` |
| The `guarded` round as a place to hold merges | Drop | Clean merges no longer wait for Geoff (`20261117-191047-0ef56b`) | Nowhere |
| `gotool` | Dropped already | The Go tool is deleted | The approved deletion pass |
| `site-events-1`, the events feature | Change | The feature lives in the package | `features-1`, `features-2` |
| `site-events-2`, the live proof | Change | The live proof is the one live run | `setup-3` |
| `site-basics-1`, search | Change | A feature in the package | `basics-1` |
| `site-basics-2`, contact form | Change | A feature that sends through `mail` | `basics-2` |
| `site-basics-3`, links | Change | Stock loaders and theme views | `basics-3` |
| `site-basics-4`, `new` | Change | `cairn new` is written once, in TypeScript | `setup-1`, `setup-2` |
| `site-basics-5`, docs | Change | The docs are written once, at the end | `release-1`, `release-2` |

## Leftovers

Nothing here is done before Geoff approves. Each line says who does it and when.

| Leftover | What happens | Who, when |
| --- | --- | --- |
| Pull request #259 and branch `foundation-ci-edits` | Closed unmerged with a comment that points here. The branch is deleted | The `checks` conductor, before its first launch |
| Branch `foundation-7` (no commits) and its worktree, with the untracked 538-line plan | The plan is copied to `plans/` as reference for `stock-2`'s planner. The worktree and branch are removed | The `checks` conductor |
| Stash `foundation3-task3-wip` and the 106 `agent-*` worktrees | Listed for Geoff in the `checks` round's report with the command that removes them. They are another round's debris and removing a stash can't be undone, so no session removes them unasked | The `checks` conductor reports |
| Queue page `20261117-070205-068a5d`, sent back | Withdrawn. The update page and this design answer both its questions | The desk, on approve |
| Queue page `20261117-073728-22e0c0`, the pass 4 hold | Left in the queue's store, already answered. Pass 4 is dropped, so the hold has nothing to hold | Nobody |
| The foundation block in cairn-cms `docs/STATUS.md` | Replaced by the route's block: the round order, this file's path, and the next launch | The `checks` conductor's first STATUS write |
| Planner and conductor prompts for stopped rounds in `plans/`: 14 tracked files (foundation 4 to 7 and its conductor, `site-events`'s 3, `site-basics`'s 6) and the structure rounds' 23 untracked files (`checks`, `surface`, `layers`, `errors`, `editor`, `guarded`) | Deleted, the tracked ones in the commit that adds the route's prompts. I write the route's prompts fresh under names that open `2026-11-17-route-`, so no old file shares a name with a new one. Five round ids are reused (`checks`, `surface`, `layers`, `errors`, `editor`) because those rounds never launched and left no branch, report, or STATUS block | Me, on approve |
| Prompts for rounds that finished or are running: `theme-garden` 1 to 3, `events`, `pennant`, `theme-catalog`, foundation 1 to 3, and `tool-delete` | Kept. They are the record of work that landed | Nobody |
| The 2026-11-14 `events` round's report | Kept. That round finished | Nobody |
| The approved designs for the stopped rounds, in `specs/` | Kept as the source of findings. Each gains one line at its top naming this file as what replaced it | Me, on approve |
| Published Go leftovers: `create-cairn-site` and six `@glw907/cairn-<os>-<cpu>` packages on npm, three `tool/*` tags, the tool's GitHub releases, the `release-tags` ruleset, the Cloudflare sign-in client | `setup-3` publishes a new `create-cairn-site` over the old name. The rest are listed in the closing report with what each would take to remove | `release-3` reports. Geoff decides |
| Six environment names with no reader | `CAIRN_CF_ACCOUNT_ID`, `CAIRN_CF_READ_TOKEN`, and `CAIRN_GH_READ_TOKEN` get readers in `access-1`. `CAIRN_THEME` and `CAIRN_PLAIN` get readers in `access-3`. `CAIRN_STATE_DIR` is removed from the allowlist in `setup-1`, since setup state lives in the site folder | Those passes |
| Three stale lines no pass may edit (two permission lines, two sentences in the workstation's `cairn-pass` skill) | Listed in the closing report | `release-3` reports. Geoff or a dotfiles pass edits them |
| The Go design records, readable at `79d326bed` under `tool/docs/` | Cited by path and commit in the `access` and `setup` planner prompts | Me, on approve |

## Steps only Geoff can take

| Step | Needed by | What it holds if not done | The check that shows it done |
| --- | --- | --- | --- |
| `[you: look at the terminal screens]` | The page `access-3` sends | Nothing. Standing answer 22 | His answer on that page |
| `[you: sign in to Cloudflare once in a browser, when the setup session asks]` | `setup-3`, the live run | `setup-3`. `survey`, `release-1`, and `release-2` run past it | The run's sign-in step records a token in the keyring, and `cairn auth check` passes |
| `[you: add GitHub Actions as a trusted publisher for create-cairn-site on npm]` | `setup-3`, the snapshot publish | `setup-3`'s publish. The pass sends the exact fields to enter | `npm view create-cairn-site@<test tag>` shows the snapshot |
| `[you: make a test site on Waymark, take it down, then make 907.life on Survey]` | The gate's `owner` leg, after the closing report | The cut | The harness records the `owner` leg |
| `[you: say "cut"]` | The release | The cut | The desk's record of his word |

## Backlog

A subagent swept the 197 open items against this route. Approving the queue page approves these
edits. Each pass's planning session lands the edits for the items its pass names.

- **Fold**, by round: `checks` #485, #370, #540, #489. `errors` #323, #320. `stock` #546, #548,
  #496a, #538, #533. `editor` #298. `themes` #535. `made-site` #551, and with `basics` #388, #481,
  #484. `command` #550, #407. `release` #368, #372, #556, #549, #168, #552.
- **Reword** as a requirement on the pass named: #547 (`stock-1`, the record check enforces
  patterns), #302 and #304 (`command-2`, `setup-1`), #423, #422, #424 (`setup-1`, `setup-2`),
  #429 and #406 (`checks-1`), #378 and #526 (new paths), #531, #64, and the four cards-block
  items (#491b to #494b, new path in the package).
- **Carry as a behavior list** for `access` and `setup`: the Go setup, terminal, and harness items
  those rounds name. The sweep proposed dropping them on the belief that the new `new` does no
  provisioning. It does (`20261117-173947-69f637`), so they stay.
- **Drop**: #410, #488, #415. The strongest case for keeping each is that a theme designer wants
  the tokens build in a site. No site holds a theme copy any more, so the case has no subject.
- **Keep**, stamped: the theme bugs and rules, #418, #537, #527, #532, #497a, #490, #297, #501a,
  and the rest.

The deletion design's 90 verdicts are unchanged.

## Rulings to record

`release-2` writes these into `docs/internal/engine-rulings.md`.

- `scope-verdict-361`: the clause that put "a theme shipped as an npm dependency that updates in
  place" out of scope is overturned by Geoff's update page: "The theme follows the same rule as a
  page."
- `scope-verdict-page-home`: reopened. The home view moves into each theme, which is the engine
  code that verdict's "reopens on" clause names.
- `20261117-070713-d82261`: its "feature type stays in the site's code" half is overturned by the
  update page.

## Reports

Each round's conductor writes `reports/<round>-report.md` as `round-run.md` says, copies it into
`docs/STATUS.md` between its markers, and sends it once at the round's end under the title
standing answer 26 fixes. A round report says what landed, what was flagged for Geoff, the
minutes planned and spent, and the next round's start line.

The `release` conductor writes the route's closing report, `reports/route-report.md`, and sends
it as a `report`. It says what cairn is now, in the target file's terms. It lists what was cut
and why, every flagged call from every round, the published leftovers, and the three stale lines.
It ends with what Geoff does next: the `owner` run, then the word to cut.

## What this design did not do

- I ran no gate and no build for this design. The acceptance outputs marked "Today" are greps and
  listings in a clone.
- A7 is unproven on this repo. `stock-1` exists to prove it, and if it fails, take-over copies from
  a `src` folder shipped without declaration maps and go-to-definition lands on `.d.ts` files.
  Geoff's update page asked that it land on readable source, so that outcome would come to him.
- I didn't run the main-checkout and busy checks, for the reason in "Launch checks".
- Rounds 9 to 16 are priced from the hand-overs' size tables, not from code that exists.

## Sources

- `pass-core`: `references/round.md`, `planner.md`, `round-run.md`, `ready.md`, `advisor.md`.
- The hand-overs in `~/.local/state/desk/handover/`: `2026-11-17-cairn-command-design.md`,
  `2026-11-17-site-update-design.md`, `2026-11-17-foundation-conductor.md`.
- The stopped designs in this folder, named in the table above.
- SvelteKit, "Packaging". <https://svelte.dev/docs/kit/packaging>
- The backlog sweep's working file is quoted in "Backlog". Its full table is in this session's
  transcript.
