# Self-hosting plan: fold verification (2026-10-17)

Verification read of the folded plan `self-hosting/plans/2026-10-17-self-hosting-plan.md` at `e43cdb5` (cited `plan:N`), against the pre-fold plan at `152b604`, the fold record `self-hosting/research/2026-10-17-self-hosting-plan-fold.md` (`fold:N`), the three lens reviews, and the design `self-hosting/specs/2026-10-17-self-hosting-design.md` (`design:N`). Reader: `claude-opus-5-5`, with no part in the reviews or the fold, per `spec-plan-review` "The verification read".

Probes ran in `/tmp/claude-1000/-var-home-glw907--dotfiles/26c03024-495f-48eb-8c85-7a70bf66decd/scratchpad/verify-probes*` and `vp3`, `vp4`. No live account was called. The only network reads were public DNS lookups and public documentation.

**Verdict: not passing.** 1 blocker, 2 majors, 16 minors. Every review blocker and major closed at its cited location except two. Data B1 closed for concurrency but not for durability, and that leads to the blocker below. Data M7's rebuild-protection fork rests on a false premise (M1 below). Mechanics B1 left one design move untasked (m1). The path arithmetic is correct.

## Blocker

### B1. The storage order leaves `values.age` uncommitted in the live workstation checkout, so the restic-password PR can't be pulled, and a rebase can silently drop the password (correctness)

- **Location:** `plan:210` (M6 storage order), `plan:244` (L3), `plan:248` (L7 entry check), `plan:123` (Pass 0 stores every credential, with no commit step), `plan:191` (F3 tokens, no commit step), `plan:180` (W5 round trip on the live store); `fold:102` (data B1, the refused part); `design:523`.
- **Defect:** `secret-set.sh` writes `$HOME/.dotfiles/secrets/values.age` (`VALUES` default, `secret-set.sh:36`). That file sits in the main checkout, which must stay on `main`, because `~/.claude` and `~/.local/bin` stow from it (`dotfiles-pass`). From the first `secret-receive` in 0.4 until M6, every Pass 0 credential and F3's topic names and heartbeat tokens exist only as an uncommitted change to that tracked file. No task commits them. M6 then commits a copy of that file on a branch, and the PR waits for Pass 2's packet. Five consequences follow.
  1. **The merge can't be pulled.** Probe (`verify-probes`): with `values.age` modified in the working tree, `git pull --ff-only` of a merge that touches it aborts with "Your local changes to the following files would be overwritten by merge". It aborts even when the working-tree bytes equal the merged blob. age encryption is randomized, and any `secret-set.sh` run after the branch commit changes the bytes anyway. `pass-core` "Close" then reports the checkout stale and never forces it. The pull aborts as a whole, so every later workstation merge stays unpulled as well. That includes Pass W's `ws-pass-key` if its PR merges after Pass 2's packet, and W5 needs that helper live.
  2. **Every later launch and worktree goes stale.** `pass-core` "Execute" requires `rev-list --count HEAD..origin/main` to print 0 before a launch, and worktrees branch from local `HEAD` (`worktree.baseRef: "head"`). L3's and D2's workstation worktrees, and P4's, would branch from a `HEAD` that lacks M6's commit.
  3. **A rebase or merge can drop the password.** Probe (`verify-probes2`): two branches that each carry `values.age` give `CONFLICT (content): Merge conflict in values.age` under both rebase and merge. The only resolutions git offers are whole-file picks. A pick of the wrong side drops the other side's entries. 0.10's survivor check runs inside `secret-set.sh`, never inside git. The plan's check that "the pushed blob decrypts to the same hash" runs once, at push time, and never after a rebase or force-push.
  4. **The off-machine copy is weaker than the precedent the fold cites.** Until the PR is opened (the plan opens it at pass close: "rides in this pass's packet"), the branch is the copy's only ref, and deleting or force-pushing the branch orphans it. Workstation PR #81, the cited precedent, merged three minutes after its commit (`35e24ef` at 09:42 -0800, merged 17:45Z), in an attended session. Here the wait is days. Until the merge, the design's recovery claim does not hold for this password: the paper key plus the public repo's `values.age` "so every restic password and token survives losing Proton Pass" (`design:523`).
  5. **The lock lands before Geoff reads the PR.** M6 applies media's Indefinite rules inside Pass 2, so by the time the packet carries the PR, rejecting it can't undo the state it guards. On reject, `pass-core` says to "fix forward", which invites exactly the rebase in item 3.
