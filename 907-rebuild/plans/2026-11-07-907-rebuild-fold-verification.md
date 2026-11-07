# 907 rebuild: verification read of the fold

Read at initiatives `5b3f2f2`, covering the design (D), spec (S), plan (P), fold record (F), and the three reviews. The reader took no part in the fold. Sources checked: `cairn-cms` at `b172d789a` (`packages/create-cairn-site/src`), the installed wrangler's `cli.js`, `servers/cloudflare/dns.sh`, the Cloudflare docs (custom-domains, the Workers domains API, and email-service troubleshooting), and the code.claude.com sandboxing and env-vars pages. Live listings of `/tmp`, `/run/user/1000`, and `/dev/shm` were taken by name only, and no secret value was read.

## Answers to the four questions

1. **Did each blocker and major close where the fold cites?** Yes for every contract and mechanics blocker and major. Failure B1 and M11 close only for the environment and for paths under `/var/home/glw907`. Each leaves an open path, given below as B1. Failure B2's claim that the credentials stay small is undercut by M2 below.
2. **Contradictions and run order.** The task order runs. Two statements contradict the code: S:172 says setup's carry-over gate will warn on the placeholder, and S:49/S:67 say builder B holds no Cloudflare credential after the sitting. Both are below.
3. **Are the new mechanisms sourced?** Most quotes match their sources: `env -i`, ancestor loading, `dontAsk`, `disableClaudeAiConnectors`, the setup source lines, the audit flag, the DMARC sentence, and the R2 and rename quotes. The exception is the placeholder's interaction with setup's attach. That question is open in Cloudflare's docs, and the evidence that exists points against it (M1).
4. **Can the owner rule the forks?** The two existing forks have enough evidence. The read adds two OWNER FORKs, M1 and M3, each with a recommendation.

**The path estimate checks.** T1 to T4 total 30+40+30+45 = 145. T5, T6, and T8 total 25+60+120 = 205, longer than T7's 180. T9, T12, and T13 total 120+150+60 = 330. That makes 680, matching D:89-94 and P:91. T11's 20 runs off the path.

## Findings, ranked by consequence

### B1. The clean room seals only Geoff's home. `/tmp`, `/run/user/1000`, and `/dev/shm` stay readable, and the D-Bus socket can be reached by its path

- **Severity:** blocker. **Tag:** `correctness`.
- **Location:** S:43, S:45, S:33, P:55, P:97-100.
- **Defect.**
  - The Read and Edit deny rules cover `//var/home/glw907/**`, `//home/glw907/**`, and the other builder's paths. Sandbox `denyRead` covers the same three roots. The sandbox's default is "read access to the entire computer, except certain denied directories", and "A `denyRead` entry doesn't stop the Read tool" (docs/en/sandboxing). So the Read tool, `cat`, and `node` can read these paths, which no rule names:
    - `/tmp`: 6,019 entries today. They include `cairn-closing-scaffold-*`, `cairn-closing-state-*`, and earlier `*-setup.log` runs from engine work, plus `/tmp/claude-1000/`, which holds other sessions' working files. That is the workstation knowledge the test has to exclude, and it is one Read away.
    - `/run/user/1000`: `bus` (mode `srw-rw-rw-`), `keyring/`, `op-daemon.sock`, `cc-socks/`, `ch-a-shares.json`, `tech-mail-probe/`, and more.
    - `/dev/shm`: `claude-askpass` reads Geoff's sudo password from `/dev/shm/claude-sudo-$(id -u)` (`~/.local/bin/claude-askpass:4`). The cache is cold today. Any sitting that warms it, such as `claude-sudo-setup`, makes the password readable to a builder.
  - `env -i` removes `DBUS_SESSION_BUS_ADDRESS`, but it doesn't remove the socket. The docs say "The seccomp filter is optional and adds Unix domain socket blocking. Install it with `npm install -g @anthropic-ai/sandbox-runtime`" (docs/en/sandboxing). It isn't installed under the clean `PATH`'s Node (`lib/node_modules` holds only `npm`). An allowed `node -e` can therefore connect to `unix:path=/run/user/1000/bus` and reach the unlocked keyring's Secret Service. That is the chain failure B1 named, and the fold closed only the address variable.
  - T1's denied list (P:97) probes none of these paths, so the probe would pass with the holes open. P:55's "No secret reaches them" doesn't hold.
