# Survey design: the synthesis rewrite

Target: `survey-house-style/specs/2026-10-21-survey-house-style-design.md`, branch
`survey-house-style`, rewritten in place from HEAD `a884f1d`. The spec had been folded four times
(the 2026-10-21 three-lens fold and its verification, the 2026-10-22 Pass D fold, and the
2026-10-22 writing restructure). This pass rewrote it as one document. It reopened no ruling and
stated no new mechanism; every mechanism in the new text is carried from the spec at `a884f1d` or
from a probe or source the four records cite.

Gates on the result: `node src/check-brief.ts design <spec>` exits 0; `tellgrader --register docs`
exits 0 with no findings and zero tells per 1,000 words; the file holds no em dash. The brief
through Worth knowing is 808 words, against 785 in the last draft.

## The pass list

| New | Outcome | Class | Minutes | Built from |
|---|---|---|---|---|
| A | Visual harvest and rulings | `ordinary` | 210 | old A, unchanged |
| B | Repo and `1.0.0-rc.1` | `runner`, `live-account` | 460 | old B, unchanged |
| C | Workstation visual tooling | `runner` | 160 | old C; render line made unconditional |
| D | Writing baseline and the verbatim move, 1.1.0 | `runner`, `live-account` | 590 | old D + old E |
| E | Adoption: the workstation, then every repo with prose | `runner` | 460 | old F + old G |
| F | Corrections and the monthly review, 1.2.0 | `runner`, `live-account` | 380 | old H, unchanged |
| G | The house register | `runner`, `live-account` | 300 | old J's register half |
| H | The packs | `runner`, `live-account` | 640 | old I + old J's pack half |

Order: A, B, then C beside D, the approval queue's pass to 1.0.0, then E, F, G, H in sequence.
The drafter option (40 minutes, `ordinary`) runs before G.

Eight passes, down from ten. The estimates sum to 3,200 (from 3,250). The path is 3,040 with C
beside D. The old shape's path was 2,810 when old G ran beside old H, so this shape trades about
230 path minutes of machine time for two fewer passes, two fewer packets, and one fewer sitting.
Geoff's standing preference for batched, front-loaded interaction decided the trade.

## What changed and why

### One document instead of four folds

- One **Intent and goals** section replaces four (Intent, Goals, Non-goals, Anti-goals). The
  writing and visual intents are stated together, since they are one intent.
- A new **The shape of the work** section says what the two halves share (repo, version line,
  release workflow, channels, the one `survey` skill as the agent-facing entry, the Claude-infra
  map) and carries the pass table with outcome, repos, class, minutes, and the dependency order.
  This is the planner's entry point.
- **Versioning and release** now holds the whole policy: tokens (Spectrum), the checker (ESLint),
  and the writing part (the `writing` rung, Vale rule levels). The writing versioning bullet left
  "The house register", where it sat as a fourth home for one rule.
- **Channels and pins** states that visual consumers pin through npm alone and the writing part
  adds the zip and vendored-skill channels, so the section serves both halves once.
- **Agent-friendly by construction** now names the one `survey` skill as the entry for both
  halves and carries the "why one skill, why `writing-voice` keeps its name" reasoning, which the
  infra map used to repeat.
- **Stops and standing answers** is grouped by the pass that meets each stop first, with three
  universal answers (clock, STRUCTURAL rounds, drift) stated once at the top. This gives each pass
  its stops without a second list.
- Each pass section opens with one sentence naming outcome, repos, class, and estimate, so the
  pass table and the pass sections agree by construction.
- The brief's **If you approve** is eleven steps for eight passes plus pre-flight, the approval
  queue's pass, and the apps' passes.

### Merge 1: old D and old E become Pass D

Old D (baseline) and old E (verbatim move and 1.1.0) shared the survey repo, the `pass-core`
default gate, and a strict sequence (E's candidate run needs D's baseline). The only thing between
them was Geoff's blind read of the baseline drafts. The spec already said that read does not gate
the move ("the move still only has to match"; a weak mark orders Pass H). So the read rides on
Pass D's close packet beside the PR, and ruling 4's "small sample shown to Geoff" still holds. One
pass, one packet, one fewer sitting. The stop "1.0.0 is not out when the PR is ready" stays.

### Merge 2: old F and old G become Pass E

Ruling 3 names the workstation as one of the repos adoption covers. Old F (workstation cutover)
and old G (every other repo) were both `runner`, both after 1.1.0, and old G was ordered after
old F. The merged pass lands the `~/.dotfiles` PR first, in old F's commit order with the output
style last, then one PR per repo, all in one packet (old G already sent its PRs in one packet).
Old F's acceptance is kept whole as "Workstation acceptance". The cost is that Pass F
(corrections) now waits for adoption to finish, since both touch `~/.dotfiles`; old H ran beside
old G.

### Reorder: the register before the packs

Old I wrote `flavor.md` for eight packs, and every `flavor.md` names `packs/core/voice.md` as its
first read and carries departure ruling ids. Old J built `voice.md` and held the departures
sitting. The two passes were unordered ("then I and J"). That is a dependency the last draft left
open, not a ruling conflict. The rewrite splits old J into its register half (Pass G: sources
ledger, sitting, voice file, departures, style sheet, Vale rules, licensing, drafter leg) and its
pack half, and merges the pack half with old I into Pass H, which takes all fourteen surfaces in
scorecard order. Pass G's release must match on all fourteen surfaces, because it changes the
Survey Vale style that every surface's checks run. Pass H's note that it "can close at any pack
boundary" follows from each pack being its own minor.

