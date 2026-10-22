# Survey Pass D review: data integrity and failure risk

Spec: `survey-house-style/specs/2026-10-21-survey-house-style-design.md` at `4827f40`. Scope: "The writing register and copy-editing rules" (L124-133), "Pass D" (L165-172), the "cairn's docs" bullet (L181), and the Pass D lines in "Stops" (L211-212), "Risk and estimate" (L217), and the sittings paragraph (L226). Line numbers below are the spec's unless a file is named.

Verdict: not ready. One blocker (the drafter mechanism cannot work as written), nine majors, six minors, and two OWNER FORKs (findings 2 and 10).

## Findings, ranked by consequence

### 1. Blocker, correctness: drafter can never inline a file under `node_modules`

Location: L131, L171. Evidence: `drafter/internal/assemble/files.go:144-147` (an absolute path inside the project root resolves only when git tracks it), `files.go:152-156` (`outOfRepo` refuses any path inside the root, even one `inline_files` allows), `files.go:61-75` (`expand` silently drops a relative `inline_files` entry), and `section.go:35-37` (a `<path>#<slug>` token that fails to resolve returns no block at all, not even "not inlined").

Defect: `inline_files` only admits files outside the repository. The path `node_modules/@glw907/survey/writing/` is inside the project root and ignored by git, so every brief section is dropped. The drop is silent, so the drafting seat writes with no register and the run looks normal. A relative entry such as `node_modules/@glw907/survey/writing` is also discarded, and an absolute one differs per worktree, while `drafter.local.toml` is untracked, so a fresh worktree has none. Pass D's acceptance ("a drafter dry run ... inlines a brief section by slug", L171) would catch this only if it asserts the block's text.

Fold: Pass D gains a drafter task, or a drafter pass precedes it. drafter admits a project-relative, git-ignored path named in a project or local setting (for example, `inline_ignored = ["node_modules/@glw907/survey/writing"]`), and a `<path>#<slug>` token that names an allowed path but does not resolve fails the run loudly instead of dropping. The L171 acceptance asserts that the inlined block contains a known sentence from the brief and that a run with the package absent exits non-zero. Allow the narrowest directory, never `node_modules`, since the setting can send any file under it to the API (`drafter/docs/configuration.md:155-157`).

### 2. Major, correctness: four of the five `glw907` repos have no `package.json`, and three use the style to lint Go comments

Location: L130, L181, against the non-goal at L64. Evidence: poplar, dubplate, and cairn-cms `tool/` each have `go.mod`, no `package.json`, and `[*.go] BasedOnStyles = glw907` (comment linting). phonebook and cairn-themes have no `package.json` either. All five copies hash identically today (`171be1d9...`), so there is no drift yet to fix. cairn-cms `tool/.vale.ini` sits in a subdirectory, so `node_modules/...` from there points at nothing.

Defect: "An app lists `... node_modules/@glw907/survey/vale/Survey` ... and runs `vale sync`" cannot work in any of the five repos named. Moving `EmDash`, `Slop`, and the rest into Survey also puts the code-comment linter inside a package whose non-goal says code comments keep their own standards. The em-dash ban on comments is linter-enforced today (global CLAUDE.md), so a careless cutover loses it.

**OWNER FORK** (scope of the Survey Vale style):

- (a) Survey's style carries the audience-invariant tells for every surface, comments included. `publish.yml` attaches a versioned `Survey.zip` to each GitHub release, and a repo without Node lists that release URL in `Packages`, which Vale fetches by URL. The L64 non-goal gains "except the tells linter".
- (b) Split. `glw907` stays as the comment-tells style, still copied, and Survey's style covers prose only. Drift in the copies stays an open problem.
- (c) The Go repos gain a `package.json` only to install Survey.

Recommendation: (a). It keeps one source, needs no npm in a Go repo, and pins the version in the URL. Whichever is chosen, the L181 inheritance line must name the distribution path per repo kind.

### 3. Major, correctness: Pass D's "minor" may fall while Survey is still a release candidate

Location: L24, L167, against L35. Evidence: Pass B publishes `1.0.0-rc.1`, and 1.0.0 is promoted only at the approval queue's convergence pass close, which is outside Passes A to D (L62).

