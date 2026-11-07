# 907 rebuild review: data integrity and failure risk

Lens: crash, concurrency, partial writes, upgrades, restores, and silent loss. Target: initiatives
commit `ca45e41`. Paths below are relative to `907-rebuild/`. Spec lines are the spec file's own
line numbers.

Facts checked live on 2026-11-07, all read-only:

- This shell's environment carries about 60 secret names: `CLOUDFLARE_API_TOKEN`,
  `CF_WS_SERVERS_TOKEN`, `GITHUB_APP_PRIVATE_KEY_B64`, `GITHUB_TEST_PASSWORD`,
  `GITHUB_TEST_TOTP_SECRET`, `CLAUDE_CODE_MESSAGING_TOKEN`, `SSH_AUTH_SOCK`,
  `DBUS_SESSION_BUS_ADDRESS`, `SUDO_ASKPASS`, and more. `~/.bashrc:213` sources
  `~/.local/secrets` into every interactive shell. I read the names only.
- Public DNS for 907.life already serves Email Sending records: `cf-bounce.907.life` (three
  `route*.mx.cloudflare.net` MX records and an SPF TXT) and `cf-bounce._domainkey.907.life`.
  `_dmarc` reads `p=none` with its report address. None of these records is declared in
  `servers/cloudflare/dns/`.
- `servers/cloudflare/monitor` sends its alerts as `monitor@907.life` through a `send_email`
  binding, so the zone's Email Sending onboarding is shared with the monitor.
- `servers/docs/decisions.md:104`: Hylki's only discovery path is `907.life/.well-known/jmap`,
  which `cloudflare/redirects` sends to ward. A redirect rule only fires on a proxied hostname.
- `907-life/static/privacy.html` (commit `220caa0`) is the privacy policy that Google requires
  before it publishes the Geoff's Tools OAuth app.
- `create-cairn-site/src/state.mjs:27`: setup's state lives at `homedir()/.config/cairn/sites/`,
  or `CAIRN_STATE_DIR` (which isn't documented). It ignores `XDG_CONFIG_HOME`. Geoff's real
  directory already holds `cairn-rc2-install-91f0d5.json`.
- `wrangler r2 object` has only `get`, `put`, and `delete`. It has no `list`.
- `chapter2.mjs:308` and `:1064` tell the user that onboarding writes `p=reject`. They say so
  whether or not `ensureSendingDomain` (`email.mjs:94`) found the domain already onboarded and
  created nothing.
- The old repo has `deploy.yml`, which deploys with `secrets.CLOUDFLARE_API_TOKEN`. It also has
  three worktrees, one of them locked, and a live `workerd` running in
  `.claude/worktrees/ch-c-contact`.

## Blockers

### B1. The builder inherits every workstation secret through its environment
`correctness` · spec:22-30, plan:65 (T1 outcome), plan:67-74 (T1 acceptance)

**Defect.** The isolation design covers files only: Read deny rules, sandbox `denyRead`, and a
separate `XDG_CONFIG_HOME`. But `cleanroom-run` is launched by the observer, and the observer
inherits Geoff's shell, so every exported secret reaches `claude -p` and every Bash child it
starts. Denying `~/.local/secrets` doesn't help, because its contents are already exported. A
plain `printenv` hands over:

- the broad Cloudflare token. Wrangler reads `CLOUDFLARE_API_TOKEN` from the environment, which
  gives full account access, and it would also make T1's "wrangler whoami says not signed in"
  check fail with no fold named;
- `CF_WS_SERVERS_TOKEN`, the zone's declared writer;
- the shared GitHub App's private key;
- the test account's password and TOTP secret;
- `SSH_AUTH_SOCK`, so git over SSH runs as Geoff on every repo;
- `DBUS_SESSION_BUS_ADDRESS`. Through `ws-pass-key` or `secret-tool`, that reaches the GNOME
  Keyring agent token, then the age key, then the whole store. `claude-block-pass` is a
  workstation hook, so it doesn't load in the clean room.

The sandbox's network and socket limits may block some of these paths, but T1 doesn't test any
of them. The excluded-command fallback (spec:24) lifts every limit.

**Fold.**

- `cleanroom-run` execs through `env -i`, with an explicit allowlist:
  - `HOME`, set to a per-builder clean home under `~/.local/state/cairn-cleanroom/`;
  - `PATH` without `~/.local/bin` or `~/.dotfiles`;
  - `LANG`, `TERM`, `CLAUDE_CONFIG_DIR`, and `CLAUDE_CODE_DISABLE_AUTO_MEMORY`;
  - `CAIRN_CF_API_TOKEN`, at T10 only.
- No `SSH_AUTH_SOCK`, `DBUS_SESSION_BUS_ADDRESS`, `SSH_ASKPASS`, or `SUDO_ASKPASS`.
- A clean `HOME` also fixes M10 and most of M11, so `XDG_CONFIG_HOME` is no longer needed.
- T1's acceptance adds four checks:
  - the builder's `env` output names none of the variables in `~/.local/secrets`. The observer
    compares names on its own side and never prints a value;
  - `ssh -T git@github.com` fails;
  - `secret-tool search` fails;
  - `npx wrangler whoami` reports signed out.

### B2. A headless builder holds owner-level credentials, and only three names are denied
`correctness` · spec:25, spec:29, spec:30, spec:43, design:117

**Defect.** After P4, builder B holds three credentials:

- Geoff's wrangler OAuth, which reaches every Worker, D1, and R2 on the account (among them
  `servers-monitor`, the monitor and mta-sts Workers, and the other cairn sites);
