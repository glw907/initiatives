#!/usr/bin/env bash
# setup-tooling-owner-steps.sh: the four owner steps before the first tool tag
# (cairn-cms .claude/skills/cairn-releasing/SKILL.md, "The launcher and its platform packages").
#
# Geoff runs it in a Ptyxis terminal, because steps 3 and 4 need his npm login. With no argument
# it is a dry run: it reads each step's current state and prints what --apply would do. Nothing
# changes. With --apply it runs each step that is not already done, in order, and stops at the
# first failure. A step already done is skipped, so a rerun resumes. Every run writes its output
# to ~/.local/state/cairn-setup/owner-steps-<UTC time>.log for the conductor to read.
#
#   1. Allow tool/v* tags in the npm-publish environment.
#   2. Add refs/tags/tool/v* to the release-tags ruleset.
#   3. Publish the six platform packages once by hand from a dispatch run's npm-tarballs artifact
#      on main, then bind each package and create-cairn-site to tool.yml's trusted publisher.
#   4. Retire the wizard's next dist-tag and deprecate create-cairn-site below 1.0.0.
#
# Needs Geoff's gh sign-in (repo admin) and, for steps 3 and 4, `npm login` as glw907 first.
set -euo pipefail

APPLY=0
case "${1:-}" in
  --apply) APPLY=1 ;;
  "") ;;
  *) echo "usage: setup-tooling-owner-steps.sh [--apply]" >&2; exit 2 ;;
esac

REPO=glw907/cairn-cms
ENV=npm-publish
RULESET=26779320 # release-tags
TARGETS=(darwin-arm64 darwin-x64 linux-arm64 linux-x64 win32-arm64 win32-x64)
DEPRECATION="Retired: use the latest version, which installs the cairn tool."
STATE=$HOME/.local/state/cairn-setup
mkdir -p "$STATE"
LOG=$STATE/owner-steps-$(date -u +%Y%m%dT%H%M%SZ).log
exec > >(tee "$LOG") 2>&1
echo "log: $LOG"
(( APPLY )) && echo "mode: apply" || echo "mode: dry run (nothing changes)"

die() { echo "owner-steps: STOP: $*" >&2; exit 1; }
say() { echo "[$1] $2"; }

# 1. The environment's tag policy.
# https://docs.github.com/en/rest/deployments/branch-policies
if gh api "repos/$REPO/environments/$ENV/deployment-branch-policies" \
    --jq '.branch_policies[] | select(.type == "tag") | .name' | grep -qx 'tool/v\*'; then
  say 1 "done: $ENV already allows tool/v* tags"
elif (( APPLY )); then
  gh api -X POST "repos/$REPO/environments/$ENV/deployment-branch-policies" \
    -f name='tool/v*' -f type=tag >/dev/null || die "step 1: the tag policy was refused"
  say 1 "added the tool/v* tag policy to $ENV"
else
  say 1 "would add a tag policy tool/v* to $ENV (never *)"
fi

# 2. The tag ruleset.
# https://docs.github.com/en/rest/repos/rules
rules=$(gh api "repos/$REPO/rulesets/$RULESET")
if jq -e '.conditions.ref_name.include | index("refs/tags/tool/v*")' <<<"$rules" >/dev/null; then
  say 2 "done: release-tags already covers refs/tags/tool/v*"
elif (( APPLY )); then
  jq '{name, target, enforcement, rules, bypass_actors,
       conditions: (.conditions | .ref_name.include += ["refs/tags/tool/v*"])}' <<<"$rules" \
    | gh api -X PUT "repos/$REPO/rulesets/$RULESET" --input - >/dev/null \
    || die "step 2: the ruleset update was refused"
  say 2 "added refs/tags/tool/v* to release-tags"
else
  say 2 "would add refs/tags/tool/v* to release-tags (update and deletion rules stay as they are)"
fi

# Steps 3 and 4 need the npm login.
if ! npm whoami >/dev/null 2>&1; then
  if (( APPLY )); then
    die "steps 3 and 4 need npm's login: run npm login as glw907, then rerun with --apply"
  fi
  say 3 "npm is not signed in here; --apply needs npm login as glw907 first"
