# drafter F, foundations: the stock pieces every project needs

Status: designed 2026-10-18, awaiting Geoff's approval. Initiative: `docs-system`. Scope comes from
the approved onboarding design (`specs/2026-10-18-drafter-onboarding-design.md`, "F, foundations"),
whose acceptance table this design splits between two passes and does not change.

## Brief

Approving this builds the pieces a new project needs before it can use drafter, so nothing it needs
lives only on this workstation. The onboarding design's F holds about fourteen pieces, so it runs as
two passes. F1 is setup and checks, in plain Go. F2 is the prompt mechanism and the tracks, which
touch the prompt contract. F1 launches after the change-read pass merges, whatever that pass's
format test scores, and F2 follows F1 (Geoff, 2026-10-18). Each is planned without Geoff and handed
to the conductor, and each comes back to him as one packet.

## F1, setup and checks

Outcome: a new repo runs `drafter init`, then `drafter check` passes; its config resolves without a
gate of its own or a hand-copied price table; facts are verified against their sources; and an
existing page's prose survives its first blueprint.

- `drafter init`: writes `drafter.toml`, `blueprints/outline.yaml` with the base types, and a facts
  directory holding a `README.md` with the bullet grammar and a seed file, all passing
  `drafter check`.
- Defaults for `gate.command` (the stock gate) and each stock seat's model, effort, and
  `max_tokens`; a dated price table for the stock models, overridable in the user layer, its date in
  every run report. `workspace_id`, `page_cap`, and `cycle_ceiling` stay required.
- `drafter gate --page`: that page's blueprint, the facts it cites, Vale on the page with its
  package pinned by release URL, and internal links. It confirms Vale and the package before any
  spend.
- Fact verification in `drafter check`: cairn's `check:facts` contract, generalized (bullet grammar,
  a unique id, the tag vocabulary, a source that resolves as `path`, `path:line[-line]`, or
  `path#Symbol`, and a quoted anchor within ten lines). Unsupported pointer forms are skipped and
  counted. The `Source:` grammar is published in the format page.
- Lock seeding: a command that writes an existing page's lock entry from the page as it stands once
  its blueprint is accepted, as conversion does.

Acceptance: the onboarding design's rows for `init` then `check`, the fact fixtures, and cairn's
1,748 facts, plus `drafter config` resolving with only a key source, `workspace_id`, and two caps
in the user layer once `prompts` is set; and a seeded fixture page whose lock entry carries the
page and section hashes conversion would write, where today an entry with only `accepted` marks it
not drafted (`internal/blueprint/blueprint.go:169-173`).

## F2, prompts and tracks

Outcome: drafter runs on a stock prompt module when a project names none, and a project declares its
reader tracks.

- The stock-prompt mechanism: an embedded default module through `prompts.Load`, which takes bytes
  (`internal/prompts/prompts.go:49`); embedded package blocks; the `path#heading` excerpt.
  `drafter config` and every run report name the module's source and hash, and the run directory
  keeps its bytes so a resume after an upgrade uses the same prompts. The module's text is
  placeholder until B3 writes it against B3's handoff.
- A committed setting with which a project refuses the stock fallback; cairn sets it.
- `tracks` in `outline.yaml` with path globs, additive to v1.
- Stock anatomies and the introduction guidance as reference pages; the `framing.introPlan` rule;
  the new-page procedure and `check.go:221`'s fix text stop naming a register.

Acceptance: the onboarding design's rows for cairn's config with no local file, an unknown anatomy
and a missing `introPlan`, and a headless new-page session opening no register path; plus
`drafter config` resolving with no `prompts` setting.

## Shared

- Fixture: a synthetic repo with no register and one non-cairn track, run with `HOME` holding only
  the drafter binary and Vale. The drafter repo is public, so it is synthetic.
- Risk class `runner` (the gate tools and the skill). Not `live-account`: no acceptance check calls
  the API. `internal/pipeline/money.go` and `resume.go` stay untouched; a need to edit either stops
  the line.
- Repos: `glw907/drafter`; cairn-cms read-only, for the facts comparison and the guard setting's
  one-line change, landed in F2's packet.
- Estimates: F1 240 path minutes, F2 200. B1 planned 780 and ran in about 240; B2 planned 530 and
  ran in about 60.
- Out of scope: the stock prompt text, the provenance check, and the standard package's embedded
  parts (B3); the plugin, release binaries, and the onboarding skill (O); the Microsoft package and
  the register kit (their first consumer).

## Standing answers

The planner and conductor apply these in place of stopping (Geoff, 2026-10-18).

- F1 launches after change-read merges, whatever its format test scores.
- Each plan whose path stays within twice its estimate (480 for F1, 400 for F2) launches unattended.
- A plan over that line, or a finding that changes this design, stops and asks Geoff.
