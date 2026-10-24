# Extend blueprints batch 2: the overnight run

The run was paused 2026-10-23 at 08:50 and resumes at 00:01 on 2026-10-24 as an unattended run of up to 8 hours on pavilion. Geoff settled every decision below on 2026-10-23, so the run asks him nothing. Anything that needs his approval goes to the approval queue and waits for the morning. Never block on it.

## Guards (arm first)

- `/loop` with no interval, the dynamic wake-up, as the run's first act. The prompt points back at this file. The backstop fallback is 1200 to 1800 seconds (`~/.claude/docs/unattended-work-guards.md`, "A wake-up that does not depend on the API link").
- The run uses individual agents only, never a Workflow (Geoff, 2026-10-23). At most two run at once, each in its own worktree. Name a model on every dispatch.
- Pavilion has no battery and no lid, and the sleep inhibitor is tool-held. Confirm it with `systemd-inhibit --list`, but don't arm it.
- An agent that runs past about 45 minutes with no commit gets checked. Stop it if its transcript is growing with nothing to show.
- Stop the whole run at 08:00, or at a judgment-call stop (`pass-core`). On stopping, update this file's "Done" list.

## State at the pause

- The three branches are pushed, all off `extend-blueprints-2` (cut from main `a350c8367`):
  - `ebp2-content-model`: Geoff **approved** the blueprint.
  - `ebp2-arrange-the-admin-sidebar`: Geoff **approved** the blueprint.
  - `ebp2-share-a-draft-preview`: Geoff rejected the standalone page and chose to fold it in. The branch retires the page's outline entry and blueprint, adds `build-the-public-routes.blueprint.md` (the whole page, with a "Mount the draft preview route" section), adds `sc-preview` to `security-model.blueprint.yaml`, and repoints two inbound links. Head `c38b32dda`.
