# Onboarding a new project to drafter

Status: designed with Geoff in chat, 2026-10-18, awaiting his approval. Initiative: `docs-system`.
This amends `2026-10-17-blueprint-architecture-design.md`: it adds a goal and an anti-goal, a
section on onboarding, and a new build order. Everything else in that spec stands.

## Brief

Approving this makes setup for a new developer on a new project a first-class goal of drafter, not
a sub-project 5 afterthought (Geoff, 2026-10-18). Before drafter can draft anything, a new project
needs four things built with Claude: a facts store from a code audit, a style register, a
doc-set register, and an outline. The developer reads a system overview first, then runs an
onboarding skill in Claude Code that builds all four with them.

The order changes. After the change-read pass, a foundations pass gives drafter the stock pieces
every project needs, so B3 builds on those rather than on cairn's own. The onboarding skill and the
overview land after B3, and drafter onboards itself as the first new project. The cairn release
waits about one pass longer.

## The new goal and anti-goal

- Goal: a new developer on a new project gets drafter working through one documented path. They
  read the system overview, install, and run the onboarding skill. Nothing they need lives only on
  Geoff's workstation.
- Anti-goal: a project needs a file, setting, agent, or tool that exists only on the machine that
  built drafter. Today that's true of the prompts module (`~/.claude/workflows/docs-page-chain.js`),
  the seat agent paths, the docs gate and the fact checks (cairn's `check:facts` and
  `check:provenance`), and the skill and hook install (drafter's `make install` plus this
  workstation's dotfiles settings).

## What a new project builds

Four pieces come before any blueprint. The developer rules on everything a person must decide;
Claude does the reading and the drafting.

1. **The facts store.** Claude audits the code and writes each fact with its source. drafter
   verifies mechanically that each cited source exists, which cairn's gates do today.
2. **The style register.** The developer picks a base guide for each track (Google for developer
   docs, Microsoft for end-user docs). The register then records each departure with its provenance
   and the developer's ruling. Claude may propose departures; only the developer rules.
3. **The doc-set register.** This says which pages exist, on a published base: reader tracks, with
   Diátaxis modes inside each (tutorial, how-to, reference, explanation) and Good Docs Project
   templates for the page anatomies (Geoff, 2026-10-18). The project declares its tracks, each with
   a reader profile, and records any page type beyond the base as a departure. cairn's four tracks
   and its symptom-row type are one project's overlay on this base. cairn's register already uses
   Diátaxis and the Good Docs templates, internally.
4. **The outline.** Claude proposes the doc set from what the audit found: each track's surfaces,
   the tasks the code supports, and the concepts a reader needs. The developer approves it, and it
   becomes `blueprints/outline.yaml`.

Blueprints follow. A new page gets one from the blueprint skill's new-page procedure. An existing
page gets one the same way, with the page itself as a source, so onboarding doesn't wait on the
write-back seat (B4).

## Who drives it

A Claude Code session running the onboarding skill drives it (Geoff, 2026-10-18). Two of the four
pieces need the developer's rulings, and the audit needs an agent that can explore a repo. The
skill calls drafter for the mechanical steps: `drafter init`, `drafter check`, and fact
verification.

Before the skill, the developer reads the system overview (Geoff, 2026-10-18). It explains the four
pieces, the blueprint rule, the nightly run, and what each piece costs, so the skill's questions
make sense when they come. It is drafter's own published documentation, written to the Google
developer documentation style guide.

## What drafter ships stock

- Stock prompts built into the binary, generalized from the chain's seat prompts. A project may
  still point `prompts` at its own module, as cairn does.
- `drafter init`, which writes `drafter.toml`, `blueprints/outline.yaml` with the base types, a
  facts directory, and register stubs naming the base guides.
- Fact verification and a stock docs gate (`drafter check`, Vale on the base package, and a link
  check). The gate is the default `gate.command`, so a new project needs no gate of its own.
- The base doc-set standard as a reference page, and the page anatomies as the new-page reference.
- The blueprint skill, the onboarding skill, and the page hook, packaged as a Claude Code plugin so
  one install covers them on any machine.

## Build order

1. The change-read pass (planned; it adds no setup step).
2. F, foundations: stock prompts, `drafter init`, fact verification, the stock gate, and fewer
   required settings. cairn keeps its overrides.
3. B3, drafting from blueprints, built on the stock pieces.
4. O, onboarding: the onboarding skill, the plugin, the system overview, and drafter onboarding
   itself as the first new project. It is accepted when a fresh session in a new repo, with only
   the plugin, the overview, and a key, reaches a first accepted blueprint.
5. B4, the nightly run, then B5, the migrations, where cairn's register splits into the base and its
   overlay.

## Calls made in this design

1. Fact verification checks that a cited source exists; the audit and the fact read judge whether
   the fact is true.
2. An existing page's first blueprint comes from the new-page procedure during onboarding, not
   from the write-back seat.
3. The skills and the hook ship as a plugin in O. drafter's `make install` stays for development.
4. Each pass's risk class and estimate are set when it's planned.
