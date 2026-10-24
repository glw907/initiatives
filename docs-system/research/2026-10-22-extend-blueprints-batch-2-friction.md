# Extend blueprints batch 2: friction record (2026-10-22)

Initiative: docs-system

Batch 2 built three more extend blueprints under the reviewed-pages flow on `pavilion`:
content-model (a concept page), arrange-the-admin-sidebar (a task guide with a figure), and
share-a-draft-preview (a task guide). An Opus author agent wrote each one in the markdown blueprint
format from the page's plan and framing record, re-verifying its facts from the code. A fresh
`fact-checker` read it, and the session settled the findings and queued it with
`approval-queue blueprint`. Geoff rejected the preview page, and a fold author wrote a fourth
blueprint, build-the-public-routes, to hold what was left of it. This record holds the run's
numbers and every snag, each under the repo that owns the fix. "Pilot N" points at an item in
`2026-10-22-extend-blueprints-pilot-friction.md`. Branches: cairn-cms `ebp2-content-model`,
`ebp2-arrange-the-admin-sidebar`, and `ebp2-share-a-draft-preview` (which now carries the fold,
head `c38b32dda`), off `extend-blueprints-2`, which was cut from main at `a350c8367`.

## The numbers

| Page | Author (min) | Round 1 claims | Hold | Imprecise | Unsupported | Wrong | Later rounds | Geoff |
|---|---|---|---|---|---|---|---|---|
| Content model | 11.6 | 122 | 117 | 3 | 2 | 0 | R2 3/5, R3 2/2; after send-back 42/42 | sent back once for writing tics, approved |
| Arrange the admin sidebar | about 12 | 156 | 154 | 2 | 0 | 0 | R2 2/2; after send-back 60/60 | sent back once, approved |
| Share a draft preview | 11.7 | 141 | 135 | 6 | 0 | 0 | R2 11/12, R3 2/2; after send-back 76/78, 2/2 | rejected, folded into Build the public routes |
| Build the public routes | about 90 | 269 | 258 | 9 | 2 | 0 | R2 6/14, R3 8/11, R4 4/5 | queued 2026-10-24, decision pending |

Author times for the three batch pages are wall-clock; the authors estimated 55 to 75
minutes. The fold took longer because it wrote a whole page, the outline change, and a security
model line.

The fact layer held again. No round found a wrong claim in 688 round-1 claims, and the four
unsupported ones each rested on a source outside the repo: MDN for the HTML `pattern` attribute on
the content model, and a 2026-09-29 read of `@sveltejs/adapter-cloudflare` for the `Content-Type`
caveat on build-the-public-routes (`f:gwpffe`, now a question note). The imprecise findings were
the pilot's pattern: an exhaustive word or a list that said more than its source. This time the
session repeated it. Round 2 on the content model and the preview found the session's round-1
fixes still too wide ("feed" for JSON Feed only, "an error at any step" for a 404 or 503). On
build-the-public-routes, two reader-block lines about "two shared inputs" came back in rounds 2, 3,
and 4 until `c38b32dda` rewrote them structurally instead of narrowing a word again.

What the batch learned is that both of Geoff's corrections fell outside every check the flow runs.
He sent the sidebar and the content model back for the empty "own", a writing tic that three
authors, three fact-checkers, and the session all passed over. He rejected the preview page with
one question, "What is the case for this piece of documentation?", after three authoring rounds,
three fact-checks, and a register pass. A scaffolded site needs nothing from that page, and the
rest repeated reference pages. The two findings that lead this record follow from those: item 1, a
premise check before any page is authored, and item 6, a dangling-idiom scan for any scripted word
sweep.

## Geoff's rulings

He sent the sidebar back once: "You should fix the awkward AI writing ticks in this and other
blueprints." Two comments named the empty "own" ("a site's own screen", "links the site's own
screens"). He ruled it a tell to catch in all house writing. The ruling produced cairn-cms PR #137,
which removed about 4,000 empty uses from the published arms, the blueprints, and the engine
source; Survey backlog #1, a deterministic check; and cairn-cms backlog #34 for the rest. His scope
for #34 is everything except the admin's editor-facing copy, such as "Your own custom rules".

He sent the content model back for the same tics, with no answers on its two engine questions.
Those questions were the session's to settle from the code and the design history (item 4).

He rejected share-a-draft-preview and chose to fold its one needed section into Build the public
routes and the security model (2026-10-23), and to queue the whole new blueprint with notes
pointing at the preview section.

