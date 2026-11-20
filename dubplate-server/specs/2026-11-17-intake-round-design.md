---
kind: design
approve: I record your picks in the design, write the prompts that will launch each pass, and launch nothing until the `engine` pull request is merged and the other conditions under "Start line" hold.
sendback: I answer each note in its thread, change the design, and send it back to you.
---

# Approve the design for the `intake` round of `dubplate`?

This is the design for round three on the road to `dubplate` 0.8. When it ends, a member (one person in the group
that shares a library) can drop an album on a page and watch it upload. The page then says whether the album was
matched to a MusicBrainz release, pushed back because no match was sure, or refused. Five passes build it, and the
last one ends with you trying the page yourself, the uploader sitting. I put the round at 2,610 minutes of work. A
round is meant to hold about 600, so its size is question 9. **It does not start when you approve.** It waits until
the `engine` round's pull request is merged and no other pass is running in `dubplate`. That wait ends without you
unless `engine` sends you a question. Thirteen questions are yours, and each has a recommendation. A question you leave unanswered takes its
recommended option. Approving also approves the backlog edits listed at the end.

Three rulings left open in October come first. Each is a small change once you answer.

**1. Does the upload check keep its rule about short audio blocks?** A FLAC file states the smallest block of audio
it will use. The check refuses a file as corrupt when a block in the middle of it is smaller than that. The rule
stops no attack, since a hostile file can state a minimum of one. It can refuse a rare honest file whose audio
was copied from another file without being encoded again. With the rule kept, a member who uploads such a file sees
it refused as corrupt, though it plays everywhere. With the rule dropped, the file passes when it decodes cleanly.

:::question short block rule
- **Drop the rule** A file passes when every block decodes and its checksum matches. {recommended}
- **Keep the rule** A rare honest file is refused as corrupt.
:::

**2. Do four upload limits ask an admin for a recent sign-in before they change?** Some settings are marked
sensitive. An admin is a member who can manage the server. One who changes a marked setting more than two hours
after signing in is asked to sign in again first. October's review of the upload code asked whether four upload
limits should carry the mark: the largest album, the largest embedded picture, the largest block of tags, and the
number of uploads checked at once. They are four of fifteen upload settings with no mark. Each of the fifteen has a
ceiling in the code that no session can lift, so a mark would protect little. The one upload setting that guards
the disk directly, the free-space floor, is already marked.

:::question sensitive upload limits
- **Mark none** A stolen admin session can raise a limit as far as its ceiling and no further. {recommended}
- **Mark the four** They ask for a recent sign-in, and the other eleven don't.
- **Mark every upload limit** All fifteen ask for a recent sign-in.
:::

**3. What does the sign-in page tell someone whose address is not a member's?** Today it says, "We don't recognize
that address. Check the spelling, or ask whoever runs this server to add you." That is kind to a member who mistyped.
It also lets a stranger test addresses and learn who belongs to the group. The other answer gives every address the
same line, "If that address belongs to a member, we'll send it a sign-in link." A member who mistypes then waits for
mail that never comes. Which answer the page gives is a server setting, with the values `kind` and `generic`.
The setting stays either way, so whoever runs the server can switch it.

:::question unknown address answer
- **Same line for everyone** The setting's default becomes `generic`, and nobody can test who is a member. {recommended}
- **Keep telling them** The default stays `kind`.
:::

The next four questions are about what a member meets on the uploader page.

**4. What happens when a member uploads a second copy of an album the group already has?** The check already
refuses an upload whose audio is identical to one accepted before. A different rip of the same album, a second
copy made from the disc, has different audio. Today nothing catches it. Once the album is matched, `dubplate` knows which MusicBrainz release it is and
can tell. MusicBrainz lists a remaster or a high-resolution edition as a separate release, and those still pass.

:::question second rip of an album
- **Refuse the second rip** The member sees the "already in library" refusal and the upload ends. A better rip can't replace the first until the `queue` round gives an admin that choice. {recommended}
- **Accept both** The second upload is accepted too. Once the `catalog` round adds albums to the library, the album appears there twice.
- **Hold it for an admin** The member sees it waiting. The upload and its files stay on the server until the `queue` round builds the page where an admin settles it.
:::

**5. What does the page say once an album is accepted?** The wording you approved for this page reads, "Matched: {artist} - {album}
({year}). You can close this page now." The list of past uploads then shows the album as "adding now". Nothing adds
an album to a library until the `catalog` round, so at your sitting an accepted album stays at "adding now". By
first launch `catalog` has landed and the step after it, "In your library", is real.

:::question after acceptance wording
- **Use the wording you approved** The page says "Matched" and "adding now", and `catalog` adds "In your library" with its link. {recommended}
- **Say less until `catalog`** The page says "Matched" and "accepted", and `catalog` changes both strings later.
:::

**6. When MusicBrainz is down, does `dubplate` try again by itself?** A member whose album can't be matched because
MusicBrainz isn't answering sees "Can't check MusicBrainz right now" and a "Try again" button. If they close the
page and forget, the upload waits seven days and is then deleted. With automatic tries, `dubplate` asks again every
hour until the seven days end, and the member's album is usually matched by the time they look. The wording you
approved says "Try again in a little while". That line no longer fits when the server tries by itself. I rewrite
it, and you read the new line at the sitting.

:::question retry while MusicBrainz is down
- **Try again every hour** The member needs to do nothing, and the button stays for the impatient. {recommended}
- **Only the button** An upload nobody returns to is deleted after seven days.
:::

**7. Which archive files can a member upload at 0.8?** On 2026-09-23 you asked for "`.zip`, `.tar.gz`, and similar".
The upload core that landed in October takes loose files or one ZIP. Each further format needs separate defenses
against an archive built to fill the disk, as ZIP has today.

:::question archive formats
- **ZIP only at 0.8** A member with a `.tar.gz` or `.7z` unpacks it and uploads the folder. Other formats go to the backlog. {recommended}
- **Add `.tar.gz` in this round** The round grows by about 150 minutes beyond the figure above, in the first pass, where the ZIP defenses sit.
:::

The last six are about scope, order, and budget.

**8. Does this round first fix the two shapes the uploader would otherwise copy?** The architecture survey found two
places where the code does one job several ways, and this round adds to both. Fixing them changes nothing on any
screen.

- On the server, the code for members and settings knows nothing about the web API. A small package beside it
  translates between the two. The upload code has no such package and builds the web API's answers itself. This
  round adds upload operations. The streamer, the part of the server that music apps talk to, will later need the
  same upload facts in a different form.
  The fix gives uploads the same small package. It is 260 minutes, counting three leftovers of the `cleanup` round
  that sit in the same files.
- In the browser, the members page and the settings page each carry a copy of the logic for a failed
  save: the notice, the retry, the fresh sign-in, the reload. The uploader would be a third copy and `library` adds
  three more. The fix is 150 minutes.

You wrote that you want "the straightest line to correct", so I recommend both.

:::question fix the two shapes first
- **Fix both first** The two fixes are about 410 minutes, which the 2,610 already counts. {recommended}
- **Fix the server one only** The uploader page copies the save logic a third time. The round is 2,460 minutes.
- **Fix neither** New code follows the right shape and the old code stays. The round is 2,200 minutes.
:::

