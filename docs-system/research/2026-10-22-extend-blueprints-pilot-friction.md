# Extend blueprints pilot: friction record (2026-10-22)

Initiative: docs-system

Three of the eighteen extend pages with no blueprint were built under the reviewed-pages flow on
`pavilion`: architecture, add-a-custom-admin-screen, and replace-magic-links-with-cloudflare-access.
Each started from `drafter convert plan` and `drafter convert markdown` on its v1 plan. An Opus
author agent then rewrote it and re-verified its facts from the code. A fresh `fact-checker` read
it, and the session settled the findings and queued it with `approval-queue blueprint`. This record
holds the run's numbers and every snag, each under the repo that owns the fix. Branches:
cairn-cms `ebp-architecture`, `ebp-add-a-custom-admin-screen`, and
`ebp-replace-magic-links-with-cloudflare-access`, off `extend-blueprints-pilot`.

## The numbers

| Page | Author (s) | Round 1 claims | Hold | Imprecise | Wrong | Later rounds | Geoff |
|---|---|---|---|---|---|---|---|
| Cloudflare Access | 762 | 145 | 139 | 6 | 0 | R2 9/9 hold | approved, re-approved after one clause |
| Architecture | 909 | 133 | 124 | 9 | 0 | R2 13/15, R3 7/10, R4 10/10 | approved, one decide |
| Custom admin screen | 1246 | 179 | 172 | 7 | 0 | R2 15/17, R3 3/3; after send-back 8/11, 8/9, 5/5 | sent back once, approved |

No round found a wrong claim. Every imprecise one was a line or a fact saying more than its source.
Two causes covered most of them. In the Access page, all six were a line paraphrasing a correct fact
loosely, dropping an item from a list or turning three named cookies into "every cairn cookie." In
architecture, five of the nine traced to the fact bullet itself, so the author's re-verification had
passed facts that over-claimed. The returning cause in rounds 2 to 4 was an exhaustive word ("only",
"every", "no", a count): each fix's narrower list was still short until the line gave examples
instead of a complete list.

Geoff's one ruling (architecture D1): drop charter-sourced claims on every page. The two authors had
split on it, one dropping the charter's boundary sentence and one citing it.

