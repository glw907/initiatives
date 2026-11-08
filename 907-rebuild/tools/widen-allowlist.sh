#!/usr/bin/env bash
# widen-allowlist.sh: add everyday shell tools to the clean-room builders' Bash allowlist, then
# reinstall both homes' settings. Builder A's T7 turn was refused six compound commands that used
# tools off the list (cat >, chmod, bash, tail, curl, sleep, rm, sed, cd, timeout). The OS
# sandbox still confines reads, writes, and the network, and the deny list is unchanged.
set -euo pipefail
cd "$(dirname "$(readlink -f "$0")")"
jq '.permissions.allow += ([
    "cd", "rm", "sed", "chmod", "bash", "sh", "tail", "head", "curl", "sleep", "timeout",
    "kill", "pkill", "grep", "find", "diff", "cmp", "wc", "sort", "uniq", "tar", "touch",
    "ln", "jq", "echo", "printf", "test", "pwd", "env", "which", "file", "du", "stat",
    "basename", "dirname", "xargs", "awk", "tr", "cut", "tee", "date", "seq",
    "chromium-browser", "/usr/bin/chromium-browser", "~/work/tools/*"
  ] | map("Bash(" + . + " *)")) | .permissions.allow |= unique' cleanroom-settings.json > s.new
mv s.new cleanroom-settings.json
./cleanroom-run install
echo "allowlist now $(jq '.permissions.allow | length' cleanroom-settings.json) entries"
