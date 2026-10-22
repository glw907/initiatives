# Survey rewrite fold: verification read

Target: `survey-house-style/specs/2026-10-21-survey-house-style-design.md` at `a4b30e5` (branch
`survey-house-style`), read against `2026-10-22-survey-rewrite-fold.md` and the four reviews
(contract, integrity, mechanics, prior-art). Process: `spec-plan-review` "The verification read" and
`pass-core` step 4 (pre-flight is "every step only Geoff can do").

Counts: 1 blocker, 4 majors, 12 minors (8 `correctness`, 4 `optional`).

## Checks run

- **Brief.** `node src/check-brief.ts design <spec>` in `approval-queue/approval-queue` exits 0. The
  spec holds no em dash.
- **Estimates.** Every per-pass breakdown sums to its row (B 520, D 690, E 720, F 485, G 360,
  H 1,080), and the total is 4,065.
- **Sign test.** One-sided at α = 0.05 over nine decisive pairs: P(≥8 of 9) = 10/512 = 0.0195 and
  P(≥7 of 9) = 46/512 = 0.090, so "at nine such pairs that takes eight" is right. Over six fresh
  pairs, a miss needs 6 of 6 (p = 0.0156). The quoted source checks out: Anthropic's page says
  "conducting a paired-differences test lets us eliminate the variance in question difficulty".
- **Single `skills/survey/` layout.** `fetch_skill` (`~/.local/bin/claude-tooling-sync:395-422`)
  copies only blobs under the entry's path into `claude/.claude/skills/<name>` in `~/.dotfiles`,
  writes in place, never deletes, and applies overlays after the fetch. Fold probe P1 covers Vale
  ignoring `SKILL.md`, `SHA256SUMS`, and `packs/`. New probe (Vale 3.24.0): Vale skips the
  `StylesPath` directory itself on a tree run, whether or not it is hidden, so pack files that hold
  deliberate tells do not show up in a repo's own Vale findings.
- **Eval arm isolation.** New probe: `claude -p --setting-sources project --model haiku` in an
  empty scratch repo listed only built-in and plugin skills, and no user skill (`writing-voice` and
  the conventions skills were absent). So project-only arms do not load the user's skills, which
  P3 had not shown.
- **Host check.** `hostname` on pavilion prints `pavilion`.
- **Public-permalink rule.** `gh repo view --json visibility`: 907-life, cairn-cms, ecxc-ski,
  aksailingclub-org, and approval-queue are PUBLIC; xcathletes-org and cairn-pub are PRIVATE. A
  private repo that CI's token can't see errors out, which counts as private, so the check fails
  safe.
- **`content-draft` direct commit (M7).** None of the five site repos protects `main` (404 on the
  three public ones; the private ones are on a plan without protection), so a direct
  default-branch draft commit can land.
- **Atomic `fetch_skill`.** Not probed. See minor 1.
- **cairn's readers today.** `docs-register.md` cites no `~/.claude/docs/voice/` file, and
  `cairn-register-editor`, `cairn-docs-drafter`, and `register-check` read only `docs-register.md`.
  `~/.claude/workflows/docs-page-chain.js` is a symlink into drafter.

## Blockers and majors from the reviews: closure

Every blocker and major closed at its cited location, except the owner forks, which are now Decide
blocks:

