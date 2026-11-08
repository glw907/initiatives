# rc.4 build session: tooling failures, ranked (recon, 2026-11-08)

Sources: the observer session transcript
(`~/.claude/projects/-var-home-glw907-Projects-initiatives--claude-worktrees-907-rebuild-design/62470924-2be0-41df-a924-06f930d41e08.jsonl`,
cited "obs" with UTC time), the planning session transcripts (907-life 0c7ff9d7, fd409ee2), the
planning-misses record (`~/Projects/initiatives/907-rebuild/plans/2026-11-08-planning-misses.md`),
the builders' friction files, and the ledger (`~/.local/state/cairn-agent-first/ledger.md`).

1. The gate never takes the owner's path (gate and tests). `scripts/gate/legs.mjs:352-370, :644`
   always answers AI posture "none" (hid #365), a blank brand color, has `CLOUDFLARE_API_TOKEN` set
   (wrangler OAuth and its 2-minute timeout never run), types tokens key by key (no bracketed
   paste; Geoff's paste failed twice), and follows App redirects in one context (no stale tab,
   #364). No test runs each prompt answer through scaffold, `cairn-manifest --check`, and build.
2. The observer couldn't see or drive the wizard (Claude tooling, CLI). Geoff (obs 05:53Z): "In the
   future, asking me for the wizard's progress is a problem. YOu need a way to do this work
   unattended." Fixed mid-run by tmux plus `secret-receive`; no progress stream or status command
   existed, so the observer polled `~/.config/cairn/sites/*.json`.
3. The clean-room harness and auto mode stopped the pass (Claude tooling). Sandbox widening
   refused as a security weakening, a too-narrow allowlist, sign-in rounds. Geoff: "This session
   keeps stopping progress to ask me for input" (02:23Z). Root cause: the probe tested isolation,
   never a representative build (misses 3, 5, 7, 8).
4. Nothing an agent can read before the scaffold exists (packaged skill, docs, CLI, release). No
   packaged skill mentions setup, no `--help` flag reference, ten permission denials in builder B's
   planning turn, and the engine's npm `latest` (0.98.0) differs from the scaffold's (rc.4), so
   builder A read the wrong docs first.
5. The theme was never on the site (CLI, docs, process). Stock demo on the live domain (miss 15);
   theme-packaging doc gaps (friction A 2, 3, 10; backlog #376).
6. Gate harness defects and bugs found only by reading code. The JMAP reader turned a method error
   into "0 messages" (six reruns); leg A1 never read the mailbox; the name-clash defect and false
   DMARC copy were caught by agents reading code, not by the gate.
7. Release-process friction. rc.4 recut three times in a day; no preflight recut mode (#369);
   `check:close` out of memory on the light lane (#370); no dependency sweep on the run sheet
   (#372); a fail-closed hook blocked a worktree session; a usage-limit stall read as idle.
8. Session cost. Builder A's resumed sessions cost $17.49 over three turns against $0.97 fresh
   (miss 10).
9. Teardown tooling. Token scope unchecked, no resume, no log (misses 1, 2); repo deletion needed a
   new scope; App deletion needed Geoff's hands.

Wins to keep: the stable waits on Geoff's own install (`cairn-releasing` step 9); setup's progress
record and resume worked twice; tmux plus `secret-receive`; conductor code reads found bugs in
minutes; the planning-misses table; the cost ledger; the isolation probe; the gate's `xdg-open`
shim (reuse it for the clean-room `BROWSER`).

Recon's top changes: build #366 around the owner's path (every prompt option offline through
scaffold, manifest check, and build; a bracketed-paste pty leg; OAuth with no token; resume at
each boundary; a stale-tab leg). Make `cairn new` observable (NDJSON events and a `status`
command). Commit a `site-rebuild` skill and a `cleanroom` tool with pre-approved settings proven by
a full-build probe. Publish a pre-scaffold agent kit (setup skill on cairn.pub, `--help`,
version-stamped docs, a release check on the dist-tag split). Two gate rules: an error is never
read as an empty result, and provider-facing copy gets a fact-check before a cut.
