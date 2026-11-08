#!/bin/bash
# Captures every screen at 80x24 and 60x24 on dark and light grounds.
cd "$(dirname "$0")" || exit 1
out=$PWD/shots
mkdir -p "$out"
screens=${SCREENS:-$(./proto --screens | awk '{print $1}')}
for s in $screens; do
  for size in 80x24 60x24; do
    for t in dark light; do
      cols=${size%x*}
      kitty-headless-shot -o "$out" -t "$t" -s "$size" -c "cd $PWD && ./proto --screen $s; sleep 600" sleep:2 "shot:$s-$cols-$t" >/dev/null 2>&1 || echo "FAIL $s $size $t"
    done
  done
done
echo done
