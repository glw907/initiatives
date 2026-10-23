Initiative: self-hosting

# Mail filters: plan

## Brief

This plan builds the approved design `self-hosting/specs/2026-10-22-mail-filters-design.md`: one Sieve script for Geoff's mailbox on ward, rendered from data files in the servers repo, plus a preview and re-sort loop that Geoff can keep iterating on, and the first re-sort of his existing mail. One servers branch, `mail-filters`, goes to Geoff through `conductor-servers`. The planned path is 715 minutes against the design's 480 estimate, under the 960-minute line where the standing answer applies. One ruling below needs Geoff at plan approval. The three plan reviews, their fold, and its verification (`self-hosting/research/2026-10-22-mail-filters-plan-review-fold.md`, `2026-10-22-mail-filters-fold-verification.md`) rebuilt the move, the undo, the runner's verdict, the timer, and the live checks.

The pass has one planned sitting with Geoff, between its phases. Phase A builds everything and makes no write to any mailbox. It ends with the preview packet: what each rule would do to Geoff's mail, run twice, once with the security rule and once with its fallback, so Geoff picks one. The conductor sends that packet to Geoff, and phase B starts only on his approval. Phase B installs the script on the probe account, then on Geoff's, takes a backup, and runs the first re-sort. The design requires Geoff to see those numbers before mail moves, so the sitting is planned and is not a planning miss.

Facts settled at planning and at the fold, from the prior-art research (`self-hosting/research/2026-10-22-mail-filters-prior-art.md`) and the Stalwart v0.16.27 and sieve-rs 0.7.3 source:

1. A user script can't read the address book, so the known-correspondent list is rendered into the script.
2. Stalwart files spam to Junk only when the script ends in a plain `keep`, so the script files spam itself.
3. `fileinto :create` works and nests on `/`. It resolves each path component trimmed and lowercased (`crates/email/src/mailbox/manage.rs:94-110`), and `Mailbox/set` refuses a sibling whose name matches case-insensitively (`crates/jmap/src/mailbox/set.rs:589-601`). A folder name may run to 255 bytes per level (`manage.rs:128`, default at `crates/registry/src/schema/structs_impl.rs:20429`).
4. JMAP can't run a script over stored mail, so the re-sort runs the real interpreter offline: a small Rust program on sieve-rs `=0.7.3`, built and run in a pinned `rust` container under `podman`. No Rust toolchain goes on the workstation, so nothing enters a software manifest.
5. Activation runs in its own JMAP request, never by a same-request `#id` (stalwartlabs/stalwart#3207). Deactivation is `SieveScript/set` with `onSuccessDeactivateScript: true` (`crates/jmap/src/sieve/set.rs:354-390`).
6. Ward's JMAP returns `null` for `header:<name>:asText` but answers the raw `header:<name>` form (observed 2026-10-22), so every JMAP read asks for raw headers.
7. User scripts get every sieve-rs capability plus Expressions (sieve-rs `src/runtime/mod.rs:339`; Stalwart `crates/common/src/config/mailstore/scripts.rs:55-95`, with `disable_capabilities` empty by default, `structs_impl.rs:36818`). Their limits are 102,400-byte scripts, 4,096-byte strings, 15 nested tests and blocks, 128 local variables, 5,000 CPU instructions, and 1,024-byte headers (`structs_impl.rs:36813-36845`). A runtime error is logged and, when nothing was filed, the message goes to the Inbox (`crates/email/src/sieve/ingest.rs:502-520`). The CPU count is one per executed instruction, whatever a test's key list holds (sieve-rs `src/runtime/context.rs:126-130`). A message is spam at a score of 50 or more (`crates/email/src/message/delivery.rs:46-48`).
8. Stalwart runs the spam filter only on unauthenticated sessions (`enable_spam_filter` defaults to `is_empty(authenticated_as)`, `structs_impl.rs:28905-28907`), so a spam test must arrive on port 25 without authentication.
9. A script can hand the runner a value: `set "global.step" "9"` writes a global variable (sieve-rs `src/compiler/grammar/actions/action_set.rs:177`), which the caller reads back as `Context::global_variable("step")`, the namespace stripped and the name lowercased (`src/runtime/context.rs:632`). The runner learns each message's sorting step this way.
10. `Mailbox/set` destroy removes mail only when `onDestroyRemoveEmails` is sent (default false, `crates/jmap/src/mailbox/set.rs:81`), and it refuses a folder with children or mail (`:326-333`).
11. Turning on a vacation reply activates Stalwart's script named `vacation` and switches off the active one (`crates/jmap/src/vacation/set.rs:134, 281-295`).

The servers repo is bash and jq throughout (`roles/stalwart/stalwart-jmap` is the pattern), so the new tools are too, except the Rust runner.

## Rulings needed

A yes-or-no question for the plan's packet. The tasks build the recommended answer.

1. **In a re-sort, move unread automated mail out of the Inbox like the rest, holding back only flagged mail?** Recommended: yes. The Inbox holds 623 messages, and Geoff may keep some there as a to-do. A flag is the explicit mark of that; unread state is not, since most automated mail in the Inbox was never opened. The packet lists every message leaving the Inbox by sender and subject, so a misread one is caught before anything moves, and it gives the unread and flagged counts of the automated mail that would leave, so Geoff may revise this answer at the preview sitting. Yes builds T4's mapping rule that leaves any `$flagged` Inbox message where it is, and moves unread automated mail by its verdict. No adds one condition to that rule: an Inbox message without `$seen` also stays, and the packet counts the unread messages held back.

## Preview rulings (Geoff, 2026-10-23)

Geoff approved the preview packet for servers#17 at head `1520963` with each recommended answer. The account-security rule ships, filing to INBOX rather than the Notifications/Tech fallback. Ruling 1 stands as yes: unread automated mail leaves the Inbox and flagged mail stays. Remind mail moves to Deleted Items. Phase B starts at the conductor's "go phase B", once ward is free.

## Entry

Phase A, at launch:

- The plan is approved, with the ruling given.
- No other executor works `.claude/worktrees/mail-filters` or the branch `mail-filters` (`pgrep -f`, `git status`, `claude agents --json`). `servers-backlog-2` and `servers-bulwark` may be live. This pass never touches their worktrees or branches.
- The servers main checkout is on `main`, clean, and level with `origin/main`.
- `podman info` succeeds, and `podman pull docker.io/library/rust:1` succeeds. sieve-rs 0.7.3 is `edition = "2024"`, so the image's Rust must be 1.85 or later. T2 pins the digest.

Phase A writes nothing to ward. It may read Geoff's mailbox over JMAP, read-only, with `STALWART_PASSWORD_GEOFF` from the repo's `secrets_load` (`scripts/lib/secrets.sh`). It may also run `ssh -o BatchMode=yes geoff@ward.907.life` for read-only commands.

Phase B, when `conductor-servers` sends "go phase B":

- Geoff has approved the preview packet, with his choice of the security rule or its fallback and any data edits he asked for already committed and re-previewed.
- The conductor says ward is free: no other pass holds a ward hold line in STATUS, and any branch that applied ward has merged.
- The executor merges `origin/main` into `mail-filters`, runs the gate, and pushes.

## Pre-flight

None. Every live write runs on a rule the workstation already holds: `scripts/apply.sh * --apply` and `--check`, and `ssh geoff@ward.907.life *`, with or without `-o BatchMode=yes` (`docs/runbook.md:434`). The re-sort itself is an ssh command under that rule, so it needs no new allow rule. Mailbox passwords come from `secrets_load`: `STALWART_PASSWORD_GEOFF`, `STALWART_PASSWORD_TEST`, and `STALWART_PASSWORD_TEST2` (`docs/runbook.md:478-479`). T7's SMTP sends with `curl` may meet the classifier; the standing answer covers a denial.

## Layout

The builder may adjust names, but the shape is fixed:

- `roles/mail-filters/data/` holds the data and the template. They sit inside the role because `scripts/apply.sh:98` ships only `base` and the listed roles to a host. `categories.tsv` maps a sender domain to a category. `security-senders.txt` and `security-words.txt` hold the security rule's lists, and `security-folder.txt` holds its target: `INBOX`, or `Notifications/Tech` for the design's fallback. `always-inbox.txt` and `never-inbox.txt` hold single addresses. `signup-aliases.txt` holds the sign-up addresses and domains that never count as "to Geoff": `geoff-login`, the three 907.life masks, the fastmail.com masks, and `m.907.life`. `list-names.tsv` holds optional List-Id to folder-name overrides. Two files serve the re-sort only: `delete-senders.txt` (Remind's sender domains, whose mail moves to Deleted Items) and `legacy-folders.txt` (the Fastmail-era folders, the only ones personal mail moves out of to Archive). `geoff.sieve.in` is the template.
- `roles/mail-filters/` is a ward role installed after `stalwart` in `hosts/ward/roles.txt`. It installs one helper, `/usr/local/sbin/mail-filters`, which talks to Stalwart over the loopback listener as `stalwart-jmap` does, reading the account password from `/etc/servers/stalwart.env` as data. It installs `mail-filters-refresh.timer`, daily at 05:15 UTC, outside the 03:20 to 04:00 backup band. It applies to no account until `/etc/servers/mail-filters/accounts`, copied from `roles/mail-filters/accounts`, lists one. The managed script is always named `mail-filters`. `install.sh` fails only when its own files fail to install; it then starts `mail-filters-refresh.service`, whose failure reaches the heartbeat but never fails the apply, since `scripts/apply.sh` stops at the first failing role. That service runs `install` for each listed account and `deactivate` for each `accounts.json` mailbox the file doesn't list.
- `tools/sieve-run/` is the Rust runner: a `Cargo.toml` with `sieve-rs = "=0.7.3"` and `mail-parser = "=0.11.9"`, the version Stalwart's `Cargo.lock:4724-4725` pins, a committed `Cargo.lock`, a `Containerfile` on the pinned image, and `stalwart-tag`, holding `v0.16.27`, the Stalwart release whose interpreter it matches.
- `scripts/mail-filters.sh` is the workstation command for the loop: `preview` and `diff OLD NEW`.

The helper's verbs follow. Each runs with `LC_ALL=C` and prints JSON with `jq -c`, so a render is byte-identical on the workstation and on ward. `install`, `move`, `undo`, and `folders --prune` refuse to run between 03:20 and 04:00 UTC, as `roles/stalwart/stalwart-apply:44-48` does, since the backup stops Stalwart at 03:30.

| Verb | Does |
|---|---|
| `render ACCOUNT` | Prints the script: the template with the data files and the account's known correspondents filled in. Fails on any JMAP error |
| `correspondents ACCOUNT` | Prints the sorted, de-duplicated addresses from every address book the account can read and from the To and Cc of its Sent Items, leaving out the account's own login and aliases |
| `export ACCOUNT` | Prints one JSON line per message, de-duplicated by id: id, mailbox ids, keywords, and the raw headers. Never a body. Leaves out every folder with a role other than `inbox` and `archive` |
| `status ACCOUNT` | Prints the active script's name and SHA-256 |
| `install ACCOUNT` | Renders and runs `SieveScript/validate`. A failed validate sends no `SieveScript/set` and exits non-zero. If the active script is `vacation`, it logs "filtering paused" and exits 0. Otherwise, when the managed script differs from the render or isn't active, it creates or updates it in one request and activates it in a second. Prints the active hash |
| `deactivate ACCOUNT` | When the active script is `mail-filters`, `SieveScript/set` with `onSuccessDeactivateScript: true`, in its own request. Any other active script, a vacation reply or operator2's own, is left alone |
| `move ACCOUNT` | Reads a move plan on stdin and applies it, as T3 sets out |
| `undo ACCOUNT MANIFEST` | Moves each message the manifest moved back to its old folder, if it is still where the move put it, recreating a missing folder by its path, matched as `move` matches. Reports the rest |
| `folders ACCOUNT` | Prints each folder's id, path, role, and count. With `--prune`, removes empty folders, as T3 sets out |

`STALWART_URL`, `STALWART_ENV`, and `STALWART_ACCOUNTS` override the defaults, as in `stalwart-jmap`, and `MAIL_FILTERS_DATA` overrides the data directory. So `scripts/mail-filters.sh` runs `export`, `correspondents`, and `render` on the workstation against `https://mail.907.life`, with the repo's `roles/stalwart/accounts.json`, the repo's data directory, and a 0600 env file under `$XDG_RUNTIME_DIR/mail-filters/` holding `STALWART_PASSWORD_GEOFF` from `secrets_load`. That lets phase A read without installing anything on ward.

## Tasks

The servers worktree is `.claude/worktrees/mail-filters` on branch `mail-filters`, cut from `origin/main`. Every task is `auth-data` unless marked, runs test-first, and gets a `diff-reviewer` task-scope read while CI runs. A step that reads Geoff's mailbox or touches ward runs in the main loop. Tests use the harness (`tests/harness/run.sh`) and the existing fake `curl` (`tests/fakes/curl`, driven as `tests/stalwart.test.sh:322-340` drives it), and no fixture holds real mail: fixture headers are invented.

### Phase A: no write to ward

- **T1. The template, the data, and the renderer (85 min, pair with T2).** Write `roles/mail-filters/data/geoff.sieve.in` with the nine steps in the design's order, and the data files seeded from the 2026-10-22 survey (the design's folder table and the roughly 120 notification domains it names). Write the render function as a library that T3's `render` verb wraps. The template takes the account's own address and its sign-up aliases as parameters, so the probe account can run the same rules. It sets `global.step` to the step's number before each terminal action (Brief fact 9). Every `fileinto` carries `:create`, since without it a missing folder falls back to the Inbox. Step 6 leaves out category-domain senders, so GitHub's mail, which carries a mailto List-Post, reaches Tech. Step 3 matches the role addresses on To as well as on the envelope. A list folder name is capped at 64 bytes and keeps the List-Id's case. The script uses only header, address, envelope, `spamtest`, and `variables` tests, never a body test, because the re-sort runs on headers alone. *Test*: the render for a fixture account matches a golden file, and passes `sieve-run`'s compile check once T2 merges. *Acceptance*: tests pass.

- **T2. The runner (125 min, pair with T1).** `tools/sieve-run/` reads a script and a stream of header-only messages (JSON lines from `export`). A message's envelope recipient is its topmost `Delivered-To`, which Stalwart adds at delivery (`crates/email/src/message/ingest.rs:252`), falling back to `X-Delivered-to`, then to the account address; on migrated mail the topmost one may be Fastmail's, and step 3 also matches on To. Its envelope sender is its `Return-Path`, which Stalwart adds at SMTP (`crates/smtp/src/inbound/data.rs:763-772`). The runner builds the compiler and runtime with Stalwart's user-script settings, copied from `scripts.rs:55-95` with the defaults in Brief fact 7, and takes `--cpu-limit` to override the CPU limit. It runs sieve-rs `=0.7.3` and prints one JSON line per message: the id, the step from `global.step`, and the folders it would be filed into, or `keep`, or `error` with the reason. The corpus runs with spamtest unknown; a fixture can set a spam percentage, turned into a status as Stalwart's `spam_status` does (`crates/common/src/config/mailstore/spamfilter.rs:98-104`). Build in the pinned container, and run with `--network=none` and `--security-opt label=disable` (`tests/container/run.sh:8`), the repo mounted read-only and the corpus on a tmpfs mount. Tag the image by a hash of `tools/sieve-run/**`, as `tests/container/image.sh` does. Add a gate leg, `sieve`, that runs only when `tools/sieve-run/**`, `roles/mail-filters/**`, or `roles/stalwart/install.sh` changes. The leg runs the fixtures below. It renders with a fixed fixture list of 4,000 correspondents and fails on any `error` or a script over 102,400 bytes. It fails if the rendered script holds a `body` test or a `"body"` requirement (a token, never a substring such as `nobody@`), and if the Stalwart tag in `roles/stalwart/install.sh` differs from `tools/sieve-run/stalwart-tag`. CI already runs podman for the container leg. *Test*: each fixture gives the verdict the design sets. A fixture the template can't meet is a cause to trace, never an edit to this table. Step 8 tests the same automated markers as step 5, so the stamp row holds. A crafted list post's To is the list address, with the recipient on RCPT only.

  | Fixture | Verdict (step, folder) |
  |---|---|
  | A stranger's note, Geoff on To | 5, Inbox |
  | A contact's note, Geoff on Bcc | 5, Inbox |
  | A stranger's note, Geoff on Bcc | 9, Other |
  | A receipt from a category domain to `geoff@`, no List-Unsubscribe | 7, its category |
  | A contact's post to a list (List-Id, mailto List-Post) | 6, `Lists/<name>` |
  | A list post with Geoff on Cc | 5, Inbox |
  | A groups.io post | 6, `Lists/<name>` |
  | A GitHub notification with List-Id and a mailto List-Post | 7, Notifications/Tech |
  | `List-Post: NO` with List-Id and List-Unsubscribe, unknown domain | 8, Other |
  | A List-Id holding `/`, over 64 bytes | 6, the name with `/` removed, capped |
  | A person's note to `geoff-login@`, a 907.life mask, or an `m.907.life` alias | not Inbox |
  | A security sender and an account word, no List-Unsubscribe | 2, the folder in `security-folder.txt` |
  | The same with List-Unsubscribe | 7, its category |
  | An account word from a sender not on the security list | not step 2 |
  | "Promo code" and "Confirm your subscription" from a security sender | not step 2 |
  | A DMARC report from google.com to `dmarc-reports@`, on the envelope and on To | 3, Notifications/Tech/Reports |
  | Mail to `postmaster@` | 3, Inbox |
  | `no-reply@thelightphone.com` | 4, Light |
  | An always-Inbox sender with bulk headers | 5, Inbox |
  | A never-Inbox sender, Geoff on To | not Inbox |
  | Unknown bulk mail with List-Unsubscribe | 8, Other |
  | A receipt from an unknown domain with an email-provider stamp and no other bulk header | 8, Other |
  | Bulk mail whose From is Geoff's own address | not Inbox |
  | Spam percentages 9, one below the threshold, at the threshold, and 100 | Junk at and above the threshold only |

  *Acceptance*: the leg passes in the gate, and its cold time is recorded.

- **T3. The ward helper and role (180 min).** `roles/mail-filters/` with `install.sh` (safe to rerun), the helper with the Layout's verbs, and the refresh timer, after `roles/stalwart/`'s shape. The timer runs `install` for each account in the accounts file. Every failure exits non-zero, so the unit shows in the heartbeat's `failed_units` (`roles/health/health.sh:34`). Add the role to `hosts/ward/roles.txt` after `stalwart`, and update every test that counts ward's roles or pins golden hashes.

  `move` works as follows. The plan's first line carries the preview's time and the rendered script's hash. `move` refuses a plan older than 24 hours, one whose hash isn't the active script's, and one with no backup newer than its preview time (`last_ok_at` in `/var/lib/servers/backup-status.json`). It works in batches of the session's `maxObjectsInSet` (500 by default, `structs_impl.rs:23293`). For each batch, it reads the messages' current `mailboxIds` and moves only a message whose single folder equals the plan's source. It patches `mailboxIds/<from>: null` and `mailboxIds/<to>: true`, never `keywords`. It refuses a source folder with a role other than `inbox` and `archive`. It refuses a target outside Archive, Light, `Lists/*`, and `Notifications/*`, except the trash, junk, and sent role folders for a Remind or duplicate-folder move. It finds a target folder as `fileinto :create` does: split on `/`, each component trimmed and compared lowercased (Brief fact 3). It creates the folder when missing, and on "already exists" reads the folder list again. After each batch commits, it appends the `updated` ids to the run's manifest under `/var/lib/servers/mail-filters/manifests/`, with each old and new folder's id and path and the keywords that batch's read saw. It counts skips and `notUpdated` ids. It never destroys a message.

  `folders --prune` destroys only user folders with no role, no mail, and no children, deepest first, so an emptied parent goes after its children. It never sends `onDestroyRemoveEmails`, and it counts a `mailboxHasChild` or `mailboxHasEmail` refusal as a skip.

  *Test*, against the fake `curl`:
  - `export` requests no body property.
  - `install` never sends `onSuccessActivateScript` with a `#` reference; a failed validate sends no `SieveScript/set`; an active `vacation` script gets no `set`.
  - With an empty accounts file, the refresh service deactivates every account whose active script is `mail-filters`, and sends no `SieveScript/set` to an account whose active script is `vacation` or has another name. `install.sh` still exits 0 when the service fails.
  - `render` for an account with no correspondents succeeds, and fails on a JMAP error. Renders under `LC_ALL=C` and `en_US.UTF-8` are byte-identical.
  - `move` never sends `destroy` or a `keywords` path. It skips a message whose current folders differ from the plan's, and one in two folders. It refuses a stale plan, a hash mismatch, a missing backup, a role-folder source, and a target outside the allow-list. When the fake fails the third batch, the manifest holds exactly the first two. `Lists/Foo` and `Lists/foo` targets resolve to one folder.
  - A move, then a prune, then an `undo` puts every message back in a folder with its old path.
  - Prune never sends `onDestroyRemoveEmails`, and destroys no role folder, no parent with children, and no folder with mail.

  *Acceptance*: tests pass.

- **T4. The workstation loop (120 min).** `scripts/mail-filters.sh preview` writes the env file, runs `export` and `correspondents` against `https://mail.907.life`, renders the script with the repo's data, and runs `sieve-run` over the corpus. It reads `/etc/servers/stalwart-image` over ssh and refuses unless its tag matches `tools/sieve-run/stalwart-tag`. `--security-folder FOLDER` overrides `security-folder.txt` for one run. It then applies the re-filing mapping to each message, first match wins:
  1. A message from a `delete-senders.txt` domain moves to Deleted Items.
  2. A message in a user folder named `Trash`, `Spam`, or `Sent` moves to the matching role folder.
  3. A `$flagged` message in the Inbox stays (ruling 1).
  4. A message with an `error` or Junk verdict stays.
  5. An Inbox verdict, or a step-9 verdict, never moves a message into the Inbox. It moves to Archive only from a folder in `legacy-folders.txt`, and otherwise stays where it is.
  6. Any other verdict moves the message to its folder.

  It writes the move plan and the report to `$XDG_RUNTIME_DIR/mail-filters/`, and removes the env file on exit. The corpus, plan, and report never leave that directory and are never committed. The report carries the design's five sections: the count per destination with its sources; every security-rule hit, with digit runs in subjects masked; up to 50 human-looking messages landing outside the Inbox, with full subjects; every message reaching Other, grouped by sender domain with counts; and every message reaching the Inbox from a sender who is neither a contact nor someone Geoff has written to. "Human-looking" is the report's own test, independent of the script: no `List-*`, `Precedence`, `Auto-Submitted`, or email-provider stamp, and no no-reply sender. The report adds the account-word subjects the security rule didn't pull in, every Remind hit and every message leaving the Inbox by sender and subject, and the `error` count. `diff OLD NEW` compares two plans by message id and prints the ids added, dropped, and retargeted.

  *Test*, with fixtures and a fake `ssh`: each mapping rule holds, on a step-8 and a step-9 message each in Archive and in a legacy folder, a personal message in a script destination, a Remind message in Archive and in the Inbox, one message in each duplicate system folder, and a flagged and an unread automated Inbox message. Each of the five sections is present and non-empty. A human message filed to a category appears in the sample, and a reset from an unlisted sender appears among the misses. The password never appears in argv or output, and the env file is gone after a failure. *Acceptance*: tests pass.

- **T5. The first preview (60 min, main loop).** Run `scripts/mail-filters.sh preview` against Geoff's real mailbox, then again with `--security-folder Notifications/Tech`. Read the report and fix what's plainly wrong in the data (a category domain the survey missed, a list folder name that reads badly), then re-preview. The loop guard is three rounds. From the corpus, record:
  - how Proton Pass rewrites To, From, and `Delivered-To` on `m.907.life` alias mail, and whether the sender's category still matches;
  - whether List-Post separates the discussion lists from the bulk senders in this corpus;
  - the rendered script's size, and a corpus run at `--cpu-limit 2500`, half of ward's limit, with its `error` count;
  - the `Delivered-To` values seen on migrated mail;
  - the Remind count, which must be non-zero and within a factor of ten of the surveyed 250;
  - the Trash expiry period on ward, which bounds how long a Remind move can be undone.

  Write the packet to `$XDG_RUNTIME_DIR/mail-filters/packet.md`, never committed. It holds the counts per destination for both runs, the category table, the five sections, the Remind hits, every message leaving the Inbox with the unread and flagged counts among them, the Trash expiry, and a note that mail clients resync after the move. Geoff picks the security rule or its fallback there. The PR's draft body carries counts only. *Acceptance*: the packet holds both runs and the five sections, and any `error` verdict has a traced cause.

- **T6. The runbook (45 min, `ordinary`).** A runbook section, "Mail filters", covering where the data lives, the loop, how to add a sender or a list name, how to test on `probe`, how to undo a re-sort from its manifest, and how to turn the script off (`deactivate`, or remove the account from the accounts file and apply ward). The loop is: edit the data, preview, apply ward, back up (`systemctl start servers-backup.service`, a brief Stalwart stop, or the nightly run), re-sort. A template or helper change goes to `probe` first: apply with only `probe` listed, which switches Geoff's filtering off for the test window while spam still reaches Junk, send the probe set, then list `geoff`. Filters change only through the data files: the timer re-installs the managed script over any other edit, and pauses while a vacation reply is on. Turning a vacation reply off leaves no script active, so mail lands unfiltered until the next 05:15 run; run `install geoff` to end that sooner. Undo is the rollback for a re-sort; a backup restore replaces the whole store and is for disaster only. Add one `docs/decisions.md` entry that cites the research and the fold record and lists the Brief facts. Add the role and the timer to the runbook's service catalog. *Acceptance*: the section names every helper verb, and the gate passes.

At the end of phase A, push, mark the PR draft, and send `conductor-servers` the packet's path and "preview ready". Then wait.

### Phase B: live, after Geoff approves the preview

- **T7. Probe, Geoff, and the re-sort (135 min, `live-account`, main loop).** Outside 03:20 to 04:00 UTC. Commands run from the worktree after `source scripts/lib/secrets.sh; secrets_load`, and `ward` below stands for `ssh -o BatchMode=yes geoff@ward.907.life`. Each test message carries `X-Servers-Rehearsal: mail-filters` and a Message-ID `mail-filters-<case>-<UTC stamp>@probe.907.life`, is written to a file under `$XDG_RUNTIME_DIR/mail-filters/`, and its Message-ID goes to `scripts/mail-test-ids.sh add`.
  1. Phase B entry: merge `origin/main`, gate, push. If Geoff picked the fallback, `security-folder.txt` already says so.
  2. Send `conductor-servers` the hold line for STATUS: "ward runs branch mail-filters until it merges". Write `probe` into the role's accounts file in the branch, then `scripts/apply.sh ward --apply` and `--check`. Send five messages from `probe2` to `probe` over authenticated submission: a plain personal note, a list post with List-Id and a mailto List-Post, To the list address, a list post with `probe` on Cc, a no-reply notification from a category domain, and a security alert from a security sender. Header From may name any sender, since Stalwart checks only the envelope sender (`crates/smtp/src/inbound/mail.rs:232-251`). Each send is `printf 'user = "probe2@probe.907.life:%s"\n' "$STALWART_PASSWORD_TEST2" | curl -sS -K - --ssl-reqd --url smtp://mail.907.life:587 --mail-from probe2@probe.907.life --mail-rcpt probe@probe.907.life --upload-file FILE`. Send the GTUBE case from the workstation without authentication, as `docs/cutover-log.md:87` did: `curl -sS --url smtp://ward.907.life:25 --mail-from probe2@probe.907.life --mail-rcpt probe@probe.907.life --upload-file FILE`. Read each message's folder with `ward sudo mail-filters export probe`, filtered by Message-ID, and `ward sudo mail-filters folders probe`. Each lands where the design says; a GTUBE refused at SMTP also passes, and is recorded. Run `ward sudo mail-filters deactivate probe`, read `status probe` showing no active script, then run `install probe` and read it active again with the render's hash.
  3. Add `geoff` to the accounts file and apply ward again. Read `ward sudo mail-filters status geoff`, and check its hash equals both `ward sudo mail-filters render geoff | sha256sum` and the workstation's render through `scripts/mail-filters.sh`. From `probe`, over authenticated submission, send `geoff@907.life` a plain note and a crafted list post (To the list address, Geoff on RCPT only), and send `dmarc-reports@907.life` a report. They land in the Inbox, `Lists/<name>`, and Notifications/Tech/Reports. This is the design's end-to-end check. Record the report's stored `Delivered-To`.
  4. Re-run `preview`, then `scripts/mail-filters.sh diff` against the approved plan. Every id in both plans has the same destination. An id only in the new plan arrived after the approved preview, or sits in a folder Geoff changed since. An id only in the old plan is one Geoff moved or deleted, and is counted. After a partial move, an id the manifest already moved counts as done.
  5. `ward sudo systemctl start servers-backup.service`, and wait until it ends successfully. Read `ward sudo server-restore list` and `last_ok_at` in `/var/lib/servers/backup-status.json`, and record the snapshot's id and time. `counts["geoff@907.life"]` in `/var/lib/servers/backup/manifest.json` is within 10 of Geoff's live count from `ward sudo stalwart-status counts`, the reader the backup uses. The backup stops Stalwart briefly, and delivery waits for that time.
  6. For `probe`, write a one-line plan headed with step 4's time and `status probe`'s hash, moving the step-2 list post to the category folder the notification case filled. Pipe it to `ward sudo mail-filters move probe`, run `ward sudo mail-filters folders probe --prune`, which removes the emptied list folder, then `undo probe <manifest>`. `folders probe` matches the state before by path and count, with the list folder back and the post in it. Then run `ward 'sudo /usr/local/sbin/mail-filters move geoff' < "$XDG_RUNTIME_DIR/mail-filters/plan.jsonl"` and record the manifest path.
  7. Re-read every id in the manifest with `export geoff`: each sits in its target folder, and its keywords equal the ones the manifest recorded at the move.

  *Acceptance*: each step's excerpt goes under `## Decisions`, with addresses other than Geoff's own masked.

- **T8. Close (50 min).** One whole-branch `diff-reviewer`, one batched fix chain quoting its findings verbatim, and the gate. If a fix changes a file ward installs, re-apply ward and rerun T7 step 3. File follow-ups through `log-issue` in the servers `BACKLOG.md`. The PR body opens with `## Brief`, then what landed, each `auth-data` verdict, `## After merge`, `## Decisions` (the design departures the fold record lists among them), `## Not checked`, `## Found, not done`, the score, and `## STATUS lines` for the conductor.

**Path**: the T1 and T2 pair at 125, then T3 at 180, T4 at 120, T5 at 60, and T6 at 45, for 530 minutes in phase A. Phase B is T7 at 135 and T8 at 50, for 185. The planned path is 715 minutes. That's 235 over the design's 480 estimate, and under the 960 line where the standing answer below applies. The wait for Geoff's preview approval is not on the path.

## After merge

The conductor runs these after Geoff approves the PR, outside 03:20 to 04:00 UTC:

1. Merge, pull the servers checkout, then `scripts/apply.sh ward --apply` from `main` and `--check`. `ssh -o BatchMode=yes geoff@ward.907.life sudo mail-filters status geoff` shows the managed script active, and its hash equals `sudo mail-filters render geoff | sha256sum` run at that time.
2. Delete the pass's test messages by Message-ID: `scripts/mail-test-ids.sh list`, `stalwart-jmap find` for each, then `scripts/ward-mail-delete.sh probe`, `probe2`, and `geoff` with the ids found, reading each mailbox's counts before and after.
3. Run `sudo mail-filters folders geoff --prune` and `folders probe --prune`, and record the folders each removed. This removes the emptied legacy folders and the test list folders.
4. Clear the ward hold line in STATUS.

If Geoff rejects the PR after the re-sort, the conductor backs it out on ward: `sudo mail-filters undo geoff <manifest>`, `sudo mail-filters deactivate geoff` and `deactivate probe`, and `sudo systemctl disable --now mail-filters-refresh.timer`. It removes `/etc/systemd/system/mail-filters-refresh.service` and `.timer`, `/usr/local/sbin/mail-filters`, and `/etc/servers/mail-filters`, keeps `/var/lib/servers/mail-filters/manifests/`, and runs `sudo systemctl daemon-reload`. Then it applies ward from `main`, which removes `/opt/servers/roles/mail-filters`, deletes the test messages as in step 2, and clears the hold line. The back-out's excerpt goes in the rejection's packet.

## Standing answers

| Situation | Answer |
|---|---|
| The path passes 715 minutes | Continue up to 960 (twice the design's estimate). Past 960, stop for the conductor. |
| The pinned `rust` image can't be pulled, or sieve-rs `=0.7.3` won't build in it | Try the newest stable 1.x image that builds it and record the digest. If none builds, stop: the design's parity guarantee depends on this runner. |
| The rendered script passes 102,400 bytes or another size limit | Keep every contact, and trim Sent Items correspondents to the most recent years until it fits. Record the cut in the packet. |
| T5's half-limit run shows CPU errors | Restructure the template so the common path runs fewer tests; trimming correspondents can't lower CPU use. A cause that can't be traced is a stop. |
| The approved plan is gone from `$XDG_RUNTIME_DIR` (a reboot during the wait) | Re-preview, compare per-destination counts with the packet, and stop for the conductor on any difference. |
| T5's three rounds are spent | Each further round must fix a traced cause. Otherwise send the packet with the open items listed. |
| Geoff asks for data changes in the preview packet, or picks the security fallback | Make them (the fallback is `Notifications/Tech` in `security-folder.txt`), re-preview, and send the conductor the new counts. Start phase B only on the conductor's "go phase B". |
| A probe message in T7 step 2 lands in the wrong folder | Fix the traced cause in the data or template, re-render, re-apply, and rerun step 2. Never enable `geoff` while a probe case fails. |
| A probe or end-to-end case can't pass | Don't enable `geoff`, or run no re-sort if it is enabled. Still run T8, and close with `## Bar unmet`, the failing step's excerpt attached. |
| T7 step 4's diff retargets an id, or adds one it can't explain | Stop for the conductor before the move. |
| `move` refuses a stale plan or a hash mismatch | Rerun T7 steps 4 and 5, then the move. |
| `move` stops partway (an error, a dropped ssh session) | The manifest holds every committed batch. Rerun T7 steps 4 and 5, then the move: a filed message yields no move. |
| A ward apply, `install`, `move`, `undo`, or prune meets 03:20 to 04:00 UTC | Wait until 04:00 and rerun it. |
| The auto-mode classifier denies `apply.sh ward --apply`, the move, or a T7 send | Never retry it. Write the exact command under `## Stop`, and send `conductor-servers` one message. Geoff runs it himself, and the session resumes at the next step. |
| The backup in T7 step 5 fails, or its count is off by more than 10 | Stop for the conductor. No re-sort runs without that snapshot. |
| A pair's files overlap | Run the two tasks in sequence and record it. |

Stops: the 960-minute line; a cause the session can't trace; any step that would destroy a message; a re-sort without a fresh snapshot; and a classifier denial of a live write. Each stop sends `conductor-servers` one message with the state.
