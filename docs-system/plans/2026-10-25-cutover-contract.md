# The `docs` review: the fixed interface

Initiative: docs-system

Design: `~/Projects/initiatives/docs-system/specs/2026-10-25-docs-as-code-cutover-design.md`,
approved by Geoff 2026-10-25 (Approval Queue item 20261025T215556-1865163), "The Approval Queue".

This file fixes the `docs` kind's interface before any executor starts. Three pieces of work code
against it and against nothing else: the Approval Queue executor builds it, the cairn executor's
`cairn-docs` skill (`references/review.md`) tells a session how to use it, and the infra
executor's `approval-packet` rewrite points at it. A change to anything here goes through the
conductor, which amends this file on a branch and tells all three executors.

The planning session read approval-queue at `4f1e833` (`bin/.local/bin/approval-queue`, the
`page` and `change` paths: `check_blueprint`, `check_origin`, `queue_change`, `doc_decision`,
`change_decision`, `head_unmoved`, `revision_program`, `waiting_item`, `load_collected`;
`approval-queue/src/lib/server/blueprint.ts` and `items.ts`), and the live state directory's 22
`page` items and their decisions.

## Planning notes

Each note says what the design leaves open or gets wrong, the reading this plan takes, and
whether it is an escalation. None changes the design's outcome, so none stops the run.

1. **The note shape.** The design outlines a note as `{file, anchor: {quote, prefix?, suffix?},
   body}`, and the decision as carrying `calls`. A call needs a note with choices, so the outline
   alone can never produce one. Geoff answered a `decide` note on 8 of the 22 page reviews on
   record, and 16 notes used `was` and `now`, so ruling 7 ("the current review workflow ... stays")
   keeps them. Reading taken: a note keeps `id`, `kind`, `title`, `choices`, `was`/`now`, and
   `sides`, gains a required `file`, and takes a quote anchor only. Dropped as blueprint-era: the
   named anchors (`<slug>.p<n>`, which no page review needs once quotes exist), a choice's `text`
   and `edit` (never used on a page review), and `waived` (the facts store's dispute record). Not
   an escalation.
2. **Which pages.** The design says each changed `docs/**/*.md` page. The `change` kind left out
   `docs/internal/`, but the register PR the design queues as a `docs` review changes
   `docs/internal/docs-register.md`. Reading taken: every changed `docs/**/*.md` file, internal
   ones included. Not an escalation.
3. **`approved`.** The design removes `approved --kind`'s blueprint default. The command's only
   caller was drafter, which goes, and it matched only `blueprint` and `page` lines. Reading
   taken: the whole `approved` command goes. Not an escalation.
4. **`notes --check`.** It took one file, since a blueprint or page note named none. A `docs`
   note names its file, so the form becomes `notes --check <worktree> <notes.json>`. Not an
   escalation.
5. **The send-back carries `commit` too.** Geoff's in-place edits commit to the worktree, so the
   session needs the commit he left on a send-back as much as on an approve, to push his edits
   before fixing forward. Both printed shapes carry `pr`, `head`, and `commit`. Not an escalation.
6. **CI before the merge.** The design's merge step is push, then `gh pr merge
   --match-head-commit <commit>`. Where Geoff edited, the push starts the repo's CI on a commit no
   gate has seen, and neither cairn-cms nor approval-queue protects `main`, so a merge would not
   wait for it. Reading taken: the session waits for the repo's CI watch on `<commit>` before the
   merge, and a red is fixed forward and queued again. Not an escalation.
7. **A comment on an approve.** Geoff can comment and approve at once (the Architecture page,
   2026-10-25: "a site's"). Merging a session's edit after the approve would merge text he did not
   see. Reading taken: the session merges at `<commit>`, then lands each change a comment asks for
   after the merge: a fix of one sentence or less as a `pass-core` direct change, which a comment
   from Geoff fully specifies; anything larger as a follow-up docs PR, queued as a `docs` review.
   Not an escalation.
8. **The conductor cannot load cairn's skill or agent.** It launches from the approval-queue
   checkout, and Claude Code loads project skills and agents from the directory the session starts in. The
   morning `/healthz` fix therefore runs in a short session launched from a cairn-cms worktree,
   which also tests that the skill triggers on a plain request. Not an escalation.
9. **cairn-cms#134**, a draft PR of the old reviewed-pages flow (a blueprint, an outline, a facts
   file, `drafter.toml`), is not in the design. Every file it adds retires tonight. Reading taken:
   the morning packet carries a `[session]` step to close it with a comment; nothing touches it
   overnight. Not an escalation, since closing a PR reopens.
10. **Survey's vendored copy.** The workstation carries Survey's skill as a vendored copy that
    only Survey's "Releasing a change" sequence may change, and the Approval Queue's register test
    reads that copy's `approval-brief.md` exemplars. Reading taken: the workstation PR vendors the
    Survey PR's branch per that sequence and carries a `## Before merge` (cut the Survey release,
    then the diff check), so it reaches Geoff as a forced ask, and the morning packet gains the
    release step. Not an escalation: it is the documented way to change the file the design names.
