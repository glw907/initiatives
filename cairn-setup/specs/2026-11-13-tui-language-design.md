# One terminal design language for `cairn`

Initiative: `cairn-setup`. Round: `tui-language`. Repo: cairn-cms, the Go tool under `tool/`.

## Brief

This round gives every `cairn` command one look, taken from the `cairn new` mockups, writes it down as a standard the next command can follow, and clears the technical debt in the packages it opens. Approving it approves four passes that run unattended once setup-tooling pass 3 has merged.

Today the tool has three looks. `health` and `logs` are styled one way, the installer another, and `doctor`, `auth`, `adopt`, `sites`, and errors print plain text. The palette is typed out by hand in three Go files, and the open circle means "held" in a report and "not started" in the installer.

### What changes

- `cairn doctor` on a terminal becomes a report with the marks, titles, and fix arrow `cairn health` uses.
- `health`, `logs`, and `sites` keep their verdict words, section order, and lowercase section names. Ruled headings become bold titles on a two-cell margin.
- `cairn health` shows one progress line on a terminal while it runs. Today it waits in silence.
- An error on a terminal gets the failing mark, and a fix arrow where the error carries a fix.
- `--help` keeps its layout, drops the accent colour, and takes light or dark from the same place as every other command.
- `sites`, `auth`, `adopt`, and `new status` are laid out on the shared grid on a terminal.
- Output on a pipe does not change for any command.
- `tool/docs/design/terminal-standard.md` states the language, with a table that says which block to use for what.
- Thirty-eight debt items from an architecture read of four packages are fixed in the pass that opens each file.

### If you approve

1. Nothing starts until setup-tooling pass 3 has merged and `claude-worktree-busy` reports `tool/` free.
2. The planning session lands the backlog verdicts below, runs the full backlog sweep that is due, and commits a plan per pass.
3. Pass 1 builds the shared package and the standard with no visible change to any command.
4. Pass 2 restyles the reports and `doctor`. Pass 3 does help, errors, lists, and receipts. Pass 4 cleans `health`, `logs`, and `adopt`.
5. Each pass lands on a green CI run and an accepted review. You get one round report, with real-terminal screenshots of every command beside `gh` and `brew doctor`.
6. The installer rebuild follows as its own round after theme-garden G3, on the package this round builds.

### Decide: Should today's installer get the new chrome in this round

The mockups you liked are of `cairn new`, and this round leaves its screens looking as they do today. Your 2026-11-11 order puts the installer redesign after theme-garden G3, since the theme screen and the Review edits depend on it. A fifth pass could put the rail, panel, cursor, and full screen on today's screens now, before G3.

Source: `research/handoff-installer-redesign.md`, "Order (Geoff, 2026-11-11)"

- Keep the order: the installer waits for G3 and gets one rebuild (recommended)
- Add a fifth pass now, about 240 path minutes, knowing G3's round reworks the Site and Review screens

### Decide: What a light terminal sees by default

`--theme` defaults to dark and the tool never asks the terminal, because the query can hang. On a light terminal with no flag, body text is painted near-white on white, at about 1.2 to 1. Help is the exception today: its library asks the terminal itself, so help and reports can disagree. The recommended fix leaves body text in the terminal's own foreground colour, which is readable on any ground, reads the `COLORFGBG` variable some terminals set, adds a `CAIRN_THEME` variable so the choice can live in a shell profile, and makes help follow the same answer.

Source: `tool/cmd/cairn/root.go:46-53`; `tool/internal/render/palette.go`

- Body text uses the terminal's foreground, `COLORFGBG` and `CAIRN_THEME` are read, and help follows `--theme` (recommended)
- Leave the default as it is, and let help keep asking the terminal

### Decide: A plain mode a person can turn on

A screen-reader user on a terminal hears each mark read aloud and a spinner redrawn eight times a second. `--color never` does not help, because it keeps the terminal layout in one ink. The plain body every command already prints to a pipe is the linear form such a reader needs. `CAIRN_PLAIN=1` would select that body on a terminal and turn off the progress line, with no new renderer.

