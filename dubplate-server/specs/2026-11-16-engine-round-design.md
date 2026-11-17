# Approve the design for the `engine` round of `dubplate`?

This is the design for round two on the road to `dubplate` 0.8. One pass rewrites the matcher, the MusicBrainz
client, and the tag reader so each states its facts once, and it proves that no score and no written byte
changed. Then it trims the test harness and makes the gate fail on a comment that cites a pass or a ruling. I put it
at 600 minutes on the path. **It does not start when you approve.** It waits until the four `cleanup` pull
requests are merged, and you end that wait by answering the `cleanup` close packet. Six questions are yours, and
each has a recommendation.

**1. How far may the pass overrun before it stops starting work?** The estimate is 600 path minutes. The
planning rule parks a plan whose path is over twice the design's figure, and I use the same line while the pass
runs. The four recent passes with a recorded figure took 0.4 to 1.6 times it. At 1.6 times, this pass would take
960 minutes, which a 900-minute ceiling would stop.


**2. Where is the weekly usage stop for this pass?** The standing answer stops new work at 85 percent. This week
you said, "we'll want to get as close as we can to 100% before the reset." Usage read 71 percent on
2026-11-16, and it resets on November 20 at 10:59 PM.


**3. Does the pull request merge on its checks and review, or do you read it first?** The tag reader,
`internal/engine/tagio`, is the code that parses each file a member uploads. The upload gate calls it. It sits outside
the adapter's list of sign-in and data paths, so by the rule this pull request merges without a packet. The pass
proves the reader returns the same answer for every fixture, and it changes no file under a sign-in or data
path. Its close review holds the tag reader's diff to the stricter bar the reviewer applies to sign-in and data
code.


**4. What happens to the 55 process tags in the sign-in and data packages?** The gate's pattern today finds 142
comment lines that cite a pass, a task, or a ruling, all in packages this pass owns. A wider pattern, which adds
the forms the first one misses, finds 365. This pass clears the 310 of those in the packages it owns. The other 55 sit in
`cmd/dubplate-server`, `internal/serve`, `internal/auth`, and `internal/intake`, where any edit needs your
read. I recommend leaving them, because clearing them now costs you a second pull request to read for no change
in behavior.


**5. Do the two held major versions stay held?** TypeScript 7.0.2 and `@types/node` 26.6.6 are tagged for this
round and wait for your ruling. This round changes no web code, so nothing in it would exercise a new compiler.


**6. Does the one dropped backlog item go?** A full sweep of 40 older backlog items was due. It proposes keeping
34 and closing 4 that are done or covered by another item. One it read was already closed. That leaves one true
drop, #4: the `pings` tool's `remove-check`
command lacks a `--force` flag. The fix lives in the `pings` repo, and nothing in `dubplate` refers to it. Approving this design applies the
sweep's other proposals, which "Backlog verdicts" lists.


Initiative: `dubplate-server`. Round: `engine`. Repo: `glw907/dubplate` (`dubplate`, default branch `master`).
Written 2026-11-16 against the `cleanup-ops` branch at `44eabdf`, and checked again at its newer head
`adac61d`, with `master` at `bc48394`. Status: approved 2026-11-16 (see "Rulings").

## Brief

The 2026-11-10 review found the engine packages correct and overbuilt. The tag reader states its 69 fields five
times. The matcher keeps one scoring component per file. The MusicBrainz client carries a 390-line rate limiter that
nothing calls. Comments cite the passes and rulings that produced the code. This round removes all of that in
one pass and changes no behavior.

Proof matters more here than in the `cleanup` round. The matcher is a port of beets 2.14.1, and its value is that
it scores as beets scores. So the pass first records every score the engine produces for the 216 corpus cases,
bit for bit, and every byte the tag writer produces. It rewrites the engine while the harness stays untouched.
It shows the record is identical, and only then does it trim the harness.

The pass also repairs `make derive`, which fails today, and turns on the comment gate that the `cleanup` round
left as a warning.

## Why

Round three, `intake`, makes the first production call into the matcher and the client. Its planner should
read packages that are small and plain. Today a reader of the matcher meets 33 source files and four comment
lines for every five lines of code.

