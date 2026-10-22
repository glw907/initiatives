# Survey Pass D fold

Target: `survey-house-style/specs/2026-10-21-survey-house-style-design.md`, branch
`survey-house-style`, folded from HEAD `0e1bf12`. Inputs: the three Pass D lens reviews dated
2026-10-22 (contract, integrity, mechanics) and the session's prior-art research, which Geoff asked
for on 2026-10-22. The fold agent loaded `receiving-code-review` and verified each finding before
acting on it. The rest of the spec was folded earlier (`2026-10-21-survey-house-style-fold.md`) and
was touched only where a Pass D finding reached it: the brief's step order and Worth knowing, Goals,
Non-goals, the changelog rung list, the end-to-end check, the stops, risk and estimate, the sittings
paragraph, and the Sources list.

`node src/check-brief.ts design <spec>` in `approval-queue/approval-queue` exits 0 on the revision.
The spec holds no em dash.

## Totals

52 entries (17 contract, 16 integrity, 18 mechanics, plus the mechanics over-ceremony note).

| Disposition | Entries | Roots |
|---|---|---|
| Folded | 37 | 24 |
| Owner fork | 7 | 3 |
| Refused | 1 | 1 |
| Dropped (`optional`) | 7 | 7 |

Convergent findings fold once at the root named below; each later entry points at it.

## Owner forks (now `### Decide:` blocks in the brief)

1. **How drafter reads the installed briefs.** Roots: contract 1, integrity 1, mechanics 1. Verified
   in drafter at `568c262`: `docs/configuration.md:155` says `inline_files` "lists files outside the
   repository"; the reviews' probes of `files.go` and `section.go` are relied on as quoted. Checked a
   third route the reviews named: `seat.<name>.inputs` commands run from the project root and their
   output enters the request, but `internal/assemble/commands.go:60-79` only appends
   `[exit status N]` on failure and the run continues, so a missing package is not loud. Option (c),
   a committed copy, breaks anti-goal "copies that drift" and is not offered. Recommended: a short
   drafter pass (about 60 minutes, `ordinary`). The fork is scope and budget in a third repo, so it
   stays Geoff's. The acceptance fix (assert a known sentence in the assembled request, fail with the
   package absent) is folded into Pass D's scratch-app bullet under that option.
2. **Whether Survey's Vale style takes over `glw907`.** Roots: contract 2, integrity 2, mechanics 4.
   Verified: none of poplar, dubplate, phonebook, cairn-themes, or cairn-cms `tool/` has a
   `package.json`; poplar, dubplate, and `tool/` apply `glw907` to `[*.go]`, and phonebook and
   cairn-themes apply `Google, glw907` to `docs/**/*.md`, so the style is a tells linter for comments
   and docs alike. The reviews split (contract recommends keeping it separate, integrity recommends
   absorbing it with a release zip). Recommended: keep `glw907` outside Survey, since the charter
   (`authoring-charter.md:21-23`) gives audience-invariant tells to the output style and the design
   leaves code comments out of scope. Integrity 14 (four versus five repos) folds here: the
   inheritance section now names the five repos in a bullet that applies only under the second
   option.
