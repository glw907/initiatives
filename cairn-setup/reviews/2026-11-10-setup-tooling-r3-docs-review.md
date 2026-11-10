# Review: PR glw907/cairn-cms#221, round three's docs paragraph

Whole-branch `standards:diff-reviewer` at head `f40a61efe`. Verdict: accept, no blocking finding.

The agent page, the embedded copy in the `cairn` binary (byte-identical, `git diff --quiet` exits 0), and
the setup skill say the same three things: put no npx option before the name, add no version or tag, and
write no `new` after it. The launcher claim holds: `packages/create-cairn-site/bin.mjs:77` spawns the
binary with `new` and every argument, so a leading `new` becomes `cairn new new`. The sandbox claim is
hedged ("can keep the call sandboxed") because the sandboxing page does not say how an inserted option or
tag is treated. The two new backlog entries follow the file's format and their ids are free. No path the
plan holds for Geoff is touched.

One non-blocking note, folded at `7db8d7c20`: the two entries carried the UTC date, and the file dates by the
local day, so they now read 2026-11-09.