- **Proposed fold.**
  - Add `TMPDIR` and `CLAUDE_CODE_TMPDIR`, both set to `/var/tmp/cairn-cleanroom/<A|B>/tmp`, to the `env -i` allowlist. The docs say: "`CLAUDE_CODE_TMPDIR` | Override the temp directory used for internal temp files ... Claude Code's own temp files always use your override" (docs/en/env-vars). The same entry warns that sandboxed Bash "receive[s] a short fallback `$TMPDIR` under the system default when your override is a long path", so T1 records the `$TMPDIR` that a sandboxed command actually sees.
  - Add Read and Edit denies for `//tmp/**`, `//run/user/**`, and `//dev/shm/**`. Add `/tmp`, `/run/user/1000`, and `/dev/shm` to `filesystem.denyRead`, keeping an allow for whatever fallback `$TMPDIR` T1 finds.
  - Install the seccomp filter in the clean toolchain, or show that bwrap blocks the socket some other way.
  - T1 adds these checks. Read and `cat` must fail on a canary planted in `/tmp` and another in `/dev/shm`, and on `/run/user/1000/ch-a-shares.json`. `node -e "require('net').connect('/run/user/1000/bus').on('connect',()=>console.log('OPEN')).on('error',e=>console.log(e.code))"` must not print `OPEN`. A normal `npm install` must still work with the moved `TMPDIR`.

### M1. OWNER FORK: the placeholder apex record is likely to block setup's attach, and T4's planned read can't settle the question

- **Severity:** major. **Tag:** `correctness`, with the keep-or-drop choice as an `optional` fork.
- **Location:** S:170-172, S:227, P:38, P:137-138, P:146, P:151, F:143, D:18, D:103.
- **Defect.**
  - **Docs.** Cloudflare's custom-domains page says only "You cannot create a Custom Domain on a hostname with an existing CNAME DNS record". It is silent on an existing A or AAAA record. The `PUT /accounts/{id}/workers/domains` reference documents `hostname`, `service`, `enabled`, `previews_enabled`, `zone_id`, and `zone_name`, with no override field.
  - **Source.** Wrangler treats an existing record as a conflict. It sends `override_existing_dns_record: false` by default and sets it to `true` only after the prompt "You already have DNS records that conflict for these Custom Domains ... Update them to point to this script instead?" (`wrangler-dist/cli.js:147394`, `:147454-147460`). That is strong evidence the platform refuses an attach over an existing AAAA unless told to override. cairn's attach sends only `hostname`, `zone_id`, `service`, and `environment` (`api.mjs:514-520`). The likely result is `custom-domain-failed` in the middle of P4.
  - **S:172's evidence doesn't apply.** S:172 leans on "Setup's carry-over gate warns on an existing apex address record". On an already-active zone, setup skips that gate entirely: `carryOver = { outcome: 'not-needed' }` when `alreadyActive` (`chapter2.mjs:713-729`). 907.life is active, so no warning appears, and reading `records.mjs` (P:138) tells T4 nothing. T4 has nothing read-only that can decide it.
  - **The pause is longer than stated.** The fallback, Geoff pausing "at setup's domain prompt", happens at chapter 2's first question (`chapter2.mjs:622`). That comes before the account, token, and zone steps. The gap is therefore the whole chapter, not "the minutes until the attach" (S:172).
  - **Stale declaration window.** In the branch where setup overrides the record, the placeholder line stays declared after the hold is released at T6 (P:159) and until T11 merges.
