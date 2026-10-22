# Survey rewrite fold

Target: `survey-house-style/specs/2026-10-21-survey-house-style-design.md`, branch
`survey-house-style`, folded from HEAD `ef69d7f` (the reviews read it at `ad97b5f`; the spec did not
change between them). Inputs: the four lens reviews dated 2026-10-22 (contract, integrity,
mechanics, prior-art) and five messages from the coordinator relaying Geoff's rulings of the same
day. The fold agent loaded `receiving-code-review` and verified each finding before acting on it.

`node src/check-brief.ts design <spec>` in `approval-queue/approval-queue` exits 0 on the revision.
The spec holds no em dash.

## Rulings received during the fold

All five are recorded in the spec's Rulings section.

1. **No Survey plugin.** Survey does not ship as a Claude Code plugin; a Survey plugin is a later
   item for `~/Projects/initiatives/shared-standards`. The prior-art review's plugin fork
   (finding 5) is removed, and the spec's new "Later" section records the item.
2. **Simplicity.** The design is as simple and clean as possible: the simpler of two folds that
   close a finding, the smallest standard mechanism, no detail the builder can settle, each thing
   said once. Where it decided a disposition, the entry below says "simplicity ruling". It also
   asked whether the Claude-infra changes should be consolidated; see "Consolidating the
   workstation PRs".
3. **907.life.** Its rebuild comes after cairn's docs are complete, so nothing here waits on it.
   907-life leaves Pass E's npm list for its "Out" line, the cairn-site recipe stays pending until
   the rebuild, and Pass H may still take house examples from its existing posts.
4. **cairn's docs** move to the Survey register in Pass E as designed, during the ongoing cairn docs
   effort, behind the baseline match. The design is unchanged: Pass E pins Survey in cairn-cms (npm
   channel, `tool/` included) and switches only matched surfaces, and cairn's `docs-register.md`
   stays authoritative until cairn's own convergence pass. That reading of "as designed" is flagged
   to the coordinator.
5. The rulings paragraph that said "Pass C adds that line to `dependency-upgrade`" now reads "the
   workstation pass (now Pass E)". Only the placement changed, not the ruling.

## Consolidating the workstation PRs

The draft split Claude-infra work across three workstation PRs: Pass C (the `survey` skill authored
in `~/.dotfiles`, the hook, agent lines, the render rule), Pass E (vendoring and the writing
switch), and Pass F (the correction channels). It also moved the skill from `~/.dotfiles` into the
survey repo in Pass D, which is the mechanics review's M1 dependency. The revision has two
workstation PRs. The skill is written once, in the survey repo's `skills/survey/`, in Pass B, and
vendored once. Pass E's one PR lands everything that exists at 1.1.0, in an order whose last commit
is the output style. Pass F's PR adds the correction channels, a separate feature that comes after
the measured switch.

Why: one skill home from the start (M1 disappears), one vendoring step, one host rollout, one
trigger-check run, and one packet. The order stays safe: `fetch_skill` change, vendored entry,
hook, preloads, `dependency-upgrade` lines, symlinks, pointers, reviewer, docs, CLAUDE.md, output
style last, reverted in reverse order. The cost is that the hook and preloads arrive after the
approval queue's pass rather than before it. That pass's own gate runs `survey-check` from the
package, so it loses only the advisory hook. The path also lengthens, since Pass C no longer runs
beside Pass D. Pass F was not merged into Pass E: the channels are new behavior, and keeping them
out of the switch PR keeps that PR reviewable. Pass letters keep their meaning, and the spec says
there is no Pass C, so every review and fold record still reads correctly.

## Totals

| Lens | Findings | Folded | Refused | Owner fork | Dropped (`optional`) | Removed by ruling |
|---|---|---|---|---|---|---|
| Contract | 22 | 19 | 0 | 1 | 2 | 0 |
| Integrity | 21 | 18 | 0 | 1 | 2 | 0 |
| Mechanics | 28 | 23 | 0 | 1 | 4 | 0 |
| Prior-art | 14 | 5 | 0 | 0 | 8 | 1 |
| Total | 85 | 65 | 0 | 3 | 16 | 1 |

Integrity 9's mechanical half and mechanics M3 fold, and only the workstation's half is a fork, so
those two are counted under fork and folded respectively. Several folds refuse a part of the
proposed fix under the simplicity ruling. Each such part is named in its entry ("part refused").
Prior-art 4 was `optional` but is taken as a call and counted as folded: the dispatch named it as a candidate, and it has
one clearly better answer (see its entry).