Geoff sent the custom admin screen back once: "This isn't just about keeping data outside of
markdown. It's any administrative functionality, and it might or might not include keeping data
out of markdown." He followed up asking for a few examples of what a screen is for. The v1 plan
and its worked example (the showcase's signups screen over D1) had narrowed the reader, and the
author carried that narrowing into the blueprint even though the outline's job was already general.
Fixing the framing exposed a structural gap that no fact-check had flagged: a screen with no data
of its own can't use `createSectionAction`, which the steps build on. For the remaining fifteen
pages, the reader block should be framed from the outline's job, never from the worked example.

## drafter: the converters

1. `convert plan` matches framing-record headings exactly, parentheticals included. Two of three
   records ("Readers, where they come from, what they want"; "Readers and their reasons", and both
   with a parenthetical on "Background the page rests on") made it exit 1 and write nothing. The
   error names the heading but not the accepted set. The workaround was a scratch copy with the
   headings renamed. `internal/blueprint/convert.go:162`
2. `convert plan` seeds `drafted.lock` with the uncommitted YAML's blob, which is not in the object
   store. `convert markdown` then calls the page stale and says to run `drafter page`, but
   committing the YAML is the fix. Write the blob when seeding (`git hash-object -w`), or name the
   uncommitted file in the message.
3. `convert markdown` writes a skeleton, not a reviewable blueprint: 44 check errors over three
   pages, all of them missing job lines. Three of three pages needed a full rewrite, which took the
   author agents 13 to 21 minutes each. The artifacts:
   - The reader block runs four framing sections together, with list bullets glued after the bold
     label ("**Who reads it.** - **Evaluator.**").
   - Each fact item becomes the fact's text followed by its `use` text, so a claim appears two or
     three times.
   - Introduction items land in "Before you begin".
   - A row's Fix is the handler step's text copied verbatim, and a failure with no cause gets an
     empty Cause.
   - Steps are renumbered `1.` after every interleaved bullet, and `f:` ids stay untagged in prose.
   - Code and figure items lose their source, hand-offs come out unmarked, and `track` is `""`.

## drafter: check, excerpt, and refs

4. `track` is never validated when the outline declares no tracks, so an empty or wrong value
   passes. Two authors hit it.
5. The excerpt window of ±10 lines let six drifted pointers pass the store check: `f:3rb362`,
   `f:n1om0r`, `f:hk24xs`, `f:qz4gj2`, `f:esp93u`, and `f:hroqbu` cited lines that no longer held
   their symbols. Two authors hit it.
6. A pointer inside parentheses is read as commentary (`f:gknz29`), and the only message is "no
   block shows source lines." Say how many spans were skipped as commentary.
7. The no-excerpt warning says "point it at the code," which doesn't fit an owner's statement
   sourced from a charter doc. Geoff's D1 ruling now settles the cairn case; the message could name
   the drop rule, or `facts.prose_sources` once it ships.
8. `drafter excerpt` on a vendor fact exits 1 and prints only the bullet. Re-verifying the Access
   page meant fetching about ten vendor pages by hand. Print the URLs and their read dates as a
   checklist.
9. Excerpts can be very long (`f:0gihxq` printed 2,110 lines), and reading the code directly was
   faster.
10. `drafter refs` lists blueprint lines only, not briefs or drafted pages, so it can't show what a
    fact correction will redraft. No tool shows that cost before the edit. It also takes one id per
    call.
11. No subcommand checks one fact's pointers. The store check runs only on an unnamed run, so its
    output mixes in other blueprints' findings.
12. There is no `drafter --version` and no outline query (`drafter outline <slug>` would do;
    `python3 -I` has no yaml module).

## drafter: the blueprint skill (`claude/.claude/skills/blueprint`)

13. The markdown format has no form for a code example. `format.md` says only "Code fences are
    skipped," and `CodeSources` returns nil for markdown, so a code item's source no longer reaches
    the draft seat. All three authors hit it and wrote a fact-tagged bullet naming the source, then
    a fence. Snippet-check skip comments have no home either.
14. It also has no form for a figure or for page-level constraints. The YAML `constraints`,
    `orderReason`, `argument`, and dispositions are dropped. The authors improvised two forms, a
    `**Background.**` paragraph and a `**The figure.**` paragraph in the reader block.
15. `format.md` still calls a blueprint "one YAML file," its Layout shows only `.blueprint.yaml`,
    and the check's exit-2 list says "A file you name isn't a `.blueprint.yaml` file."
16. `format.md`'s own job-line example uses the trailing hinge the register bans ("*Gets the reader
    ready, so no step fails for a missing role.*"), and the anatomies give no rule on job-line
    mood. Two authors hit it.
17. "Check what you add" puts a task section's steps before any explanation, while the register
    wants a lead-in that ties the section to the task. The skill doesn't say whether one lead-in
    line is allowed.
18. The skill has no rule for parallel authors sharing one facts store. `f:9xthnq` was flagged
    wrong by one author and left alone, and the other author corrected it.

## approval-queue

19. Note anchors are positional (`<slug>.p<n>`). Settling a finding by splitting one bullet
    renumbers every later item in its section, so the anchors had to be computed after the last
    fix. A reviewer's edit that splits a bullet would orphan the notes below it. An anchor keyed on
    the line's text or its fact ids would survive.
20. The anchor grammar doesn't say how to address a line inside the `:::reader` block. The session
    anchored those notes at the title heading.
21. A decide note's ruling on one blueprint reached a blueprint Geoff had already approved. A
    one-clause deletion made the approved blob stale, so the item went back through a full review.
    A cross-item ruling, or an amend kind that shows only the delta, would save the round trip.
22. `approval-queue blueprint` prints nothing on a successful queue, so the author learns it is
    queued only from `pgrep`.

## workstation: the `fact-checker` agent

23. One of eight fact-checker runs added prose notes after its JSON array, though its definition
    and the dispatch asked for the array alone. The notes were useful, but the session's verbatim
    save of the array failed until the parser took only the leading array. Either give the agent a
    sanctioned notes field or hold it to the array.

## cairn-cms

24. `docs/internal/facts/extend.md` still files the Access page's facts under its old name,
    `## docs/extend/sign-in-through-your-organization.md`.
25. `f:9xthnq` (front door) said the auth endpoints are public. The code gates `/admin/auth/*` except
    `/admin/auth/confirm`. Corrected on `ebp-add-a-custom-admin-screen`.
26. `check:facts` can't run in a fresh worktree without `npm ci`, so the authors had only drafter's
    store check.
27. Plan sources disagree: `architecture.plan.md` is called the prose twin, but `plan.yaml` is newer
    and their concurrency rules contradict each other. The remaining fifteen pages have a framing
    record and a `.plan.md` but no v1 `.plan.yaml`, so `convert plan` can't start them; their
    blueprints start from the prose plan by hand.
28. Facts contradicted their own sources: `f:pmmtdv` against the code comment beside it, and
    `f:39sn8c` calling an observed band "ratified."
