---
kind: design
approve: I record your picks in the design, write a planner prompt for each pass and one conductor prompt, and launch nothing until the start line holds.
sendback: I answer each note in its thread, change the design, and send it back to you.
---

# Approve the design for the structure round of `dubplate`?

This is the design for the structure work you allowed before `catalog`. It moves the server's code into the shape
the remaining rounds build on. Each part of the server holds its settings, its health checks, and its database
tables, and the command folder (`cmd/dubplate-server`) only connects the parts. **Nothing you can see changes.** No setting is renamed, no
line that `doctor` prints changes, and no command moves. A member (one person in the group that shares a library)
sees the same pages. Three passes do the work, and I put them at 1,090 minutes on the path. The round deletes 128
old files from the repo, all of which git history keeps. It deletes nothing on the `dubplate` server and deploys
nothing. **It does not start when you approve.** It waits for the `engine` pass to close, and I launch it then. You
have nothing to do in between unless `engine` sends you a question. Six questions are yours, and each has a
recommendation.

**1. Does this round run before `intake` or after it?** You ruled eight rounds in order and allowed this work
"before `catalog`". `intake` sits between `engine` and `catalog`, so either place fits your words. The two rounds
can't run together, because both rewrite the upload code and the server's command folder.

With this round first, `intake` starts about 1,090 planned minutes later. Its five passes then write their new
settings, checks, and upload code onto the final shape, and nothing they write moves again. With `intake` first,
the uploader reaches your sitting sooner. Its 2,280 minutes of new code go onto the old shape, and this round then
moves that code too. I put that second move at about 150 more minutes for this round. It also reopens code that
reviews have only just passed.

The `intake` design is in your queue and asks the same thing as its question 13. It recommends "whichever is
approved first". I recommend this round first, because you wrote "We're looking for the straightest line to
correct". The two designs recommend different answers, so please pick the same option on both pages. "This round
first" here is "Structure first" there, and the other two options carry the same names on both. That page's
"structure pass" is the three passes of this round. If the two pages get different answers, I start nothing and
send you the one question again.

:::question order with intake
- **This round first** It runs when `engine` closes, and `intake` starts from its merge. {recommended}
- **`intake` first** This round waits for the last `intake` pass to merge and grows by about 150 minutes.
- **Whichever is approved first** The other starts from its merge, as the `intake` design recommends.
:::

**2. Is this one round or two?** The rule holds a round to about 600 minutes, so that you read a design before
much is built on it. This work is 1,090 minutes in three passes, so one round goes past that figure. Each pass is
planned just before it runs, from the code the pass before it left. No pass changes what a person sees. Each proves
it the same way, by recording every line the server's commands print before the pass and comparing after. Split
in two, the second round is still 700 minutes.

:::question round size
- **One round of three passes** You approve once, and I send you one report when the third pass merges. {recommended}
- **Two rounds** This approval covers the first pass, 390 minutes. When it merges I send a second design for the other two, 700 minutes, with its questions asked again.
:::

**3. Do the passes merge on their checks and reviews, or do you read each first?** Every pass here touches the
command folder, which the repo classes with sign-in and data code. The standing rule sends each such pass to you as
a document before it merges. That is three documents, and each holds the pass behind it. Every pass gets a review
of each task, a review of the whole branch, a security read, and green checks. For `engine` you picked "Merge on
checks and review".

:::question merge rule
- **Merge on checks and review** The three passes merge without you and appear in the round's report. {recommended}
- **A document for every pass** Three reads, as the standing rule has it.
:::

**4. Where is the weekly usage stop for this round?** The standing answer stops new work at 85 percent. For
`engine` you picked 95 percent until the reset on November 20 at 10:59 PM, and 85 after. Usage read 41 percent on
2026-11-17, after your Fable reset. This round starts after `engine`, so part of it may run after the reset. At the stop,
a pass finishes the task in hand, pushes it, and waits.

:::question usage stop
- **95 percent until the reset, 85 after** The line you picked for `engine`. {recommended}
- **85 percent throughout** The standing line. In a heavy week the round stops sooner and waits for the reset.
:::

**5. How far past its plan may the round run before it stops and asks you?** For `engine` you set the ceiling at
twice the plan, 1,200 minutes for a 600-minute pass. Recent passes took between 0.4 and 1.6 times their figures.
At the ceiling the pass in hand finishes its task and starts no new one, and I send you the question. The
multiple you pick applies to whatever the round's figure becomes under questions 1, 2, and 6.

:::question overrun ceiling
- **Twice the plan** 2,180 minutes for the 1,090 planned, as for `engine`. {recommended}
- **One and a half times the plan** 1,635 minutes for the 1,090 planned.
:::

**6. Which round builds the check that holds the table rule?** The catalog architecture design is in your queue. It
sets a rule: each database table has one package that owns it, named in one list, and only the owner writes it.
That design leaves the test that enforces the list for the `catalog` round to build. I checked today's code against the rule.
Every table that is written at all is already written by one package, so the list can be made true now.

If this round builds the list and its test, the rule is checked from this round's first pass. `intake`
and `catalog` then add one line for each table they create. If `catalog` builds it, this round moves the code and
writes the rule down, and nothing checks the rule until `catalog` lands. The first pass then drops the list, its
test, and the one acceptance item marked for this question. That design and this one differ on this one item.

:::question table rule check
- **This round builds it** About 45 minutes here, already counted. `catalog` adds its tables to a list that exists. {recommended}
- **`catalog` builds it** As the catalog design lists. This round is 1,045 minutes.
:::

:::decide

Initiative: `dubplate-server`. Round: `structure`. Repo: `glw907/dubplate` (`dubplate`, default branch `master`).
Written 2026-11-17 against `master` at `e03e574`, with the approved `engine` design read on top. Status: approved
2026-11-17 (see "Rulings").

## Brief

The architecture survey of 2026-11-17 found three things that every remaining round would add to. The command
folder, `cmd/dubplate-server`, holds 5,595 lines of settings, wiring, and health checks for every part of the
server. No rule said which package owns a database table. The rule for what an id looks like was written out
several times. You answered "You can also do these", and this round does them in three passes.