On the sidebar figure he ruled "Keep the fixture as is." His standing answer for batch 3: before
authoring any page, answer from the code what the case for it is, and when the case is weak, file a
fold recommendation instead of authoring.

## workstation: the blueprint skill's flow (`claude/.claude/skills/blueprint`)

1. The flow has no premise step. Nobody asked whether share-a-draft-preview earned a page until
   Geoff did, after the full flow had run on it. The scaffold already carries its migration, route,
   and banner, deploy applies the `AUTH_DB` migrations, and the rest duplicated reference pages.
   Add a step before step 1 of `new-page.md`: who has work to do here that the scaffold, the
   tutorial, or a reference page doesn't already cover? Treat an outline entry inherited from the
   pre-rebuild page list as no evidence of need. When the case is weak, write a fold
   recommendation instead of a blueprint.
2. The rule "adds a section, approve the blueprint first" has no path for a target page with no
   blueprint. Folding one section into build-the-public-routes became a new whole-page blueprint
   with 13 covers. Say what to do when the receiving page has none.
3. The register editor isn't in the flow. `docs-register.md`'s developer brief already lists "No
   intensifier own", and the authors were told to read it, but the tic got through 10 times on the
   sidebar and 6 on the content model. Only a fresh `cairn-register-editor` caught it, along with
   11 task sentences over 26 words in the sidebar blueprint, a blocking base-guide rule. Run the
   register editor and apply its rewrites before the fact-check and before queueing.
4. A question note on engine intent went to Geoff without the session tracing it first. The
   content model's two (the address-collision advisory against the resolver throw, and
   `inFeeds`) and the preview's two (D1's reach over design specs, and an unset `PUBLIC_ORIGIN`,
   which a code comment documents as a deliberate trade) were all answerable from specs, history,
   or code. Add to the Review section: trace an engine question through the code and the design
   history first, and send Geoff only product, taste, and scope.
5. The settle step doesn't hold the session's fix lines to the discipline the authors get. Both
   round-2 regressions in "The numbers" were the session's fixes. Say that a fix line meets the
   same exhaustive-word rule, and that a finding returning twice calls for a structural rewrite.

## survey: house writing

6. Scripted word removal leaves dangling idioms. In the PR #137 sweep, slices that removed "own"
   by script turned "no X of its own" into "no X of its" and "after its own:" into "after its:".
   A post-merge regex scan caught 14 such remnants (repairs `3960d4913`): "of" or "on", then "its"
   or "their", then punctuation or a function word. Pair Survey #1's `own` warning in `tellgrader`
   with this dangling-remnant check, and build the scan into any future word sweep's method. The
   same risk applies to backlog #34.
7. No deterministic check catches the empty "own". `tellgrader --register docs` exits 0 on both
   sent-back blueprints. Survey #1 is logged to add it to `writing-voice.md`'s tells and to
   `tellgrader` as a warn-level check, keeping a real contrast legal.

## workstation: the blueprint skill's format (`claude/.claude/skills/blueprint`)

8. `format.md` has no table form, though the register wants tables introduced by a sentence. Two
   authors hit it.
9. `introductions.md` still describes a `**Background.**` paragraph, while `new-page.md` says to
   use `:::constraints`. Pick one and fix the other.
10. The skill never says how an exemplar name resolves. The author found it in
    `~/.config/drafter/cairn-cms.local.toml` under `inline_files`.
11. The code-example form is unclear in two places. `format.md` shows `Code:` followed by a fence
    but also says "bare fence", and an author read the prompt's "bare code fences" as no fence.
    It allows one fence per `Code:` bullet, so a command and its output need two bullets. Add one
    sentence and one example of each case.
