# Batch friction: the store checks, the lint, and the authoring fixes

Status: drafted 2026-10-24 for Geoff's approval. Initiative: `docs-system`. Input: the extend
blueprints batch 2 and 3 friction record (`research/2026-10-22-extend-blueprints-batch-2-friction.md`,
items 1 to 35 and B3-1 to B3-29) and drafter's `BACKLOG.md` #48 to #81, less #42, #43, and #82.
Risk class: `runner`, because the `blueprint` skill's files change. No `live-account` flag.

## Brief

Approving this starts one drafter pass that fixes what slowed the batch 2 and 3 authors, before
the last nine extend pages start. Most of it is in `drafter check`: drifted pointers that pass
today get caught, the over-claim lint stops firing on plain negation, and a check of one blueprint
prints only that blueprint's warnings. The skill gets the steps the batches showed it was
missing, and a running `drafter page` says what its batches are doing.

### What changes

- A line pointer with no anchor warns. The excerpt window no longer hides drift, and dotted
  pointers, doc-comment anchors, route paths, and `node_modules` paths are checked or excerpted.
- The exhaustive-word lint drops `no` and `never` and skips `:::constraints` lines (your
  2026-10-24 ruling on #48). Each match points at its own line, and every match on a line is
  reported.
- A named `drafter check` prints no outline-wide warnings. A `See` bullet with trailing text
  counts as a link. A link to a `managed: false` page or to an anchor a blueprint adds stops
  misfiring.
- `:source[...]` takes a path with brackets, such as a SvelteKit route. A second `:source` on a
  bullet warns. A `Figure:` bullet takes a fence, so a `repro` figure has a form.
- `drafter refs` reads the briefs of pages with no blueprint yet, lists the links into a page
  being retired, and marks each fact as code-, URL-, or prose-sourced for the D1 audit.
- A running `drafter page` prints a line when a batch's status changes, and `drafter status
  <run-id>` reports each open batch (#81, which replaces #73).
- A fresh worktree finds its local config in `~/.config/drafter/<repo>.local.toml`. An
  `outline.yaml` error names its line and column.
- The skill gains a premise step before authoring, the register editor before the fact-check,
  and the missing recipes and fixes the authors asked for (#51 to #58, #75 to #77, #80).

### If you approve

1. The planning session merges the initiatives PR carrying this design, writes the plan, and hands
   the pass to `conductor-drafter`. You have no pre-flight steps.
2. The pass runs unattended and comes back to you as one packet with the PR.

### Standing answers

The run decides five things without you, each set here.

- A plan up to 1000 path minutes launches without you; above that it stops and asks.
- The pass spends no API credit. `make smoke` stays off, `drafter page` runs only with
  `--dry-run`, and `drafter status` is tested against a fake server. Its one live call in the
  end-to-end check is a batch lookup, which is free.
- The close installs the new build to `~/.local/bin/drafter` only once run
  `20261024T080412Z-13b5d021` has no open batch. While one is open, the install waits, and STATUS
  says so.
- A review finding that a form approved here could satisfy with a smaller change takes that change
  and lists it in the PR's `## Decisions`. Only a finding that needs a different form stops.
- The sentence-length limit for #64 is a `drafter.toml` setting, off by default. The pass sets
  cairn's to 26 words in a cairn backlog item, never in cairn's tree.

## The decisions inside the scope

These are method calls the design makes, so the plan carries them as written.

- **#59 and #79.** An anchorless `path:N` or `path:N-M` pointer warns, naming the fix: add the
  anchor. The drift check reads the anchor's line against the cited span exactly, with no window.
  A pointer whose anchor sits in parentheses is read as an anchor.
- **#60.** A `#name` anchor resolves to the declaration with its doc comment, as `format.md`
  says the excerpt does. A dotted `#a.b` pointer is checked through the nested resolver #28
  added. A bracket or parenthesis route path is checked as `drafter excerpt` resolves it. A
  figure's `:source` gets an existence check.
- **#71.** A code span inside a tag note, such as ``[verified: ran `x` on ...]``, is commentary
  and never a pointer. drafter already reads it that way; the pass adds the rule to the grammar in
  `format.md` and a test. cairn-cms #38 brings `check:facts` to the same rule.
- **#72.** A pointer into `node_modules` is excerpted from the file on disk, and the excerpt says
  it is untracked.
- **#49.** A `Figure:` bullet takes a fence below it, as `Code:` does, and `View` keeps the fence
  as the figure's body.
- **#64.** The limit counts words per sentence on blueprint lines only, never fact bullets. A
  trailing-hinge check is left to the register editor (your 2026-10-24 ruling).
- **#66 and #68.** Both ride on `drafter refs`. `drafter refs --page <path>` lists the blueprint
  links and outline `crossLinks` into a page. Each fact hit gains its source kind: code, URL, or
  prose.
- **#69.** The fallback is read only when the project has no `drafter.local.toml`. `<repo>` is the
  main checkout's directory name, so every worktree of a repo shares one file. The error for a
  missing `prompts` names the fallback path.
- **#81.** Each poll writes the batch's `processing_status` and `request_counts` to the run state
  in an optional field, so a state file from today's build still loads. The field stays out of
  `fingerprint.go`. `drafter status <run-id>` reads the run state, looks up each open batch with
  the configured key, and prints its status, age, request counts, and any API error by type.

## Order and files

The plan writes the tasks; this is the order it takes.

1. The decoder: #61, #50, and #49 (`internal/blueprint/markdown.go`).
2. A pair. The check lints (#48, #62, #63, #64, #65, #74) in `internal/plan`'s check, exhaustive,
   and links files, beside the store checks (#59, #79, #60, #71, #72) in `verify.go` and the
   excerpt code.
3. A pair. `drafter refs` (#66, #67, #68, #78), beside the batch status (#81) in
   `internal/batch`, `internal/pipeline`, and a new `cmd/drafter/status.go`.
4. The config fallback and the YAML error (#69, #70).
5. The skill and the format doc (#51 to #58, #75 to #77, #80), with every rule the Go tasks
   changed written into `format.md` and `docs/blueprint-format.md` in one place. It runs last
   because the Go tasks' doc rows land in the same files.

Out of scope: #82 (each page advances on its own), which gets its own pass with a live run to prove
it; the converters (#42, #43); the cairn blueprints, facts, and pages; and the record's
approval-queue, dotfiles, and cairn items.

## The end-to-end check

On a scratch copy of cairn's configure-media blueprint and its facts, outside both repos: a named
`drafter check` prints no outline-wide warning and no exhaustive warning on a `:::constraints`
line. A bracketed route `:source` resolves. The six B3-12 drifted facts each warn. `drafter refs --page` lists the links into a page. `drafter status` on the
finished run `20261024T080412Z-13b5d021` reports its batches ended, with their counts.

## Later

- #82, each page advancing through its stages on its own.
- A per-line marker that settles an exhaustive warning, if `only`, `every`, and counts stay noisy.
- A `run` tag for facts about a dependency's behavior that rest on a dated run (B3-28).
