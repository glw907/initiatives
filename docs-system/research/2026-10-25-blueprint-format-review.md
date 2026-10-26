# Blueprint format review

Read-only evaluation of the Markdown blueprint format, 2026-10-25, for Geoff's ruling before the
docs system cleanup program (`specs/2026-10-25-docs-system-cleanup-program-design.md`). Sources: the
format doc and decoder at drafter `454587f`, the 14 blueprints on cairn `origin/main`, the four hand
rewrites on cairn-cms#144, the friction records under this folder, cairn's
`docs/internal/docs-friction-log.md`, and the Approval Queue's stored blueprint decisions. Geoff's
rulings on each change are recorded under "Rulings".

## Verdict

The format needs little change. 15 pages went to Geoff as blueprints; 10 were approved in the first
round. The 5 send-backs were about content (the "own" tic, a reader framed too narrowly, a page's
premise, open questions) or the two settled format points (the YAML file, the hard line breaks).
Geoff never edited a blueprint in place: cairn's history has no "Edit ... in review" commit on any
blueprint (the queue's save message, `approval-queue/src/lib/server/blueprint.ts:90`).

## Keep

- Fact tags with the facts store. Batch 4 checked 371 claims in round 1 and found 1 wrong, from a
  session constraint; the pilot found 0. `drafter refs` works because every line carries ids.
- `:::row` Symptom, Cause, and Fix, enforced (`internal/blueprint/check.go:250-256`); no review note
  faulted it.
- The italic job line, required and checked (median 19 words over 144 lines).
- `Code:` and `Figure:` with `:source` and an attached fence (fixed pilot friction 13; held in batch
  4 T12; 63 in use).
- `:::constraints` (fixed pilot friction 14).
- Notices and GFM tables. Leftovers are migration lag: `add-an-island.blueprint.md:89,181` still
  writes "A caution notice says...", and content-model writes a table as bullets.
- Headings are the page's headings, with one path rule; notes anchor by quote.

## Does the evidence support the tenet?

The tenet: "Agents build, maintain, and use blueprints. drafter turns blueprints into content that's
easy for humans to work with."

- Agents build blueprints: supported. Agents wrote all 14 on main, with zero in-review edits.
- Agents maintain them: partly. The skill routes code changes through blueprints (SKILL.md case 2),
  but settles fix the page and leave the blueprint stale (claude-code RESUME friction 35, drafter
  #130), and batch 5 found published pages that disagree with their blueprints (cairn BACKLOG #71,
  drafter #114). In practice the page is still the working source of truth.
- Agents read them as documentation: an aim, with no evidence yet. No skill or agent sends an agent
  to a blueprint to learn a feature (`cairn-implementer`, cairn's CLAUDE.md, and the extend skills
  never mention `blueprints/`). The readers are drafter, `fact-checker`, and the register editor.
  The agent-facing knowledge layer that exists is the facts store, which cairn's CLAUDE.md:90 tells
  passes to update; each fact is one claim with an anchored `Source:`.
- What would make it true: write settle fixes back to the blueprint (#130); fail when a page and its
  blueprint disagree (#108 and #114, extended to claims); point code-facing agents at the blueprint
  and facts for a feature's documented contract; measure it by having an agent answer feature
  questions from the blueprint and, separately, from the page.

## As agent documentation

Strong: every claim is one line tied to verified fact ids; rows give symptom, cause, and fix;
"Before you begin" states preconditions; "What it leaves to other pages" bounds scope. Weak: what
belongs to what is implicit (notes sit flat between steps, list members flat under a lead-in, as at
`act-on-newly-published-entries.blueprint.md:45-50`); which step a row recovers from was lost with
the YAML graph (hand-rewrite item 2); cut and subordinated facts have no form (item 1). The
page-shaped structure serves drafting and Geoff; the facts store already serves feature lookup, so
blueprints aren't reshaped for it.

## Proposed changes, ranked

1. Check every inline link. Today a link is checked only as a `See [..](..).` bullet matching
   `^See \[(.+?)\]\(([^()\s]+)\)(?:\.|\s.*)$` (`markdown.go:113`; checked at `plan/check.go:213`).
   The comma form drops out silently (hand-rewrite item 4), already on main at
   `build-the-public-routes.blueprint.md:58,189`; the second link in "See [a](x) and [b](y)." is
   unchecked (`act-on...:58`); 98 inline links in steps, rows, and prose get only the inbound scan
   (`inbound.go:22`); 301 of 1,612 bullets are `See` bullets, often paired with a bullet describing
   the same page. Change: every `[text](target)` outside a fence is a checked link; a `See` bullet
   stays legal but isn't required. Before: `- Write a markdown component covers declaring the
   component.` then `- See [Write a markdown component](write-a-markdown-component.md).` After:
   `- See [Write a markdown component](write-a-markdown-component.md) for declaring the component,
   its attributes, and its build() fallback.` Migration: none required; merging pairs is optional.
   Risk: up to 98 newly checked links surface once.
2. Name the reader block's labels and check them. 13 of 14 blueprints converged on Who reads it /
   Why they arrive / What they already know / Background / What the page does for them / What it
   leaves to other pages; the format shows three (`blueprint-format.md:79-85`) and says "short
   labeled paragraphs" (`:127-131`); punctuation drifts; the Claude Code reader block runs 86 lines
   with duplicated lists; pilot friction 3 and 14 record improvised labels; Geoff asked for "all the
   correct components" (#115). Change: list the labels; Background optional, the other five
   required; each item under "What it leaves to other pages" links its page. Before: `**What it
   leaves to other pages, each named in the introduction:**` then `- The islands reference covers
   the runtime's full contract.` After: `**What it leaves to other pages.**` then `- The runtime's
   full contract: [Islands](../reference/islands.md).` Migration: label punctuation in 14 files,
   mechanical; the Claude Code reader block by hand.
3. Give dispositions a form: `Cut:` and `Elsewhere:` bullets in `:::constraints`. The hand rewrites
   carry 72 ad hoc disposition bullets in 4 files with three verbs, their ids invisible to `refs` and
   the facts checks; a rejected fact can't be tagged; a subordinated link reaches the page unseen
   (#132, friction 46; friction log 467-470). Change: such a bullet's tags accept any fact status,
   `refs` reports them as a separate kind, an `Elsewhere:` link is checked, and drafter never places
   those facts. After: `- Elsewhere: [createAuthGuard](../reference/sveltekit.md#createauthguard)
   owns the config bag. :fact[gun084]` and `- Cut: engine-repository CI gate a site never runs.
   :fact[35s2dk]`. Migration: 72 bullets in 4 files, mostly regex with a hand review. Its maintenance
   benefit is shown; its documentation benefit serves the untested part of the tenet.
4. Optional, highest cost: nested lists, so a step owns its notes and a lead-in owns its members.
   A prerequisite was filed under the wrong step (batch 4 log R1); there's no idiom for a one-step
   procedure or a list of alternatives (hand-rewrite item 7); 54 lead-ins leave membership implicit.
   Change: an indented bullet or `Code:` under a step or lead-in belongs to it; flat stays valid.
   Risk: medium, since it reworks item ids, fence indentation, and `page-drift`'s step count. It
   mainly serves the untested reading aim.

## Considered and rejected

- Restoring the step-state graph: it adds required parts, and in YAML it was friction itself.
- An inline gist beside each fact id: duplicates the store and drifts.
- Explicit section ids: the published anchor is still the heading slug.
- A disclosure (`<details>`) form: one tutorial's evidence (friction log 543-546, register 813);
  revisit at the second tutorial, likely as a label like the notices.
- A home for `argument` and `orderReason`: adds a part the job lines already carry.
- A `scope` field for scaffold-fact narrowing: one page.
- A form for per-line drafter instructions: seen only in the converted Claude Code page; a skill rule
  (put them in constraints) instead.
- Hand-rewrite items 5, 6, and 8: check bugs for drafter, not format changes.

## Rulings

Geoff, 2026-10-25:

- Changes 1 to 4 all go in, nested lists included.
- The program pursues the whole tenet now: settle fixes written back to the blueprint, a failure
  when a page and its blueprint disagree, code-facing agents pointed at blueprints and facts, and a
  measured trial.
- The question to answer: is the format easy for agents to use as documentation and to maintain?
  Blueprints should be easier to work with than human-centered docs. The agent trial in the
  program design measures that.

Later the same evening, asked for an agent's honest view, the planning session reported that a
blueprint is no easier than the page for an agent learning a feature, and harder to maintain (a fix
runs through blueprint, redraft, and two reviews, and agents' settle fixes went to the page). The
blueprint's value is as a reviewable plan for Geoff. Geoff ruled to dismantle the program and move
to industry best practice (Geoff, 2026-10-25).

The facts store retires with blueprints. Docs stay true through industry practice: code samples
included from tested source, generated reference, and a fact-check against the code at review
time (Geoff, 2026-10-25).

drafter is removed entirely; no part stays as a standalone check (Geoff, 2026-10-25).