- **Proposed fold, with an OWNER FORK on which path.**
  - **(a) Recommended: drop the placeholder.** Accept that the three `/.well-known` redirects are down from the detach until setup's attach. Those redirects serve only a mail client's first discovery. MX, IMAP, SMTP, and already-configured clients don't use them. This removes one DNS write and its removal, the teardown pause, T4's servers PR, P4's conditional pause, and T11's line drop. The three 308s then move out of the after-T5 check and stay in the before-T5 and after-T6 checks. Whether "my mail needs to continue to work" covers discovery during that window is Geoff's reading.
  - **(b) Keep the placeholder, but remove it unconditionally before setup's domain chapter.** Drop T4's probe, since the wrangler evidence already answers it. S:172 then states the gap as the whole of chapter 2, and T11 or the line removal runs before the hold is released.
  - Under either branch, delete S:172's carry-over-gate sentence, and make sure a `custom-domain-failed` caused by the placeholder is never filed as a cairn item.

### M2. Setup's state record holds the pasted Cloudflare token in builder B's readable home

- **Severity:** major. **Tag:** `correctness`.
- **Location:** S:45, S:49, S:67, P:166, S:241.
- **Defect.**
  - Chapter 2 saves the pasted token as `cloudflare.apiToken` in the site record (`chapter2.mjs:227-239`), and chapter 3 does the same (`chapter3.mjs:1135-1137`). Both delete it only at their terminal steps (`deleteApiToken`, `chapter2.mjs:203-224`). That record is `~/.config/cairn/sites/*.json` in B's home, which `allowRead: ["~/"]` and the Read tool both reach.
  - If setup stops short, the token with Workers and DNS edit rights stays there. Possible causes are the loopback timeout row (S:241), a park, or an engine failure. Builder B then holds it while it builds. That contradicts S:49 ("builder B holds `gh` plus wrangler only during the setup sitting"), and T6 checks only `wrangler whoami` (P:166).
- **Proposed fold.**
  - T6's acceptance adds `jq -e '.cloudflare | has("apiToken") | not'` on B's record. It tests for the key and never prints the value.
  - Add a Read deny and a `denyRead` for B's `~/.config/cairn/`, since a newcomer's builder has no need to read it.
  - A record left holding a token is a P4 step: Geoff deletes that token at Cloudflare before B resumes.

### M3. OWNER FORK: the mail check sends mail from an account of unknown ownership, and its DKIM criterion tests the sender, not 907.life

- **Severity:** major. **Tag:** `correctness`, with how inbound delivery gets proved as an `optional` fork.
- **Location:** S:180, P:53, P:146, P:212, D:9.
- **Defect.**
  - S:180 says the message goes "from Geoff's Google mailbox through the session's Gmail connector". Nothing verifies whose account the connector holds. Sending as an unverified identity is an outward act with no provenance behind it, and the check repeats four times (before T5, after T5, after T6, and at T12).
  - The `dkim=pass` that `tech-mail.sh show` reads on that inbound message is the sending provider's signature, not 907.life's. It proves nothing about the zone.
  - The fallback, "you send ... inside the P3 and P4 sittings", leaves out T12's check. It also doesn't say whether P3 covers both the before-T5 and the after-T5 checks.
- **Proposed fold.** Recommendation: drop the connector.
  - The zone half of every check is check 1 (`dns.sh --check`, which reads each declared mail record back from a public resolver), the snapshot diff, and the redirect curls. These cover MX, SPF, both `w1-*` selectors, and `_dmarc` with no message sent.
  - Prove inbound delivery once, where the zone was actually written: at the end of P4, Geoff sends one message from an outside mailbox he names to `glw@907.life`, and the observer reads it with `tech-mail.sh`.
  - The before-T5 and T12 checks rely on check 1 plus the monitor's daily inbound probe. P6's outbound message, with `header.d=907.life` (S:252), stays as it is.
  - If the connector is kept, P1 must first confirm, read-only, that the connector's account is Geoff's.

### m1. The bare `Edit` and `Write` allows let a builder write anywhere outside the denied roots

- **Severity:** minor. **Tag:** `correctness`.
- **Location:** S:42.
- **Defect.** The file tools aren't sandboxed. With `Edit` and `Write` allowed bare, a builder can write to `/tmp`, to `/run/user/1000` (user-writable, `systemd/` included), and to `/dev/shm`.
- **Proposed fold.** Allow `Edit(~/**)` and `Write(~/**)` instead of the bare tools, alongside B1's denies.

