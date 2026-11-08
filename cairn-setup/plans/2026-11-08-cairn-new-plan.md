Initiative: cairn-setup

# cairn new: plan

Design: `../specs/2026-11-08-cairn-new-design.md` (approved 2026-11-08, binding)
Spec: `../specs/2026-11-08-cairn-new-spec.md` (mechanisms, with sources)
Repos: `glw907/cairn-cms` (passes P1 to P6), `glw907/cairn-pub` (pass P7)
Base: cairn-cms `main` at `d27ea60b0`, cairn-pub `main` at `85c97cc` (every `file:line` is at these)
Conductor: `conductor-cairn-cms` for P1 to P6; P7 is `ordinary` and merges itself (`site-pass`)
Load at start of every pass: `pass-core`, `cairn-pass`, `cairn-running-passes`; for `tool/**`,
`standards:go-conventions` (and `standards:golang-spf13-cobra` for `tool/cmd/cairn`); for the
terminal view, `standards:elm-conventions`, `standards:bubbletea-design`, `tui-design:tui-design`,
`standards:tui-visual-verify`; for docs, `cairn-writing-docs`.

The two rules every dispatch in this initiative carries are `pass-core` step 1's quoted samples
("Avoid over-engineering..." and "Deliver what was asked..."). They apply here: nothing below adds a
feature the design or the fold record (`2026-11-08-cairn-new-review-fold.md`) does not name.

## Pre-flight

Each item is done and checked before the conductor launches P1, except where an item names a
later pass.

1. **[you] Create the cairn-owned Cloudflare OAuth client (private).** Cloudflare dashboard on the
   glw907 account, Manage account > OAuth clients > create: name `cairn`, a public client (no
   secret), grant type authorization code with PKCE, redirect URI
   `http://127.0.0.1:49152/cloudflare/callback`, and the scopes `user-details.read
   account-settings.read zone.read zone.write dns.write workers-scripts.edit workers-routes.write
   d1.write workers-r2.write email-sending.write workers-ci.write user-api-tokens.write
   offline_access` (spec 6 says why setup requests fewer). The client id is public. Write it, alone,
   to `~/Projects/initiatives/cairn-setup/research/cloudflare-oauth-client-id.txt`. Check: `grep
   -Ec '^[0-9a-f]{32}$' ~/Projects/initiatives/cairn-setup/research/cloudflare-oauth-client-id.txt`
   prints `1`. This proves the id's shape only; S1's consent proves the redirect and the scopes.
   Going public waits until "Before the first release".
2. **[you] Settings grant for the held files and the merges.** Two `autoMode.allow` lines, through
   the dotfiles repo (`~/.dotfiles/claude/.claude/settings.json`, which `claude-tooling-sync apply`
   generates into `~/.claude/settings.json`; it is never stowed). Their text lives in one place, the `LINE` and `MERGE_LINE` strings of
   `research/add-cairn-setup-grant.py`, which Geoff reads and runs; this item does not restate it.
   `cairn-setup-passes` lets executors edit the held files (the `.claude/skills/cairn-*` skills the
   plan names, `.claude/agents/cairn-implementer.md`, `claude/CLAUDE.md`, the setup overlay's
   `.claude/settings.json` and `.mcp.json`, `.claude-plugin/marketplace.json`, `plugins/cairn/**`),
   and says how each change merges per Decide 12. `cairn-setup-passes-merge` (on a yes to Decide 11)
   makes the conductor's `gh pr merge <n> -R glw907/cairn-cms --merge --match-head-commit <head>`
   routine for the PRs of branches `cairn-new-1`, `-2`, `-5`, and `-6` once Decide 11's gates hold
   on that head. Check: `grep -c 'cairn-setup-passes' ~/.claude/settings.json` prints `2` (`1` on a
   no to Decide 11), and item 8's probe proves the write.
3. **[you] Rule on the twelve Decide items** in "Rulings before launch", in the pre-launch packet.
   Check: `grep -cE '^Ruled: (yes|no)\b'
   /var/home/glw907/Projects/initiatives/cairn-setup/plans/2026-11-08-cairn-new-plan.md` prints
   `12` (an empty `Ruled:` line does not count).
