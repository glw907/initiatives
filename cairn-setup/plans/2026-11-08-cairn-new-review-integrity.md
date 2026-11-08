Initiative: cairn-setup

# cairn new: review, data integrity and failure risk lens

Targets: `2026-11-08-cairn-new-plan.md` (plan) and `../specs/2026-11-08-cairn-new-spec.md` (spec),
against the binding design `../specs/2026-11-08-cairn-new-design.md`. Code read at cairn-cms
`d27ea60b0`. Reviewer: fresh context, 2026-11-08. No design ruling is re-argued; every fold below
works inside the approved design, except the one item marked OWNER FORK.

Counts: 2 blockers, 13 majors, 14 minors (two of them over-ceremony). Ranked by consequence.

## Blockers

### B1. Resume would pick up a site record `cairn new` never wrote (`correctness`)

Location: spec:103-108 ("An unfinished run is any record whose step is not the terminal one";
"with one unfinished record resumes it"); plan:223-228 (T1.4).

Defect. The setup record lives in the existing registry (spec:97), which already holds records
from two other writers: the Node wizard (19 step strings, `tool/internal/spine/step.go:11-31`) and
`cairn adopt` (step `live`, `tool/internal/adopt/adopt.go:178`). Geoff's own registry
(`~/.config/cairn/sites/`) holds one such record today, at step `live`, with Node-era keys
including App credential fields in plaintext. Whatever terminal constant `cairn new` adopts, every
Node record at another step (an abandoned rc install, a site at `email-live` or
`config-reconciled`) qualifies as "unfinished". A bare `cairn new` on that machine would resume a
foreign record: overwrite it through `Store.Save` (store.go:164-168, "replacing whatever the
registry held"), compare "our" ids against a live production site's ids, and run the installation
cleanup in approval 4 against an installation it did not create.

Fold. Give setup records a typed discriminator (for example a `setup` object carrying the run id
and a setup schema version), and make resume candidates only records that carry it. T1.4 gains a
test: a registry holding a Node record at each of the 19 steps plus an adopted record yields zero
candidates, and none is written.

### B2. An all-repositories installation can outlive a kill, a timeout, or a failure (`correctness`)

Location: spec:236-253 (approvals 3 and 4); plan:291-300 (T1.10 acceptance: "a run killed after
each of the four approvals resumes").

Defect. The design's bound on the over-grant ("exists for about five seconds", design:190) holds
only on the happy path. The dangerous windows are inside the approvals, not after them: between
the approval 3 callback and its `DELETE /app/installations/{id}` (the repository create and its
422 suffix loop run in between), and inside approval 4's refuse-and-resend loop. A Ctrl+C, a
crash, the 30-minute stop, or a failed repository create in those windows leaves an App with
`administration: write` installed on every repository the owner has, with its private key in the
keyring. Nothing in the spec deletes it on resume, and an owner who never reruns keeps it. The
plan's kill tests sit at the four boundaries, where the window is already closed.

Fold. (1) The callback records the installation id before any other call. (2) Deletion of a
non-selected installation runs on every exit path of the chain (error, Ctrl+C, clock stop). (3) On
resume, and in any run whose record holds an App id, the first GitHub act is the App JWT's `GET
/app/installations`, deleting every installation whose `repository_selection` is `all` or whose
list is not exactly the recorded repository. T1.10's acceptance adds kills between the approval 3
callback and the delete, and inside approval 4's loop, each ending with no over-grant left.

## Majors

### M1. The never-printed rule's scrubber cannot see the credentials setup holds (`correctness`)

Location: spec:132-134 ("Output goes through `logx`'s scrubber"); plan:296-300.

Defect. `logx.New` takes its needles once, when cmd/cairn wraps the streams before any command
runs (`tool/internal/logx/logx.go:1-5,46`). Every setup credential arrives mid-run: the OAuth
pair, `ghu_` and its `ghr_` refresh token, the `ghs_` installation token, the App key and client
secret, the deploy key, and the sign-in token. None is registered. The App key is a multi-line
PEM, which logx states it cannot match (logx.go:32-33). And a Bubble Tea inline renderer writing
through a newline-buffered Writer would hold cursor sequences, so the terminal view probably
bypasses logx entirely.

Fold. logx gains a registration call the runner reaches through an injected sink the moment each
credential arrives; a PEM registers line by line (each base64 line clears `MinLength`). The view
writes through the same scrubbing path, or ADR-0004 states it renders only typed event fields and
the test proves no credential reaches a frame. T1.10's "never appears" test widens to the record
file, the plan file, stderr, the NDJSON stream, every loopback response except the one sign-in
redirect, and provider error text surfaced in the four-part failure.

### M2. T1.4's no-secrets acceptance names a test that cannot fail on the stated condition (`correctness`)

Location: plan:226-227 ("a record holding a secret-shaped value in any typed field fails the
existing no-secrets test").

Defect. The existing test reflects on exported field names and json tags only
(`tool/internal/record/record_test.go:133-169`). It cannot see a value. And `record.Record`
carries every untyped key, secrets included, through `Extra` (record.go:1-4, 59-60), which is
exactly how the Node wizard's plaintext client secret and webhook secret reach the registry
today. A conversion response copied into the record's `Extra` would pass every test the plan
names.

Fold. T1.4 adds a value test: after a full fake run, marshal the record and fail when it contains
any credential the fakes issued, or any key under `Extra` that setup wrote. Keep the reflection
test as is.

### M3. Create-then-record gaps orphan resources, one of them a no-expiry account-wide token (`correctness`)

Location: spec:89-93 (ids stored "the moment its create returns"); spec:181 (deploy key, "no
`expires_on`"); spec:231-234 (conversion).

Defect. A crash, kill, or failed `Save` between a provider's 2xx and the record write loses the id
of a resource that now exists. On resume: D1 and R2 answer "name exists" for setup's own
resource, and no rule says whether to adopt it or suffix (a suffix diverges from the repository
name already created, breaking spec 3's one-suffix rule). The repository answers 422 and the spec
says to take the next suffix (spec:242), orphaning setup's own private repository. Worst is the
deploy key: `POST /user/tokens` returns the value once. Lose it before the sealed PUT and the
owner's account keeps a never-expiring token with Workers Scripts, D1, and R2 write over every
Worker the owner has, and each failed rerun mints another.

Fold. Write the intent (the name about to be created) to the record before each create. On
resume, a "name exists" for a recorded intent reads the resource by exact name and adopts it only
when it is empty (D1 with no tables, an empty bucket, a private repository with no commits). Name
the deploy key with the run id, record its token id as soon as the create returns, and on resume
before step 5 completes delete the recorded token by id and mint a new one. T1.10 adds a kill
between each create and its record write.

### M4. The App's private key has one home, and nothing checks it is writable (`correctness`)

Location: spec:110-112, 231-234; `tool/internal/secrets/keyring.go:325-336,450-458`.

Defect. GitHub returns the PEM and client secret once, at conversion. The spec's only store for
them is the keyring, yet the opening's prerequisite list (spec:279-281) checks git, Node, the port,
and the template fetch, not the keyring. `Set` gives up after 2 seconds on a locked collection and
reports `ErrKeyringUnavailable` while the abandoned goroutine may still complete the write once the
owner unlocks, so a "failed" write can land later and escape the end-of-run delete. A failed
write after conversion leaves an App nobody can authenticate as, and GitHub has no delete API
(spike GH, "Cleanup").

Fold. The opening writes, reads, and deletes a throwaway entry under a longer deadline, so a
missing or locked keyring fails before anything exists. At conversion, persist the key and secret
before the record step advances; if persistence fails, stop with the four-part failure whose "what
setup already did" names the App and links its settings page for deletion. The end-of-run delete
also sweeps entries by the run's name prefix, not only those whose `Set` reported success.

### M5. A resume can find its Cloudflare grant dead, with no path back (`correctness`)

Location: spec:118, 125-127; plan:241-247 (T1.5).

Defect. Refresh revokes the previous pair (spike CF, "Confirmed"). A crash between the provider's
refresh answer and the keyring write, a keyring failure at that moment, or a refresh token that
expires while a run waits (an abandoned run, or a long gap between `--plan` and `--apply`) leaves
no valid Cloudflare credential. The spec has no re-consent on resume, so the run can neither
continue nor clean up what it made on Cloudflare. T1.5's acceptance ("leaves the old pair marked
superseded") asks for a marker in the same store whose write just failed, and no reader for the
marker exists.

Fold. Drop the superseded marker. On a persist failure, stop resumable. On resume, an
`invalid_grant` or 401 from the stored pair reruns approval 1 alone, with its own `waiting` state,
and refuses a grant whose account list lacks the recorded account id. T1.10 adds this resume, and
T1.5's test becomes "a failed persist never returns the old pair and stops resumable".

### M6. Two concurrent runs can drive one record (`correctness`)

Location: spec:103-108; plan:567 (standing answer "any loopback port accepted: an ephemeral port");
`tool/internal/store/store.go:164-168`.

Defect. A second `cairn new` started while one runs sees exactly one unfinished record, the live
one, and resumes it. With an ephemeral port nothing stops it. Both then create (two databases, the
record keeping whichever wrote last), both push, both issue sign-in tokens. `Save` is
last-writer-wins, so resource ids are lost and the losers are orphans. The fixed port 49152 would
act as a mutex only while the loopback is bound.

Fold. A per-record lock (an exclusive-create lock file beside the record holding the pid and
host, with stale detection by pid) taken before any write; a locked record is reported "running"
by `cairn new status` and is never a resume candidate. Keep the fixed port whatever the probe
finds (see O2), so a second run's bind failure reads as "another setup is running".

### M7. Setup can take over a hostname or a Worker it did not create (`correctness`)

Location: spec:175 (address check reads A, AAAA, CNAME), 183 (custom domain `PUT`, "idempotent"),
80-87 (Worker name checked by a list at plan time); spec:317-321 (`wrangler deploy` in Actions).

Defect. A Worker custom domain attached to another Worker, or a Workers route on the hostname, may
not show as an A, AAAA, or CNAME record, and a custom domain attach replaces what the hostname
served (Cloudflare's Vercel guide: "The custom domain replaces the existing ... DNS record for that
hostname"). The check also runs at the opening or the summary while the attach runs at step 7,
after the owner may have left. Likewise, the Worker name is checked free at plan time, and the
first `wrangler deploy` overwrites any Worker of that name that appeared since. The design's rule
"setup never changes a DNS record it didn't create" (design:439) needs these reads to hold.

Fold. The address check also reads `GET /accounts/{id}/workers/domains` (filtered by hostname)
and `GET /zones/{id}/workers/routes`, and refuses any match. Step 7 rechecks just before the
`PUT`. Step 4 rechecks that no Worker of the name exists before the push that triggers the first
deploy, and stops with the four-part failure if one does.

### M8. `--apply` trusts an editable plan file (`correctness`)

Location: spec:375-379; design:267-275.

Defect. Between the two calls the plan file sits on disk where the agent edits the open choices,
and nothing says apply refuses edits to the rest. An edited Worker name, account id, zone, or
address, whether a mistake or a prompt-injected agent, sends writes to an existing Worker or zone,
past every check that ran at plan time.

Fold. The plan file carries the run id. Apply loads the record under the lock (M6), takes from the
file only the open fields (email, address, and the account and zone from the listed options),
recomputes every derived name from the record, and reruns the free checks and the address check.
A test edits each closed field and expects a usage error with nothing created. The file is written
0600 and holds no credential.

### M9. Setup's sign-in SQL couples the tool to the engine's schema across two release lines (`correctness`)

Location: spec:340-345; design:165-169 (the tool and engine release separately; the template
tracks `latest`).

Defect. Setup inserts `editor` and `magic_token` rows through the D1 query API with SQL compiled
into the tool, while the site pins whatever engine `latest` was at fetch time. An engine release
that changes either table (migrations `0000` to `0004` already reshaped `magic_token` once) makes
an older tool write a malformed or rejected row into a live site's auth table, with no gate
between them. The spec's insert also skips `issueToken`'s replace-and-sweep batch
(`src/lib/auth/store.ts:104-113`), so a resumed step 8 leaves two live rows for one email.

Fold. Setup refuses to seed when the fetched engine version falls outside the range the tool was
built and tested against, or when the site's applied migrations (`d1_migrations`) hold a name the
tool does not know, with the four-part failure pointing at the sign-in page. The insert runs as one
batch mirroring `issueToken` (delete the email's rows and expired rows, then insert).

### M10. S1 writes to Geoff's production Cloudflare account with an incomplete, non-resumable cleanup (`correctness`)

Location: spec:392-400; plan:55-60 (pre-flight 4), 203-212 (T1.0).

Defect. `carin-test.org` lives in Geoff's single account, beside every production Worker
(`cloudflare-estate-inventory.md`, header). The OAuth consent covers every zone in it, so a
recorder bug that picks "the first active zone" writes to a production site. The cleanup list
(Worker, database, bucket, minted token, repository, App) omits: the custom domains and the DNS
records they create; the Advanced Certificate each custom domain issues, which Cloudflare does not
delete with the domain (Workers custom domains docs, "Certificates"); the Email Sending subdomain
the `POST` route needs, with its DNS records, since the apex is already onboarded (spike CF); and
the OAuth grant, whose revoke may 403 (spec:149-152). The minted token follows production's "no
`expires_on`", which breaks the estate's token scheme (TTL on a powerful token). A crash mid-run
leaves all of it with no ledger.

Fold. In T1.0: a write guard that refuses any Cloudflare write whose path is not the test zone's id
or a name carrying the run id; hostnames of the form `rec-<runid>.carin-test.org`, checked absent
first; an `expires_on` of one hour on the minted token; a ledger (0600, outside the repository) of
every created id written before each create; `record.sh --cleanup <runid>` that sweeps from the
ledger and verifies each delete by a read that 404s; and a results line per resource. If revoke
fails, the results file says so and pre-flight 4's check gains "Geoff confirms the grant is
removed" (or records that it cannot be removed without deleting the client). Use a dummy value,
not the minted token, for the sealed-secret recording.

### M11. The recorder runs unreviewed with Geoff's whole secret store, into the executor's worktree (`correctness`)

Location: plan:55-60, 203-212, 78-90; spec:388-390.

Defect. Four gaps meet here. (1) T1.0 is agent-written code that Geoff runs after `source
~/.local/secrets`, which exports every workstation secret (Geoff's admin Cloudflare token among
them) to Node and its dependencies; a helper reading `process.env.CLOUDFLARE_API_TOKEN` would
silently record under the wrong credential. The plan reviews it only at T1.11, after S1. (2) S1
writes `tool/testdata/fixtures/` in the P1 worktree while the executor keeps committing there
(plan:211-212), which is two writers in one worktree, against the workstation's one-executor rule.
The plan names no directory to run `record.sh` from and says nothing about who commits the
recordings or who checks them first. (3) The scrub is shape-based ("a planted token shape, email,
account id, and `ghu_` value"). It misses `ghr_`, `ghs_`, the PEM, the client secret, and
Cloudflare OAuth token shapes nobody has recorded yet. (4) T1.7's JWT test needs a working RSA key,
which tempts a builder to keep the conversion's real PEM in the fixture.

Fold. Dispatch `standards:diff-reviewer` (task scope) and `standards:web-auth-security-reviewer`
on T1.0's commit before the S1 notice. `record.sh` reads only the named variables it needs, in a
subshell, and launches node under `env -i` with an allowlist. S1 writes to a staging directory
outside the worktree. The recorder scrubs by key name and by exact value (every credential it
handled is a needle), and a final pass greps the staged corpus for each held value. Only then does
the executor copy, run the hygiene test, and commit. The conversion fixture's PEM is replaced by a
committed test-only key, and the hygiene test asserts the corpus PEM equals it. Evidence and
controls files go to the staging directory, never the repository.

### M12. A resume re-resolves what it must pin (`correctness`)

Location: spec:53-59 (template at `dist-tags[latest]`), 78 (local folder refused when non-empty),
258-261 (push).

Defect. On resume, `latest` may have moved, so a re-scaffold writes a different engine than the
one the plan showed. The opening refuses a non-empty folder, which is setup's own folder on a
resume. A re-scaffold after a push that landed makes a new root commit, so the second push is
rejected as non-fast-forward. A folder the owner moved or deleted is not detected.

Fold. The record holds the resolved version and integrity, the folder's absolute path, and the
local commit's SHA. Resume fetches that exact version, treats the folder as its own only when HEAD
matches the recorded SHA, and past `pushed` compares the remote ref instead of pushing again.

### M13. An abandoned run keeps its credentials and captures every later `cairn new` (`correctness`) OWNER FORK

Location: spec:105-108, 118-120; design:56 ("Nothing locks the owner out"), 203 (credentials "only
while setup runs").

Defect. With one unfinished record, `cairn new` resumes it. An owner who quit at approval 2, or a
run killed during step 8, makes every later `cairn new` resume that run, with no way to start a
second site except deleting the record by hand. That also strands the keyring entries (the refresh
token carries `user-api-tokens.write`) and an orphan App. The design rules out an undo command.

Options. (a) The terminal's resume choice always includes "Start a new site", and the agent lane
gets `--new`; the stale run's credentials stay until it is resumed. (b) (a), plus `cairn new
status` lists what each unfinished run still holds (keyring entries by name, the App, the
repository) with the docs' credentials page saying how to remove each. (c) Docs only: the
credentials and recovery pages say how to delete a record and its entries by hand.
Recommendation: (b), which adds no undo command and keeps the owner from being locked into an old
run.

## Minors

### m1. The child environment deny-list misses git's own leak paths (`optional`)

Location: spec:129-131, 258-261. The push's child gets the token in `GIT_CONFIG_*`, so a user's
`GIT_TRACE*` or `GIT_CURL_VERBOSE` prints headers to the stderr setup may surface. A 401 hands
control to the user's credential helper, which may push under the owner's personal token. The
background `npm install` of a fresh dependency tree inherits every other secret in the user's
environment. Fold: an allowlist environment for children; for git, unset `GIT_TRACE*`,
`GIT_CURL_VERBOSE`, and `GIT_ASKPASS`, and set `GIT_TERMINAL_PROMPT=0` and an empty
`credential.helper` through the same `GIT_CONFIG_*` entries.

### m2. The runner's git config entries can clobber the harness's, and the proxy should fail closed (`correctness`)

Location: spec:258-261, 408-418. Both use `GIT_CONFIG_COUNT`. A runner that sets `COUNT=1` drops
the harness's `insteadOf`, so the CI push goes to the real github.com. Fold: the runner appends
after any inherited count. The harness proxy refuses `CONNECT` to any host it does not fake (the
HTTPS wait's address, the Email Sending send), and T2.1's self-test asserts the refusal.

### m3. The loopback's sign-in redirect needs to be one-shot and bound to the tab (`correctness`)

Location: spec:343-344, 294-296. Another local user, or any local process, can request the
loopback route that answers with the sign-in URL and read its `Location`. Fold: the route answers
once, only to a request carrying a cookie the loopback set on `/`, and then 404s. Also cite whether
GitHub returns `state` on the install callback (spec:236); if it does not, that callback is
unauthenticated and the spec should say so.

### m4. In the agent lane, step 8's setup tab belongs to a process that has exited (`correctness`)

Location: spec:343-345, 375-379. `--plan` ran the loopback, and it exits before `--apply`. The spec
does not say whether `--apply` opens a new tab for the redirect, or where else the token goes.
Fold: say that `--apply` opens the loopback through the opener for step 8 with its own `waiting`
state, or skips the redirect and relies on the email, and keep the token out of argv either way.

### m5. Decide 2's emailed token is unbound, which relaxes the engine's 0004 binding (`optional`)

Location: plan:110-118; spec:353-360. The engine binds request tokens to a browser so that "a mail
scanner following the link, an attacker putting their link in front of a victim" refuses
(`src/lib/sveltekit/auth-routes.ts:363-366`). An unbound emailed row confirms in any browser for
10 minutes. This is within the engine's existing hand-seeded path, but the Decide 2 packet should
say so in one sentence, so Geoff rules with it in view.

### m6. The first save of a new record can overwrite another site's record (`correctness`)

Location: spec:102 (`<slug>-<6 hex>`); store.go:164-168. Two sites with one slug share 24 random
bits, and `Save` replaces silently. Fold: the first save of a run refuses an existing id (a `Load`
miss check under the lock, or an exclusive create), retrying with a new suffix.

### m7. Tarball extraction needs path and type hardening (`correctness`)

Location: spec:53-57 ("extract only `package/template/**`"). A prefix match on an unclean path lets
`package/template/../../x` through. Fold: clean each entry's path and refuse one that escapes the
target, refuse links and devices, and cap the total size. Add unit cases to T1.9.

### m8. The record needs a setup schema version for upgrades and downgrades (`correctness`)

Location: spec:95-112. `npm create cairn-site` installs the newest binary each time it runs, so a
resume can run a newer tool than the run's, or an older one. Fold: the discriminator in B1 carries
a setup schema version; a tool refuses to resume a newer one with an upgrade message. T1.4's
round-trip test gains a record from the previous schema once a release exists (a `// WATCH:` until
then).

### m9. Keyring entry names and sizes (`correctness`)

Location: spec:118-120; keyring.go:323, 450-458. Spec says "one entry per run" only for the OAuth
pair. Fold: every setup entry is named under a run-id prefix that `cairn auth list` and `cairn
auth unset` do not treat as theirs. Add a test that the PEM and the OAuth pair fit Windows'
2,560-byte credential blob, since go-keyring's `ErrSetDataTooBig` flattens to "unavailable" here.

### m10. The App key leaves the keyring before anything proves the Worker can use it (`optional`)

Location: spec:120, 182. A wrong encoding in the Worker secret is found only when the first editor
saves, by which point the key's only other copy is gone. Fold: the done screen's next steps, or
the credentials page, name the key rotation page as the recovery. A proof step is not worth its
cost.

### m11. Retired wizard records keep plaintext App secrets on disk (`optional`)

Location: plan:512-521 (T6.4). The registry's Node-era records carry the client secret and webhook
secret in plaintext (`record/record.go:59-60`), and nothing will ever clean them. Fold: one
`MIGRATION-NOTES.md` line in T6.5 saying so, and how to remove them.

### m12. The first by-hand platform publish should carry no binary (`optional`)

Location: plan:647-648. A hand-published package holding a binary built on Geoff's machine breaks
the provenance chain for the first version. Fold: publish a `0.0.0` placeholder with no binary to
register the trusted publisher, as the release skill does for a new name.

### O1. Over-ceremony: S1 should not manufacture live error states (`optional`)

Location: plan:276-281 (T1.6 needs "zone pending" and "missing scope 403" bodies); plan:565.
Recording a pending-zone body live means adding a zone to Geoff's production account and removing
it. A missing-scope body needs a second consent, and S1 has one. Cost: S1's clock past its 20
minutes, plus more cleanup risk on the production account. Fold: S1 records success bodies and the
errors that are free to provoke (name exists, a call outside the granted scopes). Zone pending
takes the docs-sourced body with the `pending live recording` note, under the existing standing
answer.

### O2. Over-ceremony: the any-loopback-port probe is moot (`optional`)

Location: spec:140-142; plan:567. A fixed port is the cheaper mutex for M6, and the client is
registered for 49152 anyway, so the probe's "yes" branch would be declined. Cost: one S1 probe, one
standing answer, and an ephemeral-port path through T1.8's tests. Fold: drop the probe and fix the
port. A bound port fails in the opening with what to do.

## Checked and sound

- Store writes are atomic, fsynced, owner-only, and refuse symlinks (store.go:164-219).
- The gate's Playwright driver keeps secrets out of children, screenshots, and logs
  (`scripts/gate/browser.mjs:132-151,210-225,419-428`). The recorder's reuse inherits that, but not
  for its own loopback's logging, which M11's exact-value pass covers.
- The engine facts in spec section 10 match `store.ts:87-113,195-210` and `auth-routes.ts:341-383`.
- No executor touches a live account. The only live step is S1, and the plan keeps it in Geoff's
  terminal. The Workers and Pages installation on `glw907-test` is out of reach of the recorder's
  App JWT. The M10 guard should also refuse any `/settings/installations` click whose App slug
  lacks the run id.
