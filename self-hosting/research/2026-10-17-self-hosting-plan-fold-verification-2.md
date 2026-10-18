# Self-hosting plan: second fold verification (2026-10-17)

Second verification read of `self-hosting/plans/2026-10-17-self-hosting-plan.md` at `af54e36` (cited `plan:N`), scoped to the round 2 changes from `e43cdb5`. It reads against the fold record's "Round 2" section (`fold:N`), the first verification (`verify1:N`), the design (`design:N`), and the workstation scripts `scripts/secrets/secret-set.sh`, `scripts/secrets/sync.sh`, and `bin/.local/bin/secret-receive` in `glw907/workstation` at `2739239`. Reader: `claude-opus-5-5`, with no part in the reviews, either fold, or the first verification, per `spec-plan-review` "The verification read".

Probes ran in `/tmp/claude-1000/-var-home-glw907--dotfiles/26c03024-495f-48eb-8c85-7a70bf66decd/scratchpad/v2probe`, using a scratch age key, a scratch bare origin, a main clone, and worktrees, with `HOME` pointed at a scratch directory and a fake `op` that always fails. `sync.sh` hardcodes its key cache under `/dev/shm`, so the probe's copy changes that one line to the scratch key and nothing else. No live account was touched. The network reads were Hetzner's public API spec, the `gh` reads of four merged PR bodies, and one read of the workstation repo's merge settings.

**Verdict: passing on blockers, not on majors.** 0 blockers, 2 majors, 7 minors (5 `correctness`, 2 `optional`). B1's durability and clean-checkout rules hold. M2 is closed. M1 is a sound owner fork, but ruling 3's evidence leaves out a production rebuild the plan already schedules. The path arithmetic and the design:443 quote both check out.

## 1. Did B1 close?

**Yes for the rule as stated, with one major left behind (N1).**

- **The live store stays untouched.** Probe: `VALUES=<worktree>/secrets/values.age secret-set.sh RESTIC_PW --value …` left `git status` empty in the main clone and showed ` M secrets/values.age` in the worktree only. The override is real (`secret-set.sh:36`). `secret-receive` calls the main checkout's `secret-set.sh` by absolute path (`secret-receive:18`), and an exported `VALUES` reaches it through the environment.
- **The value is usable before the merge.** `secret-set.sh` regenerates `LOCAL_SECRETS` from the store it just wrote (`secret-set.sh:178`), so `~/.local/secrets` held `RESTIC_PW` at once. `secret-set.sh --sync` run with the same `VALUES` restores it later. The plan names that recovery at `plan:60`.
- **`sync.sh` doesn't do this.** It has no `VALUES` override. It reads `$DOTFILES_DIR/secrets/values.age`, where `DOTFILES_DIR` is the checkout the script itself sits in (`sync.sh:25-27`). Probe: the main checkout's `sync.sh --local` rewrote `~/.local/secrets` without `RESTIC_PW`, and the worktree's own copy of `sync.sh` kept it. So the brief's "`sync.sh` on the same host then makes the value usable" is true only for the worktree's copy of the script, which the plan never names. The plan's own recovery, `secret-set.sh --sync` with `VALUES`, is the right form. N1 covers who regenerates from `main` while a branch is in flight.
- **Durability.** Every restic password and rebuild-critical token is committed and pushed as soon as it is stored, under a draft PR (`plan:61-62`). Each lock is gated on that password being on `origin/main` (`plan:63`, `plan:234`, `plan:271`). M6 and L7 no longer apply a lock (`plan:224`, `plan:262`). No password sits only on an unmerged branch while a lock makes it irreplaceable. The ancestry check can give a false negative, which only delays a lock and never weakens it (n1).
- **`git pull --ff-only` keeps working.** Nothing in the plan writes the main checkout's `values.age`. Pass 0 writes through `.claude/worktrees/self-hosting-pass0` (`plan:135`). W5's round trip uses scratch `VALUES` and `LOCAL_SECRETS` (`plan:192`). The lock file sits outside every checkout (`plan:170`). Nothing checks that this stays true, though (n3).

## 2. Did M1 and M2 close?

