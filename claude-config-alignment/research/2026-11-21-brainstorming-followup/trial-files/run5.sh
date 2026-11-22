#!/usr/bin/env bash
# Runs the eleven-case suite six times a case, first on the draft skill, then on the current one.
cd "$(dirname "$0")" || exit 1
run() {
  local start=$SECONDS
  claude plugin eval "./$1" --eval-dir cases-evals --runs 6 --ablation none \
    --judge-model sonnet --trust-plugin --no-publish -j 1 \
    --json "$2.json" --output-dir "$2" --max-cost-usd 12 > "$2.log" 2>&1
  echo "$2 exit=$? seconds=$((SECONDS - start))"
}
run standards-draft sd
run standards sc