- `gh` with `repo` scope on every repo Geoff owns;
- at T10, a setup token that README:511 calls "scoped across all your accounts and zones",
  with DNS edit rights.

The command deny rules name only `907-life-legacy`, `cairn-build`, and `cairn-907-auth`. The
`dontAsk` fallback (spec:29) allows `Bash(npx *)`, `Bash(gh *)`, `Bash(git *)`, and
`Bash(mv *)`. Together those admit `npx wrangler delete`, `wrangler d1 delete`,
`wrangler r2 bucket delete`, `gh repo delete`, `gh api -X DELETE`, and `git push --force`
against any target. Auto mode's classifier is a heuristic, not a guarantee.

The observer's "about to do damage" trigger (spec:43) can't prevent anything. In `-p` mode a
tool call runs the moment it appears in the stream that the observer reads. design:117's promise
("anything irreversible beyond what this design and the retirement packet approve waits")
therefore has no mechanism behind it.

Spec:30 also reads as one `XDG_CONFIG_HOME` for both builders. If it is one, builder A, which
must never deploy, inherits B's wrangler and `gh` sign-ins.

**Fold.**

- Deny rules for destructive verbs, in every permission mode:
  - `Bash(*wrangler delete*)`, `Bash(*d1 delete*)`, `Bash(*r2 bucket delete*)`, and
    `Bash(*r2 object delete*)`;
  - `Bash(*repo delete*)`, `Bash(*-X DELETE*)`, and `Bash(*--method DELETE*)`;
  - `Bash(*push*--force*)`, `Bash(*push* -f*)`, and `Bash(*dns_records*)`;
  - `Bash(curl *)`, because WebFetch already covers reading.
- Each builder gets its own clean home. Builder A gets a `gh` sign-in only and never signs in
  to wrangler.
- P2's token is limited to the 907.life zone under Zone Resources, with a TTL that ends at the
  run ceiling (M14).
- The spec states that prevention rests on the deny rules, and that the observer's damage
  trigger is a check made after the fact.
- T1 proves one destructive pattern from each group is denied.

## Major

### M1. The design and the spec disagree on DMARC, and the live zone points to a third outcome
`correctness` · design:37, spec:133-137, plan:138 (T10 acceptance), plan:142 (T11), spec:153

**Defect.** The approved design says setup sets `_dmarc` to `p=reject`, and e7 then declares
`p=reject` in `dns.sh`. The spec, T10, and the end-to-end check instead require `_dmarc`
unchanged at `p=none`, and they treat a change as a failure to undo by restore plus a blocker.
That reverses an outcome the owner already approved.

Live DNS shows that 907.life is already onboarded for Email Sending, from the old site's
sign-in mail. `ensureSendingDomain` will therefore find the existing entry and create nothing,
so `p=none` most likely survives. Even so, setup prints "Onboarding also wrote a p=reject DMARC
policy" (`chapter2.mjs:1064`) regardless of what it did. That message is a cairn backlog item
the run should expect to file.

**OWNER FORK.** What should `_dmarc.907.life` read at the close?

