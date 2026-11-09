"""Add the setup-tooling autoMode lines to the dotfiles settings, replacing the prototype's clean-room line.

Run by Geoff: python3 -I add-setup-tooling-grant.py [--dry-run | --remove [--dry-run]], then
claude-tooling-sync apply, then commit claude/.claude/settings.json in ~/.dotfiles.
  --dry-run  Print what would change and write nothing.
  --remove   The initiative's end packet: remove the six setup-tooling lines. It does not restore
             the 907-rebuild prototype's line; it prints a note instead, since that rerun builds
             a new grant if it resumes.
Any other argument is refused, so a typo never writes.
It edits only autoMode.allow. Adding also removes the 907-rebuild prototype's line that begins
"Configuring the clean-room builder sandbox", because the first line below replaces it for the new
`cleanroom` tool. It skips a marker already present, keeps the file's 2-space format, and writes a
temporary file beside the settings, flushed and fsynced, that it renames over them (os.replace, an
atomic rename(2) on POSIX), so an interrupted run never leaves the settings truncated.
This file is the single source of the six lines' text; the plan's pre-flight item 5 points here.
"""

import json
import os
import sys

PATH = "/var/home/glw907/.dotfiles/claude/.claude/settings.json"
PLAN = "/var/home/glw907/Projects/initiatives/cairn-setup/plans/2026-11-09-setup-tooling-plan.md"
OLD_PREFIX = "Configuring the clean-room builder sandbox is routine work"
END = " The initiative's end packet removes this line through Geoff's [you] step."
SANDBOX_DOC = "https://code.claude.com/docs/en/sandboxing"
EXCLUDED = (
    "`cairn *`, `npm create cairn-site`, `npm create cairn-site -- *`, `npx create-cairn-site *`"
)