Defect: Pass D runs "after Passes B and C" and "releases them in a minor". If the approval queue has not converged, no 1.0.0 exists, and Pass D's release is `1.0.0-rc.2` under `next`, or Pass D waits on an app pass. The Pass D plan cannot decide which, and a 1.1.0 cut on top of an unpromoted rc would leave `latest` on the deprecated placeholder.

Fold: State the order. Either Pass D waits for 1.0.0 (its precondition names the approval queue's promotion), or Pass D's work ships as `1.0.0-rc.2` and joins 1.0.0. Recommend the second, since the writing part then reaches 1.0.0's stable surface without a minor, and the "every minor" render rule (L35) does not fire on a writing-only change. Add a standing answer to Stops.

### 4. Major, correctness: the "cairn's docs" bullet omits most of cairn's live pipeline contract

Location: L181. Evidence: `drafter/claude/.claude/workflows/docs-page-chain.js:660` takes one `registerPath` file, and `:670-695` selects sections by exact heading strings ("## Drafting brief: developer docs", "## Deviations from the base guides", and others), pinned by `docs-page-chain-derivation.test.mjs`. `:1211-1213` paste two scope rulings verbatim (`CAP_SCOPE`, `HANDOFF_OWNER`). Other live readers: `cairn-docs-drafter`, `prose-voice-reviewer`, `figure-verifier`, `cairn-implementer`, and `site-implementer` agents; `register-check` SKILL.md:75; the global CLAUDE.md "Writing voice" line; cairn's `.tellgrader.json` (`"profile": "docs-register"`) and tellgrader's `posthook.go:51`; and cairn's `Cairn` Vale rule messages that cite "'Names' in docs/internal/docs-register.md".

Defect: The bullet names three readers. A cairn pass that follows it moves the briefs to a second file, and the chain then reads a shrunken register whose headings no longer exist (the chain throws on a missing section only if its derivation test is updated, and the verbatim copies silently go stale). The bullet also gives no rule for a chain run in a worktree that has not run `npm ci`.

Fold: The bullet lists the full reader set above, says the chain gains a second source (Survey's brief path) beside the cairn-only register, and says that every reader fails loudly when the installed package is absent, never falls back to cairn's old text. Add: "cairn's `docs-register.md` stays the authority for cairn until cairn's convergence pass merges; Survey's register is not read by any cairn surface before then."

### 5. Major, correctness: provenance is lost between the harvest and cairn's move

Location: L169-170, L181. Evidence: `docs-register.md:1089-1094` ("Only Geoff adds a row"), `:1108-1111` (ruling ids such as "rulings 3 and 10", "ruling 1 of Pass D, 2026-08-14" in cairn's `.vale.ini`), relative links into `./record/` (`:696`), and rulings that live only in records cited by path.

Defect: Four losses are possible.

- The harvest records no source commits, unlike Pass A (L137). A ruling Geoff adds to cairn's register after the harvest and before cairn converges exists in one copy only, and nothing re-diffs it.
- Relative links such as `./record/2026-08-15-docs-visual-layer-rulings.md` break once copied into a package.
- Bare ruling ids ("ruling 3") collide across sources, and cairn's own 2026-08-14 "Pass D" collides with this initiative's Pass D.
- After cairn shrinks, a cairn-only rule now overlays Survey, which overlays Google. The spec does not say where a cairn-only departure from a Survey rule is recorded or who rules it, so cairn's deviation test (`:1083-1088`) has no defined base.

Fold: The harvest ledger records each source at a commit. Every carried ruling cites a GitHub permalink at that commit, and every ruling id gains a source prefix (`cairn-2026-09-28-r3`). cairn's convergence pass diffs cairn's register from the harvest commit to its head and carries any new row before it shrinks the file. The departures file states the two-level rule: a cairn-only rule that forbids what Survey prescribes is a row in cairn's own table, with Geoff's ruling.

### 6. Major, correctness: the corpus licensing is unsettled for Microsoft and unstated for the package

Location: L128 (corpus "each with its URL, license, and retrieval date"), L11 (a public npm package). Evidence: drafter's Google corpus quotes CC BY 4.0 pages, with attribution, a license link, and a note of changes (`drafter/stock/google-corpus.md:8-11`, `google-description.md:47-55`). drafter ships no Microsoft corpus. The Microsoft Writing Style Guide pages on learn.microsoft.com carry "© Microsoft. All rights reserved." A third-party notice says the guide's GitHub source is under CC BY 4.0, but that was not confirmed at the source here.

Defect: Quoting Microsoft excerpts into a redistributed npm tarball with a "License:" line that may be wrong is a correctness risk. The package's own license (the field in `package.json`, a `LICENSE` file) would claim to cover third-party text it does not own. CC BY 4.0 also requires the attribution and the change notice to travel with every copy, and neither the brief nor the package shape names a NOTICE file in `files`.

Fold: Pass D confirms each corpus source's license at the page or repository that states it, and records that pointer in the excerpt. If Microsoft's license cannot be confirmed, the Microsoft brief carries links and paraphrased rules only, with no quoted excerpts. The package's `license` field becomes an SPDX expression that names CC-BY-4.0 for `writing/` corpora, a `NOTICE` (or `writing/LICENSES.md`) ships in `files`, and each corpus file carries the "not endorsed by" line drafter's does. Add a stop: "A source's license can't be confirmed: quote nothing from it, and list it in `## Decisions`."

### 7. Major, correctness: a user-scope skill installed "from the installed package" has no single installed package

Location: L132, L172. Evidence: `~/.claude/docs/claude-tooling.md:10-25` names no skill kind sourced from npm. `vendored-skills.json` fetches a GitHub source at a commit. The workstation itself, the initiatives repo, and the Go repos have no `node_modules`.

Defect: A user-scope skill can link to only one checkout's `node_modules`. When that checkout is cleaned, re-installed at another version, or absent on thinkpad-x1, the link dangles, and the skill holds one version while each repo installs its own, which contradicts "the skill follows the version". `claude-tooling-sync` needs new code for this kind, which the 320-minute estimate does not cover.

Fold: Copy Pass C's pattern (L158). The user-scope `survey-writing` skill is a short router authored in `~/.dotfiles`. It sends the agent to `node_modules/@glw907/survey/writing/` in the repo at hand, tells it to run `npm ci` first, and says what to do in a repo with no package: fail closed per the charter ("No audience, no system"), or read the release zip from finding 2. The package then ships the brief content, not the skill. This needs no new manifest kind.

### 8. Major, correctness: `vale sync` would replace cairn's vendored, offline base styles

Location: L130. Evidence: cairn-cms commits 33 Google and 48 Microsoft rule files under `.vale/styles`, and its `test.yml:142-143` says the gate "runs offline against the exact rules committed to the repo", under a pinned Vale 3.23.0.

Defect: `Packages = Microsoft, node_modules/...` followed by `vale sync` downloads the hub's current Microsoft package over the vendored one. The base rules then change silently on every sync. The relative path's resolution base (the `.vale.ini` directory or the working directory) is not stated, and it differs for cairn-cms `tool/`.

Fold: Keep base packages vendored and out of `Packages`. The app's gate copies (or symlinks) `node_modules/@glw907/survey/vale/Survey` into a git-ignored `StylesPath/Survey` before Vale runs, and fails loudly when the source is absent. Pass D's scratch-app acceptance tests from a subdirectory `.vale.ini` too.

### 9. Major, correctness: the workstation `vale-hook` goes quiet when the Survey style is missing

Location: L130, L172. Evidence: `~/.dotfiles/bin/.local/bin/vale-hook:4-9,82-86` fails open in silence on any Vale error, and Vale exits with a runtime error when a `BasedOnStyles` style is not on disk.

Defect: In any fresh worktree before `npm ci` and the sync step, every prose edit gets no Vale feedback, and nothing tells the agent why.

Fold: Mirror Pass C's hook (L160). When the nearest `.vale.ini` names `Survey` and the style directory is absent, `vale-hook` emits one line ("run `npm ci` and the Vale sync step to enable Survey checks"). Pass D's workstation PR carries that change and a hook test.

### 10. Major, correctness: the charter amendment and site interface text overlap

Location: L172, L132, L63. Evidence: `authoring-charter.md:21-23` ("Website content is the one personal voice ... The workstation itself keeps no house lexicon of its own") and the `content-draft` skill's scope, which includes "form copy".

Defect: L172 amends only the "no house voice" sentence. The "no house lexicon" sentence then contradicts a shipped house style sheet, and L132 routes "house tools' interface text" to Survey while 907.life, which adopts Survey, keeps its form copy under its content guide. On a site, two routes claim buttons, form labels, and errors.

**OWNER FORK** (who owns a site's interface text):

- (a) A site's interface text stays with its content guide. Survey's interface section governs house tools only (the approval queue, the phonebook, Bulwark).
- (b) Survey's interface section governs all interface chrome, sites included. A site's content guide keeps pages, posts, and the words inside forms.

Recommendation: (a). It keeps the charter's one-personal-voice rule whole, and the amendment then rewrites both sentences at L21-23 and adds a boundary line to the `writing-voice` table.

### 11. Minor, correctness: the version rule for Vale changes leaves two cases open

Location: L133. Defect: The line covers a new rule only. It says nothing on widening an existing rule's pattern (ESLint calls that a bug fix and allows it in a minor, but it can fail an error-tier gate) or raising a level from `suggestion` to `warning` or `error`. Every config here sets `MinAlertLevel = suggestion`, and `vale-hook` returns suggestions to the agent, so a "suggestion" rule still reaches agents. That is intended, but it should be stated. Fold: Add two sentences. A pattern change that can report new findings at `error` is major. Raising a level is major at `error` and minor below it. Each rule's failing fixture pins its level.

### 12. Minor, correctness: Pass D's two pull requests have no stated order or adapter

Location: L172, L217, L226. Defect: Pass D lands a release in `survey` and a workstation PR (charter, `writing-voice` rows, the skill), but the risk paragraph names no `dotfiles-pass` adapter for the second, and nothing orders them. If the workstation PR merges first, `writing-voice` routes to briefs no published version holds. Fold: The release goes first, and the workstation PR follows under `dotfiles-pass` and cites the published version. Both close in one packet.

### 13. Minor, correctness: the harvest names an ambiguous source

Location: L169. Defect: "cairn's 2026-06-20 copy-edit research" matches six files in `cairn-cms/docs/internal/design/` plus a spec and a plan. Fold: Name `2026-06-20-editor-copyedit-conventions-research.md` (or the intended set) at a commit.

### 14. Minor, correctness: "The four other repos" does not match the five listed

Location: L181 against L130. Defect: L130 lists five repos, cairn-cms `tool/` among them. cairn's own docs use its `Cairn` style, not `glw907`. Fold: Name the repos, and say that cairn-cms `tool/` changes in cairn's pass.

### 15. Minor, correctness: the pack check does not cover the writing files

Location: L188, L171. Defect: The end-to-end pack listing names the Pass B outputs only. Nothing asserts that `writing/`, `vale/Survey/`, and the license notice ship, or that the Vale fixtures do not. Fold: Pass D extends the `npm pack --dry-run --json` assertion to those paths.

### 16. Minor, optional: the sitting should hold overrides only

Location: L170, L226. Defect: "Each new or widened departure reaches Geoff" can be read to include tightenings. cairn's own test (`docs-register.md:1083-1088`) says a tightening needs no ruling. Fold: Adopt that test by name. Overrides and widened cairn-only rulings go to the sitting, and tightenings are Claude's call, listed in `## Decisions`. This shortens the sitting without losing a ruling.

## Notes, no fold needed

- The public package carries Geoff's verbatim rulings. cairn-cms, workstation, poplar, and drafter are already public, and the workstation registers `editor.md` and `technical-doc-web.md` hold no personal data, so this adds no exposure.
- L212 ("A copy-editing rule Vale can't express") is sound as written.
- The `live-account` class for Pass D's release is warranted, since it publishes to npm.

Sources consulted for licensing:

- [Microsoft Writing Style Guide welcome page](https://learn.microsoft.com/en-us/style-guide/welcome/)
- [Oxygen XML notice citing the guide repository's CC BY 4.0 license](https://www.oxygenxml.com/addons/oxygen-terminology-checker-writing-styleguide_license.html)