1. `structure-base` deletes the `_salvage` folder, gives the store package its final name, and makes one home each
   for ids, time helpers, and the table rule.
2. `structure-keys` moves every setting to the package that reads it.
3. `structure-doctor` moves every health check to the package that knows the fact, and takes out the seams that
   exist only for tests.

## Why

You allowed this work on 2026-11-16 and said what you want from it: "now is the time to make sure all the code is
clean, streamlined, and with any over-engineering or duplication removed". You asked for "clean, well-designed
code" that stays easy to maintain over the long term. On 2026-11-17 you added, "We're looking for the straightest
line to correct."

Six rounds are still to come before 0.8 after `engine` and this one: `intake`, `catalog`, `playback`, `queue`,
`library`, and `launch`. Each adds settings, tables, and health
checks. Today each of those additions goes into the command folder, because that is where the examples are. After
this round each goes into the package it belongs to, and a written rule and a test say where.

## Decided by Geoff

- This work is allowed, and it runs before `catalog` ("You can also do these", 2026-11-16).
- "We're looking for the straightest line to correct." The design takes the whole move to the final shape, with no
  half step that a later round would redo.
- Nothing stored on the `dubplate` server has to be kept until first launch (document `20261117-073456-91db2f`).
  That ruling isn't used here. This round changes no table and no stored file.
- For `engine`: the overrun ceiling at twice the plan, the usage stop at 95 percent until the reset, and "Merge on
  checks and review". Questions 3, 4, and 5 ask whether the same holds here.

## Goals

- A reader finds a setting, a health check, or a table's code in the package that owns it.
- The command folder holds commands, flags, and wiring, and no rule of any part of the server.
- One function parses an id, and one type holds it.
- A written rule and a test say where the next setting, table, id, or health check goes.
- Every command prints what it prints today, byte for byte.

## Non-goals

- No change to what a setting is called, what it defaults to, or what `doctor` and `check` print.
- No change to any table or migration file. The six migration files move with their folder, unedited.
- No new package for `catalog`, and no move of the catalog tables' code. `catalog` creates its package.
- No work on the upload operations' path to the web, the web app's shared save logic, or the launch items. Those
  are survey items 3, 5, and 6, and they belong to `intake` and `launch`.
- Nothing in `web/`.

## Anti-goals

- A move that quietly changes a refusal sentence, a default, or the order of a list a person reads.
- A new layer that a reader has to learn and that does no work: a clock type, a doctor package, a shared row type,
  or a wiring package.
- A recorded fingerprint edited to match the new code.
- A second half of the move left for a later round.

## What I found

I checked each survey finding against the code at `e03e574`.

**Item 1 holds.** The command folder has 5,595 lines outside its tests. It declares 49 settings and other
configuration entries in eight registration functions. It also holds eleven functions that work out a `doctor`
row's status, with the network and file probes behind them.

**Item 2 holds in part.** No ownership rule was written down. The code already follows one for writes: every table
that is written has exactly one writing package. The gap is in reads. Four packages read `users`: the sign-in package,
which owns it, the store's inspector, the upload code, and backup. The last two reads belong behind the sign-in
package's functions.

**Item 4 holds, and it is larger than the survey says.** The id rule exists five times, with three Go types. The
five agree on the shape, 32 lowercase hex characters, and each refuses with a different sentence. Three of those
sentences reach a caller of the API, and the other two stay inside the server. Three parsers accept an
id of all zeros and two refuse it. A sixth place, in the upload code, decodes an id with no check at all.

**Item 7 holds, with two corrections.** `_salvage` has 128 tracked files. The tag `pre-greenfield` holds 120 of
them unchanged at their old paths. The other eight were edited after the files moved, so the tag alone doesn't
preserve them. Git history does: every commit before the deletion holds all 128.

The second correction is about the two seams the survey says exist only for tests. One is a backup hook in the
job runner. Only a test sets it, and it goes. The other is the small interface that every route passes through
when the server is assembled. I keep that one. A test records each route through it and fails when a route is
added around the list, and Go's router offers no way to list its routes. Production code uses the type too. The
survey doesn't name seven package variables that tests overwrite. Five of them sit in the command folder and
become plain fields as their code moves. Two sit in the store, where each stands in for a system call that no
test can reach any other way, so they stay.

## The end shape

This is the package list when the round ends. A package that isn't named is unchanged.

| Package | What it holds |
| --- | --- |
| `cmd/dubplate-server` | The commands and their flags, nine registration lines, the order of `doctor`'s rows, and the assembly of `serve`. No setting, no health check, no SQL. |
| `internal/config` | The registry, and the four entries that belong to no single part: the library root, the state folder, the site name, and the admin address. |
| `internal/settings` | Settings an admin changes while the server runs, and its three tables. It also reads such a setting from a store that isn't open yet. |
| `internal/store` | The database file, the migration files, transactions, snapshots, the inspector, and the small time and query helpers. Its two timeouts and the count of local snapshots to keep. It owns the migration ledger and no other table. |
| `internal/id` | The id type, the function that makes one, and the one function that parses one. |
| `internal/identity` | Who a request acts for. Its member id is built on `internal/id`. |
| `internal/auth` | Sign-in and sessions. The `users` and `member_preferences` tables. Its ten settings, the required setting that names the identity source, the one source it declares, its two rules, and its health checks. |
| `internal/backup` | Backups and restore reports. Its three settings, the backup entry, its health checks, and the probe of the remote copy. |
| `internal/serve` | The HTTP shell. Its three settings, the trusted-proxy entry, and the health checks for addresses and the boundary probe. |
| `internal/webapp` | The built web app. Its four settings and the `web` health check. |
| `internal/ops/admin` | Member and settings operations. The setting for how recent a sign-in must be, and its rule. |
| `internal/ops/local` | Background jobs. The `jobs` table and the job retention setting. |
| `internal/intake` | Uploads. The four submission tables, with `collections` until `catalog` takes it. Its fifteen settings, the format list, the staging folder entry, and the music volume health check. |
| `internal/engine/...` | Matching and tag reading only. The store has left. The transliteration table's install logic joins the table's package. |