| Finding | Closed at |
|---|---|
| Contract 1, 2 (B), mechanics B1 | Evals "The decision" (L242), stop L437, Pass G stop L465 |
| Contract 3 | Evals "Knockout" (L243), stop L438 |
| Contract 4, mechanics M2 | Evals "Arms" and "Graders" (L240-241); but see major 1 |
| Contract 5 | Writing contexts (L218-220), Evals "Tasks" (L239), step 4 (L265) |
| Contract 6, 7, 10; integrity 7 | Evals "Stored drafts" and "Breaks" (L244-245) |
| Contract 8 | Evals "Geoff's read" (L246), step 5 (L266) |
| Contract 9 | step 8 (L269), Pass F acceptance (L373) |
| Contract 11 | step 4 (L265) |
| Contract 12, integrity 1 (B) | Context packs (L233), Corrections (L256), L246, steps 7-9; but see major 2 |
| Integrity 2 (B), mechanics M4 | step 1 (L262), release gate (L180) |
| Integrity 3 | Pass E "The workstation" (L355), stop L445; but see major 4 |
| Integrity 4, mechanics B2 | Channels and pins (L187-197), map L291-293; but see minors 1 and 3 |
| Integrity 5 | map L293, Pass E acceptance (L357) |
| Integrity 6, mechanics M7 | Corrections "The cairn editor" (L255) |
| Integrity 8, mechanics M6 | Versioning "Rollback" (L183), stop L431, L499 |
| Integrity 9 | Decide 2; but see major 3 |
| Integrity 10 | steps 2, 8, 9 (L263, L269-270) |
| Mechanics B3 | Context packs (L224, L233), Pass H (L392) |
| Mechanics M1 | Consolidated: skill written in Pass B (L330), map L290 |
| Mechanics M3 | "Taking a release" (L196) |
| Mechanics M5 | monthly review (L260), Pass F acceptance (L373) |
| Mechanics M8 | Risk and estimate (L478-490) |
| Mechanics M9 | Pass E "npm channel" (L358) |
| Mechanics M10 | Versioning "Release" (L181), stop L430 |
| Prior-art 1 | Agent-friendly (L166), map L295 |
| Prior-art 2 | Evals (L237-242) |
| Prior-art 3 | Release gate (L180); but see minor 2 |

## Findings

### Blocker 1. correctness. cairn's convergence contradicts Geoff's Pass E ruling and cannot sit in Pass E at the current order

Location: spec L85 against L33, L108, L220, L278, L282, L310, L401; fold record L27-31, L368-370.