The comment gate has warned since the `cleanup` round because these packages held most of its findings. It can
only fail the build once they are clean.

`make derive` is the one check that runs real beets against the corpus. It has failed since the `cleanup`
round's dependency sweep moved `numpy`, and no gate runs it, so nothing reported the failure.

## Decided by Geoff

- The rounds and their order: "Use these eight rounds, in this order" (2026-11-16, document
  `20261116-000308-88f4d3`). `engine` is second and depends on nothing after `cleanup`.
- This session runs on Fable, to "use Fable to lean into any complex design decision for
  either effort" (2026-11-16).
- The pace this week: "I'd like to keep both development efforts running continuously as much as possible"
  (2026-11-16).
- The review's "Leave alone" list stands, as it did for `cleanup`.
- The standing bars: exemplary Go, nothing exported ahead of a caller, and a test whose expected value is a
  literal or computed independently.

## Goals

1. The matcher, the MusicBrainz client, the tag reader, and the `tag` package each state a fact once. Review
   findings E1 to E9.
2. No distance, recommendation, action, parsed tag, or written byte changes.
3. The harness loses what nothing uses and grades what it says it grades. Findings E10 and E11.
4. Tests that restate their subject go, and comments keep the reason without the process tag. Findings E12 and
   E13.
5. The process-citation gate fails the build, with a pattern wide enough to catch the forms in use.
6. `make derive` passes, and the record stops saying the main checkout is the only place it can run.
7. A fresh architecture read grades each of the three engine packages "sound with nits" or better.

## Non-goals

- A new feature, or any change a member, an admin, or an API client could see.
- Request pacing for MusicBrainz. The limiter goes, and pacing comes back as a separate design with the first
  live caller, in `intake`.