- **Why this is a blocker:** items 1 and 2 are certain under the plan as written, not a risk, and they block steps `pass-core` makes mandatory. The fold refused data B1's "commit on `origin/main` before the lock" because the merge "would stall the pass" (`fold:102`). Moving the lock removes that stall at no path cost, as fold item 3 below shows.
- **Proposed fold:**
  1. 0.10's PR (merged by Geoff in the Pass 0 session) also commits `values.age` and the workstation registry with every Pass 0 credential stored to that point. Pass 0 closes with the main checkout clean. Pass 1's workstation PR (F6, F8) carries F3's names the same way.
  2. 0.10 adds `scripts/secrets/secret-pull.sh`, test-first. It decrypts the working copy and the incoming blob, refuses unless every incoming name is present locally with an equal value hash, sets the working copy aside in `/dev/shm`, runs `git checkout -- secrets/values.age` and `git pull --ff-only`, then restores the working copy only if it holds names the merge lacks. Every pull of the workstation checkout after a `values.age` merge uses it. A `values.age` conflict on any branch is resolved only by copying the main checkout's current file into the branch and re-running the pushed-blob hash check, never by picking a side. A branch that carries `values.age` is never force-pushed.
  3. Media's lock moves from M6 to the first step of I1, and mail's from L7 to the first step of C1. Each step's entry check is that the password's commit is on `origin/main`, which Pass 2's and Pass 5's packets deliver. The design allows both: rules land "after `restic init` and the first verified backup on media, and after the last rehearsal import on mail, before cutover" (`design:443`). M6's and L7's lock acceptances move with the rule. The drills don't need the lock.
  4. M6 opens the workstation PR as a draft at push time, so GitHub keeps a `refs/pull/<n>/head` ref even if the branch is deleted. Whether that ref survives a force-push was not probed (that would mean a live GitHub write), so fold item 2's no-force-push rule carries the weight.
  5. W5's `secret-set.sh` round trip runs with `VALUES` and `LOCAL_SECRETS` pointed at a scratch copy, so it proves the agent-token path without dirtying either host's checkout. The script's own comment documents that override (`secret-set.sh:33-34`).
  6. The lock file from 0.10 lives under `$XDG_RUNTIME_DIR` or is gitignored, so `git status` never shows it.

## Major

### M1. Rebuild protection can't be left off: Hetzner ties it to delete protection, so the fold's "taken without asking" call rests on a false premise (correctness, OWNER FORK)

- **Location:** `plan:68` (standing answer), `plan:205` (M1 turns on delete protection and rebuilds behind a guard); `fold:109`, `fold:137`; `design:66`, `design:616`, `design:198`.
- **Defect:** Hetzner's own client library documents the server protection flags as coupled. For `delete`: "If true, prevents the server from being deleted (currently delete and rebuild attribute needs to have the same value)". For `rebuild`: "If true, prevents the server from being rebuilt (currently delete and rebuild attribute needs to have the same value)" (hcloud-python, `hcloud/servers/client.py`, `change_protection`). The Ansible module says the same: `delete_protection` "Needs to be the same as `rebuild_protection`" (hetzner.hcloud server module). The design puts delete protection on every production server (`design:616`), so rebuild protection is on as well. Data review M7 quoted the same Ansible line but read it as "the plan never sets it". A production rebuild therefore needs `disable-protection` first. The gate fails on that string in `infra/` and `scripts/` (`design:198`), and the deny rule blocks it as a raw command (`plan:157`). So three design statements can't all hold at once: Claude may rebuild (`design:66`), production carries delete protection (`design:616`), and nothing scripted may disable protection (`design:198`). The fold's reason for not asking ("leaving protection off is the only answer that keeps the design", `fold:137`) is false, because "off" isn't available. Per `spec-plan-review`, a finding that changes the design goes to Geoff. Whether the API rejects a delete-only change or couples the flags silently was not probed, since that would take a live call. M1's fake `hcloud` should model the documented constraint either way.
- **OWNER FORK:**
  - (a) A production rebuild comes to Geoff, who disables protection himself. `provision.sh` runs everything up to the rebuild call, stops, and writes a packet. Claude keeps rebuilds of drill servers and every create. This narrows the rebuild authority in `design:66`, but keeps both guards.
  - (b) `provision.sh` may disable and re-enable protection around its own guarded rebuild. The gate and the deny rule each gain one named exception: the call inside `provision.sh rebuild`, after the stop, backup, and snapshot checks. This keeps the rebuild authority, but turns delete protection from "two API calls instead of one" into one scripted path.
  - (c) No rebuild in place. A rebuild becomes `restore-drill.sh --hold` plus `promote.sh` onto a new server, and the old one is deleted by Geoff. This uses machinery the plan already builds, but `design:509` keeps replacing a server that still exists with Geoff, so in practice it reduces to (a).
  - **Recommendation: (a).** The plan has no scheduled production rebuild; I2's upgrade uses a snapshot. Rebuilds are rare operations that the monthly review raises, and a packet costs little where a scripted protection-off path is the exact hazard the gate exists to stop. Record the choice as a design erratum, and replace the standing answer at `plan:68`. Also add `hcloud * rebuild` to 0.10's deny list (m3).

