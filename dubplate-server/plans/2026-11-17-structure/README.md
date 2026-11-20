# Hand-over files for the `structure` round

The session that designed dubplate's `structure` round wrote these on 2026-11-17. The design is
`../../specs/2026-11-17-structure-design.md`, which Geoff approved as queue document
`20261117-083604-d6b622`. No file here is ever committed to `dubplate`.

| File | What it is |
| --- | --- |
| `conductor-prompt.txt` | The prompt for `conductor-dubplate`: the order table, the planner's launch line, and the checks before the first launch |
| `structure-base-planner-prompt.txt` | The planner prompt for pass 1 |
| `structure-keys-planner-prompt.txt` | The planner prompt for pass 2 |
| `structure-doctor-planner-prompt.txt` | The planner prompt for pass 3 |
| `structure-proof.sh` | Runs the server's commands in a temp folder and prints a fingerprint of every line a person sees. `structure-proof.sh <path to dubplate-server binary> [transcript file]` |
| `zz_registrydump_test.go` | The registry dump. It prints every entry of the production registry in registration order, with every field, and logs one sha256 line |

## Running the proof

Each pass runs both files on a binary built at its base commit and again at its head. The two
runs must print the same lines.

1. Build each binary with `go build -o <out> ./cmd/dubplate-server` in a fresh detached worktree
   that has never run the gate or the web build. `web/embed.go` embeds `web/build`, and a fresh
   checkout holds only `placeholder.txt` there. `doctor` then prints "the embedded build tree
   holds only the placeholder" in its `web` row, and the values below include that sentence. A
   binary with a real web build prints a different row. Base and head must be built in the same
   state.
2. Run `structure-proof.sh <binary> <transcript file>`, one run at a time. Port 18431 on
   127.0.0.1 must have no listener. The script prints seven lines: six sections, then
   `everything:`.
3. When a line differs between base and head, diff the two transcripts. The script masks the
   temp folder's path, the log timestamp, the local user's name, and the free-space figure, so
   any other difference is a change in what the server prints.
4. Copy `zz_registrydump_test.go` into `cmd/dubplate-server/`, run
   `go test ./cmd/dubplate-server -run TestRegistryDump -count=1 -v`, and read the
   `registry dump:` line. Delete the copy before any commit. The test calls
   `newProductionRegistry`, so a pass that renames that function changes the one call in its
   uncommitted copy.

## Values at `e03e574`

The kit printed these on 2026-11-17 for `dubplate` at `e03e574`, before round `engine` merged.
Two runs of the script matched. A pass compares its own base with its own head, so values at a
later base may differ from these without any fault.

```text
empty environment:                 lines=78   sha256=5233cf78193226dec7e293c34b63b676691fb573bee263b2dc294f0667731ea3
complete environment, no store:    lines=77   sha256=d98236213a4019e7cf1c167a0128bfa4628f440c8d3d91b439ef58b6964a73fa
a retired setting name:            lines=74   sha256=29cec9c8b52a94066b6d209f144f417a9fd157e76ea6febfc678c916024113fc
refused values:                    lines=1867 sha256=e06b84f9a762f3baeab228ed42e3dc3a766641855cba5c1848429b858e445596
a store with one admin:            lines=183  sha256=968d704237a02f5d0fc090c06727f7283614d0f2892ea6ddeb264c760a1a20ab
help text, every command:          lines=225  sha256=c09227a87aebb58c7c933b530857ae8eff92e29122b69aac8d44575809d9c6a3
everything:                        lines=2510 sha256=7b996b4391ddca9ca2cfcb54a2de399ce88f22fa5a5d201018dfd92e346b4b06
registry dump: 56 lines, sha256 b8a59fba160781e6fd33c513d9a844266c20a9af401fd1e6f18e61e2b1365842
```

Two more values come from commands in the design's "Acceptance" table for every pass:

```text
migrations: 6 files, sha256 ffc4e9dba22b03e6afed130458776b448a19b758a5b2c0ed7613ff9d7c3beef9
test names: 1921, sha256 4918d4c4329625879cf7133693f29660023f567261092ccc9afc63fa68aeedef
```

The migrations line is `(cd internal/engine/store/migrations && sha256sum -- *.sql) | sha256sum`.
The test-names line is the sha256 of the sorted list the table's `grep` prints, one name per
line.

## Launch flags

`claude --help` on 2026-11-17 lists `--bg`, `--model`, `--effort`, and `--name`. It doesn't list
`--advisor`, and the `cleanup` round's conductor found that the flag is accepted. The conductor
probes the line again on the day it launches.

## Two additions made after approval

The designing session added two files to the design's file lists while it wrote the planner
prompts. Each planner lists its addition under `## Decisions`.

- `docs/standing-rules.md` joins pass 1. Its gate description names the two `_salvage` filters
  the pass removes.
- `.claude/skills/dubplate-pass/SKILL.md` joins pass 2. Its "Config keys" rule tells a pass to
  declare each key from the pass's own file with a line in `main.go`, which is the shape pass 2
  ends.
