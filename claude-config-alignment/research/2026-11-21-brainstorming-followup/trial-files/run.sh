#!/usr/bin/env bash
# run.sh <plugin dir> <result name> [extra flags]: six runs a case, one session at a time.
cd "$(dirname "$0")"
dir=$1; out=$2; shift 2
claude plugin eval "./$dir" --runs 6 --ablation none --model claude-fable-5-2 --judge-model claude-sonnet-5-5 --scaffold \
  --trust-plugin --no-publish -j 1 --json "$out.json" --output-dir "$out" --max-cost-usd 15 "$@" > "$out.log" 2>&1
echo "$out exit=$? $(date +%H:%M:%S)"
