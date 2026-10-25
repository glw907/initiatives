# Operator runbook plan review: contract and criteria

Target: `self-hosting/plans/2026-10-25-operator-runbook-plan.md` at `9552ef9`, against `self-hosting/specs/2026-10-25-operator-runbook-design.md`. Lens: contract and criteria. Reviewer read the servers repo at `main` (`f37a5a7`), `~/.claude/docs/bluefin-admin.md`, and `~/.claude/docs/cloudflare-estate-inventory.md`. The design's rulings aren't re-opened. Plan line numbers match the file at that commit.

Count: 2 blocker, 12 major, 15 minor. One OWNER FORK (M11).

## Blockers

### B1. The bus-day check can pass without the docs being right or being the source (blocker, correctness)

Plan:182, 196, 198. The design's headline check (design:94) has three gaps that each let T10 pass vacuously.

- **No answer key.** The grading rule (plan:196) fails an answer only when it depends on Claude Code, Geoff, or access he lacks. A cited, confident, wrong answer passes. For example, Q3 could give a wrong renewal date, or Q2 a wrong identity path.
- **The answerer isn't confined.** A `general-purpose` agent has Bash and every tool. It can read `~/.claude/docs/cloudflare-estate-inventory.md`, `~/.dotfiles`, and the initiatives repo, which hold most of the answers. "Gets only the servers repo" is a prompt instruction, not a fixture.
- **The grader is unnamed.** If the main loop grades the agent's answers against pages the main loop wrote, the read is anchored.

Fold:

- Before T10 runs, write an answer key in the plan's pre-flight file, one or two load-bearing facts per question. For example: Q2 is his own Proton Pass vault, `SERVERS_AGE_IDENTITY` or `~/.config/servers/age-identity.txt`. Q3 is the expiry date and price from the pre-flight 5 record. Q8 is direct ssh as `<his account>@`, with the fingerprints. An answer fails when it misses a key fact or cites a path that isn't in the repo at the branch head.
- Give the agent a `git archive` export in a scratch directory. Tell it to read only under that directory, and reject any citation outside it.
- Have the main loop grade against the key, so it's mechanical and not judgment. Record the key and every answer under `## Decisions`.

### B2. The moved-name set is circular, so a missed name is waved through as "expected OWED" (blocker, correctness)

Plan:102, 104, 78, 137. T1 copies "the moving names (`secrets/registry.md` lists them)", and T1 also writes `registry.md`. Its acceptance compares hashes "for every moved name", so a name missing from the list is never compared. T4's acceptance allows "only the expected OWED rows", but no task lists the expected set. The standing answer at plan:78 names categories, not names. A name that should have moved therefore shows up as OWED on his `dry-run.sh` and gets accepted. On the bus day, a render or Worker deploy then lacks that secret. The standing answer at plan:80 cites a "workstation-wide grep" that no task defines.

Fold:

- In T1, derive the set mechanically. Take every name read by `secrets/templates/**`, `hosts/*/secrets.txt`, the Worker secret lists under `cloudflare/`, and the `scripts/`, `infra/`, and `cloudflare/*.sh` references. Intersect it with `values.age`'s names and subtract the "Calls" stay-list (plan:41-44).
- Record that derivation's command and output. T1's acceptance becomes "derived set equals `registry.md`'s moved set, and the hash comparison matches for each".
- T4's acceptance names the expected OWED rows exactly, using the `dry-run.sh` row names (the `webdav-geoff` row plus the named broad-token and Fastmail rows). Any other OWED fails.

## Majors

### M1. Pre-flight 1 and 2 checks can't run with `ws-admin` (major, correctness)

Plan:60-61. The canonical scope record (`~/.claude/docs/cloudflare-estate-inventory.md:92-100`) gives `ws-admin` no Account Members and no Account Settings scope. The `GET /accounts/{id}/members` check will 403. So will the `PATCH` and probably the `GET /accounts/{id}` read of `enforce_twofactor`. Both checks then fall back to nothing written down.

Fold: make each check "the API read, or, on 403, the Cloudflare MCP OAuth read, which is broad read; else Geoff's confirmation with the dashboard state recorded". Plan pre-flight 2 as Geoff's dashboard step from the start, with Claude's `PATCH` as a try that's expected to fail.

### M2. "His own address is enough" has no fixture (major, correctness)

Design:73 says the builder checks each account's recovery and notification addresses. Plan:164 has "a check that each of his seats uses only his own addresses", but no source of truth. Claude can't read Hetzner, GitHub, or Proton recovery or notification addresses, and his side doesn't exist until the sitting. As written, the accounts page can assert it unchecked.

