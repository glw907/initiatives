# Survey house style: design

## Brief

This makes Survey the one house style for every house tool, in how it looks and in how Claude writes, kept in one public repo that every other repo pins by git tag.

Survey's visual style exists in three places that have drifted apart: the approval queue's vendored copy, the cairn-themes spec of 2026-10-07, and its approved specimen. Bulwark webmail and the phonebook's UI both wait on it. The writing voice works well today, but it is spread across an output style, six registers, a charter, and five hand-copied Vale styles, with no version and no regular path for your corrections.

### What changes

- A new public `survey` repo holds the visual theme, the writing files, a short skill, and a changelog. Each release is a git tag.
- The visual theme ships as a daisyUI theme, a plain CSS-variable sheet for apps with few theming hooks, and a DESIGN.md that agents read first.
- The writing files move into Survey word for word, and one Vale style replaces the five copies. The workstation and cairn read Survey's copy at a pinned tag.
- Your corrections to Claude's writing go to a private log, and the monthly model review grades a small sample and proposes Survey changes for your approval.

### If you approve

1. Pass 1 compares the three visual versions and brings you the differences in one sitting, then builds the repo and tags `v1.0.0`.
2. Pass 2 moves the writing into Survey, points the workstation and every repo with prose at it, and tags `v1.1.0`.
3. Pass 3 starts the corrections log and adds the writing step to the monthly model review.
4. The approval queue, the phonebook, Bulwark, and 907.life's later rebuild each take the visual theme in a pass of their own.

### Worth knowing

The work is three passes and about 520 minutes. You have one sitting, Pass 1's visual rulings, plus the usual merge packets. This replaces a larger design you rejected on 2026-10-22 as over-engineered; that version stays in git history at commit `63fc234`. There is no npm publishing: a repo installs Survey from GitHub at a tag, and a rollback is pinning the previous tag.

### Standing answers

Approving the design approves these answers, so the run takes them without asking you.

- A pass that runs past 1.5 times its estimate stops and reports.
- A file the move would change, even by a byte, stops that file's move. The workstation keeps its current copy, and the PR lists the file.
- A visual value that fails contrast is tuned within its hue, and the PR's `## Decisions` lists the old and new values.
- A repo with no prose is left out and listed with the reason.

### Rulings

These stand (Geoff, 2026-10-21 and 2026-10-22). Survey is the house style for every house tool's UI, and it carries the house writing register and its copy-editing rules. It lives in a public repo, is versioned with a changelog, includes a drop-in daisyUI theme, and is agent-friendly from the ground up. Every writing context is first a good instance of its own published standard, with Survey's flavor on top. Today's writing voice must not break. Cairn's docs move to the Survey register in Pass 2, and the small risk to partly drafted pages is accepted. 907.life takes Survey in its full rebuild, after the cairn docs are complete, so nothing here waits on it. Survey is not a Claude Code plugin. Bulwark's theme waits for Survey.

On 2026-10-22 Geoff rejected an eight-pass design as over-engineered and approved this three-pass shape. It drops the conventions skills from the move, npm publishing, the statistical eval harness, the separate ledger repo, the approval-queue and cairn-editor intake channels, and a planned twelve-pack build. Each could return later if a real need appears.

## Design

### The repo

`glw907/survey` is public. Its layout:

- `tokens.json` holds every color, radius, font, and motion value in light and dark, in the W3C design-token (DTCG) format. It is the one source for the visual side.
- `scripts/build` is a short Node script with no dependencies. It writes `theme/survey.css` (the daisyUI 5 `@plugin "daisyui/theme"` blocks for light and dark), `theme/survey-vars.css` (the same values as plain `:root` variables), and the token table inside `DESIGN.md`. The built files are committed, and the gate fails when they are stale.
- `theme/components.css` and `theme/fonts.css` carry the shared CSS from the approval queue's copy.
- `DESIGN.md` states the principles, the token table, and each app's recipe. Agents read it first.
- `skills/survey/SKILL.md` tells an agent where each piece is and which to read for the task at hand. It also says the writing files are edited in this repo only, since a workstation edit to a vendored copy is overwritten by the next update.
- `skills/survey/writing/` holds the writing files (see Pass 2). Keeping them inside the skill lets one vendored-skill entry carry both.
- `vale/Survey/` is the one Vale style.
- `package.json` is minimal: a name, a version, `files` naming `theme` and `DESIGN.md`, and devDependencies on `@glw907/cairn-cms` and `daisyui` for the contrast check. A `cairn-audit.config.json` points the check at `theme/survey.css`.
- `CHANGELOG.md` follows Keep a Changelog. A version follows SemVer: a changed value or rule is a minor, and a removed or renamed one is a major.

