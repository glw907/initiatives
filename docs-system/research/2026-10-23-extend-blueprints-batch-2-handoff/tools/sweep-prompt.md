# Sweep the empty "own" from one slice of cairn-cms

You are one of eight agents. Each works a disjoint slice in its own git worktree. Work only in your worktree and only on the files in your slice. Never push.

- Worktree: WORKTREE (run every command there)
- Slice: SLICE

## Why

Geoff flagged the empty intensifier "own" as an AI writing tic: "Own adds nothing, and reads awkwardly." His examples were "a site's own screen" and "links the site's own screens". The cairn register (`docs/internal/docs-register.md`, the developer brief's Tells) already bans it as "No intensifier own". This sweep removes it from the repo's live prose.

## What to change

Find candidates with `git grep -n -i -E "\b(\w+'s|its|their|your|his|her|our) own\b" -- <your slice>`, and also check bare `own` near a possessive. Judge every hit in its sentence:

- **Empty, so remove it.** The sentence means the same with "own" deleted. Most hits are this kind. Delete "own" ("the site's own render" becomes "the site's render", and "its own row" becomes "its row"). If deleting it leaves the possessive awkward, reword minimally ("its own" might become "a separate" or "the").
- **Contrastive, so keep it.** The sentence sets the owner against another party named in the same sentence or the one before it, and the reader would lose that contrast. Example: "cairn's tokens sit beside daisyUI's own theme variables" keeps it if the point is whose variables they are. A contrast you have to argue for is not one. Remove the word.
- **Idioms stay.** "on its own" (meaning alone or unaided) and "of its own accord" are idioms, so keep them.
- **Verb and adjective "own" stay.** Examples are "the site owns", "owner", and "owned", and also "own" as a verb ("a pass that owns the file").

## What never to change

- **Runtime text.** Never change anything the program emits or the tests assert. That covers string literals, template literals, error and log messages, CLI output, Svelte markup text, `aria-*` and `title` attributes, and test names and assertions. In code files you change comment text only: `//`, `/* */`, `/** */`, `<!-- -->`, and CSS comments. After you finish, review `git diff -U0` and confirm that every changed line in a code file is a comment line. List each runtime-text hit you left in the report, as `file:line`.
- **Quoted text.** A docs sentence that quotes UI copy, an error message, or a log message verbatim keeps the quote, because `check:editor-quotes` matches quotes to the source.
- **Code.** Identifiers, code spans in docs (`` `...` ``), and code fences all stay as they are.
- **Out-of-slice paths.** Never touch `docs/internal/**` except the page briefs (below), `CHANGELOG.md`, `docs/specs/**`, `docs/plans/**`, `docs/research/**`, any `history/` directory, `blueprints/outline.yaml`, or `blueprints/docs/admin/troubleshooting.blueprint.md`.

## Coupled files

- **Page briefs.** A published page under `docs/` may have a brief at `docs/internal/briefs/<track>/<page>.json`. Each brief lists the page's sentences verbatim, and `npm run -s check:provenance` fails on any sentence it cannot match. When you change a page sentence, make the identical change to the brief's `text` for that sentence. Run `npm run -s check:provenance -- <brief path>` for each brief you touched.
- **Mirrors.** Many files under `templates/waymark/` have a twin under `examples/showcase/` (same path after the prefix). When the two files are identical before you start (`cmp`), keep them identical. When they differ, edit each one on its own terms.
- **Blueprints.** After editing a blueprint, run `drafter check <file>` on it. Its warnings were there before you started; fix only an error your edit caused.

## Doing the work

- Work file by file. In large files, apply edits with a short Python script that asserts each old span occurs exactly once. Never use a blind `sed s/ own / /g`.
- Setup, when your checks need node_modules: run `npm ci --no-audit --no-fund` once in your worktree.
- Checks to run before committing, depending on what you touched:
  - Docs pages: `npm run -s check:vale`, `npm run -s check:docs`, `npm run -s check:editor-quotes`, and `check:provenance` per brief.
  - Code: `npm run -s check:comments` and `npm run -s lint`.
  - Templates: `npm run -s check:template` and `npm run -s check:chassis-boundary`.

  If a check fails on a file or line your diff did not touch, report it as pre-existing and go on. Never use `git stash`, because the stash stack is shared with other sessions.
- Commit only your slice's files by name, never `git add -A`. Use the message "Drop the empty own from <slice name>", then a blank line, then `Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>`. Split into more than one commit if the diff is large.

## Report

Reply with:
- Your commit SHAs.
- The number of hits found, removed, reworded, and kept.
- Each kept contrastive hit with a one-line reason, and the idioms kept as a count.
- Each runtime-text hit you left, as `file:line` and its text, trimmed.
- Each check's result, and anything you were unsure of.