### M2. thinkpad-x1 can't receive the topic names in Pass 1, so F6b has no producer (correctness)

- **Location:** `plan:195` (F6b), `plan:194` (topics read from `~/.local/secrets`), `plan:191` (F3 stores them through `secret-set.sh` on pavilion), `plan:10`, `plan:258` (C2 needs thinkpad-x1).
- **Defect:** under the plan as written, F3's topic names reach thinkpad-x1 only after some `values.age` commit merges and thinkpad-x1 pulls it and runs `sync.sh --local`. The first such commit is M6's, in Pass 2's packet. So F6b, scheduled in Pass 1, has an entry condition nothing produces in Pass 1. C2's thinkpad-x1 leg inherits the gap. The plan also names a servers repo clone on thinkpad-x1 (`plan:10`, `plan:180`), but no task does the clone.
- **Proposed fold:** B1's fold item 1 (Pass 1's workstation PR carries F3's names) closes it. F6b's entry then reads "Pass 1's workstation PR merged and pulled on thinkpad-x1". Add a 5-minute attended task beside F6b for the thinkpad-x1 servers clone.

## Minor

| # | Location | Defect | Proposed fold |
|---|---|---|---|
| m1 | `plan:272` (D4); mechanics B1 | Mechanics B1 named D4's removal of the `fm*` CNAMEs (`design:368`: "the `fm*` CNAMEs go with it"). The revised D4 never declares them `absent`, and the fold's B1 row doesn't mention D4. | D4 adds `absent` rows for `fm1` to `fm3` in a `cloudflare/dns/` file, with `--check` confirming they are gone. |
| m2 | `plan:161` (0.10 acceptance) | The SSH proof runs `ssh ... geoff@<a name that doesn't resolve>`, but the allow rule names only `mail.907.life` and `media.907.life`, so an arbitrary name can't match it. The likely "fix" would be a broad `Bash(ssh *)` rule. Probe: neither `mail.907.life` nor `media.907.life` resolves today. | Name the target: `ssh -o BatchMode=yes geoff@mail.907.life true`, which fails to resolve until L4 and so proves the rule without reaching a host. |
| m3 | `plan:157` | The deny list leaves raw `hcloud server rebuild` uncovered, so a rebuild can bypass M1's guard. A rule binds Claude's own command, not the call inside `provision.sh`. | Add `hcloud * rebuild` (with and without the full path) to 0.10's deny rules. |
| m4 | `plan:280`, `plan:53`, `plan:240`, `plan:19` | "The passes run in sequence except Pass W and Pass 4" contradicts `plan:53` ("passes 3, 4, and 5 can run alongside each other") and Pass 5's entry, which needs only Pass 2. Ruling 2's "running actual path" doesn't say which passes' score rows count, so summing all of them would compare roughly 4,300 actual minutes against a 3,490 line. | State that the line counts passes 0, 1, 2, 3, 5, 6, 7 in sequence as a conservative bound, and that the conductor sums only those passes' score rows. |
| m5 | `plan:12`, `plan:19` | `pass-core` "Plan" says an estimate is "set from the actual-against-planned path in recent passes' scores". Ruling 2 offers the plan's own task sum with a 1.5x ceiling and no recent ratio, so Geoff rules without the evidence the process names. | Add one line to ruling 2 with the recent ratios (the intake-1 overnight run is already cited in `pass-core`) and whether 5,235 covers them. |
| m6 | `plan:123`, `plan:125`, `plan:210` | Two registries: Pass 0 lists names in the servers repo's `secrets/registry.md`, and M6 commits the workstation's `registry.md`. The plan never says which one is canonical, or whether both get every name. | State that the workstation registry holds every store name (the store's own documentation, `secret-set.sh:30`), and that the servers registry lists which server reads each name. |
| m7 | `plan:203`, `plan:240` | Pass 1's header says it creates the other repos' worktrees, and it launches with `--add-dir` (`plan:187`). Pass 2's and Pass 5's headers don't say this, though M4, M6, and L3 commit to the workstation repo. | Add the line to both headers. |
| m8 | `plan:208` vs `plan:191` | M4 "generates the heartbeat token's server copy", but F3 already generated both heartbeat tokens and deployed them to the Worker. Generating again would break the match. | M4 renders F3's token to the server; it generates only the tunnel token. |
| m9 | `plan:158` | "Fails unless every name in the old store is still in the new one" would break `--delete` (`secret-set.sh:132-149`), which W5 and the registry's retire flow use. | Exempt the deleted `NAME` in `--delete` mode, and test that case. |
| m10 | `plan:165` | "The DNS token is refused a write on another zone" names no payload. If the token is over-scoped, the probe writes to a live site zone. | The refused write is a TXT record at a fixed scratch name, deleted with Claude's own token if it unexpectedly succeeds. |
| m11 | `plan:212`, `plan:210` | M8 needs W3's hash mode merged and the `Servers emergency` vault from W5's FIDO2 session. Its stale-snapshot test also needs the scratch object to be two days old, which is a calendar wait inside Pass 2. None of the three is in Pass 2's entry or path note. | Name the three as M8's waits. Pass 2's close notes that M8 can hold the pass open. |
| m12 | `plan:161` vs `design:622`, `design:689`; `plan:234` vs `design:603` | Two departures are missing from the six owed errata: "guard hooks" became deny rules plus a lock with no hook script, and the 1Password uninstall moved from "once step 5 has passed on both" to P4's cancellation packet. Neither is a ruling. | Add both to `fold:173`'s errata list. |
| m13 | `plan:243` | The RFC 5782 form quoted ("octets reversed") covers IPv4 only, but L2 checks both Primary IPs. | Add the nibble form for IPv6 (RFC 5782, section 2.4), or state that DQS is queried for IPv4 only. |
| m14 | `plan:18`, `plan:259`, `plan:255` | Ruling 1 relies on "the password it set", but Pass 6's entry has already shared each password with its member, who may change it before C3. The sixteen test messages also stay in the members' mailboxes with no cleanup step. | The ruling text names both points. C3 deletes its messages by Message-ID, as L8 does, or says they stay. |
| m15 | `plan:212`, `plan:157`, `plan:190` | M8 deletes `servers-scratch-stale`, but the gate fails on `bucket delete` in `cloudflare/` and `scripts/`, and the deny rule blocks `wrangler r2 bucket delete`. The route for the delete is unnamed, and an improvised one may hit the classifier. | Name the route (an R2 REST `DELETE` in the main loop with Claude's token, on a `servers-scratch-` name only), or leave the bucket to the monthly review. |
| m16 | `fold:5`, `fold:109` | The fold's counts and dispositions check out (104 findings: 87 folded, 16 dropped, 1 fork), but data M7's row records the fork as "not a fork", which M1 above overturns. | Update the row and the "Owner forks" list once M1 is ruled. |

## The two calls taken without asking

- **Rebuild protection left off:** unsound, and the reason is in M1. The flag can't be off while delete protection is on, so the plan's standing answer has no answer behind it, and the design's own rules conflict. This is an owner question.
- **The conductor launching each pass:** sound. `pass-core` "Conductor" says the conductor "launches the next committed prompt from the main checkout after the 'Execute' pre-launch checks", and "Lifecycle" step 1 lets an approved design hand launches to the conductor without Geoff. One condition depends on B1: those pre-launch checks require the main checkout to be level with `origin/main`. As written, the workstation checkout can't meet that after M6's merge.

## The six owed design errata

None of the six changes something Geoff ruled on. Each one touches a mechanism section ("DNS", "What Geoff does", "Workstation wiring", "Claude's operating authority", "Access"), not the "Rulings" list at `design:55-85`.

1. **`dns.sh` deletes within a declared set.** No ruling covers it, and the design's own MX and photos switches need it. This is an erratum.
2. **Added token permissions.** Geoff gets more steps, but these are mechanics, not a ruling. This is an erratum.
3. **The dry run makes writes.** The ruling reads "ends with a dry run proving every token works" (`design:75`), and "one read-only call" appears only in "What Geoff does" (`design:693`). Reversible writes on scratch names are consistent with the ruling, so this is an erratum. m10 narrows the one write that could touch another zone.
4. **`claude-block-op` kept until the uninstall.** This is wiring, not a ruling. It is an erratum, but see m12 for the uninstall timing it implies.
5. **`--keep-stopped` before a rebuild.** This makes the rebuild order stricter and leaves the rebuild authority as it was. This is an erratum. M1, though, is a seventh design-level conflict, and that one is an owner question.
6. **The CA through the cloudflared role.** This is mechanics. It is an erratum.

## Can Geoff rule on the evidence given?

- **Ruling 1 (Claude tests the members' mailboxes): yes.** The options, the privacy boundary, and the household cost are all stated. m14 adds two facts the ruling text should carry.
- **Ruling 2 (line, ceiling, overrun answer): mostly.** The arithmetic is right, and the overrun mechanics are concrete. The ruling lacks the recent actual-against-planned basis that `pass-core` names (m5), and "running actual path" is undefined across parallel passes (m4).
- **M1 adds a third question**, as an OWNER FORK, with options and a recommendation above.

## Path arithmetic

Every figure checks out:

- Pass 0: 410 (thirteen tasks).
- Pass W: path 230, sum 380.
- Pass 1: path 540, sum 600.
- Pass 2: path 695, sum 775.
- Pass 3: 235.
- Pass 4: 225.
- Pass 5: 740 (eight tasks).
- Pass 6: 295.
- Pass 7: 295.
- Path: 3,210 plus 7 × 40 = 3,490.
- Sum: 3,955 plus 9 × 40 = 4,315.
- Ceiling: 5,235, which is 1.5 × 3,490.
- Server branch, passes 1 to 3: 1,470. Pass W plus Pass 4 is 455, so the side branch is shorter, as the plan claims.

## Probes and quotes

| Mechanism | Evidence |
|---|---|
| Pull with a modified `values.age` | `verify-probes`: `git pull --ff-only` aborts ("Your local changes ... would be overwritten") both when the working copy equals the merged blob and when it differs. |
| Binary conflict across branches | `verify-probes2`: rebase and merge of two branches that each change `values.age` both give `CONFLICT (content)`; the only resolutions are whole-file picks. |
| Where `secret-set.sh` writes | `scripts/secrets/secret-set.sh:36`, `VALUES="${VALUES:-$HOME/.dotfiles/secrets/values.age}"`; no `git` call in the script. |
| PR #81 timing | `git show 35e24ef` (09:42 -0800); `gh pr view 81`, `mergedAt` 17:45Z. |
| Pull and launch rules | `pass-core` "Close": pull `--ff-only` only with "no uncommitted change in a file the merge touches", else report stale; "Execute": `rev-list --count HEAD..origin/<default>` prints 0. |
| Hetzner protection coupling | hcloud-python `change_protection`: "currently delete and rebuild attribute needs to have the same value"; Ansible hetzner.hcloud server module: "Needs to be the same as `rebuild_protection`". |
| Fold probes re-run | GNU grep: a missing pattern file exits 2, an empty one exits 1, a blank line exits 0 and matches every line; `age-keygen -y` prints the matching recipient; `flock` is util-linux 2.42.4; `claude --help` lists `dontAsk`. |
| `restic check --read-data --no-lock` (I4) | `vp4`, restic 0.19.1: passes on a read-only repository ("no errors were found"). |
| Planned hostnames | `dig`: `mail.907.life`, `media.907.life`, and `mta-sts.907.life` don't resolve; the apex MX is Fastmail's. |

Sources: [hcloud-python servers client](https://raw.githubusercontent.com/hetznercloud/hcloud-python/main/hcloud/servers/client.py), [Ansible hetzner.hcloud server module](https://docs.ansible.com/ansible/10/collections/hetzner/hcloud/server_module.html).
