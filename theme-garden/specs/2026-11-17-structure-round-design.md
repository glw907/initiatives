# The cairn-cms structure rounds: design

Replaced on 2026-11-17. These rounds are stopped (`20261117-182825-8b4207`), and their work moves to
the route in `specs/2026-11-17-route-rounds.md`, which Geoff approved in queue document
`20261117-210356-a03b21`. This file is kept as the source of its findings.

Initiative: theme-garden. Rounds: `checks`, `surface`, `layers`, `errors`, `editor`, `guarded`,
`gotool`. Status: approved by Geoff on 2026-11-17 in queue document
`20261117-091516-5c3656`. "Rulings" quotes each answer.

Read against cairn-cms at `604b4596d` (`origin/main`) and `389df42fc` (`origin/foundation-3`),
fetched on 2026-11-16, Alaska time. Every count in this design was read or run in a clone at
those commits. I fetched again before sending, on 2026-11-17 at 12:05 AM. `origin/main` was
then `264c96b72`, one commit on, and that commit changes only `docs/STATUS.md`. The numbered
questions are asked on the queue page and repeated under "Questions for Geoff".

## Brief

Seven rounds, 20 passes, and about 4,990 path minutes put the engine and the Go tool into a form
a maintainer can read top to bottom. No pass adds a feature. A site developer sees two seams
renamed, one `validate` hook where two hooks were, one log event renamed and one removed, and
sixteen published names removed that nothing uses. An editor sees no change at all.

The work goes in this order:

1. `checks` gives the repo one list of its checks and one form for a check script.
2. `surface` does the renames and removes what nothing uses from the published names.
3. `layers` gives `src/lib` a dependency order and a check that holds it.
4. `errors` sorts every thrown error by who can fix it, and folds the server-side duplicates.
5. `editor` moves the edit screen's state into modules and gives the admin one dialog shell.
6. `guarded` holds every pass whose pull request waits for you: CI, bindings and mail, the
   sign-in and route errors, and the admin's calls to the server.
7. `gotool` cleans the Go tool. It shares almost no file with the other six, so it runs beside
   them.

Nothing starts when you approve. The first round launches when pass 3 of `foundation` has landed.

## Why

You asked for this on 2026-11-16, after the desk's architecture survey. The survey found that
`src/lib` has no dependency order, that the edit screen is one 2,900-line component, and that
the checks are 16,000 lines with no runner. I verified each finding in the code before designing
from it. Most hold. One is wrong, and the code held a larger problem the survey missed. Both are
under "Where I differ from the survey".

The time is right for a plain reason. Every cairn site is being rebuilt from scratch, and you
aren't using cairn until it is functionally complete. A breaking rename costs nothing today. It
will cost a migration note and a release once a site depends on the name.

## Decided by Geoff

His words, from chat on 2026-11-16:

- "You can do the renames. Also note that all cairn sites are being rebuilt from scratch."
- "You can also do these", of the desk's paragraph on a structure round "beside or after round
  two".
- "Again, I have the spare tokens, so now is the time to make sure all the code is clean,
  streamlined, and with any over-engineering or duplication removed."
- "I'm looking for clean, well-designed code that is easy to maintane over the long-term."
- "I'm looking for a polished, clean, and beautiful codebase on both cases."
- "I can also do a Fable reset at any point, which gives back all the Fable credit used. This is
  an opporutnity to use Fable to lean into any complex design decision for either effort."

A later line reached me through the `desk` session and matches a note in my memory dated
2026-11-16: "Note that I'm not doing anything with cairn until it's functionally complete. So
there's no reason not to implement architectural correctness immediately."

Two readings follow from those lines. Both are the desk's wording, and I designed on them:

- No site that exists today has to keep working across these rounds. A breaking change needs no
  alias and no migration path. The roadmap ruling of 2026-09-27 says the same until the Waymark
  rebuilds land.
- Where a pass could take the full clean form now or a smaller form with the rest left waiting,
  the design takes the full form and prices it honestly.

Earlier rulings this design carries out or leans on:

- `cleanup-one-validate-hook` (2026-11-01): "One fail-closed `validate` hook replaces `refine`
  and `behavior`". The ruling has no "Executed" line, and the code still has both hooks.
- `cleanup-unset-options`: an option no site sets is removed, and "Adding one back isn't a
  break".
- The typed-error rule in queue document `20261117-070713-d82261`, which he approved: "A failure
  is sorted by who can fix it."
- The held paths in `docs/STATUS.md`: `.github/**`, `scripts/release/**`, and `.claude/settings*`
  go to you in one small packet.

## Where I differ from the survey

The survey ran nothing. I ran or read each claim at `604b4596d`.

| Survey item | Verdict | What the code says |
| --- | --- | --- |
| 1. `src/lib` has no dependency order | Holds | 32 import statements in 18 files are upward in the order this design proposes. `content/types.ts` alone imports from seven folders above it. |
| 3. Errors | Holds, undercounted | The survey counted 123 plain `new Error(` calls in five folders. The whole library has 171 in fifteen. |
| 4. The edit screen | Holds | `EditPage.svelte` is 2,924 lines, with 50 state variables, 65 derived values, and 14 effects. |
| 5. The four renames | Three hold | #102 and #130 are one question about the sidebar. #161 holds. #112 is already gone: the option it wanted renamed was removed, and only a guard that names the old key is left. |
| 6. The Go tool | Holds | The terminal grid is written in three packages. 129 of 673 exported names are used only inside their package. |
| 7. The checks have no runner | Wrong | A runner exists. `close-prebuilt.mjs` builds the package once and runs 36 checks. The fault is that the list of checks is kept in three files and again in `package.json`, and four scripts are in no list. |

The larger problem the survey missed is the validate hook. You ruled on 2026-11-01 that one
`validate` hook replaces `refine` and `behavior`. Nine files in the library and the Go tool still
name the old pair or the log event one of them raises, and the approved events design tells a
planner to use `refine`. Pass `surface-2` carries the ruling out.

## The shape the code ends in

### One home for each concept

| Concept | Today | After |
| --- | --- | --- |
| The list of checks | `close-prebuilt.mjs`, `gate-table.json`, `docs-gate.mjs`, and 37 `check:*` strings in `package.json` | One registry module. Every runner reads it, and a test holds `package.json` equal to it. |
| The form of a check script | Four verdict words, the repo root worked out in 22 files, a subprocess runner written in seven files | One helper module, one verdict line, one exit convention |
| Who sees a sidebar link | `hidden`, `ownerOnly`, `roles`, and `navFilter`, none of which authorizes | The access map, which already hides a link from anyone who can't open the page (question 1) |
| The tidy client | A `tidy` block in code beside a `tidy` block in the site's YAML | `tidyClient` in code, and the YAML block as the only `tidy` (question 2) |
| A concept's validation | `refine` and `behavior` on a fieldset, and `behavior` again on a block definition | One `validate` on a fieldset and one on a block definition. A failure refuses the save, and a throw fails it. |
| The adapter and the runtime | In `content/types.ts`, which imports seven folders above it to describe them | A `site` folder above the folders it composes |
| The Worker's bindings | `CairnEnv`, `CairnPlatformBindings`, and `WorkerEnv` | `CairnPlatformBindings`. A lower module names only the fields it reads. |
| The sign-in mail sender | The `EMAIL` binding and an `auth.send` option that only tests set | The `EMAIL` binding (question 6) |
| An error | 171 plain throws in two message styles, a class with 24 conditions, and three subclasses | An owner-fixable failure is a `CairnError` with a registered condition. A retry is a result keyed on `outcome`. A developer's mistake is a plain `Error` in one message form. |
| A Markdown parse | `unified()` built inline in 17 places with two plugin sets | One `parseMdast` |
| The log's event names | The same 78 names in `log/events.ts` and again in `log/events-list.ts` | One table |
| The edit screen's state | 50 state variables in one component | Five modules in the pattern the screen's three existing modules use, and child components for the screen's regions |
| A modal dialog | About 15 hand-rolled shells | One `AdminDialog.svelte` |
| The admin's calls to the server | The CSRF context read in 11 files, and seven hand-built CSRF headers | One module with `postAdminAction` and `useMediaUrl()` |
| The terminal grid | Columns, marks, and wraps written in `style`, `render`, and `newview` | `internal/style` |
| A command's terminal setup | Built five times in `cmd/cairn`, and a sixth time in another form in `root.go` | One function that returns the terminal, the theme, and the width |

### The dependency order of `src/lib`

The table lists the lowest layer first. A folder or root file imports only from lower layers,
which are the rows before its row. An import of a later row is an upward import. Each row
holds one folder or one file, so no two share a rank. The entry files on the last row may
import from anywhere, and nothing imports them.

| Row | Folder or file | What it holds |
| --- | --- | --- |
| 1 | `log` | The log and its event names |
| 2 | `escape.ts` | HTML escaping |
| 3 | `dev-flag.ts` | The rules for the development flag |
| 4 | `diagnostics` | `CairnError` and the conditions |
| 5 | `content` | Concepts, fields, validation, and front matter. `types.ts` imports nothing from a later row. |
| 6 | `github` | The repository backend |
| 7 | `nav` | The site config file |
| 8 | `auth` | Roles, the access map, sessions, and the sign-in mail |
| 9 | `islands` | Island types |
| 10 | `media` | The media manifest and references |
| 11 | `render` | The Markdown pipeline and the component registry |
| 12 | `site` (new) | The adapter and the runtime: `CairnAdapter`, `CairnRuntime`, `BackendProvider`, `defineAdapter`, `composeRuntime` |
| 13 | `delivery` | Public routes and feeds |
| 14 | `cloudflare` | Cloudflare helpers |
| 15 | `env.ts` | The bindings type, until `guarded-2` |
| 16 | `email.ts` | The mail sender, until `guarded-2` |
| 17 | `sveltekit` | The admin's server side, and the bindings shape after `guarded-2` |
| 18 | `admin-toolkit` | Parts a site's custom admin screen uses |
| 19 | `admin` | The admin screens |
| 20 | `public` | Components for the public site |
| 21 | `vite` | The Vite plugin |
| 22 | `guidance` | The guidance command |
| 23 | `reproductions` | Stories and fixtures |
| 24 | `design` | One file, until `layers-2` moves it into `audit` |
| 25 | `audit` | The audit and its command |
| 26 | `index.ts`, `internal.ts`, `ambient.ts`, `auth-crypto` | Published entry files |

`env.ts` and `email.ts` import each other today. Pass `guarded-2` moves the bindings shape into
`sveltekit` and the mail sender into `auth`, and both files go.

A new check, `check:layers`, reads this table from `scripts/checks/layers.json` and fails on any
upward import. It parses each file. It counts `import` and `export … from`
statements, `import('…')` types, and imports of the package by its published name, and it never
counts a path inside a string.

Today 32 import statements in 18 files are upward. Of those, 23 are in `content`. My
script prints the same 32, though it miscounts twice: it counts one path inside a string of
generated code in `vite`, and it misses the import between `env.ts` and `email.ts`. The two
cancel.

The check carries a list of the imports a pass hasn't cleared yet. An entry on the list is one
import statement, named by its file and its target. `layers-1` leaves nine on it: five on the
admin side, two from `github` to `env.ts`, the one from `env.ts` to `email.ts`, and one
re-export of `CairnRuntime` that "Calls made here" explains. `layers-2` leaves four, and
`guarded-2` one. Pass `guarded-3` clears the last and deletes the list.

