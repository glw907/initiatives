---
kind: design
approve: The design is recorded as the basis for the `catalog` round and the rounds after it.
sendback: I answer each note and return the revised design.
---

# Approve the architecture under `dubplate`'s `catalog` round and the rounds after it?

This design settles how an accepted upload becomes an album in the library, and what the `playback`, `queue`,
`library`, and `launch` rounds may rely on once it has. Every album enters by one path, inside the running
server. The command that brings in music already on disk hands its albums to that same path. The catalog's rows
are the one record every later round reads, and nothing keeps a second copy of them. It plans no pass, and
nothing starts when you approve. Five questions are yours, and each has a recommendation.

The page uses these words throughout.

| Word | What it means here |
| --- | --- |
| A member | One person in the group that shares a library |
| The gate | The check every uploaded file passes: a real FLAC file that decodes cleanly |
| The probe | The lookup that finds which MusicBrainz release an album is |
| Accepted | The state of an upload that passed the gate and has a release chosen for it |
| Admission | The work that turns an accepted upload into an album in the library. It writes the tags, places the files, and writes the catalog's rows |
| The catalog | The tables that say what the library holds: collections, albums, tracks, and artists |
| Folder-admit | The command that brings in music already on disk |
| A rip | One set of audio files made from a release. Two rips of one CD can differ in their audio |

**1. What does a member see when they upload a different rip of an album the library already holds?** The
upload names a release the collection already has, and its audio differs. The spec and the code disagree. The
streamer design replaces the tracks. The intake code refuses only identical audio and lets a different rip
through, which would leave the album in the library twice. Your ruling of 2026-09-02 made refusal the default
wherever a decision would otherwise wait for a person: "strict refusal default, owner-queue and
contributor-picks as settings". I recommend the same here.

:::question A different rip of an album already held
- **Refuse it and say why** {recommended}. The member reads "This album is already in the library" and the upload ends. The album in the library doesn't change. An admin's choice to replace an album with a better rip arrives with the `queue` round, which builds the decision queue.
- **Replace the album's tracks.** The member sees the upload accepted. Everyone's copy of the album changes, and stars and playlists carry over. Nobody is asked, so a worse rip can replace a better one.
- **Keep both.** The member sees the upload accepted, and everyone sees the album twice in the library.
:::

**2. What does folder-admit do with an album it cannot match with confidence?** The `cleanup` design you
approved says an album that fails the gate "is reported and left out". This question is about an album
that passes the gate but whose release the probe cannot name with confidence. No member sits at a page to pick
a candidate during a folder-admit run. The taggers beets and Picard write the release into each file's tags,
so a collection tagged by either should have few such albums.

:::question Folder-admit and an album with no confident match
- **Leave it out and list it with its candidates** {recommended}. The admin reads one line for each such album in the command's report, with the closest releases. The admin runs the command again on that album's folder and names the release. Until then the album is absent from the library and untouched on disk.
- **Admit it as unlisted music.** The album appears in the "Unlisted music" collection under the tags it arrived with. It has no MusicBrainz identity, and 0.8 has no way to give it one later.
- **Admit it under the closest release.** Nothing is left out. An album can land under the wrong release's titles with nobody told.
:::

**3. Does every album enter the library through the running server?** Your ruling of 2026-09-02 expected
bulk imports to run beside the server in a separate process: "Rung 9's concurrency model is a per-album lease
... Not an explicit queue." A lease is a lock that one process holds on one album while it works on it. I
recommend one admission path instead. The server admits one upload at a time and is the only program that
calls MusicBrainz. The folder-admit command hands the server a few albums at a time as ordinary uploads,
waits, and reports. The recommendation keeps what the ruling protects. A member's upload never waits behind a
bulk run, and no queue position reaches a client. An admin who starts a second folder-admit run while one is
going is told that one is already running. A member sees the same thing under either answer, and each option says what changes for an admin.

:::question Where albums are admitted
- **Only in the running server** {recommended}. The admin starts folder-admit with the server running, and the command says so if it isn't. Closing the terminal stops the command and leaves the albums already handed over to finish. One program writes the library and paces every MusicBrainz request.
- **In the command's process too, as the ruling says.** Folder-admit works with the server stopped. Two programs can then write the library at once, each album needs a lease, and the two must share MusicBrainz's request limit across processes.
:::

