#!/usr/bin/env bash
# setup-tooling-owner-steps.sh: the four owner steps before the first tool tag
# (cairn-cms .claude/skills/cairn-releasing/SKILL.md, "The launcher and its platform packages").
#
# Geoff runs it in a Ptyxis terminal, because steps 3 and 4 need his npm login and npm asks for a
# one-time password only when stdin and stdout are both a terminal (npm lib/utils/auth.js,
# otplease). So no npm call that can ask runs inside $(...) or a pipe: stdout stays the terminal,
# and the trust reads, which every need 2FA (npm help trust), run on a pty through script(1) with
# their output read back from its log. Take npm's "skip two-factor authentication for the next 5
# minutes" option at the first prompt. Only this script's own [n] lines go to the run log.
#
# With no argument it is a dry run: it reads each step's state and prints what --apply would do.
# Nothing changes. With --apply it runs each step that is not already done, in order, and stops at
# the first failure. A step already done is skipped, so a rerun resumes. Each run's [n] lines go to
# ~/.local/state/cairn-setup/owner-steps-<UTC time>.log for the conductor to read.
#
#   1. Allow tool/v* tags in the npm-publish environment.
#   2. Add refs/tags/tool/v* to the release-tags ruleset.
#   3. Publish the six platform packages once by hand from a dispatch run's npm-tarballs artifact
#      on main, then bind each package and create-cairn-site to tool.yml's trusted publisher,
#      revoking create-cairn-site's publish.yml binding first (npm allows one per package).
#   4. Remove the wizard's next dist-tag. With --deprecate (a yes to the plan's Decide S-7), also
#      deprecate create-cairn-site below 1.0.0, which no 2.0 gate candidate falls under; without it
#      the deprecation waits for the stable tool cut.
#
# Needs Geoff's gh sign-in (repo admin) and, for steps 3 and 4, `npm login` as glw907 first. When a
# dry run prints no "would" line, run `npm logout` so no publish-capable token stays in ~/.npmrc.
set -euo pipefail

APPLY=0
DEPRECATE=0
for arg in "$@"; do
  case "$arg" in
    --apply) APPLY=1 ;;
    --deprecate) DEPRECATE=1 ;;
    *) echo "usage: setup-tooling-owner-steps.sh [--apply] [--deprecate]" >&2; exit 2 ;;
  esac
done

REPO=glw907/cairn-cms
ENV=npm-publish
RULESET=26779320 # release-tags
TARGETS=(darwin-arm64 darwin-x64 linux-arm64 linux-x64 win32-arm64 win32-x64)
DEPRECATION="Retired: this wizard writes secrets to disk. Its replacement is create-cairn-site 2.0; see https://github.com/glw907/cairn-cms."
STATE=$HOME/.local/state/cairn-setup
mkdir -p "$STATE"
LOG=$STATE/owner-steps-$(date -u +%Y%m%dT%H%M%SZ).log
: >"$LOG"

say() { printf '[%s] %s\n' "$1" "$2" | tee -a "$LOG"; }
die() { printf 'owner-steps: STOP: %s\n' "$*" | tee -a "$LOG" >&2; exit 1; }

# Runs `npm trust list <pkg> --json` on a pty, so npm sees a terminal and can ask for 2FA, and prints
# the JSON objects it wrote (each begins with "{" and ends with "}" at column 0) from script's log.
# The log also holds the start line and any prompt text, which the sed range leaves out.
trust_json() {
  local out
  out=$(mktemp "$STATE/trust-XXXXXX")
  # script's own stdin and stdout are the terminal, so Geoff sees and answers any prompt even
  # though the caller redirects this function's output.
  script -q -e --log-out "$out" -c "$(printf '%q ' npm trust list "$1" --json)" </dev/tty >/dev/tty \
    || { rm -f "$out"; return 1; }
  # Replay the pty's cursor moves first. npm draws a spinner and then ESC[1G ESC[0K (column 1,
  # clear the line) on the same line as the opening brace, so drop each line up to its last
  # ESC[1G, then strip the control sequences left, before reading the column-0 brace blocks.
  tr -d '\r' <"$out" | sed 's/.*\x1b\[1G//; s/\x1b\[[0-9;?]*[A-Za-z]//g; s/\x1b\][^\x07]*\x07//g' | sed -n '/^{/,/^}/p'
  rm -f "$out"
}

say - "log: $LOG"
if (( APPLY )); then say - "mode: apply"; else say - "mode: dry run (nothing changes)"; fi

# 1. The environment's tag policy.
# https://docs.github.com/en/rest/deployments/branch-policies
policies=$(gh api "repos/$REPO/environments/$ENV/deployment-branch-policies" \
  --jq '.branch_policies[] | select(.type == "tag") | .name') || die "step 1: reading the policies failed"
if grep -qx 'tool/v\*' <<<"$policies"; then
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
rules=$(gh api "repos/$REPO/rulesets/$RULESET") || die "step 2: reading the ruleset failed"
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

