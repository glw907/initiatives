Initiative: self-hosting

# Mail filters: plan

## Brief

This plan builds the approved design `self-hosting/specs/2026-10-22-mail-filters-design.md`: one Sieve script for Geoff's mailbox on ward, rendered from data files in the servers repo, plus a preview and re-sort loop that Geoff can keep iterating on, and the first re-sort of his existing mail. One servers branch, `mail-filters`, goes to Geoff through `conductor-servers`. The planned path is 520 minutes against the design's 480 estimate.

The pass has one planned sitting with Geoff, between its phases. Phase A builds everything and makes no write to any mailbox. It ends with the preview report: what each rule would do to Geoff's mail, the full category table, every message the security rule would pull into the Inbox, and the human mail that would land outside it. The conductor sends that report to Geoff as a packet, and phase B starts only on his approval. Phase B installs the script on the probe account, then on Geoff's, takes a backup, and runs the first re-sort. The design requires Geoff to see those numbers before mail moves, so the sitting is planned and is not a planning miss.

Facts settled at planning, from the prior-art research (`self-hosting/research/2026-10-22-mail-filters-prior-art.md`, which read Stalwart v0.16.27's source and sieve-rs 0.7.3):

1. A user script can't read the address book, so the known-correspondent list is rendered into the script.
2. Stalwart files spam to Junk only when the script ends in a plain `keep`, so the script files spam itself.
3. `fileinto :create` works and nests on `/`.
4. JMAP can't run a script over stored mail, so the re-sort runs the real interpreter offline: a small Rust program on sieve-rs `=0.7.3`, built and run in a pinned `rust` container under `podman`. No Rust toolchain goes on the workstation, so nothing enters a software manifest.
5. Activation runs in its own JMAP request, never by a same-request `#id` (stalwartlabs/stalwart#3207).
6. Ward's JMAP returns `null` for `header:<name>:asText` but answers the raw `header:<name>` form (observed 2026-10-22), so every JMAP read asks for raw headers.

The servers repo is bash and jq throughout (`roles/stalwart/stalwart-jmap` is the pattern), so the new tools are too, except the Rust runner.

## Entry

Phase A, at launch:

- The design is approved (Geoff, 2026-10-22, in chat).
- No other executor works `.claude/worktrees/mail-filters` or the branch `mail-filters` (`pgrep -f`, `git status`, `claude agents --json`). `servers-backlog-2` and `servers-bulwark` may be live. This pass never touches their worktrees or branches.
- The servers main checkout is on `main`, clean, and level with `origin/main`.
- `podman info` succeeds, and `podman pull` of the pinned `rust` image digest (T2 picks the newest stable 1.x image and pins its digest) succeeds.

Phase A writes nothing to ward. It may read Geoff's mailbox over JMAP, read-only, with his credential from `claude-pass` (`907.life mail: geoff` in the Workstation vault). It may also run `ssh -o BatchMode=yes geoff@ward.907.life` for read-only commands.

Phase B, when `conductor-servers` sends "go phase B":

- Geoff has approved the preview packet, with any data edits he asked for already committed and re-previewed.
- The conductor says ward is free: no other pass holds a ward hold line in STATUS, and any branch that applied ward has merged.
- The executor merges `origin/main` into `mail-filters`, runs the gate, and pushes.

## Pre-flight

None. The pass uses rules the workstation already has: `scripts/apply.sh ward --apply` and `--check`, `ssh geoff@ward.907.life *`, and `claude-pass item view` for the mailbox password, which the brainstorm session used on 2026-10-22. T7's `scripts/mail-filters.sh resort --apply` is a new command that moves Geoff's mail. If the auto-mode classifier denies it, the standing answer below applies.

## Layout

The builder may adjust names, but the shape is fixed:

- `mail-filters/` at the repo root holds the data and the template. `categories.tsv` maps a sender domain to a category, `security-senders.txt` and `security-words.txt` hold the security rule's lists, `always-inbox.txt` and `never-inbox.txt` hold single addresses, `list-names.tsv` holds optional List-Id to folder-name overrides, and `geoff.sieve.in` is the template.
- `roles/mail-filters/` is a ward role installed after `stalwart` in `hosts/ward/roles.txt`. It installs the data, the template, and one helper, `/usr/local/sbin/mail-filters`, which talks to Stalwart over the loopback listener as `stalwart-jmap` does, reading the account password from `/etc/servers/stalwart.env` as data. It also installs a daily `mail-filters-refresh.timer`.
- `tools/sieve-run/` is the Rust runner: a `Cargo.toml` with `sieve-rs = "=0.7.3"`, a committed `Cargo.lock`, and a `Containerfile` on the pinned image.
- `scripts/mail-filters.sh` is the workstation command for the loop: `preview` and `resort` (`--apply` makes it live).

The helper's verbs:

| Verb | Does |
|---|---|
| `render ACCOUNT` | Prints the script: the template with the data files and the account's known correspondents filled in |
| `correspondents ACCOUNT` | Prints the sorted, de-duplicated addresses from every address book the account can read and from the To and Cc of its Sent Items |
| `export ACCOUNT` | Prints one JSON line per message: id, mailbox ids, keywords, and the raw headers. Never a body |
| `install ACCOUNT` | Renders, runs `SieveScript/validate`, creates or updates the script in one request, then activates it in a second request. Prints the script's blob hash |
| `move ACCOUNT` | Reads a move plan on stdin and applies it with `Email/set`, creating folders it names. Writes a manifest of each move under `/var/lib/servers/mail-filters/manifests/`. Never destroys a message |
| `undo ACCOUNT MANIFEST` | Moves each message in a manifest back to its old folders |
| `folders ACCOUNT` | Prints each folder, its role, and its count. With `--prune`, deletes user folders that are empty, never one with a role |

`STALWART_URL` and `STALWART_ENV` override the defaults, as in `stalwart-jmap`. So `scripts/mail-filters.sh` can run `export` and `correspondents` on the workstation against `https://mail.907.life`, with an env file in `$XDG_RUNTIME_DIR` that holds the password from `claude-pass`. That lets phase A read without installing anything on ward.

## Tasks

The servers worktree is `.claude/worktrees/mail-filters` on branch `mail-filters`, cut from `origin/main`. Every task is `auth-data` unless marked, runs test-first, and gets a `diff-reviewer` task-scope read while CI runs. A step that reads Geoff's mailbox or touches ward runs in the main loop. Tests use the harness (`tests/harness/run.sh`) with fixtures and fakes, and no fixture holds real mail: fixture headers are invented.

### Phase A: no write to ward

- **T1. The template and data (75 min, pair with T2, `ordinary`).** Write `mail-filters/geoff.sieve.in` with the nine steps in the design's order, and the data files seeded from the 2026-10-22 survey (the design's folder table and the roughly 120 notification domains it names). The template takes the account's own address and its sign-up aliases as parameters, so the probe account can run the same rules. The script uses only header, address, envelope, `spamtest`, and `variables` tests, never a body test, because the re-sort runs on headers alone. The renderer is the helper's `render` verb (T3 builds the verb; T1 writes the template it fills). *Test*: the rendered script for a fixture account passes `sieve-run`'s compile check, which T2 provides. Until T2 merges, T1 tests rendering only. *Acceptance*: the rendered script for Geoff fits ward's user-script limits (100 KB, 4,096-byte strings, 15 nested tests), measured and recorded.

- **T2. The runner (90 min, pair with T1).** `tools/sieve-run/`: reads a script and a stream of header-only messages (JSON lines from `export`), each with an envelope recipient taken from its `Delivered-To` header, falling back to `X-Delivered-to`, then to the account address. It runs sieve-rs `=0.7.3` with the same extensions Stalwart enables for user scripts, and prints one JSON line per message: the id, the folders it would be filed into, or `keep`. The extension set comes from Stalwart's source at the tag ward runs (`crates/email/src/sieve/` and `crates/common/src/scripts/`); record the file and line. Build and run in the pinned container with the repo mounted read-only and the corpus on a tmpfs mount. Add a gate leg, `sieve`, that runs only when `tools/sieve-run/**` or `mail-filters/**` changes, and is cached so an unchanged tree builds nothing. *Test*: fixture messages for each of the nine steps file where the design says, including a GitHub notification with List-Post going to Tech, a groups.io post going to `Lists/`, a list post with Geoff on Cc going to the Inbox, and a spam-scored message going to Junk. *Acceptance*: the leg passes in the gate, and its cold and cached times are recorded.

- **T3. The ward helper and role (120 min).** `roles/mail-filters/` with `install.sh` (safe to rerun), the helper, and the refresh timer, after `roles/stalwart/`'s shape. `install` follows the activation order above. The timer runs `install geoff` daily, which picks up new contacts and Sent Items correspondents. It only updates when the rendered script's hash changes, and it logs the hash. The role applies to no account until `/etc/servers/mail-filters/accounts` lists one, so installing the role changes no mail. Add the role to `hosts/ward/roles.txt` after `stalwart`, and update every test that counts ward's roles or pins golden hashes. *Test*: against a fake JMAP server on localhost, each verb sends only the methods it should. `export` requests no body property. `install` never sends `onSuccessActivateScript` with a `#` reference. `move` never sends `destroy`. `undo` restores a manifest exactly. *Acceptance*: tests pass, and `scripts/apply.sh ward --check` lists the role.

- **T4. The workstation loop (90 min).** `scripts/mail-filters.sh preview` takes the password from `claude-pass` into a 0600 env file under `$XDG_RUNTIME_DIR/mail-filters/`, runs `export` and `correspondents` against `https://mail.907.life`, renders the script with the repo's data, and runs `sieve-run` over the corpus. It then applies the design's re-filing mapping: never into the Inbox, never personal mail out of Archive, and personal mail in any other user folder goes to Archive. It writes the move plan and a report to the same directory, and removes the env file on exit. The report carries the design's five reliability-gate sections, plus a count per destination folder and the number of Remind messages to be moved to Deleted Items. `resort --apply` sends the move plan to ward's `move` over ssh and prints the manifest path. Without `--apply`, it prints the plan's counts. The corpus and report never leave `$XDG_RUNTIME_DIR` and are never committed. *Test*: with fixtures and a fake `ssh` and `claude-pass`, the mapping rules hold, the password never appears in argv or output, and the env file is gone after a failure. *Acceptance*: tests pass.

- **T5. The first preview (40 min, main loop).** Run `scripts/mail-filters.sh preview` against Geoff's real mailbox. Read the report and fix what's plainly wrong in the data (a category domain the survey missed, a list folder name that reads badly), then re-preview. The loop guard is three rounds. Write a summary for the packet: counts per destination, the category table, every security-rule hit, a sample of up to 50 human messages landing outside the Inbox, and every message reaching the Inbox from an unknown sender. Senders and subjects are fine in the packet, but no bodies. The summary goes in `$XDG_RUNTIME_DIR` and in the PR's draft body only as counts, since the servers repo is private but the packet is read in the approval app. *Acceptance*: if the security rule shows any marketing hit or misses a real code or reset in the sample, apply the design's fallback (security mail to Notifications/Tech) and say so in the summary.

- **T6. The runbook (40 min, `ordinary`).** A runbook section, "Mail filters", covering where the data lives, the loop (edit, preview, apply ward, re-sort), how to add a sender or a list name, how to undo a re-sort from its manifest, and how to turn the script off (`install` with an empty accounts file, or deactivate in the Stalwart web admin). One `docs/decisions.md` entry for each Brief fact. Add the role and the timer to the runbook's service catalog. Under "Claude infrastructure", list the `claude-pass` read the loop uses.

At the end of phase A, push, mark the PR draft, and send `conductor-servers` the summary's path and "preview ready". Then wait.

### Phase B: live, after Geoff approves the preview

- **T7. Probe, Geoff, and the re-sort (90 min, `live-account`, main loop).**
  1. Phase B entry: merge `origin/main`, gate, push.
  2. Write `probe` into the role's accounts file in the branch, then `scripts/apply.sh ward --apply` and `--check`. Send crafted messages from `probe2` to `probe` over authenticated submission on ward: a plain personal note, a list post with List-Id and List-Post, a list post with `probe` on Cc, a no-reply notification from a category domain, a security alert from a security sender, and a GTUBE spam test. Read each one's folder with `stalwart-jmap`, and record each Message-ID with `scripts/mail-test-ids.sh add`. Each lands where the design says.
  3. Add `geoff` to the accounts file and apply ward again. Read back that the script is active and its hash matches the render. Send one plain note from `probe` to `geoff@907.life` and confirm it reaches the Inbox. This is the design's end-to-end check, and the list half of it is step 2's list post.
  4. On ward, `sudo systemctl start servers-backup.service`, and wait until it ends successfully. Read `restic snapshots --no-lock` (runbook "Restore from backup") and record the new snapshot's id and time.
  5. Re-run `preview` and check that its counts match the approved packet within the mail that arrived since. Then run `scripts/mail-filters.sh resort --apply`, then `folders geoff --prune`.
  6. Read `folders geoff` and compare it with the preview's per-folder counts. Record the manifest path.
  *Acceptance*: each step's excerpt goes under `## Decisions`, with addresses other than Geoff's own masked.

- **T8. Close (50 min).** One whole-branch `diff-reviewer`, one batched fix chain quoting its findings verbatim, and the gate. If a fix changes a file ward installs, re-apply ward and rerun T7 step 3. File follow-ups through `log-issue` in the servers `BACKLOG.md`. The PR body opens with `## Brief`, then what landed, each `auth-data` verdict, `## After merge`, `## Decisions`, `## Not checked`, `## Found, not done`, the score, and `## STATUS lines` for the conductor.

**Path**: the T1 and T2 pair at 90, then T3 at 120, T4 at 90, T5 at 40, and T6 at 40, for 380 minutes in phase A. Phase B is T7 at 90 and T8 at 50, for 140. The planned path is 520 minutes. That's 40 over the design's 480 estimate and under the 960 line where the standing answer below applies. The wait for Geoff's preview approval is not on the path.

## After merge

The conductor runs these after Geoff approves the PR:

1. Merge, pull the servers checkout, then `scripts/apply.sh ward --apply` from `main` and `--check`, outside 03:20 to 04:00 UTC. The script stays active, and its hash matches the branch's.
2. Delete the pass's test messages by Message-ID: `scripts/mail-test-ids.sh list`, `stalwart-jmap find` for each, then `scripts/ward-mail-delete.sh probe`, `probe2`, and `geoff` with the ids found, reading each mailbox's counts before and after.
3. Clear the ward hold line in STATUS.

If Geoff rejects the PR after the re-sort, the conductor runs `undo geoff <manifest>`. It then clears the accounts file on a branch from `main` and applies ward, which deactivates the script. The back-out branch's PR goes in the rejection's packet.

## Standing answers

| Situation | Answer |
|---|---|
| The path passes 520 minutes | Continue up to 960 (twice the design's estimate). Past 960, stop for the conductor. |
| The pinned `rust` image can't be pulled, or sieve-rs `=0.7.3` won't build in it | Try the newest stable 1.x image that builds it and record the digest. If none builds, stop: the design's parity guarantee depends on this runner. |
| Stalwart's enabled extension set can't be read from its source | Enable the extensions the design uses (fileinto, mailbox, variables, envelope, spamtest, relational, comparator-i;ascii-numeric, regex) and record that parity is by inspection, under `## Not checked`. |
| The security rule fails T5's check | Apply the design's fallback and say so in the packet. The rest of the pass goes on. |
| Geoff asks for data changes in the preview packet | Make them, re-preview, and send the conductor the new counts. Start phase B only on the conductor's "go phase B". |
| A probe message in T7 step 2 lands in the wrong folder | Fix the traced cause in the data or template, re-render, re-apply, and rerun step 2. Never enable `geoff` while a probe case fails. |
| T7 step 5's counts differ from the packet by more than the mail that arrived since | Stop for the conductor before `--apply`. |
| The auto-mode classifier denies `resort --apply`, `move`, or `apply.sh ward --apply` | Never retry it. Write the exact command under `## Stop`, and send `conductor-servers` one message. Geoff runs it himself, and the session resumes at the next step. |
| The backup in T7 step 4 fails | Stop for the conductor. No re-sort runs without a snapshot newer than the preview. |
| A pair's files overlap | Run the two tasks in sequence and record it. |

Stops: the 960-minute line; a cause the session can't trace; any step that would destroy a message; a re-sort without a fresh snapshot; and a classifier denial of a live write. Each stop sends `conductor-servers` one message with the state.
