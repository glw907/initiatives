# P1 (`cairn-new-1`) whole-branch reviews

Base 2e6283b0d, head reviewed cd49f6c54, PR glw907/cairn-cms#201. Both reviews ran fresh-context,
read-only. Dispositions are the executor's; the fix chain follows each table.

## Diff review (`standards:diff-reviewer`, whole-branch scope): verdict fix

The branch delivers P1 as planned (51 commits, 210 files). No behavioral or security defect found in the
runner, loopback, sign-in, or provider code it read. The live admin smoke does not apply: no engine auth
path changed (it checked `src/lib/{auth,auth-crypto,github}`, `src/lib/sveltekit/{csrf*,auth-*,commit-log,guard,preview}.ts`,
`src/lib/admin/{csrf-context.ts,CsrfField.svelte}`, `migrations*`, `hooks.server.ts`, `wrangler.*`,
`packages/create-cairn-site/src/**`; `.gitattributes` only adds `eol=lf` attributes).

| Finding | Disposition |
| --- | --- |
| Blocking: `package.json` `test:emit` fused two paths (missing space), so CI never ran T1.2's pack test or the writing-docs eval | fixed, c9e41b28c (`npm run test:emit` now 65 tests) |
| Blocking: `scaffold/workflow_test.go` kept a local copy of the deploy secret name behind a stale WATCH | fixed, c9e41b28c (`providers.DeploySecretName`) |
| Class map edit follows Decide 6 text; approvals/watch/child/deploy and the provider write files stay `ordinary` by path | logged to BACKLOG (held-file scope call) |
| `ManifestTarget`/`ManifestFormHTML` unused | fix chain (a) |
| `ReasonWorkersPaid` and `CloudflareAPI.Subscriptions` unreferenced after the 403 probe | logged to BACKLOG |
| `FetchFrom` untested | fix chain (d) |
| `SetupIntents.Worker` never written | fix chain (f) |
| Token scrub implemented twice; scaffold git reads `os.Environ()` | fix chain (e) |
| `cairne2e` tag not vetted by the gate | fix chain (g) |
| ADR wording (port, session-proof sign-in finish) | fix chain (b) |
| Matrix paths omit `packages/create-cairn-site/scripts/**` | fix chain (c) |
| Required red matrix run with site-facts regeneration stubbed | recorded in the PR body (run 42550507966) |

## Security review (`standards:web-auth-security-reviewer`): verdict fix

Confirmed sound: sweep scope (App id, App JWT), resume trust (`checkKept`), approval 1 persist-before-use,
keyring deletion, deploy-key replacement on resume, parameterized sign-in SQL, credential registration
before use, `Failure.Err` never serialized, loopback host/key/state/CSP, scrubbed child environments,
hardened tar extraction. No Critical.

| # | Sev | Finding | Disposition |
| --- | --- | --- | --- |
| H-1 | High | Resume runs Cloudflare before the over-grant sweep, so an all-repositories installation survives a resume that fails Cloudflare-side | fix chain |
| M-1 | Med | Session cookie crosses 127.0.0.1 ports; `/next` accepted absent Fetch Metadata | fix chain (require headers present; Max-Age; doc boundary) |
| M-2 | Med | Callback routes accepted no cookie; unverified installation id recorded | fix chain |
| M-3 | Med | npm scripts and git hooks run while credentials are live | fix chain (`--ignore-scripts`, `--no-verify`, hooks path) |
| M-4 | Med | Wiring contract for P2: Ctrl+C/SIGHUP/SIGTERM cancel ctx and wait for Run; Vault built with the record's RunID on resume; `Config.Register` wired to logx before Run; tab key never to an agent stream | forwarded to P2 |
| L-1 | Low | `adoptRepo` adopts a public repository | fix chain |
| L-2 | Low | Opener inherits full env; key in argv | fix chain (env scrubbed; argv residual documented) |
| L-3 | Low | Emailed unbound link sent even after SignedIn | not changed: Decide 2's ruled behavior |
| L-4 | Low | Only refresh token revoked | fix chain |
| L-5 | Low | Reconsent-only resume never stops the clock | fix chain |
| L-6 | Low | Cookie has no Max-Age | folded into M-1 |
| L-7 | Low | Manifest code in `url.Error` text | fix chain |
| L-8 | Low | User-token identity vs App owner | fix chain |
| L-9 | Low | Probe entry not recorded | BACKLOG |
| L-10 | Low | Port 49152 in the ephemeral range | BACKLOG (registered redirect fixes the port) |
| L-11 | Low | `zones.list` fixture (moved from main) keeps hex ids, zone names, account name | BACKLOG |
| L-12 | Low | Deploy workflow comment overclaims token isolation; tag pins | fix chain (comment) |

