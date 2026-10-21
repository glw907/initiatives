# drafter reviewed pages: you approve the blueprint, then the page

Status: designed with Geoff in chat on 2026-10-20, awaiting his approval. Initiative:
`docs-system`. It follows the blueprint-first pass, which ended by ruling after its read at `main`,
and the continue-or-stop review of nineteen passes
(`research/2026-10-20-docs-system-failure-history.md`). About $183 of API credit has bought no
accepted page. The deterministic checks and the drafting seat held up every time; the API judging
seats did not, and the one judging step that worked was B3c's session fact-check with repository
access.

## Brief

Approving this ends drafter's machine acceptance and puts you at the two decisions that set a page's
quality: its blueprint, then its draft. A fresh Claude Code agent checks every fact against the
code before each decision, and a local review tool shows you the findings in place and lets you
edit. The pass proves the flow on one new cairn page, the admin troubleshooting page, merged.

### What changes

- API credit pays for drafting only (your ruling, 2026-10-20). Authoring,
  fact checks, and fixes run on session tokens.
- drafter ships `drafter-fact-check`: a fresh-context, read-only agent that
  checks each fact or claim against the code and returns claim, verdict, file:line, and proposed
  fix. It never fixes anything and never runs in the session that wrote the blueprint.
- `drafter review` is a local review tool with three screens: blueprint review, page
  review, and change review (a blueprint diff and a page diff together, for a code PR). It shows
  each finding on the passage it concerns, edits the markdown in a CodeMirror editor modeled on
  cairn's, saves to the worktree, and prints your decision as JSON. It takes approval-queue's house
  look and its local-server shape, and depends on neither approval-queue nor cairn at runtime.
- Approving a blueprint records its blob and a hash of its facts in
  `drafted.lock`. `drafter page` refuses a blueprint with no current approval. A changed fact lapses
  the approval of every blueprint citing it (D2's idea, rebuilt around your approval, not a read).
- A new page runs: author the blueprint, fact-check it, you approve it, draft, fact-check
  the draft, you approve the page, merge. An established page whose code changed: the blueprint and
  page edits ride in the code PR with one review, unless the change adds or removes a section or
  changes the reader's path, when you approve the blueprint change before the redraft.

### If you approve

1. In an attended sitting, the session builds clickable prototypes of the three screens
   with real data, one screen at a time, in approval-queue's house look. You review each in rounds
   until it is right and approve the set. Nothing is built before that approval.
2. The build runs as a pass under `conductor-drafter`, matched to the prototypes and checked
   against them with `visual-fidelity`.
3. The troubleshooting page goes through the flow. You approve its blueprint and its page in
   `drafter review`, and the cairn PR merges.

### Standing answers

- A prototype round that ends without your approval starts the next round; there is no cap.
- A fact-check finding the author disputes goes to you on the review screen as a finding with the
  author's note, never resolved between agents.
- A draft over its $10 cap stops the draft and reports; nothing retries on credit.

## Scope

Files and interfaces: `cmd/drafter` (new `review` command; `page` refuses an unapproved blueprint),
`internal/` lock and approval code, a new `review/` SvelteKit app built static and embedded with
`go:embed` (the built bundle is committed so `go install` needs no Node, with a gate check that it
matches its source), `claude/.claude/agents/drafter-fact-check.md`, the `blueprint` skill's flow
section, and drafter's docs. In cairn-cms: one outline entry, the troubleshooting blueprint and its
facts, and the page.

Harvest from the parked `worktree-blueprint-first` and `blueprint-first-d2-d4` branches only what
the plan names: likely `drafter excerpt` and the dotted-anchor fix (`979b864`), and D2's fact hash.
The branches stay parked. cairn's `blueprint-first-pages` is deleted after its 23 real fact catches
(saved in `research/2026-10-20-blueprint-first-r2/`) are filed as one cairn backlog item.

## Calls the session made

These settle the builder check's questions. Each is the session's call, not a ruling of yours.

- `drafter page` defaults to the drafting seat and the deterministic checks, with no consistency,
  coverage, review, or final-reader seat. The old seats run only behind an explicit flag. A
  redraft after a failed deterministic check counts as drafting and sits inside the $10 cap.
- `drafter review` commits each save in the worktree, so an approval names a committed blob.
  Approving a page writes its lock entry, page blob and section hashes, re-seeded from your edited
  page. If your edit changes a claim, the session updates the blueprint or fact in the same PR.
- Approval sits beside the old `Accepted` and read-bar fields. A `drafter read` accept doesn't
  satisfy `page`. Existing pages are untouched until their next change, and that change's review
  is their first approval. `drafter check` warns, without failing, on a page with no current
  approval, so cairn's gate doesn't go red on the old pages.
- `page` refuses when a blueprint has no approval, when its approval lapsed on a changed fact, or
  when its section ids differ from the approved blueprint's. An edit inside existing sections
  passes, and the code PR's one review approves the blueprint and page together. A change to the
  reader's path with the same sections is the author's call, raised in the PR.
- The fact check runs as a Claude Code subagent from the authoring session, since a subagent
  starts with a fresh context. It writes its findings as JSON under drafter's state directory, keyed
  by page and commit, for `drafter review` to read. `make install` links the agent the way it links
  the skill.
- A waiver lives in the lock's approval record, with the finding's claim and your reason, so a
  later check can see it.
- Change review is built and tested against a fixture made from a past cairn change, and its
  prototype uses that change's real files. The estimate rises to 540 path minutes to cover it.

Out of scope, for "Later": removing drafter's read and acceptance seats (they stay, unused by this
flow); the seven B3c pages; backlog #33's API agentic read (closed, superseded); a hosted review.

## Check, class, and cost

End-to-end check: the troubleshooting page merges on cairn `main` after you approve its blueprint
and page in `drafter review`, with every fact-check finding fixed or waived, and `drafter check`
and cairn's gate green.

Risk class: `runner` (a new agent and a skill change), so the pass hands over a packet. Not
`live-account`.

Estimate: 540 path minutes of build, excluding your prototype and approval sittings. API spend:
one page's draft, capped at $10. Session tokens: the fact checks and authoring.

Pre-flight: none foreseen. The prototype rounds and the two page approvals are the pass's named
sittings, not pre-flight items.