4. **[you] Agree the recording sitting S1.** S1 never holds the run: Geoff runs it when the
   notification reaches him, and the work goes on meanwhile (T1.0, "Stops and standing answers").
   It runs in your Ptyxis terminal at P1's set point,
   after T1.0's commit and its two reviews, for about 30 minutes: one `bash <P1 worktree>/tool/scripts/record-fixtures/record.sh`
   (the conductor's `notify-send -u normal` names the absolute path and the commit) that sources
   `~/.local/secrets` in a subshell, opens your Chromium for one Cloudflare Allow (tick API Tokens:
   Write), drives GitHub as `glw907-test` by Playwright, writes only to
   `~/.local/state/cairn-setup-s1/`, and cleans up; after a crash you run `bash <P1 worktree>/tool/scripts/record-fixtures/record.sh --cleanup <run id>` in the same sitting. S1 ends when you have read its results file's
   cleanup lines; a failed revoke line means you remove the grant where the dashboard lists it, or
   note that it stays until its refresh token expires. S1 does not run during a release-gate run,
   which shares `carin-test.org`. Check: the packet's S1 ask is answered yes with the window, and
   `grep -cE '^(export )?GITHUB_TEST_(LOGIN|PASSWORD|TOTP_SECRET|TOKEN)=' ~/.local/secrets`, run by
   you, prints `4` (names only).
5. **[session] Land the backlog and ROADMAP edits** in "Backlog verdicts" and "ROADMAP additions"
   as one direct change on `main` (`pass-core` "Ledgers"), before P1's worktree is cut. Check, on
   `origin/main`: `grep -c '#initiative:cairn-setup' BACKLOG.md` is at least 4; `grep -cE '^- \[ \]
   \*\*#(350|351|353|339|340|204|185|382|381)\*\*' BACKLOG.md` prints `0`; `grep -c 'GitHub
   organizations' ROADMAP.md` and `grep -c 'Migrate content' ROADMAP.md` are each at least 1.
6. **[session] Conductor pre-launch checks** (`pass-core` "Execute"), before each pass: the main
   checkout is on `main`; `git -C /var/home/glw907/Projects/cairn-cms rev-list --count HEAD..origin/main`
   prints `0`; `git -C /var/home/glw907/Projects/cairn-cms check-ignore -q .claude/worktrees/x`
   succeeds; no session has the pass's branch checked out (`pgrep -f '[c]airn-new-<n>'` is empty);
   `git -C <worktree> status --short` shows no change the conductor did not author; and, on a yes to
   Decide 5, P6's base is P5's approved head. A launch
   that prints "Workspace not trusted" stops for item 7.
7. **[you, only if item 6's launch prints "Workspace not trusted"]** Run `claude` once in that
   checkout and accept the prompt. Check: the relaunch prints no such line.
8. **[session] Auto-mode probe, after item 2 and before P1.** A `claude --bg` probe session in the
   cairn-cms checkout cuts a scratch worktree under `.claude/worktrees/`, cites T5.7 as its task, and,
   in it: runs `kitty-headless-shot --help` and one
   80x24 capture of `printf 'probe\n'`; edits one line of `.claude/skills/cairn-running-passes/SKILL.md`,
   commits, and reverts it; and runs `npm publish --dry-run` in a temp directory holding a dummy
   `package.json`; and runs `claude plugin validate` on a dummy plugin manifest. It pushes nothing and removes the worktree. Check: the PNG exists and the
   transcript shows no refusal. A refusal holds the launch and becomes a `[you]` grant like item 2
   (`standards:tui-visual-verify`; `pass-core` "Pre-flight").
9. **[session] The planning-miss PR.** The planning session opens the `standards:plan-reviewer`
   checklist PR ("Planning misses at design") on `~/Projects/standards` and names it in the
   pre-launch packet. Check: `gh pr view <n> --repo <standards repo>` shows it open or merged.

Permissions checked: each task's writes and credentials were read against auto mode in a `claude
--bg` executor. Every executor and pair writes only tracked files in its own worktree, runs `make -C
tool check`, `npm run lane:fast`, `go test`, `npm pack`, `npm install` into temp directories, `node
--test`, actionlint, and `npm publish --dry-run` (item 8), reads public registries and Go and npm
proxies, pushes its branch to `glw907/cairn-cms` or `glw907/cairn-pub`, and opens a PR. No executor
reads `~/.local/secrets`, calls a live provider account, publishes, tags, cuts a release, or
dispatches a workflow: the only live-account step is S1, in Geoff's terminal (item 4), because auto
mode refuses a session's sourced-secret read (`pass-core` lens, cairn release gate pass A,
2026-11-07). The executor reads S1's staged output from `~/.local/state/cairn-setup-s1/`, which
holds no secret after the recorder's scrub. The `.claude/**` paths, `claude/CLAUDE.md`, the setup
overlay's `.claude/settings.json` and `.mcp.json`, and the plugin manifests are held files covered
by item 2 and proved by item 8, because auto mode refused `.claude/**` content as Self-Modification
on 2026-11-02 and 2026-11-03 (release-process-b plan). Keyring tests swap the package vars at
`tool/internal/secrets/keyring.go:21-26`, and the end-to-end binary uses the test build tag's file
store (spec 5), so no task touches the desktop keyring. Screenshots go through item 8's probe.

Reviewed: three-lens review (`2026-11-08-cairn-new-review-mechanics.md`,
`2026-11-08-cairn-new-review-contract.md`, `2026-11-08-cairn-new-review-integrity.md`) of this plan
and its spec, folded per `2026-11-08-cairn-new-review-fold.md`, with a verification read in
`2026-11-08-cairn-new-fold-verification.md`.

## Rulings before launch

Each Decide changes something the approved design says, or chooses what the design left open in a
way that changes what an owner sees. The plan builds the recommendation once ruled; the tasks that
depend on it are named.

### Decide 1: the sign-in redirect lands on the confirm page

The engine's `GET /admin/auth/confirm` consumes nothing and shows a Sign in button, so the setup
tab's redirect takes one click (spec 10). **Recommendation: yes, keep the engine unchanged, accept
the click, and change step 8's watch sentence and `done.html`'s footer to name it.** The done
screen says "You're signed in" only when the token was consumed; otherwise "Your site is open in the
setup tab. Select Sign in there, or use the link in your email." (copy task T3.8). No means an
engine auth change (a one-click confirm GET), which the design rules out. Depends: T1.12, T3.4,
T3.8.

Ruled: yes (Geoff, 2026-11-08, packet 20261108T133837-352510)

### Decide 2: who sends the sign-in email

A sign-in request from setup binds the emailed token to setup's browser nonce. A plain click in the
owner's browser then does not sign in; the link works there only if the owner first submits the
sign-in form for that address from the same browser within 60 seconds of setup's request, which
rebinds the row (`rebindToken`, `auth-routes.ts:271-293`). An owner reading mail later gets a dead
link (spec 10). **Recommendation: yes, setup writes a second unbound row and sends the email itself
through Cloudflare Email Sending, when the redirect's token is consumed or expires, whichever comes
first (at once in the agent lane), with a line to request a fresh link from the sign-in page if it
has expired.** The emailed row is unbound, the path the engine keeps for a hand-seeded row. Yes adds
one tool email and its copy (T1.6, T1.12, T3.8). No drops the email and changes the done screen's
second sentence, and leaves the agent lane's owner to request a link from the sign-in page.
Depends: T1.12, T3.4, T3.8.

Ruled: yes (Geoff, 2026-11-08, packet 20261108T133837-352510)

### Decide 3: reading the first deploy's result

The App asks for no Actions permission (design "Deploys"), and a private repository's runs are not
readable without `actions: read`, so setup cannot tell a failed first deploy from a slow one.
**Recommendation: yes, add `actions: read` to the manifest; setup reads the run for the pushed
commit with the installation token. The Workers Paid failure copy shows only when the opening's
subscriptions read says the plan is absent; every other failed run shows a generic four-part
first-deploy failure linking the run's page (T3.8).** The admin still shows no deploy status. No
means step 6 waits for the Worker to appear through the Cloudflare API up to a timeout, and every
first-deploy failure reads as that generic failure. Either way, the Workers Paid copy never names a
cause setup did not read. Depends: T1.7, T1.12, T3.8.

Ruled: yes (Geoff, 2026-11-08, packet 20261108T133837-352510)

### Decide 4: the cairn-pub pass's size

cairn.pub pins engine `0.94.0-rc.1` and its loader reads the `guides`, `reference`, and
`explanation` arms, a layout the engine removed; the new docs live in `admin/` and `editors/`
(spec 14). A markdown-copies pass on today's loader would serve stale pages. **Recommendation: yes,
widen P7 to port the loader to the two current arms, move the pin to the published `0.99.0-rc.4`
(dist-tag `next`, which ships both arms) in the same PR, add the markdown copies, and add the
`/start` and `/docs` short links; `/deploys` lands with the release's pin bump.** This is a
docs-route change, not the `cairn-pub-rebuild` initiative's rebuild. No keeps P7 to the markdown
copies and short links on today's loader, and the current docs reach cairn.pub only with that
rebuild, which would then gate the first release of `cairn new`. Depends: P7.

Ruled: yes (Geoff, 2026-11-08, packet 20261108T133837-352510)

### Decide 5: engine and tool releases stay possible between P1 and P6

Without care, a release cut mid-initiative ships setup surfaces for a hidden command: the setup
reference page (in the engine's `docs/admin` files), the help-agents setup contract, and P5's pages
describing a launcher P6 builds. **Recommendation: yes, keep `main` releasable: `cairn help agents`
shows the setup section only when `cairn new` is shown (T2.4); the generated reference writes to
`tool/docs/setup-reference.md` (outside the engine's `files`) until P5 moves its output to
`docs/admin/` (T5.4); and the conductor merges P5's approved PR immediately before P6's, so no
release can fall between them.** The setup overlay (spec 2) keeps the template side clean in either
case. No means a release freeze from P1's merge to the first `cairn new` release, recorded in
STATUS, with `scripts/release/preflight.mjs` refusing a cut while `tool/cmd/cairn/new.go` carries
`Hidden: true`. Depends: T2.4, T5.4, T5.8, P6 merge order.

Ruled: yes (Geoff, 2026-11-08, packet 20261108T133837-352510)

### Decide 6: raise the setup chain's risk class

`cairn-running-passes` maps only `tool/internal/secrets/**` in the tool to `auth-data`, so T1.8
(loopback, state nonces, the sign-in route) and T1.10 and T1.12 (the approval chain, the over-grant
deletion, the sign-in rows) are `ordinary`: no failing test first and no per-task diff review. Only
you raise a class. **Recommendation: yes, raise T1.8, T1.10, and T1.12 to `auth-data`, and add
`tool/internal/setup/{loopback,signin,runner}*` and `tool/internal/providers/{cloudflare_oauth,github_app}*`
to the skill's `auth-data` map in P1's close.** No keeps them `ordinary` with the close's
`web-auth-security-reviewer` read only. Depends: T1.8, T1.10, T1.12, T1.11.

Ruled: yes (Geoff, 2026-11-08, packet 20261108T133837-352510)

### Decide 7: the theme row on the summary

The design says the summary shows Waymark "with its one-line description" (design "The flow" 2);
the copy deck's summary says "Theme: Waymark (no reason)". **Recommendation: yes, show the
description as the row's reason, since the design names it and you decided its wording.** No
follows the deck. Depends: T3.4.

Ruled: yes (Geoff, 2026-11-08, packet 20261108T133837-352510)

### Decide 8: a GitHub App name someone else holds

App names are unique across all of GitHub and capped at 34 characters (GitHub docs, spec 3), so
`cairn-<base>` can collide with another owner's App, and a private App does not show to an
unauthenticated check. **Recommendation: yes, keep `cairn-<base>` cut to 34 characters; on a taken
name GitHub's Create page shows its error, the owner edits the name there, and setup reads the slug
back from the conversion; the Create waiting sentence gains one line for that case (T3.8).** No
means setup names the App `cairn-<login>-<base>` cut to 34 characters, which collides only within
one account. Depends: T1.3, T1.7, T1.10, T3.8.

Ruled: yes (Geoff, 2026-11-08, packet 20261108T133837-352510)

### Decide 9: an abandoned run does not capture every later run

With one unfinished run, `cairn new` resumes it (design "Failures and limits"), so an owner who quit
at approval 2 can start no second site without deleting a record by hand, and the old run keeps its
keyring entries and App. **Recommendation: yes, the resume choice always includes "Start a new
site", the agent lane gets `--new`, and `cairn new status` lists what each unfinished run still holds
(keyring entries by name, the App, the repository) with the credentials page saying how to remove
each.** No undo command is added. No keeps the design's rule, and the recovery page says how to
delete a record and its entries by hand. Depends: T1.4, T2.2, T2.3, T3.3, T5.3.

Ruled: yes (Geoff, 2026-11-08, packet 20261108T133837-352510)

### Decide 10: `cairn health` for a site deployed by Actions

The deploy check reads only Workers Builds triggers and returns UNKNOWN without one
(`tool/internal/health/check_deploy.go:189-193`), so every site `cairn new` makes reads UNKNOWN
(exit 3), and `is-it-working.md` would teach a check that never passes. **Recommendation: yes, add
T2.6 in P2, so P5's page describes shipped behavior: the record notes `deploys: actions`, and for such a site the deploy check reads the Worker's
latest deployment instead of Builds triggers.** No files it, and the docs carry a caveat, which the
close checklist's boundary test discourages. Depends: T2.6, T5.3.

Ruled: yes (Geoff, 2026-11-08, packet 20261108T133837-352510)

### Decide 11: the run goes through every pass without waiting on Geoff

Geoff asked for the passes to run without a break wherever possible (2026-11-08). As first written,
the run waited on him five times: S1, and a packet after each of P1, P2, P5, and P6, each holding
the next pass. **Recommendation: yes, the conductor merges each `auth-data` and `runner` pass's PR
itself once every gate below holds, and sends that pass's packet as a record that the merge does not
wait on (the 2026-11-01 cairn run sheet's pattern).** The gates, all on the PR's head commit: CI
green; the whole-branch `standards:diff-reviewer` folded with no open finding and no `escalate`
verdict; for an `auth-data` pass, the `standards:web-auth-security-reviewer` read folded with no
open finding, and the live admin smoke passed or the PR records it as not applicable with the
reason (P1 changes no engine auth path, T1.11); `npm run check:docs-gate` green, run locally by
the close task on the head, since `test.yml` ignores `tool/**` and CI does not run it on a
tool-only PR. Before merging, the conductor posts a gate record on the PR: one line per gate with
its evidence (the CI run, the review files, the smoke or its reason, the docs-gate output). A head
that changes after a gate ran (a fix, or P6's rebase onto `main`) reruns the gates on the new head:
CI and the docs gate always; the two reviews too, unless `git range-diff` shows the only changes
are the rebase's, in which case the gate record says so. A record packet Geoff sends back
becomes a fix-forward PR in the pass then running (or a follow-up PR after P6), never a revert of
later work. Nothing publishes: no pass bumps a version or cuts a release, and no release is cut
before the tooling brainstorm's gates exist, so Geoff's read of every merged pass still comes before
any owner runs this code. S1 never holds the run either (T1.0, "Stops and standing answers"). The
autoMode grant (pre-flight item 2) gains a second line for these merges. On a yes, wherever this
plan says a pass's "packet" it means its record packet, and a pass's "approved head" means the head
on which every gate above holds. No keeps the per-pass
packets, and each one holds the next pass until Geoff decides. Depends: pre-flight item 2, the pass
table, "Stops and standing answers".

Ruled: yes (Geoff, 2026-11-08, packet 20261108T133837-352510)

### Decide 12: who merges an edit to the repo's own skills and agents

Under Decide 11 the conductor would merge its passes' edits to `.claude/skills/cairn-*` and
`.claude/agents/cairn-implementer.md`, files the run's later sessions load as instructions (P1's
`cairn-running-passes` map edit, P5's `cairn-writing-docs` brief, P6's `cairn-releasing` and
`cairn-implementer.md`). The delta review found that wider than Decide 11 states (finding 5,
2026-11-08). **Recommendation: yes, each pass puts those edits in a side PR on branch
`cairn-new-<n>-held`, cut from the pass's head, which goes to Geoff in that pass's record packet as
an ask and merges only on his approve.** The main PR carries everything else, including the
product files that ship to sites (`claude/CLAUDE.md`, the setup overlay, the plugin, the
marketplace), and merges under Decide 11. Nothing in the chain waits on a side PR: every later
pass's risk class is set in this plan, not read from the skill, and each skill edit is used only
inside the pass that writes it. No means the conductor merges the held edits inside the main PRs.
Depends: pre-flight item 2, T1.11, T5.x, T6.x.

Ruled: no (Geoff, 2026-11-08, packet 20261108T135640-373803): the held edits merge inside each pass's PR

## Alignment with the theme-garden initiative

The theme-garden initiative designs cairn's theme catalog in parallel (Geoff, 2026-11-08), and its
sessions and this run's sessions coordinate directly to keep the two aligned. Geoff hears only of a
conflict that would change either design. Before a task changes one of these boundary points, the
conductor sends the theme-garden session the change and waits up to 30 minutes for its reply
(`ListAgents`; if no theme-garden session is live, or none replies in 30 minutes, the conductor
records that in `## Decisions` and reads the "Alignment with cairn-setup" section of the
`theme-garden` initiative record and goes on if the change contradicts nothing there, or if the
record does not exist yet):

- the catalog entry shape: `templates/catalog.json`, and a reader that accepts extra fields (T1.2, T1.9);
- the scaffold's substitution targets, named once in `tool/internal/setup/scaffold/`, since the theme's
  config files will later move out of `src/theme/` (T1.9);
- the questions form and the summary's Theme row, where theme options are added later (T3.x);
- `src/content/.cairn/`, where the garden may add a theme lock file beside `site-facts.json`;
- the starter overlay (P4), which the garden's conformance set stays out of.

A reply that asks for more than a one-line change to a task is recorded in the PR's `## Decisions`,
or, when it would change the design, stops the run for Geoff.

## Planning misses at design

The design's approval named no sitting, so S1 (pre-flight item 4) and the Decide items hold the
launch for one pre-launch packet. The design stage missed them because it did not check the corpus
rule against the write routes, the engine's nonce binding, the App's permissions against step 6,
cairn.pub's installed docs layout, or the release path's `--ignore-scripts` pack. The fix that
generalizes: a `standards:plan-reviewer` checklist line, "a design that asserts a mechanism of
existing code (a template's location, an auth flow's binding, a permission's reach, a consumer's
loader, a release step's pack) carries the `file:line` that shows it," which the planning session
opens as a PR on `~/Projects/standards` before launch and names in the pre-launch packet.

## Passes

Sequence and merge order: P1, P2, then P3 and P4 side by side (disjoint files), then P5, then P6
(on a yes to Decide 5, P6's worktree is cut from P5's approved head as a stacked branch, the
conductor merges P5's PR immediately before P6's, and P6 rebases onto `main` and passes CI on the
rebased head before its merge). P7 runs
beside any of them once Decide 4 is ruled. The release gates that prove setup belong to the tooling
brainstorm. No pass bumps a version or publishes (`cairn-running-passes` "No release").

| Pass | Slug | Class | Path minutes | Packet |
| --- | --- | --- | --- | --- |
| P1 | `cairn-new-1` spine and provider writes | `auth-data` | 1,170 | record; the conductor merges (Decide 11) |
| P2 | `cairn-new-2` agent lane, generated reference, and health on Decide 10 | `runner` | 510 | record; the conductor merges (Decide 11) |
| P3 | `cairn-new-3` terminal view | `ordinary` | 765 | merges itself |
| P4 | `cairn-new-4` starter content | `ordinary` | 300 | merges itself |
| P5 | `cairn-new-5` docs and Claude Code tooling | `runner` | 540 | record; the conductor merges (Decide 11) |
| P6 | `cairn-new-6` the switch: launcher, release pipeline, wizard retired | `auth-data` | 480 | record; the conductor merges (Decide 11) |
| P7 | `cairn-pub-docs-md` markdown copies (and the loader port on a yes to Decide 4) | `ordinary` | 195, or 375 on yes | merges itself |

On a no to Decide 11, each "record" row is a packet that holds the next pass until Geoff decides.
P1's path is 1,190 with T1.9's two theme-garden cases (20 minutes, added after the review).

Critical chain (P1, P2, P3, P5, P6): **3,485 path minutes.** P4 and P7 run beside it.

P5 is `runner` because `pass-core` "Lifecycle" puts skills and agents in `runner`, and P5 writes a
skill, a plugin, and the docs brief.

**Main stays releasable** (on a yes to Decide 5). `cairn new` is a hidden Cobra command (`Hidden:
true`) from P2 until P6 shows it, and its help-agents section and reference page stay out of shipped
surfaces until then. The setup overlay reaches only the engine tarball's `template/`, so the
wizard's sites and `templates/waymark/` gain no setup file until P6; P4's starter content reaches
every channel, as intended. From P6's merge, the release gate's
legs (`scripts/gate/legs.mjs`, which drive the wizard) no longer run; no release is cut before the
tooling brainstorm's gates exist (design "If you approve" 4), and STATUS records this at P6's close.

Each task block below is what a pair dispatch quotes verbatim. A dispatch with `model: opus` sets
`effort: high`; every other dispatch uses the agent's pinned model and effort. Every task writes
`.pass-task-clock` at its start (`pass-core` "Clock stop"), commits, and runs `npm run lane:fast --
--range <base>..HEAD` (which prints `make -C tool check` for `tool/**`) at its end. An `auth-data`
task commits its failing test first, then the fix; the lane runs on the task's last commit. A test
that must stay red until a later task lands carries `t.Skip` (or `test.skip`) and a `// WATCH:`
naming the task that unskips it, and that task shows it failing once unskipped before its fix. Each
new Go require lands in the task that first imports it, with `purity_test.go:184`'s count. Each
accepted-task report names the CI verdict on its head commit.

### P1 `cairn-new-1`: the setup spine and the providers' write surface (`auth-data`)

Outcome: `tool/internal/setup` plans and runs every setup step against injected clients, with the
providers' write routes tested on recorded responses, the template packed into the engine tarball
on the release path, and every answer proven through scaffold, `cairn-manifest --check`, and a
build. No command or view exists yet. Spec sections 1 to 10 and 12.

**T1.1 Corpus move and ADR-0003** (75 min, `runner`). Outcome: the fixture corpus and its hygiene
test live under `tool/testdata/fixtures/`, and ADR-0003 records the setup spine, the write surface,
the recorded-response rule extended to writes, keyring-only credentials, the never-printed list,
the e2e harness mechanism with the git-config and `SSL_CERT_FILE` quotes (spec 7, 13), the test
build tag (spec 5), and the `golang.org/x/crypto` require. Files: `packages/create-cairn-site/fixtures/**`
(moved), `packages/create-cairn-site/test/fixtures-hygiene.test.mjs` (moved beside the corpus),
`tool/internal/providers/corpus.go`, `packages/create-cairn-site/test/fake-server.mjs`,
`.github/workflows/tool.yml` (the two fixtures paths at lines 17 and 33, plus a Linux-only step,
after `setup-node` 24 and `npm ci`, running the moved hygiene test), the other sites the acceptance
grep hits (`tool/internal/{health/check_errors_test.go,logs/logs.go,render/golden_test.go}`,
`tool/internal/providers/{cloudflare.go,cloudflare_test.go,npm_test.go}`), `scripts/checks/gate-table.json` (`toolInputs`, line 68),
`tool/docs/adr/0003-setup-spine-and-writes.md`. Acceptance: `make -C tool check`, `npm test -w
packages/create-cairn-site`, and the hygiene test pass with the corpus at the new path, and `git grep
-n 'packages/create-cairn-site/fixtures' -- . ':!*CHANGELOG.md' ':!MIGRATION-NOTES.md'
':!BACKLOG.md' ':!ROADMAP.md' ':!tool/docs/release-candidate-notes.md'` prints nothing. Test: the existing corpus tests, which fail if a path
is missed.

**T1.0 The recorder** (150 min, `runner`), after T1.1. Outcome: `tool/scripts/record-fixtures/`
(Node, reusing `scripts/gate/browser.mjs` for GitHub) records one live body per route spec 12 lists
as recordable, with the guards, ledger, `--cleanup <run id>`, value scrub, staging output, results
file, and latency lines spec 12 names. Files: `tool/scripts/record-fixtures/**` (importing `browser.mjs` lazily), `.github/workflows/tool.yml`
(a Linux-only step running its tests in T1.1's Node setup). Acceptance: `node --test tool/scripts/record-fixtures/` passes, run
against a local fake HTTP server the test starts, with cases that fail on: a planted `ghu_`, `ghr_`,
`ghs_`, PEM, client secret, email, and account id in the staged output; a Cloudflare write off the
test zone; a GitHub write when `GET /user` is not `glw907-test`; a Cloudflare callback that redirects
to `github.com`; a ledger entry written after its create; and a cleanup that leaves a resource.
Test: those cases. Then `standards:diff-reviewer` (task scope) and
`standards:web-auth-security-reviewer` read T1.0's commit, and their fixes land, before **set point
S1**: the conductor notifies Geoff with the worktree's absolute path and the commit. The executor
goes on with Pairs A to C, none of which needs a recording; once Geoff's S1 is done it copies the
staged corpus in, runs the hygiene test, and commits it. S1 never holds the run: if the recordings
have not landed when Pair D is next, Pair D builds against docs-sourced bodies, and the import task
in "Stops and standing answers" swaps in the recordings when they land.

**Pair A: T1.3 and T1.4**

**T1.3 Planner** (90 min, `ordinary`). Outcome: `Plan(Answers)` in `tool/internal/setup/` returns
every derived name and every step with its actor, per spec 3 and 8, and is pure. Files:
`tool/internal/setup/{answers,plan,names,steps}.go` and tests. Acceptance: a table test over names
with expected outputs (empty; punctuation only; 70 characters; `Café` gives `caf`; a non-Latin name
gives the validation error; a base that makes the App name exceed 34 characters; a taken name with
suffix) and a golden of one full plan; a second call with the same answers is byte-identical. Test:
the table and the golden, which fail on any derivation change.

**T1.4 Record and resume** (90 min, `ordinary`). Outcome: the setup object of the site record
(spec 4: run id, schema version, intents and ids, version and integrity, folder and commit,
keyring entry names), resume selection, and the stored resource ids (#367). Files:
`tool/internal/record/{setup.go,*_test.go}`, `tool/internal/store/*_test.go`, and
`tool/internal/spine/{step.go,step_test.go}` if new constants join `spine`. Acceptance: a record
written at each step reloads equal; a registry holding a wizard record at each of the 19 steps plus
an adopted record yields zero resume candidates and none is written; with two unfinished setup
records, selection returns both and picks neither; a newer schema version is refused; a first save
onto an existing id draws a new id; a marshalled record from a fake run holds no credential the
fakes issued and no `Extra` key setup wrote; `cairn sites` lists a finished setup record and `cairn
health` loads an unfinished one. Test: those cases.

**Pair B: T1.2 and T1.5**

**T1.2 The template in the engine package** (90 min, `runner`). Outcome: the release path packs
`template/catalog.json` and `template/waymark/**` (composed tree plus setup overlay) into the engine
tarball (spec 2). Files: `scripts/build/pack-engine-template.mjs`, `scripts/build/setup-overlay/`
(created empty but for a README line; T1.9 fills it), `package.json` (`files`, `check:package`),
`.gitignore` (`/template/`), `.github/workflows/publish.yml` (the "Pack the three tarballs" step),
`scripts/checks/check-package-files.mjs`, `templates/catalog.json`. Acceptance: a test runs the
script (compose, then the `gitignore` rename), then `npm pack --ignore-scripts --dry-run --json`, and
fails when `template/catalog.json`, `template/waymark/gitignore`, or
`template/waymark/.dev.vars.example` is missing, or when `template/waymark/gitignore` lacks the
`!.dev.vars.example` line; `npm run check:package` passes. Test: that listing test,
which T1.9 and T5.6 extend.

**T1.5 Credential storage** (90 min, `auth-data`). Outcome: the OAuth pair (two entries), the App
key, and the client secret are stored, replaced, and deleted under `setup/<run id>/` through
`tool/internal/secrets` (spec 5), with the refresh rule. Files:
`tool/internal/secrets/{setup.go,setup_test.go,keyring_e2e.go}` (the test build tag's file store,
spec 5). Acceptance, with the package vars swapped for an in-memory map: a refresh whose persist fails never returns the old pair and reports a resumable
stop; delete removes every entry the record names, including one whose `Set` reported unavailable,
and no other entry; each entry for a 2048-bit PEM and a recorded OAuth pair is at most 2,560 bytes;
under the tag the file store round-trips across two processes, and a default build does not compile
the tagged file.
Test, written first: those cases, which fail against a store that returns the old pair.

**Pair C: T1.8 and T1.9**

**T1.8 Loopback and opener** (150 min, `ordinary`, or `auth-data` on a yes to Decide 6; dispatch
with `model: opus`). Outcome: the one-tab chain server and the opener (spec 4, 7, 8, 10): routes for
`/`, `/cloudflare/callback`, `/github/manifest`, `/github/callback`, `/next`, `done.html`, and
`error.html` (from `/var/home/glw907/Projects/initiatives/cairn-setup/research/prototype/pages/`),
port 49152 held for the run, the `Host` allowlist, one state nonce per approval, the 30-minute clock,
and the opener with SSH and no-display detection and the Windows quoting (#338, #363). Files:
`tool/internal/setup/loopback/**`. Acceptance: a wrong `Host` gets 403; a callback with a stale or
wrong `state` is refused and changes nothing; a path nobody waits on gets 404; a bound port fails
with the in-use reason; `/next` answers 204 before the URL, answers once with the setup cookie, and
404s without it and after; on a fake clock the countdown starts at 25 minutes and the chain stops at
30; detection stops for `SSH_TTY` set and for Linux with no display and no `$BROWSER`, and not for
macOS with no `DISPLAY`; an opener that is missing or exits 1 reports failure; the Windows argument
for a URL holding `&` reaches the launcher whole. Test: each as a table or `httptest` case.

**T1.9 Scaffold, deploy workflow, and the answer matrix** (180 min, `runner`). Outcome: the scaffold
fetches a template tarball (verified digest, hardened extract), writes the site per spec 9, runs `git
init -b` with the default branch, and commits locally; the setup overlay gains `deploy.yml` and the
`pull_request`-only `check.yml`; a CI workflow scaffolds every answer combination that changes files
(both AI crawler answers, bare and subdomain address, a name needing a slug) from a packed engine
tarball, rewrites the engine and dev dependencies to `file:` tarballs (`create-site.yml:81-95`), and
runs `npm install`, `npm run check`, `npx cairn-manifest --check`, and `npm run build` on each. Files:
`tool/internal/setup/scaffold/**`, `scripts/build/setup-overlay/.github/workflows/{deploy,check}.yml`,
`.github/workflows/setup-matrix.yml` (paths: `tool/**`, `examples/showcase/**`, `templates/**`,
`scripts/build/**`, `src/lib/vite/**`, `package.json`). Acceptance: a digest mismatch, an entry that
escapes the target, and a link entry each fail before any file is written; a missing substitution
anchor fails naming the file; the written `package.json` pins the exact version; `--tag` picks the
dist-tag; the owner's email appears in no file under `src/content`; the workflow test asserts spec
9's `deploy.yml` properties against the secret-name constant, and actionlint passes on both
workflows; T1.2's listing test fails when `template/waymark/.github/workflows/deploy.yml` is absent;
each scaffolded site carries `deploy.yml` and `.dev.vars.example`; the matrix fails on the `invite`
case when site-facts regeneration is removed (#365). Test: unit cases for the first seven; the
matrix for the last, run once on the branch with the regeneration stubbed out and the red recorded
in the PR. Two constraints for the theme-garden initiative (its alignment request, 2026-11-08), each
with a unit case: the catalog reader decodes an entry carrying fields beyond `{id, name,
description, path}` without error, and the scaffold names each substitution's target path (spec 9's
`src/theme/site.config.yaml` and `src/theme/cairn.config.ts` among them) once, in one table in
`tool/internal/setup/scaffold/`, so a later move of those files is a one-line change.

**Pair D: T1.6 and T1.7** (on S1's recordings when they have landed, otherwise on docs-sourced
bodies; see "Stops and standing answers")

**T1.6 Cloudflare writes** (150 min, `ordinary`). Outcome: the OAuth client (authorize URL with
PKCE, exchange, refresh, revoke) and every call in spec 6's table, on the hosts spec 6 pins per
client, plus the Email Sending send on a yes to Decide 2. Files:
`tool/internal/providers/{cloudflare_oauth.go,cloudflare_write.go}` and tests. Acceptance: each route
decodes its recorded or pending body; a recorded error body (missing scope 403, name exists, zone
pending) maps to its reason; a request to a host outside its client's list is refused before
dialing. Test: one case per route on the corpus.

**T1.7 GitHub writes** (150 min, `ordinary`). Outcome: the manifest form (with `actions: read` on a
yes to Decide 3), conversion, App JWT, code exchange, installation list and delete, repository
create, installation read-back, installation token, public key and sealed secret, and the run read
on a yes to Decide 3 (spec 7), on `api.github.com` and `github.com`. Files:
`tool/internal/providers/{github_app.go,github_write.go}` and tests, `tool/go.mod`, `tool/go.sum`,
`tool/internal/render/purity_test.go`. Acceptance: each route decodes its recorded or pending body;
the read-back reports an over-grant for `repository_selection: all` and for a selected list of two,
and picks our App's installation from a list led by a foreign App with `all`; a sealed value opens
with the matching private key in the test. Test: those cases on the corpus.

**T1.10 The runner: opening and approvals** (180 min, `ordinary`, or `auth-data` on a yes to Decide
6; dispatch with `model: opus`). Outcome: the runner takes injected clients, runs the opening checks
and the four approvals (design "The flow"), emits typed events (spec 11), registers each credential
with logx as it arrives (spec 5), and enforces the chain's safety (spec 7). It defines the narrow
provider interfaces it consumes, which T1.6 and T1.7 satisfy. Files:
`tool/internal/setup/{runner,events}.go` and tests, `tool/internal/logx/{logx.go,logx_test.go}`.
Acceptance, with fake clients on the corpus: each opening check (git missing, Node below 24, the port
bound, the keyring locked, the template fetch failing, no zones, a pending zone, Workers Paid absent,
an address with records, a custom domain or route on it, a non-empty folder, a taken name) stops with
its reason and the fakes saw zero write requests; the theme question appears only with a two-entry
catalog and the account and domain questions only with several; a granted scope missing
`user-api-tokens.write` sends the tab to `error.html` and Try again re-consents; a failed
all-repositories delete stops with the four-part failure; a kill between the approval 3 callback and
its delete, inside approval 4's loop, and at the 30-minute stop each ends with no over-grant left,
and a resume's first GitHub act sweeps one; a private-name 422 reruns the Cloudflare name checks; a
taken App name follows the Decide 8 ruling; logx's mutex-guarded `Register` passes `go test -race`
with a concurrent write. Test: those cases.

**T1.12 The runner: watch, resume, sign-in, and end** (180 min, `ordinary`, or `auth-data` on a yes
to Decide 6; dispatch with `model: opus`), after T1.10. Outcome: the eight watch steps (design "The
watch plan") with intents and ids (spec 3), resume, the four-part failure, scrubbed and captured
child processes (#352), the address and Worker rechecks (spec 6), the first-deploy read per Decide 3,
the sign-in per spec 10 and Decides 1 and 2, and revoke and delete at the end (#354). Files:
`tool/internal/setup/{runner,signin,deploy}.go` and tests. Acceptance: a full run reaches done; a run
killed after each of the four approvals and after each of the eight watch steps resumes and finishes
with no approval repeated and each create called once (the fakes count); a kill between a create and
its record write resumes by adopting the empty resource, and a resource whose id differs from the
record is refused; a resume before step 5 deletes the recorded deploy key and mints one; a resume
whose stored pair answers `invalid_grant` reruns approval 1 alone; one failure per provider
(Cloudflare, GitHub, npm) stops with the four-part failure and a resumable record; the HTTPS wait
fails at 15 minutes on a fake clock and resumes at the domain step; a summary address edit is
rechecked; the sign-in batch matches the engine's `hashToken` vector and the columns in
`migrations/*.sql`, and a non-empty editor table without the email gets no token; on a yes to
Decide 2, on a fake clock, the first row read gone sends one email with an unbound second row, the
first row expiring sends one email, and `--apply` sends one at once with no redirect; after done the keyring map holds nothing for the run and the fake saw revoke,
and after a failure or Ctrl+C the entries survive and the record says so; a stub child's stdout and
stderr never reach the process's own; no credential the run holds appears in any event, log, record,
child environment, or loopback response but the one `/next` answer. Test: those cases.

**T1.11 Close** (75 min). Whole-branch `standards:diff-reviewer` loading `standards:go-conventions`,
plus `standards:web-auth-security-reviewer` over `tool/internal/secrets/**`,
`tool/internal/setup/{loopback,signin,runner}*`, and the provider OAuth files; one batched fix
chain; `tool/CHANGELOG.md` under Unreleased; ADR-0003 final; on a yes to Decide 6, the
`cairn-running-passes` map edit (held file). The admin smoke does not apply (no engine auth path
changes) and the PR says so. `npm run check:docs-gate` runs on the head and the PR records its
output. Packet through the conductor.

Path: T1.1 75 + T1.0 150 + Pair A 90 + Pair B 90 + Pair C 200 (T1.9 at 200 with the theme-garden
cases) + Pair D 150 + T1.10 180 + T1.12 180 + T1.11 75 = **1,190**.

### P2 `cairn-new-2`: the agent lane and the generated reference (`runner`)

Outcome: `cairn new` (hidden) runs the agent lane end to end from the built binary against fakes:
flags, `--plan`, `--apply`, `--dry-run --json`, NDJSON events with the waiting states, the exit
code table, `cairn new status`, and the generated setup reference with its gate. Spec 11 and 13.

**Pair: T2.1 and T2.2**

**T2.1 The end-to-end harness** (165 min, `ordinary`, dispatch with `model: opus`). Outcome: the spec
13 harness, which builds the binary with the test build tag and runs it as a child process. Files:
`tool/internal/testharness/**`, `.github/workflows/tool.yml` (the Linux e2e job). Acceptance: the harness's self-test proves the
proxy, the CA, the `BROWSER` helper, the git rewrite surviving setup's appended pairs, the keyring
file store, and the `node` and `npm` stubs each carry one request or call, refuses `CONNECT` to an
unfaked host, and fails when any is removed. Test: that self-test.

**T2.2 The command** (120 min, `ordinary`). Outcome: `cairn new` with a flag for every answer,
`--plan <file>`, `--apply <file>`, `--resume <id>`, `--tag <dist-tag>`, `--dry-run`, `--new` on a yes
to Decide 9, usage errors that name the flag, and the no-terminal agent guide; `flags.json` and the
copy tables regenerated. Files: `tool/cmd/cairn/{new.go,new_test.go,messages.go,root.go,coverage_test.go}`,
`tool/cmd/copylist/main.go` (collect `tool/internal/setup`), `tool/testdata/{flags.json,copy.golden.md}`.
Acceptance: each required field missing in a non-interactive run exits with the usage code, names its
flag, and leaves stdout empty; `TestEveryActionCoverage` names `cairn new` and its flags; `make
check-copy` passes. Test: a table of missing fields.

**T2.3 The agent view** (165 min, `ordinary`). Outcome: the NDJSON writer, the event schema in
`schema/`, the exit code table, `cairn new status`, and the e2e cases. Files:
`tool/internal/setup/agentview/**`, `schema/cairn-setup-event.schema.json`,
`tool/cmd/cairn/{new_status.go,new_e2e_test.go,coverage_test.go}`, `tool/testdata/{new/**,flags.json}`.
Acceptance: goldens for `--dry-run --json`, the event stream, and the exit codes; separate assertions
that the stream holds the waiting events in approval order with the messages table's sentences, the
eight steps in watch order, and a final `summary`; every line validates against the schema; across
`--plan` the proxy logs zero non-GET Cloudflare requests; `--apply` refuses an edited closed field, an
invalid email, and an open choice left open with usage errors that name them, and rechecks an edited
address; the harness plants known values for every credential and the sign-in token, and a grep of
stdout, stderr, `plan.json`, the store directory, and the local repo's `.git/` finds none; `status`
reports a record left at a non-terminal step by another process as unfinished. Test: those.

**Pair: T2.4 and T2.6**

**T2.4 The generated reference** (120 min, `runner`). Outcome: `make reference` writes the setup
reference (flags, derived names, steps, events, exit codes) from the code, to
`tool/docs/setup-reference.md` on a yes to Decide 5 (else `docs/admin/setup-reference.md`); a Go
test fails when the page and the code disagree; `agentsPage` gains the setup contract, shown only
when `cairn new` is not hidden. Files: `tool/cmd/reference/**`, `tool/Makefile`, the page,
`tool/cmd/cairn/messages.go`, `tool/cmd/cairn/help_agents_test.go`, `tool/testdata/copy.golden.md`. Acceptance: a one-word edit to
the page fails `make -C tool check`; `cairn help agents` holds no setup section while `cairn new` is
hidden. Test: the drift test and that help case.

**T2.6 Health for Actions deploys** (90 min, only on a yes to Decide 10). Outcome: the record notes
`deploys: actions` and the deploy check reads the Worker's latest deployment for such a site. Files:
`tool/internal/health/check_deploy.go` and tests, `tool/internal/record/setup.go`, the runner's
record write. Acceptance: a recorded Actions-deployed site reads OK with a deployment and Failing
without one, and a Builds site keeps today's result. Test: those.

**T2.5 Close** (60 min). Whole-branch review with the runner checklist; `tool/CHANGELOG.md`;
`npm run check:docs-gate` on the head, its output recorded in the PR; packet.

Path: Pair 165 + T2.3 165 + Pair 120 + T2.5 60 = **510**.

### P3 `cairn-new-3`: the terminal view (`ordinary`)

Outcome: `cairn new` in a terminal runs the design's flow inline, at the copy deck's words and the
layout grid's columns, with golden frames at 80 and 60 columns and a real-terminal screenshot read
of every screen. The prototype (`/var/home/glw907/Projects/initiatives/cairn-setup/research/prototype/`)
is the reference implementation of each screen and of the three Huh workarounds, and the tiebreaker
where the grid and the deck disagree (wraps at 18 against values at 20; unnumbered terminal lists).

**T3.1 ADR-0004 and the frame harness** (90 min). Outcome: ADR-0004 records the Bubble Tea v2, Huh
v2, Bubbles v2, Fang v2, and teatest v2 requires (the ADR-0002 shape) the one-model component
architecture ADR-0001 deferred, and the view's writer (spec 5); a teatest v2 harness replays fixture event streams into a minimal
model. Files: `tool/docs/adr/0004-terminal-view.md`, `tool/go.mod`, `tool/go.sum` (Bubble Tea and
teatest only), `tool/internal/render/purity_test.go`, `tool/internal/ui/newview/{model.go,harness_test.go}`.
Acceptance: the harness replays a fixture stream and its frame golden passes, and fails when the
replay drops an event. Test: that golden.

**Pair: T3.2 and T3.8**

**T3.2 Theme and grid** (135 min). Outcome: the Warm Stone `huh.Theme`, palette slots, the grid
helpers (columns 2, 4, 20 and 18 for wraps, one blank line between blocks, balanced wrap to the
window minus 4 capped at 76), key-hint footers through bubbles `help`, and the too-small screen.
Files: `tool/internal/ui/newview/{theme,grid,footer,toosmall}.go` and tests, `tool/go.mod`,
`tool/go.sum`, `purity_test.go` (Huh and Bubbles). Acceptance: a positional test fails when a value
lands off column 20 or a paragraph ends on one lone word; too-small goldens at 49 columns and at the
tallest step's rows minus one name both sizes. Test: those.

**T3.8 Failure and gap copy** (60 min). Outcome: the four-part messages-table entry for every runner
failure reason, the generic first-deploy failure, the Decide 1, 2, 3, and 8 lines, the in-use port
line, and the slug error for a name with no Latin letters, passed through the register editor; each
opening failure's entry carries its `before-you-start.md` anchor as a field. Files: the messages
table under `tool/internal/setup/`, its test, `tool/testdata/copy.golden.md`.
Acceptance: a Go test fails when a reason has no entry or an entry has an empty part; the register
editor's findings are closed in the PR. Test: that test.

**Pair: T3.3 and T3.5**

**T3.3 Screens, part 1** (180 min). Outcome: welcome, the SSH stop, the questions with the live
repository preview, browser-start, the in-progress browser screen with the opener-failure line, the
countdown, the prerequisite failure, the resume choice, and the account and domain choices. Files:
`tool/internal/ui/newview/{welcome,questions,browser,prereq,choose,catalogue}.go`, goldens,
`tool/cmd/copylist/main.go` (collect `newview` through a `Catalogue()` like `health`'s),
`tool/testdata/copy.golden.md`; no module file.
Acceptance: goldens at 80 and 60 columns in both themes; the theme question only with a two-entry
catalog; the domain screen at 60x24 with five zones. Test: the goldens.

**T3.5 Fang for the whole tool** (105 min). Outcome: Fang v2 themes Cobra help and errors in Warm
Stone for every command. Files: `tool/cmd/cairn/{root.go,main.go}`, help tests, `tool/cmd/mangen`,
`tool/go.mod`, `tool/go.sum`, `purity_test.go` (Fang). Acceptance: `help_contract_test.go` and the
man-page build pass; `NO_COLOR` output carries no escape. Test: the existing help contract plus a
`NO_COLOR` case.

**T3.4 Screens, part 2** (150 min). Outcome: the summary with the email and address edits and the
address recheck, the watch (eight steps, elapsed time, `tea.View.ProgressBar`, a window title per
phase), the four-part failure, done, and the Ctrl+C lines, per Decides 1, 2, 3, and 7. Files:
`tool/internal/ui/newview/{summary,watch,failure,done,stop}.go`, goldens, `tool/testdata/copy.golden.md`. Acceptance: goldens at 80
and 60 columns in both themes. Test: the goldens.

**T3.6 Wiring and the screenshot read** (150 min). Outcome: `cairn new` with a terminal runs the view
inline (no alternate screen); `standards:tui-visual-verify` captures every screen at 80 and 60
columns in both themes through the replayer, a fresh-context grader classifies each, and STRUCTURAL
findings are fixed. Files: `tool/cmd/cairn/new.go`, `tool/internal/ui/newview/**`. Acceptance: the
grader's verdict has no open STRUCTURAL finding; the main loop has read the decisive captures; a grep
of every teatest frame's bytes for the planted credentials finds none. Test: the captures' manifest
beside the goldens and the frame grep.

**T3.7 Close** (60 min). Whole-branch review with `go-conventions`, which reads the copy golden's
diff against the copy deck's binding sections; BACKLOG #362 closes with the captures' manifest, which
P6's packet links for Geoff; merges itself.

Path: T3.1 90 + Pair 135 + Pair 180 + T3.4 150 + T3.6 150 + T3.7 60 = **765**.

### P4 `cairn-new-4`: starter content (`ordinary`), beside P3

Outcome: the template carries the design's starter set instead of the trail demo; the showcase keeps
its fixtures; a test keeps the demo from reaching the template.

**T4.1 The content overlay** (75 min). Outcome: the emit takes `src/content/**` and its assets from a
starter overlay instead of the showcase. Files: `scripts/build/emit-template*.mjs`, the overlay
directory, `examples/showcase/.cairn-template.json`, `templates/waymark/src/content/**` (emitted).
Acceptance: a test fails when any showcase post, `the-trail-crew.md`, or the trail fragment appears
in `templates/waymark/`, and when any starter page links an external image host. Test: that test.

**T4.2 The starter pages** (165 min). Outcome: home and archive page one, About, an author page,
Contact with a placeholder address, five or six one-task how-to posts, one post showing every element
on the model of Astro's markdown style guide, each directive once, one image shipped with the site,
and one video (design "Starter content"), in the house register, passed through `register-check`.
Files: the overlay's content and assets. Acceptance: a test lists the expected starter routes and
fails on a missing one or a non-200 prerender in the showcase build of the template; a test fails
unless each directive in the engine's directive list appears exactly once; `register-check`'s
findings are closed in the PR. Test: those and the T4.1 test.

**T4.4 Repoints and close** (60 min). Outcome: the theme-check references that named
`/posts/the-reading-surface` and `/styleguide` point at the new every-element post (#379); review;
merges itself. Files: `skills/cairn-styling-public-pages/references/checking-a-theme.md`,
`examples/showcase/src/chassis/README.md`. Acceptance: `git grep -nE 'the-reading-surface|/styleguide'
--` on both files prints nothing.

Path: 75 + 165 + 60 = **300**.

### P5 `cairn-new-5`: the docs and the Claude Code tooling (`runner`)

Outcome: the setup pages rebuilt from their briefs for `cairn new`, the four new pages, the cairn
plugin with `cairn-setting-up-a-site` and its marketplace, the site's Claude Code settings, the agent
page embedded in the binary, and the README and npm readme sections (design "Docs", "Claude Code
tooling"). Every page passes the docs gate, a fresh `docs-fact-checker`, and the register editor.
The pages describe `npm create cairn-site` as the launcher P6 builds: the fact-checker's finding on
those lines is the one declared deferral, listed in the PR, and P5 merges immediately before P6 on a
yes to Decide 5.

**T5.1 Premise, outlines, and transcripts** (75 min). The `cairn-writing-docs` C steps for each page:
before you start, create your site, credentials, setup recovery, own your domain, troubleshooting,
and the new set up with an agent, deploys, and suggested plugins pages; every other page that names
the wizard (`git grep -l create-cairn-site -- docs README.md`). The commands the pages quote are
captured from the built binary through the P2 harness into the transcript corpus
(`scripts/checks/transcript-blocks.mjs`), the recorded runs `docs-register.md:477-478` asks for.
Files: the outlines in the PR, the new transcripts. Acceptance: `node scripts/checks/transcript-blocks.mjs`
passes.

**Pair: T5.2 and T5.3**

**T5.2 Pages A** (165 min): before you start (a heading for each anchor T3.8's messages table
carries), create your site, own your domain (with #375's records sentence and the DMARC caution);
a Go test, `tool/internal/setup/anchors_test.go`, resolves every messages-table anchor against
`docs/admin/before-you-start.md`'s headings, and the page joins `tool.yml`'s paths. Files:
`docs/admin/{before-you-start,create-your-site,own-your-domain}.md`, the test,
`.github/workflows/tool.yml`. Each page task links only pages that exist at its commit and declares
the transcripts its own pages stop quoting. **T5.3 Pages B** (150 min):
setup recovery, troubleshooting, credentials (what setup holds, when it deletes it, what a stopped
run keeps, and Decide 9's removal steps), and the inbound edits in `invite-editors.md`,
`is-it-working.md` (per Decide 10), `rotate-the-github-app-key.md`, `docs/admin/README.md`, and
`docs/why-cairn.md`. Files: those pages and the transcript declarations. Acceptance for both: `npm
run check:docs-gate` passes; `docs-fact-checker` returns no open finding but the declared deferral;
`git grep -nE 'create-cairn-site --|cairn-build|Workers Builds connect|chapter [0-9]' -- docs`
prints only the deploys page's move-to-Builds section; the anchors test passes. Test: the
docs gate and the anchors test.

**Pair: T5.4 and T5.6**

**T5.4 New pages** (150 min): set up with an agent, deploys (the Actions limit and the move to
Workers Builds by hand), suggested plugins; on a yes to Decide 5, `make reference` moves its output
to `docs/admin/setup-reference.md` (`tool/Makefile`, `tool/cmd/reference/**`), and the page joins
`tool.yml`'s paths and `gate-table.json`'s `toolInputs`; T5.4 owns these pages' `docs/admin/README.md`
entries and every inbound link to them. Files:
`docs/admin/{set-up-with-an-agent,deploys,suggested-plugins,setup-reference,README}.md`, the inbound
pages, `.github/workflows/tool.yml`, `scripts/checks/gate-table.json`. Acceptance as T5.2.

**T5.6 The plugin and the site's settings** (135 min, held files). Outcome:
`.claude-plugin/marketplace.json` named `cairn`, `plugins/cairn/.claude-plugin/plugin.json`, and
`plugins/cairn/skills/cairn-setting-up-a-site/SKILL.md`, thin, deferring to `cairn help agents` and
ending on `cairn-extending-a-site`; the source is an npm package entry if Claude Code's plugin docs
allow one, else `git-subdir`. The setup overlay's `.claude/settings.json` declares the vendor
marketplaces and plugins (Svelte from `sveltejs/ai-tools`, Cloudflare from `cloudflare/skills`,
daisyUI from `saadeghi/daisyui`), and `.mcp.json` adds the Svelte MCP server. Files: those, and the
T1.2 listing test. Acceptance: `claude plugin validate <path>` passes on both manifests; a test
extracts every `--flag` in `SKILL.md` and fails on one absent from `tool/testdata/flags.json`; a test
asserts exactly the three marketplaces, their three plugins, and the Svelte server; T1.2's listing
test fails when `template/waymark/.claude/settings.json` or `template/waymark/.mcp.json` is absent.
Test: those.

**Pair: T5.5 and T5.7**

**T5.5 The embedded agent page** (60 min, `tool/**`). Outcome: `make agent-guide` copies the agent
page into the tool for `go:embed`, and a test fails on drift; the page joins `tool.yml`'s paths and
`gate-table.json`'s `toolInputs`. Files: `tool/Makefile`, the embed file and test,
`.github/workflows/tool.yml`, `scripts/checks/gate-table.json`. Acceptance: a one-word edit to the
page fails `make -C tool check`. **T5.7 The entry points** (60 min, held files): the README and the
npm readme open with "Setting up with an agent"; `claude/CLAUDE.md` gains the plugin section; the
`cairn-writing-docs` admin-track brief's arrival state names `cairn new` (`docs-register.md:479-481`).
Acceptance: a test fails unless the first H2 of both readmes is "Setting up with an agent".

**T5.8 Close** (90 min). Whole-branch review; `npm run check:docs-gate` rerun after the last docs
edit; `CHANGELOG.md` under Unreleased; packet. On a yes to Decide 5, the conductor holds the approved
PR and merges it immediately before P6's.

Path: T5.1 75 + Pair 165 + Pair 150 + Pair 60 + T5.8 90 = **540**.

### P6 `cairn-new-6`: the switch (`auth-data`, `runner`)

Outcome: `npm create cairn-site` installs the prebuilt binary through platform packages (the esbuild
optional-dependencies pattern) and runs `cairn new`; the tool's release builds and publishes those
packages and the launcher; the JavaScript wizard is gone, its checks are decoupled, and `cairn new`
is shown.

**T6.1 The launcher and platform packages** (195 min, test first). Outcome: `bin.mjs` resolves the
installed platform package, execs the binary with inherited stdio, and on a missing one says how to
install it; the six platform package manifests are generated at pack time. Files:
`packages/create-cairn-site/{bin.mjs,package.json,README.md}`, `scripts/release/pack-platforms.mjs`,
`packages/create-cairn-site/test/launcher.test.mjs`. Acceptance: the test, committed first and red
against the wizard, packs the launcher and the host's platform package, installs both into a temp
directory, and runs `node_modules/.bin/create-cairn-site` with no terminal (expecting the agent
guide) and with `--dry-run --json` and flags (expecting the plan's names); a case with the platform
package absent expects the install message; a test fails when a platform manifest's `os` and `cpu`
do not match its binary's header.

**Pair: T6.3 and T6.4**

**T6.3 The release pipeline** (180 min, `runner`). Outcome: `tool.yml`'s release job packs and
publishes the six platform packages and the launcher with OIDC provenance at the tool's version;
`publish.yml` drops `create-cairn-site` from the engine's version lockstep; `scripts/release/*` and
the `cairn-releasing` skill (held file) say so. Files: `.github/workflows/{tool,publish}.yml`,
`scripts/release/**`, `.claude/skills/cairn-releasing/SKILL.md`. T6.3 owns every `tool.yml` and `publish.yml` edit in P6, including removing
`create-cairn-site`'s bake and pack at `publish.yml:125-130`. Acceptance: actionlint passes, a
`npm publish --dry-run` of each packed package succeeds, and `git grep -n 'bake-template' --
.github/workflows` hits no `packages/create-cairn-site` path; `node scripts/release/preflight.mjs` and the
other release commands still run. Test: actionlint plus the release scripts' existing tests.

**T6.4 The wizard retired** (210 min, `auth-data`). Outcome and files:
- removed: `packages/create-cairn-site/src/**`, `packages/create-cairn-site/test/**` except T6.1's
  `launcher.test.mjs` (the moved hygiene test is already under `tool/testdata/fixtures/`), `.github/workflows/create-site.yml`;
- moved: `packages/create-cairn-site/src/site-config-path.json` to `scripts/build/site-config-path.json`,
  repointing `src/tests/unit/site-config-path.test.ts:27`, `scripts/build/emit-tool-conditions.mjs:19`,
  `scripts/checks/check-tool-conditions.mjs`, `.github/workflows/tool-conditions.yml:13,22`, and the
  comments in `src/lib/content/compose.ts:18` and `tool/internal/doctor/siteconfigpath.go`; the
  transcript corpus to `tool/testdata/transcripts/`, repointing `scripts/checks/transcript-blocks.mjs:34`;
  `packages/create-cairn-site/scripts/{bake-template,emit-template-dir}.mjs` with their tests and
  `template-repo/` to `scripts/build/`, repointing `.github/workflows/test.yml:85-89`, root
  `package.json` (`check:template`), and `scripts/build/pack-engine-template.mjs`;
- decoupled: `scripts/checks/{check-symbols,check-leaks,check-dev-package}.mjs` (`check:symbols`
  reads `cairn new`'s flags from `flags.json`), `scripts/checks/gate-table.json`,
  `src/tests/unit/gate-tier.test.ts`,
  `tool/internal/spine/{step_test,park_test}.go`, and the comment sites under
  `tool/internal/{adopt,health,providers,record,spine}`;
- held: the `cairn-running-passes` setup command and `.claude/agents/cairn-implementer.md` drop the
  prepack;
- `tool/cmd/cairn/new.go` loses `Hidden`.
Acceptance: `npm run check:close`, `make -C tool check`, `npm test -w packages/create-cairn-site`
(T6.1's launcher test), and the unit suite including `src/tests/unit/gate-main.test.ts` pass, and `git grep -n
'packages/create-cairn-site/\(src\|scripts\|template-repo\|test\)' -- . ':!*CHANGELOG.md'
':!MIGRATION-NOTES.md' ':!BACKLOG.md' ':!ROADMAP.md' ':!scripts/gate/'` prints nothing
(`scripts/gate/` goes to the tooling brainstorm's backlog item). Test, written first: a test that
fails while `packages/create-cairn-site/src/github` exists, while the launcher's packed file list
holds anything but `bin.mjs`, `package.json`, and `README.md`, or while no hygiene test reads
`tool/testdata/fixtures/`.

**T6.5 Close** (75 min). Whole-branch review with `web-auth-security-reviewer` on the deletions and
the runner checklist; `MIGRATION-NOTES.md` (the wizard retires, `cairn new` replaces it, and wizard
records keep their plaintext App secrets on disk until removed by hand) and `CHANGELOG.md`; ROADMAP's
setup lines rewritten for `cairn new`; STATUS states that the release gate waits on the tooling
brainstorm; the packet links P3's captures manifest; packet.

Path: T6.1 195 + Pair 210 + T6.5 75 = **480**.

### P7 `cairn-pub-docs-md`: markdown copies (`ordinary`, cairn-pub, `site-pass`)

**Dropped (Geoff, 2026-11-08, after launch):** cairn.pub will be rebuilt from scratch, so this run
does nothing with it. The conductor never relaunches P7, and its session (`ef6730ba`) was stopped
before it pushed anything. No cairn-cms pass ships a cairn.pub link, so P1 to P6 are unchanged.
The markdown copies, the `/start`, `/docs`, and `/deploys` short links, and the engine pin belong
to that rebuild. Decide 4's ruling is superseded.

**T7.1 Tests first** (60 min): prerender tests that every docs page has a `.md` copy whose first line
names the engine version, and that `/start` and `/docs` reach their pages. **T7.2 The copies** (90
min): a prerendered `+server.ts` per docs route serving the source as `text/markdown`. **T7.3 The
short links** (30 min, pair with T7.2): `/start` and `/docs`; `/deploys` lands with the release's pin
bump. **T7.4 The loader port** (180 min, only on a yes to Decide 4): the loader, navigation, and
routes read the `admin` and `editors` arms, and the pin moves to `0.99.0-rc.4` in the same PR through
`standards:dependency-upgrade`, tested against it and, as an extra test, a packed tarball of cairn-cms `main` (the `link:consumer`
gotcha in `durable-gotchas.md`). **T7.5 Close** (45 min): the full-page render read of each touched
page; merges itself.

Path: 60 + 90 + 45 = **195**; with T7.4, **375**.

## The design's estimate

The design carried no estimate, so the planner set one from recent scores; it is a planner-set
number for Geoff to approve in the pre-launch packet, not a design figure. Actual against planned
path, from the merged PRs' score sections: #193 setup-fix 210 of 665 (0.32), #188 cleanup pass 8
246 of 839 (0.29), #186 p2-p4 235 of 580 (0.41), #185 tool fixes 72 of 105 (0.69), #195 release gate
A about 480 of 900 (0.53; "about one working day"). **Factor: 0.41**, the median.

Sized top-down from those actuals: P1 like #195 (about 480 actual), P2 like #186 (235), P3 about 300,
P5 like #188 (246), P6 about 250, for about 1,511 actual minutes on the chain. Divided by 0.41, the
estimate is **3,685 path minutes**. After the review fold and its verification read the plan's
chain is 3,465, 0.94 of it, under the twice-estimate line (7,370). Expected actual on the chain:
about 1,420 minutes.

## Stops and standing answers

These are proposed for Geoff's approval in the pre-launch packet; once approved, each is applied in
place of stopping.

| Stop | Standing answer |
| --- | --- |
| Clock stop: a task past twice its estimate | When the cause is traced and the rest is in scope, reset `start=` once with `estimate=` the remaining work, and record it in `## Decisions`. On a second stop on the same task, the conductor decides in place of asking: it splits the remaining work into a follow-up task in the same pass, or replaces the unit the fixes keep missing (`pass-core` step 1), and records the call in `## Decisions`. It asks only for a cause it cannot trace. |
| Pass path ceiling: a pass past twice its plan path | Go on while the cause is traced and the initiative's actual critical-chain minutes stay under 2,840 (twice the expected actual of 1,420; the 7,370 plan-minute line is the same bound in plan units, since actuals run near 0.41 of plan); record the overrun in the PR's score. Past 2,840 actual minutes, or on a cause the session cannot trace, stop: the conductor asks with the trace and a recommendation. |
| A merge gate in Decide 11 fails | The pass does not merge; fix forward and rerun the gate. A finding that would change the design, or an `escalate` verdict, stops: the conductor asks. |
| Auto mode refuses the conductor's merge | Write STATUS, `notify-send -u normal`, and give Geoff the exact `gh pr merge` line with its `--match-head-commit` to paste as a `! ` command. Meanwhile the next pass stacks on the gated head, the way Decide 5 stacks P6 on P5, and rebases once the merge lands. |
| A P6 gate fails after P5 merged | Acceptable: `main` carries P5's docs while `cairn new` stays hidden, and no release is cut before the tooling gates exist. Fix forward on P6. |
| S1 recordings land after Pair D started | A separate import PR, classed `auth-data` (the bodies feed T1.10 and T1.12) with the `web-auth-security-reviewer` read, cut from `main` once P1 has merged (or folded into P1 if P1 is still open): copy the staged corpus in, run the hygiene test, rerun T1.6, T1.7, and T1.10's tests against the recordings, fix any body the docs got wrong, and list each fix in the PR. It merges under Decide 11's gates. |
| S1 has not run by P6's close | P6's record packet and STATUS list every route still marked "pending live recording", and the release's real-account leg records them before any cut. |
| A red on the fast lane or CI | Fix forward or revert the commit. A known trap (`durable-gotchas.md`) reruns once. A skipped failing-first test with its `// WATCH:` is not a red. A red traced to executor reasoning moves the next task to `high`. |
| A route S1 could not record, or spec 12's unrecordable list | A docs-sourced body with `provenance.note: "pending live recording"`, listed in the PR; the release's real-account leg records it. |
| S1 not yet run when Pair D is next | Pair D builds on docs-sourced bodies with `provenance.note: "pending live recording"`; the import task above swaps in the recordings when they land. |
| S1 crashed mid-run | Geoff runs `record.sh --cleanup <run id>` in the same sitting; the conductor checks the results file's cleanup lines before the executor imports anything. |
| Probe S1: revoke refused | Delete the keyring entries; record #354 as partly done in the PR. |
| Probe S1: subscriptions unreadable | Workers Paid is not checked in the opening; Decide 3's ruling gives the first-deploy signal. |
| A scope answers 403 in S1 | Add the narrowest scope the catalogue lists for that call (spec 6), within the registered set. |
| A subdomain depth Cloudflare cannot serve | Refuse it on the summary with the address error pattern. |
| teatest v2 does not build against the pinned Bubble Tea | Golden the `View()` output through `x/exp/golden` and record why in ADR-0004. |
| Claude Code docs allow no npm plugin source | `git-subdir` in the cairn-cms repo. |
| A review round finds a blocker after the fix chain | One more review on that blocker only. |
| A found item outside the task | `standards:log-issue`, tagged `#initiative:cairn-setup`, and listed in the PR. |

**Judgment calls the run can plausibly meet, with answers:** package names under `tool/internal/`
(spec 1 holds; a rename is recorded); exit-code numbers and event field names (choose, document in
the reference, keep the usage-error contract); one suffix across the four names (spec 3); new step
constants' names and whether they join `spine` (spec 4); the every-element post's breadth (every
CommonMark and GFM construct, each directive once); whether the reference generator is a Go command
or a test helper (a command, `make reference`); a Huh limit the prototype did not meet (work around
it in the view, never patch Huh).

**Items the run may escalate without breaking its outcome** (after a structural fix fails, per
`pass-core` step 1): Fang theming (T3.5; plain Cobra help stays); the countdown's look and the
`ProgressBar` and window-title levers (T3.4); the Workers Paid opening probe; the npm plugin source;
the markdown copies' version line format; the every-element post's breadth; the Windows opener's
quoting where CI cannot reproduce it. **Not escalable**, since each is the outcome: the approval
chain and its over-grant deletion on every exit, credential storage and the never-printed list,
resume after each approval and each watch step, the answer matrix, the four-part failure, the
docs gate, and the hidden-until-P6 rule.

## Backlog verdicts (scoped sweep, cairn-cms `BACKLOG.md` at `d27ea60b0`)

Approving this plan approves these edits; pre-flight item 5 lands them.

| Item | Verdict | Where, or why |
| --- | --- | --- |
| #360 agent can plan setup | fold | P2 (flags, `--plan`, `--dry-run --json`, events, reference) and P5 (plugin, docs); its llms.txt part drops (design: no llms.txt) |
| #361 theme choice | reword | to the theme catalog's remainder: a packaging path for a reusable theme, and the theme-cookie regex generated from `theme-names.ts` |
| #362 wizard design session | fold | P3; the approved design and prototype were the session |
| #363 no-browser path | fold | P1 T1.8 (opener failure, SSH stop), P3 (the screen) |
| #364 the App's browser steps | fold | P1 T1.8, T1.10 (the one-tab chain) |
| #365 stale site-facts | fold | P1 T1.9 (regeneration and the answer matrix) |
| #366 setup test suite | reword | to its part (d), one live leg per candidate, for the tooling brainstorm |
| #367 deploy lockout | fold | P1 T1.4, T1.12 (intents and ids, no list or clock) |
| #381 resume marker by resource | duplicate | of #367 |
| #375 domain and Builds in one run | fold | P5 T5.2 (Builds half gone; records half kept) |
| #379 theme checks' missing styleguide | fold | P4 T4.4 |
| #352 strip token variables from children | fold | P1 T1.12 |
| #354 revoke the setup token | fold | P1 T1.6, T1.12 |
| #338 Windows opener splits at `&` | fold | P1 T1.8 |
| #246 admin permission on the App key | fold | P1 (approvals 3 and 4; the tradeoff documented in P5) |
| #302 `wrangler types --check` | reword | to: add the precheck once `cairn new` regenerates types after writing `wrangler.jsonc` |
| #333 @types/node 26 | reword | the trigger becomes the Actions deploy's Node pin, not Workers Builds' default |
| #382 DKIM selectors in the probe | drop | setup no longer copies DNS records; the case for it (self-hosted mail) is answered by setup never touching records it did not create |
| #350, #351, #353 build token and registration | drop | no Workers Builds, no `cairn-build` registration |
| #339, #340 chapter 3 watch and reconcile | drop | chapter 3 is gone |
| #204 token in the state file | drop | the Go store writes atomically (`tool/internal/store/store.go:213`) and tokens live in the keyring |
| #185 re-capture the setup transcript | drop | the fixtures retire with the wizard; the goldens replace them |
| #376, #377, #378, #380, #368 to #374, #336, #349, #355 to #357, #245, #304, #324, #358, #168 | keep | outside this design; `*(swept 2026-11-08)*` |

New items to file (`#initiative:cairn-setup`): an admin view of a failed deploy (the design);
`cairn health`'s deploy check for Actions-deployed sites (`tool/internal/health/check_deploy.go:189-193`),
closed by T2.6 on a yes to Decide 10; the release gate's legs (`scripts/gate/`) need rebuilding for
`cairn new` (handed to the tooling brainstorm); and the S1 pending routes for the real-account leg to
record. The full sweep is technically due (73 open items carry no stamp), but the 2026-11-03 full
sweep's triage still waits on Geoff (`docs/STATUS.md`, "Open decisions"), so none runs now.

## ROADMAP additions

- Content migration: "Migrate content from another site or CMS into a new cairn site" under Later,
  as a possible feature with its own design (design "Non-goals").
- GitHub organizations: "Setup for a GitHub organization (the manifest's org path and an owner's
  approval)" under Later (design "Non-goals").
- P6 rewrites the `create-cairn-site` narrative the sweep found (`ROADMAP.md:74-110, 273-275, 425-436,
  589-595, 640-641, 1066-1070`). The `secrets`-block entry (`ROADMAP.md:1185-1198`) stays open and
  names `cairn new`: the template keeps no `secrets` block, so the first Actions deploy succeeds
  before setup stores the App key.

## Before the first release (not part of these passes)

- **[you]** Make the OAuth client public: a name, a logo, the client URL (cairn.pub), and the DNS TXT
  verification on a zone you own. Permanent, so it waits until the stable is ready.
- **[you]** Publish each new platform package once by hand and register its trusted publisher, as
  `create-cairn-site` needed (`publish.yml:292-294`; `cairn-releasing`).
- Before the release that first shows `cairn new` prints an anchor, `scripts/checks/check-readiness.mjs`
  learns a second page (it accepts only `is-it-working.md`, `:27,146-166`) in a `runner` change, and
  the messages table's `before-you-start` anchors join `scripts/checks/shipped-anchors.json`.
- An engine release carrying `template/` is `latest` before the tool release that shows `cairn new`,
  since today's `latest` (`0.98.0`) has no `template/` and the fetch would fail.
- The tooling brainstorm's gates exist and pass (design "If you approve" 4), recording the pending
  routes.
- The cairn.pub rebuild serves the current docs (P7 was dropped; see its section).