Source: `tool/internal/render/body_plain.go`; <https://clig.dev/#output>

- Add `CAIRN_PLAIN=1`, documented in the standard and in `cairn --help` (recommended)
- Leave it out; a person who needs it pipes through `cat`

### Worth knowing

The mockups are `research/command-mockups/commands.html` and `research/installer-mockups/flow.html`, and all wording in them is placeholder that goes through `tool/docs/design/copy-standard.md` and the register editor before it ships. Two outside readers checked this design against the code, and their corrections are folded in: the `doctor` frame, the help frame, the pass mark's colour, and the lowercase section names all changed. No pass touches setup's runner, providers, secrets, or the approval pages.

### The language

The language is five things: eight colour roles, one set of marks, one grid, a short list of blocks, and three output tiers.

The roles are the Warm Stone eight that `render` carries: Text, Muted, Subtle, OK, Failing, Unknown, Accent, Rule. Accent means a cursor or a next step and nothing else, which is why help and the spinner lose it. Colour never carries meaning alone.

| Mark | ASCII | Meaning | Role |
| --- | --- | --- | --- |
| `●` | `+` | passed, done | OK in a run whose verdict is OK, Muted otherwise |
| `■` | `!` | failing | Failing |
| `□` | `*` | failing at warning level | Unknown |
| `?` | `?` | could not run | Unknown |
| `◌` | `o` | held | Unknown |
| `○` | `.` | not started | Muted |
| `▲` | `^` | a warning before a commitment | Unknown |
| `→` | `>` | the fix, or the next step | Accent |
| `⣾⣽⣻⢿⡿⣟⣯⣷` | `...`, not animated | working, 120 ms a frame | Muted |

The pass mark is muted below a failure because iteration-2 ruling 4 allows no green under the last failure, and `passRole` already does this. Not-started moves from `o` to `.` in the installer round, since `newview` owns that mark today.

The grid is a 2-cell margin, marks at column 2, names at column 4, and values at column 20. A name over 15 cells takes a line to itself, and its detail sits under it at column 4. That is how `doctor` checks render, since their names are sentences of 40 cells and more. Reports keep today's width rule: below 60 columns a report drops to one column. Content stops growing at 120.

Section titles are the bold lowercase nouns `copy-standard.md` section 2.3 requires: `failing`, `could not run`, `held`. The blocks are the verdict line, the title, the mark row, the label row, the continuation line, the fix line, the table, the progress line, and the error block. Full-screen commands add the stage rail, the panel, the cursor row, and the key hint line, which stay in `newview` until the installer round. A command that prints and exits never takes the alternate screen.

The tiers are colour on a terminal, one ink under `NO_COLOR` or `--color never`, and ASCII marks where `TERM=dumb`, the stream is not a terminal, or the locale is not UTF-8. One ink means no escape bytes at all, bold included, as `strong()` behaves today. The locale check is new in pass 2. A pipe gets each command's plain output as it is today, byte for byte.

### Command by command

- `doctor`: a failing check takes `■` or `□` by its condition's severity. An unchecked check is "could not run" with `?`. Passes fold into one count line. Skips fold into one muted "does not apply" line, and info results form a muted notes group. The verdict comes from `doctor.Verdicts`, which already feeds the exit code.
- Progress line: drawn on stderr, and only when stdout and stderr are both terminals, `CI` is unset, and neither `--json` nor `--quiet` is set. It appears after about 200 ms, in muted ink, and is erased when the report prints or the run is interrupted. Under `--verbose` the per-check lines `checkProgress` writes today replace it. The every-site run shows it too.
- Errors: styling keys on stderr being a terminal. Off a terminal the bytes are today's, which run to three lines for some errors. The arrow appears only on an error built with a typed fix, never by parsing a message.
- Help: Fang keeps drawing the layout, with its capital titles. The round changes its colour scheme only.
- Tables: `health` for every site keeps its columns and shows every site.

### The shared package

