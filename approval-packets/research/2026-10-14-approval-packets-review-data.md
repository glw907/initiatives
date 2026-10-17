# Approval packets design: data integrity and failure-risk review

Target: `specs/2026-10-14-approval-packets-design.md` at `c72785d` (branch `approval-packets-design`).
Lens: crash, concurrency, partial write, upgrade, restore, and above all merge authorization. Code
read: `approval-queue` at `8fbe952`, `~/.dotfiles` `pass-core` "Conductor" and "Close".

Count: 4 blockers, 12 majors, 8 minors. One finding is an OWNER FORK (M4).

## Blockers

### B1. The post can map a pick or an override onto the wrong part, or omit a part that then defaults to the session's verdict

- Severity: blocker. Tag: `correctness`.
- Location: spec 106-110 (routine table), 183 (per-row override), 241 (the invariant); code
  `approval-queue/src/lib/cards.ts:84`, `cards.ts:92-103`, `routes/item/[id=id]/+page.server.ts:140-146`.
- Defect: today's guard against a stale page names only each card's kind and title, and picks are
  positional:

  ```ts
  export const fingerprint = (cards: readonly Card[]) => cards.map((c) => `${c.kind}:${c.title}`).join('|');
  ...
  const raw = read(`c${i}`);
  const at = typeof raw === 'string' && /^\d+$/.test(raw) ? Number(raw) : -1;
  ```

  A packet adds per-row routine overrides and choices that carry verdict tags (`[approve]`,
  `[hold]`). If the build copies this pattern, then a parser change between page load and post (a
  server restarted on a new build while a tab is open, which the README's upgrade step causes)
  can reorder choices under an unchanged title. Index 0 then means `[approve]` where the page
  showed `[hold]`, and the fingerprint still matches. The spec also never says what happens when a
  post omits a routine row's override field. The obvious implementation falls back to the
  preselected session verdict, so a row the page never rendered (an older build that drops an
  unknown row kind, or a row lost in the form) reaches `"verdict": "approve"` without being shown.
- Fold: state in "The app" that the server rebuilds every part from the stored packet. The
  fingerprint covers each ask's title and every choice's label and tag, plus each part's ref,
  kind, preselected verdict, and head. The post names every part explicitly, keyed by ref, not
  position, and the server refuses a post that is missing a part, carries an extra one, or sends
  a verdict outside its kind. Add one table row to the decision-builder tests (spec 243): "a post
  missing a routine row is refused, never defaulted".

### B2. The server never enforces the lock, and the switch to `aria-disabled` removes the native guard

- Severity: blocker. Tag: `correctness`.
- Location: spec 60 ("Approve packet unlocks only after every ask has an answer"), 132 (the
  irreversible confirmation), 187-188 (`aria-disabled`, Mod+Enter); code
  `lib/components/ItemPanel.svelte` handler registration.
- Defect: every lock in the spec lives in the page. Today the keyboard path depends on the native
  attribute:

  ```ts
  approve: () => approveButton && !approveButton.disabled && form?.requestSubmit(approveButton),
  ```

  With `aria-disabled` in place of `disabled`, `approveButton.disabled` is always false, and a
  click or `requestSubmit` on the button submits the form. The spec does say that pressing the
  locked button moves focus, but only the page does that. Nothing says the `approve` action
  refuses an unanswered ask or a missing irreversible confirmation. An unanswered ask whose `Part:`
  is a PR then leaves that PR's verdict to whatever the builder defaults to.
- Fold: add to "The decision bar" that the `approve` action refuses (400) a post with an
  unanswered ask, a choice index outside its ask, or a missing confirmation on an irreversible
  packet, as `readChoices` does today for cards. The click and keyboard handlers check the lock
  state, not `.disabled`. The tests at spec 243 gain "unanswered ask posted directly is refused".

### B3. A PR held in one packet merges through another packet's routine approve

- Severity: blocker. Tag: `correctness`.
- Location: spec 140 ("queues it anyway, and both pages mark the part 'also in <packet>'"), 129.
- Defect: the dedupe refusal fires at queue time only, so a PR waiting in two packets is decided
  twice. Here is the case: packet B raises PR #42 as an ask and Geoff picks "hold until X lands".
  Packet A lists #42 as a routine row, preselected `approve`, and one "Approve packet" click
  merges it at the same head. The deliberate answer loses to the default. The "also in" mark is
  the only defense, and the spec puts no rule behind it. Two decides inside each other's 5-second
  hold make it worse: both check, and both write.
- Fold: at decide time the server checks whether a packet holding the same ref at the same head
  has already been decided. On the second page that part is locked to the earlier verdict and
  shown as "Decided in <packet>: hold". The JSON carries the earlier verdict, and the session never
  merges a part another packet held. Run the check and the write under one in-process mutex,
  since the app is a single Node process. Add an end-to-end step: queue the same PR in two
  packets, hold it in one, approve the other, and confirm it comes back held.

### B4. Ask-bound PRs have no specified place in the decision JSON, and no head

- Severity: blocker. Tag: `correctness`.
- Location: spec 142-151 (the JSON), 153 (the merge command), 125.
- Defect: the example `parts` list shows routine parts. The `asks` entries carry `title`, `rule`,
  `choice`, and `recommended`, but no `ref`, verdict, or `head`. A PR whose verdict comes from an
  ask choice tag (`Part: glw907/drafter#42`, choice `[approve]`) has no stated home in `parts`. A
  session then either skips the merge or merges from the ask's label with no
  `--match-head-commit` head, which would be the one merge path without head pinning.
- Fold: state that `parts` lists every part in the packet, ask-bound or routine, each with its
  verdict and (for a PR) the head from the item record, and that every `asks[]` entry carries the
  `ref` it decided. Add a builder test: an ask-bound PR answered `[approve]` appears in `parts`
  with its head.

## Majors

### M1. A server still running the old build renders a packet as an empty triage and accepts a `submit`

- Severity: major. Tag: `correctness`.
- Location: spec 20 and 164 ("keep working throughout"); code `lib/server/items.ts:120-126`,
  `routes/item/[id=id]/+page.server.ts:108-128` and `154-173`, `bin/.local/bin/approval-queue:70-89`,
  README line 21.
- Defect: the server is long-lived (`setsid -f node "$app/build"`), and the command only builds
  when `build/index.js` is missing. The README makes the rebuild and restart a manual step:
  "rebuild after an upgrade with `npm run build --prefix approval-queue` and restart the server".
  The command runs `check-brief.ts` from source, so a new command queues packets while an old
  server is still serving. The old server treats any unknown kind as triage:

  ```ts
  } else {
      const triage = await readJson<Triage>(join(dir, 'triage.json'));
      content = { kind: 'triage', headline: '', lede: '', rows: [], ...(triage && !Array.isArray(triage) && triage) };
  ```

  Zero rows pass the row-count check (`0 === 0`), so Submit writes `{"decision":"submit","rows":[]}`
  for a packet. The spec leaves the packet command's handling of that shape undefined. The
  readiness check at line 86 (`curl -sf "$base/item/$id"`) passes on the old server.
- Fold: (1) The command refuses any `decision.json` that is not a packet `approve` or `reject`,
  exiting 1 and printing nothing on stdout. (2) `readItem` switches on kind exhaustively and
  returns undefined for an unknown kind, so it is a 404. (3) The command compares a build id that
  the build writes, served at `/version`, against the source's id, and refuses with the restart
  line on a mismatch. Put the rebuild and restart in the pass plan's install step.

### M2. A session killed while waiting leaves a live-looking item that Geoff can still decide

- Severity: major. Tag: `correctness`.
- Location: spec 138 ("It then waits for `decision.json`, as every kind does"), 155; code
  `bin/.local/bin/approval-queue:20-21`, `109`.
- Defect: cleanup is a shell trap:

  ```bash
  trap '[ -e "$item/decision.json" ] || rm -f "$item/item.json" "$item/item.json.tmp"; ...' EXIT
  trap 'exit 143' TERM HUP INT
  ```

  SIGKILL, an OOM kill, a power loss, or a session teardown that kills the process group hard
  skips the trap, so `item.json` stays and the packet sits on the board. A restored state
  directory brings back items whose commands are long gone, too. When Geoff approves such a
  packet, no session receives the decision and nothing merges. If the app writes
  `decisions.jsonl` (the spec does not say who does, see M3), the log now holds an approve no one
  acted on, and the dedupe refusal blocks the next session's hand-over of that PR at that head.
- Fold: `item.json` records the command's pid and its `/proc/<pid>/stat` start time. The board
  and the item load treat an item whose process is gone as abandoned: a muted "Session ended"
  row, with the `approve` action refused. The command, not the app, appends to the log (M3).

### M3. The decision log cannot back the dedupe refusal, and its writer, order, and atomicity are unspecified

- Severity: major. Tag: `correctness`.
- Location: spec 129, 155-162, 250 (the end-to-end step that expects four lines).
- Defect, in three parts:
  1. The schema has no `head`, no `verdict`, and no repo. The fields are `time, packet,
     initiative, ref, kind, lane, rule, recommended, chosen, overridden`. The refusal at spec 129
     ("already decided at the same head commit … naming the earlier decision's time and verdict")
     cannot be computed from it, and a design `ref` like `docs/specs/x-design.md` is ambiguous
     across repos.
  2. No writer is named. If the app writes in the action and then crashes before or after
     `writeDecision`, the log and `decision.json` disagree. Log first, then crash: Geoff decides
     again and duplicate lines follow. Decision first, then crash: the merge happens and nothing
     is logged. If the app writes, orphans poison the log (M2).
  3. Concurrent appends: one packet writes N lines. If those go out as N writes, or as one buffered
     stream over 4 KiB (jq flushes in chunks), two writers can interleave, and a crash leaves half
     a packet logged.
- Fold: add `repo`, `head` (PR parts), `sha256` (design parts, see M8), and `verdict` to the line.
  The command appends after it reads `decision.json` and before it prints, under `flock` on
  `$root/decisions.lock` (the script already uses `flock` for `start.lock`), as one write. The log
  then records exactly the decisions a session received. Readers skip a truncated last line. On
  reject, log one line per part with `verdict: "reject"`, so the M4 fork has data either way.

### M4. What the dedupe refusal refuses is unsettled: holds, rejects, and a delivered approve that never merged (OWNER FORK)

- Severity: major. Tag: `correctness`.
- Location: spec 129, 251; `pass-core` Close: "On reject, it fixes forward from the note."
- Defect: the refusal applies to any earlier decision at the same head. Three cases go wrong:
  - After a reject whose note asks only for a better packet (no code change), the session can
    re-send only by pushing a no-op commit, which resets CI.
  - After a hold ("wait until X lands"), re-asking at the same head is the intended next step,
    and the refusal blocks it.
  - A session that received an approve and died before `gh pr merge` leaves an open PR that the
    next session can never hand over. Nothing says whether the logged approve authorizes the
    merge.
- Options:
  - (a) Refuse only when the earlier verdict was `approve`, and print that decision so the session
    merges on it at exactly that head. A hold, send-back, or reject re-queues with a "Held on
    <date>: <note>" mark.
  - (b) Refuse only a PR that GitHub reports merged or closed (one `state` field on the existing
    `gh pr view`). Everything open re-queues with an "Already decided on <date>" mark. This is
    the least code, and no merge ever rests on the log.
  - (c) Keep the spec's refusal of any earlier verdict, and document the no-op-commit workaround
    plus how to merge on a logged approve.
- Recommendation: (b). It drops log-reading from the merge path, so the dedupe can never
  authorize or block a merge by itself. The double meeting it was meant to stop (a PR plus its
  triage) is gone by construction. The monthly review still sees "parts decided twice" from the
  log. Change end-to-end step 5 to match.

### M5. The diff Geoff reads can differ from the head the JSON pins

- Severity: major. Tag: `correctness`.
- Location: spec 138 ("fetches the title, head commit, checks, and diff as the `pr` kind does
  today"), 241; code `bin/.local/bin/approval-queue:45-53`.
- Defect: the head and the diff come from two calls:

  ```bash
  view=$(gh pr view "$source" -R "$repo" --json body,headRefOid,number,url,headRefName,baseRefName,statusCheckRollup)
  ...
  gh pr diff "$source" -R "$repo" >"$item/diff.patch"
  ```

  A push between them pins `head` to commit A and shows the diff of commit B. `--match-head-commit
  A` then merges code Geoff never saw. A packet with N PRs runs N such windows. The spec states
  the invariant ("a PR's `head` must be the commit the page showed") but keeps the racy fetch.
- Fold: after the diff, re-read `headRefOid` and refetch while it moved (bounded, three tries,
  then exit 1). Or fetch the diff for the pinned commit
  (`gh api repos/<o>/<r>/compare/<base>...<head>` with the diff media type). State that the JSON's
  `head` comes from the item record the command wrote, never from the form post.

### M6. Only failing checks are enforced, so a PR the old flow forced a decision on can arrive preselected `approve`

- Severity: major. Tag: `correctness`.
- Location: spec 55 (`gate-failed` covers "A check or the independent review failed"), 128; code
  `lib/cards.ts:32-67`; `pass-core` Close, `## Before merge` and `claude-merge-guard`.
- Defect: today `cardsFor` raises a card on its own for a failed check, for a review verdict of
  `fix` or `escalate`, and for a `## Before merge` section, and Approve stays locked until each
  card has a choice. The packet parser enforces only the first: "A PR whose checks fail, with no
  `gate-failed` ask naming it". Three paths stay open:
  - A routine row with a `fix` review verdict passes the parser.
  - Pending checks pass, so a merge can land before CI finishes when branch protection does not
    block it.
  - A `## Before merge` PR loses the "The session runs it, then merges" or "I'll run it myself"
    choice that `pass-core` reads to decide whether to merge at all.
- Fold: extend the refusal rows. A PR whose review verdict is `fix` or `escalate` needs a
  `gate-failed` ask. A PR with pending checks is refused ("wait for checks"), or needs a
  `low-confidence` ask. A PR with a `## Before merge` section needs an ask whose choices carry the
  two existing labels. Update the `pass-core` paragraph to map onto it.

### M7. A `step:N` ref has no defined link to a plan step

- Severity: major. Tag: `correctness`.
- Location: spec 76-79 (numbered plan steps), 110 (routine rows of kind `step` keyed by "what the
  step does"), 149 (`"ref": "step:2"`).
- Defect: a routine step row is written as free text, yet the JSON names it `step:2`. Nothing
  ties the row to plan step 2, nothing refuses a row that matches no step, and nothing says
  whether every `[irreversible]` step needs a row. An override to `skip` on the row Geoff read can
  come back as the number of a different step, and the session runs or skips the wrong one.
- Fold: the routine `Part` cell for a step is `step:<n>`, and the parser refuses an `n` outside the
  plan list. Each `[irreversible]` step must have a row or an ask, and the confirmation at spec
  132 names steps by number.

### M8. A design part's approval names a path, not the content Geoff read

- Severity: major. Tag: `correctness`.
- Location: spec 109, 138 ("reads design parts from their paths"), 148; code
  `bin/.local/bin/approval-queue:55` (`cp "$source" "$item/doc.md"`).
- Defect: the page renders the copy, and the session acts on the path. An edit to the file
  between queue and decision (another session, or a worktree switch) leaves Geoff's approve
  attached to text he never saw. The ref is relative with no repo, so in a cross-repo packet it is
  ambiguous, and it is ambiguous in the log too.
- Fold: the design ref is `<owner>/<repo>:<path>`. The command stores the file's `sha256` in the
  item record, and the JSON carries it. The session confirms the hash before acting and re-queues
  on a mismatch.

### M9. Two posts on one item both pass the "still waiting" check, and the second overwrites the first

- Severity: major. Tag: `correctness`.
- Location: spec 189 (the hold), 241; code `lib/server/items.ts:131-136`,
  `routes/item/[id=id]/+page.server.ts:22-36`.
- Defect:

  ```ts
  const tmp = join(dir, 'decision.json.tmp');
  await writeFile(tmp, JSON.stringify(decision));
  await rename(tmp, join(dir, 'decision.json'));
  ```

  `readWaiting` checks `decided`, and the write comes later, so two tabs on one packet (a second
  tab opened from the board, or an old tab) can both pass. The `rename` replaces the first
  decision. The command may already have printed it, so the session merges on decision 1 while
  the board and any app-side log record decision 2. The shared tmp name also lets two writers
  clobber each other's temp file.
- Fold: write to a per-request tmp, then `link(tmp, 'decision.json')`, which fails with EEXIST on
  an existing file (exclusive create), then unlink the tmp. On EEXIST, return 409 "Already decided".
  Use the same mutex as B3.

### M10. A partial merge has no defined order or stopping rule

- Severity: major. Tag: `correctness`.
- Location: spec 153 ("the session merges each PR whose verdict is `approve` … reports what it
  did with each one"); `pass-core` Conductor ("merged in the order its prompt names").
- Defect: in a packet with two PRs in one repo, merging the first can make the second conflict,
  or can change the base under a diff Geoff approved. A failed `--match-head-commit` on PR 2,
  after PR 1 has merged, leaves the packet half landed. Nothing says whether irreversible steps
  still run.
- Fold: the session merges in the packet's listed order and stops at the first failed merge. It
  runs no `[irreversible]` step after a failure, and re-queues the remainder as a new packet that
  states what landed.

### M11. The monthly review reads data no log records

- Severity: major. Tag: `correctness`.
- Location: spec 234 ("packets the command refused for more than three asks, and parts decided
  twice"), 235 (word target).
- Defect: a refusal exits 2 before any item directory exists (`check_brief` runs before
  `mkdir -p "$item"`), so it leaves no trace. The word-target check needs the packet text, and the
  spec never says the packet file is kept in the item directory.
- Fold: the command appends each refusal (time, initiative, defect) to `refusals.jsonl` under the
  same lock, and copies the packet to `items/<id>/packet.md`.

### M12. An ask with `Part: none` cannot hold a part, so "don't ship this" still merges

- Severity: major. Tag: `correctness`.
- Location: spec 86 (`Part: <a part reference, or none>`), 125.
- Defect: only a PR-bound ask's choices set a verdict. Suppose an ask with `Part: none` asks
  "Ship this sweep now or after the release?" and Geoff picks "after". Approve packet still marks
  every routine PR `approve`, and the session merges them. Reconciling the label with the parts
  is left to the session's reading.
- Fold: a choice may carry `[hold-all]`, which sets every part to `hold` in the JSON. Or the
  register rule says that an ask whose answer conditions a part names that part, and the parser
  refuses verdict tags on a `Part: none` ask.

## Minors

### m1. One corrupt JSON file breaks the board

- Severity: minor. Tag: `correctness`.
- Location: code `lib/server/items.ts:58-65`.
- Defect: `readJson` re-throws parse errors, so a zero-length `decision.json` after a power loss
  (a rename with no fsync) fails `listWaiting` and every page.
- Fold: fsync the tmp file before the rename, and have the listing skip an unparseable item with a
  log line. The command treats an unparseable `decision.json` as exit 1.

### m2. The hold has no stated input lock for the new controls

- Severity: minor. Tag: `correctness`.
- Location: spec 183, 189.
- Defect: the form data is captured at submit, and today the cards lock with
  `disabled={desk.held || decided}`. The spec does not carry that lock to the routine overrides or
  the ask radios. A change during the 5 seconds would then show on the page but not be sent.
- Fold: one line, "every control locks during the hold".

### m3. A hold paused indefinitely becomes a silent undo

- Severity: minor. Tag: `optional`.
- Location: spec 189 ("pausing while the pointer is over the bar"); code `ItemPanel.svelte`
  `beforeNavigate` (`if (navigation.willUnload) { desk.undo?.(); ...`).
- Defect: a pointer left resting on the bar keeps the hold paused, and closing the tab then
  undoes the decision. Geoff believes he decided.
- Fold: cap the pause, for example resuming after 30 seconds, or show "Paused, not sent" in the
  status region.

### m4. The choice-tag vocabulary is unstated

- Severity: minor. Tag: `correctness`.
- Location: spec 97-98, 125.
- Defect: the spec does not say whether `[send-back]` is legal on a choice. Duplicate choice
  labels within an ask are not refused, and the JSON reports choices by label.
- Fold: the tags are the kind's verdicts, and the parser refuses a duplicate label within an ask.

### m5. A merged or closed PR is not refused at queue time

- Severity: minor. Tag: `correctness`.
- Location: spec 129.
- Fold: add `state` to the `gh pr view` fields, and refuse a merged or closed PR. Under M4(b),
  this is the whole dedupe.

### m6. Old kinds sit outside the dedupe and the "also in" mark

- Severity: minor. Tag: `correctness`.
- Location: spec 164.
- Defect: a `pr` item and a packet holding the same PR during the transition are not cross-marked,
  and `pr` decisions are not logged.
- Fold: "also in" spans single items, and `pr` and `design` decisions append to the log too.

### m7. The order of irreversible steps relative to merges is unstated

- Severity: minor. Tag: `optional`.
- Location: spec 77-79.
- Fold: steps run in plan order, and a step after a merge runs only when that merge succeeded.

### m8. The log is single-copy state with no retention line

- Severity: minor. Tag: `optional`.
- Location: spec 155, 237.
- Defect: `decisions.jsonl` lives only in `~/.local/state`, and losing it loses the record the
  monthly review evolves on.
- Fold: the monthly `log.md` line records the month's counts, so a lost log costs at most one
  month of history.

## Over-ceremony

No costly ceremony turned up under this lens. The one saving on offer is M4(b): it replaces a
log-reading dedupe path, and its tests, with one field on a call the command already makes.