- **(a) Keep `p=none` (recommended).** It matches the live state, the zone's report address
  stays useful, and the spec's acceptance stays strict. If setup does write `p=reject`, the
  observer restores `p=none` through `dns.sh --apply`, which already declares it, and files the
  item. The design's Decide text gets corrected, since its premise ("it sets `p=reject`") is
  false for a zone that is already onboarded.
- **(b) Accept whichever setup leaves, as the design approved.** T10 then passes with `_dmarc`
  either unchanged or exactly setup's `p=reject`, and T11 declares the result. Before a
  `p=reject` stays, the observer reads the existing DMARC reports for senders other than
  Stalwart and Cloudflare.

Either way, the design, spec, plan, and end-to-end check must name one end state.

### M2. 907.life stays dark for the whole run, not only until "setup's first deploy"
`correctness` · design:15, design:21, design:100, spec:79 (the site brief's workers.dev line),
plan:61, plan:137

**Defect.** The design promises the domain is dark "only from the teardown to setup's first
deploy". The spec moves the domain to T10, though, which runs after T12's acceptance and its
packet. The path is T5 → T6 → T7/T8 → T9 → T12 → P5 → T10. That is about 600 or more path
minutes, plus the open-ended waits whenever a blocker sends a builder to the conductor
(design:111).

For that whole window the apex has no proxied record, so three live things break:

- the `/.well-known/{jmap,caldav,carddav}` redirects to ward, which are Hylki's only discovery
  path;
- `privacy.html` (M3);
- the old feeds, `/feed.xml` and `/feed.json`.

**OWNER FORK.**

- **(a) Connect the domain in T6's first setup run (recommended).** The design already allows
  "down or shows the bare starter", the redirects come back within the first hour, and T10
  shrinks to the snapshots, sign-in email, and Builds.
- **(b) Keep T10 last, and restate the design's dark window as the whole run.** Geoff accepts a
  Hylki discovery outage and the loss of the privacy page for that time.
- **(c) Keep a proxied placeholder at the apex until T10.** This adds an apex record that setup's
  Custom Domain attach has to replace.

### M3. `privacy.html` isn't exported, briefed, or accepted
`correctness` · design:12, spec:76-82 (site brief), plan:85 (T2 plain export)

**Defect.** The export names posts, About, media, and settings. `static/privacy.html` is none
of those, and Google requires it for the Geoff's Tools OAuth app (`gws` and `clasp` sign-in). It
disappears at T5 and never comes back.

**Fold.** Add `static/privacy.html` to T2's plain export and to the site brief as a page the new
site must keep at `/privacy.html`. T12's acceptance checks that `https://907.life/privacy.html`
answers 200 with the `glw@907.life` contact.

### M4. Running `retire-project` as written would wreck live mail and shared secrets
`correctness` · design:100-106, spec:118-127, plan:98-103 (T4), plan:107 (T5)

**Defect.** The plan says the retirement runs "per `retire-project`" but never says which of the
skill's teardown steps don't apply. Read literally, the skill would do five things this run
must not:

- step 4.1 removes the DNS records;
- step 4.3 removes "the secrets from the store and the registry", and the store's
  `GITHUB_APP_*` belong to the shared App;
- step 4.4 parks a kept domain with `MX 0 .` and `v=spf1 -all`, which would kill ward's mail;
- step 4.5 deletes the repo;
- step 5 says to "rerun the Cloudflare inventory and show it empty".

The zone's Email Sending onboarding is shared with the monitor and the new site, and nothing in
the inventory marks it shared.

**Fold.** T4 and T5 name the steps that run (1, 2, 3, the Worker, D1, and R2 half of 4.2, and 5
with a "remaining is expected" list) and the steps skipped with their reasons:

- 4.1: the zone stays;
- 4.3: limited to sole-owner keys, never `GITHUB_APP_*`;
- 4.4: not run, because the domain stays live with ward's mail;
- 4.5: replaced by the rename and archive.

T4's inventory marks the Email Sending onboarding, `cairn-build`, the GitHub App, and the zone
as shared and kept.

### M5. The export can come back silently empty, and T2's proof is weaker than the skill's
`correctness` · plan:79-87 (T2)

**Defect.**

- T2's acceptance compares the archive against "`wrangler r2 object` listing's count", and that
  command doesn't exist.
- In wrangler 4, `d1 export` and `r2 object get` default to the local simulator unless they get
  `--remote`. A run that leaves the flag off archives empty data, and the decrypt-and-count check
  can't tell.
- T2 checks only that the archive decrypts, plus counts. It skips the skill's restore test
  (clone the bundle, load the SQL into SQLite), the R2 copy at `servers-archive` with
  `rclone check`, the sha256, and any byte-level check of the objects.
- Only the "editor rows" are named, but the skill says every D1 export.

**Fold.** T2's acceptance becomes:

- the remote object list from the R2 API, or `rclone ls` over the R2 S3 endpoint, matches the
  archive by key and size;
- `wrangler d1 export cairn-907-auth --remote` makes a full dump, and its `editors` row count
  equals a remote `SELECT count(*)`;
- the archive restores to scratch: the bundle clones and the SQL loads;
- `rclone check` passes on the R2 copy, and the sha256 is recorded.

Every one of these fails closed before T4's packet goes out.

### M6. The old checkout and its worktrees outlive the rename and point at the new repo
`correctness` · plan:107 (T5), plan:156 (T13)

**Defect.** After T6 creates the new `glw907/907-life`, the old `~/Projects/907-life` checkout
and its three worktrees still use `origin = glw907/907-life`, which is now the new repo. Two
things can go wrong between T6 and T13:

- **A push lands in the new repo.** Any session's `git push` of a branch (the remote has
  `docs-layout`, `pass-c-contact`, and `lean-cutover`) puts old history into the new repo,
  where Workers Builds would build it.