- The `build-the-public-routes` fact-check is settled through round 3. Commit `c38b32dda` structurally rewrites reader-block lines 22 and 24 after their findings came back twice. Its fact-check was stopped before it finished.
- Already on main: PR #137 (the empty "own" sweep) and backlog #31 to #34 (`8b75b9d99`).
- The friction log so far is `friction.md` in this folder (S, A, B, C, D, and G items), with the earlier review notes JSON beside it as models for new notes.
- `tools/` in this folder holds the session's helpers. `anchors.py <blueprint>` prints every note anchor. `save_findings.py <fact-checker output> x <file> <commit>` saves a fact-check to the queue's findings store. `comment-only.mjs` is the compile-equivalence proof from PR #137. `sweep-prompt.md` is PR #137's slice prompt. Copy them to the new session's scratchpad before use.
- `extend-blueprints-2` is pushed. It sits at `a350c8367`, behind main (PR #137 merged after the cut). Merge `origin/main` into it before step 2's merge, so the three-word heading renames and the swept prose come along.

## Standing answers (Geoff, 2026-10-23)

- **Build the public routes:** queue the **whole** blueprint for review, with notes pointing at the preview section.
- **Overnight scope:** all four items below, in the order given.
- **Agents:** individual agents, no Workflow.
- **Backlog #34 scope:** sweep everything except the admin's editor-facing copy, such as "Your own custom rules" and "These edits are on their own branches". That covers the Go tool, the scaffolder package, the sources of the template's generated agent files, audit finding messages, CLI diagnostics, the tidy prompt, e2e test names, and showcase content.
- **Page premise check (new, from Geoff's preview send-back):** before authoring any batch 3 page, answer "what is the case for this page?" from the code. Who has work that the scaffold, the tutorial, or a reference page doesn't already cover? When the case is weak, don't author the page. Write a one-paragraph fold recommendation for Geoff, file it as a cairn-cms backlog item, and take the next page in outline order instead.

## Overnight plan, in order

1. **Finish Build the public routes** (worktree `.claude/worktrees/ebp2-share-a-draft-preview`).
   - Fact-check `git diff c38b32dda~1 c38b32dda` with a fresh `fact-checker`. If a finding returns a third time, it becomes a question note.
   - Write the notes JSON. Anchors follow the blueprint skill's Review section; an apostrophe becomes a hyphen in a slug. The notes cover:
     - why the page exists now (the fold);
     - the preview section, and where the rest of the old page went;
     - the `sc-preview` line, quoted;
     - a question note on `f:gwpffe`: the adapter-cloudflare `Content-Type` caveat rests on a 2026-09-29 read of the vendor's `index.js` and a local measurement, and no repo code settles it;
     - the corrected facts: `f:0elmiu` (the sign-in page carries `noindex`), `f:niuzzg`, `f:yef4lo`, and the outline's `editor.nav` `configPath`, which does not exist;
     - two open items: the scaffold ships two origins (the literal `https://showcase.test` against the setup-written `PUBLIC_ORIGIN`), and deploy migrates the remote database only.
   - Queue the blueprint: `setsid -f sh -c "approval-queue blueprint <worktree> 'Build the public routes' blueprints/docs/extend/build-the-public-routes.blueprint.md --notes <notes> > <decision file>"`. Write the decision file in this folder.
2. **Merge and draft the approved pages.**
   - Merge `ebp2-content-model` and `ebp2-arrange-the-admin-sidebar` into `extend-blueprints-2`. Settle any `outline.yaml` or facts conflict from the code. Push, and open a draft PR to main.
   - For each page: run `approval-queue approved <file> <blob>`, which must exit 0. Run `drafter page <blueprint>` with no `--judge` (exit 3 means `--resume <run-id>`).
   - Fact-check each draft with a fresh `fact-checker`, settle the findings, run `cairn-register-editor`, apply its rewrites, then fact-check the changed lines.
   - Run the docs gate: `npm run -s check:docs-gate`, `check:vale`, `check:provenance`, and `check:facts`.
   - Queue each page with `approval-queue page <worktree> <title> <file> --pr glw907/cairn-cms#<n> --notes <notes>` under `setsid -f`.
   - The preview branch merges only after Geoff approves its blueprint. Leave it out.
3. **Write the friction record and file the backlogs.**
   - Write `docs-system/research/2026-10-22-extend-blueprints-batch-2-friction.md` from `friction.md`, in the shape of the pilot's record (`2026-10-22-extend-blueprints-pilot-friction.md`).
   - File each item through `log-issue` in its owning repo: drafter (`~/Projects/drafter`), the blueprint skill and the fact-checker agent (`~/.dotfiles`, the workstation repo), cairn-cms, and approval-queue. Tag each with `#initiative:docs-system`.
   - Lead with G12 (the page-premise check before authoring) and G9 (a dangling-idiom scan for word sweeps).
   - Commit the record in initiatives. A backlog-only change is a direct change, pushed to each repo's main from a worktree when another session is live.
4. **Run backlog #34, the rest of the empty "own" sweep,** as its own branch off main.
   - Use the PR #137 method:
     - Split the work into slices, one agent each, each in its own worktree. Run at most two at once.
     - Removal is by judgment. Keep a real contrast, the idioms, the verb, and identifiers.
     - After the merge, run the dangling-idiom scan. It looks for "of" or "on" plus a possessive, followed by punctuation or a function word.
     - Prove the code changes with the compile-equivalence check, except where runtime text changed on purpose.
     - Close with a whole-branch `diff-reviewer`.
   - `tool/` is Go. Invoke `go-conventions`, and its gate is `make -C tool check`.
   - A message change updates every test and doc quote that asserts it (`check:editor-quotes`).
   - For the template's generated agent files, edit the sources (repo-root `claude/`, `skills/`, `packages/create-cairn-site/template-repo`), then run `npm run emit:template`.
   - Before the PR: run the fast lane, then CI through `ci-green` (re-issue on exit 75), then an `approval-packet` to Geoff.
5. **Batch 3: the next three blueprints,** if time remains.
   - The candidates, in outline order, are `define-an-adapter-and-schema`, `configure-rendering`, and `link-content-with-references`. After those: `reuse-content-across-entries`, `configure-media`, `migrate-existing-content`, `theme-your-public-site`, `act-on-newly-published-entries`, `add-an-island`, `turn-on-tidy`, and `run-cairn-audit-on-your-site`.
   - Run the premise check first, from the standing answers.
   - Branch `ebp3-<slug>` off `extend-blueprints-2` after step 2's merge.
   - Use the batch 2 author prompt. `author-template.txt` in this folder is the fold author's prompt for build-the-public-routes. Keep its "Where you work", method, and report sections, and replace the page-specific brief with the new page's outline entry.
   - Follow the flow: author, `cairn-register-editor`, apply its rewrites, fact-check, settle, a fresh fact-check of the changed lines, notes, then queue under `setsid -f`.
   - Collect friction as batch 2 did, appended to the friction record.

## Done

- 00:10 Step 1 done: `0ab7af0f1` takes the fact checker's wording for line 24; Build the public routes queued, decision to `decision-bpr.json`.
- 00:20 Step 2 started: `extend-blueprints-2` merged origin/main and both approved branches (pushed). Worktree `.claude/worktrees/extend-blueprints-2` needed `drafter.local.toml` copied from `~/.config/drafter/cairn-cms.local.toml` (record item 60). `drafter page` running on both pages.
- 00:40 Step 3: record committed (`eb49670`); a filing agent is filing it into the five backlogs.
- 00:55 Step 3 done: filed in drafter #51-#69 (+#48), survey #2 (+#1), approval-queue #24-#26 (+#21, #23), cairn-cms #35-#45 (+#28, #30, #34), dotfiles #31 extended. The blueprint skill lives in the drafter repo, so its items went there.
- 01:00 Step 4 started: branch `own-sweep-2` off origin/main. Five slices, prompt `tools/sweep2-prompt.md`: tool-a (cmd, doctor, health, render) and scaffolder (packages/ minus template-repo) running; tool-b (rest of tool/ minus docs/design and adr), agent-sources (skills/, claude/, template-repo, emit:template, scripts/), and runtime (src/lib non-editor strings, showcase, tests, mirrored docs quotes) queued.
- 01:00 Step 4: five slices merged into `own-sweep-2` (tool-a `f8769fdea`, tool-b `caeb71c01`, scaffolder `176d60cd6`/`f4b8c843f`, runtime `58a3b56b2`/`dc4df7c65`, sources `b3a7bd175`/`c82fc2be9`). The sources slice had emptied `scripts/checks/gate-tier.mjs`; restored in `587f0bf28` (record item 61). Fast lane green (leg one's lone failure is Firefox missing locally), close review accept. Draft PR glw907/cairn-cms#138; e2e baseline regen dispatched (run 40079322349), then CI, then the packet.
- 01:00 Step 2: drafter is in the gate-fix exchange on Content model (first draft failed check:provenance and check:symbols); Arrange the admin sidebar is queued behind it in the same run.
- 01:13 Step 5: premise check kept define-an-adapter-and-schema (trimmed) and configure-rendering (narrowed to writing a markdown component); link-content-with-references folds into Content model (cairn-cms #46). Both kept pages authored, register-edited, fact-checked, and settled (configure-rendering `d1db67e9b`, define-an-adapter `ff84e66bf`); a last check of the settled lines is running, then notes and the queue.
- 01:13 Step 2: drafter is waiting on the Message Batches API for the sidebar's draft (record B3-17); not stalled.
- 01:18 Step 4: PR #138 CI green on `5f4024801`, marked ready, packet queued (decision to `decision-138.json`).
- 01:18 Step 5: Configure rendering and Define an adapter and schema queued (`notes-cr.json`, `notes-dad.json`; decisions to `decision-cr.json`, `decision-dad.json`). Reuse content across entries failed the premise check: fold filed as cairn-cms #47 (`30b3fb088`). Configure media kept and trimmed; its author is running in `ebp3-configure-media`.
- 01:47 Step 5: Configure media authored, register-edited, fact-checked, settled (`1a35a3f9f`), and queued (`notes-cm.json`, decision to `decision-cm.json`). Branch also fixes `log-events.md`'s `media.uploaded` row (`946f14dcb`) and `extractMediaRefs`'s doc comment (`e2974f313`). Batch 3's three blueprints are done (two folded: #46, #47). Engine bugs from B3-25 still to file.
- 01:50 Batch 3 friction filed: drafter #70-#77 (`27f095e`, addenda on #48, #56, #57, #59, #60, #61, #63), cairn-cms #48-#51 and #53 (`0ef67c5c0`, `9a044839b`; addenda on #36-#38), dotfiles #32 (`3bfdcd5`, moved from cairn-cms #52, `d7d7453ab`). Extra page: Migrate existing content passed the premise check unchanged; its author is running in `ebp3-migrate-existing-content`.
- 02:13 Extra page: Migrate existing content authored, register-edited, fact-checked, settled (`510190a9c`, the listed-date row in the checker's own wording after two rounds), and queued (`notes-mec.json`, decision to `decision-mec.json`). Friction B3-27 to B3-30 recorded, not yet filed.
- 07:06 Geoff's decisions: PR #138 approved and merged (`7702529`), #34 closed (`d17ab6eba`). Approved blueprints: Build the public routes (kept the f:gwpffe note), Define an adapter and schema, Migrate existing content (UTC day kept, draft-field step kept), Configure rendering (rename to Write a markdown component, DaisyUI caution kept; rename agent running on `ebp3-configure-rendering`). Configure media sent back: document the workaround and log the engine issues with a docs update in each; #48 and #49 updated, cap kept; requeued (decision to `decision-cm2.json`). Merging the approved branches into `extend-blueprints-2` waits for the drafter run there to finish (one executor per worktree); then sweep leftover `configure-rendering` links.
- 07:09 Rename done on `ebp3-configure-rendering` (`676963c47`, pushed): blueprint, published page, briefs, outline, and 45 files' links; docs gate, links, facts all OK. No docs redirect map exists, so cairn.pub's old `/configure-rendering` URL breaks at the next pin bump unless cairn.pub adds a redirect then.
- 07:40 Configure media approved on requeue. All six batch 3 blueprints are approved. B3-27 to B3-30 filed: drafter #78 to #80 (`bb916aa`), cairn-cms #54. Run ended here.

## Next session starts here

1. The drafter run `20261024T080412Z-13b5d021` (content-model, arrange-the-admin-sidebar, in `.claude/worktrees/extend-blueprints-2`) has had its second batches pending since 01:33. If its process is gone, run `drafter page --resume 20261024T080412Z-13b5d021` with the same two blueprint arguments from that worktree. When it finishes: fact-check each draft (fresh agent), settle, register edit, docs gate, commit, draft PR, `approval-queue page`.
2. After the drafter is done with the worktree, merge the six approved blueprint branches into `extend-blueprints-2`: `ebp2-share-a-draft-preview` (holds the approved Build the public routes blueprint at 0ab7af0; take that file only, since the branch name is from the rejected page), `ebp3-define-an-adapter-and-schema`, `ebp3-configure-rendering` (now Write a markdown component, `676963c47`), `ebp3-configure-media`, `ebp3-migrate-existing-content`. Then `git grep configure-rendering` for links the merge brought back, outside historical records.
3. Draft the five newly approved pages through `drafter page`.
4. Geoff's friction-cleanup pass reads the batch 3 section of `2026-10-22-extend-blueprints-batch-2-friction.md` and the filed items.

**Queue change (approval-queue#7, merged 86d142d, 2026-10-24):** `approval-queue blueprint` and `approval-queue page` now require `--description <file>`, two or three paragraphs. The title follows the packet title rule, and the queue prints its link on stderr. A command without the flag exits 2. Every page queued in step 1 or step 3 above needs it.

**Drafter rebuilt mid-run (f2ad05e, 2026-10-24, drafter #60, #62, #64):** the running `drafter page` keeps the old code, and the new build reads its state. A `--resume`, and every `drafter check` or `drafter refs` from here on, runs the new rules: sentence-length and hinge checks on blueprint lines (#64), exhaustive-word matches reported per line (#62), and a stricter store check (#60). Expect new findings on the six approved blueprints before they draft. Settle them, and if a fix changes an approved line, it goes back through the blueprint rules before drafting.
