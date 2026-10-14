# Cairn docs standard

## Summary

The cairn docs standard sets how every cairn-family docs surface is written. Each surface has one published base style guide, and a register in `cairn-cms` overlays it with recorded departures. Vale and the comment linters check the rules a machine can check.

## Motivation

Sites and the engine share readers and tooling. Without one standard, each repo's docs drift in voice, and a reviewer can't tell a departure from a defect.

## Goals

- Map each docs surface to a base guide: Google for developers, Microsoft for editors.
- Record every departure from a base guide with its provenance and Geoff's ruling.
- Carry the standard into each site repo's own content guide and lint config.

## Non-goals

- Drafting the pages. The drafter initiative owns the pipeline that does it.
- Standards for surfaces that aren't cairn-family docs, such as `workstation`'s internal docs.

## Where the work lives

- `cairn-cms`: the register, `docs/internal/docs-register.md`, and the published docs it governs.
- `workstation`: the voice skills and the authoring charter that route each audience to its standard.
- The site repos (`ecxc-ski`, `907-life`, `aksailingclub-org`, `xcathletes-org`, `cairn-pub`): each repo's content guide and Vale config.

## Records

- The docs standard infrastructure plans move here from `workstation`, per the migration map. The 2026-07-18 register spec and the 2026-09-28 style-guide sync spec stay with the repos that hold them.