Defect: Geoff ruled on 2026-10-22, when asked whether cairn's docs should move in Pass E or wait,
that they move in Pass E during the ongoing cairn docs effort, accepting the small risk. L85 records
that. But the non-goal at L108 ("cairn's move of its own docs register onto Survey's packs. Each is
the app's own pass"), brief step 10 (L33), L220 ("until cairn's own convergence pass"), L278 and
L282 ("once cairn converges"), L310 (three readers "keep cairn's register until cairn's own
convergence pass"), and the inherited bullet at L401 all still defer it. L73 ("When this work is
done, cairn uses the Survey register") also conflicts with L108. The fold read "as designed" as pin
only and flagged it as owed (fold L27-31, L368-370). That reading is wrong.

There is also an ordering problem. Pass E comes before Pass G, and Pass G is where the house register
gets built: its sources include cairn's `docs-register.md` (L380), and Geoff rules there which cairn
rows are house-wide and which are cairn-only (L382). At Pass E, Survey's `dev-docs-web` and
`end-user` packs are verbatim copies of `technical-doc-web.md` and `editor.md`, and cairn's readers
don't read those today. So L401's convergence (diff from Pass G's harvest commit, shrink the file to
its cairn-only parts, move the readers) has nothing to converge onto at Pass E. Also, no Pass D
surface measures cairn's docs pipeline, so "behind the baseline match" has no baseline.

Proposed fix, the simplest that puts the convergence in Pass E: run Pass G before Pass E, and move
L401's paragraph into Pass E as one bullet.

1. **Order (L130, brief L28-31).** A, B, D, the approval queue's pass, G, E, F, H. Pass G needs only
   Pass D's packs and rules (it already does), and its all-surface match runs against Pass D's stored
   baselines. The drafter pass, if taken, still runs before G. Pass G's minor is 1.2.0. Pass E then
   lands 1.2.0 (L337, L353, L413 "From 1.1.0 on" stays), and Pass F releases 1.3.0 (L19, L31,
   L126, L367). Pass H follows F as now.
2. **Baseline (Pass D).** Add two cairn surfaces to the baseline run: the `dev-docs-web` tasks and
   the `end-user` docs tasks, drafted in a cairn-cms arm whose project carries cairn's register and
   readers at a recorded cairn-cms commit. That is six tasks, 18 baseline drafts plus the knockout,
   about 30 minutes. They are not packs or surfaces of Survey, and they leave the monthly review.
3. **Pass E (new bullet "cairn's docs", replacing L401).** Use L401's text from "That pass first
   diffs" on, with the subject changed to Pass E's cairn-cms task: diff cairn's register from Pass G's
   harvest commit to head, keep each new row cairn-only (a later minor can widen it), shrink the file
   to its cairn-only parts pointing at cairn-cms's pinned packs, and move every reader across
   drafter, `~/.dotfiles`, and cairn-cms, with the same fail-loudly rule. It switches only when both
   cairn surfaces match. The `~/.dotfiles` reader moves join the workstation PR before the CLAUDE.md
   line. The drafter and cairn-cms changes are their repos' Pass E PRs. Estimate about 150 minutes
   on Pass E and 30 on Pass D (the total becomes about 4,245).
4. **Stops (Pass E).** A cairn surface repeat-misses: cairn keeps its register and readers, its
   pin still lands, and the PR escalates. A cairn page in mid-draft: it finishes on the register its
   chain started with (the accepted risk), and the PR lists it.
5. **Remove the deferrals.** Drop the L108 clause and brief step 10's "and cairn's docs". Rewrite
   L220 ("until Pass E's cairn step"), L278 and L282 ("once cairn converges in Pass E"), and L310's
   sentence. Delete the L401 bullet from "What each app's pass inherits".
6. **Fold record.** Mark the owed coordinator check (L368-370) answered: convergence happens in
   Pass E.

If Geoff would rather not move Pass G, the smaller alternative splits the move. Pass E moves only
the readers onto the pinned packs, with `docs-register.md` unchanged as the overlay, behind the same
two cairn surfaces. Pass G's close then shrinks the file once its sitting has ruled the rows. This
is two steps where the reorder needs one, so the reorder is simpler.

### Major 1. correctness. Eval arms resolve absolute home paths, so the Pass D candidate can't find its packs and a later baseline redraft reads current Survey

Location: L240 ("Arms"), L245 ("Breaks"), L345 ("Pointer texts"), L339 (snapshot).

Defect: The `writing-voice` router names absolute paths (`~/.claude/docs/voice/approval-brief.md`
and the rest; `writing-voice/SKILL.md:23-32`). The candidate pointer texts are "the exact bytes Pass
E lands" (L345), so they name the vendored `~/.claude/skills/survey/...` path or the symlinked
registers. `--setting-sources project` isolates settings and skills (probe above), but Read still
resolves any absolute path. That has two effects. (a) In Pass D, the candidate arm's pointers name
`~/.claude/skills/survey/packs/...`, which doesn't exist until Pass E vendors it. The candidate then
drafts without its pack, the pack-read measure fails, and every switched surface misses. (b) The
baseline arm reads the live home files, not the snapshot. After Pass E those are symlinks to the
current vendored packs, so when "a new drafting model redrafts the stored baseline from its files"
(L245), the baseline runs today's Survey, which makes the comparison meaningless. P3 used a
project-relative pack path, so it did not exercise this.

Proposed fix: one sentence in "Arms". The runner copies each arm's files into its project and
rewrites the `~/.claude/` prefix in those copies to the project's `.claude/` path. The pack-read
measure matches that project path. Add an acceptance line: no Read in any arm's transcript lands
outside its project.

### Major 2. correctness. The public-permalink gate fails every drafted house example that Pass H's stop calls for

Location: L233 against L471; L474 ("the public-permalink rule ... never escalate").

Defect: L233 requires every house example to name a GitHub permalink in a public repo, and "a
source it can't resolve counts as private", so the gate fails it. Pass H's stop at L471 answers "fewer
than three house examples" with "Claude drafts the rest, marks each one drafted". A drafted example
has no permalink, so the release gate fails, the rule never escalates, and Pass H can't release any
pack short of examples. The fold introduced this contradiction.

Proposed fix: in L233, an example is either sourced (public permalink, checked) or marked
`drafted`, which needs no source because Claude wrote it in the public repo. The gate passes a
drafted example only when it has no ledger id, so a private correction can't be relabelled as
drafted to get through.

### Major 3. correctness. Decide 2's recommendation skips Geoff's standing dependency rule and has no failure answer

Location: L44-52 (Decide 2), L264 (step 3).

Defect: The global rule says every dependency bump goes through `dependency-upgrade`, every minor
and patch is taken by default, and Geoff is always asked before a major. Option 1 moves the tag "to
the newest release" unattended, with no packet, so it would take a major (a renamed pack or a
removed section) without asking. The block doesn't say it departs from that rule, so Geoff rules
without seeing the conflict. The reason given ("each release has already passed its baseline") is
not true of a major: a rename breaks the seven links, the `readlink` check (L293) fails the commit,
and no stop says what the monthly run does then. Option 2 is the one that matches the rule, and the
block should say so.

Proposed fix: option 1 becomes "moves the tag to the newest minor or patch; a major goes to Geoff
in the month's packet". Add a stop under "Pass F and the monthly run": the tag move fails the
dotfiles gate, so leave the tag, grade at the old pin, and put the failure in the review record.
Add one line to the block naming the `dependency-upgrade` rule and saying option 1 is a recorded
exception to it.

### Major 4. correctness. Pass E's mid-pass "Survey patch" is a release Pass E's class and versioning don't allow for

Location: L355, L445 against L125, L178, L353, L437-439.

Defect: approval-brief.md changes often (integrity 3's evidence), so this path will probably run.
When a workstation file differs from its pack at `HEAD`, Pass E "carr[ies] the change into a Survey
patch, move[s] the tag, then link[s]". Three problems follow. (a) Under L178 a changed rule or tell
is a minor, not a patch. (b) Writing changes must match their baseline (ruling 4), and Pass D's
equivalent stop re-runs that surface's baseline and candidate (L439), but Pass E's stop has no eval
step. (c) It publishes to npm, while Pass E is `runner` only (L125, L353), so its plan would skip
the `live-account` review. It also leaves open which version the thirteen repos pin.

Proposed fix: Pass E's row carries `live-account`. L355 and L445 say "carry it into a Survey minor
through Pass D's stop answer (re-baseline that surface, run its candidate), release it, move the
tag, then link". Every repo pins the newest release at its PR.

### Minor 1. correctness. "Renames it over the old one" fails on a non-empty directory

Location: L193, L291.

Defect: `rename(2)` and Python's `os.replace` fail with ENOTEMPTY when the target is a non-empty
directory. A literal implementation errors on every update. A temporary sibling inside
`claude/.claude/skills/` that a crash leaves behind is also stowed and found as a skill.

Proposed fix: say "swaps it in" (`mv --exchange`, which the host's coreutils has, then remove the
old directory) and put the temporary directory outside the stow package. Apply overlays before the
swap.

### Minor 2. correctness. The release gate has no previous token set before 1.0.0, and the rc-to-1.0.0 renames conflict with it

Location: L180, L71, L182.

Defect: `npm pack @glw907/survey@latest` is the 0.0.0 placeholder until 1.0.0, and it holds no
token JSON. The ruling lets the 1.0.0 promotion change names freely, but the gate fails a rename
that has no `$deprecated` alias outside a major.

Proposed fix: the gate compares with the newest published version that ships token JSON, and it
is skipped for prereleases and for 1.0.0.

### Minor 3. correctness. The checksum check doesn't tie a copy to its pin

Location: L189, L192, L193.

Defect: In a zip repo, a `.vale.ini` URL moved to a new version without `vale sync` leaves the old
copy, whose own `SHA256SUMS` still passes. The vendored copy has the same gap against its tag. The
npm channel's `diff -r` has no gap.

Proposed fix: `skills/survey/` carries its version (in `SHA256SUMS` or the `SKILL.md`
frontmatter), and each gate compares it with the version in the URL or tag.

### Minor 4. correctness. The repeat-miss test is unstated, and Pass G's stop assumes a cause

Location: L242, L437, L465.

Defect: It isn't said whether the repeat test uses only the six fresh pairs or pools them with the
nine that already missed. Pooling would bias it. With five measures per surface, a full fifteen-surface
run has roughly a 75% chance of at least one first miss and about 10% of a repeat miss on noise
alone. Pass G's answer is to "trace it to the rule or row that caused it", but a noise miss has no
cause to trace.

Proposed fix: the repeat test uses only the fresh pairs. Pass G's stop adds that a repeat miss
with no traced cause is reported and the release proceeds.

### Minor 5. correctness. The `site-content` surface count is ambiguous

Location: L217, L220.

Defect: The row lists "blog posts, pages, form copy" in the same form `end-user` uses for its
three surfaces, yet fifteen surfaces needs `site-content` to count as one.

Proposed fix: write "one surface: blog posts, pages, and form copy".

### Minor 6. correctness. Whether a non-discriminating surface switches is unstated

Location: L243, L353, L438.

Defect: A surface whose knockout matches still "matches" its baseline. Pass E switches surfaces
that matched, so the switch on such a surface rests on a test that couldn't fail.

Proposed fix: either "it switches, since the move is verbatim, and the PR names it" or "it stays
unswitched". One clause.

### Minor 7. correctness. The committed style copy reaches other markdown checks

Location: L191, L361-362.

Defect: Vale skips `StylesPath` (probed), but a repo's other prose tools, such as `tellgrader`
profiles, markdownlint, link checks, and `drafter check`, may walk `<StylesPath>/Survey/packs/*.md`,
whose tells are deliberate. Repo acceptance compares only Vale.

Proposed fix: "Each repo" excludes the copy from the repo's other markdown checks, and repo
acceptance checks that every gate's findings match, not only Vale's.

### Minor 8. correctness. The monthly grade has no answer when pavilion is down

Location: L262.

Defect: `Persistent=true` covers a late boot. If pavilion is down or retired for a month, nothing
is graded and nothing reports it.

Proposed fix: `check-drift` reports a ledger with no review record for last month. One clause.

### Minor 9. optional. Pre-flight step 1 is not strictly Geoff-only

Location: L496, L499.

Defect: L499 has sessions running on thinkpad-x1, so a session there could run step 1's git
commands. Geoff's only part is being at that host.

Proposed fix: keep the step, or shrink it to "start a session on thinkpad-x1 and approve its
archive push". It is a judgment call under the pass-core definition.

### Minor 10. optional. The hook bullet holds detail the builder can settle

Location: L356.

Defect: The 10-second timeout, the 9000-character cap, the servers-repo carve-out, and the
extension pre-filter are implementation detail. The simplicity ruling leaves these out.

Proposed fix: keep what it does and its acceptance (L357). Move the rest to "Left to the builder".

### Minor 11. optional. Decide 1 doesn't show its interaction with Decide 2

Location: L35-42.

Defect: Under Decide 2's option 1, any month that follows a distill release moves the version, so
the months the recommendation saves may be few. Geoff can't weigh the saving without that.

Proposed fix: one sentence in the Decide 1 block.

### Minor 12. optional. The fold record's Owed list is out of date

Location: fold record L368-370.

Defect: The coordinator check is now answered by blocker 1.

Proposed fix: record the answer when blocker 1 is folded.

## Simplicity ruling

The fold mostly honors it: refused parts are named, and one helper, one skill home, and one
workstation PR replace several. Heavier than needed: the hook bullet (minor 10). Two checks do one
job differently, `diff -r` for npm repos and the checksum for zip repos. That is acceptable, since
`diff -r` also binds the copy to the installed version, and minor 3 closes the zip side the same
way. Blocker 1's reorder adds no mechanism. It moves one existing paragraph and swaps two passes.