- **T13's move breaks things.** Moving the directory while a session or the live `workerd` runs
  there breaks them, and the move also breaks the absolute worktree links under
  `.git/worktrees/`.

The bundle also misses uncommitted work in the worktrees, including the locked one.

**Fold.**

- At T2: every worktree's `git status` and unpushed branches go into the inventory, and the
  skill's commit-or-drop rule applies.
- At T5, right after the rename: `git remote set-url origin` to `907-life-legacy` in the old
  checkout. The archive happens in the same step, before T6.
- At T13: `pgrep -f ~/Projects/907-life` comes back empty first, then `git worktree repair`
  runs after the move.

### M7. T5's not-found check fails on GitHub's rename redirect
`correctness` · plan:108 (T5 acceptance)

**Defect.** After a rename, GitHub redirects the old name until something else claims it. So
`gh repo view glw907/907-life` succeeds and shows `907-life-legacy`, which makes T5 fail at the
irreversible step. It invites an observer "fix", too. Setup's #200 name-clash check might also
follow the redirect and report a clash.

**Fold.** T5 checks that `gh api repos/glw907/907-life --jq .full_name` prints
`glw907/907-life-legacy`, the redirect, and that `isArchived` is true. Before the teardown, T1
or the conductor confirms how the #200 check treats a redirected repo name.

### M8. The DNS snapshot diff and the restore are unsafe while the servers conductor is live
`correctness` · spec:133-137, plan:137-138 (T10)

**Defect.** `conductor-servers` can run `dns.sh --apply` during T10. The before-and-after diff
would then charge its changes to setup, and "restore that record from the before snapshot by
API" would revert a legitimate servers change. The restore also bypasses the declared writer:

- for a name `dns.sh` declares, `dns.sh --apply` is the restore;
- the apex `@ TXT` and `@ MX` are declared sets, and the header says "each declared name and
  type owns its whole record set". So any apex TXT that setup adds is deleted at the next
  `--apply` unless T11 puts it in the same set.

**Fold.**

- Ask `conductor-servers` for a write freeze covering T10's window, and record its
  acknowledgement before the before-snapshot.
- A restore goes through `dns.sh --apply` for a declared name, and through the snapshot only for
  an undeclared one.
- T11 confirms that `dns.sh` merges one name and type across files before it splits an apex
  record into `dns/907-site`.

### M9. T11's acceptance can't pass, because undeclared records already exist
`correctness` · plan:142-143 (T11)

**Defect.** `dns.sh --check` already reports five undeclared records today: the three
`cf-bounce` MX records, the `cf-bounce` TXT, and `cf-bounce._domainkey`. They come from the old
site's onboarding, not from T10. T11 only declares "every record T10's diff added", so "no
undeclared record" fails. The new apex AAAA from the Custom Domain is managed by the Workers
domains API, and declaring it would let `dns.sh --apply` try to own a record it doesn't manage.

