# Operator runbook plan: fold record

Target: `self-hosting/plans/2026-10-25-operator-runbook-plan.md` at `ffdad7c`, revised in place. Reviews: `2026-10-25-operator-runbook-plan-review-mechanics.md` (38 findings), `-contract.md` (29), and `-data.md` (18, counting its owner fork). The design's rulings aren't reopened. The second operator's identifiers appear only as roles; the plan's Brief says where the executor reads the real values in the private servers repo.

Totals: 79 folded (13 of them convergent, folded once at their root), 4 refused, 2 owner forks with no other fold. With the four forks that sit inside folded findings, the plan carries six rulings, under "Rulings for Geoff". After the verification read (below): path 720 to 905 minutes, under the 1,200 path ceiling; task sum 1,165 to 1,435.

A mid-fold fact from the conductor (Geoff's renaming of the `Household IT` items with category prefixes, each note naming its store variable, and the trashed Fastmail and duplicate Yealink items) is folded into T4's expected title set and the docs tasks' naming rule.

## Probes run by the fold

Every mechanism the revision introduces was quoted or probed, never stated from memory:

- `%q` escaping and trailing `=` loss: a scratch reproduction of `sync.sh:235-241` and `_secrets_take` loads `pa$s!w0rd#1` as `pa\$s\!w0rd#1` and `B=abc=` as `abc`.
- SELinux and rootless podman: on pavilion, `ssh-add -l` through the mounted agent socket and `cat` of a `/dev/shm` mount both answer "Permission denied" without `--security-opt label=disable` and succeed with it.
- `htpasswd -niB -C 10 U` reads stdin and prints the line plus one blank line; `htpasswd -vi` verifies (exit 0) and rejects (exit 3); htpasswd's default cost is 5 (`man htpasswd`); Go's `bcrypt.DefaultCost` is 10 and `GenerateFromPassword` refuses over 72 bytes (`golang.org/x/crypto@v0.58.0/bcrypt/bcrypt.go:24, 95-97`); htpasswd accepts 80 bytes silently.
- `openssl passwd -6 -salt <salt> -stdin` reproduces a `$6$` hash. `openssl` and `httpd-tools` are in the Bluefin base image (`rpm -qf`).
- Cloudflare's account update is `PUT /accounts/{account_id}` (developers.cloudflare.com/tenant/how-to/manage-accounts). The lock-out quote is the 2025-09-08 changelog.
- The name derivation: names in `~/.local/secrets` read by the servers repo's tracked files outside `docs/` number 42 (matching the mechanics count); restricted to code directories, 36, the difference being registry-only names such as `ACCESS_GITHUB_CLIENT_*`.
- `privacy-check.sh` exits 0 on the current design, plan, and reviews, and 1 on the plan at `9552ef9`. Of the two Proton addresses in `cloudflare/monitor/config.json`, one isn't in `privacy/patterns.txt`.
- The pinned permission-rule shape follows `~/.claude/settings.json:89`. `secret-set.sh` holds `flag_path` (line 54) and the shared `flock` (89-91); `sync.sh:192-197` fills the age cache through `ws-pass-key`.
- `mail-filters-refresh.service` is `Type=oneshot`; `cloudflare/deploy.sh` has no `--check` (usage line 30); `stalwart-jmap` takes `show ACCOUNT`; `authBanPeriod` is 86400000 (`roles/stalwart/plan.ndjson:6`); `roles/webdav/install.sh:72` starts a member on its `.env` alone; the `dotfiles-pass` map puts `claude-pass`, `pass-count`, and `secrets/**` in `auth-data`.

## Mechanics review

| Finding | Disposition |
|---|---|
| B1 counts, backup, restore read Geoff's plaintext | Folded: Brief fact 5, T3b (`stalwart-status`, `build-plan`, fixture unset), After merge 2. Rebuilt-ward behavior is ruling 1. |
| B2 rebuilt hosts unreachable | Folded at the root (with data B2): T2 cloud-init user per `base/keys/` directory, provision, promote, restore-drill on `SERVERS_SSH_USER`; T8 sitting PR adds his cloud-init user. |
| B3 public repo with a private pattern | Folded: scrub forward (Brief privacy line, pre-flight file, T8 patterns, T11, After merge 5). History is ruling 2. |
| B4 container can't use the agent | Folded: T2 route-check podman line, probed. |
| M1 T3 deletes and the standing answer | Folded: T3 main loop with the full command, standing answer points at it. |
| M2 empty age cache | Folded: T1 identity order with the `ws-pass-key` fill, quoted from `sync.sh`. |
| M3 tests and CI meet the real store | Folded at the root (with data m4): T1 `SERVERS_TEST=1` overrides and refusal; T2 CI workflow. |
| M4 Mint apt tools | Folded: T2 tool list with pinned releases; standing answer. |
| M5 `dry-run.sh` isn't read-only | Folded: Brief fact 1, standing answers. Design erratum owed (below). |
| M6 names not enumerated | Folded at the root (with contract B2): Calls rule plus T1's mechanical derivation; the list goes in the private servers PR, since the names can carry a member's name. `TEST_YAHOO_*` is ruling 6. |
| M7 rotation between T1 and merge | Folded: T11 store recheck. |
| M8 pre-flight 7 undrafted, `*` reaches main | Folded: pre-flight 7 carries both rules, pinned to the pass's worktree, plus `store.sh`'s `..` and main-checkout refusal and the stub proof's `..` case. No separate pre-flight file is needed for the rules. |
| M9 sitting commits auth-data to main | Folded at the root (with contract M7): his own PR, rekey on its branch, Geoff merges in the sitting. |
| M10 T9 is `auth-data` | Folded: T9 class. |
| M11 clock-stop answer stops under the ceiling | Folded: standing answer per `pass-core` Lifecycle step 1. |
| M12 thinkpad-x1 | Folded: Before merge 3, Entry baseline. |
| M13 two-factor method and scope | Folded at the root (with data M6 and contract M1): pre-flight 2 PUT with the full GET body, field diff, members first, dashboard on 403/404/405. |
| M14 Cloudflare-down screen needs DNS | Folded: T5 addresses with `HostKeyAlias`. |
| M15 after-merge commands wrong, no baseline | Folded at the root (with contract M12): Entry baselines; After merge 2 and 3 written in full. |
| M16 retiring `docs/runbook.md` | Folded: T5 re-pointing (`check-links.sh`, `check.test.sh`), T3 files (`monitor-subscribe.service`, `registry.md`). |
| m1 htpasswd stdin form and cost | Folded: T1, probed; cost 10. |
| m2 `.txt` template, install check, restart | Folded at the root (with data m5): T3b. |
| m3 Vale section order and sync guard | Folded: T5. |
| m4 key validation and live diff | Folded (convergent with data M7, folded there): T2, Entry fingerprints. |
| m5 `gh api user` plan name empty | Folded: pre-flight 5 reads billing. |
| m6 BACKLOG numbers | Folded: Brief fact 7, T11. |
| m7 bus-day isolation | Folded (convergent with contract B1): T10. |
| m8 `check-drift` findings | Folded: standing answer. |
| m9 store overrides, bad recipients | Folded at the root (with data m2): T1. |
| m10 Mint images exist (optional) | Refused: optional, and the standing answer is conditional, so a false premise costs nothing. |
| m11 agent with no vault grant | Folded: pre-flight 6. |
| m12 invite expiry | Folded: standing answer, T8 checklist. |
| m13 `%q` hash | Folded (convergent with data B1, folded there). |
| m14 T10 traced-fix continuation (optional) | Folded: free once M11's `pass-core` reading applies; standing answer. |
| m15 route proof fails on an unfixable cause | Folded: standing answer. |
| m16 over-ceremony (optional) | Folded in part: T4 no longer reruns the harness, T3 no longer adds hash tools to a manifest (they're in the base image). Refused for the figure reads: four PNG reads are the only visual check and cost little. |
| m17 GitHub successor scope | Owner fork: ruling 3. |
| m18 estimates (optional) | Folded: re-estimated. |

## Contract review

| Finding | Disposition |
|---|---|
| B1 bus-day check can pass vacuously | Folded: T10 answer key outside the export, `git archive`, mechanical grading. |
| B2 moved-name set is circular | Folded (convergent with mechanics M6): T1 derivation; T4 and Calls name the exact expected OWED rows. |
| M1 pre-flight checks can't run with `ws-admin` | Folded in part (convergent with mechanics M13): 403 fallbacks written. Refused in part: the premise that the GETs 403; the mechanics probe got 200 on both. |
| M2 own-address fixture | Folded: T8 sitting step 1 and the accounts column; pre-flight 5 column. |
| M3 register read | Folded: T11 `prose-voice-reviewer`. |
| M4 concepts and stable links | Folded in part: T6 concept list, T11 read checks link targets. Refused in part: the domain allowlist gate is new machinery with no measured defect (the pages don't exist yet); it's listed under Later. |
| M5 accounts acceptance | Folded: T8. |
| M6 upkeep and alert acceptance | Folded: T8 duty and alert tables. |
| M7 sitting acceptance, key integrity | Folded (convergent with mechanics M9): T8 his PR, the acceptance checks. |
| M8 route proof can pass on Geoff's key | Folded: T4 throwaway-alone rekey, negative control; T2 no-mount assertion and `--network=none` refusal. Design erratum owed (below). |
| M9 T9 verify stows an unmerged branch | Folded: T9 acceptance. |
| M10 vault expected list | Folded: T4 expected sets (with the conductor's new titles), pre-flight 6. |
| M11 two scripts hard-wire Geoff's key | Folded: T2 workstation-assumption grep. The archive question is ruling 4. |
| M12 no baselines | Folded (convergent with mechanics M15): Entry. |
| m1 stop-line grep | Folded: T5 acceptance. |
| m2 "history" undefined | Folded: T5 and T9 acceptance. |
| m3 T3b acceptance on an empty store | Folded: T3b. |
| m4 hash logins proven after merge | Folded (convergent with data M5, folded there). |
| m5 figure and overview checks | Folded: T6. |
| m6 plaintext fixtures | Folded: T1 canary and `TMPDIR`. |
| m7 start-here word ceiling (optional) | Refused: optional; T10's key covers findability. |
| m8 skill pointers unchecked | Folded: T9. |
| m9 fingerprints from pavilion's cache (optional) | Folded: T4 reads them over the session it already opens, one command. |
| m10 `geoff@` grep scope | Folded: T2 grep. |
| m11 rebuild question (optional) | Refused: optional; the question list is the builder's call. |
| m12 pre-flight 6 misses `Workstation` | Folded (with M10). |
| m13 T7 acceptance mostly "not run" | Folded: T7 usage-flag grep. |
| m14 mint leg in the light lane (over-ceremony) | Folded: T2 runs it in CI and the full gate. |
| m15 T4 task-scope review (over-ceremony) | Folded: Tasks preamble drops it for T4. |

## Data review

| Finding | Disposition |
|---|---|
| B1 `%q` cutover changes secrets | Folded at the root (with mechanics m13): Brief fact 8; T1 stores the deployed form and compares old and new `secrets_load` per name; T1 and T3 parse with `${line%%=*}`; byte-exact tests. |
| B2 rebuilt hosts unreachable | Folded (convergent with mechanics B2). |
| M1 wrong hash and the 24-hour ban | Folded: After merge 1 on-host comparison; T3b probe account first and the ban-lift lookup; standing answer. |
| M2 stale-branch rollback | Folded: Calls store path, T1 stale-store guard. |
| M3 two writers | Folded in part: T1 lock, tmp and rename, `.gitattributes`; T7 order and conflict rule. Refused in part: "write only on main" conflicts with the pass's own worktree writes and T4's scratch store, and the stale-store guard already stops the rollback. |
| M4 rotated plaintext, stale hash | Folded: T3b workstation hash check, T3 `secret-set` hint, T7 rule. |
| M5 htpasswd switch proven only against text | Folded: T3b container test, `ExecStart` test, `install.sh` both files, `dry-run.sh` 401 split. |
| M6 two-factor call and members | Folded (convergent with mechanics M13); backup codes in T8 step 1; their home is ruling 5. |
| M7 key sync lockout | Folded at the root (with mechanics m4): T2 preview, atomic write, validation, refusal. |
| m1 `values.age` merge drop | Folded: Before merge 1. |
| m2 recipients check | Folded (convergent with mechanics m9): T1 stanza count. |
| m3 plaintext committed as the store | Refused: a new gate check with no measured defect; `store.sh`'s decrypt check covers every write. The `.gitignore` line is folded (T1). |
| m4 hard-failing loader | Folded (convergent with mechanics M3); #22 standing answer runs the full suite. |
| m5 bare template, 72 bytes | Folded (convergent with mechanics m2); 72-byte refusal in T1. |
| m6 stale copies | Folded: T8 upkeep line, T5 `values.age` instructions. |
| m7 stale-name write, silent skip | Folded: T3 refusal before write, T3b stderr and `--check`. |
| m8 host keys, mint leg | Folded: T4 host keys, T2 mint leg out of the light lane. |
| Fork: recovery codes' home | Owner fork: ruling 5. |

## Owner forks

All six are in the plan's "Rulings for Geoff": 1 rebuilt-ward counts (mechanics B1), 2 git history (mechanics B3), 3 GitHub successor gap (mechanics m17), 4 Geoff-only archives (contract M11), 5 recovery codes (data fork), 6 `TEST_YAHOO_*` (mechanics M6). None was ruled here.

## Errata owed on the design

The fold doesn't edit the design. Two of its sentences under "The check" no longer match the plan:

- "one live, read-only `dry-run.sh`": `dry-run.sh` creates and deletes probe objects at Cloudflare (Brief fact 1).
- "a throwaway identity added to a scratch copy of the store": the scratch copy is rekeyed to the throwaway alone, so Geoff's key can't open it (contract M8).

## Verification read

Source: `2026-10-25-operator-runbook-plan-fold-verification.md` (0 blockers, 6 majors, 9 minors). All 15 folded, none refused, none owed. Each was checked against the source first.

Probes for the new mechanisms:

- `roles/mail-backup/server-restore:158-166` reads a missing count as `-999` and dies after Stalwart has started (read).
- `scripts/apply.sh:95` exits before any git call in `--check` today (read).
- A worktree mounted read-only with the main `.git` mounted read-only at its own absolute path answers `git rev-parse HEAD:<path>` and `origin/main:<path>` in a container that has git (probed; the servers gate image has no git, so `git` joins `tools/mint-packages.txt`).
- The servers repo merges PRs with merge commits (`git log --merges`: #19, #20, #21), so a two-commit order survives the merge.
- `stalwart-jmap show ACCOUNT` takes the `accounts.json` name, and `probe` is one (lines 9-10). `scripts/webmail-check.py:23` signs in with `STALWART_PASSWORD_TEST`.

| Finding | Disposition |
|---|---|
| V-M1 `server-restore` fails on a rebuilt ward | Folded: T3b `stalwart-status skipped` and the `server-restore` filter, with a test; ruling 1's text now states the restore consequence with lines 158-166. |
| V-M2 the merged render escapes twice | Folded: T3 acceptance compares against T1's record and expects the old loader to differ; Before merge 3 and After merge 6 keep old loaders from applying; `## Decisions` records the shell form. |
| V-M3 rekey to A alone fails the write check | Folded: T4 two-step rekey; T1 test of the handoff. |
| V-M4 `--check` needs git in the image | Folded: T2 `.git` mount (probed) and `git` in the tool list; T1 states the override case (`--check` skips the comparison and never fetches, `--apply` refuses). |
| V-M5 rotation between T11 and merge | Folded: Before merge 1 reruns the comparison and updates the servers branch first. |
| V-M6 probe-first not mechanized | Folded with option (b), not (a): two ordered commits and a probe-only ward apply in After merge 2. Option (a), a Stalwart container test, would need a fresh-server bootstrap the repo has no fixture for; (b) costs one apply and proves the same thing live on a test login. |
| V-m1 `systemctl show` without ssh | Folded: After merge 2. |
| V-m2 Entry and Close disagree | Folded: the Close sentence is dropped; Entry requires every ruling answered. |
| V-m3 T5 needs T4's outputs | Folded: T5 placeholders, filled by the main loop after T4. |
| V-m4 stub proof form | Folded: pre-flight 7 tests the assignment form, with flags as the fallback. |
| V-m5 `SERVERS_STORE_BRANCH_OK` on rekey | Folded: dropped from the sitting line. |
| V-m6 stale hash for the other members | Folded: T3b hash check covers every login with both forms; T7 names both commands. |
| V-m7 probe hash name | Folded: `STALWART_PASSWORD_HASH_TEST` in T3b and its acceptance; the plaintext stays. |
| V-m8 workstation history paths | Folded: T9 allows only dated files, listed. |
| V-m9 totals line | Folded: this record's totals line. |

Time: T1 +5, T2 +5, T3b +20, T4 +5. Path 905 (the T1/T2 pair at 165, T3/T3b at 155), task sum 1,435. The rulings are unchanged in number and question; ruling 1's text and both rulings' "no" paths changed (965 and 925).

## Privacy

`privacy-check.sh` exits 0 on this record and on the revised plan.
