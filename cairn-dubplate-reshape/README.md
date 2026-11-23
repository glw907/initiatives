# cairn and dubplate reshape

Status: proposed (2026-11-22). Geoff set the scope in the terminal. The goals and non-goals below
are Claude's reading of his words.

## Summary

This initiative moves the two project repos, cairn-cms and dubplate, onto the workstation's Claude
tooling and its process. That process is the `building-from-specs` skill: an approved spec, a fresh
session that builds each task under `/goal`, a review by a fresh subagent, and a pull request that
Geoff approves by number. Success is that a task in either repo launches, builds, and merges by
that skill and the repo's short facts file, with no process text of the repo's own in the way.

## Motivation

The workstation's configuration was aligned with Anthropic's documented practice between
2026-11-20 and 2026-11-22, under `claude-config-alignment`. That record lists "Moving cairn and
dubplate to the new flow" as a non-goal and says Geoff reshapes both afterward. Both repos still
carry the process they had before. On 2026-11-22 a search of each repo's `CLAUDE.md` and `.claude/`
for `pass-core`, `running-passes`, and `conductor` finds 25 lines in cairn-cms and 6 in dubplate.
cairn-cms holds a process skill of its own, `cairn-running-passes`, and dubplate holds
`dubplate-pass`.

Geoff asked on 2026-11-22: "Once we're done with this, does it make sence to start a project to
reshape the cairn and dubplate efforts to fit the workstation claude tooling?" He ruled that it
comes before the monthly review rework ("The reshape first.") and agreed to steer it from the
initiatives repo ("Perfect."). He set who plans and who builds: "I'd like a Fable planning effort. I
can execute with something lighter." He also asked two questions the audit answers: "are we missing
any anthropic or community skills that would improve development for this projects?" and "Are there
any particular skills, tools, or patterns I should be using to write good Go code?"

## Goals

- One written audit covers both repos. It reads each repo's `CLAUDE.md`, its `.claude/` folder, its
  `docs/STATUS.md`, its gate, and its CI against the workstation's process and the Anthropic page
  for each mechanism. Each finding rests on a quoted sentence or on a command and its output.
- Each repo has one approved spec that lists every change, dubplate's first.
- After a repo's spec is built, its Claude files name no process but `building-from-specs`, and one
  real task there has run from launch to merge by that skill.
- The audit gives a verdict, with a trial, on each tool Geoff's two questions raised: the plugins
  `security-guidance`, `claude-security`, `claude-code-setup`, and `claude-md-management`; the
  skills `golang-security` and `golang-database` from `samber/cc-skills-golang`; and three checks
  for dubplate's gate, `go test -race`, `govulncheck`, and a fuzz test for its upload and audio
  parsers.
- Each spec is written on Fable, and each task is built on a lighter model. The audit runs on
  Opus: Fable was at 85 percent of its week on 2026-11-22, Claude proposed the split, and
  Geoff answered "Split is fine."

## Non-goals

- Product work in either repo: cairn's roadmap, the dubplate server's features, and the work of
  `cairn-setup` and `dubplate-server`.
- A change to the workstation's process. A gap the audit finds in `building-from-specs`, the
  settings, or the global `CLAUDE.md` goes to the workstation backlog.
- The site repos, which `site-pass` already covers.
- The monthly review rework, item 115 in the workstation backlog. It comes after this.
- A mechanism of our own design where the docs or a cited source already give one.

## Where the work lives

The changes land in `cairn-cms` and `dubplate`, each task launched from that repo's main checkout.
The `workstation` repo holds `cairn-pass`, the short facts file for cairn-cms, and would hold one
for dubplate if the audit calls for it. The audit, both specs, and the launch prompts live here.
Two planning sessions steer the work from this repo, one for the audit and one for the specs.

## Records

- Launch prompt for both planning sessions: `plans/2026-11-22-planning-prompt.txt`.
- What came before: `../claude-config-alignment/STATUS.md`, which records Geoff's rulings on this
  work and the count of skill use behind the tool candidates.
