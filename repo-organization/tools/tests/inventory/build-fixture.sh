#!/usr/bin/env bash
# build-fixture.sh ROOT: add the known-ties state to a fixture root (Projects/ and the HOME files).
# Repos that do not exist yet are created. Every id here is invented.
set -euo pipefail
root=$1
here="$(cd "$(dirname "$0")" && pwd)"
scope="$here/../../../scope.tsv"
export GIT_AUTHOR_NAME=t GIT_AUTHOR_EMAIL=t@example.invalid GIT_COMMITTER_NAME=t GIT_COMMITTER_EMAIL=t@example.invalid
kv() { printf '%032x' "$1"; }
d1=00000000-0000-0000-0000-00000000d001

dir_of() { local p; p=$(awk -F'\t' -v r="$1" '$1 == r {print $3}' "$scope"); p="${p/#\~\/Projects\//$root/Projects/}"; echo "${p/#\~\//$root/}"; }
put() { mkdir -p "$(dirname "$1")"; cat > "$1"; }
commit() { git -C "$1" add -A && git -C "$1" commit -q -m fixture --allow-empty; }

while IFS=$'\t' read -r repo _ _; do
  [[ $repo == repo ]] && continue
  d=$(dir_of "$repo")
  [[ -d $d ]] || { mkdir -p "$d"; git -C "$d" init -q; printf '%s\n' "$repo" > "$d/README.md"; }
done < "$scope"

# pings: a jsonc config with comments and trailing commas, a KV, a custom domain, and a cron
put "$(dir_of pings)/wrangler.jsonc" <<EOF
{
  // the pings Worker
  "name": "pings",
  "kv_namespaces": [{ "binding": "PINGS_KV", "id": "$(kv 1)", },],
  "routes": [{ "pattern": "pings.example.invalid/*", "custom_domain": true }],
  "triggers": { "crons": ["*/5 * * * *"] },
}
EOF
mkdir -p "$(dir_of pings)/scripts"; echo '#!/bin/sh' > "$(dir_of pings)/scripts/add-check"

# aksailingclub-sveltekit: binds Workers and a bucket the legacy repo also binds
put "$(dir_of aksailingclub-sveltekit)/wrangler.toml" <<EOF
name = "asc-shell"
services = [{ binding = "HB", service = "asc-handbook" }, { binding = "UP", service = "asc-uptime" }]
r2_buckets = [{ binding = "IMG", bucket_name = "asc-event-images" }]
d1_databases = [{ binding = "DB", database_name = "asc-shell-db", database_id = "$d1" }]
kv_namespaces = [{ binding = "K3", id = "$(kv 3)" }, { binding = "K4", id = "$(kv 4)" }]
[env.staging]
kv_namespaces = [{ binding = "K2", id = "$(kv 2)" }]
EOF
put "$(dir_of aksailingclub-legacy)/wrangler.toml" <<EOF
name = "asc-legacy-main"
r2_buckets = [{ binding = "IMG", bucket_name = "asc-event-images" }]
EOF
put "$(dir_of aksailingclub-legacy)/.github/workflows/deploy.yml" <<'EOF'
jobs:
  deploy:
    steps:
      - run: npx wrangler deploy --name asc-handbook
      - run: |
          npx wrangler deploy \
            --name asc-uptime
EOF

# cairn-scratch: one id per hiding place in a surviving repo
put "$(dir_of cairn-scratch)/wrangler.toml" <<EOF
name = "scratch-a"
kv_namespaces = [{ binding = "A", id = "$(kv 11)" }, { binding = "B", id = "$(kv 12)" }]
routes = ["scratch.example.invalid/*", "app.wild.example.invalid/*"]
EOF
put "$(dir_of cairn-scratch)/apps/w3/wrangler.toml" <<'EOF'
name = "scratch-w3"
EOF
put "$(dir_of ecxc-ski)/wrangler.toml" <<EOF
name = "ecxc"
[env.production]
kv_namespaces = [{ binding = "ENVONLY", id = "$(kv 11)" }]
EOF
put "$(dir_of 907-life)/wrangler.jsonc" <<EOF
{ "name": "907-life", "kv_namespaces": [{ "binding": "JSONC", "id": "$(kv 12)" }],
  "routes": ["survivor.example.invalid/*", "*.wild.example.invalid/*"] }
EOF
put "$(dir_of aksailingclub-org)/.github/workflows/deploy.yml" <<'EOF'
jobs:
  d:
    steps:
      - run: npx wrangler deploy --name scratch-w3 --env production
EOF

# local-leg kinds: kit is a git repo with an unpushed branch, a stash, and a dirty file;
# jrnl-md an orphaned worktree; cairn-scratch-b a plain directory
k=$(dir_of kit)
if ! git -C "$k" rev-parse -q --verify refs/heads/feature-x >/dev/null; then
  commit "$k"
  git -C "$k" branch feature-x
  echo stashed >> "$k/README.md"; git -C "$k" stash push -q -m s1
  echo dirty > "$k/dirty.txt"
fi
j=$(dir_of jrnl-md); rm -rf "$j"; mkdir -p "$j"; echo "gitdir: $root/gone/.git/worktrees/jrnl-md" > "$j/.git"; echo n > "$j/notes.txt"
b=$(dir_of cairn-scratch-b); rm -rf "$b"; mkdir -p "$b/sub"; echo a > "$b/a.txt"; echo b > "$b/sub/b.txt"
touch -d '2026-01-02 03:04:05 UTC' "$b/a.txt" "$b/sub/b.txt"

# references, manifest entries, and a registry secret that point into targets
put "$(dir_of dubplate)/docs/notes.md" <<'EOF'
See ~/Projects/healthy-diet/README.md for the old diet notes.
EOF
if [[ -n ${SCOPE_CANARY_IN:-} ]]; then # under the scope harness: a reference whose path carries the canary
  echo "See ~/Projects/healthy-diet/README.md" > "$(dir_of dubplate)/docs/ref-$SCOPE_CANARY_IN.md"
fi
put "$(dir_of workstation)/bluefin/Brewfile" <<'EOF'
tap "glw907/kit"
EOF
put "$(dir_of workstation)/secrets/registry.md" <<'EOF'
# Registry

### PINGS_ADMIN_TOKEN
- **Grants**: the pings admin endpoints
- **Used by**: workstation scripts only (`~/Projects/pings/scripts/add-check`).
- **Rotate at**: re-run provisioning

---

### OTHER_NAME
- **Used by**: nothing here
EOF
for r in dubplate workstation pings aksailingclub-sveltekit aksailingclub-legacy cairn-scratch ecxc-ski 907-life aksailingclub-org; do
  [[ $r == kit ]] || commit "$(dir_of $r)"
done
mkdir -p "$root/.local"
{ printf 'export CLOUDFLARE_API_%s=%s\n' TOKEN "$(printf 'stub-%s' fixture)"; printf 'export CLOUDFLARE_ACCOUNT_ID=acct-fixture\n'; } > "$root/.local/secrets"