## Security delta re-review of the fix chain (03ef25b9c to ab284662e): accept with fixes

Every earlier finding (H-1, M-1, M-2, M-3, L-1, L-2, L-4, L-5, L-7, L-8, L-12) confirmed fixed or carrying a
documented residual; no new Critical or High. Gate run: `go test -race` on setup, childenv, loopback, scaffold,
providers, secrets, logx, all pass.

| # | Finding | Disposition |
| --- | --- | --- |
| Medium-1 | A callback without the cookie (provider session in another browser) dead-ends in a bare 403 | fixed: explanatory page; Fetch Metadata-less browsers get one on `/cloudflare/go` |
| Low-1 | Lax cookie rides a hostile page's top-level navigation; comments and a test name overclaim | fixed: comments and test name reworded; no `state` added to the install URLs |
| Low-2 | `GIT_CONFIG_PARAMETERS`, `GIT_DIR`, `GIT_TRACE*` and friends pass through | fixed in `childenv.Git` |
| Low-3 | Template extractor allows `.git/`; `core.fsmonitor` | fixed |
| Low-4 | Empty hooks path unguarded | fixed |
| Low-5 | Fetch Metadata mandatory: no fallback page | folded into Medium-1 |
| Low-6 | Secret denylists miss `*_KEY`, `*_PAT`, `*_CREDENTIALS`, `CLOUDFLARE_API_KEY` | fixed |
| Low-7 | Skipped lifecycle scripts unannounced; done.html silent on 404 | fixed: `ScriptsSkipped` flag, 404 line |
| Low-8 | Revoke order may report a false failure; comment on GitHub token lifetime wrong | fixed: refresh revoke authoritative; comment corrected |
| Low-9 | Wrong GitHub account creates repositories before the owner check | fixed: read `GET /user` first; refuse an empty owner login |
| Low-10 | One-time key stays in a started browser's argv | doc comment corrected |
| Low-11 | Nil `Config.Env` gives git an empty environment | fixed: refused |
| Low-12 | Worker intent has no consumer yet | WATCH comment |
| Info | 404 vs 403 shows whether a route is armed | accepted |

## Conductor's delta security review (ab284662e to c70a8a7a3): fix, nothing above Low

Run by `conductor-cairn-cms` under Decide 11 (a changed head reruns its reviews). `go test -race` on setup,
childenv, loopback, scaffold, and providers passes at c70a8a7a3; the tests at 9137b1f5d fail for the
right reasons. Medium-1, Low-1, Low-3, Low-4, Low-6, Low-8, Low-9, Low-10 to Low-12 confirmed fixed. No
credential, token, or one-time key is printed.