The gate is `scripts/gate`. It checks that the build is current and that contrast passes (`npx cairn-audit --rule theme-contrast --fail-on advisory`). Pass 1 step 3 probes the contrast check once; if the rule can't read a bare theme sheet, it is cut from the gate, and each cairn site's own contrast check covers the theme there.

### Releasing

A release is a changelog entry, a tag, and `gh release create` with `Survey.zip` attached, all from one `scripts/release <version>` command. The script zips from inside `vale/`, so the zip unpacks to one `Survey/` folder, as Vale requires. Repos take Survey three ways:

- A repo with a `package.json` runs `npm install github:glw907/survey#v<version>`.
- A repo's `.vale.ini` names the release's `Survey.zip` URL in `Packages`. The repo runs `vale sync` once locally and commits `.vale/styles/Survey/`, so CI stays offline and unchanged.
- The workstation vendors `skills/survey/` through `claude-tooling-sync`, with the tag in the manifest's `branch` field. The GitHub API resolves a tag there (probed on `cairn-cms` at `v0.98.0`).

Taking a new version is editing one tag in each place and, for Vale, syncing and committing again. A rollback is the same edit back to the previous tag.

### Pass 1: visual (about 240 minutes)

1. Compare the three versions token by token and bring Geoff a one-page table of the differences, each with a recommended value, in one sitting (60).
2. Write `tokens.json` from the rulings, the build script, the shared CSS, and DESIGN.md with the recipes: the cairn admin, the cairn site, a plain app, and a theme-limited app such as Bulwark (120).
3. Write the skill, the gate, and the release script, and tag `v1.0.0` (40).
4. cairn-themes gives up `survey-theme/`, its Survey spec, and its backlog items #1 and #2, each with a pointer to the new repo (20).

The approval queue's copy stands for commit `dea9839`, which exists on neither GitHub nor pavilion; its `survey.css` and `fonts.css` headers record that they were copied from it.

### Pass 2: the writing move (about 180 minutes)

The move copies, then links. Nothing is rewritten.

1. Copy each file into `skills/survey/writing/` byte for byte: the `writing-voice` output style, the six registers in `~/.claude/docs/voice/`, and the authoring charter. Prove each copy with `cmp`. The go, ts, svelte, and python conventions skills stay where they are, since they already load as skills; Survey's skill points to them (40).
2. Build `vale/Survey/` from the `glw907` style that five repos copy by hand (cairn-cms/tool, cairn-themes, dubplate, phonebook, poplar; all identical), and run each repo's Vale before and after to show the same findings. That run is the style's proof (40).
3. Tag `v1.1.0`, vendor it on the workstation, and replace each workstation file with a link to its vendored copy. The output style goes last. Confirm that `claude -p "/output-style"` lists `writing-voice (current)`, and run `claude-tooling-sync verify` (40).
4. Point each repo with prose at Survey, one PR each. Swap the hand-copied style for the synced `Survey` style, restore any other style directory the sync touched (phonebook's `Google`) with `git checkout`, and rename each `glw907.*` override in `.vale.ini` to `Survey.*` (40).
5. Move cairn's docs: cairn's `docs-register.md` keeps its cairn-only rules and points at Survey for the rest, and the agents that read it follow. A cairn page mid-draft finishes on the register it started with (20).

A file whose copy differs from its source by any byte doesn't move, per the standing answers. Because the content is identical, no eval run is needed to show that nothing broke.

### Pass 3: corrections and grading (about 100 minutes)

1. A private repo, `glw907/survey-notes`, cloned at `~/Projects/survey-notes` on both hosts, holds one file per correction, named by date, time, and host so two hosts never collide. When Geoff corrects Claude's wording in chat, the `survey` skill has Claude write the before, the after, the context, and his reason, then commit and push. The output style names this step, so it runs without his asking. That edit lands in the Survey repo and ships as `v1.2.0` through `claude-tooling-sync update-skills survey` (50).
2. The monthly model review gains one step, run on pavilion only. It drafts a fixed set of ten samples across the main kinds of writing, checks them with Vale and `tellgrader`, and compares them with last month's drafts and with the month's corrections. It then proposes Survey changes, each with a before-and-after example, in one packet for Geoff. An approved change is a Survey minor (50).
The house register's flavor and the examples for each kind of writing grow from here, one approved change at a time.

## Later

- An npm package, if a repo outside this workstation needs Survey.
- Intake from approval-queue edits and the cairn editor, if chat corrections miss too much.
- A Survey plugin, under the shared-standards initiative.

## Left to the builder

The exact token names, the build script's structure, the ten monthly samples, the corrections file format, and the wording of the skill.
