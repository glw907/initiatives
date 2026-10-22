# Survey Pass D: mechanics and feasibility review

Reviewer: `plan-reviewer` (Opus, medium), against the spec at commit 4827f40, scoped to the writing register section, Pass D, the "cairn's docs" inherited bullet, and Pass D's lines in stops, risk, and sittings. The dispatching session saved this file from the reviewer's handback, lightly reflowed. Probes ran in the session scratchpad `passd/`.

## Findings

**1. Blocker, correctness. drafter can't inline the installed briefs.** L131, L171, L181. `internal/assemble/files.go` `outOfRepo` refuses a path within the repo (`if within(real, r.real) || !r.allows(real)`), and `resolve` refuses an untracked path under the root. `docs/configuration.md:155`: "`inline_files` lists files outside the repository". A Go probe in a scratch drafter clone at 568c262: "in-repo untracked abs allowed=false rel=false ; outside allowed=true". `register.<track>` is only recorded (`configuration.md:373-374`; only use `internal/config/apply.go:164-165`). OWNER FORK: (a) a small drafter change letting `inline_files` cover untracked in-repo paths, and making `register.<track>` feed prompts or dropping it, about 45 to 60 minutes (recommended); (b) seat `inputs` commands that `cat`/`sed` the installed section, with no slug check; (c) consumers commit a synced copy, which brings back drift. Rewrite L131 and add a standing answer for an unpassable drafter leg.

**2. Blocker, correctness. A minor has no 1.0.0 to sit on.** L20-24, L30, L167. Pass B ships `1.0.0-rc.1`; 1.0.0 is promoted at the approval queue's pass close, which the brief lists after Pass D. OWNER FORK: (a) Pass D waits for 1.0.0 and ships 1.1.0 (recommended); (b) Pass D ships `1.0.0-rc.2` on `next`. Reorder or state the dependency.

**3. Major, correctness. A synced Vale style doesn't follow the npm version, and an unsynced one hard-fails.** L130. A directory `Packages` entry synced and flagged in Vale 3.24.0 and 3.23.0 (cairn's CI pin), also after `Microsoft`. But `vale sync` "copies what it holds into the `StylesPath`": an edited package rule left the synced copy unchanged until the next sync. With no sync, Vale exits 2: "Style 'Survey' isn't on the StylesPath". The vendored `vale-ci`, `vale-fix`, `vale-setup` notes in `~/.claude/tooling/vendored-skills.json` say not to run `vale sync` against a committed `styles/`, and cairn-cms commits its Google styles. Fold: each consumer's lint script runs `vale sync` first and gitignores `.vale/styles/Survey/`, or commits the copy with a gate diff against the installed directory. Amend the three vendored notes in Pass D's workstation PR.

**4. Major, correctness. The five glw907 repos have no `package.json`, and three lint Go comments with it.** L130, L181, Non-goals. poplar, dubplate, cairn-cms/tool have `go.mod` only; phonebook and cairn-themes have neither. The three apply `BasedOnStyles = glw907` to `[*.go]` comments only, which the new code-comment non-goal excludes. "The four other repos" is unclear. Fold: Survey's prose style takes the prose rules only; publish `vale/Survey` as a `.zip` release asset for non-npm repos (Vale `Packages` accepts "A URL to a `.zip` archive"); glw907's comment rules stay put, or the zip covers comments with a ruling; name the repos.

**5. Major, correctness. No tooling channel installs a skill from npm, and a user-scope skill can't follow one repo's version.** L132, L172. `claude-tooling.md` "Layout" has three skill sources (dotfiles stow, vendored from GitHub default branch via `claude-tooling-sync` `fetch_skill`, drafter `make install`). Fold: a thin dotfiles skill that routes to `node_modules/@glw907/survey/writing/` in the current repo, with a named fallback for repos without the package (the zip, or a pinned copy in a tier manifest).

**6. Major, correctness, OWNER FORK. The Microsoft guide's text isn't licensed for a public corpus.** L128. drafter's corpus relies on Google's CC BY 4.0. The Microsoft welcome page ends "© 2024 Microsoft. All rights reserved.", and `MicrosoftDocs/microsoft-style-guide-pr` is not public. Options: (a) no Microsoft corpus, a paraphrased rubric with links plus house exemplars (recommended); (b) short attributed quotations under fair use; (c) an unpublished Microsoft corpus kept in the workstation. Add a standing answer for any excerpt without an open license.

