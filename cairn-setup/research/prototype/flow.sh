#!/bin/bash
# Walks the whole flow on fake data in a real kitty and captures each stage.
cd "$(dirname "$0")" || exit 1
out=$PWD/shots/flow
mkdir -p "$out"
kitty-headless-shot -o "$out" -t dark -s 80x24 -c "cd $PWD && ./proto; echo exit=\$?; sleep 600" \
  sleep:2 shot:01-welcome key:enter sleep:1 key:down sleep:0.5 shot:02-theme-survey \
  key:enter sleep:1 shot:03-option key:enter sleep:1 type:Field\ Notes sleep:0.5 shot:04-name \
  key:enter sleep:1 shot:05-crawlers key:enter sleep:1 shot:06-browser-start key:enter sleep:3.5 shot:07-browser \
  sleep:8.5 shot:08-summary key:e sleep:0.5 key:ctrl+u sleep:0.3 type:sam@ sleep:0.3 key:enter sleep:0.5 shot:09-edit-error \
  key:escape sleep:0.5 shot:10-summary-back key:enter sleep:6 shot:11-watch sleep:12 shot:12-done
echo flow-done
kitty-headless-shot -o "$out" -t dark -s 80x24 -c "cd $PWD && ./proto --no-domain; echo exit=\$?; sleep 600" \
  sleep:2 key:enter sleep:0.7 key:enter sleep:0.7 type:Field\ Notes key:enter sleep:0.7 key:enter sleep:0.7 key:enter sleep:4 shot:20-no-domain
kitty-headless-shot -o "$out" -t dark -s 80x24 -c "cd $PWD && ./proto --fail-deploy --several-domains; echo exit=\$?; sleep 600" \
  sleep:2 key:enter sleep:0.7 key:enter sleep:0.7 type:Field\ Notes key:enter sleep:0.7 key:enter sleep:0.7 key:enter sleep:11.5 shot:21-domain-step \
  key:down sleep:0.5 key:enter sleep:0.7 shot:22-summary-chosen key:enter sleep:6 shot:23-fail-deploy
echo flow-extra-done