11. **Unlisted residue.** The fresh reads found files the design's lists do not name: in cairn,
    the shipped `cairn-extend` skill (both copies) links `docs/internal/facts/extend.md`, plus
    `docs/internal/docs-maintenance.md` and `docs/internal/pass-gate-tiers.md`; in the workstation,
    the `settings.json` repository-visibility line, `docs/STATUS.md`'s Drafter section, open
    `BACKLOG.md` items about the retired system, and two dated provenance lines in `plan-reviewer`
    and `design-refinement`. The design's residue standing answer covers them, so the plans list
    them as tasks. Not an escalation.
12. **The other workstation.** thinkpad-x1 may carry a drafter install too. Nothing tonight can
    reach it; after its next `~/.dotfiles` pull, `check-drift` there reports `~/.local/bin/drafter`
    as an unlisted bin. The infra PR lists it under "Found, not done".
13. **Main checkouts.** cairn-cms's main checkout is 76 commits behind `origin/main`, and Geoff's
    interactive session `cairn-cms-ae` sits idle in it. Survey's is one commit ahead with another
    session's unpushed FRICTION entry. Reading taken: no one pulls or edits either checkout; each
    executor cuts its worktrees from `origin/main` with `git worktree add` and enters by path.
14. **Facts records the inventory missed.** `docs/internal/record/harvest/` holds 53 outputs of
    the retiring `verify-harvest`. It sits under `record/`, so it is history and stays.
15. **Risk class.** The infra plan's secret removal edits `secrets/**`, which the dotfiles adapter
    maps to `auth-data`, so that task gets its task-scope `diff-reviewer` read. Its PR waits for
    Geoff either way, so nothing about the run changes.

No finding changes the design. The design's path, about 460 minutes in parallel against the
900-minute ceiling, holds: the plans' paths are approval-queue 405, cairn 350, and infra 175.

## The command

```
approval-queue docs <worktree> <owner/repo#n> <title> --description <file> [--notes <notes.json>] [--replies <replies.json>]
```

Flags may sit anywhere after `docs`. `<worktree>` is the top of a git worktree of the PR's
repository, checked out at the PR's head. `<title>` follows the packet title rule (sentence case,
no closing punctuation, at most 80 characters). The command fetches the PR, queues the item under
`$XDG_STATE_HOME/approval-queue/items/<id>/` (default `~/.local/state/approval-queue/`), starts
the app if it is down, prints `approval-queue: queued <id> at <url>` on stderr, opens a tab as the
other kinds do, and waits. On a decision it prints one line of JSON on stdout and exits 0. Stdout
never carries anything else.

Run it as a background command (`setsid -f`, stdout to a decision file the session watches), as
`approval-packet` says for a packet.

### Refusals

Each refusal prints one line naming the problem on stderr and exits before anything is queued.

| Condition | Exit |
| --- | --- |
| Wrong argument count, an unknown flag, or a flag with no value (prints the usage) | 2 |
| `<owner/repo#n>` is not that shape | 2 |
| `--description` missing, not a file, or failing the description check (a background paragraph, then one or two summary paragraphs), or a bad title | 2 |
| `<worktree>` is not a git worktree's top | 2 |
| The worktree's `origin` is not `<owner/repo>` | 2 |
| `git -C <worktree> status --porcelain --untracked-files=no` prints anything ("commit or stash first") | 2 |
| The worktree's `HEAD` is not the PR's head ("push first, or pull the PR head") | 2 |
| The PR is merged or closed | 2 |
| The PR changes no `docs/**/*.md` file that exists at its head ("queue it with the pr form") | 2 |
| A notes or replies file that is missing, not JSON, or not the shape below; a note or thread whose `file` names no changed page; a quote that matches more than once in its page | 2 |
| The PR is already in a waiting item (a packet part, a `pr` item, or a `docs` item) | 2 |
| `gh` cannot read the PR, its diff, or its merge base | 1 |

