# Mechanics and feasibility review: setup-tooling plan (initiatives `4618991`)

**Target:** `/var/home/glw907/Projects/initiatives/cairn-setup/plans/2026-11-09-setup-tooling-plan.md`, with its prompts, `setup-tooling-owner-steps.sh` and `add-setup-tooling-grant.py`.

I checked every claim against cairn-cms `main` (`5456b257e`; the plan's base `f7e5e1ff5` is stale, see M17), the workstation repo, the Claude Code and Cloudflare docs, and live probes.

**What holds up:**
- **Arithmetic:** all three chain sums (485, 800, 1,070), the 1,870 total, the 1,950 estimate, the 1,035 expected actual, and the 2,070 and 3,900 lines.
- **Pairs:** T1.1/T1.5, T2.1/T2.3, T2.2/T2.4 and T2.5/T2.6 share no files.
- **Cited lines:** every file:line in "Calls settled here" and "Backlog verdicts" points at the code it describes.
- **Merge:** the pre-flight 5 merge is clean (`git merge-tree`).

The findings below are ranked by consequence.

---

## Blocker

**1. `correctness` — The `excludedCommands` entries as written are exact matches, so `cairn new` stays sandboxed.**
- **Where:** plan:178-181, plan:74-75 (item 7), plan:354 (T1.1), `add-setup-tooling-grant.py:40-41`, plan:565-567 (T2.7 skill line).
- **Docs (https://code.claude.com/docs/en/sandboxing):**
  - "a pattern with no wildcard is an exact match. `docker` matches only `docker` with no arguments. `docker *` matches `docker` with or without arguments."
  - "Every command in the call has to match … a redirect to a file, a `cd`, or a command substitution such as `$(...)` keeps the whole call sandboxed."
- **Consequences:**
  - The five bare entries (`cairn`, `npm create cairn-site`, and the rest) leave `cairn new --plan …` sandboxed. Its localhost is then private, and the `BROWSER` relay can't write `urls.log` outside the working folder, so every run fails.
  - T2.7's skill wording "or with its events to a file" means a shell redirect, since `cairn new` has no events-file flag. A redirect keeps the call sandboxed.
  - A naive agent's usual `cd site && cairn new` is also sandboxed.
  - T1.6's probe can't catch any of this: `cairn` isn't installed in part one, and its only canary is a compound command, which stays sandboxed anyway. It surfaces at T3.2 as a guaranteed S-1 packet.
  - The grant text names the five bare words, so a `cairn *` fix may be refused as outside the line.
- **Fold:**
  - Write the entries as `cairn *`, `npx create-cairn-site*`, `npm create cairn-site*`, `npm init cairn-site*` and `create-cairn-site*`, in the plan, item 7's probe file and the grant script.
  - The skill and agent-page line becomes: run `cairn` as one bare command, with no `cd`, redirect, pipe or `$(...)`, and use the Bash tool's `run_in_background` for its events.
  - Add probe items for `cd x && cairn --version`, `cairn --version > f`, and a backgrounded `cairn` call. The docs don't say how a background call is matched.

## Major

**2. `correctness` — T3.2 cannot pass: an excluded `cairn` command prompts, and the probe answers every prompt "No".**
- **Where:** T1.3 (plan:397-398, 410-411), T3.2 (plan:600-607), template allow list (prototype `cleanroom-settings.json:6-66`).
- **Docs:** "An excluded command goes through the regular permission flow: … commands your allow rules cover run without a prompt."
- The template allows `npm *` and `npx *` but not `cairn`. T3.2's `cairn new --plan` therefore prompts, the probe answers No, and the probe fails. Adding `Bash(cairn *)` is arguably outside the grant's "everyday shell tools" wording.
- Sandboxed Bash never prompts (`autoAllowBashIfSandboxed` defaults to true). So `defaultMode: default` only shows prompts for excluded commands and non-Bash tools; the friction tally should say so.
- **Fold:**
  - Put `Bash(cairn *)` in the template's allow list in T1.1, and name it in the cleanroom-config grant line.
  - Or have the probe answer "Yes" (never "always") to a prompt whose command is in its own command file, and "No" to anything else.

**3. `correctness` — The private keyring as settled fails go-keyring's write. Probed.**
- **Where:** plan:185-189.
- Under `env -i` + Homebrew `dbus-run-session` + `printf "" | gnome-keyring-daemon --unlock --components=secrets`, the only collection is `session` and the default alias reads `/`.
- I built a probe against `zalando/go-keyring` v0.2.8 from the module cache. Its `Set` returned `failed to unlock correct collection '/org/freedesktop/secrets/aliases/default'`.
- With the password `x`, a `login` collection is created, and Set and Get succeed. `GetLoginCollection` falls back to the alias (`secret_service.go:97-101`).
- **Also:**
  - Homebrew's bus socket lands in `/tmp`, which the template denies for sandboxed commands.
  - `secret-tool lookup` is refused by the workstation's `claude-block-pass` hook in every Geoff session. I hit this myself, so an executor can't diagnose with it.
- **Fold:**
  - `init` generates a random non-empty keyring password per home, kept in a 0700 file outside the run directory.
  - T1.2's acceptance adds a keyring write and read through a go-keyring-shaped client (a tiny Go or gdbus check), not `secret-tool`.

**4. `correctness` — Deleting `legs.mjs` breaks two files the plan says to keep unchanged.**
- **Where:** T2.3 (plan:497-499); pass 2 prompt line 11 says "Keep `publishViaAdmin`, `gate-publish.spec.ts`…".
- `examples/showcase/e2e/gate-publish.spec.ts:7` and `src/tests/unit/gate-browser.test.ts:28` import `PUBLISHED_ALERT` from `scripts/gate/legs.mjs`.
- `scripts/checks/gate-table.json:260` maps `browser.mjs` to that spec, so T2.4's edit also runs it.
- `requireAdmin` (`browser.mjs:307`) isn't exported, though T2.4 relies on it.
- **Fold:** move `PUBLISHED_ALERT` into `browser.mjs` or `mail.mjs`; add both importers to T2.3's file list; export `requireAdmin` in T2.4.

**5. `correctness` — T2.1, T2.2 and T2.7 miss generated and pinned files, and one task hand-edits a generated page.**
- **T2.1:**
  - `schema/cairn-setup-event.schema.json` has `additionalProperties: false`, so a `credential` field on the done event fails `new_e2e_test.go`.
  - `tool/testdata/new/events.*.ndjson` and `tool/internal/setup/testdata/plan.golden.json` name `approve-cloudflare`.
  - The new refusal copy lives in `tool/testdata/copy.golden.md` (`make -C tool copy-list`).
  - `tool/cmd/reference/main.go` must change so `cairn help agents` and the reference list the variable.
- **T2.2:**
  - The Workers Paid copy is pinned at `copy.golden.md:548,593,601`, and the #403 copy at line 675.
  - The `--tag` default is pinned in `docs/admin/setup-reference.md:27`.
  - `BACKLOG.md` isn't in its file list, though it moves items to Done. T2.3 never closes #409.
- **T2.7:**
  - `docs/admin/setup-reference.md` says "generated from the code by `make reference`. Do not edit it by hand."
  - `tool/cmd/cairn/set-up-with-an-agent.md` is an embedded copy held identical by `agent_page_test.go:16` (`make -C tool agent-guide`), and `scripts/checks/transcript-blocks.mjs:46` pins its blocks.
  - The tool's changes (token option, tag default, Workers Paid sentence) belong in `tool/CHANGELOG.md`, which has its own `## Unreleased`, not only the root `CHANGELOG.md`.
- **Fold:** add each file to its task; T2.1 and T2.2 run `make -C tool copy-list reference agent-guide`; T2.7 edits only the source page and regenerates.

**6. `correctness` — The grader's and conductor's `cairn new status` read always fails.**
- **Where:** T2.5 (plan:527) and the T2.7 skill (plan:557).
- `create-cairn-site/bin.mjs:77` spawns the platform binary with `new`. Nothing puts `cairn` on the clean `PATH`, and no `cairn` exists on the host.
- With "A read that fails is a failed check", every record fails that check.
- **Fold:** read status with `cleanroom shell <name> -c 'npx --yes create-cairn-site status'` (the launcher prepends `new`), or from the registry record alone.

**7. `correctness` — `run-gate.sh naive` returns at once, so the lock and the cleanup trap break "runs are sequential".**
- **Where:** T2.5 (plan:531-533); `scripts/gate/run-gate.sh:26-27, 73-77`.
- The flock on fd 9 is released when the script exits, while the run continues in tmux. A second `naive` or `sweep --apply` can then start mid-run.
- The EXIT trap's `gate --teardown-run` fires at that same return.
- The stand-in's lifetime and display environment after the return are unnamed.
- **Fold:**
  - `naive` and `scripted` take no EXIT teardown.
  - The stand-in runs as a third tmux window.
  - `naive`, `scripted`, `probe` and `sweep --apply` refuse while a `cleanroom-*` tmux session is live, or the watcher holds the lock until `state.json` leaves `running`.

**8. `correctness` — The release rule is keyed on engine versions, but setup's code ships in the tool.**
- **Where:** "The release rule's mechanics" (plan:231-241).
- `carry` diffs `v<from>..v<to>` (engine tags), and `verdict` checks rows by engine version.
- A tool-only round (`tool/v2.0.0-rc.N`, no engine cut) leaves the engine version unchanged. An older tool's naive row then still satisfies `verdict`, against the design's commit-based rule (design:176-180).
- **Fold:** each Gate row records the cairn-cms commit plus the engine and tool versions. `carry` diffs commits. `verdict` requires the naive and owner rows' commits to have no rerun-path change up to the release commit. `verdict.mjs` must still import only built-ins and `./record.mjs` (`publish.yml:247-248` sparse checkout).

**9. `correctness` — The token option leaves the interactive lane's owner email unspecified, and the scripted leg depends on it.**
- **Where:** T2.1 (plan:461-467) and T2.6 (plan:544-545).
- The email comes from `/user` today (`opening.go:210-215`), and an account-owned token can't read it.
- T2.1 says only that the agent lane refuses without `--email`. T2.6 types "the email as a bracketed paste" at a screen, which exists only if the TUI asks for it.
- **Fold:** T2.1's acceptance says the interactive lane asks for the email when the token is set, with a test. Or T2.6 passes `--email`.

**10. `correctness` — Pre-flight never exercises the credentials, and setup's write sequence under an account-owned token first runs after a candidate is published.**
- **Where:** item 3 (plan:50-51, a name check only; "T2.3's smoke proves the scopes"), item 4 (plan:56-57, checked by T1.6).
- A missing scope surfaces mid-pass-2 through a standing answer that needs Geoff (plan:654).
- The full sequence (`/accounts`, zones, D1, R2, Worker upload, custom domain, Email Sending send) is first exercised at T3.2, after rc.5 and `tool/v2.0.0-rc.1` publish.
- Cloudflare's account-token page lists D1, R2, Workers and Email Service as supported. It is silent on `/user` and on a verify endpoint, so that is unprobed.
- **Fold:** add a `[you]` script to the sitting, run right after `secret-receive`, which reads the store itself:
  - `/accounts/<id>/tokens/verify`;
  - create and delete a D1 database, an R2 bucket and a Worker script;
  - attach and detach a custom domain on a probe hostname;
  - read Email Sending subdomains;
  - one `/v1/models` call on the Anthropic key.

  Write its replies into T2.1's fakes and T2.3's fixtures.

**11. `correctness` — Pre-flight item 7 doesn't cover the riskiest grant lines.**
- **Where:** plan:71-77 and plan:97-100.
- It probes only the held-files and cleanroom-config writes. Untested before their first live use:
  - `setup-tooling-cleanroom-run` (Credential Exposure: `--secret` store names; first used in T1.6);
  - `run-gate.sh sweep` sourcing the store (T2.3);
  - `tmux send-keys` approving another session's permission prompt;
  - the pushes to `glw907/initiatives` `main` (T1.6, pass 3).
- "Three grants are first used live" undercounts.
- **Fold:** item 7 also runs:
  - a stub `cleanroom` at a scratch path called with `--secret CF_WS_CAIRN_CLEANROOM_TOKEN:CAIRN_CF_SETUP_TOKEN`;
  - the existing `bash scripts/gate/run-gate.sh --smoke`;
  - a `tmux send-keys` to a scratch session showing a fake prompt;
  - a scratch commit and revert on `initiatives` `main`.

**12. `correctness` — Pane text and transcripts are untrusted input, and can carry the production token.**
- **Where:** T2.7 skill (plan:556-558) and the pass 3 prompt.
- The executor reads the naive session through `tmux capture-pane` and replies as the owner. It holds the merge, publish and sweep grants.
- The naive agent holds `CAIRN_CF_SETUP_TOKEN` and can print it with `env`, which puts the account-wide token into the executor's transcript. That breaks "no task reads a secret value into a session" (plan:101), and any injected instruction in the pane reaches a privileged session.
- **Fold:**
  - Add a `cleanroom capture <name>` that redacts every `--secret` value the run handed in.
  - The skill states that pane and transcript text is data: the executor sends only owner-card answers and prompt choices, never a command the pane proposes.
  - Round records get a value scan (`assertNoToken` or gitleaks) before commit.

**13. `correctness` — The owner-steps script dies at step 3 on `create-cairn-site`.**
- **Where:** `setup-tooling-owner-steps.sh:115-126`.
- `npm help trust`: "the registry only supports one configuration per package … it will result in an error. To replace an existing configuration: … `npm trust list` … revoke."
- `create-cairn-site` is already bound to `publish.yml` (`cairn-releasing` SKILL:337-339), so `--apply` fails in Geoff's sitting after the six platform packages are published.
- **Fold:** for a package whose trust list names another workflow, print it in the dry run, and under `--apply` run `npm trust revoke <pkg> --id=<id>` before binding. Rerun the dry run.

**14. `correctness` — The pass 3 launch check can't read done without Geoff's npm login, and his login lingers.**
- **Where:** conductor prompt line 24, plan:41.
- Unauthenticated, `npm trust list` answers E401 (seen here). The script then prints "would bind" for all seven packages, and the conductor's final dry run never shows only `done:` lines.
- Conversely, a lingering `npm login` leaves a publish-capable token in `~/.npmrc` for every session, including pass 3's.
- **Fold:** the script ends with `npm logout` after `--apply`. The conductor's check reads steps 1, 2 and 4, the six packages' existence, and the `--apply` log's `bound` lines.

**15. `correctness` — Pre-flight item 5's check fails as written, and pass 1's PR would carry Geoff's grant commit.**
- **Where:** plan:58-68.
- After `pull`/`push`, Geoff commits `settings.json` locally and never pushes. `rev-list --count origin/main...main` then prints `1`.
- Pass 1's worktree branches from local `HEAD` (`worktree.baseRef: head`), so the grant commit rides pass 1's PR.
- **Fold:** item 5 ends with a second `git -C ~/.dotfiles push origin main` (main is unprotected, checked) before its check.

**16. `correctness` — The runbook's browser can't open from the clean shell.**
- **Where:** T3.6 (plan:631-632).
- `--open-with "chromium-browser …"` runs inside `env -i`, under setup's scrubbed launcher env (`childenv.go:35-45`). It has no `WAYLAND_DISPLAY`, `DISPLAY` or `XDG_RUNTIME_DIR`, so Chromium can't start a window.
- **Fold:**
  - `cleanroom shell --open-with` starts, in Geoff's own environment, a tail on `urls.log` that opens each new URL with the command, so the clean environment stays clean.
  - The runbook also names the site `Cairn gate <run id>`; it doesn't now, and the sweep finds only that prefix.

**17. `correctness` — The canary reads can pass vacuously.**
- **Where:** T1.3 (plan:401-403).
- "`~/.local/secrets`" inside the clean session resolves to the clean home, where the file doesn't exist.
- "Expected to fail" doesn't tell a sandbox denial from ENOENT.
- **Fold:** the probe list uses absolute paths substituted at `init` (`/var/home/glw907/.local/secrets`, the canary's absolute path), and passes only on a denial message, not "No such file".

**18. `correctness` — The scripted leg's screenshot mechanism is unproven on this host.**
- **Where:** T2.6 (plan:546-548).
- `kitty-headless-shot` runs `CMD` inside distrobox `term-headless` (Fedora 41). Probed there:
  - it has no `tmux`;
  - `/home/linuxbrew` isn't visible;
  - its `/tmp` is a separate mount, so `tmux attach -r` to the host's default socket isn't reachable as written. No host tmux server was running, so socket sharing is unconfirmed.
- **Fold:** T2.6 adds `tmux` to the box (`kitty-headless-shot setup`), runs the leg's session on a `tmux -S <socket under $HOME>`, and proves one shot before building on it. The plan already lists this item as escalable.

**19. `correctness` — There is no standing answer for which items still run once the success bar is out of reach.**
- **Where:** plan:649.
- The budget stop says "no sixth run" but not whether T3.4's scripted leg (no spend, new evidence), T3.5 and T3.6 run, or that the run closes reporting the bar unmet.
- **Fold:** on the budget stop, run T3.4 once on the current candidate. Skip T3.5 and T3.6, and close with the bar marked unmet. Skip any rerun whose cause is already traced.

## Minor

**20. `correctness` — The template contracts contradict themselves in four places.**
- T1.1's "written settings equal the template plus nothing else" (plan:360) can't hold. The `statusLine` command needs the per-home run directory and the tool's own path.
- `init` can't seed the API-key approval "by its last 20 characters": it takes no `--secret`, and only `run` does.
- The tool must find its template beside itself, or T1.6 run from a worktree reads a missing `~/.local/share/cleanroom/`. `bin/.local/share` doesn't exist in the repo yet, so `stow -R bin` creates it.
- The `.claude.json` keys are uncited.
- **Fold:** "the template with its placeholders filled"; seed the key at `run`; resolve the template relative to `__file__`; cite or probe the onboarding and approval keys.

**21. `correctness` — The sweep families don't match how setup names resources, and the leftover inventory is unchecked.**
- Setup creates no DNS records itself. `checkAddress` only reads them (`opening.go:305-330`), and records at the bare address and `www` carry no `cairn-gate-` prefix.
- The GitHub App family can't be scope-probed by a create and delete without the manifest flow.
- The old gate's names are `cairn-e2e-gate-…` (`legs.mjs:49`). `cairn-gate-` doesn't match them, so any old-gate leftovers are invisible to the sweep, and nobody has checked for them.
- **Fold:**
  - Drop the DNS delete family; after the domains are removed, assert no records remain at the bare address and `www`.
  - Name the App family's check: the settings page lists the Apps and sudo passes.
  - Add a pre-flight inventory read of `cairn-e2e-gate-` and `cairn-gate-` resources.
  - Use `cairn-e2e-gate-` names as the "never listed" fixture.

**22. `correctness` — Pass 1 and pass 2 build the run-directory interface in parallel.**
- Pass 2's grader and stand-in read pass 1's layout, which pass 1 is still writing.
- The statusline output file name and the transcript's location in the clean home are unnamed, so a mismatch first shows at T3.2.
- **Fold:** fix both names in "Calls settled here".

**23. `correctness` — The overlap check and the base are stale.**
- `main` is now `5456b257e`: G1 merged, touching `scripts/gate/cloudflare/catalogue.mjs` and `tool/internal/setup/scaffold/targets.go`.
- G2, in flight, edits `BACKLOG.md`, `CHANGELOG.md`, `MIGRATION-NOTES.md`, root `package.json` and `.github/workflows/test.yml`. Item 8's list omits all of these.
- **Fold:** update the base line; add the ledgers to item 8; add a standing answer that the later PR merges `main` and resolves append-only ledger conflicts before its merge.

**24. `correctness` — The launch guard never checks this plan.**
- `claude-launch-guard` matches plans only under `docs/plans/` (`PLAN_PATH`, line 32), and the sibling fallback (`-1.md`) doesn't exist. So none of these launches is checked, despite the plan relying on the guard (plan:87-103).
- **Fold:** T1.5's acceptance includes an initiatives-layout case (`~/Projects/initiatives/<id>/specs/*-design.md`). File the executor-side gap with `standards:log-issue`.

**25. `correctness` — `check:close` may run out of memory during the light cut.**
- #370 records `check:close` running out of memory on the 3G light lane. T3.1's cut runs it (`cairn-releasing` step 6.3) without naming the lane.
- **Fold:** name the default lane, or add a standing answer.

**26. `correctness` — T3.5 conflicts with the dependency-sweep rule and the merge grant.**
- "No other cairn-cms worktree live" conflicts with pass 3's own worktree, and `cairn-releasing` step 2 says the sweep runs "with no worktree live".
- The sweep's PR branch must be `setup-tooling-r<n>`, or `setup-tooling-merge` doesn't cover it.
- **Fold:** state both.

**27. `correctness` — Repeated commands aren't written out in full.**
- `run-gate.sh naive`, `scripted` and `probe` have no argument forms written anywhere, and T3.3 and T3.4 repeat them.
- **Fold:** write each command with its flags and `run_in_background` at each step.

**28. `optional` — The estimate text contradicts its own arithmetic.**
- plan:304 says pass 3's live minutes "take no factor", then divides all of pass 3's 555 by 0.53 (plan:309-310).
- Either figure is under the 2x line, but S-4's 2,070 rests on it.
- **Fold:** correct the sentence or the figure before Geoff rules.

**29. `optional` — S-2's mitigations are overstated.**
- The deny rules are text matches (`*-X DELETE*`). `curl --request DELETE` or `node -e "fetch(…)"` to the allowlisted `api.cloudflare.com` bypass them.
- **Fold:** state that only the run-tagged names, the caps and the watcher limit damage, so Geoff rules on accurate text.

**30. `correctness` — The denied-command rule is incomplete.**
- No rule says whether a sandbox denial the naive agent recovers from counts as friction or flailing.
- **Fold:** a recovered denial is one test-drive item, and flailing only when repeated.

**31. `optional` — A few small inconsistencies.**
- plan:21 claims "every dispatch" carries the two samples, but `pass-core` requires them in planning dispatches only, and the prompt files and task blocks don't carry them.
- `## Review` is empty while `Reviewed:` points to it.
- The CLAUDE.md skills list should gain `cairn-proving-setup` in T2.7.
- The light cut's `gh run rerun` standing answer isn't named in the `setup-tooling-candidates` grant line.
- After a workstation round PR merges, the conductor's "pull, then `stow -R bin`" isn't stated.

**32. OWNER FORK `optional` — Clean-room settings changes after packet B.**
- The design has Geoff approve the settings once (design:209-210) and bans a settings change mid-run (design:88-89).
- T3.3 lets workstation round PRs change the template under `setup-tooling-merge` with no packet. S-1 covers only T3.2.
- Options:
  - (a) Every template change after packet B sends a small packet.
  - (b) A widening inside the cleanroom-config grant line merges between runs and rides the end packet.
- **Recommendation:** (b), since the line forbids every narrowing and the clean home is rebuilt each run.

**33. `optional` — The live admin smoke is waived without a cited rule.**
- The planner waives the adapter's `auth-data` close item (plan:268-271).
- **Fold:** quote the `cairn-running-passes` rule that allows it, or make it a one-line Decide.

## Over-ceremony (by cost)

**34. `optional` — The sweep's dry run probes every family's write scope on every naive run.**
- It creates and deletes throwaway resources, including a custom domain, on the production account, against the 5-minute overhead line.
- The design asks for the scope check (miss 1), so trimming it is a cost call, not a fork.
- **Fold:** a full probe the first time and after any token change; every run does `tokens/verify` plus the list.

**35. `optional` — Two tasks are a single small deliverable each.**
- T2.0 (10 min, `BACKLOG.md` only) can fold into T2.1's first commit.
- T1.4 (30 min, docs only) can fold into T1.7.

**36. `optional` — Pre-flight item 6 ("Nothing else") is not a step.**
- **Fold:** drop it.

---

The probes left scratch directories I couldn't remove, because the safety check blocks `rm -rf` on a variable: `/var/tmp/gkprobe-src`, `/var/tmp/gkprobe-a`, `/var/tmp/gkprobe-b`, `/var/tmp/npmtag-probe`, and possibly `/var/tmp/kr-probe-*`. Each holds only throwaway keyring files or a probe binary, and is safe to delete by hand.