A later round follows five rules. They go into the repo's `CLAUDE.md` in place of the rule that sends settings to
the command folder.

1. **A setting** is declared in the file `config.go` of the package that reads it, and added to that package's
   `Register` function. The command folder gains a line only when a new package registers for the first time.
2. **A table** gets a migration file in the store and a line in the ownership list. Only the owner writes it.
   Another package calls the owner's function, and passes its transaction when the two changes must commit
   together.
3. **An id** is the type in `internal/id`, or a named type built on it. Only `id.Parse` reads one from text.
4. **A health check** lives in the package that knows the fact, in its `doctor.go`. The `doctor` command gains one
   line that places the row.
5. **The time** reaches a package as a `Now` function in its configuration. No package under `internal` reads the
   clock, apart from the test harness. A timeout is a deadline on the request's context.

## Calls made here

These are method and architecture calls, which are mine. You can skip this section.

### Settings live in the package itself

Each package gets one file, `config.go`, with its declarations, its `Register` function, and the function that
reads its settings into the plain values its constructors already take. I tried the imports this needs in a
scratch copy, and the tree builds with no import cycle. Two notes in the code say that `auth` and `serve` stay
free of the configuration package. Those notes change, and one small test replaces them. In `auth`, `backup`,
`serve`, the store, `webapp`, `intake`, and `ops/local`, only `config.go` and `doctor.go` may import the
configuration or settings packages. The rest of each package still takes plain values, which is what the notes
protected. `ops/admin` is left out of the test. It serves the settings operations, and three of its files import
both packages today for that reason.

I turned down two other shapes. A sibling package for each part (`authconfig` beside `auth`) doubles the package
count for no reader's gain. One shared wiring package is the command folder again under a new name.

### Nine registration lines

`doctor` and the admin settings list print in the order the packages register. Eight packages can't register in
eight lines and keep that order. `doctor` prints `serve`'s port before the store's timeouts, the store's snapshot
count before backup's settings, and the backup entry before the trusted-proxy entry. Those three facts ask for
`serve` before the store, the store before `backup`, and `backup` before `serve`. One line for `serve` can't sit
at both ends.

`serve` therefore registers twice: its three settings early, and its trusted-proxy entry after `backup`. The
order in `main.go` is `auth`, `ops/local`, `serve`, the store, `webapp`, `backup`, `serve`'s trusted-proxy entry,
`ops/admin`, `intake`. I tried that order in a scratch copy, and the registry prints exactly as it does today. One
line for `serve` would be simpler, and it would move the trusted-proxy row above the backup row in `doctor`. That
is a visible change, so it is listed under "Later" for you.

### The snapshot count is read from the settings package

The count of local snapshots to keep is the store's setting, and an admin can change it. `serve` needs its value
before the store is open. The four small functions that work that out sit in the command folder today. They can't
move into the store, because the settings package already imports the store and Go allows no circle. They move to
`internal/settings`, beside the function they call. The declaration itself sits in the store with its two
timeouts.

### No doctor package

A health check is a function that returns the sentence `doctor` prints. Each one moves to the package that knows
the fact, keeps its sentence, and is called from the `doctor` command, which keeps the row names and their order.
I add no row type and no registry of checks. The command already holds the order in one readable list, and a
registry would hide it.

### One id type

`internal/id` holds `ID`, sixteen bytes, with `New`, `Parse`, `String`, and `IsZero`. It stores and loads itself
from the database, so callers stop converting by hand. The member id in `internal/identity` becomes a named type
built on it. The job handle stays the text form on the wire, since it is part of the operations' interface.

`Parse` holds the shape rule once and says nothing about zeros. Each caller keeps its sentence, and the two
callers that refuse an id of all zeros ask `IsZero` themselves. Every answer on the wire stays the same. The
pass's first commit adds tests that pin those answers through the public operations, before any parser moves.
Making the five agree on zeros would change an answer of the API, so it goes to the backlog for a pass that may
change behavior.

### No clock type

Three places under `internal` read the clock directly: two in `backup` and one in `ops/local`. `auth`, `intake`,
and `ops/admin` already take a `Now` function in their configuration. The three follow that pattern. The test that
keeps the engine from reading the clock widens to all of `internal` except the test harness. A clock interface
would be a type with one implementation.

One more read arrives in the third pass. The boundary probe sets its network deadline from the clock, and it
moves from the command folder to `internal/serve`. There it takes the deadline from its context, which is Go's
usual form for a timeout and needs no clock.

### The inspector is the list's one exception

The store's inspector reads a database file at any schema version, before any other package can open it, for
`doctor` and for restore. It reads `users`, `jobs`, `settings`, and `collections` with plain queries. It sits below
every owner and can't call them. The ownership list names it as the one reader outside the rule.

Two other reads move. Upload code looks up the earliest admin, and backup counts live members. Both become
functions in `auth` that take the caller's transaction. Backup's join of `tracks` and `collections` stays until
`catalog`, as the catalog design says, because the owner it would call doesn't exist yet.

### The migration history stays as it is

Your ruling lets a design start the server's database from one clean file. I leave the six migration files
unedited and the fold to `launch`. `intake` and `catalog` both add tables first. Folding now would mean folding
twice, or leaving a second run of development files behind the fold.

### Three passes

One pass can't hold 1,090 minutes of work, and the three parts review differently. The first is renames and
deletions. Its reviewer checks that nothing changed. The second and third move logic between packages, and their
reviewers read each move. Each pass rewrites command-folder files the one before it touched, so they run in a
chain.

### What the builder check changed

A fresh session with no background read this design before you, as the builder who would plan from it. It raised
nothing that is yours. I checked
each of its findings against the code and made these calls from them.

- `main.go` has nine registration lines, since eight can't keep `doctor`'s order.
- The snapshot count is read from the settings package.
- `id.Parse` checks the shape only, and each caller keeps its answer for an id of all zeros.
- The boundary probe's timeout becomes a context deadline.
- The import test leaves out `ops/admin`.
- The store keeps the engine's two layering rules when it leaves the engine's folder.
- Every acceptance item now gives today's count, and the fingerprint covers refusals and a real store.

