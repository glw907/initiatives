#!/usr/bin/env bash
# Stub gh for the e2e-check tests, driven by files under $STUB_GH_DIR:
#   repos        one existing repo name per line
#   roadmap      repos whose origin/main carries ROADMAP.md
#   desc/<repo>  the repo's GitHub description
set -u
d=$STUB_GH_DIR
if [[ $1 == repo && $2 == view ]]; then
  name=${3#*/}
  if ! grep -qxF "$name" "$d/repos"; then
    echo "GraphQL: Could not resolve to a Repository with the name '$3'. (repository)" >&2
    exit 1
  fi
  if [[ ${4:-} == --json ]]; then cat "$d/desc/$name" 2>/dev/null; else echo "$3"; fi
  exit 0
fi
if [[ $1 == api ]]; then
  repo=${2#repos/*/}; repo=${repo%%/*}
  if grep -qxF "$repo" "$d/roadmap"; then echo '{"name":"ROADMAP.md"}'; exit 0; fi
  echo "gh: Not Found (HTTP 404)" >&2
  exit 1
fi
exit 2
