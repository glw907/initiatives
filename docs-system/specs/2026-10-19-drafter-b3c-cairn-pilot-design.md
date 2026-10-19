# drafter B3c, cairn's pilot pages

Status: designed 2026-10-19, awaiting Geoff's approval. Initiative: `docs-system`. It takes the cairn
half that the B3 design (`specs/2026-10-19-drafter-b3-drafting-design.md`) split off, with Geoff's
ruling on drafter backlog #13 from chat on 2026-10-19 ("That works").

## Brief

Approving this drafts cairn's eight stage 2b pages that carry no figure through drafter's blueprint
path, and brings them to you in a cairn PR to read. It also makes a whole blueprint read able to
accept, which no read has done on a cairn blueprint. The pass is planned tonight and launches when
you merge B3, then comes back to you as one packet. cairn's release waits on these docs.

### Decide: The live budget for B3c

Each page is read, then drafted whole and reviewed. One cairn read costs about $0.22, and a whole
page cost $3 to $4.50 in the spike, but four of these pages run 500 to 1,225 lines. This month's
spend is $24, and B3 may spend up to $20.

Source: `drafter spend --since 2026-10-01`; the architecture spec's "Budget"; page sizes in cairn's
`docs/extend/`.

- $80 for the pass, with the existing $10 page cap (recommended)
- $40, which likely drafts about half the pages
- $120, which leaves room for a second whole draft of the longest pages

### Decide: Draft all eight pages, or a first three

The pilot criteria in the architecture spec turn on unread merges after three pages you accept. All
eight have finished plans. The run drafts the smallest page first as a probe and stops the line if
that page escalates for a cause the plan can't fix.

Source: the architecture spec's "The pilot"; cairn's `docs/STATUS.md:21-33`.

- All eight, smallest first, behind the probe (recommended)
- The first three, then a new packet before the rest

## Outcome

cairn's eight non-figure stage 2b pages each have an accepted blueprint, a whole draft that passed
cairn's docs gate and drafter's reviews, and a lock entry. They land in one cairn PR for Geoff's
read. The three figure pages (add a custom admin screen, architecture, replace magic links) stay
out until drafter takes figures.

## What it builds

1. **A whole read that converges** (#13, as ruled). When a whole blueprint read blocks, drafter
   records the commit it read and its findings. The next read of that blueprint runs as a change
   read since that commit, with the earlier findings passed in as the bar. It judges whether each
   was fixed and whether the fix added a defect. An accept writes `accepted` to the lock. This
   holds for `drafter read` and for the read that starts `drafter page`.
2. **Conversion.** The seven remaining non-figure plans convert to blueprints with `drafter
   convert`. The claude-code page has a plan but no framing record or page yet. Rotate's blueprint
   already exists.
3. **A deliberate whole redraft.** Conversion seeds a page's lock entry as the page stands, so
   B3's scope rule would never redraft it. A `drafter page` flag drafts a page whole on purpose,
   as the architecture's `drafter nightly --all` does for the nightly run.
4. **cairn's module drafts.** cairn keeps its own module, the docs page chain, loaded through each
   workstation's `drafter.local.toml` as cairn's `docs/STATUS.md` already sets out. The chain gains
   the `coherence` seat that B3 adds, so section redrafts work later.
5. **cairn's paths.** cairn's docs gate takes the brief at `docs/internal/briefs/`, and its
   provenance check refuses any other path. A drafter setting carries that legacy path until B5
   moves cairn to the convention, as the architecture's call 13 says.
6. **The drafts.** Rotate first as the probe, then the rest from smallest to largest. Each page runs
   the blueprint read until it accepts or escalates, then a whole draft through the review seats and
   cairn's gate. A page that escalates is reported with its finding, and the run moves on.

## Calls made in this design

- cairn stays on its chain module, not drafter's stock prompts. The chain's seats are tuned to
  cairn's register, and moving cairn onto the base is B5's job, after the register split. The cost
  is that cairn still needs a workstation-only local file until then.
- An escalated page doesn't stop the run, except at the probe. Each page is independent, and one
  failure says little about the next page.

## Check

1. A whole read of rotate's blueprint, then a fix, then a second read that runs as a change read
   with the first findings as its bar, reaching accept. Today the second read is another whole read.
2. Each of the eight pages ends accepted or escalated with a recorded finding and stop rule. Each
   accepted page passes `npm run check:docs-gate -- --page <page> --brief <brief>` in cairn.
3. Each accepted page's lock entry matches its page, its blueprint, and `accepted`.

## Shape

- Out of scope: the three figure pages; stage 2b's other close work (relinks, `LEGACY_PATH_MAP`,
  the arm index, the boundary test); moving cairn to the convention (B5); the nightly run (B4).
- Risk class `runner`: the chain is a workflow, and the pass changes drafter's read loop.
  `live-account` for API spend. `money.go` stays untouched; `resume.go` follows B3's ruling.
- Repos: `glw907/drafter` (the read rule, the redraft flag, the brief path setting, the chain's
  seat) and `glw907/cairn-cms` (blueprints, drafts, lock, on one branch).
- Depends on B3 merged. The conductor launches B3c after Geoff merges B3's packet.
- Estimate: 400 path minutes, much of it waiting on API batches.

## Standing answers

The planner and conductor apply these in place of stopping (Geoff, 2026-10-19).

- A plan within twice the estimate (800 path minutes) launches unattended once B3 merges.
- Live spend up to the budget ruled above runs without asking. The meter is `drafter spend --since
  2026-10-19 --json`, its `total` plus `open.worst`, less B3's spend.
- An escalated page is reported and the run continues. An escalated probe stops the line unless the
  plan's fix applies.
- A finding that changes this design, or spend past the budget, stops and asks Geoff.