**9. Is this one round or two?** The rule holds a round to about 600 minutes so that you read a design before much
is built on it. This work is 2,610 minutes in five passes: two on the server, two in the browser, and the last for
the look and your sitting. Each pass is planned just before it runs, from the code the earlier ones left.

:::question round size
- **One round of five passes** You approve once. A report reaches you when the two server passes have merged, and you meet the page at the sitting. {recommended}
- **Two rounds** This approval covers the two server passes, 1,090 minutes. I send a second, shorter design for the three browser passes when those merge.
- **One pass at a time** This approval covers the first pass only, 610 minutes.
:::

**10. Do the passes merge on their checks and reviews, or do you read each first?** Every pass in this round touches
sign-in or data code. The standing rule puts each such pass in your queue to read before it merges. That is
five documents for you to read, and each pass waits for your answer before the next one starts. Every pass here
gets a review of each task, a review of the whole branch, a review by a security reader, and green checks. The last
pass ends at your sitting whatever you pick.

:::question merge rule
- **Merge four on checks and reviews** The first four merge without you. The report after the server passes and the sitting's document list what merged. The fifth waits for your sitting. {recommended}
- **One document after the server passes** You read one document for passes one and two. Passes three and four merge on checks and reviews, and the fifth waits for your sitting.
- **A document for every pass** Five reads, as the standing rule has it.
:::

**11. Do TypeScript 7 and the Node 26 types land in this round?** You held both until `intake`. This round writes
the first large body of browser code, so taking them now means that code is written once, against the new version.
If the tools that check Svelte files don't support TypeScript 7 yet, the pass holds it again and says so.

:::question held majors
- **Take both in the first pass** The uploader is written against TypeScript 7. {recommended}
- **Hold both until `library`** The uploader is written against TypeScript 6.
:::

**12. Where is the weekly usage stop for this round?** The standing answer stops new work when the week's Claude
usage reaches 85 percent: a pass finishes its task, pushes, and waits. You lifted it until the reset on November 20 at 10:59 PM, and for `engine` you picked 95 percent until then. Usage read 39
percent on 2026-11-17. This round can't start before `engine` merges, so most of it runs
after the weekly reset.

:::question usage stop
- **95 percent until the reset, 85 after** The line you picked for `engine`. {recommended}
- **85 percent throughout** The standing line, with no lift.
- **No stop until the reset, 85 after** Work runs to the weekly limit before November 20.
:::

**13. Does this round or the structure pass go first?** You allowed a structure pass, which moves code to better
homes and changes nothing it does. Another session is designing it and will ask you its order. I ask here only so the two answers agree. The two never run together,
since both rewrite the upload code and the server's command folder. No decision in this design changes with the
order. If structure goes first, the files have new paths and each planner here reads them where they are.

:::question order with the structure pass
- **Whichever is approved first** The other starts from its merge. {recommended}
- **Structure first** `intake` waits for the structure pass to merge, however long its design takes.
- **`intake` first** The structure pass waits for this round's last pass to merge.
:::

:::decide

Initiative: `dubplate-server`. Round: `intake`. Repo: `glw907/dubplate` (`dubplate`, default branch `master`).
Written 2026-11-17 against `master` at `7151edb`, with the approved `engine` design read on top. `master` has since
moved to `e03e574`, which changes `docs/STATUS.md` and nothing else. Status: approved 2026-11-17 (see "Rulings").

## Brief

The upload core landed in October. A member's files arrive, a gate checks each one, and an album that passes moves
to a state named `matching`. Nothing moves it on. There is no page, so the only way to upload is a script.

This round finishes the job in five passes.

1. `intake-ground` gives upload operations the same translating package that members and settings have, clears the
   review's findings in the upload code, and lands your three rulings.
2. `intake-match` builds the match probe. One worker in the server asks MusicBrainz about each album in `matching`
   at one request a second and records the answer.
3. `intake-shell` gives every page one frame and one module for a failed save, adds the gate that keeps signed-out
   visitors off member pages, and styles the 404.
4. `intake-page` builds the uploader page.
5. `intake-look` adds the photographs, finishes the carried styling, and ends in your sitting.

## Why

You asked for this round's design now, while there is time to spend on its hard questions, and you named what you
want from it: the hard questions of architecture, and "a polished, clean, and beautiful codebase". On 2026-11-17
you added that you want "clean, well-designed code" that stays easy to maintain, and "the straightest line to
correct".

The survey of 2026-11-17 handed this design four findings and three structural items. I checked each against the
code. The section "Where I differ from the survey" says where I landed somewhere else.

## Decided by Geoff

- The route for music MusicBrainz doesn't list is named "Unlisted music". There is no default quota per member. A
  rejected upload is final. A member uploads an album or separate tracks. (Intake spec, owner rulings.)
- One uploader sitting, at the end, on the workstation. It is your design review of the uploader.
- 0.8 takes FLAC only.
- TypeScript 7.0.2 and `@types/node` 26.6.6 are held "until intake" (`engine` design, 2026-11-16).
- A parked pass does not hold the next one (document `20261116-163931-082d9d`).
- The 85 percent usage stop is lifted until the reset on November 20, and `engine` stops at 95 percent until then
  (document `20261117-055811-900560` and the `engine` design).
- A structure pass is allowed before `catalog`, designed by another session.
- Nothing stored on the `dubplate` server has to be kept until first launch (document `20261117-073456-91db2f`).
  This round deploys nothing and deletes nothing there. It also carries no upload row forward: a database from before
  this round may be thrown away, so no pass writes code to convert old rows.

## Goals

- A member uploads an album as files or as a ZIP, or separate tracks, and sees one of three ends: matched, pushed
  back with ways forward, or refused with the reason.
- An upload interrupted by a closed laptop resumes from the page.
- Every MusicBrainz request the server makes goes through one pacer at one request a second.
- What the probe stores lets `catalog` admit the album without matching it again.
- `internal/intake` no longer imports `internal/ops`. Each wire dialect has one adapter per domain.
- A page's save logic exists once.
- You see every state of the page, at desktop and phone widths in both palettes, and rule the visual identity's two
  open items.

## Non-goals

- Admitting an accepted album to a library, the library pages, and "Open in" links. Those are `catalog` and
  `library`.
- An admin's page for settling a pushed-back or duplicate album. That is `queue`.
- Splitting `cmd/dubplate-server`, renaming the store, one home for ids and the clock, and deleting `_salvage`. Those
  are the structure pass's.
- Deploying anything. The `dubplate` server stays as it is until `launch`.
- A second caller of MusicBrainz, a priority between callers, and a setting for a MusicBrainz mirror.
- Formats other than FLAC.
- A test in Safari or on an iPad. The harness drives Chromium, and your sitting is on the workstation. The page
  keeps the file picker as a full path beside the drop target, which is what an iPad needs, and uses the screen
  lock only where the browser has it. A check on a real iPad is filed for `launch`.

## Anti-goals

- A write to the database that stays open across a MusicBrainz request or a file read.
- A test or a gate leg that calls `musicbrainz.org`.
- A probe that accepts an album with a track left over on either side.
- A page or an API answer that gives a signed-out visitor any member's data. The app's script and style files hold
  code and copy and no data, and they stay open to everyone as they are today.