Fold:

- Add a sitting step. For each account he accepts, he reads and records the login, recovery, and notification addresses, and each must be `<his 907.life address>` or `<his Proton address>`.
- For the Geoff side, add a pre-flight 5 column: where each account's alerts and invoices go.
- The accounts page marks the column "confirmed at the sitting" until then.

### M3. The Survey editor register is checked only by Vale (major, correctness)

Plan:145, 152, 159, 172. The design (design:61) puts the operator pages in Survey's editor register (`~/.claude/skills/survey/writing/editor.md`). The only check the plan names is the Microsoft Vale package. Per the workstation rule, a clean lint is necessary, never sufficient. No task reads the pages against `editor.md`.

Fold: in T11, before the whole-branch review, run one `prose-voice-reviewer` read over the operator pages and `EMERGENCY.md`, naming `editor.md` as the standard. Fold its findings in the same batched chain. It costs about 15 minutes.

### M4. Concepts-before-links and the stable-link rule have no check (major, correctness)

Design:59; plan:151-153. T6 restates the rule, but its tests are Vale and the relative-link check. Nothing fails a page that links "Cloudflare Tunnel" before saying what a tunnel is. Nothing fails a blog or community-post link either, and the design bans those.

Fold:

- Extend T5's link check to external links: a domain allowlist (vendor docs domains, `en.wikipedia.org`, GitHub release pages). Any other domain fails, and adding one to the list needs its reason.
- Add a concept list to the plan: zone, Worker, tunnel, Access application, MX record, DKIM, R2 bucket, and age identity. For each one, the page where it first appears has a defining sentence before its first external link. The main loop checks the list by grep at T6 acceptance, and the T10 key can ask one concept question.

### M5. The accounts acceptance passes with every cell "unknown" (major, correctness)

Plan:173. "No row blank, and an unknown says where to read it" lets every amount and renewal cell read "unknown, see the dashboard". Pre-flight 5 (plan:64) already fills every row, and the design (design:43, 74) promises the amount and renewal date.

Fold: for every account that pre-flight 5 covered, the amount, payer, renewal, and auto-renew cells match the record and aren't "unknown". "Unknown" is allowed only for a column the record marks unread, with where to read it.

### M6. Upkeep and the alert map have no acceptance (major, correctness)

Plan:163. T8's acceptance (plan:173) covers only the accounts table. Nothing checks these design:84-86 promises:

- Every duty in `docs/monthly-review/prompt.txt` became a checklist item.
- The prompt now reads the checklist.
- Each email alert maps to its screen.

Fold:

- Write a duty table under `## Decisions`, one row per duty in `prompt.txt` steps 1 to 5 (US pricing, upgrades, health, catalog and credentials, and each periodic item), each naming its `docs/upkeep.md` heading. After T8, `prompt.txt` holds no duty text, only a pointer and the session mechanics.
- Write an alert table: one row per alert kind the monitor sends (from `cloudflare/monitor/src/alerts.ts` and `alertlist`), each naming its screen. No row may be blank.

### M7. The sitting checklist has no acceptance, and the key hand-over has no integrity step (major, correctness)

Plan:165-171. No criterion checks the checklist. The design (design:76) requires his half to cover accepting, enrolling two-factor, and sending his ssh and age public keys, and the plan covers those. But step 5, "Send his age and ssh public keys", names no channel. In an `auth-data` pass, Claude adds whatever key arrives to `recipients.txt` and `base/keys/`. A key swapped in transit becomes a recipient of every household secret and root on both hosts.

Fold:

- Have him open a PR from his own GitHub account (he has write) that adds `base/keys/<his account>/<machine>.pub` and his `recipients.txt` line. Claude then rekeys on that branch. His GitHub sign-in authenticates the keys. Failing that, read the fingerprints back over a second channel.
- T8's acceptance names each design half item and its check. These checks are: Cloudflare members shows him accepted with two-factor; `ssh <his account>@orpheus.907.life` works; and `dry-run.sh` from Mint decrypts with his identity alone, with no `~/.local/secrets` on his machine.

### M8. The route proof can pass on Geoff's key instead of the throwaway (major, correctness)

Plan:134, 136. The scratch store is rekeyed to `recipients.txt` plus the throwaway, so Geoff's workstation key also opens it. `store.sh` and `secrets_load` fall back to `/dev/shm/.age-key-$UID` and `~/.local/secrets` (plan:100-101). If the container sees either path through a mount, the run passes without the throwaway ever decrypting. Also, the refusal test's "before any network call" has no fixture.

