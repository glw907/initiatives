# Sweep the empty "own" from one slice of cairn-cms (round 2)

You are one of five agents. Each works a disjoint slice in its own git worktree. Work only in your worktree and only on the files in your slice. Never push. Skip any agent-memory maintenance.

- Worktree: WORKTREE (run every command there; the branch is already cut from origin/main)
- Slice: SLICE

## Why

Geoff flagged the empty intensifier "own" as an AI writing tic: "Own adds nothing, and reads awkwardly." His examples were "a site's own screen" and "links the site's own screens". PR #137 swept the docs, blueprints, and `src/lib` comments. Geoff then chose to sweep everything else except the admin's editor-facing copy (backlog #34). Your slice is part of that.

## What to change

Find candidates with `git grep -n -i -E "\b(\w+'s|its|their|your|his|her|our|my|one's) own\b" -- <your slice>`, and also check a bare `own` near a possessive. Judge every hit in its sentence, by reading it, never by script:

- **Empty, so remove it.** The sentence means the same with "own" deleted. Most hits are this kind. "the site's own render" becomes "the site's render", and "its own row" becomes "its row".
- **Removal leaves a dangling possessive, so reword.** "with its own" at a sentence end, "a key of its own", "on their own branch" where "own" carried "separate". Write the plain meaning: "a separate branch", "its key". PR #137's scripted pass left 20 broken remnants like "a second live region of its." and "after its:"; never leave one.
- **Keep the meaning.** A rewording may not change what the sentence says. PR #137 had to revert "its own route" -> "on a separate route" (a different claim) and "ships unrenamed" -> wrong sense. If no plain rewording keeps the meaning exactly, keep "own".
- **Contrastive, so keep it.** The sentence sets the owner against another party named in the same sentence or the one before, and the reader would lose that contrast. A contrast you have to argue for is not one.
- **Idioms stay.** "on its own" (alone, unaided), "of its own accord", "in its own right", "come into its own", "hold its own".
- **Verb and adjective uses stay.** "owns", "owner", "owned", "own" as a verb.

## Runtime text is in scope this time, with its tests

Unlike PR #137, you may change text the program emits: Go and TS string literals, CLI output and diagnostics, audit finding messages, log `reason` text, prompts sent to a model, test names, and showcase content. When you change one, update every test, golden file, fixture, and docs quote that asserts it, in the same commit. Find them with `git grep -n -F '<the old text>'` across the whole repo, not only your slice; a docs quote outside your slice that mirrors your string is yours to update too (and its page brief in `docs/internal/briefs/`, so `check:provenance` holds).

Never change:
- **Editor-facing admin copy.** Text an editor sees in `/admin` (Svelte markup in `src/lib/admin/**`, admin dialog and toast strings), such as "Your own custom rules" and "These edits are on their own branches". Leave it and list it in your report.
- **Identifiers, keys, flags, file names, JSON field names, and code spans in docs.**
- **Historical records:** `CHANGELOG.md`, `docs/internal/**` (except page briefs mirroring a changed quote), `docs/specs/**`, `docs/plans/**`, `docs/research/**`, `tool/docs/design/**`, `tool/docs/adr/**`, any `history/` directory, and migrations (`**/migrations/**`, which must stay byte-identical).

## Coupled files

- **Generated template files.** `templates/waymark/.claude/**`, `templates/waymark/README.md`, and `templates/waymark/CLAUDE.md` are baked by `npm run emit:template` from repo-root `claude/`, `skills/`, and `packages/create-cairn-site/template-repo`. Edit the source, then run `npm run emit:template`, and commit both. `npm run -s check:template` must pass.
- **Mirrors.** Files under `templates/waymark/` with a twin under `examples/showcase/` (same path after the prefix): when identical before you start (`cmp`), keep them identical.

## Checks

Run what applies before each commit. Setup when needed: `npm ci --no-audit --no-fund` once.
- Go (`tool/`): invoke the `go-conventions` skill before editing; run `make -C tool check`. Update goldens with the package's documented `-update` flag only when your string change is the reason they differ.
- TS and Svelte: `npm run -s check:comments`, `npm run -s lint`, `npm run -s check`, and `npx vitest run <the test files touching your change>`.
- Scaffolder (`packages/create-cairn-site`): its own `npm test` from that directory if it has one, else the root `npx vitest run packages`.
- Templates: `npm run -s check:template`, `npm run -s check:chassis-boundary`.
- Docs quotes: `npm run -s check:editor-quotes`, `npm run -s check:provenance -- <brief>`.

A check that fails on a line your diff did not touch is pre-existing: report it and go on. Never use `git stash`.

After your last edit, run this dangling-idiom scan on your diff and fix every hit it shows:
`git diff origin/main -U0 | grep '^+' | grep -n -i -E "\b(of|on|in|with|for|to) (its|their|his|her|your|our|the \w+'s|\w+'s)([.,;:)]| (and|or|but|is|are|was|that|which|when|so|as|to|in|on)\b)"`

## Commit

Commit only your files by name, never `git add -A`. Message: "Drop the empty own from <slice name>", a blank line, then `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`. Split into a few commits if the diff is large.

## Report

Reply with:
- Your commit SHAs.
- Hits found, removed, reworded, and kept (contrast and idiom counts).
- Every runtime string you changed, as `file:line old -> new`, and the tests, goldens, and docs quotes you updated for it.
- Each editor-facing string you left, as `file:line`.
- Each check's result, and anything you were unsure of.
