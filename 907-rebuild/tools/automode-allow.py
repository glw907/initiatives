"""Add two autoMode allow rules to the stowed Claude Code settings, then commit and push.

Geoff runs this himself, because auto mode refuses any session's edit to its own rules.
Run it as `python3 -I automode-allow.py`. Rerunning it adds nothing that is already there.
The rules follow https://code.claude.com/docs/en/permission-modes (auto mode's
`autoMode.allow` prose rules).
"""
import json
import pathlib
import subprocess

REPO = pathlib.Path.home() / ".dotfiles"
SETTINGS = REPO / "claude/.claude/settings.json"
QUOTE = '(2026-11-08: "You need to be able to do this kind of thing directly")'

RULES = [
    "Publishing 907.life DNS from a checkout or worktree of github.com/glw907/servers is routine "
    f"work Geoff asked for {QUOTE}. This covers `cloudflare/dns.sh --apply` and "
    "`bash cloudflare/dns.sh --apply` when every record it creates, changes, or deletes is "
    "declared in a file under `cloudflare/dns/` or `cloudflare/redirects/` committed on that "
    "checkout's HEAD; dns.sh prints each change and ends with its own check. It clears Production "
    "Deploy, Blind Apply, and Modify Shared Resources for that apply only. It does not clear a "
    "change to a name or type no committed file declares, a direct Cloudflare API write to the "
    "zone outside dns.sh, deleting the zone, or anything a permissions deny rule names.",
    "Configuring the clean-room builder sandbox is routine work Geoff asked for "
    f"{QUOTE}. The clean room runs untrusted naive builder sessions (`claude -p` in "
    "`/var/tmp/cairn-cleanroom/A` and `/B`), separate from this session. Its settings template is "
    "`907-rebuild/tools/cleanroom-settings.json` in a checkout or worktree of "
    "/var/home/glw907/Projects/initiatives, or the `cleanroom` tool's template in a checkout or "
    "worktree of /var/home/glw907/.dotfiles, and `cleanroom-run install` or `cleanroom install` "
    "copies it into the builder homes. Edits and commits to that template, and running the "
    "install, are allowed when they add to the builders' `permissions.allow` (everyday shell "
    "tools, never `Bash(*)`), add a host to `sandbox.network.allowedDomains` for a package "
    "registry, a browser or tool download, or a docs site, set `env` keys such as "
    "`NODE_USE_ENV_PROXY`, or set `sandbox.network.allowAllUnixSockets`. This clears Security "
    "Weaken and Self-Modification for those edits only. It does not cover removing or narrowing "
    "a `permissions.deny` rule, a `denyRead` path, `blockReadsOutsideWorkingDirectories`, "
    "`blockWritesOutsideWorkingDirectories`, or `strictAllowlist`; adding Geoff's home, `/tmp`, "
    "`/run/user`, `/dev/shm`, or a secrets path to a builder's reads or writes; giving a builder "
    "a credential; or the observing session's own settings.",
]


def git(*args):
    subprocess.run(["git", "-C", str(REPO), *args], check=True)


def main():
    git("pull", "--ff-only", "-q")
    data = json.loads(SETTINGS.read_text())
    allow = data["autoMode"]["allow"]
    added = [r for r in RULES if r not in allow]
    if not added:
        print("both rules are already there")
        return
    allow.extend(added)
    SETTINGS.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n")
    git("add", "claude/.claude/settings.json")
    git("commit", "-q", "-m", "Allow declared dns.sh applies and clean-room sandbox config in auto mode\n\n"
        "Geoff, 2026-11-08: \"Please fix auto mode so this isn't a recurring problem.\"\n"
        "Follows https://code.claude.com/docs/en/permission-modes (autoMode.allow).")
    git("push", "-q", "origin", "main")
    print(f"added {len(added)} rule(s), committed, and pushed")


main()
