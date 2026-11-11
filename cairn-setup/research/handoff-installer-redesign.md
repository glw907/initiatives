# Hand-off: the `cairn new` screen redesign

Geoff starts this in a fresh session once two things have landed: setup-tooling pass 3 (the proving
loop) and theme-garden G3 (the Survey theme). The brainstorm ran on 2026-11-11 and stopped before a
written design. Nothing is approved and nothing is built.

## Launch prompt

> Finish the `cairn new` screen redesign with `standards:brainstorming` and `cairn-pass`. Start from
> `~/Projects/initiatives/cairn-setup/research/handoff-installer-redesign.md`. Open
> `research/installer-mockups/flow.html` in Chromium first. Confirm pass 3 and theme-garden G3 have
> merged, replace the mockup's stand-ins with Survey's real options, and mock up the other
> commands in the same language. Then write the design and send it through `approval-packet`.

## Order (Geoff, 2026-11-11)

1. Setup-tooling pass 3 finishes its proving loop on today's screens.
2. Theme-garden G3 builds Survey.
3. This redesign updates the installer, in a fresh session.

## Decided by Geoff (2026-11-11)

- Add a theme selector to `cairn new` and improve the whole run's UI and UX.
- No "cairn education" goal. Follow successful installer patterns instead.
- Screens look like a real Charm tool.
- The theme screen points to `https://cairn.pub/themes`, with a stub page there while the tool is
  built. Each theme also links to its own page.
- The owner can choose the theme's options during setup.
- The owner is told when an answer can't be changed later.
- The parity gate is a requirement. The pass can't close until real-terminal frames of `cairn new`
  are graded beside the exemplars on one checklist by a fresh grader. Each row where an exemplar
  wins ends in a fix or a written reason.

- The redesign covers every cairn command, and one goal is a reusable design language for the tool.
  The other commands today are `adopt`, `agents`, `auth`, `doctor`, `health`, `logs`, `sites`,
  `status`, and the secret commands (`list`, `set`, `unset`).

## What the design language ruling changes

- The design's first deliverable is the language itself, written once and applied to each command:
  color roles, glyphs, the grid, the stage rail, the label-and-value row, the step list, the
  three-answer failure block, the key hint line, links, and the narrow and no-color rules.
- `cairn new` is the proving ground for the full-screen parts. The one-shot commands (`health`,
  `status`, `doctor`, `logs`, `sites`) print and exit, so they take the same roles, glyphs, rows,
  and failure block, and no rail or alternate screen.
- Today the shared pieces live in `tool/internal/ui/newview/` (`theme.go`, `grid.go`,
  `catalogue.go`). A language used by every command likely moves them to a shared package. That is
  an architecture call for the design to make.
- Read first: `tool/docs/design/README.md`, `charm-v2-capabilities.md`, `copy-standard.md`,
  `render-reference/`, and ADR `0004-terminal-view.md`. The language extends those, and should not
  restate them.
- The parity gate widens. One-shot commands are graded against one-shot exemplars such as `gh`,
  `flyctl status`, and `brew doctor`.
- This is likely more than one pass: the language with `cairn new`, then the other commands.

## Claude's calls, shown to Geoff and not objected to

- Four stages on a rail across the top: Site, Accounts, Review, Build. A left rail costs 16 columns.
- The site name is asked before the theme, so the specimen can use it.
- The theme screen is a list beside a specimen drawn in the theme's colors. `o` opens the
  highlighted theme's page. The link is built from the theme id.
- Theme options are one row each, changed with left and right, defaults preselected. The color mode
  row is always present. The specimen can't show fonts, and the screen says so.
- The warning about fixed names sits on the Accounts screen that waits for Enter before opening
  the browser. No separate confirmation screen. The name question shows the repository name it
  produces as the owner types.
- Only the resource names lock at the approvals. The display name stays editable on Review. This
  needs a small change to how setup carries the name.
- Review folds to about six rows. Every row but the fixed names is editable in place with `e`.
- A failed step shows its last output lines in a small pane, and `o` opens the failed run.
- Resume says which step the run stopped at.
- Welcome lists what to have ready.
- Stock Charm pieces to adopt: Huh groups, Huh inline selects, bubbles progress, stopwatch, and
  viewport, and Huh's accessible mode.

## Parity checklist

The plan stated first. One asking pass. A warning at the point of commitment. A review before
acting. Per-step progress. A failure that says what to do. Resume. Narrow and no-color behavior.
The last frame left in scrollback.

Exemplars: Homebrew and rustup (plan first), `fly launch` and create-astro (order and review), `gh`
and Stripe (browser hand-off), Ghostty and kitty (theme choice), Docker (long waits), Glow and
`gh dash` (restraint). `research/prior-art-compare.md` holds the earlier comparison.

## Facts checked in the code (cairn-cms at `b3d0c2062`)

- `tool/internal/setup/approvals.go` builds the GitHub App manifest from `r.names`, which
  `deriveNames` computes from the site name. The App is named `cairn-<slug>` and the repository
  `<slug>`.
- `tool/internal/setup/opening.go` writes the site name, theme id, and crawler choice into the
  resume record before any approval. An edit on Review must rewrite that record.
- The tool already has failure, resume, stop, prerequisite, and too-small screens with goldens in
  `tool/internal/ui/newview/testdata/`.
- In use today: Bubble Tea, Huh, bubbles spinner, help, key, and textinput, Lip Gloss `LightDark`
  and hyperlinks, `tea.ProgressBar`, colorprofile, fang, teatest.

## Still open

- Trace when the email and address answers are first used, to confirm neither locks before Build.
- Whether the theme screen shows when the catalog holds one theme.
- Who owns the cairn.pub stub (a `site-pass` change in cairn-pub) and the later browsing page,
  which the theme-garden design lists as later work.
- The exemplar capture study has not been run. The comparison so far is from knowledge of the
  tools, with no frames side by side.
- All wording in the mockups is placeholder. `tool/docs/design/copy-standard.md` binds the real
  copy.

## Mockups

`research/installer-mockups/flow.html` holds 19 frames at 80 and 60 columns. Regenerate it with
`python3 -I mock.py <out.html>` from that folder. Survey's colors, description, and options are
invented. So are the failed step's output lines and the "about ten minutes" figure.