# Steps 3 and 4 need the npm login, in a dry run too: npm trust list answers E401 without it.
npm whoami >/dev/null 2>&1 || die "steps 3 and 4 need npm's login: run npm login as glw907, then rerun"

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
    # A rerun after a partial publish reuses the last downloaded run, so all six first versions
    # come from one commit.
    work=""
    for dir in "$STATE"/tarballs-*; do
      [[ -f $dir/run-id ]] && work=$dir
    done
    if [[ -n $work ]]; then
      run=$(cat "$work/run-id")
      say 3 "reusing run $run's tarballs in $work"
    else
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
      printf '%s\n' "$run" >"$work/run-id"
    fi
    for t in "${missing[@]}"; do
      tgz=$(compgen -G "$work/glw907-cairn-$t-*.tgz" | head -1) || true
      [[ -n $tgz ]] || die "step 3: run $run has no tarball for $t"
      gh attestation verify "$tgz" --repo "$REPO" --source-ref refs/heads/main >/dev/null \
        || die "step 3: $tgz failed attestation"
      # npm refuses a prerelease version without --tag. A package's first publish also points
      # latest at it, which nothing reads: the launcher pins each platform package to its own
      # exact version (scripts/release/pack-platforms.mjs, optionalDependencies).
      npm publish "$tgz" --access public --tag gate || die "step 3: publishing $tgz failed"
      say 3 "published $(basename "$tgz") to gate"
    done
  else
    say 3 "would dispatch tool.yml on main, verify each tarball's attestation, and publish: ${missing[*]}"
  fi
fi
for pkg in "${TARGETS[@]/#/@glw907/cairn-}" create-cairn-site; do
  # The owner's package list, not npm view: a first publish can stay 404 on the public registry
  # for a while after npm has the package. npm access get status cannot serve either, since it
  # prints "private" for a name that does not exist.
  if ! npm access list packages glw907 --json 2>/dev/null | jq -e --arg p "$pkg" 'has($p)' >/dev/null; then
    say 3 "would bind $pkg to $REPO tool.yml in $ENV once it is published"
    continue
  fi
  # npm trust list --json prints one object per binding: id, type, file, repository, environment
  # (npm lib/commands/trust/github.js, bodyToOptions). The read itself runs on a pty (trust_json).
  trust_json "$pkg" >"$STATE/trusts.json" \
    || die "step 3: npm trust list $pkg failed; on EOTP, rerun and take the 5-minute skip"
  # Keep only binding objects; anything else in the recording is not a binding.
  trusts=$(jq -c 'select(type == "object" and has("id") and has("repository") and has("file"))' "$STATE/trusts.json") \
    || die "step 3: npm trust list $pkg printed output this script cannot read; run it by hand and check"
  rm -f "$STATE/trusts.json"
  # shellcheck disable=SC2016 # $repo is a jq variable, not a shell one
  keep='.repository == $repo and .file == "tool.yml"'
  bound=$(jq -rs --arg repo "$REPO" "[.[] | select($keep)] | length" <<<"$trusts")
  others=$(jq -rs --arg repo "$REPO" "[.[] | select(($keep) | not) | \"\(.id) \(.repository) \(.file)\"] | join(\"; \")" <<<"$trusts")
  if (( bound > 0 )); then
    say 3 "done: $pkg trusts $REPO tool.yml"
  elif (( APPLY )); then
    for id in $(jq -rs --arg repo "$REPO" ".[] | select(($keep) | not) | .id" <<<"$trusts"); do
      npm trust revoke "$pkg" --id="$id" || die "step 3: revoking $pkg's binding $id failed"
      say 3 "revoked $pkg's binding $id"
    done
    npm trust github "$pkg" --repo "$REPO" --file tool.yml --env "$ENV" --allow-publish --yes \
      || die "step 3: binding $pkg failed; npm trust list $pkg shows its current publishers"
    say 3 "bound $pkg to $REPO tool.yml in $ENV"
  elif [[ -n $others ]]; then
    say 3 "would revoke $pkg's binding ($others), then bind it to $REPO tool.yml in $ENV"
  else
    say 3 "would bind $pkg to $REPO tool.yml in $ENV"
  fi
done

# 4. Retire the wizard's dist-tags.
next=$(npm view create-cairn-site dist-tags.next) || die "step 4: reading create-cairn-site's dist-tags failed"
if [[ -z $next ]]; then
  say 4 "done: create-cairn-site has no next tag"
elif (( APPLY )); then
  npm dist-tag rm create-cairn-site next || die "step 4: removing next failed"
  say 4 "removed create-cairn-site@next (was $next)"
else
  say 4 "would remove create-cairn-site@next (now $next)"
fi
if (( DEPRECATE )); then
  dep=$(npm view create-cairn-site@0.99.0-rc.4 deprecated) || die "step 4: reading the deprecation failed"
  if [[ -n $dep ]]; then
    say 4 "done: create-cairn-site below 1.0.0 is deprecated"
  elif (( APPLY )); then
    npm deprecate 'create-cairn-site@<1.0.0' "$DEPRECATION" || die "step 4: deprecate failed"
    say 4 "deprecated create-cairn-site@<1.0.0"
  else
    say 4 "would deprecate create-cairn-site@<1.0.0: $DEPRECATION"
  fi
else
  say 4 "skip: deprecating create-cairn-site below 1.0.0 waits for the stable tool cut (a no to Decide S-7)"
fi

if (( APPLY )); then
  say - "finished (apply); now run it again with no argument to confirm"
elif grep -q '^\[[0-9]\] would' "$LOG"; then
  say - "finished (dry run); the would lines above are pending"
else
  say - "finished (dry run); every step is done: now run npm logout"
fi