## Owner forks (now `### Decide:` blocks)

1. **How often the monthly review re-grades the fixed tasks.** Roots: contract 21, mechanics o4,
   integrity 20. Under the revised method a full grade is 135 drafts and 270 judge calls. Options:
   re-grade only when the Survey version, drafting model, or judge changed (recommended); re-grade
   every month. The mechanics review's middle option (one run per task, with a three-run
   confirmation) is not offered. At three pairs per surface the sign test cannot reach significance
   (the smallest one-sided p is 0.125), so it could never detect a fall.
2. **How the workstation takes new Survey releases.** Root: integrity 9. Options: the monthly
   review moves the tag before it grades, as a gated `~/.dotfiles` commit (recommended); a
   `dependency-upgrade` workstation sweep; a packet per move. The recommendation differs from
   integrity's (the sweep). The workstation has no release cadence that would trigger a sweep, and
   the grading host's own pin should be current when it grades. Contestable: option 1 pushes to
   `~/.dotfiles` main unattended, which the design's approval would grant.
3. **Whether drafter stops a run when a Survey section is missing.** Carried unchanged from the
   prior fold.

Stylelint as the base of `survey-check` was a candidate fork and is not one. See prior-art 4.

## Contract review

1. **Folded** (Evals, "The decision"; eval root). The band against a draft-level standard deviation
   is replaced by a paired sign test at one-sided α = 0.05 on each of five measures. The fixed
   non-inferiority margins with bootstrap intervals are a **part refused** under the simplicity
   ruling. The knockout acceptance (contract 3) shows the rule can see a deletion-size regression,
   which was the evidence the margins were meant to give. Smaller regressions remain a residual,
   stated by the method's power, not hidden. Verified: the September `benchmark.json` files
   declare `runs_per_configuration: 3` and hold `run_number` 1 only (reviewer's reading relied on
   as quoted). The binomial table was checked: P(≥6 of 9 at 0.5) = 0.254.
2. **Folded** (Evals, "The decision"; stops, "Pass D and every eval run"). False misses are
   controlled by α and by the rule that a first miss reruns with fresh drafts and only a repeat
   miss counts. At nine decisive pairs a miss needs eight (p = 0.0195). The pooled all-surface
   preference is a **part refused** as a second test to maintain once the repeat-miss rule bounds
   the false rate.
