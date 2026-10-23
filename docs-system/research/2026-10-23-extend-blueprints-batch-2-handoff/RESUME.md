# Extend blueprints batch 2: resume point

Paused 2026-10-23 08:50 on Geoff's request to save tokens. Resume from here in a cairn-cms session.

## State

- Branches, all pushed, off `extend-blueprints-2` (cut from main `a350c8367`):
  - `ebp2-content-model`: blueprint **approved** by Geoff.
  - `ebp2-arrange-the-admin-sidebar`: blueprint **approved** by Geoff.
  - `ebp2-share-a-draft-preview`: Geoff rejected the standalone page ("What is the case for this piece of documentation?") and chose to fold it in. The branch now retires the page's outline entry and blueprint, adds a new `build-the-public-routes.blueprint.md` (whole page, with a "Mount the draft preview route" section), adds `sc-preview` to `security-model.blueprint.yaml`, and repoints two inbound blueprint links. Head `c38b32dda`.
- `build-the-public-routes` fact-check: round 1 (269 claims: 258 hold), round 2, and round 3 are settled. The last commit `c38b32dda` is a structural rewrite of reader-block lines 22 and 24, after their findings returned. Its fact-check was stopped before it finished: **re-run it on `git diff c38b32dda~1 c38b32dda`**.
- Merged on main this session: PR #137 (the empty "own" sweep) and backlog #31 to #34 (`8b75b9d99`). PR #134's troubleshooting blueprint got its "own" fix (`db75ccdc8` on `reviewed-pages`).

## Next

1. Fact-check `c38b32dda`'s two lines. If a finding returns a third time, it becomes a question note.
2. Write `notes-build-the-public-routes.json`. Anchors come from `anchors.py` (the scratchpad copy is lost; the format is in the blueprint skill's Review section). The notes cover:
   - why this page exists now (the fold);
   - the preview section, and where the rest of the old page went;
   - the `sc-preview` line, quoted, since the YAML blueprint is not queued;
   - a question note on `f:gwpffe`: the adapter-cloudflare `Content-Type` caveat rests on a 2026-09-29 read of the vendor's `index.js` and a local measurement, and no repo code settles it;
   - corrected facts (`f:0elmiu`: the sign-in page carries `noindex`; `f:niuzzg`; `f:yef4lo`; the outline's `editor.nav` `configPath` does not exist);
   - two open items: the scaffold ships two origins (`https://showcase.test` against a setup-written `PUBLIC_ORIGIN`), and deploy applies migrations to remote only.
3. Ask Geoff whether to queue the whole `build-the-public-routes` blueprint or only its preview section. That question was pending when the pass paused.
4. Queue it with `approval-queue blueprint` under `setsid -f`, then watch the decision file.
5. After approval, merge the three `ebp2-*` branches into `extend-blueprints-2`. `outline.yaml` may conflict between the content-model and preview branches. Open the PR and send it through `approval-packet`. Two repointed links error in `drafter check` until build-the-public-routes is drafted (friction D14).
6. Write the batch 2 friction record from `friction.md` (in this folder) at `docs-system/research/2026-10-22-extend-blueprints-batch-2-friction.md`. File each item in its owning repo's backlog: drafter, the blueprint skill, cairn-cms, approval-queue, and the fact-checker agent. Lead with G12, the page-premise check before authoring, and G9, the dangling-idiom scan for word sweeps.