## Scope

Three passes, in order. Every pass is class `auth-data`, so each task writes its failing test first and gets its
own review.

| Pass | Outcome | Files | Path minutes | Depends on |
| --- | --- | --- | --- | --- |
| `structure-base` | `_salvage` is gone. The store is `internal/store`. One id type, one home for the time helpers, and the table list with its test. | `_salvage/**`, `.gitignore`, `CLAUDE.md`, `BACKLOG.md`, `scripts/{check,vale-comments,deploy}.sh`, `.claude/skills/dubplate-pass/SKILL.md`, `internal/engine/store/**` to `internal/store/**`, the import line of the 86 Go files that name the store, `internal/id/**` (new), `internal/identity/identity.go`, `internal/ops/ops.go`, `internal/ops/admin/admin.go`, `internal/ops/local/jobs.go`, `internal/intake/{submission,seam,collection,tus}.go`, `internal/backup/{backup,reconcile}.go`, `internal/auth/roster.go`, `internal/webapp/layering_test.go`, `internal/harness/conform/arch_test.go` and its fixtures | 390 | `engine` closed |
| `structure-keys` | Every setting is declared in the package that reads it. | `cmd/dubplate-server/{main,serve,auth,store,web,backup,proxy,api,intake,doctor,settings,check}.go`, a new `config.go` in `internal/{auth,backup,serve,store,webapp,intake}` and `internal/ops/{admin,local}`, `internal/settings/**`, `internal/auth/doc.go`, `internal/serve/serve.go`, `internal/webapp/layering_test.go`, `internal/config/{registry,keys}.go`, `CLAUDE.md` | 360 | 1 |
| `structure-doctor` | Every health check sits with its fact. The test-only backup hook and package variables are gone. | `cmd/dubplate-server/{doctor,doctorprobe,unidecode,backup,serve,store,auth,web,proxy,member,intake}.go`, a new `doctor.go` in the packages above, `internal/engine/matcher/unidecode/**`, `internal/serve/**`, `internal/ops/local/local.go`, `internal/config/config.go` | 340 | 2 |

A listed file brings its tests and the fixtures under its `testdata`. The first pass also touches three scripts
and one skill file, which are class `runner`. The pass takes the higher class.

## What this round deletes

- **In the repo:** the `_salvage` folder, 128 files and 32,622 lines. It is the code from before the September
  rewrite, kept for reading. Nothing in the Go code, the web app, or the styles cites it. `CLAUDE.md` will name the
  commit that last held it, so a later pass can read any file with one `git show`. The `intake` design reads old
  uploader components from there, and it already plans to read them from git history.
- **In the repo:** functions and variables that only tests reach, listed under `structure-doctor`.
- **On the `dubplate` server:** nothing. The round deploys nothing and connects to nothing. The store's new package
  name changes no file on disk. The migration files are byte-identical after the move, and the ledger that checks
  them reads each file's name and contents, which don't change.

## How it fails

| What goes wrong | What the pass does |
| --- | --- |
| A fingerprint differs between the pass's base and its head | The line stops. The pass fixes the code until the two match. It never edits the recorded value. |
| A move can't keep a sentence or an order that a person reads | The pass parks and I send you a `decide` document. Nothing visible changes without you. |
| A move needs an import the tree can't take | The smaller shared piece moves down to a package both sides import, and the pull request lists it. If that needs a package this design doesn't name, the pass parks. |
| A test passes only through a seam the pass removes | The test is rewritten to enter through the public function. It is never deleted to get a green run. |
| `engine` left a tree that differs from its design | The planner plans against the tree it finds and notes each difference. |
| A reviewer asks for a change in behavior | It is filed in the backlog and not done here. |

Every limit is a count that must not move: 0 changed bytes in each fingerprint, 0 changed lines under `web/`, and 6
migration files with 6 unchanged hashes.

## The passes

Every pass waits for `engine` to close, because the round does. Two moves also touch files the `engine` pass
rewrites, and their planners read those files as `engine` left them.

### `structure-base`

The pass deletes `_salvage` and the lines that exist only for it: the ignore rules, the filters in
`scripts/check.sh` and `scripts/vale-comments.sh`, and two sentences of `CLAUDE.md`, which are reworded to name
the commit. One pattern in `scripts/check.sh` stays. It refuses a code comment that cites a `_salvage` file by
line, and that refusal is still right when the folder is gone.

It renames `internal/engine/store` to `internal/store`. 89 tracked files outside `docs` name the old path: 86 Go
files, the pass skill's class map, the backlog, and one comment in the deploy script. All 89 change. The files
under `docs` that name it are plans, specs, and research records, and they stay as written. The migration files
move as whole files.

Two tests hold rules for everything under `internal/engine`, and the store would slip out from under both when
it moves. The web app's layering test refuses any import of the engine, so it gains `internal/store`. The rule
that nothing in the engine imports the test harness widens to all of `internal`. No package breaks either rule
today.

The pass's first commit adds tests that pin every id answer through the public operations: the three refusal
sentences a caller can see, what each of the five parsers answers for an id of all zeros, and what the upload
code answers for a malformed one. It then creates `internal/id` and moves the six places onto it. The pinning
tests don't change again.

It moves the two copies of the microseconds-to-time helper, the row-collecting helper, and the rows-affected
helper into the store, which every caller already imports. It gives `backup` and `ops/local` a `Now` function and
widens the clock test. That test lives in `internal/harness/conform/arch_test.go`, which `engine` leaves in one
file. Today the test reads the engine's test files too. The engine and the store keep that strict form. The wider
form skips test files, because 17 test files elsewhere under `internal` read the clock to build their fixtures.
It refuses `time.Now`, `time.Since`, and `time.Until` alike.

Under question 6 it writes the ownership list as a table in a test file in the store, beside the schema it
describes. The list names all 19 tables. Twelve have a writer today: `auth` owns two, `intake` five, `ops/local`
one, `settings` three, and the store its ledger. `intake` holds `collections` until `catalog` creates its package.
Seven tables have no writer yet, and the list marks each with the round that takes it.

