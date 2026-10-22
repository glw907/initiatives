# Survey writing restructure

Target: `survey-house-style/specs/2026-10-21-survey-house-style-design.md`, branch
`survey-house-style`, revised from HEAD `ffce48d`. Input: seven owner rulings from Geoff dated
2026-10-22, plus a coordinator request for a Claude-infra inventory. The visual part (the lever
ladder through versioning, and Passes A to C) is unchanged; no ruling touched it. Scratch probes
live under
`/tmp/claude-1000/-var-home-glw907--dotfiles/cd716614-5551-4ef9-a8d1-4ccc7fe74ceb/scratchpad/restructure/`.

`node src/check-brief.ts design <spec>` in `approval-queue/approval-queue` exits 0 on the revision.
`tellgrader --register docs --profile docs-register` exits 0 (one trailing-hinge run it found in
the infra map's skill paragraph was rewritten). The spec holds no em dash.

## What changed, ruling by ruling

### Ruling 1: base standard first, Survey flavor second

- New section "Writing contexts": eleven packs plus `core`, fourteen surfaces, each row naming its
  base standard, its base linter, and the workstation file Pass E moves verbatim. The base and
  linter columns come from the charter's audiences table and the four conventions skills.
- Non-goals: the two exclusions (website content; code comments, commit messages, agent-facing
  files) are gone. Two new non-goals keep scope honest: grading human-written writing (the
  charter's "not a quality gate for human-written content") and replacing a base's own linter.
- Site content: today's base is `~/.claude/docs/web-content-method.md`, which cites no published
  standard (grep of the file found only Wikipedia's "Signs of AI writing" page). It moves as is;
  naming a published base is an improvement for Pass J. This avoids inventing a base the ruling
  did not name.
- The charter's site-content line is rewritten in Pass F, per the ruling's own wording.
- Replies have no pack: the output style's text is the `core` pack, which already governs them.

### Ruling 2: a pack per context

- New section "Context packs": the six files of the full shape (`standard.md`,
  `examples/base.md`, `examples/house.md`, `flavor.md`, `tells.md`, `checks.md`) and an eval set
  at `evals/<pack>/` that never ships. Pass E fills each pack with `pack.md` only, today's text,
  so the shape arrives as improvements (ruling 4).
- House-example sources: approved PR bodies and packets (the approve verdicts in
  `~/.local/state/approval-queue/decisions.jsonl`), merged docs, posts, and public corrections.
- Passes I (eight code and workflow surfaces) and J (six prose surfaces plus the house register)
  build the shape, weakest surface first.

### Ruling 3: other projects use Survey

- New section "Channels and pins" and new Pass G (adoption). npm repos keep the Pass D fold's
  committed copy with a `diff -r` gate. Repos without npm pin a release zip in `.vale.ini`
  `Packages`. The workstation pins the vendored `survey` skill by tag.
- Pass G lists every repo by channel, from a probe of each repo's `package.json`, `.vale.ini`,
  and GitHub visibility. aksailingclub-legacy is out (the `asc-cutover` README says the
  initiative archives it). fishwright joins if it holds prose.
- The `glw907` rules move into the `Survey` Vale style unchanged in Pass E; their comment tells
  reach the comment packs' `tells.md` in Pass I.
- Removed: the two Decide blocks "Whether Survey's Vale style takes over the glw907 tells" and
  "Which repos the Survey register governs", and the inheritance bullet that applied only under
  the glw907 option.

### Ruling 4: do not break what works

- New section "Evals and the baseline" and new Pass D (baseline before anything moves).
- Pass E moves content verbatim, `cmp`-checked, and runs the candidate arm against the baseline.
  Pass F switches only surfaces that matched.
- Thin pointers: each register path becomes a relative symlink into the vendored pack. Every
  reader sees the same bytes at the same path, which is the strictest form of "verbatim". The
  four conventions skills and the router get pointer text, which the candidate run evaluates
  byte for byte before Pass F lands it.
- Old files: Pass F deletes nothing. The symlinked paths keep their bytes, the baseline snapshot
  (`evals/baseline/<commit>/` in the survey repo) keeps every old file for as long as the
  baseline is the comparison, and each switch is one commit that reverts alone. I read ruling
  4(b) and 4(d) together this way: (b) builds the pointers, (d) forbids losing the old content
  until the new path has run cleanly, and neither requires keeping two live copies.
- Rollback is one line per repo: the `package.json` version, the `.vale.ini` URL, or the
  `vendored-skills.json` tag.
- "Match" and "beat" are defined numerically against the baseline's mean and one standard
  deviation, with a 60% blind-preference threshold, and a scope rule for which surfaces a change
  must re-run.
- Improvements come only in Passes I and J and the monthly distill, each a minor.

### Ruling 5: corrections must be easy to take

- New section "Corrections": the ledger, the chat route, the approval-queue harvester, notes, and
  the publication rule. New Pass H builds them.
- Private store: a private GitHub repo, `glw907/survey-ledger`. Evidence: corrections arrive on
  both hosts and from GitHub; the workstation already keeps private material in private GitHub
  repos (`gh repo list --visibility private` lists phonebook and servers); the initiatives repo
  is public, so it can't hold the ledger; the approval queue's per-host state directory splits by
  host, which its decision review accepts only because each host's queue stands alone
  (`docs/decision-review/prompt.txt`: "Queue state lives per host").
- Cadence: monthly, from the existing timers (`decision-review.timer` and `model-review.timer`
  both read `OnCalendar=monthly`).
- Sanitizing: an example ships only from a correction whose source repo is public. A private
  correction informs only generalizations, which go to Geoff in a packet.

### Ruling 6: the cairn editor channel

- In "Corrections", the cairn-editor bullet. Attribution exists for Geoff's saves: committer
  `cairn-cms[bot]`, author the editor. The draft side has no reliable marker, so the drafting
  session adds one trailer, `Survey-Draft: site-content`, through one line in `content-draft`.
  Nothing is asked of Geoff.

### Ruling 7: grade the writing periodically

- New section "The monthly writing review", chained from the monthly model review as its step 9
  (the way step 8 chains the servers review), with a guard so the second host only harvests.
- Two grades per surface: the fixed tasks (three runs, comparable over time) and up to five real
  Claude-written pieces shipped since the last run. Scorecards live in the private ledger, since
  real samples and Geoff's verdicts can come from private repos; the public log in the survey
  repo carries counts only.
- Drops open a backlog item through `log-issue`; the distill takes the lowest-scoring surfaces
  first. Six blind pieces a month calibrate the judge against Geoff.

### Coordinator request: the Claude-infra map

- New section "The Claude-infra map": a table of every piece the writing work touches, its home,
  its change, its pass, and the Anthropic page it follows, plus the pieces that change nothing.
  Pass F's commit order puts the always-on pieces last: the CLAUDE.md line, then the output style.
- Skill count: one `survey` skill (visual route from Pass C, packs, corrections route), the
  existing `writing-voice` as the router under its own name, and no skill for distill or grading.
  Evidence: ruling 5 names "a `survey` skill route"; Anthropic's skill guide says Claude uses
  each description "to choose the right Skill from potentially 100+ available Skills";
  `prose-voice-reviewer` preloads `writing-voice` by name (`skills:` in its frontmatter), so a
  rename would change triggers and break the preload; both monthly reviews run from a committed
  `prompt.txt` with no skill.
- The approval-brief register keeps its path because the approval queue's gate reads exemplars
  from it (`tests/approval-queue.test.sh:209`) and `src/lib/brief.ts:8` prints it in refusals.

### Other edits

- The brief: headline, lede, What changes, If you approve, the drafter Decide block, and Worth
  knowing are rewritten. The brief through Worth knowing is 785 words, down from 852.
- The drafter Decide block is narrowed. drafter already inlines tracked repo files, so the
  committed copy reaches it with no change; the open question is only whether a missing section
  fails the run. Estimate 40 minutes, down from 60, since admitting an ignored directory and
  feeding `register.<track>` are no longer needed.
- The old writing section's content (voice and tone, drafter stock, departures, corpus licensing,
  copy-editing rules, Vale rules, judgment layer, versioning) moved to "The house register" and
  Pass J. Paths changed from `writing/` to `packs/`. Pass J carries the old Pass D's sources,
  ledger counting rules, and sitting unchanged in substance.
- Old Pass D became Pass J. New Passes D to I are listed below.
- "What each app's pass inherits": the cairn's-docs bullet now refers to Pass J's harvest commit
  and to cairn-cms's pinned packs.
- End-to-end check: the old Pass D leg is replaced by four writing legs.
- Stops: the old Pass D stops are reworded for Passes E to J, fourteen new writing stops cover
  the baseline, the cutover, adoption, the ledger, and the monthly run, and the escalation list
  is updated.
- Risk and estimate: a table with each pass's path minutes and breakdown.
- Rulings: the seven rulings are recorded as a numbered list after the existing paragraphs.

## The pass list

| Pass | What | Class | Path minutes |
|---|---|---|---|
| A | Visual harvest and rulings | `ordinary` | 210 |
| B | Repo and 1.0.0-rc.1 release | `runner`, `live-account` | 460 |
| C | Workstation tooling (visual) | `runner` | 160 |
| D | Writing evals and the baseline | `runner` | 320 |
| E | Verbatim move, 1.1.0 | `runner`, `live-account` | 300 |
| F | Workstation cutover | `runner` | 200 |
| G | Adoption in every repo with prose | `runner` | 280 |
| H | Correction ledger and monthly review, 1.2.0 | `runner`, `live-account` | 380 |
| I | Code and workflow packs | `runner`, `live-account` | 420 |
| J | Prose packs and the house register | `runner`, `live-account` | 520 |

Total 3,250, plus 40 for drafter if Geoff takes that option. Order: A, B, then C and D (D needs
only B's repo), the approval queue's pass to 1.0.0, E, F, then G and H side by side (no shared
repo), then I and J.

## Every mechanism and its source or probe

| Mechanism | Source or probe |
|---|---|
| Vale loads a version-pinned GitHub release zip by URL | Probe `ghprobe/`: `Packages = https://github.com/errata-ai/Google/releases/download/v0.7.1/Google.zip`, `vale sync` exit 0, 38 files installed (Vale 3.24.0). |
| A `packs/` folder inside the style directory survives `vale sync` and is ignored by Vale | Probe `zipprobe/`: zip with `Survey/styles/Survey/{Utilize.yml,packs/}`; after sync the packs were present; `vale --output=JSON` raised `Survey.Utilize` and nothing from `packs/`. A `styles/config/survey-packs/` folder was dropped by sync, so packs can't ride there. |
| A committed Google style not named in `Packages` survives a Survey sync | Probe `zipprobe/repo`: `.vale/styles/Google/Probe.yml` kept after `vale sync`. |
| Pin-only `.vale.ini` adds no findings | Probe `zipprobe/pinonly`: `Packages` names the zip, no `BasedOnStyles`; sync installed style and packs; lint exit 0 with no output on a file full of tells. |
| Zip diff check | Probe `zipprobe/pinonly`: extract the URL from `Packages`, `curl` and `unzip` to a temp dir, `diff -r` against the committed copy; exit 0 in sync, 1 after a local edit. |
| npm diff gate | The Pass D fold's probe (`foldd/`), relied on as recorded in `2026-10-22-survey-pass-d-fold.md`. |
| Vendored skill pinned by tag | `fetch_skill` (`~/.local/bin/claude-tooling-sync:397-421`) calls `repos/{repo}/commits/{branch}`, `git/trees/{branch}?recursive=1`, and `contents/{p}?ref={branch}`. Probe: all three accepted `v0.7.1` on `errata-ai/Google`. |
| Packs must sit under the skill's path | `fetch_skill` filters `t["path"].startswith(path + "/")`. |
| drafter reads tracked repo files | `resolve` in `drafter/internal/assemble/files.go` accepts `r.tracked[t]`; `sectionBlock` in `section.go` returns "no excerpt: no heading <slug>" for a missing heading and the run goes on; a missing file yields "not inlined: missing". Read at `568c262`. |
| Output style through a relative symlink | Probe `styleprobe/`: `.claude/output-styles/probe-style.md` symlinked to `../skills/survey/packs/core-style.md`; `claude -p --settings '{"outputStyle":"probe-style"}'` followed the style. |
| Headless arm loads a chosen output style | Same probe: the style's instruction applied with `--settings`; without it, it did not. |
| `--disable-slash-commands` removes skills but keeps the style | Probe: the session reported no Skill tool, and the style's instruction still applied. `claude --help`: "Disable all skills and commands". |
| `stow` links a package file that is itself a symlink | Probe `stowprobe/`: `stow -d dot -t home claude`; `readlink -f` resolved to the pack file and `cat` printed its text. |
| Output styles don't reach subagents; read at start | <https://code.claude.com/docs/en/output-styles>: "Other subagents run their own system prompt, so styles don't change how they respond"; "Claude Code reads style files when it starts"; `/output-style` "lists the styles you can pick and marks the current one" and works in non-interactive mode. |
| Approval queue reads the brief register at a fixed path | `approval-queue/tests/approval-queue.test.sh:209` (`register="${REGISTER:-$HOME/.claude/docs/voice/approval-brief.md}"`) and `approval-queue/approval-queue/src/lib/brief.ts:8` (`REGISTER_PATH`). |
| Decision data for the harvester | `approval-queue/README.md` ("The decision JSON and the decision log", "Comments and replies"): `decisions.jsonl` lines carry `comments` and `replies` counts; comment text and anchors live in each item's `decision.json`. Inspected `~/.local/state/approval-queue/items/`: send-back `note` fields and triage row notes present; no comments yet. |
| In-place prose edits in review | `approval-queue/approval-queue/src/lib/server/blueprint.ts:90`: `git commit -m "Edit ${file} in review"`. |
| cairn save attribution | `cairn-cms/src/lib/github/repo.ts` (`commitFiles` doc comment): "The author is the editor; the committer is omitted, so GitHub attributes the commit to the App." Observed on 907-life `18644a5`: author `Geoff Wright <geoff-login@907.life>`, committer `cairn-cms[bot]`. Publish message `Publish ${concept.label.toLowerCase()}: ${id}` (`content-routes-entry-write.ts:398`). |
| Pending branches vanish at publish | `src/lib/content/pending.ts` (`cairn/<concept>/<id>`), and `content-routes-entry-write.ts` deletes the branch after the publish commit lands. |
| Claude's co-author trailer is not a draft marker | Counted on `origin/main`: 907-life 239 of 256, ecxc-ski 380 of 400, aksailingclub-org 374 of 400, xcathletes-org 220 of 226, cairn-pub 60 of 63. It marks every Claude commit, code included. |
| `Survey-Draft` trailer and the harvest queries | Probe `trailerprobe/`: with `--trailer` the trailer joins the co-author block and `%(trailers:key=Survey-Draft,valueonly)` returns it; written as its own `-m` paragraph it is not parsed. `--committer='cairn-cms\[bot\]' --author=geoff-login@907.life <draft>..main` returned Geoff's save and skipped a volunteer's; `git diff --word-diff` showed the correction. git 2.56.0. |
| Monthly cadence and home | `~/.dotfiles/upkeep/.config/systemd/user/model-review.timer` and `decision-review.timer` (`OnCalendar=monthly`); `model-review-notify` runs `claude -p` unattended in a worktree and has `--dry-run`; `docs/model-review/prompt.txt` step 8 chains the servers review. |
| Private repos as the workstation's private store | `gh repo list glw907 --visibility private`: servers, phonebook, cairn-themes, cairn-pub, xcathletes-org, fishwright, aksailingclub-legacy. `gh repo view glw907/initiatives`: public. |
| Characterization testing | <https://michaelfeathers.silvrback.com/characterization-testing>, quotes verified by fetch. |
| Evaluation-driven development, three scenarios, one-level references, scripts for deterministic work, the 100+ skills line | <https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices>, quotes verified by fetch. |
| Different model as judge; volume over quality | <https://platform.claude.com/docs/en/test-and-evaluate/develop-tests>, verified by fetch. |
| Snapshot baseline, `aggregate_benchmark`, the viewer and its `feedback.json`, the analyst's non-discriminating assertions | skill-creator `SKILL.md` lines 184-186, 229, 234, 247 and `eval-viewer/generate_review.py:6`. |
| Examples steer output; 3 to 5 examples; say what to do; give reasons | Anthropic prompting best practices, as verified in the Pass D fold. |
| Hook, skill, CLAUDE.md order | <https://code.claude.com/docs/en/features-overview>, as quoted in the `claude-infra` skill. |

## Decide blocks left

1. **Whether drafter stops a run when a Survey section is missing.** Recommended: a short drafter
   pass (about 40 minutes, `ordinary`) that fails the run on a missing file or heading under a
   Survey path. It matches the charter's fail-closed rule ("No audience, no system"). The other
   option moves the check into each repo's gate. It stays Geoff's because it is scope in a third
   repo.

No other fork remained. The private store, the cadence, the skill count, the sample size, and the
match and beat thresholds are mechanism calls taken from the evidence above.

## Owed

- No lens review or verification read has run on this revision. Passes B, E, H, I, and J carry
  `live-account`, so `spec-plan-review` calls for the three lenses and a verification read before
  Geoff reads the design.
- The path figures are first estimates with no recent score to set them from. The planner checks
  each against its plan.
- The thresholds (one standard deviation, 60% blind preference, one rubric point as "too wide")
  are judgment calls from the September benchmark's spreads, not from a published standard. A
  lens review should test them against `writing-voice/evals/results/2026-09-01-iteration-3/`.
- Not probed: an end-to-end `claude -p "/output-style"` check of the real `writing-voice` style
  (the docs are quoted instead); a real GitHub release of `Survey.zip` (a third-party release
  stood in); `sha256sum -c` over a vendored directory (standard coreutils behavior).
- Both hosts run `model-review.timer`. The writing review's guard handles that, but the model
  review itself has no host guard; that is outside this design and may deserve a backlog line in
  the workstation repo.
