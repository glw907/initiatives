## Brief

This PR corrects seven published extend pages and three reference rows that still showed the hooks calls engine pass B replaced on 2026-10-08 (`37797ff35`). Since that pass, `createAuthGuard`, `devBackendHandle`, and `createEditorRoutes` take one config with a required `runtime`, and `roles` and `access` are declared once on the adapter. A reader who copied the old calls got a type error. A reader following the tutorial got a hand-built site that threw at startup. A fact-check of Write a markdown component found the problem during batch 5.

### What changes

- **The tutorial** imports the `runtime` it already exports and passes `{ runtime }` to both hook handles.
- **Hooks calls on the other pages.** Add a second sign-in group, Add a custom admin screen, Restrict admin access, Replace magic links with Cloudflare Access, and Scaffolded site files now show the same call. Restrict admin access drops three steps that edited the hooks file, since the hooks file needs no edit now.
- **The `access_map_not_attached` cause** on Debug your site, `sveltekit.md`, and `log-events.md` now matches the code. Both handles attach the map wherever they set the editor, so the refusal comes only from a site's own hook that sets the editor without it.
- **The removed signups demo.** Restrict admin access and Scaffolded site files no longer describe a scaffold signups screen, its `APP_DB` database, or `migrations-app/`. The scaffold doesn't ship them, and they live only in `examples/showcase`.
- **Blueprints and facts** match each page change, including three blueprint lines that still named the old calls, so a redraft won't bring them back.
- **Housekeeping.** `docs/STATUS.md` points past batch 5, and BACKLOG #70 lists the page-versus-blueprint drift this sweep found but left for a redraft.

### If you approve

The session merges this PR.

## Decisions

- The fix is its own PR rather than part of batch 5, so the five new pages didn't wait on a seven-page correction.
- The signups demo was in scope only where a page now contradicted itself. Restrict admin access said the scaffold declares no access map while describing the scaffold's signups rule. Other drift the sweep found, such as the tutorial's hand-written define plugin and `src/access.ts`, is filed as BACKLOG #70 for a redraft from the blueprints, not patched by hand.
- The last three edits to Scaffolded site files (one D1 database, `0001_roles.sql` shipped, `+error.svelte` in the route tree) are the session's, checked against the `templates/waymark` listing and `f:gepykz` rather than another fact-check round. The recheck that found them held every line the sweep changed.
- Scaffolded site files' tree leaves out `src/app.html` on purpose, per its blueprint. The page now says the tree omits files no section discusses, rather than adding the file.

🤖 Generated with [Claude Code](https://claude.com/claude-code)