It moves the two foreign reads of `users` behind functions in `auth`.

### `structure-keys`

Each of eight packages gets a `config.go`. The pass moves the 49 declarations out of the command folder with their
validators and the functions that read them. `main.go` keeps nine lines, in the order given under "Nine
registration lines". A dump of the whole registry proves the order, under "Proof that nothing changed".

The four functions that read the snapshot count before the store opens move to `internal/settings`. Job retention
leaves the store's registration function for `ops/local`, which runs the jobs it governs.

The pass rewrites the two notes that say `auth` and `serve` stay free of configuration, loosens the `webapp`
layering test to allow the configuration package, and adds the import test described under "Calls made here". It
removes three leftovers in the same files: a one-line function that only forwards to another, a registry method
no production code calls, and a value list only a test reads.

### `structure-doctor`

Eleven status functions and their probes move out of the command folder, each to a `doctor.go` in the package
that knows the fact. The boundary probe's client goes to `serve` and takes its deadline from its context. The
remote-copy probe goes to `backup`. The `doctor` command keeps the row names, the order, and the printing.

The transliteration table's install logic moves from the command folder into
`internal/engine/matcher/unidecode`, beside the functions that fetch, build, and parse the table. That package
already makes network and file calls, so the move breaks no rule of the engine. The `engine` design keeps every
function there under its name, and this pass adds to them. The command keeps its name, its flag, and its output.

The pass removes the backup hook in the job runner, and the test that used it enters through the runner's
public constructor. The five package variables in the command folder become fields of the code that reads them.
Three of the five move out of the folder with the probes and the install logic.

`doctor` parses the admin address with a copy of the code the configuration package already has. The moved row
calls the one parser. Both parse the address and lowercase it the same way. Three comments that cite a review
note or a plan step lose the citation as their code moves.

A fresh architecture reader then grades `cmd/dubplate-server` and `internal/id`, as the `engine` design does for
its packages. The bar is "sound with nits" or better.

## Proof that nothing changed

Every pass carries the same proof, taken on a binary built at the pass's base commit and again at its head. The
kit is two small files that sit in the initiative's plans folder and never enter the repo.

**What a person sees.** A script runs the server's commands in a temp folder and hashes every line they print,
with each exit code. It masks the four things that differ between two runs: the temp folder's path, the log
timestamp, the local user's name, and the free-space figure. I ran it twice on `e03e574` and the two runs matched.

| Section | What it runs | Lines today | Hash today |
| --- | --- | --- | --- |
| Empty environment | `doctor` and `check` with no setting present | 78 | `5233cf78` |
| Complete environment, no store | `check`, `doctor`, and `member list` with every required setting valid | 77 | `d9823621` |
| A retired setting name | `check` and `doctor` with a name the server renamed | 74 | `29cec9c8` |
| Refused values | `check` and `doctor` 25 times over, each with one setting given a value the server refuses | 1,867 | `e06b84f9` |
| A store with one admin | `serve` creates the store. Then members are added, listed, refused, and removed, and `check`, `doctor`, `settings reset`, `backup`, and `version` run against it. | 183 | `968d7042` |
| Help text | `--help` for the root and all 16 commands | 225 | `c09227a8` |
| Everything | The six sections together, each under a title line | 2,510 | `7b996b43` |

The refused-values section reaches every package that declares a setting. Among its lines today are "80 is below
1024", "`DUBPLATE_BACKUP_REMOTE`: required setting unset", "invalid email address", `below the floor 24h`, and the
rule that a session's lifetime stays within its cap. The store section includes "the roster must name at least
one admin" and "duplicate address".

**Every declaration.** A throwaway test prints each entry in the registry in registration order, with every
field, and hashes the result. It prints 56 lines today. They are the 49 entries that move, and the four settings
and three reserved entries that stay in `internal/config`. The retired names never leave `internal/config`, and
the fingerprint's third section covers them.

**The web app.** `git diff --stat` over `web/` prints nothing.

**The schema.** Each of the six migration files keeps its name and its hash.

**The tests.** The sorted list of test names is compared at base and head. A name that is gone at head is listed
in the pull request with the reason.

I ran the kit on `e03e574` and recorded the values under "Acceptance".

## Acceptance

Each item names its check. The last column is what the check printed on 2026-11-17 at `e03e574`, and what it must
print to pass.

### Every pass

| Item | Check | Today, and to pass |
| --- | --- | --- |
| What a person sees is unchanged | `structure-proof.sh` on the base and head binaries | Today 2,510 lines in six sections, `7b996b43`. The two runs print the same seven lines. |
| Every declaration is unchanged | The registry dump test at base and head | Today 56 lines, `b8a59fba`. The same at head. |
| The web app is untouched | `git diff --stat <base>..HEAD -- web/` | Prints nothing. |
| The migration files are unchanged | `(cd <store>/migrations && sha256sum -- *.sql) \| sha256sum` | Six names with their hashes, `ffc4e9db`, at the old path today and the new path after. |
| No test was dropped | `grep -rhoE '^func (Test\|Fuzz\|Benchmark\|Example)[A-Za-z0-9_]*' --include=*_test.go cmd internal \| sort` at base and head, then `comm -23` | 1,921 names today, `4918d4c4`. Each name gone at head is in the pull request with the seam it tested. |
| The merge gate passes | `bash scripts/gate.sh --merge` | Exits 0. |

### `structure-base`