- A second place in the browser that talks to the network outside the two named modules.
- Anything exported that no caller in this round uses.

## Calls made here

These are Claude's calls, made under the method-and-architecture rule. Each is open to a note.

### The pacer

`engine` deletes the MusicBrainz limiter, which had no caller and a spacing bug. This round builds what replaces it.

The server builds one `rate.Limiter` from `golang.org/x/time/rate` at one request a second with a burst of one. That
package is already a direct dependency, used by the sign-in limiter. The limiter is wrapped as an
`http.RoundTripper` and handed to the MusicBrainz client through `ClientConfig.HTTP`, a field the client already
has. One client is built at startup and lives as long as the server.

The transport is the right place for three reasons. Every attempt passes through it, a retry included, so no caller
can forget to wait. The engine's client needs no change after `engine` removes its budget field. The engine stays
free of the clock, which `TestEngineNeverReadsTheClock` enforces.

One cost comes with it. The client's 30-second timeout covers the whole round trip, so time spent waiting for the
pacer counts against it. With one caller the wait is at most a second. `catalog` adds a second caller and must look
at this again, and the pass leaves that sentence in the pacer's doc comment.

Every MusicBrainz caller runs inside `serve`, as the survey recommends. A command-line caller would be a second
process with a second pacer, and MusicBrainz counts requests by address.

This supersedes the intake spec's probe paragraph at lines 708 to 720, which builds a `Limiter`, a `Budget` per run,
and a setting named `DUBPLATE_INTAKE_MATCH_BUDGET`. None of the three is built. A frozen spec takes a one-line
pointer at its head, and the pass adds it.

### The probe's bounds

One probe makes at most about twelve requests before any retry: a lookup by id when the tags carry one, else
several searches and up to five lookups. At one request a second that is about twelve seconds. The client tries a failed
request up to seven times in all, with a 30-second timeout on each, so a probe with no bound could run for most of an hour.
The probe therefore runs under a deadline of two minutes, a constant. A probe that passes it ends as `match-unavailable`.

The client identifies itself to MusicBrainz as `dubplate/<version> ( https://github.com/glw907/dubplate )`, the form
MusicBrainz asks for.

### The worker

The checking worker already treats the database as its queue, and the probe copies that shape. `Intake.Start` runs
one more goroutine beside the checker and the sweep. It reads the ids in `matching`, oldest first, and probes one at
a time, since the pacer makes the wire serial anyway.

Each probe has three steps.

1. Read the submission's file rows in a read.
2. Outside any transaction, read the tags of each staged file and call `tag.Album`.
3. Commit the outcome in one write that moves the row only if it is still in `matching`, with the duplicate checks
   inside that write.

Four things wake the worker: the write that moves a row into `matching`, a member's retry, the sweep, and startup.
A cancelled context commits nothing, so a restart leaves the row in `matching` and the next start probes it again.
A panic in the matcher is caught as the checker's is, logged as an error, and ends as `match-unavailable`.

The stall rule watches the worker and never the length of the queue. The worker notes the instant each probe ends.
The sweep marks a `matching` row stalled when the row has waited longer than the stall setting (30 minutes by
default) and no probe has ended in that time. With a two-minute deadline on every probe, that happens only when the
worker is stuck or dead. A row that is waiting behind others shows "Waiting its turn" and sends no mail. A stalled
row gets the same `stalled` event and the same mail to admins that a stalled check gets. The startup pass queues
`matching` rows as it queues `checking` ones.

### The outcomes

| The matcher says | The row moves to | The member sees |
| --- | --- | --- |
| A strong match, every file paired with one track, no track left over | `accepted`, or `rejected` when the release is a duplicate | "Matched: {artist} - {album} ({year})" |
| Anything weaker, or no candidates | `pushed-back` | The push-back view and its four ways forward |
| MusicBrainz unreachable, or the two-minute deadline | `match-unavailable`, reason `musicbrainz-unavailable` | "Can't check MusicBrainz right now" |
| A staged file can't be read, or the matcher panicked | `match-unavailable`, reason `could-not-run` | The same view, and an error in the server log |

The probe uses the quiet-import settings of the matcher, under which only a strong recommendation applies a match. It
also checks the pairing itself and never trusts the recommendation alone: a candidate with a file or a track left
over is pushed back.

Under question 6's recommended answer the sweep moves a row with reason `musicbrainz-unavailable` back to `matching`
once it has waited an hour. A row with reason `could-not-run` is never retried by the server, since the same
input would fail the same way.

A member's "Try again" moves `match-unavailable` or `pushed-back` back to `matching`. A submission can be probed
ten times at a member's request. The count belongs to the submission, and the server's hourly tries don't add to
it. The eleventh answers a conflict, so one member can't spend the shared second of
MusicBrainz time in a loop.

The seven-day hold for the two new waiting states counts from the first time the submission reached `matching`.
Neither a retry nor an automatic try extends it.

### The stored proposal

Three columns that already exist hold it. I use them because their shape is right, so this design changes no
table. No row has to survive this round. A planner who does find a column in the way changes the table and writes
no code to convert old rows.

| Column | Holds |
| --- | --- |
| `mb_release_id` | The MusicBrainz id of the release that was applied |
| `match_evaluated_at` | The date handed to the matcher, which it scores against |
| `match_candidate` | One JSON object, described below |

`match_candidate` holds a `version` of 1, the candidate's `distance`, and a `release`. The `release` is the whole
`matcher.AlbumInfo` the matcher scored, with nothing dropped. Each of its tracks also carries `file`, the id of the
`submission_files` row paired with it. The pairing the matcher returns uses positions in a slice, which mean nothing later,
so the pairing is stored by file id. A test compares the stored JSON for a fixture album with a literal.

`AlbumInfo` is the view of a release that the matcher scores. It has titles, artists as text, years, the label, the catalog
number, the medium and position of each track, and each track's length. It has no artist ids, no release-group id,
and no sort names. When admission needs one of those, it looks the release up by `mb_release_id`. That is one
request through the same pacer, and it is a lookup, never a second search or score. Whether to store more is the
catalog architecture's call. A change there adds a field and a version.

A pushed-back submission stores `match_evaluated_at` and nothing else, and its event carries one of two reasons,
`no-candidates` or `not-strong`. No caller in this round reads a pushed-back candidate, so none is stored.

### What `accepted` promises

A session that admits an `accepted` submission may rely on each of these.

- Every byte is staged and held. Cleanup never takes an `accepted` submission's files, and nothing in `intake` moves
  a row out of `accepted`.
- Every audio file passed the gate under the limits in force when it was checked. Its audio key, file hash, sample
  rate, bit depth, channels, sample count, disc, and track are stored.
- No other `accepted` submission in the same collection has the same audio. For an album that is the album key, for
  a separate track the audio key.
- On the default route, the three proposal columns are set, and the stored pairing matches every audio file with
  exactly one release track.
- Under question 4's recommended answer, no other `accepted` submission in the collection has the same
  `mb_release_id`.
- On the unlisted route, the collection is "Unlisted music" and the names the member typed are stored. A duplicate
  there is judged by the audio and never by the typed names.
- The uploader, the source answer, the note, and the store link are stored.