3. **Which repos the Survey register governs.** Root: contract 9; mechanics 8 shares its edit list.
   Recommended: only repos whose `package.json` lists `@glw907/survey`, which is checkable from the
   manifest. The edit list (charter sentences, global CLAUDE.md "Writing voice" line, the three
   workstation registers' fate) is folded into Pass D's Workstation bullet for either answer.

## Candidate forks taken as calls

The dispatch named seven candidate forks. Four have one clearly correct answer, so the spec takes
them and records why.

- **Pass D's release timing against 1.0.0** (integrity 3, mechanics 2). The rulings define 1.0.0 as
  the release candidate the approval queue converged on, plus any names it changed, and say the
  approval queue's pass close promotes it. A writing `1.0.0-rc.2` would put content into 1.0.0 that
  pass never converged on. So Pass D starts after Pass C, merges only after 1.0.0, and releases
  1.1.0. The brief's steps now put the approval queue's pass before Pass D; a stop covers 1.0.0 not
  being out.
- **Microsoft corpus licensing** (integrity 6, mechanics 6). Probed: `gh api
  repos/MicrosoftDocs/microsoft-style-guide` reports `cc-by-4.0`, public, archived; its
  `ThirdPartyNotices` grants the documentation under CC BY 4.0; last commit `c6945c3`
  (2024-11-13). The live welcome page still reads "© 2024 Microsoft. All rights reserved."
  (mechanics was right about the live page and the `-pr` repo, which returns 404, but missed the
  public archive). The answer follows: quote only from the archive at that commit with attribution,
  paraphrase and link anything newer, ship `writing/LICENSES.md`, and stop on an unconfirmed license.
  This is a compliance call, not a taste call.
- **Widening cairn's tightenings house-wide** (contract 5, mechanics 7). Geoff's 2026-10-22 ruling
  already set the pattern for a large set of small calls: one table with a default he can pull into
  a render. Tightenings widen through the same kind of table (default "widen"), and overrides go to
  the sitting one by one. This keeps the voice Geoff's call at the cost of one table, and keeps
  cairn's tightening test (`docs-register.md:1083-1095`) as the admission rule.
- **Who owns a site's interface text** (integrity 10). The spec's non-goal already keeps website
  content with each site's voice, the charter calls it "the one personal voice", and the
  `content-draft` skill's scope includes form copy. Option (b) would split that. So a site's pages,
  posts, and form copy stay with its content guide even where the repo installs Survey, and the
  workstation PR adds that boundary line to `writing-voice`.

## Dispositions by review

### Contract and criteria lens

1. Blocker, drafter inline. **Owner fork 1** (root).
2. Blocker, `glw907` takeover in non-npm repos. **Owner fork 2** (root).
3. Major, ledger completeness. **Folded**, Pass D "Ledger": countable units per source, mapped
   count equals their sum.
4. Major, the sort can pass empty. **Folded**, Pass D "Ledger" (each row says why; a cairn-only row
   names its cairn noun; no noun means house-wide) and "The sitting" (unclear rows go to the table).
   The old standing answer that marked unclear rows cairn-only without asking is replaced in Stops.
5. Major, widening tightenings. **Folded as a call** (see above), Pass D "The sitting" and the
   writing section's "Departures".
6. Major, vacuous Vale fixtures. **Folded**, Pass D "Build" (exactly `Survey.<Rule>` in JSON output,
   no `Survey.*` on the passing fixture, rule count equals fixture pairs) and "Scratch app" (a tell
   only a `Survey` rule catches). Probed: `vale --output=JSON` reports `Survey.SerialComma` by name.
   Fixtures move to `tests/vale/`, since Vale reads every `.yml` in a style directory as a rule.
7. Major, pack check misses the writing part. **Folded** (root; integrity 15 and mechanics 10's pack
   part point here), End-to-end check, new Pass D leg for the pack list and the post-publish install.
8. Major, skill trigger and version match. **Folded** (root; integrity 7, mechanics 5), writing
   section "Skill" and Pass D "Acceptance". See the mechanism note below.
9. Major, routing scope. **Owner fork 3** (root); edit list folded into Pass D "Workstation".
10. Major, briefs copy drafter stock and output-style tells. **Folded**, writing section "Briefs"
    (the Google brief holds deltas and cites `drafter:google-*.md`; `drafterPrefix = "drafter:"`
    confirmed at `internal/assemble/section.go:13`) and Pass D "Ledger" (owned-elsewhere rows). The
    corpus lint is folded into "Corpus licensing".
11. Major, no closing invariant on the sitting. **Folded**, Pass D "The sitting" (every row carries a
    ruling id or a carried cairn ruling; each id maps to a landing place; a check counts both).
12. Minor, "can't express" is self-certified. **Folded**, writing section "Copy-editing rules" (the
    `vale:` field) and the Stops line.
13. Minor, style sheet format. **Folded** by cutting the promise: the sheet is Markdown and not a
    public API, and a later code reader names its format in its own pass. Mechanics 11 confirms
    poplar's tidy feature is gone, so the old sentence promised a consumer that no longer exists.
14. Minor, sync and ignore contract. **Folded** (root; integrity 8, mechanics 3), writing section
    "Custom linters". See the mechanism note below.
15. Minor, unpinned sources. **Folded** (root; integrity 13, mechanics 11), Pass D "Sources".
16. Minor, missing stop answers. **Folded** (root; mechanics 10's stops part), Stops: rejected
    house-wide row, mostly cairn-only result, drafter leg, 1.0.0 not out, license, thin exemplars,
    and the escalation list.
17. Minor, optional, ceremony and estimate. **Dropped** (`optional`). Its correctness-adjacent parts
    land elsewhere: the adapter and PR order through integrity 12, the estimate through the
    dispatch's instruction.

### Integrity and failure-risk lens

1. Blocker, drafter. **Owner fork 1** (convergent with contract 1).
2. Major, `glw907` repos. **Owner fork 2** (convergent with contract 2).
3. Major, minor release on an rc. **Folded as a call** (root; mechanics 2), Pass D lead, brief steps
   5 and 6, Worth knowing, and Stops.
4. Major, cairn's reader set. **Folded**, inheritance "cairn's docs" bullet: authority until cairn
   converges, the full reader set across drafter, `~/.dotfiles`, and cairn-cms, a second source for
   the chain, and a loud failure with no fallback.
5. Major, provenance. **Folded**, writing section "Departures" (prefixed ruling ids, permalinks at
   the harvest commit, the two-level rule), Pass D "Sources" (each source at a commit), and the
   "cairn's docs" bullet (re-diff from the harvest commit before cairn shrinks its file).
6. Major, corpus licensing. **Folded as a call** (root; mechanics 6), writing section "Corpus
   licensing" and Stops.
7. Major, skill from npm. **Folded** (convergent with contract 8).
8. Major, `vale sync` replaces vendored base styles. **Folded** (convergent with contract 14).
   Verified: cairn-cms `.vale.ini` sets `Packages = Google, Microsoft` and commits
   `.vale/styles/{Google,Microsoft}`, and the vendored `vale-ci` and `vale-fix` notes say not to run
   `vale sync` against a committed styles directory.
9. Major, `vale-hook` goes quiet without the style. **Refused**: the committed-copy mechanism keeps
   the style on disk in every checkout of a repo that names it, so the case reduces to a repo that
   names `Survey` without committing the copy, which that repo's own gate already fails (Vale exits
   2, probed).
10. Major, owner fork on site interface text. **Folded as a call** (see above), Pass D "Workstation"
    boundary line.
11. Minor, Vale versioning cases. **Folded** (root; mechanics 13), writing section "Versioning".
12. Minor, PR order and adapter. **Folded** (root; mechanics 12), Pass D "Workstation" and "Order",
    risk paragraph, and the sittings paragraph (two packets).
13. Minor, ambiguous copy-edit source. **Folded** (convergent with contract 15).
14. Minor, four versus five repos. **Folded** under owner fork 2's root, inheritance section.
15. Minor, pack check. **Folded** (convergent with contract 7).
16. Minor, optional, sitting holds overrides only. **Dropped** (`optional`); the tightenings table
    from contract 5 answers the same question the other way.

### Mechanics and feasibility lens

1. Blocker, drafter. **Owner fork 1** (convergent with contract 1). Its option (b), seat `inputs`,
   is the Decide block's second option.
2. Blocker, minor with no 1.0.0. **Folded as a call** (convergent with integrity 3).
3. Major, synced style doesn't follow npm. **Folded** (convergent with contract 14). The vendored
   Vale notes need no change, since no repo runs `vale sync` for Survey; the Workstation bullet says
   so.
4. Major, `glw907` repos. **Owner fork 2** (convergent with contract 2).
5. Major, no npm skill channel. **Folded** (convergent with contract 8).
6. Major, Microsoft license. **Folded as a call** (convergent with integrity 6), with the correction
   recorded above.
7. Major, rulings contradiction and overrides in harvested rules. **Folded** with contract 5: every
   harvested rule, `glw907` and copy-editing rows included, takes cairn's tightening-or-override
   test, and a cairn override marked house-wide reaches the sitting with cairn's ruling as evidence.
   Under owner fork 2's recommendation, `EmDash` stays in `glw907` and enters the register only if
   the harvest proposes it, in which case it is an override row in the sitting.
8. Major, workstation edits incomplete. **Folded**, Pass D "Workstation": the charter's overlay
   paragraph and both closing sentences of its website paragraph, global CLAUDE.md, `writing-voice`
   rows and boundary line, the fate of `editor.md`, `technical-doc-web.md`, and
   `technical-doc-go.md` (pointer line, or pointers under fork 3's second option), and the vendored
   Vale notes. The `tellgrader` overlap is an owned-elsewhere ledger row.
9. Major, hosts. **Folded**, Pass D "Hosts".
10. Major, Pass D standing answers. **Folded** (stops part convergent with contract 16; pack and
    post-publish part with contract 7).
11. Minor, poplar's tidy feature is gone. **Folded** (convergent with contract 15). Verified:
    `poplar/internal/tidytext` is absent, `041eb329` is "Retire the legacy tree at the build
    boundary", and `docs/archive/specs/2026-05-08-claude-tidy-design.md` exists. Non-goals now say
    "any tidy feature's move".
12. Minor, two PRs' order. **Folded** (convergent with integrity 12).
13. Minor, writing rung. **Folded** (convergent with integrity 11); the Versioning section's rung
    list gains `writing`.
14. Minor, drafter ships only a Google standard. **Folded**, writing section "Briefs". Verified at
    `internal/blueprint/tracks.go:21`.
15. Minor, optional, trigger checks and fixture runner. **Dropped** (`optional`); both are covered by
    contract 8 and contract 6.
16. Minor, optional, 320 minutes is low. **Dropped** as a finding. The estimate moved to 400 on the
    dispatch's instruction, with the breakdown in the risk paragraph.
17. Minor, optional, adapter and risk wording. **Dropped** (`optional`); the adapter is named through
    integrity 12.
18. Minor, optional, cairn's pass spans three repos. **Dropped** (`optional`); integrity 4's reader
    list names the three repos anyway.
- Over-ceremony, one `survey` skill with a writing route. **Dropped** (`optional`).

## New mechanisms and their probes

- **Committed Vale style copy with a diff gate** (replaces the `Packages` local path and `vale
  sync`). Probe in `scratchpad/foldd/` under Vale 3.24.0: a `Survey` style copied under
  `.vale/styles` with `BasedOnStyles = Survey` raised `Survey.SerialComma` in `--output=JSON`;
  `diff -r` against the package copy exited 0 in sync and 1 after one rule changed; with the copy
  removed, Vale printed "Style 'Survey' isn't on the StylesPath" and exited 2. The pattern matches
  the house practice in the vendored `vale-setup` note ("commit the StylesPath directory instead of
  gitignoring it"). The Vale `Packages` source line left the Sources list, since nothing relies on it
  now.
- **Skill through the vendored-skills channel.** `claude-tooling-sync update-skills` fetches a skill
  from any GitHub repo at a branch and rewrites its pinned commit (`fetch_skill`,
  `~/.local/bin/claude-tooling-sync:397-421`), so the skill's source can live in the public `survey`
  repo, as Geoff's ruling that Survey holds the register's skills requires, with no new manifest
  kind. The skill carries no rule text, so the commit it was fetched at never decides a version.
- **drafter's `drafter:` stock prefix**, used by the Google brief to cite the base:
  `const drafterPrefix = "drafter:"` at `internal/assemble/section.go:13`.
- **drafter seat `inputs`** (the drafter fork's second option): `commandBlocks` and `runCommand` in
  `internal/assemble/commands.go` run each template from the project root and append an exit note on
  failure without stopping the run.

## How the prior-art input landed

- **Fixed voice, moving tone** (Mailchimp, Atlassian, Polaris). Writing section "Voice and tone".
  All three URLs return 200. Mailchimp's page states its voice in the "X but not Y" form ("smart but
  not snobbish"), quoted in the spec. Polaris renders client-side, so the fold could not confirm from
  the static page that its four principles take the same form; the spec attributes the form to
  Mailchimp only and cites Polaris for the voice-and-tone split.
- **Three to five traits in "X but not Y" form.** Landed in one file, `writing/voice.md`, which both
  briefs name as their first read. The input said each brief opens with the traits. Two copies of one
  fixed voice would be the drift anti-goal, and drafter tracks and the skill can load `voice.md`
  before a brief, so the traits reach every reader first from one home.
- **Tone table on NN/g's four dimensions.** In `writing/voice.md`, covering interface text, errors,
  empty states, docs pages, and release notes. The NN/g article returns 200 and names the dimensions
  ("Formal vs. casual", "Respectful vs. irreverent", and the rest). Geoff rules the traits and the
  table in Pass D's sitting.
- **Anthropic prompting best practices.** Quotes verified on the live page: "Examples are one of the
  most reliable ways to steer Claude's output format, tone, and structure", the relevant, diverse,
  and `<example>`-tagged criteria, "Include 3–5 examples for best results", "Tell Claude what to do
  instead of what not to do", and the "context or motivation behind your instructions" passage.
  Landed in "Briefs" (positive rules with reasons; tells as before-and-after pairs, after first) and
  "Examples" (three to five tagged house exemplars per surface under `writing/examples/`), with a
  standing answer when a surface has fewer than three.
- **Claude Code skills docs.** Verified: "Keep SKILL.md under 500 lines. Move detailed reference
  material to separate files." Landed in "Skill" (a short router with no rule text) and "Examples"
  (example sets read on demand).
- **Vale as the deterministic net, the agents as the judgment layer.** Writing section "Judgment
  layer": `prose-voice-reviewer` for house tools, `cairn-register-editor` for cairn after it
  converges.
- **Sources added**: Mailchimp, Atlassian, Polaris, NN/g, Anthropic's prompting best practices, and
  the Microsoft style guide's source repository (the license basis). The Claude Code skills page was
  already listed.

## Owed

- Pass D's 400-minute path figure is the mechanics review's breakdown plus the prior-art work
  (voice file, tone table, example sets) folded into the 120-minute writing task. The planner checks
  it against the task list, as the risk paragraph says.
- No verification read has run on this fold. Pass D carries the `live-account` flag, so
  `spec-plan-review` calls for one before Geoff reads the design.
- Not done, worth a backlog line: the five `glw907` copies are hand-synced. They hash identically
  today (integrity 2), but nothing checks that. Under owner fork 2's recommendation this stays outside
  Survey.