| Item | Check | Today, and to pass |
| --- | --- | --- |
| `_salvage` is out of the tree | `git ls-files _salvage \| wc -l` | 128 today. 0 to pass. |
| `CLAUDE.md` names where it went | `git ls-tree -r --name-only <named commit> _salvage \| wc -l` | Prints 128. The named commit is the parent of the one that deletes the folder. |
| No tracked file outside `docs` names the old store path | `git grep -l 'engine/store' -- . ':(exclude)docs' ':(exclude)_salvage' \| wc -l` | 89 today. 0 to pass, and the folder `internal/engine/store` doesn't exist. |
| The layering test covers the store | A trial edit shown in the pull request: a `webapp` file imports `internal/store` | `TestLayering` fails and names the import. |
| The harness rule covers all of `internal` | The test's fixture, moved outside the engine's folder | The test fails on the fixture and passes on the tree. |
| One function parses an id | `grep -rlE 'hex\.Decode(String)?\(' --include=*.go internal cmd`, leaving out tests and three packages that decode hex for other uses | Six files today. Only `internal/id/id.go` to pass. |
| Every id answer is unchanged | `git diff <first commit>..HEAD` over the pinning tests' files | Prints nothing. The tests pass at the first commit and at head. |
| The time helper exists once | `grep -rnE '^func micros\(' --include=*.go internal cmd` | 2 lines today. 1 to pass, in the store. |
| Nothing under `internal` reads the clock | `grep -rnE 'time\.(Now\|Since\|Until)\b' --include=*.go internal`, leaving out tests, the harness, and comment lines | 3 lines today. 0 to pass. Two trial edits are shown in the pull request, a `time.Now` in `backup` and a `time.Since` in `ops/local`, and the widened test fails on each. |
| `users` is read by its owner and the inspector | `grep -rlzE '(FROM\|JOIN)[[:space:]]+users\b' --include=*.go internal cmd`, leaving out tests | Four files today. Only files under `internal/auth`, and `internal/store/inspect.go`, to pass. |
| The table test can fail (under question 6) | Five trial edits, shown in the pull request: an `INSERT INTO users` in `intake`, an `UPDATE users` in `backup`, a `DELETE FROM jobs` in `intake`, a write whose table name comes from a constant, and one line removed from the list | The test fails on each and names the file or the table. |

### `structure-keys`

| Item | Check | Today, and to pass |
| --- | --- | --- |
| The command folder declares nothing | `grep -rnE 'config\.(Setting\|Threshold\|IntegrationClass\|WallRow\|CorrelatedRule\|IdentitySource\|ReservedClass)\{' --include=*.go cmd`, leaving out tests | 52 lines today, which are the 49 declarations, two list openers, and one empty return. 0 to pass. |
| The command folder registers nothing itself | `grep -rnE '\.Add(WallRow\|ReservedClass\|IntegrationClass\|Threshold\|IdentitySource\|Setting\|CorrelatedRule\|Superseded)\(' --include=*.go cmd`, leaving out tests | 29 lines today. 0 to pass. |
| `main.go` has the nine lines | `grep -cE '\.Register[A-Za-z]*\(reg\)' cmd/dubplate-server/main.go`, and the same count for the old form, `register[A-Z][A-Za-z]*Config\(reg\)` | 0 and 8 today. 9 and 0 to pass. |
| The order prints as today | The registry dump test, as for every pass | 56 lines, `b8a59fba`. |
| Configuration stays in two files of each package | The new import test, with two trial edits shown in the pull request | The test fails when a third file of `auth` imports the configuration package, and when a third file of `intake` imports the settings package. |
| The three leftovers are gone | `grep -rnE 'lookupEnviron\|identitySourceValues\|\) Superseded\(\)' --include=*.go cmd internal`, leaving out tests, and `go doc ./internal/config Registry \| grep -c '^func (r \*Registry)'` | 19 lines and 16 methods today. 0 lines and 15 methods to pass. |

### `structure-doctor`

| Item | Check | Today, and to pass |
| --- | --- | --- |
| The command folder works out no status | `grep -rnE '\(status string, failed bool\)' --include=*.go cmd`, leaving out tests | 11 lines today. 0 to pass. |
| The command folder is wiring | Lines in `cmd/dubplate-server/*.go` outside tests | 5,595 today. Under 3,000 to pass. I expect about 2,300. |
| The install logic has left the command folder | `grep -rnE '^func (\([^)]*\) )?[A-Za-z]*nidecode[A-Za-z]*\(' --include=*.go cmd`, leaving out tests | 13 functions today. 3 or fewer to pass. |
| The backup hook is gone | `grep -rn bindBackup --include=*.go internal cmd`, leaving out tests, and `grep -rnE '\br\.[a-zA-Z]+ = func' internal/ops/local/*_test.go` | 4 lines and 1 line today. 0 and 0 to pass. |
| No command-folder variable exists for tests to overwrite | Each package variable that `go doc -cmd -u -all ./cmd/dubplate-server` lists, searched for an assignment in the folder's test files | Five names today: `featuresProbeTimeout`, `geteuid`, `operatorVerbWriteWait`, `osUserLookupID`, `unidecodeClient`. None to pass. The same search in the store prints `geteuid` and `statfsFunc`, which stay. |
| The admin address is parsed in one place | `grep -rn 'mail\.ParseAddress' --include=*.go cmd internal`, leaving out tests | 4 lines today, 2 of them in the command folder. 3 to pass, none in the command folder. The second pass moves one of the two to `auth` with its setting, and this pass removes the other. |
| The moved probe reads no clock | The widened clock test from the first pass | Passes with the probe in `internal/serve`. |
| The packages read well | A fresh `standards:go-architecture-reader` on `cmd/dubplate-server` and on `internal/id` | "Sound with nits" or better. A finding in lines `intake` rewrites is filed for it. |

## Shared assumptions