fi

# 3. First publish of the six platform packages, then the trusted publishers.
missing=()
for t in "${TARGETS[@]}"; do
  if npm view "@glw907/cairn-$t" name >/dev/null 2>&1; then
    say 3 "done: @glw907/cairn-$t exists on the registry"
  else
    missing+=("$t")
  fi
done
if (( ${#missing[@]} )); then
  if (( APPLY )); then
    work=$(mktemp -d "$STATE/tarballs-XXXXXX")
    before=$(gh run list -R "$REPO" --workflow tool.yml --event workflow_dispatch --limit 1 --json databaseId --jq '.[0].databaseId // 0')
    gh workflow run tool.yml -R "$REPO" --ref main
    say 3 "dispatched tool.yml on main; waiting for the run to appear"
    run=$before
    for _ in $(seq 60); do
      run=$(gh run list -R "$REPO" --workflow tool.yml --event workflow_dispatch --limit 1 --json databaseId --jq '.[0].databaseId // 0')
      [[ $run != "$before" ]] && break
      sleep 5
    done
    [[ $run != "$before" ]] || die "step 3: no dispatch run appeared"
    gh run watch "$run" -R "$REPO" --exit-status >/dev/null || die "step 3: dispatch run $run failed"
    gh run download "$run" -R "$REPO" -n npm-tarballs -D "$work"
    for t in "${missing[@]}"; do
      tgz=$(compgen -G "$work/glw907-cairn-$t-*.tgz" | head -1) || true
      [[ -n $tgz ]] || die "step 3: run $run has no tarball for $t"
      gh attestation verify "$tgz" --repo "$REPO" --source-ref refs/heads/main >/dev/null \
        || die "step 3: $tgz failed attestation"
      # npm refuses a prerelease version without --tag; gate is the tag no install reads.
      npm publish "$tgz" --access public --tag gate || die "step 3: publishing $tgz failed"
      say 3 "published $(basename "$tgz") to gate"
    done
  else
    say 3 "would dispatch tool.yml on main, verify each tarball's attestation, and publish: ${missing[*]}"
  fi
fi
for pkg in "${TARGETS[@]/#/@glw907/cairn-}" create-cairn-site; do
  trusts=$(npm trust list "$pkg" 2>/dev/null || true)
  if grep -q 'tool.yml' <<<"$trusts"; then
    say 3 "done: $pkg trusts tool.yml"
  elif (( APPLY )); then
    npm trust github "$pkg" --repo "$REPO" --file tool.yml --env "$ENV" --allow-publish --yes \
      || die "step 3: binding $pkg failed; npm trust list $pkg shows its current publishers"
    say 3 "bound $pkg to tool.yml in $ENV"
  else
    say 3 "would bind $pkg to tool.yml in $ENV"
  fi
done

# 4. Retire the wizard's dist-tags.
next=$(npm view create-cairn-site dist-tags.next 2>/dev/null || true)
if [[ -z $next ]]; then
  say 4 "done: create-cairn-site has no next tag"
elif (( APPLY )); then
  npm dist-tag rm create-cairn-site next || die "step 4: removing next failed"
  say 4 "removed create-cairn-site@next (was $next)"
else
  say 4 "would remove create-cairn-site@next (now $next)"
fi
dep=$(npm view create-cairn-site@0.99.0-rc.4 deprecated 2>/dev/null || true)
if [[ -n $dep ]]; then
  say 4 "done: create-cairn-site below 1.0.0 is deprecated"
elif (( APPLY )); then
  npm deprecate 'create-cairn-site@<1.0.0' "$DEPRECATION" || die "step 4: deprecate failed"
  say 4 "deprecated create-cairn-site@<1.0.0"
else
  say 4 "would deprecate create-cairn-site@<1.0.0: $DEPRECATION"
fi

echo "owner-steps: finished ($( (( APPLY )) && echo apply || echo dry run))"