| # | Sev | Finding | Fix |
| --- | --- | --- | --- |
| D-1 | Low | `childenv.go:83-91` denylist misses `GIT_TEMPLATE_DIR` (reproduced: a template `config` filter plus `info/attributes` runs a command on `git add --all`), `GIT_COMMON_DIR`, `GIT_SSL_NO_VERIFY`, `GIT_SSL_CAINFO`, `GIT_SSH`, `GIT_ATTR_SOURCE`, `GIT_NAMESPACE`, `GIT_REPLACE_REF_BASE`, `SSH_ASKPASS`; ADR-0003:142 overclaims | allowlist: drop every `GIT_*` but the harness's pairs; `git init --template=` in `scaffold/git.go:53`; correct the ADR line |
| D-2 | Low | inherited `GIT_CONFIG_KEY_n`/`VALUE_n` (`childenv.go:59-78`) reach every git call | stop inheriting them in production; a test-only pairs field on Config for the harness |
| D-3 | Low | `dropApp` (`approvals.go:533`, via `:624`) leaves the dropped App's PEM and client secret in the keyring | delete the App's keyring entries in `dropApp` before saving the record |
| D-4 | Low | owner check `approvals.go:305` compares logins by exact string | compare numeric account ids, or at least `strings.EqualFold` |
| D-5 | Low | `ScrubSecrets` (`childenv.go:45-58`) misses `*_APIKEY`, `*_PASSWD`, `*_PASS`, `*_AUTH`, credentialed URLs such as `DATABASE_URL`; `Scrub` (`:30-37`) misses `CF_EMAIL`, `CF_API_TOKEN` | add them |
| Info | Info | `Done.ScriptsSkipped` and `RevokeFailed` have no reader yet (P3's view should); `otherbrowser.html` names the site to a cookieless request; access-token revoke error discarded at `runner.go:522`; approval 4's user token not owner-checked (harmless) | no change; the first goes to P3 |

### Dispositions for D-1 to D-5 (executor, head 0023f8151)

| # | Fix |
| --- | --- |
| D-1 | `childenv.Git` is an allowlist: it drops every inherited `GIT_*` variable and `SSH_ASKPASS`, `SSH_ASKPASS_REQUIRE`; the scaffold runs `git init --template=`. A test reproduces the `GIT_TEMPLATE_DIR` filter path with a control that must run the marker first (skipped on Windows: the filter is a POSIX shell line). ADR-0003 states the real boundary. |
| D-2 | `GIT_CONFIG_COUNT/KEY/VALUE` are no longer inherited; the harness passes pairs through the test-only `Config.GitConfigPairs`. A decoy pair in the process environment never reaches a push. |
| D-3 | `dropApp` deletes the App's keyring entries (only the names the record lists) before the record forgets the App; a refused delete stops with a four-part failure and leaves the record intact. |
| D-4 | `AppRecord.OwnerID` and `Setup.OwnerID` are stored at conversion; the owner check compares numeric ids when both are in hand and falls back to `strings.EqualFold` on the login. |
| D-5 | `ScrubSecrets` adds `_APIKEY`, `_PASSWD`, `_PASS`, `_AUTH` and credentialed URL values (a user name alone counts); `Scrub` adds `CF_EMAIL`, `CF_API_TOKEN`. |
| Info | `Done.ScriptsSkipped` and `Done.RevokeFailed` need readers in P3's done view (told the conductor); the other Info items unchanged. |

## Conductor's final delta review (c70a8a7a3 to 0023f8151): fix, Low only

D-1 to D-4 closed; each fix verified by undoing it in a temp copy and watching its test fail. D-5 closed for
well-formed URLs. `Config.GitConfigPairs` is unreachable from production input; the owner-id fallback cannot
accept a wrong account; no credential logged.

| # | Sev | Finding | Fix |
| --- | --- | --- | --- |
| E-1 | Low | `childenv.go:55-61` `credentialURL` keeps the variable when `url.Parse` fails (`pa#ss`, `pa%zz`, a space, a leading space, `mirror=https://u:p@h`) | drop on a `://[^/\s]*@` match, no parse; doc comment names the kept MySQL DSN form |
| E-2 | Low | ADR-0003:93 and :165 still say the harness rides `GIT_CONFIG_COUNT` | state that the env-to-`GitConfigPairs` reader lives only in a `//go:build cairne2e` file (P2 built it so: `tool/cmd/cairn/new_e2e_hook.go`) and is on the hygiene allow-list |
| E-3 | Low | `approvals.go:338` overwrites `Setup.OwnerID` with a zero repo owner id | write it only when nonzero |
| E-4 | Low | on resume, the existing site folder's `.git/config` is trusted (`http.sslVerify`, `http.proxy`, `core.sshCommand`, `url.*.insteadOf`) for the token-bearing push | pass `http.sslVerify=true`, `http.proxy=`, `core.sshCommand=` as setup's own pairs |
| Info | Info | `dropApp` leaves `Setup.OwnerID`; npm env keeps `GIT_*`; a private-CA operator gets a misleading stop; `$XDG_CONFIG_HOME/git/attributes` still read; extra suffixes `_PWD`, `_PASSPHRASE`, `_DSN`, `_COOKIE`, `_SESSION` | zero `OwnerID` and add the suffixes in the same fold; the rest to BACKLOG |

Conductor's call (Decision for the PR): the review rounds converge on Low hygiene, so this is the last full
re-review. The next review reads only the E-1 to E-4 lines; a new Low outside them goes to BACKLOG, not
another round.

### Dispositions for E-1 to E-4 (executor, head fa029a11f)

| # | Fix |
| --- | --- |
| E-1 | `credentialURL` is the regexp `://[^/\s]*@` matched on the value, no parse; the doc comment names the kept MySQL DSN form (a DSN with no `://` is kept by this rule; the `_DSN` suffix drops it by name). Tests: `pa#ss`, `pa%zz`, a space in the host, a leading space, `mirror=https://u:p@h`, a user name alone dropped; `https://example.test/a@b` and `/run/agent` kept. A password with a raw space still does not match (the pattern stops at whitespace). |
| E-2 | ADR-0003 says the harness passes its git config pairs through `Config.GitConfigPairs`; the reader from the environment lives only in a `//go:build cairne2e` file on the hygiene allow-list (`tool/cmd/cairn/new_e2e_hook.go`, built by P2). |
| E-3 | `createRepo` writes `Setup.OwnerID` only when the repository owner id is nonzero. |
| E-4 | `childenv.Git` always sets `core.hooksPath`, `core.fsmonitor=false`, `http.sslVerify=true`, `http.proxy=<the proxy git would read from the environment, else empty>`, and an empty `core.sshCommand`, before the extraheader and the harness pairs. Deviation: an empty `http.proxy` also disables the environment proxy, which would break a push behind one, so the pair carries the environment's value (order `https_proxy`, `HTTPS_PROXY`, `all_proxy`, `ALL_PROXY`). Gap: git picks the most specific `http.<url>.*` key first, so URL-scoped folder keys still win; logged as BACKLOG #397. |
| Info | `dropApp` zeroes `Setup.OwnerID`; `ScrubSecrets` adds `_PWD`, `_PASSPHRASE`, `_DSN`, `_COOKIE`, `_SESSION` (kept: `PWD`, `OLDPWD`, `SESSION_MANAGER`, `XDG_SESSION_ID`, `DESKTOP_SESSION`, `KDE_FULL_SESSION`, which xdg-open reads). The other Info items are BACKLOG #396. |

## Conductor's narrow line read (0023f8151 to fa029a11f): accept E-1 to E-3 and Info; E-4 one Low

| # | Sev | Finding | Fix |
| --- | --- | --- | --- |
| F-1 | Low | `remote.origin.proxy` from the folder beats setup's `http.proxy` pair (confirmed on git 2.56: CONNECT went to the folder's proxy); plain `http.sslCAInfo`/`sslCAPath` also win, so a folder proxy plus CA can read the push's token header. childenv_test.go:104, childenv.go:81 and #397 overclaim; the runner test reads `git config --get http.proxy`, which cannot see it | `pushEnv` adds `remote.origin.proxy=<httpsProxy(env)>`; setup's pairs add `credential.helper=` and `core.askPass=` (empty) so a 401 never runs a folder helper; test the effective proxy with a listener; reword the comments; amend #397 to name `remote.<name>.pushurl`, plain CA keys, URL-scoped keys, `insteadOf`, `curloptResolve` as the remaining residual |