**7. Major, correctness. The Rulings bullet contradicts itself, and some harvested rules are overrides.** L170, L211. cairn's recorded rulings were cairn-scoped (for example "cairn's public-facing writing is technical and academic", 2026-09-08). cairn's register (L1081-1094) separates a tightening (no row) from an override (a row). glw907's `EmDash` bans a form Google prescribes; Openers and Judgment need the same test. Fold: any cairn row marked house-wide counts as widened and goes to the sitting with cairn's ruling as evidence; apply the tightening-or-override test to every glw907 and copy-editing rule; the em dash is a named sitting row.

**8. Major, correctness. The workstation edits are incomplete.** L172. The charter says "keeps no house lexicon", not "voice". Charter L15-19 makes an overlay per-repo with cairn as "the named example"; L70-73 says product tidy tooling is independent of the charter. The global CLAUDE.md "Writing voice" names cairn's docs voice as the named overlay. `writing-voice` SKILL.md L9-10, L23-29, L96 name cairn or the workstation registers. `editor.md`, `technical-doc-web.md`, and `technical-doc-go.md` each need a stated fate. tellgrader's slop lexicon overlaps the Survey tells. Fold: list each with what happens to it, plus finding 3's vendored notes.

**9. Major, correctness. Pass D says nothing about hosts.** L172. Fold: copy Pass C's four post-merge commands and the thinkpad-x1 `check-drift` path.

**10. Major, correctness. Pass D has no standing answers of its own.** L171, L194-213. Missing: an unreachable bar (the drafter leg, or the sitting moving most rows cairn-only) with what still runs and a close that reports it unmet; Pass D's escalation list (the drafter leg may escalate; planted-tell and fixture checks never); a post-publish check (install, `vale sync` the installed style, fail on a planted tell, confirm attestation); the pack listing should name `writing/`, `vale/Survey`, and the skill source.

**11. Minor, correctness. poplar's tidy feature is gone.** L129, L169. `internal/tidytext/` was deleted in 041eb329 (2026-07-27); the rules survive in history and `docs/archive/specs/2026-05-08-claude-tidy-design.md`. Fold: harvest from `041eb329^:internal/tidytext/` and the archive spec; cut "the tidy features in poplar" from L129.

**12. Minor, correctness. Pass D's two PRs need an order.** L172, L226. Fold: survey PR packet, then release and post-publish check, then the dotfiles PR packet; L226 says two packets.

**13. Minor, correctness. Versioning doesn't cover writing changes.** L119, L133. Fold: add a `writing` rung; a changed tell or rubric line is minor; removing or renaming a brief slug is major.

**14. Minor, correctness. drafter ships only a `google` standard.** L128. `internal/blueprint/tracks.go:21`: `var standards = []string{"google"}`. Fold: the Microsoft brief serves a project prompts module (`require_prompts = true`, as cairn's editors track does), not the stock prompts.

**15. Minor, optional. No skill trigger checks or fixture runner in Pass D.** L171. Fold: trigger prompts as in Pass C; use cairn's `.vale/styles/Cairn/*.test.yml` pattern; keep fixtures in `tests/` so sync doesn't copy them.

**16. Minor, optional. 320 minutes is low.** L217. Breakdown: harvest 60-90, sitting prep 30-45, briefs and style sheet 90-120, Vale style and fixtures 45-60, skill 30, scratch checks 25, workstation PR 40, release 20; path about 380-420. Fold: 400, plus 45-60 in drafter if finding 1 (a).

**17. Minor, optional. Adapter and risk wording are loose.** L217. Name pass-core defaults for the survey half and `dotfiles-pass` for the workstation half; the `runner` paths are the skill, the routing, the vendored notes, and CLAUDE.md, not the charter doc.

**18. Minor, optional. The "cairn's docs" pass spans three repos.** L181. `register-check` and `cairn-register-editor` live in `~/.dotfiles`; the docs page chain's source is in drafter. Name all three.

**Over-ceremony (minor, optional).** A separate `survey-writing` skill adds a second skill, trigger set, and manifest entry. One `survey` skill with a writing route saves about 15 minutes, unless the descriptions collide.

## Checked and sound

A directory path in `Packages` works in Vale 3.23.0 and 3.24.0. The five-repo glw907 inventory matches. All harvest sources except poplar's tidy rules exist where the spec says. The Pass D sitting is named. Pass D has no Geoff-only pre-flight beyond its sitting and merge packets.