12. The skill doesn't say when `Code:` may omit `:source`. The text reads as mandatory, but `drafter
    check` passes a bullet with neither a fence nor a source. For an invented example, citing a
    model file may read as a claim that the file holds the example. Three authors raised it.
13. `:::row` outside symptom pages: `drafter check` accepts it, and the skill is silent on whether
    it is sanctioned.
14. Explanation bullets before the one lead-in bullet that precedes numbered steps: `drafter check`
    accepts them, and the skill doesn't say whether they are allowed. Pilot 17 is the sibling.
15. `new-page.md` never names the project's mint command. The preview author hand-picked
    `f:sp1mbt` to `f:spamto` instead of running `check-facts.mjs --mint`, which the facts README
    requires. The ids are opaque, so it's harmless, but they aren't random.
16. The skill and the author prompt say "Edit tool only", and two authors asked whether an in-place
    `sed` substitution for pointer swaps is allowed. Say so either way.
17. A page's facts can sit under three headings plus `front-door.md` and `editors.md`. Tell the
    author to find facts by grepping each id the plan cites, not by heading.

## workstation: the `fact-checker` agent

18. The agent hands back through `SubagentHandback`, not a text reply, so saving its array
    verbatim needs a transcript parser (the session's `tools/save_findings.py`). Pilot 23 is the
    sibling. Give the save a sanctioned path, or have the agent write its array to a named file.

## drafter: pointers and the store check

19. An anchorless `path:N` or `path:A-B` pointer never detects drift. `f:ys1iq1` cited
    `types.ts:418` for a symbol at 430, `f:hdrzxd` and `f:69j91g` passed a `--fact` check with 0
    errors, and the preview blueprint had 11 stale ranges of which the check warned on 1. An anchor
    inside parentheses still isn't read as an anchor (pilot 6). Require an anchor or a content hash
    on every line pointer. Three authors hit it.
20. The ±10-line excerpt window still hides drift: `f:hdrzxd`'s write moved from 181 to 189 and
    passed. Pilot 5 stays open.
21. The `#name` store check reads the anchor against the declaration without its doc comment, while
    `format.md` says the excerpt includes the leading doc comment. An anchor taken from a doc
    comment fails with "not found in the declaration".
22. The store check skips dotted `#a.b` pointers, so `f:8zdux6` is effectively unverified.
23. `:source[...]` can't hold a path with brackets, such as `preview/[token]` or `[...path]`. The
    parse stops at the first `]`, and escaping doesn't help. Two authors dropped `:source` from
    their `Code:` bullets.
24. `drafter excerpt` resolves bracket and parenthesis route paths, but the store check skips them,
    so those pointers are never verified.
25. A figure's `:source` gets no existence check, and `format.md` doesn't say what it should name.

## drafter: check lints and links