## Ruling conflicts resolved

1. **Pass C's render line was conditional.** Old C read "If the brief's render decision takes the
   first option, `dependency-upgrade` gains its one line." The 2026-10-22 rulings paragraph had
   already settled it ("Every minor or major Survey bump in an app needs a full-page render ...
   and Pass C adds that line"). The line is now unconditional, with the ruled wording.
2. **A site's interface text.** The Pass D fold took the call that a site's interface text stays
   with its content guide and said the workstation PR "adds that boundary line to
   `writing-voice`". Ruling 1 makes site content a Survey context with the site's guide as its
   overlay. The two agree once the boundary is named, so "Writing contexts" now says it: a house
   tool's interface text is `end-user`; a site's form copy, labels, and errors are `site-content`
   under the site's guide. The router rows carry it in Pass E.
3. **Ruling 3 versus the Pass D fold.** The fold recommended keeping `glw907` outside Survey and
   governing only npm repos; ruling 3 superseded both. The restructure had already applied this;
   the rewrite keeps it and names the five `glw907` copies' retirement in Pass E's "Each repo".

## Findings and text dropped

- The Worth knowing sentences "The phonebook has no UI yet and adopts Survey fresh" and "The five
  hand-synced `glw907` Vale copies retire when adoption renames them" were cut to keep the brief
  near its previous length. The phonebook is named in step 11 and in Pass E's zip channel; the
  `glw907` retirement is in Pass E's "Each repo" bullet.
- The old "The house register" versioning bullet moved into "Versioning and release" (see above).
  No rule was dropped.
- The restructure's remark that the model review has no host guard stays outside this design; it
  is a workstation backlog candidate, as that record said.
- No folded correctness finding was dropped. Every acceptance criterion, fixture, probe citation,
  and standing answer in the spec at `a884f1d` appears in the rewrite, under its new pass letter.
- Changes of wording only: the old `survey-j-r1` ruling-id example is now `survey-g-r1`, matching
  the register pass's letter.

## Old-to-new mapping

| Old | New |
|---|---|
| Pass A | Pass A |
| Pass B | Pass B |
| Pass C | Pass C (render line unconditional) |
| Pass D (evals and baseline) | Pass D, first half |
| Pass E (verbatim move, 1.1.0) | Pass D, second half |
| Pass F (workstation cutover) | Pass E, "The workstation" and "Workstation acceptance" |
| Pass G (adoption) | Pass E, the channel lists and "Each repo" |
| Pass H (ledger and monthly review, 1.2.0) | Pass F |
| Pass I (code and workflow packs) | Pass H, eight of its fourteen surfaces |
| Pass J (prose packs and house register) | Pass G (register) and Pass H (six prose surfaces) |
| Intent, Goals, Non-goals, Anti-goals | Intent and goals |
| The house register, "Versioning" bullet | Versioning and release, "Writing" bullet |
| The Claude-infra map, "Three skills cover the work" | Agent-friendly by construction, lead paragraph, and the map's closing paragraph |
| Stops and standing answers (flat list) | Stops and standing answers, grouped by pass |
| Pre-flight | Pre-flight and sittings |

Sittings Geoff attends: the design approval with its two pre-flight steps, Pass A's rulings,
Pass B's close, and Pass G's voice and departures. Pass D's blind read rides on its close packet.
Passes C, D, E, F, and H close on a packet each; the monthly review adds a packet when it has
generalizations and a six-piece blind sample page each month.

## Decide blocks

One remains, unchanged in substance: whether drafter stops a run when a Survey section is
missing (recommended: the 40-minute drafter pass). The evidence did not settle it, since the
question is scope in a third repo. No new Decide block was added. The two merges, the reorder, and
the sitting's move to a packet are mechanism and sequencing calls inside the rulings, not product,
taste, priority, scope, or budget choices, so they are recorded here and in the spec's "The shape
of the work" rather than asked.

## Owed

- No lens review or verification read has run on this rewrite. Passes B, D, F, G, and H carry
  `live-account`, so `spec-plan-review` calls for the three lenses and a verification read before
  Geoff reads the design. A reviewer should check in particular that the two merges introduce no
  task order that cannot build, and that Pass E's single packet (one `~/.dotfiles` PR plus up to
  fourteen repo PRs) stays readable.
- The estimates are the restructure's first estimates, re-cut for the merges (one close dropped
  from D, one packet from E, old J's 100-minute "voice and Microsoft pack" split 60 to G and 40 to
  H's `end-user` pack, 30 minutes added to G for its full-surface match run). No recent score
  covers this work. The planner checks each figure against its plan.
- Not re-probed here: everything in the restructure's "Not probed" list (an end-to-end
  `/output-style` check of the real style, a real `Survey.zip` release, `sha256sum -c` over a
  vendored directory) and the thresholds (one standard deviation, 60% blind preference), which
  the spec now labels as judgment calls set from the September benchmark's spreads.
