#!/usr/bin/env bash
# teardown.sh: retire the old 907.life site (907-rebuild, T5, Geoff's P3 set point).
#
# With no argument it is a dry run: it re-reads every target by id, checks it still belongs
# only to the old site, and prints the delete list. Nothing changes.
# With --apply it runs the same list in order and stops at the first failure, except that a
# Builds registration that won't delete is reported and left. A target an earlier --apply
# removed is skipped, so a rerun resumes. Every run also writes its output to
# 907-rebuild/plans/teardown-<UTC time>.log for the observer.
#
# The order follows retire-project step 4: take traffic off first, then the Worker and its
# resources, then the repo. The spec's table ("The retirement") is the source; the packet's
# additions (the Turnstile widget, two unused build registrations, and the
# CLOUDFLARE_ACCOUNT_ID Actions secret) are marked below.
#
# Kept, never touched: the zone and every mail record, the Single Redirects, Email Sending,
# the shared cairn-build registration, the shared GitHub App, and ws-admin itself.
#
# Needs CLOUDFLARE_API_TOKEN (ws-admin) and CF_WS_CAIRN_GATE_TOKEN (Workers CI), both from
# ~/.local/secrets, and Geoff's gh sign-in.
set -euo pipefail

APPLY=0
case "${1:-}" in
    --apply) APPLY=1 ;;
    "") ;;
    *) echo "usage: teardown.sh [--apply]" >&2; exit 2 ;;
esac

# shellcheck source=/dev/null
source "$HOME/.local/secrets"
LOG=$(dirname "$(readlink -f "$0")")/../plans/teardown-$(date -u +%Y%m%dT%H%M%SZ).log
exec > >(tee "$LOG") 2>&1
: "${CLOUDFLARE_API_TOKEN:?CLOUDFLARE_API_TOKEN is not set}"
# ws-admin carries no Workers CI scope, so its trigger deletes fail. ws-cairn-gate does
# (cloudflare-estate-inventory.md), and the Builds steps use it.
: "${CF_WS_CAIRN_GATE_TOKEN:?CF_WS_CAIRN_GATE_TOKEN is not set}"

ACCOUNT=120c269ad6d3dfbe6d63a0bb53758ca0
CF=https://api.cloudflare.com/client/v4
WORKER=907-life
DOMAIN_ID=c377079217e7e9ca15d3ec295b6d8cef9e7e2b56   # 907.life -> 907-life
TRIGGERS=(ca2aff6d-32e0-4764-9369-4cc7ac1bacf9 cf2dc35f-2f20-405a-a64d-46b65cd918ce)
# Workers Builds registrations, by uuid. The first wraps ws-admin and backs only the two
# triggers; the next two are named "907-life build token" and back no trigger.
TRIGGER_REG=503cd3fe-a701-4d5e-be7b-4c93a61335fa
UNUSED_REGS=(567e83d8-9801-433d-9149-517d8993499a b8d55367-ef5d-4df6-b3b2-d8cdf8558ffe)
SHARED_REG=be3ea41e-e821-449b-80c4-03280a9e6d61     # cairn-build: must survive
D1_ID=93aa929d-0228-4f8b-8d1e-5e7e0d755617          # cairn-907-auth
BUCKET=907-life-media
WIDGET=0x4AAAAAACPc3bf8bl6ifC3c                     # Turnstile "907.life Contact Form"
REPO=glw907/907-life
LEGACY=907-life-legacy
CHECKOUT=/var/home/glw907/Projects/907-life

die() { echo "teardown: STOP: $*" >&2; exit 1; }