A draft PR is accepted, and pending checks are not refused: a docs review reads the pages, and
CI is the merge step's business.

### Changed pages

A changed page is a file the PR's diff adds, modifies, or renames whose path at the head matches
`docs/**/*.md`, `docs/internal/` included. A deleted page has nothing to edit; it shows in the
code diff. A rename reads its old text from the old path. The diff is taken between the merge
base and the head, where the merge base is GitHub's (`gh api
repos/<owner/repo>/compare/<baseRefOid>...<head> --jq .merge_base_commit.sha`), so commits the
base branch gained after the branch was cut never read as the PR's. Both commits are read from the
worktree with git; one the worktree lacks is fetched from `origin` first.

### The notes file

A JSON array of notes. Each note:

```json
{
  "id": "N1",
  "file": "docs/extend/rotate-the-github-app-key.md",
  "kind": "info",
  "anchor": {"quote": "answers with status 503", "prefix": "The route ", "suffix": " when"},
  "title": "Fact check corrected the status code",
  "body": ["The page said 200. `src/lib/sveltekit/health.ts:188` answers a failed check with 503."],
  "was": "The route answers with status 200 even when the check fails",
  "now": "The route answers with status 503 when the check fails"
}
```

- `id`: a non-empty string, unique in the file.
- `file`: a changed page's path, as above.
- `kind`: `info`, `decide`, or `question`.
- `anchor`: an object with a non-empty `quote` and optional string `prefix` and `suffix`, and no
  other key. The screen places it at the one place `prefix + quote + suffix` occurs, else at the
  first occurrence of `quote`, else at the top of its page. A quote that matches more than once
  with its context (a missing `prefix` or `suffix` reads as empty) is refused, naming the note, the
  quote, and the count; a quote that matches nowhere is not refused.
- `title`: a string. `body`: an array of paragraph strings.
- Optional: `was` and `now` together (strings); `sides`, an array of `{who, text}` strings;
  `choices`, an array of `{label, done}` strings, where `done` says what the session will do on
  that choice.
- A `decide` or `question` note must carry choices. Approve stays locked until each has one.

### The replies file

The author's answers to the comments of a send-back, passed when the item is queued again:

```json
[{"id": "C1", "status": "done", "text": "<the author's reply>", "quote": "<the comment's quote>",
  "anchor": {"quote": "...", "prefix": "...", "suffix": "...", "from": 120, "to": 168, "commit": "<sha>", "file": "docs/extend/x.md"}}]