LINES = [
    "setup-tooling-cleanroom-config: Configuring the clean room is routine work Geoff asked for "
    "(2026-11-08: \"You need to be able to do this kind of thing directly\"; design approved 2026-11-09). "
    "The clean room runs untrusted naive Claude Code sessions on the test accounts, separate from this "
    "session. Its settings template is bin/.local/share/cleanroom/settings.json, its probe list "
    "bin/.local/share/cleanroom/probe-commands.md, and its tool bin/.local/bin/cleanroom, in a checkout "
    "or worktree of /var/home/glw907/.dotfiles; `cleanroom init` copies the template into a clean home "
    "under /var/tmp/cleanroom/. Edits and commits to those files, and running `cleanroom init`, are "
    "allowed when they add to the clean room's `permissions.allow` (everyday shell tools, "
    f"`WebFetch(domain:...)` rules for hosts on the network allowlist, or the excluded patterns {EXCLUDED}; "
    "never `Bash(*)` or a bare `WebFetch`), add a host to `sandbox.network.allowedDomains` for a package "
    "registry, GitHub, the Cloudflare API, the carin-test.org test zone or *.workers.dev, a browser or "
    "tool download, or a docs site, add a `sandbox.credentials.envVars` or `files` entry in `deny` mode, "
    "set `env` keys such as `NODE_USE_ENV_PROXY` or `npm_config_tag`, set `permissions.defaultMode` "
    "to `default` so the clean room's permission prompts show, set "
    "`sandbox.network.allowAllUnixSockets`, set a `statusLine` command that writes the session's "
    "statusline JSON into the clean room's run directory, or add `sandbox.excludedCommands` entries for "
    f"the cairn tool and its launcher only ({EXCLUDED}). Those run outside the sandbox because setup's "
    "browser tab listens on 127.0.0.1 and a sandboxed command's localhost is private on Linux "
    f"({SANDBOX_DOC}). This clears Security Weaken and Self-Modification for those edits only. It does "
    "not cover removing or narrowing a `permissions.deny` rule, a `denyRead` path, a credentials `deny` "
    "entry, `blockReadsOutsideWorkingDirectories`, `blockWritesOutsideWorkingDirectories`, "
    "`strictAllowlist`, `sandbox.enabled`, `failIfUnavailable`, or `allowUnsandboxedCommands: false`; an "
    "excluded command other than those four; setting `CLAUDE_CODE_SUBPROCESS_ENV_SCRUB` or "
    "`allowNestedUserNamespaces`; adding Geoff's home, `/tmp`, `/run/user`, `/dev/shm`, or a secrets path "
    "to the clean room's reads or writes; writing a credential into the template; or the observing "
    "session's own settings." + END,
    "setup-tooling-cleanroom-run: Under the approved setup-tooling plan "
    f"({PLAN}), running `cleanroom init`, `probe`, `run`, `shell`, `cost`, `capture`, `scan`, and `stop`, "
    "and cairn-cms's `bash scripts/gate/run-gate.sh` forms (`--smoke`, `sweep` without `--apply`, "
    "`sweep --check-scopes`, `probe`, `naive`, `scripted`, `grade`, `shell`), from a checkout or worktree "
    "is routine; none of these deletes anything (`naive` refuses while the sweep's dry run lists a target, "
    "and the sweep's apply is the setup-tooling-sweep line's). On a yes to the plan's Decide S-8, "
    "`cleanroom` starts the clean session as the unprivileged `cleanroom` user through its own `sudo -n -u "
    "cleanroom ... _child` call, the only command the sudoers drop-in allows; that is routine, and sudo "
    "to root or any other user is not. `cleanroom` hands test-account credentials into the clean room by store name through "
    "`--secret`, never by value on a command line: CF_WS_CAIRN_CLEANROOM_TOKEN, "
    "ANTHROPIC_CLEANROOM_API_KEY (CLAUDE_CLEANROOM_OAUTH_TOKEN on a no to the plan's Decide S-3), and, "
    "for `probe` only, GITHUB_TEST_TOKEN. `run-gate.sh` reads CF_WS_CAIRN_CLEANROOM_TOKEN, "
    "GITHUB_TEST_TOKEN, and the machine account's TOTP and mailbox names itself for the sweep, the "
    "stand-in, and the grader. `sweep --check-scopes` creates and deletes only throwaway resources named "
    "`cairn-gate-probe-<time>`. The harness sources the store itself; the session never reads a value, "
    "and it reads the clean room's pane through `cleanroom capture`, which redacts every handed-in value. "
    "Answering the clean-room session through `tmux send-keys` as the plan's owner card describes is "
    "routine, including its permission prompts with \"Yes\" once or \"No\", never \"don't ask again\", "
    "and always \"No\" to a WebFetch of a host outside the clean room's network allowlist: "
    "that session is the test subject, runs under the approved clean-room settings, and holds only those "
    "credentials. This clears Credential Exposure for those names and that hand-off only. It does not "
    "cover passing any other store value, any credential for Geoff's own accounts (glw907), reading a "
    "value into this session's transcript, approving an unsandboxed-command prompt, or approving a prompt "
    "for this session itself." + END,
    "setup-tooling-held-files: Edits and commits inside git worktrees of /var/home/glw907/Projects/cairn-cms "
    "(paths under /var/home/glw907/Projects/cairn-cms/.claude/worktrees/) are allowed when they implement "
    f"task T2.7 or a round fix of pass 3 of the approved setup-tooling plan ({PLAN}), limited to "
    ".claude/skills/cairn-releasing/** and .claude/skills/cairn-proving-setup/**. These edits state the "
    "release rule and the conductor's proving procedure that the approved design names. Each change "
    "takes effect only after its PR merges. This clears Self-Modification and Instruction Poisoning for "
    "that text only; it does not cover the repo's .claude/settings.json, hooks, permission rules, "
    "autoMode, or memory, and it does not cover text that grants permissions or tells a session to "
    "bypass a block. Pair subagents never write these paths; they hand the content back and the "
    "executor writes it." + END,
    "setup-tooling-merge: Under the approved setup-tooling plan "
    f"({PLAN}), `gh pr merge <n> --merge --match-head-commit <head>` in glw907/cairn-cms or "
    "glw907/workstation is routine for conductor-cairn-cms on a round PR of pass 3 (head branch "
    "`setup-tooling-r<n>`), once on that head: CI is green (cairn-cms) or `bash scripts/gate.sh` passed "
    "on it (workstation); the whole-branch diff review is folded with no open finding and no escalate "
    "verdict; a PR touching an auth-data path also has its security read folded; `npm run "
    "check:docs-gate` is green when docs changed; and the conductor has posted the plan's gate record on "
    "the PR. Geoff's design approval (\"The conductor runs the loop unattended and merges each round's "
    "fixes under the plan's gates\", 2026-11-09) is the authorization. This clears Merge Without Review "
    "only, for those PRs only: never passes 1 or 2, which go to Geoff in a packet; never a version "
    "bump, tag, publish, or release; and never a PR whose diff touches `.github/**`, `scripts/release/**`, "
    "`.claude/settings*`, the sweep's name matcher in `scripts/gate/sweep.mjs` or its pinning test, "
    "`bin/.local/bin/cleanroom`'s secret, environment, user, or stop code, or (unless the plan's Decide S-5 "
    "was ruled yes) `bin/.local/share/cleanroom/settings.json`. Those go to Geoff in a small packet." + END,
    "setup-tooling-candidates: Under the approved setup-tooling plan "
    f"({PLAN}), cutting a cairn prerelease candidate to npm's hidden `gate` dist-tag is routine for the "
    "pass 3 executor (cairn-cms-setup-tooling-3): the light cut in cairn-cms's cairn-releasing skill "
    "(`scripts/release/preflight.mjs`, `bump.mjs`, a fast-forward push of the cut commit to main, and "
    "`gh release create v0.99.0-rc.<n> --prerelease --target <sha>`), pushing a `tool/v2.0.0-rc.<n>` tag "
    "at a commit on main, and `gh run rerun <id> --failed` of the publish.yml or tool.yml run for such a "
    "prerelease. Each publishes only to `gate`, which no install reads by default. This clears Production "
    "Deploy for those prereleases only. It does not cover a stable version, the `latest` or `next` "
    "dist-tag, the promote dispatch, `npm dist-tag`, `npm deprecate`, `npm unpublish`, any other package, "
    "or a force push." + END,
    "setup-tooling-sweep: Under the approved setup-tooling plan "
    f"({PLAN}), `bash scripts/gate/run-gate.sh sweep --apply` in a checkout or worktree of "
    "/var/home/glw907/Projects/cairn-cms is routine once a dry run in the same session printed its "
    "delete list. It deletes only what setup derives from a `Cairn gate <run id>` site name, matched by "
    "the anchored names the plan gives: on the glw907-test machine account the repository "
    "`cairn-gate-<10 digits>[-<2-9>]` (its in-progress Actions runs cancelled first) and the GitHub App "
    "`cairn-cairn-gate-<10 digits>`; on the Cloudflare account the Worker of the repository's name, the "
    "custom domains whose `service` is that Worker, the D1 database `<name>-auth`, and the R2 bucket "
    "`<name>-media`, emptied first. It deletes no DNS record. This clears Blind Apply and Irreversible "
    "Destruction for those deletes only. It does not cover the carin-test.org zone, its DNS records, or "
    "its Email Sending, the ci-cairn-build token or the cairn-build registration, the old gate's "
    "`cairn-e2e-gate-` resources, any other name, or anything on the glw907 account." + END,
]
MARKERS = tuple(line.split(":", 1)[0] + ":" for line in LINES)