It does not promise three things. The catalog may already hold that release, since `intake` can't see a catalog
that doesn't exist yet. MusicBrainz may have changed or removed the release since. The limits may have changed
since the check.

### Nothing here forces a second pass over a file

The survey asked for this check. The probe reads only each file's tag blocks. Admission must open each file anyway
to write its tags and move it, so nothing the probe leaves out costs a read.

One fact is worth passing on. The gate already decodes every frame of every file once, to compute the audio key.
ReplayGain and R128 loudness need a full decode too, and today that would be a second one at admission. Measuring
loudness during the gate's decode would save it. That would put `catalog` code that isn't designed into `intake`
ahead of any caller, so this round doesn't build it. The catalog architecture decides, and the gate's decode loop
is at `internal/intake/gate/file.go:297`.

### The transliteration table

The matcher compares names after turning accented and non-Latin letters into plain ones, from a table.
`matcher.Transliterate` panics when no table is installed, and today only a test installs one. `serve` loads the
table from the state folder and installs it before `Intake.Start`. If the table is missing, `serve` refuses to
start and names the command that writes it, `dubplate-server unidecode install`. A server that matched without the
table would score the same album differently, and nothing would show it.

This adds one step to the first deploy, which `launch` carries.

### Tags to matcher input

The matcher takes `matcher.ItemFields`. The only code that builds them today reads the test corpus. The pass adds
one function in `internal/engine/tag` that builds them from a file's `tagio.TagSet` and its length. `catalog` will
call the same function. Its test compares against literals.

### The wire

Under question 8's recommended answer, `internal/intake` exports a plain Go API whose types and errors name nothing from the wire, and a
new package `internal/ops/submissions` translates it to the wire, as `internal/ops/admin` does for members and
settings. `internal/intake/seam.go` goes away. Then the new operation and fields land on that shape:

- `route_unlisted` moves a pushed-back album to the unlisted route with the names the member types.
- `create_submission` takes the route and, for the unlisted route, the typed names.
- `retry_submission` and `cancel_submission` work from the two new waiting states.
- `get_submission` gains the match (artist, album, year, release id) and the push-back reason.
- `list_submissions` gains a `label` for each row: the matched artist and album, else the typed names, else the
  top folder or file name.

`internal/ops` keeps its import of `internal/reject`, though the operations spec says it imports `identity` only.
The reject reasons are contract text that every dialect carries, and the spec's sentence is the part that is out
of date.

### The browser

Under question 8's recommended answer, one rune module owns a page's save state: the notice, the retry, the fresh
sign-in branch, and the reload after a save. A page hands it the calls and the copy. The members and settings
pages move onto it first, with every rendered row unchanged. `AdminPage.svelte` knows only admin pages, so it
becomes one page frame that a member page uses too.

Backlog item #155 lists seven faults in that save logic and the frame, and says one "needs a ruling". After a save,
the page loads its list again. When the server refuses that load because the admin's session ended or their role
changed in between, the page keeps the old list on screen as though nothing happened. The call is one of method, so I make it. A
refused reload shows what a fresh visit would show, the signed-out state or the refusal. A reload that fails
because the server can't be reached keeps the list and its notice, as today. The seven fixes land after the move,
each with the rendered row it changes.

`web/src/lib/api/request.ts` says it is the one place the app calls `fetch`. Nothing checks that. Uploads need a
second network module, since `tus-js-client` sends requests without going through that file. The rule becomes two named modules, and a gate
script fails on a `fetch(` or an import of `tus-js-client` anywhere else.

### What I assume of the structure pass

- It moves files and renames packages and changes no behavior. Each planner here reads the tree as it finds it.
- `intake` stays the only writer of `submissions`, `submission_files`, and `submission_events`.
- New settings are declared beside the upload wiring, wherever that pass puts it. Today that is
  `cmd/dubplate-server/intake.go`.
- This round adds no id parser and no clock helper.
- If `_salvage` is deleted first, the page pass reads the old components from git history.

### Where I differ from the survey

- **The pacer.** The survey asks for "a plain interval pacer". I use the limiter from a package the repo already
  depends on, placed on the transport, and build no new type.
- **The second rip.** The survey refuses it "at admission". I also refuse it at the probe, when the member is still
  on the page, against other accepted submissions. Admission repeats the check against the catalog. The `albums`
  table has no unique index on collection and release id, and `catalog` adds one.
- **The page frame.** The survey names the save module. A member page also needs the frame, which is admin-only
  today.
- **`ops` and `reject`.** The survey counts that import as a fault. I count the spec's sentence as the fault.
- **Folder-admit.** The survey has it create `accepted` submissions. That is `catalog`'s call. The promise list
  above is what any path into `accepted` must keep.

I agree with the rest of findings 1, 2, 4, and 6 and of items 3 and 5.

## Scope

Five passes, in order. Every pass is class `auth-data`, so each task writes its failing test first and gets its
own review.

| Pass | Outcome | Files | Path minutes | Depends on |
| --- | --- | --- | --- | --- |
| `intake-ground` | Upload operations reach the wire through an adapter. The review's upload findings are cleared. Your three rulings land. | `internal/intake/**`, `internal/ops/**`, `internal/reject/**`, `cmd/dubplate-server/{intake,api,serve,auth,doctor}*.go`, `web/package.json`, `Makefile` | 610 | `engine` merged |
| `intake-match` | An album in `matching` ends matched, pushed back, or waiting on MusicBrainz. | `internal/intake/**`, `internal/engine/tag/**`, `internal/ops/**`, `cmd/dubplate-server/{serve,intake,unidecode}.go` | 480 | 1 |
| `intake-shell` | Every page shares one frame and one save module. Member pages are gated. The 404 is styled. | `web/src/lib/**`, `web/src/routes/**`, `web/scripts/**`, `internal/auth/admin.go`, `internal/serve/**`, `internal/webapp/**`, `cmd/dubplate-server/{web,serve,rendered_test}.go` | 500 | 2 |
| `intake-page` | A member uploads from the page and sees every state. | `web/src/**`, `web/scripts/**`, `web/package.json`, `internal/reject/**`, `internal/webapp/webapp.go`, `cmd/dubplate-server/{web,rendered_test}.go`, `docs/research/passb-copy-final.md` | 540 | 3 |
| `intake-look` | The photographs and carried styling are in, and you have sat with the page. | `internal/photos/**` (new), `tools/photos/**`, `photos/**`, `web/src/**`, `web/scripts/**`, `internal/webapp/**`, the living reference documents under `docs/` | 480 | 4 |

Every pass shares `cmd/dubplate-server/serve.go` or the `web/` tree with its neighbor, so the order is a chain and
no two run together.

A listed file brings its tests, the fixtures under its `testdata`, and any file a command generates from it. The
lock files count as listed wherever a manifest is: `go.mod` and `go.sum`, `web/package.json` and
`web/package-lock.json`, and `web/tsconfig.json`. `web/src/lib/copy/deck.ts` counts as listed in every pass, since a
new error detail on the server needs its line of copy in the same change. A test anywhere in
`cmd/dubplate-server` that starts the server counts as listed in `intake-match`, which changes how it starts.

## How it fails