Fold:

- Rekey the scratch store to the throwaway alone.
- Inside the image, assert that there's no `~/.local/secrets` and no `/dev/shm/.age-key-*`.
- Add a negative control: a second throwaway that isn't a recipient must fail.
- Run the refusal case with `--network=none`, so a network call would fail differently from the expected refusal.

### M9. T9 acceptance stows an unmerged branch into the live `~/.claude` (major, correctness)

Plan:179. "`claude-tooling-sync verify` passes after stow" can run before merge only by stowing the workstation worktree's `claude` package over the live tooling, which is a live change before approval. Otherwise it can't run at all. After merge step 3 (plan:227) already does it.

Fold: T9's acceptance keeps `claude-tooling-sync lint --root <worktree>` and drops verify. Verify stays at After merge 3.

### M10. The vault check has no expected list (major, correctness)

Plan:135. "Every shared household item, the restore kit included, is in `Household IT`" has no enumeration, so any title list passes. Pre-flight 6 (plan:65) proves `Household IT` access only, yet T4 also lists `Workstation`. The agent has editor on `Workstation` (`bluefin-admin.md:302-303`), but that's never checked before T4.

Fold:

- Enumerate the expected `Household IT` titles in the pre-flight file: the former `Servers emergency` titles (from `pass-count` history or `registry.md`), the restore kit, and the design-named shared items. Enumerate the `Workstation` titles the same way.
- The check is set equality on titles, with differences sent to the standing answer at plan:77.
- Add `claude-pass item list --vault-name Workstation` to pre-flight 6's check.

### M11. Two scripts still hard-wire Geoff's key (major, correctness) OWNER FORK

`scripts/archive.sh:30-31` and `scripts/mail-test-ids.sh:17-18` encrypt to Geoff's workstation recipient, and by default decrypt with `/dev/shm/.age-key-$UID`. T2's portability acceptance (plan:114) greps only `geoff@`, so these pass unseen. The `servers-archive` bucket would stay readable only through Geoff's key or the paper kit.

OWNER FORK, on whether he should be able to read the archives:

- (a) Keep archives Geoff-only. The accounts page and `your-machine.md` say so, and the scripts' headers mark them Geoff-only.
- (b) Encrypt new archives to `recipients.txt`, and leave old ones as they are.
- (c) Re-encrypt the existing archives to both.

Recommendation: (a), since the bucket likely holds Geoff's personal mail exports, and that matches the least-privilege reasoning (design:21). Whatever the ruling, add a T2 acceptance grep for workstation assumptions (`/dev/shm/.age-key`, `age197mcd`, `/var/home`, `secret-tool`, `notify-send`) over `scripts secrets infra cloudflare/*.sh`, with an allowlist.

### M12. The "same as before" checks have no captured baseline (major, correctness)

Plan:214, 226, 122. Three checks compare against a "before" state that nobody records:

- Before-merge: "`~/.local/secrets` lists every name it listed before".
- After-merge 2: "`dry-run.sh` shows the same rows as before the pass".
- T3: "every name the old `~/.local/secrets` held".

Each passes or fails on memory.

Fold: at Entry, record the `~/.local/secrets` name list for pavilion and thinkpad-x1 (names only), and pavilion's `dry-run.sh` row table, in the pre-flight file. Also fix "with arguments" at plan:226, which reads like a slip for "with no arguments".

## Minors

### m1. The stop-line grep catches one phrasing (minor, correctness)

Plan:147. `call Geoff` misses "ask Geoff", "contact Geoff", and "Geoff can". Fold: grep the operator pages and `EMERGENCY.md` for `Geoff` at all. Allow the appendix, plus named facts such as the accounts page's owner column.

### m2. "Hits only history" isn't defined (minor, correctness)

Plan:147, 179. Fold: list the allowed paths (`docs/cutover-log.md`, dated plans, `docs/decisions.md`, `docs/monthly-review/log.md`). Grep case-insensitively and include the `servers-emergency` spelling.

### m3. T3b acceptance passes on an empty store (minor, correctness)

Plan:131. Fold: also require `store.sh names` to list `STALWART_PASSWORD_HASH_GEOFF` and the three `WEBDAV_HTPASSWD_*` names, one each for `geoff`, `operator2`, and `memberc` (per `roles/webdav/users.txt`).

### m4. The hash logins are proven only after merge (minor, optional)