| Assumption | Probe or source |
| --- | --- |
| `engine` keeps every function of the transliteration package under its name | Approved `engine` design: each "keeps its name, signature, and behavior" |
| `engine` leaves `conform/arch_test.go` in one file | Approved `engine` design, which lists its split under "Later" |
| The new imports make no cycle | I added the configuration, settings, and sign-in imports to each package in a scratch copy at `e03e574`. `go build ./...` passed. The store is the one package that can't import the settings package, and its `config.go` doesn't need to. |
| The nine-line order prints as today | In a scratch copy at `e03e574` I split job retention out of the store's function, put the calls in the nine-line order, and ran the dump test. It printed 56 lines, `b8a59fba`, the same as the unedited tree. |
| A short run of `serve` creates a store the kit can use | Run on the `e03e574` binary, which has no web build. `serve` stops at the web check, after it has created and migrated the store. `check` then prints "store: current (v6)". |
| Every written table has one writer | A search for `INSERT`, `UPDATE`, `DELETE`, and `REPLACE` statements for each of the 19 tables at `e03e574`. It found a writer for eleven tables, each in one package. The twelfth is the migration ledger, which only the store writes. |
| A moved migration file keeps its ledger entry | The ledger checks each file's name and SHA-256. The files are embedded by a pattern relative to the package. |
| No code cites `_salvage` | A search of `cmd`, `internal`, and `web/src` for the name prints nothing |
| The launch line's flags exist | `claude --help` on 2026-11-17 shows `--bg`, `--effort`, `--model`, `--name`. `--advisor` isn't listed and is accepted, as the `cleanup` conductor found. |

## Left for other rounds

| What | Where it goes | Why it waits |
| --- | --- | --- |
| Survey item 3, upload operations' path to the web | `intake`, first pass | That pass rewrites the same files. |
| Survey item 5, the web app's shared save logic | `intake`, third pass | It is browser work, and this round touches no browser file. |
| Survey item 6, and one clean migration file | `launch` | The fold happens once, after the last table is added. |
| The doubled request check in sign-in | `intake`, third pass | Its design already takes it. |
| Catalog tables' code, and backup's read of them | `catalog` | The owning package doesn't exist yet. |
| One answer for an id of all zeros | Backlog | Three parsers accept it and two refuse it. Making them agree changes an answer of the API. |
| One registration line for `serve` | Backlog, yours to rule | It moves the trusted-proxy row above the backup row in `doctor`. |
| The words "arrives at rung" in three `doctor` rows | Backlog, yours to word | It changes what `doctor` prints. |
| Four near-copies of a file-ownership check | Backlog | Merging them changes refusal sentences. |
| Whether the pass skill's class map should list `internal/ops` | Yours, by a note on this page | Only you raise a class. The first pass edits that sentence of the map, so a note from you adds the path there. |
| The store's two package variables that tests overwrite | Stay | Each stands in for a system call. |
| An unused bypass in the origin check | `playback` | The streamer's sign-in uses it. |

## Start line

Nothing launches until every state below holds.

1. Your approve is recorded: this design's "Rulings" section carries a `Ruled:` line with the queue id.
2. `engine` has closed. `docs/STATUS.md` on `origin/master` no longer names `engine` as the next action, and
   `claude agents --json` lists no planner or executor for it.
3. No pull request is open in `dubplate`.
4. The main checkout is on `master` and level with `origin/master`, and `claude-worktree-busy` on it exits 0.
5. No pass is running in `dubplate`. `claude agents --json` lists no conductor for it, and no planner or executor
   of an `engine` or `intake` pass. A design session doesn't count, whether it is drafting or waiting on you.
6. Weekly usage is under the line you pick in question 4.
7. If `intake` goes first under question 1, its last pull request is merged and its report is in your queue. It
   goes first when you pick "`intake` first", or when you pick "Whichever is approved first" and its design was
   approved before this one.
8. Your answers to question 1 here and question 13 of the `intake` design agree.

| Check | Command | Output on 2026-11-17 |
| --- | --- | --- |
| Status | `docs/STATUS.md` at `origin/master` | "Next action: Design round `engine`". State 2 doesn't hold. |
| Pull requests | `gh pr list --repo glw907/dubplate --state open` | None open. |
| Sessions | `claude agents --json` | Four `dubplate` design sessions, this one among them. No conductor and no pass session. |
| Usage | `claude -p "/usage" --model haiku` | `Current week (all models): 41% used · resets Nov 20, 10:59pm` |
| Queue | `approval-queue list` | The catalog architecture design and the `intake` design wait for you. |

I didn't run `claude-worktree-busy`. A design session keeps the main checkout's path off its command line while
`engine` runs there, so the conductor runs that check at launch.

State 2 doesn't hold today. Until the line holds I write the prompts in the initiative's folder and nothing in
`dubplate`. When `engine` closes I check each state, and the conductor's first act is to check them again.

## Steps for Geoff

- `[you: answer the six questions above]`

No pass needs a secret, a sign-in, or a dialog from you.

## Standing answers

The twelve in `round-run.md` hold. These add to them.

13. A fingerprint differs between a pass's base and its head. The pass fixes the code until they match and never
    edits the recorded value.
14. A move can't keep something a person reads. The pass parks and I send a `decide` document.
15. A plan's path is over twice its pass's figure. The pass parks and I send a `decide` document.
16. The round passes the ceiling of question 5. The pass in hand finishes its task, starts no new one, and I send
    a `decide` document. This replaces answer 7 of the twelve.
17. Usage passes the line of question 4. The pass finishes its task, pushes, and waits. This replaces the 85
    percent of answer 4 until the reset.
18. A task needs a file outside its pass's list. A call site forced by a changed signature or import path is
    taken and listed under `## Decisions`. Anything else is filed and left.
19. `engine` left a tree that differs from its design. The planner plans against what it finds and notes it.
20. `intake` merged first and its new code sits on the old shape. The planner moves that code by the same five
    rules and says what it added to the figure.
21. A reviewer asks for a change in behavior. It is filed and not done.
22. A security read finds a blocker. The pass fixes it and the read runs again. A second blocker parks the pass.
23. CI is red for a cause outside the pass. The executor fixes the workflow in its branch and lists the fix.
24. Your approval carries no pick for a question. The recommended option is used.
25. Question 1 here and question 13 of the `intake` design have different answers. I launch nothing and send a
    `decide` document with the one question.

## Rulings

Ruled: approved by Geoff on 2026-11-17 through the Approval Queue, document `20261117-083604-d6b622`, with no
notes. His picks:

1. Order with `intake`: "This round first".
2. Round size: "One round of three passes".
3. Merge rule: "Merge on checks and review".
4. Usage stop: "95 percent until the reset, 85 after". The reset is November 20 at 10:59 PM.
5. Overrun ceiling: "Twice the plan", which is 2,180 minutes.
6. Table rule check: "This round builds it".