**Fold.** T11 declares the Email Sending records whatever their age. It excludes the
Worker-managed apex record, with a comment that says why, and its acceptance names the excluded
records explicitly.

### M10. Setup's state record lands in a denied path, or in Geoff's real one
`correctness` · spec:22-24, spec:30, spec:148 (the browser-approval timeout row)

**Defect.** Setup keeps its state at `homedir()/.config/cairn/sites/`. With the planned config:

- **Sandboxed**, `denyRead ~/.config/**` stops setup reading its own record, so the "re-run
  resumes from setup's saved state" path in the failure table breaks.
- **Unsandboxed**, through the excluded-command fallback, setup writes the setup token, the
  App's client secret, and the webhook secret into Geoff's real `~/.config/cairn/sites/`, next
  to an existing rc.2 record.

**Fold.** B1's per-builder clean `HOME` covers this the way a newcomer's machine would, with no
undocumented variable. T1 proves a scaffold run writes its record under the clean home.

### M11. The unsandboxed fallback drops Bash read isolation, and the deny list misses real paths
`correctness` · spec:22-24

**Defect.** Spec:24 says "the Read deny rules still hold" for commands that run unsandboxed.
Read rules govern the Read tool, not a Bash child, so an excluded `npx` command can read
anything. The deny list also leaves out `~/.ssh` (where `id_ed25519` is readable by Read today),
`~/.local/share/keyrings`, and `~/.local/state`.

**Fold.** B1's clean `HOME` plus `env -i` closes most of this. Add `Read(~/.ssh/**)` and
`Read(~/.local/share/**)` anyway. T1 runs its denied-read probe in the excluded-command form as
well, if that form is used.

### M12. The likeliest setup failure is first tried after the irreversible teardown
`correctness` · spec:24, spec:139-149, plan:65-74 (T1), plan:112 (T6)

**Defect.** The spec names the sandbox breaking setup's local OAuth callbacks (GitHub's App
manifest flow and `wrangler login`) as the known risk. Its proof doesn't run until T6, though,
after T5's deletes. The failure table has no row for "setup fails after the teardown", and
nothing says what restoring the old site would take: rename it back, un-archive it, recreate D1
from the export, re-upload R2, and deploy the old `main` from the bundle.

**Fold.**

- At P1's sitting, prove `npx wrangler login` and a localhost callback under the final clean-room
  config, with Geoff clicking. That way T1 can't pass on a config that breaks setup.
- Add the failure row: the site stays dark, the observer reports, and Geoff chooses between
  waiting on a fix and restoring.
- The retirement packet states that a restore is a rebuild from the archive, so the
  irreversible approval is informed.

### M13. Nothing checks that the migrated posts are faithful, and T12 invites edits to them
`correctness` · plan:123-128 (T8 acceptance), plan:147 (T12)

**Defect.** T8 checks that the posts answer 200 and carry their tags. A builder that normalizes
quotes, rewraps lines, or rewrites frontmatter (title, date, description) passes anyway. T12
then runs the `standards:content-review` AI-tell gates on `src/content/**`, which is Geoff's own
published prose, so the fix rounds may "correct" his writing. That is silent corruption in both
directions.

**Fold.** T8's acceptance adds a byte-level diff of each post body against
`handoff/content/`, plus a check that title, date, description, and tags equal the export. T12
runs the content-review gates only on new copy: project pages, the intro sentence, and About if
the builder rewrote it.

### M14. The setup token outlives the run, and P2's permission list is short
`correctness` · plan:17 (P2), plan:27, spec:145 (the token-missing row)

**Defect.**

- P2 says "Setup deletes the token when the email chapter ends." README:506 says the opposite
  for this case: deleting setup's local copy "is not the same as the token being gone". The
  token stays live at Cloudflare with all-zones scope, and it stays in the age store and the
  registry, where `secret-receive` put it. No step revokes it.
- T10 runs `--connect` for Workers Builds. chapter3's setup token needs "the same five
  chapter 2 already asked for, plus Workers Builds", and P2 lists only the five. Mid-run, setup
  would then ask for a second token, created outside the store.

