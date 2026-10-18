# Fold: drafter onboarding design

Target: `specs/2026-10-18-drafter-onboarding-design.md` (branch `docs-system-onboarding-design`,
head `c9dbd24`, glw907/initiatives#18), revised in place. Reviews: contract (C1 to C19),
mechanics (M1 to M25), human ergonomics (H1 to H22), and agent ergonomics (A1 to A22), all under
`research/2026-10-18-drafter-onboarding-review-*.md`. Code read at drafter `f7d9034` and cairn-cms
`main`.

Counts: 88 findings. 73 folded, 6 refused, and 9 carried by 3 owner forks.

## Verification notes

Each finding was checked against source before it was folded. Most mechanisms held. These didn't,
or were narrower than stated:

- M14 says cairn pins its Vale package at `.vale.ini:5-11`. Those lines pin the Vale binary in CI;
  the packages are named, not pinned (`Packages = Google, Microsoft`). The fold (pin by release URL)
  stands on Vale's own docs, fetched: "To hold a package at a known version, give the release URL
  in place of the name."
- M8 counts 89 dotted pointers in cairn's 1,748 facts. The 1,748 holds; a quick count of the dotted
  form gave a different number, so the design names the pointer forms from `check-facts.mjs`'s
  header and drops the count.
- M8's probe ("drafter check passes a fact whose source is missing") was confirmed from code
  instead: `internal/plan/facts.go:45-49` parses `Sources`, and no check reads them.
- The reviewers cite `internal/config/validate.go:273-315`; at `f7d9034` the file is 77 lines, and
  the required settings sit at lines 27-67. The mechanism is as stated.
- `drafter check-prompts` already exists (`cmd/drafter/checkprompts.go`), so A2's proposed check
  extends a command rather than adding one.
- The plugins reference confirms `bin/` "on the Bash tool's `PATH` while the plugin is enabled",
  namespacing under the plugin name, and that a component path resolving outside the plugin root
  doesn't load.

## Roots

Convergent findings fold once, at the root.

| Root | Findings | Disposition | Where the revision carries it |
|---|---|---|---|
| R1. Testable acceptance in a clean environment | C1, C2 (a, b), M12, M22, H7, A15, A20 | Folded | The anti-goal table; F's and O's acceptance (clean `HOME`, a synthetic fixture, a recorded count of installs, settings, and decisions). A15: the skill stops when `drafter` is missing or rejects a flag; its minimum-version pin is refused (no measured defect). A20: the hook becomes a `drafter` subcommand |
| R2. Required money settings | C6, M13, H2 | Fork 2 (prices); the rest folded | Caps and `workspace_id` stay required by the pipeline spec's ruling, and the skill asks. Defaults named for `gate.command`, `prompts`, and seat model, effort, and `max_tokens`. H2's option (c), `init` capturing `workspace_id` from the response header, is refused: it relaxes a credentials guard to save one copy step |
| R3. Existing pages on the first run | C7, M7, H3, A6 | Fork 1 | "Existing pages"; the seeding command in F's scope; arch 179-184 in the changes table |
| R4. O's bar and whole-read convergence | C2 (c), A1, H1 (bar) | Folded, taken | O's bar is a blueprint accepted within two read rounds, then a drafted page. O's design starts once a whole read has accepted a cairn blueprint in B3, which B3's drafting needs anyway. A1's option (c), unbounded rounds, defeats the caps; option (b) measures nothing a developer gets |
| R5. "Everything else stands" is false | C4, M15, H17, C3 | Folded | "Changes to the architecture spec" table. C3: the register path moves to the track entry, so no scalar `register` key collides with `register.<track>`, which stays for cairn's module until B5 |
| R6. Tracks and the type taxonomy | C5, C15, M6, A5 | Folded | "The tracks": `tracks` in `outline.yaml` with path globs, additive to v1, and two checks. A5's `mode` field is refused as part: a stock anatomy is one Good Docs template, which carries its mode |
| R7. Register pointers in the base | A4, H12 | Folded | F scope and acceptance: stock anatomy ids; new-page steps 1 and 4 and `check.go:221`'s fix text retargeted; a headless new-page run on a register-less fixture |
| R8. Stock prompts: mechanism and text | M1, M2, M3, M20, A2, C12 | Folded | F builds the mechanism (embedded module, embedded blocks, `path#heading`, the refusal setting, the module's source and hash in reports, its bytes in the run directory). B3 writes the text and proves it on a fixture page and through `check-prompts` |
| R9. How package parts reach a seat | M4, A3, C16, C17, H21 | Folded, taken | The package table's "Reaches a seat as" column. A3's rules fork has one answer: the rubric part is already the rules text a seat sees, and paraphrase with citation keeps Geoff's "never copied". Corpus: full text only under a license that permits it; otherwise a short attributed excerpt. C16 has one answer that keeps Geoff's ruling that accepted pages join: "accepted" means a person approved the merge (call 8), which answers the drift-to-the-mean risk without a promotion step |
| R10. The register: intake, check, and rulings | M10, M11, M16, M17, C11, H8, A10 | Folded, taken | "The house register, optional". M16, H8, and A10 converge on import into the template, and it's the only option that reaches a seat. The check is structural (C11, M10). M11: owner role, both skills forbid rulings, nightly allowlist excludes the register. M17: rows carry URL and retrieval date, packages are pinned; its monthly recheck is refused as new routine work with no consumer yet |
| R11. Fact verification | C14, M8, M9, M24, A7, H13 | Folded | F scope: cairn's `check:facts` contract, the published `Source:` grammar, anchors required, unsupported forms counted. C14's pending-tag requirement is refused: arch's pending tag (319-323) is for a fact taken from a human edit, while an audit fact is filed by an agent that read the code, as cairn's agents do today, and the fact seat reads each fact a draft places (call 1). H13: the developer reviews no fact one by one |
| R12. The stock gate | M14, M19, C9 | Folded | F: `drafter gate --page`, page-scoped, preflighting Vale before spend, internal links only. Provenance goes to B3, where the brief's format settles |
| R13. Install and plugin | M21, C8, H5, H20, A14, A22, A17 (part) | Folded | O scope: release binaries plus `go install`, the plugin replacing `make install`'s skill and hook here, `--plugin-dir` for development, the format page as a real file with a contents list and the item reference inside it, `disable-model-invocation: true` |
| R14. Building ahead of a consumer | C13, M25 | Fork 3 | Brief |
| R15. The developer's path | H4, H6, H10, H14, H15, H16, H18, H19, H22, A8, A9 | Folded | "The onboarding skill" and the overview paragraph: the two-sentence model, a one-screen opening, two bills, a projected cost before outline approval, one plain track question, a vocabulary rule, dispute and exit routes, phases with commits and defaults. A8 is taken as call 2 (a staged audit), flagged as the most contestable call. H4's estimate in `drafter status` is refused as new machinery with no measured need; the skill's projection covers the moment it matters |
| R16. The nightly run for other projects | H1 (runner), H9 | Folded | The anti-goal table gives the runner to B4's design. H9 has one answer: arch already starts merging off (548-552), so it becomes a per-project default |
| R17. `init` output fails `check` | M5, A11 | Folded | F acceptance row one |
| R18. Introductions and background | A12, A16, A21, C19, M23 | Folded | "Introductions and background" |
| R19. Figure pages | C10 | Folded | The anti-goal table's last row |
| R20. Contract's call 4 | C (call 4) | Folded | The brief says "at least one pass" |

Contract's fork A (style notes with no register) has one answer, taken in the changes table: the
report keeps listing style candidates as information, and the onboarding design's "never a step
drafter prompts" no longer conflicts, since listing isn't prompting. Its "clears after N redrafts"
part is new machinery with no measured defect, so it isn't folded.

## Refused

| Finding | Reason |
|---|---|
| C18 | Optional. Naming the seat that catches an unplanned background section belongs to B3's seat design, and the background rule now gives that content an item kind (A12), which coverage checks |
| H11 | Reverses Geoff's 2026-10-17 ruling ("meaning is enough; rewrite it in the register's voice") and is B4's surface. The overview now says what a hand edit does |
| M18 | `drafter facts mint` answers no measured defect. The ported contract checks id format and uniqueness, so a collision fails the gate |
| A13 | (i), `check --since` listing `refs`, waits on the change-read rerun, which tests the skill's new `refs` step on the same prompts; file it if the rerun misses again. (ii), a `PostToolUse` check hook: B2's five agents all ran `drafter check`, so there's no measured defect. (iii) reverses arch's non-goal (63-64), which is Geoff's, and is outside onboarding; worth a backlog entry |
| A18 | Optional; ids are covered under M18, and a file-per-track rule has no consumer before O, whose skill can set it |
| A19 | Optional and unmeasured; the format test already measures the small-edit path on Sonnet at medium |

A17's description rewording is also refused, as part of a folded finding: it rewords a B2 artifact
and isn't onboarding work. File it in drafter's `BACKLOG.md`.

## Owed errata

The revision changes the meaning of ratified text. None of it is edited here.

- **Architecture spec** (`specs/2026-10-17-blueprint-architecture-design.md`): a status line
  pointing at the onboarding design's "Changes to the architecture spec" table. It covers lines 85,
  86, 88, 98, 108, 179-184, 252-254, 325, 332-333, 339-344, 429-437, 457-467, 469-472, 494-495,
  499-501, 519-520, 548-552, and calls 8, 21, and 22.
- **B1 plan** (`plans/2026-10-17-drafter-b1-blueprint-format-plan.md`, "Build sequence"): F and O
  join the order, B3 gains the stock prompts and provenance, and B5 gains cairn's register split.
- **Change-read design**: no erratum. Its backlog #2 closure stands for live agents; O adds
  headless loading of the plugin's format page as its own acceptance check.

## Packet corrections

`specs/2026-10-18-drafter-onboarding-design-packet.md` needs these:

1. Routine row 1's "Why" is false. The design changes built things: the outline schema
   (`tracks`), `Type.anatomy`'s meaning and `check.go:221`'s fix text, the blueprint skill's
   new-page steps, the required settings in `validate.go`, `make install`, and the page hook. It
   should say the design amends the architecture spec at the lines its table names, and that each
   built change lands in F, B3, or O under its own packet.
2. Row 1's "Fact" says "its four method calls". There are now eleven calls, and three forks.
3. The headline and Background should say that F and B3 grow and that O's bar is a drafted page in
   a clean environment.
4. The packet needs one ask per fork, matching the brief's three `### Decide:` blocks.
5. "Not checked": "about one pass later" becomes "at least one pass later". The stock gate's
   contents are now specified, so drop them from that list.
6. "If you approve" gains a step: file the owed errata in the architecture spec and the B1 plan.

## Rulings for Geoff

1. **Existing pages keep their prose.** Should onboarding seed each existing page's lock entry,
   as conversion does, and offer a priced full redraft once? Recommendation: yes. Yes builds a
   seeding command in F and one question in the skill. No means each existing page is redrafted
   whole on its first run, at $3 to $4.50 a page. (C7, M7, H3, A6)
2. **A stock price table.** Should drafter ship a dated price table for its stock models,
   overridable in the user layer, with the caps and `workspace_id` still required and asked for by
   the skill? Recommendation: yes. Yes builds the table in F, and every run report shows its date.
   No leaves prices as user settings the skill helps fill, five rates per model. (C6, M13, H2)
3. **Build only what has a consumer.** Should the Microsoft package and the register kit wait for
   their first consumer (an end-user project, and B5's cairn split)? Recommendation: yes. Yes builds
   the Google package only in F to O. No builds both packages and the kit now, with nothing in F to
   O to test them. (C13, M25)

Not forks, with the reason each has one answer: the O bar (R4), the rules text (R9), bringing a
house guide (R10), merge default for teams (R16), style notes with no register, and `workspace_id`
staying required (R2).

## Build order

No change: change-read, F, B3, O, B4, B5. F and B3 grow, and O's design waits on a whole read
accepting a cairn blueprint in B3.