def parse(args: list[str]) -> tuple[bool, bool]:
    """Return (dry, remove), refusing any argument but the two flags."""
    allowed = {"--dry-run", "--remove"}
    unknown = [arg for arg in args if arg not in allowed]
    if unknown or len(args) != len(set(args)):
        sys.exit(f"usage: add-setup-tooling-grant.py [--dry-run] [--remove]; refused: {' '.join(args)}")
    return "--dry-run" in args, "--remove" in args


def main() -> None:
    """Add or remove the six lines, or print what either would do."""
    dry, remove = parse(sys.argv[1:])
    with open(PATH, encoding="utf-8") as handle:
        settings = json.load(handle)
    allow = settings.setdefault("autoMode", {}).setdefault("allow", [])

    if remove:
        kept = [entry for entry in allow if not entry.startswith(MARKERS)]
        report = [f"remove: {entry.split(':', 1)[0]}" for entry in allow if entry.startswith(MARKERS)]
        report.append("note: the 907-rebuild prototype's clean-room line is not restored")
    else:
        kept = [entry for entry in allow if not entry.startswith(OLD_PREFIX)]
        report = ["remove: the prototype's clean-room line"] if len(kept) < len(allow) else []
        for line in LINES:
            marker = line.split(":", 1)[0] + ":"
            if any(entry.startswith(marker) for entry in kept):
                report.append(f"skip: {marker} already present")
                continue
            kept.append(line)
            report.append(f"add: {marker}")

    for row in report:
        print(row)
    if dry:
        print("dry run: nothing written")
        return
    allow[:] = kept
    tmp = PATH + ".tmp"
    with open(tmp, "w", encoding="utf-8") as handle:
        json.dump(settings, handle, indent=2, ensure_ascii=False)
        handle.write("\n")
        handle.flush()
        os.fsync(handle.fileno())
    os.replace(tmp, PATH)
    print(f"wrote {PATH}; now run: claude-tooling-sync apply, then commit it in ~/.dotfiles")


if __name__ == "__main__":
    main()