**Fold.** P2's token adds Workers Builds, limits Zone Resources to 907.life, and sets a TTL.
T13 revokes it at Cloudflare by API and removes it from the age store and the registry. T13's
acceptance confirms the token verify endpoint reports it gone.

## Minor

### m1. T4's "exactly four targets" check conflicts with the inventory the skill requires
`correctness` · plan:103

The skill's inventory lists shared and kept items too: Turnstile, Actions secrets, worktrees,
Email Sending, and `cairn-build`. "Fails if it names anything else" forbids those rows.
**Fold.** Split the check: the delete list is exactly the four targets, and the inventory may
list kept rows marked shared.

### m2. The bucket's object deletes and the Worker's domain detach are missing from the dry run
`correctness` · spec:122, plan:107

`r2 bucket delete` refuses a bucket that still has objects, so T5 needs a bulk object delete.
That delete is irreversible too, and the dry run doesn't list it. The skill's order also removes
the custom domain before the Worker is deleted. **Fold.** The dry run lists the object purge
by count and the custom-domain detach as their own steps.

### m3. The old deploy workflow can still fire after the rename
`correctness` · plan:107

Until the archive, a push to `907-life-legacy` runs `deploy.yml`, which deploys the old
`wrangler.toml` to the Worker named `907-life`. After T6, that is the new site. The Actions
secret `CLOUDFLARE_API_TOKEN` also stays behind. **Fold.** Archive in the same step as the
rename, before T6, and revoke the deploy token at Cloudflare if it is sole-owner.

### m4. Exported editors are never re-invited
`correctness` · design:101

The editor rows are archived, but the new site starts with only the owner, so any other editor
quietly loses access. **Fold.** T12 lists the exported editor emails. Either they are
re-invited, or Geoff confirms in the packet that the site is owner-only.

### m5. The logs hold the owner sign-in link and can hold a token
`correctness` · spec:34, plan:75

The stream-json logs capture the owner sign-in URL from P4 and any token a tool echoes. T1's
probe log is committed and pushed to the initiatives `main`. **Fold.** Scan the probe log for
secret values by name before it's committed (the observer checks this; the builder never does).
Keep builder logs out of git, and delete them at T13.

### m6. The release conductor can move `latest` partway through the run
`optional` · design:111, plan:112

`npx create-cairn-site` resolves a dist-tag each time it runs, so T6, T7's scaffold, and T10 can
land on different versions if the conductor publishes in between. **Fold.** Record
`npm view create-cairn-site dist-tags` at each launch. A version change is either a deliberate
resume on a fix or a flag.

### m7. Old URLs and feeds aren't carried over
`optional` · spec:76-82

The old site serves `/feed.xml`, `/feed.json`, `/archives`, `/tags`, and the post paths through
`[...path]`. The brief names none of these, so subscribers can lose the feed or get duplicate
entries, and inbound links can break. **Fold.** The brief lists the old URLs, and T12 checks
that each one answers 200 or 301.

### m8. The builders share one config directory and can read each other's sessions
`optional` · spec:9, spec:14

Memory is off, but session transcripts under the shared `CLAUDE_CONFIG_DIR` aren't denied. That
leaks between the two runs, and B's transcript carries the sign-in link. **Fold.** Add
`Read(~/.local/state/cairn-cleanroom/**)` to the deny list, with each builder's own working tree
still allowed.

### m9. The `Bash(*cairn-build*)` deny rule distorts the test
`optional` · spec:25

The rule also blocks harmless reads, such as grepping the docs for `cairn-build`, which a
newcomer would do. And it doesn't stop setup's own Builds calls, which happen inside one
`npx create-cairn-site` command. **Fold.** Drop it. The standing answer and B2's destructive-verb
denies cover the real risk.

## Over-ceremony

### o1. T12's whole-branch review starts from the scaffold commit
`optional` · plan:147

**Cost.** "From setup's first commit" pulls the entire generated scaffold into
`standards:diff-reviewer`. That is thousands of template lines the builders didn't write, which
costs a large share of T12's tokens and some of its 150 minutes for no finding a newcomer test
needs. **Fold.** Review `<scaffold commit>..HEAD`.

### o2. The content-review gates run on the migrated posts
`optional` · plan:147

**Cost.** This is the over-ceremony half of M13. The gates run over eight published posts, and
every finding is one that shouldn't be acted on. **Fold.** Covered by M13's fold.