One new package, `tool/internal/style`, owns the palette, the roles, the marks, the grid, terminal detection, and the print-and-exit blocks. It imports Lip Gloss, colorprofile, the width library, `x/term`, `x/sys`, and `x/ansi`, and no Bubble Tea, so `render` can import it and keep ADR-0002's rule. `render`, `newview`, and `cmd/cairn` import it and delete their copies.

It exports only what a caller in the tree uses. `render` exports most of its theme today for a HUD that was never built, a test pins those names, and that pin is why `newview` copied the palette instead of importing it. Pass 1 removes the unused exports and the pinning tests with them, and a later HUD exports what it needs when it exists.

- The three palette tables become one. `newview/theme.go` and `cmd/cairn/fang.go` lose theirs.
- The eight things `render` and `newview` each implement (role enum, ink table, colour resolve, styles, profile, glyphs, wrap, width measure) merge to one each, per the table in the debt read. Where they differ, `render`'s width measure and `newview`'s plain link win.
- The purity test moves with the palette and widens: no package but `style` may call a Lip Gloss colour setter or hold a colour literal of any form.
- A test in `style` reads `internal/setup/loopback/pages/*.html` and fails on a hex outside the role table, the two grounds `#221f1a` and `#fdfbf9`, and six named tints (`#1b1430`, `#2b2537`, `#5f4f94`, `#b9a3ec`, `#f3eefc`, `#ffffff`). The pages are not edited.
- `doctor` stops importing `render` for `DoctorSchemaVersion`, which moves to `doctor`. That frees `render` to take a `doctor` row type without an import cycle.
- ADR-0005 records the move. ADR-0002 and ADR-0004 gain a line pointing to it.

### Debt

Four architecture reads at `b3d0c2062` are in `research/tool-debt-read-2026-11-13.md`, with an id per item. `health` and `doctor` read as sound, `render` and `cmd/cairn` as workmanlike. The common faults are logic written two or three times, exported names nobody calls, seams that exist only for tests, and comments that cite retired files and task numbers. Each pass fixes the items in its package, and all but three change no output.

- Pass 1 takes R1 to R9.
- Pass 2 takes D1 to D8.
- Pass 3 takes C1 to C11, less the `new_*.go` items, which wait for the installer round. C1 changes the copy-list golden.
- Pass 4 takes H1 to H10. H8 removes a dead actor name from help text.
- Left alone, with the reason in the read: R10, C12, H11.

`internal/setup` and `internal/ui/newview` get the same read in the installer round. The passages each reader named as the package's best work are listed in the read, and a cleanup that flattens one is a review finding.

### Passes

| Pass | Outcome | Files | Class | Path minutes | Depends on | Shares files with |
| --- | --- | --- | --- | --- | --- | --- |
| 1 `style` | The package, the standard, ADR-0005, the widened tests, and R1 to R9. No command's output changes. | `tool/internal/style/**` (new), `internal/render/**`, `internal/ui/newview/{theme,grid,footer}.go` and tests, `cmd/cairn/{fang,fang_test,health,root,new_terminal}.go`, `tool/docs/design/**`, `tool/docs/adr/**` | ordinary | 150 | none | 2, 3 |
| 2 `reports` | `health`, `logs`, the `sites` status block, and `doctor` in the new shape, the progress line, the locale check, and D1 to D8. | `internal/render/**` and goldens, `internal/doctor/**`, `cmd/cairn/{health,health_sweep,doctor,logs,sites,messages}.go`, `docs/admin/is-it-working.md`, `CHANGELOG.md` | ordinary | 200 | 1 | 1, 3, 4 |
| 3 `commands` | Help colours, the error block, the list and receipt commands, the Decides' variables, and C1 to C11. | `cmd/cairn/**` except `new_*.go`, `testdata/copy.golden.md`, `docs/admin/**` where a flag or variable is listed, `CHANGELOG.md` | ordinary | 150 | 2 | 1, 2, 4 |
| 4 `lean` | H1 to H10. | `internal/health/**`, `internal/logs/**`, `internal/adopt/adopt.go`, `internal/record/**`, `cmd/cairn/{health,messages}.go`, `CHANGELOG.md` | ordinary | 80 | 3 | 2, 3 |