Plan:128-130, 220-224. The Stalwart and rclone hash acceptance rests on reading the source. A cheap fixture in `tests/webdav.test.sh`: the pinned rclone serves a scratch directory with a `htpasswd -B` file, and `curl` signs in with the test plaintext. That turns the riskiest post-merge failure, every member's Floccus sync, into a pre-merge test. Upserting Stalwart credentials on every apply (`roles/stalwart/build-plan:32`) does make the after-merge check real.

### m5. The figure and overview checks name no failure (minor, correctness)

Plan:152-153. "The main loop reads each PNG" names no fail condition, and the overview has no table for "every overview row" to refer to.

Fold: a figure fails when `mmdc` exits non-zero, or when a node names a host, service, or account not in `hosts/`, `roles/`, or the accounts page. The overview acceptance becomes: a heading for each of the five design questions (design:53), and each service named links to its `docs/services/` page.

### m6. T1's plaintext rules lack fixtures (minor, correctness)

Plan:100, 103. "No value appears in any output" needs a named canary value that's grepped in all captured stdout and stderr. "Plaintext lives only in pipes or `/dev/shm`" is untested. Fold: run the tests with `TMPDIR` pointed at a scratch directory and assert it's empty afterwards.

### m7. "Short" and the anti-goal have no bound (minor, optional)

Design:46, 52. Fold: a word ceiling for `docs/start-here.md` (for example, 400) checked by `wc -w` at T5 acceptance. Findability itself is covered by B1's key.

### m8. The skill's "no copy" and pointers are unchecked (minor, correctness)

Plan:176-178. Fold: every servers path the skill names exists at the servers branch head. A grep fails the skill on IP addresses, fingerprints, or token ids. Its description names the design's three triggers (design:90).

### m9. The #38 fingerprints are trust-on-first-use from pavilion (minor, optional)

Plan:145. `~/.ssh/known_hosts` holds what pavilion accepted. Fold: cross-check against `ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub` read over the T4 `--check` ssh session, which goes direct to `<host>.907.life:22` (`scripts/apply.sh:52`).

### m10. The `geoff@` grep scope is narrow (minor, correctness)

Plan:114. It skips `cloudflare/*.sh` and forms like `-l geoff` and `User geoff`. Fold: widen the grep to those.

### m11. No bus-day question covers a rebuild (minor, optional)

Plan:184-195. Provision plus apply is the store-heaviest route and the design's "keep everything running" case (design:27). Question wording is the builder's call. Fold: add "ward is gone; rebuild it", graded by the B1 key.

### m12. The pre-flight 6 check misses `Workstation` (minor, correctness)

Plan:65. This is the check half of M10. Fold it there.

### m13. T7 acceptance mostly resolves to "not run" (minor, correctness)

Plan:160. T2 and T4 run the harness, `dry-run.sh`, and `--check`. Most change-page commands (provision, DNS, Worker deploy, R2, redirects) are never run, so the criterion checks little. Fold: each command's flags must match its script's usage block (a mechanical grep), and "not run" is recorded per command.

### m14. The Mint leg runs in the local fast lane (minor, optional, over-ceremony)

Plan:111. The leg builds a podman image whenever `scripts/`, `tests/`, and the other trees change. That's a recurring clock cost on every future servers pass, not only this one. Fold: run it in CI, and locally only when `tools/mint-packages.txt` or `tests/mint/` changes, plus once at T2 and T4.

### m15. A task-scope `diff-reviewer` on T4 adds little (minor, optional, over-ceremony)

Plan:98, 133. T4 is main-loop live work plus one wrapper script with one refusal test, and the whole-branch read at T11 covers that script. Dropping the T4 read saves about one reviewer dispatch, roughly 10 minutes and its tokens. Keep the task-scope reads on T1, T2, T3, and T3b.

## Coverage map

Each design promise the dispatch named, with its task and whether a check now exists. "Gap" means a finding above.

| Promise | Task | Check |
|---|---|---|
| Bus-day questions (design:94) | T10 | Gap (B1) |
| Sitting checklist (design:76) | T8 | Gap (M7) |
| Survey editor register (design:61) | T5 to T8 | Vale only (M3) |
| Concepts before links (design:59) | T6 | Gap (M4) |
| Figures (design:63) | T6 | Render only (m5) |
| Accounts page (design:74) | T8 | Vacuous (M5), addresses (M2) |
| `household-infra` skill (design:90) | T9 | Lint only (m8, M9) |
| `Household IT` re-pointing (design:72) | T9, T4 | Grep (m2), vault list (M10) |
| Server secrets split (design:21) | T1, T3, T3b | Circular (B2) |
| Mint portability (design:80) | T2, T4 | Partial (M8, M11) |
| Upkeep checklists and alerts (design:84-86) | T8 | Gap (M6) |