Backlog only: `remote.origin.url`/`pushurl` redirect within github.com (closed by #397's explicit-URL push); `credentialURL` misses a raw space or unencoded `/`; forced `http.proxy` would apply the https proxy to a plain-http remote (none today).

Conductor's call: this fold is checked by the conductor's own read of its diff plus CI, not another review round, per the round-cap ruling.

### Disposition for F-1 (executor, head d28422d46)

`pushEnv` adds `remote.origin.proxy=<childenv.HTTPSProxy(env)>` after the extraheader and before the harness pairs; setup's always-set git pairs end with empty `credential.helper` and `core.askPass`. Tests: a listener test (two recorder proxies; the folder's `remote.origin.proxy` and `http.proxy` point at one, the environment's at the other; the push's `CONNECT github.com:443` lands only on the environment's proxy; before the fix it landed on the folder's) and a real 401 test (the folder's `credential.helper`, a URL-scoped helper, and `core.askPass` marker scripts never run; before the fix all three ran, so `GIT_TERMINAL_PROMPT=0` alone does not stop askpass; skipped on Windows, the markers are shell scripts). Comments reworded to say which keys the pairs beat. BACKLOG #397 names the true residual: `remote.<name>.pushurl`, plain `http.sslCAInfo`/`http.sslCAPath`, URL-scoped `http.<url>.*` keys, `url.*.insteadOf`, `http.curloptResolve`.