### m2. The pre-flight preamble contradicts its own set points

- **Severity:** minor. **Tag:** `correctness`.
- **Location:** P:15.
- **Defect.** P:15 says "Every item is done and checked before T5", but P3 to P6 are set points at T5, T6, T12, and T13.
- **Proposed fold.** Say that P1 and P2 finish before T5, and that P3 to P6 are named set points.

### m3. Two PRs that must merge before T5 have no named merger or check

- **Severity:** minor. **Tag:** `correctness`.
- **Location:** P:136, P:137.
- **Defect.** The dotfiles PR has to merge before T5, and so does the servers placeholder PR if M1(b) is chosen. No pre-flight item names who merges either one or how the merge is checked.
- **Proposed fold.** Fold both into P2: Geoff merges them, or the packet says who does. The check is `gh pr view --json state` reporting `MERGED` before P3.

### m4. P4 promises browser tabs that can't open under `env -i`

- **Severity:** minor. **Tag:** `correctness`.
- **Location:** P:35.
- **Defect.** P4 says "in the tabs setup opens". Under `env -i` there is no `WAYLAND_DISPLAY`, `DISPLAY`, or bus address, so `xdg-open` can't start Chromium. `open.mjs` swallows the failure and prints the link instead (`open.mjs:54-66`).
- **Proposed fold.** Carry P1's "open each printed link in your Chromium" line into P4.

### m5. The `create-cairn-site` deny also blocks the commands a newcomer would use to work out setup

- **Severity:** minor. **Tag:** `optional`.
- **Location:** S:44, S:67.
- **Defect.** B's `Bash(*create-cairn-site*)` deny also blocks `--help` and `--dry-run`. A newcomer would use those to work out the command, so the deny skews the test.
- **Proposed fold.** Record it as a harness departure in the fold record, so B's gaps aren't read as docs gaps.

### m6. The design cites the wrong line for `_dmarc`

- **Severity:** minor. **Tag:** `correctness`.
- **Location:** D:32.
- **Defect.** D:32 cites `servers/cloudflare/dns/ward`, line 17. The `_dmarc` value is on line 18; line 17 is the comment above it.
- **Proposed fold.** Cite line 18.

## Verdict

Not ready. B1 has to fold first, since the clean room as written leaves `/tmp`, the runtime directory with its D-Bus socket, and `/dev/shm` open to both builders. After that, M2 needs its fold, and Geoff rules the M1 and M3 forks. None of these changes the task order or the 680-minute path.

## Second read

Read at initiatives `5f9e9a3`, against F's "Verification dispositions" and the spec, plan, and design diff from `5b3f2f2`. The docs were checked against the current markdown of code.claude.com/docs/en/settings-reference ("`permissions.blockReadsOutsideWorkingDirectories`", "Sandboxed commands under the block", and "`permissions.blockWritesOutsideWorkingDirectories`") and docs/en/sandboxing.

### Answers

- **B1 closed, subject to T1's probes.** The file tools are held to `~/work/` by the read and write blocks. The quotes in S:44 and F:185-187 match settings-reference word for word, version floors included (v2.1.257 and v2.1.314, against CLI 2.1.319).
  - For sandboxed commands, the block "denies them read access to your home directory and to the other roots that hold user files: `/Users`, `/home`, `/root`, `/Volumes`, `/mnt`, `/media`, `/run/media`, and `/srv`". Here, "your home directory" is the clean `HOME`, not `/var/home/glw907`. That list doesn't name `/tmp`, `/var/tmp`, `/run/user/1000`, or `/dev/shm`. The explicit `denyRead` (S:47) supplies them, and it also keeps Geoff's home denied by name. Together they cover every path in the first read.
  - `TMPDIR` and `CLAUDE_CODE_TMPDIR` are in the allowlist with their env-vars quote.
  - T1 now probes the `/tmp` and `/dev/shm` canaries, `ch-a-shares.json`, B's `~/.config/cairn/canary`, the bus connect, refused writes, and an `npm install` with the moved temp directory (P:97-102).
  - The masking claim rests on sandbox-runtime's source, which isn't Claude Code's bundled build, and F:190 says so. The bus probe makes it falsifiable, with a stated fallback (the seccomp filter).