26. The exhaustive-word lint is mostly false positives: 33 warnings on the sidebar, 34 on the
    content model (about 9 real), 39 on the preview, and 34 on the fold, nearly all false. The
    common cases are "no" before a code span or as a determiner ("no sign-in"), counts ("two
    dates", "seven days"), "never" in `:::constraints`, and a bold UI label (`**Revoke all
    links**`). Exempt the constraints block and those forms, and add a per-line settled marker so
    a settled line stops repeating. This feeds drafter #48.
27. An exhaustive warning inside `:::row` points at the `:::row` opening line, not the word's line.
28. The lint reports one match per line, which forces a fix, rerun, fix loop.
29. A check by name still prints `outline.yaml` `types` warnings (the tutorial milestone, the
    symptom row) that belong to no named blueprint. Two authors hit it.
30. `drafter check` has no sentence-length or hinge check on blueprint lines. The register editor
    found 11 task sentences over 26 words in the sidebar blueprint, and the fold author wrote a
    throwaway script for it.
31. The links warning flags an outline `crossLink` to a `managed: false` page
    (`choose-an-ai-posture`) as "names no page".
32. The links check resolves a cross-page anchor against the published page, not the target's
    blueprint. Repointing to a section a blueprint adds
    (`build-the-public-routes#mount-the-draft-preview-route`) errors until the page is redrafted.
33. Retiring a page leaves inbound blueprint links (the add-cairn tutorial at line 2168 and
    replace-magic-links' See also at line 303), and no tool lists them on an outline removal.
    `drafter refs` is fact-based.

## drafter: refs and the D1 audit

34. `drafter refs` reports "no blueprint places or cites" `f:ld6xam` though the page's existing
    brief cites it. It reads briefs only for pages that have a blueprint, so pilot 10 and pilot 30
    are half fixed.
35. No tool lists which ids a plan cites that are charter- or doc-sourced, so the D1 audit (drop
    charter-sourced claims) runs by hand on every page. Two authors did it.

## approval-queue

36. `approval-queue blueprint` still prints nothing on a successful queue (pilot 22). The session
    confirmed each queue with `pgrep`.
37. A send-back note auto-prefixes "Still open: <title>" even for a question Geoff answered. The
    sidebar's figure note carried his call, "Keep the fixture as is", and still came back as open.
38. There is no `approval-queue withdraw`. Withdrawing a queued item means killing the blueprint
    process and relying on its exit trap.
39. The README's anchor slug rule turns an apostrophe into a hyphen
    (`set-a-section-s-starting-state`), which is easy to get wrong by hand, and no tool prints a
    blueprint's anchors. The session wrote `tools/anchors.py`. Reader-block lines still have no
    anchor (pilot 20).

## cairn-cms

40. An unnamed `drafter check` on main has 15 errors, all from the three pilot blueprints, so a
    whole-tree check is red before any new work and authors must check by name. PR #134's
    troubleshooting blueprint adds another (`track: "admin"`, an error since drafter #58). Backlog
    #30 should name both.
41. No prose linter runs on a blueprint. `check:vale` covers `docs`, `README.md`, and the showcase
    README only (`package.json:52`), so the empty "own" reached Geoff unflagged. Add
    `blueprints/**` to Vale's scope once Survey #1's check exists.
42. Facts headings still use retired page names: the sidebar page's facts sit under
    `## organize-your-admin-nav.md` and also under an `### arrange-the-admin-sidebar` subsection,
    and the Access page's under `sign-in-through-your-organization.md`. A new author has to know the
    old name. Backlog #28; pilot 24.
43. Plans and framing records inherit wrong facts, and nothing flags a plan when a fact it cites is
    corrected. `f:ld6xam` ("validates at runtime composition") reached the sidebar plan, the content
    model's carried about a dozen code-contradicted claims, and the preview plan's constraints were
    gaps rather than truths. Build-the-public-routes' plan (2026-10-12) predates D1, so only its
    section order was usable. All four authors hit it.
44. Stale or prose-sourced facts are still marked `[verified]`: `f:0elmiu` says the sign-in page is
    indexed, but `LoginPage` sets `noindex`; `f:niuzzg`; `f:s4prb0` (sourced from a README); and
    `f:q07rd5` (sourced from a docs page). The fold corrected `f:0elmiu`, `f:niuzzg`, and
    `f:yef4lo`.
45. Bundled facts block reuse under D1: `f:q07rd5` joins a code clause with docs-only clauses, so a
    page can't cite the code part alone. Split such bullets.
46. `check:facts` refuses a `path#Symbol` source outside `src/`, while `drafter check --fact`
    accepts it (`packages/create-cairn-site/...#applyMigrations`).
47. Three branches adding facts to the same files invite merge conflicts. Batch 2's two merges into
    `extend-blueprints-2` had to settle them; batch 3 should expect the same.
48. No code source exists for the tutorial site's layout, and D1 removes tutorial-site claims from
    every page that serves tutorial readers. Add a fixture or record a ruling.
49. `docs/reference/sveltekit.md` has no `ContentRoutesConfig` heading, so the plan's link target
    can't exist. The sidebar blueprint links `createCairnAdmin` instead.
50. `src/lib/content/manifest.ts:3-4` has a stale header comment ("save path patches one entry").
    It is already in the docs friction log, unfixed.
51. The scaffold names its origin twice: a literal `https://showcase.test` and the setup-written
    `PUBLIC_ORIGIN` `workers.dev` URL, so a deployed site has two.
52. Deploy applies the `AUTH_DB` migrations with `--remote` only; a local D1 still needs
    `--local` (`f:m4y3m4`).
53. PR #137 dropped "own" from three extend headings, which changed their anchors
    (`upload-from-your-screen`, `mint-and-revoke-from-your-admin-route`,
    `port-your-theme-onto-the-chassis`). In-repo links are fixed; inbound links from cairn.pub are
    unchecked.
54. About 240 "own" hits remain in `templates/waymark/.claude/**`, `README.md`, and `CLAUDE.md`,
    which `emit:template` bakes from repo-root `claude/`, `skills/`, and
    `packages/create-cairn-site/template-repo`. Sweep the sources, then emit. Backlog #34.
55. Engine questions the authors raised, now tracked: the address-collision advisory against the
    resolver throw (#31), `RoutingRule.inFeeds`, never read (#32), and the `branch_gone` row at
    `docs/reference/log-events.md:40` (#33). One has no backlog item yet: renaming the scaffold's
    posts concept empties its feed.

## initiatives: the batch author prompt (`author-template.txt`)

56. "Bare code fences" was read as "no fences". Say "a fence with no `Code:` bullet" or show it.
57. "Raise the fixture rather than decide" conflicted with writing a concrete snippet. Say which
    wins.
58. The prompt's retired-name warning was wrong for the preview page. Generate it per page.
59. The fold prompt's credential line named too few facts; it needed `f:a7yrhq` and `f:l4waby`.

## drafter: worktree config

60. A fresh worktree has no `drafter.local.toml`, so `drafter page` exits 2 with "prompts is not
    set, and require_prompts in drafter.toml refuses the stock module". The template sits at
    `~/.config/drafter/cairn-cms.local.toml`, but drafter reads only the file beside
    `drafter.toml` (`internal/config/load.go:85`). Older worktrees carry copies that point at a
    deleted drafter worktree's prompts module. Load `~/.config/drafter/<repo>.local.toml` as the
    fallback layer, or name the template in the error.

## workstation: the sweep method (cairn-cms PR #138)

61. A slice agent's edit script emptied `scripts/checks/gate-tier.mjs` (929 lines) and committed
    it. No slice check caught it, and the fast lane printed nothing and exited 0, because the
    fast lane is that file. A word sweep keeps every line's count, so a whole-branch
    `git diff --numstat` that lists files whose added and deleted counts differ finds this class
    in one command. Add it to the sweep method before any gate runs, and have `gate-tier.mjs`
    refuse to exit 0 when it prints no legs.

## Dropped

- The sweep's scope measurement (about 900 hits in the published arms and blueprints, 700 of them
  in the reference arm): a sizing note, not a defect. PR #137 records the result.
- An unset `PUBLIC_ORIGIN` storing a row and then answering 500: a code comment documents it as a
  deliberate trade, so there is nothing to fix.
- Whether D1 covers design specs (`f:6rao75`): moot after the preview page was folded, and D1
  applies as written.
- The sidebar's open items for Geoff (the figure fixture, including the `navFilter` throw in a row,
  and the `ContentRoutesConfig` anchor) and the content model's routing table as bullets: each was
  settled in its notes, and items 49 and 55 carry what remains.

## Batch 3 (overnight 2026-10-24), appended as it runs

B3-1. (drafter) configure-rendering's author hit the bracketed `:source[...]` path bug again (record 23):
      a SvelteKit route path can't be a source.
B3-2. (drafter) `exhaustive` warnings are noisy: 27 on configure-rendering, nearly all absence
      wording ("no `registry`") or `:::constraints` lines, which instruct the drafter rather than
      claim. Exempt constraints lines, and tell absence phrasing from an exhaustive claim.
B3-3. (drafter) A named `drafter check` still prints the outline's unrelated `types` warnings.
B3-4. (drafter) A YAML error in `outline.yaml` reports only "malformed", with no line or column.
B3-5. (blueprint skill) `introductions.md` links drafter's GitHub `blueprint-format.md`, not the
      local `format.md`; `format.md` doesn't say whether a `:fact` tag on a `Code:` bullet counts.
B3-6. (blueprint skill) No recipe for a generated example (a render's HTML output): the author ran
      `createRenderer` by hand, and a fact-checker has no `:source` to re-verify it from.
B3-7. (cairn-cms) An `external` fact with no URL (`f:34wt4f`) passes `check:facts` silently.
B3-8. (cairn-cms) After a page is narrowed, its 782-line plan and 254-line framing record are mostly
      out of scope; reading them cost more than they returned.
B3-9. (prompt) Narrowing a page's `covers` leaves neighbors' `outOfScope` lines routing to it
      (outline.yaml 105, 127, 393); the brief should say whether to reword them.
B3-10. (session) The premise check folded 1 of 3 candidates (link-content-with-references, backlog
       #46) and trimmed the other 2. It cost one agent read and saved an authored page.
B3-11. (cairn-cms CI) The baseline-regen run pushes as `github-actions[bot]`, and every workflow on
       that head then sits in `action_required`; `ci-green` reports it as red. Approving each run
       with `gh api -X POST repos/glw907/cairn-cms/actions/runs/<id>/approve` releases them. Have
       `ci-green` name `action_required` as held, not red, and print the approve command.
B3-12. (drafter) define-an-adapter's author found six facts whose `path:N-M` pointers had drifted off
       their lines and still passed `drafter check --fact` (f:aj5c4z, f:sz71ur, f:7ak73t, f:9ro4u5,
       f:n07oiu, f:hkh101). Pilot item 5 still open; an anchorless line range should warn.
B3-13. (drafter, cairn-cms) The two fact parsers disagree: a code span inside a `[verified: ...]` note
       passed `drafter check --fact` but failed `check:facts` as an unresolved path. The grammar
       should say whether a tag note's code spans count as pointers.
B3-14. (drafter) A pointer into `node_modules` gives "no excerpt: untracked", so a vendor's thrown
       string can't be shown to a reader of the fact.
B3-15. (blueprint skill) `anatomies.md` links `../docs/blueprint-format.md`, which doesn't exist from
       the skill directory. `format.md` has no table form, and a flat list can't tell a step's
       explanation bullet from a sub-item.
B3-16. (cairn-cms) Duplicate facts state one claim (f:pdgkex, f:4mz4tp, f:yef4lo; f:fe46lo and
       f:97c6g1), and f:q07rd5 is `[verified]` from a docs page against ruling D1. The plan inputs
       carried the wrong vocabulary storage path (`editor.nav.configPath`) into the outline.
B3-17. (drafter) `drafter page` sends its seats through the Message Batches API. The sidebar's draft
       batch, reserved 08:04Z, was still pending an hour later, and the run's state file and log
       showed nothing in the meantime, so the session read a healthy wait as a stall. Print a
       "waiting on batch <id> since <time>" line, and offer a non-batch mode for an attended run.
B3-18. (cairn-cms) `defineConcept` names a concept in its errors by `label ?? dir`
       (`src/lib/content/concepts.ts:67`), while the later checks in `normalizeConcepts` name it
       by its content-map key. A developer who sets `label: 'Events'` on key `events` sees two
       names for one concept in the diagnosis rows. Name it by key everywhere, or say both.
B3-19. (drafter) A `See [text](target)` bullet with trailing text, or with a `#anchor` link and
       trailing text, is not counted as a link item, so the cross-link check warns. format.md
       never says trailing text disqualifies the bullet. (configure-media author)
B3-20. (drafter) `exhaustive` fired 37 times on configure-media, mostly on `:::constraints` lines
       (instructions, not claims) and on "no" as a determiner ("no manifest row"). Exempt the
       constraints block; settling 37 warnings by hand is real cost.
B3-21. (drafter) A named `drafter check` still prints outline-wide warnings (anatomy names, a
       crossLink to `docs/reference/sveltekit.md` "names no page the outline lists").
B3-22. (drafter) The ±10-line pointer window still passes drifted pointers (`f:c8c9ji`, 78-84
       against 80-88), and `#Outer.inner` pointers are skipped by verification. Pilot item 5,
       unchanged.
B3-23. (blueprint skill) introductions.md calls the reader block's Background paragraph a
       planning note; new-page.md says page-wide instructions go in `:::constraints`. One
       sentence should say how they differ. No guidance exists for a table in a markdown
       blueprint.
B3-24. (cairn-cms) Page plans and framing records written for an untrimmed page (configure-media,
       2026-10-12) cost reading time after a premise trim. Mark a plan superseded when its page
       is trimmed.
B3-25. (cairn-cms, engine) The edit page's live preview hard-codes `/media` and the slug URL form
       (`EditPage.svelte:1359`, `resolve-media.ts:141`), so a site with a moved `publicBase`
       gets 404 preview images. And `mediaUpload` commits no manifest row while the committing
       `mediaLibraryUpload` is off the typed contract, so a custom screen's upload resolves as
       missing until an entry save records it.
B3-26. (cairn-cms) `docs/reference/log-events.md` said `media.uploaded` writes the manifest row;
       fixed on `ebp3-configure-media` (`946f14dcb`).
B3-27. (drafter) `drafter refs <fact>` lists a page's brief citations only once the page has a
       blueprint; before that it says "no blueprint places or cites it", so a fact correction
       looks free while the published page's brief cites it 5+ times. It also labels ordinary
       bullets `(example)`, a kind format.md never names. (migrate-existing-content author)
B3-28. (drafter, cairn-cms) A `path:lines` pointer with no anchor span is never drift-checked:
       f:ivhuyc, f:gh4ckg, f:2p519o, f:qd7iat had drifted 1 to 30 lines and passed. Require an
       anchor on line pointers. Dependency-behavior facts (gray-matter, js-yaml) have no
       excerptable source and rest on dated runs; a `run` or vendor tag would let a checker
       know why.
B3-29. (blueprint skill) format.md's "What `drafter check` checks" table is mostly YAML-era rows
       (`why`, `use`, `framing`, `recovery`, `reader-state`); say which apply to markdown. The
       fact-edit rule should allow an exact in-place substitution, never an append.
B3-30. (cairn-cms) `f:q07rd5` bundles a code-sourced scaffold path with tutorial paths sourced
       only from a docs page and an unrelated hooks note, so D1 blocks citing it for the
       scaffold alone. Split it. Page plans state as constraints things the code now settles
       (the build error's count prefix, `parseMarkdown` and TOML); see B3-24.
