# drafter B3, drafting from blueprints

Status: designed 2026-10-19, awaiting Geoff's approval. Initiative: `docs-system`. Scope comes from
the B1 plan's "Build sequence" item 3 (`plans/2026-10-17-drafter-b1-blueprint-format-plan.md`) and
the onboarding design's "B3 additions" (`specs/2026-10-18-drafter-onboarding-design.md`). This
design moves that scope's cairn half to a pass of its own, B3c, if Geoff approves the split below.

## Brief

Approving this makes `drafter page` draft a page from its blueprint on drafter's own prompts, with
no project prompts module, and record what it wrote in `drafted.lock`. A later blueprint change
then redrafts only the sections it touched, followed by one read of the whole page for flow. It is
the first time a page goes through the blueprint path end to end. The pass is planned and run
overnight without Geoff and comes back to him as one packet.

### Decide: Move cairn's half of B3 to its own pass

B3's scope includes converting cairn's remaining stage 2b plans and drafting the pilot pages. Those
need a whole blueprint read that accepts a cairn blueprint, and four whole reads in a row each
blocked on a new finding (drafter backlog #13, drafter#43). That is unsolved, and it needs Geoff's
ruling on #1, #8, and #13 first. The drafter half is plain build work with a synthetic fixture.

Source: the session's reading of drafter#43, drafter backlog #1, #8, and #13, and the F2 record.

- Split: B3 builds drafting in drafter tonight, and B3c (cairn conversion, the whole-read bar, the
  pilot drafts) is designed after Geoff rules on #13 (recommended)
- Keep one pass: B3 waits until #13 is ruled and designed into it

### Decide: Let the pass edit `resume.go`

Writing the lock after an accept adds a file every run touches, and the resume's tree check
(`internal/pipeline/resume.go`, `checkTree` and `wantHashes`) accounts for each file a run owns.
A page-region bound and a new coherence step may also reach it. Geoff's pass 5 ruling makes the
money path `auth-data`, and every pass since stops the line on any edit to `money.go` or
`resume.go`. An overnight stop waits until morning.

- Allow `resume.go` edits, written test-first, each commit read by `diff-reviewer` at task scope
  with its auth-data bar before the next task; `money.go` stays a stop (recommended)
- Keep the stop: a needed `resume.go` edit halts the run until Geoff answers

## Outcome

On a synthetic project with no prompts module, `drafter page docs/x.md` drafts the page from
`blueprints/docs/x.blueprint.yaml`, passes the stock gate, and writes the page's lock entry. After a
one-item blueprint edit, the next run redrafts only that section, reads the whole page once for
coherence, and updates the lock. With nothing changed, a run does nothing and says so.

## What it builds

1. **Blueprints into `drafter page`.** `drafter page` takes pages or blueprints. It builds the
   internal handoff from the blueprint: the job, type, and exemplars from the outline entry and the
   blueprint, the items in place of a claim inventory, and the facts the items cite. The plan
   seats read is `blueprint.View`'s projection, which `drafter read` already uses. The blueprint
   read runs first and is skipped when the lock's `accepted` matches the blueprint. Handoff files
   and `--workflow-run` keep working, since cairn's chain calls them, until B5 retires the chain.
2. **The lock written on accept.** An accepted page's entry gets the page and blueprint blob ids,
   the section hashes, and `accepted`, through the writer conversion and seeding already use. The
   lock keeps its format. The commit field the architecture names waits for B4, which commits.
3. **Scope from the lock.** No entry, or no page, drafts the page whole. Otherwise drafter compares
   the blueprint with the blob the lock records (`blueprint.Compare`). A structure change drafts the
   page whole, as the architecture's "Scope of a redraft" defines it. Any other change redrafts the
   changed sections, and a changed fact bullet counts for every section that cites it.
4. **Section redrafts under the edit contract.** The draft seat gets the whole page and the changed
   sections' blueprint and answers in edits. `edits.Apply` gains a region bound: it refuses an edit
   whose old text lies outside the named sections (`coverage.Regions`). The review seats are
   narrowed to those sections through the context's existing `scope` field.
5. **The coherence read.** A new `coherence` seat reads the whole page with the changed sections
   marked, after a section redraft passes review. It checks transitions, repetition, and the
   argument's flow. Its findings get one edit-contract redraft that may touch any section, then the
   gate and coverage. A second coherence `fix` escalates the page.
6. **The stock seat prompts.** The stock module gains `draft`, `structure`, `editor`, `fact`,
   `reader`, and `coherence`, written against the context this pass defines. The Google standard
   package lands as embedded `drafter:` files: the description, the tells with before-and-after
   pairs, the reviewer rubric (short paraphrased rules, each citing the guide's URL and section),
   and a corpus of attributed excerpts with each license recorded. The editor seat grades the rubric.
7. **Provenance in the stock gate.** `drafter gate --page` reads the page's brief and fails a
   sentence that cites an id the store lacks, a sentence not on the page, and a fact item no
   sentence cites. It ports cairn's `check:provenance` contract, generalized, as F1 ported
   `check:facts`.
8. **`drafter check-prompts` on the stock module.** It renders every stock seat against the
   synthetic fixture and fails on a path the fixture lacks or a cairn-only name.

## Check

The end-to-end check runs live on a synthetic fixture project committed under `e2e/testdata`: a
small CLI with an outline, a track on the Google standard, facts, and one task page's blueprint.

1. `drafter page` drafts the page whole on the stock module and the stock gate, and it is
   accepted. The lock entry matches the page, the blueprint, and the section hashes.
2. A one-item edit to one section's blueprint, committed. The next `drafter page` redrafts that
   section, the page diff outside it is empty, the coherence read runs, and the page is accepted
   with its lock entry updated.
3. A third run spends nothing and reports the page up to date.

Offline, `drafter check-prompts` passes on the stock module, and pipeline tests with the fake API
cover the region refusal, the coherence escalation, the lock write, and a resume across each new
step. Each row fails today: `drafter page` takes only a handoff, and the stock module holds only the
blueprint read.

## Shape

- Out of scope: B3c's cairn work, if split; commits, pull requests, the write-back seat, and
  clearing `origin: human` (B4); the plugin (O); the Microsoft package.
- Risk class `runner`: the stock prompts, the gate tool, and the pipeline. `live-account` for API
  spend only; no GitHub, Cloudflare, or npm account is touched. `money.go` stays untouched.
- Repos: `glw907/drafter` only. cairn-cms is read for `check:provenance`'s contract and not changed.
- Estimate: 360 path minutes. F2 planned 310 and ran in about 30; B3 adds the stock prompts and the
  redraft path to a pass of F2's shape.

## Standing answers

The planner and conductor apply these in place of stopping (Geoff, 2026-10-19).

- A plan within twice the estimate (720 path minutes) launches unattended.
- Live spend up to $20 runs without asking. The meter is `drafter spend --since 2026-10-19 --json`,
  its `total` plus `open.worst`.
- `resume.go`, as the decision above rules.
- A live check that misses after the executor's fixes, inside the budget, still opens the PR with
  the miss reported, as the format tests did.
- A finding that changes this design, or spend past $20, stops and asks Geoff.