Merge order is 1, 2, 3, 4. The chain is 580 path minutes. Pass 1 runs first because it rests on the least-proven assumption, that three packages can share one palette and grid with every golden unchanged.

### Acceptance

Every pass: `make -C tool check` passes, and a fresh `standards:go-architecture-reader` read of each package the pass cleaned reports none of that pass's item ids still open.

Pass 1, `style`:

1. `git diff --stat main...HEAD -- tool` lists no changed file under any `testdata` directory, and no changed `*.golden*` file, except the new specimen golden.
2. The purity test fails on a planted `lipgloss.Color("#fff")`, a planted `lipgloss.Color("212")`, and a planted three-digit hex string, each in a real file of `internal/render` in a throwaway commit whose test output is pasted in the PR.
3. The loopback test fails when run against the real pages with one tint removed from its list, shown the same way.
4. A test fails when a block in `terminal-standard.md`'s table has no exported function of that name in `style`, or the reverse.
5. `go doc ./internal/style` lists no exported name that `grep -rn 'style\.<Name>' tool --include='*.go'` cannot find outside `internal/style` and test files.
6. Kitty screenshots of the specimen (every mark, role, and block at 80 columns) on a dark ground and a light ground show each mark one cell wide, with the row below it starting on the same column, in Adwaita Mono and JetBrains Mono.
7. `grep -rnE 'Task [0-9]|iteration-[0-9]|20[0-9]{2}-[0-9]{2}-[0-9]{2}' tool/internal/render tool/internal/style --include='*.go'` prints nothing.

Pass 2, `reports`:

1. Kitty screenshots of `cairn health my-site`, `cairn health`, `cairn doctor`, `cairn logs`, and `cairn sites`, each run through the built binary against the fixture registry at 80 and 59 columns, match their frames in `commands.html` on these points: margin 2, marks at column 2, short names at column 4 with details at column 20, long names on their own line, bold lowercase titles with no rule, one column at 59.
2. `cairn health | cat` and `cairn doctor | cat`, run through the built binary, produce the bytes they produce on `main`, compared by a test that runs both binaries.
3. With `NO_COLOR=1`, the terminal `health` and `doctor` goldens hold no `ESC` byte, and each verdict word, section name, and mark is present.
4. With `TERM=dumb`, and separately with `LC_ALL=C`, the goldens hold only bytes below 128.
5. A `doctor` golden covers one run holding a failing, a warning, an unchecked, a skipped, an info, and a passing check, and each state renders as "Command by command" says. `grep -rnE '^(PASS|FAIL|SKIP|INFO|UNCHECKED)  ' ` over the terminal goldens prints nothing.
6. A terminal golden of a failing run holds no OK-coloured cell below the first failing row.
7. A pty test shows the progress line on stderr during a slow fixture run and absent from the final screen. It is absent when stdout is a pipe, when stderr is redirected to a file (the file holds no `ESC` byte), with `CI=1`, and under `--quiet`, `--json`, and `--verbose`. An interrupt mid-run leaves no progress line on the screen.
8. A held check renders `◌` if pass 1's screenshot showed it one cell wide, or `○` if standing answer 4 fired. The PR says which.
9. A fresh grader scores the screenshots beside `gh pr status` and `brew doctor` frames on one checklist. Every row an exemplar wins ends in a fix in the PR.
10. `docs/admin/is-it-working.md` still embeds the pipe transcript unchanged, and says in one sentence that a terminal shows the same checks grouped by state. `npm run check:docs-gate` passes.

Pass 3, `commands`:

1. Kitty screenshots of `cairn --help`, `cairn sites`, `cairn auth list`, `cairn auth check`, `cairn adopt list`, `cairn new status`, and the three error cases, run through the built binary, match their frames in `commands.html` on margin, mark column, and title weight.
2. The help golden holds no cell in the Accent colour, on a dark and a light ground.
3. If the light-terminal Decide is approved: `cairn --help --theme light` and `CAIRN_THEME=light cairn health` paint the light palette, `COLORFGBG=0;15` with no flag does too, and the Text role emits no foreground colour code at any profile. If declined, none of the three variables is read.
4. If the plain-mode Decide is approved: `CAIRN_PLAIN=1 cairn health` on a pty prints the bytes `cairn health | cat` prints and no progress line.
5. Each list command piped to `cat` produces the bytes it produces on `main`, compared through both binaries.
6. Each error in `messages.go`, printed with stderr redirected to a file, produces the bytes it produces on `main`. Exit codes are unchanged: 0, 1, 2, and 3.
7. An error with no typed fix shows no arrow on a terminal.
8. `make -C tool check-copy` passes, and the PR lists the register editor's verdict for each new string.
9. No file in `cmd/cairn` outside `new_*.go` is over 280 lines.
10. The same fresh-grader checklist as pass 2, for help against `gh --help` and for the lists against `gh repo list`.

Pass 4, `lean`:

1. No changed file under any `testdata` directory except the help and copy-list goldens, whose diff is the one removed actor name.
2. `grep -rnE '\.mjs|Task [0-9]|20[0-9]{2}-[0-9]{2}-[0-9]{2}' tool/internal/health tool/internal/logs --include='*.go'`, test files left out, prints nothing.
3. `go doc ./internal/health` and `go doc ./internal/logs` list no exported name without a caller outside its package.

### Shared assumptions

| Assumption | Probe or source |
| --- | --- |
| No lint rule blocks a new internal package. | `grep -n -i 'depguard\|forbidigo\|gomodguard' tool/.golangci.yml` printed nothing (2026-11-13, `b3d0c2062`). |
| `◌` is one cell wide. | U+25CC has East Asian Width `N`. Adwaita Mono, Cascadia Code, and JetBrains Mono carry it on this workstation (`fc-list`). Pass 1's item 6 checks the painted cell. |
| The copies exist only because `render` pins its surface. | `newview/theme.go:36-37`, and the `render` read's item R1. |
| Help's colours can follow one answer. | `fang.ColorScheme` is built from a `lipgloss.LightDarkFunc` (`fang/v2@v2.0.1/theme.go:39-44`), and `cmd/cairn/fang.go:33` already supplies the scheme. |
| Help's layout cannot be restyled through the scheme. | Fang uppercases titles and boxes usage in its own renderer. The round does not try. |
| `render` may import `style` without Bubble Tea. | `style` takes `render`'s direct requires and three `x/` modules already in `go.mod`. `purity_test.go` moves with the package. |
| The pinned tests are known. | `render`: `purity_test.go`, `TestExportedSurfaceIsPinned`, `TestThemeMethodSetIsPinned`, the `palette_test.go` contrast test, `glyph_test.go` parity tests, `TestGlyphTiersAreOneCellWide`. `cmd/cairn`: `TestHelpInksMatchRendersPalette`, the 300-line bound in `root_test.go`. `newview`: `theme_test.go`, ten hexes. |
| `▲` and the braille frames measure one cell. | Not in `render-reference/measurements.txt`. Pass 1 measures and adds them. |

### Out of scope

- The installer's screens, flow, theme selector, and Review edits, and the `new_*.go` command files. They are the next round.
- `cairn hud`.
- Any change to `--json` output, exit codes, or the agent lane's events.
- A new layout for help.
- The approval pages' layout and markup.
- Debt in `internal/setup`, `internal/ui/newview`, `providers`, `spine`, `store`, and `secrets`. None was read.

### How it fails

- Below 60 columns a report is one column, as today. A table drops its rightmost columns in a fixed order and folds counts into one cell.
- A value longer than its cell wraps to a continuation line in a report and truncates with `…` in a table.
- A string from a provider or a site still passes `render`'s sanitizer and the `logx` scrubber before it is painted. `style` never writes to a stream.
- A terminal that cannot show the marks gets the ASCII tier.
- A run that dies mid-check erases the progress line before the error prints.

### Standing answers

The twelve in `round-run.md` hold. This round adds seven.