**4. Do the library's filter, facet, and search queries leave the `catalog` round?** The approved round plan
gives `catalog` "the catalog's library queries: filter, facets, and trigram search" (backlog item #60). No page
or music app in `catalog` calls them. I recommend that each query is built by the round that first calls it.
Search goes to `playback`, whose music-app search needs it. Filter and facets go to `library`, which shows them.
A member sees the same product at the end of each round under either answer. The choice is when the queries
are written and what they're tested against. It changes what an approved round contains, so it is yours.

:::question The library queries
- **Move them** {recommended}. The `catalog` round ends with albums in the library and no way to browse them yet. `playback` and `library` each build the queries their screens need, and test them against what a person sees.
- **Keep them in `catalog`.** The queries are written a round or two before anything shows their results, and they're tested only against fixtures.
:::

**5. Is the `Navidrome` import built for 0.8?** Your ruling of 2026-10-05 keeps it: "`dubplate import navidrome`
stays in 0.8. It serves a stranger switching from `Navidrome`. The group's first launch runs it once ... so
members keep their stars, playlists, and play counts." On 2026-11-16 you told the desk: "`Dubplate` isn't
currently used. You can delete any information there." The desk recorded that ruling as covering the stars and
playlists `Navidrome` left on your server, so they may be deleted. If they go, the first launch has no stars to
carry over, and the import's one remaining user is a person who switches from `Navidrome` later. I recommend
leaving the import until that person exists. The recommendation departs from the 2026-10-05 ruling, which is
why this is a question. Leaving it until later makes the `queue` and `launch` rounds smaller. No other part of
this design depends on the answer.

:::question The `Navidrome` import
- **Leave it until after 0.8** {recommended}. Your server starts with its music and with no stars or playlists from `Navidrome`. A person who moves from `Navidrome` to 0.8 brings their music in with folder-admit and starts their stars and playlists fresh. The import can still be built later. Under either answer the catalog keeps the path each folder-admitted file had in the folder it came from, and that path is what an import matches a `Navidrome` track against.
- **Build it for 0.8, as ruled.** `queue` builds the import, and `launch` runs it once on your server as its proof. A person switching from `Navidrome` keeps their stars, playlists, and play counts, and each track the import cannot match is reported by name.
:::

:::decide

Initiative: `dubplate-server`. Repo: `glw907/dubplate` (`dubplate`, default branch `master`). Written on the
night of 2026-11-16 and filed under the UTC date, 2026-11-17. I read the `cleanup-ops` branch at commit
`c42bb858`. The four `cleanup` pull requests have since merged, and `master` at `49c5596b` differs from that
commit only in four lines of `docs/STATUS.md`. This is a standalone design. It has no round id and no pass
table, and approving it starts no session.

## Brief

An upload ends today at `accepted`, and no code takes it further. The `catalog` round builds what comes next:
admission, the catalog, and folder-admit. `playback` then reads the catalog to serve music apps. `queue` adds
each member's stars and playlists, with the decision queue. `library` shows the albums on a page, and `launch`
brings in the 6.6 GB of music on your server and opens the doors.

Five subjects cross those rounds, and a round's designer who met one alone would settle it for one round and
leave the next to undo it. This design answers each once. A survey of the code filed on 2026-11-17 named them,
and it read no file and ran nothing. I checked each finding against the code and the specs, and "Where this
design differs from the survey" lists what I found.

## Why now

The `catalog` round's design comes next after `intake`. Three of its decisions are expensive to change once
music is in the library. The first is which facts are measured while each file is read. Folder-admit reads
every file once, and a fact it misses costs a second pass over the whole library. The second is where ids
live, because a member's stars and playlists point at them. The third is the order of steps between moving
files and writing rows, which decides what a crash can leave behind.

## Decided by Geoff already

- The beets migrator goes: "yes, use the folder-admit command". An album that fails the gate "is reported and
  left out" (the `cleanup` round design, 2026-11-15).
- Refusal is the default where a decision would wait for a person: "strict refusal default, owner-queue and
  contributor-picks as settings, the classical-appeal action rides every setting" (ruling 9, 2026-09-02).
- Nothing stored on your server has to be kept until the first launch: "`Dubplate` isn't currently used. You
  can delete any information there." The desk recorded this on 2026-11-16 as covering the database, what
  `Navidrome` left, and the music files. This design therefore converts no old row and keeps no old folder
  layout.
- Where a design chooses between the correct form now and a stopgap, it takes the correct form: "We're
  looking for the straightest line to correct."
- The first launch is 0.8.0 on the built-in streamer, and 0.8 takes FLAC only (2026-10-05).
- A rejected upload is final. Separate tracks land as unlisted music with no MusicBrainz match.
- The code bar, in your words this week: "clean, well-designed code" that stays easy to keep up over the long
  term, with "any over-engineering or duplication removed".

## Goals

- One path admits an upload, whether it arrived from a member or from a folder on disk.
- A crash or a failed write at any moment leaves the library and the catalog agreeing, or leaves a record that
  makes them agree on the next attempt.
- Folder-admit's one pass over the library measures everything that a later round would otherwise need to
  read the files again for.
- An id that a member's star or a music app holds never changes and is never minted twice.
- Each table has one package that writes it.

## Non-goals

- This design plans no pass, names no column, and writes no schema. Each round's design does that.
- It doesn't design the uploader page, the probe, or the decision queue.
- It doesn't move today's tables or rename the store package. A separate structure pass does both, and that
  pass takes the ownership rule below as given.

## Anti-goals

- A second way into the library that skips the gate or the probe.
- A track row that names a file that is absent.
- A table that copies another table and can drift from it.
- A package, interface, or table built before the round that first uses it.

The sections from here to "Who owns a table" are method and architecture calls, which are mine. Each gives its
reason. You can skip them and lose nothing you need for the five questions. Six of the calls are worth a look
on your way past.

| My call | The reason |
| --- | --- |
| Folder-admit records the member the admin names on the command as the one who added each album | Every album then has a member behind it, and no page or quota rule has to handle an album added by nobody. The streamer design says "no client field writes it". That sentence gives way for this one command, which only an admin on the server can run |
| Folder-admit copies files, and never links or moves them | The folder it reads is never changed, whoever runs the command and whatever goes wrong |
| An upload is admitted whole, with one rename | An interrupted admission leaves one thing to finish |
| Loudness is measured inside the gate | The gate already decodes every frame. The edit lands under `internal/intake`, so its pull request waits for your read |
| The catalog is one layer of tables, with no second set derived from it | Nothing can drift, and nothing needs a rebuild |
| The move journal table gets a new shape, and nothing converts the old one | The table has never held a row, and your ruling of 2026-11-16 frees it in any case |

## How an album is admitted

### One path, in the server

Admission runs inside `serve`, the long-running server process, in the worker that already runs the gate. An
uploaded album and a folder-admitted album are both submissions, the row an upload already has. They pass the
same gate and the same probe, and one function admits them. The server admits one submission at a time. It
takes members' uploads ahead of a folder-admit run's albums, at the gate as well as at admission.

The reason is that every alternative builds a second path. A separate importing process would need a lease
per album, a share of the MusicBrainz budget, and a second answer to a crash. The intake spec
already saw the cost: "If rung 9's import runs in a process other than `serve`, its limiter will not share the
probe's wire budget."

### States after accepted

A submission today is in one of eight states: `uploading`, `checking`, `check-unfinished`, `matching`,
`accepted`, `rejected`, `cancelled`, or `expired`. This design adds one, `admitted`, which is final.

`accepted` comes to mean that the upload passed every check and waits its turn. From there it goes to
`admitted`, or to `rejected` when admission finds the album already present or finds that the staged files
changed after the gate read them. A failure that says nothing about the album, such as a full disk, leaves it
`accepted` with the failure recorded, and the worker tries again on its next sweep.

I add no state between the two. The move journal described below already marks an upload whose files are
moving, and a state that said the same thing would be a second record that could disagree with the first.

### The steps

1. **Build.** Admission builds the directory for the upload in a build area inside staging, apart from the directory
   that holds the uploaded files. It writes each track with the chosen release's tags and writes `cover.jpg`.
   It stores the cover image under the image's hash, so storing one image twice changes nothing. While it
   copies a file it hashes the staged original again. A hash that differs from the gate's ends the upload as
   `rejected`. It hashes each file it writes, then syncs each file and the build directory to disk. No store
   lock is held during the build.
2. **Record the plan.** Admission creates the final directory's parent directories and syncs them. One short
   transaction then writes a move-journal entry, from the build directory to the final directory in the
   collection. It also records each built file's hash, size, and final path beside the submission's file rows.
3. **Admit.** One transaction marks the submission `admitted`, inserts the album and track rows, charges the
   member's quota, releases the reservation, and closes the journal entry. Its last act before it commits is
   to rename the build directory into the library and sync the two parent directories.

If a unique index refuses the album in step 3, nothing has moved. The transaction rolls back. A second
transaction ends the submission `rejected` as already in the library and closes the journal entry, and the
build directory is deleted.

The worker looks for an open journal entry before every attempt, at each sweep as well as when the server
starts. It finishes that entry before it admits anything else.

### What an interrupted admission leaves

| Admission stops | What the next attempt finds | What it does |
| --- | --- | --- |
| During the build | The upload `accepted`, part of a build directory, no journal entry | Deletes the build directory and builds again |
| After the plan is recorded | The upload `accepted`, an open journal entry, the build directory whole, no final directory | Runs step 3 |
| After the rename, before the commit lands | The upload `accepted`, an open journal entry, the final directory present, no build directory | Checks that each recorded file is there at its recorded size, then runs step 3 without the rename, writing the rows from the store's record |
| After the commit | The upload `admitted`, the entry closed | Removes the uploaded originals if they are still in staging |

The third row covers more than a crash. A commit can fail with the server still running, when the disk under
the store fills or the transaction's deadline passes during the syncs. The files have then moved and no row
was written. The open entry tells the next sweep to finish the upload, so it never waits for a restart.

Three facts hold at every moment. No track row names a file that is absent, because the rows commit only
after the rename is on disk. Files sit in the library without rows for one upload at most, the one whose
journal entry is open. The worker finishes that upload before it admits another.

Restoring the store from a snapshot is outside these facts, because a restored store can be older or newer
than the files beside it. The restore command already prints a report of rows without files and files without
rows, and that report stays the net. "How it fails" says what an admin does with it.

### Why the rename sits inside the transaction

The store spec sets a rule for this work: "no write transaction spans a MusicBrainz lookup or a file copy".
This design keeps it. Every copy happens in the build, with no lock held. The rename of one directory is a
single filesystem operation, and placing it last inside the transaction closes a gap the other order leaves
open. If the rows came after a rename done outside the transaction, another write could take the album's
identity in between, and admission would hold moved files that it could no longer record. With the rename
inside, the unique indexes decide while the write lock is held, and a refused album has moved nothing.

The store's `Update` function runs its callback once and never retries it, so the rename is attempted once.
The cost is that the write lock is held for one rename and two directory syncs. The `catalog` round measures
that on your server's volume.

### One upload, one rename

Admission moves one upload with one rename. An album's upload becomes the album's directory, which no other
album shares, so the album arrives whole or doesn't arrive. An upload of separate tracks becomes one directory
too, and "Separate tracks" below describes its rows.

The rename is the Linux call that refuses an existing target, `renameat2` with `RENAME_NOREPLACE`. The
ordinary rename replaces an empty directory without saying so. If the final directory exists, nothing is
replaced, and the upload stays `accepted` with the failure recorded.

Staging and the library have to sit on one device for the rename. The `serve` unit already grants both under
one volume directory for this reason, and nothing checks it at start today. The `catalog` round adds that
check.

### The move journal

The store has had a move-journal table since the store round, with the replay rule "source absent and target
present means done". Nothing reads or writes it today, and it has never held a row. Admission is its first
user, and the table as written cannot hold this move. Its two paths are relative to one root, while admission
moves from staging to the library. It has no column for the submission. Its states are `pending` and `done`,
with none for a plan that ended in a refusal.

The `catalog` round gives the table the shape admission needs: an entry names its submission, and each path
names the root it is relative to. No step converts the old shape. A build directory with no open entry is
debris, and intake's cleanup sweep removes it.

### What counts as the same album

The `albums` table gains two unique indexes, each within one collection.

The first is on the release. A collection holds one album for a MusicBrainz release, and albums with no
release, the unlisted ones, are exempt. If you choose "Keep both" in question 1, this index is left out.

The second is on the audio. A collection holds one album for a given set of audio. The gate already computes
this as the album key, a hash over the track count and each track's audio in order. Identical audio is one
album whatever title was typed. Two unlisted albums that share a typed title and differ in their audio are two
albums, because nothing else identifies them.

A track's audio key gets a plain index and never a unique one, because one recording can sit on two releases.

The duplicate check reads in two places, each from the package that holds the truth. What the library holds is
read from `albums`, through a function in the catalog package. What is on its way is read from intake's
submissions that are `accepted`. A member hears as early as each fact exists. The audio is checked when the
gate passes the upload. The release is checked when a release is chosen for it, at the probe. The unique
indexes decide both again at admission.

The check reads only the collection the upload is going to, and a member can upload only to a collection they
can see. That answers the first half of backlog item #91, which found that "already in the library" could tell
an uploader about an album in a private collection.

### Separate tracks

One upload of separate tracks can hold many tracks. The gate accepts it while one track passes, and it has no
album key. Admission still treats it as one upload, with one build directory, one journal entry, one rename,
and one transaction. That transaction inserts an album of one track for each track that passed. The schema
already requires every track to have an album, and a music app expects every song to have one. The catalog
then has one shape, and no code asks whether a track stands alone.

Duplicates among separate tracks follow the rule the intake code has today. A track is refused as already in
the library when its audio equals any track in the collection, and the other tracks in the upload go on. The admit
transaction makes that read through the plain index on the audio key while it holds the write lock. An upload
left with no track ends `rejected`.

## What is computed at admission

Folder-admit reads every file in the library once. The table lists each fact that is cheapest, or only
possible, at that moment. The last column says what a miss would cost later. "Hook" numbers are the streamer
design's forward hooks, its list of facts an earlier round must record for a later one.

| Fact on the row | Computed from | Asked for by | First read by | Cost of a miss |
| --- | --- | --- | --- | --- |
| Audio key of each track | The decoded audio, at the gate | Hook 1 | `catalog`, for duplicates | Decoding every file again |
| Album key | The tracks' audio keys, at the gate | Hook 1 | `catalog`, for duplicates | Decoding every file again |
| Length, sample rate, bit depth, channels | The FLAC header, at the gate | The streamer design's song fields | `playback` | Reading every file again |
| Track loudness and true peak | The decoded audio, at the gate | Hook 11 | `playback` | Decoding every file again |
| Album loudness and true peak | All the album's audio, at the gate | Hook 11 | `playback` | Decoding every file again |
| Hash and size of the file as admitted | The tagged file as written | Hook 1 | `playback`, for its cache of converted audio | Reading every file again |
| Path within the collection | The layout and the tags | Hook 12 | `playback` | Moving every file again |
| Release, release group, recording, and track ids | The chosen release | The streamer design's alternate keys | `catalog` | One MusicBrainz request for each album |
| Titles, artist credits, dates, disc and track numbers | The chosen release, or the typed fields for unlisted music | The streamer design's catalog row | `playback` | One MusicBrainz request for each album |
| Artist sort names, and folded sort keys for artist, album, and title | The chosen release | Hooks 2 and 13 | `playback`, for its index and search | One MusicBrainz request for each album |
| Sort tags and gain tags inside the file | Written while tagging | Hook 13 | Any player that reads the files | Tagging every file again |
| Genre | The uploaded file's tag | The streamer design's genre list | `playback` | Reading every file again |
| Cover image, its hash, and `cover.jpg` | The picture uploaded or embedded | Hooks 3 and 12 | `playback` | Reading every file again |
| Added by | The submission's uploader | Hook 17 | `library` | Nothing can recover it |
| Source answer and store link | The submission and the chosen release | Hook 21 and backlog item #86 | `library` | Nothing can recover the answer |
| When it was admitted | The clock at admission | Hook 4 | `playback`, for newest albums | Nothing can recover it |
| Where each folder-admitted file came from | The run's source folder and the file's path in it | The folder-admit report | `catalog`, for the report, and the `Navidrome` import when it is built | Nothing can recover it |

The `catalog` round's design names the columns and holds this table as one list in the code. A test admits
fixture albums of each kind and fails on a fact that is missing or wrong.

### Gain

Loudness is measured at the gate, in the pass that already decodes every frame of every file to compute the
audio key. That needs no second decoder, no `ffmpeg`, and no work a round early. Album loudness comes from the
same pass, pooled over the album's tracks while the gate holds them together.

The store keeps each track's and each album's measured loudness and true peak. ReplayGain and the R128 fields
that Opus uses are that loudness subtracted from a fixed reference level, so they're worked out when asked for
and never stored a second time. Admission also writes the ReplayGain tags into each file, because it writes the
file's tags once and a file copied off the server should play at the right level anywhere.

I measured this before relying on it. A throwaway pure-Go meter over the decoder `dubplate` already uses matched
`ffmpeg` within 0.1 loudness units and 0.2 dB of true peak on three test files. It ran at 88 times real time
for CD audio. "Shared assumptions" has the numbers.

The gate lives under `internal/intake`, where any edit needs your read. The `catalog` round builds the meter,
and its pull request waits for you on that account.

## How the catalog is read

The streamer design describes two layers: a catalog with one row per track, and a "projector" that derives the
artist, album, song, genre, and folder tables from it and can rebuild them. This design keeps one layer.

The album and track tables are the albums and songs a music app sees. Artists are rows too, written at
admission from the release's credits. A genre is a name with a count, read by a query. A music folder is a
collection. Nothing is copied into a second set of tables, so nothing can drift, and no rebuild is needed for
any of it.

What stays derived is small: the search index, and any count worth caching. A derived table mints no id. It
refers to catalog rows, and a rebuild reads the rows as they stand.

The reason is the bar. The second layer exists in the spec so that the shape a music app wants can differ
from the shape the pipeline writes. With albums, tracks, and artists as tables, the two shapes are the same.

### Where ids live

Every id that a music app or a member's row can hold is minted once and stored on a row that no rebuild
touches: the album, the track, the artist, and the collection's number on the wire. A rebuild of the search
index therefore mints nothing, and it leaves every id as it was.

The streamer design asks that "a full rebuild produces byte-identical tables". For the search index, the
`playback` round tests that as identical answers to the same searches before and after a rebuild. The index's
stored bytes depend on the order of past writes, so comparing bytes would fail on a correct index.

### The seam for derived tables

Every change to the catalog goes through one function in the catalog package for each kind of change, and each
takes the caller's transaction. Admission is the first. When `playback` adds the search index, it adds the
index update inside those functions, and the update commits with the change or not at all.

The catalog package defines no projector interface, no list of subscribers, and no event table. Go practice
here is "don't define an interface until a second consumer exists", and `dubplate`'s rule is that "a hook is
built by its first consumer". The submission's event log already records each admission with its time and
actor. The first round that needs a history of catalog changes adds the table at the same single point.

### Reads

Queries on catalog tables live in the catalog package. Each is added by the round whose page or endpoint first
calls it, which is what question 4 asks you to confirm. Every query takes the viewer and applies collection
visibility in its SQL, so no caller can forget to.

## Where long work runs

Only `serve` admits albums, and only `serve` calls MusicBrainz.

Folder-admit is a command an admin runs on the server under the service's account, the way the runbook already
runs the backup command. The admin names the collection and the member who is recorded as adding the albums.
The command walks the folder and hands the server a few albums at a time. For each album it copies the files
into the staging area and writes one submission at the state `checking`. The server's worker picks those up as
it picks up an upload whose files have all arrived. When an album finishes, the command prints what happened
to it and stages the next. It ends with a report, and it never changes the folder it reads.

The command copies and never links. A hard link would share each file's bytes with the folder being read, and
the promise about that folder would then rest on nothing ever writing to a staged file. A copy keeps the
promise whatever happens. The cost is bounded, because staging holds only a few of the run's albums at any
moment. The `catalog` design sets that number.

The worker takes a member's upload ahead of a run's albums at the gate and at admission. Its queue today is
oldest first, and the `catalog` round changes that order. A member who uploads during a run waits for the
album in hand and no longer. The probe's order belongs to the intake design, and the assumptions table says
what I expect of it.

A run's albums pass the same limits as any upload. Each holds a reservation while it is staged, and the
group's quota and the free-space floor apply to it. An album that one of them refuses is reported and left out.

The command and the server share the store, as the backup command and the server already do. The rows are the
hand-over, so the command needs no sign-in and no new connection to the server. A later admin page can call
the same function.

- The command refuses to start when no server is running, and says to start it.
- It refuses a folder that sits inside the library or the staging area, and a folder the service's account
  cannot read.
- A run is a job of a new kind, beside the backup job. One run exists at a time, and a second answers that one
  is running and names it.
- If the command stops, the albums it already handed over finish. A second run on the same folder reports each
  of those as already present and admits nothing twice.

## The first launch

The only written launch sequence predates folder-admit. This is the order the `launch` round runs. Under your
ruling of 2026-11-16 the store can start empty, and the `launch` design may create it fresh.

1. Deploy the release and prove a backup.
2. If the old music tree sits inside the configured library folder, rename it aside. The library folder then
   holds collection directories only.
3. Start the server.
4. Check that the volume has free space the size of the old tree, then run folder-admit on it, into the main
   collection.
5. Read the report. Fix or accept each album left out, and run the command again for the ones fixed.
6. Run the `Navidrome` import, if question 5 keeps it.
7. Listen through a music app.
8. Delete the old tree. The `launch` design names this deletion in plain words, and your approval of that
   design covers it.

The old sequence had a third step, a re-layout of the whole library. It is gone, because admission places each
album by the collection's layout as it arrives.

If the import is built, it follows folder-admit. It matches a `Navidrome` track by its release and position
first. Where that fails, it looks up the path `Navidrome` recorded in the store's record of where each
folder-admitted file came from, and takes the audio key from the track row. It opens no music file. It needs
the per-member tables that `queue` builds, so the round that builds it comes no earlier than `queue`.

## Who owns a table

1. Every table has one owning package, named in one list.
2. Only the owning package contains a statement that writes the table.
3. Another package changes the table by calling the owner's function. When the change has to commit with the
   caller's work, that function takes the caller's transaction.
4. Another package reads the table through the owner's query functions. A foreign key may point at another
   owner's id. A query that joins two owners' tables lives in one of them and is named in the list.
5. The schema files stay together in the store package, as one ordered history of one database file. Ownership
   is about the statements in Go code.

One test holds the list and fails when a statement outside the owner writes a table.

The new package `internal/catalog` owns `collections`, `albums`, `tracks`, the artist tables, the move journal,
and later the search index. Intake owns the submission tables and the admission worker, because the worker
drives the submission's states. The admit transaction crosses both through their functions.

Three things are other work. Moving today's tables to their owners and renaming the store package from
`internal/engine/store` to `internal/store` belong to the structure pass. Intake writes `collections` today
when it creates the two route collections, and that write moves to the catalog package with the rest. The
backup package reads `tracks` and `collections` directly for its restore report, and those reads become
catalog queries.

One finding for the `catalog` design: once each track row has its size and each album its adder, a member's
charged bytes equal a sum over catalog rows. The design should decide whether the stored counter stays.

## What this design assumes of the intake design

A session is drafting the `intake` round's design. It decides three things this design depends on. Its draft
had not appeared in the specs folder or the queue when this page was sent, so I state what I assume and what
admission does if the assumption is wrong. Its designer and you should read these against that draft.

| Theirs to decide | What this design assumes | If it is otherwise |
| --- | --- | --- |
| The fields of the stored proposal | It names one release and when it was evaluated. It keeps enough of the release to write every tag and fill the admission table with no further request: ids, titles, credits with sort names, dates, positions, and store links | Admission fetches that one release by id, inside `serve`, through the same paced client |
| What `accepted` promises | Every file passed the gate and has its facts on its row. The staged files are complete and on the library's device. The reservation is held. A release is chosen, or the typed fields stand in for unlisted music. The uploader and the source answer are recorded | Admission checks whatever is not promised, and it checks duplicates in any case |
| How MusicBrainz calls are paced | One pacer inside `serve` that every request passes, with a member's upload able to go ahead of a bulk run's albums | A long folder-admit run delays members' uploads at the probe until the pacer can rank them |

Two smaller assumptions ride with these. The probe uses a release id already in a file's tags, which is how a
folder organized by beets gets a confident match. The gate can carry the loudness meter, which "Gain" explains.

## Sentences this design replaces

| Where | What it says | What becomes of it |
| --- | --- | --- |
| Streamer design, lines 463 to 464 | "A re-rip of the same release into the same collection is the same album with replaced tracks, not a second album." | Question 1 decides it. Under the recommendation, the re-rip is refused |
| Configuration design, line 651 | A different rip "is never refused or replaced automatically" | It stands for what it describes, the report shown when a laptop's library is attached to a server in 0.9. It never governed an upload |
| Streamer design, lines 449 to 452 | "A projector derives the OpenSubsonic entities" into separate tables, and each catalog event "applies its delta in the transaction that commits the event" | The catalog's tables are those entities. A derived table is updated inside the function that makes the change |
| Streamer design, lines 461 to 463 | An album with no release is identified by collection, folded artist, folded title, and its set of content hashes | The album key within a collection replaces that tuple |
| Streamer design, line 483 | "folder ids are minted rows in the projection" | A minted id never lives in a table that a rebuild drops |
| Streamer design, line 500 | The search index is one "the projector maintains" | The catalog package's write functions maintain it, and `playback` builds it |
| Streamer design, hook 17 | The server sets the adder "from the authenticated principal", and "no client field writes it" | It holds for every upload. Folder-admit records the member its admin names |
| Re-plan design, line 165, and the build spec, line 1031 | "The import precedes the re-layout" | The import, if built, follows folder-admit, and no re-layout exists |
| Store spec, line 547 | "Rung 16's relocation is a named consumer" of the move journal | Admission is its first user, and the `catalog` round reshapes the table for it |
| Store spec, lines 148 to 150 | "library mutations continue during a backup's sync unless rung 9's lease pauses them" | No lease exists to pause them. Admission continues during a backup, and the restore report stays the net |
| Ruling 10 of 2026-09-02 | A lease for each album | Question 3 decides it |
| Intake spec, line 508 | It "leaves ruling 10's per-album lease to rung 9" | Under the recommendation no such lease is built |
| Admin API design, line 113 | The "import job then adds a job kind" | The kind is folder-admit's |

## Where this design differs from the survey

- The survey reads three specs as disagreeing about a different rip. The configuration design's sentence is
  about the laptop report, so one spec and the code disagree.
- It does not mention ruling 10, which is why question 3 is on this page.
- It could not say whether gain needs a decoder early. It doesn't: the gate already decodes every frame, and
  the meter rides that pass.
- It treats a separate folder-admit process as the natural form. That form is possible, since a command and
  the server already share the store. The case for the server rests on having one admission path.
- It names the states `pushed-back` and `match-unavailable`. Neither exists in the code. The intake design
  decides whether they do.
- It puts the `Navidrome` import in `catalog`'s reach. The import needs the per-member tables, which arrive with
  `queue`.
- It says the music on your server sits in a collection. The files sit under no collection's directory, which
  is why step 2 of the first launch exists.
- It asks for the "event seam the write path needs" as something to build. The seam is a function that takes
  the caller's transaction, and no event table is built until a round reads one.

## How it fails

| What goes wrong | What happens |
| --- | --- |
| MusicBrainz is down | Albums wait before `accepted`, by the intake design's rule. Admission sends MusicBrainz nothing |
| The disk fills during a build | The upload stays `accepted`, the failure is recorded, and the worker tries again on its next sweep |
| The same album arrives twice at once | One is admitted. The unique index refuses the other, which ends `rejected` as already in the library |
| The album's final directory already exists | Nothing is replaced. The upload stays `accepted` with the failure recorded |
| The server stops mid-admission | The table under "What an interrupted admission leaves" applies |
| The commit fails after the files moved, with the server still running | The journal entry stays open, and the next sweep finishes the upload from the store's record |
| The store is restored from a snapshot | The restore command's report lists rows without files and files without rows. An admin moves an album directory that has no rows out of the library and runs folder-admit on it |
| A member uploads during a folder-admit run | The worker takes the member's upload next, at the gate and at admission |
| The server stops during a folder-admit run | The command reports that it lost the server and ends. Albums already handed over finish when the server starts |
| Folder-admit is pointed at a folder inside the library, or one the service's account cannot read | The command refuses to start and says why |
| A folder-admit album would pass the group's quota or the free-space floor | It is reported and left out |
| Folder-admit meets a file that is not FLAC | The album fails the gate and is "reported and left out" |
| A staged file changes after the gate read it | The build's second hash differs, and the upload ends `rejected` |

The limits are these. The server admits one upload at a time. One journal entry at most is open. One
folder-admit run exists at a time, with a few of its albums staged at once. A run needs free space for the
admitted copy of every album, which is about the size of the folder it reads.

## What each round's design has to show

Each item can fail, and a later design that cannot meet one says so to you.

| Round | What its design has to show |
| --- | --- |
| `catalog` | A test stops admission at each of the four points in the interruption table, once by killing the server and once by failing the commit with the server left running. Afterward the album is in the library once and its submission is `admitted`. Every track row names a file whose hash matches the recorded one, and no file sits in the library without a row. The quota is charged once, the reservation is released, the journal entry is closed, and the build directory is gone |
| `catalog` | Two uploads of one album, in flight together, end with one `admitted` and the other `rejected` as already in the library, and the test shows that the unique index made the refusal. A different rip, whose audio really differs, ends as question 1 rules. A second unlisted album with the same audio is refused, and one with the same typed title and different audio is admitted |
| `catalog` | An upload of separate tracks with one track already in the collection admits the others as one-track albums and marks that one as already in the library |
| `catalog` | Folder-admit is run twice on one fixture folder. The first run admits every album in it. The second reports each as already present and admits none. A hash over every file in the folder is the same before the first run and after the second |
| `catalog` | Folder-admit refuses to start, writes no row, and stages no file when the server is stopped, and also when the server was killed without a clean stop |
| `catalog` | The admission table is one list in the code, and the test is generated from it, so no fact can be added without a check. Fixtures cover a multi-disc album, a various-artists album, unlisted music, separate tracks, and a folder-admitted album. The test compares each fact with an expected value |
| `catalog` | The file at the path a track row names, read after tagging, decodes to the audio key the gate recorded |
| `catalog` | The meter's loudness is within 0.1 loudness units, and its true peak within 0.2 dB, of reference values recorded from `ffmpeg` to two decimal places. The fixtures include a 24-bit file, a 96 kHz file, a mono file, and an album measured as a whole. The ReplayGain tags in each admitted file equal the values worked out from the stored loudness |
| `catalog` | During a folder-admit run against a stand-in MusicBrainz server, the command's process makes no request. A member's upload that arrives mid-run is gated and admitted before the run's waiting albums |
| `catalog` | The ownership test reads every SQL statement in the Go code, including the upsert and `REPLACE` forms and table names written with a schema prefix. It fails when a statement outside the owner writes a table, and when a table in the schema is missing from the list |
| `playback` | An index built one admission at a time and an index rebuilt from the rows give the same results in the same order for a fixed set of searches, and every id is unchanged |
| `launch` | The first-launch steps run in their order against a copy of your server's music. A list of every audio file in the old tree, made by a separate tool before the run, is checked against the report: each file is in an admitted album or in an album left out with a reason |

## What is left to each round's design

| Round | Left to its design |
| --- | --- |
| `catalog` | The column and function names. The layout, with the rule for two albums that would share a path and the directory an upload of separate tracks lands in. How folder-admit finds where one album ends, and its flags, with a dry run. How many albums a run stages at once. How the command learns that the server is running. How many times a failed admission is retried and what an admin sees. The form of the cover image store. Whether genre comes from the file or from MusicBrainz. Whether the charged-bytes counter stays. What an admin does with a row whose file is absent after a restore |
| `playback` | The form of an id on the wire, the search index, the queries music apps need, and collection visibility on every endpoint |
| `queue` | The per-member tables, the admin's replace decision for a different rip, and the `Navidrome` import if question 5 keeps it |
| `library` | The filter and facet queries, if question 4 moves them |
| `launch` | The first-launch runbook, from the sequence in "The first launch", and the deletions it makes |

## Shared assumptions

Each was checked by a probe I ran in a clone at `c42bb858`, or by a line of the code or a spec.

| Assumption | Checked by | Result |
| --- | --- | --- |
| The SQLite build has FTS5 with the trigram tokenizer | A probe program on the pinned driver, `modernc.org/sqlite` 1.60.1 | SQLite 3.53.4 with `ENABLE_FTS5`. `tokenize = 'trigram remove_diacritics 1'` works, and a search for `jork` finds "Björk". A search for `agaet` misses a title spelled with the letter æ, so search runs over the folded key |
| Loudness can be measured in pure Go in the gate's decode | A meter over `mewkiz/flac` frames against `ffmpeg`'s `loudnorm` measurement | -20.05 against -20.12, -24.23 against -24.28, and -20.58 against -20.61 LUFS on three files |
| True peak can be measured the same way | A four-times oversampling filter in the same probe, against the same measurement | -6.21 against -6.25, -13.77 against -13.62, and -7.85 against -7.91 dB |
| The meter is fast enough | The same run, with both measures on | 88 times real time for CD audio, and 40 times for 96 kHz at 24 bits |
| The gate decodes every frame of every file | `internal/intake/gate/file.go`, lines 225 to 335 | One pass computes the file hash and the audio key |
| A command and the server can share the store | `internal/ops/local`, and the backup command | The backup job runs in the command's process beside `serve` |
| A hand-run command runs under the service's account | `docs/server-runbook.md`, lines 205 to 213 | The runbook runs each through `systemd-run` as the `music` user, with the `serve` unit's limits |
| The store runs a write callback once | `internal/engine/store/write.go`, lines 69 to 101 | No retry around the callback |
| The move journal exists, is unused, and needs a new shape | Migration `0005_routed.sql`, lines 46 to 68, and a search for its name | No Go code touches it. Both paths are relative with no parent step, it has no submission column, and its states are `pending` and `done` |
| The rename that refuses an existing target is available | `go.mod` | `golang.org/x/sys` is already a dependency, and it has `Renameat2` |
| Every track must have an album | Migration `0003_catalog.sql` | `tracks.album_id` is `NOT NULL` with a foreign key |
| A new state needs no table rebuild | Migration `0006_intake.sql` | `state` has no `CHECK`, and Go validates it |
| Staging and the library are meant to share one device | The `serve` unit's comment on `rename(2)`, and `resolveStaging` in `cmd/dubplate-server/intake.go` | The unit grants one volume directory that holds both. The start check refuses overlapping paths and does not compare devices |
| The worker picks up rows another process wrote | `internal/intake/worker.go`, lines 21 to 24 | Each wake lists the `checking` submissions, and the sweep wakes it every interval |
| The gate's queue is oldest first | `internal/intake/worker.go`, line 75 | `ORDER BY updated_at, id`, with nothing that ranks a member's upload |
| Separate tracks are refused one by one | The `accept` function in `internal/intake/accept.go`, from line 130 | A track whose audio matches an accepted track in the collection is marked already in the library, and the upload is rejected when none is left |
| The restore report exists | `internal/backup/reconcile.go`, and the store spec, line 749 | It lists tracks whose file is absent and files no track names |

Two things I did not check. I read no file on your server, so the configured library folder and the tags in
the music there are as the docs describe them. The exact encoding of the R128 tags is unverified, which
matters only when a later release writes Opus files.

A fresh reader checked this design as the builder who would plan from it. Its findings are folded in: the
separate-tracks rule, the order at the gate during a run, the copy in place of a link, the restore row, the
failed commit with the server running, the syncs, the rename that refuses a target, the journal's shape, and a
tighter form of every item in "What each round's design has to show".

Two readers with no context then read the page, which is the cap. The second understood all five questions.
Its last notes on wording went in after it, so no reader has seen the final text above the buttons.

## Rulings

Ruled: approved by Geoff on 2026-11-20, in his terminal session. The queue held this design unread after he
stopped reading it on 2026-11-17. His picks, each the recommended answer:

1. A different rip of an album already held: "Refuse it", given as question 4 of the `intake` design.
2. Folder-admit and an album with no confident match: "Leave out, list it".
3. Where albums are admitted: "Server only".
4. The library queries: "Move them". Search goes to `playback` and the filter and facets to `library`.
5. The `Navidrome` import: "After 0.8".

## Practice and sources

- Geoff's rulings: `docs/research/2026-09-02-greenfield-server-rulings.md` (rulings 9 and 10), the re-plan
  design's rulings of 2026-10-05, the `cleanup` round design of 2026-11-15, and the ruling the desk recorded in
  the queue on 2026-11-16, "Nothing stored on the `dubplate` server has to be kept".
- The specs in `docs/specs/`: the streamer design (2026-09-07), the configuration design (2026-09-11), the
  store spec (2026-09-23), the re-plan design (2026-10-05), the intake spec and the admin API design
  (2026-10-10).
- The survey: `~/.local/state/desk/reviews/2026-11-17-dubplate-architecture-survey.md`.
- Loudness: ITU-R BS.1770 for the measure, and the [ReplayGain 2.0 specification](https://wiki.hydrogenaud.io/index.php?title=ReplayGain_2.0_specification) for
  the -18 LUFS reference level. EBU R 128 sets -23 LUFS.
- Go practice: Effective Go, Go Code Review Comments, and the `standards:go-conventions` skill.