## Goals

- Each job in the code has one name, and each concept has one home.
- A reader can learn `src/lib` bottom to top, and a check keeps that true.
- Nothing published does no work. A name or option that no site sets is gone.
- A pass that only moves code proves the behavior unchanged with the suites as they stand.
- The feature rounds keep running. No structure pass stops a `foundation` or round-two pass
  that is ready to launch.

## Non-goals

- No feature, no new option, and no change to what an editor sees.
- No release. A pass never bumps the version or publishes.
- No change to `scripts/gate/**`, the release proving harness.
- No rewrite of a component for style. A file changes where a finding names it.
- The full backlog sweep. It is due, with 45 items unstamped in 90 days, and `ready.md` says a
  due full sweep "never rides a design". It runs as a separate session.

## Anti-goals

These would make the rounds a failure even with every check green:

- A rename that leaves an alias behind, or a moved file that leaves a re-export stub.
- A layer check that passes because its exceptions list grew.
- A test deleted or loosened to make a move pass.
- An error sweep that changes which status code a visitor or editor gets.
- A structure pass that makes a feature pass wait.

## Questions for Geoff

The queue page asks each of these in full, with what a site developer or an editor sees under
each option. This table is the short form. "Rulings" records the answer you gave to each. You
took my pick on all twelve.