- Newer versions in the beets venv (#132). The venv is the instrument that proves this pass, so its versions
  hold still.
- Any file under a sign-in or data path. The tag reader keeps the names and signatures the upload gate calls.
  The one exception is the comment-only pull request, if question 4 asks for it.
- The ranges on the review's "Leave alone" list. In these packages they are the assignment solver
  (`matcher/assign.go:149-393`), the bounded FLAC parse (`tagio/container.go:229-330`), and the block
  planner (`tagio/write.go:70-88,121-164`). The `subsonic` harness packages are on the list too, so E10's
  `stack.go` line and the `ErrNoPodman` cut stay out.
- The test cuts in `cmd/dubplate-server` and `internal/ops`, the rest of #125.
- Splitting `conform/arch_test.go`. Half its rules belong to server packages this round doesn't own. The pass
  files it.
- Web code, apart from the TypeScript version if question 5 takes it.

## Anti-goals

- A rewrite that passes the conformance suite and still moves a score. The suite compares at a tolerance, so it
  can't see a change in the last bits.
- A comment deleted along with the only record of the ruling it cited.
- A gate pattern that flags a beets citation or an ordinary word. People would switch it off.
- A harness cut that removes the only check of something.
- A changed corpus file. The corpus is the evidence.

## Calls made here

These are Claude's calls, made under the method-and-architecture rule. Each is open to a note.

1. **One pass.** The backlog's round record already says one pass. The work splits by package inside it. A round
   of four passes under a conductor would have about the same path and would add three plans and three reviews.
2. **Two stages.** In the first, the engine changes and the harness and corpus stay as they are, apart from two
   call sites the limiter's removal forces and one line of the manifest. In the second, the harness changes.
   The harness is the instrument, so it changes only after it has shown the engine didn't move.
3. **Three lanes in the first stage.** The matcher with `unidecode`, the tag reader, and the client with `tag`
   share no file. Each goes to a subagent in a separate worktree, the way the pass rules run two independent tasks.
4. **A worktree, where the record says the main checkout.** The backlog, the adapter, and the review all say
   this round runs in the main checkout because the beets venv lives there. That is out of date. The main
   checkout has no venv built. I built one from the lock in a fresh clone and ran the whole of `make derive` in
   6 minutes 58 seconds. So the pass runs in a worktree like any other, runs `make derive` there, and corrects
   the adapter's paragraph and the backlog's record.
5. **Bit-for-bit proof by a throwaway dump.** The pass writes a test it never commits. The test prints, for
   every corpus case, each distance and penalty as raw float bits with the recommendation and the action, and
   for the tag reader each parsed field and each written file's hash. The pass records the dump's hash before
   the first engine edit and after the last. A committed copy would be a test that compares the code with itself, which
   the standing bar rules out.
6. **The distance functions in the matcher become straight-line code.** `DistanceForAlbum` and `DistanceForTrack`
   call each component in beets' order, in two files, and each helper takes only what it reads. The 20
   one-component files and the table rows whose `Name` and `Key` only tests read all go. The assignment solver
   is untouched.
7. **Three settings stay strings because beets reads them late.** The review asked for typed fields throughout. beets
   reads `max_rec`, `quiet_fallback`, and `none_rec_action` only when a decision needs them, and a test pins
   that. Parsing them early would turn a config that works in beets into an error. So those three stay
   strings and one function resolves an action name. The two pattern compilers return an error, which removes
   the `recover` that turned a panic into one. I add no pattern cache, because nothing has measured a cost.
8. **The string-distance patterns compile once.** Each table holds compiled patterns. The mutex and the cache for
   patterns set from outside go, since only a test sets them.
9. **The limiter is deleted outright.** `Limiter`, `Class`, `Budget`, `Unmetered`, and `ClientConfig.Budget` go
   with their tests. Nothing in production paces requests today, and the capture tool paces itself. The pass
   files a backlog item for `intake`: the first live caller designs pacing and installs the transliteration
   table, which no binary installs today.
10. **The client caps what it reads.** A response body over 32 MiB is an error that names the cap. The largest
    response in the corpus is 9.1 MB. A cancelled context returns at once, where today it is retried once. The
    retry count stays at seven.
11. **The tag reader gets one field table.** Each row carries the field's name, its keys in the file, and typed
    access to its struct member, so the reader and the writer walk the table and both 66-case switches go. The
    registry that dispatches over one format becomes plain functions, and `Read` opens the file once.
12. **Upstream citations stay.** A comment that cites a beets file and line at 2.14.1 is the port's
    specification. The tags that go are ours: a rung, a task, a pass, a contract number, a resolution, a
    ruling id, or a dated owner tag.
13. **Each ruling stays findable.** Before a tag goes, the plan lists every distinct ruling the comments cite
    and where its record lives: a corpus ledger, a frozen spec, or `docs/HISTORY.md`. A ruling with no other
    home is written into one first.
14. **The gate gets two patterns.** The narrow pattern it has today fails the build in every package. A wider
    one, adding forms such as `contract 7`, `Ruling D`, and `pass 3a`, fails the build everywhere except the
    packages question 4 names. A new package is covered from its first commit.
15. **The gate keeps reading shipped files only.** The rule says shipped comments. Tags in test comments go
    where the pass already edits the file.
16. **An export goes only after a recorded search.** The review and three fresh reads name about 40 exports with no
    caller outside their package. The plan records a search for each. A name that only another package's test
    uses is settled there, by moving the test or keeping the export, and listed.
17. **Class `runner`.** The pass edits `scripts/check.sh` and the adapter. It edits no sign-in or data path.

## Scope

The pass owns `internal/engine/matcher` with `unidecode`, `internal/engine/musicbrainz`,
`internal/engine/tagio`, `internal/engine/tag`, `internal/harness` outside `subsonic`, `cmd/harness`, and the
comments of `internal/config`. It also edits the citation leg in `scripts/check.sh`, three lines of
`docs/standing-rules.md`, one paragraph of the adapter, one line of `corpus/manifest.json`, and `BACKLOG.md`.

The upload gate (`internal/intake/gate`) calls `Sniff`, `Read`, `ParseBounded`, `Bounds`, `StreamInfo`,
`Format`, `FormatFLAC`, and four error values from the tag reader. The server calls `SupportedFormats` and eight
`unidecode` functions. Every one keeps its name, signature, and behavior.

## How it fails

| What goes wrong | What happens | Limit |
| --- | --- | --- |
| A dump hash differs after a commit | The commit is reverted and the cause found. The new hash is never taken as the baseline | Zero differing bits |
| `make derive` moves a derived record after the dependency sweep | The bump that moved it is reverted and filed | Zero moved records |
| A MusicBrainz body is over the cap | `Get` returns an error naming the cap | 32 MiB |
| The context ends during a request or a wait | `Get` returns the context's error without another attempt | Seven attempts otherwise, as today |
| A media or country pattern doesn't compile | `Tunables.Validate` returns an error naming the pattern, with no `recover` | |
| A comment carries a process tag | `scripts/check.sh` exits non-zero and prints the file and line | |
| A change would need an edit under a sign-in or data path | The signature stays as it is | Zero such files |
| The pass runs long | It starts nothing new at the ceiling of question 1 | The ceiling you pick |

## The pass

One pass, named `engine`, on branch `engine`, in a worktree. Class `runner`.

| Step | What it does | Minutes |
| --- | --- | --- |
| Set up | Land the backlog verdicts, run the dependency sweep, build the venv, run `make derive`, correct the manifest's `numpy` line, write the dump, record the base hashes | 60 |
| Matcher lane | E3, E4 as narrowed, E6, E7, E9, E12, and the comments, in `matcher` and `unidecode` | 210 |
| Tag reader lane | E1, E5, E6, E12, and the comments, in `tagio` | 180 |
| Client lane | E2, E8, E6, and the comments, in `musicbrainz`, `tag`, and `internal/config` | 120 |
| Join | Merge the lanes, run the dump and the conformance suite, record the hashes, run `make derive` | 30 |
| Harness stage | The mutation proofs, then E10 and E11, and the comments in `internal/harness` and `cmd/harness` | 150 |
| Gate | Widen the pattern, set the leg to fail, plant and remove a line of each form, and update the docs and the adapter | 60 |
| Close | Three architecture reads, the whole-branch review, one fix chain, the full gate, the pull request | 90 |

The three lanes run side by side, so the path counts the longest, 210. The path is 600 minutes. The sum over
every step is 900.

## What the merge changes

Nothing a member, an admin, or an API client can see. The upload gate parses with a smaller tag reader that
returns the same answers. A developer gets engine packages about a third smaller, a `make derive` that passes,
and a gate that rejects a comment citing a pass or a ruling. The adapter stops telling a planner that
engine work must run in the main checkout.

## Acceptance

The pull request carries each item with its check's output. I ran each check once on 2026-11-16 in a clone at
`44eabdf`, and "Today" is what it printed.

1. **`make derive` exits 0 at the branch head.** Today: it exits 1. `TestReconcileAcceptsTheCheckedInManifest`
   fails with `numpy: manifest pins 2.5.3, venv has 2.5.4`. Every other package passed, and no tracked file
   changed, so the derivation agrees with the corpus under the newer `numpy`.
2. **Every score is identical.** The dump of all 216 cases has the same sha256 before the first engine edit and
   at the head. Today: can't run yet. The dump is the pass's first task.
3. **Every tag answer is identical.** The dump of each fixture's parsed fields, each refusal, and each written
   file's hash has the same sha256 at both points. Today: can't run yet, for the same reason.
4. **The upload gate's tests pass with no change to a file under `internal/intake`.** `git diff --stat` over
   the sign-in and data paths prints nothing, and `go test ./internal/intake/...` passes. Today: passes, and the
   diff is empty by definition.
5. **The harness sees a changed score.** With one weight changed, the conformance suite fails. Today: I changed
   the `album` weight from 3.0 to 3.5, and seven tests failed: three whole-corpus tests, one other conformance test, and
   three matcher tests.
6. **The harness sees a changed request without the sweep that E10 removes.** With one `inc=` value dropped,
   the whole-corpus tests fail. Today: they fail, alongside `TestRequestConstructionGradesCleanly`, the sweep's
   test. So the sweep is redundant, and the pass repeats this run after removing it.
7. **Default-mode grading reads the pattern table.** A case whose row names the wrong `PatternTable` fails.
   Today: `PatternTable` appears nowhere in `conform/case.go`, so such a row passes.
8. **The limiter is gone.** A search for its ten names in the engine and harness prints nothing. The ten are
   the types in call 9 with their constructor, constants, and errors.
   The files `limiter.go` and `limiter_test.go` don't exist. Today: 66 lines match, and the two files hold 813 lines.
9. **The client is bounded.** A test serves a body over the cap and gets the cap's error. A second test cancels
   the context during a wait and `Get` returns without another request. Today: `io.ReadAll` has no reader limit
   in the package, and a cancelled context is retried once.
10. **The matcher has no one-component file.** `ls` of `album_*.go` and `track_*.go` lists two source files at
    most. Today: 20, among 33 source files.
11. **The matcher has no `recover` and no mutex.** Today: one of each.
12. **The tag reader states its fields once.** `case Field` appears in neither the encoder nor the reader, and
    a search for the registry's three names prints nothing. Today: 66 cases in each, and 37 registry lines.
13. **`Read` opens the file once.** `os.Open` appears twice in the package, once to read and once to write.
    Today: three times.
14. **No export lacks a caller.** For each name on the plan's list, a search outside its package prints
    nothing and the name is no longer exported, or the plan says why it stays. Today: the 13 names from the review that I probed are all
    exported. The plan's list is longer, about 40.
15. **The harness trims are in.** Searches for `GradeRequests`, `tiesAwaitingRuling`, and `Case.Extra` print
    nothing, `fieldNullability` appears only in a test file, and `internal/harness/mbrequest` is gone. Today:
    4, 3, and 8 lines, no corpus case sets `extra`, and `mbrequest` holds two files.
16. **The restating tests are gone.** `TestWriteOrderDeterministic` and the eight `TestDefaultTunables_*`
    tests don't exist. Today: they do.
17. **The pass's packages carry no process tag.** The wider pattern prints nothing for them, and the narrow
    pattern prints nothing in the repo. Today: 310 lines for the wider pattern and 142 for the narrow one.
18. **The gate fails on a tag.** With one planted line of each form, in an engine file and again in a new
    package, `scripts/check.sh` exits non-zero and names each line. With the lines removed it passes. A beets
    citation doesn't trip it. Today: the leg warns and exits 0.
19. **Each removed ruling has a home.** The pull request holds a table from each distinct ruling the comments
    cited to the file and line of its record, and each row's search finds it. Today: can't run yet. The plan
    builds the list.
20. **The record is right.** `docs/standing-rules.md` no longer says the leg "warns today", and the adapter
    says where `make derive` runs. Today: one such line, and the adapter says the main tree.
21. **Three reads grade "sound with nits" or better.** A fresh `standards:go-architecture-reader` reads
    `matcher`, `tagio`, and `musicbrainz` at the head. Today: `matcher` and `tagio` read "workmanlike", and
    `musicbrainz` reads "sound with nits". The findings of today's reads go into the plan.
22. **The gate and CI are green.** `bash scripts/gate.sh --merge` passes through `cairn-run-gate`, with
    `go vet -tags oracle` over the harness packages, and the hosted check passes on the head. Today: build,
    vet, and tests pass in the clone.

## Shared assumptions

| Assumption | Probe or source | Result |
| --- | --- | --- |
| The `cleanup` branches don't change this round's packages | `git diff --stat bc48394 adac61d` over the engine, harness, corpus, and tools paths | Only 11 files under `internal/config` and three backlog lines differ |
| The venv builds outside the main checkout | `uv venv` and `uv pip install` from `tools/venv/requirements.txt` in a fresh clone | Built, and `make derive` ran in 6m58s |
| The corpus agrees with the newer `numpy` | `git status --short` after `make derive` | Empty |
| A green conformance run doesn't prove identical bits | `conform/case.go:843-859` | Distances compare at a tolerance |
| Production reaches only the tag reader and `unidecode` | `go list -deps ./cmd/dubplate-server` | `tagio` and `matcher/unidecode`, and no other engine package |
| The capture tool doesn't need the limiter | `cmd/harness/capture.go:356` | It builds a separate HTTP client and paces itself |
| The cap is larger than every known response | Sizes under `corpus/cases/*/responses` | Largest 9,107,383 bytes |
| The launch flags exist | `claude --help` | `--bg`, `--model`, `--effort`, `--name` listed; `--advisor` is accepted |

## Where a `cleanup` answer would change this design

I read the engine and harness packages on the `cleanup-ops` branch. They are byte for byte what `master`
holds, so three places only depend on your answers to the close packet.

- If the store pull request is sent back, the comment lines in `internal/config` may move. The planner counts
  them again.
- If the gate pull request is sent back, `scripts/check.sh` may change around the citation leg. The pass edits
  the leg where it then sits.
- If the ops pull request changes, the count of tags outside this pass changes, and question 4's 55 with it.

The calls waiting in that packet change none of this round's files.

## Start line

Nothing launches until each of these reads true.

1. Your approve is recorded: this design's "Rulings" section carries a `Ruled:` line with the queue id.
2. `gh pr list --state open` for `dubplate` is empty, and the four `cleanup` pull requests show as merged.
3. The main checkout is on `master`, and `git rev-list --count HEAD..origin/master` prints 0 after a fetch.
4. `claude agents --json` lists no `conductor-dubplate` session and no session whose name starts
   `dubplate-cleanup`.
5. `claude-worktree-busy` on the main checkout exits 0.
6. Weekly usage reads under the line you pick in question 2. If you pick no stop, this state always holds.

| Check | Command | Output on 2026-11-16 |
| --- | --- | --- |
| Open pull requests | `gh pr list --state open` | Four, all ready for review: gate, store, web, and ops at `adac61d` |
| Level with the remote | `git rev-list --count HEAD..origin/master` | `0`, on `master` at `bc48394`, with no fetch run |
| Live sessions | `claude agents --json` | `conductor-dubplate` busy and `dubplate-cleanup-ops` idle |
| Free checkout | `claude-worktree-busy` | exit 1, a `cleanup` session has its working directory there |
| Usage | `claude -p "/usage" --model haiku < /dev/null` | "Current week (all models): 71% used" |

Until the line holds I plan in my job folder and write nothing in `dubplate`.

## Steps for Geoff

Before launch, `[you: answer the cleanup close packet]`. That is the only step, and it is already yours. At the
end there is nothing unless you chose "Send it to me first" in question 3, or the pass meets a call that is
yours and sends a `decide` document.

## Standing answers

The twelve in `round-run.md` hold, with question 2's line in place of the 85 percent in answer 4 until the
reset. This design adds:

13. The plan's path is over 1,200 minutes, twice the estimate. The pass parks and I send a `decide` document.
    Once the pass runs, it starts no new task past the ceiling of question 1, and the executor sends the
    `decide` document.
14. A dump hash differs. The commit that moved it is reverted and the cause found before work goes on.
15. A mutation leaves the suite green. The harness cut that the mutation was guarding is not made, and the pull
    request says so.
16. A cut would change the "Leave alone" list or a frozen spec. It is left, and the pull request says so.
17. A change needs a file under a sign-in or data path. The signature stays, and the item is filed.
18. A task needs another file outside the pass's list. A call site forced by a changed signature is taken and
    listed under `## Decisions`. Anything else is filed and left.
19. A review finding no longer matches the code. The planner drops it and names it under `## Planning misses`
    with `[stale-fact]`.
20. A cited ruling has no other record. The pass writes it into `docs/HISTORY.md` before the tag goes.
21. The wider pattern flags a correct comment. The pattern is narrowed. No comment is reworded to slip past it,
    and no line gets an exemption.
22. A read still grades a package "workmanlike" after the one fix chain. The pull request states the verdict
    and the open findings, files them, and the pass closes.
23. The dependency sweep meets a major. It waits for you, as #130 and #131 do.
24. CI is red for a cause outside the pass. The executor fixes the workflow in its branch and lists the fix.
25. A `cleanup` pull request is sent back after you approve this design. Nothing launches until it merges, and
    the planner then counts again as "Where a `cleanup` answer would change this design" says.
26. Your approval carries no pick for a question. The recommended option is used.

## Rulings

Ruled: approved by Geoff on 2026-11-16 through the Approval Queue, document `20261117-063854-e44c48`, with no
notes. His picks:

1. Overrun ceiling: "1,200 minutes".
2. Usage stop: "95 percent until the reset". After the November 20 reset the 85 percent of standing answer 4
   applies again.
3. Merge rule: "Merge on checks and review".
4. Tags in guarded packages: "Leave them for a later pass".
5. Held majors: "Hold both until intake".
6. Dropped item: "Drop it from this backlog".

## Backlog verdicts

The scoped sweep read the items tagged for this round and the items naming a file the pass changes. Approving
this design approves these edits. They ride the pass branch as its first commit.

| Item | Verdict | Note |
| --- | --- | --- |
| #110 Delete the limiter | fold | 30 minutes |
| #111 The fields and registry of `tagio` | fold | 120 minutes |
| #112 Distance functions and settings in the matcher | fold | 150 minutes, with the typing narrowed as call 7 says |
| #113 The client and `unidecode` leftovers | fold | 60 minutes |
| #114 Harness trims and the pattern-table bug | fold | 150 minutes. The `ErrNoPodman` cut stays out under "Leave alone" |
| #115 Restating tests and process comments | fold | 150 minutes |
| #59 Run `make derive` before the first matcher pass | fold | The pass runs it and corrects the manifest |
| #125 Test bloat in `cmd` and ops | reword | The gate flip and the `internal/config` comments fold. The test cuts stay open |
| #156 Tags the pattern misses, and `webapp` exports | reword | The engine and harness tags fold. The guarded packages and the exports stay open |
| #66 The architecture cleanup | reword | It says four copies of a test shim where there are three |
| #61 Recheck TypeScript 7 before 0.8 | duplicate | Of #130 |
| #130, #131 The held majors | keep | Their tag changes as question 5 rules |
| #132 Newer versions in the venv | keep | After this round, as a separate corpus revalidation |
| #28, #31, #32, #63, #105, #124, #126, #129, #135, #136 | keep | Each still holds, and none is in the pass's lines |

Items #67, #118, and #134 are already closed in the file. The pass files three new items: pacing and the
transliteration table for `intake`, the split of `conform/arch_test.go`, and whatever the reads find that
the fix chain doesn't take.

The backlog holds 120 open items, and 119 of them carried no sweep stamp, so a full sweep was due. It read 40
older items, 39 of them open and one already closed, and it folds nothing. The queue's two dispositions are `defer` and `drop`. In the table, `drop` with a
second word closes an item that is done or a duplicate, and `drop` alone is the one true drop. Rows marked "unverified" rest on state the repo can't show, such as files on the
server.

<details>
<summary>The full sweep's 40 rows</summary>

| Item | What it is | Proposed | Reason |
| --- | --- | --- | --- |
| #2 | Reset stale ping-failure units on the server | defer | Server state, unverified |
| #4 | `pings remove-check` lacks `--force` | drop | Question 6 |
| #5 | The `ssh_cidrs_json` exit only ends an inner shell | drop, duplicate | #68 states the symptom and the fix |
| #6 | SELinux check of the state directory | drop, done | `docs/HISTORY.md:8357-8360` records it as Enforcing with the right labels |
| #8 | Watch for tus-js-client 5.0 | defer, reworded | The pass it named is gone. It moves to the `intake` uploader pass |
| #9 | Geoff reviews two parked seed albums | defer | Yours, on the server, unverified |
| #10 | `provision.sh` refuses unset SSH ranges | defer | The guard still exits before `--check` runs |
| #15 | The doctor probe trips the forwarded-header warning | defer, reworded | The mechanism holds and its line numbers moved |
| #16 | A username may equal another member's address | defer, reworded | Still open, and its line numbers moved |
| #19 | The members hint's faded contrast | none | Already closed in the file. Commit `3915b94` removed the class |
| #36 | The `srcset` check flags data URIs | drop, duplicate | #57 lists it, and its fix moves into #57's text |
| #37 | The first store-backed deploy | defer | Launch work, not built |
| #38 | Run `member add` and `doctor` sandboxed on the server | defer | An attended launch step, unverified |
| #39 | Archive copy, relocation, and identity | defer | A launch decision the spec holds open |
| #40 | The roster walk with the `Amperfy` client | defer | An attended launch gate that hasn't run |
| #41 | A restore check for later epochs | defer | Only the line in the runbook exists |
| #42 | Streamer slice 3 waits for the catalog | defer | A `playback` carry, its count unverified |
| #43 | Slice 3 takes four ledger rows | defer | The rows are still in the ledger |
| #44 | The `Tempus` version and flag in the roster walk | defer | The doc still names the old ones |
| #45 | The seed lacks lyrics, now-playing, and radio | defer | A `playback` carry, unverified |
| #46 | Slice 5 takes ledger row L-17 | defer | Still a ledger row |
| #47 | Slice 6, the revoke verb and epochs | defer, reworded | Its claim that `EpochStore.Bump` has no production caller is stale |
| #48 | Slice 6, the member side | defer, reworded | Username uniqueness already holds, so only the address half is open |
| #49 | Slice 7, the streamer database in restore | defer | A `queue` carry with no code yet |
| #50 | Slice 8, trailers and naming | defer | A `queue` carry with no code yet |
| #56 | The `id3-tags` rejection copy | drop, duplicate | The code half is done, and #83 owes the copy |
| #57 | Web carries for `intake-3` | defer, reworded | The favicon pointers moved to `internal/webapp`, and it takes #36. Only part was checked |
| #58 | Uploader images at stable paths | defer | The uploader page doesn't exist yet |
| #60 | Catalog library queries | defer | Nothing is built |
| #62 | The project site's naming and config generator | defer | Both are still open in the spec |
| #64 | Photo check failures | defer | Two tests still assume an empty folder |
| #65 | Photo licensing recheck | defer | Unverified |
| #68 | `provision.sh` computes the ranges at top level | defer | The substitution still drops the status |
| #84 | `intake-2` planner carries | defer, reworded | `RequireMember` was never written, so "has no caller" describes it wrongly |
| #85 | `intake-3` visual identity records | defer, reworded | The spec's line numbers moved |
| #86 | The MusicBrainz buy-link hook | defer, reworded | It was never added to the forward-hooks list |
| #87 | `intake-2` hardening from its review | defer | Three checked parts hold. The rest wasn't checked |
| #88 | `intake-2` cleanups from its review | defer, reworded | One part became #144, and `TestLayering` exists twice |
| #89 | What the deploy pass owes | defer | The unit and the grep are unchanged |
| #90 | A collection's owner is never reassigned | defer | Still set once at insert |

</details>

After this run and the scoped sweep, 56 open items still carry no sweep stamp, so another full sweep is due at
the next round's design.

## Estimate

The path is 600 minutes and the steps sum to 900. Recent passes: `admin-api-1` planned 695 and took 475,
`intake-1` planned 725 and took 570, the first `cleanup` pass planned 182 and took about 80, and the fourth
planned 180 and took about 290. The sizes of the six folded review items sum to 660 minutes of work, which
three lanes shorten on the path. The ceiling is question 1's.

## Practice and sources

- The review: `docs/research/2026-11-10-whole-repo-review.md`, section `cleanup-engine`, findings E1 to E13,
  and its "Leave alone" list.
- The `cleanup` round's design, `2026-11-15-cleanup-round-design.md`, whose pass 5 says the citation leg
  "starts to gate in round `engine`".
- `tools/venv/README.md` on a version change: "re-derive, adjudicate what moved, then update the manifest."
- Three `standards:go-architecture-reader` reports from 2026-11-16, on `matcher`, `tagio`, and `musicbrainz`.
- `pass-core`: `round.md` on a one-pass round, and `planner.md`, `ready.md`, and `round-run.md`.

## Later

- Pacing for MusicBrainz requests, designed with the match probe in `intake`.
- Newer versions in the beets venv (#132), as a corpus revalidation.
- Running `make derive` in the gate or on a schedule, so a drift like the `numpy` one is reported the day it
  happens.
- The 55 tags in the guarded packages, if question 4 leaves them.
- The split of `conform/arch_test.go`.
- Another full backlog sweep, for the 56 items neither sweep reached.