| Case | What happens | Number |
| --- | --- | --- |
| MusicBrainz answers 429 or 5xx | The client retries. The probe ends `match-unavailable` if it can't finish. | 7 attempts per request, 2 minutes per probe |
| MusicBrainz is down for days | The row is tried again each hour (question 6) and expires at the hold. | 1 hour, 7 days |
| A member presses "Try again" in a loop | The eleventh request answers a conflict. | 10 retries per submission |
| The server restarts in the middle of a probe | Nothing was committed. Startup probes the row again. | |
| The probe worker ends no probe while a row waits in `matching` | A `stalled` event and one mail to admins. | 30 minutes by default |
| The transliteration table is missing | `serve` refuses to start and names the install command. | |
| A signed-out visitor opens the uploader | A redirect to the sign-in page. | 303 |
| A member opens an admin page, or anyone opens an unknown path | The same styled 404, byte for byte. | 404 |
| The connection drops in the middle of an upload | The page retries, then offers "Resume". | `tus-js-client` default delays |
| A member reloads during an upload | "Your uploads" lists it with "Resume". The member picks the files again, and the page matches them by path and size. | |
| A pushed-back album goes to the unlisted route and a copy is already there | It is refused as a duplicate. | |

## The passes

### `intake-ground`

The first task is the round's dependency sweep, with the two held majors under question 11.

Then the adapter move. `intake` gains exported request and result types and errors declared in `intake`. `internal/ops/submissions`
holds a `Seam` that satisfies `ops.SubmissionSeam` and one function that maps `intake`'s errors to wire errors. Two
test files already drive the five operations over HTTP, `cmd/dubplate-server/apisubmissions_test.go` and
`internal/ops/opshttp/submissions_test.go`. Neither changes during the move, and both must pass at its end.
`internal/intake/seam_test.go` holds 18 tests written against the wire types. Each is rewritten against the new Go
API in `intake`, or moves to `internal/ops/submissions` when it tests the translation, and the pull request lists
where each went. The adapter's tests build an `Intake` through its exported constructor and use no helper exported
for tests. The three leftovers of the last
cleanup ride along, since they sit in the same files: the mount and handler merge, the error code as the target
of `errors.Is`, and one actor type where there are two.

Then the review's upload findings: the gate's second parse of each file, the duplicate-name check that misses a
file and a folder with the same name, the role derived in two places, a branch in `accept` that nothing reaches,
and a reject reason nothing produces. The cleanup and hardening items in "Backlog verdicts" marked for this pass
follow. Your three rulings are the last tasks.

### `intake-match`

The pacer, the one client, and the table check at startup come first, since the probe needs all three. Then the
tags-to-matcher function, the two new states with their transitions, the worker, the stall and startup rules for
`matching`, the hourly retry, and the wire changes listed under "The wire".

No test calls MusicBrainz. The probe's tests run against a local server that replays recorded answers, the way the
conformance harness does.

### `intake-shell`

The save module and the page frame come first, and the members and settings pages move onto them. The frame takes
over the login, sign-in-link, and error pages' scaffolding too, which the last web cleanup left.

`RequireMember` goes beside `RequireAdmin` and is built on the request check that exists, which also removes a
doubled check there. A page request without a session gets a 303 to the sign-in page. The 404 becomes the web
error document. Seven places answer a page request with Go's plain 404 today, `RequireAdmin`'s refusal among them,
and all seven go through one handler. A `web-auth-security-reviewer` read
covers both.

The prefix root redirects to the path of the uploader page, the signed-in page gains a Continue link, and the header's mark
points there. Until the next pass builds the page, that path shows the frame with an empty body.

### `intake-page`

One module wraps `tus-js-client` at 4.3.1 with the settings the intake spec fixes. The page is the member's landing
page and has four parts.

| Part | What a member sees |
| --- | --- |
| Start | A drop target and a file picker of equal standing. The choice of album or separate tracks, with album picked. The source question, asked once and required. The unlisted route as a choice, with what it means stated before the upload starts. |
| Upload | One bar per file and one for the whole upload. The page keeps the screen awake where the browser allows it. |
| Journey | Four steps: "Uploaded", "Checked", "Matching", and "In your library". A branch (refused, pushed back, MusicBrainz down, stalled) shows as a panel beside the steps, which stop where they are. The page asks the server every five seconds. |
| Your uploads | Every upload the member has made, unfinished ones first with "Resume". |

The push-back view offers four ways forward: fix the names and upload again, add the release to MusicBrainz, try
again, or send it to "Unlisted music".

Copy comes from the approved copy document word for word, except the strings the backlog lists for redraft, which
you read at the sitting. Every state is a named row in the rendered harness at 390 and 1440 pixels in both
palettes. The pass renders and reads each one before you see any.

### `intake-look`

The photo loader becomes a small Go package and a gate leg, replacing `tools/photos/check.mjs`, with the credits
file generated from the same manifest. The login page gains its photo column, and the error pages and the empty
state gain their photographs. The carried styling items land. The visual identity's open items that need no
catalog are built for your verdict: the phone header, error alerts as a tinted panel, and motion.

The pass runs the coherence read, then prepares the sitting.

## The sitting

You drive real uploads on the workstation, against the live MusicBrainz, at desktop and phone widths in both
palettes. The pass prepares a file that is refused and an album that is pushed back. You bring one FLAC album you
own.

1. The album as loose files, through to "Matched".
2. The same album as a ZIP, which is refused as already in the library.
3. Separate tracks.
4. The refused file.
5. The pushed-back album, then the unlisted route.
6. An upload interrupted and resumed.

You decide four things there, on one document: whether the page's look is right in each state, the phone header,
error alerts as a tinted panel, and the redrafted strings. Your approve merges the last pass.

## Acceptance

Each item names what you would see or what a command prints. "Today" is the output on 2026-11-17 at `7151edb`. A
test named here is new unless the item says otherwise, and it fails before its task's change.

### `intake-ground`

