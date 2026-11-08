#!/usr/bin/env bash
# teardown.sh: retire the old 907.life site (907-rebuild, T5, Geoff's P3 set point).
#
# With no argument it is a dry run: it re-reads every target by id, checks it still belongs
# only to the old site, and prints the delete list. Nothing changes.
# With --apply it runs the same list in order and stops at the first failure.
#
# The order follows retire-project step 4: take traffic off first, then the Worker and its
# resources, then the repo. The spec's table ("The retirement") is the source; the packet's
# additions (the Turnstile widget, two unused build registrations, and the
# CLOUDFLARE_ACCOUNT_ID Actions secret) are marked below.
#
# Kept, never touched: the zone and every mail record, the Single Redirects, Email Sending,
# the shared cairn-build registration, the shared GitHub App, and ws-admin itself.
#
# Needs CLOUDFLARE_API_TOKEN (ws-admin, from ~/.local/secrets) and Geoff's gh sign-in.
set -euo pipefail

APPLY=0
case "${1:-}" in
    --apply) APPLY=1 ;;
    "") ;;
    *) echo "usage: teardown.sh [--apply]" >&2; exit 2 ;;
esac

# shellcheck source=/dev/null
source "$HOME/.local/secrets"
: "${CLOUDFLARE_API_TOKEN:?CLOUDFLARE_API_TOKEN is not set}"

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
cf() {
    local body
    body=$(curl -sS -X "$1" -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" "$CF$2")
    if [[ "$(jq -r '.success' <<<"$body")" != "true" ]]; then
        echo "$body" >&2
        return 1
    fi
    printf '%s\n' "$body"
}

step=0
# run LABEL CMD...: print the step; under --apply, run it.
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

echo "== Re-reading the inventory ($(date -u +%FT%TZ))"

# The custom domain still points at the old Worker.
# https://developers.cloudflare.com/api/resources/workers/subresources/domains/methods/get/
svc=$(cf GET "/accounts/$ACCOUNT/workers/domains/$DOMAIN_ID" | jq -r '.result.hostname + " -> " + .result.service')
[[ "$svc" == "907.life -> $WORKER" ]] || die "custom domain $DOMAIN_ID is '$svc'"
echo "custom domain $DOMAIN_ID: $svc"

# https://developers.cloudflare.com/api/resources/workers/subresources/scripts/methods/list/
scripts=$(cf GET "/accounts/$ACCOUNT/workers/scripts")
tag=$(jq -r --arg w "$WORKER" '.result[] | select(.id==$w) | .tag' <<<"$scripts")
[[ -n "$tag" ]] || die "Worker $WORKER not found"
echo "Worker $WORKER: tag $tag"

# https://developers.cloudflare.com/workers/ci-cd/builds/api-reference/
reg_users() {  # prints "<worker> <trigger>" for every trigger on the account using registration $1
    jq -r '.result[] | "\(.id) \(.tag)"' <<<"$scripts" | while read -r name t; do
        cf GET "/accounts/$ACCOUNT/builds/workers/$t/triggers" |
            jq -r --arg n "$name" --arg k "$1" '.result[]? | select(.build_token_uuid==$k) | "\($n) \(.trigger_uuid)"'
    done
}
mine=$(cf GET "/accounts/$ACCOUNT/builds/workers/$tag/triggers" | jq -r '.result[].trigger_uuid' | sort)
[[ "$mine" == "$(printf '%s\n' "${TRIGGERS[@]}" | sort)" ]] || die "the Worker's triggers changed: $mine"
echo "triggers: ${TRIGGERS[*]}"
users=$(reg_users "$TRIGGER_REG" | awk '{print $1}' | sort -u)
[[ "$users" == "$WORKER" ]] || die "registration $TRIGGER_REG is used by: $users"
echo "registration $TRIGGER_REG: used only by $WORKER"
for r in "${UNUSED_REGS[@]}"; do
    [[ -z "$(reg_users "$r")" ]] || die "registration $r now backs a trigger"
done
regs=$(cf GET "/accounts/$ACCOUNT/builds/tokens")
for r in "$TRIGGER_REG" "${UNUSED_REGS[@]}"; do
    n=$(jq -r --arg r "$r" '.result[] | select(.build_token_uuid==$r) | .build_token_name' <<<"$regs")
    [[ -n "$n" ]] || die "registration $r not found"
    echo "registration $r: '$n'"
done
jq -e --arg r "$SHARED_REG" '.result[] | select(.build_token_uuid==$r)' <<<"$regs" >/dev/null ||
    die "the shared cairn-build registration is missing before the teardown"

# https://developers.cloudflare.com/api/resources/d1/subresources/database/methods/get/
d1=$(cf GET "/accounts/$ACCOUNT/d1/database/$D1_ID" | jq -r '.result.name')
[[ "$d1" == "cairn-907-auth" ]] || die "D1 $D1_ID is '$d1'"
echo "D1 $D1_ID: $d1"

# https://developers.cloudflare.com/api/resources/r2/subresources/buckets/subresources/objects/
keys=$(cf GET "/accounts/$ACCOUNT/r2/buckets/$BUCKET/objects" | jq -r '.result[]?.key')
echo "R2 $BUCKET: $(grep -c . <<<"$keys" || true) objects"

# https://developers.cloudflare.com/api/resources/turnstile/subresources/widgets/methods/get/
tw=$(cf GET "/accounts/$ACCOUNT/challenges/widgets/$WIDGET" | jq -r '.result.name + " " + (.result.domains|join(","))')
[[ "$tw" == "907.life Contact Form 907.life,localhost" ]] || die "Turnstile $WIDGET is '$tw'"
echo "Turnstile $WIDGET: $tw"

repo=$(gh api "repos/$REPO" --jq '.full_name + " archived=" + (.archived|tostring)')
[[ "$repo" == "$REPO archived=false" ]] || die "repo is '$repo'"
gh api "repos/glw907/$LEGACY" >/dev/null 2>&1 && die "glw907/$LEGACY already exists"
names=$(gh api "repos/$REPO/actions/secrets" --jq '[.secrets[].name] | sort | join(" ")')
[[ "$names" == "CLOUDFLARE_ACCOUNT_ID CLOUDFLARE_API_TOKEN" ]] || die "Actions secrets are '$names'"
echo "repo $repo; Actions secrets: $names"

echo
if (( APPLY )); then echo "== Applying"; else echo "== Dry run (nothing changes; rerun with --apply)"; fi

# 1. Take traffic off. This opens the mail-discovery redirect gap until setup's attach.
# https://developers.cloudflare.com/api/resources/workers/subresources/domains/methods/delete/
run "detach custom domain 907.life ($DOMAIN_ID) from Worker $WORKER" \
    cf DELETE "/accounts/$ACCOUNT/workers/domains/$DOMAIN_ID"
if (( APPLY )); then echo "    redirect gap opened at $(date -u +%FT%TZ)"; fi

# 2. Builds triggers, then the registrations nothing uses any more.
# https://developers.cloudflare.com/workers/ci-cd/builds/api-reference/
for t in "${TRIGGERS[@]}"; do
    run "delete Workers Builds trigger $t" cf DELETE "/accounts/$ACCOUNT/builds/triggers/$t"
done
run "delete Builds registration $TRIGGER_REG (wraps ws-admin; ws-admin itself stays)" \
    cf DELETE "/accounts/$ACCOUNT/builds/tokens/$TRIGGER_REG"
for r in "${UNUSED_REGS[@]}"; do   # packet addition
    run "delete unused Builds registration $r ('907-life build token')" \
        cf DELETE "/accounts/$ACCOUNT/builds/tokens/$r"
done

# 3. The Worker.
# https://developers.cloudflare.com/api/resources/workers/subresources/scripts/methods/delete/
run "delete Worker $WORKER" cf DELETE "/accounts/$ACCOUNT/workers/scripts/$WORKER"

# 4. Turnstile (packet addition), R2 objects by key then the bucket, then D1.
run "delete Turnstile widget $WIDGET (907.life Contact Form)" \
    cf DELETE "/accounts/$ACCOUNT/challenges/widgets/$WIDGET"
# "To delete an R2 bucket, it must be completely empty."
# https://developers.cloudflare.com/r2/reference/consistency/
while read -r k; do
    [[ -n "$k" ]] || continue
    run "delete R2 object $BUCKET/$k" npx wrangler r2 object delete "$BUCKET/$k" --remote
done <<<"$keys"
# https://developers.cloudflare.com/api/resources/r2/subresources/buckets/methods/delete/
run "delete R2 bucket $BUCKET" cf DELETE "/accounts/$ACCOUNT/r2/buckets/$BUCKET"
# https://developers.cloudflare.com/api/resources/d1/subresources/database/methods/delete/
run "delete D1 cairn-907-auth ($D1_ID)" cf DELETE "/accounts/$ACCOUNT/d1/database/$D1_ID"

# 5. The repo: Actions secrets, then the rename, then the archive.
# https://docs.github.com/rest/actions/secrets#delete-a-repository-secret
run "delete Actions secret CLOUDFLARE_API_TOKEN on $REPO" \
    gh api -X DELETE "repos/$REPO/actions/secrets/CLOUDFLARE_API_TOKEN"
run "delete Actions secret CLOUDFLARE_ACCOUNT_ID on $REPO" \
    gh api -X DELETE "repos/$REPO/actions/secrets/CLOUDFLARE_ACCOUNT_ID"
# https://docs.github.com/rest/repos/repos#update-a-repository
run "rename $REPO to glw907/$LEGACY" gh api -X PATCH "repos/$REPO" -f name="$LEGACY"
run "archive glw907/$LEGACY" gh api -X PATCH "repos/glw907/$LEGACY" -F archived=true
run "point the old checkout's origin at glw907/$LEGACY" \
    git -C "$CHECKOUT" remote set-url origin "https://github.com/glw907/$LEGACY.git"

echo
if (( APPLY )); then
    echo "== Teardown finished at $(date -u +%FT%TZ). Tell the observer."
else
    echo "== $step steps. Compare them with the packet, then run: bash $0 --apply"
fi