```

`id`, `quote`, and `anchor` are copied from the decision's comment. `status` is `done` (the
change is made), `kept` (the text stays, and `text` says why), or `answered` (the comment asked a
question, and `text` answers it). `anchor.file` must name a changed page. An empty array is
accepted. A new comment on the re-queued item takes an id past every thread's.

### The screen

The item opens with the title and description, the PR (number, branch, checks) and its body, then
the code diff (the PR's diff without the changed pages), then each changed page as an editable diff
against its merge-base text, with its notes and comments beside the lines. Every pause in typing
(or Ctrl+S) writes that page in the worktree and commits it alone with `Edit <path> in review`.
Geoff selects text to comment; each comment saves on Save. A resend shows "Revision N" and a "Since
you sent it back" diff. Approve, Send back with note, and Defer act as on the other kinds.

### The decision

An approve prints, keys in this order:

```json
{"decision":"approve","pr":"glw907/cairn-cms#150","head":"<PR head, unmoved since the queue>","commit":"<worktree HEAD at approval>","calls":[{"id":"N2","choice":"Apply the fix"}],"comments":[],"threads":[]}
```

`commit` equals `head` when Geoff made no edit, and is a descendant of it holding only his `Edit
... in review` commits when he did. A send-back prints:

```json
{"decision":"reject","note":"<his note>","pr":"glw907/cairn-cms#150","head":"<PR head as queued>","commit":"<worktree HEAD at the send-back>","calls":[],"comments":[{"id":"C1","text":"...","anchor":{"quote":"...","prefix":"...","suffix":"...","from":120,"to":168,"commit":"<sha>","file":"docs/extend/x.md"}}],"threads":[]}
```

`calls` holds each answered `decide` or `question` note as `{id, choice}`; on a send-back, only
those he answered. `comments` holds every comment, `{id, text, anchor}`, where the anchor's
`commit` is the worktree HEAD when he saved it and `file` names its page. `threads` holds
`{id, reply}` for each author reply Geoff answered; a thread he resolved or left alone resolves at
the decision. A defer prints `{"decision":"defer","id":"<id>"}`.

Every approve and send-back appends one line to `decisions.jsonl`:

```json
{"time":"<ISO 8601 UTC>","packet":"<id>","initiative":null,"ref":"glw907/cairn-cms#150","kind":"docs","lane":"single","verdict":"approve","head":"<sha>","commit":"<sha>","calls":[],"comments":0,"replies":0}
```

`comments` and `replies` are counts here. A send-back's line has `"verdict":"reject"`.

### The approve refusal

At an approve the command reads the PR's head. If it is not the head the item was queued at, the
approve is refused: nothing is logged, `refused.json` is written in the item directory
(`{"at": "<ISO 8601 UTC>", "reason": "The pull request moved after it was queued, so the approval wasn't recorded. The session will queue it again."}`),
the rail shows the row as "Refused", and the command exits 1 with a line naming the PR and both
heads. A head `gh` cannot read exits 1 with nothing logged and no `refused.json`, so the item
stays in `pending` for a `collect` to retry. The session pulls the new head into the worktree and
queues the item again.

### Revision

A `docs` item queued after a send-back of the same PR is a revision. The command looks up the PR's
latest counting reject line for `{"ref": "<owner/repo#n>", "kind": "docs"}` with the existing
revision lookup, writes `revises: {item, revision, commit}` into `item.json` (`commit` is the
send-back line's), and saves what changed since: `since.patch` (`git -C <worktree> diff <commit>
HEAD`) when that commit is an ancestor of HEAD, else `since.json` as `{"gone": true}`. The screen
shows "Revision N" and the since diff. A `docs` item needs no `## What changed`: the replies answer
each comment, and the description says what changed.

### Amend

A `docs` item queued when the PR's latest `docs` line in `decisions.jsonl` is an approve (CI went
red after the approve, say, and the session fixed forward) is an amend review, kept from the page
kind. The command reads that approve line's `commit`, writes `amends: {"commit": "<sha>"}` into
`item.json`, and saves `approved.patch` (`git -C <worktree> diff <commit> HEAD`) when that commit
is an ancestor of HEAD, else `approved.json` as `{"gone": true}`. The screen shows a "Since you
approved" diff above the pages. An amend is never also a revision: the latest line decides.

### The other commands

- `approval-queue notes --check <worktree> <notes.json>`: the queue-time notes checks without
  queueing, with each note's `file` read from the worktree's `HEAD`. Prints nothing and exits 0
  when they pass; exits 2 with the queue-time messages when they do not, or when a path is missing.