| # | Question | My pick |
| --- | --- | --- |
| 1 | What decides who sees a sidebar link (#102, #130) | The access map. `ownerOnly` and `roles` leave nav entries and sections. |
| 2 | The name of the tidy option in code (#161) | `tidyClient`, with `timeoutMs` removed |
| 3 | When the rounds start | In the `foundation` hold, once pass 3 has landed |
| 4 | How much runs | All of it: 20 passes, 4,990 minutes |
| 5 | The four rounds longer than the 600-minute guide | Keep them as designed |
| 6 | The published names a site developer loses | Remove all four groups |
| 7 | Whether site code can throw the engine's typed error | Keep it closed |
| 8 | Whether a pass may edit the CI workflow files | Yes, in the round whose merges wait for you |
| 9 | The Go tool's visible changes | Take them |
| 10 | Whether the misnamed log event `entry.prior_read_failed` is renamed (#323) | Rename it to `entry.save_prior_read_failed` |
| 11 | The usage stop after the weekly reset on November 20 | The 85 percent stop returns |
| 12 | How far a plan or a round may overrun | Twice its design minutes, as `round.md` says |

#112 needs no answer. It asked for a new name for the `preview` option of `createCairnAdmin`,
and that option has since been removed. `surface-1` deletes the guard that names the old key and
moves the item to Done.

## Calls made here

These are method and architecture calls, which are mine to make. Each has its reason. You can
skip this section.

**Seven rounds.** A round holds six passes at most, and this work is 20. I grouped the passes so
that every pull request that waits for you is in `guarded` or is the last pass of `gotool`. A
pass that waits holds every later landing of its round. With this grouping, five rounds land
every pass unattended and you read one `merge` document for `guarded` and one for `gotool`.

**`checks` runs first.** Three later passes add a check, and every pass runs the checks. The
list of checks gets one home before anything is added to it. The round shares no file with
`src/lib`.

**One check still runs alone.** Each `check:*` script calls the runner with the check's name.
The runner builds the package first when that check's registry entry says it needs the build,
unless it is told the build is fresh, as CI tells it after its build step. `check:close` runs
the close group and builds once. A check that isn't a node script, such as `check:vale` or the
comment check, is an entry that names its command.

**One validate hook, on a fieldset and on a block.** A fieldset's `validate` takes the front
matter and the body, as `refine` does, and returns a message for each field it refuses. It runs
after the per-field checks pass. A block definition gets the same hook over its attributes,
where it had a `behavior` table. A throw isn't caught, as with `refine` today: the save fails
with a server error, and the build fails. That is the fail-closed form the ruling asks for. The
log event `content.field_behavior_failed` reported a `behavior` hook that threw and was let
through. Nothing can raise it after the pass, so it goes with no replacement, and question 6
tells you so.

**`surface` runs before `layers`.** Removing a name is cheaper than moving it and then removing
it. The surface passes also rewrite `content/types.ts`, the file `layers-1` splits.

**The adapter and the runtime get a folder.** `content/types.ts` imports seven folders above it
because it declares `CairnAdapter` and `CairnRuntime`, and those two types describe the whole
site. They move to a new `site` folder that sits above the folders they name. `content` then
holds only content. `BackendProvider`, which `content/types.ts` imports from `github`, moves with
them.

**`content` names the reader it needs.** Three index files in `content` import the `Backend`
type from `github` and call two of its methods, `readFile` and `listBranches`. `content`
declares a type with those two methods, and `Backend` satisfies it by shape. No file in `github`
changes, so no guarded file is edited. `github` then sits above `content`, which matches the one
import that already runs that way.

**The order is a strict list.** Each folder and root file has one rank, with no ties. A tie
would let two folders import each other, as `env.ts` and `email.ts` do today.

**The order lands with a shrinking list.** Three files on the guarded list import `CairnRuntime`
from `content/types.ts`, and two more import the bindings type. A pass that edits a guarded file
waits for you, and `layers` would then hold `errors` and `editor` behind your answer. So
`layers-1` leaves one type-only re-export in `content/types.ts`, the check lists it, and
`guarded-3` repoints the three imports and deletes it. An entry on the list is one import
statement, named by its file and its target, so a second import in a listed file still fails.
The list can only shrink. A test holds its length at a ceiling that each pass lowers.

**`auth-crypto` stays where it is.** It is a published entry file for one subpath. It ranks with
the other entry files, and no file moves.

**The error sweep is split by who reads the merge.** `errors-1` sweeps the folders outside the
guarded list and lands unattended: 107 plain throws. `guarded-3` sweeps `sveltekit`, `auth`,
`github`, and `auth-crypto`, 64 throws, and waits for you. Together they cover all 171. The rule
both follow belongs to the layering design you approved. I changed nothing in it.

**Eleven throws are a developer's mistake and stay plain.** Ten sit in the story fixtures, the
spellcheck worker, the Cloudflare browser stub, and the conditions table, and one in
`auth-crypto`. None is a fault a
site's owner can fix. Each keeps a plain `Error` and takes the one message form.

**One message form, with a prefix for a command.** Library code writes
`cairn: <function>: <what is wrong>`. A command-line entry file keeps the prefix its tool
already prints, which is `cairn-guidance: `, `cairn-audit: `, or `cairn-manifest: `.
`check:errors` accepts both.

**The three `site-config.ts` subclasses fold into conditions.** `NavValidationError`,
`TidyConventionsError`, and `SiteConfigError` each exist to carry a message to the settings
screen. A condition id does that job, and `cairn doctor` can then show it. Two files in
`sveltekit` test for a subclass with `instanceof`. Neither is guarded, so `errors-1` changes
them to read the condition, and the words an editor sees stay as they are. `SiteConfigError` is
published, so its removal is in question 6.

**The edit screen splits along its existing seam.** Three modules already hold parts of its
state, each a `createX(params)` function that reads the component's values through getters.
`editor-1` adds five more in the same pattern. The keyboard handling, the layout, zen mode, the
element references, and the `editor` variable stay in the component, because a module can't
hold a `bind:this` reference and the editor loses reactivity when passed by value.
`editor-2` then moves the markup of the screen's regions into child components. I set no target below about
1,600 lines. Past that, the component is mostly the wiring between its parts.

**The dialog shell stays internal.** `AdminDialog.svelte` is used by the admin's screens and is
published nowhere. A site that wants a dialog uses daisyUI.

**The Go grid goes to `internal/style`.** `render` and `newview` both draw on it, and `style`
already owns the theme. The pass that removes unused exports runs last, because the two before
it change which names are used.

**Design minutes carry the planning overrun.** `foundation` passes 1 and 2 planned at 1.7 and
1.5 times their design minutes. I priced each pass here as its work minutes times 1.3, plus 40
for an `ordinary` or `runner` pass and 70 for an `auth-data` pass. A plan should come out near
its design figure. A plan over twice the figure still parks.

**Three prices rose after the review.** The fresh reviewer found work the first prices left
out. `surface-2` went from 180 to 220 for the block's hook and the log event. `errors-1` went
from 280 to 300 for ten more throws, the two `sveltekit` files, and a test for each new
condition. `guarded-1` went from 100 to 120 for the list of what each CI job runs today.

## Running beside the other rounds

`round.md` says rounds run one at a time "unless a design says otherwise". This design says
otherwise, within the busy check and `pass-core` as they are. I change neither.

Three things are shared between two rounds in one repo.

**The main checkout.** No structure pass works there. Each pass has a worktree under
`.claude/worktrees/`, cut from `origin/main` or from the branch of the pass before it. The
`foundation` conductor runs `claude-worktree-busy` on its round's worktrees only, so a structure
session never makes that check answer busy.

**`docs/STATUS.md`.** Each conductor copies its round's block into STATUS in the main checkout.
The `foundation` conductor's prompt tells it to stop editing STATUS when another conductor is
live and to send its lines to that conductor. A structure conductor therefore writes STATUS
itself and copies in, unchanged and in the same commit, any block another round's conductor
sends it. Between two structure conductors, the one that started first writes.

**The files.** Two passes can't both change one file. Before each launch, a structure conductor
lists the files changed by every open pull request of another round and holds while one of them
is under its next pass's Files. Its clock stops while it holds. After each of its merges it
waits ten minutes when another cairn-cms conductor is live, so that a feature pass that became
ready launches first. The `foundation` conductor already holds the same way from its side.

The overlaps are few, and the hold only ever applies to these pairs:

| Structure round | Overlaps with | On |
| --- | --- | --- |
| `checks` | `foundation` 4 | `scripts/checks/**` outside the surface snapshot, `package.json` |
| `surface` | `foundation` 4 and 5, the routing pass | `templates/waymark/**`, `examples/showcase/**`, `skills/**`, `docs/internal/engine-rulings.md`, `src/lib/content/**`, the surface snapshot |
| `layers`, `errors` | `foundation` 5, the routing pass | `src/lib/public/**`, `src/lib/delivery/**`, `src/lib/content/**` |
| `editor` | The routing pass | The edit screen and the rename dialog |
| `guarded` | The routing pass | `src/lib/sveltekit/**` |
| `gotool` | `foundation` 6 | `tool/**` |
| `surface-2`, `errors-1`, `errors-2`, `guarded-3` | `foundation` 6, `gotool-3` | One file each of `tool/internal/logs/events.go` and `tool/internal/spine/conditions.json`. `gotool-3` leaves both alone. |
| Any | Round two | Nothing. Round two's passes park if they need a file under `src/lib/**`. |

The conductor reads the hold two ways. It lists the files of every open pull request of another
round. It also reads this table against the live sessions, because a pass that has just
launched has no pull request yet.

One case costs a feature pass a wait. `foundation` passes 4 to 6 are held for a brainstorm. If
one of them is released while a structure pass has its files open, it waits for that pass to
merge. The wait is one pass long at most.

What I assume of the sessions I may not message:

- **The routing design.** It reached your queue as `20261117-080523-be1fbe` while I was writing,
  and I read it in full. It is one engine pass of 200 design minutes. Its files cover
  `src/lib/content/**`, `delivery/**`, `sveltekit/**`, `admin/**`, the surface snapshot, and
  tests. It says "This pass lands before the structure round." I agree for every round that
  shares a file with it, which is all of them except `checks` and `gotool`. Those two share no
  file with it and don't wait. Question 3 says where that leaves each of its two placements.
- **`foundation` passes 4 to 6.** I assume the Files in the approved `foundation` design. If the
  brainstorm changes them, the hold still reads the pull requests, and the table above is
  corrected by the conductor's next report.
- **The sent-back layering document.** I assume nothing from it. The typed-error rule comes from
  the approved document only.

## What a later planner meets

A planner for a round approved before this one reads a tree that has changed. Each of those
designs already says to plan against the files as merged. Four facts are worth knowing:

- The events design and the first `site-events` planner prompt tell the planner to use the
  concept's `refine` hook. After `surface-2` the hook is `validate`. It takes the same front
  matter and body and returns the same shape, and a failure refuses the save.
- A check is added by one entry in the registry, where the round-two prompts expect an entry in
  `gate-table.json` and a `check:*` script.
- `CairnAdapter` and `defineAdapter` are imported from the same published paths as today. Only
  their files inside `src/lib` move.
- The routing pass's fourth routing value is in the tree before `surface` starts. Every
  structure pass keeps it. It is a published name that question 6 doesn't list.

I may not edit an approved design or prompt, and I haven't. If you want the first two
changed in the approved files, say so in a note and I'll do it after approval.

## Scope

In scope, by round:

- `checks`: the list of checks, the runner, and the form of a check script.
- `surface`: the two renames, the validate hook, and every published name or prop that nothing
  uses.
- `layers`: the order of `src/lib` and the check that holds it.
- `errors`: thrown errors outside the guarded list, and the server-side duplicates.
- `editor`: the edit screen's state and markup, and the dialog shell.
- `guarded`: CI, the bindings and mail, the errors in the guarded folders, and the admin's calls
  to the server.
- `gotool`: the terminal grid, `cmd/cairn`, and unused exports.

Read and left waiting, with the reason:

| Finding | Why it waits |
| --- | --- |
| Move `src/lib/audit` and the `cairn-audit` command to the development package | It changes what a site installs and how it runs the audit. That is a product call with a release note, and no pass here needs it. |
| The `BackendProvider` seam with one implementation | A second backend is on the roadmap. Removing the seam now means adding it back. |
| Split `CairnMediaLibrary` | The roadmap's P5 item already owns it. |
| `CairnAdminShell.svelte` and `MarkdownEditor.svelte` | Both are large, and neither has the edit screen's tangle of state. A split would be for size alone. |
| Comments that tell history, about 60 places | Each pass fixes the ones in the files it touches. A sweep of the rest is all churn and no structure. |
| The shared helper for assertive live-region text | One caller today. |
| #320, the sign-in rate limiter failing open | The code records that as deliberate. Changing it is a security decision for you, and it isn't structure. |
| #479, #494a, #510, #513, #515 | Each fixes Go tool output or behavior. They stay out of passes whose proof is unchanged output. |
| The full backlog sweep | It is due and runs as a separate session. |

## How it fails

| What goes wrong | What happens |
| --- | --- |
| A plan comes out over twice its design minutes | The pass parks, and the conductor sends you a `decide` document. |
| A round passes twice its planned minutes | It launches nothing more and reports. |
| A move breaks a published import path | `check:surface` fails on the snapshot. The pass updates the snapshot only for names question 6 lists. |
| A pass's proof fails: a suite count drops, a visual baseline differs, or a Go golden changes that question 9 doesn't list | The line stops. The pass fixes forward or reverts. It never updates the baseline. |
| A pass not classed `auth-data` needs a guarded file | It leaves the file alone and records the need. It parks only if an acceptance item can't be met without it. |
| The layer check's list would have to grow | The pass parks. |
| Another round's open pull request changes a file the next pass needs | The conductor holds, with its clock stopped, and says so in the report. |
| The `foundation` block in STATUS stops updating | The start line can't be read, and the round waits until that block is written again. |
| The weekly allowance reaches the usage stop | The conductor waits for the reset, with its clock stopped. |
| STATUS still forbids `make -C tool check` | `gotool` doesn't start. Other passes that touch a Go file rely on CI for the Go suite. |

The limits, with their numbers: six passes a round; the 600-minute guide for a round's longest
chain, which four rounds exceed (question 5); a park at twice a pass's design minutes and a stop
at twice a round's planned minutes (question 12); the usage stop at 85 percent of the week (question 11); ten
minutes between a structure merge and the next structure launch when another conductor is live.

## Passes

Every pass is in the `theme-garden` initiative. Path minutes are design minutes, priced as
"Calls made here" says. A pass's class comes from the repo's path map. A pass whose only file
under `scripts/checks/**` is the surface snapshot, which a command writes, is `ordinary`, as
pass 2 of `foundation` was. Every pass shares `BACKLOG.md` and `docs/STATUS.md` with every
other, and the last column leaves those two out. "The snapshot" is
`scripts/checks/api-surface.md`. "The guarded list" is the `auth-data` path list in the repo's
`cairn-running-passes` skill.

### Round `checks`: 460 minutes

| Pass | Outcome | Files | Class | Path minutes | Depends on | Shares a file with |
| --- | --- | --- | --- | --- | --- | --- |
| 1 `checks-1` one list | One registry module names every check, the command it runs, and whether it needs the built package. One runner builds the package once and runs the checks asked for. `close-prebuilt`, `docs-gate`, `gate-tier`, and `fast-lane` read the registry. Every `check:*` script keeps its name and calls the runner with it, and a test holds `package.json` equal to the registry. The scripts in no list are registered. Folds #370, #406, #429, #485, and the check half of #540. | `scripts/checks/**` except the snapshot, `package.json`, and the tests under `src/tests/unit/` that import from `scripts/` | `runner` | 260 | None | `checks-2`; `guarded-1` |
| 2 `checks-2` one form | One helper module gives a check script the repo root, a subprocess call, a file walk, and one verdict line. Every check ends with `OK` or `FAIL` in one form and exits 0 or 1. The mutual import between `check-version` and `check-consumers-must` is broken. | `scripts/checks/**` except the snapshot, `scripts/repo-root.mjs`, and the 42 tests that import from `scripts/checks/`. The 13 tests that import from `scripts/gate/` stay as they are. | `runner` | 200 | 1 | `checks-1`; `guarded-1` |

### Round `surface`: 860 minutes

| Pass | Outcome | Files | Class | Path minutes | Depends on | Shares a file with |
| --- | --- | --- | --- | --- | --- | --- |
| 1 `surface-1` renames | The sidebar and the tidy option take the forms you pick in questions 1 and 2. The guard that names the removed `preview` key and the three guards for misplaced adapter keys are deleted. Backlog #102, #112, #130, and #161 leave "Won't do" with your words and the date. | `src/lib/sveltekit/{admin-nav,cairn-admin,content-routes-context,content-routes-shell}.ts`, `src/lib/content/adapter.ts`, `src/lib/render/pipeline.ts`, `src/lib/nav/site-config.ts`, `src/lib/reproductions/fixtures.ts`, `templates/waymark/src/chassis/cairn.server.ts`, `examples/showcase/**` outside `admin/signups`, `skills/cairn-extending-a-site/**`, `docs/admin/**`, the snapshot, `CHANGELOG.md`, `MIGRATION-NOTES.md`, `src/tests/**` | `ordinary` | 200 | `checks-2` (order) | `surface-2`, `-3`, `-4` |
| 2 `surface-2` validate | A fieldset has one `validate` hook, and so does a block definition. A failure refuses the save, and a throw fails the save and the build. `refine`, `behavior`, `BehaviorTable`, `FieldBehavior`, and the log event `content.field_behavior_failed` are gone. The ruling gains its "Executed" line. | `src/lib/index.ts`, `src/lib/content/{concepts,fieldset,types,taxonomy-enforce}.ts`, `src/lib/render/{registry,component-validate}.ts`, `src/lib/log/{events,events-list}.ts`, `tool/internal/logs/events.go`, `docs/internal/engine-rulings.md`, `templates/**`, `examples/showcase/**` outside `admin/signups`, `skills/**`, `docs/admin/**`, the snapshot, the changelog and migration notes, `src/tests/**` | `ordinary` | 220 | 1 | `surface-1`, `-3`, `-4` |
| 3 `surface-3` unused pieces | `ExpandableRow`, the `themeOverride` prop, the `previewMint` prop, and the `formatExpiry` prop are gone. Eight admin components lose a built-in trigger button that no caller renders. `check:self-use` no longer passes a component because a story file mentions it. | `src/lib/admin/**` outside `csrf-context.ts` and `CsrfField.svelte`, `src/lib/admin-toolkit/**`, `src/lib/public/PreviewBanner.svelte`, `src/lib/reproductions/**`, `src/lib/audit/rules/static/{focus-parity,stripe-trim-parity}.ts` (comments), `scripts/checks/check-self-use.mjs`, `skills/**`, `templates/waymark/.claude/skills/**`, the snapshot, the changelog and migration notes, `src/tests/**` | `runner` | 220 | 2 | `surface-1`, `-2`, `-4`; `editor-1` |
| 4 `surface-4` wiring types | `createCairnAdmin` is the one way to mount the admin, and its config spells its fields itself. `ContentRoutesConfig` leaves the published names. The base dictionary's file name and the site dictionary's path each have one home, and the runtime fields that only repeated them are gone. | `src/lib/sveltekit/content-routes*.ts`, `src/lib/sveltekit/{cairn-admin,index}.ts`, `src/lib/content/{types,compose}.ts`, `src/lib/nav/site-config.ts`, `src/lib/admin/{spellcheck.ts,MarkdownEditor.svelte,EditPage.svelte}`, `src/lib/reproductions/stories/{support,editor}.ts`, the snapshot, the changelog and migration notes, `src/tests/**` | `ordinary` | 220 | 3 | `surface-1`, `-2`, `-3`; `layers-1`; `editor-1` |

### Round `layers`: 480 minutes

| Pass | Outcome | Files | Class | Path minutes | Depends on | Shares a file with |
| --- | --- | --- | --- | --- | --- | --- |
| 1 `layers-1` the server side | `content` imports nothing above it. The adapter and the runtime live in a new `src/lib/site` folder. `check:layers` reads the order from `scripts/checks/layers.json`, parses each file's imports, and fails on an upward one. The list of imports not yet cleared holds nine. | `src/lib/**` outside the guarded list, `scripts/checks/{check-layers.mjs,layers.json}`, the registry, `package.json`, `CLAUDE.md`, `docs/internal/**`, `src/tests/**` | `runner` | 280 | `surface-4` | `layers-2`; `surface-4` |
| 2 `layers-2` the admin side | `admin-toolkit` no longer imports `admin`, `sveltekit` no longer imports `admin`, and `admin` no longer imports the root entry file. `CairnHead.svelte` moves into `public`, and the one-file `design` folder moves into `audit`. The list holds four. | `src/lib/{admin,admin-toolkit,sveltekit,public,delivery,design,audit}/**` outside the guarded list, `scripts/checks/layers.json`, `src/tests/**` | `runner` | 200 | 1 | `layers-1` |

### Round `errors`: 560 minutes

| Pass | Outcome | Files | Class | Path minutes | Depends on | Shares a file with |
| --- | --- | --- | --- | --- | --- | --- |
| 1 `errors-1` the sweep | Each of the 107 plain throws outside `sveltekit`, `auth`, `github`, and `auth-crypto` is sorted by the typed-error rule. An owner-fixable one becomes a `CairnError` with a registered condition. The rest keep a plain `Error` in one message form. The three subclasses in `nav/site-config.ts` fold into conditions, and the two files that test for them read the condition. A new check holds the rule. | `src/lib/{content,delivery,render,media,vite,guidance,audit,nav,diagnostics,site,reproductions,cloudflare}/**`, `src/lib/admin/spellcheck-worker.ts`, `src/lib/sveltekit/{content-routes-settings,nav-routes}.ts`, `src/lib/index.ts`, `tool/internal/spine/conditions.json`, `scripts/checks/check-errors.mjs`, the registry, `package.json`, `docs/internal/**`, the snapshot, the changelog and migration notes, `src/tests/**` | `runner` | 300 | `layers-2` | `errors-2` |
| 2 `errors-2` duplicates | The media manifest is read through one function. One `parseMdast` builds the Markdown parser. The log's event names are one table, and the misnamed event takes the name you pick in question 10 (#323). The development package imports the dev-flag rules where it copied them. | `src/lib/{media,render,content,log,delivery,sveltekit}/**` outside the guarded list, `src/lib/admin/{markdown-format,paste-html-to-markdown,tidy-validate}.ts`, `src/lib/dev-flag.ts`, `src/lib/internal.ts`, `packages/cairn-cms-dev/src/handle.ts`, `tool/internal/logs/events.go`, `skills/cairn-extending-a-site/references/log-events.md` and its copy under `templates/waymark/.claude/skills/`, the snapshot, the changelog and migration notes, `src/tests/**` | `ordinary` | 260 | 1 | `errors-1` |

### Round `editor`: 790 minutes

| Pass | Outcome | Files | Class | Path minutes | Depends on | Shares a file with |
| --- | --- | --- | --- | --- | --- | --- |
| 1 `editor-1` state | The edit screen's dictionary commit, preview, block editing, notices, and submit state live in five modules beside the three that exist. `EditPage.svelte` is 2,200 lines or fewer. No test file changes except to add the new modules to the reset-coverage list. | `src/lib/admin/EditPage.svelte`, five new files under `src/lib/admin/`, `src/tests/unit/edit-page-state-reset-coverage.test.ts`, new unit tests | `ordinary` | 280 | `surface-3`, `surface-4` | `editor-2`; `surface-3`, `surface-4` |
| 2 `editor-2` markup | The markup inside the screen's keyed block, about 980 lines today, moves into child components along the regions the screen already has. The plan names them. `EditPage.svelte` is 1,600 lines or fewer. The visual baselines are byte-identical. | `src/lib/admin/EditPage.svelte`, new components under `src/lib/admin/`, new component tests | `ordinary` | 200 | 1 | `editor-1`, `editor-3` |
| 3 `editor-3` the dialog shell | One internal `AdminDialog.svelte` holds the modal shell: open and close, focus return, the title, and the busy state. The admin's dialogs use it. A failed submit after close reaches the page's live region (#298). | `src/lib/admin/**` outside `csrf-context.ts` and `CsrfField.svelte`, `src/tests/**`, `examples/showcase/e2e/**` | `ordinary` | 310 | 2 | `editor-2`; `guarded-4` |

### Round `guarded`: 850 minutes

Every pull request in this round waits for you, in one `merge` document sent when the last pass
ends.

| Pass | Outcome | Files | Class | Path minutes | Depends on | Shares a file with |
| --- | --- | --- | --- | --- | --- | --- |
| 1 `guarded-1` CI | Each CI job calls the runner with one group, and the registry says which checks a group holds. `test.yml` and `design.yml` name no check script themselves. A test holds each group equal to what its job runs today. It runs only if question 8 allows it. | `.github/workflows/{test,design}.yml`, the runner and the registry under `scripts/checks/`, `src/tests/unit/close-ci-coverage.test.ts` | `runner`, held path | 120 | `checks-2` | `checks-1`, `checks-2` |
| 2 `guarded-2` bindings and mail | `CairnPlatformBindings` is the one bindings shape and lives in `sveltekit`. A lower module names only the fields it reads. The sign-in mail goes through the `EMAIL` binding only, and the sender moves into `auth`. `env.ts` and `email.ts` are gone. The list holds one. | `src/lib/{env,email,index}.ts`, `src/lib/{auth,github,sveltekit}/**`, `scripts/checks/layers.json`, the snapshot, the changelog and migration notes, `src/tests/**` | `auth-data` | 240 | `layers-2` | `guarded-3` |
| 3 `guarded-3` routes | The 64 plain throws in `sveltekit`, `auth`, `github`, and `auth-crypto` are sorted by the rule, with no status code changed. The four refusal pages share one page. The preview and the edit load build their render resolvers through one function. The three imports of `CairnRuntime` point at `site`, the re-export is deleted, and the list of exceptions is deleted with it. | `src/lib/{sveltekit,auth,github,auth-crypto}/**`, `src/lib/content/types.ts`, `examples/showcase/src/routes/admin/signups/+page.server.ts` (one stale comment), `scripts/checks/{check-layers.mjs,check-errors.mjs,layers.json}`, `tool/internal/spine/conditions.json`, `src/tests/**` | `auth-data` | 300 | `errors-1`, 2 | `guarded-2`, `guarded-4` |
| 4 `guarded-4` the admin's calls | One module holds the admin's calls to the server: `postAdminAction` sends the CSRF header, and `useMediaUrl()` reads the media address. Components stop reading the CSRF context themselves. | `src/lib/admin/**`, `src/lib/admin-toolkit/**`, `src/lib/reproductions/ReproContext.svelte`, `src/tests/**` | `auth-data` | 190 | `editor-3`, 3 | `guarded-3`; `editor-3` |

### Round `gotool`: 990 minutes

| Pass | Outcome | Files | Class | Path minutes | Depends on | Shares a file with |
| --- | --- | --- | --- | --- | --- | --- |
| 1 `gotool-1` the grid | `internal/style` owns the column helper, the narrow-width limit, and the wrap. `render` and `ui/newview` call it. The "criterion N" comments in the `render` and `style` tests say what each test checks. Folds #474, the rest of #475, and #477. | `tool/internal/{style,render,ui/newview}/**` | `ordinary` | 300 | None | `gotool-2` |
| 2 `gotool-2` commands | One function in `cmd/cairn` returns the terminal, the theme, and the width for a command. Help wraps at 80 columns. Folds #503, #504, #508, #509, #511, the second #512, and #524. | `tool/cmd/cairn/**`, `tool/internal/{style,render}/**`, `tool/internal/{health,logx}/*_test.go` (comments), the Go goldens | `ordinary` | 300 | 1 | `gotool-1`, `gotool-3` |
| 3 `gotool-3` unused names | An exported name used only inside its package is unexported. Code no binary reaches is deleted. A seam that exists only for a test is replaced by a test that needs none. Folds the second #497 and #516 to #521. | `tool/**` except `tool/internal/spine/conditions.json` and `tool/internal/logs/events.go` | `auth-data` | 390 | 2 | `gotool-2` |

## What each merge publishes

No pass bumps the version or publishes a package. Each line below is what a site developer
reads in `CHANGELOG.md` under "Unreleased" when the pass merges, with one `Consumers must:` line
for each thing a site has to change. A pass not listed changes nothing a site can see.

| Pass | What a site developer sees |
| --- | --- |
| `surface-1` | The forms you pick in questions 1 and 2. Under my picks, a nav entry and a section lose `ownerOnly` and `roles`, `navFilter` goes, and `tidy: { client }` becomes `tidyClient: client`. |
| `surface-2` | `validate` replaces `refine` and `behavior` on a fieldset, and replaces `behavior` on a block definition. `BehaviorTable` and `FieldBehavior` leave the root entry. The log event `content.field_behavior_failed` goes, because nothing can raise it. |
| `surface-3` | `ExpandableRow` leaves `/admin-toolkit`. `CairnAdminShell` loses `themeOverride`, `CairnAdmin` and `EditPage` lose the `previewMint` prop, and `PreviewBanner` loses `formatExpiry`. The form action named `previewMint` stays. |
| `surface-4` | `ContentRoutesConfig` leaves `/sveltekit`. `CairnRuntime.spellcheckDictionary` and `EditData.spellcheckDictionary` go. |
| `layers-1`, `layers-2` | Nothing. Each published path maps to a file in `dist`, and the snapshot holds every name where it was. |
| `errors-1` | `SiteConfigError` leaves the published names. A config mistake that threw a plain error now names a condition, and `cairn doctor` can show it. The words an editor reads on the settings and navigation screens don't change. |
| `errors-2` | Under my pick in question 10, the log event `entry.prior_read_failed` becomes `entry.save_prior_read_failed`. |
| `guarded-2` | `CairnEnv` leaves the root entry. `auth.send`, `SendMagicLink`, `EmailRecipient`, `EmailAttachment`, and the `cc`, `bcc`, and `attachments` fields of the sign-in message go. |
| `gotool-1`, `gotool-2` | The Go tool's changes in question 9. No flag, command name, or exit code changes, and `cairn health --json` is untouched. |

Question 9 covers seven changes to what the Go tool prints, and no others:

1. `cairn doctor --help` stops saying that `--color`, `--theme`, and `--width` are ignored
   (`gotool-2`, #508).
2. Six help rows wider than 80 columns come inside 80 (`gotool-2`, #503).
3. The help's group titles lose their colon (`gotool-2`, #503).
4. Two words in flag help are corrected, "Wall-Clock budget" and "colour" (`gotool-2`, #503).
5. An error block honors `--width`, on a terminal only (`gotool-2`, #508).
6. The installer honors `CAIRN_THEME` and `COLORFGBG`, on a terminal only (`gotool-2`, #508).
7. The installer breaks lines differently on a screen too small for it (`gotool-1`).

Changes 1 to 4 reach the bytes a pipe receives.

## Acceptance

Each item has a check that can fail. I ran each once in the clone at `604b4596d`, and "Today"
gives the output. An item that says "Not runnable today" checks something the pass builds.
Every pass also ends with `npm run check`, the unit suite, and `npm run check:close` green.
Today those print `svelte-check found 0 errors`, `Tests 5791 passed | 3 skipped (5794)`, and
`check:close: OK (36 check(s))`.

Three rules hold for every item:

- "The base" is the commit the pass's worktree was cut from. A diff is taken against the base
  with `git diff <base>...HEAD`, so a committed change shows. A count that must not drop is
  compared with the count at the base, which the plan's first task records.
- A check that reads the snapshot runs after a fresh `npm run package`.
- No test is deleted. `git diff --diff-filter=D --name-only <base>...HEAD -- src/tests | wc -l`
  prints 0 for every pass.

Nine passes write for a person: the four `surface` passes, `errors-1`, `errors-2`, `guarded-2`,
`gotool-1`, and `gotool-2`. Each has a last item, "The words follow the standard". The standard
is `~/.claude/docs/voice/written-for-people.md` or the repo's rules. In cairn-cms the repo's
rules apply: `.claude/skills/cairn-writing-docs/references/docs-register.md` for the changelog,
the migration notes, `docs/admin`, and the skills, and the tool's copy rules for Go tool
output. The plan and each launch prompt of those passes name the standard too.

### `checks-1`

1. The registry holds every check, both ways. Check: a new unit test compares the registry with
   a list the plan's first task commits. That list is every name in the four homes the checks have now: the
   `checks` and `extraCommands` keys of `gate-table.json`, `CLOSE_COMPONENTS`, the list in
   `docs-gate.mjs`, and the `check:*` scripts. The test fails on a name missing from the
   registry and on a registry name missing from the list. Today, against `gate-table.json`
   alone, the `check:*` scripts in no list are
   `check:docs-gate check:admin-css-classes check:close check:theme`, and `check:tellgrader`,
   `check:vale-rules`, and `check:version-rise` are in `gate-table.json` with no script.
2. The list is written once. Check: `grep -c 'CLOSE_COMPONENTS = Object.freeze(\[' scripts/checks/close-prebuilt.mjs`
   prints 0, `grep -cE 'check[:-][a-z-]+' scripts/checks/docs-gate.mjs` prints 0, and
   `ls scripts/checks/gate-table.json` fails. Today: 1, 23, and the file exists.
3. No check script builds the package itself, and a built-package check still runs alone.
   Check: the count of `check:*` scripts in `package.json` whose command holds `npm run package`
   is 0, and `rm -rf dist && npm run check:surface` passes. Today: 16, and the second command
   passes because the script builds first.
4. `package.json` can't drift from the registry, in either direction. Check: a new unit test
   fails when a `check:*` script has no registry entry and when a registry entry has no script.
   Not runnable today: the test is new. The plan proves each direction by adding a stray entry
   and watching the test fail.
5. Behavior is unchanged. Check: `npm run check:close` ends `OK`, and its output names each of
   today's 36 checks. Today: `check:close: OK (36 check(s))`.

### `checks-2`

1. A check script doesn't work out the repo root itself. Check:
   `grep -lE "fileURLToPath\(new URL\('\.\.|resolve\(.*import\.meta\.dirname|dirname\(fileURLToPath" scripts/checks/*.mjs | wc -l`
   prints 1, the helper module. Today: 22.
2. One verdict form, printed in one place. Check:
   `grep -lE "(console\.(log|error)|process\.std(out|err)\.write)\(.*\b(PASS|FAILED|OK|FAIL)\b" scripts/checks/*.mjs | wc -l`
   prints 2 or fewer, the helper and the runner. A new unit test runs one passing and one
   failing fixture through the helper and through a registry entry that names a command, as
   `check:comments` does, and expects a last line of the form `<name>: OK` or `<name>: FAIL`.
   Today: 28 files print a verdict, with `PASS` in 5 and `FAILED` in 2.
3. The mutual import is gone. Check: `grep -c 'check-version' scripts/checks/check-consumers-must.mjs`
   prints 0. Today: 1, with 1 the other way.
4. Behavior is unchanged. Check: `npm run check:close` ends `OK` with the same count as after
   `checks-1`. In the 42 tests that import from `scripts/checks/`, a changed assertion may
   change a verdict's word, as from `PASS` to `OK`, and never which fixture passes or fails.
   The reviewer reads each changed assertion. Today: all 42 pass.

### `surface-1`

Items 1 and 2 are written for my picks. A different pick changes the name the check greps for
and nothing else.

1. `ownerOnly`, `roles`, and `navFilter` are off the sidebar. Check:
   `grep -c 'ownerOnly' src/lib/sveltekit/{admin-nav,content-routes-shell,content-routes-context}.ts src/lib/reproductions/fixtures.ts`
   prints 0 for each file, `grep -c 'roles?: string\[\]' src/lib/sveltekit/admin-nav.ts` prints
   0, and `grep -rn 'navFilter' src/lib --include=*.ts --include=*.svelte | grep -v '\.test\.' | grep -v 'src/lib/auth/' | wc -l`
   prints 0. Today: 10, 2, 1, and 2; then 2; then 13. The pass leaves `ownerOnly` in
   `section-action.ts` and `admin-action.ts`, where it is a server gate, and leaves the guarded
   `auth/access.ts` alone.
2. The tidy option has its new name. Check: `grep -c 'tidyClient' src/lib/sveltekit/cairn-admin.ts`
   prints 1 or more, `grep -cE 'tidy\?:' src/lib/sveltekit/cairn-admin.ts src/lib/sveltekit/content-routes-context.ts`
   prints 0 for both, and `grep -c 'timeoutMs' src/lib/sveltekit/content-routes-context.ts`
   prints 0. Today: 0; 1 and 1; 2.
3. The leftover guards are gone. Check: ``grep -c 'has no `preview` key' src/lib/sveltekit/cairn-admin.ts``
   and `grep -c 'ADAPTER_MISPLACEMENTS' src/lib/nav/site-config.ts` print 0. Today: 1 and 3.
4. The four items moved, and none was deleted. Check:
   `awk '/^## Won.t do/{f=1;next} /^## /{f=0} f' BACKLOG.md | grep -cE '#(102|112|130|161)\b'`
   prints 0, and the same `awk` over `## Done` prints 4, each line with Geoff's words and
   "2026-11-16". Today: 4 and 0.
5. A person who can't open a page doesn't see its link. Check: the existing tests of the sidebar
   resolver pass, with one new test that an editor sees no link to an owner-only page under the
   access map alone. Not runnable today: the test is new.
6. The words follow the standard.

### `surface-2`

1. The old hooks are gone. Check:
   `grep -rlE '\brefine\b|BehaviorTable|FieldBehavior|behavior\?:|field_behavior_failed' src/lib tool/internal/logs --include=*.ts --include=*.svelte --include=*.go | grep -v '\.test\.' | grep -v '_test\.go' | wc -l`
   prints 0, and `grep -rlE '\brefine\b|behavior\.<|field_behavior_failed' skills templates | wc -l`
   prints 0. Today: 9 and 6.
2. A failing `validate` refuses the save. Check: one integration test saves an entry whose
   `validate` returns a failure and gets the refusal, with the message on the field the hook
   named. Not runnable today: the test is new.
3. A throwing `validate` fails closed. Check: one integration test saves an entry whose
   `validate` throws. The save fails with a server error and commits nothing. Not runnable
   today.
4. A block's `validate` refuses a bad block. Check: one unit test of `validateComponent` gives a
   block definition a `validate` that returns a failure and gets it back keyed by attribute.
   Not runnable today.
5. The ruling is marked carried out. Check:
   `awk '/cleanup-one-validate-hook/{f=1;next} f&&/^#+ /{f=0} f' docs/internal/engine-rulings.md | grep -c 'Executed'`
   prints 1. Today: 0.
6. The words follow the standard.

### `surface-3`

1. The four unused pieces are gone. Check:
   `for n in ExpandableRow themeOverride formatExpiry; do grep -rl $n src/lib skills templates --include=*.ts --include=*.svelte --include=*.md | wc -l; done`
   prints three zeros, `grep -rnE 'previewMint(\?| =|: boolean|=\{)|\{previewMint\}' src/lib --include=*.svelte | wc -l`
   prints 0, and `grep -rl 'previewMint={false}' skills templates | wc -l` prints 0. The bare
   word `previewMint` stays as the name of a form action in `cairn-admin.ts` and
   `ShareLinkPanel.svelte`. Today the second check prints 6 or more and the third prints 2.
2. No component carries a trigger nobody renders. Check:
   `grep -rn 'trigger={false}' src/lib --include=*.svelte | wc -l` and
   `grep -rlE 'trigger\?: boolean' src/lib --include=*.svelte | wc -l` both print 0. Today: 15
   lines in 8 files, and 8 files.
3. A component only a story mentions fails `check:self-use`. Check: a new unit test gives the
   check such a component and expects a failure. Not runnable today: the test is new.
4. The words follow the standard.

### `surface-4`

1. `ContentRoutesConfig` isn't published, under that name or another. Check, after a fresh
   build: with `names` as `grep -oE '^- \x60[A-Za-z0-9_$]+\x60' | sort -u`, the names in the
   snapshot at the base that aren't in the snapshot at `HEAD` are `ContentRoutesConfig` alone,
   and no name is in the snapshot at `HEAD` that wasn't at the base.
   `grep -c 'ContentRoutesConfig' scripts/checks/api-surface.md` prints 0. Today: 270 names,
   and the last check prints 1.
2. Each dictionary value has one home. Check:
   `grep -rl 'dictionary-en-us.txt' src/lib --include=*.ts --include=*.svelte | grep -v '\.test\.' | wc -l`
   and the same for `\.cairn/dictionary.txt` both print 1, and
   `grep -c 'spellcheckDictionary' src/lib/content/{types,compose}.ts src/lib/sveltekit/content-routes-entry-read.ts`
   prints 0 for each. Today: 6 files and 3 files; then 1, 1, and 2.
3. The spellchecker still loads. Check: the existing spellcheck tests and the showcase's editor
   e2e spec pass unchanged.
4. The words follow the standard.

### `layers-1`

1. `content` imports nothing above it. Check: `npm run check:layers` reports no upward import
   from `src/lib/content/**`, apart from the one listed re-export of
   `CairnRuntime` from `site`. The check counts `import` and `export … from` statements,
   `import('…')` types, and imports of the package by its published name. Today, by my script: 23
   such imports from `content`, in the 32 below.
2. The order holds. Check: `npm run check:layers` passes with nine listed exceptions, each one
   import statement named by its file and its target. Not runnable today: the check is new. My
   script for the same count prints `32 upward imports in 18 files, 13 folder pairs`.
3. The check reads real imports. Check: a unit test gives it a fixture with an `import()` type,
   a re-export, and an import path inside a string, and expects two findings. Not runnable
   today.
4. The list can't grow. Check: a unit test holds the number of exceptions at nine or fewer and
   fails when one is listed that the committed list doesn't hold. Not runnable today.
5. No published path moved. Check: after a fresh build, `npm run check:surface` passes with no
   change to the snapshot against the base.
6. Behavior is unchanged. Check: the unit suite passes at least as many tests as at the base.
   Today: 5,791.

### `layers-2`

1. Four exceptions are left. Check: `npm run check:layers` passes,
   `node -e 'console.log(require("./scripts/checks/layers.json").exceptions.length)'` prints 4,
   and the ceiling in the unit test is 4. Not runnable today.
2. No published path moved. Check: after a fresh build, `npm run check:surface` passes with no
   change to the snapshot against the base.
3. The public site still gets its head tags. Check: `src/tests/component/CairnHead.test.ts`
   passes with only its import line changed.

### `errors-1`

1. The plain throws are sorted. Check: `npm run check:errors` passes. Over the swept folders it
   fails on a `CairnError` whose condition isn't registered. It also fails on a plain
   `new Error(` unless the throw is on the check's list with a one-line reason and its message
   has the form `cairn: <name>: <what>`, where `<name>` is a function declared in the same
   file. A command-line entry file keeps its tool's prefix in place of `cairn: `. The list
   holds 55 throws at most. Not runnable today. The count it starts from, by
   `grep -rn 'new Error(' ... | grep -v '\.test\.' | wc -l` over the swept folders: 107, of
   which my report's sort leaves between 35 and 48 plain.
2. Each new condition is raised by the mistake it names. Check: for each condition the pass
   adds, one unit test makes the mistake and expects that condition's id. Not runnable today.
3. The subclasses are folded. Check:
   `grep -rnE 'NavValidationError|TidyConventionsError|SiteConfigError' src/lib --include=*.ts --include=*.svelte | grep -v '\.test\.' | wc -l`
   prints 0. Today: 41.
4. An editor reads the same words. Check: the settings and navigation save tests pass with
   their expected messages unchanged against the base.
5. The Go tool knows each new condition. Check: `npm run check:tool-conditions` passes.
   Today: it passes, with 24 conditions.
6. No test was loosened. Check: every changed `toThrow(` assertion still names a message or a
   condition. The reviewer reads each one. Today: 465 `toThrow(` assertions under `src/tests`.
7. The words follow the standard.

### `errors-2`

1. One parser. Check: `grep -rn 'unified()' src/lib --include=*.ts | grep -v '\.test\.' | wc -l`
   prints 2 or fewer, and `grep -rl "from 'unified'" src/lib --include=*.ts --include=*.svelte | grep -v '\.test\.' | wc -l`
   prints 1. Today: 17 and 11.
2. One list of log events. Check: `src/lib/log/events-list.ts` is deleted or derives its list
   from `log/events.ts`, and a test fails when a name is in one and not the other. Not runnable
   today.
3. The event has the name you picked. Under my pick, check:
   `grep -rn 'entry.prior_read_failed' src/lib tool/internal skills templates | grep -v test | wc -l`
   prints 0. Today: 6.
4. One reader of the media manifest. Check:
   `grep -rn 'parseMediaManifest(' src/lib/sveltekit --include=*.ts | grep -v '\.test\.' | wc -l`
   prints 1. Today: 14, by my server-library report. The plan's first task confirms the count.
5. The development package imports the dev-flag rules. Check:
   `grep -cE 'Change them together|isLocalHost *=|function isLocalHost' packages/cairn-cms-dev/src/handle.ts`
   prints 0. Today: the file copies the message, the rule, and `isLocalHost` under that comment.
6. Behavior is unchanged. Check: the unit suite passes at least as many tests as at the base.
7. The words follow the standard.

### `editor-1`

1. The component is smaller. Check: `wc -l src/lib/admin/EditPage.svelte` prints 2,200 or
   fewer. Today: 2,924.
2. Behavior is unchanged. Check: `npx vitest run src/tests/component/EditPage.test.ts` passes
   as many tests as at the base, and `git diff --stat <base>...HEAD -- src/tests/component/EditPage.test.ts`
   prints nothing. Today: 242 passed.
3. Each new module resets with the entry. Check: `src/tests/unit/edit-page-state-reset-coverage.test.ts`
   passes with the five new modules in its list, and no `RESET_EXEMPT:` list is longer than at
   the base.

### `editor-2`

1. The component is smaller. Check: `wc -l src/lib/admin/EditPage.svelte` prints 1,600 or fewer.
2. The screen looks the same. Check: the admin visual spec passes in CI against the committed
   baselines, and `git diff --stat <base>...HEAD -- examples/showcase/e2e/admin-visual.spec.ts-snapshots`
   prints nothing.
3. Behavior is unchanged. Check: `EditPage.test.ts` passes as many tests as at the base, with
   no change to the file.

### `editor-3`

1. The dialogs share one shell. Check:
   `grep -rlE '<dialog|role="(alert)?dialog"' src/lib/admin src/lib/admin-toolkit --include=*.svelte | wc -l`
   prints 5 or fewer, and the plan names each file left with its reason. Today: 19.
2. The screens look the same. Check: the same diff of the visual baselines as in `editor-2`
   prints nothing.
3. #298 is fixed. Check: a new component test fails a submit after the dialog closes and finds
   the message in the page's live region. Not runnable today.

### `guarded-1`

1. CI names no check script. Check:
   `grep -cE 'scripts/checks/check-|npm run check:' .github/workflows/test.yml .github/workflows/design.yml`
   prints 0 for both. Today: 23 and 1.
2. Each job runs every check it ran before. Check: the plan's first task writes the checks each
   CI job runs today into the fixture of `src/tests/unit/close-ci-coverage.test.ts`, and the
   test fails when a job's group lacks one. The first CI run on the pull request shows each in
   its log.
3. The jobs and the test steps stay. Check:
   `git diff <base>...HEAD -- .github/workflows | grep -cE '^-.*npm run test'` prints 0.

### `guarded-2`

1. One bindings shape. Check:
   `grep -rnE 'CairnEnv|WorkerEnv' src/lib --include=*.ts --include=*.svelte | grep -v '\.test\.' | wc -l`
   prints 0. Today: 12.
2. One way to send the sign-in mail. Check: `grep -rn 'SendMagicLink' src/lib --include=*.ts | grep -v '\.test\.' | wc -l`
   prints 0. Today: 6.
3. One exception is left. Check: `npm run check:layers` passes, the list holds 1, and the
   ceiling in the unit test is 1.
4. Sign-in still works. Check: the sign-in integration tests pass with the `EMAIL` binding
   faked where they set `auth.send`, and the live smoke test in the close checklist passes.
5. The words follow the standard.

### `guarded-3`

1. The throws are sorted. Check: `npm run check:errors` passes with `sveltekit`, `auth`,
   `github`, and `auth-crypto` added to its folders. Today, by the same grep: 64.
2. No status code changed. Check: over the three folders, the count of each of `error(4`,
   `error(5`, `fail(4`, `redirect(3`, and `status: ` followed by a 4xx or 5xx code is the same
   as at the base. No integration test changes an expected status. A converted throw on a path
   no integration test reaches gets its test before the change. The security reviewer reads
   every changed refusal. Today: 43, 3, 117, 35, and 9.
3. The order has no exceptions. Check: `npm run check:layers` passes, and
   `scripts/checks/layers.json` has no `exceptions` key.

### `guarded-4`

1. One reader of the CSRF context. Check:
   `grep -rlE 'csrf-context|CSRF_CONTEXT_KEY' src/lib --include=*.ts --include=*.svelte | grep -v '\.test\.'`
   prints five files: `csrf-context.ts`, `CairnAdminShell.svelte` and `ReproContext.svelte`,
   which set the context, `CsrfField.svelte`, and the new module. Today: 12 files.
2. One caller of `fetch`. Check:
   `grep -rnE '\bfetch\b' src/lib/admin --include=*.ts --include=*.svelte | grep -v '\.test\.' | grep -v spellcheck-worker | grep -vE '^\S+:\s*(//|\*)' | wc -l`
   prints 1, so a `fetch` passed as a value counts. Today: 2 calls outside the worker.
3. A request without the token is still refused. Check: the existing CSRF integration tests
   pass unchanged.

### `gotool-1`

1. One column helper, one wrap, and one narrow-width limit, all in `internal/style`. Check:
   `grep -rnE 'func (atColumn|Wrap)\b|widthNarrow *=' tool/internal/render tool/internal/ui/newview --include=*.go | grep -v _test | wc -l`
   prints 0. Today: 3, at `render/layout.go:341`, `newview/grid.go:63`, and
   `render/width.go:13`, each beside its twin in `style`.
2. The test comments say what they check. Check: `grep -rnE 'criterion [0-9]' tool/internal/render tool/internal/style --include=*_test.go | wc -l`
   prints 0. Today: 60.
3. Output is unchanged except where question 9 allows. Check: `make -C tool check` passes, and
   `git diff --stat <base>...HEAD` on the goldens shows only the installer's too-small screen.
   Not run by me: STATUS forbids `make -C tool check` while your 907.life setup is live. The Go
   report ran `go build ./...` and `go vet ./...`, and both passed.
4. The words follow the standard.

### `gotool-2`

1. One terminal setup. Check: `grep -rn 'style.NewTheme(resolveGround' tool/cmd/cairn --include=*.go | grep -v _test | wc -l`
   prints 1. Today: 5.
2. The rest of the comments. Check: `grep -rnE 'criterion [0-9]' tool --include=*_test.go | wc -l`
   prints 0. Today: 86, of which `gotool-1` clears 60.
3. Help fits 80 columns. Check: a test walks every command's help and fails on a line over 80.
   Not runnable today.
4. Output changes only where question 9 allows. Check: `make -C tool check` passes, and
   `git diff --stat <base>...HEAD` on the goldens holds only the help text and
   `cairn doctor --help`.
5. The words follow the standard.

### `gotool-3`

1. Nothing unreachable is left. Check: with `deadcode` pinned to one version in the `Makefile`,
   `deadcode -test ./...` in `tool` prints nothing, and `deadcode ./...` prints exactly the
   lines of a committed list: the functions only the three development commands and the test
   fixtures reach. Today: 2 lines and 69 lines.
2. No name is exported only for the package that declares it. Check: the Go report's export script lands in
   the repo as a test. It fails on a package-level name used only inside its package unless the
   name is on a list of 10 at most, each with its reason. Today: 129 of 673.
3. Output is unchanged. Check: `make -C tool check` passes, and `git diff --stat <base>...HEAD`
   on the goldens prints nothing.

## Shared assumptions

| Assumption | Probe or source | Result |
| --- | --- | --- |
| No site that exists today has to keep working across these rounds | Geoff, 2026-11-16: "all cairn sites are being rebuilt from scratch". The roadmap ruling of 2026-09-27 | Holds, on the desk's reading of his words |
| The access map already hides a sidebar link from a person who can't open the page | Read of `src/lib/sveltekit/content-routes-shell.ts` line 204, `hrefReachable` and `engineVisible` | Holds at `604b4596d` |
| No template or showcase sidebar entry sets `ownerOnly`, `roles`, or `navFilter` | `grep -rnE 'ownerOnly\|navFilter' templates examples/showcase/src` | Three hits, all in the showcase's signups page: two comments and one section action. None is a sidebar entry |
| The suites are green before any pass | `npm run check`, the unit suite, `EditPage.test.ts`, and `npm run check:close`, each run once in the clone | `0 errors`; `Tests 5791 passed \| 3 skipped (5794)`; `242 passed`; `check:close: OK (36 check(s))` |
| A `validate` hook's type already exists | `src/lib/content/types.ts` line 411 and `concepts.ts` line 258 | `validate(frontmatter, body): ValidationResult` |
| 32 import statements are upward in the proposed order | My script over the import graph of `src/lib`, `research/2026-11-17-structure-round/scripts/order2.py` | `32 upward imports in 18 files, 13 folder pairs` |
| `Backend` satisfies a two-method reader that `content` declares | Read of `src/lib/github/backend.ts` and the three index files in `content` | The three files call only `readFile` and `listBranches`. Unproven by a compile. `layers-1`'s first task makes the change and runs `npm run check` |
| A throw from `refine` already fails the save and the build | `skills/cairn-extending-a-site/references/content-model.md` lines 82 to 92 | "A throw is not caught: it fails the save with a server error and fails the build." |
| Moving the adapter and the runtime into `site` changes no published path | Read of the `exports` map in `package.json`: each path names an entry file, and the entry files stay | Unproven by a run. `layers-1`'s first task moves one type and runs `check:surface` |
| The typed-error rule is approved, and `CairnError` is closed to site code | Queue document `20261117-070713-d82261` | "A failure is sorted by who can fix it." and "its list of conditions is closed" |
| Round two changes no file under `src/lib/**` | Standing answer 17 of the round-two design | "A feature needs a file under `src/lib/**`: the pass parks." |
| `foundation` holds after pass 3 | Queue document `20261117-073728-22e0c0`, approved | Passes 4 to 6 wait for the brainstorm on updating a site |
| The `foundation` conductor holds for a structure pass as this design holds for its passes | Its prompt, rules 4 to 6 | "If a live pass in another round has a path from this round's pass table open, hold and say so in the report." |
| The routing pass's files and placement | Read of `specs/2026-11-17-routing-design.md` and queue document `20261117-080523-be1fbe` | Unanswered when I sent this. `surface`'s start line reads the answer |
| The Go passes change no flag, command name, exit code, or line of `cairn health --json` | The Go report's read of `tool/**`, with `go build ./...` and `go vet ./...` passing | Unproven by the suite. I ran neither `make -C tool check` nor the Go tests, because STATUS forbids the first while your setup is live |
| The admin's visual baselines match in CI on an untouched branch | Not probed | Unproven. `editor-2`'s first task runs the visual spec in CI before any markup moves |
| The hold can read another round's open files | `gh pr list` in the clone | Lists #258, "Foundation 3: the site record" |
| A planner launches with the line the conductors use | `claude --help` | Lists `--bg`, `--model`, `--effort`, and `--name`, and no `--advisor`, which is accepted all the same |

Four assumptions are unproven. Two of them belong to `layers-1`: the `site` folder move and the
two-method reader. Neither can be proved earlier, because the `surface` passes rewrite the
files `layers-1` moves. The first task of `layers-1` proves both, and standing answer 22
applies if either fails.

## Order

Round `checks`:

| Pass | Planner prompt | Depends on | Path minutes | Waits for Geoff |
| --- | --- | --- | --- | --- |
| 1 one list | `plans/2026-11-17-checks-1-planner-prompt.txt` | none | 260 | no |
| 2 one form | `plans/2026-11-17-checks-2-planner-prompt.txt` | 1 | 200 | no |

Round `surface`:

| Pass | Planner prompt | Depends on | Path minutes | Waits for Geoff |
| --- | --- | --- | --- | --- |
| 1 renames | `plans/2026-11-17-surface-1-planner-prompt.txt` | none | 200 | no |
| 2 validate | `plans/2026-11-17-surface-2-planner-prompt.txt` | 1 | 220 | no |
| 3 unused pieces | `plans/2026-11-17-surface-3-planner-prompt.txt` | 2 | 220 | no |
| 4 wiring types | `plans/2026-11-17-surface-4-planner-prompt.txt` | 3 | 220 | no |

Round `layers`:

| Pass | Planner prompt | Depends on | Path minutes | Waits for Geoff |
| --- | --- | --- | --- | --- |
| 1 the server side | `plans/2026-11-17-layers-1-planner-prompt.txt` | none | 280 | no |
| 2 the admin side | `plans/2026-11-17-layers-2-planner-prompt.txt` | 1 | 200 | no |

Round `errors`:

| Pass | Planner prompt | Depends on | Path minutes | Waits for Geoff |
| --- | --- | --- | --- | --- |
| 1 the sweep | `plans/2026-11-17-errors-1-planner-prompt.txt` | none | 300 | no |
| 2 duplicates | `plans/2026-11-17-errors-2-planner-prompt.txt` | 1 | 260 | no |

Round `editor`:

| Pass | Planner prompt | Depends on | Path minutes | Waits for Geoff |
| --- | --- | --- | --- | --- |
| 1 state | `plans/2026-11-17-editor-1-planner-prompt.txt` | none | 280 | no |
| 2 markup | `plans/2026-11-17-editor-2-planner-prompt.txt` | 1 | 200 | no |
| 3 the dialog shell | `plans/2026-11-17-editor-3-planner-prompt.txt` | 2 | 310 | no |

Round `guarded`:

| Pass | Planner prompt | Depends on | Path minutes | Waits for Geoff |
| --- | --- | --- | --- | --- |
| 1 CI | `plans/2026-11-17-guarded-1-planner-prompt.txt` | none | 120 | yes |
| 2 bindings and mail | `plans/2026-11-17-guarded-2-planner-prompt.txt` | 1 (order) | 240 | yes |
| 3 routes | `plans/2026-11-17-guarded-3-planner-prompt.txt` | 2 | 300 | yes |
| 4 the admin's calls | `plans/2026-11-17-guarded-4-planner-prompt.txt` | 3 | 190 | yes |

Round `gotool`:

| Pass | Planner prompt | Depends on | Path minutes | Waits for Geoff |
| --- | --- | --- | --- | --- |
| 1 the grid | `plans/2026-11-17-gotool-1-planner-prompt.txt` | none | 300 | no |
| 2 commands | `plans/2026-11-17-gotool-2-planner-prompt.txt` | 1 | 300 | no |
| 3 unused names | `plans/2026-11-17-gotool-3-planner-prompt.txt` | 2 | 390 | yes |

The pass tables give each pass's dependency on a pass of an earlier round. The round order
meets every one of them, so the tables here show only the dependencies inside a round.

The rounds run in the order `checks`, `surface`, `layers`, `errors`, `editor`, `guarded`. Each
launches when the one before it has closed. `gotool` runs beside them from the day its start
line holds. Within a round the passes run one at a time. Each later pass builds on the merged
result of the one before it, and in `guarded` each worktree is cut from the branch before it.

In `checks`, `surface`, `layers`, `errors`, and `editor`, a pass lands with
`approval-queue land` when its whole-branch review is accepted, and the next pass's worktree is
cut from `origin/main`. In `guarded`, each worktree is cut from the branch of the pass before
it, and you get one `merge` document when pass 4's review is accepted. In `gotool`, passes 1 and
2 land unattended, and pass 3's pull request comes to you in a `merge` document. The merge order
is the pass order.

Each round's conductor is named `conductor-<round>`, and each pass's sessions
`cairn-cms-<round>-<n>-plan` and `cairn-cms-<round>-<n>`.

| Round | Path minutes | Stops new launches past |
| --- | --- | --- |
| `checks` | 460 | 920 |
| `surface` | 860 | 1,720 |
| `layers` | 480 | 960 |
| `errors` | 560 | 1,120 |
| `editor` | 790 | 1,580 |
| `guarded` | 850 | 1,700 |
| `gotool` | 990 | 1,980 |

## Start line

These lines are written for my pick in question 3. A different pick changes line 1 of `checks`
and of `gotool`, as the question says.

`checks` launches when each of these reads true. Lines 1 and 3 aren't true today.

1. `gh pr view 258 --json state -q .state` prints `MERGED`. #258 is pass 3 of `foundation`.
2. `claude agents --json` holds no row whose name starts `cairn-cms-foundation-3`.
3. `approval-queue collect` prints "approve" for this design's document.
4. No open pull request of another round changes a file under `scripts/checks/**` or
   `package.json`, by `gh pr list` and `gh pr diff --name-only`.

`surface` launches when each of these reads true.

1. `docs/STATUS.md` on `origin/main` holds a line that reports round `checks` closed.
2. `claude agents --json` holds no row named `cairn-cms-checks-*` or `conductor-checks`.
3. `approval-queue collect 20261117-080523-be1fbe` prints an answer for the routing design. If
   the answer is "approve" with the pick "Join the foundation round as its seventh pass", the
   `foundation` block in STATUS also reports pass 7 landed.

`layers`, `errors`, `editor`, and `guarded` each launch when STATUS on `origin/main` reports the
round before it closed and `claude agents --json` holds no row of that round.

`gotool` launches when each of these reads true. None of the three is true today.

1. `gh pr view 258 --json state -q .state` prints `MERGED`.
2. `grep -c 'make -C tool check' docs/STATUS.md` on `origin/main` prints 0. The line that
   forbids that command while your 907.life setup is live is gone.
3. `approval-queue collect` prints "approve" for this design's document.

Against the other rounds in the repo: `foundation` is running and holds after pass 3. The
routing pass has a design in your queue and no answer. `site-events` and `site-basics` are
approved and wait for `foundation` to close. `pennant` is closed. No structure round waits for
round two, and round two waits for none of them.

Launch checks, read on 2026-11-17 at 12:05 AM Alaska time and read again at 12:11 AM with the same output:

| Check | Command | Output |
| --- | --- | --- |
| Main is current | `git fetch` and `git rev-parse origin/main` in the clone | `264c96b72`, one commit past the `604b4596d` the counts were run at. The commit changes only `docs/STATUS.md` |
| Usage | `claude -p "/usage" --model haiku` | `Current week (all models): 55% used · resets Nov 20, 10:59pm`. Fable: 31% |
| Live sessions | `claude agents --json` | `conductor-foundation` idle, and no `cairn-cms-foundation-*` row. No row of a structure round |
| Open pull requests | `gh pr list` | #258 `foundation-3`, open and no longer a draft. `gh pr view 258 --json state -q .state` prints `OPEN` |
| Launch flags | `claude --help` | Lists `--bg`, `--model`, `--effort`, and `--name`, and no `--advisor`, which is accepted all the same: the `foundation` planners launched with this line. Each conductor probes the flags the day it launches |
| `checks` line 1 | Read of `docs/STATUS.md` on `origin/main` | "Round foundation is holding after pass 3, and one call waits for Geoff". Pass 3 is ready as #258 and hasn't merged. Not met |
| `gotool` line 2 | `grep -c 'make -C tool check' docs/STATUS.md` | 1. Not met |
| Retired forms | `grep` for the removed names in `~/.dotfiles/claude`, each repo's `.claude/` and `skills/`, and the prompts under `~/Projects/initiatives` | 19 files in cairn-cms's `skills/` and `.claude/skills/`, each under a pass's Files. Two in aksailingclub-org's `cairn-admin-screens` skill. The first `site-events` planner prompt and the events design name `refine` |

Each conductor reads all of them again on the day it launches.

Two of those retired forms are outside this repo. The aksailingclub-org skill names
`ownerOnly`. That site is rebuilt from scratch, and its skill is rewritten with it. The
`site-events` prompt is approved, and I may not edit it. "What a later planner meets" says what
its planner finds.

## Steps for Geoff

- Done on 2026-11-17: you answered the twelve questions and approved this design.
- Done on 2026-11-17: you answered the routing design, document `20261117-080523-be1fbe`,
  which `surface` reads.
- [you: say when your 907.life setup is finished, so that the line forbidding
  `make -C tool check` leaves STATUS and `gotool` can start]
- [you: answer the `merge` document for `guarded`]
- [you: answer the `merge` document for `gotool-3`]

Nothing else needs you. No pass needs a secret, a sign-in, or a change on Cloudflare, orpheus,
or ward.

One hand-off is outside what I may do. `conductor.md` has the session that acts on your approve
launch the conductor from the main checkout, and `ready.md` has STATUS name the conductor prompt
as the next launch. I may not work in the main checkout, write there, or message a session. So I
launch nothing, and my last message names each conductor prompt and its start line. I assume the
`desk` session, which wrote my prompt, launches each conductor when its line holds. If you want
that done another way, say so in a note.

## Standing answers

The twelve in `round-run.md` hold for all seven rounds. This design adds:

13. A pass needs a change under a held path (`.github/**`, `scripts/release/**`,
    `.claude/settings*`, the sweep's name matcher, or `cleanroom`'s secret, environment, user,
    and stop code): it leaves the file alone and records the change it needs in the round's
    report. `guarded-1` is the one exception, and only if question 8 allows it.
14. The tree differs from what this design read: the planner plans against the files as merged,
    and parks only if an acceptance item can no longer be met.
15. A plan comes out over the ceiling you set in question 12, which is twice its design minutes
    under my pick: the pass parks, as `round.md` says.
16. A pass not classed `auth-data` needs a file on the guarded list: it leaves the file alone
    and records the need for `guarded-3`. It parks only if an acceptance item can't be met
    without the file.
17. A caller of a renamed or removed name turns up late: the pass updates it when the file is
    under its Files, and records it for the next pass that owns the file when it isn't.
18. A rename or a move would be easier with an alias or a re-export stub: never leave one. The
    one exception is the type-only re-export of `CairnRuntime` that `layers-1` lists and
    `guarded-3` deletes.
19. A published name this design doesn't list as removed looks unused: it stays, and the pass
    records it for Geoff. The routing pass's fourth routing value is one such name.
20. A proof that behavior is unchanged fails (a suite count drops, a visual baseline differs, an
    expected status changes, or a Go golden changes outside question 9): the line stops. The
    pass fixes forward or reverts, and never updates the baseline or the expectation.
21. A check's verdict changes after `checks-1` or `checks-2`: the fault is fixed in the script.
    The fixture and the expected verdict stay as they were.
22. The layer check's list of exceptions would have to grow, or the `site` folder can't hold the
    adapter and the runtime without a published path moving: the pass parks.
23. An error's sorting isn't clear from the rule: it stays a plain `Error` in the one message
    form, and the pass lists it in the report. No pass changes a status code or a refusal.
24. Another cairn-cms conductor is live: the structure conductor that started first writes
    `docs/STATUS.md`. It copies in, unchanged and in the same commit, any block another
    conductor sends it. A structure conductor that isn't the writer sends its block, and any
    block it receives, to the writer.
25. Before each launch, an open pull request of another round changes a file under the next
    pass's Files, or a live pass of another round has such a file open by the overlap table: the
    conductor holds with its clock stopped, and says so in the report.
26. A structure pass has just merged and another cairn-cms conductor is live: the conductor
    waits ten minutes before its next launch.
27. STATUS still forbids `make -C tool check`: a pass outside `gotool` that touches a Go file
    relies on CI for the Go suite and never runs that command.
28. The weekly allowance reaches the usage stop you set in question 11: the conductor waits for
    the reset with its clock stopped.
29. A start line can't be read, because pull request #258 has no state or the `foundation`
    block in STATUS doesn't say whether pass 7 has landed: the round doesn't start, and the
    `desk` session is told which line can't be read.

## Rulings

Geoff approved this design in queue document `20261117-091516-5c3656` on 2026-11-17, with no
note. Each `Ruled:` line quotes the option he picked there. The page asked questions 8, 9, and
10 in another order, so each line here is matched to its question by the option's words.

1. What decides who sees a sidebar link (#102, #130).
   Ruled: "The access map alone". `ownerOnly` and `roles` leave nav entries and sections, and
   `navFilter` goes. `hidden` stays.
2. The name of the tidy option in code (#161).
   Ruled: "tidyClient". `timeoutMs` is removed.
3. When the rounds start.
   Ruled: "In the foundation hold". `checks` starts once pull request #258 has merged, and
   each later round starts when the round before it closes.
4. How much runs.
   Ruled: "All 20 passes".
5. The four rounds longer than the 600-minute guide.
   Ruled: "Keep seven rounds".
6. The published names a site developer loses.
   Ruled: "Remove all four groups". `auth.send` is among them.
7. Whether site code can throw the engine's typed error.
   Ruled: "Keep it closed".
8. Whether a pass may edit the CI workflow files.
   Ruled: "Yes, in guarded 1". `guarded-1` runs, as the one exception standing answer 13
   names.
9. The Go tool's visible changes.
   Ruled: "Take the changes". They are the seven listed under "What each merge publishes",
   and no others.
10. Whether the misnamed log event is renamed (#323).
    Ruled: "Rename it now". `entry.prior_read_failed` becomes `entry.save_prior_read_failed`
    in `errors-2`.
11. The usage stop after the weekly reset on November 20.
    Ruled: "It returns at 85 percent". Until that reset the stop is off, by queue document
    `20261117-055811-900560`.
12. How far a plan or a round may overrun.
    Ruled: "Twice, as round.md says".

Geoff answered the routing design the same day, in queue document `20261117-080523-be1fbe`:
"Join the foundation round as its seventh pass". Line 3 of `surface`'s start line then needs
the `foundation` block in STATUS to report pass 7 landed.

Geoff ruled on the Go tool the same day, in queue document `20261117-173947-69f637`, a `decide` page the
`desk` session stored from his words in chat.
Ruled: "Retire the Go tool." Round `gotool` doesn't start, and none of its three passes runs.
The `cairn` command is rewritten in TypeScript inside the engine package, under a design that
comes to him separately, and the Go tool keeps working until that command replaces it. The
other six rounds stand as approved, which leaves 17 passes and 4,000 path minutes. Ruling 9
has nothing left to allow. Every other line this design gives `gotool` is left as he approved
it and no longer runs.

## Backlog verdicts

A scoped sweep read the open items at `604b4596d`, and #546 to #557 on `origin/foundation-3`. It
covered the items that name a file one of these passes changes. The verdicts: 23 fold, 48 keep,
3 reword, 1 reword and fold, and 1 already done. The backlog uses ids #491 to #502 and #512
twice. "First" and "second" below follow the order they appear in the file.

| Item | Verdict | Where |
| --- | --- | --- |
| #370 `close-prebuilt` runs a step without the environment | fold | `checks-1`, 15 minutes |
| #406 the symbol check misses setup-overlay paths | fold | `checks-1`, 15 |
| #429 the gate table has no plugins bucket | fold | `checks-1`, 20 |
| #485 `test:theme` is listed in one place of two | fold | `checks-1`, 15 |
| #540 `check-definitions` stops at the first problem | fold | `checks-1`, 15, for the check half. The emit half stays open |
| #323 the log event `entry.prior_read_failed` is misnamed | fold | `errors-2`, 30. The name is question 10 |
| #298 a failed create isn't announced | fold | `editor-3`, 25 |
| #474 two wrap implementations | fold | `gotool-1`, 30. The plan picks the greedy wrap, which every report already uses |
| #475 `style` and `render` repeat helpers | reword and fold | `gotool-1`, 45. The text is cut to the six points still open |
| #477 test comments cite plan criteria | fold | `gotool-1`, 30 |
| #503, #504, #508, #509, #511, the second #512, #524 | fold | `gotool-2`, 185 in all. #503 and #508 change help text, which is question 9 |
| The second #497, #516, #517, #518, #519, #520, #521 | fold | `gotool-3`, 145 in all |
| #64 hand-drawn admin icons | reword | The counts changed: `MediaFigureControl` has four and `MediaHeroField` six |
| #479 blocks render names unclamped | reword | Cut to `MarkRow` and `VerdictLine`. The `ErrorBlock` half is fixed |
| The first #494, `statusTable` indexed unchecked | reword | It names the wrong package. The table is `doctor/result.go` line 95 |
| #114 | done | Already under "Done" at `BACKLOG.md` line 1418 |
| #320 the sign-in rate limiter fails open | keep | The code records it as deliberate. A change is a security decision for you |
| #510, #513, #515 | keep | Each changes Go tool output. They stay out of a pass whose proof is unchanged output |
| #303, #311, #326 | keep | Each fixes what one check decides. `checks-2` changes the form of a check, never its verdict |
| #543 the shell's crumbs decode inside a derived value | keep | `surface-3` changes that component's props and leaves the crumbs |
| #546 to #557 | keep | They describe files that exist only on `foundation-3` |
| 37 more | keep | Product copy, theme and content work, and behavior changes outside every pass's lines. The sweep report lists each with its reason |

The stamps and the three rewords land in `checks-1`'s pull request. The four items in "Won't
do" aren't sweep items: `surface-1` moves them out with your words and the date.

The sweep report is `research/2026-11-17-structure-round/backlog-sweep.md`. It uses my earlier
working names for the passes: `gates-1` is `checks-1`, `gates-3` is `gotool-1`, `gates-4` is
`gotool-3`, and `gates-5` is `gotool-2`.

A full sweep is due. The round-two design counted 45 open items with no stamp from the last 90
days. It runs as a separate session and never rides this design.

## Estimate

Twenty passes and 4,990 path minutes in seven chains. `checks`: 260 and 200. `surface`: 200,
220, 220, and 220. `layers`: 280 and 200. `errors`: 300 and 260. `editor`: 280, 200, and 310.
`guarded`: 120, 240, 300, and 190. `gotool`: 300, 300, and 390.

Each figure is the pass's work minutes times 1.3, plus 40 for an `ordinary` or `runner` pass and
70 for an `auth-data` pass. The basis is thin: two scored passes of `foundation`, which planned
at 1.7 and 1.5 times their design minutes. A plan should come out near its figure here.

The six rounds that run in sequence hold 4,000 minutes, and `gotool` runs beside them. The
survey's items alone, which is the second option in question 4, come to 14 passes and 3,550
minutes. That option drops `surface-3`, `surface-4`, `errors-2`, `editor-3`, `guarded-2`, and
`guarded-4`.

The work is larger than one weekly allowance. By a rough figure of mine, 100 design minutes
cost about 2.5 points of the week, which puts the whole design near 125 points. Question 11
says what that means for the usage stop.

## What I couldn't check

- I read the agents' reports and ran every count in the acceptance list myself. I didn't check
  each line number a report cites.
- Neither `make -C tool check` nor the Go test suite ran. The Go figures rest on a read, a
  build, and `go vet`.
- How `gate-tier` puts its steps together. I read that it builds the package first every time,
  and no further. `checks-1`'s plan reads the rest before it moves the list.
- The exact list of check names across the four homes. A rough script of mine counts 48. The
  first task of `checks-1` commits the exact list.
- The count of 14 media-manifest reads under `sveltekit` comes from my server-library report,
  and I didn't rerun it. The first task of `errors-2` confirms it.
- Whether a site can set `MarkdownEditor`'s `spellcheckDictionary` prop. `surface-4`'s plan
  decides whether the prop goes with the runtime field.
- Whether the visual baselines match across machines. The proof runs in CI.
- Whether a resumed installer run prints a different summary in the agent lane after
  `gotool-2`. The Go report raises it and didn't settle it.
- The routing design's answer, and so whether the edit screen gains lines before `editor-1`.
  The line targets of 2,200 and 1,600 leave room for it.

## Practice and sources

- `pass-core`: `round.md`, `round-run.md`, `ready.md`, `planner.md`, `conductor.md`, and
  `advisor.md`.
- The desk's survey, `~/.local/state/desk/reviews/2026-11-17-cairn-architecture-survey.md`.
- The layering document you approved, `20261117-070713-d82261`, for the typed-error rule.
- The routing design, `specs/2026-11-17-routing-design.md`.
- The `foundation` design and its conductor prompt, and the round-two design.
- `docs/internal/engine-rulings.md` and the roadmap ruling of 2026-09-27 in cairn-cms.
- My reports on the code, under `research/2026-11-17-structure-round/`: the checks, the errors,
  the edit screen, the admin library, the server library, the Go tool, and the backlog sweep,
  with the scripts that produced the counts.
- One fresh Opus reader ran the builder check on this design before it reached you. It asked
  eight questions and named a set of acceptance items that could pass on a wrong result. The
  design answers each: the checks are tightened, the order is a strict list, and three prices
  rose.

## Out of scope and later

- Moving the audit and its command into the development package.
- The `BackendProvider` seam, until a second backend is designed.
- Splitting `CairnMediaLibrary`, `CairnAdminShell.svelte`, and `MarkdownEditor.svelte`.
- Opening `CairnError` to site code, if question 7 keeps it closed.
- The Go tool's output bugs: #479, the first #494, #510, #513, and #515.
- The full backlog sweep.
- The engine release that carries these changes.