1. A pass may run to twice its path minutes while each retry fixes a traced cause. The round stops new launches past 1,160 path minutes.
2. A golden changes in pass 1. That is a defect to fix. No session regenerates a golden in pass 1.
3. A pipe golden changes in pass 2, 3, or 4, outside the two named exceptions. Fix the code.
4. `◌` paints wider than one cell, or as a box, in either font. Held keeps today's amber `○`, the standard records the clash as open, and the pass goes on.
5. A string the copy catalogue lacks. The session drafts it to `copy-standard.md`, runs `cairn-register-editor`, and lists it in the PR. Placeholder wording from the mockups never ships.
6. A debt item turns out to change output, or to need a file outside its pass. The session leaves it, files it through `standards:log-issue`, and lists it in the PR.
7. Setup-tooling pass 3 has not merged, or the busy check exits 1. Nothing launches.

### Backlog sweep

The scoped sweep read the open `#initiative:cairn-setup` items and every item naming a file the round changes, at `b3d0c2062`. Nothing folds, because every candidate lives in the installer's screens.

| Item | Verdict | Reason |
| --- | --- | --- |
| #464 full-screen TUI UX | reword | This round covers the print-and-exit half. The item is cut to the installer and placed with the installer round. |
| #462 domain chooser paints with nothing selected | keep | `newview/choose.go:26-28` is deliberate. Placed with the installer round. |
| #461 done screen names nothing to revoke | keep | `newview/done.go:44-50`. Placed with the installer round. |
| #401 `KeysLeft` and `InstallFailed` unworded | keep | `newview/done.go` renders neither. Placed with the installer round. |
| #402 summary needs 26 rows; countdown unwired | reword | Split in two: the layout half goes to the installer round, and the countdown is runner work and stays its own item. |
| #354 tell the admin to revoke the setup token | duplicate | The token run is covered by `done.go:48-49`. The rest is #461. |
| #384 `health` for a site deployed by Actions | done | Commit `fd78cb813`, `health/check_deploy.go:189-193`. |
| #274 recapture the `doctor` transcript | reword | `tool/testdata/transcripts/04-doctor-report.txt` needs a real site. Placement becomes "after pass 2 of `tui-language`". |
| #463, #400, #407, #421, #405, #398, #399 | keep | Each is setup logic, agent-lane content, or a copy ruling outside this round's files. |

A full sweep is due: 134 items are open and 100 carry no sweep stamp from the last 90 days. The planning session runs it as its own triage list, apart from this packet.

### Claude's calls

Each is reversible in the pass that builds it.

- The package is `tool/internal/style`, and it exports only what is called.
- Held gets `◌`, so `○` means "not started" everywhere.
- `doctor` takes the report shape on a terminal, with long names on their own line, and keeps today's lines on a pipe.
- The pass mark is green only in a run whose verdict is OK.
- Help keeps Fang's layout. Only its colours change.
- The spinner is muted, and the progress line stays off whenever either stream is not a terminal.
- Errors keep today's bytes off a terminal.
- Debt is fixed inside the pass that opens the file, with a fourth pass for the three packages no other pass opens.
- The approval pages are checked against the palette by a test and not edited, which keeps every pass out of the `auth-data` class.

### Not checked

`flyctl status` was not captured. The exact `brew doctor` and `gh` frames the grader compares against are captured in pass 2. Nothing was rendered in Ptyxis or a non-kitty terminal, and font coverage of `◌` on other systems is unknown.

### Practice drawn on

Command Line Interface Guidelines (<https://clig.dev>) for the pipe contract, progress on a terminal only, and errors that say what to do. <https://no-color.org> for the one-ink tier. Lip Gloss v2 and Fang v2 (`charm.land`) for `LightDark` and the help colour scheme. Go Code Review Comments and Effective Go, through `standards:go-conventions`, for the debt items. The house records this extends are `tool/docs/design/copy-standard.md`, `reviews/iteration-2-brief.md`, ADR-0002, and ADR-0004. Exemplars are `gh` and `brew doctor`, per the hand-off.

### Owner steps

None. The round needs no sign-in, secret, setting, or permission rule.