# cf METHOD PATH: one Cloudflare API call; prints the JSON body and fails on success=false.
# A /builds/ path uses the Workers CI token.
cf() {
    local body tok=$CLOUDFLARE_API_TOKEN
    [[ "$2" != */builds/* ]] || tok=$CF_WS_CAIRN_GATE_TOKEN
    body=$(curl -sS -X "$1" -H "Authorization: Bearer $tok" "$CF$2")
    if [[ "$(jq -r '.success' <<<"$body")" != "true" ]]; then
        echo "$body" >&2
        return 1
    fi
    printf '%s\n' "$body"
}

step=0
failed=()
# run LABEL CMD...: print the step; under --apply, run it and stop on failure.
run() {
    local label=$1; shift
    step=$((step + 1))
    if (( APPLY )); then
        echo "[$step] $label"
        "$@" >/dev/null || die "step $step failed: $label"
        echo "    done"
    else
        echo "[$step] would: $label"
    fi
}
# soft LABEL CMD...: like run, but a failure is recorded and the teardown goes on. Used only
# for the Builds registrations: each wraps a token that stays live, so a leftover revokes nothing.
soft() {
    local label=$1; shift
    step=$((step + 1))
    if (( APPLY )); then
        echo "[$step] $label"
        if "$@" >/dev/null; then echo "    done"; else echo "    FAILED, going on"; failed+=("$label"); fi
    else
        echo "[$step] would: $label"
    fi
}
# gone LABEL: a target an earlier run already removed.
gone() { step=$((step + 1)); echo "[$step] already gone: $1"; }
quiet() { cf "$@" 2>/dev/null; }

echo "== Re-reading the inventory ($(date -u +%FT%TZ))"
# Each target is re-read by id. One an earlier --apply removed is skipped, so the script resumes.

# https://developers.cloudflare.com/api/resources/workers/subresources/domains/methods/get/
if d=$(quiet GET "/accounts/$ACCOUNT/workers/domains/$DOMAIN_ID"); then
    svc=$(jq -r '.result.hostname + " -> " + .result.service' <<<"$d")
    [[ "$svc" == "907.life -> $WORKER" ]] || die "custom domain $DOMAIN_ID is '$svc'"
    echo "custom domain $DOMAIN_ID: $svc"; HAVE_DOMAIN=1
else echo "custom domain $DOMAIN_ID: gone"; HAVE_DOMAIN=0; fi

# https://developers.cloudflare.com/api/resources/workers/subresources/scripts/methods/list/
scripts=$(cf GET "/accounts/$ACCOUNT/workers/scripts")
tag=$(jq -r --arg w "$WORKER" '.result[] | select(.id==$w) | .tag' <<<"$scripts")
if [[ -n "$tag" ]]; then echo "Worker $WORKER: tag $tag"; else echo "Worker $WORKER: gone"; fi

# https://developers.cloudflare.com/workers/ci-cd/builds/api-reference/
reg_users() {  # prints "<worker> <trigger>" for every trigger on the account using registration $1
    jq -r '.result[] | "\(.id) \(.tag)"' <<<"$scripts" | while read -r name t; do
        cf GET "/accounts/$ACCOUNT/builds/workers/$t/triggers" |
            jq -r --arg n "$name" --arg k "$1" '.result[]? | select(.build_token_uuid==$k) | "\($n) \(.trigger_uuid)"'
    done
}
mine=""
[[ -z "$tag" ]] || mine=$(cf GET "/accounts/$ACCOUNT/builds/workers/$tag/triggers" | jq -r '.result[].trigger_uuid' | sort)
for t in $mine; do
    printf '%s\n' "${TRIGGERS[@]}" | grep -qx "$t" || die "the Worker has a new trigger $t"
done
echo "triggers left: ${mine:-none}"
users=$(reg_users "$TRIGGER_REG" | awk '{print $1}' | sort -u)
[[ -z "$users" || "$users" == "$WORKER" ]] || die "registration $TRIGGER_REG is used by: $users"
for r in "${UNUSED_REGS[@]}"; do
    [[ -z "$(reg_users "$r")" ]] || die "registration $r now backs a trigger"
done
regs=$(cf GET "/accounts/$ACCOUNT/builds/tokens")
has_reg() { jq -e --arg r "$1" '.result[] | select(.build_token_uuid==$r)' <<<"$regs" >/dev/null; }
for r in "$TRIGGER_REG" "${UNUSED_REGS[@]}"; do
    if has_reg "$r"; then echo "registration $r: '$(jq -r --arg r "$r" '.result[] | select(.build_token_uuid==$r) | .build_token_name' <<<"$regs")'"
    else echo "registration $r: gone"; fi
done
has_reg "$SHARED_REG" || die "the shared cairn-build registration is missing"

# https://developers.cloudflare.com/api/resources/d1/subresources/database/methods/get/
if d=$(quiet GET "/accounts/$ACCOUNT/d1/database/$D1_ID"); then
    [[ "$(jq -r '.result.name' <<<"$d")" == "cairn-907-auth" ]] || die "D1 $D1_ID was renamed"
    echo "D1 $D1_ID: cairn-907-auth"; HAVE_D1=1
else echo "D1 $D1_ID: gone"; HAVE_D1=0; fi

# https://developers.cloudflare.com/api/resources/r2/subresources/buckets/subresources/objects/
keys=""
if o=$(quiet GET "/accounts/$ACCOUNT/r2/buckets/$BUCKET/objects"); then
    keys=$(jq -r '.result[]?.key' <<<"$o"); HAVE_BUCKET=1
    echo "R2 $BUCKET: $(grep -c . <<<"$keys" || true) objects"
else echo "R2 $BUCKET: gone"; HAVE_BUCKET=0; fi

# https://developers.cloudflare.com/api/resources/turnstile/subresources/widgets/methods/get/
if w=$(quiet GET "/accounts/$ACCOUNT/challenges/widgets/$WIDGET"); then
    tw=$(jq -r '.result.name + " " + (.result.domains|join(","))' <<<"$w")
    [[ "$tw" == "907.life Contact Form 907.life,localhost" ]] || die "Turnstile $WIDGET is '$tw'"
    echo "Turnstile $WIDGET: $tw"; HAVE_WIDGET=1
else echo "Turnstile $WIDGET: gone"; HAVE_WIDGET=0; fi

# The repo is either still glw907/907-life, or already glw907/907-life-legacy.
if repo=$(gh api "repos/$REPO" --jq '.full_name + " archived=" + (.archived|tostring)' 2>/dev/null) &&
   [[ "$repo" == "$REPO archived=false" ]]; then
    gh api "repos/glw907/$LEGACY" >/dev/null 2>&1 && die "glw907/$LEGACY already exists"
    HAVE_REPO=1; HOLDER=$REPO
elif repo=$(gh api "repos/glw907/$LEGACY" --jq '.full_name + " archived=" + (.archived|tostring)' 2>/dev/null); then
    HAVE_REPO=0; HOLDER=glw907/$LEGACY
else die "neither $REPO nor glw907/$LEGACY is readable"; fi
secrets=$(gh api "repos/$HOLDER/actions/secrets" --jq '[.secrets[].name] | sort | join(" ")')
echo "repo $repo; Actions secrets: ${secrets:-none}"
has_secret() { [[ " $secrets " == *" $1 "* ]]; }

echo
if (( APPLY )); then echo "== Applying"; else echo "== Dry run (nothing changes; rerun with --apply)"; fi

# 1. Take traffic off. This opens the mail-discovery redirect gap until setup's attach.
# https://developers.cloudflare.com/api/resources/workers/subresources/domains/methods/delete/
if (( HAVE_DOMAIN )); then
    run "detach custom domain 907.life ($DOMAIN_ID) from Worker $WORKER" \
        cf DELETE "/accounts/$ACCOUNT/workers/domains/$DOMAIN_ID"
    if (( APPLY )); then echo "    redirect gap opened at $(date -u +%FT%TZ)"; fi
else gone "custom domain $DOMAIN_ID"; fi

# 2. Builds triggers, then the registrations nothing uses any more.
# https://developers.cloudflare.com/workers/ci-cd/builds/api-reference/
for t in "${TRIGGERS[@]}"; do
    if grep -qx "$t" <<<"$mine"; then
        run "delete Workers Builds trigger $t" cf DELETE "/accounts/$ACCOUNT/builds/triggers/$t"
    else gone "Workers Builds trigger $t"; fi
done
if has_reg "$TRIGGER_REG"; then
    soft "delete Builds registration $TRIGGER_REG (wraps ws-admin; ws-admin itself stays)" \
        cf DELETE "/accounts/$ACCOUNT/builds/tokens/$TRIGGER_REG"
else gone "Builds registration $TRIGGER_REG"; fi
for r in "${UNUSED_REGS[@]}"; do   # packet addition
    if has_reg "$r"; then
        soft "delete unused Builds registration $r ('907-life build token')" \
            cf DELETE "/accounts/$ACCOUNT/builds/tokens/$r"
    else gone "Builds registration $r"; fi
done

# 3. The Worker.
# https://developers.cloudflare.com/api/resources/workers/subresources/scripts/methods/delete/
if [[ -n "$tag" ]]; then
    run "delete Worker $WORKER" cf DELETE "/accounts/$ACCOUNT/workers/scripts/$WORKER"
else gone "Worker $WORKER"; fi

# 4. Turnstile (packet addition), R2 objects by key then the bucket, then D1.
if (( HAVE_WIDGET )); then
    run "delete Turnstile widget $WIDGET (907.life Contact Form)" \
        cf DELETE "/accounts/$ACCOUNT/challenges/widgets/$WIDGET"
else gone "Turnstile widget $WIDGET"; fi
# "To delete an R2 bucket, it must be completely empty."
# https://developers.cloudflare.com/r2/reference/consistency/
while read -r k; do
    [[ -n "$k" ]] || continue
    run "delete R2 object $BUCKET/$k" npx wrangler r2 object delete "$BUCKET/$k" --remote
done <<<"$keys"
# https://developers.cloudflare.com/api/resources/r2/subresources/buckets/methods/delete/
if (( HAVE_BUCKET )); then
    run "delete R2 bucket $BUCKET" cf DELETE "/accounts/$ACCOUNT/r2/buckets/$BUCKET"
else gone "R2 bucket $BUCKET"; fi
# https://developers.cloudflare.com/api/resources/d1/subresources/database/methods/delete/
if (( HAVE_D1 )); then
    run "delete D1 cairn-907-auth ($D1_ID)" cf DELETE "/accounts/$ACCOUNT/d1/database/$D1_ID"
else gone "D1 cairn-907-auth ($D1_ID)"; fi

# 5. The repo: Actions secrets, then the rename, then the archive.
# https://docs.github.com/rest/actions/secrets#delete-a-repository-secret
for sname in CLOUDFLARE_API_TOKEN CLOUDFLARE_ACCOUNT_ID; do
    if has_secret "$sname"; then
        run "delete Actions secret $sname on $HOLDER" gh api -X DELETE "repos/$HOLDER/actions/secrets/$sname"
    else gone "Actions secret $sname"; fi
done
# https://docs.github.com/rest/repos/repos#update-a-repository
if (( HAVE_REPO )); then
    run "rename $REPO to glw907/$LEGACY" gh api -X PATCH "repos/$REPO" -f name="$LEGACY"
else gone "rename to glw907/$LEGACY"; fi
if [[ "$repo" != *"archived=true" ]]; then
    run "archive glw907/$LEGACY" gh api -X PATCH "repos/glw907/$LEGACY" -F archived=true
else gone "archive of glw907/$LEGACY"; fi
run "point the old checkout's origin at glw907/$LEGACY" \
    git -C "$CHECKOUT" remote set-url origin "https://github.com/glw907/$LEGACY.git"

echo
if (( APPLY )); then
    for f in "${failed[@]}"; do echo "== left in place: $f"; done
    echo "== Teardown finished at $(date -u +%FT%TZ). Tell the observer."
else
    echo "== $step steps. Compare them with the packet, then run: bash $0 --apply"
fi