- `approval-queue notes <id> <notes.json>`: replaces a waiting `docs` item's notes, checked against
  its pages as the screen shows them (the worktree's `HEAD` copy, else the copy queued). Prints
  `replaced the notes of <id> at <url>`; refuses (exit 2, notes unchanged) a bad or unknown id, a
  decided item, a kind other than `docs`, and notes that fail the checks.
- `approval-queue collect <id>`: prints and logs a `docs` decision whose queuing command is gone,
  exactly as the queuing command would, running the approve refusal first.
- `approval-queue pending`: lists a decided `docs` item with no live waiter and no log line, as it
  does every kind.
- `approval-queue withdraw <id>`: unchanged; it covers a `docs` item.
- The waiting-item check: one waiting item per PR, across packet parts, `pr` items, and `docs`
  items, enforced by all three queuing forms.

### Removed

The `blueprint`, `page`, `change`, `anchors`, and `approved` commands and their screens, named
anchors and the slug rule, YAML handling, fact-tag parsing, `waived`, and every
fixture, test, type, comment, and README line that served them. Packets, `pr`, `design`, and
`triage` keep their behavior. Decided items of the removed kinds stay on disk; the app neither
lists nor serves them (`/item/<id>` answers 404), and `pending` and `collect` skip them.

## From fact-check findings to notes

`docs-fact-checker` returns one JSON array, one element per claim in the changed lines:
`{file, line, claim, verdict, source, proposed}`, with `verdict` one of `holds`, `wrong`,
`imprecise`, `unsupported`. The session fixes each `wrong` or `imprecise` claim it agrees with
before queueing, then writes notes:

- One `info` note per page, anchored on its first heading's text: how many claims were checked,
  how many held, and what was corrected.
- A corrected claim: an `info` note quoting the new text, with `was` and `now` and the `source`
  line in its body.
- A finding the session disputes: a `decide` note quoting the text, with `sides` (`Fact check` and
  `Author`) and two choices: `{"label": "Apply the fix", "done": "The session applies the proposed wording."}`
  and `{"label": "Keep the text", "done": "The page stands as written."}`.
- An `unsupported` claim the code cannot settle (a vendor's behavior, for one): an `info` note
  naming what would settle it.

A `holds` claim gets no separate note.

## The session's steps after the decision

**Approve.**

1. Check `git -C <worktree> rev-parse HEAD` prints `<commit>`. If `<commit>` is not `<head>`, push
   Geoff's edits: `git -C <worktree> push origin HEAD:<headRefName>`.
2. If the repo runs CI on the PR, wait for it on `<commit>` with the repo's watch (cairn-cms:
   `ci-green <commit> --pr <n> --wait`, re-issued on 75). A red is fixed forward, pushed, and the
   item queued again; the approve does not cover the fix.
3. `gh pr merge <n> -R <owner/repo> --merge --match-head-commit <commit>`.
4. Bring the main checkout up to date as `pass-core` "Close" says.
5. Answer each comment in the PR thread. A comment that asks for a change lands after the merge,
   named in the reply: a fix of one sentence or less as a `pass-core` direct change; anything
   larger as a follow-up docs PR, queued as a `docs` review.

**Send-back.** Push Geoff's edits first, as step 1 above. Fix forward from the note, each call,
and each comment. Then queue the same PR again from the worktree at the new head, with `--replies`
answering every comment and a description that says what changed.

**Defer.** Record the id; a later session runs `approval-queue collect <id>` under `setsid -f`.

**Refused approve.** `git -C <worktree> pull --ff-only` to the PR's new head, check what moved,
and queue again.

## Between the command and the app

The Approval Queue executor's two halves meet here; nothing else depends on it.

`item.json`:

```json
{"id":"<id>","kind":"docs","repo":"glw907/cairn-cms","number":150,"title":"<title>","headline":"<title>","created":"<ISO 8601 UTC>","worktree":"/abs/path","head":"<sha>","base":"<merge-base sha>","pid":123,"pidStart":456,"revises":{"item":"<id>","revision":2,"commit":"<sha>"}}
```

`revises` is present only on a revision, and `amends` (`{"commit": "<sha>"}`) only on an amend. The item directory also holds `description.md`,
`body.md` (the PR body), `pr.json` (as the `pr` kind's), `diff.patch` (the whole PR diff at
`head`), `pages.json` (`[{"path": "docs/x.md", "from": "docs/old.md"}]`, `from` only on a rename),
`pages/<k>/base.md` (the merge-base text, empty for a new page) and `pages/<k>/queued.md` (the text
at `head`), with `<k>` the page's index in `pages.json`, `notes.json` (`[]` when none),
`replies.json` (on a resend), `since.patch` or `since.json` (on a revision), and `approved.patch`
or `approved.json` (on an amend). The app writes
`comments.json`, `decision.json`, and `deferred.json`; the command writes `refused.json`.

`decision.json`, written by the app:

- Approve: `{"decision": "approve", "commit": "<worktree HEAD>", "calls": [...], "comments": [...], "threads": [...]}`.
  The app writes it only when every page is committed and clean in the worktree, each page's
  posted blob is its blob at `HEAD`, and every call is answered.
- Send-back: `{"decision": "reject", "note": "<text>", "commit": "<worktree HEAD>", "calls": [...], "comments": [...], "threads": [...]}`.

The command adds `pr` and `head` and prints the shapes above.
