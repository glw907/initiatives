# Docs layout design

## Brief

Approving this design starts a pass that moves every repo's `docs/superpowers/` folder up to `docs/`, so specs, plans, and research live under names that say what they are.

The `superpowers` folder name comes from a plugin the workstation no longer runs (`workstation`#105), yet 13 repos hold about 1,700 files under it, and about 1,400 tracked files cite the path. Two repos, `aksailingclub-org` and `fishwright`, already use the neutral layout.

### What changes

- In each repo, `docs/superpowers/specs`, `plans`, `research`, and `archive` become `docs/specs`, `docs/plans`, `docs/research`, and `docs/archive`. Any other folder or loose file moves up one level with its name unchanged.
- Every tracked file that cites `docs/superpowers/` cites `docs/` instead, across all repos, so a citation of another repo's spec stays correct.
- The workstation's skills, agents, `CLAUDE.md`, and the monthly-review prompt name the new paths.
- A check in `workstation` and one in `cairn-cms` fail when the old path comes back.

### If you approve

1. You start the pass from a `repo-organization` session. It writes the plan, has it reviewed, and runs it with no questions to you.
2. Docs-only PRs merge themselves. The `workstation` PR and the `cairn-cms` check-script PR come to you in one packet at the end.

### Standing answers

- A merge of an open branch that adds a file under the old path recreates the folder. The run reruns the move script on that repo and opens a follow-up PR.
- A repo whose gate fails for a cause the move didn't make keeps its PR open, and the packet names the cause.
- `drafter` waits until the B3c pass merges, then runs last.

## Outcome

No tracked file in any repo in this initiative's `repos` list lives under `docs/superpowers/`. No tracked file cites that path, except the records below that state a past path as a fact. The two guard checks are in place.

## Files and interfaces

- **The move script**: `repo-organization/tools/docs-layout`, idempotent, with one argument, the repo path. It runs `git mv` for each child of `docs/superpowers/` into `docs/`, refuses a collision with an existing `docs/<name>` that holds files, then replaces the prefix `docs/superpowers/` with `docs/` in every tracked text file, skipping the excluded records.
- **Excluded records**: a file that records a past path as a fact keeps it. That covers `repo-organization/research/migration-map.tsv`, the retirement log and manifest, and any file whose old path sits beside a commit pin. The plan lists each one.
- **By hand**: `cairn-cms`'s `scripts/checks/` (`check-idioms.mjs` and its `superpowers-path` fixture, `docs-links.mjs`, `check-consumers.mjs`, `transcript-blocks.mjs`, `check-surface-leaks.json`) and `packages/create-cairn-site/src/cloudflare/api.mjs`. Each is read before it changes, and the idiom check becomes the cairn-cms guard.
- **Guard in `workstation`**: `docs/superpowers` joins the retired names that `scripts/check.sh` keeps absent.
- **Repos**: `workstation`, `cairn-cms`, `dubplate`, `poplar`, `ecxc-ski`, `907-life`, `xcathletes-org`, `phonebook`, `cairn-themes`, `aksailingclub-legacy`, and the citation-only repos `initiatives`, `aksailingclub-org`, `cairn-pub`, and `drafter`.

## Out of scope

Commit messages, GitHub issue and PR bodies, memory files, and git history. No file's content changes beyond its path citations.

## End-to-end check

For every repo in the list, `git grep -l 'docs/superpowers'` on the default branch prints only excluded records, `test ! -e docs/superpowers` succeeds, and each repo's gate is green.

## Risk class

`ordinary` for the docs moves. `runner` for the `workstation` PR (skills, agents, and `scripts/check.sh`) and for `cairn-cms`'s `scripts/checks/`.

## Pre-flight

None foreseen. `gh` is signed in as `glw907` with push to every repo in the list.

## Estimate

240 path minutes: the script and its fixture test, one repo at a time with its gate, `cairn-cms` by hand, then the end-to-end check.