- **M2 closed.** Setup's record sits in B's home, which is outside `~/work/` for the file tools. For sandboxed commands, the block and `denyRead` `/var/tmp` both close it, and B's `allowRead` doesn't reopen it. T6 adds the `jq -e` key test, which exits non-zero (fails closed) on a record with no `cloudflare` object. P4 adds the token delete.
- **M1 landed as ruled.** No placeholder, `100::`, or carry-over-gate text remains in D, S, or P. The gap is stated in D:11, S:175, and the packet (P:142). T5 expects the redirects down, and T6 requires all three 308s back, records the gap's length, and stops if they don't return.
- **M3 landed as ruled.** No Gmail or connector text remains, apart from S:50's unrelated `disableClaudeAiConnectors`. Check 1 runs every time. Geoff's message is the inbound half in P3 and P4, and P2 names his mailbox. S notes that the inbound `dkim=pass` is the sender's signature.
- **The "get back only" paraphrase.** F:172 says sandboxed commands under the block "get only the work tree, the session temp directory, and the user-settings `allowRead` entries back". The docs reopen more: "the working directories, worktrees Claude Code creates in the session, the session temp directory, and the parts of `~/.claude` that commands need", plus the global git config files. The docs also never say outright that user-settings `allowRead` entries reopen paths under the block. They say "`allowRead` and `allowWrite` entries from repository settings don't count", and the spec infers the rest. T1's `npm install` and `gh auth status` prove that inference, so this is optional precision, not a defect.

### Findings

#### M1b. The clean shell's working directory is unstated, and the new block puts anything setup creates outside `~/work/` beyond B's reach

- **Severity:** major. **Tag:** `correctness`.
- **Location:** S:25, S:27-31, S:70, P:33, P:17-29.
- **Defect.**
  - `env -i` keeps the caller's working directory. Nothing says `cleanroom-run --shell` changes into `~/work/`, so Geoff's shell opens wherever he launched it, probably the initiatives worktree.
  - `--dir` "Defaults to a slug of the name" (create-cairn-site README:30), so setup creates the site under that directory. Under the read and write blocks, builder B then can't read or edit the site, and its record's `dir` points into Geoff's tree.
  - P1's interactive `claude` runs from the same directory, which loads that repo's and its ancestors' CLAUDE.md for the sign-in session.
- **Proposed fold.**
  - Every `cleanroom-run` form does `cd "$HOME/work"` before it execs.
  - P4 checks `pwd` prints `/var/tmp/cairn-cleanroom/B/work` before running setup, and T6's acceptance checks that the site directory sits under B's `~/work/`.
  - T1 checks `pwd` in a `--shell`.

#### m1b. `gh` lives only under `/home/linuxbrew`, a root the block closes to sandboxed commands

- **Severity:** minor. **Tag:** `correctness`.
- **Location:** S:30, S:47.
- **Defect.**
  - `/usr/bin` has `git` and `jq` but no `gh`. `gh` resolves to `/var/home/linuxbrew/.linuxbrew/Cellar/gh/2.103.3/bin/gh`, through `/home -> var/home`.
  - Under the block, sandboxed commands lose `/home`, and `allowRead` doesn't reopen Homebrew. A sandboxed `gh` and the `gh auth git-credential` helper would then fail, and builder A needs both to open its Survey PR.
  - T1's `gh auth status` check would catch it, and S:48's "adds that one path" covers the fix. Naming the path now just saves a T1 loop.
- **Proposed fold.** Add `/home/linuxbrew/.linuxbrew` and `/var/home/linuxbrew/.linuxbrew` to both builders' `allowRead`, and record any further path T1 has to reopen.

### Second-read verdict

Not ready, by one line. M1b's `cd "$HOME/work"` and its `pwd` checks have to land. Then the plan is ready: B1 and M2 are closed pending T1's probes, and M1 and M3 landed as Geoff ruled.