3. **Folded** (Evals, "Knockout"; Pass D; stops). One knockout arm (September's bare arm) must miss
   on every surface, on the four content measures. A surface where it matches gets five runs, one
   assertion rewrite, then a non-discriminating report. The second, register-removed knockout is a
   **part refused**: its acceptance needs a judgment of which registers carry non-default rules,
   and the bare arm already shows the rule can fail.
4. **Folded** (Evals, "Arms" and "Graders"). The arms are now natural: project skills, a natural
   prompt, `stream-json`, and pack reads as a fifth paired measure. Probed: see "Probes", P3.
5. **Folded** (Writing contexts, Evals, monthly step 4). `reply` is a surface of `core`; fifteen
   surfaces and 45 tasks. Verified `evals.json` eval 7 has register `reply`.
6. **Folded** (Evals, "Stored drafts"). Pairwise judging re-judges stored baseline drafts in each
   batch, so no stored mean is ever compared across judge cohorts.
7. **Folded** (Evals, "Arms" and "Breaks"). `--model` pins the drafting model, each run records
   four versions, a drafting-model change redrafts the stored baseline, and a judge or rubric
   change marks a break. Marking a break on every Claude Code version change is a **part
   refused**: it changes most months, and the version is recorded for tracing.
8. **Folded** (Evals, "Geoff's read"; monthly step 5). The judge gives the same ship, edit, or
   reject on the blind pieces, and agreement is reported cumulatively with its count.
9. **Folded** (monthly step 8; Pass F acceptance). Each correction becomes a probe kept in the
   ledger, and an example beats on its probes while the fixed tasks match. Probes stay in the
   private ledger rather than the public `evals/`, because they carry Geoff's corrected text.
   Pass F's dry run carries the end-to-end leg. Contestable, as the review said: "beat its
   context's baseline" is read as "beat on the corrected behavior while matching the fixed tasks".
10. **Folded** (Evals, "The decision"). A beat needs significance on one measure named before the
    run, and every other measure must match. The permanent Pass D anchor beside the moving
    baseline is a **part refused** under the simplicity ruling: with a significant beat required,
    a no-op is accepted at most 5% of the time and a worse change less often, and the monthly
    comparison against stored drafts catches cumulative decline.
11. **Folded** (monthly step 4). A seeded random draw, grading at Claude's own commit, and figures
    only for a surface with three or more pieces. The "fell two months running" trigger is removed
    (mechanics m7).
12. **Folded** at integrity 1's root (Context packs, the public-permalink rule and its gate).
13. **Folded** at integrity 2's root (monthly step 1, host check).
14. **Folded** (monthly step 6). The comparison is against stored baseline drafts, which stay fixed
    until a beat, so a slow decline accumulates against one yardstick. A partial scorecard skips
    the trigger.
15. **Folded** (Evals, "The decision"). Tells and Vale errors are compared per draft, pair by pair.
16. **Folded** (Evals, "Graders"). Pairs by task and run, both orders, ties allowed.
17. **Folded** (Pass F acceptance). Negative fixtures: a code comment, a send-back about a missing
    test, a volunteer's save, and a page with no trailer. Integrity 6's intervening edit was added.
18. **Folded** (Pass F acceptance). A seeded prior scorecard, the printed `log-issue` item, and the
    distill order.
19. **Folded** (Pass D "Snapshot"; Claude-infra map). The snapshot is the kept copy ruling 4 asks
    for, and the self-contradicting "deletes nothing" is gone. The workstation PR's order and
    revert rule replace it. Defining "run cleanly" as a later retirement step is a **part
    refused**: after Pass E nothing old remains outside the snapshot to retire.
20. **Dropped** (`optional`).
21. **Owner fork** (Decide 1).
22. **Dropped** (`optional`). Contract 8 keeps the read useful.

## Integrity review

1. **Folded, root** (Context packs; Corrections, "What gets published"; Evals, "Geoff's read";
   monthly steps 8 and 9; stops). Survey publishes only text that is already public: each house
   example names a GitHub permalink in a public repo, the gate checks visibility with
   `gh repo view --json visibility` at release time, and an unresolved source counts as private.
   Packets are no longer an example source, since their text is local. Geoff's verdicts and notes
   go to the ledger, and the review log moves from the public repo into the ledger's
   `reviews/<YYYY-MM>.md`. Distill PRs cite record ids. The ledger is created in Pass D so the
   first private record has a private home. Two parts are refused under the simplicity ruling.
   The denylist grep is one: with the log and the verdicts out of the public repo, no free-text
   path remains but PR bodies, whose rule is ids only. The check that quoted text is present at
   the permalink's commit is the other, left to the builder.
2. **Folded** (monthly step 1; release gate). One host grades: any host but pavilion harvests,
   pushes, and stops. This is the simpler of the two folds (claim file or host check) and closes
   the race. Verified the timer: `OnCalendar=monthly`, `Persistent=true`, `RandomizedDelaySec=1h`.
   The release gate also fails when the version is already on npm, which closes the silent
   publish skip whoever causes the collision.
3. **Folded** (Pass E, "The workstation"; stops). Before each symlink commit, the file at `HEAD`
   must equal its pack. The gate freeze from Pass D's close is a **part refused** under the
   simplicity ruling: the pre-link check alone catches every edit made between snapshot and
   cutover.
4. **Folded, root with mechanics B2** (Channels and pins; Claude-infra map). One directory,
   `skills/survey/`, is the skill, the Vale style, the npm payload, and the zip. It carries a
   committed `SHA256SUMS` that the survey gate regenerates. `fetch_skill` writes to a temporary
   sibling and renames it, for every vendored skill. One checksum check adds a file-set comparison.
   The rollback is `git revert` of the tag commit. Verified `fetch_skill` at
   `claude-tooling-sync:397-421`: it writes each file in place and never deletes. Probed: P1.
5. **Folded** (Claude-infra map, `scripts/check.sh`; Pass E acceptance). Each of the seven links is
   checked with `readlink` against its recorded target. The session-start warning and the fallback
   probe are a **part refused**: the atomic fetch and the gate remove the causes of a dangling link.
6. **Folded** (Corrections, "The cairn editor"). Each of Geoff's saves is diffed against its own
   parent, and the walk stops at the first commit by anyone else. The draft is a direct
   default-branch commit (mechanics M7), so squash and branch deletion cannot lose it. That makes
   the draft-time ledger record a **part refused** as a second source of truth.
7. **Folded** at the eval root (contract 1, 7, 10). The dual baseline is a part refused as in
   contract 10. Baselines stored by Survey version cover the revert case.
8. **Folded, root with mechanics M6** (Versioning, "Rollback"; stops; sittings). Verified on
   docs.npmjs.com: OIDC "supports `npm publish`, `npm stage publish`, and the dist-tag operations",
   and the page does not cover `npm deprecate`. The deprecation goes to Geoff as a `[you: ...]` line.
   Moving or removing `next` after 1.0.0 is a **part refused**: every consumer pins an exact
   version, and nothing reads `next` after the promotion.
9. **Owner fork** (Decide 2) for the workstation. The repo half folds at mechanics M3.
10. **Folded** (monthly steps 2, 8, 9). The review record lists consumed ids. The distill takes
    every correction no record consumed, and the guard tests for a complete record. The
    `check-drift` warning for a skipped month is a **part refused**: the next run consumes the
    corrections, and a missing monthly blind page is visible to Geoff.
11. **Folded** (Corrections, "The ledger"). Records are created once, and keys name host, commit, or
    session. Commit-by-path and the `index.lock` retry are left to the builder.
12. **Folded** (Corrections, "The approval queue"; Pass F acceptance). `refs/pull/<n>/head`, with a
    squash-merged, deleted-branch fixture.
13. **Folded** (Corrections, "Chat"; Claude-infra map, `check-drift`; stops). Offline commits wait
    for the next harvest's push, and `check-drift` checks the ledger clone as it checks the
    initiatives clone. Verified: `check_initiatives` in `check-drift` already checks missing,
    unreachable, and behind. The spool directory is a **part refused** under the simplicity ruling.
14. **Folded** (Versioning, "Release"; Channels and pins). Immutable releases, an offline checksum
    gate in place of a download, and the zip attached at release creation, so a publish re-run
    never needs an upload. Verified on GitHub's docs that attached files "are protected from
    modification or deletion" and that immutability applies only to later releases. The
    repository's `immutable-releases` REST endpoint answered a read on cairn-cms. Committing the
    zip's hash beside the pin is a **part refused**: immutability fixes the bytes behind the URL.
15. **Folded** (Versioning, "Release"). The publish job refuses any ref but `main` or a tag on
    `main`. Verified that cairn's `publish.yml` takes `workflow_dispatch` with no guard.
16. **Folded** (Pre-flight). `"files": ["README.md"]` and an `npm pack --dry-run` check.
17. **Folded** (Evals, "Arms"; stops). `/output-style` must list the arm as `(current)` before each
    batch, with mechanics m3's exact form.
18. **Folded** (Pass E, "The workstation"). "Revert in reverse order".
19. **Folded** (monthly review). `survey-ledger review --ledger <dir>`.
20. **Dropped** (`optional`). It converges on Decide 1.
21. **Dropped** (`optional`). The render rule is Geoff's ruling. Apps take Survey in
    `dependency-upgrade` sweeps, which already batch every minor since the last sweep.

## Mechanics review

- **B1. Folded** at the eval root. Its sign test is the method taken, and its "first miss re-runs"
  is the repeat-miss rule. Pass G gains a stop for a repeat miss.
- **B2. Folded** at integrity 4's root, with its `--strict` flag and file-set check.
- **B3. Folded** (Context packs; Pass H). `pack.md` stays each pack's one file. Pass H adds sections
  and keeps every heading, `core`'s `pack.md` stays the output style with frontmatter, and the
  approval-briefs pack runs the approval queue's gate with `REGISTER`. This is simpler than
  building `pack.md` from six files. Verified `approval-queue/tests/approval-queue.test.sh:209-236`:
  `n -ge 6` exemplars and exactly 3 packets.
- **M1. Folded** by consolidation: the skill is written in the survey repo in Pass B.
- **M2. Folded** (Evals, "Arms"; Pass D snapshot). `--setting-sources project`, a named permission
  mode, the global "Writing voice" section as the baseline arm's project CLAUDE.md, and a pinned
  model.
- **M3. Folded** (Channels and pins, "Taking a release"; Claude-infra map). `dependency-upgrade`
  gains a Survey step that refreshes an npm repo's committed copy and moves a zip repo's URL. That
  is one skill step, not a new helper (simplicity ruling). Verified `dependency-upgrade` measures
  `package.json` directories only. The workstation half is Decide 2.
- **M4. Folded** at integrity 2's root.
- **M5. Folded** (monthly review; Pass F). One helper, `survey-ledger`, with `harvest` and `review`
  (`--dry-run`, `--ledger`, `--surfaces`), and step 9 runs it. One helper replaces the separate
  `survey-harvest` and a launcher (simplicity ruling). Verified `model-review-notify` takes only
  `--dry-run` and reads `docs/model-review/prompt.txt`.
- **M6. Folded** at integrity 8's root.
- **M7. Folded** (Corrections, "The cairn editor"). Verified `content-draft` only offers to save or
  commit (its step 5). The "PRs merge with `--merge`" half is unnecessary: the draft is a direct
  commit.
- **M8. Folded** (Risk and estimate). There are twelve packs, and every eval figure states its
  concurrency (four sessions) and per-surface assumption (about ten minutes), to be re-cut from
  Pass D's measured times. Totals moved from 3,200 to 4,065, and the path from 3,040 to 4,065.
- **M9. Folded** (Pass E, "npm channel"). The approval queue's PR takes the ruled render, 30
  minutes.
- **M10. Folded** (Versioning, "Release"; stops). The session creates the release with the zip
  attached, so the workflow keeps `contents: read`. A retry after a workflow fix dispatches from
  `main`. Verified cairn's `publish.yml`: `release: [published]`, `workflow_dispatch`, `contents:
  read`.
- **m1. Folded** (Writing contexts; Pass D "Packs"). Verified the headings. `ts-conventions`,
  `svelte-conventions`, and `python-conventions` are wholly comment standards (principles, §0,
  rubric, shape, linting, output), so each moves its whole body below the frontmatter. Go moves
  "## Comments" (line 339). Each is checked with `cmp` against the extracted bytes. The
  reviewer's narrower §0-plus-shape reading would leave half of each standard behind.
- **m2. Folded** (Pass D "Snapshot"). Verified: `~/.dotfiles/vale/.config/vale/styles/` holds only
  `Google` and `Microsoft`, and poplar holds `.vale/styles/glw907`.
- **m3. Folded** with integrity 17.
- **m4. Folded** (Evals, "Geoff's read"; monthly step 1). Static mode, a first-word verdict, and a
  `feedback*.json` glob. Relied on the reviewer's probe as quoted.
- **m5. Folded** (Corrections, "The approval queue"). `verdict == send-back`.
- **m6. Folded by removal.** The sign tests replace `aggregate_benchmark`'s mean and deviation, so
  nothing copies it.
- **m7. Folded** at contract 11 (the trigger is removed).
- **m8. Folded** (Pass H). It falls back to Pass D's baseline.
- **m9. Folded** (The house register, Vale rules). New rules ship at `suggestion`.
- **m10. Folded** (Channels and pins). A devDependency where only writing uses it.
- **m11. Dropped** (`optional`). Moot: the zip gate is offline now.
- **o1, o2, o3. Dropped** (`optional`). Separately, the simplicity ruling cut Pass E's re-run of
  `writing-voice` trigger prompts, since its description does not change.
- **o4. Owner fork** (Decide 1).

## Prior-art review

1. **Folded** (Agent-friendly, "Agents get the skill without a trigger"; Claude-infra map). The
   spec's premise was wrong. Verified on code.claude.com/docs/en/sub-agents: "The full skill
   content is injected, not only the description", and "To preload Skills into context, use the
   `skills` field rather than listing `Skill` here". The four agents list `skills: [survey]` in
   place of a prose line, the mechanism `prose-voice-reviewer` already uses. The path-scoped user
   rule is a **part refused**. It would open a new home (`~/.claude/rules/` does not exist on this
   workstation), `visual-verifier` sets `omitClaudeMd: true` so a rule would not reach it, and the
   hook already corrects the main loop at every CSS edit. Per-language comment rules go to the
   spec's "Later".
2. **Folded** at the eval root. Paired differences, both-order judging with ties, and a test that
   needs no scale assumption come from Anthropic's statistical approach and Zheng et al. The 1 to
   5 means are gone, since the rubric's dimensions now drive a pairwise pick. Cumulative judge
   agreement is folded too. Two parts are refused under the simplicity ruling. Binary
   per-criterion graders under a two-of-three vote would triple judge calls; assertions are
   already binary, and pairwise judging removes the Likert-mean problem. A formal power
   calculation is the other, since the knockout acceptance measures the rule's power empirically
   on each surface.
3. **Folded** (Versioning, "Release gate"). The token JSON is diffed against the last published
   version's, by path and type. `design.md diff` beside it is a **part refused**, because the token
   diff already covers it (each thing once). The coordinator's message called the stylelint finding
   "prior-art 3"; in the review file it is finding 4.
4. **Taken as a call** (The conformance check; package shape). This is an `optional` finding the
   dispatch named as a candidate fork. It is not a taste or budget choice. The 2026-10-21 ruling
   asks that Survey follow established practice, and Primer, Polaris, Atlassian, and Mozilla ship
   token linting as stylelint plugins. The simplicity ruling prefers the standard mechanism over a
   custom parser, and the spec already modelled its ignore comment on stylelint's. Probed: P2.
5. **Removed by ruling** (Geoff, 2026-10-22). Recorded under the spec's "Later".
6. **Folded** (Pass E acceptance; Pass F, "Corrections route"). skill-creator's twenty-query set
   with near-misses and its held-out split, for the `survey` skill and its corrections route.
7. **Dropped** (`optional`).
8. **Dropped** (`optional`).
9. **Dropped** (`optional`). Moot without a plugin.
10. **Dropped** (`optional`).
11. **Dropped** (`optional`).
12. **Dropped** (`optional`).
13. **Dropped** (`optional`).
14. **Dropped** (`optional`).

## Probes

Scratch: `/tmp/claude-1000/-var-home-glw907--dotfiles/cd716614-5551-4ef9-a8d1-4ccc7fe74ceb/scratchpad/fold3/`.

- **P1, one directory as skill and Vale style** (`vale1/`, Vale 3.24.0). A `styles/Survey/` holding
  `SKILL.md`, `SHA256SUMS`, `packs/core/pack.md`, and one rule raised `Survey.Tell` by name (exit 1)
  and ignored the other files. `sha256sum -c --strict --quiet` exited 0 clean. After a stray file
  was added, `sha256sum -c` still exited 0 and the file-set diff exited 1, which is why the check
  has both halves.
- **P2, stylelint as the checker's base** (`sl/`, stylelint 17.16.0, postcss-html 2.0.0). A
  ten-line plugin rule flagged a hex literal in an inline `style=""` (line 2) and in a Svelte
  `<style>` block (line 4), honored `stylelint-disable-next-line survey/no-literal -- <reason>`
  (line 6 not reported), and exited 2 with JSON findings.
- **P3, a natural eval arm** (`arm/`, Claude Code on pavilion, `--model haiku`). Under
  `--setting-sources project --settings '{"outputStyle":"probe-style"}' --output-format
  stream-json`, a project skill triggered on "Write a haiku about a river." The transcript showed
  `Skill` then `Read` of `packs/river.md`, the draft followed the pack, and the style's marker line
  appeared.
- **Relied on as quoted.** The reviews' probes of `--disable-slash-commands`, `/output-style`
  (`(current)` marker, and exit 0 when dangling), `--setting-sources project` dropping user
  CLAUDE.md and hooks, the viewer's `feedback.json`, and the npm and trusted-publisher behavior.

## New mechanisms and their sources

Each new mechanism names a source that runs it and the defect it answers.

- Sign test on paired drafts, both-order judging, knockout arm: Anthropic's statistical approach
  (paired differences), Zheng et al. (position bias), mutation testing. Answers contract 1 to 3 and
  the September data the contract review measured.
- Stylelint plugin: Primer, Polaris, Atlassian, Mozilla. Answers a custom parser's maintenance
  under the ESLint-style policy (P2).
- Token diff release gate: Adobe Spectrum's token-diff generator. Answers prior-art 3.
- Immutable releases: GitHub's feature. Answers integrity 14.
- Atomic fetch by temporary directory and rename: the standard pattern. Answers the half-written
  directory and stale files verified in `fetch_skill`.
- `skills:` preload: Claude Code's documented field, already used here. Answers prior-art 1.

## Owed

- **A verification read.** This is a `live-account` design, so a fresh agent reads this revision
  against this record and the four reviews.
- **The initiative's README and `initiative.yaml`.** Both are stale: no writing half, and 907-life is
  listed as a consumer. They were outside this fold's two files.
- **The coordinator's check.** Confirm that Geoff's "cairn's docs move to the Survey register in
  Pass E as designed" means the spec's existing design (pin in Pass E, register convergence in
  cairn's own pass) and not a convergence inside Pass E.
- **PR #131** (`glw907/dotfiles`, open, global CLAUDE.md line). Pass E's workstation PR stacks on
  it if it is still open.
