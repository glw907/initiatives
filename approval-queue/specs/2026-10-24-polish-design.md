# Approval queue: the polish pass

## Brief

The last ten approval-queue backlog items will be cleared: the board and packet screens will match the approved prototype, the home-grown parts move to stock DaisyUI where the look allows, a packet part shows its full diff and rendered design, and the notes get a real screen-reader check with Orca.

These are the review and visual-grade suggestions the earlier passes filed and left: backlog #3 to #8, #10 to #12, and #20. None of them slows the docs work, so this is the third of three passes and runs after the docs friction pass merges. It has no deadline.

### What changes

- The board and packet screens pick up the prototype's details the build missed, such as the sort segment's colour, the sidebar's ask count and irreversible flag, and the number keys on ask options.
- Board rows join the j and k navigation, and the decision hold also pauses while the bar has keyboard focus.
- A packet part shows the same full diff and rendered design that the single PR and design screens show.
- The home-grown parts become stock DaisyUI components. Where a stock part would lose something the prototype needs, the repo records why it stays.
- The Svelte and accessibility suggestions are applied, including a longer, pausable Undo toast and highlight colours that meet 3:1 contrast.
- Orca, GNOME's screen reader, is run against a blueprint review to check that the notes' buttons are read as buttons.

### If you approve

1. The session plans the pass once the docs friction pass has merged, and launches it from the approval-queue checkout.
2. The pass is `ordinary` class, so it merges its own PR after a green suite and an accepted close review, and sends no packet.
3. Its follow-ups go to the backlog, among them an NVDA check on Windows for whenever one is at hand.

### Worth knowing

Orca runs on your desktop for a few minutes during the pass. The executor starts it with speech muted, so you hear nothing, and quits it after the check. Orca also holds its own keys (Insert and Caps Lock) while it runs.

### Standing answers

The run decides these without you. A plan up to 480 path minutes, twice the estimate, goes ahead without a stop. Where a stock DaisyUI component cannot keep the prototype's look with overrides, the part stays home-grown and the README records the defect. If Orca's debug log does not show what it would speak, the executor reads the accessibility tree over AT-SPI instead, records that in the PR, and files the speech check in the backlog. A visual difference the prototype does not settle goes to the survey theme's rule, and the PR records the call.

## Design

Initiative: `approval-queue`. Risk class: `ordinary`: the pass touches only the app's UI, its server listing, and its tests, and no skill, agent, workflow, or `auth-data` path. No live account. Estimate: 240 path minutes, set from recent passes finishing at about a third of plan. The pass is UI work against a reference, so it follows the `visual-fidelity` skill and gates on `visual-verifier`. The reference is the prototype at `~/.local/share/approval-packets/prototype-2026-10-14/`, which the approval-packets design names as the visual reference.

### 1. Prototype fidelity (#8, #6)

Every item in #8's list is built as the prototype has it: the near-black selected sort segment, the bordered sidebar group with its mono repo label and "Board [b]" row, sidebar entries showing the ask count and the irreversible flag (the layout's data gains both, from the stored packet), the phone top bar's menu icon, the breadcrumb's initiative, repos, and waiting time, the person step's text colour, the 1, 2, and 3 key chips on ask options with single-key picks, the dark-mode lifted bar, and a "Reject with note" that fits a 390px bar. From #6, board rows join the `data-q` navigation, the hold pauses on focus within the bar as well as on pointer, and the reduced hint copy reads correctly either way.

### 2. DaisyUI-first (#5, #11)

Each home-grown part #5 and #11 name takes its stock class and keeps the prototype's look through overrides: `breadcrumbs`, `collapse` for the packet asks and routine rows, `menu menu-sm` for `PaneList`, `drawer drawer-end` for the frame drawers, `toggle toggle-sm`, and the stock button classes in place of `.linkbtn`, `.drawer-x`, and `.appbtn`. The frame drawers keep their own `inert` focus handling if the stock drawer's is weaker, and the README records the defect. The rest of #5 lands as written: `aria-hidden` on the timeline rules, `aria-describedby` and `autofocus` on the confirm dialog, the join segments' focus z-index, the `--btn-color` override, a focusable routine table, and the board link context. The `daisyui` skill is the reference and the Blueprint server's quality inspector the audit.

### 3. Part detail (#7)

A packet part's detail reuses the PR screen's file diff (`FilesDiff`) and the design screen's rendered view (`DesignView`). The server renders the design part's Markdown, as it does for a design item. The PR and design screens set prose at 56ch, as the packet screen does.

### 4. Suggestions (#12, #20, #3, #4)

The #12 list lands as written, `App.PageData` in `app.d.ts` included. That closes #3's `app.d.ts` half, and #3's other half fixes the "Close when empty" restart and the one-frame "closes in 30 s" flash. From #20: the delete toast's Undo lasts 10 seconds and pauses while hovered or focused (WCAG 2.2.1), the highlight fills move to colours with 3:1 contrast against the page, the comment chords match `e.key`, a comment op started during a decision's flush is awaited, and the store tests gain the four missing cases. From #4, the board caches each parsed `packet.json` by mtime.

### 5. The screen-reader check (#10)

The executor starts `orca --debug-file <path>` with speech muted, opens a blueprint review whose notes carry choices, and tabs through two notes. The check passes when the log shows each choice announced as a button with its label. Orca quits after the check. An NVDA check is filed in the backlog.

### Files

`approval-queue/src/`: the board route and its server listing, `+layout.server.ts` and the sidebar, `ItemPanel.svelte`, `PacketAsks.svelte`, `PacketRoutine.svelte`, `PacketBrief.svelte`, the frame components and `frame.css`, `PaneList`, `BriefBlock.svelte`, `DecideCards.svelte`, `CommentCard.svelte`, `src/lib/editor/` (`review.svelte.ts`, the chords, the highlight colours), `src/lib/server/items.ts`, `app.d.ts`, and the tests beside each. `README.md` for any part kept home-grown.

### Out of scope

New features, and anything not in the ten items. The NVDA check, which waits for a Windows machine.

### End-to-end check

1. `visual-verifier` grades the board, a packet, and a blueprint review against the prototype at 1440px and 390px, light and dark, and finds no structural difference.
2. On the board, j and k move through the rows. A packet part opens on its full diff, and a design part opens rendered.
3. Orca's log shows a note's choices announced as buttons.
4. `svelte-check` reports no errors, and the full suite passes.

### Pre-flight

None. Orca runs muted, and the pass needs nothing from you.
