# Drafter

## Summary

Drafter generates cairn docs pages from page plans. A page plan names the page's job, its sections, and the facts it may claim. A gated pipeline then drafts the page, runs the docs gate, reviews the draft against the register, and checks each sentence against its fact.

## Motivation

Hand-drafted docs pages drift from the register and from the facts they cite. A pipeline that carries the register, the fact list, and the gate in one place makes a page's quality repeatable and checkable.

## Goals

- Draft a docs page from its page plan with no step that depends on a skill invocation.
- Gate every draft on the docs gate, a register edit, and a sentence-to-fact read before a person sees it.
- Keep the pipeline's code, tests, and gate in the `drafter` repo, with the history of each moved file intact.

## Non-goals

- Writing the register itself. The cairn docs register lives in `cairn-cms`.
- Publishing pages. The docs pass that uses the pipeline owns the published page.
- Drafting prose for other audiences, such as site content.

## Where the work lives

- `drafter`: the Go tooling, the prompts, and from the repo-organization pass the docs page chain workflow, its `cairn-docs-outline` helper, and the drafter gate.
- `workstation`: the `cairn-docs-drafter` and `cairn-register-editor` agents, and until the move the workflow itself. The records of earlier drafter passes stay in `workstation`'s history.

## Records

- Specs and plans for drafter passes 0 to 5 move here from `workstation` once drafter pass 5's PRs have merged. The migration map marks them `deferred:p5` until then.