- **M1: closed as an owner fork (ruling 3), with an evidence gap (N2).** Hetzner's API spec carries the coupling quote, and the plan quotes it accurately (`plan:20`). The standing answer (`plan:80`), M1's fake `hcloud` (`plan:219`), the `hcloud * rebuild` deny rule (`plan:169`), and erratum 7 (`fold:14`) all follow the recommendation. One gap is new to round 2 (n6).
- **M2: closed.** F3's names ride in Pass 1's workstation PR (`plan:199`). F6b's entry is that PR merged, followed by a `--ff-only` pull and `sync.sh --local` on thinkpad-x1 (`plan:207`). Running `sync.sh` from `main` is correct there, because by then the names are on `main`. F6c clones the servers repo (`plan:211`), and W5 on thinkpad-x1 waits for F6c (`plan:192`). C2's thinkpad-x1 leg now has a producer.

## 3. Contradictions and build order

- **design:443 is quoted correctly.** `plan:63` and `fold:15` quote "after `restic init` and the first verified backup on media, and after the last rehearsal import on mail, before cutover". That is an exact substring of design:443. I1's first step (`plan:234`) comes after the first verified backup (M6) and before the Immich switch. C1's first step (`plan:271`) comes after L5's and L6's rehearsal imports and before the window opens. Moving the locks contradicts "Order of work" items 2 and 5 (design:726, design:729), and erratum 8 records that (`fold:15`).
- **Entry conditions line up.** Pass 3 needs Pass 2's workstation PR merged (`plan:232`). Pass 6 needs Pass 5's (`plan:269`). Each lock step then checks the commit itself.
- **Minutes.** M6 −15 and L7 −15 move to I1 +15 and C1 +15. The pass paths are 680, 250, 725, and 310. The path is 410 + 540 + 680 + 250 + 725 + 310 + 295 + 280 = 3,490. The sum is 3,960 plus 360 = 4,320, and the server branch is 540 + 680 + 250 = 1,470. All of these match `plan:294-308`.
- **Stale rows.** The round-1 rows at `fold:18`, `fold:102`, and `fold:115` still describe the lock in M6 and L7, and `fold:102` still records the refusal that round 2 reversed (n7).
- **No order fails to build.** N1 and N2 are gaps in mechanism and evidence, not order defects.

## 4. Can Geoff rule on the evidence given?

- **Ruling 1: yes.** It now names the shared-password and message-cleanup facts (`plan:18`), and C3 carries them (`plan:273`).
- **Ruling 2: yes.** I spot-checked the cited Score sections with `gh pr view`. dubplate #6 reads "about 9.5 hours … about 725 minutes on the critical path". dubplate #4 reads "about 475 min … against the plan's 695". approval-queue #2 reads "path was 540 minutes; the run took about 105". workstation #75 reads "path plan 35 min; actual about 20". Each ratio in `plan:19` follows from those figures. The "running actual path" is now defined.
- **Ruling 3: not fully.** The cost argument rests on "No production rebuild is planned in these passes" (`plan:20`), and that is false (N2).

## Major

### N1. While a branch store is in flight, `~/.local/secrets` is last-writer-wins across stores, and the plan has no way to detect a lost name (correctness)