He left no note about the class map. The map doesn't gain `internal/ops`, and backlog item #157 stays open.

The order agrees with the `intake` design. Geoff approved that design 69 seconds after this one, as document
`20261117-075541-3e7116`, and picked "Whichever is approved first" for its question 13. This design was approved
first, so that answer also puts this round first. The `intake` design's start line reads its recommended answer
the same way. Start-line state 8 holds, and standing answer 25 isn't used.

Amended by Geoff on 2026-11-20, in his terminal session: TypeScript 7 and `@types/node` 26 move from the `intake`
round into this round's dependency sweep, the first task of `structure-base`. He asked why one SvelteKit app would
take the upgrade in a later round, and said "Move it to structure". The sweep closes #130 and #131. If the tools that
check Svelte files don't support TypeScript 7 that day, the pass holds it, says so in its pull request, and carries
on. The proof base stays the commit after the sweep, so the bump never reads as a change the structure work made.

## Backlog verdicts

A fresh reader checked 62 open backlog items against the code at `e03e574`: every item that names a file this
round changes, and every item tagged for a round to 0.8. Approving this design approves the edits below. The
first pass's planner lands them in its branch, because a design session writes nothing in the repo. No item is
dropped, done, or a duplicate.

The `intake` design gives verdicts on some of the same items. Where both rounds take part of one item, the round
that merges second rewords what the first left.

A full sweep of the backlog is due: 99 of 122 open items carry no sweep stamp, and 14 carry the tag of a pass
that has merged. It doesn't ride this design.

<details>
<summary>The verdicts, item by item</summary>

| Item | Verdict | Where | Reason |
| --- | --- | --- | --- |
| #138 a one-line function that only forwards | fold | `structure-keys`, 10 | Its 14 callers all sit in code the pass moves. |
| #139 a registry method no production code calls | fold | `structure-keys`, 20 | Its three tests assert through the refusal that loading a retired name gives. |
| #124 library code in the command folder | reword and fold | `structure-doctor` and `structure-keys`, already counted | The probes, the install logic, and the repeated read of the store's wait setting are this round. What stays in the item is one shape for the commands' wiring. |
| #147 copies of a value parser | reword and fold | `structure-doctor`, 15 | The item's text is out of date. The one live copy is `doctor`'s admin-address parse. |
| #156 comments that cite a review or a plan | fold in part | `structure-keys` and `structure-doctor`, 10 | Three such comments move with their code. The rest stay, with two exports only tests use. |
| #123 sign-in and shell trims | fold in part | `structure-doctor`, already counted | The backup hook. The `intake` design takes the doubled request check, and the rest stays. |
| #157 the class map leaves out `internal/ops` | keep | | Raising a class is your ruling. See "Left for other rounds". |
| #66 architecture cleanup | reword | | Two of the three items it points at are done. The ownership-check copies stay, because merging them changes refusal sentences. |
| #88 upload cleanups | reword | | Two of its clauses are already done. `intake` carries the rest. |
| #140, #149, #158 | keep | | Each changes what `doctor` prints or refuses. |
| #146, #148, #24, #77, #15, #13 | keep | | Each changes behavior, a log line, or the sign-in link. |
| #141 | keep | | It overlaps #148, and the full sweep can merge the two. |
| #142, #143, #144, #145, #133 | keep | | Tests and constants in lines this round only moves. #143 and #144 name a file the third pass relocates, and that pass updates the path in each. |
| #135, #136, #137, #154, #128, #129 | keep | | Gate, skill, and dependency items outside this round's lines. |
| #90 | keep | | `catalog` carries it. The first pass moves the query it names into `auth`, and updates the item's path. |
| #125 | keep | | `engine` carries it. |
| #121, #126, #84, #87, #92, #56, #57 | keep | | `intake` carries them. |
| #16, #47, #52, #54, #74, #73 | keep | | `playback` and `catalog` carry them. |
| #37, #89, #106, #107 | keep | | `launch` carries them. |
| #62 to #65, #93 to #96, #98 to #101, #103 | keep | | Initiative records, and none is in this round's files. |

</details>

## Estimate

1,090 path minutes: 390, 360, and 340.

| Pass | Where the minutes go |
| --- | --- |
| `structure-base` | The `_salvage` deletion 30, the store rename and the two layering rules 70, the pinning tests, the id package, and its six callers 130, the helpers 30, the clock 40, the table list and test 45, the two `users` reads 45 |
| `structure-keys` | Eight packages at about 35 each, the registration order and leftovers 40, the import test and the two notes 40 |
| `structure-doctor` | Eleven status functions and their probes 150, the install logic 60, the backup hook and the five variables 45, the address parser and the three comments 25, the probe's deadline 10, the architecture read and its fixes 50 |

The closest earlier pass is `cleanup-ops`, which moved code in the same folders. It was planned at 274 minutes
and took 150. The upload core was planned at 725 and took 570, and the admin API at 695 and took 475. Recent
passes took 0.4 to 1.6 times their figures, so the round lands between 436 and 1,744 minutes. I can't turn path
minutes into a share of the weekly allowance, and the usage stop is the guard.

## Practice and sources

- The architecture survey of 2026-11-17, Part 2, items 1, 2, 4, and 7.
- The approved `engine` design and the `cleanup` round design.
- The catalog architecture design in your queue, "Who owns a table", and the `intake` design's draft.
- Effective Go and Go Code Review Comments, on package names and on interfaces with one implementation.
- The repo's Go conventions: "`cmd/` contains only CLI wiring. No business logic."
- `pass-core` `references/round.md`, `planner.md`, `ready.md`, and `advisor.md`.
- Two readers with no background read this page before I sent it, the most the writing rule allows. The second
  reader's notes are folded in, and no third reader checked those last changes.

## Later

- The full backlog sweep, which is due and doesn't ride a design.
- One answer for an id of all zeros.
- One registration line for `serve`, which changes the order of two `doctor` rows.
- One file-ownership check in place of four.
- The wording of the three reserved `doctor` rows.
- One clean migration file, at `launch`.
