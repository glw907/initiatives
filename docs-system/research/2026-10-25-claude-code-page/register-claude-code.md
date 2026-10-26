# Register edit: Using Claude Code with cairn

Page: `docs/claude-code/using-claude-code-with-cairn.md` (worktree `claude-code-page`, commit 542262e03).
Track: Claude Code (`docs/claude-code/`). Base guide: Google. Brief: "Drafting brief: developer docs", plus the
Claude Code track profile, Names, and the task-guide anatomy. Blueprint read beside it.

Verdict: **fix**. 26 findings, 8 of them BLOCKING (6 base-guide structure, 1 base-guide heading, 1 logic/truth).

## Deterministic floor

- `tellgrader --register docs` (profile `docs-register`, resolved on its own): exit 0, **no findings**, no gate.
  Counts: 1 tricolon, 1 uniform paragraph (informational).
- Vale: 0 errors, 18 warnings, 15 suggestions. The warnings that matter are carried below: `Cairn.Headings` on the
  H1 (B7) and `Google.Headings` on "Wire the Stop hook" (N15). The rest are noise or house usage: "stylesheet"
  (extend arm's settled usage across six pages), "CLI" inside the reference page's own title, the Oxford-comma
  false positives on lines 71 and 249, "admin" (free on this track), `Cairn.NamesRetired` on "the package" (each
  use is a fact about the shipped snippet files, the sense the Names table allows), and passive-voice suggestions.

### Measurements

| Measure | Value | Source |
| --- | --- | --- |
| sentences | 168 | tellgrader `measures` |
| hinged_pair_share | 0.351 | tellgrader `measures` (no band; not a threshold) |
| short_sentence_share | 0.190 | tellgrader `measures` (no band; not a threshold) |
| average sentence length | about 14 words (prose, list items, and table cells) | my count |
| longest sentence | 33 words, line 41 ("Each file sits where Claude Code looks for it: ...") | my count |
| prose paragraphs | 56 | my count |
| disproportionate blocks | Verify step 1 (lines 209-226: one step carrying an exit-code list, a nested four-item algorithm, and a freshness note); the second CI-table Fix cell (line 282, about 90 words) | my reading |

## BLOCKING findings (base guide first)

### B1. The CI procedure's numbered list is broken by unindented explanation (BLOCKING, structure)

Lines 186-195. Step 1 ends at line 186; then an unindented paragraph ("The choice turns on the exit codes. ...")
and an unindented code block (the scaffold's last step) sit at column 0, and "2." at line 195 opens a second
ordered list that starts at 2 with no introducing sentence.

Rules: "A sequence of actions is a numbered list introduced by a complete sentence"; "A complete sentence
introduces every list"; anatomy, "Explanation stays subordinate to the steps". The block at lines 190-193 also
repeats the last two lines of the snippet shown in step 1.

Rewrite: move the exit-code reasoning above the procedure, drop the duplicate block, and show the result in step 2.

> The scaffold's workflow reports a stale or missing guidance tree in its job log without failing the build. Its
> guidance step runs `npx cairn-guidance check` without `--strict`, under `continue-on-error: true`. Once its
> arguments parse, `check` exits 0 whatever the report says, and `--strict` exits 1 only when the guidance tree
> is stale or missing. Gating the build therefore takes both `--strict` and removing the `continue-on-error`
> line.
>
> To make the step gate, follow these steps:
>
> 1. If the site has no `.github/workflows/check.yml`, create it from the package's `check.yml` snippet.
>
>    (snippet, indented, as now)
>
> 2. In `.github/workflows/check.yml`, replace the guidance step with the following:
>
>    ```yaml
>    - run: npx cairn-guidance check --strict
>    ```

The paragraphs at lines 197-199 then follow the list unchanged in position (see N1 for line 197's wording).

### B2. List item over 26 words, line 5 (BLOCKING, 26-word cap)

"A site scaffolded by `create-cairn-site` already carries the tree, and the developer wants to know what Claude
Code now reads and which skill loads for which task." (27 words, list item.)

Rewrite: "A site created by `create-cairn-site` already carries the tree, and the developer wants to know what Claude
Code reads and which skill loads for each task." (25)

### B3. List item over 26 words, line 6 (BLOCKING, 26-word cap)

"An existing site adopts the tree, or refreshes it after an engine upgrade, and the developer wants to know what
`install` writes and what it leaves to them." (28)

Rewrite: "An existing site adopts the tree, or refreshes it after an engine upgrade. The developer wants to know
what `install` writes and what it leaves to them." (13 + 15)

### B4. List item over 26 words, line 15 (BLOCKING, 26-word cap)

"How to wire the `Stop` hook that runs the site's `check:cairn` script when a Claude Code turn ends, including
adding that script on a site without one." (27)

Rewrite: "How to wire the `Stop` hook that runs `check:cairn` when a Claude Code turn ends, and add that script
where it's missing." (22)

### B5. Task-section sentence over 26 words, line 259 (BLOCKING, 26-word cap)

Install table, third row, Cause cell: "The run hit a filesystem failure it can't step past, such as a failure creating
a directory, writing the `MANIFEST`, or reading a destination that already exists." (27, in "Diagnose an install
or check failure", a task section.)

Rewrite: "The run hit a filesystem failure it can't continue past. Examples are a failure creating a directory,
writing the `MANIFEST`, or reading an existing destination." (10 + 16)

### B6. Task-section sentence over 26 words, line 292 (BLOCKING, 26-word cap)

Check table, Tailwind row, Cause cell: "No `.gitignore` line ignores `.claude`, and the first of `src/admin.css` and the
`admin.css` under `src/theme/` that carries `@source` or `source(none)` holds neither the `@source not
"./.claude";` line nor `source(none)`." (29)

Rewrite: "No `.gitignore` line ignores `.claude`. The first of `src/admin.css` and the `admin.css` under
`src/theme/` that carries `@source` or `source(none)` holds neither the `@source not "./.claude";` line nor
`source(none)`." (5 + 24)

### B7. The title opens on an -ing word (BLOCKING, heading form; Vale `Cairn.Headings`)

"# Using Claude Code with cairn"

Rule: "no heading opens on an -ing word where another form serves"; a task guide's title takes a bare
infinitive. Another form serves here.

Rewrite: "# Work on a cairn site with Claude Code" (or "# Set up Claude Code on a cairn site"). The title comes from
the outline, so the rename also touches `docs/claude-code/README.md` line 6 and the outline entry; flag it to the
planner rather than renaming in the draft alone.

### B8. "Two edits are left to you" is false on the page's own evidence (BLOCKING, logic: contradiction)

Line 10: "Two edits are left to you: the `Stop` hook in `.claude/settings.json`, and a CI gate if you want one."

The page itself leaves more: Adopt step 2 says "the import line is yours to add" (line 86); "Wire the Stop hook"
step 2 has the reader merge `package.json` scripts; the check table's third row has them paste the
`cairn-audit.config.json` and `check.yml` snippets. The track's success criterion is that the reader "has made or
deliberately declined each edit cairn leaves to them", so an undercount in the introduction misleads exactly the
reader the track serves. (Also carried to the claims checker: the `.claude/` Tailwind exclusion is another edit
the reference asks for, and see N14 for the commit step.)

Rewrite: "Every edit outside `.claude/` is yours to make or decline, from the import line in the root `CLAUDE.md` to
the `Stop` hook and an optional CI gate."

## Register findings (not blocking)

### N1. Balanced halves (hunt first)

- Line 8: "The rest of cairn's docs assume you work without a coding assistant, and this page is the one that covers
  working with Claude Code." Rest-of-docs against this-page, set side by side for symmetry. "This page is the one"
  is also a universal the track will outgrow; the track profile places Claude Code material in the track, not on
  one page. Rewrite: "cairn's other docs assume you work without a coding assistant, and what is specific to Claude
  Code lives in this section." If the symmetry still reads, cut to: "What is specific to Claude Code lives in this
  section of the docs."
- Line 52: "because the root file is the site's and the fragment under `.claude/cairn/` is the package's to
  refresh." A possessive echo pair. The claim underneath is what `install` does. Rewrite: "`install` replaces the
  fragment under `.claude/cairn/` when it refreshes the tree, and it never rewrites the root file. The site's
  guidance for Claude Code therefore belongs under `# Your site`."
- Line 197: "`--strict` sets the step's exit code, and GitHub's `continue-on-error` setting decides whether a
  failing step fails the job." X sets A, Y decides B. Rewrite: "`--strict` only changes the exit code. Whether a
  failing step fails the job is GitHub's [`continue-on-error`](...) setting, which the workflow syntax reference
  defines."

### N2. Trailing-hinge cluster, lines 98-100

Line 98 ends ", because `install` never writes that file", then hangs an appositive and a "for you to paste in
deliberately" tail; line 100 opens on ", so the engine leaves that one edit to you." Three hinged tails in a row
across the break. The first reason is also circular: you add it yourself because the installer does not, which
restates the fact. Rewrite:

> The `Stop` hook runs `npm run check:cairn --if-present` [when a Claude Code turn ends](https://code.claude.com/docs/en/hooks#stop).
> It lives in `.claude/settings.json`, a file `install` never writes. A hook gives the package's code unattended
> execution inside a Claude Code session, and the engine leaves that grant to a deliberate edit of yours.
> [The trust boundary](../reference/guidance.md#the-trust-boundary) in the `cairn-guidance` reference records the
> reasoning.
>
> The package ships the whole hook block as `claude/snippets/settings-hook.json`:

### N3. Figurative language

- Line 41: "A scaffolded site is born with all of it installed." Rewrite: "A site created by the setup command starts
  with all of it installed."
- Line 56: "The skills are the part of the tree that acts on the task you ask for." Skills do not act; Claude Code
  loads them. Rewrite: "Of the files in the tree, the skills are the ones Claude Code loads by task."
- Line 188: "The choice turns on the exit codes." Absorbed by the B1 rewrite.

### N4. Restatement

- The `install` exit-0 fact appears at line 10 and again near-verbatim at line 90. Keep it in the Adopt section,
  where the reader acts on it; cut the intro's sentence or reduce it to "what `install` and `check` print is how you
  learn what they did."
- `check`'s exit codes: line 188 and the step-1 list at lines 213-214 say the same two things. After B1 moves the
  CI statement up, the Verify step can carry only the exit-2 case and the uncaught-error note, with a pointer back.
- "never rewrites the root `CLAUDE.md`": lines 10, 86, and 289.
- The `cairn-consult` protocol is left out twice: line 27 and line 69 ("this page doesn't teach it", which is also
  prose about the docs). Cut line 69's second sentence.
- Lines 251 and 253 are two consecutive table introducers. Cut 251; each table already has its own.
- Line 41's second clause ("the skills and the review agent sit in `.claude/skills/` and `.claude/agents/`")
  restates the list two lines below. End the sentence at the import link.

### N5. Equivocation on "the tree"

Line 41 says the guidance sits "entirely under `.claude/`" apart from the root `CLAUDE.md`, but "The tree holds
the following paths" (line 43) then lists `CLAUDE.md` at the project root as a tree path (line 50). Elsewhere
`install` "writes under `.claude/` alone" and writes "the tree". The root file is either in the tree or not.
Rewrite: introduce the list as "The tree under `.claude/` holds the following paths:", drop line 50, and keep the
root file in the prose sentence that follows (line 52).

### N6. Overstated universal, line 52

"The root `CLAUDE.md` is the one import line, then a `# Your site` section for the site's guidance." True of a
scaffolded site; on an adopting site the root file is whatever the developer wrote, plus the line they add.
Rewrite: "On a scaffolded site, the root `CLAUDE.md` is the one import line, then a `# Your site` section for the
site's guidance."

### N7. Verify step 1 carries reference material, and the report lines are named two ways

Step 1 nests the Tailwind line's four-part judging order (lines 219-224), which the Tailwind row of the check
table restates (line 292) and the reference owns. Anatomy: "Anything more (a full output listing, the behavior's
limits ...) belongs on the reference entry ... linked from the step that needs it." Keep the order in one place;
the Diagnose row is where a reader needs it. Also, "in a fixed order" at line 219 dangles (it reads as modifying
the Tailwind build).

The page then names `check`'s lines by ordinal in Diagnose ("The first line", "The second line", "The seventh
line") but by content in Verify ("One line", "The Tailwind line", "The freshness line"), and never lists the
seven, so the reader cannot map "seventh" to anything. Name every line by content: "The freshness line", "The
import line", "The `.orig` line", "The Tailwind line". Proposed step-1 body:

> The check prints seven report lines. Under `--strict`, it exits 1 only when the guidance tree is stale or
> missing, and an unknown command or flag prints the usage to stderr and exits 2. The freshness line ignores the
> `VERSION` stamp, so a tree that differs only there reads fresh. For every line `check` prints, see
> [`check`](../reference/guidance.md#check) in the `cairn-guidance` reference.

### N8. The refusal list sits after the table that needs it, and one Fix cell is flat

- Line 257's Cause, "The path is one `install` won't write," says nothing until the list at lines 261-268 is read,
  and a reader can't be pointed "below" (a reference names its target, never its position). Move the refusal list
  above the install table, introduced as now, and make the Cause "The path matches one of the refusal cases. The run
  names it and continues."
- Line 291, the `.orig` row: the Fix is only a link, but the reference states what to do (".orig files are meant to
  be read and deleted"). Rewrite the Fix: "Read the `.orig` file for any edit you want to keep, move that edit under
  `# Your site` in the root `CLAUDE.md` if it is guidance, then delete the `.orig` file." If the planner wants no
  claim past the reference, use: "Read the `.orig` file, keep any edit you need, then delete it. See
  [`install`](../reference/guidance.md#install)."

### N9. "Healthy" contradicts the optional workflow (logic)

Line 205: "A healthy setup reports the tree fresh and every other line satisfied". The page calls the CI gate
optional and the workflow line is one of the seven; a site that declines the workflow never reads "healthy".
Rewrite: "A healthy setup reports the tree fresh and every line you chose to satisfy satisfied, and `check
--strict` exits 0." Simpler: "A healthy setup reports the tree fresh and the import line present, and `check
--strict` exits 0."

### N10. Person shifts inside the introduction

Paragraph 1 and its list speak of "a developer ... their"; paragraph 2 switches to "you". Google's voice is second
person. The B2/B3 rewrites keep third person to stay minimal; if the planner prefers, recast lines 3-6 in second
person ("You may choose Claude Code as your coding assistant on a site built on cairn's seams, and cairn ships
guidance for it to read while it works on the site.").

### N11. Links

- First use of `CLAUDE.md` (line 3) is unlinked; the track's vocabulary contract links Claude Code's terms "there on
  first use". The memory page is linked only at line 41 under the anchor "`@` import". Link the first `CLAUDE.md`
  to `https://code.claude.com/docs/en/memory` and leave line 41's link as is or drop it.
- "Skill" first appears at line 5, unlinked; the link arrives at line 20. Acceptable given the knowledge sentence,
  but the skills URL is then linked again at line 60 under the anchor "description". Drop the line 60 link.
- Overlinking: `guidance.md#install` is linked seven times, `guidance.md#check` five, "What ships under `claude/`"
  three. The intro's leave-to list and See also duplicate four links outright. Wikipedia's first-occurrence rule
  argues for cutting repeats in prose (lines 54, 186); the per-row Fix links can stay, since a row is read alone.
- The subagent link (line 20) never pays off: the page says "the review agent" throughout. Line 46 could read
  "`.claude/agents/cairn-extension-reviewer.md`, the review agent, a Claude Code subagent." Optional.

### N12. "That is the trade ... describes" names a word the section never uses

Line 282: "That is the trade [Make the CI step gate on a stale tree](...) describes." The section says "widens
what fails the build", not "trade" (the word survives from the blueprint). Rewrite: "[Make the CI step gate on a
stale tree](#make-the-ci-step-gate-on-a-stale-tree) describes this wider failure."

### N13. Non sequitur, line 94

"With the tree in place, the one Claude Code setting it needs is yours to add." The tree needs no setting; the
hook runs the audit. Rewrite: "With the tree in place, the `Stop` hook is the one Claude Code setting left to you."

### N14. Missing middle steps (for the claims checker and the planner)

- The Adopt procedure ends without committing the tree, yet the CI-table Fix (line 281) assumes "commit the
  refreshed `.claude/` tree", and the reference says "the whole guidance tree belongs in the site's commit". A
  gated site that runs Adopt and pushes without committing fails at the guidance step. Proposed step 3: "In the
  project root, commit the `.claude/` tree and the root `CLAUDE.md`."
- The `.claude/` Tailwind exclusion is an edit the reference asks every site to make, so the skills' quoted class
  names never compile into shipped CSS. The page only diagnoses its absence (line 292); no step asks for it. A
  blueprint-scope question, not a wording fix.
- Wire step 2 merges `precheck`, `prebuild`, and `predev`, which replace any same-named scripts a hand-built site
  already has, and `build:admin-css` assumes `src/admin.css` and `@tailwindcss/cli`. Verify against the facts
  before adding a caution; do not add one without a fact.

### N15. Code font in the "Wire the Stop hook" heading

`Stop` is code font in every body use but plain in the heading, which is why `Google.Headings` reads it as title
case. Rewrite: "## Wire the `Stop` hook" (the slug `#wire-the-stop-hook` is unchanged in most renderers; confirm
on cairn.pub's renderer before merging, since five links point at it).

### N16. The shipped `check.yml` comments carry scaffold-only claims and contributor vocabulary

The snippet quoted in CI step 1 says "The scaffold ships no lockfile (the bake deletes it), so this installs from
package.json rather than npm ci." Step 1 serves a site with no workflow, most likely a hand-built one, for which
both comments are wrong, and "the bake" is contributor-zone vocabulary on a published page. The page already
omits one comment; omitting the other two the same way, or adding one sentence that the comments describe the
scaffold, fixes the page. The snippet file itself is the engine's to fix (a friction-log candidate).

### N17. Diagnose overview order differs from the tables

The four-item list at lines 246-249 runs install, check, hook, CI; the tables run install, hook, CI, check. Match
the tables' order.

### N18. VERSION paragraph ends on a negation, line 54

"The scaffold resolved that spec when its template was built, and the stamp isn't a version read from
`node_modules`." The reader's question is whether the mismatch matters, which the page answers 170 lines later
(the freshness line ignores the stamp). Rewrite: "On a scaffolded site, `VERSION` holds the engine dependency spec
with its caret stripped, fixed when the scaffold's template was built rather than read from `node_modules`.
`check` ignores the stamp when it judges freshness. For the stamp `install` writes, see
[`install`](../reference/guidance.md#install) in the `cairn-guidance` reference."

## Clean on

No marketing, no virtue claims, no softeners, no intensifier "own", no question or teaser headings, no
two-headed headings, no setup-colon triad in prose, and no em-dash rhythm. The page addresses the developer
throughout, never Claude Code, names no other agent, and gives other agents the one introduction line the track
requires. Claude Code's mechanics (Stop timing, skill discovery, hook output) sit behind links to its docs, as the
vendor rule and track profile require. Examples are generic; no consumer-site domain leaks in.

## Verdict

The prose reads as the cairn docs voice's plausible author: measured, contract-first, linked where the vendor owns
the detail, and free of pitch. It is not ready because of structure and one false count. Five sentences break the
26-word cap in list items and task-section table cells. The CI procedure's list splits in two around unindented
explanation. The title opens on an -ing word. And the introduction's "Two edits are left to you" undercounts what
the page itself goes on to hand the reader. The single change that would move it most is B1 together with N4: move
the exit-code reasoning above the CI procedure and state each exit-code fact once, which repairs the broken list
and removes the page's main source of repetition.
