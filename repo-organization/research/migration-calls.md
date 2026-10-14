# Migration map calls

## Brief

Approving this settles 4 placements the classifier could not make, so the docs copy can start.

The classifier placed 172 of 173 entries on its own. A copy never runs while an entry is unplaced, and a differing file in a destination repo is kept there unless you say otherwise.

### What changes

- 1 unplaced entry gets a destination you pick.
- 3 differing files stay as the destination copy unless you choose the workstation copy.
- The other 172 entries stay as the map places them.

### If you approve

1. Your choices replace the `flagged` and `collision-differs` states in the migration map.
2. The copy step runs per destination repo, each in one commit that names the source commit.
3. Workstation deletes the moved files in a draft PR that waits on the verification check.

### Decide: 2026-08-30-dubplate-go-rewrite-design.md already exists in dubplate

A different copy of `2026-08-30-dubplate-go-rewrite-design.md` sits in `dubplate` at `docs/superpowers/specs/2026-08-30-dubplate-go-rewrite-design.md`. The workstation copy would replace it, so someone has to say which one is current.

Source: `docs/superpowers/specs/2026-08-30-dubplate-go-rewrite-design.md` against `docs/superpowers/specs/2026-08-30-dubplate-go-rewrite-design.md` in `dubplate`

- Keep the destination (recommended)
- Replace with the workstation copy

### Decide: 2026-08-31-dubplate-uploader-design.md already exists in dubplate

A different copy of `2026-08-31-dubplate-uploader-design.md` sits in `dubplate` at `docs/superpowers/specs/2026-08-31-dubplate-uploader-design.md`. The workstation copy would replace it, so someone has to say which one is current.

Source: `docs/superpowers/specs/2026-08-31-dubplate-uploader-design.md` against `docs/superpowers/specs/2026-08-31-dubplate-uploader-design.md` in `dubplate`

- Keep the destination (recommended)
- Replace with the workstation copy

### Decide: 2026-08-31-dubplate-uploader.md already exists in dubplate

A different copy of `2026-08-31-dubplate-uploader.md` sits in `dubplate` at `docs/superpowers/archive/plans/2026-08-31-dubplate-uploader.md`. The workstation copy would replace it, so someone has to say which one is current.

Source: `docs/superpowers/plans/2026-08-31-dubplate-uploader.md` against `docs/superpowers/archive/plans/2026-08-31-dubplate-uploader.md` in `dubplate`

- Keep the destination (recommended)
- Replace with the workstation copy

### Decide: Where 2026-10-11-cairn-cms-alignment-audit.md belongs

No rule places `2026-10-11-cairn-cms-alignment-audit.md`, so it has no destination yet. The options below are the repos its text names most, plus leaving it where it is.

Source: `docs/superpowers/research/2026-10-11-cairn-cms-alignment-audit.md`

- Move it to `cairn-cms` under `docs/superpowers/` (recommended)
- Keep it in `workstation`

## Decisions applied

Geoff decided each block on 2026-10-14, and the map reflects the calls.

- `2026-08-30-dubplate-go-rewrite-design.md`: keep the destination. The `dubplate` copy stays and `workstation` deletes the source.
- `2026-08-31-dubplate-uploader-design.md`: keep the destination, same handling.
- `2026-08-31-dubplate-uploader.md`: keep the destination, same handling. The row keeps the state `collision-differs`, and the pass does not overwrite the `dubplate` file.
- `2026-10-11-cairn-cms-alignment-audit.md`: move it to `cairn-cms` under `docs/superpowers/research/`. Its map row is now `moved` with `new_repo` cairn-cms, so the `cairn-cms` sweep receives it.
