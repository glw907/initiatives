#!/usr/bin/env bash
# Stub approval-queue: writes an item, starts a listener, waits; its EXIT trap removes the item.
# STUB_AQ_MODE: ok | noitem | wrongbuild | noclean
set -u
mode=${STUB_AQ_MODE:-ok}
[[ $mode == noitem ]] && exec sleep 30
id=$(date +%s%N)
dir=$STUB_AQ_STATE/items/$id
mkdir -p "$dir"
printf '{"title":"%s"}\n' "$3" > "$dir/item.json"
[[ $mode == noclean ]] || trap 'rm -rf "$dir"' EXIT
trap 'exit 143' TERM
tag=$STUB_AQ_BUILD
[[ $mode == wrongbuild ]] && tag=/elsewhere
setsid python3 -c 'import os,socket,time
s=socket.socket(); s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
s.bind(("127.0.0.1", int(os.environ["E2E_QUEUE_PORT"]))); s.listen(); time.sleep(60)' "$tag" &
echo $! > "$STUB_AQ_STATE/listener.pid"
while :; do sleep 0.2; done
