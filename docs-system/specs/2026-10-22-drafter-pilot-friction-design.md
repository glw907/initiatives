# Pilot friction: markdown forms and the authoring fixes

Status: approved by Geoff on 2026-10-22, with #42 and #43 deferred to Medium. Initiative:
`docs-system`. Input: the extend blueprints pilot's friction record
(`research/2026-10-22-extend-blueprints-pilot-friction.md`) and drafter's `BACKLOG.md` #36 to #47.
Risk class: `runner`, because the `blueprint` skill's files change. No `live-account` flag.

## Brief

Approving this starts one drafter pass that fixes what slowed the three pilot authors. The next
fifteen cairn pages are written from their prose plans by an author agent, so the pass puts first
what that author touches: three new markdown forms (code examples, figures, and page constraints),
a skill rule that frames the reader from the outline's job, and checks that catch over-claiming
lines and drifted pointers before the fact-checker runs.

### What changes

- A blueprint can say "show this code" or "show this figure", with the model file named. drafter
  sends that file to the drafting step again, which the markdown format lost.
- Page-wide instructions to the drafter, such as "state no version range", get one block of their
  own, outside the reader block.
- The skill tells an author to frame the reader from the outline's job, never from the plan's
  worked example (your custom admin send-back), and says who fixes a fact two authors share.
- `drafter check` warns on "only", "every", "no", and counts in blueprint lines and fact bullets,
  catches a pointer whose symbol moved off its cited lines, and catches a wrong `track`.
- `drafter refs` takes several fact ids and also lists the briefs and drafted pages a correction
  breaks. Smaller fixes: a one-fact check, an outline query, `--version`, and `excerpt` output for
  vendor and very long sources.

### If you approve

1. The planning session merges the initiatives PR carrying this design, writes the plan, and hands
   the pass to `conductor-drafter`. You have no pre-flight steps.
2. The pass runs unattended and comes back to you as one packet with the PR.

### Decide: Defer the two converter fixes, #42 and #43?

Both fix the converters that turn a YAML plan into a markdown blueprint. The fifteen pages left
have prose plans only, no YAML plan, so neither converter runs on them, and every YAML plan cairn
has already has its blueprint. #42 would still help when cairn's eight YAML blueprints move to
markdown.

Source: the pilot's friction record, item 27, and a file count in cairn-cms at `0e01d37e3`.

- Defer both: they stay in the backlog at Medium, and the pass runs about 420 minutes (recommended)
- Keep both: they run last, adding about 150 minutes

### Standing answers

- A plan up to 840 path minutes launches without you; above that it stops and asks.
- The pass spends no API credit: no `make smoke`, and `drafter page` runs only with `--dry-run`.
- A review finding that a form approved here could satisfy with a smaller change takes that change
  and lists it in the PR's `## Decisions`. Only a finding that needs a different form stops.
- The exhaustive-word lint is a warning, never an error. Its word list is the executor's call.

## The markdown forms (#47)

Each form follows the format's existing pattern: a bullet whose label names its kind, and a
directive tag in the `:fact[id]` style.

A code example is a bullet that opens `Code:`, says what the block shows, and may name its model
file with `:source[path]` or `:source[path#Symbol]`. A fence directly below it, blank lines
allowed, is the block as the page shows it. A comment line directly above that fence, such as
cairn's `<!-- snippet-check-skip: ... -->`, goes to the page with it.

````markdown
- Code: the resolver module, adapted from Cloudflare's Validate JWTs sample. :source[src/lib/identity.ts#resolve] :fact[s9s8mw]

```ts
export const resolve = ...
```
````

A figure is a bullet that opens `Figure:`, says what the figure shows, and may name an existing
image or diagram file with `:source[path]`. It may sit in a section or in the reader block, where
the pilot's introduction diagram went.

Page constraints are a `:::constraints` block between the reader block and the first heading, one
bullet per constraint, with fact tags allowed. It replaces the YAML `constraints` field and the
`**Background.**` paragraph the authors improvised. The reader block stays the introduction brief.

What drafter does with them: `View` maps a `Code:` bullet to a `code` item and a `Figure:` bullet
to a `figure` item, so the existing plan checks and `refs` read them. `CodeSources` returns each
`:source` path, and the draft request inlines those files as it does for YAML. The whole file
still goes to the drafter, so the constraints reach it as written. Two new errors in
`drafter check`: a fence with no `Code:` bullet above it, and a second `:::constraints` block.
`argument`, `orderReason`, and dispositions stay out of the markdown format, since the section
jobs and their order carry them.

## Order and files

The plan writes the tasks; this is the order it takes.

1. #47 and #45: the decoder, `View`, `CodeSources`, the check, and the format doc with its skill
   copy (`docs/blueprint-format.md`, `claude/.claude/skills/blueprint/format.md`). #45's stale
   wording, hinge example, and lead-in rule are in the same file, so they ride here.
2. A pair. The skill (#46, #44, and the new forms in `new-page.md` and `anatomies.md`), beside the
   check changes (#40, #41).
3. A pair. Pointer drift and the parenthetical count (#39), beside `refs` (#38).
4. #36 and #37: the one-fact check, `drafter outline <slug>`, `--version`, and `excerpt`.

Out of scope: the cairn blueprints and pages, and the record's approval-queue, dotfiles, and cairn
items. The three pilot blueprints use bare fences and `track: extend`, which the new checks flag;
the pass files a cairn backlog item to move them to the new forms.

## The end-to-end check

On a scratch copy of the custom admin screen blueprint, rewritten to the new forms, `drafter
check` reports no error, `drafter refs` with two ids lists the blueprint lines and the cairn page
brief, and `drafter page --dry-run` builds its request with the `:source` file inlined.

## Later

- The outline's `figure: true` could require a `Figure:` bullet.
- Dispositions could get a markdown home if a fact-checker keeps flagging a fact left out on
  purpose.
- #35, a fence inside an open block, stays in the backlog; no new form puts a fence in a block.
