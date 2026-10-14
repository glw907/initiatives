# Initiatives

This repo holds one record per initiative: a body of work that spans repos or runs longer than a single pass. Each record states the initiative's goals, its non-goals, the repos it touches, and its status. The records follow the shape of a Kubernetes enhancement proposal (KEP), trimmed to what a small team needs.

Cross-repo specs, plans, and research live next to the record they serve. A session in any repo reads the matching records at startup, so work lands where the goals say it belongs.

## Place new work

Work falls under one of three cases. Check them in order.

1. The work belongs to an initiative when it serves one of the initiative's goals and no non-goal excludes it. Put its spec, plan, and research in `<id>/specs/`, `<id>/plans/`, or `<id>/research/`, and start the plan with an `Initiative: <id>` line.
2. When no record fits, the work is ordinary work for that repo's backlog, or the start of a new initiative. A new initiative gets a record with status `proposed`.
3. A fix with no larger purpose needs no initiative.

A document that concerns one repo only stays in that repo's `docs/superpowers/`, even when it belongs to an initiative.

## Add or change a record

Each record is a directory named for its `id`:

```
<id>/
├── initiative.yaml
├── README.md
└── specs/  plans/  research/
```

`initiative.yaml` holds only the fields that tools read:

```yaml
id: drafter
title: Drafter
summary: Generates cairn docs pages from page plans through a gated pipeline.
status: active
owner: glw907
created: 2026-10-12
repos: [drafter, workstation]
```

The `status` is one of `proposed`, `active`, `paused`, `done`, or `withdrawn`. The `repos` list holds GitHub repo names under `glw907`, with no owner prefix. A surface that isn't a repo, such as a Google Doc, goes in the README's "Where the work lives".

The record's `README.md` has six sections: Summary, Motivation, Goals, Non-goals, Where the work lives, and Records. The non-goals carry the most weight, because they settle whether a piece of work belongs. A status change adds a dated line to the README, so the history stays with the record.

After you edit a record, run `scripts/index` to regenerate the table below, then `scripts/check`.

## Check the records

```
scripts/check            # every state but the repos list; what CI runs
scripts/check --repos    # also checks each repos entry against `gh repo list glw907`
scripts/test.sh          # scripts/check plus every *.test.sh
```

`scripts/check` fails and names the file for each of these states: no records, a directory without `initiative.yaml`, YAML that doesn't parse, an `id` that differs from its directory name, a duplicate `id`, an unknown `status`, a missing required field, a `repos` entry that isn't a `glw907` repo, and an index that disagrees with the YAML. CI skips the `repos` state because several listed repos are private. Run `scripts/check --repos` under your own `gh` login, which sees them.

## Know the repo names

`~/Projects/workstation` is a symlink to `~/.dotfiles`, so both names refer to the same repo, `glw907/workstation`. A session's repo name comes from its `origin` remote.

## Index

<!-- index:start -->
| Initiative | Status | Repos | Summary |
|---|---|---|---|
| [Approval queue](approval-queue/README.md) | active | approval-queue, workstation | Puts each PR, design, and triage list in front of Geoff in one app and returns his decision to the session. |
| [Cairn docs standard](cairn-docs-standard/README.md) | active | cairn-cms, workstation, ecxc-ski, 907-life, aksailingclub-org, xcathletes-org, cairn-pub | Keeps every cairn-family docs surface on one published base style guide plus a recorded register. |
| [Drafter](drafter/README.md) | active | drafter, workstation | Generates cairn docs pages from page plans through a gated pipeline. |
| [Monthly model review](monthly-model-review/README.md) | active | workstation | Reviews the Claude models, effort settings, and skills each month and logs the result. |
| [Personal design system](personal-design-system/README.md) | proposed | 907-life, cairn-themes, approval-queue | Would unify the visual language of Geoff's own surfaces under one design system. |
| [Repo organization](repo-organization/README.md) | active | initiatives, workstation, drafter, approval-queue, dubplate, poplar, cairn-cms, 907-life, aksailingclub-org, cairn-pub, cairn-themes, ecxc-ski, phonebook, xcathletes-org | Gives every initiative a record, moves past work to the repo that owns it, and retires unused repos. |
| [Shared standards](shared-standards/README.md) | proposed | workstation | Would package the skills, registers, and agents an outside developer needs as a Claude Code plugin marketplace. |
| [Workstation secrets](workstation-secrets/README.md) | proposed | workstation | Would track the age-encrypted secrets across both workstations so no machine holds one the other lacks. |
<!-- index:end -->
