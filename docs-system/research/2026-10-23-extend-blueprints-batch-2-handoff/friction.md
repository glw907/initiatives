# Batch 2 friction (session log)

Pages: content-model (concept), arrange-the-admin-sidebar (task guide, figure), share-a-draft-preview (task guide).
Integration branch extend-blueprints-2 off main a350c8367; worktrees .claude/worktrees/ebp2-<slug>.

## Session-observed

- S1 (cairn-cms): an unnamed `drafter check` on main has 15 errors, all from the three pilot blueprints (backlog #30), so a whole-tree check is red before any new work. Authors must check by name.
- S2 (cairn-cms): facts store headings still use retired page names for the sidebar page (`organize-your-admin-nav.md`) beside the Access one (#28). A new author has to know the old name to find the page's facts.

## Sidebar author (8e34b40ba, ~10-15 min, 0 errors / 35 warnings, 33 exhaustive)

A1 drafter: drifted line pointer passed store check (f:ys1iq1 types.ts:418 vs 430); anchor inside parens not read as anchor, bare range unchecked. Pilot 5/6 not fully fixed.
A2 drafter: refs says "no blueprint places or cites" f:ld6xam though the page's existing brief cites it; refs reads briefs only for pages that have a blueprint. Pilot 10/30 half-fixed.
A3 drafter: exhaustive lint 33 warnings, mostly "no" in conditions and constraints-block lines. Exempt constraints, "no" before code span / as determiner. (feeds drafter #48)
A4 drafter: Figure: :source gets no existence check; format.md silent.
A5 skill: no table form in format.md though register wants sentence-introduced tables.
A6 skill: introductions.md still describes **Background.** paragraph; new-page.md says use :::constraints. Contradiction.
A7 skill: exemplar name resolution path written nowhere in skill (found in ~/.config/drafter/cairn-cms.local.toml inline_files).
A8 skill: format.md example of Code: + fence vs "bare fence" wording; one sentence would settle.
A9 cairn-cms: page facts in two homes (## organize-your-admin-nav.md + ### arrange-the-admin-sidebar subsection). Pilot 24 class.
A10 cairn-cms: no code source for tutorial site's layout; D1 removes tutorial-site claims from every page serving tutorial readers. Need fixture or ruling.
A11 cairn-cms: plans/framing inherit wrong facts (f:ld6xam "validates at runtime composition"); nothing flags plan when fact corrected.
A12 cairn-cms: docs/reference/sveltekit.md lacks ContentRoutesConfig heading; plan link target can't exist.
A13 prompt (mine): "bare code fences" read as "no fences".
A14 prompt (mine): "raise the fixture rather than decide" conflicts with writing a concrete snippet.
Shared-fact corrections: f:ld6xam, f:bc27j9, f:tycp7k (+10 pointer-only).
Open for Geoff: figure fixture (media relabel), navFilter-throw line inclusion, ContentRoutesConfig anchor.

## Content-model author (c067dfb48, ~75 min self-report / 11.6 min wall, 0 err / 25 warn after rewording 10 of 34)

B1 drafter: anchorless path:N pointers never detect drift (f:hdrzxd EditPage:1030, f:69j91g) -> --fact 0 errors. Same as A1.
B2 drafter: ±10 window hid f:hdrzxd write drift (181->189). Pilot 5 open.
B3 drafter: #name store check reads anchor against declaration WITHOUT doc comment; format.md says excerpt includes leading doc comment. Mismatch; anchors from doc comments fail "not found in the declaration".
B4 drafter: exhaustive lint false positives ("two dates", "the whole value", "none", constraints "never"); ~9/34 real; no per-line settled marker so every run repeats.
B5 drafter: named check still prints outline.yaml `types` warnings (tutorial milestone, symptom row).
B6 skill: no table form (=A5).
B7 skill: Code: :source for an invented example: cite a model file? Unclear; may read as claim file holds the example.
B8 cairn-cms: plans/framing carry ~dozen code-contradicted claims (=A11).
B9 cairn-cms: manifest.ts:3-4 header comment stale ("save path patches one entry") - already in docs friction log, unfixed.
B10 cairn-cms: bundled facts (f:q07rd5 code + docs-only clauses) block reuse under D1.
B11 cairn-cms/drafter: dotted #a.b pointers skipped by store check; f:8zdux6 effectively unverified.
B12 prompt: content-model facts under 3 headings + front-door.md + editors.md; prompt should say grep by id from plan.
B13 skill/prompt: sed -i substitution vs "Edit tool only" - is in-place substitution allowed?
B14 drafter: no tool lists which plan-cited ids are charter/doc-sourced (D1 audit by hand).
Open for Geoff: address-collision advisory vs resolver throw (engine), inFeeds vestigial?, renaming scaffolded posts empties feed, routing table as bullets.

## Share-a-draft-preview author (6cca70ae6, ~55 min self / 11.7 wall, 0 err / 41 warn)

C1 drafter: :source[...] can't hold a path with [ ] (preview/[token]); parse stops at first ]; escaping doesn't help. Dropped :source from 2 Code: bullets.
C2 drafter: excerpt resolves bracket/paren route paths but store check skips them -> never verified.
C3 drafter: unanchored path:A-B pass whatever lines hold; 11 stale, 1 warned (=A1,B1). Suggest require anchor or content hash.
C4 drafter: exhaustive 39 warnings mostly FP: "no sign-in", "seven days", bold UI label **Revoke all links**, constraints lines.
C5 drafter: exhaustive warning in :::row points at :::row opening line, not the word's line.
C6 drafter: one exhaustive match reported per line; fix-rerun-fix loop.
C7 drafter: named check prints outline types warnings (=B5).
C8 skill: one fence per Code: bullet; command+output needs two; show the case.
C9 skill: :::row outside symptom pages: allowed? check accepts.
C10 skill: "one lead-in bullet before numbered steps" vs explanation bullets before lead-in; check accepts; sanctioned?
C11 skill: may Code: omit :source? text reads mandatory.
C12 cairn-cms: plan constraints were gaps not truths (=A11,B8).
C13 cairn-cms: sign-in-through-your-organization heading (#28).
C14 cairn-cms: three branches adding facts to same files -> merge conflicts likely.
C15 prompt: retired-name warning wrong for this page.
S3 (session): preview author hand-picked ids (f:sp1mbt..f:spamto) instead of `check-facts.mjs --mint` (facts README rule); blueprint skill new-page.md never names the project's mint command. Ids are opaque so harmless, but not opaque-random.
Open for Geoff: D1 covers design specs? (f:6rao75); log-events.md:40 branch_gone row likely wrong; curl -D constraint unsourced; PUBLIC_ORIGIN unset -> row stored then 500 (engine).

## Session, fact-check rounds

S4 workstation agent: fact-checker hands back through the SubagentHandback tool, not a text reply, so "save the array verbatim" needs a transcript parser (save_findings.py). Pilot 23 sibling.
S5 process: round 2 on content-model and preview each found my own round-1 fix still a little wide (feed -> JSON Feed only; "an error at any step" -> 404/503). Same exhaustive-word pattern as the pilot: the session's fix lines need the same discipline the authors get.
S6 approval-queue: `blueprint` printed nothing on queue (pilot 22 still open); confirmed queued only via pgrep.
S7 approval-queue/skill: README anchor slug rule turns an apostrophe into a hyphen ("set-a-section-s-starting-state"); easy to get wrong by hand; no tool prints a blueprint's anchors. Reader-block lines still have no anchor (pilot 20).
Round numbers: sidebar R1 156 claims 154 hold 2 imprecise, R2 2/2. content-model R1 122: 117/3 imprecise/2 unsupported (external MDN), R2 3/5, R3 2/2. preview R1 141: 135/6, R2 11/12, R3 2/2.

## Geoff's review (2026-10-22 ~20:11)

G1 Geoff sent back sidebar: empty "own" ("a site's own screen", "links the site's own screens") as an AI tic; "fix the awkward AI writing ticks in this and other blueprints". Three authors, three fact-checkers, and the session all missed it. No prose net runs on blueprints (check: does vale/tellgrader see blueprints/**?). Geoff: "an issue we need to catch going forward for any house writing" -> survey #1 logged (a0872ed). Correction logged in survey-notes.
G2 Geoff sent back content-model with zero answers on its two engine questions: they were mine to settle (code + design history), not his. Process: a question note on engine intent should first be traced through specs/history by the session; only product/taste goes to Geoff. Same for preview's two (D1 spec, PUBLIC_ORIGIN = documented trade in code comment).
G3 approval-queue: the send-back note auto-prefixes "Still open: <title>" even for a question Geoff answered (sidebar N1 had a call "Keep the fixture as is" and still listed as still open). Check.
G4 Process: withdrawing a queued item = killing the blueprint process (exit trap). No `approval-queue withdraw`.
G5 cairn-cms register: docs-register.md's developer brief already lists the tell "No intensifier own". Authors were told to read it; three authors, three fact-checkers, and the session missed it 10x (sidebar), 6x (content-model). Only a fresh register editor caught it. The register-check step (cairn-register-editor) is not in the blueprint flow; tellgrader --register docs exits 0 on both files (it has no own check). Fix: register editor in the blueprint skill's flow before queueing, and the deterministic check (survey #1).
G6 register editor also found 11 over-26-word task sentences (a blocking base-guide rule) in the sidebar blueprint; drafter check has no sentence-length check on blueprint lines.
G7 cairn-cms: PR #134's troubleshooting blueprint fails `drafter check` on `track: "admin"` (drafter #58 made a named track an error). Same class as backlog #30; #30 should name it too. Pre-existing, not from the own fix (db75ccdc8 pushed to reviewed-pages).
G8 sweep scope: own-pattern hits ~900 in published arms + blueprints (reference arm ~700: sveltekit 133, admin-toolkit 130, cairn-audit 60, core 41). Plans/specs/research are history, excluded.
G9 own sweep (own-sweep branch, 8 slices merged 0bee3b1d0, repairs 3960d4913): agents that removed by script broke idioms ("no X of its own" -> "no X of its", "after its own:" -> "after its:"); 14 dangling remnants caught only by a post-merge regex scan (of/on + its/their before punctuation or function word). survey #1's tellgrader check should pair the own warning with this dangling-remnant check; any future word sweep needs the scan built in.
G10 own sweep: templates/waymark/.claude/**, README.md, CLAUDE.md are baked from repo-root claude/, skills/, packages/create-cairn-site/template-repo by emit:template; 240 own hits stay there until the sources are swept (out of approved scope with tool/ and packages/).
G11 own sweep: three extend headings lost "own" -> anchors changed (upload-from-your-screen, mint-and-revoke-from-your-admin-route, port-your-theme-onto-the-chassis); in-repo links fixed; external inbound links (cairn.pub) unchecked.
G12 Geoff rejected share-a-draft-preview: "What is the case for this piece of documentation?" A scaffolded site needs nothing (template carries migration/route/banner; deploy applies AUTH_DB migrations), the rest duplicated reference pages. Three authoring rounds, three fact-checks, a register pass were spent before anyone asked whether the page earns its place. Fix (blueprint skill new-page.md + outline): a premise step before step 1 — who has work to do here that no other page or the scaffold already covers? Outline entries inherited from the pre-rebuild page list are not evidence of need. Folded into build-the-public-routes (new blueprint) + security-model by Geoff's choice 2026-10-23.
G13 build-the-public-routes had no blueprint, so a one-section fold became a whole new-page blueprint (13 covers). The skill's "adds a section, approve the blueprint first" rule has no path for a page with no blueprint.

## Fold author (14d7ce655, ~90 min, build-the-public-routes new + security-model + outline; 0 err / 34 exhaustive warn)
D1 drafter: exhaustive fires on "never" in :::constraints (instructions) and on descriptive "no"; 34 warnings near all FP (=A3,B4,C4).
D2 drafter: :source[...] with [...path] route dirs unknown/unsupported (=C1); Code bullets left sourceless.
D3 drafter: links warning flags outline crossLink to a managed:false page (choose-an-ai-posture) as "names no page".
D4 cairn-cms/drafter: check:facts refuses path#Symbol outside src/ while drafter check --fact accepts it (packages/create-cairn-site/...#applyMigrations).
D5 cairn-cms: stale or prose-sourced facts still [verified]: f:0elmiu (sign-in page indexed: wrong, LoginPage noindex), f:niuzzg, f:s4prb0 (README), f:q07rd5 (docs page). Nothing flags D1-uncitable facts (=B14).
D6 prompt (mine): credential line needed f:a7yrhq + f:l4waby too.
D7 plan inputs: build-the-public-routes plan (2026-10-12) predates D1; saved only section order (=A11).
D8 skill: format.md silent on Code: bullet with no fence/no :source (passes check).
D9 skill: no blueprint-time sentence-length / hinge tool (=G6); author wrote a throwaway script.
D10 agent: sed pointer swap vs "Edit tool only" grey area (=B13).
D11 cairn-cms: scaffold literal origin https://showcase.test vs setup-written PUBLIC_ORIGIN workers.dev URL: two origins after deploy (scaffold friction).
D12 cairn-cms: deploy applies AUTH_DB migrations --remote only; local D1 still needs --local (f:m4y3m4).
D13 retiring a page leaves inbound blueprint links (add-cairn tutorial :2168 anchor, replace-magic-links See also :303); no tool lists them on outline removal (drafter refs is fact-based).
D14 drafter: links check resolves a cross-page anchor against the PUBLISHED page, not the target's blueprint; repointing to a section a not-yet-drafted blueprint adds (build-the-public-routes#mount-the-draft-preview-route) errors until the redraft.