1. No package under `internal/intake` imports `internal/ops`, tests included. A `go list` over
   `./internal/intake/...` that prints each package's imports and test imports, piped to `grep -c
   dubplate/internal/ops`, prints 0. Today it prints 2. `TestLayering` in `internal/intake` gains the same rule, so
   a later import fails the gate.
2. `internal/intake/seam.go` is gone, and the server builds its upload operations from the adapter. `grep -rn
   "ops/submissions" cmd/dubplate-server --include=*.go | grep -v _test` prints one import line. Today the file
   exists and the grep prints nothing.
3. The two test files that drive the five operations over HTTP pass at the commit that ends the move. Their diff
   from `7151edb` at that commit holds lines that build the server under test and no changed expected value. The
   pull request carries a table of the 18 tests in `seam_test.go` with where each went, and the whole-branch
   reviewer checks each one's expected values against `7151edb`.
4. The gate reads each file once. `grep -rn "tagio.Read(" internal/intake/gate --include=*.go | grep -v _test`
   prints nothing, where today it prints one line. A gate test passes a clean file through a reader that fails on
   a second pass.
5. A test declares `a.flac` beside `a.flac/b.flac` and is refused as a malformed manifest, the answer a path listed
   twice gets today. Today the pair passes the check.
6. Under question 1's recommended answer, the row at `internal/intake/gate/file_test.go:147` flips. Today it
   expects `Corrupt` for frames under the stated minimum. After the change it expects the file to pass. Two new rows pass too: a clean file
   whose last frame is short, and a long silent track. The pull request shows the three rows in the output of `go
   test -v`.
7. Under question 2's recommended answer no setting changes, and the backlog item closes with your ruling. Under
   either other answer, a test changes each marked setting with a session older than two hours and gets the
   refusal a marked setting gives today, then succeeds with a fresh session.
8. Under question 3's recommended answer, a test on a fresh database requests a link for an unknown address and for
   a member's. The two answers have the same status, the same headers apart from `Date`, and the same body. Today
   the unknown address gets the `unknown` answer.
9. `bash scripts/gate.sh --merge` passes.

### `intake-match`

1. The server builds its MusicBrainz client in one function. `grep -rn "musicbrainz.NewClient(" cmd
   internal/intake internal/serve --include=*.go | grep -v _test` prints one line, and today it prints none. A test
   builds the client through that function, points it at the local server, and runs three probes together. The
   server sees no two requests less than 950 milliseconds apart, counting a request it answered 503 and the retry.
2. For a fixture album with a strong match, the row ends `accepted`. The fixture's files are created in an order
   that differs from the track order. The test checks that each release track's `file` is the id of the file whose
   path carries that track's number, and that the whole of `match_candidate` equals a literal JSON document.
3. Three fixtures end `pushed-back`: one with a file MusicBrainz doesn't list and one missing a listed track, both
   with reason `not-strong`, and one whose search returns nothing, with reason `no-candidates`. In all three
   `mb_release_id` and `match_candidate` are empty.
4. With the local server answering 503, the row ends `match-unavailable` with reason `musicbrainz-unavailable`. With
   the clock moved an hour on and the server answering again, the sweep sends it back and it ends `accepted`. A row
   with reason `could-not-run` is still `match-unavailable` after the same hour.
5. A second submission holds a different rip of an accepted album, so its audio differs and its release is the
   same. It ends `rejected` with `already-in-library` (question 4).
6. A test holds the database's write lock and starts a probe. The local server receives every request of that
   probe while the lock is held, and the row is still in `matching`. When the lock is released the row ends
   `accepted`. A probe whose commit fails on a busy database leaves the row in `matching`.
7. A probe is cancelled after the local server has received its first request. The row stays in `matching` with no
   event added, and a new `Intake.Start` finishes it.
8. `dubplate-server serve` with no table in the state folder exits 1, prints the table's path and `dubplate-server
   unidecode install`, and opens no listener. A table that fails its checksum gets the same refusal. Today `serve`
   starts.
9. Over HTTP, `get_submission` for the accepted fixture returns the artist, album, year, and release id as
   literals, and for a pushed-back one its reason. `route_unlisted` on the pushed-back one ends `accepted` in
   "Unlisted music" with the typed names stored. A second upload of the same audio sent the same way is refused as
   a duplicate. Today `route_unlisted` answers as an unknown operation.
10. After three automatic tries, ten `retry_submission` calls on one submission succeed and the eleventh answers a
    conflict. A retry on the same member's other submission still succeeds.
11. With the worker blocked and the clock moved 31 minutes on, the sweep writes one `stalled` event for a waiting
    row and sends one mail. With probes ending as usual, a row that has waited 31 minutes in the queue gets neither.
12. Two guards pass today and must still pass. `go test ./internal/harness/conform -run
    'TestEngineNeverReadsTheClock|TestEngineNeverImportsHarness'` passes, and `go list -deps ./internal/engine/... |
    grep -c golang.org/x/time` prints 0.

### `intake-shell`

1. The commits that move the members and settings pages onto the save module and the frame change neither
   `web/scripts/rendered/run.ts` nor `cmd/dubplate-server/rendered_test.go`, and every rendered row passes at the
   last of them. `git diff --stat` over those commits lists neither file. Later commits change only the rows the
   pull request names for #18, #20, #150 to #153, and #155.
2. `grep -l needsReauthentication web/src/routes/*/+page.svelte` prints nothing, since only the save module calls
   it. Today it prints the two pages.
3. A gate script fails when a file outside the network module names `fetch`, `XMLHttpRequest`, `sendBeacon`,
   `EventSource`, or `WebSocket`, or imports `tus-js-client`. The pull request shows it failing on a planted line
   of each kind and passing without them.
4. A request for the path of the uploader page with no session answers 303, and so does one with an expired session.
   `Location` is the sign-in path under the prefix and names no host.
5. A test requests one path at each of the seven places that answer a page request with 404 today: the server's
   route table, the document router's two refusals, the static file handler, the web app's route table,
   `RequireAdmin`'s refusal, and the probe route's refusal. Every answer equals the first in status, in headers
   apart from `Date`, and in body, and the body is the styled page. A member's request for the members page is one
   of the seven. Today each returns Go's plain `404 page not found`.
6. You would see the styled 404 at 390 and 1440 pixels in both palettes. The pull request carries the four
   captures.

### `intake-page`

1. The network gate lists two modules and passes. `grep -rl "from 'tus-js-client'" web/src` prints the upload
   module alone. Today it prints nothing.
2. The rendered harness holds a named row for each of these states, at 390 and 1440 pixels in both palettes: the
   empty start, the start with the unlisted route chosen, files picked, uploading, connection lost with "Resume",
   checking, waiting its turn, matching, matched, already in library, refused, pushed back, MusicBrainz down, a
   check or a match that could not run, stalled, cancelled, expired, and "Your uploads" with an unfinished upload.
   Each row asserts the state's heading and the controls it offers. Today the harness has no upload row.
3. A rendered row cuts the connection in the middle of a file and restores it. The server's request log shows the
   next `PATCH` starting at an offset above zero, and the bytes the server holds equal the file.
4. A rendered row reloads in the middle of an upload and picks the same files. The next `PATCH` starts at the
   server's offset, which is above zero.
5. A rendered row drives the push-back view to the unlisted route and ends at an accepted upload in "Unlisted
   music", listed in "Your uploads" under the typed names.
6. `grep -rli "private recordings" docs/research/passb-copy-final.md web/src` prints nothing. Today it prints the
   copy document.
7. Each string the uploader shows is a key in the copy deck, and each deck string equals its line in the approved
   copy document, apart from the redrafted strings the pull request lists. No gate checks either today. The
   whole-branch reviewer reads the page's files for a literal string, compares the deck with the document, and
   reports both.

### `intake-look`

1. `go test ./internal/photos` runs tests that pass, the gate has a leg that loads every photograph in `photos/`
   through the package, and `tools/photos/check.mjs` is gone. Today the package doesn't exist.
2. Each photograph is a `.webp` file beside a `.json` record. The gate fails on a photograph with no record, a
   record with no `license`, a record whose `sha256` doesn't match its file, and a credits file that differs from
   the generated one. The pull request shows it failing on each of the four, planted.
3. The coherence read's six captures are in the pull request with three readers' verdicts. A capture passes when at
   least two readers pass it, and every capture passes. One that fails is fixed and read again.
4. You sit with the page and answer the sitting's document.

## Shared assumptions

| Assumption | Probe or source |
| --- | --- |
| `engine` removes the client's budget and leaves `ClientConfig.HTTP` | Approved `engine` design, #110. At `7151edb`, `internal/engine/musicbrainz/client.go:84-141` has the field. |
| `golang.org/x/time` is a direct dependency | `go.mod` at `7151edb`, `v0.16.0`, imported by `internal/auth/limit.go` |
| Nothing installs the transliteration table outside tests | `grep -rn SetTransliterator --include=*.go . \| grep -v _test` prints nothing |
| Nothing moves a row out of `matching` | `internal/intake/worker.go`: `conclude` is the last writer, and `grep -rn "pushed-back\|match-unavailable" --include=*.go internal cmd \| grep -v _test` prints nothing |
| The proposal columns exist | `internal/engine/store/migrations/0006_intake.sql` |
| `tag.Album` returns candidates sorted, the best first, and wraps wire failures as `ErrUnavailable` | `internal/engine/tag/tag.go`, read in full |
| Quiet-import settings cap a match with a missing or unmatched track below strong | `internal/engine/matcher/tunables.go:268-279`, `MaxRec` |
| The gate decodes every frame | `internal/intake/gate/file.go:297` |
| `tus-js-client` is installed at 4.3.1 and imported nowhere | `web/package.json`; `grep -rl tus-js-client web/src` is empty |
| The flags on the command that launches a planner exist | `claude --help` on 2026-11-17 shows `--bg`, `--effort`, `--model`, `--name`. `--advisor` isn't listed and is accepted, as the `cleanup` conductor found. |

## Where an `engine` answer would change this design

- If `engine` keeps the limiter or the budget field, the pacer here would pace twice. The first task of
  `intake-match` checks that both are gone and stops if they aren't.
- `engine` rewrites the tag reader's field table. The tags-to-matcher function reads `tagio.TagSet`, so its planner
  reads that type as `engine` leaves it.
- `engine`'s gate fails on a comment that cites a pass or a ruling. Every comment this round writes follows that.
  `engine` leaves the 55 older comments of that kind in files this round touches. A task that rewrites one of
  those lines removes the citation.
- `engine`'s backlog sweep rewords items this design also judges. It hasn't landed in `master`. The first planner
  reconciles the two lists, and `engine`'s wording wins where both touch an item.

## Start line

Nothing launches until every state below holds.

1. Your approve is recorded: this design's "Rulings" section carries a `Ruled:` line with the queue id.
2. The `engine` pull request is merged.
3. No pull request is open in `dubplate`.
4. The main checkout is on `master` and level with `origin/master`.
5. No pass is running in `dubplate`. `claude agents --json` lists no conductor for it, and no planner or executor of
   a `cleanup`, `engine`, or structure pass. A design session doesn't count, whether it is drafting or waiting on
   you.
6. `claude-worktree-busy` on the main checkout exits 0.
7. Weekly usage is under the line you pick in question 12.
8. If the structure pass goes first under question 13, its pull request is merged. It goes first when you pick
   "Structure first", or when you pick the recommended answer and its design was approved before this one.

| Check | Command | Output on 2026-11-17 |
| --- | --- | --- |
| Pull requests | `gh pr list --repo glw907/dubplate --state open` | None open. The four `cleanup` pull requests merged at 06:56Z, and no `engine` pull request exists yet. |
| Sessions | `claude agents --json` | Three `dubplate` design sessions are listed: `dubplate-engine-design`, `dubplate-structure-design`, and `dubplate-catalog-architecture`. No conductor and no pass session is. |
| Usage | `claude -p "/usage" --model haiku` | `Current week (all models): 39% used · resets Nov 20, 10:59pm` |

States 1 and 2 don't hold today, and state 8 waits on your answer. Until the line holds I write prompts in the
initiative's folder and nothing in `dubplate`.

## Steps for Geoff

- `[you: answer the thirteen questions above]`
- `[you: have one FLAC album you own on the workstation for the sitting]`
- `[you: the sitting, at the end of `intake-look`]`

No pass needs a secret, a sign-in, or a dialog from you. MusicBrainz takes no key.

## Standing answers

The twelve in `round-run.md` hold. These add to them.

13. A plan's path is over twice its pass's figure. The pass parks and I send a `decide` document.
14. A pass runs past twice its figure. It finishes the task in hand, starts no new one, and I send a `decide`
    document.
15. Usage passes the line of question 12. The pass finishes its task, pushes, and waits.
16. `engine` left the limiter or the budget in place. `intake-match` stops before its first task and I send a
    `decide` document.
17. A task needs a file outside its pass's list and outside the rule under the scope table. A call site forced by
    a changed signature, or a file a gate leg fails without, is taken and listed under `## Decisions`. Anything else
    is filed and left.
18. The dependency sweep meets a major other than the two in question 11. It waits for you.
19. The tools that check Svelte files don't support TypeScript 7. The pass holds it, says so in the pull request,
    and carries on.
20. A test would need the live MusicBrainz. It is rewritten against the local server. No test calls out.
21. The structure pass merged first and a path here is gone. The planner uses the new path and notes it.
22. A redrafted string is a matter of taste. The pass picks one, marks it in the pull request, and you read it at
    the sitting.
23. The proposal needs a field `catalog` asks for before this round ends. A request that adds a field is taken
    with a new version. Anything else is filed for `catalog`.
24. CI is red for a cause outside the pass. The executor fixes the workflow in its branch and lists the fix.
25. A security read finds a blocker. The pass fixes it and the read runs again. A second blocker parks the pass.
26. Your approval carries no pick for a question. The recommended option is used.

## Rulings

Ruled: approved by Geoff on 2026-11-17 through the Approval Queue, document `20261117-075541-3e7116`, with no
notes. His picks:

1. Short block rule: "Drop the rule".
2. Sensitive upload limits: "Mark none".
3. Unknown address answer: "Same line for everyone".
4. Second rip of an album: "Refuse the second rip".
5. Wording after acceptance: "Use the wording you approved".
6. Retry while MusicBrainz is down: "Try again every hour".
7. Archive formats: "ZIP only at 0.8".
8. The two shapes: "Fix both first".
9. Round size: "One round of five passes". A report reaches him when the two server passes have merged.
10. Merge rule: "Merge four on checks and reviews". The fifth pass waits for the sitting.
11. Held majors: "Take both in the first pass".
12. Usage stop: "95 percent until the reset, 85 after".
13. Order with the structure round: "Whichever is approved first".

The structure round goes first. The queue recorded its approve at 17:17:19Z on 2026-11-17, as document
`20261117-083604-d6b622`, and recorded this design's at 17:18:28Z. On that page Geoff picked "This round first",
which gives the same order. State 8 of the start line waits for the three structure pull requests to merge.
Standing answer 21 then applies to every pass, and each planner reads a file where that round left it.

Amended by Geoff on 2026-11-20, in his terminal session, where a session asked the questions again without knowing
they were answered. Ten of his answers matched. Three changed:

- Question 3: "Generic, hint". The default becomes `generic` as before, and the line's copy also asks the person to
  check the address they typed.
- Question 7: "Add `.tar.gz`", after he said "I'd assume that there were good .zip and .tar.gz libaries that we
  could use". `intake-ground` grows by 150 minutes to 760, the round to 2,760, and its ceiling to 5,520. `.7z`
  stays out, because Go's standard library can't read it.
- Question 11: TypeScript 7 and `@types/node` 26 move to the structure round's dependency sweep. He asked why one
  SvelteKit app would take the upgrade in a later round, and said "Move it to structure".

## Backlog verdicts

One read-only reader swept the backlog at `7151edb`: the ten items tagged for this round and every item naming a
file a pass changes. Approving the design approves these edits, which the first planner lands. A verdict marked
"unchecked" came back without the code being opened, and the pass's planner checks it before acting.

<details>
<summary>Verdicts, item by item</summary>

| Item | Verdict | Pass and minutes | Reason |
| --- | --- | --- | --- |
| #8 `tus-js-client` 5.0 | fold | `intake-page`, 10 | The wrapper task is where the version is decided. |
| #14 Node version in `engines` | fold | `intake-ground`, 5 | The dependency sweep edits that file. |
| #15 forwarded-header warning | keep | | No pass rewrites those lines. |
| #18, #20 members page assertions | fold | `intake-shell`, 25 | The page moves onto the save module and gains rows. |
| #36 `srcset` in the root-path gate | fold | `intake-look`, 15 | The photo column adds the first `srcset`. |
| #56 `id3-tags` copy | duplicate | of #83 | The code half landed. The copy half is #83's. |
| #57 carried web items | fold | `intake-shell`, 95, for the 404, onward link, Continue link, mark target, and masked address line. `intake-look`, 180, for the rest. | Three parts are unchecked: the four items under its fifth ruling, the placeholder opacity, and the phone gutter. |
| #58 picked images | reword | | Its sources are misnamed. The input shadow goes to the sitting, the stable photo paths to the loader. |
| #61 TypeScript 7 | duplicate | of #130 | |
| #64 photo check failures | fold | `intake-look`, 20 | The Go port replaces the failing script. |
| #72 `--size-field` in two themes | fold | `intake-look`, 10 | The pass edits the theme files. |
| #73 comment typo | fold | `intake-shell`, 5 | Now at `internal/serve/serve.go:63-64`. |
| #79 to #82 admin page suggestions | keep | | The pages move unchanged. These change what an admin sees. |
| #83 copy wording | fold | `intake-page`, 60 | Includes the two reject strings, so all wording reaches the sitting together. |
| #84 planner carries | fold | `intake-match`, 120, and `intake-page`, 45 | Every sub-item still holds. Each is part of a task the pass already has. |
| #85 visual identity carries | reword | | Library items stay for `library`. The phone header, alerts, and motion go to `intake-look`. |
| #86 spec hooks | reword | | The hook half is done. The buy-link half stays for `catalog`. |
| #87 upload hardening | reword | `intake-ground`, 75: the ZIP directory cap, the staging path in a 500, the unbounded note, manifest work under the write lock, concurrent creates. `intake-match`, 45: the commit backstop and the rate limit. | The reader found two sub-items already fixed, and the planner strikes them. The authorize race is unchecked. |
| #88 upload cleanups | reword | `intake-ground`, 60 | Two sub-items duplicate #142 and #144. The event-reason one is unchecked. |
| #92 three rulings | fold | `intake-ground`, 60 | Questions 1 to 3. |
| #120 last web cleanup's leftovers | fold | `intake-shell`, inside the frame's 150 | The frame takes the scaffolding. Its round tag moves from `launch`. |
| #121 ops leftovers | fold | `intake-ground`, 80 | The same files as the adapter move, under question 8. |
| #123 auth cleanup | reword | `intake-shell`, 25, for the doubled request check | The rest stays. |
| #124 `unidecode` and doctor probes | keep | | Larger than the lines a pass touches. |
| #126 review findings I1 to I3 | fold | `intake-ground`, 90 | All three hold. |
| #130, #131 held majors | fold or keep | `intake-ground` | By question 11. |
| #150 to #153 rendered-row gaps | fold | `intake-shell`, 65 | Unchecked in detail. |
| #155 page state and accessibility | fold | `intake-shell`, 45 | The save module and frame absorb it, with the ruling under "The browser". |
| #136 to #140, #142 to #144, #147, #149, #154, #156 to #158 | keep | | None sits in lines a pass rewrites. |

</details>

A full sweep of the backlog is due: 99 of 122 open items carry no sweep stamp. It doesn't ride this design, and it
goes to you as a separate triage list.

## Estimate

The round is 2,610 path minutes, built from the parts below. A backlog item's figure is the one in "Backlog
verdicts".

| Pass | Minutes | Made of |
| --- | --- | --- |
| `intake-ground` | 610 | The dependency sweep 60. The adapter move with #121, 260. #126, 90. #88, 60. #87's part, 75. #92, 60. #14, 5. |
| `intake-match` | 480 | The pacer, the client, and the table check 80. The tags function 50. The states and the stored proposal 80. The worker 110. The stall rule, the startup rule, the hourly retry, and the cap 80. The wire changes 80. #84's 120 and #87's 45 are inside these. |
| `intake-shell` | 500 | The save module and the frame with #120, 150. #18 and #20, 25. #73, 5. #123, 25. #150 to #153, 65. #155, 45. The network module and its gate 60. The sign-in redirect 30. The 404 handler and its page 95. |
| `intake-page` | 540 | The upload module with #8, 70. The page's states and "Your uploads" 200. Resume and reload 80. The unlisted route 50. The copy with #83, 60. The rendered rows 80. #84's 45 is inside these. |
| `intake-look` | 480 | #57's rest, 180. The photos package with #64, 110. #36, 15. #72, 10. #85's part, 45. The coherence read 60. The sitting 60. |

Two outside figures check the size. The upload core in October was planned at 725 minutes and took 570. The intake
spec sized this round's two halves at 0.76 and 0.83 of that pass, about 1,150 together, and `intake-match` with
`intake-page` comes to 1,020. Recent passes took 0.4 to 1.6 times their figures, so the round lands between 1,050
and 4,200 minutes. I can't turn path minutes into a share of the weekly allowance, and the usage stop is the guard.

## Practice and sources

- The intake spec, `docs/specs/2026-10-10-rung-7-intake-design.md`, and the approved copy,
  `docs/research/passb-copy-final.md`.
- The architecture survey of 2026-11-17 and the `cleanup` and `engine` round designs.
- MusicBrainz API rate limiting, <https://musicbrainz.org/doc/MusicBrainz_API/Rate_Limiting>: one request a second
  and a user agent that names the application and a contact.
- `golang.org/x/time/rate`, <https://pkg.go.dev/golang.org/x/time/rate>.
- The `tus` resumable upload protocol 1.0, <https://tus.io/protocols/resumable-upload>, and `tus-js-client` 4.3.1.
- The visual identity spec and the web surface standard, sections W6, W7, W8, and W11.
- `pass-core` `references/round.md`, `planner.md`, `ready.md`, and `advisor.md`.

## Later

- The full backlog sweep.
- Archive formats beyond ZIP and `.tar.gz`, `.7z` among them, under question 7.
- A setting for a MusicBrainz mirror.
- Loudness measured during the gate's decode, for the catalog architecture.
- A second MusicBrainz caller and the pacer's timeout, for `catalog`.
- A unique index on collection and release id in `albums`, for `catalog`.
- The operations spec's sentence about what `ops` imports.
- `tus-js-client` 5.0.
- A check of the uploader on a real iPad, filed for `launch`.