- **Location:** `plan:60` (regeneration and the "If another session regenerates it" remedy), `plan:61` (short-lived worktrees for late credentials), `plan:192` (W5 runs `sync.sh --local` and the hash compare on pavilion while passes 1 to 3 run), `plan:185` (Pass W runs alongside passes 1 to 3), `plan:89` (the conductor's dry run for a late credential reads the live file); `secret-set.sh:37`, `secret-set.sh:178`; `sync.sh:25-27`.
- **Defect:** each store writes all of `~/.local/secrets` from whichever `values.age` it read. With N stores live (`main`, the pass's worktree, and any short-lived worktree), the last writer wins. The scratch probe showed both directions.
  1. A short-lived worktree stored `MEMBER_A_TOKEN`, and the regenerated file dropped Pass 2's unmerged `RESTIC_PW`. Pass 2's next store, `TUNNEL_TOKEN`, then dropped `MEMBER_A_TOKEN`, which by then was on its way to `main`.
  2. The main checkout's `sync.sh --local` dropped every branch name.

  The plan schedules exactly this overlap. W5 runs `sync.sh --local` on pavilion during passes 1 to 3, while Pass 1's F3 names or Pass 2's tunnel token and restic password exist only in a branch store. W5's own check, "compares the result with `~/.local/secrets` by hash", also fails falsely whenever a branch has regenerated the file with extra names. Late member credentials arrive during passes 1 to 5 through short-lived worktrees (`plan:61`), and the conductor's dry run and L1's dry run read the live file. The remedy at `plan:60` ("the pass reruns `secret-set.sh --sync` with its own `VALUES`") needs the pass to notice the loss, and nothing tells it. The loss is silent until `render.sh` or `deploy.sh` reads a missing name. Durability is unaffected, because every name is still in some committed store.
- **Proposed fold:** keep `~/.local/secrets` generated from `main` only, and give each in-flight store its own overlay.
  1. A pass runs `secret-set.sh` and `secret-receive` with `LOCAL_SECRETS=$XDG_RUNTIME_DIR/secrets-<pass>`, beside `VALUES`. Its scripts (`render.sh`, `deploy.sh`, `dry-run.sh`) source that file when it exists, and `~/.local/secrets` otherwise.
  2. 0.10 makes `secret-receive` honor `LOCAL_SECRETS`, since it hardcodes `$HOME/.local/secrets` for its post-store check (`secret-receive:19`).
  3. A late credential's short-lived worktree goes through the same overlay rule, and `sync.sh --local` from `main` runs after its merge.

  W5's compare and `sync.sh` are then correct as written. Delete the "If another session regenerates it" sentence at `plan:60`.

### N2. Ruling 3's cost argument says no production rebuild is planned, but L6's image restore is one (correctness, OWNER FORK)

- **Location:** `plan:20` ("No production rebuild is planned in these passes"), `plan:261` (L6 acceptance "the image restore booted"), `plan:257` (L2 turns on Hetzner Backups; M1's provision step turns on protection), `plan:116` ("Human steps", no row for it); design:330 (rehearsal row "Image restore: Last night's Hetzner backup image, restored in place from the console, boots and Stalwart starts"), design:493 and design:653 (the runbook's broken-mail-server path), design:507.
- **Defect:** Hetzner's API restores a backup image in place through the rebuild action. The spec for `POST /servers/{id}/actions/rebuild` says: "Rebuilds a Server overwriting its disk with the content of an Image … The Image can either be one you have created earlier (`backup` or `snapshot` Image) or …" (`docs.hetzner.cloud/cloud.spec.json`, fetched to the scratchpad). The mail server carries delete protection from L2, and so, by the coupling ruling 3 quotes, rebuild protection too. L6's rehearsal row is therefore a production rebuild, and under every option it needs protection off. Under (a) it needs Geoff's flip and a packet, or his own console session, and neither appears in L6 or in "Human steps". Under (b) it needs `provision.sh rebuild` to take an image argument. The same applies to the runbook's emergency screen for a broken mail server, which the second operator may follow from the console (design:237, design:493). His screen needs a "turn protection off, then back on" step, and that is an Emergency-screen change Geoff should see before he rules. So the line "the cost is a rare packet" understates the cost: one rebuild is certain in Pass 5, and the emergency path changes shape.
- **Proposed fold:** correct `plan:20` to name L6's in-place image restore and the runbook's emergency path as the known production rebuilds.
  - Under (a): add a "Human steps" row (Geoff turns protection off for L6's image restore and back on after, or runs the console restore himself), name that row as L6's wait, and add the protection steps to the mail emergency screen in F7 and D5.
  - Under (b): `provision.sh rebuild <host> --image <backup-id>` carries L6.

  Recommendation unchanged, (a): a Pass 5 rehearsal already waits on Geoff for several rows, so one more row costs little. **OWNER FORK:** whether the second operator's emergency screen should tell him to turn protection off himself.

## Minor

| # | Sev | Tag | Location | Defect | Proposed fold |
|---|---|---|---|---|---|
| n1 | minor | correctness | `plan:63`, `plan:234`, `plan:271` | The lock gate is `git merge-base --is-ancestor <commit> origin/main`. `glw907/workstation` allows squash and rebase merges (`gh api repos/glw907/workstation`: squash true, rebase true). Probe: after a squash merge, the password's commit is "ancestor: no". The result is a false negative that stalls I1 or C1. It never weakens the lock, but it also tests a proxy for the property the rule needs. | Gate on content: after a fetch, decrypt `origin/main:secrets/values.age` to `/dev/shm` and compare the restic password's hash with the pass's record. Or require merge commits for these PRs in the packet. |
| n2 | minor | correctness | `plan:60`, `plan:224`, `plan:258`, `plan:203` | The unattended passes now store with an env prefix, `VALUES=… secret-set.sh …`. The plan's own quote of the permissions docs says "An allow rule won't match past an assignment of any other variable" (`plan:168`), and `settings.json` has no rule for `secret-set.sh` at all. Each store is therefore up to the classifier, and a denial is "never retried" (`plan:87`). M6 must store the password before `restic init`, so one denial holds M6, M7, and M8. | 0.10 adds a `--values PATH` flag (and `--local PATH`, for N1) to `secret-set.sh`, passed through by `secret-receive`. It also adds one narrow allow rule for the main checkout's `secret-set.sh` with those flags, proven in the same `dontAsk` session. |
| n3 | minor | correctness | `plan:58`; `fold:25` (refusal of `secret-pull.sh`) | The refusal rests on "nothing writes the main checkout's store". But a bare `secret-receive NAME` still writes it by default (`secret-set.sh:36`), and no check detects that slip. One slip brings back the first verification's B1 without any notice. | Add `git -C ~/.dotfiles diff --quiet -- secrets/values.age` to the conductor's pre-launch checks and to each pass's close checklist. A dirty store stops the launch and is moved into a worktree. |
| n4 | minor | correctness | `plan:64` | The conflict procedure "re-stores each of the branch's own names from its decrypted copy in `/dev/shm`". No such copy exists, because `secret-set.sh` shreds its decrypted file on exit (`secret-set.sh:102`). The procedure also names no owner. The conflict appears when Geoff merges at the packet, after the executor has closed. | The closing session runs the procedure before it sends the packet: it fetches, test-merges, and on a `values.age` conflict decrypts the branch store to `/dev/shm` under a trap, takes `origin/main`'s file, re-stores the branch's names, and checks every hash. |
| n5 | minor | correctness | `plan:203` | F3 is a pair arm, and its secret generation is not placed in the main loop, though only the deploy is ("The arm builds and tests; the deploy runs in the main loop"). An arm works in its own servers-repo isolation worktree, so its `VALUES` target, Pass 1's workstation worktree, sits outside that isolation. | State that the topic names and heartbeat tokens are generated in the main loop, into Pass 1's workstation worktree, as M4 and M6 do. |
| n6 | minor | correctness | `plan:219`, `plan:20` | Under (a), protection is off from Geoff's flip until the rebuild finishes. `provision.sh rebuild` "turns both flags back on after", but the plan never says what happens on a failed stop, backup, snapshot, or rebuild, which would leave a production server unprotected. | Re-enable protection on every exit path after the flip (a trap), and add a test where the fake `hcloud` fails the rebuild and protection ends on. |
| n7 | minor | optional | `fold:18`, `fold:102`, `fold:115`; `plan:211` | The round-1 rows still say the lock lands in M6 and L7, and `fold:102` still records a refusal that round 2 reversed. F6c sits after F8, though it runs in F6b's sitting. | Add "superseded by round 2, B1" to the three rows, and move F6c to follow F6b. |

## Probes and quotes

| Mechanism | Evidence |
|---|---|
| `VALUES` override leaves `main` clean | `v2probe`: after `secret-set.sh RESTIC_PW` with `VALUES` set to the worktree store, the main clone's `git status --short` is empty and the worktree shows ` M secrets/values.age`. |
| Value usable before the merge | Same run: `~/.local/secrets` (scratch `HOME`) lists `RESTIC_PW`. `secret-set.sh --sync` with `VALUES` restores it after a main-store regeneration. |
| `sync.sh` reads its own checkout only | `sync.sh:25-27`. The main checkout's `sync.sh --local` drops `RESTIC_PW`, and the worktree's copy keeps it. |
| Cross-store last-writer-wins | A short-lived worktree's store dropped `RESTIC_PW`, and Pass 2's next store dropped `MEMBER_A_TOKEN`. A merge of `origin/main` into the branch gave `CONFLICT (content): Merge conflict in secrets/values.age`. |
| Squash merge and the ancestry gate | After a squash of the branch, `merge-base --is-ancestor` printed "no". The repo allows squash and rebase merges (`gh api repos/glw907/workstation`). |
| Image restore is a rebuild | Hetzner `cloud.spec.json`, `/servers/{id}/actions/rebuild`: "Rebuilds a Server overwriting its disk with the content of an Image … (`backup` or `snapshot` Image)". |
| design:443 quote | An exact substring of the design's "Lock rules" paragraph. |
| Ruling 2 basis | Score sections of dubplate #6 and #4, approval-queue #2, and workstation #75, read with `gh pr view`, match `plan:19`. |
| Path arithmetic | The pass paths 410, 540, 680, 250, 725, 310, and 295, plus 280 for hand-overs, give 3,490. The sum is 4,320. |
