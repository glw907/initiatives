# Reviewed pages: approval-queue approves, drafter drafts

Status: designed with Geoff in chat on 2026-10-20, awaiting his approval. Initiative:
`docs-system`. It follows the blueprint-first pass, which ended by ruling after its read at `main`,
and the continue-or-stop review of nineteen passes
(`research/2026-10-20-docs-system-failure-history.md`). About $183 of API credit has bought no
accepted page. The deterministic checks and the drafting seat held up every time; the API judging
seats did not, and the one judging step that worked was B3c's session fact-check with repository
access.

## Brief

Approving this splits the docs system in two. drafter becomes a narrow tool that turns an approved
blueprint into a copy-edited page on API credit. approval-queue gains the review side: you approve
each blueprint, then each page, with a fresh agent's fact check shown on the passages it concerns
and an editor to change them. The pass proves it on one new cairn page, the admin troubleshooting
page, merged.

### What changes

- API credit pays for drafting only (your ruling, 2026-10-20). Authoring, fact checks, and fixes
  run on session tokens.
- drafter takes a blueprint and applies the docs standard, the project's register, and the
  project's editing preferences, then drafts. A final edit pass applies the preferences a project
  declares, such as cairn's tidy conventions and dictionary. `check` and `refs` stay, since the
  blueprint is drafter's input. drafter knows nothing of approvals.
- approval-queue gains blueprint and page item kinds and a change review for code PRs. Each shows
  findings on the passage they concern, edits the markdown in a CodeMirror editor modeled on
  cairn's, commits each save to the worktree, and prints your decision as JSON. The new screens
  keep the queue's current look so every screen in it stays coherent, and 907.life later adopts
  that look as separate work (your ruling in the prototype sitting, 2026-10-20). The existing PR
  review and packet screens take the new screens' design language as it settles: the document and
  margin unit centered as one, the place bar, margin notes tied to their lines, and the same keys. A blueprint reaches you only after the author has fixed or
  disputed every fact-check finding, and it shows as an editable document of what the page will
  tell its reader, with a margin note wherever a dispute or correction needs you.
- A fact-check agent joins the workstation's Claude infrastructure: fresh-context and read-only, it
  checks each fact or claim against the code and returns claim, verdict, file:line, and proposed
  fix. It never fixes anything and never runs in the session that wrote the blueprint.
- A new page runs: author the blueprint, fact-check it, you approve it, draft, fact-check the
  draft, you approve the page, merge. An established page whose code changed: the blueprint and
  page edits ride in the code PR with one review, unless the change adds or removes a section or
  changes the reader's path, when you approve the blueprint change before the redraft. The
  `blueprint` skill and `approval-packet` carry this order.

### If you approve

1. In an attended sitting, the session builds clickable prototypes of the three screens with real
   data, one screen at a time, in approval-queue's house look. You review each in rounds until it
   is right and approve the set. Nothing is built before that approval.
2. The build runs as one pass across approval-queue, drafter, and the workstation, matched to the
   prototypes and checked against them with `visual-fidelity`.
3. The troubleshooting page goes through the flow, and the cairn PR merges after your two
   approvals.

### Standing answers

- A prototype round that ends without your approval starts the next round; there is no cap.
- A fact-check finding the author disputes goes to you on the review screen with the author's
  note, never resolved between agents.
- A draft over its $10 cap stops the draft and reports; nothing retries on credit.

## Scope

drafter: `drafter page` defaults to the drafting seat, the new edit pass, and the deterministic
checks; the judging seats run only behind an explicit flag until a later pass removes them. The edit
pass reads a preferences file the project's drafter config names. For cairn that file carries the
showcase's tidy conventions (`examples/showcase/src/theme/site.config.yaml:33-38`) and its
dictionary.

approval-queue: the blueprint, page, and change-review kinds, their command forms, and the
CodeMirror editor. Approval of a blueprint or page lands in approval-queue's decision log, keyed to
the committed blob, with any waiver and its reason. The `blueprint` skill drafts only after a
logged approval.

Workstation: the fact-check agent under the Claude tooling manifest (`claude-infra`), writing its
findings as JSON under approval-queue's state directory, keyed by page and commit.

cairn-cms: one outline entry, the troubleshooting blueprint and its facts, the preferences file,
and the page.

Harvest from the parked `worktree-blueprint-first` branch only what the plan names, likely
`drafter excerpt` and the dotted-anchor fix (`979b864`). Both drafter branches stay parked.
cairn's `blueprint-first-pages` is deleted after its 23 real fact catches (saved in
`research/2026-10-20-blueprint-first-r2/`) are filed as one cairn backlog item.

Out of scope, for "Later": removing drafter's judging seats; the seven B3c pages; backlog #33's
API agentic read (closed, superseded); a drafter-side approval gate.

## Calls the session made

- The blueprint becomes a markdown file with YAML front matter, using cairn's remark directive syntax:
  `:fact[id]` ties a line to its fact and `:::row` holds a troubleshooting row. You edit the file
  itself in the review, so nothing translates your edits back. `drafter check` and `refs` gain a
  markdown reader, the existing cairn blueprints are converted, and the `blueprint` skill changes.
  This is contestable: YAML validates more strictly, which the front matter keeps for settings.
- drafter stays unaware of approvals. The workflow enforces "draft only after approval", which
  gives up a mechanical refusal in exchange for a narrow tool.
- A developer outside this workstation installs drafter and reviews pages however their team
  reviews PRs, so nothing drafter needs lives on one machine.
- A redraft after a failed deterministic check counts as drafting and sits inside the $10 cap.
- Your edit to a page is final; if it changes a claim, the session updates the blueprint or fact in
  the same PR.
- The fact check runs as a Claude Code subagent, since a subagent starts with a fresh context.
- Change review is built and tested against a fixture made from a past cairn change, and its
  prototype uses that change's real files.

## Check, class, and cost

End-to-end check: the troubleshooting page merges on cairn `main` after you approve its blueprint
and page in approval-queue, with every fact-check finding fixed or waived, and `drafter check` and
cairn's gate green.

Risk class: `runner` (a new agent, the approval tool, and skill changes), so the pass hands over a
packet. Not `live-account`.

Estimate: 540 path minutes of build, excluding your prototype and approval sittings. API spend: one
page's draft and edit pass, capped at $10.

Pre-flight: none foreseen. The prototype rounds and the two page approvals are the pass's named
sittings.
